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

    --Prendo i dati del ticket MH di partenza 
    EXEC @ReturnCode2 = [Ticket].[Extract_pomezia] 
    @ConcessionaryID = @ConcessionaryID, 
    @TicketCode = @TicketCode, 
    @ClubID = @ClubID, 
    @ReturnMessage = @ReturnMessage2 output 

    --SELECT @ReturnCode ReturnCode, @ReturnMessage ReturnMessage  
    -- Selezioni il clubID e creo la vista 
    SELECT @ClubID = clubid 
    FROM   [TMP].[Ticketstart] 

    SELECT @ViewString = (SELECT Object_definition ( 
                                Object_id(N'[Tmp].RawData_View'))) 

    IF NOT @ViewString LIKE '%![' + @ClubID + '!]%' ESCAPE '!' 
    EXEC [RAW].[Createnewviewrawid] 
        @ClubID = @ClubID 

    -- Errore specifico 
    IF (SELECT Count(*) 
        FROM   [TMP].[Ticketstart]) <> 1 
    BEGIN 
        SET @Msg = 'Numero ticket di partenza errato' 

        RAISERROR (@Msg,16,1); 
    END 

    -- Tracking indietro  
    IF @Direction = 0 
    BEGIN 
        -- PrintingData 
        SELECT @PrintingData = [printingdata], 
                @ClubID = clubid, 
                @MachineID = printingmachineid, 
                @IsprintingCashDesk = Isnull(isprintingcashdesk, 0), 
                @TicketValue = ticketvalue 
        FROM   [TMP].[Ticketstart] 

        IF @IsprintingCashDesk = 0 
            BEGIN 
                -- Controlla se MH o ticket---- 
                IF @PrintingData IS NULL 
                BEGIN 
                    SELECT @PrintingData = eventdate, 
                            @ClubID = clubid, 
                            @MachineID = mhmachineid, 
                            @TicketValue = ticketvalue 
                    FROM   [TMP].[Ticketstart] 

                    SELECT @OffSet = offsetmh * 500 
                    FROM   config.[Table] 
                END 
                --creo indici 
                --EXEC [Raw].[CreateIndex] @Clubid, @PrintingData 
                -- totalout nell'offset 
                ; 

                WITH ctetotalout 
                    AS (SELECT servertime, 
                                totalout - Lag(totalout, 1, 0) 
                                            OVER ( 
                                                ORDER BY servertime) AS 
                                TotalOut 
                        FROM   [TMP].[Rawdata_view] 
                        WHERE  servertime < Dateadd(second, @OffSet, 
                                            @PrintingData) 
                                AND servertime > Dateadd(second, -@OffSet, 
                                                @PrintingData) 
                                AND machineid = @MachineID 
                                AND totalout > 0), 
                    ctetotalout2 
                    AS (SELECT totalout, 
                                servertime, 
                                Row_number() 
                                OVER ( 
                                    ORDER BY Datediff(ss, @PrintingData, 
                                servertime) 
                                DESC) 
                                rn 
                        FROM   ctetotalout 
                        WHERE  totalout = @TicketValue) 
                -- servertime più vicino al payout 
                -- SELECT * FROM  CteTotalOut2  
                SELECT @ToOut = servertime 
                FROM   ctetotalout2 
                WHERE  rn = 1 

                -- per la sessione minore di 50 
                INSERT INTO [TMP].[Ticketservertime] 
                            ([servertime], 
                            direction) 
                SELECT @ToOut, 
                        @Direction 

                SET @FromServerTimeOut = (SELECT Max(servertime) 
                                        FROM   [TMP].[Rawdata_view] 
                                        WHERE  totalout > 0 
                                                AND machineid = 
                                                    @MachineID 
                                                AND loginflag = 0 
                                                AND servertime < @ToOut) 

                IF @FromServerTimeOut IS NULL 
                BEGIN 
                    SET @FromServerTimeOut = Isnull( 
                    (SELECT Max(servertime) 
                        FROM   [TMP].[Rawdata_view] 
                        WHERE  loginflag = 1 
                            AND machineid = 
                                @MachineID 
                            AND servertime < 
                                @ToOut) 
                                                , 
                                                @ServerTime_FIRST) 
                END 

                -- reset/restart 
                SET @RestartTime = Isnull((SELECT Max(servertime) 
                                            FROM   [TMP].[Rawdata_view] 
                                            WHERE  loginflag = 1 
                                                AND machineid = 
                                                    @MachineID 
                                                AND servertime < 
                                                    @FromServerTimeOut) 
                                    , 
                                    @ServerTime_FIRST) 

                -- calcolo contatori 
                INSERT INTO @TableMaxCounters 
                            (totalbet, 
                            totalwon, 
                            wind, 
                            totalbillin, 
                            totalcoinin, 
                            totalticketin, 
                            totalticketout, 
                            totalhandpay, 
                            totalout, 
                            totalin) 
                SELECT Isnull(Max(totalbet), 0), 
                        Isnull(Max(totalwon), 0), 
                        Isnull(Max(wind), 0), 
                        Isnull(Max(totalbillin), 0), 
                        Isnull(Max(totalcoinin), 0), 
                        Isnull(Max(totalticketin), 0), 
                        Isnull(Max(totalticketout), 0), 
                        Isnull(Max(totalhandpay), 0), 
                        Isnull(Max(totalout), 0), 
                        Isnull(Max(totalin), 0) 
                FROM   [TMP].[Rawdata_view] 
                WHERE  servertime BETWEEN 
                        @RestartTime AND @FromServerTimeOut 
                        AND machineid = @MachineID 

                --Aggiorno i contatori 
                INSERT [TMP].[Counterscork] 
                        (clubid, 
                        machineid, 
                        fromout, 
                        toout, 
                        totalbet, 
                        totalwon, 
                        wind, 
                        totalbillin, 
                        totalcoinin, 
                        totalticketin, 
                        totalticketout, 
                        totalhandpay, 
                        totalout, 
                        totalin) 
                SELECT @ClubID, 
                        @MachineID, 
                        @FromServerTimeOut, 
                        @ToOut, 
                        TMCN.totalbet, 
                        TMCN.totalwon, 
                        TMCN.wind, 
                        TMCN.totalbillin, 
                        TMCN.totalcoinin, 
                        TMCN.totalticketin, 
                        TMCN.totalticketout, 
                        TMCN.totalhandpay, 
                        TMCN.totalout, 
                        TMCN.totalin 
                FROM   @TableMaxCounters AS TMCN 

                -- Errore specifico 
                IF NOT EXISTS (SELECT * 
                                FROM   [TMP].[Counterscork]) 
                BEGIN 
                    SET @Msg = 'Empty table [TMP].[CountersCork]' 

                    RAISERROR (@Msg,16,1); 
                END 
            END 
        ELSE 
            SET @ReturnCode = 1 
    --SELECT @FromServerTimeOut,@ToOut 
    END 

    -- Tracking in avanti -- va preso il serverTime di IN di questo ticket 
    IF @Direction = 1 
    BEGIN 
        -- date di inizio e fine 
        SELECT @PayOutData = [payoutdata], 
                @MachineID = payoutmachineid, 
                @TicketValue = ticketvalue, 
                @IspaidCashdesk = Isnull(ispaidcashdesk, 0) 
        FROM   [TMP].[Ticketstart] 

        IF @MachineID IS NOT NULL 
            AND @IspaidCashdesk = 0 
            BEGIN 
            --creo indici 
            --EXEC [Raw].[CreateIndex] @Clubid, @PayOutData 
            -- totalout nell'offset 
            ; 
                WITH ctetotalin 
                    AS (SELECT servertime, 
                                totalin - Lag(totalin, 1, 0) 
                                            OVER ( 
                                            ORDER BY servertime) AS 
                                TotalIn 
                        FROM   [TMP].[Rawdata_view] 
                        WHERE  servertime < Dateadd(second, @OffSetIN, 
                                            @PayOutData) 
                                AND servertime > Dateadd(second, 
                                                -@OffSetIN, 
                                                @PayOutData) 
                                AND machineid = @MachineID 
                                AND totalin > 0), 
                    ctetotalin2 
                    AS (SELECT totalin, 
                                servertime, 
                                Row_number() 
                                OVER ( 
                                    ORDER BY Datediff(ss, @PayOutData, 
                                servertime) 
                                DESC) 
                                rn 
                        FROM   ctetotalin 
                        WHERE  totalin = @TicketValue) 
                -- servertime più vicino al payout 
                SELECT @FromServerTimeIN = servertime 
                FROM   ctetotalin2 
                WHERE  rn = 1 

                SET @FromServerTimeIN = Isnull(@FromServerTimeIN, 
                                        @ServerTime_FIRST) 

                -- per la sessione minore di 50 
                INSERT INTO [TMP].[Ticketservertime] 
                            ([servertime], 
                            direction) 
                SELECT @FromServerTimeIN, 
                        @Direction 

                -- Primo out precedente all'IN - se non ci sono out prendoil restart 
                SET @FromServerTimeOut = (SELECT Max(servertime) 
                                        FROM   [TMP].[Rawdata_view] 
                                        WHERE  totalout > 0 
                                                AND machineid = 
                                                    @MachineID 
                                                AND loginflag = 0 
                                                AND servertime < 
                                                    @FromServerTimeIN) 

                IF @FromServerTimeOut IS NULL 
                BEGIN 
                    SET @FromServerTimeOut = Isnull( 
                    (SELECT Max(servertime) 
                        FROM   [TMP].[Rawdata_view] 
                        WHERE  loginflag = 1 
                            AND machineid = 
                                @MachineID 
                            AND servertime < 
                                @FromServerTimeIN 
                    ), 
                                                @ServerTime_FIRST) 
                END 

                -- reset/restart 
                SET @RestartTime = Isnull((SELECT Max(servertime) 
                                            FROM   [TMP].[Rawdata_view] 
                                            WHERE  loginflag = 1 
                                                AND machineid = 
                                                    @MachineID 
                                                AND servertime < 
                                                    @FromServerTimeOut) 
                                    , 
                                    @ServerTime_FIRST) 
                -- fino al prossimo out 
                SET @ToOut= Isnull((SELECT Min(servertime) 
                                    FROM   [TMP].Rawdata_view 
                                    WHERE  totalout > 0 
                                            AND machineid = @MachineID 
                                            AND loginflag = 0 
                                            AND servertime > 
                                                @FromServerTimeOut), 
                            @ServerTime_Last) 

                --SELECT @FromServerTimeIN,@RestartTime,@FromServerTimeOut,@ToOut 
                -- calcolo contatori 
                INSERT INTO @TableMaxCounters 
                            (totalbet, 
                            totalwon, 
                            wind, 
                            totalbillin, 
                            totalcoinin, 
                            totalticketin, 
                            totalticketout, 
                            totalhandpay, 
                            totalout, 
                            totalin) 
                SELECT Isnull(Max(totalbet), 0), 
                        Isnull(Max(totalwon), 0), 
                        Isnull(Max(wind), 0), 
                        Isnull(Max(totalbillin), 0), 
                        Isnull(Max(totalcoinin), 0), 
                        Isnull(Max(totalticketin), 0), 
                        Isnull(Max(totalticketout), 0), 
                        Isnull(Max(totalhandpay), 0), 
                        Isnull(Max(totalout), 0), 
                        Isnull(Max(totalin), 0) 
                FROM   [TMP].[Rawdata_view] 
                WHERE  servertime BETWEEN 
                        @RestartTime AND @FromServerTimeOut 
                        AND machineid = @MachineID 

                --Aggiorno i contatori 
                INSERT [TMP].[Counterscork] 
                        (clubid, 
                        machineid, 
                        fromout, 
                        toout, 
                        totalbet, 
                        totalwon, 
                        wind, 
                        totalbillin, 
                        totalcoinin, 
                        totalticketin, 
                        totalticketout, 
                        totalhandpay, 
                        totalout, 
                        totalin) 
                SELECT @ClubID, 
                        @MachineID, 
                        @FromServerTimeOut, 
                        @ToOut, 
                        TMCN.totalbet, 
                        TMCN.totalwon, 
                        TMCN.wind, 
                        TMCN.totalbillin, 
                        TMCN.totalcoinin, 
                        TMCN.totalticketin, 
                        TMCN.totalticketout, 
                        TMCN.totalhandpay, 
                        TMCN.totalout, 
                        TMCN.totalin 
                FROM   @TableMaxCounters AS TMCN 

                -- Errore specifico 
                IF NOT EXISTS (SELECT * 
                                FROM   [TMP].[Counterscork]) 
                BEGIN 
                    SET @Msg = 'Empty table [TMP].[CountersCork]' 

                    RAISERROR (@Msg,16,1); 
                END 
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
