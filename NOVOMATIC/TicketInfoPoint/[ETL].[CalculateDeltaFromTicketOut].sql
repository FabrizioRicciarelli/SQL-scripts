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
Description.........: Calcola i Delta in runtime da Out a Out - Versione in memoria (nessuna tabella fisica coinvolta) 

Note 
- Use [Tab size] = 3 and [Indent size] 3 (Insert spaces)
 
------------------ 
-- Parameters   -- 
------------------ 

------------------ 
-- Call Example -- 
------------------
DECLARE
		@XCONFIG	XML -- ex Config.Table
		,@XTMPTicketStart		XML	-- ex TMP.TicketStart
		,@XTMPCountersCork		XML -- ex TMP.CountersCork
		,@XTMPTicketServerTime		XML -- ex TMP.TicketServerTime
		,@XTMPRawData_View		XML OUTPUT -- ex TMP.RawData_View 
		,@XTMPDelta	XML OUTPUT -- ex TMP.Delta
 
EXEC	[ETL].[CalculateDeltaFromTicketOut] 
		@XCONFIG = @XCONFIG
		,@XTMPTicketStart = @XTMPTicketStart
		,@XTMPCountersCork = @XTMPCountersCork
		,@XTMPTicketServerTime = @XTMPTicketServerTime
		,@XTMPRawData_View = @XTMPRawData_View OUTPUT 
		,@XTMPDelta	= @XTMPDelta OUTPUT
*/ 
ALTER PROC	[ETL].[CalculateDeltaFromTicketOut] 
			@XCONFIG				XML -- ex Config.Table
			,@XTMPTicketStart		XML	-- ex TMP.TicketStart
			,@XTMPCountersCork		XML -- ex TMP.CountersCork
			,@XTMPTicketServerTime	XML -- ex TMP.TicketServerTime (in uscita verso la procedura chiamante)
			,@XTMPRawData_View		XML OUTPUT -- ex TMP.RawData_View 
			,@XTMPDelta				XML OUTPUT -- ex TMP.Delta
AS
 
SET NOCOUNT ON; 

