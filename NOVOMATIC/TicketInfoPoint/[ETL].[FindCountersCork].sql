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
DECLARE @ReturnCode int 
EXEC @ReturnCode = [ETL].[FindCountersCork] @TicketCode = '91327506344382796',@Direction = 0,@BatchID = 1 
SELECT @ReturnCode ReturnCode  
*/ 
ALTER PROC	[ETL].[FindCountersCork] 
			@Direction  bit 
			,@TicketCode varchar(50) 
			,@ClubID     varchar(10) = NULL 
			,@BatchID    int 
			,@ReturnCode int = 0 output
AS 

SET NOCOUNT ON; 

DECLARE 
		@Message				varchar(1000) 
        ,@PayOutData			datetime 
        ,@FromServerTimeOut		datetime 
        ,@OFFSET				int 
        ,@OFFSETIN				int
        ,@OFFSETOUT				smallint = 3600 
        ,@ReturnMessage2		varchar(1000)
		,@ServerTimeMaxCounters	datetime 
        ,@Stringa				varchar(500) 
        ,@FromServerTime		datetime 
        ,@FromServerTimeIN		datetime 
        ,@ToServerTime			datetime 
        ,@ReturnCode2			int 
        ,@IspaidCashdesk		bit 
        ,@RestartTime			datetime 
        ,@CalcDurationSS		int 
        ,@ServerTime			datetime 
        ,@DataStart				datetime 
        ,@ConcessionaryID		tinyint 
        ,@PrintingData			datetime2(0) 
        ,@IsprintingCashDesk	bit
		,@FromOut				datetime = NULL 
        ,@ToOut					datetime = NULL 
        ,@MachineID				smallint 
        ,@Msg					varchar(1000) 
        ,@TicketValue			int 
		,@ServerTime_FIRST		datetime = '1900-01-01 00:00:00.000' 
        ,@ServerTime_Last		datetime = '2050-12-31 00:00:00.000' 
        ,@ViewString			varchar(5000)

DECLARE @TableMaxCounters TABLE( 
		totalbet       bigint 
		,totalwon       bigint 
		,wind           bigint 
		,totalbillin    bigint 
		,totalcoinin    bigint 
		,totalticketin  bigint 
		,totalticketout bigint 
		,totalhandpay   bigint 
		,totalout       bigint 
		,totalin        bigint
)		 

