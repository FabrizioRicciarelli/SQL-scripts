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
		,@XTKS XML -- ex [TMP].[TicketStart]
		,@XRD XML
		,@XRS XML

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
SET	@XTKS = ETL.WriteXTICKETS(    @XTKS,        1, 1000002, '309551976638606413',         4000,    'GD014017411',                 27, '2015-11-17 18:49:27.000',  'GD014017652',               26, '2015-11-17 18:49:46.000',               0,                   0, '2016-02-15 18:49:27.000',       NULL,       NULL,         NULL,                NULL) -- CARICA UN ELEMENTO AL CONTENITORE (ex [TMP].[TicketStart])

EXEC	ETL.CalcAll 
		@Direction = 0
		,@BatchID = 1
		,@Xconfig = @XCONFIG
		,@XTKS = @XTKS
		,@XRD = @XRD OUTPUT
		,@XRS = @XRS OUTPUT
SELECT * FROM ETL.GetAllXRD(@XRD) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetAllXRS(@XRS) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE 
		@XCONFIG XML -- ex [Config].[Table]
		,@XTKS XML -- ex [TMP].[TicketStart]
		,@XRD XML
		,@XRS XML

SET	@XCONFIG = ETL.WriteXCONFIG(@XCONFIG, 7, 'POM-MON01', 25, 45, 7200, 50, 'GMatica', 1, 1) -- CARICA UN ELEMENTO AL CONTENITORE @XCONFIG (ex [Config].[Table])
--SET	@XTICKETS = ETL.WriteXTICKETS(@XTICKETS, @Batchid, @Clubid,          @Ticketcode, @Ticketvalue, @Printingmachine, @Printingmachineid,         @Printingdate, @Payoutmachine, @Payoutmachineid, @Payoutdate, @Ispaidcashdesk, @Isprintingcashdesk,  @Expiredate,                 @Eventdate, @Mhmachine, @Mhmachineid, @Creationchangedate) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XTKS =  ETL.WriteXTICKETS(     @XTKS,        1, 1000114, '205211897507353489',       150001,    'GD010024135',                 33, '2017-07-09 01:25:04',           NULL,             NULL,        NULL,            NULL,                NULL, '2017-10-07',  '2017-07-09 01:50:39.000',       NULL,         NULL,                NULL) -- CARICA UN ELEMENTO AL CONTENITORE (ex [TMP].[TicketStart])

EXEC	ETL.CalcAll 
		@Direction = 0
		,@BatchID = 1
		,@Xconfig = @XCONFIG
		,@XTKS = @XTKS
		,@XRD = @XRD OUTPUT
		,@XRS = @XRS OUTPUT
SELECT * FROM ETL.GetAllXRD(@XRD) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetAllXRS(@XRS) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE 
		@XCONFIG XML -- ex [Config].[Table]
		,@XTKS XML -- ex [TMP].[TicketStart]
		,@XRD XML
		,@XRS XML

SET	@XCONFIG = ETL.WriteXCONFIG(@XCONFIG, 7, 'POM-MON01', 25, 45, 7200, 50, 'GMatica', 1, 1) -- CARICA UN ELEMENTO AL CONTENITORE @XCONFIG (ex [Config].[Table])
--SET	@XTICKETS = ETL.WriteXTICKETS(@XTICKETS, @Batchid, @Clubid,          @Ticketcode, @Ticketvalue, @Printingmachine, @Printingmachineid,         @Printingdate, @Payoutmachine, @Payoutmachineid, @Payoutdate, @Ispaidcashdesk, @Isprintingcashdesk,  @Expiredate,                 @Eventdate, @Mhmachine, @Mhmachineid, @Creationchangedate) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XTKS =  ETL.WriteXTICKETS(     @XTKS,        1, 1000114, '205211897507353489',       150001,    'GD010024135',                 33, '2017-07-09 01:25:04',           NULL,             NULL,        NULL,            NULL,                NULL, '2017-10-07',  '2017-07-09 01:50:39.000',       NULL,         NULL,                NULL) -- CARICA UN ELEMENTO AL CONTENITORE (ex [TMP].[TicketStart])

