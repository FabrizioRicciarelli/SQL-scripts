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
		@XCONFIG			XML = NULL
		,@TicketCode		varchar(50) = NULL
		,@Direction			bit
		,@XTMPCountersCork	XML = NULL -- ex TMP.CountersCork
		,@XTMPTicketStart	XML = NULL -- ex TMP.Ticket
		,@XTMPDelta			XML = NULL -- ex TMP.Delta 
		,@XRAWTicketMatched	XML OUTPUT -- ex RAW.TicketMatched
*/ 
ALTER PROC	[ETL].[TicketMatching]
			@XCONFIG				XML = NULL
			,@TicketCode			varchar(50) = NULL
			,@Direction				bit
			,@XTMPCountersCork		XML = NULL -- ex TMP.CountersCork
			,@XTMPTicketStart		XML = NULL -- ex TMP.TicketStart
			,@XTMPDelta				XML OUTPUT -- ex TMP.Delta 
AS 
SET NOCOUNT ON;
 
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
		,@ClubID					int 
		,@MachineID					tinyInt 
		,@DDRange					smallint 
		,@MatchedCount				int 
		,@OutMatched				bit 
		,@InMatched					bit
		,@MatchedCountTotOut		int 
		,@MatchedCountTotIn			int 
		,@ConcessionaryID			tinyint
		,@BatchID					int
		,@XTMPTICKET				XML -- ex TMP.TICKET
		,@XTMPTicketMatched			XML -- ex TMP.TicketMatched
		,@XTMPDeltaTicketIN			XML -- ex TMP.Deltaticketin
		,@XTMPDeltaTicketOUT		XML -- ex TMP.Deltaticketout
		,@XRAWTicketMatched			XML -- ex RAW.TicketMatched

		,@TMPDELTATICKETOUT			ETL.DELTATICKET_TYPE
		,@TMPDELTATICKETIN			ETL.DELTATICKET_TYPE

		-- PER MERGE
		,@TMPDELTA					ETL.RAWDELTA_TYPE
		,@TMPTICKETMATCHED			ETL.TICKETMATCHED_TYPE
		,@RAWTICKETMATCHED			ETL.TICKETMATCHED_TYPE

