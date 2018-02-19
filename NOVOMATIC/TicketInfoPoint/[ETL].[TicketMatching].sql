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
Description.........: Calcola i Delta - Versione in memoria (nessuna tabella fisica coinvolta) 

Note 
- Use [Tab size] = 3 and [Indent size] 3 (Insert spaces) 

------------------ 
-- Parameters   -- 
------------------   

------------------ 
-- Call Example -- 
------------------   

EXEC	[ETL].[TicketMatching] 
		@Direction = 1 
*/ 
ALTER PROC	[ETL].[TicketMatching]
			@XCONFIG XML = NULL
			,@TicketCode varchar(50) = NULL
			,@Direction  bit
			,@XCCK XML = NULL -- ex TMP.CountersCork
			,@XTICKETS XML = NULL -- ex TMP.Ticket
			,@XRD XML = NULL -- ex TMP.Delta 
			,@XTKM_RAW XML OUTPUT -- ex RAW.TicketMatched
AS 

SET nocount ON; 

DECLARE 
        @OffSetOut					int 
        ,@OffSetIn					int 
        ,@OffSetMH					int 
        ,@FromServerTime			datetime 
        ,@ToServerTime				datetime 
        ,@DataStart					datetime 
        ,@TicketDataFrom			datetime2(3) 
        ,@TicketDataTo				datetime2(3) 
        ,@OutCount					int 
        ,@InCount					int 
        ,@IterationNum				tinyint 
        ,@ClubID					varchar(10) 
        ,@DDRange					smallint 
        ,@MatchedCount				int 
        ,@OutMatched				bit 
        ,@InMatched					bit
        ,@MatchedCountTotOut		int 
        ,@MatchedCountTotIn			int 
        ,@ConcessionaryID			tinyint
        ,@BatchID					int
		,@XDTKIN					XML -- ex TMP.Deltaticketin
		,@XDTKOUT					XML -- ex TMP.Deltaticketout
		,@XTKM_TMP					XML -- ex TMP.TicketMatched

		-- PER MERGE
		,@TMPDELTA					ETL.RAWDELTA_TYPE
		,@TMPTICKETMATCHED			ETL.TICKETMATCHED_TYPE
		,@RAWTICKETMATCHED			ETL.TICKETMATCHED_TYPE