EXEC	ETL.CalcAll 
		@Direction = 0
		,@BatchID = 1
		,@Xconfig = @XCONFIG
		,@XTKS = @XTKS
		,@XRD = @XRD OUTPUT
		,@XRS = @XRS OUTPUT
SELECT * FROM ETL.GetAllXRD(@XRD) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetAllXRS(@XRS) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE 
		@XCONFIG XML -- ex [Config].[Table]
		,@XTKS XML -- ex [TMP].[TicketStart]
		,@XRD XML
		,@XRS XML

SET	@XCONFIG = ETL.WriteXCONFIG(@XCONFIG, 1, 'POM-MON01', 25, 45, 7200, 50, 'GMatica', 1, 1) -- CARICA UN ELEMENTO AL CONTENITORE @XCONFIG (ex [Config].[Table])
--SET	@XTICKETS = ETL.WriteXTICKETS(@XTICKETS, @Batchid, @Clubid,          @Ticketcode, @Ticketvalue, @Printingmachine, @Printingmachineid,         @Printingdate, @Payoutmachine, @Payoutmachineid, @Payoutdate, @Ispaidcashdesk, @Isprintingcashdesk,  @Expiredate,                 @Eventdate, @Mhmachine, @Mhmachineid, @Creationchangedate) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XTKS =  ETL.WriteXTICKETS(     @XTKS,        1, 1000114, '205211897507353489',       150001,    'GD010024135',                 33, '2017-07-09 01:25:04',           NULL,             NULL,        NULL,            NULL,                NULL, '2017-10-07',  '2017-07-09 01:50:39.000',       NULL,         NULL,                NULL) -- CARICA UN ELEMENTO AL CONTENITORE (ex [TMP].[TicketStart])

EXEC	ETL.CalcAll 
		@Direction = 0
		,@BatchID = 1
		,@Xconfig = @XCONFIG
		,@XTKS = @XTKS
		,@XRD = @XRD OUTPUT
		,@XRS = @XRS OUTPUT
SELECT * FROM ETL.GetAllXRD(@XRD) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetAllXRS(@XRS) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/ 
ALTER PROC	[ETL].[CalcAll] 
			@Direction			bit
			,@TicketCode		varchar(50)
			,@Level				int = NULL 
			,@SessionParentID	int = NULL 
			,@BatchID			int
			,@Xconfig			XML -- ex Config.Table
			,@XTKS				XML	-- ex TMP.TicketStart
			,@XRS				XML OUTPUT -- ex RAW.Session
			,@XRD				XML OUTPUT -- ex RAW.Delta
AS
 
SET NOCOUNT ON; 

DECLARE 
		@ConcessionaryID		smallint
		,@ClubID				int 
		--,@TicketCode			varchar(50) 
		,@ConcessionaryDB		varchar(50) 
        ,@DataStart				datetime2(3) 
        ,@Message				varchar(1000) 
        ,@Msg					varchar(1000) 
        ,@ReturnCodeInternal	int 
        ,@ReturnCodeGlobal		int 
        ,@CalcEnd				bit 
        ,@VltEndCredit			int 
        ,@CashDesk				tinyint = 0 
        ,@PayoutData			datetime2(3) 
        ,@ServerTime_FIRST		datetime = '1900-01-01 00:00:00.000' 
        ,@PrintingData			datetime2(3) 
        ,@ServerTimeStart		datetime2(3) 
        ,@ParentID				int 
		,@XTST					XML -- ex TMP.TicketServerTime
		,@XCCK					XML-- ex TMP.CountersCork
		,@XTICKETS				XML -- ex Ticket.Extract_pomezia
		,@XRAW					XML -- ex TMP.RawData_View 
		,@XTKM_RAW				XML -- ex RAW.TicketMatched
		,@XTMPDelta				XML -- ex TMP.Delta

