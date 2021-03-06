USE [GMATICA_AGS_RawData_Elaborate_Tip]
GO
/****** Object:  StoredProcedure [RAW].[CalcSession]    Script Date: 06/03/2018 20:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Batch submitted through debugger: SQLQuery3.sql|7|0|C:\Users\GD2B2~1.AND\AppData\Local\Temp\~vsE26F.sql
ALTER PROCEDURE [RAW].[CalcSession]
@Level Int = Null,
@SessionParentID INT NULL,
@ReturnCode Int = 0 OUTPUT
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
Creation Date.......: 2017-05-22
Description.........: Calcola la sessione da Out a Out

Note
- Use [Tab size] = 3 and [Indent size] 3 (Insert spaces)

------------------
-- Parameters   --
------------------	

------------------
-- Call Example --
------------------ 
DECLARE @ReturnCode int
EXEC @ReturnCode =  [RAW].[CalcSession]
SELECT @ReturnCode ReturnCode  

*/
BEGIN
SET NOCOUNT ON;
-- Variabili
DECLARE @Message VARCHAR(1000),@DataInizioImportazione datetime, @DataStart Datetime,@Stringa varchar(100), @ServerTime_Delta datetime, @FromServerTime Datetime,@ToServerTime Datetime,
		  @StartCalculation Datetime,@CalcDurationSS Int,@ClubID varchar(10),@MachineID SmallInt,@SessionID Int, @StartTicketCode Varchar(50),@Msg VARCHAR(1000),@TicketCode Varchar(50),
		  @SessionCalc TINYINT,@GD [VARCHAR](30), @AamsMachineCode [VARCHAR](30),@GameName Varchar(100),@UnivocalLocationCode [VARCHAR](30),
		  @ServerTimeMinVltCredit Datetime,@Direction BIT = NULL,@MinVltEndCredit Int;
