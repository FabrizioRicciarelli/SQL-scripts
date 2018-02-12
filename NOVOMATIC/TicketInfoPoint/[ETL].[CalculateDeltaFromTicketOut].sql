USE [TicketInfoPoint]
GO
/****** Object:  StoredProcedure [ETL].[CalculateDeltaFromTicketOut]    Script Date: 12/02/2018 15:38:55 ******/
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
Description.........: Calcola i Delta in runtime da Out a Out - Versione in memoria (nessuna tabella fisica coinvolta) 

Note 
- Use [Tab size] = 3 and [Indent size] 3 (Insert spaces)
 
------------------ 
-- Parameters   -- 
------------------ 

------------------ 
-- Call Example -- 
------------------ 
DECLARE @ReturnCode int 
EXEC @ReturnCode =  [RAW].[CalculateDeltaFromTicketOut] 
SELECT @ReturnCode ReturnCode 
*/ 
ALTER PROC	[ETL].[CalculateDeltaFromTicketOut] 
			@XCONFIG	XML  -- ex Config.Table
			,@XTKS		XML	-- ex [TMP].[TicketStart]
			,@XCCK		XML -- ex TMP.CountersCork
			,@XRAW		XML OUTPUT -- ex TMP.RawData_View 
AS
 
SET nocount ON; 

