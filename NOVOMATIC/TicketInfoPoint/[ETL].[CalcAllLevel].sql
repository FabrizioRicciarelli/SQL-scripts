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
		@ReturnCode int 
		,@tkStart XML -- ex TMP.TicketStart
		,@XCONFIG XML -- ex Config.Table
		,@XRD XML -- ex RAW.Delta OUTPUT
		,@XRS XML -- ex RAW.Session	OUTPUT

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
			-- ETL.WriteXTICKETS(@XTICKETS, @Batchid, @Clubid,          @Ticketcode, @Ticketvalue, @Printingmachine, @Printingmachineid,             @Printingdate, @Payoutmachine, @Payoutmachineid,               @Payoutdate, @Ispaidcashdesk, @Isprintingcashdesk,               @Expiredate, @Eventdate, @Mhmachine, @Mhmachineid, @Creationchangedate) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@tkStart = ETL.WriteXTICKETS(@tkStart ,     NULL, 1000002, '309551976638606413',         4000,    'GD014017411',                 27, '2015-11-17 18:49:27.000',  'GD014017652',               26, '2015-11-17 18:49:46.000',               0,                   0, '2016-02-15 18:49:27.000',       NULL,       NULL,         NULL,                NULL) -- CARICA UN ELEMENTO AL CONTENITORE (ex [TMP].[TicketStart])

EXEC	ETL.CalcAllLevel
		@ConcessionaryID = 7
		,@Direction = 0
		,@TicketCode = NULL 
		,@BatchID = 1
		,@MaxLevel = 10
		,@XCONFIG = @XCONFIG
		,@Xts = @tkStart
		,@XRD = @XRD OUTPUT
		,@XRS = @XRS	OUTPUT

SELECT	'DELTA' AS Tabella, * FROM ETL.GetAllXRD(@XRD)
SELECT	'SESSION' AS Tabella, * FROM ETL.GetAllXRS(@XRS)

DECLARE @ReturnCode int 
EXEC	ETL.CalcAllLevel 
		@ConcessionaryID = 7
		,@Direction = 1
		,@TicketCode = '391378593917118855' 
		,@BatchID = 1
		,@MaxLevel = 10
		,@XCONFIG = @XCONFIG
		,@Xts = @tkStart
		,@XRD = @XRD OUTPUT
		,@XRS = @XRS	OUTPUT

SELECT	'DELTA' AS Tabella, * FROM ETL.GetAllXRD(@XRD)
SELECT	'SESSION' AS Tabella, * FROM ETL.GetAllXRS(@XRS)

*/ 
ALTER PROC	[ETL].[CalcAllLevel]
			@ConcessionaryID	tinyint 
			,@Direction			bit 
			,@TicketCode		varchar(50) 
			,@BatchID			int 
			,@MaxLevel			smallint 
			,@ClubID			varchar(10) = NULL 
			,@XCONFIG			XML -- ex [Config].[Table]
			,@Xts				XML	-- ex [TMP].[TicketStart]
			,@ReturnCode		int = NULL OUTPUT 
			,@XRD				XML OUTPUT -- ex RAW.Delta
			,@XRS				XML OUTPUT -- ex RAW.Session
AS

SET nocount ON; 