BEGIN TRY 
    -- Log operazione 
	EXEC ETL.WriteLog @@PROCID, 'Matching ticket iniziato', @TicketCode, @BatchID -- Log operazione  

    SELECT 
			@DataStart = SYSDATETIME() 
			,@IterationNum = 1 
			,@OutCount = 0 
			,@InCount = 0 
			,@DDRange = 2 
			,@MatchedCount = 0 

    --TRUNCATE TABLE [TMP].[Deltaticketin] 
    --TRUNCATE TABLE [TMP].[Deltaticketout] 
    --TRUNCATE TABLE [TMP].[Ticket] 
    --TRUNCATE TABLE [TMP].[Ticketmatched] 
    --TRUNCATE TABLE [RAW].[Ticketmatched] 

    --Inizializzo 
    --SELECT	@ConcessionaryID = concessionaryid 
    --FROM	config.[Table] 

    SELECT
			@ConcessionaryID = concessionaryid
			,@OffSetOut = offsetout 
			,@OffSetIn = offsetin 
			,@OffSetMH = offsetmh 
    --FROM	config.[Table] 
    FROM	ETL.GetAllXCONFIG(@XCONFIG) 

    -- Intervallo di calcolo 
    SELECT
			@FromServerTime = fromout 
            ,@ToServerTime = toout 
            ,@ClubID = clubid 
    --FROM	[TMP].Counterscork 
    FROM	ETL.GetAllXCCK(@XCCK)

    -- Caricamento ticket 
    -- Primo inserimento ticket indietro 
    IF @Direction = 0 
    BEGIN 
        SET @TicketDataTO = DATEADD(DD, 1, @ToServerTime) 
        SET @TicketDataFrom = DATEADD(DD, -@DDRange, @FromServerTime) 
    END 

    -- Primo inserimento ticket in avanti 
    IF @Direction = 1 
    BEGIN 
        SET @TicketDataTO = DATEADD(dd, @DDRange, @ToServerTime) 
        SET @TicketDataFrom = DATEADD(dd, -1, @FromServerTime) 
    END 

    -- scarico i ticket 
   -- EXEC	[Ticket].[Extract_pomezia] 
			--@ConcessionaryID = @ConcessionaryID, 
			--@ClubID = @ClubID, 
			--@Fromdate = @TicketDataFrom, 
			--@ToDate = @TicketDataTO, 
			--@IsMhx = 1 
			----@ReturnMessage = @ReturnMessage output 
	IF ISNULL(CAST(@XTICKETS AS varchar(MAX)),'') = ''
	OR ISNULL(CAST(@XTICKETS AS varchar(MAX)),'<TICKETS/>') = '<TICKETS/>'
		BEGIN
			EXEC	ETL.ExtractTicketsFromPIN
					@ConcessionaryID = @ConcessionaryID -- OBBLIGATORIO, DETERMINA IL CONCESSIONARIO
					,@ClubID = @ClubID	-- FACOLTATIVO, DETERMINA LA SALA
					,@TicketCode = @TicketCode -- FACOLTATIVO, ELENCO DI TICKETS (MIXATI, SIA MHx CHE NON), SEPARATI DA VIRGOLE, OPPURE TICKET SINGOLO (SIA MHx CHE NON)
					,@TicketValue = NULL 
					,@XMLTICKETS = @XTICKETS OUTPUT
		END

    --END 
    ------------------------------ 
    -- Matching TicketOut -- 
    -------------------------------- 
    --Totalout da Matchare 
    --INSERT INTO [TMP].[Deltaticketout] 
    --            (rowid, 
    --            totalout, 
    --            servertime, 
    --            machineid) 
    --SELECT	rowid, 
    --        totalout, 
    --        servertime, 
    --        machineid 
    --FROM	tmp.Delta 
    --WHERE	totalout <> 0 
    --AND		ticketcode IS NULL 

	SELECT	@XDTKOUT = ETL.WriteXDTK(@XDTKOUT,rowid,NULL,totalout,servertime,machineid)
	FROM	ETL.GETAllXRD(@XRD)
    WHERE	totalout <> 0 
    AND		ticketcode IS NULL 


    SET @OutCount = @@ROWCOUNT 
    -- Massimo un TotalOut 
    SET @MatchedCountTotOut = 0 

    -- iterazioni 
	WHILE @IterationNum <= 3 
	AND @MatchedCountTotOut < @OutCount 
		BEGIN 
			-- iterazioni successive 
			IF @IterationNum = 2 
				BEGIN 
					SELECT @OFFSETOUT = @OFFSETOUT * 6 
					SELECT @OffSetMH = @OffSetMH * 12 
				END 
			ELSE IF @IterationNum = 3 
				BEGIN 
					SELECT @OFFSETOUT = @OFFSETOUT * 10 
					SELECT @OffSetMH = @OffSetMH * 3 
				END 
         

			-- Matching ticket OUT 
			;WITH cte_tck_out AS (
				SELECT 
						ticketcode 
                        ,servertime 
                        ,machineid 
                        ,ticketvalue 
                        ,RANK() OVER (PARTITION BY ticketvalue ORDER BY ABS(DATEDIFF(SECOND, servertime, printingdate)) ASC) AS RowRank 
                        ,T1.rowid AS RowID 
                FROM   (
					SELECT 
							rowid
							,totalout
							,servertime
							,machineid 
					--FROM	[TMP].[Deltaticketout]) T1
					FROM	ETL.GETAllXDTK(@XDTKOUT)
				) AS	T1 
						INNER JOIN 
						--tmp.Ticket T2
						ETL.GetAllXTICKETS(@XTICKETS) AS T2 
						ON (printingdate BETWEEN DATEADD(SECOND, -@OffSetOut, servertime) AND DATEADD(SECOND, @OffSetOut, servertime)) 
						AND T1.totalout = T2.ticketvalue 
						AND printingmachineid = machineid 
						-- Escludo quelli già linkati 
						AND ticketcode NOT IN (
							SELECT	ticketcode 
							--FROM   [RAW].[Ticketmatched]
							FROM	ETL.GetAllXTKM(@XTKM_RAW) 
							WHERE	[OUT] = 1
						)
			)
				
        
			-- inserisco ticket matchati 
			--INSERT INTO [TMP].[Ticketmatched](ticketcode, rowid) 
			--SELECT ticketcode, rowid 
			--FROM   cte_tck_out 
			--WHERE  rowrank = 1 
			SELECT @XTKM_TMP = ETL.WriteXTKM(@XTKM_TMP ,ticketcode, rowid, NULL) 
			FROM   cte_tck_out 
			WHERE  rowrank = 1 

			SET @MatchedCount = @@ROWCOUNT 
			SET @MatchedCountTotOut += @MatchedCount 

			---------------------------------------------------------------- 
			-- Aggiorna tabella delta -- 
			---------------------------------------------------------------- 
			IF @MatchedCount > 0 
				BEGIN
					INSERT	@TMPDELTA
					SELECT	* FROM ETL.GetAllXRD(@XRD)

					INSERT	@TMPTICKETMATCHED
					SELECT	* FROM ETL.GetAllXTKM(@XTKM_TMP)
				 
					--MERGE	[TMP].[Delta] AS T 
					--USING	(SELECT ticketcode, rowid FROM [TMP].[Ticketmatched]) AS S 
					--ON	T.rowid = S.rowid
					--WHEN	MATCHED 
					--THEN	UPDATE 
					--		SET ticketcode = S.ticketcode 
					--		OUTPUT inserted.ticketcode, 1 -- salvo i ticket Matchati 
					--		INTO [RAW].[Ticketmatched](ticketcode, out); 

					MERGE	@TMPDELTA AS T 
					USING	(SELECT ticketcode, rowid FROM @TMPTICKETMATCHED) AS S 
					ON		T.rowid = S.rowid
					WHEN	MATCHED 
					THEN	UPDATE 
							SET ticketcode = S.ticketcode 
							OUTPUT inserted.ticketcode, 1 -- salvo i ticket Matchati 
							INTO @RAWTicketmatched(ticketcode, [OUT]); 

					SET	@XRD = ETL.BulkXRD(@XRD, @TMPDELTA)
					SET	@XTKM_TMP = ETL.BulkXTKM(@XTKM_TMP, @TMPTICKETMATCHED)
					SET	@XTKM_RAW = ETL.BulkXTKM(@XTKM_RAW, @RAWTICKETMATCHED)
				END
				 
        -- Provo con i pagamenti remoti 
        ELSE 
            BEGIN 
				---------------------------------------------------------------- 
				-- Matching MH -- 
				---------------------------------------------------------------- 
                ;WITH cte_tck_mh AS(
					SELECT 
							ticketcode 
                            ,servertime 
                            ,machineid 
                            ,ticketvalue 
                            ,RANK() OVER(PARTITION BY ticketvalue ORDER BY ABS(DATEDIFF(SECOND, servertime, printingdate)) ASC) AS RowRank 
                            ,T1.rowid AS RowID 
                    FROM ( 
                        -- scarto i matchati 
                        SELECT	
								rowid 
                                ,totalout 
                                ,servertime 
                                ,machineid 
                        --FROM	[TMP].[Deltaticketout]
						FROM	ETL.GETAllXDTK(@XDTKOUT)
					) AS	T1 
                            INNER JOIN 
							--tmp.Ticket AS T2 
							ETL.GetAllXTICKETS(@XTICKETS) AS T2 
                            ON (eventdate BETWEEN DATEADD(SECOND, -@OffSetMH, servertime) AND DATEADD(SECOND, @OffSetMH, servertime) )
                            AND T1.totalout = T2.ticketvalue 
                            AND mhmachineid = machineid 
                            AND ticketcode NOT IN (
								SELECT	ticketcode 
                                --FROM	[RAW].[Ticketmatched] 
								FROM	ETL.GetAllXTKM(@XTKM_RAW) 
                                WHERE	[OUT] = 1
							)
				)
				 
                -- inserisco ticket matchati 
                --INSERT INTO [TMP].[Ticketmatched] 
                --            (ticketcode, 
                --            rowid) 
                --SELECT ticketcode, 
                --        rowid 
                --FROM   cte_tck_mh 
                --WHERE  rowrank = 1 
				SELECT @XTKM_TMP = ETL.WriteXTKM(@XTKM_TMP ,ticketcode, rowid, NULL) 
				FROM   cte_tck_mh 
				WHERE  rowrank = 1 

                SET @MatchedCount = @@ROWCOUNT 
                SET @MatchedCountTotOut += @MatchedCount 

                ---------------------------------------------------------------- 
                -- Aggiorna tabella delta -- 
                ----------------------------------------------------------------     
                IF @MatchedCount > 0 
                BEGIN 
					INSERT	@TMPDELTA
					SELECT	* FROM ETL.GetAllXRD(@XRD)

					INSERT	@TMPTICKETMATCHED
					SELECT	* FROM ETL.GetAllXTKM(@XTKM_TMP)

					--MERGE	[TMP].[Delta] AS T 
					--USING	(SELECT ticketcode, rowid FROM [TMP].[Ticketmatched]) AS S 
					--ON		T.rowid = S.rowid
					--WHEN	MATCHED 
					--THEN	UPDATE 
					--		SET ticketcode = S.ticketcode 
					--		OUTPUT inserted.ticketcode, 1 -- Tabella finale
					--		INTO [RAW].[Ticketmatched](ticketcode, out); 

					MERGE	@TMPDELTA AS T 
					USING	(SELECT ticketcode, rowid FROM @TMPTICKETMATCHED) AS S 
					ON		T.rowid = S.rowid
					WHEN	MATCHED 
					THEN	UPDATE 
							SET ticketcode = S.ticketcode 
							OUTPUT inserted.ticketcode, 1 -- salvo i ticket Matchati 
							INTO @RAWTicketmatched(ticketcode, [OUT]); 

					SET	@XRD = ETL.BulkXRD(@XRD, @TMPDELTA)
					SET	@XTKM_TMP = ETL.BulkXTKM(@XTKM_TMP, @TMPTICKETMATCHED)
					SET	@XTKM_RAW = ETL.BulkXTKM(@XTKM_RAW, @RAWTICKETMATCHED)

                END 
            END 

			---------------------------------------------------------------- 
			----iterazione successiva 
			---------------------------------------------------------------- 
			SET @IterationNum += 1 
    END 

    -------------------------------- 
    -- Matching TicketIN -- 
    --------------------------------     
    SET @IterationNum = 1 
    SET @MatchedCountTotIn = 0 

    --TicketIn Da Matchare 
    --INSERT INTO [TMP].[Deltaticketin] 
    --            (rowid, 
    --            totalticketin, 
    --            servertime, 
    --            machineid) 
    --SELECT rowid, 
    --        totalticketin, 
    --        servertime, 
    --        machineid 
    --FROM	tmp.Delta 
    --WHERE	totalticketin <> 0 
    --AND		ticketcode IS NULL 
	SELECT	@XDTKIN = ETL.WriteXDTK(@XDTKIN, rowid, totalticketin, NULL, servertime, machineid)
	FROM	ETL.GETAllXRD(@XRD)
    WHERE	totalticketin <> 0 
    AND		ticketcode IS NULL 

    SET @INCount = @@ROWCOUNT 

    -- Ciclo Iterazioni 
    WHILE	@IterationNum <= 3 
    AND		@MatchedCountTotIn < @InCount
		BEGIN 
			-- inizializzo 
			--TRUNCATE TABLE [TMP].[Ticketmatched] 
			SET @XTKM_TMP = NULL
			SET @MatchedCount = 0 

			--iterazioni successive 
			IF @IterationNum = 2 
				SELECT @OffSetIn = @OffSetIn * 5 

			IF @IterationNum = 3 
				SELECT @OffSetIn = @OffSetIn * 10 
        
			-- Matching ticket 
			;WITH cte_tck_in AS(
				SELECT 
						ticketcode 
                        ,rowid 
                --FROM	[TMP].[Deltaticketin] DT
				FROM	ETL.GetAllXDTK(@XDTKIN) DT 
                        CROSS APPLY (
							SELECT	TOP 1 
									* 
                            --FROM	tmp.Ticket T1
							FROM	ETL.GetAllXTICKETS(@XTICKETS) T1 
                            WHERE	(payoutdate BETWEEN DATEADD(SECOND, -@OffSetIn, servertime) AND DATEADD(SECOND, @OffSetIn, servertime) )
                            AND		DT.totalticketin = T1.ticketvalue 
                            AND		payoutmachineid = machineid 
                            AND		ticketcode NOT IN(
										SELECT	ticketcode 
                                        --FROM	[RAW].[Ticketmatched] 
										FROM	ETL.GetAllXTKM(@XTKM_RAW)
                                        WHERE	[OUT] = 0
									) 
							ORDER  BY ABS(DATEDIFF(SECOND, dt.servertime, t1.payoutdate))
						) AS TI
			)
			 
			-- inserisco ticket matchati 
			--INSERT	INTO [TMP].[Ticketmatched](ticketcode, rowid) 
			--SELECT	ticketcode, rowid 
			--FROM	cte_tck_in 
			SELECT	@XTKM_TMP = ETL.WriteXTKM(@XTKM_TMP ,ticketcode, rowid, NULL) 
			FROM	cte_tck_in 

			SET @MatchedCount = @@ROWCOUNT 
			SET @MatchedCountTotIn += @MatchedCount 

			IF @MatchedCount > 0 
				BEGIN 
					INSERT	@TMPDELTA
					SELECT	* FROM ETL.GetAllXRD(@XRD)

					INSERT	@TMPTICKETMATCHED
					SELECT	* FROM ETL.GetAllXTKM(@XTKM_TMP)

					---- aggiorno delta 
					--MERGE	[TMP].[Delta] AS T 
					--USING	(SELECT ticketcode, rowid FROM [TMP].[Ticketmatched]) AS S 
					--ON		T.rowid = S.rowid 
					--WHEN	MATCHED 
					--THEN	UPDATE 
					--		SET ticketcode = S.ticketcode 
					--		OUTPUT inserted.ticketcode, 0 -- Tabella finale
					--		INTO [RAW].[Ticketmatched](ticketcode, [OUT]); 

					MERGE	@TMPDELTA AS T 
					USING	(SELECT ticketcode, rowid FROM @TMPTICKETMATCHED) AS S 
					ON		T.rowid = S.rowid
					WHEN	MATCHED 
					THEN	UPDATE 
							SET ticketcode = S.ticketcode 
							OUTPUT inserted.ticketcode, 0 -- Tabella finale 
							INTO @RAWTicketmatched(ticketcode, [OUT]); 

					SET	@XRD = ETL.BulkXRD(@XRD, @TMPDELTA)
					SET	@XTKM_TMP = ETL.BulkXTKM(@XTKM_TMP, @TMPTICKETMATCHED)
					SET	@XTKM_RAW = ETL.BulkXTKM(@XTKM_RAW, @RAWTICKETMATCHED)

				END 

			-- ticketIn Rimanenti da Matchare 
			SET @XDTKIN = NULL

			--INSERT	INTO [TMP].[Deltaticketin](rowid,totalticketin,servertime,machineid) 
			--SELECT	rowid,totalticketin,servertime,machineid 
			--FROM	tmp.Delta 
			--WHERE	totalticketin <> 0 
			--AND		ticketcode IS NULL 

			SELECT	@XDTKIN = ETL.WriteXDTK(@XDTKIN, rowid, totalticketin, NULL, servertime, machineid)
			FROM	ETL.GETAllXRD(@XRD)
			WHERE	totalticketin <> 0 
			AND		ticketcode IS NULL 

			-- Iterazioni successive 
			SET @IterationNum += 1 
		END 

    -- Controlli Finali 
    IF @MatchedCountTotIN = @InCount 
		SET @InMatched = 1 

    IF @MatchedCountTotOut = @OutCount 
		SET @OutMatched = 1 

    -- Log operazione 
	EXEC ETL.WriteLog @@PROCID, 'Matching ticket terminato', @TicketCode, @BatchID -- Log operazione  

    -- Errore specifico 
    IF @InMatched <> 1 
    OR @OutMatched <> 1 
		BEGIN 
			RAISERROR ('Not every ticket has been matched',16,1); 
		END 

    IF @MatchedCountTotIN = 0 
    AND @MatchedCountTotout = 0 
		BEGIN 
			RAISERROR ('None of the tickets has been matched',16,1); 
		END 
END try 

-- Gestione Errore 
BEGIN catch 
    ----Select ERROR_MESSAGE()  
    --EXECUTE [ERR].[Usplogerror] 
    --@ErrorTicket = @TicketCode, 
    --@ErrorRequestDetailID = @BatchID 

    --SET @ReturnCode = -1; 
END catch 

--RETURN @ReturnCode 

-- fine calcoli  
