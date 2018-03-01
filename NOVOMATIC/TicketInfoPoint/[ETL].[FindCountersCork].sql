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
Description.........: Calcola i valori di tutti i contatori non nulli precedenti all'ultimo calcolo dei delta effettuato - Versione in memoria (nessuna tabella fisica coinvolta)

Revision        

Note 
- Use [Tab size] = 2 and [Indent size] 

------------------ 
-- Parameters   -- 
------------------   

------------------ 
-- Call Example -- 
------------------


-- DIRECTION = 0 
DECLARE
		@TicketCode					varchar(50) = '427102895993931934'
		,@ReturnCode int 
		,@XConfigTable				XML -- ex Config.Table
		,@XTMPTicketStart			XML -- ex TMP.TicketStart
		,@XTMPTicketServerTime		XML -- ex TMP.TicketServerTime
		,@XTMPCountersCork			XML -- ex TMP.CountersCork
		,@XTMPRawData_View			XML -- ex TMP.RawData_View 

-- CARICA UN ELEMENTO NEL CONTENITORE @XConfigTable
SET	@XConfigTable =	ETL.WriteXCONFIG(
					@XConfigTable
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

EXEC	[ETL].[FindCountersCork]
		@XConfigTable = @XConfigTable
		,@Direction = 0
		,@TicketCode = @TicketCode
		,@BatchID = 1 
		,@XTMPTicketStart = @XTMPTicketStart OUTPUT -- ex TMP.TicketStart
		,@XTMPTicketServerTime = @XTMPTicketServerTime OUTPUT -- ex TMP.TicketServerTime
		,@XTMPCountersCork = @XTMPCountersCork OUTPUT -- ex TMP.CountersCork
		,@XTMPRawData_View = @XTMPRawData_View OUTPUT -- ex TMP.RawData_View 

SELECT 'CountersCork' AS TableName, * FROM ETL.GetAllXCCK(@XTMPCountersCork)
SELECT 'ConfigTable' AS TableName, * FROM ETL.GetAllXCONFIG(@XConfigTable)
SELECT 'TicketStart' AS TableName, * FROM  ETL.GetAllXTICKETS(@XTMPTicketStart)
SELECT 'TicketServerTime' AS TableName, * FROM ETL.GetAllXTST(@XTMPTicketServerTime)

-- DIRECTION = 1 
SET @XTMPTicketStart = NULL
SET @XTMPTicketServerTime = NULL
SET @XTMPCountersCork = NULL
SET @XTMPRawData_View = NULL

EXEC	[ETL].[FindCountersCork]
		@XConfigTable = @XConfigTable
		,@Direction = 1
		,@TicketCode = @TicketCode
		,@BatchID = 1 
		,@XTMPTicketStart = @XTMPTicketStart OUTPUT -- ex TMP.TicketStart
		,@XTMPTicketServerTime = @XTMPTicketServerTime OUTPUT -- ex TMP.TicketServerTime
		,@XTMPCountersCork = @XTMPCountersCork OUTPUT -- ex TMP.CountersCork
		,@XTMPRawData_View = @XTMPRawData_View OUTPUT -- ex TMP.RawData_View 

SELECT 'ConfigTable' AS TableName, * FROM ETL.GetAllXCONFIG(@XConfigTable)
SELECT 'TicketStart' AS TableName, * FROM  ETL.GetAllXTICKETS(@XTMPTicketStart)
SELECT 'TicketServerTime' AS TableName, * FROM ETL.GetAllXTST(@XTMPTicketServerTime)
SELECT 'CountersCork' AS TableName, * FROM ETL.GetAllXCCK(@XTMPCountersCork)
--SELECT 'RawData' AS TableName, * FROM ETL.GetAllXRAW(@XTMPRawData_View)

*/ 
ALTER PROC	[ETL].[FindCountersCork] 
			@XConfigTable				XML -- ex Config.Table
			,@Direction					bit 
			,@TicketCode				varchar(50) 
			,@ClubID					varchar(10) = NULL 
			,@BatchID					int 
			,@XTMPTicketStart			XML OUTPUT -- ex TMP.TicketStart
			,@XTMPTicketServerTime		XML OUTPUT -- ex TMP.TicketServerTime
			,@XTMPCountersCork			XML OUTPUT -- ex TMP.CountersCork
			,@XTMPRawData_View			XML OUTPUT -- ex TMP.RawData_View 
AS 

SET NOCOUNT ON; 

DECLARE
        @PayOutDate					datetime 
		,@RAWDATAServerTimeStart	datetime 
		,@RAWDATAServerTimeEnd		datetime 
        ,@FromServerTimeOut			datetime 
		,@INNERSQL					Nvarchar(MAX)
		,@OFFSET					int
        ,@OFFSETOUT					SmallInt = 3600 
        ,@OFFSETIN					int
        ,@FromServerTime			datetime 
        ,@FromServerTimeIN			datetime 
        ,@IspaidCashdesk			bit 
        ,@RestartTime				datetime 
        ,@ConcessionaryID			tinyint 
        ,@PrintingDate				datetime2(0) 
        ,@IsprintingCashDesk		bit
        ,@ToOut						datetime = NULL 
        ,@MachineID					smallint 
        ,@StrMachineID				varchar(10) 
        ,@TicketValue				int 
		,@ServerTime_FIRST			datetime = '1900-01-01 00:00:00.000' 
        ,@ServerTime_LAST			datetime = GETDATE() 
		,@CountersCorkTYPE			ETL.CCK_TYPE

BEGIN TRY 
	SET @IspaidCashdesk = 0	
	SET @ISPrintingCashdesk = 0	

	SELECT	
			@ConcessionaryID = concessionaryid
			,@OFFSET = offsetout * 1000
			,@OFFSETIN = offsetin * 1000
	FROM	ETL.GetAllXCONFIG(@XConfigTable) 

    -- Log operazione 
	EXEC ETL.WriteLog @@PROCID, 'Calcolo tappo iniziato', @TicketCode, @BatchID -- Log operazione  

    -- Prelievo dei dati del ticket di partenza 
	EXEC	ETL.ExtractTicketsFromPIN
			@ConcessionaryID = @ConcessionaryID	-- OBBLIGATORIO, DETERMINA IL CONCESSIONARIO
			,@ClubID = @ClubID					-- FACOLTATIVO, DETERMINA LA SALA (VERRA' COMUNQUE DETERMINATO DAI TICKETS ESTRATTI DALLA PIN E POSTO NEL "RECORDSET" DI OUTPUT @XTMPTicketStart)
			,@TicketCode = @TicketCode			-- OBBLIGATORIO, ELENCO DI TICKETS (MIXATI, SIA MHx CHE NON), SEPARATI DA VIRGOLE, OPPURE TICKET SINGOLO (SIA MHx CHE NON)
			,@XMLTICKETS = @XTMPTicketStart OUTPUT
			 
	SELECT	@ClubID = ClubID 
	FROM	ETL.GetAllXTICKETS(@XTMPTicketStart)

	-- Errore specifico (rimpiazza il codice commentato poco più sotto "-- Errore specifico", mantenendone la logica: se il ClubID è nullo, sicuramente la COUNT(*) della TMP.TicketStart sarà != 1)
    IF @ClubID IS NULL OR (SELECT COUNT(*) FROM	ETL.GetAllXTICKETS(@XTMPTicketStart)) != 1
		BEGIN
			SET @Direction = -1 -- IMPEDISCE AL RESTO DELLA STORED PROCEDURE DI PROSEGUIRE NEI CALCOLI 
			RAISERROR ('Numero ticket di partenza errato',16,1); 
		END


	-- AGGIORNAMENTO DEL BATCHID PER PROPAGAZIONE A TUTTE LE ALTRE STORED COINVOLTE NELLA CALCALL
	SET	@XTMPTicketStart = ETL.DenullXTICKETS(@XTMPTicketStart)
	SET	@XTMPTicketStart = ETL.UpdMultiFieldX(@XTMPTicketStart, 'BatchID=' + CAST(@BatchID AS varchar(10)), 'ClubID=' + CAST(@ClubID AS varchar(10))) 

    -- Tracking indietro  
    IF @Direction = 0
    BEGIN
		-- PrintingData 
		SELECT	
				@PrintingDate = printingdate
				,@MachineID = PrintingMachineID
				,@IsprintingCashDesk = ISNULL(isprintingcashdesk, 0)
				,@TicketValue = ticketvalue 
		FROM	ETL.GetAllXTICKETS(@XTMPTicketStart) 

		IF @IsprintingCashDesk = 0
			BEGIN
		
				-- Controlla se MH o ticket----
				IF @PrintingDate IS NULL 
					BEGIN
						SELECT	
								@PrintingDate = EventDate
								,@ClubID = ClubID
								,@MachineID = MhMachineID
								,@TicketValue = TicketValue 
						FROM	ETL.GetAllXTICKETS(@XTMPTicketStart)
							
						SELECT	@OffSet = OffSetMH*50 
						FROM	ETL.GetAllXCONFIG(@XConfigTable)
					END	
					

				SET		@INNERSQL = 
						N'
						SELECT	
								ServerTime
								,totalout - Lag(totalout, 1, 0) OVER (ORDER BY servertime) AS TotalOut 
								,MachineID
						FROM	[$_AGS_RawData].[#].[RawData_View]
						WHERE	(ServerTime < ''' + CONVERT(Nvarchar(26), dateadd(second,@OffSet,@PrintingDate), 126) + ''' AND ServerTime > ''' + CONVERT(Nvarchar(26), dateadd(second,-@OffSet,@PrintingDate), 126) + ''')
						AND		MachineID = ' + CAST(@MachineID AS varchar(5)) + '
						AND		TotalOut > 0
						'
				EXEC	[ETL].[ExtractRawDataFromPOMMON] 
						@ConcessionaryID = @ConcessionaryID
						,@ClubID = @ClubID
						,@INNERSQL = @INNERSQL
						,@XTMPRawData_View = @XTMPRawData_View OUTPUT

                ;WITH ctetotalout AS(
					SELECT 
							ServerTime 
                            ,TotalOut--,totalout - Lag(totalout, 1, 0) OVER (ORDER BY servertime) AS TotalOut
							,MachineID 
					FROM	ETL.GetAllXRAW(@XTMPRawData_View)
				)
				,ctetotalout2 AS(
					SELECT 
							TotalOut 
                            ,ServerTime
							,ROW_NUMBER() OVER (ORDER BY DATEDIFF(ss, @PrintingDate, ServerTime) DESC) AS rn 
                    FROM	ctetotalout 
                    WHERE	TotalOut = @TicketValue
				) 

                -- servertime più vicino al payout 
                SELECT	@ToOut = ServerTime 
                FROM	ctetotalout2 
                WHERE	rn = 1 

                -- per la sessione minore di 50 
				SET	@XTMPTicketServerTime = ETL.WriteXTST(@XTMPTicketServerTime, @ToOut, NULL, NULL, NULL, @Direction, @MachineID) 

				SET @INNERSQL = 
				'
				SET NOCOUNT ON;
				SET FMTONLY OFF;
				DECLARE	@FromServerTimeOut datetime
				SELECT	@FromServerTimeOut = MAX(ServerTime)
				FROM	[$_AGS_RawData].[#].[RawData_View]
				WHERE	TotalOut > 0
				AND		MachineID = ' + CAST(@MachineID AS varchar(5)) + '
				AND		LoginFlag = 0
				AND		ServerTime <  ''' + CONVERT(Nvarchar(26), @ToOut, 126) + '''
				IF @FromServerTimeOut IS NULL
					BEGIN
						SELECT	@FromServerTimeOut = ISNULL(MAX(ServerTime),''1900-01-01 00:00:00.000'')
						FROM	[$_AGS_RawData].[#].[RawData_View]
						WHERE	LoginFlag = 1
						AND		MachineID = ' + CAST(@MachineID AS varchar(5)) + '
						AND		ServerTime <  ''' + CONVERT(Nvarchar(26), @ToOut, 126) + '''
					END
				SELECT @FromServerTimeOut AS ServerTime
				'
				EXEC	[ETL].[ExtractRawDataFromPOMMON] 
						@ConcessionaryID = @ConcessionaryID
						,@ClubID = @ClubID
						,@INNERSQL = @INNERSQL
						,@XTMPRawData_View = @XTMPRawData_View OUTPUT

				SELECT	@FromServerTimeOut = ServerTime
				FROM	ETL.GetAllXRAW(@XTMPRawData_View) 

				SET @INNERSQL =
				'
				SELECT	
						ISNULL(MAX(ServerTime), ''2000-01-01 00:00:00.000'') AS ServerTime
				FROM	[$_AGS_RawData].[#].[RawData_View]
				WHERE	LoginFlag = 1
				AND		MachineID = ' + CAST(@MachineID AS varchar(5)) + '
				AND		servertime <  ''' + CONVERT(Nvarchar(26),  @FromServerTimeOut,126) + '''
				'
				EXEC	[ETL].[ExtractRawDataFromPOMMON] 
						@ConcessionaryID = @ConcessionaryID
						,@ClubID = @ClubID
						,@INNERSQL = @INNERSQL
						,@XTMPRawData_View = @XTMPRawData_View OUTPUT
				
				SELECT	@RestartTime = ISNULL(ServerTime, @ServerTime_FIRST)
				FROM	ETL.GetAllXRAW(@XTMPRawData_View) 

				SET @INNERSQL =
				'
				SELECT	
						ISNULL(MAX(TotalBet), 0) AS TotalBet
						,ISNULL(MAX(TotalWon), 0) AS TotalWon
						,ISNULL(MAX(WinD), 0) AS WinD
						,ISNULL(MAX(TotalBillIn), 0) AS TotalBillIn
						,ISNULL(MAX(TotalCoinIn), 0) AS TotalCoinIn
						,ISNULL(MAX(TotalTicketIn), 0) AS TotalTicketIn
						,ISNULL(MAX(TotalTicketOut), 0) AS TotalTicketOut
						,ISNULL(MAX(TotalHandPay), 0) AS TotalHandpay
						,ISNULL(MAX(TotalOut), 0) AS TotalOut
						,ISNULL(MAX(TotalIn), 0) AS	TotalIn
				FROM	[$_AGS_RawData].[#].[RawData_View]
				WHERE	(servertime BETWEEN  ''' + CONVERT(Nvarchar(26), @RestartTime, 126) + ''' AND  ''' + CONVERT(Nvarchar(26), @FromServerTimeOut,126) + ''')
				AND		MachineID = ' + CAST(@MachineID AS varchar(5)) + '
				'
				EXEC	[ETL].[ExtractRawDataFromPOMMON] 
						@ConcessionaryID = @ConcessionaryID
						,@ClubID = @ClubID
						,@INNERSQL = @INNERSQL
						,@XTMPRawData_View = @XTMPRawData_View OUTPUT

				SELECT	@XTMPCountersCork = ETL.WriteXCCK(@XTMPCountersCork, @ClubID, @MachineID, @FromServerTimeOut, @ToOut, totalbet, totalwon, wind, totalbillin, totalcoinin, totalticketin, totalticketout, totalhandpay, totalout, totalin)
				FROM	ETL.GetAllXRAW(@XTMPRawData_View) 

				IF NOT EXISTS (SELECT TOP 1 * FROM	ETL.GetAllXCCK(@XTMPCountersCork))
					RAISERROR ('Empty table [TMP].[CountersCork]',16,1);
            END 
    END 

    -- Tracking in avanti -- va preso il serverTime di IN di questo ticket 
    IF @Direction = 1 
    BEGIN
		SELECT 
				@MachineID = payoutmachineid
				,@StrMachineID = CAST(ISNULL(payoutmachineid,0) AS varchar(10))	-- PER LA CHIAMATA AD [ETL].[ExtractRawDataFromPOMMON] CHE RICHIEDE UN PARAMETRO STRINGA QUALE MACHINEID
		FROM	ETL.GetAllXTICKETS(@XTMPTicketStart) 

        IF @MachineID IS NOT NULL AND @IspaidCashdesk = 0 
            BEGIN 
				SET	@RAWDATAServerTimeStart = DATEADD(SECOND, -@OFFSETIN, @PayOutDate)
				SET	@RAWDATAServerTimeEnd = DATEADD(SECOND, @OFFSETIN, @PayOutDate)

				EXEC	[ETL].[ExtractRawDataFromPOMMON] 
						@ConcessionaryID = @ConcessionaryID
						,@ClubID = @ClubID
						,@CSVmachineID = @StrMachineID
						,@FromDate = @RAWDATAServerTimeStart
						,@ToDate = @RAWDATAServerTimeEnd
						,@XTMPRawData_View = @XTMPRawData_View OUTPUT

				-- totalout nell'offset 
				;WITH 
				ctetotalin AS
				(
					SELECT	
							servertime
							,totalin - Lag(totalin, 1, 0) OVER (ORDER BY servertime) AS TotalIn 
					FROM	ETL.GetAllXRAW(@XTMPRawData_View)
					WHERE	servertime < DATEADD(SECOND, @OFFSETIN, @PayOutDate) 
					AND		servertime > DATEADD(SECOND, -@OFFSETIN, @PayOutDate) 
					AND		machineid = @MachineID 
					AND		totalin > 0
				)
				,ctetotalin2 AS 
				(
					SELECT	
							servertime
							,totalin
							,ROW_NUMBER() OVER (ORDER BY DATEDIFF(ss, @PayOutDate, servertime) DESC) AS rn 
					FROM	ctetotalin 
					WHERE	totalin = @TicketValue
				) 
            
				-- Servertime più vicino al payout 
				SELECT	@FromServerTimeIN = ISNULL(servertime, @ServerTime_FIRST) 
				FROM	ctetotalin2 
				WHERE	rn = 1 

				-- Per la sessione minore di 50 
				SET	@XTMPTicketServerTime = ETL.WriteXTST(@XTMPTicketServerTime,@FromServerTimeIN,NULL,NULL,NULL,@Direction,NULL) 

				-- Primo OUT precedente all'IN - se non ci sono out prendo il restart 
				SELECT	@FromServerTimeOut = MAX(servertime) 
				FROM	ETL.GetAllXRAW(@XTMPRawData_View)
				WHERE	servertime < @FromServerTimeIN 
				AND		loginflag = 0 
				AND		machineid = @MachineID 
				AND		totalout > 0 

				IF @FromServerTimeOut IS NULL 
					BEGIN 
						SELECT	@FromServerTimeOut = ISNULL(MAX(servertime), @ServerTime_FIRST) 
						FROM	ETL.GetAllXRAW(@XTMPRawData_View)
						WHERE	servertime < @FromServerTimeIN 
						AND		loginflag = 1 
						AND		machineid = @MachineID 
					END 

					-- Reset/restart 
					SELECT	@RestartTime = ISNULL(MAX(servertime), @ServerTime_FIRST) 
					FROM	ETL.GetAllXRAW(@XTMPRawData_View)
					WHERE	servertime < @FromServerTimeOut 
					AND		loginflag = 1 
					AND		machineid = @MachineID 
                                     
					-- Fino al prossimo out 
					SELECT	@ToOut = ISNULL(MIN(servertime), @ServerTime_LAST) 
					FROM	ETL.GetAllXRAW(@XTMPRawData_View)
					WHERE	servertime > @FromServerTimeOut 
					AND		totalout > 0 
					AND		loginflag = 0 
					AND		machineid = @MachineID 
				
					SELECT	@XTMPCountersCork = ETL.WriteXCCK(@XTMPCountersCork, @ClubID,@MachineID,@FromServerTimeOut,@ToOut,ISNULL(MAX(totalbet), 0),ISNULL(MAX(totalwon), 0),ISNULL(MAX(wind), 0),ISNULL(MAX(totalbillin), 0),ISNULL(MAX(totalcoinin), 0),ISNULL(MAX(totalticketin), 0),ISNULL(MAX(totalticketout), 0),ISNULL(MAX(totalhandpay), 0),ISNULL(MAX(totalout), 0),ISNULL(MAX(totalin), 0))
					FROM	ETL.GetAllXRAW(@XTMPRawData_View)
					WHERE	(servertime BETWEEN @RestartTime AND @FromServerTimeOut) 
					AND		machineid = @MachineID 

					IF NOT EXISTS (SELECT TOP 1 * FROM	ETL.GetAllXCCK(@XTMPCountersCork))
						RAISERROR ('Empty table ETL.GetAllXCCK(@XTMPCountersCork)',16,1);
				END 
    END 

    -- Verifiche finali 
	EXEC ETL.WriteLog @@PROCID, 'Calcolo tappo terminato', @TicketCode, @BatchID -- Log operazione  

END TRY

BEGIN CATCH 
    SELECT
			ERROR_NUMBER() AS ErrorNumber
			,ERROR_SEVERITY() AS Severity
			,ERROR_STATE() AS ErrorState
			,ISNULL(ERROR_PROCEDURE(), ISNULL(dbo.GetProcName(@@PROCID),'*Unknown*')) AS ErrorProcedure  
			,ERROR_LINE() AS ProcedureLine
			,ERROR_MESSAGE() As ErrorMessage
END CATCH 
