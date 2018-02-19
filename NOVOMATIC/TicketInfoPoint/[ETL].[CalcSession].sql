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
		,@XCCK = @XCCK -- ex TMP.CountersCork 
		,@XTMPDelta	= @XTMPDelta -- ex TMP.Delta
		,@Level	= @Level 
		,@SessionParentID = @SessionParentID
		,@XTKS = @XTKS -- ex TMP.TicketStart
		,@XRS = @XRS OUTPUT -- ex RAW.Session
		,@XRD = @XRD OUTPUT -- ex RAW.Delta
*/ 
ALTER PROC	[ETL].[CalcSession]
			@XCONFIG			XML = NULL -- ex Config.Table
			,@XCCK				XML = NULL -- ex TMP.CountersCork 
			,@XTMPDelta			XML = NULL -- ex TMP.Delta
			,@Level				int = NULL 
			,@SessionParentID	int = NULL
			,@XTKS				XML = NULL -- ex TMP.TicketStart
			,@XRS				XML OUTPUT -- ex RAW.Session
			,@XRD				XML OUTPUT -- ex RAW.Delta
AS
 
SET nocount ON; 

DECLARE 
		@ConcessionaryID		tinyint
		,@ClubID				int 
		,@MachineID             smallint 
		,@SessionID             int 
		,@StartTicketCode       varchar(50) 
		--,@TicketCode            varchar(50) 
		,@SessionCalc           tinyint 
		,@GD                    varchar(30) 
		,@AamsMachineCode       varchar(30) 
		,@UnivocalLocationCode  varchar(30) 
		,@MinVltEndCredit       int 
		,@BatchID               int
		,@XVLT					XML -- ex dbo.VLT + dbo.gamingroom
		,@inputXRD				ETL.RAWDELTA_TYPE 
		,@inputXRS				ETL.RAWSESSION_TYPE 

