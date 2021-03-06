/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: GA, FR
Creation Date.......: 2017-05-23 
Last revision Date..: 2017-07-05
Description.........: Calcola tutti i livelli delta, sessioni, ticket

Revision			 

Note
- Use [Tab size] = 3 and [Indent size] 3

------------------
-- Parameters   --
------------------	
@ConcessionaryID tinyint
@Direction Bit
@TicketCode Varchar(50)
@BatchID Int
@MaxLevel SmallInt
@ClubID Varchar(10) = NULL

@ReturnCode Int = NULL OUTPUT 

------------------
-- Call Example --
------------------ 
DECLARE	@ReturnCode int

EXEC	[RAW].[CalcAllLevel2] 
		@ConcessionaryID = 4
		,@ClubID = '1000296'
		,@Direction = 0
		,@TicketCode = '4412211590049855' 
		,@BatchID = 1
		,@MaxLevel = 50
		,@ReturnCode = @ReturnCode Output
SELECT	@ReturnCode

-- Svuotamento tabelle di log: errori ed operazioni
-- (solo i dati relativi alla giornata odierna)
EXEC DeleteTodayErrorLog
EXEC DeleteTodayOperationLog

-- Letture tabelle di log: errori ed operazioni
-- (solo i dati relativi alla giornata odierna)
SELECT * FROM dbo.VTodayErrorLog ORDER BY ErrorTime DESC
SELECT * FROM dbo.VTodayOperationLog ORDER BY OperationTime DESC

DECLARE	@ReturnCode int
EXEC	[RAW].[CalcAllLevel2] 
		@ConcessionaryID = 7
		,@ClubID = '1000296'
		,@Direction = 0
		,@TicketCode = '1000294MHR201502110001' 
		,@BatchID = 1
		,@MaxLevel = 50
		,@ReturnCode = @ReturnCode Output
SELECT	@ReturnCode

DECLARE	@ReturnCode int
EXEC	[RAW].[CalcAllLevel2] 
		@ConcessionaryID = 7
		,@ClubID = '1000296'
		,@Direction = 1
		,@TicketCode = 'dddds' 
		,@BatchID = 1
		,@MaxLevel = 50
		,@ReturnCode = @ReturnCode Output
SELECT	@ReturnCode

EXEC	[RAW].[CalcAllLevel2] 
		@ConcessionaryID = 1
		,@ClubID = '1000296'
		,@Direction = 0
		,@TicketCode = '116136268470765059' 
		,@BatchID = 1
		,@MaxLevel = 10
*/
ALTER PROC	[RAW].[CalcAllLevel2]
			@ConcessionaryID tinyint
			,@ClubID varchar(10) = NULL
			,@Direction bit
			,@TicketCode varchar(50)
			,@BatchID int
			,@MaxLevel smallint
			,@ReturnCode int = NULL OUTPUT 
AS

SET NOCOUNT ON;

DECLARE 
		@ConcessionaryDB varchar(50)
		,@DataStart datetime2(3)
		,@Message varchar(1000)
		,@Level int
		,@Msg varchar(1000)
		,@ReturnCodeInternal Int
		,@ReturnCodeGlobal Int
		,@ConcessionaryName sysname
		,@CalcEnd bit
		,@VltEndCredit int
		,@CashDesk tinyInt = 0
		,@PayoutData DateTime2(3)
		,@ServerTime_FIRST datetime = '1900-01-01 00:00:00.000'
		,@ServerTime_LAST datetime = '2050-12-31 00:00:00.000'
		,@ServerTimeStart DateTime2(3)
		,@ProcedureName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + '.' + QUOTENAME(OBJECT_NAME(@@PROCID))

		,@TicketList TICKETLIST_TYPE
		,@Tickets TICKET_TYPE

