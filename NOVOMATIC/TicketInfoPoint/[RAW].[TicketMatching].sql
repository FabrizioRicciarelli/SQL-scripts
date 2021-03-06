ALTER PROCEDURE [RAW].[TicketMatching]
@Direction Bit,
@ReturnCode Int = 0 Output
AS
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: GA
Creation Date.......: 2016-02-24 
Description.........: Calcola i Delta

Note
- Use [Tab size] = 3 and [Indent size] 3 (Insert spaces)

------------------
-- Parameters   --
------------------	

------------------
-- Call Example --
------------------  

DECLARE @ReturnCode int
EXEC @ReturnCode = [RAW].[TicketMatching] @Direction = 1
Select @ReturnCode

DECLARE @ReturnCode int, @ReturnMessage varchar(1000) 
EXEC @ReturnCode = [Ticket].[Extract_Pomezia]  @ConcessionaryID = 1, @ClubID = 1000432, @Fromdate = '20150211', @ReturnMessage = @ReturnMessage OUTPUT
SELECT @ReturnCode ReturnCode, @ReturnMessage ReturnMessage 

DECLARE @ReturnCode int, @ReturnMessage varchar(1000) 
EXEC @ReturnCode =  [Ticket].[Extract_Pomezia]  @ConcessionaryID = 1,  @TicketCode = '525764475876923475', @ReturnMessage = @ReturnMessage OUTPUT
SELECT @ReturnCode ReturnCode, @ReturnMessage ReturnMessage 
*/
BEGIN
SET NOCOUNT ON;

-- Variabili
DECLARE @Message VARCHAR(1000),@DataInizioImportazione datetime		  
-- Costanti
DECLARE @ServerTime_FIRST datetime = '1900-01-01 00:00:00.000', @ServerTime_Last datetime = '2050-12-31 00:00:00.000', @DailyLoadingType_Delta tinyint = 1,
		  @OffSetOut Int, @OffSetIn Int,  @OffSetMH Int,  @FromServerTime Datetime, @ToServerTime Datetime,
		  @GD Varchar(30) = 'GD016013368',@OffSetImport int = 48,@DataStart Datetime,@TicketDataFrom  Datetime2(3),
		  @TicketDataTo  Datetime2(3),@OutCount Int,@InCount Int,@MhCount Int,@IterationNum TinyInt,@ClubID varchar(10),@MachineID varchar(5),
		  @HourRange Smallint,@TckMaxData Datetime2(3),@TckMinData  Datetime2(3), @TicketDownload BIT, @DDRange SmallInt,@MatchedCount Int,@Msg VARCHAR(1000),@TicketCode Varchar(50),@OutMatched BIT,@InMatched Bit;
DECLARE @ReturnCode2 int, @ReturnMessage varchar(1000),@MatchedCountTotOut Int,@MatchedCountTotIn INT,  @ConcessionaryID TINYINT; 
DECLARE @ProcedureName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) +'.'+QUOTENAME(OBJECT_NAME(@@PROCID)),@BatchID Int;
DECLARE @TableDateRange TABLE(MAX_MIN_TicketData datetime2(3));	

BEGIN TRY
-- Log operazione
Select @TicketCode= TicketCode ,@BatchID = BatchID From [TMP].[TicketStart]
SET @Msg  = 'Matching ticket iniziato'
INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
Select @ProcedureName,@Msg,@TicketCode,@BatchID

--Inizializzo
SELECT @ConcessionaryID = ConcessionaryID FROM Config.[Table]
Set @DataStart = SYSDATETIME()  
SET @IterationNum = 1
SET @TicketDownload = 0
SET @HourRange = 36
SET @OutCount = 0
SET @InCount = 0
SET @DDRange = 2
SET @MatchedCount = 0

Truncate Table [TMP].[DeltaTicketIn]
Truncate Table [TMP].[DeltaTicketOut]
Truncate Table [TMP].[TicketMatched]
Truncate Table [TMP].[Ticket]
TRUNCATE TABLE [RAW].[TicketMatched]

Select @OffSetOut = OffSetOut,@OffSetIn = OffSetIn,@OffSetMH = OffSetMH FROM Config.[Table]

-- Intervallo di calcolo
Select @FromServerTime = FromOut,@ToServerTime = ToOut,@ClubID = ClubID FROM [TMP].CountersCork 

-- Caricamento ticket
--IF NOT EXISTS (Select Top 1 * FROM  [TMP].[Ticket])
--	BEGIN
	-- Primo inserimento ticket indietro
	IF @Direction = 0 
	BEGIN
		 SET @TicketDataTO = Dateadd(DD,1,@ToServerTime) 
		 SET @TicketDataFrom = Dateadd(DD,-@DDRange,@FromServerTime)
	END
	-- Primo inserimento ticket in avanti
	IF @Direction = 1
	BEGIN
		 SET @TicketDataTO = Dateadd(DD,@DDRange,@ToServerTime) 
		 SET @TicketDataFrom = Dateadd(DD,-1,@FromServerTime)
	END
	-- scarico i ticket
	--Select @TicketDataFrom,@TicketDataTO
	EXEC @ReturnCode2 = [Ticket].[Extract_Pomezia] @ConcessionaryID = @ConcessionaryID, @ClubID = @ClubID, @Fromdate = @TicketDataFrom,@ToDate = @TicketDataTO,@IsMhx = 1,  @ReturnMessage = @ReturnMessage OUTPUT