BEGIN TRY 
    -- Log operazione 
	EXEC ETL.WriteLog @@PROCID, 'Calcolo globale iniziato', @TicketCode, @BatchID -- Log operazione  

    --IF @ClubID = NULL 
    --(SELECT @ClubID = clubid FROM TMP.Ticketstart) 
	SELECT	
			@ClubID = ClubID 
			,@TicketCode = ISNULL(@TicketCode,TicketCode)
	FROM	ETL.GetAllXTICKETS(@XTKS)

    --SET @VltEndCredit = (SELECT minvltendcredit FROM [Config].[Table]) 
    SELECT	
			@ConcessionaryID = concessionaryid
			,@VltEndCredit = minvltendcredit 
	FROM	ETL.GetAllXCONFIG(@XCONFIG) 

	--inizializzo 
    SET @ReturnCodeInternal = 0; 
    SET @DataStart = Sysdatetime(); 

    -- Trova il tappo 
   -- EXEC	@ReturnCodeInternal = ETL.Findcounterscork 
			--@TicketCode 
			--,@Direction 
			--,@BatchID
	EXEC	ETL.Findcounterscork 
			@Xconfig = @Xconfig -- ex Config.Table
			,@Direction	= @Direction 
			,@TicketCode= @TicketCode 
			,@ClubID = @ClubID 
			,@BatchID = @BatchID
			,@XTKS = @XTKS OUTPUT -- ex TMP.TicketStart
			,@XTST = @XTST OUTPUT -- ex TMP.TicketServerTime
			,@XCCK = @XCCK OUTPUT -- ex TMP.CountersCork
			,@XRAW = @XRAW OUTPUT -- ex TMP.RawData_View 

    --IF @ReturnCodeInternal <> -1 AND @ReturnCodeInternal <> 1 
  --  IF @ReturnCodeInternal NOT IN (-1,1) -- non errore e non pagato/stampato da cashdesk
		--BEGIN 
			-- Calcola i delta 
			--EXEC @ReturnCodeInternal = ETL.Calculatedeltafromticketout 
			EXEC	ETL.CalculateDeltaFromTicketOut 
					@XCONFIG = @XCONFIG
					,@XRAWinput = @XRAW
					,@XTKS = @XTKS
					,@XCCK = @XCCK
					,@XTST = @XTST
					,@XRAW = @XRAW OUTPUT 
					,@XTMPDelta	= @XTMPDelta OUTPUT

			--IF @ReturnCodeInternal != -1 -- Matching dei ticket
				--EXEC	@ReturnCodeInternal = ETL.Ticketmatching @Direction = @Direction 
				EXEC	ETL.Ticketmatching 
						@XCONFIG = @XCONFIG
						,@TicketCode = @TicketCode
						,@Direction = @Direction
						,@XCCK = @XCCK -- ex TMP.CountersCork
						,@XTICKETS = @XTICKETS -- ex TMP.Ticket
						,@XRD = @XTMPDelta -- ex TMP.Delta 
						,@XTKM_RAW = @XTKM_RAW OUTPUT -- ex RAW.TicketMatched

			--IF @ReturnCodeInternal != -1 -- Calcola le sessioni
				--EXEC	@ReturnCodeInternal = ETL.Calcsession @Level = @Level, @SessionParentID = @SessionParentID, @ReturnCode =  @ReturnCodeInternal OUTPUT 
			EXEC	ETL.CalcSession 
					@XCONFIG = @XCONFIG -- ex Config.Table
					,@XCCK = @XCCK -- ex TMP.CountersCork 
					,@XTMPDelta	= @XTMPDelta -- ex TMP.Delta
					,@Level	= @Level 
					,@SessionParentID = @SessionParentID
					,@XTKS = @XTKS -- ex TMP.TicketStart
					,@XRS = @XRS OUTPUT -- ex RAW.Session
					,@XRD = @XRD OUTPUT -- ex RAW.Delta


			----DEBUG
			--SELECT
			--		'ETL.CalcAll - POST CalcSession' AS ProcedureName
			--		,@ConcessionaryID AS ConcessionaryID
			--		,@ClubID AS ClubID
			--		,@TicketCode AS TicketCode
			--		,@VltEndCredit AS VltEndCredit

			--SELECT	'TMP.TicketStart' AS tabella, * FROM ETL.GetAllXTICKETS(@XTKS)
			--SELECT	'TMP.TicketServerTime' AS tabella, * FROM ETL.GetAllXTST(@XTST)
			--SELECT	'TMP.CountersCork' AS tabella, * FROM ETL.GetAllXCCK(@XCCK)
			--SELECT	'TMP.RawData_View' AS tabella, * FROM ETL.GetAllXRAW(@XRAW)
			--SELECT	'TMP.Delta' AS tabella, * FROM ETL.GetAllXRD(@XTMPDelta)
			--SELECT	'TMP.Session' AS tabella, * FROM ETL.GetAllXRS(@XRS)

			--RETURN 0

		--END 
  --  ELSE 
		--IF @ReturnCodeInternal = 1 AND @Direction = 1 -- pagato da cashdesk
		IF @Direction = 1 -- pagato da cashdesk
			BEGIN 
				--SELECT @PayoutData = payoutdata 
				--FROM   TMP.Ticketstart 
				--WHERE  ticketcode = @TicketCode
				SELECT	@PayoutData = payoutdate
				FROM	ETL.GetAllXTICKETS(@XTKS)
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
				SET	@XRS = ETL.WriteXRS(@XRS       ,NULL      ,@SessionParentID,@Level,NULL                 ,@CashDesk ,NULL,NULL            ,ISNULL(@PayoutData, @ServerTime_FIRST),NULL          ,NULL      ,NULL        ,NULL        ,NULL          ,NULL          ,NULL        ,NULL          ,NULL        ,NULL,NULL    ,NULL     ,NULL             ,@TicketCode     )						 
				--SELECT	'RAW.Session_Direction1' AS tabella, * FROM ETL.GetAllXRS(@XRS)
			END 
		ELSE 
			--IF @ReturnCodeInternal = 1 AND @Direction = 0 -- stampato da cashdesk 
			IF @Direction = 0 -- stampato da cashdesk 
				BEGIN 
					--SELECT @PrintingData = printingdata 
					--FROM   TMP.Ticketstart 
					--WHERE  ticketcode = @TicketCode
					SELECT	@PrintingData = printingdate
					FROM	ETL.GetAllXTICKETS(@XTKS)
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
					SET	@XRS = ETL.WriteXRS(@XRS       ,NULL      ,@SessionParentID,@Level,NULL                 ,@CashDesk ,NULL,NULL            ,ISNULL(@PrintingData, @ServerTime_FIRST),NULL          ,NULL      ,NULL        ,NULL        ,NULL          ,NULL          ,NULL        ,NULL          ,NULL        ,NULL,NULL    ,NULL     ,NULL             ,@TicketCode     )						 
					--SELECT	'RAW.Session_Direction0' AS tabella, * FROM ETL.GetAllXRS(@XRS)
				END 

    -- Log operazione 
	EXEC ETL.WriteLog @@PROCID, 'Calcolo globale terminato', @TicketCode, @BatchID -- Log operazione  

    -- Errore specifico 
    IF @ReturnCodeInternal = -1 
    BEGIN 
        RAISERROR('Internal procedure Error',16,1); 
    END 
END try 

-- Gestione Errore 
BEGIN catch 
   -- EXECUTE	ERR.Usplogerror 
			--@ErrorTicket = @TicketCode, 
			--@ErrorRequestDetailID = @BatchID 
    PRINT 'Error ' + CONVERT(varchar(50), ERROR_NUMBER()) +
          ', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) +
          ', State ' + CONVERT(varchar(5), ERROR_STATE()) + 
          ', Procedure ' + ISNULL(ERROR_PROCEDURE(), '-') + 
          ', Line ' + CONVERT(varchar(5), ERROR_LINE());
    PRINT ERROR_MESSAGE();
END catch 

RETURN 
