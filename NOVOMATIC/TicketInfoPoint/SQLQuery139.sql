USE [TicketInfoPoint]
GO
/****** Object:  StoredProcedure [ETL].[FindCountersCork]    Script Date: 15/02/2018 12:38:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
		@ReturnCode int 
		,@XCONFIG		XML -- ex Config.Table
		,@XTKS			XML -- ex TMP.TicketStart
		,@XTST			XML -- ex TMP.TicketServerTime
		,@XCCK			XML -- ex TMP.CountersCork
		,@XRAW			XML -- ex TMP.RawData_View 

-- CARICA UN ELEMENTO NEL CONTENITORE @XCONFIG
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

EXEC	[ETL].[FindCountersCork]
		@Xconfig = @XCONFIG
		,@Direction = 0
		,@TicketCode = '309551976638606413'
		,@BatchID = 1 
		,@XTKS = @XTKS OUTPUT -- ex TMP.TicketStart
		,@XTST = @XTST OUTPUT -- ex TMP.TicketServerTime
		,@XCCK = @XCCK OUTPUT -- ex TMP.CountersCork
		,@XRAW = @XRAW OUTPUT -- ex TMP.RawData_View 

SELECT 'ConfigTable' AS TableName, * FROM ETL.GetAllXCONFIG(@XCONFIG)
SELECT 'TicketStart' AS TableName, * FROM  ETL.GetAllXTICKETS(@XTKS)
SELECT 'TicketServerTime' AS TableName, * FROM ETL.GetAllXTST(@XTST)
SELECT 'CountersCork' AS TableName, * FROM ETL.GetAllXCCK(@XCCK)
--SELECT 'RawData' AS TableName, * FROM ETL.GetAllXRAW(@XRAW)


-- DIRECTION = 1 
SET @XTKS = NULL
SET @XTST = NULL
SET @XCCK = NULL
SET @XRAW = NULL
--DECLARE
--		@ReturnCode int 
--		,@XCONFIG		XML -- ex Config.Table
--		,@XTKS			XML -- ex TMP.TicketStart
--		,@XTST			XML -- ex TMP.TicketServerTime
--		,@XCCK			XML -- ex TMP.CountersCork
--		,@XRAW			XML -- ex TMP.RawData_View 

---- CARICA UN ELEMENTO NEL CONTENITORE @XCONFIG
--SET	@XCONFIG =	ETL.WriteXCONFIG(
--					@XCONFIG
--					,7				-- ConcessionaryID
--					,'POM-MON01'	-- Position
--					,25				-- OffSetIN
--					,45				-- OffSetOut
--					,7200			-- OffSetMh
--					,50				-- MinVltEndCredit
--					,'GMatica'		-- ConcessionaryName
--					,1				-- FlagDbArchive
--					,1				-- OffsetRawData
--				) 

EXEC	[ETL].[FindCountersCork]
		@Xconfig = @XCONFIG
		,@Direction = 0
		,@TicketCode = '309551976638606413'
		,@BatchID = 1 
		,@XTKS = @XTKS OUTPUT -- ex TMP.TicketStart
		,@XTST = @XTST OUTPUT -- ex TMP.TicketServerTime
		,@XCCK = @XCCK OUTPUT -- ex TMP.CountersCork
		,@XRAW = @XRAW OUTPUT -- ex TMP.RawData_View 

SELECT 'ConfigTable' AS TableName, * FROM ETL.GetAllXCONFIG(@XCONFIG)
SELECT 'TicketStart' AS TableName, * FROM  ETL.GetAllXTICKETS(@XTKS)
SELECT 'TicketServerTime' AS TableName, * FROM ETL.GetAllXTST(@XTST)
SELECT 'CountersCork' AS TableName, * FROM ETL.GetAllXCCK(@XCCK)
--SELECT 'RawData' AS TableName, * FROM ETL.GetAllXRAW(@XRAW)

*/ 
ALTER PROC	[ETL].[FindCountersCork] 
			@Xconfig		XML -- ex Config.Table
			,@Direction		bit 
			,@TicketCode	varchar(50) 
			,@ClubID		varchar(10) = NULL 
			,@BatchID		int 
			,@XTKS			XML OUTPUT -- ex TMP.TicketStart
			,@XTST			XML OUTPUT -- ex TMP.TicketServerTime
			,@XCCK			XML OUTPUT -- ex TMP.CountersCork
			,@XRAW			XML OUTPUT -- ex TMP.RawData_View 
AS 

SET NOCOUNT ON; 