BEGIN TRY
		SELECT 
				@DataStart = SYSDATETIME() 
				,@IterationNum = 1 
				,@OutCount = 0 
				,@InCount = 0 
				,@DDRange = 2 
				,@MatchedCount = 0 

		SET @XTMPDeltaTicketIN = NULL	--TRUNCATE TABLE [TMP].[Deltaticketin]
		SET @XTMPDeltaTicketOUT = NULL	--TRUNCATE TABLE [TMP].[Deltaticketout]
		SET @XTMPTICKET = NULL			--TRUNCATE TABLE [TMP].[Ticket]
		SET @XTMPTicketMatched = NULL	--TRUNCATE TABLE [TMP].[Ticketmatched]
		SET @XRAWTicketMatched = NULL	--TRUNCATE TABLE [RAW].[Ticketmatched]

		--Inizializzo 
		SELECT
				@ConcessionaryID = concessionaryid
				,@OffSetOut = offsetout 
				,@OffSetIn = offsetin 
				,@OffSetMH = offsetmh 
		--FROM	config.[Table] 
		FROM	ETL.GetAllXCONFIG(@XCONFIG) 

		SELECT	
				@BatchID = BatchID 
		FROM	ETL.GetAllXTICKETS(@XTMPTicketStart)
	
		-- Intervallo di calcolo 
		SELECT
				@FromServerTime = fromout 
				,@ToServerTime = toout 
				,@ClubID = clubid
				,@MachineID = MachineID 
		--FROM	[TMP].Counterscork 
		FROM	ETL.GetAllXCCK(@XTMPCountersCork)

		-- Log operazione 
		EXEC ETL.WriteLog @@PROCID, 'Matching ticket iniziato', @TicketCode, @BatchID -- Log operazione  

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

		EXEC	ETL.ExtractTicketsFromPIN
				@ConcessionaryID = @ConcessionaryID
				,@ClubID = @ClubID
				,@Fromdate = @TicketDataFrom
				,@ToDate = @TicketDataTO
				,@IsMhx = 1
				,@XMLTICKETS = @XTMPTICKET OUTPUT

		---- DEBUG
		--SELECT	'1. Reading tickets' AS Phase
		--		,@TicketDataFrom AS TicketDataFrom
		--		,@TicketDataTO AS TicketDataTO
		--SELECT	'1. TMP.TICKET' AS TABLENAME
		--		,* 
		--FROM	ETL.GetAllXTICKETS(@XTMPTICKET)

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
		INSERT	@TMPDELTATICKETOUT--(RowID,TotalTicketIN,TotalOut,ServerTime,MachineID) 
		SELECT	RowID,TotalTicketIN,TotalOut,ServerTime,MachineID
		FROM	ETL.GETAllXRD(@XTMPDelta)
		WHERE	totalout != 0 
		AND		ticketcode IS NULL 
		SET		@XTMPDeltaTicketOUT = ETL.BulkXDTK(@XTMPDeltaTicketOUT,@TMPDELTATICKETOUT)

		SET @OutCount = @@ROWCOUNT -- VERIFICARE SE FUNZIONA, ALTRIMENTI DECOMMENTARE LE RIGHE CHE SEGUONO E COMMENTARE LA PRESENTE
		--SELECT	@OutCount = COUNT(*)
		--FROM	ETL.GetAllXDTK(@XTMPDeltaTicketOUT)
		
		-- Massimo un TotalOut 
		SET @MatchedCountTotOut = 0 

		---- DEBUG
		--SELECT	'2. Starting' AS Phase
		--		 ,@OutCount AS OutCount
		--SELECT	'2. @XTMPDeltaTicketOUT' AS TABLENAME
		--		,* 
		--FROM	ETL.GetAllXDTK(@XTMPDeltaTicketOUT)

		-- iterazioni 
		WHILE @IterationNum <= 3 AND @MatchedCountTotOut < @OutCount 
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
         
				---- DEBUG
				--SELECT	'3. Inside "WHILE @IterationNum <= 3 AND @MatchedCountTotOut < @OutCount"' AS Phase
				--		 ,@IterationNum AS IterationNum
				--		 ,@OFFSETOUT AS OFFSETOUT
				--		 ,@OffSetMH AS OffSetMH

				DELETE FROM @TMPTICKETMATCHED
				
				-- Matching ticket OUT 
				;WITH cte_tck_out AS (
					SELECT 
							ticketcode 
							,servertime 
							,machineid 
							,ticketvalue 
							,RANK() OVER (PARTITION BY ticketvalue ORDER BY ABS(DATEDIFF(SECOND, servertime, printingdate)) ASC) AS RowRank 
							,T1.rowid AS RowID 
					FROM(
						SELECT 
								rowid
								,totalout
								,servertime
								,machineid 
						--FROM	[TMP].[Deltaticketout]) T1
						FROM	ETL.GETAllXDTK(@XTMPDeltaTicketOUT)
					) AS	T1 
							INNER JOIN 
							--tmp.Ticket T2	
							ETL.GetAllXTICKETS(@XTMPTICKET) AS T2 
							ON (printingdate BETWEEN DATEADD(SECOND, -@OffSetOut, servertime) AND DATEADD(SECOND, @OffSetOut, servertime)) 
							AND T1.totalout = T2.ticketvalue 
							AND printingmachineid = machineid 
							-- Escludo quelli già linkati 
							AND ticketcode NOT IN (
								SELECT	ticketcode 
								--FROM   [RAW].[Ticketmatched]
								FROM	ETL.GetAllXTKM(@XRAWTicketMatched) 
								WHERE	[OUT] = 1
							)
				)
				
        
				-- inserisco ticket matchati 
				--INSERT INTO [TMP].[Ticketmatched](ticketcode, rowid) 
				--SELECT ticketcode, rowid 
				--FROM   cte_tck_out 
				--WHERE  rowrank = 1
				INSERT	@TMPTICKETMATCHED
				SELECT	ticketcode, rowid, NULL AS [OUT]
				FROM	cte_tck_out 
				WHERE	rowrank = 1 

				SET @MatchedCount = @@ROWCOUNT 
				SET @MatchedCountTotOut += @MatchedCount

				---- DEBUG
				--SELECT	'4. After "WITH cte_tck_out"' AS Phase
				--		 ,@MatchedCount AS MatchedCount
				--		 ,@MatchedCountTotOut AS MatchedCountTotOut
				--SELECT	'4. @TMPTICKETMATCHED (type)' AS TABLENAME
				--		,* 
				--FROM	@TMPTICKETMATCHED
				--SELECT	'4. @XTMPDelta' AS TABLENAME
				--		,* 
				--FROM	ETL.GetAllXRD(@xTMPDELTA)
				
				---------------------------------------------------------------- 
				-- Aggiorna tabella delta -- 
				---------------------------------------------------------------- 
				IF @MatchedCount > 0 
					BEGIN
						DELETE FROM @TMPDELTA 
						INSERT	@TMPDELTA
						SELECT	* FROM ETL.GetAllXRD(@XTMPDelta)
						SET		@XTMPDelta = NULL
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
								SET		ticketcode = S.ticketcode 
								OUTPUT	inserted.ticketcode, 1 -- salvo i ticket Matchati 
								INTO	@RAWTicketmatched(ticketcode, [OUT]); 

						SET	@XTMPDelta = ETL.BulkXRD(@XTMPDelta, @TMPDELTA)
						SET	@XTMPTicketMatched = ETL.BulkXTKM(@XTMPTicketMatched, @TMPTICKETMATCHED)
						SET	@XRAWTicketMatched = ETL.BulkXTKM(@XRAWTicketMatched, @RAWTICKETMATCHED)

						---- DEBUG
						--SELECT	'5a. After MERGE NO-MHx' AS Phase
						--SELECT	'5a. @TMPTICKETMATCHED (type)' AS TABLENAME
						--		,* 
						--FROM	@TMPTICKETMATCHED
						--SELECT	'5a. @RAWTICKETMATCHED (type)' AS TABLENAME
						--		,* 
						--FROM	@RAWTICKETMATCHED
						--SELECT	'5a. @XTMPDelta' AS TABLENAME
						--		,* 
						--FROM	ETL.GetAllXRD(@xTMPDELTA)

					END
				 
			-- Provo con i pagamenti remoti 
			ELSE 
				BEGIN 
					---------------------------------------------------------------- 
					-- Matching MH -- 
					---------------------------------------------------------------- 
					DELETE FROM @TMPTICKETMATCHED

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
							FROM	ETL.GETAllXDTK(@XTMPDeltaTicketOUT)
						) AS	T1 
								INNER JOIN 
								--tmp.Ticket AS T2 
								ETL.GetAllXTICKETS(@XTMPTICKET) AS T2 
								ON (eventdate BETWEEN DATEADD(SECOND, -@OffSetMH, servertime) AND DATEADD(SECOND, @OffSetMH, servertime) )
								AND T1.totalout = T2.ticketvalue 
								AND mhmachineid = machineid 
								AND ticketcode NOT IN (
									SELECT	ticketcode 
									--FROM	[RAW].[Ticketmatched] 
									FROM	ETL.GetAllXTKM(@XRAWTicketMatched) 
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
					INSERT	@TMPTICKETMATCHED
					SELECT	ticketcode, rowid, NULL AS [OUT]
					FROM	cte_tck_mh 
					WHERE	rowrank = 1 

					SET @MatchedCount = @@ROWCOUNT 
					SET @MatchedCountTotOut += @MatchedCount 

					---------------------------------------------------------------- 
					-- Aggiorna tabella delta -- 
					----------------------------------------------------------------     
					IF @MatchedCount > 0 
					BEGIN 
						--INSERT	@TMPDELTA
						--SELECT	* FROM ETL.GetAllXRD(@XTMPDelta)
						DELETE FROM @TMPDELTA 
						INSERT	@TMPDELTA
						SELECT	* FROM ETL.GetAllXRD(@XTMPDelta)
						SET		@XTMPDelta = NULL

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
								SET		ticketcode = S.ticketcode 
								OUTPUT	inserted.ticketcode, 1 -- salvo i ticket Matchati 
								INTO	@RAWTicketmatched(ticketcode, [OUT]); 

						SET	@XTMPDelta = ETL.BulkXRD(@XTMPDelta, @TMPDELTA)
						SET	@XTMPTicketMatched = ETL.BulkXTKM(@XTMPTicketMatched, @TMPTICKETMATCHED)
						SET	@XRAWTicketMatched = ETL.BulkXTKM(@XRAWTicketMatched, @RAWTICKETMATCHED)

						---- DEBUG
						--SELECT	'5b. After MERGE Matching MH' AS Phase
						--SELECT	'5b. @TMPTICKETMATCHED (type)' AS TABLENAME
						--		,* 
						--FROM	@TMPTICKETMATCHED
						--SELECT	'5b. @XTMPDelta' AS TABLENAME
						--		,* 
						--FROM	ETL.GetAllXRD(@XTMPDelta)
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
		INSERT	@TMPDELTATICKETIN--(RowID,TotalTicketIN,TotalOut,ServerTime,MachineID) 
		SELECT	RowID,TotalTicketIN,NULL,ServerTime,MachineID
 		FROM	ETL.GETAllXRD(@XTMPDelta)
		WHERE	totalticketin <> 0 
		AND		ticketcode IS NULL 

		SET @INCount = @@ROWCOUNT 

		SET @XTMPDeltaTICKETIN = ETL.BulkXDTK(@XTMPDeltaTICKETIN,@TMPDELTATICKETIN)

		-- Ciclo Iterazioni 
		WHILE	@IterationNum <= 3 
		AND		@MatchedCountTotIn < @InCount
			BEGIN 
				-- inizializzo 
				--TRUNCATE TABLE [TMP].[Ticketmatched] 
				SET @XTMPTicketMatched = NULL
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
					FROM	ETL.GetAllXDTK(@XTMPDeltaTicketIN) DT 
							CROSS APPLY (
								SELECT	TOP 1 
										* 
								--FROM	tmp.Ticket T1 
								FROM	ETL.GetAllXTICKETS(@XTMPTICKET) T1 
								WHERE	(payoutdate BETWEEN DATEADD(SECOND, -@OffSetIn, servertime) AND DATEADD(SECOND, @OffSetIn, servertime) )
								AND		DT.totalticketin = T1.ticketvalue 
								AND		payoutmachineid = machineid 
								AND		ticketcode NOT IN(
											SELECT	ticketcode 
											--FROM	[RAW].[Ticketmatched] 
											FROM	ETL.GetAllXTKM(@XRAWTicketMatched)
											WHERE	[OUT] = 0
										) 
								ORDER  BY ABS(DATEDIFF(SECOND, dt.servertime, t1.payoutdate))
							) AS TI
				)
			 
				-- inserisco ticket matchati 
				--INSERT	INTO [TMP].[Ticketmatched](ticketcode, rowid) 
				--SELECT	ticketcode, rowid 
				--FROM	cte_tck_in
				INSERT	@TMPTicketMatched(ticketcode, rowid)
				SELECT	ticketcode, rowid 
				FROM	cte_tck_in 

				SET @MatchedCount = @@ROWCOUNT 
				SET @MatchedCountTotIn += @MatchedCount
				
				SET @XTMPTicketMatched = ETL.BulkXTKM(@XTMPTicketMatched,@TMPTicketMatched)

				IF @MatchedCount > 0 
					BEGIN 
						--INSERT	@TMPDELTA
						--SELECT	* FROM ETL.GetAllXRD(@XTMPDelta)
						DELETE FROM @TMPDELTA 
						INSERT	@TMPDELTA
						SELECT	* FROM ETL.GetAllXRD(@XTMPDelta)
						SET		@XTMPDelta = NULL

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
						USING	(SELECT ticketcode, rowid FROM ETL.GetAllXTKM(@XTMPTicketMatched)) AS S 
						ON		T.rowid = S.rowid
						WHEN	MATCHED 
						THEN	UPDATE 
								SET		ticketcode = S.ticketcode 
								OUTPUT	inserted.ticketcode, 0 -- Tabella finale 
								INTO	@RAWTicketmatched(ticketcode, [OUT]); 

						SET	@XTMPDelta = ETL.BulkXRD(@XTMPDelta, @TMPDELTA)
						SET	@XTMPTicketMatched = ETL.BulkXTKM(@XTMPTicketMatched, @TMPTICKETMATCHED)
						SET	@XRAWTicketMatched = ETL.BulkXTKM(@XRAWTicketMatched, @RAWTICKETMATCHED)

						---- DEBUG
						--SELECT	'6. After MERGE matching ticketin' AS Phase
						--SELECT	'6. @TMPTICKETMATCHED (type)' AS TABLENAME
						--		,* 
						--FROM	@TMPTICKETMATCHED
						--SELECT	'6. @RAWTICKETMATCHED (type)' AS TABLENAME
						--		,* 
						--FROM	@RAWTICKETMATCHED
						--SELECT	'6. @XTMPDelta' AS TABLENAME
						--		,* 
						--FROM	ETL.GetAllXRD(@XTMPDelta)
					END 

				-- ticketIn Rimanenti da Matchare 
				SET @XTMPDeltaTicketIN = NULL

				--INSERT	INTO [TMP].[Deltaticketin](rowid,totalticketin,servertime,machineid) 
				--SELECT	rowid,totalticketin,servertime,machineid 
				--FROM	tmp.Delta 
				--WHERE	totalticketin <> 0 
				--AND		ticketcode IS NULL 

				INSERT	@TMPDELTATICKETIN--(RowID,TotalTicketIN,TotalOut,ServerTime,MachineID) 
				SELECT	RowID,TotalTicketIN,NULL,ServerTime,MachineID
 				FROM	ETL.GETAllXRD(@XTMPDelta)
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
		IF @InMatched != 1 
		OR @OutMatched != 1 
			BEGIN 
				RAISERROR ('Not every ticket has been matched',16,1); 
			END 

		IF @MatchedCountTotIN = 0 
		AND @MatchedCountTotout = 0 
			BEGIN 
				RAISERROR ('None of the tickets has been matched',16,2); 
			END 

		---- DEBUG
		--SELECT	'7. END TICKETMATCHING' AS Phase
		--SELECT	'7. @XTMPDelta' AS TABLENAME
		--		,* 
		--FROM	ETL.GetAllXRD(@XTMPDelta)
END TRY

BEGIN CATCH 
    SELECT
			ERROR_NUMBER() AS ErrorNumber
			,ERROR_SEVERITY() AS Severity
			,ERROR_STATE() AS ErrorState
			,ISNULL(ERROR_PROCEDURE(), ISNULL(dbo.GetProcName(@@PROCID),'*Unknown*')) AS ErrorProcedure  
			,ERROR_LINE() AS ProcedureLine
			,ERROR_MESSAGE() As ErrorMessage
END CATCH 
