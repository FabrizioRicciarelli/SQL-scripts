/* 
Template NIS (1.1 - 2015-04-01) 
███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗ 
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝ 
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║ 
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║ 
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗ 
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ 
Author..............: Jena 
Creation Date.......: 2017-0512 
Description.........: Estrazione tickets per RawData 

Revision s
2017-25-05: GA - Nuova versione per correzioni e adattamento a requisiti progetto 
2018-01-15: FR - Revisione semantica e sintattica, reindentazione per leggibilità e manutenibilità

Note 
LA PRESENTE STORED PROCEDURE E' ISTANZIATA, IN MODO IDENTICO, ALL'INTERNO DI CIASCUNA MACCHINA PIN01;
ESSA VIENE INVOCATA - SU POM-MON01 - DALLA STORED PROCEDURE Ticket.Extract_Pomezia LA QUALE OPERA 
L'INVOCAZIONE ATTRAVERSO I SUOI LINKED SERVERS "ConcessionaryName_PIN01\DW" PRODUCENDO, DINAMICAMENTE,
UNA CHIAMATA DEL TIPO: 

EXEC [POM-MON01].[Ticket].[Extract_Pomezia] params >>> EXEC [AGS_ETL].[Ticket].[Extract_PIN01] AT [GMATICA_PIN01\DW] params

A SUA VOLTA, LA PRESENTE STORED PROCEDURE - SEMPRE DINAMICAMENTE - PRENDE I PARAMETRI IN INGRESSO E LI COMBINA IN MODO
UTILE AFFINCHE' POSSANO ESSERE UTILIZZATI PER INVOCARE I DB "NUCLEUS" E "FINANCE" E DA QUESTI ESTRARRE
I DATI NECESSARI PER LE ELABORAZIONI SUCCESSIVE 

------------------ 
-- Parameters   -- 
------------------ 
@ClubID        varchar(10)
@TicketCode    varchar(MAX)
@TicketValue   varchar(20)
@FromDate      datetime
@ToDate        datetime
@IsMhx         bit
@ISpaid        bit 
@Threshold     varchar(20)
@ReturnMessage varchar(1000) OUTPUT

------------------ 
-- Call Example -- 
------------------ 
-- Dati inesatti 
DECLARE @ReturnCode int, @ReturnMessage varchar(1000); 
EXEC @ReturnCode =  Ticket.[Extract_PIN01] @Fromdate = '20150211', @ReturnMessage = @ReturnMessage OUTPUT; 
SELECT @ReturnCode ReturnCode, @ReturnMessage ReturnMessage 

EXEC  [Ticket].[Extract_PIN01_NEW] @Fromdate = '20150211', @ClubID = '1000296' 
EXEC  [Ticket].[Extract_PIN01_NEW] @Fromdate = '20150222', @ClubID = 1000294 

-- Ticket 
EXEC  [Ticket].[Extract_PIN01_NEW] @TicketCode = '525764475876923475' 

-- MHx 
EXEC  [Ticket].[Extract_PIN01_NEW] @TicketCode = '1000332HPV201709220001' 

-- Multitickets 
EXEC  [Ticket].[Extract_PIN01_NEW] @TicketCode = '479194386004564610,369456253604773261,525764475876923475,181340809208629093,1000294MHR201502110001'
*/ 
ALTER PROC	[Ticket].[Extract_PIN01_NEW] 
			@ClubID        varchar(10) = NULL, 
			@TicketCode    varchar(MAX) = NULL, 
			@TicketValue   varchar(20) = NULL, 
			@FromDate      datetime = NULL, 
			@ToDate        datetime = NULL, 
			@ReturnMessage varchar(1000) = NULL output, 
			@IsMhx         bit = 0, 
			@ISpaid        bit = 0, 
			@Threshold     varchar(20) = NULL 
AS 
DECLARE	
		@ReturnCode int = 0
		,@IsTicket bit = 1 
		,@NumRecord      tinyint