BEGIN TRY
	-- Log operazione
	EXEC spWriteOpLog @ProcedureName, 'Calcolo globale iniziato', @TicketCode, @BatchID

	-- Inizializzazione
	TRUNCATE TABLE [RAW].[Delta]
	TRUNCATE TABLE [RAW].[Session]
	TRUNCATE TABLE [RAW].[TicketToCalc]
	TRUNCATE TABLE [RAW].[TicketMatched]
	TRUNCATE TABLE [TMP].[Ticket]

	SELECT 
			@ServerTimeStart = @ServerTime_FIRST 
			,@CalcEnd = 0

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

	SELECT	@VltEndCredit = [MinVltEndCredit] 
	FROM	[Config].[Table] WITH(NOLOCK)
	
	-- Livello
	SELECT 
			@Level = 0
			,@ReturnCode = 0

	-- Inserimento del ticket tra quelli da calcolare 
	INSERT	[RAW].[TicketToCalc]
			(
				TicketCode
				,FlagCalc
				,[Level]
			)
	VALUES (
				@TicketCode
				,0
				,@Level
			)

	-- Ciclo attraverso i livelli
	WHILE	EXISTS 
			(
				SELECT	TOP 1 TicketCode 
				FROM	[RAW].[TicketToCalc] WITH(NOLOCK) 
				WHERE	FlagCalc = 0 
				AND		Level = @Level
			) 
			AND	@Level <= @MaxLevel
			AND	@CalcEnd = 0
	BEGIN
		SELECT	TOP 1
				@ReturnCodeInternal = 0
				,@DataStart = SYSDATETIME()
				,@TicketCode = TicketCode  -- ticket da calcolare
		FROM	[RAW].[TicketToCalc] WITH(NOLOCK) 
		WHERE	FlagCalc = 0

		-- Trova il servertime corrispondente al ticket
		EXEC	@ReturnCodeInternal = 
				[RAW].[TicketOutServerTime2] 
				@TicketCode = @TicketCode
				,@Direction = @Direction
				,@ClubID = @ClubID
				,@BatchID = @BatchID

		-- Se è in avanti ed è pagato da cashdesk non calcolo la sessione
		IF	@Direction = 1 
		AND 
		(
			SELECT	IsPaidCashdesk 
			FROM	[TMP].[TicketStart] WITH(NOLOCK)
			WHERE	TicketCode = @TicketCode
		) = 1
			BEGIN
				-- Inserimento nella session del ticket pagato da cashdesk come ticket finale
				SET @CalcEnd = 1
				SELECT	TOP 1
						@CalcEnd = 1
						,@PayoutData = PayoutData  
				FROM	@Tickets --[TMP].[TicketStart] WITH(NOLOCK)
				WHERE	TicketCode = @TicketCode
			
				INSERT	[RAW].[Session]
						(
							MachineID
							,StartServerTime
							,StartTicketCode
							,[Level]
						)
				VALUES	(
							@CashDesk
							,@PayoutData
							,@TicketCode
							,@Level
						)
			END  
		ELSE IF -- Se non è né stampato né pagato da cashdesk o è MHR
			(
				@Direction = 0 
				AND 
				(
					SELECT	ISNULL(IsPrintingCashDesk,0) 
					FROM	@Tickets
					WHERE	TicketCode = @TicketCode
				) = 0
			) 
			OR
			(
				@Direction = 1 
				AND 
				(
					SELECT	ISNULL(IsPaidCashdesk,0) 
					FROM	@Tickets -- [TMP].[TicketStart] 
					WHERE	TicketCode = @TicketCode
				) = 0
			)
			-- Calcoli
			BEGIN
				IF @ReturnCodeInternal <> -1 -- Trova il tappo
					EXEC	[RAW].[FindCountersCork2] 
							@TicketCode = @TicketCode
							,@Direction = @Direction
							,@ClubID = @ClubID
							,@ReturnCode = @ReturnCodeInternal OUTPUT

				IF @ReturnCodeInternal <> -1 -- Calcola i delta
					EXEC	@ReturnCodeInternal =  
							[RAW].[CalculateDeltaFromTicketOut2]
							@TicketCode = @TicketCode
							,@ReturnCode = @ReturnCodeInternal OUTPUT
				
				IF @ReturnCodeInternal <> -1 -- Matching dei ticket
					EXEC	@ReturnCodeInternal =  
							[RAW].[TicketMatching2] 
							@Direction = @Direction
							,@TicketCode = @TicketCode
							,@BatchID = @BatchID
							,@ReturnCode = @ReturnCodeInternal OUTPUT

				IF @ReturnCodeInternal <> -1 -- Calcola le sessioni
					EXEC	@ReturnCodeInternal =  
							[RAW].[CalcSession2] 
							@Level = @Level 
							,@TicketCode = @TicketCode
							,@BatchID = @BatchID
							,@ReturnCode = @ReturnCodeInternal OUTPUT

				-- Punto di partenza della catena
				IF	@ServerTimeStart = @ServerTime_FIRST 
					SELECT	@ServerTimeStart = Servertime 
					FROM	[TMP].[Delta] WITH(NOLOCK) 
					WHERE	TicketCode = @TicketCode
			END
		
		-- Inserimento del ticket tra quelli calcolati se ci sono corrispondenze
		MERGE	[RAW].[TicketToCalc] AS target  
		USING 
		(
			SELECT	@TicketCode AS TicketCode
		) AS source
		ON 
		(
			target.TicketCode = source.TicketCode
		)  
		WHEN	MATCHED 
		THEN	UPDATE SET FlagCalc = 1;

		-- Livello successivo
		IF	NOT EXISTS 
			(
				SELECT	TicketCode 
				FROM	[RAW].[TicketToCalc] WITH(NOLOCK) 
				WHERE	FlagCalc = 0 
				AND		Level = @Level
			) 
			SET @Level += 1
		
		------------------------------------------------------------------------------------------------
		-- Salvataggio dei ticket da calcolare per iterazione
		------------------------------------------------------------------------------------------------
		IF @Direction = 0
		BEGIN
			-- Scrittura dei ticket da calcolare
			IF	NOT EXISTS 
				(
					SELECT	TOP 1 
							RowID 
					FROM	[RAW].[Delta] WITH(NOLOCK) 
					WHERE	FlagMinVltCredit = 1
				)
				BEGIN
					-- Scrittura dei ticket da calcolare
					MERGE [RAW].[TicketToCalc] AS target  
					USING 
					(
						SELECT	TicketCode 
						FROM	[TMP].[Delta] WITH(NOLOCK) 
						WHERE	TotalTicketIn <> 0 
						AND		TicketCode IS NOT NULL
					) AS source
					ON 
					(
						target.TicketCode = source.TicketCode
					) 
					WHEN NOT MATCHED 
					THEN 
						INSERT (TicketCode, FlagCalc, [Level])  
						VALUES (source.TicketCode, 0, @Level);
				END 
			ELSE 
				SET @CalcEnd = 1
			END 
		ELSE 
			BEGIN
				-- Scrivo ticket da calcolare
				IF	NOT EXISTS 
					(
						SELECT	TOP 1 
								RowID 
						FROM	[RAW].[Delta] WITH(NOLOCK)
						WHERE	FlagMinVltCredit = 1
					)
					BEGIN
						MERGE [RAW].[TicketToCalc] AS target  
						USING 
						(
							SELECT	TicketCode 
							FROM	[TMP].[Delta] WITH(NOLOCK) 
							WHERE	TotalOut <> 0 
							AND		TicketCode IS NOT NULL
						) AS source
						ON 
						(
							target.TicketCode = source.TicketCode
						) 
						WHEN	NOT MATCHED 
						THEN 
							INSERT (TicketCode, FlagCalc,Level)  
							VALUES (source.TicketCode, 0,@Level);
					END
				
				-- Uscita dai calcoli
				ELSE 
					SET @CalcEnd = 1
				
				-- Fine Calcoli
			END  
	-- Fine Ciclo
	END -- WHILE EXISTS (SELECT	TicketCode...

	-- Log operazione
	EXEC spWriteOpLog @ProcedureName, 'Calcolo globale terminato', @TicketCode, @BatchID

	-- Errore specifico
	IF @ReturnCodeInternal <> 0
		BEGIN
			SET @Msg = 'Internal procedure Error'
			RAISERROR (@Msg,16,1);
		END

END TRY

-- Gestione Errore
BEGIN CATCH
	EXEC	[ERR].[UspLogError]  
			@ErrorTicket = @TicketCode
			,@ErrorRequestDetailID  = @BatchID
	SET		@ReturnCode = -1;
END CATCH
      
RETURN 
