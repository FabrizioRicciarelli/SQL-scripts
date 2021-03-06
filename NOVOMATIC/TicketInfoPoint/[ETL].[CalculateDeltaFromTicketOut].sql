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
		,@XTMPDelta	XML OUTPUT -- ex TMP.Delta
 
EXEC	[ETL].[CalculateDeltaFromTicketOut] 
		@XCONFIG = @XCONFIG
		,@XTMPTicketStart = @XTMPTicketStart
		,@XTMPCountersCork = @XTMPCountersCork
		,@XTMPTicketServerTime = @XTMPTicketServerTime
		,@XTMPDelta	= @XTMPDelta OUTPUT
*/ 
ALTER PROC	[ETL].[CalculateDeltaFromTicketOut] 
			@XCONFIG				XML			-- ex Config.Table
			,@XTMPTicketStart		XML			-- ex TMP.TicketStart
			,@XTMPCountersCork		XML			-- ex TMP.CountersCork
			,@XTMPTicketServerTime	XML			-- ex TMP.TicketServerTime (in uscita verso la procedura chiamante)
			,@XTMPDelta				XML OUTPUT	-- ex TMP.Delta
			,@ReturnCode			int = 0 OUTPUT
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
			,@XVLT						XML			-- ex dbo.VLT + dbo.gamingroom
			,@XGAME						XML
			,@XTMPRawData_View			XML			-- ex TMP.RawData_View 
			,@TMPDELTATYPE				ETL.RAWDELTA_TYPE
			 
	SELECT	@ConcessionaryID = ConcessionaryID 
			,@VltMinSession = minvltendcredit
	FROM	ETL.GetAllXCONFIG(@XCONFIG)
	
    SELECT	
			@MachineID = Machineid 
			,@ClubID = ClubID 
            ,@FromServerTime = FromOut
			,@ToServerTime = ToOut
	FROM	ETL.GetAllXCCK(@XTMPCountersCork)

	SELECT	@TicketCode= TicketCode  
			,@BatchID = BatchID 
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

	EXEC ETL.WriteLog @@PROCID, 'Calcolo delta iniziato', @TicketCode, @BatchID -- Log operazione  
	 
	SET @XTMPDelta = NULL
    
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
			)
			,tabella01 AS( 
                SELECT   
						rowid 
                        ,servertime 
                        ,machineid 
                        ,gameid 
                        ,loginflag 
                        ,totalbet = totalbet             - ISNULL(MAX(totalbet)			OVER(ORDER BY servertime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0)
                        ,totalwon = totalwon             - ISNULL(MAX(totalwon)			OVER(ORDER BY servertime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0)
                        ,wind = wind                     - ISNULL(MAX(wind)				OVER(ORDER BY servertime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0)
                        ,totalbillin = totalbillin       - ISNULL(MAX(totalbillin)		OVER(ORDER BY servertime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0)
                        ,totalcoinin = totalcoinin       - ISNULL(MAX(totalcoinin)		OVER(ORDER BY servertime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0)
                        ,totalticketin = totalticketin   - ISNULL(MAX(totalticketin)	OVER(ORDER BY servertime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0)
                        ,totalticketout = totalticketout - ISNULL(MAX(totalticketout)	OVER(ORDER BY servertime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0)
                        ,totalhandpay = totalhandpay     - ISNULL(MAX(totalhandpay)		OVER(ORDER BY servertime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0)
                        ,totalout = totalout             - ISNULL(MAX(totalout)			OVER(ORDER BY servertime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0)
                        ,totalin = totalin               - ISNULL(MAX(totalin)			OVER(ORDER BY servertime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0)
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
			INSERT	@TMPDELTATYPE(RowID, UnivocalLocationCode, ServerTime, MachineID, GD, AamsMachineCode, GameID, GameName, LoginFlag, VLTCredit, TotalBet, TotalWon, TotalBillIn, TotalCoinIn, TotalTicketIn, TotalHandPay, TotalTicketOut, Tax, TotalIn, TotalOut, WrongFlag, TicketCode, FlagMinVltCredit, SessionID)
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
					ETL.GetAllXGAME(@XGAME) t2
					ON t1.GameID = t2.GameID
			
			SELECT	
					@ServerTimeTicketStart = ServerTime 
					,@Direction = direction 
			FROM	ETL.GetAllXTST(@XTMPTicketServerTime)
    
			SELECT	@ServertimePre = MAX(ServerTime) 
			FROM	@TMPDELTATYPE 
			WHERE	vltcredit < @VltMinSession 
			AND		servertime < @ServerTimeTicketStart 
			AND		ISNULL(TotalIn,0) = 0

			IF @ServertimePre IS NOT NULL 
				BEGIN
					DELETE 
					FROM   @TMPDELTATYPE 
					WHERE  servertime < @ServertimePre

					UPDATE	@TMPDELTATYPE 
					SET		totalbet = NULL
							,totalwon = NULL 
					WHERE	servertime = @ServertimePre
				END 
    
			IF @Direction = 1 
				BEGIN 
					SELECT	@ServertimePost = MIN(ServerTime) 
					FROM	@TMPDELTATYPE 
					WHERE	vltcredit < @VltMinSession 
					AND		servertime > @ServerTimeTicketStart 
					AND		ISNULL(totalout,0) = 0 

					IF @ServertimePost IS NOT NULL 
						DELETE 
						FROM   @TMPDELTATYPE 
						WHERE  servertime > @ServertimePost 
				END 

			SET	@XTMPDelta = ETL.BulkXRD(@XTMPDelta, @TMPDELTATYPE)

			EXEC ETL.WriteLog @@PROCID, 'Calcolo delta terminato', @TicketCode, @BatchID -- Log operazione  

		END 
    ELSE 
		BEGIN 
			RAISERROR ('@FromServerTime OR @ToServerTime is Null',16,1); 
		END 
    
    IF NOT EXISTS(SELECT TOP 1 *FROM ETL.GetAllXRD(@XTMPDelta)) 
		BEGIN 
			RAISERROR ('Empty table [TMP].[Delta]',16,1); 
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

