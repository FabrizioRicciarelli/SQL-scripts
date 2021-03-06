USE [GMATICA_AGS_RawData_Elaborate_Stag_Agile]
GO
/****** Object:  StoredProcedure [RAW].[CalcSession2]    Script Date: 17/07/2017 10:13:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: GA, FR
Creation Date.......: 2017-05-22
Last revision Date..: 2017-07-06
Description.........: Calcola la sessione da Out a Out

Note
- Use [Tab size] = 3 and [Indent size] 3 (Insert spaces)

------------------
-- Parameters   --
------------------	
@Level Int = Null
@ReturnCode Int = 0 OUTPUT

------------------
-- Call Example --
------------------ 
DECLARE	@ReturnCode int
EXEC	@ReturnCode =  
		[RAW].[CalcSession2]
		@Level = NULL
		,@TicketCode = '4412211590049855'
		,@BatchID = 1
		,@ReturnCode = @ReturnCode OUTPUT
SELECT	@ReturnCode ReturnCode  

-- Svuotamento tabelle di log: errori ed operazioni
-- (solo i dati relativi alla giornata odierna)
EXEC DeleteTodayErrorLog
EXEC DeleteTodayOperationLog

-- Letture tabelle di log: errori ed operazioni
-- (solo i dati relativi alla giornata odierna)
SELECT * FROM dbo.VTodayErrorLog ORDER BY ErrorTime DESC
SELECT * FROM dbo.VTodayOperationLog ORDER BY OperationTime DESC

*/
ALTER PROC	[RAW].[CalcSession2]
			@Level Int = Null
			,@TicketCode varchar(50)
			,@BatchID int
			,@ReturnCode Int = 0 Output
AS
---------------------
-- CODICE RIVISITATO
---------------------
SET NOCOUNT ON;
-- Variabili
DECLARE
		@Message VARCHAR(1000)
		,@DataInizioImportazione datetime
		,@DataStart Datetime2(3)
		,@Stringa varchar(100)
		,@ServerTime_Delta datetime
		,@FromServerTime Datetime2(3)
		,@ToServerTime Datetime2(3)
		,@StartCalculation datetime2(3)
		,@CalcDurationSS Int
		,@ConcessionaryID tinyint
		,@ConcessionaryName sysname
		,@ClubID varchar(10)
		,@MachineID SmallInt
		,@SessionID Int
		,@StartTicketCode Varchar(50)
		,@Msg VARCHAR(1000)
		,@SessionCalc TINYINT
		,@GD [VARCHAR](30)
		,@AamsMachineCode VARCHAR(30)
		,@GameName Varchar(100)
		,@UnivocalLocationCode VARCHAR(30)
		,@ServerTimeMinVltCredit Datetime2(3)
		,@Direction BIT = NULL
		,@MinVltEndCredit Int
		,@ProcedureName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + '.' + QUOTENAME(OBJECT_NAME(@@PROCID))
		,@ServerTime_FIRST datetime = '1900-01-01 00:00:00.000'
		,@ServerTime_Last datetime = '2050-12-31 00:00:00.000'
		,@DailyLoadingType_Delta tinyint = 1
		,@TicketList TICKETLIST_TYPE
		,@Tickets TICKET_TYPE

