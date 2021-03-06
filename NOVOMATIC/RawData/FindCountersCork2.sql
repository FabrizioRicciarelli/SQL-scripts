/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: GA, FR
Creation Date.......: 2017-01-30
Last revision Date..: 2017-07-05
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
DECLARE	@ReturnCode int
EXEC	[RAW].[FindCountersCork2] 
		@TicketCode = '4412211590049855'
		,@Direction = 1 -- 0 = Tracciamento a ritroso, 1 = Tracciamento in avanti
		,@ClubID = '1000296'
		,@ReturnCode = @ReturnCode OUTPUT
SELECT	@ReturnCode AS ReturnCode 

SELECT * FROM [TMP].[TicketServerTime] WITH(NOLOCK)
SELECT * FROM [TMP].[CountersCork] WITH(NOLOCK)

SELECT * FROM dbo.VTodayErrorLog ORDER BY ErrorTime DESC

*/
ALTER PROC	[RAW].[FindCountersCork2]
			@TicketCode varchar(50)
			,@Direction bit
			,@ClubID varchar(10)
			,@ReturnCode int = 0 OUTPUT
AS
SET NOCOUNT ON;

DECLARE 
		@Message varchar(1000)
		,@ServerTimeMaxCounters datetime2(3)
		,@Stringa varchar(500)
		,@FromServerTime Datetime2(3)
		,@ToServerTime Datetime2(3)
		,@RestartTime Datetime2(3)
		,@CalcDurationSS int
		,@CtnNumbered int
		,@UpdateCalc bit
		,@GD varchar(30)
		,@Msg varchar(1000)
		,@ConcessionaryID tinyint
		,@ConcessionaryName sysname
		,@BatchID int
		,@FromOut datetime2(3) = NULL
		,@ToOut datetime2(3) = NULL
		,@OFFSETOUT smallint = 3600
		,@MachineID smallint
		,@ServerTime_FIRST datetime = '1900-01-01 00:00:00.000'
		,@ServerTime_LAST datetime = '2050-12-31 00:00:00.000'
		,@criteria varchar(4000)
		,@ProcedureName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + '.' + QUOTENAME(OBJECT_NAME(@@PROCID))
		,@TMP sql_variant

		,@TicketList TICKETLIST_TYPE
		,@Tickets TICKET_TYPE

DECLARE @RawData TABLE
		(
			ServerTime datetime
			,TotalBet int NULL
			,TotalWon int NULL
			,WinD int NULL
			,TotalBillIn int NULL
			,TotalCoinIn int NULL
			,TotalTicketIn int NULL
			,TotalTicketOut int NULL
			,TotalHandPay int NULL
			,TotalOut int NULL
			,TotalIn int NULL
		)

DECLARE	@TableMaxCounters TABLE 
		(
			TotalBet bigint
			,TotalWon bigint
			,WinD bigint
			,TotalBillIn bigint
			,TotalCoinIn bigint
			,TotalTicketIn bigint
			,TotalTicketOut bigint
			,TotalHandPay bigint
			,TotalOut bigint
			,TotalIn bigint
		)
DECLARE	@TableNumbered TABLE
		(
			Col varchar(50)
			,[Value] bigint
			,ServerTime datetime2(3) 
			,Rn int
		)