--END


------------------------------
-- Matching TicketOut --
--------------------------------
--Totalout da Matchare

INSERT INTO [TMP].[DeltaTicketOut](RowID,TotalOut,Servertime,MachineID)
SELECT RowID,TotalOut,Servertime,MachineID FROM Tmp.Delta WHERE  TotalOut <> 0 AND TicketCode IS NULL
SET @OutCount = @@ROWCOUNT
-- Massimo un TotalOut
SET @MatchedCountTotOut = 0
-- iterazioni
WHILE  (@IterationNum <= 3) AND (@MatchedCountTotOut < @OutCount)
BEGIN
-- iterazioni successive
	IF @IterationNum = 2 
		BEGIN
			SELECT @OFFSETOUT = @OFFSETOUT * 6
			SELECT @OffSetMH = @OffSetMH * 12
		END
		ELSE IF @IterationNum = 3
		BEGIN
			SELECT @OFFSETOUT = @OFFSETOUT * 10
			SELECT @OffSetMH = @OffSetMH * 3
		END

-- Matching ticket OUT
;WITH CTE_TCK_OUT AS (
	SELECT   TicketCode,ServerTime,MachineID,TicketValue, RANK() OVER  (PARTITION BY TicketValue ORDER BY 
				ABS(datediff(second,ServerTime,PrintingData)) asc) AS RowRank,T1.RowID  AS RowID FROM
							(
			SELECT RowID,TotalOut,Servertime,MachineID FROM [TMP].[DeltaTicketOut]) T1 
					 INNER JOIN TMP.Ticket T2 ON PrintingData Between dateadd(second,-@OffSetOut,ServerTime) 
					 AND dateadd(second,@OffSetOut,ServerTime) AND T1.TotalOut = T2.TicketValue 
					 AND PrintingMachineID = MachineID 
					 -- Escludo quelli già linkati
					 AND TicketCode NOT IN (Select TicketCode FROM [RAW].[TicketMatched] WHERE Out = 1)
							)
	-- inserisco ticket matchati
	INSERT INTO [TMP].[TicketMatched](TicketCode,RowID)
	SELECT   TicketCode,RowID FROM CTE_TCK_OUT WHERE RowRank = 1
	SET @MatchedCount = @@ROWCOUNT
	SET @MatchedCountTotOut += @MatchedCount
	----------------------------------------------------------------
	-- Aggiorna tabella delta --
	----------------------------------------------------------------
	IF @MatchedCount > 0
	BEGIN
		 MERGE [TMP].[Delta] AS target  
			 USING (SELECT TicketCode, RowID FROM [TMP].[TicketMatched]) AS source
			 ON (target.RowID = source.RowID)  
			 WHEN MATCHED THEN  UPDATE SET TicketCode = source.TicketCode
			 OUTPUT inserted.TicketCode,1
			-- salvo i ticket Matchati
			INTO [RAW].[TicketMatched](TicketCode,Out);	
	END
	-- Provo con i pagamenti remoti
	ELSE
	BEGIN
		----------------------------------------------------------------
		-- Matching MH --
		----------------------------------------------------------------
		;WITH CTE_TCK_MH AS (
			SELECT   TicketCode,ServerTime,MachineID,TicketValue, RANK() OVER  (PARTITION BY TicketValue ORDER BY 
						ABS(datediff(second,ServerTime,PrintingData)) asc) AS RowRank,T1.RowID  AS RowID FROM
							 (
					-- scarto i matchati
					SELECT RowID,TotalOut,Servertime,MachineID FROM [TMP].[DeltaTicketOut] 
					) T1 
							 INNER JOIN  TMP.Ticket T2 ON EventDate Between dateadd(second,-@OffSetMH,ServerTime) 
							 AND dateadd(second,@OffSetMH,ServerTime) AND T1.TotalOut = T2.TicketValue 
							 AND MhMachineID = MachineID  AND TicketCode NOT IN (Select TicketCode FROM [RAW].[TicketMatched]
							 WHERE Out = 1)
									)
			-- inserisco ticket matchati
			INSERT INTO [TMP].[TicketMatched](TicketCode,RowID)
			SELECT   TicketCode,RowID FROM CTE_TCK_MH WHERE RowRank = 1
		   SET @MatchedCount = @@ROWCOUNT
			SET @MatchedCountTotOut += @MatchedCount
			----------------------------------------------------------------
			-- Aggiorna tabella delta --
			----------------------------------------------------------------		
			IF @MatchedCount > 0
				BEGIN
					 MERGE [TMP].[Delta] AS target  
						 USING (SELECT TicketCode, RowID FROM [TMP].[TicketMatched]) AS source
						 ON (target.RowID = source.RowID)  
						 WHEN MATCHED THEN  UPDATE SET TicketCode = source.TicketCode
						 OUTPUT inserted.TicketCode,1
						 -- Tabella finale
						 INTO [RAW].[TicketMatched](TicketCode,Out);
				END
			END