BEGIN TRY 
    SELECT
			--@TicketCode = ticketcode  
			@StartTicketCode = ticketcode
            ,@BatchID = batchid 
    --FROM	tmp.ticketstart
	FROM	ETL.GetAllXTICKETS(@XTKS)
	 
	SELECT 
			@ConcessionaryID = ConcessionaryID
			,@MinVltEndCredit = minvltendcredit
	--FROM   [Config].[Table]
	FROM	ETL.GetAllXConfig(@XCONFIG)
    
	-- Log operazione 
 	EXEC ETL.WriteLog @@PROCID, 'Calcolo sessioni iniziato', @StartTicketCode, @BatchID -- Log operazione  
  
    SET @SessionCalc = 0 
    ----------------- 
    -- Inizializzo 
    ----------------- 
    SELECT	
			@MachineID = machineid 
			,@ClubID = clubid 
   --         ,@FromServerTime = fromout
			--,@ToServerTime = toout
	FROM	ETL.GetAllXCCK(@XCCK)


    --SELECT @MachineID = machineid, 
    --        @ClubID =    clubid 
    --FROM   tmp.counterscork
	 
    --SELECT @StartTicketCode = ticketcode 
    --FROM   tmp.ticketstart
	 
    --SELECT @GD = machine, 
    --        @AamsMachineCode = aamsmachinecode 
    --FROM   dbo.vlt
    --WHERE  machineid = @MachineID 
    --AND    clubid = @ClubID 

    --SELECT @UnivocalLocationCode = univocallocationcode 
    --FROM   dbo.gamingroom 
    --WHERE  clubid = @ClubID 
	EXEC	ETL.ExtractVLT 
			@ConcessionaryID = @ConcessionaryID
			,@ClubID = @ClubID
			,@XVLT = @XVLT OUTPUT

	SELECT	@GD = Machine
			,@AamsMachineCode = aamsmachinecode 
			,@UnivocalLocationCode = univocallocationcode
	FROM	ETL.GetAllXVLT(@XVLT) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI

    IF @MachineID IS NOT NULL 
    BEGIN 
		--INSERT INTO raw.session( 
		--			univocallocationcode
		--			,machineid
		--			,gd
		--			,aamsmachinecode
		--			,startservertime
		--			,endservertime
		--			,totalrows
		--			,totalbillin
		--			,totalcoinin
		--			,totalticketin
		--			,totalbetvalue
		--			,totalbetnum
		--			,totalwinvalue
		--			,totalwinnum
		--			,tax
		--			,totalin
		--			,totalout
		--			,flagminvltcredit
		--			,startticketcode
		--			,level
		--			,sessionparentid
		--		) 
		---- Aggregazione per sessione 
		--SELECT 
		--		@UnivocalLocationCode 
		--		,@MachineID 
		--		,@GD 
		--		,@AamsMachineCode 
		--		,min(servertime)              AS startservertime 
		--		,max(servertime)              AS endservertime 
		--		,count(*)                     AS totalrows  
		--		,isnull(count(totalbillin),0) AS totalbillin 
		--		,count(totalcoinin)           AS totalcoinin 
		--		,count(totalticketin)         AS totalticketin 
		--		,isnull(sum(totalbet),0)      AS totalbetvalue 
		--		,count(totalbet)              AS totalbetnum 
		--		,isnull(sum(totalwon),0)      AS totalwinvalue 
		--		,count(totalwon)              AS totalwinnum 
		--		,isnull(sum(tax),0)           AS tax 
		--		,sum(totalin)                 AS totalin 
		--		,sum(totalout)                AS totalout 
		--		,max(cast(flagminvltcredit AS tinyint)) 
		--		,@StartTicketCode 
		--		,@level 
		--		,@SessionParentID 
		--FROM	tmp.delta

		--SELECT	ETL.WriteXRS(
		INSERT	@inputXRS
		SELECT
				--@XRS
				NULL -- @SessionID
				,@SessionParentID
				,@Level
				,@UnivocalLocationCode
				,@MachineID
				,@GD
				,@AamsMachineCode
				,MIN(servertime) -- @StartServerTime
				,MAX(servertime) -- @EndServerTime
				,COUNT(*) -- @TotalRows
				,ISNULL(COUNT(totalbillin),0) --@TotalBillIn
				,COUNT(totalcoinin) -- @TotalCoinIN
				,COUNT(totalticketin) -- @TotalTicketIn
				,ISNULL(SUM(totalbet),0) -- @TotalBetValue
				,COUNT(totalbet) -- @TotalBetNum
				,ISNULL(SUM(totalwon),0) -- @TotalWinValue
				,COUNT(totalwon) -- @TotalWinNum
				,ISNULL(SUM(tax),0) -- @Tax
				,SUM(totalin) -- @TotalIn
				,SUM(totalout) -- @TotalOut
				,MAX(CAST(flagminvltcredit AS tinyint)) -- @FlagMinVltCredit
				,@StartTicketCode
		FROM	ETL.GetAllXRD(@XTMPDelta)
		SET		@XRS = ETL.BulkXRS(@XRS, @inputXRS)

		SET		@SessionCalc = @@RowCount 
		SELECT	@SessionID = MAX(sessionid) 
		--FROM	raw.session 
		FROM	ETL.GetAllXRS(@XRS)
    END 

    IF @SessionCalc > 0 
		BEGIN 
			------------------------------------------------------------------------------------------------ 
			-- Inserisci i delta -- 
			------------------------------------------------------------------------------------------------ 
			--INSERT INTO raw.delta( 
			--			rowid  
			--			,univocallocationcode 
			--			,servertime 
			--			,machineid 
			--			,gd 
			--			,aamsmachinecode 
			--			,gameid 
			--			,gamename 
			--			,vltcredit 
			--			,totalbet  
			--			,totalwon  
			--			,totalbillin 
			--			,totalcoinin  
			--			,totalticketin  
			--			,totalhandpay 
			--			,totalticketout  
			--			,tax  
			--			,totalin  
			--			,totalout  
			--			,ticketcode 
			--			,flagminvltcredit 
			--			,sessionid 
			--		) 
			--SELECT	
			--		rowid 
			--		,univocallocationcode 
			--		,servertime 
			--		,machineid 
			--		,gd 
			--		,aamsmachinecode 
			--		,gameid 
			--		,gamename 
			--		,vltcredit  
			--		,totalbet  
			--		,totalwon  
			--		,totalbillin  
			--		,totalcoinin 
			--		,totalticketin 
			--		,totalhandpay 
			--		,totalticketout 
			--		,tax  
			--		,totalin 
			--		,totalout 
			--		,ticketcode 
			--		,NULL 
			--		,@SessionID 
			--FROM	tmp.delta 
			--ORDER BY
			--		servertime ASC 
			--		,machineid ASC
			
			--SELECT @XRD = [ETL].[WriteXRD]
			--	(
			--		@XRD 
			INSERT @inputXRD
			SELECT
					rowid -- @RowID
					,univocallocationcode -- @UnivocalLocationCode
					,servertime -- @ServerTime
					,machineid -- @MachineID
					,gd -- @GD
					,aamsmachinecode -- @AamsMachineCode
					,gameid -- @GameID
					,gamename -- @GameName
					,NULL -- @LoginFlag
					,vltcredit -- @VLTCredit
					,totalbet -- @TotalBet
					,totalwon -- @TotalWon
					,totalbillin -- @TotalBillIn
					,totalcoinin -- @TotalCoinIn
					,totalticketin -- @TotalTicketIn
					,totalhandpay -- @TotalHandPay
					,totalticketout -- @TotalTicketOut
					,tax -- @Tax
					,totalin -- @TotalIn
					,totalout -- @TotalOut
					,NULL -- case when VLTCredit<(0) OR TotalBet<(0) OR TotalWon<(0) OR TotalBillIn<(0) OR TotalCoinIn<(0) OR TotalTicketIn<(0) OR TotalHandPay<(0) OR TotalTicketOut<(0) OR Tax<(0) OR VLTCredit>(10000000) OR TotalBet>(1000) OR TotalWon>(500000) OR TotalBillIn>(50000) OR TotalCoinIn>(200) OR TotalTicketIn>(1000000) OR TotalHandPay>(6000000) OR TotalTicketOut>(1000000) OR Tax>(50000) then (1) else (0) end -- @WrongFlag
					,ticketcode -- @StartTicketCode
					,NULL -- @FlagMinVltCredit
					,@SessionID 
				--)
			FROM	ETL.GetAllXRD(@XTMPDelta)
			ORDER BY
					servertime ASC 
					,machineid ASC
 			SET		@XRD = ETL.BulkXRD(@XRD, @inputXRD)

    END 

    --- fine procedura 
    -- Log operazione 
 	EXEC ETL.WriteLog @@PROCID, 'Calcolo sessioni terminato', @StartTicketCode, @BatchID -- Log operazione  

    -- Errore specifico 
    IF @SessionCalc <> 1 
    BEGIN 
		RAISERROR ('Session has not been calculated',16,1); 
    END 
END try 
-- Gestione Errore 
BEGIN catch 
    --SELECT @BatchID = batchid 
    --FROM   tmp.ticketstart 
    --EXECUTE err.usplogerror 
    --@ErrorTicket = @StartTicketCode, 
    --@ErrorRequestDetailID = @BatchID 
    --SET @ReturnCode = -1; 
end catch 
--RETURN @ReturnCode 
-- fine calcoli 
