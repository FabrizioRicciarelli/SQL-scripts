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
Description.........: Calcola la sessione da Out a Out - Versione in memoria (nessuna tabella fisica coinvolta) 

Note 
- Use Tab size = 3 and Indent size 3 (Insert spaces) 
------------------ 
-- Parameters   -- 
------------------ 

------------------ 
-- Call Example -- 
------------------ 
EXEC	ETL.CalcSession 
		@XCONFIG = @XCONFIG -- ex Config.Table
		,@XTMPCountersCork = @XTMPCountersCork -- ex TMP.CountersCork 
		,@XTMPDelta	= @XTMPDelta -- ex TMP.Delta
		,@Level	= @Level 
		,@SessionParentID = @SessionParentID
		,@XTMPTicketStart = @XTMPTicketStart -- ex TMP.TicketStart
		,@XRawSession = @XRawSession OUTPUT -- ex RAW.Session
		,@XRAWDelta = @XRAWDelta OUTPUT -- ex RAW.Delta
*/ 
ALTER PROC	[ETL].[CalcSession]
			@XCONFIG			XML = NULL -- ex Config.Table
			,@XTMPCountersCork	XML = NULL -- ex TMP.CountersCork 
			,@XTMPDELTA			XML		   -- ex TMP.Delta
			,@Level				int = NULL 
			,@SessionParentID	int = NULL
			,@XTMPTicketStart	XML = NULL -- ex TMP.TicketStart
			,@XRawSession		XML OUTPUT -- ex RAW.Session
			,@XRAWDelta			XML OUTPUT -- ex RAW.Delta
			,@ReturnCode		int = 0 Output
AS
 
SET NOCOUNT ON; 

DECLARE 
		@ConcessionaryID		tinyint
		,@ClubID				int 
		,@MachineID             smallint 
		,@SessionID             int 
		,@StartTicketCode       varchar(50) 
		,@SessionCalc           tinyint 
		,@GD                    varchar(30) 
		,@AamsMachineCode       varchar(30) 
		,@UnivocalLocationCode  varchar(30) 
		,@MinVltEndCredit       int 
		,@BatchID               int
		,@XVLT					XML			-- ex dbo.VLT + dbo.gamingroom
		,@LOCALRAWDELTA			ETL.RAWDELTA_TYPE 
		,@LOCALRAWSESSION		ETL.RAWSESSION_TYPE 

BEGIN TRY 
    SELECT
			@StartTicketCode = ticketcode
            ,@BatchID = batchid 
	FROM	ETL.GetAllXTICKETS(@XTMPTicketStart)
	 
	SELECT 
			@ConcessionaryID = ConcessionaryID
			,@MinVltEndCredit = minvltendcredit
	FROM	ETL.GetAllXConfig(@XCONFIG)
    
    SELECT	
			@MachineID = machineid 
			,@ClubID = clubid 
	FROM	ETL.GetAllXCCK(@XTMPCountersCork)

	EXEC	ETL.ExtractVLT 
			@ConcessionaryID = @ConcessionaryID
			,@ClubID = @ClubID
			,@MachineID = @MachineID
			,@XVLT = @XVLT OUTPUT

	SELECT	@GD = Machine
			,@AamsMachineCode = aamsmachinecode 
			,@UnivocalLocationCode = univocallocationcode
	FROM	ETL.GetAllXVLT(@XVLT)

 	EXEC ETL.WriteLog @@PROCID, 'Calcolo sessioni iniziato', @StartTicketCode, @BatchID  
	
    SET @SessionCalc = 0
	 
    IF @MachineID IS NOT NULL 
		BEGIN 

			INSERT	@LOCALRAWSESSION(UnivocalLocationCode, MachineID, GD, AamsMachineCode, StartServerTime , EndServerTime , TotalRows , TotalBillIn, TotalCoinIN, TotalTicketIn , TotalBetValue, TotalBetNum, TotalWinValue , TotalWinNum , Tax , TotalIn, TotalOut, FlagMinVLtCredit, StartTicketCode, Level, SessionParentID)
			SELECT
					@UnivocalLocationCode AS UnivocalLocationCode
					,@MachineID AS MachineID
					,@GD AS GD
					,@AamsMachineCode AS AamsMachineCode
					,MIN(ServerTime) AS StartServerTime
					,MAX(ServerTime) AS EndServerTime
					,COUNT(*) AS TotalRows 
					,ISNULL(COUNT(TotalBillIn),0) AS TotalBillIn
					,COUNT(TotalCoinIN) AS TotalCoinIN
					,COUNT(TotalTicketIn) AS TotalTicketIn
					,ISNULL(SUM(TotalBet),0) AS TotalBetValue
					,COUNT(TotalBet) AS TotalBetNum
					,ISNULL(SUM(TotalWon),0) AS TotalWinValue
					,COUNT(TotalWon) AS TotalWinNum
					,ISNULL(SUM(Tax),0) AS Tax
					,SUM(TotalIn) AS TotalIn
					,SUM(TotalOut) AS TotalOut
					,MAX(CAST(FlagMinVLtCredit AS tinyint)) AS FlagMinVLtCredit
					,@StartTicketCode AS StartTicketCode
					,@level	AS Level
					,@SessionParentID AS SessionParentID
			FROM	ETL.GetAllXRD(@XTMPDELTA)
		
			SET		@SessionCalc = @@RowCount 

			SET		@XRawSession = ETL.BulkXRS(@XRawSession, @LOCALRAWSESSION)
			DELETE	FROM @LOCALRAWSESSION

 			SELECT	@SessionID = MAX(sessionid)
			FROM	ETL.GetAllXRS(@XRawSession) 
	   END 

    IF @SessionCalc > 0 
		BEGIN 
			
			DELETE	FROM @LOCALRAWDELTA
			INSERT	@LOCALRAWDELTA(RowID, UnivocalLocationCode, ServerTime, MachineID, GD, AamsMachineCode, GameID, GameName, VLTCredit, TotalBet, TotalWon, TotalBillIn, TotalCoinIn, TotalTicketIn, TotalHandPay, TotalTicketOut, Tax, TotalIn, TotalOut, TicketCode, FlagMinVLtCredit, SessionID)
			SELECT	RowID, UnivocalLocationCode, ServerTime, MachineID, GD, AamsMachineCode, GameID, GameName, VLTCredit, TotalBet, TotalWon, TotalBillIn, TotalCoinIn, TotalTicketIn, TotalHandPay, TotalTicketOut, Tax, TotalIn, TotalOut, TicketCode, NULL AS FlagMinVLtCredit, @SessionID 
			FROM	ETL.GetAllXRD(@XTMPDelta)
			ORDER BY
					servertime ASC 
					,machineid ASC
 			
			SET		@XRAWDelta = ETL.BulkXRD(@XRAWDelta, @LOCALRAWDELTA)
		END 

 	EXEC ETL.WriteLog @@PROCID, 'Calcolo sessioni terminato', @StartTicketCode, @BatchID  

    IF @SessionCalc <> 1 
    BEGIN 
		RAISERROR ('Session has not been calculated',16,1); 
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
			,NULL AS ErrorTicketCode
			,@BatchID AS ErrorRequestDetailID
            SET @ReturnCode = -1;
END CATCH 

RETURN @ReturnCode
