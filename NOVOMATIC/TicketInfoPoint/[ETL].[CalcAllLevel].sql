/* 
Template NIS (1.1 - 2015-04-01)  

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗ 
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝ 
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║      
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║      
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗ 
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ 
                                                                             
Author..............: Fabrizio Ricciarelli
Creation Date.......: 2018-01-17  
Description.........: Calcola tutti i livelli delta,sessioni,ticket - Versione in memoria (nessuna tabella fisica coinvolta) 

Revision        

Note 
- Use Tab size = 3 and Indent size 3 

------------------ 
-- Parameters   -- 
------------------   
@ConcessionaryID			tinyint 
,@Direction					bit 
,@TicketCode				varchar(50) 
,@BatchID					int 
,@MaxLevel					smallint 
,@ClubID					varchar(10) = NULL 
,@XCONFIG					XML -- ex [Config].[Table]
,@XTMPTicketStart			XML	= NULL -- ex [TMP].[TicketStart]
,@ReturnCode				int = NULL OUTPUT 
,@XRAWDelta					XML OUTPUT -- ex RAW.Delta
,@XRAWSession				XML OUTPUT -- ex RAW.Session
,@XTMPTicketServerTime		XML = NULL OUTPUT
,@XTMPCountersCork			XML = NULL OUTPUT
,@XRAWTicketToCalc			XML = NULL OUTPUT-- ex RAW.Tickettocalc
,@XTMPRawData_View			XML = NULL OUTPUT
,@XRAWTicketMatched			XML = NULL OUTPUT
,@XTMPDelta					XML = NULL OUTPUT
,@XTMPDeltaTicketIN			XML = NULL OUTPUT
,@XTMPDeltaTicketOUT		XML = NULL OUTPUT

------------------ 
-- Call Example -- 
------------------  
DECLARE
		@ReturnCode					int
		,@ConcessionaryID			tinyint = 7
		,@ConcessionaryName			varchar(30)
		,@XCONFIG					XML -- ex Config.Table
		,@XRAWDelta					XML -- ex RAW.Delta
		,@XRAWSession				XML -- ex RAW.Session

SET @ConcessionaryName = ETL.getConcessionaryName(@ConcessionaryID)

--											ConcessionaryID	, Position		, OffSetIN, OffSetOut, OffSetMh, MinVltEndCredit, ConcessionaryName , FlagDbArchive, OffsetRawData
SET	@XCONFIG =	ETL.WriteXCONFIG(@XCONFIG,	@ConcessionaryID, 'POM-MON01'	,       25,        45,     7200,              50, @ConcessionaryName,             1,             1) 

TRUNCATE TABLE [ETL].[OperationLog]

EXEC	ETL.CalcAllLevel
		@ConcessionaryID = @ConcessionaryID
		,@Direction = 0
		,@TicketCode = '427102895993931934' -- 427102895993931934, 375559646310240944, 553637305458476249, 148239190679638755, 96415771688841631 
		,@BatchID = 1
		,@MaxLevel = 10
		,@XCONFIG = @XCONFIG
		,@XRAWDelta = @XRAWDelta OUTPUT
		,@XRAWSession = @XRAWSession OUTPUT

SELECT 'OperationLog' AS TABELLA, * FROM [ETL].[OperationLog]
SELECT 'DELTA' AS Tabella, * FROM ETL.GetAllXRD(@XRAWDelta)
SELECT 'SESSION' AS Tabella, * FROM ETL.GetAllXRS(@XRAWSession)
*/
ALTER PROC	[ETL].[CalcAllLevel]
			@ConcessionaryID			tinyint 
			,@Direction					bit 
			,@TicketCode				varchar(50) 
			,@BatchID					int 
			,@MaxLevel					smallint 
			,@ClubID					varchar(10) = NULL 
			,@XCONFIG					XML -- ex [Config].[Table]
			,@XTMPTicketStart			XML	= NULL -- ex [TMP].[TicketStart]
			,@ReturnCode				int = NULL OUTPUT 
			,@XRAWDelta					XML OUTPUT -- ex RAW.Delta
			,@XRAWSession				XML OUTPUT -- ex RAW.Session
			,@XTMPTicketServerTime		XML = NULL OUTPUT
			,@XTMPCountersCork			XML = NULL OUTPUT
			,@XRAWTicketToCalc			XML = NULL OUTPUT-- ex RAW.Tickettocalc
			,@XTMPRawData_View			XML = NULL OUTPUT
			,@XRAWTicketMatched			XML = NULL OUTPUT
			,@XTMPDelta					XML = NULL OUTPUT
			,@XTMPDeltaTicketIN			XML = NULL OUTPUT
			,@XTMPDeltaTicketOUT		XML = NULL OUTPUT