BEGIN try 

    ------------------------------------------------------ 
    -- Calcolo VLT       -- 
    ------------------------------------------------------ 
    -- Inizializzo 
	-- IF @TicketCode <> '8000572HPV201705180001' 
	--	TRUNCATE TABLE [TMP].[Ticketstart] 
    TRUNCATE TABLE [TMP].[Counterscork] 
    TRUNCATE TABLE [TMP].[Ticketservertime] 
	TRUNCATE TABLE [TMP].[Ticketstart]

    --SET @IspaidCashdesk = 0 
    --SET @ISPrintingCashdesk = 0 
    --SET @ServerTime = NULL 
    --SET @DataStart = Sysdatetime() 

    --SELECT @OffSet = ( offsetout * 1000 ) 
    --FROM   config.[Table] 

    --SELECT @OffSetIn = ( offsetin * 1000 ) 
    --FROM   config.[Table] 

    --SELECT @ConcessionaryID = concessionaryid 
    --FROM   config.[Table] 

	SELECT	
			@IspaidCashdesk = 0 
			,@ISPrintingCashdesk = 0 
			,@ServerTime = NULL 
			,@DataStart = Sysdatetime() 
			,@OFFSET = offsetout * 1000
			,@OFFSETIN = offsetin * 1000
			,@ConcessionaryID = concessionaryid
	FROM	[Config].[Table]


    -- Log operazione 
    --SET @Msg = 'Calcolo tappo iniziato' 

    --INSERT INTO [ETL].[Operationlog] 
    --            ([procedurename], 
    --            [operationmsg], 
    --            [operationticketcode], 
    --            [operationrequestdetailid]) 
    --SELECT @ProcedureName, 
    --        @Msg, 
    --        @TicketCode, 
    --        @BatchID 
	EXEC ETL.WriteLog @@PROCID, 'Calcolo tappo iniziato', @TicketCode, @BatchID -- Log operazione  

    -- Prendo i dati del ticket MH di partenza 
    EXEC	@ReturnCode2 = [Ticket].[Extract_pomezia] 
			@ConcessionaryID = @ConcessionaryID 
			,@TicketCode = @TicketCode 
			,@ClubID = @ClubID 
			,@ReturnMessage = @ReturnMessage2 OUTPUT 

    -- Seleziono il clubID e creo la vista 
    --SELECT	@ClubID = clubid 
    --FROM	[TMP].[Ticketstart]

	-- CODICE PRELEVATO DALL'INTERNO DEI DUE FLUSSI DI LAVORAZIONE (IF @Direction = 0/IF @Direction = 1)
	-- PrintingData 
    SELECT	
            @ClubID = clubid 
            ,@TicketValue = ticketvalue 
			,@PrintingData = printingdata
			,@PayOutData = payoutdata 
            --,@MachineID = printingmachineid	-- SPECIFICO DEL FLUSSO DI LAVORAZIONE ALL'INDIETRO (@Direction = 0)
			--,@MachineID = payoutmachineid	-- SPECIFICO DEL FLUSSO DI LAVORAZIONE IN AVANTI (@Direction = 1) 
            ,@IsprintingCashDesk = ISNULL(isprintingcashdesk, 0)
			,@IspaidCashdesk = ISNULL(ispaidcashdesk, 0) 
    FROM	[TMP].[Ticketstart] 

	-- Errore specifico (rimpiazza il codice commentato poco più sotto "-- Errore specifico", mantenendone la logica: se il ClubID è nullo, sicuramente la COUNT(*) della TMP.TicketStart sarà != 1)
    IF @ClubID IS NULL OR (SELECT COUNT(*) FROM [TMP].[Ticketstart]) != 1
		BEGIN
			SET @Direction = -1 -- IMPEDISCE AL RESTO DELLA STORED PROCEDURE DI PROSEGUIRE NEI CALCOLI 
			RAISERROR ('Numero ticket di partenza errato',16,1); 
		END
	ELSE
		BEGIN
			--SELECT @ViewString = (SELECT Object_definition ( 
			--                            Object_id(N'[Tmp].RawData_View'))) 
			SELECT @ViewString = Object_definition(Object_id(N'[Tmp].RawData_View'))

			--IF NOT @ViewString LIKE '%![' + @ClubID + '!]%' ESCAPE '!' 
			--EXEC [RAW].[Createnewviewrawid] 
			--    @ClubID = @ClubID 
			IF @ViewString NOT LIKE '%![' + @ClubID + '!]%' ESCAPE '!' 
				EXEC [RAW].[Createnewviewrawid] @ClubID 
		END

    ---- Errore specifico 
    --IF (SELECT Count(*) 
    --    FROM   [TMP].[Ticketstart]) <> 1 
    --BEGIN 
    --    SET @Msg = 'Numero ticket di partenza errato' 

    --    RAISERROR (@Msg,16,1); 
    --END 

    -- Tracking indietro  
    IF @Direction = 0
    BEGIN
		-- CODICE SPOSTATO SOPRA 
        ---- PrintingData 
        --SELECT	@PrintingData = [printingdata], 
        --        @ClubID = clubid, 
        --        @MachineID = printingmachineid, 
        --        @IsprintingCashDesk = Isnull(isprintingcashdesk, 0), 
        --        @TicketValue = ticketvalue 
        --FROM   [TMP].[Ticketstart] 
		SELECT @MachineID = printingmachineid -- SPECIFICO DEL FLUSSO DI LAVORAZIONE ALL'INDIETRO (@Direction = 0)
		FROM   [TMP].[Ticketstart]

        IF @MachineID IS NOT NULL AND @IsprintingCashDesk = 0 
            BEGIN 
                -- Controlla se MH o ticket---- 
                IF @PrintingData IS NULL 
                BEGIN 
                    SELECT 
							@PrintingData = eventdate 
                            ,@MachineID = mhmachineid 
                            --,@ClubID = clubid -- RIDONDANTE, GIA' PRELEVATO IN PRECEDENZA
                            --,@TicketValue = ticketvalue -- RIDONDANTE, GIA' PRELEVATO IN PRECEDENZA 
                    FROM   [TMP].[Ticketstart] 

                    SELECT @OffSet = offsetmh * 500 
                    FROM   [Config].[Table] 
                END 

                ;WITH 
				ctetotalout AS 
				(
					SELECT 
							servertime 
                            ,totalout - Lag(totalout, 1, 0) OVER (ORDER BY servertime) AS TotalOut 
					FROM	[TMP].[Rawdata_view] 
                    WHERE	servertime < Dateadd(second, @OffSet, @PrintingData) 
					AND		servertime > Dateadd(second, -@OffSet, @PrintingData) 
					AND		machineid = @MachineID 
					AND		totalout > 0
				)
				,ctetotalout2 AS 
				(
					SELECT 
							totalout 
                            ,servertime
							,Row_number() OVER (ORDER BY Datediff(ss, @PrintingData,servertime) DESC) AS rn 
                    FROM	ctetotalout 
                    WHERE	totalout = @TicketValue
				) 

                -- servertime più vicino al payout 
                SELECT	@ToOut = servertime 
                FROM	ctetotalout2 
                WHERE	rn = 1 

                -- per la sessione minore di 50 
                INSERT	[TMP].[Ticketservertime] ([servertime],direction) 
                SELECT	@ToOut, @Direction 

                --SET @FromServerTimeOut = (SELECT Max(servertime) 
                --                        FROM   [TMP].[Rawdata_view] 
                --                        WHERE  totalout > 0 
                --                                AND machineid = 
                --                                    @MachineID 
                --                                AND loginflag = 0 
                --                                AND servertime < @ToOut) 
                SELECT	@FromServerTimeOut = MAX(servertime) 
                FROM	[TMP].[Rawdata_view] 
				WHERE	loginflag = 0 
                AND		machineid = @MachineID 
                AND		servertime < @ToOut 
                AND		totalout > 0 

                IF @FromServerTimeOut IS NULL 
					BEGIN 
						--SET @FromServerTimeOut = Isnull( 
						--(SELECT Max(servertime) 
						--	FROM   [TMP].[Rawdata_view] 
						--	WHERE  loginflag = 1 
						--		AND machineid = 
						--			@MachineID 
						--		AND servertime < 
						--			@ToOut) 
						--							, 
						--							@ServerTime_FIRST) 
						SELECT	@FromServerTimeOut = ISNULL(MAX(servertime),@ServerTime_FIRST) 
						FROM	[TMP].[Rawdata_view] 
						WHERE	loginflag = 1 
						AND		machineid = @MachineID 
						AND		servertime < @ToOut
					END 

                -- reset/restart 
                --SET @RestartTime = Isnull((SELECT Max(servertime) 
                --                            FROM   [TMP].[Rawdata_view] 
                --                            WHERE  loginflag = 1 
                --                                AND machineid = 
                --                                    @MachineID 
                --                                AND servertime < 
                --                                    @FromServerTimeOut) 
                --                    , 
                --                    @ServerTime_FIRST) 
                SELECT	@RestartTime = ISNULL(MAX(servertime), @ServerTime_FIRST) 
                FROM	[TMP].[Rawdata_view] 
                WHERE	loginflag = 1 
				AND		machineid = @MachineID 
				AND		servertime < @FromServerTimeOut 

                -- calcolo contatori 
                --INSERT INTO @TableMaxCounters 
                --            (totalbet, 
                --            totalwon, 
                --            wind, 
                --            totalbillin, 
                --            totalcoinin, 
                --            totalticketin, 
                --            totalticketout, 
                --            totalhandpay, 
                --            totalout, 
                --            totalin) 
                --SELECT Isnull(Max(totalbet), 0), 
                --        Isnull(Max(totalwon), 0), 
                --        Isnull(Max(wind), 0), 
                --        Isnull(Max(totalbillin), 0), 
                --        Isnull(Max(totalcoinin), 0), 
                --        Isnull(Max(totalticketin), 0), 
                --        Isnull(Max(totalticketout), 0), 
                --        Isnull(Max(totalhandpay), 0), 
                --        Isnull(Max(totalout), 0), 
                --        Isnull(Max(totalin), 0) 
                --FROM   [TMP].[Rawdata_view] 
                --WHERE  servertime BETWEEN 
                --        @RestartTime AND @FromServerTimeOut 
                --        AND machineid = @MachineID 
                INSERT	@TableMaxCounters(totalbet,totalwon,wind,totalbillin,totalcoinin,totalticketin,totalticketout,totalhandpay,totalout,totalin) 
                SELECT 	ISNULL(MAX(totalbet), 0) ,ISNULL(MAX(totalwon), 0) ,ISNULL(MAX(wind), 0) ,ISNULL(MAX(totalbillin), 0) ,ISNULL(MAX(totalcoinin), 0) ,ISNULL(MAX(totalticketin), 0) ,ISNULL(MAX(totalticketout), 0) ,ISNULL(MAX(totalhandpay), 0) ,ISNULL(MAX(totalout), 0) ,ISNULL(MAX(totalin), 0) 
                FROM	[TMP].[Rawdata_view] 
                WHERE	(servertime BETWEEN @RestartTime AND @FromServerTimeOut) 
				AND		machineid = @MachineID 

                --Aggiorno i contatori 
                --INSERT [TMP].[Counterscork] 
                --        (clubid, 
                --        machineid, 
                --        fromout, 
                --        toout, 
                --        totalbet, 
                --        totalwon, 
                --        wind, 
                --        totalbillin, 
                --        totalcoinin, 
                --        totalticketin, 
                --        totalticketout, 
                --        totalhandpay, 
                --        totalout, 
                --        totalin) 
                --SELECT @ClubID, 
                --        @MachineID, 
                --        @FromServerTimeOut, 
                --        @ToOut, 
                --        TMCN.totalbet, 
                --        TMCN.totalwon, 
                --        TMCN.wind, 
                --        TMCN.totalbillin, 
                --        TMCN.totalcoinin, 
                --        TMCN.totalticketin, 
                --        TMCN.totalticketout, 
                --        TMCN.totalhandpay, 
                --        TMCN.totalout, 
                --        TMCN.totalin 
                --FROM   @TableMaxCounters AS TMCN 
                INSERT	[TMP].[Counterscork](clubid,machineid,fromout,toout,totalbet,totalwon,wind,totalbillin,totalcoinin,totalticketin,totalticketout,totalhandpay,totalout,totalin)
                SELECT	@ClubID,@MachineID,@FromServerTimeOut,@ToOut,TMCN.totalbet,TMCN.totalwon,TMCN.wind,TMCN.totalbillin,TMCN.totalcoinin,TMCN.totalticketin,TMCN.totalticketout,TMCN.totalhandpay,TMCN.totalout,TMCN.totalin 
                FROM	@TableMaxCounters AS TMCN 

                -- Errore specifico 
                --IF NOT EXISTS (SELECT * 
                --                FROM   [TMP].[Counterscork]) 
                --BEGIN 
                --    SET @Msg = 'Empty table [TMP].[CountersCork]' 

                --    RAISERROR (@Msg,16,1); 
                --END 
                IF NOT EXISTS (SELECT * FROM [TMP].[Counterscork]) 
                    RAISERROR ('Empty table [TMP].[CountersCork]',16,1); 

            END 
        ELSE 
            SET @ReturnCode = 1 
    END 

    -- Tracking in avanti -- va preso il serverTime di IN di questo ticket 
    IF @Direction = 1 
    BEGIN
		-- CODICE SPOSTATO SOPRA 
        ---- date di inizio e fine 
        --SELECT @PayOutData = [payoutdata], 
        --        @MachineID = payoutmachineid, 
        --        @TicketValue = ticketvalue, 
        --        @IspaidCashdesk = Isnull(ispaidcashdesk, 0) 
        --FROM   [TMP].[Ticketstart] 
		SELECT @MachineID = payoutmachineid	-- SPECIFICO DEL FLUSSO DI LAVORAZIONE IN AVANTI (@Direction = 1)
		FROM   [TMP].[Ticketstart]

        IF @MachineID IS NOT NULL AND @IspaidCashdesk = 0 
            BEGIN 
            -- totalout nell'offset 
            ;WITH 
			ctetotalin AS
			(
				SELECT	
						servertime
						,totalin - Lag(totalin, 1, 0) OVER (ORDER BY servertime) AS TotalIn 
				FROM	[TMP].[Rawdata_view] 
                WHERE	servertime < Dateadd(second, @OffSetIN, @PayOutData) 
				AND		servertime > Dateadd(second, -@OffSetIN, @PayOutData) 
                AND		machineid = @MachineID 
                AND		totalin > 0
			)
			,ctetotalin2 AS 
			(
				SELECT	
						servertime
						,totalin
						,Row_number() OVER (ORDER BY Datediff(ss, @PayOutData, servertime) DESC) AS rn 
                FROM	ctetotalin 
                WHERE	totalin = @TicketValue
			) 
            
			-- servertime più vicino al payout 
            SELECT	@FromServerTimeIN = servertime 
            FROM	ctetotalin2 
            WHERE	rn = 1 

            SET @FromServerTimeIN = ISNULL(@FromServerTimeIN, @ServerTime_FIRST) 

            -- per la sessione minore di 50 
            INSERT	[TMP].[Ticketservertime](servertime,direction) 
            SELECT	@FromServerTimeIN, @Direction 

            -- Primo out precedente all'IN - se non ci sono out prendoil restart 
            --SET @FromServerTimeOut = (SELECT Max(servertime) 
            --                        FROM   [TMP].[Rawdata_view] 
            --                        WHERE  totalout > 0 
            --                                AND machineid = 
            --                                    @MachineID 
            --                                AND loginflag = 0 
            --                                AND servertime < 
            --                                    @FromServerTimeIN) 
            SELECT	@FromServerTimeOut = MAX(servertime) 
            FROM	[TMP].[Rawdata_view] 
			WHERE	loginflag = 0 
			AND		machineid = @MachineID 
			AND		servertime < @FromServerTimeIN 
			AND		totalout > 0 

            IF @FromServerTimeOut IS NULL 
				BEGIN 
					--SET @FromServerTimeOut = Isnull( 
					--(SELECT Max(servertime) 
					--	FROM   [TMP].[Rawdata_view] 
					--	WHERE  loginflag = 1 
					--		AND machineid = 
					--			@MachineID 
					--		AND servertime < 
					--			@FromServerTimeIN 
					--), 
					--							@ServerTime_FIRST) 
					SELECT	@FromServerTimeOut = ISNULL(MAX(servertime), @ServerTime_FIRST) 
					FROM	[TMP].[Rawdata_view] 
					WHERE	loginflag = 1 
					AND		machineid = @MachineID 
					AND		servertime < @FromServerTimeIN 
				END 

                -- reset/restart 
                --SET @RestartTime = Isnull((SELECT Max(servertime) 
                --                            FROM   [TMP].[Rawdata_view] 
                --                            WHERE  loginflag = 1 
                --                                AND machineid = 
                --                                    @MachineID 
                --                                AND servertime < 
                --                                    @FromServerTimeOut) 
                --                    , 
                --                    @ServerTime_FIRST) 
                SELECT	@RestartTime = ISNULL(MAX(servertime), @ServerTime_FIRST) 
				FROM	[TMP].[Rawdata_view] 
				WHERE	loginflag = 1 
				AND		machineid = @MachineID 
				AND		servertime < @FromServerTimeOut
                                     
				-- fino al prossimo out 
                --SET @ToOut= Isnull((SELECT Min(servertime) 
                --                    FROM   [TMP].Rawdata_view 
                --                    WHERE  totalout > 0 
                --                            AND machineid = @MachineID 
                --                            AND loginflag = 0 
                --                            AND servertime > 
                --                                @FromServerTimeOut), 
                --            @ServerTime_Last) 
                SELECT	@ToOut = ISNULL(MIN(servertime), @ServerTime_Last) 
				FROM	[TMP].Rawdata_view 
				WHERE	loginflag = 0 
				AND		machineid = @MachineID 
				AND		servertime > @FromServerTimeOut 
				AND		totalout > 0 

                -- calcolo contatori 
                --INSERT INTO @TableMaxCounters 
                --            (totalbet, 
                --            totalwon, 
                --            wind, 
                --            totalbillin, 
                --            totalcoinin, 
                --            totalticketin, 
                --            totalticketout, 
                --            totalhandpay, 
                --            totalout, 
                --            totalin) 
                --SELECT Isnull(Max(totalbet), 0), 
                --        Isnull(Max(totalwon), 0), 
                --        Isnull(Max(wind), 0), 
                --        Isnull(Max(totalbillin), 0), 
                --        Isnull(Max(totalcoinin), 0), 
                --        Isnull(Max(totalticketin), 0), 
                --        Isnull(Max(totalticketout), 0), 
                --        Isnull(Max(totalhandpay), 0), 
                --        Isnull(Max(totalout), 0), 
                --        Isnull(Max(totalin), 0) 
                --FROM   [TMP].[Rawdata_view] 
                --WHERE  servertime BETWEEN 
                --        @RestartTime AND @FromServerTimeOut 
                --        AND machineid = @MachineID 
                INSERT	@TableMaxCounters(totalbet,totalwon,wind,totalbillin,totalcoinin,totalticketin,totalticketout,totalhandpay,totalout,totalin) 
                SELECT	ISNULL(MAX(totalbet), 0),ISNULL(MAX(totalwon), 0),ISNULL(MAX(wind), 0),ISNULL(MAX(totalbillin), 0),ISNULL(MAX(totalcoinin), 0),ISNULL(MAX(totalticketin), 0),ISNULL(MAX(totalticketout), 0),ISNULL(MAX(totalhandpay), 0),ISNULL(MAX(totalout), 0),ISNULL(MAX(totalin), 0) 
                FROM	[TMP].[Rawdata_view] 
                WHERE	(servertime BETWEEN @RestartTime AND @FromServerTimeOut)
				AND		machineid = @MachineID 

                --Aggiorno i contatori 
                --INSERT [TMP].[Counterscork] 
                --        (clubid, 
                --        machineid, 
                --        fromout, 
                --        toout, 
                --        totalbet, 
                --        totalwon, 
                --        wind, 
                --        totalbillin, 
                --        totalcoinin, 
                --        totalticketin, 
                --        totalticketout, 
                --        totalhandpay, 
                --        totalout, 
                --        totalin) 
                --SELECT @ClubID, 
                --        @MachineID, 
                --        @FromServerTimeOut, 
                --        @ToOut, 
                --        TMCN.totalbet, 
                --        TMCN.totalwon, 
                --        TMCN.wind, 
                --        TMCN.totalbillin, 
                --        TMCN.totalcoinin, 
                --        TMCN.totalticketin, 
                --        TMCN.totalticketout, 
                --        TMCN.totalhandpay, 
                --        TMCN.totalout, 
                --        TMCN.totalin 
                --FROM   @TableMaxCounters AS TMCN 
                INSERT	[TMP].[Counterscork](clubid,machineid,fromout,toout,totalbet,totalwon,wind,totalbillin,totalcoinin,totalticketin,totalticketout,totalhandpay,totalout,totalin)
                SELECT	@ClubID,@MachineID,@FromServerTimeOut,@ToOut,TMCN.totalbet,TMCN.totalwon,TMCN.wind,TMCN.totalbillin,TMCN.totalcoinin,TMCN.totalticketin,TMCN.totalticketout,TMCN.totalhandpay,TMCN.totalout,TMCN.totalin 
                FROM	@TableMaxCounters AS TMCN 

                -- Errore specifico 
                --IF NOT EXISTS (SELECT * 
                --                FROM   [TMP].[Counterscork]) 
                --BEGIN 
                --    SET @Msg = 'Empty table [TMP].[CountersCork]' 

                --    RAISERROR (@Msg,16,1); 
                --END 
                IF NOT EXISTS (SELECT * FROM [TMP].[Counterscork]) 
					RAISERROR ('Empty table [TMP].[CountersCork]',16,1); 
            END 
        ELSE 
            SET @ReturnCode = 1 
    END 

    -- Verifiche finali 
    --SET @Msg = 'Calcolo tappo terminato' 

    --INSERT INTO [ETL].[Operationlog] 
    --            ([procedurename], 
    --            [operationmsg], 
    --            [operationticketcode], 
    --            [operationrequestdetailid]) 
    --SELECT @ProcedureName, 
    --        @Msg, 
    --        @TicketCode, 
    --        @BatchID 
	EXEC ETL.WriteLog @@PROCID, 'Calcolo tappo terminato', @TicketCode, @BatchID -- Log operazione  

END try 

-- Gestione Errore 
BEGIN catch 
    SELECT Error_message () 

    EXECUTE [ERR].[Usplogerror] 
    @ErrorTicket = @TicketCode, 
    @ErrorRequestDetailID = @BatchID 

    SET @ReturnCode = -1; 
END catch 

RETURN @ReturnCode 
