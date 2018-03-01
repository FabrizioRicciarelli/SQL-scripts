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

------------------ 
-- Call Example -- 
------------------  
DECLARE
		@ReturnCode					int
		,@ConcessionaryID			tinyint 
		,@XCONFIG					XML -- ex Config.Table
		,@XRAWDelta					XML -- ex RAW.Delta OUTPUT
		,@XRAWSession				XML -- ex RAW.Session	OUTPUT
		,@XTMPTicketStart			XML
		,@XTMPTicketServerTime		XML
		,@XTMPCountersCork			XML
		,@XRAWTicketToCalc			XML
		,@XTicketsExtractPomezia	XML
		,@XTMPRawData_View			XML
		,@XRAWTicketMatched			XML
		,@XTMPDelta					XML
		,@XTMPDeltaTicketIN			XML
		,@XTMPDeltaTicketOUT		XML

SET	@XCONFIG =	ETL.WriteXCONFIG(
					@XCONFIG
					,7				-- ConcessionaryID
					,'POM-MON01'	-- Position
					,25				-- OffSetIN
					,45				-- OffSetOut
					,7200			-- OffSetMh
					,50				-- MinVltEndCredit
					,'GMatica'		-- ConcessionaryName
					,1				-- FlagDbArchive
					,1				-- OffsetRawData
				) 
SELECT TOP 1 @ConcessionaryID = ConcessionaryID FROM ETL.gETAllXCONFIG(@XCONFIG)

TRUNCATE TABLE [ETL].[OperationLog]
EXEC	ETL.CalcAllLevel
		@ConcessionaryID = @ConcessionaryID
		,@Direction = 0
		,@TicketCode = '427102895993931934' 
		,@BatchID = 1
		,@MaxLevel = 10
		,@XCONFIG = @XCONFIG
		,@XTMPTicketStart = @XTMPTicketStart
		,@XRAWDelta = @XRAWDelta OUTPUT
		,@XRAWSession = @XRAWSession OUTPUT
		,@XTMPTicketServerTime = @XTMPTicketServerTime OUTPUT
		,@XTMPCountersCork = @XTMPCountersCork OUTPUT
		,@XRAWTicketToCalc = @XRAWTicketToCalc OUTPUT-- ex RAW.Tickettocalc
		,@XTicketsExtractPomezia = @XTicketsExtractPomezia OUTPUT
		,@XTMPRawData_View = @XTMPRawData_View OUTPUT
		,@XRAWTicketMatched = @XRAWTicketMatched OUTPUT
		,@XTMPDelta = @XTMPDelta OUTPUT
		,@XTMPDeltaTicketIN = @XTMPDeltaTicketIN OUTPUT
		,@XTMPDeltaTicketOUT = @XTMPDeltaTicketOUT OUTPUT

SELECT '[ETL].[OperationLog]' AS TABELLA, * FROM [ETL].[OperationLog]
SELECT 'XConfigTable' AS TABELLA, * FROM ETL.GetAllXCONFIG(@XCONFIG)
SELECT 'XTicketStart' AS TABELLA, * FROM ETL.GetAllXTICKETS(@XTMPTicketStart)
SELECT 'XTickets' AS TABELLA, * FROM ETL.GetAllXTICKETS(@XTicketsExtractPomezia)
SELECT 'XRawData' AS TABELLA, * FROM ETL.GetAllXRAW(@XTMPRawData_View)
SELECT 'XTicketMatched' AS TABELLA, * FROM ETL.GetAllXTKM(@XRAWTicketMatched)
SELECT 'XCountersCork' AS TABELLA, * FROM ETL.GetAllXCCK(@XTMPCountersCork)
SELECT 'XDeltaTicketIn' AS TABELLA, * FROM ETL.GetAllXDTK(@XTMPDeltaTicketIN)
SELECT 'XDeltaTicketOut' AS TABELLA, * FROM ETL.GetAllXDTK(@XTMPDeltaTicketOUT)
SELECT 'DELTA' AS Tabella, * FROM ETL.GetAllXRD(@XRAWDelta)
SELECT 'SESSION' AS Tabella, * FROM ETL.GetAllXRS(@XRAWSession)




SELECT	'2017-07-03 21:48:16.330' AS ServerTime, DATEADD(SECOND, -1000, '2017-07-03 21:48:16.330') AS BeforeServerTime, DATEADD(SECOND, 1000, '2017-07-03 21:48:16.330')  AS AfterServerTime


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
			,@XTMPTicketServerTime		XML OUTPUT
			,@XTMPCountersCork			XML OUTPUT
			,@XRAWTicketToCalc			XML OUTPUT-- ex RAW.Tickettocalc
			,@XTicketsExtractPomezia	XML OUTPUT
			,@XTMPRawData_View			XML OUTPUT
			,@XRAWTicketMatched			XML OUTPUT
			,@XTMPDelta					XML OUTPUT
			,@XTMPDeltaTicketIN			XML OUTPUT
			,@XTMPDeltaTicketOUT		XML OUTPUT
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

		,@succXTTC					XML -- ex #tickettocalcsucc

		,@TTC						ETL.TTC_TYPE
		,@rawDELTAT					ETL.RAWDELTA_TYPE