AS

SET nocount ON; 

DECLARE 
		@ConcessionaryDB			varchar(50) 
        ,@DataStart					datetime2(3) 
        ,@Message					varchar(1000) 
        ,@Level						int 
        ,@ReturnCodeInternal		int 
        ,@ReturnCodeGlobal			int 
        ,@NumTicket					smallint 
        ,@RecID						smallint 
        ,@MachineID					tinyint 
        ,@CalcEnd					bit 
        ,@VltEndCredit				int 
        ,@CashDesk					tinyint = 0 
        ,@PayoutData				datetime2(3) 
        ,@ServerTime_FIRST			datetime = '1900-01-01 00:00:00.000' 
        ,@PrintingData				datetime2(3) 
        ,@ServerTimeStart			datetime2(3) 
        ,@SessionParentID			int 
        ,@SessionID					int

		,@CSVFieldValuesPairs		varchar(MAX) = NULL
		,@CSVWhereConditionPairs	varchar(MAX) = NULL

		,@RAWSESSION				ETL.RAWSESSION_TYPE
		,@RAWTickettocalc			ETL.TTC_TYPE
		,@RAWDelta					ETL.RAWDELTA_TYPE

DECLARE	@TicketToCalcSucc TABLE(
	Id int IDENTITY(1,1) NOT NULL
	,TicketCode varchar(50) NOT NULL
	,SessionID int NULL
	,SessionParentID int NULL
	,Level int NULL
)

