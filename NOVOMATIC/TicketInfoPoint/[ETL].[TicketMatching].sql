﻿/* 
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
			,@ReturnCode			int = 0 Output
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

		SELECT
				@ConcessionaryID = concessionaryid
				,@OffSetOut = offsetout 
				,@OffSetIn = offsetin 
				,@OffSetMH = offsetmh 
		FROM	ETL.GetAllXCONFIG(@XCONFIG) 

		SELECT	
				@BatchID = BatchID 
		FROM	ETL.GetAllXTICKETS(@XTMPTicketStart)
	
		SELECT
				@FromServerTime = fromout 
				,@ToServerTime = toout 
				,@ClubID = clubid
				,@MachineID = MachineID 
		FROM	ETL.GetAllXCCK(@XTMPCountersCork)

		EXEC ETL.WriteLog @@PROCID, 'Matching ticket iniziato', @TicketCode, @BatchID -- Log operazione  

		IF @Direction = 0 
			BEGIN 
				SET @TicketDataTO = DATEADD(DD, 1, @ToServerTime)
				SET @TicketDataFrom = DATEADD(DD, -@DDRange, @FromServerTime) 
			END 

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

		INSERT	@TMPDELTATICKETOUT 
		SELECT	RowID,TotalTicketIN,TotalOut,ServerTime,MachineID
		FROM	ETL.GETAllXRD(@XTMPDelta)
		WHERE	totalout != 0 
		AND		ticketcode IS NULL 
		SET		@XTMPDeltaTicketOUT = ETL.BulkXDTK(@XTMPDeltaTicketOUT,@TMPDELTATICKETOUT)

		SET @OutCount = @@ROWCOUNT
		
		SET @MatchedCountTotOut = 0 

		WHILE @IterationNum <= 3 AND @MatchedCountTotOut < @OutCount 
			BEGIN 
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
         
				DELETE FROM @TMPTICKETMATCHED
				
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
						FROM	ETL.GETAllXDTK(@XTMPDeltaTicketOUT)
					) AS	T1 
							INNER JOIN 
							ETL.GetAllXTICKETS(@XTMPTICKET) AS T2 
							ON (printingdate BETWEEN DATEADD(SECOND, -@OffSetOut, servertime) AND DATEADD(SECOND, @OffSetOut, servertime)) 
							AND T1.totalout = T2.ticketvalue 
							AND printingmachineid = machineid 
							AND ticketcode NOT IN (
								SELECT	ticketcode 
								FROM	ETL.GetAllXTKM(@XRAWTicketMatched) 
								WHERE	[OUT] = 1
							)
				)
				
				INSERT	@TMPTICKETMATCHED
				SELECT	ticketcode, rowid, NULL AS [OUT]
				FROM	cte_tck_out 
				WHERE	rowrank = 1 

				SET @MatchedCount = @@ROWCOUNT 
				SET @MatchedCountTotOut += @MatchedCount

				IF @MatchedCount > 0 
					BEGIN
						DELETE FROM @TMPDELTA 
						INSERT	@TMPDELTA
						SELECT	* FROM ETL.GetAllXRD(@XTMPDelta)
						SET		@XTMPDelta = NULL

						MERGE	@TMPDELTA AS T 
						USING	(SELECT ticketcode, rowid FROM @TMPTICKETMATCHED) AS S 
						ON		T.rowid = S.rowid
						WHEN	MATCHED 
						THEN	UPDATE 
								SET		ticketcode = S.ticketcode 
								OUTPUT	inserted.ticketcode, 1 
								INTO	@RAWTicketmatched(ticketcode, [OUT]); 

						SET	@XTMPDelta = ETL.BulkXRD(@XTMPDelta, @TMPDELTA)
						SET	@XTMPTicketMatched = ETL.BulkXTKM(@XTMPTicketMatched, @TMPTICKETMATCHED)
						SET	@XRAWTicketMatched = ETL.BulkXTKM(@XRAWTicketMatched, @RAWTICKETMATCHED)
					END
			ELSE 
				BEGIN 
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
							SELECT	
									rowid 
									,totalout 
									,servertime 
									,machineid 
							FROM	ETL.GETAllXDTK(@XTMPDeltaTicketOUT)
						) AS	T1 
								INNER JOIN 
								ETL.GetAllXTICKETS(@XTMPTICKET) AS T2 
								ON (eventdate BETWEEN DATEADD(SECOND, -@OffSetMH, servertime) AND DATEADD(SECOND, @OffSetMH, servertime) )
								AND T1.totalout = T2.ticketvalue 
								AND mhmachineid = machineid 
								AND ticketcode NOT IN (
									SELECT	ticketcode 
									FROM	ETL.GetAllXTKM(@XRAWTicketMatched) 
									WHERE	[OUT] = 1
								)
					)
					INSERT	@TMPTICKETMATCHED
					SELECT	ticketcode, rowid, NULL AS [OUT]
					FROM	cte_tck_mh 
					WHERE	rowrank = 1 

					SET @MatchedCount = @@ROWCOUNT 
					SET @MatchedCountTotOut += @MatchedCount 

					IF @MatchedCount > 0 
					BEGIN 
						DELETE FROM @TMPDELTA 
						INSERT	@TMPDELTA
						SELECT	* FROM ETL.GetAllXRD(@XTMPDelta)
						SET		@XTMPDelta = NULL

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
					END 
				END 

				SET @IterationNum += 1 
		END 

		SET @IterationNum = 1 
		SET @MatchedCountTotIn = 0 

		INSERT	@TMPDELTATICKETIN 
		SELECT	RowID,TotalTicketIN,NULL,ServerTime,MachineID
 		FROM	ETL.GETAllXRD(@XTMPDelta)
		WHERE	totalticketin <> 0 
		AND		ticketcode IS NULL 

		SET @INCount = @@ROWCOUNT 

		SET @XTMPDeltaTICKETIN = ETL.BulkXDTK(@XTMPDeltaTICKETIN,@TMPDELTATICKETIN)

		WHILE	@IterationNum <= 3 
		AND		@MatchedCountTotIn < @InCount
			BEGIN 
				SET @XTMPTicketMatched = NULL
				SET @MatchedCount = 0 

				IF @IterationNum = 2 
					SELECT @OffSetIn = @OffSetIn * 5 

				IF @IterationNum = 3 
					SELECT @OffSetIn = @OffSetIn * 10 
        
				;WITH cte_tck_in AS(
					SELECT 
							ticketcode 
							,rowid 
					FROM	ETL.GetAllXDTK(@XTMPDeltaTicketIN) DT 
							CROSS APPLY (
								SELECT	TOP 1 * 
								FROM	ETL.GetAllXTICKETS(@XTMPTICKET) T1 
								WHERE	(payoutdate BETWEEN DATEADD(SECOND, -@OffSetIn, servertime) AND DATEADD(SECOND, @OffSetIn, servertime) )
								AND		DT.totalticketin = T1.ticketvalue 
								AND		payoutmachineid = machineid 
								AND		ticketcode NOT IN(
											SELECT	ticketcode 
											FROM	ETL.GetAllXTKM(@XRAWTicketMatched)
											WHERE	[OUT] = 0
										) 
								ORDER  BY ABS(DATEDIFF(SECOND, dt.servertime, t1.payoutdate))
							) AS TI
				)
			 
				INSERT	@TMPTicketMatched(ticketcode, rowid)
				SELECT	ticketcode, rowid 
				FROM	cte_tck_in 

				SET @MatchedCount = @@ROWCOUNT 
				SET @MatchedCountTotIn += @MatchedCount
				
				SET @XTMPTicketMatched = ETL.BulkXTKM(@XTMPTicketMatched,@TMPTicketMatched)

				IF @MatchedCount > 0 
					BEGIN 
						DELETE FROM @TMPDELTA 
						INSERT	@TMPDELTA
						SELECT	* FROM ETL.GetAllXRD(@XTMPDelta)
						SET		@XTMPDelta = NULL

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
					END 

				SET @XTMPDeltaTicketIN = NULL

				INSERT	@TMPDELTATICKETIN 
				SELECT	RowID,TotalTicketIN,NULL,ServerTime,MachineID
 				FROM	ETL.GETAllXRD(@XTMPDelta)
				WHERE	totalticketin <> 0 
				AND		ticketcode IS NULL 

				SET @IterationNum += 1 
			END 

		IF @MatchedCountTotIN = @InCount 
			SET @InMatched = 1 

		IF @MatchedCountTotOut = @OutCount 
			SET @OutMatched = 1 

		EXEC ETL.WriteLog @@PROCID, 'Matching ticket terminato', @TicketCode, @BatchID -- Log operazione  

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
END TRY

BEGIN CATCH 
	INSERT	ERR.ErrorLog(ErrorTime, ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, ErrorTicketCode, ErrorRequestDetailID) 
    SELECT
			GETDATE() AS ErrorTime
			,ERROR_NUMBER() AS ErrorNumber
			,ERROR_SEVERITY() AS ErrorSeverity
			,ERROR_STATE() AS ErrorState
			,ISNULL(ERROR_PROCEDURE(), ISNULL(dbo.GetProcName(@@PROCID),'*Unknown*')) AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine
			,ERROR_MESSAGE() AS	ErrorMessage
			,@TicketCode AS ErrorTicketCode
			,@BatchID AS ErrorRequestDetailID
            SET @ReturnCode = -1;
END CATCH 

RETURN @ReturnCode
