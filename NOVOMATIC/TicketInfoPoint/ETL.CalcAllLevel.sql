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
DECLARE @ReturnCode int 
EXEC ETL.CalcAllLevel @ConcessionaryID = 7, @Direction = 0,@TicketCode = '14578571020766708' ,@BatchID = 1,@MaxLevel = 10,@ReturnCode = @ReturnCode Output
Select @ReturnCode 

DECLARE @ReturnCode int 
EXEC ETL.CalcAllLevel @ConcessionaryID = 7, @Direction = 1,@TicketCode = '391378593917118855' ,@BatchID = 1,@MaxLevel = 10,@ReturnCode = @ReturnCode Output
Select @ReturnCode 

*/ 
ALTER PROC	ETL.CalcAllLevel
			@ConcessionaryID tinyint 
			,@Direction       bit 
			,@TicketCode      varchar(50) 
			,@BatchID         int 
			,@MaxLevel        smallint 
			,@ClubID          varchar(10) = NULL 
			,@ReturnCode      int = NULL output 
AS

SET nocount ON; 

DECLARE 
		@ConcessionaryDB    varchar(50) 
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

		,@rawXTTC XML -- ex RAW.Tickettocalc
		,@succXTTC XML -- ex #tickettocalcsucc
		,@rawXDelta XML -- ex RAW.Delta
		,@rawXSession XML -- ex RAW.Session

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

    IF @Direction = 0 
    BEGIN 
        -- livello 0 
        SET @SessionParentID = NULL 
        SET @LEVEL = 0 

        EXEC	ETL.Calcall 
				@ConcessionaryID 
				,@Direction 
				,@TicketCode 
				,@SessionParentID 
				,@Level 
				,@BatchID
				,@rawXSession OUTPUT 
				,@rawXDelta OUTPUT 

        -- Lettura della Sessione dal calcolo poc'anzi effettuato (EXEC RAW.Calcall...)
        --SELECT	@SessionID = sessionid 
        --FROM	RAW.Session 
        --WHERE	startticketcode = @TicketCode 
		SELECT	@SessionID = sessionid 
		FROM	ETL.GetXRS(@rawXSession, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @TicketCode) -- Filtra l'elenco per startticketcode = @TicketCode

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
		FROM	ETL.GetXRD(@rawXDelta, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @SessionID) -- ELENCO DEI VALORI CONTENUTI, FILTRATO PER @SessionID
        WHERE	totalin <> 0 
        AND		ticketcode IS NOT NULL 


        SET @NumTicket = @@ROWCOUNT 

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
		FROM	ETL.GetXTTC(@rawXTTC, NULL, NULL, NULL, NULL, NULL, @Level)
        
		-- ciclo su tutto il livello 
        SET @RecID = 1 

		WHILE @RecID <= @NumTicket 
		AND @Level < @MaxLevel 
            BEGIN
				 
                --SELECT @TicketCode = ticketcode, 
                --        @Level = level 
                --FROM   #tickettocalcsucc 
                --WHERE  id = @RecID 
                SELECT	
						@TicketCode = ticketcode 
                        ,@Level = level 
				FROM	ETL.GetXTTC(@succXTTC, @RecID, NULL, NULL, NULL, NULL, NULL)


                --SELECT @SessionParentID = sessionparentid 
                --FROM   RAW.Tickettocalc 
                --WHERE  ticketcode = @TicketCode 
                SELECT
						@SessionParentID = sessionparentid 
				FROM	ETL.GetXTTC(@rawXTTC, NULL, @TicketCode, NULL, NULL, NULL, NULL)

                EXEC	RAW.Calcall 
						@ConcessionaryID = @ConcessionaryID 
						,@Direction = @Direction 
						,@TicketCode = @TicketCode 
						,@SessionParentID = @SessionParentID 
						,@Level = @Level 
						,@BatchID = @BatchID 
						,@ReturnCode = @ReturnCode output 

                -- scrivo che ho calcolato il ticket 
                --SELECT	@SessionID = sessionid 
                --FROM	Raw.Session 
                --WHERE	startticketcode = @TicketCode
				SELECT	@SessionID = sessionid 
				FROM	ETL.GetXRS(@rawXSession, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @TicketCode) -- Filtra l'elenco per startticketcode = @TicketCode
 

				--UPDATE	RAW.Tickettocalc 
				--SET		flagcalc = 1, 
				--		sessionid = @SessionID 
				--WHERE	ticketcode = @TicketCode 
				SET	@rawXTTC = ETL.UpdMultiFieldXTTC(@rawXTTC,  'sessionid=' + CAST(@SessionID as varchar(10)) + ',flagcalc=1', 'ticketcode=' + @TicketCode) 

                -- scrivo quelli da calcolare              
				--MERGE	RAW.Tickettocalc AS T 
				--USING 
				--(
				--	SELECT 
				--			ticketcode
				--,0 AS FlagCalc 
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
				FROM	ETL.GetXRD(@rawXDelta, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @SessionID) -- ELENCO DEI VALORI CONTENUTI, FILTRATO PER SessionID = @SessionID
                
				INSERT	@TTC (ticketcode,flagcalc,sessionid,sessionparentid,level)
				SELECT	ticketcode,flagcalc,sessionid,sessionparentid,level
				FROM	ETL.GetXTTC(@rawXTTC, NULL, NULL, NULL, NULL, NULL, NULL)
				
				-- MERGING TRA OGGETTI ***_TYPE (NOTARE CHE IL FILTRO SU @SessionID è stato spostato dalla MERGE all'operazione precedente di popolamento dell'oggetto @rawDELTAT)
				MERGE	@TTC AS T 
                USING 
				(
					SELECT 
							ticketcode
                            ,0 AS FlagCalc 
					FROM	@rawDELTAT 
					WHERE	totalin <> 0 
					AND		ticketcode IS NOT NULL
				) AS S 
                ON T.ticketcode = S.ticketcode 
                WHEN	NOT MATCHED
				THEN	INSERT (ticketcode, flagcalc, sessionparentid, level) 
						VALUES (S.ticketcode, 0, @SessionID, @Level + 1);
				
				-- TRASFERIMENTO DA OGGETTI ***_TYPE DI NUOVO A XML
				SET @rawXDelta = NULL
				SET @rawXDelta = ETL.BulkXRD(@rawXDelta,@rawDELTAT)
				SET @rawXTTC = NULL
				SET @rawXTTC = ETL.BulkTTC(@rawXTTC, @TTC)
						 

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
					FROM	ETL.GetXTTC(@rawXTTC, NULL, NULL, NULL, NULL, NULL, @Level)

                    SELECT @NumTicket = @@ROWCOUNT 

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
		FROM	TMP.Ticketstart

        SELECT	@VltEndCredit = minvltendcredit 
		FROM   [Config].[Table]

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
			FROM	ETL.GetXTTC(@rawXTTC, NULL, NULL, 0, NULL, NULL, @Level) -- ETL.GetXTTC(@rawXTTC, @ID, @TicketCode, @FlagCalc, @SessionID, @SessionParentID, @Level)
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
				FROM	ETL.GetXTTC(@rawXTTC, NULL, NULL, NULL, NULL, NULL, @Level) -- ETL.GetXTTC(@rawXTTC, @ID, @TicketCode, @FlagCalc, @SessionID, @SessionParentID, @Level)

                --Calcolo 
                EXEC	ETL.Calcall 
						@ConcessionaryID = @ConcessionaryID, 
						@Direction = @Direction, 
						@TicketCode = @TicketCode, 
						@SessionParentID = @SessionParentID, 
						@Level = @Level, 
						@BatchID = @BatchID, 
						@ReturnCode = @ReturnCode output 

                --  
                --SELECT @SessionID = sessionid 
                --FROM   raw.Session 
                --WHERE  startticketcode = @TicketCode 
				SELECT	@SessionID = sessionid 
				FROM	ETL.GetXRS(@rawXSession, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @TicketCode) -- Filtra l'elenco per startticketcode = @TicketCode

                --SELECT @MachineID = machineid 
                --FROM   Raw.Session 
                --WHERE  sessionid = @SessionID 
				SELECT	@MachineID = sessionid 
				FROM	ETL.GetXRS(@rawXSession, @SessionID, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- Filtra l'elenco per sessionid = @SessionID

                --UPDATE	RAW.Tickettocalc 
                --SET		flagcalc = 1 
                --        ,sessionid = @SessionID 
                --WHERE	ticketcode = @TicketCode 
				SET	@rawXTTC = ETL.UpdMultiFieldXTTC(@rawXTTC,  'sessionid=' + CAST(@SessionID as varchar(10)) + ',flagcalc=1', 'ticketcode=' + @TicketCode) 

                -- controllo se è stampato da cashdesk 
                IF Isnull(@MachineID, 0) <> 0 
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
					FROM	ETL.GetXRD(@rawXDelta, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @SessionID) -- ELENCO DEI VALORI CONTENUTI, FILTRATO PER SessionID = @SessionID

					INSERT	@TTC (ticketcode,flagcalc,sessionid,sessionparentid,level)
					SELECT	ticketcode,flagcalc,sessionid,sessionparentid,level
					FROM	ETL.GetXTTC(@rawXTTC, NULL, NULL, NULL, NULL, NULL, NULL)
				
					-- MERGING TRA OGGETTI ***_TYPE (NOTARE CHE IL FILTRO SU @SessionID è stato spostato dalla MERGE all'operazione precedente di popolamento dell'oggetto @rawDELTAT)
					MERGE	@TTC AS T 
					USING 
					(
						SELECT 
								ticketcode
								,0 AS FlagCalc 
						FROM	@rawDELTAT 
						WHERE	totalout <> 0 
						AND		ticketcode IS NOT NULL
					) AS S 
					ON T.ticketcode = S.ticketcode 
					WHEN	NOT MATCHED
					THEN	INSERT (ticketcode, flagcalc, sessionparentid, level) 
							VALUES (S.ticketcode, 0, @SessionID, @Level + 1);
				
					-- TRASFERIMENTO DA OGGETTI ***_TYPE DI NUOVO A XML
					SET @rawXDelta = NULL
					SET @rawXDelta = ETL.BulkXRD(@rawXDelta,@rawDELTAT)
					SET @rawXTTC = NULL
					SET @rawXTTC = ETL.BulkTTC(@rawXTTC, @TTC)

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
    EXECUTE ERR.Usplogerror 
    @ErrorTicket = @TicketCode, 
    @ErrorRequestDetailID = @BatchID 

    SET @ReturnCode = -1; 
END catch 

RETURN 
 