-- MAI UTILIZZATA NELLA SP CORRENTE
--DECLARE @TabellaLavoro TABLE 
--( 
--    recid           int IDENTITY(1, 1) PRIMARY KEY, 
--    sessionid       int, 
--    receiptid       int, 
--    ticketwayid     tinyint, 
--    level           smallint, 
--    sessionparentid int 
--); 

-- RIMPIAZZATA DALLA VARIABILE XML @succXTTC
--CREATE TABLE #tickettocalcsucc 
--( 
--    id              int IDENTITY(1, 1) NOT NULL, 
--    ticketcode      varchar(50) NOT NULL, 
--    sessionid       int NULL, 
--    sessionparentid int NULL, 
--    level           int NULL 
--) 

BEGIN try 
    SET @CalcEnd = 0 
    
	EXEC ETL.WriteLog @@PROCID, 'Calcolo globale iniziato', @TicketCode, @BatchID -- Log operazione  

    ----Inizializzo 
    --TRUNCATE TABLE RAW.Delta 
    --TRUNCATE TABLE RAW.Session 
    --TRUNCATE TABLE RAW.Tickettocalc
	
	SELECT	@TicketCode = ISNULL(@TicketCode,TicketCode)
	FROM	ETL.GetAllXTICKETS(@XTMPTicketStart) 

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
				,@XTicketsExtractPomezia = @XTicketsExtractPomezia OUTPUT -- ex Ticket.Extract_pomezia
				,@XTMPRawData_View = @XTMPRawData_View OUTPUT -- ex TMP.RawData_View 
				,@XRAWTicketMatched = @XRAWTicketMatched OUTPUT -- ex RAW.TicketMatched
				,@XTMPDelta = @XTMPDelta OUTPUT -- ex TMP.Delta
				,@XTMPDeltaTicketIN = @XTMPDeltaTicketIN OUTPUT -- ex TMP.DeltaTicketIN
				,@XTMPDeltaTicketOUT = @XTMPDeltaTicketOUT OUTPUT -- ex TMP.DeltaTicketOUT

        -- Lettura della Sessione dal calcolo poc'anzi effettuato (EXEC RAW.Calcall...)
        --SELECT	@SessionID = sessionid 
        --FROM	RAW.Session 
        --WHERE	startticketcode = @TicketCode 
		SELECT	@SessionID = sessionid 
		--FROM	ETL.GetXRS(@XRAWSession, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @TicketCode) -- Filtra l'elenco per startticketcode = @TicketCode
		FROM	ETL.GetAllXRS(@XRAWSession) -- Filtra l'elenco per startticketcode = @TicketCode
		WHERE	startticketcode = @TicketCode

        --INSERT INTO RAW.Tickettocalc 
        --            (ticketcode, 
        --                flagcalc, 
        --                sessionid, 
        --                sessionparentid, 
        --                level) 
        --SELECT @TicketCode, 
        --        1, 
        --        @SessionID, 
        --        @SessionParentID, 
        --        @Level 
		SELECT @XRAWTicketToCalc = ETL.WriteXTTC(@XRAWTicketToCalc, @TicketCode, 1, @SessionID, @SessionParentID, @Level) 

        -- sessione padre successviva 
        SELECT @SessionParentID = @SessionID 

        -- ticket da calcolare 
        SET @Level += 1 

        --INSERT INTO RAW.Tickettocalc 
        --            (ticketcode, 
        --                flagcalc, 
        --                sessionid, 
        --                sessionparentid, 
        --                level) 
        --SELECT ticketcode, 
        --        0, 
        --        @SessionID, 
        --        @SessionParentID, 
        --        @Level 
        --FROM   raw.Delta 
        --WHERE  sessionid = @SessionID 
        --        AND totalin <> 0 
        --        AND ticketcode IS NOT NULL 
		SELECT	@XRAWTicketToCalc = ETL.WriteXTTC(@XRAWTicketToCalc, TicketCode, 0, @SessionID, @SessionParentID, @Level)
		FROM	ETL.GetAllXRD(@XRAWDelta)
        WHERE	sessionid = @SessionID
		AND		totalin <> 0 
        AND		ticketcode IS NOT NULL 


        --SET @NumTicket = @@ROWCOUNT
		SELECT  @NumTicket = COUNT(*)
		FROM	ETL.GetAllXTTC(@XRAWTicketToCalc) 

        --INSERT INTO #tickettocalcsucc 
        --            (ticketcode, 
        --                sessionid, 
        --                sessionparentid, 
        --                level) 
        --SELECT ticketcode, 
        --        sessionid, 
        --        sessionparentid, 
        --        level 
        --FROM   RAW.Tickettocalc 
        --WHERE  level = @Level 
		SELECT	@succXTTC = ETL.WriteXTTC(@succXTTC, ticketcode, NULL, sessionid, sessionparentid, level)
		--FROM	ETL.GetXTTC(@XRAWTicketToCalc, NULL, NULL, NULL, NULL, NULL, @Level)
		FROM	ETL.GetAllXTTC(@XRAWTicketToCalc)
		WHERE	level = @Level

		-- ciclo su tutto il livello 
        SET @RecID = 1 



		WHILE @RecID <= @NumTicket 
		AND @Level < @MaxLevel 
            BEGIN
				 
                --SELECT @TicketCode = ticketcode, 
                --        @Level = level 
                --FROM   #tickettocalcsucc 
                -- 
                SELECT	
						@TicketCode = ticketcode 
                        ,@Level = level 
				FROM	ETL.GetAllXTTC(@succXTTC)
				WHERE	id = @RecID


                --SELECT @SessionParentID = sessionparentid 
                --FROM   RAW.Tickettocalc 
                --WHERE  ticketcode = @TicketCode 
                SELECT
						@SessionParentID = sessionparentid 
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
						,@XTicketsExtractPomezia = @XTicketsExtractPomezia OUTPUT -- ex Ticket.Extract_pomezia
						,@XTMPRawData_View = @XTMPRawData_View OUTPUT -- ex TMP.RawData_View 
						,@XRAWTicketMatched = @XRAWTicketMatched OUTPUT -- ex RAW.TicketMatched
						,@XTMPDelta = @XTMPDelta OUTPUT -- ex TMP.Delta
						,@XTMPDeltaTicketIN = @XTMPDeltaTicketIN OUTPUT -- ex TMP.DeltaTicketIN
						,@XTMPDeltaTicketOUT = @XTMPDeltaTicketOUT OUTPUT -- ex TMP.DeltaTicketOUT

                -- scrivo che ho calcolato il ticket 
                --SELECT	@SessionID = sessionid 
                --FROM	Raw.Session 
                --WHERE	startticketcode = @TicketCode
				SELECT	@SessionID = sessionid 
				FROM	ETL.GetAllXRS(@XRAWSession)
 				WHERE	startticketcode = @TicketCode

				--UPDATE	RAW.Tickettocalc 
				--SET		flagcalc = 1, 
				--		sessionid = @SessionID 
				--WHERE	ticketcode = @TicketCode
				SET @CSVFieldValuesPairs = 'sessionid=' + CAST(@SessionID AS nvarchar(20)) + ',flagcalc=1'
				SET @CSVWhereConditionPairs = 'ticketcode=' + @TicketCode
				SET	@XRAWTicketToCalc = ETL.UpdMultiFieldX(@XRAWTicketToCalc,  @CSVFieldValuesPairs, @CSVWhereConditionPairs) 


                -- scrivo quelli da calcolare              
				--MERGE	RAW.Tickettocalc AS T 
				--USING 
				--(
				--	SELECT 
				--			ticketcode
				--			,0 AS FlagCalc 
				--	FROM	raw.Delta 
				--	WHERE	sessionid = @SessionID 
				--	AND		totalin <> 0 
				--	AND		ticketcode IS NOT NULL
				--) AS S 
				--ON T.ticketcode = S.ticketcode 
				--WHEN	NOT MATCHED
				--THEN	INSERT (ticketcode, flagcalc, sessionparentid, level) 
				--		VALUES (S.ticketcode, 0, @SessionID, @Level + 1);
				
				-- TRASFERIMENTO DA XML A OGGETTI ***_TYPE
				INSERT	@rawDELTAT
				SELECT	*						
				FROM	ETL.GetAllXRD(@XRAWDelta)

				INSERT	@TTC (ticketcode,flagcalc,sessionid,sessionparentid,level)
				SELECT	ticketcode,flagcalc,sessionid,sessionparentid,level
				FROM	ETL.GetAllXTTC(@XRAWTicketToCalc)
				
				-- MERGING TRA OGGETTI ***_TYPE (NOTARE CHE IL FILTRO SU @SessionID è stato spostato dalla MERGE all'operazione precedente di popolamento dell'oggetto @rawDELTAT)
				MERGE	@TTC AS T 
                USING 
				(
					SELECT 
							ticketcode
                            ,0 AS FlagCalc 
					FROM	@rawDELTAT 
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
				SET @XRAWDelta = ETL.BulkXRD(@XRAWDelta,@rawDELTAT)
				SET @XRAWTicketToCalc = NULL
				SET @XRAWTicketToCalc = ETL.BulkXTTC(@XRAWTicketToCalc, @TTC)
						 
                SET @RecID += 1 

                IF @RecID > @NumTicket 
                BEGIN 
                    --PRINT 'livello ' + CAST(@Level AS VARCHAR(10)) 
                    SET @Level += 1 

                    --TRUNCATE TABLE #tickettocalcsucc 
                    --INSERT	#tickettocalcsucc(ticketcode, sessionid, sessionparentid, level) 
                    --SELECT	ticketcode, sessionid, sessionparentid, level 
                    --FROM	RAW.Tickettocalc 
                    --WHERE	level = @Level
					SET		@succXTTC = NULL
					SELECT	@succXTTC = ETL.WriteXTTC(@succXTTC, ticketcode, NULL, sessionid, sessionparentid, level) -- SCRITTURA SU @succXTTC DELLE COLONNE RITORNATE DALLA ETL.GetXTTC CHE A SUA VOLTA E' FILTRATA PER Level = @Level
					FROM	ETL.GetAllXTTC(@XRAWTicketToCalc)
					WHERE	level = @Level

                    --SELECT @NumTicket = @@ROWCOUNT 
                    SELECT	@NumTicket = COUNT(*)
					FROM	ETL.GetAllXTTC(@succXTTC) 

                    SET @RecID = 1 
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

        SELECT	@VltEndCredit = minvltendcredit 
		--FROM   [Config].[Table]
		FROM	ETL.GetAllXCONFIG(@XCONFIG)

        -- Livello 
        SET @Level = 0 
        SET @ReturnCode = 0; 
        SET @SessionParentID = NULL 

        -- Inserisco il ticket tra quelli da calcolare  
        --INSERT INTO RAW.Tickettocalc 
        --            (ticketcode, 
        --                flagcalc, 
        --                sessionid, 
        --                sessionparentid, 
        --                level) 
        --SELECT @TicketCode, 
        --        0, 
        --        @SessionID, 
        --        @SessionParentID, 
        --        @Level
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
				SELECT	@TicketCode = ticketcode, @SessionParentID = sessionparentid 
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
						,@XTicketsExtractPomezia = @XTicketsExtractPomezia OUTPUT -- ex Ticket.Extract_pomezia
						,@XTMPRawData_View = @XTMPRawData_View OUTPUT -- ex TMP.RawData_View 
						,@XRAWTicketMatched = @XRAWTicketMatched OUTPUT -- ex RAW.TicketMatched
						,@XTMPDelta = @XTMPDelta OUTPUT -- ex TMP.Delta
						,@XTMPDeltaTicketIN = @XTMPDeltaTicketIN OUTPUT -- ex TMP.DeltaTicketIN
						,@XTMPDeltaTicketOUT = @XTMPDeltaTicketOUT OUTPUT -- ex TMP.DeltaTicketOUT

                --  
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
						--MERGE RAW.Tickettocalc AS target 
						--using (SELECT ticketcode, 
						--                0 AS FlagCalc 
						--        FROM   raw.Delta 
						--        WHERE  sessionid = @SessionID 
						--                AND totalout <> 0 
						--                AND ticketcode IS NOT NULL) AS source 
						--ON ( target.ticketcode = source.ticketcode ) 
						--WHEN NOT matched THEN 
						--    INSERT (ticketcode, 
						--            flagcalc, 
						--            sessionparentid, 
						--            level) 
						--    VALUES (source.ticketcode, 
						--            0, 
						--            @SessionID, 
						--            @Level + 1); 

						-- TRASFERIMENTO DA XML A OGGETTI ***_TYPE
						INSERT	@rawDELTAT
						SELECT	*						
						FROM	ETL.GetAllXRD(@XRAWDelta) -- ELENCO DEI VALORI CONTENUTI, FILTRATO PER SessionID = @SessionID

						INSERT	@TTC (ticketcode,flagcalc,sessionid,sessionparentid,level)
						SELECT	ticketcode,flagcalc,sessionid,sessionparentid,level
						FROM	ETL.GetAllXTTC(@XRAWTicketToCalc)
				
						-- MERGING TRA OGGETTI ***_TYPE (NOTARE CHE IL FILTRO SU @SessionID è stato spostato dalla MERGE all'operazione precedente di popolamento dell'oggetto @rawDELTAT)
						MERGE	@TTC AS T 
						USING 
						(
							SELECT 
									ticketcode
									,0 AS FlagCalc 
							FROM	@rawDELTAT 
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
						SET @XRAWDelta = ETL.BulkXRD(@XRAWDelta,@rawDELTAT)
						SET @XRAWTicketToCalc = NULL
						SET @XRAWTicketToCalc = ETL.BulkXTTC(@XRAWTicketToCalc, @TTC)

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