DECLARE	@TABLEOUTPUT	TABLE 
        ( 
            clubid             int, 
            ticketcode         varchar(40), 
            ticketvalue        int, 
            printingmachine    varchar(20), 
            printingmachineid  smallint, 
            printingdate       datetime, 
            payoutmachine      varchar(20), 
            payoutmachineid    smallint, 
            payoutdate         datetime, 
            ispaidcashdesk     bit, 
            isprintingcashdesk bit, 
            expiredate         datetime, 
            eventdate          datetime, 
            mhmachine          varchar(30), 
            mhmachineid        smallint, 
            creationchangedate datetime 
        ); 
     
BEGIN TRY 
    -- Settaggio Parametri 
    IF @ToDate IS NULL 
		SET @ToDate = Dateadd(day, 1, @FromDate); 
    
	--Verifica parametri 
    IF @ClubID IS NULL 
    AND @TicketCode IS NULL 
    AND @Fromdate IS NULL 
		BEGIN 
			SET @ReturnMessage = Formatmessage('Occorre inserire oltre la Data almeno il TicketCode o la sala');
			THROW 50000, @ReturnMessage, 1; 
		END; 
    
	IF NOT @TicketCode IS NULL 
		BEGIN 
			SET @IsTicket = isnull(try_parse(@TicketCode as bigint), 0); 
			SET @IsMhx = Iif(@IsTicket = 0, 1, 0) 
			SET @TicketCode = Char(39) + Replace(@TicketCode, ',', Char(39) + ',' + Char(39)) + Char(39);
		END

    --TRUNCATE TABLE Ticket.Extract; 
    ----------------------------------------------------------------------------------------------------------- 
    -- Ticket                                                                                                -- 
    ----------------------------------------------------------------------------------------------------------- 
    IF @IsTicket = 1 
		BEGIN 
			DECLARE
					@StringaWhere varchar(max) = '' 
					,@StringSQL varchar(max)

			SET @StringSQL =
			'
			DECLARE 
					@ClubID varchar(10)
					,@TicketValue varchar(20)
					,@TicketCode varchar(max)
					,@Fromdate datetime
					,@ToDate datetime
					,@Threshold Bigint 
			
			SET @ClubID = ' + Isnull(@ClubID, 'NULL') + ' 
			SET @TicketValue = ' + Isnull(@TicketValue, 'NULL') + ' 
			SET @Fromdate = ' + Quotename(CONVERT(char(8), Isnull(@Fromdate, Space(0)), 112), Char(39)) + ' 
			SET @ToDate = ' + Quotename(CONVERT(char(8), Isnull(@ToDate, Space(0)), 112), Char(39)) + ' 
			SET @TicketCode = ' + Quotename(Isnull(@TicketCode, Space(0)), Char(39)) + ' 
			SET @Threshold = ' + Isnull(@Threshold, 'NULL') + ' 
			
			SELECT	
					TD.ClubID
					,TD.TicketID as TicketCode
					,CAST(((CashA+CashB+CashC) * 100) AS BIGINT) AS TicketValue
					,-- PrintingMachine as PrintingDate
					,CreationTime as PrintingDate
					,LEFT(LTRIM(CM.CertificateName), 11) AS PrintingMachine
					,TD.MachineID as PrintingMachineID
					,-- PayoutMachine as PayoutDate
					,PayoutTime as PayoutDate
					,LEFT(LTRIM(PM.CertificateName), 11) as PayoutMachine
					,TD.PayoutMachineID as PayoutMachineID
					,(
						CASE 
							WHEN NOT PayoutUserID IS NULL 
							THEN 1 
							ELSE 0 
						END
					) AS IsPaidCashDesk
					, 
					(
						CASE 
							WHEN NOT UserID IS NULL 
							THEN 1 
							ELSE 0 
						END
					) AS IsPrintingCashDesk
					,ExpireTime AS ExpireDate 
			FROM	NucleusDB.Tito.TicketData WITH(NOLOCK) TD 
					LEFT OUTER JOIN 
					NucleusDB.Config.Machine CM WITH(NOLOCK) 
					ON TD.ClubId = CM.ClubId 
					AND TD.MachineId = CM.RecId
					LEFT OUTER JOIN 
					NucleusDB.Config.Machine PM WITH(NOLOCK) 
					ON TD.ClubId = PM.ClubId 
					AND TD.PayoutMachineId = PM.RecId 
					LEFT OUTER JOIN 
					NucleusDB.Users.UsersSite US WITH(NOLOCK) 
					ON TD.ClubId = US.ClubId 
					AND TD.UserId = US.RecId 
					LEFT OUTER JOIN 
					NucleusDB.Users.UsersSite PS WITH(NOLOCK) 
					ON TD.ClubId = PS.ClubId 
					AND TD.PayoutUserId = PS.RecId ' + Char(10) + ' 
			'
			    
			-- WHERE Condition 
			IF NOT @ClubID IS NULL 
				SET @StringaWhere = ' TD.ClubID = @ClubID AND' 
			IF NOT @TicketCode IS NULL 
				SET @StringaWhere += ' TD.TicketID IN (' + @TicketCode + ') AND' 
			IF NOT @TicketValue IS NULL 
				SET @StringaWhere = ' CAST(((CashA+CashB+CashC) * 100) AS BIGINT) = @TicketValue AND' 
			IF NOT @Fromdate IS NULL 
				SET @StringaWhere += ' ((CreationTime > @Fromdate AND CreationTime < @ToDate) OR (PayoutTime > @Fromdate AND PayoutTime < @ToDate))' 
			IF @ISpaid = 1 
				SET @StringaWhere += ' AND PayoutUserID IS NOT NULL' 
			IF NOT @Threshold IS NULL 
				SET @StringaWhere += ' AND CAST(((CashA+CashB+CashC) * 100) AS BIGINT) > @Threshold'
			
			SET @StringaWhere = 'WHERE ' + IIF(LEFT(REVERSE(@StringaWhere),3) = 'DNA', REVERSE(SUBSTRING(REVERSE(@StringaWhere),4, 1000)), @StringaWhere);
			SET @StringSQL += @StringaWhere; 
    
			-- Inserimento in Tabella 
			INSERT	@TableOutput 
					( 
						clubid, 
						ticketcode, 
						ticketvalue, 
						printingdate, 
						printingmachine, 
						printingmachineid , 
						payoutdate, 
						payoutmachine, 
						payoutmachineid , 
						ispaidcashdesk , 
						isprintingcashdesk , 
						expiredate 
					) 
			EXEC(@StringSQL) AT [SQL-FINANCE\SQL_FINANCE]; 
		END 
    
	----------------------------------------------------------------------------------------------------------- 
    -- MHx                                                                                                   -- 
    ----------------------------------------------------------------------------------------------------------- 
    IF @IsMhx = 1 
		BEGIN 
			SET @StringaWhere = '' 
			SET @StringSQL = 
			' 
			DECLARE 
					@ClubID varchar(10)
					,@TicketCode varchar(max)
					,@Fromdate datetime
					,@ToDate datetime 
					
			SET @ClubID = ' + Isnull(@ClubID, 'NULL') + ' 
			SET @Fromdate = ' + Quotename(CONVERT(char(8), Isnull(@Fromdate, Space(0)), 112), Char(39)) + ' 
			SET @ToDate = ' + Quotename(CONVERT(char(8), Isnull(@ToDate, Space(0)), 112), Char(39)) + ' 
			SET @TicketCode = ' + Quotename(Isnull(@TicketCode, Space(0)), Char(39)) + ' 
			
			SELECT 
					ST.ClubID
					,ST.Receipt
					,-- CAST(ABS(Summary * 100) as int)
					,CAST((CAST(ST.[AddInfo].value(''(/CHandpayVoucherInfo//EventValue/node())[1]'', ''nvarchar(30)'') AS  DECIMAL(13,2)) * 100) AS INT) AS Value
					,CASE 
						WHEN ST.Type = 36 
						THEN ST.[AddInfo].value(''(/CHandpayVoucherInfo//EventDateTime/node())[1]'', ''datetime'') 
						WHEN ST.Type IN (21, 22, 26, 27) 
						THEN ST.[AddInfo].value(''(/CMachineEventInfo//EventDateTime/node())[1]'', ''datetime'') 
						ELSE NULL  
					END AS EventDate
					,CASE  
						WHEN LEN(LEFT(RTRIM(LTRIM(M.LabelID)), 11)) < 11 
						THEN UPPER(LEFT(RTRIM(LTRIM(M.CertificateName)), 11))  
						WHEN LEFT(RTRIM(LTRIM(M.LabelID)), 11) NOT LIKE ''GD%'' 
						THEN UPPER(LEFT(RTRIM(LTRIM(M.CertificateName)), 11))  
						ELSE UPPER(LEFT(RTRIM(LTRIM(M.LabelID)), 11))   
					END AS Machine
					,ST.[AddInfo].value(''(/CHandpayVoucherInfo//MachID/node())[1]'', ''int'') AS MachineID
					,RegDateTime 
			FROM	[NucleusDB].[Cashdesk].[ShiftTransaction] ST WITH(NOLOCK) 
					INNER JOIN 
					NucleusDB.Cashdesk.ShiftTranCurrency STC WITH(NOLOCK) 
					ON STC.ClubId = ST.ClubId 
					AND STC.TransactionId = ST.RecId 
					LEFT OUTER JOIN 
					NucleusDB.Config.Machine M WITH8NOLOCK) 
					ON M.ClubId = ST.ClubId 
					AND M.RecId = ST.ObjectId 
			WHERE	ST.[Type] IN (21, 22, 26, 27,36) -- (19, 20, 21, 22, 24, 25, 26, 27, 36)
			AND ' + Char(10); 
			 
			-- WHERE Condition 
			IF NOT @ClubID IS NULL 
				SET @StringaWhere = ' ST.ClubID = @ClubID AND' 
			IF NOT @TicketCode IS NULL 
				SET @StringaWhere += ' ST.Receipt IN (' + @TicketCode + ') AND' 
			SET @StringaWhere = + IIF(LEFT(REVERSE(@StringaWhere),3) = 'DNA', REVERSE(SUBSTRING(REVERSE(@StringaWhere),4, 1000)), @StringaWhere);
			SET @StringSQL += @StringaWhere; 
			
			INSERT	@TableOutput 
					( 
						clubid, 
						ticketcode, 
						ticketvalue, 
						eventdate, 
						mhmachine, 
						mhmachineid, 
						creationchangedate 
					) 
			EXEC (@StringSQL) AT [SQL-FINANCE\SQL_FINANCE]; 

			SET @NumRecord = @@ROWCOUNT 
    
			IF @NumRecord = 0 
				BEGIN 
					SET @StringaWhere = '' 
					SET @StringSQL = 
					' 
					DECLARE	
							@ClubID varchar(10)
							,@TicketCode varchar(max)
							,@Fromdate datetime
							,@ToDate datetime 
					
					SET @ClubID = ' + Isnull(@ClubID, 'NULL') + ' 
					SET @Fromdate = ' + Quotename(CONVERT(char(8), Isnull(@Fromdate, Space(0)), 112), Char(39)) + ' 
					SET @ToDate = ' + Quotename(CONVERT(char(8), Isnull(@ToDate, Space(0)), 112), Char(39)) + ' 
					SET @TicketCode = ' + Quotename(Isnull(@TicketCode, Space(0)), Char(39)) + ' 
					
					SELECT 
							ST.ClubID
							,ST.Receipt
							,CASE 
								WHEN ST.Type = 36 
								THEN CAST((CAST(ST.[AddInfo].value(''(/CHandpayVoucherInfo//HandpayInfo/EventValue/node())[1]'', ''nvarchar(30)'') AS DECIMAL(13,2)) * 100) AS INT) 
								WHEN ST.Type IN (21, 22, 26, 27) 
								THEN CAST((CAST(ST.[AddInfo].value(''(/CMachineEventInfo//EventValue/node())[1]'', ''nvarchar(30)'') AS  DECIMAL(13,2)) * 100) AS INT) 
								ELSE NULL 
							END AS Value
							,CASE 
								WHEN ST.Type = 36 
								THEN ST.[AddInfo].value(''(CHandpayVoucherInfo//HandpayInfo/EventDateTime/node())[1]'', ''datetime'') 
								WHEN ST.Type IN (21, 22, 26, 27) 
								THEN ST.[AddInfo].value(''(/CMachineEventInfo//EventDateTime/node())[1]'', ''datetime'') 
								ELSE NULL 
							END AS EventDate
							,CASE  
								WHEN LEN(LEFT(RTRIM(LTRIM(M.LabelID)), 11)) < 11 
								THEN UPPER(LEFT(RTRIM(LTRIM(M.CertificateName)), 11))  
								WHEN LEFT(RTRIM(LTRIM(M.LabelID)), 11) NOT LIKE ''GD%'' 
								THEN UPPER(LEFT(RTRIM(LTRIM(M.CertificateName)), 11))  
								ELSE UPPER(LEFT(RTRIM(LTRIM(M.LabelID)), 11))   
							END AS Machine
							,CASE 
								WHEN ST.Type = 36 
								THEN ST.[AddInfo].value(''(/CHandpayVoucherInfo//HandpayInfo/MachID/node())[1]'', ''int'') 
								WHEN ST.Type IN (21, 22, 26, 27) 
								THEN ST.[AddInfo].value(''(/CMachineEventInfo//MachID/node())[1]'', ''int'') 
								ELSE NULL 
							END AS MachineID
							,RegDateTime 
					FROM	[NucleusDB].[Cashdesk].[ShiftTranClosed] ST WITH(NOLOCK) 
							INNER JOIN 
							NucleusDB.Cashdesk.ShiftTranCurrency STC WITH(NOLOCK)
							ON STC.ClubId = ST.ClubId 
							AND STC.TransactionId = ST.RecId
							LEFT OUTER JOIN 
							NucleusDB.Config.Machine M WITH(NOLOCK)
							ON M.ClubId = ST.ClubId 
							AND M.RecId = ST.ObjectId
					WHERE	ST.[Type] IN (21, 22, 26, 27,36) -- (19, 20, 21, 22, 24, 25, 26, 27, 36)
					AND ' + Char(10) 
					
					-- WHERE Condition 
					IF NOT @ClubID IS NULL 
						SET @StringaWhere = ' ST.ClubID = @ClubID AND'; 
					IF NOT @TicketCode IS NULL 
						SET @StringaWhere += ' ST.Receipt IN (' + @TicketCode + ') AND'; 
					SET @StringaWhere = + Iif(LEFT(Reverse(@StringaWhere),3) = 'DNA', Reverse(Substring(Reverse(@StringaWhere),4, 1000)), @StringaWhere);
					SET @StringSQL      += @StringaWhere; 
        
					INSERT	@TableOutput 
							( 
								clubid, 
								ticketcode, 
								ticketvalue, 
								eventdate, 
								mhmachine, 
								mhmachineid, 
								creationchangedate 
							) 
					EXEC (@StringSQL) AT [SQL-FINANCE\SQL_FINANCE]; 
				END 
		END 
    
		----------------------------------------------- 
		-- Recordset di Uscita                       -- 
		----------------------------------------------- 
		SELECT
				clubid, 
				ticketcode, 
				ticketvalue, 
				printingdate, 
				printingmachine, 
				printingmachineid , 
				payoutdate, 
				payoutmachine, 
				payoutmachineid , 
				ispaidcashdesk , 
				isprintingcashdesk , 
				expiredate, 
				eventdate, 
				mhmachine, 
				mhmachineid, 
				creationchangedate 
		FROM	@TableOutput; 
       
		RETURN @ReturnCode; 
END TRY 

BEGIN CATCH 
    SET @ReturnMessage = Error_message(); 
    SET @ReturnCode = Error_number(); 
    RETURN @ReturnCode 
END CATCH 