----------------------------------------------------------------
----iterazione successiva
----------------------------------------------------------------
	SET @IterationNum += 1
END
--------------------------------
-- Matching TicketIN --
--------------------------------		
SET @IterationNum = 1
SET @MatchedCountTotIn = 0

--TicketIn Da Matchare
INSERT INTO [TMP].[DeltaTicketIN](RowID,TotalTicketIn,Servertime,MachineID)
SELECT RowID,TotalTicketIn,Servertime,MachineID FROM Tmp.Delta WHERE  TotalTicketIN <> 0 AND TicketCode IS NULL
SET @INCount = @@ROWCOUNT

-- Ciclo Iterazioni
WHILE  (@IterationNum <= 3) AND (@MatchedCountTotIn < @InCount)
BEGIN
	-- inizializzo
    Truncate Table [TMP].[TicketMatched]
	SET @MatchedCount = 0
	--iterazioni successive
	IF @IterationNum = 2 
		SELECT @OffSetIn = @OffSetIn * 5
	IF @IterationNum = 3
		SELECT @OffSetIn = @OffSetIn * 10

-- Matching ticket
;WITH CTE_TCK_IN AS (

	SELECT TicketCode,RoWID FROM  [TMP].[DeltaTicketIN] DT

			CROSS APPLY (Select TOP 1 * FROM TMP.Ticket T1 where  PayOutData Between dateadd(second,-@OffSetIn,ServerTime) 
						AND dateadd(second,@OffSetIn,ServerTime) AND DT.TotalTicketIn = T1.TicketValue 
						AND PayoutMachineID = MachineID  
						AND TicketCode NOT IN 
						(Select TicketCode FROM [RAW].[TicketMatched] WHERE Out = 0)
						ORDER BY ABS(datediff(second,dt.ServerTime,t1.PayOutData))) TI
		
	)
	-- inserisco ticket matchati
	INSERT INTO [TMP].[TicketMatched](TicketCode,RowID)
	SELECT   TicketCode,RowID FROM CTE_TCK_IN 
	SET @MatchedCount = @@ROWCOUNT
	SET @MatchedCountTotIn += @MatchedCount

	IF @MatchedCount > 0
	BEGIN
	-- aggiorno delta
			MERGE [TMP].[Delta] AS target  
			USING (SELECT TicketCode, RowID FROM [TMP].[TicketMatched]) AS source
			ON (target.RowID = source.RowID)  
			WHEN MATCHED THEN  UPDATE SET TicketCode = source.TicketCode
			OUTPUT inserted.TicketCode,0
			-- Tabella finale
			INTO [RAW].[TicketMatched](TicketCode,Out);
	END
    
	-- ticketIn Rimanenti da Matchare
	TRUNCATE TABLE [TMP].[DeltaTicketIn]
	INSERT INTO [TMP].[DeltaTicketIn](RowID,TotalTicketIn,Servertime,MachineID)
	SELECT RowID,TotalTicketIn,Servertime,MachineID FROM Tmp.Delta WHERE  TotalTicketIn <> 0 AND TicketCode IS NULL
	
	-- Iterazioni successive
	SET @IterationNum += 1
END

-- Controlli Finali
IF @MatchedCountTotIN = @InCount SET @InMatched  = 1
IF @MatchedCountTotOut = @OutCount SET @OutMatched  = 1

	-- Log operazione
	SET @Msg  = 'Matching ticket terminato'
	INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
	Select @ProcedureName,@Msg,@TicketCode,@BatchID

-- Errore specifico
	IF @InMatched <> 1 OR @OutMatched <> 1
		BEGIN
			SET @Msg = 'Not every ticket has been matched'
			RAISERROR (@Msg,16,1);
		END

	IF @MatchedCountTotIN = 0 AND @MatchedCountTotout = 0
	BEGIN
			SET @Msg = 'None of the tickets has been matched'
			RAISERROR (@Msg,16,1);
	END

END TRY
	-- Gestione Errore
		   BEGIN CATCH
			   --Select ERROR_MESSAGE() 
				EXECUTE [ERR].[UspLogError]  @ErrorTicket = @TicketCode,@ErrorRequestDetailID = @BatchID
				SET @ReturnCode = -1;
		   END CATCH
      
RETURN @ReturnCode
	     	-- fine calcoli 
END