DECLARE @ProcedureName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) +'.'+QUOTENAME(OBJECT_NAME(@@PROCID)),@BatchID Int;	
-- Costanti
DECLARE @ServerTime_FIRST datetime = '1900-01-01 00:00:00.000', @ServerTime_Last datetime = '2050-12-31 00:00:00.000', @DailyLoadingType_Delta tinyint = 1;
BEGIN TRY
	 -- Inizio procedura
	Select @TicketCode= TicketCode ,@BatchID = BatchID From [TMP].[TicketStart]
	Select @ServerTimeMinVltCredit = ServerTime FROM  [TMP].[Delta] WHERE TicketCode = @TicketCode
	SET @MinVltEndCredit = (SELECT [MinVltEndCredit] FROM [Config].[Table])
	-- Log operazione
	SET @Msg  = 'Calcolo sessioni iniziato'
	INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
	Select @ProcedureName,@Msg,@TicketCode,@BatchID

	Set @DataStart = SYSDATETIME() 
	SET @SessionCalc = 0 
	-----------------			                   
	-- Inizializzo
	-----------------
	SELECT @MachineID = MachineID,@ClubID  = ClubID  FROM  [TMP].[CountersCork]			
	SELECT @StartTicketCode = TicketCode FROM [TMP].[TicketStart]
	SELECT @GD = [Machine],@AamsMachineCode = AamsMachineCode FROM [dbo].[VLT] WHERE MachineID = @MachineID AND ClubID = @ClubID
	SELECT @UnivocalLocationCode = UnivocalLocationCode FROM dbo.GamingRoom	WHERE ClubID = @ClubID		

	IF @MachineID is Not NULL
	BEGIN
		-- DEBUG
		SELECT	'CALCSESSION - VALUES TO BE WRITTEN IN RAW.SESSION' AS PHASE
				,@StartTicketCode AS StartTicketCode
				,@level AS Level
				,@SessionParentID AS SessionParentID
				,@UnivocalLocationCode AS UnivocalLocationCode
				,@MachineID AS MachineID
				,@GD AS GD
				,@AamsMachineCode AS AamsMachineCode
		SELECT	'CALCSESSION - DATA FROM TMP.DELTA TO BE WRITTEN IN RAW.SESSION'
				,MIN(ServerTime) AS [StartServerTime],MAX(ServerTime) AS [EndServerTime],Count(*)  AS [TotalRows] ,ISNULL(Count([TotalBillIn]),0) AS [TotalBillIn],Count([TotalCoinIN])  AS [TotalCoinIN],Count([TotalTicketIn]) AS [TotalTicketIn],
					ISNULL(SUM(TotalBet),0) AS [TotalBetValue],Count(TotalBet)  AS [TotalBetNum],
					ISNULL(SUM([TotalWon]),0) AS [TotalWinValue],Count([TotalWon]) AS [TotalWinNum],ISNULL(SUM([Tax]),0) AS [Tax],SUM([TotalIn]) AS [TotalIn],
					SUM([TotalOut]) AS [TotalOut],Max(Cast([FlagMinVLtCredit] AS tinyint))
		FROM	[TMP].[Delta] 

	--SELECT COUNT(*) FROM [TMP].[Delta] WHERE TotalIn > 0 AND TicketCode IS NOT NULL
		INSERT INTO [RAW].[Session] ([UnivocalLocationCode],MachineID,GD,[AamsMachineCode],[StartServerTime] ,[EndServerTime] ,[TotalRows] ,[TotalBillIn],[TotalCoinIN]
					  ,[TotalTicketIn] ,[TotalBetValue],[TotalBetNum],[TotalWinValue] ,[TotalWinNum] ,[Tax] ,[TotalIn],[TotalOut],[FlagMinVLtCredit],StartTicketCode,[Level],SessionParentID)
		-- Aggregazione per sessione			 
		Select	@UnivocalLocationCode,@MachineID,@GD,@AamsMachineCode, MIN(ServerTime) AS [StartServerTime],MAX(ServerTime) AS [EndServerTime],Count(*)  AS [TotalRows] ,ISNULL(Count([TotalBillIn]),0) AS [TotalBillIn],Count([TotalCoinIN])  AS [TotalCoinIN],Count([TotalTicketIn]) AS [TotalTicketIn],
					ISNULL(SUM(TotalBet),0) AS [TotalBetValue],Count(TotalBet)  AS [TotalBetNum],
					ISNULL(SUM([TotalWon]),0) AS [TotalWinValue],Count([TotalWon]) AS [TotalWinNum],ISNULL(SUM([Tax]),0) AS [Tax],SUM([TotalIn]) AS [TotalIn],
					SUM([TotalOut]) AS [TotalOut],Max(Cast([FlagMinVLtCredit] AS tinyint)),@StartTicketCode,@level,@SessionParentID 
		FROM [TMP].[Delta] 
	
		SET @SessionCalc = @@RowCount 
		Select @SessionID = Max(SessionID) FROM [RAW].[Session]
	END

	IF @SessionCalc > 0
	BEGIN
	------------------------------------------------------------------------------------------------
	-- Inserisci i delta --
	------------------------------------------------------------------------------------------------
		-- DEBUG
		SELECT	'CALCSESSION - VALUES TO BE WRITTEN IN RAWDELTA' AS PHASE
				,@SessionID AS SessionID
		SELECT	'CALCSESSION - DATA FROM TMP.DELTA TO BE WRITTEN IN RAW.DELTA'
				,RowID,[UnivocalLocationCode],[ServerTime],[MachineID],[GD],[AamsMachineCode],[GameID],[GameName],[VLTCredit] ,[TotalBet] ,[TotalWon]
				,[TotalBillIn] ,[TotalCoinIn],[TotalTicketIn],[TotalHandPay],[TotalTicketOut],[Tax]
				,[TotalIn],[TotalOut],[TicketCode],NULL
		FROM	[TMP].[Delta] 

		INSERT INTO [RAW].[Delta]  (RowID ,[UnivocalLocationCode],[ServerTime],[MachineID],[GD],[AamsMachineCode],[GameID],[GameName],[VLTCredit],[TotalBet] ,[TotalWon]
						,[TotalBillIn],[TotalCoinIn] ,[TotalTicketIn] ,[TotalHandPay],[TotalTicketOut] ,[Tax] ,[TotalIn]
						,[TotalOut] ,[TicketCode],[FlagMinVLtCredit],[SessionID])

		SELECT RowID,[UnivocalLocationCode],[ServerTime],[MachineID],[GD],[AamsMachineCode],[GameID],[GameName],[VLTCredit] ,[TotalBet] ,[TotalWon]
				,[TotalBillIn] ,[TotalCoinIn],[TotalTicketIn],[TotalHandPay],[TotalTicketOut],[Tax]
				,[TotalIn],[TotalOut],[TicketCode],NULL,@SessionID 
		FROM	[TMP].[Delta]
		ORDER BY Servertime ASC,MAchineID ASC

		--IIF((VltCredit <= @MinVltEndCredit) AND (ISNULL(TotalOut,0) = 0) 
		--				AND  (@Direction = 1 AND ServerTime > @ServerTimeMinVltCredit) OR  (@Direction = 0 AND ServerTime < @ServerTimeMinVltCredit)
		--				,1,0)
	END

	--- fine procedura
	-- Log operazione
	SET @Msg  = 'Calcolo sessioni terminato'
	INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
	Select @ProcedureName,@Msg,@TicketCode,@BatchID

	-- Errore specifico
	IF @SessionCalc <> 1
		BEGIN
			SET @Msg = 'Session has not been calculated'
			RAISERROR (@Msg,16,1);
		END

END TRY
	-- Gestione Errore
		   BEGIN CATCH
				SELECT @BatchID = [BatchID] FROM [TMP].[TicketStart]
				EXECUTE [ERR].[UspLogError]  @ErrorTicket = @TicketCode,@ErrorRequestDetailID = @BatchID
            SET @ReturnCode = -1;
       END CATCH
      
RETURN @ReturnCode
	-- fine calcoli
END