DECLARE
        @PayOutDate			datetime 
		,@RAWDATAServerTimeStart	datetime 
		,@RAWDATAServerTimeEnd		datetime 
        ,@FromServerTimeOut			datetime 
        ,@OFFSET					int 
        ,@OFFSETIN					int
        ,@FromServerTime			datetime 
        ,@FromServerTimeIN			datetime 
        ,@IspaidCashdesk			bit 
        ,@RestartTime				datetime 
        ,@ConcessionaryID			tinyint 
        ,@PrintingDate				datetime2(0) 
        ,@IsprintingCashDesk		bit
		,@FromOut					datetime = NULL 
        ,@ToOut						datetime = NULL 
        ,@MachineID					smallint 
        ,@TicketValue				int 
		,@ServerTime_FIRST			datetime = '2008-01-01 00:00:00.000' 
        ,@ServerTime_LAST			datetime = GETDATE() 

BEGIN try 
	SELECT	
			@IspaidCashdesk = 0 
			,@ISPrintingCashdesk = 0 
			,@OFFSET = offsetout * 1000
			,@OFFSETIN = offsetin * 1000
			,@ConcessionaryID = concessionaryid
	FROM	ETL.GetAllXCONFIG(@XCONFIG) 

    -- Log operazione 
	EXEC ETL.WriteLog @@PROCID, 'Calcolo tappo iniziato', @TicketCode, @BatchID -- Log operazione  

    -- Prelievo dei dati del ticket di partenza 
	EXEC	ETL.ExtractTicketsFromPIN
			@ConcessionaryID = @ConcessionaryID -- OBBLIGATORIO, DETERMINA IL CONCESSIONARIO
			,@ClubID = @ClubID	-- FACOLTATIVO, DETERMINA LA SALA
			,@TicketCode = @TicketCode -- FACOLTATIVO, ELENCO DI TICKETS (MIXATI, SIA MHx CHE NON), SEPARATI DA VIRGOLE, OPPURE TICKET SINGOLO (SIA MHx CHE NON)
			,@TicketValue = NULL 
			,@XMLTICKETS = @XTKS OUTPUT
			 
	-- PrintingData 
    SELECT	
            @ClubID = clubid 
            ,@TicketValue = ticketvalue 
			,@PrintingDate = printingdate
			,@PayOutDate = payoutdate 
            ,@IsprintingCashDesk = ISNULL(isprintingcashdesk, 0)
			,@IspaidCashdesk = ISNULL(ispaidcashdesk, 0) 
	FROM	ETL.GetAllXTICKETS(@XTKS) 

	-- Errore specifico (rimpiazza il codice commentato poco più sotto "-- Errore specifico", mantenendone la logica: se il ClubID è nullo, sicuramente la COUNT(*) della TMP.TicketStart sarà != 1)
    IF @ClubID IS NULL OR (SELECT COUNT(*) FROM	ETL.GetAllXTICKETS(@XTKS)) != 1
		BEGIN
			SET @Direction = -1 -- IMPEDISCE AL RESTO DELLA STORED PROCEDURE DI PROSEGUIRE NEI CALCOLI 
			RAISERROR ('Numero ticket di partenza errato',16,1); 
		END

    -- Tracking indietro  
    IF @Direction = 0
    BEGIN
		SELECT	@MachineID = printingmachineid
		FROM	ETL.GetAllXTICKETS(@XTKS) 

        IF @MachineID IS NOT NULL AND @IsprintingCashDesk = 0 
            BEGIN 
                -- Controlla se MH o ticket---- 
                IF @PrintingDate IS NULL 
                BEGIN 
                    SELECT 
							@PrintingDate = eventdate 
                            ,@MachineID = mhmachineid 
					FROM	ETL.GetAllXTICKETS(@XTKS) 

                    SELECT	@OFFSET = offsetmh * 500 
					FROM	ETL.GetAllXCONFIG(@XCONFIG) 
                END 

				SET	@RAWDATAServerTimeStart = DATEADD(SECOND, -@OFFSET, @PrintingDate)
				SET	@RAWDATAServerTimeEnd = DATEADD(SECOND, @OFFSET, @PrintingDate)

				EXEC	[ETL].[ExtractRawDataFromPIN] 
						@ConcessionaryID = @ConcessionaryID
						,@ClubID = @ClubID
						,@CSVmachineID = @MachineID
						,@FromDate = @RAWDATAServerTimeStart
						,@ToDate = @RAWDATAServerTimeEnd
						,@XRAW = @XRAW OUTPUT

                ;WITH 
				ctetotalout AS 
				(
					SELECT 
							servertime 
                            ,totalout - Lag(totalout, 1, 0) OVER (ORDER BY servertime) AS TotalOut 
					--FROM	ETL.GetXRAW(@XRAW, NULL,NULL,NULL,@MachineID,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
					FROM	ETL.GetAllXRAW(@XRAW)
                    WHERE	servertime < DATEADD(SECOND, @OFFSET, @PrintingDate) 
					AND		servertime > DATEADD(SECOND, -@OFFSET, @PrintingDate) 
					AND		MachineID = @MachineID
					AND		totalout > 0
				)
				,ctetotalout2 AS 
				(
					SELECT 
							totalout 
                            ,servertime
							,ROW_NUMBER() OVER (ORDER BY DATEDIFF(ss, @PrintingDate,servertime) DESC) AS rn 
                    FROM	ctetotalout 
                    WHERE	totalout = @TicketValue
				) 

                -- servertime più vicino al payout 
                SELECT	@ToOut = servertime 
                FROM	ctetotalout2 
                WHERE	rn = 1 

                -- per la sessione minore di 50 
				SET	@XTST = ETL.WriteXTST(@XTST,@ToOut,NULL,NULL,NULL,@Direction,NULL) 

				--SET @FromServerTimeOut = (
				--	SELECT Max(servertime) 
				--	FROM   [TMP].[Rawdata_view] 
				--	WHERE  totalout > 0 
				--	AND machineid = @MachineID 
				--	AND loginflag = 0 
				--	AND servertime < @ToOut
				--) 
                SELECT	@FromServerTimeOut = MAX(servertime) 
				--FROM	ETL.GetXRAW(@XRAW, NULL,NULL,NULL,@MachineID,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
				FROM	ETL.GetAllXRAW(@XRAW)
				WHERE	servertime < @ToOut  
				AND		MachineID = @MachineID
				AND		LoginFlag = 0
                AND		totalout > 0 

				--IF @FromServerTimeOut IS NULL 
				--	BEGIN 
				--		SET @FromServerTimeOut = Isnull(
				--			(
				--				SELECT	Max(servertime) 
				--				FROM	[TMP].[Rawdata_view] 
				--				WHERE	loginflag = 1 
				--				AND		machineid = @MachineID 
				--				AND		servertime < @ToOut
				--			) 
				--			,@ServerTime_FIRST
				--		) 
				--	END 

                IF @FromServerTimeOut IS NULL 
					BEGIN 
						SELECT	@FromServerTimeOut = ISNULL(MAX(servertime), @ServerTime_FIRST) 
						--FROM	ETL.GetXRAW(@XRAW, NULL,NULL,NULL,@MachineID,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
						FROM	ETL.GetAllXRAW(@XRAW)
						WHERE	loginflag = 1 
						AND		machineid = @MachineID 
						AND		servertime < @ToOut
					END 

                -- reset/restart 
                SELECT	@RestartTime = ISNULL(MAX(servertime), @ServerTime_FIRST) 
				FROM	ETL.GetXRAW(@XRAW, NULL,NULL,NULL,@MachineID,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
                WHERE	servertime < @FromServerTimeOut 

				SELECT	@XCCK = ETL.WriteXCCK(@XCCK, @ClubID,@MachineID,@FromOut,@ToOut,ISNULL(MAX(totalbet), 0),ISNULL(MAX(totalwon), 0),ISNULL(MAX(wind), 0),ISNULL(MAX(totalbillin), 0),ISNULL(MAX(totalcoinin), 0),ISNULL(MAX(totalticketin), 0),ISNULL(MAX(totalticketout), 0),ISNULL(MAX(totalhandpay), 0),ISNULL(MAX(totalout), 0),ISNULL(MAX(totalin), 0))
				--FROM	ETL.GetXRAW(@XRAW, NULL,NULL,NULL,@MachineID,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
				FROM	ETL.GetAllXRAW(@XRAW)
				WHERE	loginflag = 1 
				AND		machineid = @MachineID 
                AND		(servertime BETWEEN @RestartTime AND @FromServerTimeOut) 

				IF NOT EXISTS (SELECT TOP 1 * FROM	ETL.GetAllXCCK(@XCCK))
					RAISERROR ('Empty table [TMP].[CountersCork]',16,1);
            END 
    END 

    -- Tracking in avanti -- va preso il serverTime di IN di questo ticket 
    IF @Direction = 1 
    BEGIN
		SELECT @MachineID = payoutmachineid
		FROM	ETL.GetAllXTICKETS(@XTKS) 

        IF @MachineID IS NOT NULL AND @IspaidCashdesk = 0 
            BEGIN 
				SET	@RAWDATAServerTimeStart = DATEADD(SECOND, -@OFFSETIN, @PayOutDate)
				SET	@RAWDATAServerTimeEnd = DATEADD(SECOND, @OFFSETIN, @PayOutDate)

				EXEC	[ETL].[ExtractRawDataFromPIN] 
						@ConcessionaryID = @ConcessionaryID
						,@ClubID = @ClubID
						,@CSVmachineID = NULL
						,@FromDate = @RAWDATAServerTimeStart
						,@ToDate = @RAWDATAServerTimeEnd
						,@XRAW = @XRAW OUTPUT

				-- totalout nell'offset 
				;WITH 
				ctetotalin AS
				(
					SELECT	
							servertime
							,totalin - Lag(totalin, 1, 0) OVER (ORDER BY servertime) AS TotalIn 
					--FROM	ETL.GetXRAW(@XRAW, NULL,NULL,NULL,@MachineID,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
					FROM	ETL.GetAllXRAW(@XRAW)
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
				SET	@XTST = ETL.WriteXTST(@XTST,@FromServerTimeIN,NULL,NULL,NULL,@Direction,NULL) 

				-- Primo OUT precedente all'IN - se non ci sono out prendo il restart 
				SELECT	@FromServerTimeOut = MAX(servertime) 
				--FROM	ETL.GetXRAW(@XRAW, NULL,NULL,NULL,@MachineID,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
				FROM	ETL.GetAllXRAW(@XRAW)
				WHERE	servertime < @FromServerTimeIN 
				AND		loginflag = 0 
				AND		machineid = @MachineID 
				AND		totalout > 0 

				IF @FromServerTimeOut IS NULL 
					BEGIN 
						SELECT	@FromServerTimeOut = ISNULL(MAX(servertime), @ServerTime_FIRST) 
						--FROM	ETL.GetXRAW(@XRAW, NULL,NULL,NULL,@MachineID,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
						FROM	ETL.GetAllXRAW(@XRAW)
						WHERE	servertime < @FromServerTimeIN 
						AND		loginflag = 1 
						AND		machineid = @MachineID 
					END 

					-- Reset/restart 
					SELECT	@RestartTime = ISNULL(MAX(servertime), @ServerTime_FIRST) 
					--FROM	ETL.GetXRAW(@XRAW, NULL,NULL,NULL,@MachineID,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
					FROM	ETL.GetAllXRAW(@XRAW)
					WHERE	servertime < @FromServerTimeOut 
					AND		loginflag = 1 
					AND		machineid = @MachineID 
                                     
					-- Fino al prossimo out 
					SELECT	@ToOut = ISNULL(MIN(servertime), @ServerTime_LAST) 
					--FROM	ETL.GetXRAW(@XRAW, NULL,NULL,NULL,@MachineID,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
						FROM	ETL.GetAllXRAW(@XRAW)
					WHERE	servertime > @FromServerTimeOut 
					AND		totalout > 0 
					AND		loginflag = 0 
					AND		machineid = @MachineID 
				
					SELECT	@XCCK = ETL.WriteXCCK(@XCCK, @ClubID,@MachineID,@FromOut,@ToOut,ISNULL(MAX(totalbet), 0),ISNULL(MAX(totalwon), 0),ISNULL(MAX(wind), 0),ISNULL(MAX(totalbillin), 0),ISNULL(MAX(totalcoinin), 0),ISNULL(MAX(totalticketin), 0),ISNULL(MAX(totalticketout), 0),ISNULL(MAX(totalhandpay), 0),ISNULL(MAX(totalout), 0),ISNULL(MAX(totalin), 0))
					--FROM	ETL.GetXRAW(@XRAW, NULL,NULL,NULL,@MachineID,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
					FROM	ETL.GetAllXRAW(@XRAW)
					WHERE	(servertime BETWEEN @RestartTime AND @FromServerTimeOut) 
					AND		machineid = @MachineID 

					IF NOT EXISTS (SELECT TOP 1 * FROM	ETL.GetXCCK(@XCCK, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL))
						RAISERROR ('Empty table ETL.GetXCCK(@XCCK, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)',16,1);
				END 
    END 

    -- Verifiche finali 
	EXEC ETL.WriteLog @@PROCID, 'Calcolo tappo terminato', @TicketCode, @BatchID -- Log operazione  

END try 

-- Gestione Errore 
BEGIN catch 
    SELECT Error_message () 
END catch 
