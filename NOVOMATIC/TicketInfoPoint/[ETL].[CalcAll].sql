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
Description.........: Calcola tutti i livelli delta, sessioni, ticket - Versione in memoria (nessuna tabella fisica coinvolta)  

Note 
- Use Tab size = 3 and Indent size 3 

------------------ 
-- Parameters   -- 
------------------   

------------------ 
-- Call Example -- 
------------------  

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE 
		@XCONFIG XML -- ex [Config].[Table]
		,@XTMPTicketStart XML -- ex [TMP].[TicketStart]
		,@XRawDelta XML
		,@XRawSession XML

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
-- ETL.WriteXTICKETS(@XTicketsExtractPomezia, @Batchid, @Clubid,          @Ticketcode, @Ticketvalue, @Printingmachine, @Printingmachineid,             @Printingdate, @Payoutmachine, @Payoutmachineid,               @Payoutdate, @Ispaidcashdesk, @Isprintingcashdesk,               @Expiredate, @Eventdate, @Mhmachine, @Mhmachineid, @Creationchangedate) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
--SET	@XTMPTicketStart = ETL.WriteXTICKETS(    @XTMPTicketStart,        1, 1000002, '309551976638606413',         4000,    'GD014017411',                 27, '2015-11-17 18:49:27.000',  'GD014017652',               26, '2015-11-17 18:49:46.000',               0,                   0, '2016-02-15 18:49:27.000',       NULL,       NULL,         NULL,                NULL) -- CARICA UN ELEMENTO AL CONTENITORE (ex [TMP].[TicketStart])

EXEC	ETL.CalcAll 
		@Direction = 0
		,@BatchID = 1
		,@Xconfig = @XCONFIG
		,@XTMPTicketStart = @XTMPTicketStart
		,@XRawDelta = @XRawDelta OUTPUT
		,@XRawSession = @XRawSession OUTPUT
SELECT * FROM ETL.GetAllXRD(@XRawDelta) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetAllXRS(@XRawSession) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE 
		@XCONFIG XML -- ex [Config].[Table]
		,@XTMPTicketStart XML -- ex [TMP].[TicketStart]
		,@XRawDelta XML
		,@XRawSession XML

SET	@XCONFIG = ETL.WriteXCONFIG(@XCONFIG, 7, 'POM-MON01', 25, 45, 7200, 50, 'GMatica', 1, 1) -- CARICA UN ELEMENTO AL CONTENITORE @XCONFIG (ex [Config].[Table])
--SET	@XTicketsExtractPomezia = ETL.WriteXTICKETS(@XTicketsExtractPomezia, @Batchid, @Clubid,          @Ticketcode, @Ticketvalue, @Printingmachine, @Printingmachineid,         @Printingdate, @Payoutmachine, @Payoutmachineid, @Payoutdate, @Ispaidcashdesk, @Isprintingcashdesk,  @Expiredate,                 @Eventdate, @Mhmachine, @Mhmachineid, @Creationchangedate) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XTMPTicketStart =  ETL.WriteXTICKETS(     @XTMPTicketStart,        1, 1000114, '205211897507353489',       150001,    'GD010024135',                 33, '2017-07-09 01:25:04',           NULL,             NULL,        NULL,            NULL,                NULL, '2017-10-07',  '2017-07-09 01:50:39.000',       NULL,         NULL,                NULL) -- CARICA UN ELEMENTO AL CONTENITORE (ex [TMP].[TicketStart])

EXEC	ETL.CalcAll 
		@Direction = 0
		,@BatchID = 1
		,@Xconfig = @XCONFIG
		,@XTMPTicketStart = @XTMPTicketStart
		,@XRawDelta = @XRawDelta OUTPUT
		,@XRawSession = @XRawSession OUTPUT
SELECT * FROM ETL.GetAllXRD(@XRawDelta) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetAllXRS(@XRawSession) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE 
		@XCONFIG XML -- ex [Config].[Table]
		,@XTMPTicketStart XML -- ex [TMP].[TicketStart]
		,@XRawDelta XML
		,@XRawSession XML

