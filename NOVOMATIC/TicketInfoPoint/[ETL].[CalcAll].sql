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
		,@tkStart XML -- ex [TMP].[TicketStart]
		,@rawXDelta XML
		,@rawXSession XML

SET	@XCONFIG = ETL.WriteXCONFIG(@XCONFIG, 7, 'POM-MON01', 25, 45, 7200, 50, 'GMatica', 1, 1) -- CARICA UN ELEMENTO AL CONTENITORE @XCONFIG (ex [Config].[Table])
SET	@tkStart = ETL.WriteXTICKETS(@tkStart, 1, 1000114, '205211897507353489', 150001, '2017-07-09 01:25:04', 'GD010024135', 33, 0, NULL, NULL, NULL, NULL, '2017-10-07', '2017-07-09 01:50:39.000, NULL, NULL, 1) -- CARICA UN ELEMENTO AL CONTENITORE (ex [TMP].[TicketStart])

EXEC	ETL.CalcAll 
		@ConcessionaryID = 7
		,@Direction = 0
		,@TicketCode = '164504952927074578'
		,@BatchID = 1
		,@Xconfig = @XCONFIG
		,@Xts = @tkStart
		,@rawXDelta = @rawXDelta OUTPUT
		,@rawXSession = @rawXSession OUTPUT
SELECT * FROM ETL.GetXRD(@XRD, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetXRS(@XRS, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE 
		@XCONFIG XML -- ex [Config].[Table]
		,@tkStart XML -- ex [TMP].[TicketStart]
		,@rawXDelta XML
		,@rawXSession XML

SET	@XCONFIG = ETL.WriteXCONFIG(@XCONFIG, 7, 'POM-MON01', 25, 45, 7200, 50, 'GMatica', 1, 1) -- CARICA UN ELEMENTO AL CONTENITORE @XCONFIG (ex [Config].[Table])
SET	@tkStart = ETL.WriteXTICKETS(@tkStart, 1, 1000114, '205211897507353489', 150001, '2017-07-09 01:25:04', 'GD010024135', 33, 0, NULL, NULL, NULL, NULL, '2017-10-07', '2017-07-09 01:50:39.000, NULL, NULL, 1) -- CARICA UN ELEMENTO AL CONTENITORE (ex [TMP].[TicketStart])

EXEC	ETL.CalcAll 
		@ConcessionaryID = 7
		,@Direction = 0
		,@TicketCode = '1000294MHR201502110001'
		,@BatchID = 1
		,@MaxLevel = 50
		,@Xconfig = @XCONFIG
		,@Xts = @tkStart
		,@rawXDelta = @rawXDelta OUTPUT
		,@rawXSession = @rawXSession OUTPUT
SELECT * FROM ETL.GetXRD(@XRD, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetXRS(@XRS, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE 
		@XCONFIG XML -- ex [Config].[Table]
		,@tkStart XML -- ex [TMP].[TicketStart]
		,@rawXDelta XML
		,@rawXSession XML

SET	@XCONFIG = ETL.WriteXCONFIG(@XCONFIG, 7, 'POM-MON01', 25, 45, 7200, 50, 'GMatica', 1, 1) -- CARICA UN ELEMENTO AL CONTENITORE @XCONFIG (ex [Config].[Table])
SET	@tkStart = ETL.WriteXTICKETS(@tkStart, 1, 1000114, '205211897507353489', 150001, '2017-07-09 01:25:04', 'GD010024135', 33, 0, NULL, NULL, NULL, NULL, '2017-10-07', '2017-07-09 01:50:39.000, NULL, NULL, 1) -- CARICA UN ELEMENTO AL CONTENITORE (ex [TMP].[TicketStart])

EXEC	ETL.CalcAll @ConcessionaryID = 7
		,@Direction = 0
		,@TicketCode = 'dddds'
		,@BatchID = 1
		,@MaxLevel = 50
		,@Xconfig = @XCONFIG
		,@Xts = @tkStart
		,@rawXDelta = @rawXDelta OUTPUT
		,@rawXSession = @rawXSession OUTPUT
SELECT * FROM ETL.GetXRD(@XRD, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetXRS(@XRS, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE 
		@XCONFIG XML -- ex [Config].[Table]
		,@tkStart XML -- ex [TMP].[TicketStart]
		,@rawXDelta XML
		,@rawXSession XML

SET	@XCONFIG = ETL.WriteXCONFIG(@XCONFIG, 1, 'POM-MON01', 25, 45, 7200, 50, 'GMatica', 1, 1) -- CARICA UN ELEMENTO AL CONTENITORE @XCONFIG (ex [Config].[Table])
SET	@tkStart = ETL.WriteXTICKETS(@tkStart, 1, 1000114, '205211897507353489', 150001, '2017-07-09 01:25:04', 'GD010024135', 33, 0, NULL, NULL, NULL, NULL, '2017-10-07', '2017-07-09 01:50:39.000, NULL, NULL, 1) -- CARICA UN ELEMENTO AL CONTENITORE (ex [TMP].[TicketStart])

EXEC	ETL.CalcAll 
		@ConcessionaryID = 1
		,@Direction = 0
		,@TicketCode = '116136268470765059'
		,@BatchID = 1
		,@MaxLevel = 10
		,@Xconfig = @XCONFIG
		,@Xts = @tkStart
		,@rawXDelta = @rawXDelta OUTPUT
		,@rawXSession = @rawXSession OUTPUT
SELECT * FROM ETL.GetXRD(@XRD, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetXRS(@XRS, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/ 
ALTER PROC	[ETL].[CalcAll] 
			@ConcessionaryID	tinyint 
			,@Direction			bit
			,@TicketCode		varchar(50) 
			,@Level				int = NULL 
			,@SessionParentID	int = NULL 
			,@BatchID			int
			,@ClubID			varchar(10) = NULL
			,@Xconfig			XML -- ex [Config].[Table]
			,@Xts				XML	-- ex [TMP].[TicketStart]
			,@rawXDelta			XML OUTPUT 
			,@rawXSession		XML OUTPUT
AS
 
SET NOCOUNT ON; 

DECLARE 
		@ConcessionaryDB    varchar(50) 
        ,@DataStart          datetime2(3) 
        ,@Message            varchar(1000) 
        ,@Msg                varchar(1000) 
        ,@ReturnCodeInternal int 
        ,@ReturnCodeGlobal   int 
        ,@CalcEnd            bit 
        ,@VltEndCredit       int 
        ,@CashDesk           tinyint = 0 
        ,@PayoutData         datetime2(3) 
        ,@ServerTime_FIRST   datetime = '1900-01-01 00:00:00.000' 
        ,@PrintingData       datetime2(3) 
        ,@ServerTimeStart    datetime2(3) 
        ,@ParentID           int 

BEGIN TRY 
    -- Log operazione 
    --SET @Msg = 'Calcolo globale iniziato' 

    --INSERT INTO ETL.Operationlog 
    --            (procedurename, 
    --             operationmsg, 
    --             operationticketcode, 
    --             operationrequestdetailid) 
    --SELECT @ProcedureName, 
    --       @Msg, 
    --       @TicketCode, 
    --       @BatchID 
	EXEC ETL.WriteLog @@PROCID, 'Calcolo globale iniziato', @TicketCode, @BatchID -- Log operazione  

    --IF @ClubID = NULL 
    --(SELECT @ClubID = clubid FROM TMP.Ticketstart) 
	SELECT	@ClubID = ISNULL(@ClubID, clubid) 
	FROM	ETL.GetXTICKETS(@Xts, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)

    --SET @VltEndCredit = (SELECT minvltendcredit FROM [Config].[Table]) 
    SELECT	@VltEndCredit = minvltendcredit 
	FROM	ETL.GetXCONFIG(@XCONFIG, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) 

	--inizializzo 
    SET @ReturnCodeInternal = 0; 
    SET @DataStart = Sysdatetime(); 

    -- Trova il tappo 
    EXEC	@ReturnCodeInternal = ETL.Findcounterscork 
			@TicketCode 
			,@Direction 
			,@BatchID 

     
    --IF @ReturnCodeInternal <> -1 AND @ReturnCodeInternal <> 1 
    IF @ReturnCodeInternal NOT IN (-1,1) -- non errore e non pagato/stampato da cashdesk
		BEGIN 
			-- Calcola i delta 
			EXEC @ReturnCodeInternal = ETL.Calculatedeltafromticketout 

			IF @ReturnCodeInternal != -1 -- Matching dei ticket
				EXEC	@ReturnCodeInternal = ETL.Ticketmatching @Direction = @Direction 

			IF @ReturnCodeInternal != -1 -- Calcola le sessioni
				EXEC	@ReturnCodeInternal = ETL.Calcsession @Level = @Level, @SessionParentID = @SessionParentID, @ReturnCode =  @ReturnCodeInternal OUTPUT 
		END 
    ELSE 
		IF @ReturnCodeInternal = 1 AND @Direction = 1 -- pagato da cashdesk
			BEGIN 
				--SELECT @PayoutData = payoutdata 
				--FROM   TMP.Ticketstart 
				--WHERE  ticketcode = @TicketCode
				SELECT	@PayoutData = payoutdate
				FROM	ETL.GetXTICKETS(@Xts, NULL, NULL, @TicketCode, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
 

				--INSERT INTO RAW.Session 
				--			(machineid, 
				--				startservertime, 
				--				startticketcode, 
				--				level, 
				--				sessionparentid) 
				--SELECT @CashDesk, 
				--		Isnull(@PayoutData, @ServerTime_FIRST), 
				--		@TicketCode, 
				--		@Level, 
				--		@SessionParentID
								-- ETL.WriteXRS(@CurrentXRS,@SessionID,@SessionParentID,@Level,@UnivocalLocationCode,@MachineID,@GD,@AamsMachineCode,@StartServerTime,@EndServerTime,@TotalRows,@TotalBillIn,@TotalCoinIN,@TotalTicketIn,@TotalBetValue,@TotalBetNum,@TotalWinValue,@TotalWinNum,@Tax,@TotalIn,@TotalOut,@FlagMinVltCredit,@StartTicketCode)
				SET	@rawXSession = ETL.WriteXRS(@rawXSession,NULL,@SessionParentID,@Level,NULL,@CashDesk,NULL,NULL,ISNULL(@PayoutData, @ServerTime_FIRST),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,@TicketCode)						 
			END 
		ELSE 
			IF @ReturnCodeInternal = 1 AND @Direction = 0 -- stampato da cashdesk 
				BEGIN 
					--SELECT @PrintingData = printingdata 
					--FROM   TMP.Ticketstart 
					--WHERE  ticketcode = @TicketCode
					SELECT	@PrintingData = printingdate
					FROM	ETL.GetXTICKETS(@Xts, NULL, NULL, @TicketCode, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
 

					--INSERT INTO RAW.Session 
					--			(machineid, 
					--				startservertime, 
					--				startticketcode, 
					--				level, 
					--				sessionparentid) 
					--SELECT @CashDesk, 
					--		Isnull(@PrintingData, @ServerTime_FIRST), 
					--		@TicketCode, 
					--		@Level, 
					--		@SessionParentID 
									-- ETL.WriteXRS(@CurrentXRS,@SessionID,@SessionParentID,@Level,@UnivocalLocationCode,@MachineID,@GD,@AamsMachineCode,@StartServerTime,@EndServerTime,@TotalRows,@TotalBillIn,@TotalCoinIN,@TotalTicketIn,@TotalBetValue,@TotalBetNum,@TotalWinValue,@TotalWinNum,@Tax,@TotalIn,@TotalOut,@FlagMinVltCredit,@StartTicketCode)
					SET	@rawXSession = ETL.WriteXRS(@rawXSession,NULL,@SessionParentID,@Level,NULL,@CashDesk,NULL,NULL,ISNULL(@PrintingData, @ServerTime_FIRST),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,@TicketCode)						 
				END 

    -- Log operazione 
    --SET @Msg = 'Calcolo globale terminato' 

    --INSERT INTO ETL.Operationlog 
    --            (procedurename, 
    --            operationmsg, 
    --            operationticketcode, 
    --            operationrequestdetailid) 
    --SELECT @ProcedureName, 
    --        @Msg, 
    --        @TicketCode, 
    --        @BatchID 
	EXEC ETL.WriteLog @@PROCID, 'Calcolo globale terminato', @TicketCode, @BatchID -- Log operazione  

    -- Errore specifico 
    IF @ReturnCodeInternal = -1 
    BEGIN 
        RAISERROR('Internal procedure Error',16,1); 
    END 
END try 

-- Gestione Errore 
BEGIN catch 
    EXECUTE	ERR.Usplogerror 
			@ErrorTicket = @TicketCode, 
			@ErrorRequestDetailID = @BatchID 
END catch 

RETURN 
--@ReturnCode Output 
-- fine calcoli 
 