BEGIN TRY
	--------------------		                   
	-- Inizializzazione
	--------------------
	SELECT	
			@MinVltEndCredit = MinVltEndCredit 
			,@ConcessionaryID = ConcessionaryID 
			,@ConcessionaryName = ConcessionaryName
	FROM	[Config].[Table]

	INSERT	@TicketList(TicketCode) 
	VALUES (@TicketCode)
	
	INSERT	@Tickets
	EXEC	dbo.GetRemoteTickets
			@LOCALConcessionaryID = @ConcessionaryID
			,@LOCALClubID = @ClubID
			,@LOCALTicketList = @TicketList
			,@LOCALFromDate = @ServerTime_FIRST
			,@LOCALToDate = @ServerTime_Last
			,@LOCALIsMhx = 1
			,@ReturnMessage = NULL

	SELECT	@StartTicketCode = TicketCode 
	FROM	@Tickets

	SELECT	@Direction = Direction 
	FROM	[TMP].[TicketServerTime]

	SELECT	@ServerTimeMinVltCredit = ServerTime 
	FROM	[TMP].[Delta] 
	WHERE	TicketCode = @TicketCode

	SELECT	
			@MachineID = MachineID
			,@ClubID  = ClubID  
	FROM	[TMP].[CountersCork]
				
	SELECT	
			@GD = [Machine]
			,@AamsMachineCode = AamsMachineCode 
	FROM	[dbo].[VLT]
	
	SELECT	@UnivocalLocationCode = UnivocalLocationCode 
	FROM	[dbo].[GamingRoom]			

	
	-- Log operazione
	EXEC spWriteOpLog @ProcedureName, 'Calcolo sessioni iniziato', @TicketCode, @BatchID

	SELECT	
			@DataStart = SYSDATETIME() 
			,@SessionCalc = 0 


	IF @MachineID is Not NULL
	BEGIN
		INSERT	[RAW].[Session] 
				(
					UnivocalLocationCode
					,MachineID
					,GD
					,AamsMachineCode
					,StartServerTime 
					,EndServerTime 
					,TotalRows 
					,TotalBillIn
					,TotalCoinIN
					,TotalTicketIn 
					,TotalBetValue
					,TotalBetNum
					,TotalWinValue 
					,TotalWinNum 
					,Tax 
					,TotalIn
					,TotalOut
					,FlagMinVLtCredit
					,StartTicketCode
					,[Level]
				)
		-- Aggregazione per sessione			 
		SELECT
				@UnivocalLocationCode
				,@MachineID
				,@GD
				,@AamsMachineCode
				,MIN(ServerTime) AS StartServerTime
				,MAX(ServerTime) AS EndServerTime
				,COUNT(*) AS TotalRows 
				,ISNULL(COUNT(TotalBillIn),0) AS TotalBillIn
				,COUNT(TotalCoinIN) AS TotalCoinIN
				,COUNT(TotalTicketIn) AS TotalTicketIn
				,ISNULL(SUM(TotalBet),0) AS TotalBetValue
				,COUNT(TotalBet) AS TotalBetNum
				,ISNULL(SUM(TotalWon),0) AS TotalWinValue
				,COUNT(TotalWon) AS TotalWinNum
				,ISNULL(SUM(Tax),0) AS Tax
				,SUM(TotalIn) AS TotalIn
				,SUM(TotalOut) AS TotalOut
				,MAX(CAST(FlagMinVLtCredit AS tinyint))
				,@StartTicketCode
				,@level 
		FROM	[TMP].[Delta] 

		SELECT
				@SessionCalc = @@RowCount
	
		SELECT	@SessionID = MAX(SessionID) 
		FROM	[RAW].[Session]
	END

	IF @SessionCalc > 0
	BEGIN
	---------------------------
	-- Inserimento dei Delta --
	---------------------------
		INSERT	[RAW].[Delta]  
				(
					RowID 
					,UnivocalLocationCode
					,ServerTime
					,MachineID
					,GD
					,AamsMachineCode
					,GameID
					,GameName
					,VLTCredit
					,TotalBet 
					,TotalWon
					,TotalBillIn
					,TotalCoinIn 
					,TotalTicketIn 
					,TotalHandPay
					,TotalTicketOut 
					,Tax 
					,TotalIn
					,TotalOut 
					,TicketCode
					,FlagMinVLtCredit
					,SessionID
				)

		SELECT
				RowID
				,[UnivocalLocationCode]
				,[ServerTime]
				,[MachineID]
				,[GD]
				,[AamsMachineCode]
				,[GameID]
				,[GameName]
				,[VLTCredit] 
				,[TotalBet] 
				,[TotalWon]
				,[TotalBillIn] 
				,[TotalCoinIn]
				,[TotalTicketIn]
				,[TotalHandPay]
				,[TotalTicketOut]
				,[Tax]
				,[TotalIn]
				,[TotalOut]
				,[TicketCode]
				,IIF
				(
					(VltCredit <= @MinVltEndCredit) AND 
					(ISNULL(TotalOut,0) = 0) AND  
					(
						@Direction = 1 AND 
						ServerTime > @ServerTimeMinVltCredit
					) OR  
					(
						@Direction = 0 AND 
						ServerTime < @ServerTimeMinVltCredit
					)
					,1
					,0
					
				)
				,@SessionID 
		FROM	[TMP].[Delta] WITH(NOLOCK)
				ORDER BY Servertime ASC,MAchineID ASC
	END

-- Log operazione
EXEC spWriteOpLog @ProcedureName, 'Calcolo sessioni terminato', @TicketCode, @BatchID

-- Errore specifico
IF @SessionCalc <> 1
	BEGIN
		SET @Msg = 'Session has not been calculated'
		RAISERROR (@Msg,16,1);
	END

END TRY

-- Gestione Errore
BEGIN CATCH
	EXECUTE	[ERR].[UspLogError]  
			@ErrorTicket = @TicketCode
			,@ErrorRequestDetailID = @BatchID
	
	SET @ReturnCode = -1;
END CATCH
      
RETURN @ReturnCode
