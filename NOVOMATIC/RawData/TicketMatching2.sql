/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: GA, FR
Creation Date.......: 2016-02-24 
Last revision Date..: 2017-07-14
Description.........: Calcola i ticket matching sui Delta

Note
- Use [Tab size] = 3 and [Indent size] 3 (Insert spaces)

------------------
-- Parameters   --
------------------	
@Direction Bit
@ReturnCode Int OUTPUT

------------------
-- Call Example --
------------------  

DECLARE	@ReturnCode int
EXEC	[RAW].[TicketMatching2]
		@TicketCode = '4412211590049855'
		,@Direction = 0
		,@BatchID = 1
		,@ReturnCode = @ReturnCode OUTPUT
SELECT @ReturnCode

SELECT * FROM dbo.VTodayErrorLog ORDER BY ErrorTime DESC

*/
ALTER PROC	[RAW].[TicketMatching2]
			@TicketCode varchar(50)
			,@Direction bit
			,@BatchID int
			,@ReturnCode int = 0 OUTPUT
AS
SET NOCOUNT ON;

DECLARE
		@GD varchar(30) = 'GD016013368'
		,@ServerTime_FIRST datetime = '1900-01-01 00:00:00.000'
		,@ServerTime_Last datetime = '2050-12-31 00:00:00.000'
		,@DailyLoadingType_Delta tinyint = 1
		,@IterationNum tinyint = 1
		,@ConcessionaryID tinyint
		,@HourRange smallint = 36
		,@DDRange smallInt = 2
		,@OffSetImport int = 48
		,@OutCount int = 0
		,@InCount int = 0
		,@MatchedCount int = 0
		,@TicketDownload bit = 0
		,@Message varchar(1000)
		,@Msg varchar(1000)
		,@ReturnMessage varchar(1000)
		,@ClubID varchar(10)
		,@MachineID varchar(5)
		,@DataInizioImportazione datetime		  
		,@FromServerTime datetime2(3)
		,@ToServerTime datetime2(3)
		,@DataStart datetime2(3)
		,@PayOutMinData datetime2(3)
		,@PayOutMaxData datetime2(3)
		,@PrintingMinData datetime2(3)
		,@PrintingMaxData datetime2(3)
		,@TicketDataFrom datetime2(3)
		,@TicketDataTo datetime2(3)
		,@TckMaxData datetime2(3)
		,@TckMinData datetime2(3)
		,@OutMatched bit
		,@InMatched bit
		,@OffSetOut int
		,@OffSetIn int
		,@OffSetMH int
		,@MhCount int
		,@ReturnCode2 int
		,@MatchedCountTotOut int
		,@MatchedCountTotIn int
		,@ProcedureName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + '.' + QUOTENAME(OBJECT_NAME(@@PROCID))
		,@TicketList TICKETLIST_TYPE
		,@Tickets TICKET_TYPE

DECLARE @TableDateRange TABLE(MAX_MIN_TicketData datetime2(3));	