BEGIN TRY 

	DECLARE @TABLEMAXCOUNTERS TABLE( 
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
       
    DECLARE 
			@ConcessionaryID			tinyint
			--,@RAWDATAServerTimeStart	datetime 
			--,@RAWDATAServerTimeEnd		datetime 
			,@FromServerTime			datetime 
			,@ToServerTime				datetime 
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
			 
    -------------------- 
    -- Inizializzazione 
    -------------------- 
	SELECT	@ConcessionaryID = ConcessionaryID 
			,@VltMinSession = minvltendcredit
	FROM	ETL.GetXCONFIG(@XCONFIG, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
	 
    SELECT	
			@MachineID = machineid 
			,@ClubID = clubid 
            ,@FromServerTime = fromout
			,@ToServerTime = toout
	FROM	ETL.GetXCCK(@XCCK, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)

	SELECT	@TicketCode= ticketcode  
			,@BatchID =   batchid 
	FROM	ETL.GetXTICKETS(@XTKS, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) 

	EXEC	ETL.ExtractVLT 
			@ConcessionaryID = @ConcessionaryID
			,@ClubID = @ClubID
			,@XVLT = @XVLT OUTPUT

	SELECT	@GD = Machine
			,@AamsMachineCode = aamsmachinecode 
			,@UnivocalLocationCode = univocallocationcode
	FROM	ETL.GetXVLT(@XVLT, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
	
    
	SET @ServertimePre = NULL 

    -- Log operazione 
	EXEC ETL.WriteLog @@PROCID, 'Calcolo delta iniziato', @TicketCode, @BatchID -- Log operazione  
	 
    -- pulisco 
    DELETE 
    FROM   @TableMaxCounters; 
       
    DELETE 
    FROM   [TMP].[Delta] 
    
	-- Calcolo dall' ultimo totalout presente nel tappo 
 --   SELECT @FromServerTime = fromout 
 --   FROM   [TMP].[CountersCork] 
 --   WHERE  clubid = @ClubID 
 --   AND    machineid = @MachineID 
    
	--SELECT @ToServerTime = toout 
 --   FROM   [TMP].[CountersCork] 
 --   WHERE  clubid = @ClubID 
 --   AND    machineid = @MachineID 
    
	------------------------------------------------------- 
    -- Valori dei contatori di partenza 
    ------------------------------------------------------- 
    INSERT INTO @TableMaxCounters 
                ( 
                            totalbet, 
                            totalwon, 
                            wind, 
                            totalbillin , 
                            totalcoinin , 
                            totalticketin , 
                            totalticketout , 
                            totalhandpay, 
                            totalout, 
                            totalin 
                ) 
    SELECT
			totalbet, 
            totalwon, 
            wind, 
            totalbillin , 
            totalcoinin , 
            totalticketin , 
            totalticketout , 
            totalhandpay, 
            totalout, 
            totalin 
    --FROM   [TMP].[CountersCork] 
    --WHERE  clubid = @ClubID 
    --AND    machineid = @MachineID 
	FROM	ETL.GetXCCK(@XCCK, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)

    -- Controllo se l'intervallo dei ricalcoli  -- Se ho le date di confine inizio i calcoli (Il resto dei controlli lo effettuo nella FindCork) 
    IF @ToServerTime IS NOT NULL 
    AND @FromServerTime IS NOT NULL
		BEGIN 

			EXEC	[ETL].[ExtractRawDataFromPIN] 
					@ConcessionaryID = @ConcessionaryID
					,@ClubID = @ClubID
					,@CSVmachineID = @MachineID
					,@FromDate = @FromServerTime
					,@ToDate = @ToServerTime
					,@XRAW = @XRAW OUTPUT

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
				FROM	@TableMaxCounters 
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
				--FROM	[TMP].[Rawdata_view] (nolock) 
				FROM	ETL.GetXRAW(@XRAW, NULL,NULL,NULL,@MachineID,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
				WHERE	servertime > @FromServerTime
				AND		servertime <= @ToServerTime 
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
			 
    -- Tabella finale 
    INSERT INTO [TMP].delta 
                ( 
                            rowid, 
                            [UnivocalLocationCode], 
                            servertime, 
                            machineid, 
                            [GD], 
                            aamsmachinecode, 
                            gameid, 
                            gamename, 
                            loginflag, 
                            vltcredit, 
                            totalbet, 
                            totalwon, 
                            totalbillin, 
                            totalcoinin, 
                            totalticketin, 
                            totalticketout, 
                            totalhandpay, 
                            tax, 
                            totalin, 
                            totalout 
                ) 
    SELECT     rowid, 
                @UnivocalLocationCode, 
                servertime, 
                machineid, 
                @GD, 
                @AamsMachineCode, 
                t1.gameid, 
                Replace([GameNameType], Char(13) + Char(10), ''), 
                loginflag, 
                vltcredit, 
                totalbet, 
                totalwon, 
                totalbillin, 
                totalcoinin, 
                totalticketin, 
                totalticketout, 
                totalhandpay, 
                tax, 
                totalin, 
                totalout -- sono campi calcolati 
    FROM       tabella02 T1 
    INNER JOIN [dbo].[GameNameID] T2 
    ON         t1.gameid = t2.gameid 
    -- Cancello per avere le sessioni con limite a 50 C 
    SELECT @ServerTimeTicketStart = [ServerTime], 
            @Direction = direction 
    FROM   [TMP].[TicketServerTime] 
    SET @ServertimePre = 
    ( 
            SELECT Max([ServerTime]) 
            FROM   [TMP].[Delta] 
            WHERE  vltcredit < @VltMinSession 
            AND    servertime < @ServerTimeTicketStart 
            AND    Isnull(totalin,0) = 0) 
    --Select @ServerTimeTicketStart,@ServertimePre,@FromServerTime,@ToServerTime 
    IF @ServertimePre IS NOT NULL 
    BEGIN 
        DELETE 
        FROM   [TMP].[Delta] 
        WHERE  servertime < @ServertimePre 
        -- credito residuo da sessione precedente 
        UPDATE [TMP].delta 
        SET    totalbet = NULL, 
                totalwon = NULL 
        WHERE  servertime = @ServertimePre 
    END 
    -- se è in avanti la sessione finisce se il credito diventa inferiore a mincredit 
    IF @Direction = 1 
    BEGIN 
        SET @ServertimePost = 
        ( 
                SELECT Min([ServerTime]) 
                FROM   [TMP].[Delta] 
                WHERE  vltcredit < @VltMinSession 
                AND    servertime > @ServerTimeTicketStart 
                AND    Isnull(totalout,0) = 0) 
        IF @ServertimePost IS NOT NULL 
        DELETE 
        FROM   [TMP].[Delta] 
        WHERE  servertime > @ServertimePost 
    END 
    --Select * FROM [TMP].[Delta] 
    
	-- Log operazione 
	EXEC ETL.WriteLog @@PROCID, 'Calcolo delta terminato', @TicketCode, @BatchID -- Log operazione  

    END 
    ELSE 
    -- Errore specifico 
    BEGIN 
    RAISERROR ('@FromServerTime OR @ToServerTime is Null',16,1); 
    END 
    -- Errore specifico 
    IF NOT EXISTS 
    ( 
            SELECT TOP 1 
                * 
            FROM   [TMP].[Delta]) 
    BEGIN 
    RAISERROR ('Empty table [TMP].[Delta]',16,1); 
    END 
END try 
-- Gestione Errore 
BEGIN catch 
    EXECUTE [ERR].[UspLogError] 
    @ErrorTicket = @TicketCode, 
    @ErrorRequestDetailID = @BatchID 
    --SET @ReturnCode = -1; 
END catch 
--RETURN @ReturnCode 