BEGIN TRY 
    DECLARE 
			@ConcessionaryID			tinyint
			,@INNERSQL					Nvarchar(MAX)
			,@FromServerTime			datetime 
			,@ToServerTime				datetime 
			,@CurrentMinServerTime		datetime 
			,@CurrentMaxToServerTime	datetime 
			,@ClubID					varchar(10) 
			,@MachineID					smallint 
			,@TicketCode				varchar(50) 
			,@UnivocalLocationCode		varchar(30) 
			,@GD						varchar(30) 
			,@AamsMachineCode			varchar(30) 
			,@Direction					bit = NULL 
			,@ServertimePost			datetime 
			,@BatchID					int 
			,@ServerTimeTicketStart		datetime 
			,@ServertimePre				datetime 
			,@VltMinSession				smallint 
			,@XVLT						XML -- ex dbo.VLT + dbo.gamingroom
			,@XGAME						XML
			,@XTMPRawData_View_TOUT		XML -- RAWDATA CON TOTALOUT > 0
			,@INPUTxrd					ETL.RAWDELTA_TYPE
			,@INPUTxraw					ETL.RAWDATA_TYPE
			 
    -------------------- 
    -- Inizializzazione 
    -------------------- 
	SELECT	@ConcessionaryID = ConcessionaryID 
			,@VltMinSession = minvltendcredit
	FROM	ETL.GetAllXCONFIG(@XCONFIG)
	 
    SELECT	
			@MachineID = Machineid 
            ,@FromServerTime = FromOut
			,@ToServerTime = ToOut
	FROM	ETL.GetAllXCCK(@XTMPCountersCork)

	SELECT	@TicketCode= TicketCode  
			,@BatchID = BatchID 
			,@ClubID = ClubID 
	FROM	ETL.GetAllXTICKETS(@XTMPTicketStart)
	
	EXEC	ETL.ExtractVLT 
			@ConcessionaryID = @ConcessionaryID
			,@ClubID = @ClubID
			,@MachineID = @MachineID
			,@XVLT = @XVLT OUTPUT

	SELECT	@GD = Machine
			,@AamsMachineCode = aamsmachinecode 
			,@UnivocalLocationCode = univocallocationcode
	FROM	ETL.GetAllXVLT(@XVLT)
	
	EXEC	ETL.ExtractGAME 
			@ConcessionaryID = @ConcessionaryID
			,@XGAME = @XGAME OUTPUT
			
	SET @ServertimePre = NULL

    -- Log operazione 
	EXEC ETL.WriteLog @@PROCID, 'Calcolo delta iniziato', @TicketCode, @BatchID -- Log operazione  
	 
    -- pulisco 
    --DELETE 
    --FROM   @TableMaxCounters; 
       
    --DELETE 
    --FROM   [TMP].[Delta] 
	SET @XTMPDelta = NULL
    
    -- Controllo se l'intervallo dei ricalcoli  -- Se ho le date di confine inizio i calcoli (Il resto dei controlli lo effettuo nella FindCork) 
    IF @FromServerTime IS NOT NULL 
    AND @ToServerTime IS NOT NULL
		BEGIN 

			SET		@INNERSQL = 
					N'
					SELECT	
							RowID, ServerTime, GameID, LoginFlag, TotalBet, TotalWon, TotalBillIn, TotalCoinIn, TotalTicketIn, TotalTicketOut, TotalHandpay, WinD, TotalOut, TotalIn
					FROM	[$_AGS_RawData].[#].[RawData_View]
					WHERE	MachineID = ' + CAST(@MachineID AS varchar(5)) + '
					AND		(ServerTime > ''' + CONVERT(Nvarchar(26), @FromServerTime, 126) + ''' AND ServerTime <= ''' + CONVERT(Nvarchar(26), @ToServerTime, 126) + ''')
					'
			EXEC	[ETL].[ExtractRawDataFromPOMMON] 
					@ConcessionaryID = @ConcessionaryID
					,@ClubID = @ClubID
					,@INNERSQL = @INNERSQL
					,@XTMPRawData_View = @XTMPRawData_View OUTPUT

			;WITH tablerawdatacte AS( 
				-- tappo iniziale 
				SELECT 
						NULL AS rowid 
						,@FromServerTime AS servertime
						,@MachineID AS machineid
						,NULL AS gameid
						,0 AS loginflag
						,totalbet
						,totalwon
						,totalbillin
						,totalcoinin
						,totalticketin
						,totalticketout
						,totalhandpay
						,wind
						,totalout
						,totalin 
				--FROM	@TableMaxCounters 
				FROM	ETL.GetAllXCCK(@XTMPCountersCork)
				WHERE	ClubID = @ClubID 
				AND		MachineID = @MachineID
				UNION ALL 
				SELECT 
						rowid 
						,servertime 
						,@MachineID AS machineid 
						,gameid 
						,loginflag 
						,totalbet 
						,totalwon 
						,totalbillin 
						,totalcoinin 
						,totalticketin 
						,totalticketout 
						,totalhandpay 
						,wind 
						,totalout 
						,totalin 
				FROM	ETL.GetAllXRAW(@XTMPRawData_View)
				--FROM	[TMP].[Rawdata_view] (nolock) 
				--WHERE	MachineID = @MachineID
				--AND		servertime > @FromServerTime
				--AND		servertime <= @ToServerTime 
			)
			,tabella01 AS( 
                SELECT   
						rowid 
                        ,servertime 
                        ,machineid 
                        ,gameid 
                        ,loginflag 
                        ,totalbet = totalbet             - ISNULL(MAX(totalbet)			OVER(ORDER BY servertime rows BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0)
                        ,totalwon = totalwon             - ISNULL(MAX(totalwon)			OVER(order BY servertime rows BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0)
                        ,wind = wind                     - ISNULL(MAX(wind)				OVER(order BY servertime rows BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0)
                        ,totalbillin = totalbillin       - ISNULL(MAX(totalbillin)		OVER(order BY servertime rows BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0)
                        ,totalcoinin = totalcoinin       - ISNULL(MAX(totalcoinin)		OVER(order BY servertime rows BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0)
                        ,totalticketin = totalticketin   - ISNULL(MAX(totalticketin)	OVER(order BY servertime rows BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0)
                        ,totalticketout = totalticketout - ISNULL(MAX(totalticketout)	OVER(order BY servertime rows BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0)
                        ,totalhandpay = totalhandpay     - ISNULL(MAX(totalhandpay)		OVER(order BY servertime rows BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0)
                        ,totalout = totalout             - ISNULL(MAX(totalout)			OVER(order BY servertime rows BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0)
                        ,totalin = totalin               - ISNULL(MAX(totalin)			OVER(order BY servertime rows BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0)
                FROM	tablerawdatacte 
			) 
			,tabella02 AS( 
                SELECT   
						rowid 
                        ,servertime 
                        ,machineid 
                        ,gameid 
                        ,loginflag 
                        ,totalbet 
                        ,totalwon 
                        ,wind AS tax 
                        ,totalbillin 
                        ,totalcoinin 
                        ,totalticketin 
                        ,totalticketout 
                        ,totalhandpay 
                        ,totalin 
                        ,totalout 
                        ,vltcredit = SUM(CAST((ISNULL(totalin, 0) + ISNULL(totalwon,0)) AS bigint) - CAST((ISNULL(totalbet,0) + ISNULL(totalout,0) + ISNULL(wind,0)) AS bigint)) OVER(ORDER BY servertime rows BETWEEN UNBOUNDED PRECEDING AND CURRENT row)
				FROM	tabella01 t1
			)
			INSERT @INPUTxrd(
						RowID
						,UnivocalLocationCode
						,ServerTime
						,MachineID
						,GD
						,AamsMachineCode
						,GameID
						,GameName
						,LoginFlag
						,VLTCredit
						,TotalBet
						,TotalWon
						,TotalBillIn
						,TotalCoinIn
						,TotalTicketIn
						,TotalHandPay
						,TotalTicketOut
						,Tax
						,TotalIn
						,TotalOut
						,WrongFlag
						,TicketCode
						,FlagMinVltCredit
						,SessionID
					)
			SELECT	
					T1.rowid AS RowID
					,@UnivocalLocationCode AS UnivocalLocationCode
					,T1.servertime AS ServerTime
					,T1.machineid AS MachineID
					,@GD AS GD
					,@AamsMachineCode AS AamsMachineCode
					,t1.gameid AS GameID
					,t2.GameName AS GameName
					,t1.loginflag AS LoginFlag
					,t1.vltcredit AS VLTCredit
					,t1.totalbet AS TotalBet
					,t1.totalwon AS TotalWon 
					,t1.totalbillin AS TotalBillIn
					,t1.totalcoinin AS TotalCoinIn
					,t1.totalticketin AS TotalTicketIn
					,t1.totalhandpay AS TotalHandPay
					,t1.totalticketout AS TotalTicketOut
					,t1.tax AS Tax
					,t1.totalin AS TotalIn 
					,t1.totalout AS TotalOut
					,NULL AS WrongFlag
					,NULL AS TicketCode
					,NULL AS FlagMinVltCredit
					,NULL AS SessionID
 			FROM	tabella02 T1 
					INNER JOIN 
					--dbo.GameNameID T2 
					ETL.GetAllXGAME(@XGAME) t2
					ON t1.gameid = t2.gameid
			
			SET	@XTMPDelta = ETL.BulkXRD(@XTMPDelta, @INPUTxrd) -- RIEMPIE IL CONTENITORE XML CON I DATI PRESENTI NELL'OGGETTO DI TIPO "ETL.RAWDELTA_TYPE", RITORNA UNA VARIABILE XML CONTENENTE TUTTE LE COLONNE PRESENTI NELL'OGGETTO IN INGRESSO (@INPUTxrd = ETL.RAWDELTA_TYPE)

			-- Cancello per avere le sessioni con limite a 50 C 
			SELECT	
					@ServerTimeTicketStart = ServerTime 
					,@Direction = direction 
			--FROM	[TMP].[TicketServerTime] 
			FROM	ETL.GetAllXTST(@XTMPTicketServerTime)
    
			SELECT	@ServertimePre = MAX(ServerTime) 
			--FROM   [TMP].[Delta]
			FROM	ETL.GetAllXRD(@XTMPDelta) 
			WHERE	vltcredit < @VltMinSession 
			AND		servertime < @ServerTimeTicketStart 
			AND		ISNULL(totalin,0) = 0

			IF @ServertimePre IS NOT NULL 
				BEGIN
				 
					--DELETE 
					--FROM   [TMP].[Delta] 
					--WHERE  servertime < @ServertimePre
					SET @XTMPDelta.modify('delete //XRD[@ServerTime<sql:variable("@ServertimePre")]') 
        
					-- credito residuo da sessione precedente 
					--UPDATE	[TMP].delta 
					--SET		totalbet = NULL
					--		,totalwon = NULL 
					--WHERE	servertime = @ServertimePre
					SET	@XTMPDelta = ETL.UpdMultiFieldX(@XTMPDelta,  'totalbet=NULL,totalwon = NULL' , 'servertime=''' + CONVERT(varchar(26), @ServertimePre, 126) + '''') 
				END 
    
			-- se è in avanti la sessione finisce se il credito diventa inferiore a mincredit 
			IF @Direction = 1 
				BEGIN 
					SELECT	@ServertimePost = MIN(ServerTime) 
					--FROM   [TMP].[Delta] 
					FROM	ETL.GetAllXRD(@XTMPDelta) 
					WHERE	vltcredit < @VltMinSession 
					AND		servertime > @ServerTimeTicketStart 
					AND		ISNULL(totalout,0) = 0 

					IF @ServertimePost IS NOT NULL 
					--DELETE 
					--FROM   [TMP].[Delta] 
					--WHERE  servertime > @ServertimePost 
					SET @XTMPDelta.modify('delete //XRD[@ServerTime>sql:variable("@ServertimePost")]') 
				END 
    
			-- Log operazione 
			EXEC ETL.WriteLog @@PROCID, 'Calcolo delta terminato', @TicketCode, @BatchID -- Log operazione  

		END 
    ELSE 
		-- Errore specifico 
		BEGIN 
			RAISERROR ('@FromServerTime OR @ToServerTime is Null',16,1); 
		END 
    
	-- Errore specifico 
    IF NOT EXISTS(SELECT TOP 1 *FROM ETL.GetAllXRD(@XTMPDelta)) 
		BEGIN 
			RAISERROR ('Empty table [TMP].[Delta]',16,1); 
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
