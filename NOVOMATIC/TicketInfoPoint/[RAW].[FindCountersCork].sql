ALTER PROCEDURE [RAW].[FindCountersCork]
@Direction BIT,
@TicketCode Varchar(50),
@ClubID varchar(10) = NULL,
@ReturnCode Int = 0 Output,
@BatchID Int
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
Creation Date.......: 2017-01-30
Description.........: Calcola i valori di tutti i contatori non nulli precedenti all'ultimo calcolo dei delta effettuato

Revision			 
GA 2017-01-30..: Aggiunto creazione tappo caso senza riavvi, controlli (VltDismesse, Aggiornamento contatori,IsReadyForCork)
Note
- Use [Tab size] = 2 and [Indent size]

------------------
-- Parameters   --
------------------	

------------------
-- Call Example --
------------------
DECLARE @ReturnCode int
EXEC @ReturnCode =   [RAW].[FindCountersCork]  @TicketCode = '559560578403882054',@Direction = 0,@BatchID = 1
SELECT @ReturnCode  
*/
BEGIN
SET NOCOUNT ON;

BEGIN TRY
	DECLARE @TableMaxCounters TABLE (TotalBet bigint, TotalWon bigint, WinD bigint, TotalBillIn bigint, TotalCoinIn bigint, TotalTicketIn bigint, TotalTicketOut bigint, TotalHandPay bigint, TotalOut bigint, TotalIn bigint);
	-- Variabili
	DECLARE @Message VARCHAR(1000),@PayOutData Datetime, @FromServerTimeOut Datetime, @OFFSET INT,@ReturnMessage2  varchar(1000);
	DECLARE @ServerTimeMaxCounters Datetime,@Stringa Varchar(500), @FromServerTime Datetime,@FromServerTimeIN Datetime,@ToServerTime Datetime,@ReturnCode2 int,@IspaidCashdesk BIT,
			  @RestartTime Datetime,@CalcDurationSS Int,@ServerTime Datetime,@DataStart Datetime, @ConcessionaryID TinyInt,@PrintingData Datetime2(0),@IsprintingCashDesk Bit;
	DECLARE @FromOut Datetime = NULL,@ToOut Datetime = NULL, @OFFSETOUT SmallInt = 3600, @MachineID SmallInt,@Msg VARCHAR(1000),@TicketValue INT,@OffSetIN Int,@ReturnCodeCreateView INT;
	-- Costanti
	DECLARE @ServerTime_FIRST datetime = '1900-01-01 00:00:00.000', @ServerTime_Last datetime = '2050-12-31 00:00:00.000', @ViewString Varchar(5000);	
	DECLARE @ProcedureName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + '.' + QUOTENAME(OBJECT_NAME(@@PROCID));
------------------------------------------------------
-- Calcolo VLT       --
------------------------------------------------------
-- Inizializzo
TRUNCATE TABLE [TMP].[CountersCork]
TRUNCATE TABLE [TMP].[TicketServerTime]
IF @TicketCode <> '8000572HPV201705180001'
TRUNCATE TABLE [TMP].[TicketStart]
SET @IspaidCashdesk = 0	
SET @ISPrintingCashdesk = 0	
SET @ReturnCodeCreateView = 0

Select @OffSet = (OffSetOut*1000) FROM Config.[Table]
Select @OffSetIn = (OffSetIn*1000) FROM Config.[Table]
SET @ServerTime = NULL
Set @DataStart = SYSDATETIME()
--SET @NumRecord = 0
SELECT @ConcessionaryID = ConcessionaryID FROM Config.[Table]

-- Log operazione
SET @Msg  = 'Calcolo tappo iniziato'
INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
Select @ProcedureName,@Msg,@TicketCode,@BatchID

