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
DECLARE @ReturnCode int 
EXEC ETL.CalcAll @ConcessionaryID = 7, @Direction = 0,@TicketCode = '164504952927074578' ,@BatchID = 1,@ReturnCode = @ReturnCode Output
Select @ReturnCode 

DECLARE @ReturnCode int 
EXEC ETL.CalcAllLevel @ConcessionaryID = 7, @Direction = 0,@TicketCode = '1000294MHR201502110001' ,@BatchID = 1,@MaxLevel = 50,@ReturnCode = @ReturnCode Output
Select @ReturnCode 

EXEC ETL.CalcAllLevel @ConcessionaryID = 1, @Direction = 0,@TicketCode = '116136268470765059' ,@BatchID = 1,@MaxLevel = 10

DECLARE @ReturnCode int 
EXEC ETL.CalcAllLevel @ConcessionaryID = 7, @Direction = 1,@TicketCode = 'dddds' ,@BatchID = 1,@MaxLevel = 50,@ReturnCode = @ReturnCode Output
Select @ReturnCode 

*/ 
ALTER PROC	[ETL].[CalcAll] 
			@ConcessionaryID	tinyint 
			,@Direction			bit
			,@TicketCode		varchar(50) 
			,@Level				int = NULL 
			,@SessionParentID	int = NULL 
			,@BatchID			int
			,@ClubID			varchar(10) = NULL
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
    --(SELECT @ClubID = clubid 
    --    FROM   TMP.Ticketstart) 
	SELECT	@ClubID = ISNULL(@ClubID, clubid) 
	FROM	TMP.Ticketstart

    --SET @VltEndCredit = (SELECT minvltendcredit 
    --                    FROM   [Config].[Table]) 
    SELECT	@VltEndCredit = minvltendcredit 
	FROM   [Config].[Table] 

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
				EXEC	@ReturnCodeInternal = ETL.Calcsession @Level = @Level, @SessionParentID = @SessionParentID 
		END 
    ELSE 
		IF @ReturnCodeInternal = 1 AND @Direction = 1 -- pagato da cashdesk
			BEGIN 
				SELECT @PayoutData = payoutdata 
				FROM   TMP.Ticketstart 
				WHERE  ticketcode = @TicketCode 

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
					SELECT @PrintingData = printingdata 
					FROM   TMP.Ticketstart 
					WHERE  ticketcode = @TicketCode 

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
 