BEGIN TRY
	SELECT	TOP 1
			@ConcessionaryID = ConcessionaryID
			,@DataStart = SYSDATETIME()
			,@OffSetOut = OffSetOut
			,@OffSetIn = OffSetIn
			,@OffSetMH = OffSetMH
	FROM	[Config].[Table] WITH(NOLOCK)

	SELECT	TOP 1
			@FromServerTime = FromOut
			,@ToServerTime = ToOut
			,@ClubID = ClubID 
	FROM	[TMP].[CountersCork] WITH(NOLOCK) 

	-- Log operazione
	EXEC spWriteOpLog @ProcedureName, 'Matching Ticket iniziato', @TicketCode, @BatchID

	-- Inizializzazione
	SET @ReturnCode = 0
	TRUNCATE TABLE [TMP].[DeltaTicketIn]
	TRUNCATE TABLE [TMP].[DeltaTicketOut]
	TRUNCATE TABLE [TMP].[TicketMatched]
	--TRUNCATE TABLE [TMP].[Ticket]

	SELECT
			@TicketDataFrom = 
			CASE @Direction
				WHEN 0
				THEN DATEADD(DD, -@DDRange, @FromServerTime) -- Primo inserimento ticket a ritroso
				WHEN 1
				THEN DATEADD(DD, -1, @FromServerTime) -- Primo inserimento ticket in avanti
			END
			,@TicketDataTO = 
			CASE @Direction
				WHEN 0
				THEN DATEADD(DD, 1, @ToServerTime) -- Primo inserimento ticket a ritroso
				WHEN 1
				THEN DATEADD(DD, @DDRange, @ToServerTime) -- Primo inserimento ticket in avanti
			END 

	INSERT	@TicketList(TicketCode) 
	VALUES (@TicketCode)
	
	INSERT	@Tickets
	EXEC	dbo.GetRemoteTickets
			@LOCALConcessionaryID = @ConcessionaryID
			,@LOCALClubID = @ClubID
			,@LOCALTicketList = @TicketList
			,@LOCALFromDate = @TicketDataFrom
			,@LOCALToDate = @TicketDataTO
			,@LOCALIsMhx = 1
			,@ReturnMessage = @ReturnMessage OUTPUT


	--EXEC	@ReturnCode2 = 
	--		[POM-MON01].[Staging].[Ticket].[Extract_Pomezia] 
	--		@ConcessionaryID = @ConcessionaryID
	--		,@ClubID = @ClubID
	--		,@Fromdate = @TicketDataFrom
	--		,@ToDate = @TicketDataTO
	--		,@IsMhx = 1
	--		,@ReturnMessage = @ReturnMessage OUTPUT

	------------------------------
	-- Matching TicketOut --
	--------------------------------
	--Totalout da Matchare

	SET NOCOUNT OFF;
	INSERT	[TMP].[DeltaTicketOut]
			(
				RowID
				,TotalOut
				,Servertime
				,MachineID
			)
	SELECT 
			RowID
			,TotalOut
			,Servertime
			,MachineID 
	FROM	[TMP].[Delta] WITH(NOLOCK)
	WHERE	TotalOut != 0 
	AND		TicketCode IS NULL

	SELECT	
			@OutCount = @@ROWCOUNT
			,@MatchedCountTotOut = 0 -- Massimo un TotalOut

	WHILE	@IterationNum <= 3 
	AND		@MatchedCountTotOut < @OutCount
		BEGIN
				SELECT
					@OFFSETOUT *= 
						CASE @IterationNum
							WHEN 2
							THEN 6 -- Moltiplica l'OffsetOUT per 6 volte
							WHEN 3
							THEN 10 -- Moltiplica l'OffsetOUT per 10 volte
						END
					,@OffSetMH *= 
						CASE @IterationNum
							WHEN 2
							THEN 12 -- Moltiplica l'OffSetMH per 12 volte
							WHEN 3
							THEN 3 -- Moltiplica l'OffSetMH per 3 volte
						END

			;WITH CTE_TCK_OUT AS 
			(
				SELECT
						TicketCode
						,ServerTime
						,MachineID
						,TicketValue
						,RANK() OVER (PARTITION BY TicketValue ORDER BY ABS(DATEDIFF(SECOND, ServerTime, PrintingData)) ASC) AS RowRank
						,T1.RowID AS RowID 
				FROM
				(
					SELECT	
							RowID
							,TotalOut
							,Servertime
							,MachineID 
					FROM	[TMP].[DeltaTicketOut] WITH(NOLOCK)
				)	T1 
					--JOIN 
					--[TMP].[Ticket] T2 
					JOIN 
					@Tickets T2 
					ON (PrintingData BETWEEN DATEADD(SECOND, -@OffSetOut, ServerTime) AND DATEADD(SECOND, @OffSetOut, ServerTime)) 
					AND T1.TotalOut = T2.TicketValue 
					AND PrintingMachineID = MachineID 
					AND TicketCode	NOT IN -- Esclusione di quelli già linkati
									(
										SELECT	TicketCode 
										FROM	[RAW].[TicketMatched] WITH(NOLOCK)
										WHERE	Out = 1
									)
			)
			-- Inserimento dei ticket matchati
			INSERT	[TMP].[TicketMatched]
					(
						TicketCode
						,RowID
					)
			SELECT
					TicketCode
					,RowID 
			FROM	CTE_TCK_OUT 
			WHERE	RowRank = 1
			
			SELECT
					@MatchedCount = @@ROWCOUNT
					,@MatchedCountTotOut += @MatchedCount
			
			----------------------------------------------------------------
			-- Aggiornamento tabella delta --
			----------------------------------------------------------------
			IF @MatchedCount > 0
				BEGIN
					MERGE [TMP].[Delta] AS target  
					USING 
					(
						SELECT	
								TicketCode
								,RowID 
						FROM	[TMP].[TicketMatched] WITH(NOLOCK)
					) AS source
					ON (target.RowID = source.RowID)  
					
					WHEN	MATCHED 
					THEN	UPDATE 
							SET TicketCode = source.TicketCode

					OUTPUT	inserted.TicketCode, 1
					INTO	[RAW].[TicketMatched](TicketCode,Out);	-- salvataggio dei ticket corrispondenti
				END
			
			-- Tentativo con i pagamenti remoti
			ELSE
				BEGIN
					----------------------------------------------------------------
					-- Matching MH --
					----------------------------------------------------------------
					;WITH CTE_TCK_MH AS 
					(
						SELECT
								TicketCode
								,ServerTime
								,MachineID
								,TicketValue
								,RANK() OVER (PARTITION BY TicketValue ORDER BY ABS(DATEDIFF(SECOND, ServerTime, PrintingData)) ASC) AS RowRank
								,T1.RowID AS RowID 
						FROM
						(
							-- scarto dei non corrispondenti
							SELECT	
									RowID
									,TotalOut
									,Servertime
									,MachineID 
							FROM	[TMP].[DeltaTicketOut] WITH(NOLOCK)
						)	T1 
							JOIN 
							@Tickets T2 
							--TMP.Ticket T2 
							ON (EventDate BETWEEN DATEADD(SECOND, -@OffSetMH, ServerTime) AND DATEADD(SECOND, @OffSetMH, ServerTime)) 
							AND T1.TotalOut = T2.TicketValue 
							AND MhMachineID = MachineID  
							AND TicketCode	NOT IN 
											(
												SELECT	TicketCode 
												FROM	[RAW].[TicketMatched] WITH(NOLOCK)
												WHERE Out = 1
											)
					)
					-- Inserimento dei ticket corrispondenti
					INSERT	[TMP].[TicketMatched]
							(
								TicketCode
								,RowID
							)
					SELECT	TicketCode
							,RowID 
					FROM	CTE_TCK_MH 
					WHERE	RowRank = 1

					SELECT
							@MatchedCount = @@ROWCOUNT
							,@MatchedCountTotOut += @MatchedCount
			
					----------------------------------------------------------------
					-- Aggiornamento tabella delta --
					----------------------------------------------------------------
					IF @MatchedCount > 0
						BEGIN
							MERGE [TMP].[Delta] AS target  
							USING 
							(
								SELECT 
										TicketCode
										,RowID 
								FROM [TMP].[TicketMatched] WITH(NOLOCK)
							) AS source
							ON (target.RowID = source.RowID)  
							
							WHEN	MATCHED 
							THEN	UPDATE 
									SET TicketCode = source.TicketCode
							OUTPUT	inserted.TicketCode, 1
							INTO	[RAW].[TicketMatched](TicketCode,Out); -- Tabella finale
						END
				END -- Fine tentativo con i pagamenti remoti

			SET @IterationNum += 1
		END -- WHILE @IterationNum <= 3 AND	@MatchedCountTotOut < @OutCount

	--------------------------------
	-- Matching TicketIN --
	--------------------------------		
	SELECT
			@IterationNum = 1
			,@MatchedCountTotIn = 0

	-- TicketIn Da Matchare
	INSERT	[TMP].[DeltaTicketIN]
			(
				RowID
				,TotalTicketIn
				,Servertime
				,MachineID
			)
	SELECT	RowID
			,TotalTicketIn
			,Servertime
			,MachineID 
	FROM	[TMP].[Delta] WITH(NOLOCK)
	WHERE	TotalTicketIN <> 0 
	AND		TicketCode IS NULL
		
	SET @INCount = @@ROWCOUNT

	-- Ciclo Iterazioni
	WHILE @IterationNum <= 3 
	AND @MatchedCountTotIn < @InCount
		BEGIN
			TRUNCATE TABLE [TMP].[TicketMatched]
			SET @MatchedCount = 0

			SELECT
				@OffSetIn *= 
					CASE @IterationNum
						WHEN 2
						THEN 5 -- Moltiplica l'OffsetIN per 5 volte
						WHEN 3
						THEN 10 -- Moltiplica l'OffsetIN per 10 volte
					END
				
			-- Matching ticket
			;WITH CTE_TCK_IN AS 
			(
				SELECT 
						TicketCode
						,RoWID 
				FROM	[TMP].[DeltaTicketIN] DT WITH(NOLOCK)
						CROSS APPLY 
						(
							SELECT	TOP 1 
									* 
							FROM	@Tickets T1
							--FROM	[TMP].[Ticket] T1 WITH(NOLOCK) 
							WHERE	(PayOutData BETWEEN DATEADD(SECOND, -@OffSetIn, ServerTime) AND DATEADD(SECOND, @OffSetIn, ServerTime)) 
							AND		DT.TotalTicketIn = T1.TicketValue 
							AND		PayoutMachineID = MachineID  
							AND		TicketCode	NOT IN 
												(
													SELECT	TicketCode 
													FROM	[RAW].[TicketMatched] WITH(NOLOCK) 
													WHERE	[Out] = 0
												)
						) TI
		
			)
			-- Inserimento dei ticket corrispondenti
			INSERT	[TMP].[TicketMatched]
					(
						TicketCode
						,RowID
					)
			SELECT	
					TicketCode
					,RowID 
			FROM	CTE_TCK_IN 
	
			SELECT
					@MatchedCount = @@ROWCOUNT
					,@MatchedCountTotIn += @MatchedCount

			IF @MatchedCount > 0
				BEGIN
					-- Aggiornamento delta
					MERGE [TMP].[Delta] AS target  
					USING 
					(
						SELECT	
								TicketCode
								,RowID 
						FROM	[TMP].[TicketMatched] WITH(NOLOCK)
					) AS source
					ON (target.RowID = source.RowID)  
					WHEN	MATCHED 
					THEN	UPDATE 
							SET TicketCode = source.TicketCode

					OUTPUT inserted.TicketCode, 0
					INTO [RAW].[TicketMatched](TicketCode,Out); -- Tabella finale
				END
    
			-- ticketIn Rimanenti da Matchare
			TRUNCATE TABLE [TMP].[DeltaTicketIn]
			INSERT	[TMP].[DeltaTicketIn]
					(
						RowID
						,TotalTicketIn
						,Servertime
						,MachineID
					)
			SELECT	
					RowID
					,TotalTicketIn
					,Servertime
					,MachineID 
			FROM	[TMP].[Delta] WITH(NOLOCK)
			WHERE	TotalTicketIn <> 0 
			AND		TicketCode IS NULL
	
			-- Iterazioni successive
			SET @IterationNum += 1
		END -- WHILE @IterationNum <= 3 AND @MatchedCountTotIn < @InCount

	-- Controlli Finali
	IF @MatchedCountTotIN = @InCount 
		SET @InMatched  = 1
	IF @MatchedCountTotOut = @OutCount 
		SET @OutMatched  = 1

	-- Log operazione
	EXEC spWriteOpLog @ProcedureName, 'Matching Ticket terminato', @TicketCode, @BatchID

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
	EXECUTE	[ERR].[UspLogError]  
			@ErrorTicket = @TicketCode
			,@ErrorRequestDetailID = @BatchID
	SET @ReturnCode = -1;
END CATCH
      
RETURN @ReturnCode