--Prendo i dati del ticket MH di partenza
EXEC @ReturnCode2 =  [Ticket].[Extract_Pomezia]  @ConcessionaryID = @ConcessionaryID ,  @TicketCode = @TicketCode ,@ClubID = @ClubID, @ReturnMessage = @ReturnMessage2 OUTPUT
--SELECT @ReturnCode ReturnCode, @ReturnMessage ReturnMessage 

-- Selezioni il clubID e creo la vista
SELECT @ClubID = ClubID From [TMP].[TicketStart]
SELECT @ViewString = (Select OBJECT_DEFINITION (OBJECT_ID(N'[Tmp].RawData_View')))
	IF (NOT @ViewString Like   '%![' + @ClubID + '!]%' ESCAPE '!') OR @ViewString IS NULL
		EXEC @ReturnCodeCreateView =  [RAW].[CreateNewViewRawID] @ClubID =  @ClubID

IF @ReturnCodeCreateView = 1 
	BEGIN
		SET @ReturnCode = 2
		RETURN @ReturnCode
	END
-- Errore specifico
IF (Select Count(*) FROM [TMP].[TicketStart]) <> 1 
BEGIN
		SET @Msg = 'Numero ticket di partenza errato'
		RAISERROR (@Msg,16,1);
END

	-- Tracking indietro 
	IF @Direction  = 0
	BEGIN
		-- PrintingData
		SELECT @PrintingData = [PrintingData],@ClubID = ClubID,@MachineID = PrintingMachineID,@IsprintingCashDesk = ISNULL(IsprintingCashDesk,0),
				 @TicketValue = TicketValue FROM [TMP].[TicketStart]
      IF @IsprintingCashDesk = 0
		BEGIN
		-- Controlla se MH o ticket----
		IF @PrintingData IS NULL 
		BEGIN
			SELECT @PrintingData = EventDate,@ClubID = ClubID,@MachineID = MhMachineID,@TicketValue = TicketValue FROM [TMP].[TicketStart]
			SELECT @OffSet = OffSetMH*50 FROM Config.[Table]
		END	
		--creo indici
		--EXEC [Raw].[CreateIndex] @Clubid, @PrintingData
			 -- totalout nell'offset
		;WITH CteTotalOut AS (Select Servertime,
											 TotalOut - LAG(TotalOut,1,0) OVER ( ORDER BY Servertime) AS TotalOut FROM [TMP].[RawData_View] 
											 WHERE ServerTime < dateadd(second,@OffSet,@PrintingData)  
											 AND ServerTime > dateadd(second,-@OffSet,@PrintingData)  AND MachineID = @MachineID
											 AND TotalOut > 0
							)
							,CteTotalOut2 AS
		(SELECT TotalOut,ServerTime,ROW_NUMBER() OVER (ORDER BY datediff(SS,@PrintingData,ServerTime) desc) rn FROM CteTotalOut 
				  WHERE TotalOut = @TicketValue)
	    -- servertime più vicino al payout
		-- SELECT * FROM  CteTotalOut2 
		SELECT @ToOut = ServerTime FROM CteTotalOut2 where rn = 1
		-- per la sessione minore di 50
		INSERT INTO [TMP].[TicketServerTime]([ServerTime],Direction)
		SELECT @ToOut,@Direction
		
		SET @FromServerTimeOut = (Select Max(servertime) FROM [TMP].[RawData_View]  WHere TotalOut > 0 AND MachineID = @MachineID AND LoginFlag = 0 AND ServerTime < @ToOut)
			IF @FromServerTimeOut IS NULL 
			BEGIN
				SET @FromServerTimeOut =  ISNULL((Select Max(servertime) FROM [TMP].[RawData_View]  WHere LoginFlag = 1 AND MachineID = @MachineID  AND ServerTime < @ToOut),@ServerTime_FIRST)
			END
		-- reset/restart
		SET @RestartTime = ISNULL((Select Max(servertime) FROM [TMP].[RawData_View]  WHere LoginFlag = 1 AND MachineID = @MachineID  AND ServerTime < @FromServerTimeOut),@ServerTime_FIRST)
			-- calcolo contatori
		INSERT INTO @TableMaxCounters(TotalBet, TotalWon,  WinD, TotalBillIn , TotalCoinIn , TotalTicketIn , TotalTicketOut , TotalHandPay, TotalOut, TotalIn)
		SELECT
					 ISNULL(MAX(TotalBet),0),
					 ISNULL(MAX(TotalWon),0),
					 ISNULL(MAX(WinD),0),
					 ISNULL(MAX(TotalBillIn),0),
					 ISNULL(MAX(TotalCoinIn),0),
					 ISNULL(MAX(TotalTicketIn),0),
					 ISNULL(MAX(TotalTicketOut),0),
					 ISNULL(MAX(TotalHandPay),0),
					 ISNULL(MAX(TotalOut),0),
					 ISNULL(MAX(TotalIn),0)
					 FROM [TMP].[RawData_View]
					 WHERE ServerTime Between @RestartTime AND @FromServerTimeOut AND  MachineID = @MachineID 
		   --Aggiorno i contatori
			INSERT [TMP].[CountersCork]  (ClubID, MachineID, FromOut,ToOut,TotalBet, TotalWon, WinD, TotalBillIn, TotalCoinIn, TotalTicketIn, TotalTicketOut, TotalHandPay, TotalOut, TotalIn)
			SELECT @ClubID, @MachineID,@FromServerTimeOut,@ToOut, TMCN.TotalBet, TMCN.TotalWon,  TMCN.WinD, TMCN.TotalBillIn , TMCN.TotalCoinIn , TMCN.TotalTicketIn , TMCN.TotalTicketOut , TMCN.TotalHandPay, TMCN.TotalOut, TMCN.TotalIn
				   FROM @TableMaxCounters AS  TMCN	
	
			-- Errore specifico
			IF NOT EXISTS (Select * From [TMP].[CountersCork])
				BEGIN
				SET @Msg = 'Empty table [TMP].[CountersCork]'
				RAISERROR (@Msg,16,1);
			END
		END 
	ELSE 
		SET @ReturnCode = 1	
		--SELECT @FromServerTimeOut,@ToOut
	END
	-- Tracking in avanti -- va preso il serverTime di IN di questo ticket
	IF @Direction = 1

	BEGIN
	-- date di inizio e fine
		SELECT @PayOutData = [PayOutData],@MachineID = PayOutMachineID,@TicketValue = TicketValue,@IspaidCashdesk = ISNULL(IsPaidCashDesk,0) FROM [TMP].[TicketStart]
		IF @MachineID IS NOT NULL AND @IspaidCashdesk = 0
		BEGIN
			 --creo indici
			--EXEC [Raw].[CreateIndex] @Clubid, @PayOutData
			 -- totalout nell'offset
			;WITH CteTotalIn AS (Select Servertime,
												 TotalIn - LAG(TotalIn,1,0) OVER ( ORDER BY Servertime) AS TotalIn FROM [TMP].[RawData_View] 
												 WHERE ServerTime < dateadd(second,@OffSetIN,@PayOutData)  
												 AND ServerTime > dateadd(second,-@OffSetIN,@PayOutData)  AND MachineID = @MachineID
												 AND TotalIn > 0
								)
								,CteTotalIn2 AS
			(SELECT TotalIn,ServerTime,ROW_NUMBER() OVER (ORDER BY datediff(SS,@PayOutData,ServerTime) desc) rn FROM CteTotalIn 
					WHERE TotalIn = @TicketValue)
			 -- servertime più vicino al payout
			Select @FromServerTimeIN = ServerTime FROM CteTotalIn2 where rn = 1
			SET @FromServerTimeIN = ISNULL(@FromServerTimeIN,@ServerTime_FIRST)
			-- per la sessione minore di 50
			INSERT INTO [TMP].[TicketServerTime]([ServerTime],Direction)
			SELECT @FromServerTimeIN,@Direction

			-- Primo out precedente all'IN - se non ci sono out prendoil restart
			SET @FromServerTimeOut = (Select Max(servertime) FROM [TMP].[RawData_View]  WHere TotalOut > 0 AND MachineID = @MachineID AND LoginFlag = 0 AND ServerTime < @FromServerTimeIN)
				IF @FromServerTimeOut IS NULL 
				BEGIN
					SET @FromServerTimeOut =  ISNULL((Select Max(servertime) FROM [TMP].[RawData_View]  WHere LoginFlag = 1 AND MachineID = @MachineID  AND ServerTime < @FromServerTimeIN),@ServerTime_FIRST)
				END
			-- reset/restart
			SET @RestartTime = ISNULL((Select Max(servertime) FROM [TMP].[RawData_View]  WHere LoginFlag = 1 AND MachineID = @MachineID  AND ServerTime < @FromServerTimeOut),@ServerTime_FIRST)
			-- fino al prossimo out
			SET @ToOut= ISNULL((Select MIN(Servertime) FROM  [TMP].RawData_View where TotalOut > 0 AND MachineID = @MachineID AND LoginFlag = 0 AND ServerTime > @FromServerTimeOut),@ServerTime_Last)
	
	--SELECT @FromServerTimeIN,@RestartTime,@FromServerTimeOut,@ToOut
	
		-- calcolo contatori
		INSERT INTO @TableMaxCounters(TotalBet, TotalWon,  WinD, TotalBillIn , TotalCoinIn , TotalTicketIn , TotalTicketOut , TotalHandPay, TotalOut, TotalIn)
		SELECT
					 ISNULL(MAX(TotalBet),0),
					 ISNULL(MAX(TotalWon),0),
					 ISNULL(MAX(WinD),0),
					 ISNULL(MAX(TotalBillIn),0),
					 ISNULL(MAX(TotalCoinIn),0),
					 ISNULL(MAX(TotalTicketIn),0),
					 ISNULL(MAX(TotalTicketOut),0),
					 ISNULL(MAX(TotalHandPay),0),
					 ISNULL(MAX(TotalOut),0),
					 ISNULL(MAX(TotalIn),0)
					 FROM [TMP].[RawData_View]
					 WHERE ServerTime Between @RestartTime AND @FromServerTimeOut AND  MachineID = @MachineID 
		   --Aggiorno i contatori
			INSERT [TMP].[CountersCork]  (ClubID, MachineID, FromOut,ToOut,TotalBet, TotalWon, WinD, TotalBillIn, TotalCoinIn, TotalTicketIn, TotalTicketOut, TotalHandPay, TotalOut, TotalIn)
			SELECT @ClubID, @MachineID,@FromServerTimeOut,@ToOut, TMCN.TotalBet, TMCN.TotalWon,  TMCN.WinD, TMCN.TotalBillIn , TMCN.TotalCoinIn , TMCN.TotalTicketIn , TMCN.TotalTicketOut , TMCN.TotalHandPay, TMCN.TotalOut, TMCN.TotalIn
				   FROM @TableMaxCounters AS  TMCN	
	
			-- Errore specifico
			IF NOT EXISTS (Select * From [TMP].[CountersCork])
				BEGIN
				SET @Msg = 'Empty table [TMP].[CountersCork]'
				RAISERROR (@Msg,16,1);
			END
		END 
	ELSE SET @ReturnCode = 1		
	END
	   				
	-- Verifiche finali
	SET @Msg  = 'Calcolo tappo terminato'
	INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
	Select @ProcedureName,@Msg,@TicketCode,@BatchID

	END TRY
		-- Gestione Errore
				BEGIN CATCH
				Select ERROR_MESSAGE ( )   
					EXECUTE [ERR].[UspLogError]  @ErrorTicket = @TicketCode,@ErrorRequestDetailID  = @BatchID
					SET @ReturnCode = -1;
			 END CATCH
      
	RETURN @ReturnCode

END