BEGIN try 
    SET @CalcEnd = 0 
    
	EXEC ETL.WriteLog @@PROCID, 'Calcolo globale iniziato', @TicketCode, @BatchID -- Log operazione  

    ----Inizializzo 
    SET @XRAWDelta = NULL			--TRUNCATE TABLE RAW.Delta 
    SET @XRAWSession = NULL			--TRUNCATE TABLE RAW.Session 
    SET @XRAWTicketToCalc = NULL	--TRUNCATE TABLE RAW.Tickettocalc
	
    IF @Direction = 0 
    BEGIN 
        -- livello 0 
        SET @SessionParentID = NULL 
        SET @LEVEL = 0 

        EXEC	ETL.Calcall 
				@Direction = @Direction
				,@TicketCode = @TicketCode
				,@Level	= @Level
				,@SessionParentID =	@SessionParentID
				,@BatchID =	@BatchID
				,@Xconfig =	@Xconfig
				,@XTMPTicketStart =	@XTMPTicketStart
				,@XRAWSession = @XRAWSession OUTPUT -- ex RAW.Session
				,@XRAWDelta = @XRAWDelta OUTPUT -- ex RAW.Delta
				,@XTMPTicketServerTime = @XTMPTicketServerTime OUTPUT -- ex TMP.TicketServerTime
				,@XTMPCountersCork = @XTMPCountersCork OUTPUT -- ex TMP.CountersCork
				,@XRAWTicketMatched = @XRAWTicketMatched OUTPUT -- ex RAW.TicketMatched
				,@XTMPDelta = @XTMPDelta OUTPUT -- ex TMP.Delta
				,@XTMPDeltaTicketIN = @XTMPDeltaTicketIN OUTPUT -- ex TMP.DeltaTicketIN
				,@XTMPDeltaTicketOUT = @XTMPDeltaTicketOUT OUTPUT -- ex TMP.DeltaTicketOUT

		-- DEBUG
		SELECT  'DEBUG: CALCLALLLEVEL STARTING ' AS PHASE, @RecID AS RecID, @NumTicket AS NumTicket, @TicketCode AS TicketCode,@Level AS Level

        -- Lettura della Sessione dal calcolo poc'anzi effettuato (EXEC RAW.Calcall...)
		SELECT	@SessionID = sessionid 
		FROM	ETL.GetAllXRS(@XRAWSession)
		WHERE	startticketcode = @TicketCode

		SET	@XRAWTicketToCalc = ETL.WriteXTTC(@XRAWTicketToCalc, @TicketCode, 1, @SessionID, @SessionParentID, @Level) 

        -- sessione padre successviva 
        SELECT @SessionParentID = @SessionID 

        -- ticket da calcolare 
        SET @Level += 1 

		INSERT	@RAWTickettocalc(TicketCode,FlagCalc,SessionID,SessionParentID ,Level)
        SELECT	ticketcode,0,@SessionID,@SessionParentID,@Level 
        FROM	ETL.GETAllXRD(@XRAWDelta) 
        WHERE	sessionid = @SessionID 
        AND		totalin <> 0 
        AND		ticketcode IS NOT NULL
        
		SET		@NumTicket = @@ROWCOUNT
		
		---- DEBUG
		--SELECT  @NumTicket = COUNT(*)
		--FROM	ETL.GetAllXTTC(@XRAWTicketToCalc) 

		INSERT	@TicketToCalcSucc(TicketCode,SessionID,SessionParentID ,Level) 
        SELECT	TicketCode,SessionID,SessionParentID ,Level
		FROM	@RAWTickettocalc 
        WHERE	level = @Level

		SET		@XRAWTicketToCalc = ETL.BulkXTTC(@XRAWTicketToCalc,@RAWTickettocalc)

		-- ciclo su tutto il livello 
        SET @RecID = 1 

		WHILE @RecID <= @NumTicket 
		AND @Level < @MaxLevel 
            BEGIN
				
				-- DEBUG
				SELECT  'DEBUG: CALCLALLLEVEL WHILE LOOP ' AS PHASE, @RecID AS RecID, @NumTicket AS NumTicket, @TicketCode AS TicketCode,@Level AS Level

                SELECT	@TicketCode = TicketCode,@Level = Level 
				FROM	@TicketToCalcSucc
				WHERE	ID = @RecID

                SELECT	@SessionParentID = sessionparentid 
				FROM	ETL.GetAllXTTC(@XRAWTicketToCalc)
				WHERE	ticketcode = @TicketCode

				EXEC	ETL.Calcall 
						@Direction = @Direction
						,@TicketCode = @TicketCode
						,@Level	= @Level
						,@SessionParentID =	@SessionParentID
						,@BatchID =	@BatchID
						,@Xconfig =	@Xconfig
						,@XTMPTicketStart =	@XTMPTicketStart
						,@XRAWSession = @XRAWSession OUTPUT -- ex RAW.Session
						,@XRAWDelta = @XRAWDelta OUTPUT -- ex RAW.Delta
						,@XTMPTicketServerTime = @XTMPTicketServerTime OUTPUT -- ex TMP.TicketServerTime
						,@XTMPCountersCork = @XTMPCountersCork OUTPUT -- ex TMP.CountersCork
						,@XRAWTicketMatched = @XRAWTicketMatched OUTPUT -- ex RAW.TicketMatched
						,@XTMPDelta = @XTMPDelta OUTPUT -- ex TMP.Delta
						,@XTMPDeltaTicketIN = @XTMPDeltaTicketIN OUTPUT -- ex TMP.DeltaTicketIN
						,@XTMPDeltaTicketOUT = @XTMPDeltaTicketOUT OUTPUT -- ex TMP.DeltaTicketOUT

				---- DEBUG
				--SELECT	'WHILE LOOP CALCALLLEVEL - @XRAWSESSION' AS TABELLA
				--		,*
				--FROM	ETL.GetAllXRS(@XRawSession)

                -- scrivo che ho calcolato il ticket 
				SELECT	@SessionID = sessionid 
				FROM	ETL.GetAllXRS(@XRAWSession)
 				WHERE	startticketcode = @TicketCode

				--UPDATE	[RAW].[TicketToCalc] 
				--SET		
				--		FlagCalc = 1
				--		,SessionID = @SessionID 
				--WHERE	TicketCode = @TicketCode
				SET @CSVFieldValuesPairs = 'sessionid=' + CAST(@SessionID AS nvarchar(20)) + ',flagcalc=1'
				SET @CSVWhereConditionPairs = 'ticketcode=' + @TicketCode
				SET	@XRAWTicketToCalc = ETL.UpdMultiFieldX(@XRAWTicketToCalc,  @CSVFieldValuesPairs, @CSVWhereConditionPairs) 

				-- TRASFERIMENTO DA XML A OGGETTI ***_TYPE
				DELETE	FROM @RAWDelta
				INSERT	@RAWDelta
				SELECT	*						
				FROM	ETL.GetAllXRD(@XRAWDelta)

				INSERT	@RAWTickettocalc(ticketcode,flagcalc,sessionid,sessionparentid,level)
				SELECT	ticketcode,flagcalc,sessionid,sessionparentid,level
				FROM	ETL.GetAllXTTC(@XRAWTicketToCalc)
				
                -- scrivo quelli da calcolare              
				MERGE	@RAWTickettocalc AS T 
				USING 
				(
					SELECT 
							ticketcode
							,0 AS FlagCalc 
					FROM	@RAWDelta 
					WHERE	sessionid = @SessionID 
					AND		totalin <> 0 
					AND		ticketcode IS NOT NULL
				) AS S 
				ON		T.ticketcode = S.ticketcode 
				WHEN	NOT MATCHED
				THEN	INSERT (ticketcode, flagcalc, sessionparentid, level) 
						VALUES (S.ticketcode, 0, @SessionID, @Level + 1);

				-- TRASFERIMENTO DA OGGETTI ***_TYPE DI NUOVO A XML
				SET @XRAWDelta = NULL
				SET @XRAWDelta = ETL.BulkXRD(@XRAWDelta,@RAWDelta)
				SET @XRAWTicketToCalc = NULL
				SET @XRAWTicketToCalc = ETL.BulkXTTC(@XRAWTicketToCalc, @RAWTickettocalc)
						 
                SET @RecID += 1 

                IF @RecID > @NumTicket 
					BEGIN 
						SET @Level += 1 

						--TRUNCATE TABLE #tickettocalcsucc 
						--INSERT	#tickettocalcsucc(ticketcode, sessionid, sessionparentid, level) 
						--SELECT	ticketcode, sessionid, sessionparentid, level 
						--FROM	RAW.Tickettocalc 
						--WHERE	level = @Level
						DELETE	FROM @TicketToCalcSucc
						INSERT	@TicketToCalcSucc(TicketCode,SessionID,SessionParentID ,Level)
						SELECT	TicketCode,SessionID,SessionParentID ,Level 
						FROM	ETL.GetAllXTTC(@XRAWTicketToCalc) 
						WHERE	level = @Level

						SELECT
								@NumTicket = @@ROWCOUNT
								,@RecID = 1 
					END
				
            END 
    END 

    IF @Direction = 1 
		BEGIN 
			-- In avanti 
			--IF @ClubID = NULL 
			--    (SELECT @ClubID = clubid 
			--    FROM   TMP.Ticketstart)
			SELECT	@ClubID = ISNULL(@ClubID, clubid) 
			--FROM	TMP.Ticketstart
			FROM	ETL.GetAllXTICKETS(@XTMPTicketStart)

			--SET @VltEndCredit = (SELECT MinVltEndCredit FROM [Config].[Table])
			SELECT	@VltEndCredit = minvltendcredit 
			FROM	ETL.GetAllXCONFIG(@XCONFIG)

			-- Livello 
			SET @Level = 0 
			SET @ReturnCode = 0; 
			SET @SessionParentID = NULL 

			-- Inserisco il ticket tra quelli da calcolare 
			--INSERT	[RAW].[TicketToCalc] (TicketCode,FlagCalc,SessionID,SessionParentID ,Level)
			--SELECT	@TicketCode,0,@SessionID,@SessionParentID,@Level
			SELECT	@XRAWTicketToCalc = ETL.WriteXTTC(@XRAWTicketToCalc, @TicketCode, 0, @SessionID, @SessionParentID, @Level) 
		 

			-- ciclo finché esistono ticketout 
			--WHILE EXISTS (SELECT ticketcode 
			--                FROM   RAW.Tickettocalc 
			--                WHERE  flagcalc = 0 
			--                        AND level = @Level) 
			--        AND ( @Level <= @MaxLevel ) 
			--        AND ( @CalcEnd = 0 ) 
			WHILE EXISTS 
			(
				SELECT	ticketcode 
				FROM	ETL.GetAllXTTC(@XRAWTicketToCalc)
				WHERE	flagcalc = 0 
				AND		level = @Level
			) 
			AND	@Level <= @MaxLevel
			AND @CalcEnd = 0 
				BEGIN 
					-- Prendo il ticket da calcolare 
					--SELECT @TicketCode = ticketcode, 
					--        @SessionParentID = sessionparentid 
					--FROM   raw.Tickettocalc 
					--WHERE  level = @level
					SELECT	
							@TicketCode = ticketcode
							,@SessionParentID = sessionparentid 
					FROM	ETL.GetAllXTTC(@XRAWTicketToCalc)
					WHERE	level = @level

					--Calcolo 
					EXEC	ETL.Calcall 
							@Direction = @Direction
							,@TicketCode = @TicketCode
							,@Level	= @Level
							,@SessionParentID =	@SessionParentID
							,@BatchID =	@BatchID
							,@Xconfig =	@Xconfig
							,@XTMPTicketStart =	@XTMPTicketStart
							,@XRAWSession = @XRAWSession OUTPUT -- ex RAW.Session
							,@XRAWDelta = @XRAWDelta OUTPUT -- ex RAW.Delta
							,@XTMPTicketServerTime = @XTMPTicketServerTime OUTPUT -- ex TMP.TicketServerTime
							,@XTMPCountersCork = @XTMPCountersCork OUTPUT -- ex TMP.CountersCork
							,@XRAWTicketMatched = @XRAWTicketMatched OUTPUT -- ex RAW.TicketMatched
							,@XTMPDelta = @XTMPDelta OUTPUT -- ex TMP.Delta
							,@XTMPDeltaTicketIN = @XTMPDeltaTicketIN OUTPUT -- ex TMP.DeltaTicketIN
							,@XTMPDeltaTicketOUT = @XTMPDeltaTicketOUT OUTPUT -- ex TMP.DeltaTicketOUT

					--SELECT @SessionID = sessionid 
					--FROM   raw.Session 
					--WHERE  startticketcode = @TicketCode 
					SELECT	@SessionID = sessionid 
					FROM	ETL.GetAllXRS(@XRAWSession)
					WHERE	startticketcode = @TicketCode

					--SELECT @MachineID = machineid 
					--FROM   Raw.Session 
					--WHERE  sessionid = @SessionID 
					SELECT	@MachineID = sessionid 
					FROM	ETL.GetAllXRS(@XRAWSession)
					WHERE	sessionid = @SessionID

					--UPDATE	RAW.Tickettocalc 
					--SET		flagcalc = 1 
					--        ,sessionid = @SessionID 
					--WHERE	ticketcode = @TicketCode 
					SET @CSVFieldValuesPairs = 'sessionid=' + CAST(@SessionID AS nvarchar(20)) + ',flagcalc=1'
					SET @CSVWhereConditionPairs = 'ticketcode=' + @TicketCode
					SET	@XRAWTicketToCalc = ETL.UpdMultiFieldX(@XRAWTicketToCalc,  @CSVFieldValuesPairs, @CSVWhereConditionPairs) 

					-- controllo se è stampato da cashdesk 
					IF ISNULL(@MachineID, 0) != 0 
						BEGIN 
							-- scrivo quelli da calcolare              
							--MERGE	[RAW].[TicketToCalc] AS target  
							--USING	(	
							--			SELECT 
							--					ticketCode
							--					,0 AS FlagCalc 
							--			FROM	Raw.Delta 
							--			WHERE	SessionID = @SessionID 
							--			AND		TotalOut <> 0 
							--			AND		TicketCode IS NOT NULL
							--		) AS source
							--ON		(target.TicketCode = source.TicketCode) 
							--WHEN	NOT MATCHED 
							--THEN	INSERT(TicketCode, FlagCalc,SessionParentID,Level)  
							--		VALUES(source.TicketCode, 0,@SessionID,@Level+1);

							-- TRASFERIMENTO DA XML A OGGETTI ***_TYPE
							INSERT	@RAWDelta
							SELECT	*						
							FROM	ETL.GetAllXRD(@XRAWDelta) -- ELENCO DEI VALORI CONTENUTI, FILTRATO PER SessionID = @SessionID

							INSERT	@RAWTickettocalc (ticketcode,flagcalc,sessionid,sessionparentid,level)
							SELECT	ticketcode,flagcalc,sessionid,sessionparentid,level
							FROM	ETL.GetAllXTTC(@XRAWTicketToCalc)
				
							-- MERGING TRA OGGETTI ***_TYPE (NOTARE CHE IL FILTRO SU @SessionID è stato spostato dalla MERGE all'operazione precedente di popolamento dell'oggetto @RAWDelta)
							MERGE	@RAWTickettocalc AS T 
							USING 
							(
								SELECT 
										ticketcode
										,0 AS FlagCalc 
								FROM	@RAWDelta 
								WHERE	sessionid = @SessionID
								AND		totalout <> 0 
								AND		ticketcode IS NOT NULL
							) AS S 
							ON		T.ticketcode = S.ticketcode 
							WHEN	NOT MATCHED
							THEN	INSERT (ticketcode, flagcalc, sessionparentid, level) 
									VALUES (S.ticketcode, 0, @SessionID, @Level + 1);
				
							-- TRASFERIMENTO DA OGGETTI ***_TYPE DI NUOVO A XML
							SET @XRAWDelta = NULL
							SET @XRAWDelta = ETL.BulkXRD(@XRAWDelta,@RAWDelta)
							SET @XRAWTicketToCalc = NULL
							SET @XRAWTicketToCalc = ETL.BulkXTTC(@XRAWTicketToCalc, @RAWTickettocalc)

							SET @Level += 1 
					END 
                ELSE 
					SET @CalcEnd = 1 
            END 
    END 

    -- Log operazione 
	EXEC ETL.WriteLog @@PROCID, 'Calcolo globale terminato', @TicketCode, @BatchID 

    -- Errore specifico 
    IF @ReturnCodeInternal = -1 
    BEGIN 
        RAISERROR ('Internal procedure Error',16,1); 
    END 

	---- DEBUG
	--SELECT	'EXITING FROM CALCALLLEVEL - @XRAWSESSION' AS TABELLA
	--		,*
	--FROM	ETL.GetAllXRS(@XRawSession)
END try 

BEGIN CATCH 
    SELECT
			ERROR_NUMBER() AS ErrorNumber
			,ERROR_SEVERITY() AS Severity
			,ERROR_STATE() AS ErrorState
			,ISNULL(ERROR_PROCEDURE(), ISNULL(dbo.GetProcName(@@PROCID),'*Unknown*')) AS ErrorProcedure  
			,ERROR_LINE() AS ProcedureLine
			,ERROR_MESSAGE() As ErrorMessage
END CATCH 