DECLARE 
		@ConcessionaryDB     varchar(50) 
        ,@DataStart          datetime2(3) 
        ,@Message            varchar(1000) 
        ,@Level              int 
        ,@ReturnCodeInternal int 
        ,@ReturnCodeGlobal   int 
        ,@NumTicket          smallint 
        ,@RecID              smallint 
        ,@MachineID          tinyint 
        ,@CalcEnd            bit 
        ,@VltEndCredit       int 
        ,@CashDesk           tinyint = 0 
        ,@PayoutData         datetime2(3) 
        ,@ServerTime_FIRST   datetime = '1900-01-01 00:00:00.000' 
        ,@PrintingData       datetime2(3) 
        ,@ServerTimeStart    datetime2(3) 
        ,@SessionParentID    int 
        ,@SessionID          int

		,@CSVFieldValuesPairs varchar(MAX) = NULL
		,@CSVWhereConditionPairs varchar(MAX) = NULL

		,@rawXTTC XML -- ex RAW.Tickettocalc
		,@succXTTC XML -- ex #tickettocalcsucc

		,@TTC ETL.TTC_TYPE
		,@rawDELTAT ETL.RAWDELTA_TYPE

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
	FROM	ETL.GetAllXTICKETS(@Xts) 

    IF @Direction = 0 
    BEGIN 
        -- livello 0 
        SET @SessionParentID = NULL 
        SET @LEVEL = 0 

        EXEC	ETL.Calcall 
				@Direction = @Direction
				,@TicketCode = @TicketCode
				,@BatchID = @BatchID
				,@Xconfig = @XCONFIG
				,@XTKS = @Xts
				,@XRD = @XRD OUTPUT
				,@XRS = @XRS OUTPUT

		---- DEBUG
		--SELECT * FROM ETL.GETAllXRD(@XRD)
		--SELECT * FROM ETL.GETAllXRS(@XRS)
		--return 0

        -- Lettura della Sessione dal calcolo poc'anzi effettuato (EXEC RAW.Calcall...)
        --SELECT	@SessionID = sessionid 
        --FROM	RAW.Session 
        --WHERE	startticketcode = @TicketCode 
		SELECT	@SessionID = sessionid 
		--FROM	ETL.GetXRS(@XRS, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @TicketCode) -- Filtra l'elenco per startticketcode = @TicketCode
		FROM	ETL.GetAllXRS(@XRS) -- Filtra l'elenco per startticketcode = @TicketCode
		WHERE	startticketcode = @TicketCode

		---- DEBUG
		--SELECT
		--		@SessionID AS SessionID
		--		,@SessionParentID AS SessionParentID
		--		,@Level AS Level
		--		,@TicketCode AS TicketCode
		--SELECT	'TMP.Session' AS tabella, * FROM ETL.GetAllXRS(@XRS)
		--return 0


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
		SELECT @rawXTTC = ETL.WriteXTTC(@rawXTTC, @TicketCode, 1, @SessionID, @SessionParentID, @Level) 

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
		SELECT	@rawXTTC = ETL.WriteXTTC(@rawXTTC, TicketCode, 0, @SessionID, @SessionParentID, @Level)
		--FROM	ETL.GetXRD(@XRD, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @SessionID) -- ELENCO DEI VALORI CONTENUTI, FILTRATO PER @SessionID
		FROM	ETL.GetAllXRD(@XRD)
        WHERE	sessionid = @SessionID
		AND		totalin <> 0 
        AND		ticketcode IS NOT NULL 


        --SET @NumTicket = @@ROWCOUNT
		SELECT  @NumTicket = COUNT(*)
		FROM	ETL.GetAllXTTC(@rawXTTC) 

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
		--FROM	ETL.GetXTTC(@rawXTTC, NULL, NULL, NULL, NULL, NULL, @Level)
		FROM	ETL.GetAllXTTC(@rawXTTC)
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
				FROM	ETL.GetAllXTTC(@rawXTTC)
				WHERE	ticketcode = @TicketCode

				EXEC	ETL.Calcall 
						@Direction = @Direction
						,@TicketCode = @TicketCode
						,@BatchID = @BatchID
						,@Xconfig = @XCONFIG
						,@XTKS = @Xts
						,@XRD = @XRD OUTPUT
						,@XRS = @XRS OUTPUT
						--@ConcessionaryID 
						--,@Direction 
						--,@TicketCode 
						--,@SessionParentID 
						--,@Level 
						--,@BatchID
						--,@XCONFIG
						--,@Xts
						--,@XRS OUTPUT 
						--,@XRD OUTPUT 

                -- scrivo che ho calcolato il ticket 
                --SELECT	@SessionID = sessionid 
                --FROM	Raw.Session 
                --WHERE	startticketcode = @TicketCode
				SELECT	@SessionID = sessionid 
				FROM	ETL.GetAllXRS(@XRS)
 				WHERE	startticketcode = @TicketCode

				--UPDATE	RAW.Tickettocalc 
				--SET		flagcalc = 1, 
				--		sessionid = @SessionID 
				--WHERE	ticketcode = @TicketCode
				SET @CSVFieldValuesPairs = 'sessionid=' + CAST(@SessionID AS nvarchar(20)) + ',flagcalc=1'
				SET @CSVWhereConditionPairs = 'ticketcode=' + @TicketCode
				SET	@rawXTTC = ETL.UpdMultiFieldX(@rawXTTC,  @CSVFieldValuesPairs, @CSVWhereConditionPairs) 


				---- DEBUG
				--SELECT	
				--		@CSVFieldValuesPairs AS CSVFieldValuesPairs
				--		,@CSVWhereConditionPairs AS CSVWhereConditionPairs
				--SELECT	'RAW.TicketToCalc' AS tabella, * FROM ETL.GetAllXTTC(@rawXTTC)
				--SELECT	'RAW.Session' AS tabella, * FROM ETL.GetAllXRS(@XRS)
				--RETURN 0


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
				FROM	ETL.GetAllXRD(@XRD)

				---- DEBUG
				--SELECT	'RAW.Delta' AS tabella, * FROM ETL.GetAllXRD(@XRD)
				--SELECT	'@rawDeltaT' AS tabella, * FROM @rawDELTAT
				--return 0

                
				INSERT	@TTC (ticketcode,flagcalc,sessionid,sessionparentid,level)
				SELECT	ticketcode,flagcalc,sessionid,sessionparentid,level
				FROM	ETL.GetAllXTTC(@rawXTTC)
				
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
				SET @XRD = NULL
				SET @XRD = ETL.BulkXRD(@XRD,@rawDELTAT)
				SET @rawXTTC = NULL
				SET @rawXTTC = ETL.BulkXTTC(@rawXTTC, @TTC)
						 
				---- DEBUG
				--SELECT
				--		@RecID AS RecID
				--		,@Level AS Level
				--		,@NumTicket AS NumTicket
				--		,@MaxLevel AS MaxLevel
				--		,@SessionID AS SessionID
				--		,@SessionParentID AS SessionParentID
				--		,@TicketCode as TicketCode 
				----SELECT	'TMP.TicketToCalc' AS tabella, * FROM ETL.GetAllXTTC(@succXTTC)
				--SELECT CAST(@rawXTTC AS varchar(MAX))
				--SELECT	'RAW.TicketToCalc' AS tabella, * FROM ETL.GetAllXTTC(@rawXTTC)
				----SELECT	'TMP.TicketStart' AS tabella, * FROM ETL.GetAllXTICKETS(@Xts)
				--SELECT	'TMP.Delta' AS tabella, * FROM ETL.GetAllXRD(@XRD)
				----SELECT	'TMP.Session' AS tabella, * FROM ETL.GetAllXRS(@XRS)
				--return 0

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
					FROM	ETL.GetAllXTTC(@rawXTTC)
					WHERE	level = @Level

                    --SELECT @NumTicket = @@ROWCOUNT 
                    SELECT	@NumTicket = COUNT(*)
					FROM	ETL.GetAllXTTC(@succXTTC) 

                    SET @RecID = 1 
                END
				
				---- DEBUG
				--SELECT	'RAW.TicketToCalc' AS tabella, * FROM ETL.GetAllXTTC(@rawXTTC)
				--SELECT	'TMP.TicketStart' AS tabella, * FROM ETL.GetAllXTICKETS(@Xts)
				--SELECT	'TMP.Delta' AS tabella, * FROM ETL.GetAllXRD(@XRD)
				--SELECT	'TMP.Session' AS tabella, * FROM ETL.GetAllXRS(@XRS)
				 
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
		FROM	ETL.GetAllXTICKETS(@XTS)

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
		SELECT	@rawXTTC = ETL.WriteXTTC(@rawXTTC, @TicketCode, 0, @SessionID, @SessionParentID, @Level)
		 

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
			FROM	ETL.GetAllXTTC(@rawXTTC)
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
				FROM	ETL.GetAllXTTC(@rawXTTC)
				WHERE	level = @level

                --Calcolo 
                EXEC	ETL.Calcall 
						@Direction = @Direction
						,@TicketCode = @TicketCode
						,@BatchID = @BatchID
						,@Xconfig = @XCONFIG
						,@XTKS = @Xts
						,@XRD = @XRD OUTPUT
						,@XRS = @XRS OUTPUT
						--@ConcessionaryID 
						--,@Direction 
						--,@TicketCode 
						--,@SessionParentID 
						--,@Level 
						--,@BatchID 
						--,@XCONFIG
						--,@Xts
						--,@ReturnCode OUTPUT 

                --  
                --SELECT @SessionID = sessionid 
                --FROM   raw.Session 
                --WHERE  startticketcode = @TicketCode 
				SELECT	@SessionID = sessionid 
				FROM	ETL.GetAllXRS(@XRS)
				WHERE	startticketcode = @TicketCode

                --SELECT @MachineID = machineid 
                --FROM   Raw.Session 
                --WHERE  sessionid = @SessionID 
				SELECT	@MachineID = sessionid 
				FROM	ETL.GetAllXRS(@XRS)
				WHERE	sessionid = @SessionID

                --UPDATE	RAW.Tickettocalc 
                --SET		flagcalc = 1 
                --        ,sessionid = @SessionID 
                --WHERE	ticketcode = @TicketCode 
				SET @CSVFieldValuesPairs = 'sessionid=' + CAST(@SessionID AS nvarchar(20)) + ',flagcalc=1'
				SET @CSVWhereConditionPairs = 'ticketcode=' + @TicketCode
				SET	@rawXTTC = ETL.UpdMultiFieldX(@rawXTTC,  @CSVFieldValuesPairs, @CSVWhereConditionPairs) 

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
						FROM	ETL.GetAllXRD(@XRD) -- ELENCO DEI VALORI CONTENUTI, FILTRATO PER SessionID = @SessionID

						INSERT	@TTC (ticketcode,flagcalc,sessionid,sessionparentid,level)
						SELECT	ticketcode,flagcalc,sessionid,sessionparentid,level
						FROM	ETL.GetAllXTTC(@rawXTTC)
				
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
						SET @XRD = NULL
						SET @XRD = ETL.BulkXRD(@XRD,@rawDELTAT)
						SET @rawXTTC = NULL
						SET @rawXTTC = ETL.BulkXTTC(@rawXTTC, @TTC)

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

--  -- Gestione Errore 
BEGIN catch
    PRINT 'Error ' + CONVERT(varchar(50), ERROR_NUMBER()) +
          ', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) +
          ', State ' + CONVERT(varchar(5), ERROR_STATE()) + 
          ', Procedure ' + ISNULL(ERROR_PROCEDURE(), '-') + 
          ', Line ' + CONVERT(varchar(5), ERROR_LINE());
    PRINT ERROR_MESSAGE();
    --EXECUTE ERR.Usplogerror 
    --@ErrorTicket = @TicketCode, 
    --@ErrorRequestDetailID = @BatchID 

    SET @ReturnCode = -1; 
END catch 

RETURN 
 