BEGIN TRY

	------------------
	-- Calcolo VLT      
	------------------

	-- Inizializzazione
	SET @ReturnCode = 0
	TRUNCATE TABLE [TMP].[CountersCork]

	-- Log operazione
	EXEC spWriteOpLog @ProcedureName, 'Calcolo tappo Ticket Code iniziato', @TicketCode, @BatchID

	SELECT	TOP 1
			@ConcessionaryID = ConcessionaryID 
			,@ConcessionaryName = ConcessionaryName
	FROM	[Config].[Table] WITH(NOLOCK)

	INSERT	@TicketList(TicketCode) 
	VALUES (@TicketCode)
	
	INSERT	@Tickets
	EXEC	dbo.GetRemoteTickets
			 @LOCALConcessionaryID = @ConcessionaryID
			,@LOCALClubID = @ClubID
			,@LOCALTicketList = @TicketList
			,@LOCALFromDate = @ServerTime_FIRST
			,@LOCALToDate = @ServerTime_LAST
			,@LOCALIsMhx = 0
			,@ReturnMessage = NULL

	-- Tracking a ritroso 
	IF @Direction = 0
		BEGIN
			-- date di inizio e fine
			SELECT
					@MachineID = ISNULL(PrintingMachineID, MhMachineID)
					,@ClubID  = ClubID  
			FROM	@Tickets
			
			SELECT 
					@ToOut =  ISNULL(ServerTime, @ServerTime_FIRST)
			FROM	[TMP].[TicketServerTime] WITH(NOLOCK)
			
			SET @criteria = 
			'
			AND		TotalOut > 0 
			AND		MachineID = ' + CAST(@MachineID AS varchar(4)) + '
			AND		LoginFlag = 0 
			AND		ServerTime < ''' + CAST(@ToOut AS varchar(30)) + ''' 
			'
			EXEC	dbo.GetRawDataScalar
					@ConcessionaryName
					,@ClubID
					,'MAX(ServerTime) AS ServerTime' -- Set di colonne specifico
					,@criteria
					,@TMP OUTPUT
			SELECT	@FromOut = ISNULL(CAST(@TMP AS datetime), @ServerTime_FIRST)
		END 
	
	-- Tracking in avanti -- va preso il serverTime di IN di questo ticket
	IF @Direction = 1
		BEGIN
			-- date di inizio e fine
			SELECT
					@MachineID = PayOutMachineID
					,@ClubID  = ClubID  
			FROM	@Tickets
			
			SELECT	@FromOut = ISNULL(ServerTime, @ServerTime_Last)
			FROM	[TMP].[TicketServerTime] WITH(NOLOCK)

			SET @criteria = 
			'
			AND		TotalOut > 0 
			AND		MachineID = ' + CAST(@MachineID AS varchar(4)) + '
			AND		LoginFlag = 0 
			AND		ServerTime > ''' + CAST(@FromOut AS varchar(30)) + ''' 
			'
			EXEC	dbo.GetRawDataScalar
					@ConcessionaryName
					,@ClubID
					,'MIN(ServerTime) AS ServerTime' -- Set di colonne specifico
					,@criteria
					,@TMP OUTPUT
			SELECT	@ToOut = ISNULL(CAST(@TMP AS datetime), @ServerTime_LAST)
		END

	-- Verifica se ci sono gli estremi per effettuare il calcolo
	IF	@FromOut <> @ServerTime_Last
	AND @ToOut <> @ServerTime_FIRST
		--Calcoli
		BEGIN
			-- Ultimo riavvio prima dei calcoli
			SET @criteria = 
			'
			AND		MachineID = ' + CAST(@MachineID AS varchar(4)) + '
			AND		ServerTime <= ''' + CAST(@FromOut AS varchar(30)) + ''' 
			AND		LoginFlag = 1 
			AND		TotalBet IS NOT NULL 
			AND		TotalWon IS NOT NULL 
			AND		WinD IS NOT NULL 
			AND		TotalBillIn IS NOT NULL 
			AND		TotalCoinIn IS NOT NULL 
			AND		TotalTicketIn IS NOT NULL 
			AND		TotalTicketOut IS NOT NULL 
			AND		TotalHandPay IS NOT NULL 
			AND		TotalOut IS NOT NULL 
			AND		TotalIn IS NOT NULL
			'
			EXEC	dbo.GetRawDataScalar
					@ConcessionaryName
					,@ClubID
					,'MAX(ServerTime) AS ServerTime' -- Set di colonne specifico
					,@criteria
					,@TMP OUTPUT
			SELECT	@RestartTime = ISNULL(CAST(@TMP AS datetime), @ServerTime_FIRST)

			IF @RestartTime <> @ServerTime_FIRST 
				BEGIN											

					SET @criteria = 
					'
					AND		(ServerTime BETWEEN ''' +  CAST(@RestartTime AS varchar(30)) + ''' AND ''' + CAST(@FromOut AS varchar(30)) + ''')
					AND		MachineID = ' + CAST(@MachineID AS varchar(4)) + '
					'
					DELETE	FROM @RawData
					INSERT	@RawData
					EXEC	GetRemoteSpecificRawData
							@ConcessionaryName
							,@ClubID
							,'ServerTime,TotalBet,TotalWon,WinD,TotalBillIn,TotalCoinIn,TotalTicketIn,TotalTicketOut,TotalHandPay,TotalOut,TotalIn' -- Set di colonne specifico
							,@criteria

					-- Creazione tappo 
					;WITH cteNumberedNext AS 
					(
						SELECT
								Col
								,[Value]
								,ROW_NUMBER() OVER (PARTITION BY Col ORDER BY ServerTime desc) rn
						FROM	@RawData
								UNPIVOT
								(
									[Value] 
									FOR	Col IN 
										(
											TotalBet
											,TotalWon
											,WinD
											,TotalBillIn
											,TotalCoinIn
											,TotalTicketIn
											,TotalTicketOut
											,TotalHandPay
											,TotalOut
											,TotalIn
										)
								) p							
					)
			
					-- Popolamento tabella [TMP].[CountersCork] per i calcoli successivi										 						
					INSERT	@TableMaxCounters
							(
								TotalBet
								,TotalWon
								,WinD
								,TotalBillIn 
								,TotalCoinIn 
								,TotalTicketIn 
								,TotalTicketOut 
								,TotalHandPay
								,TotalOut
								,TotalIn
							)
 					SELECT
							 MAX(CASE WHEN Col = 'TotalBet'			THEN [Value] END) AS TotalBet
							,MAX(CASE WHEN Col = 'TotalWon'			THEN [Value] END) AS TotalWon
							,MAX(CASE WHEN Col = 'WinD'				THEN [Value] END) AS WinD
							,MAX(CASE WHEN Col = 'TotalBillIn'		THEN [Value] END) AS TotalBillIn
							,MAX(CASE WHEN Col = 'TotalCoinIn'		THEN [Value] END) AS TotalCoinIn
							,MAX(CASE WHEN Col = 'TotalTicketIn'	THEN [Value] END) AS TotalTicketIn
							,MAX(CASE WHEN Col = 'TotalTicketOut'	THEN [Value] END) AS TotalTicketOut
							,MAX(CASE WHEN Col = 'TotalHandPay'		THEN [Value] END) AS TotalHandPay
							,MAX(CASE WHEN Col = 'TotalOut'			THEN [Value] END) AS TotalOut
							,MAX(CASE WHEN Col = 'TotalIn'			THEN [Value] END) AS TotalIn
					FROM	cteNumberedNext 
					WHERE	rn = 1 
					--Fine creazione tappo 

				END -- IF @RestartTime <> @ServerTime_FIRST
	END -- IF @FromOut <> @ServerTime_Last ...

	--Aggiornamento contatori
	INSERT	[TMP].[CountersCork]  
			(
				ClubID
				,MachineID
				,FromOut
				,ToOut
				,TotalBet
				,TotalWon
				,WinD
				,TotalBillIn
				,TotalCoinIn
				,TotalTicketIn
				,TotalTicketOut
				,TotalHandPay
				,TotalOut
				,TotalIn
			)
	SELECT
			@ClubID
			,@MachineID
			,@FromOut
			,@ToOut
			,TotalBet
			,TotalWon
			,WinD
			,TotalBillIn 
			,TotalCoinIn 
			,TotalTicketIn 
			,TotalTicketOut 
			,TotalHandPay
			,TotalOut
			,TotalIn
	FROM	@TableMaxCounters					
	
	-- Log operazione
	EXEC spWriteOpLog @ProcedureName, 'Calcolo tappo terminato', @TicketCode, @BatchID
	
	-- Errore specifico
	IF	NOT EXISTS 
		(
			SELECT	TOP 1 
					ClubID 
			FROM	[TMP].[CountersCork] WITH(NOLOCK)
		)
		BEGIN
			SET @Msg = 'Empty table [TMP].[CountersCork]'
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