SET	@XCONFIG = ETL.WriteXCONFIG(@XCONFIG, 7, 'POM-MON01', 25, 45, 7200, 50, 'GMatica', 1, 1) -- CARICA UN ELEMENTO AL CONTENITORE @XCONFIG (ex [Config].[Table])
--SET	@XTicketsExtractPomezia = ETL.WriteXTICKETS(@XTicketsExtractPomezia, @Batchid, @Clubid,          @Ticketcode, @Ticketvalue, @Printingmachine, @Printingmachineid,         @Printingdate, @Payoutmachine, @Payoutmachineid, @Payoutdate, @Ispaidcashdesk, @Isprintingcashdesk,  @Expiredate,                 @Eventdate, @Mhmachine, @Mhmachineid, @Creationchangedate) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XTMPTicketStart =  ETL.WriteXTICKETS(     @XTMPTicketStart,        1, 1000114, '205211897507353489',       150001,    'GD010024135',                 33, '2017-07-09 01:25:04',           NULL,             NULL,        NULL,            NULL,                NULL, '2017-10-07',  '2017-07-09 01:50:39.000',       NULL,         NULL,                NULL) -- CARICA UN ELEMENTO AL CONTENITORE (ex [TMP].[TicketStart])

EXEC	ETL.CalcAll 
		@Direction = 0
		,@BatchID = 1
		,@Xconfig = @XCONFIG
		,@XTMPTicketStart = @XTMPTicketStart
		,@XRawDelta = @XRawDelta OUTPUT
		,@XRawSession = @XRawSession OUTPUT
SELECT * FROM ETL.GetAllXRD(@XRawDelta) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetAllXRS(@XRawSession) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE 
		@XCONFIG XML -- ex [Config].[Table]
		,@XTMPTicketStart XML -- ex [TMP].[TicketStart]
		,@XRawDelta XML
		,@XRawSession XML

SET	@XCONFIG = ETL.WriteXCONFIG(@XCONFIG, 1, 'POM-MON01', 25, 45, 7200, 50, 'GMatica', 1, 1) -- CARICA UN ELEMENTO AL CONTENITORE @XCONFIG (ex [Config].[Table])
--SET	@XTicketsExtractPomezia = ETL.WriteXTICKETS(@XTicketsExtractPomezia, @Batchid, @Clubid,          @Ticketcode, @Ticketvalue, @Printingmachine, @Printingmachineid,         @Printingdate, @Payoutmachine, @Payoutmachineid, @Payoutdate, @Ispaidcashdesk, @Isprintingcashdesk,  @Expiredate,                 @Eventdate, @Mhmachine, @Mhmachineid, @Creationchangedate) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XTMPTicketStart =  ETL.WriteXTICKETS(     @XTMPTicketStart,        1, 1000114, '205211897507353489',       150001,    'GD010024135',                 33, '2017-07-09 01:25:04',           NULL,             NULL,        NULL,            NULL,                NULL, '2017-10-07',  '2017-07-09 01:50:39.000',       NULL,         NULL,                NULL) -- CARICA UN ELEMENTO AL CONTENITORE (ex [TMP].[TicketStart])

EXEC	ETL.CalcAll 
		@Direction = 0
		,@BatchID = 1
		,@Xconfig = @XCONFIG
		,@XTMPTicketStart = @XTMPTicketStart
		,@XRawDelta = @XRawDelta OUTPUT
		,@XRawSession = @XRawSession OUTPUT
SELECT * FROM ETL.GetAllXRD(@XRawDelta) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetAllXRS(@XRawSession) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/ 
ALTER PROC	[ETL].[CalcAll] 
			@Direction					bit
			,@TicketCode				varchar(50) = NULL
			,@Level						int = NULL 
			,@SessionParentID			int = NULL 
			,@BatchID					int
			,@Xconfig					XML -- ex Config.Table
			,@XTMPTicketStart			XML	-- ex TMP.TicketStart
			,@XRawSession				XML OUTPUT -- ex RAW.Session
			,@XRawDelta					XML OUTPUT -- ex RAW.Delta
			,@XTMPTicketServerTime		XML OUTPUT -- ex TMP.TicketServerTime
			,@XTMPCountersCork			XML OUTPUT -- ex TMP.CountersCork
			,@XTicketsExtractPomezia	XML OUTPUT -- ex Ticket.Extract_pomezia
			,@XTMPRawData_View			XML OUTPUT -- ex TMP.RawData_View 
			,@XRawTicketMatched			XML OUTPUT -- ex RAW.TicketMatched
			,@XTMPDelta					XML OUTPUT -- ex TMP.Delta
			,@XTMPDeltaTicketIN			XML OUTPUT -- ex TMP.DeltaTicketIN
			,@XTMPDeltaTicketOUT		XML OUTPUT -- ex TMP.DeltaTicketOUT
AS
 
SET NOCOUNT ON; 

