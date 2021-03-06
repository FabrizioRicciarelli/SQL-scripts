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
			,@XRAWDelta					XML OUTPUT -- ex RAW.Delta
			,@XRAWSession				XML OUTPUT -- ex RAW.Session
			,@XTMPTicketServerTime		XML = NULL OUTPUT
			,@XTMPCountersCork			XML = NULL OUTPUT
			,@XRAWTicketToCalc			XML = NULL OUTPUT-- ex RAW.Tickettocalc
			,@XTMPRawData_View			XML = NULL OUTPUT
			,@XRAWTicketMatched			XML = NULL OUTPUT
			,@XTMPDeltaTicketIN			XML = NULL OUTPUT
			,@XTMPDeltaTicketOUT		XML = NULL OUTPUT
			,@ReturnCode				int = 0 Output 
AS

SET nocount ON; 
SET ANSI_WARNINGS ON;

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

		,@XTicketToCalcSucc			XML
		,@RAWSESSION				ETL.RAWSESSION_TYPE
		,@RAWTICKETTOCALCTYPE		ETL.TTC_TYPE
		,@RAWDelta					ETL.RAWDELTA_TYPE

BEGIN TRY 
    SET @CalcEnd = 0 
    
	EXEC ETL.WriteLog @@PROCID, 'Calcolo globale iniziato', @TicketCode, @BatchID -- Log operazione  

    SET @XRAWDelta = NULL			--TRUNCATE TABLE RAW.Delta 
    SET @XRAWSession = NULL			--TRUNCATE TABLE RAW.Session 
    SET @XRAWTicketToCalc = NULL	--TRUNCATE TABLE RAW.Tickettocalc
	
    IF @Direction = 0 
    BEGIN 
        SET @SessionParentID = NULL 
        SET @Level = 0 

        EXEC	ETL.Calcall 
				@Direction = @Direction
				,@TicketCode = @TicketCode
				,@Level	= @Level
				,@SessionParentID =	NULL
				,@BatchID =	@BatchID
				,@Xconfig =	@Xconfig
				,@XTMPTicketStart =	@XTMPTicketStart
				,@XRAWSession = @XRAWSession OUTPUT						-- ex RAW.Session
				,@XRAWDelta = @XRAWDelta OUTPUT							-- ex RAW.Delta
				,@XTMPTicketServerTime = @XTMPTicketServerTime OUTPUT	-- ex TMP.TicketServerTime
				,@XTMPCountersCork = @XTMPCountersCork OUTPUT			-- ex TMP.CountersCork
				,@XRAWTicketMatched = @XRAWTicketMatched OUTPUT			-- ex RAW.TicketMatched
				,@XTMPDeltaTicketIN = @XTMPDeltaTicketIN OUTPUT			-- ex TMP.DeltaTicketIN
				,@XTMPDeltaTicketOUT = @XTMPDeltaTicketOUT OUTPUT		-- ex TMP.DeltaTicketOUT

		SELECT	@SessionID = sessionid 
		FROM	ETL.GetAllXRS(@XRAWSession)
		WHERE	startticketcode = @TicketCode

		INSERT	@RAWTICKETTOCALCTYPE(TicketCode,FlagCalc,SessionID,SessionParentID ,Level)
		SELECT	@TicketCode,1,@SessionID,@SessionParentID,@Level

        SELECT @SessionParentID = @SessionID 

        SET @Level += 1 

		INSERT	@RAWTICKETTOCALCTYPE(TicketCode,FlagCalc,SessionID,SessionParentID ,Level)
        SELECT	ticketcode,0,@SessionID,@SessionParentID,@Level 
        FROM	ETL.GETAllXRD(@XRAWDelta) 
        WHERE	sessionid = @SessionID 
        AND		totalin <> 0 
        AND		ticketcode IS NOT NULL
        
		SET		@NumTicket = @@ROWCOUNT

		SELECT	@XTicketToCalcSucc = ETL.WriteXTTC(@XTicketToCalcSucc,ticketcode,NULL,sessionid, sessionparentid, level)
		FROM	@RAWTICKETTOCALCTYPE 
        WHERE	level = @Level

		SET		@XRAWTicketToCalc = ETL.BulkXTTC(@XRAWTicketToCalc,@RAWTICKETTOCALCTYPE)

        SET @RecID = 1 

		WHILE (@RecID <= @NumTicket) AND (@Level < @MaxLevel)
            BEGIN

                SELECT	@TicketCode = TicketCode, @Level = Level 
				FROM	ETL.GetAllXTTC(@XTicketToCalcSucc)
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
						,@XRAWSession = @XRAWSession OUTPUT						-- ex RAW.Session
						,@XRAWDelta = @XRAWDelta OUTPUT							-- ex RAW.Delta
						,@XTMPTicketServerTime = @XTMPTicketServerTime OUTPUT	-- ex TMP.TicketServerTime
						,@XTMPCountersCork = @XTMPCountersCork OUTPUT			-- ex TMP.CountersCork
						,@XRAWTicketMatched = @XRAWTicketMatched OUTPUT			-- ex RAW.TicketMatched
						,@XTMPDeltaTicketIN = @XTMPDeltaTicketIN OUTPUT			-- ex TMP.DeltaTicketIN
						,@XTMPDeltaTicketOUT = @XTMPDeltaTicketOUT OUTPUT		-- ex TMP.DeltaTicketOUT

				SELECT	@SessionID = sessionid 
				FROM	ETL.GetAllXRS(@XRAWSession)
 				WHERE	startticketcode = @TicketCode

				SET @CSVFieldValuesPairs = 'sessionid=' + CAST(@SessionID AS nvarchar(20)) + ',flagcalc=1'
				SET @CSVWhereConditionPairs = 'ticketcode=' + @TicketCode
				SET	@XRAWTicketToCalc = ETL.UpdMultiFieldX(@XRAWTicketToCalc,  @CSVFieldValuesPairs, @CSVWhereConditionPairs) 

				-- TRASFERIMENTO DA XML A OGGETTI ***_TYPE
				DELETE	FROM @RAWDelta
				INSERT	@RAWDelta
				SELECT	*						
				FROM	ETL.GetAllXRD(@XRAWDelta)

				DELETE FROM @RAWTICKETTOCALCTYPE
				INSERT	@RAWTICKETTOCALCTYPE(ticketcode,flagcalc,sessionid,sessionparentid,level)
				SELECT	ticketcode,flagcalc,sessionid,sessionparentid,level
				FROM	ETL.GetAllXTTC(@XRAWTicketToCalc)
				
				MERGE	@RAWTICKETTOCALCTYPE AS T 
				USING	(
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
				SET @XRAWTicketToCalc = ETL.BulkXTTC(@XRAWTicketToCalc, @RAWTICKETTOCALCTYPE)
						 
                SET @RecID += 1 

                IF @RecID > @NumTicket 
					BEGIN 
						SET @Level += 1 

						SET		@XTicketToCalcSucc = NULL
						SELECT	@XTicketToCalcSucc = ETL.WriteXTTC(@XTicketToCalcSucc,ticketcode,NULL,sessionid, sessionparentid, level)
						FROM	ETL.GetAllXTTC(@XRAWTicketToCalc) 
						WHERE	level = @Level

						SELECT	@NumTicket = @@ROWCOUNT
						SET		@RecID = 1
					END
            END 
    END 

    IF @Direction = 1 
		BEGIN 
			SELECT	@ClubID = ISNULL(@ClubID, clubid) 
			FROM	ETL.GetAllXTICKETS(@XTMPTicketStart)

			SELECT	@VltEndCredit = minvltendcredit 
			FROM	ETL.GetAllXCONFIG(@XCONFIG)

			SET @Level = 0 
			SET @ReturnCode = 0; 
			SET @SessionParentID = NULL 

			SELECT	@XRAWTicketToCalc = ETL.WriteXTTC(@XRAWTicketToCalc, @TicketCode, 0, @SessionID, @SessionParentID, @Level) 
		 
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
					SELECT	
							@TicketCode = ticketcode
							,@SessionParentID = sessionparentid 
					FROM	ETL.GetAllXTTC(@XRAWTicketToCalc)
					WHERE	level = @level

					EXEC	ETL.Calcall 
							@Direction = @Direction
							,@TicketCode = @TicketCode
							,@Level	= @Level
							,@SessionParentID =	@SessionParentID
							,@BatchID =	@BatchID
							,@Xconfig =	@Xconfig
							,@XTMPTicketStart =	@XTMPTicketStart
							,@XRAWSession = @XRAWSession OUTPUT						-- ex RAW.Session
							,@XRAWDelta = @XRAWDelta OUTPUT							-- ex RAW.Delta
							,@XTMPTicketServerTime = @XTMPTicketServerTime OUTPUT	-- ex TMP.TicketServerTime
							,@XTMPCountersCork = @XTMPCountersCork OUTPUT			-- ex TMP.CountersCork
							,@XRAWTicketMatched = @XRAWTicketMatched OUTPUT			-- ex RAW.TicketMatched
							,@XTMPDeltaTicketIN = @XTMPDeltaTicketIN OUTPUT			-- ex TMP.DeltaTicketIN
							,@XTMPDeltaTicketOUT = @XTMPDeltaTicketOUT OUTPUT		-- ex TMP.DeltaTicketOUT

					SELECT	@SessionID = sessionid 
					FROM	ETL.GetAllXRS(@XRAWSession)
					WHERE	startticketcode = @TicketCode

					SELECT	@MachineID = sessionid 
					FROM	ETL.GetAllXRS(@XRAWSession)
					WHERE	sessionid = @SessionID

					SET @CSVFieldValuesPairs = 'sessionid=' + CAST(@SessionID AS nvarchar(20)) + ',flagcalc=1'
					SET @CSVWhereConditionPairs = 'ticketcode=' + @TicketCode
					SET	@XRAWTicketToCalc = ETL.UpdMultiFieldX(@XRAWTicketToCalc,  @CSVFieldValuesPairs, @CSVWhereConditionPairs) 

					IF ISNULL(@MachineID, 0) != 0 
						BEGIN 
							-- TRASFERIMENTO DA XML A OGGETTI ***_TYPE
							INSERT	@RAWDelta
							SELECT	*						
							FROM	ETL.GetAllXRD(@XRAWDelta)

							INSERT	@RAWTICKETTOCALCTYPE (ticketcode,flagcalc,sessionid,sessionparentid,level)
							SELECT	ticketcode,flagcalc,sessionid,sessionparentid,level
							FROM	ETL.GetAllXTTC(@XRAWTicketToCalc)
				
							-- MERGING TRA OGGETTI ***_TYPE (NOTARE CHE IL FILTRO SU @SessionID è stato spostato dalla MERGE all'operazione precedente di popolamento dell'oggetto @RAWDelta)
							MERGE	@RAWTICKETTOCALCTYPE AS T 
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
							SET @XRAWTicketToCalc = ETL.BulkXTTC(@XRAWTicketToCalc, @RAWTICKETTOCALCTYPE)

							SET @Level += 1 
					END 
                ELSE 
					SET @CalcEnd = 1 
            END 
    END 

	EXEC ETL.WriteLog @@PROCID, 'Calcolo globale terminato', @TicketCode, @BatchID 

    IF @ReturnCodeInternal = -1 
    BEGIN 
        RAISERROR ('Internal procedure Error',16,1); 
    END 

END try 

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