DECLARE 
		@ConcessionaryID		smallint
		,@ClubID				int 
		,@ConcessionaryDB		varchar(50) 
        ,@DataStart				datetime2(3) 
        ,@Message				varchar(1000) 
        ,@Msg					varchar(1000) 
        ,@ReturnCodeInternal	int 
        ,@ReturnCodeGlobal		int 
        ,@CalcEnd				bit 
        ,@VltEndCredit			int 
        ,@CashDesk				tinyint = 0 
        ,@PayoutDate			datetime2(3) 
        ,@ServerTime_FIRST		datetime = '1900-01-01 00:00:00.000' 
        ,@PrintingDate			datetime2(3) 
        ,@ServerTimeStart		datetime2(3) 
        ,@ParentID				int
		,@XTMPTicket			XML 

BEGIN TRY 
    -- Log operazione 
	EXEC ETL.WriteLog @@PROCID, 'Sub-calcolo iniziato', @TicketCode, @BatchID -- Log operazione  

    SELECT	
			@ConcessionaryID = concessionaryid
			,@VltEndCredit = MinVltEndCredit
			,@ReturnCodeInternal = 0 
			,@DataStart = Sysdatetime() 
	FROM	ETL.GetAllXCONFIG(@XCONFIG) 

	SELECT	
			@ClubID = ClubID 
			,@TicketCode = ISNULL(@TicketCode,TicketCode)
	FROM	ETL.GetAllXTICKETS(@XTMPTicketStart)

    -- Trova il tappo 
   -- EXEC	@ReturnCodeInternal = ETL.Findcounterscork 
			--@TicketCode 
			--,@Direction 
			--,@BatchID
	EXEC	ETL.FindCountersCork 
			@XconfigTable = @Xconfig -- ex Config.Table
			,@Direction	= @Direction 
			,@TicketCode= @TicketCode 
			,@ClubID = @ClubID 
			,@BatchID = @BatchID
			,@XTMPTicketStart = @XTMPTicketStart OUTPUT -- ex TMP.TicketStart
			,@XTMPTicketServerTime = @XTMPTicketServerTime OUTPUT -- ex TMP.TicketServerTime
			,@XTMPCountersCork = @XTMPCountersCork OUTPUT -- ex TMP.CountersCork
			,@XTMPRawData_View = @XTMPRawData_View OUTPUT -- ex TMP.RawData_View 

    --IF @ReturnCodeInternal <> -1 AND @ReturnCodeInternal <> 1 
  --  IF @ReturnCodeInternal NOT IN (-1,1) -- non errore e non pagato/stampato da cashdesk
		--BEGIN 
			-- Calcola i delta 
			--EXEC @ReturnCodeInternal = ETL.Calculatedeltafromticketout 
			EXEC	ETL.CalculateDeltaFromTicketOut 
					@XCONFIG = @XCONFIG
					,@XTMPTicketStart = @XTMPTicketStart
					,@XTMPCountersCork = @XTMPCountersCork
					,@XTMPTicketServerTime = @XTMPTicketServerTime
					,@XTMPRawData_View = @XTMPRawData_View OUTPUT 
					,@XTMPDelta	= @XTMPDelta OUTPUT


			--IF @ReturnCodeInternal != -1 -- Matching dei ticket
				EXEC	ETL.Ticketmatching 
						@XCONFIG = @XCONFIG
						,@TicketCode = @TicketCode
						,@Direction = @Direction
						,@XTMPCountersCork = @XTMPCountersCork
						,@XTMPTicketStart = @XTMPTicketStart
						,@XTMPDELTA = @XTMPDELTA 
						,@XTMPDeltaTicketIN	= @XTMPDeltaTicketIN OUTPUT
						,@XTMPDeltaTicketOUT = @XTMPDeltaTicketOUT OUTPUT
						,@XRawTicketMatched = @XRawTicketMatched OUTPUT


			--IF @ReturnCodeInternal != -1 -- Calcola le sessioni
				--EXEC	@ReturnCodeInternal = ETL.Calcsession @Level = @Level, @SessionParentID = @SessionParentID, @ReturnCode =  @ReturnCodeInternal OUTPUT 
			EXEC	ETL.CalcSession 
					@XCONFIG = @XCONFIG -- ex Config.Table
					,@XTMPCountersCork = @XTMPCountersCork -- ex TMP.CountersCork 
					,@XTMPDelta	= @XTMPDelta -- ex TMP.Delta
					,@Level	= @Level 
					,@SessionParentID = @SessionParentID
					,@XTMPTicketStart = @XTMPTicketStart -- ex TMP.TicketStart
					,@XRawSession = @XRawSession OUTPUT -- ex RAW.Session
					,@XRawDelta = @XRawDelta OUTPUT -- ex RAW.Delta

		--END 
  --  ELSE 
		--IF @ReturnCodeInternal = 1 AND @Direction = 1 -- pagato da cashdesk
		IF @Direction = 1 -- pagato da cashdesk
			BEGIN 
				--SELECT @PayoutData = payoutdata 
				--FROM   TMP.Ticketstart 
				--WHERE  ticketcode = @TicketCode
				SELECT	@PayoutDate = payoutdate
				FROM	ETL.GetAllXTICKETS(@XTMPTicketStart)
				WHERE	ticketcode = @TicketCode
 
				--INSERT RAW.Session (
				--		machineid, 
				--		startservertime, 
				--		startticketcode, 
				--		level, 
				--		sessionparentid
				--) 
				--SELECT 
				--		@CashDesk, 
				--		Isnull(@PayoutData, @ServerTime_FIRST), 
				--		@TicketCode, 
				--		@Level, 
				--		@SessionParentID

						-- ETL.WriteXRS(@CurrentXRS,@SessionID,@SessionParentID,@Level,@UnivocalLocationCode,@MachineID,@GD ,@AamsMachineCode,@StartServerTime                      ,@EndServerTime,@TotalRows,@TotalBillIn,@TotalCoinIN,@TotalTicketIn,@TotalBetValue,@TotalBetNum,@TotalWinValue,@TotalWinNum,@Tax,@TotalIn,@TotalOut,@FlagMinVltCredit,@StartTicketCode)
				SET	@XRawSession = ETL.WriteXRS(@XRawSession       ,NULL      ,@SessionParentID,@Level,NULL                 ,@CashDesk ,NULL,NULL            ,ISNULL(@PayoutDate, @ServerTime_FIRST),NULL          ,NULL      ,NULL        ,NULL        ,NULL          ,NULL          ,NULL        ,NULL          ,NULL        ,NULL,NULL    ,NULL     ,NULL             ,@TicketCode     )						 
				--SELECT	'RAW.Session_Direction1' AS tabella, * FROM ETL.GetAllXRS(@XRawSession)
			END 
		ELSE 
			--IF @ReturnCodeInternal = 1 AND @Direction = 0 -- stampato da cashdesk 
			IF @Direction = 0 -- stampato da cashdesk 
				BEGIN 
					--SELECT @PrintingData = printingdata 
					--FROM   TMP.Ticketstart 
					--WHERE  ticketcode = @TicketCode
					SELECT	@PrintingDate = printingdate
					FROM	ETL.GetAllXTICKETS(@XTMPTicketStart)
 					WHERE	ticketcode = @TicketCode

					--INSERT RAW.Session (
					--		machineid, 
					--		startservertime, 
					--		startticketcode, 
					--		level, 
					--		sessionparentid
					--) 
					--SELECT 
					--		@CashDesk, 
					--		Isnull(@PrintingData, @ServerTime_FIRST), 
					--		@TicketCode, 
					--		@Level, 
					--		@SessionParentID
							 
							-- ETL.WriteXRS(@CurrentXRS,@SessionID,@SessionParentID,@Level,@UnivocalLocationCode,@MachineID,@GD ,@AamsMachineCode,@StartServerTime                        ,@EndServerTime,@TotalRows,@TotalBillIn,@TotalCoinIN,@TotalTicketIn,@TotalBetValue,@TotalBetNum,@TotalWinValue,@TotalWinNum,@Tax,@TotalIn,@TotalOut,@FlagMinVltCredit,@StartTicketCode)
					SET	@XRawSession = ETL.WriteXRS(@XRawSession       ,NULL      ,@SessionParentID,@Level,NULL                 ,@CashDesk ,NULL,NULL            ,ISNULL(@PrintingDate, @ServerTime_FIRST),NULL          ,NULL      ,NULL        ,NULL        ,NULL          ,NULL          ,NULL        ,NULL          ,NULL        ,NULL,NULL    ,NULL     ,NULL             ,@TicketCode     )						 
					--SELECT	'RAW.Session_Direction0' AS tabella, * FROM ETL.GetAllXRS(@XRawSession)
				END 

    -- Log operazione 
	EXEC ETL.WriteLog @@PROCID, 'Sub-calcolo terminato', @TicketCode, @BatchID -- Log operazione  

    -- Errore specifico 
    IF @ReturnCodeInternal = -1 
    BEGIN 
        RAISERROR('Internal procedure Error',16,1); 
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

RETURN 
