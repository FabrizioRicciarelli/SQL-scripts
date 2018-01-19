USE [AGS_ETL]
GO
/****** Object:  StoredProcedure [Ticket].[Extract_PIN01]    Script Date: 15/01/2018 14:54:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Ticket].[Extract_PIN01]
@ClubID varchar(10) = NULL,
@TicketCode varchar(max) = NULL,
@TicketValue varchar(20) = NULL,
@FromDate datetime = NULL,
@ToDate datetime = NULL,
@ReturnMessage varchar(1000) = NULL OUTPUT,
@IsMhx bit = 0,
@ISpaid BIT = 0,
@Threshold  varchar(20) = NULL
AS
/*
emplate NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: Jena 
Creation Date.......: 2017-0512
Description.........: Estrazione tickets per RawData

Revision			 
2017-25-05: GA - Nuova versione per correzioni e adattamento a requisiti progetto

Note
- Use [Tab size] = 3 and [Indent size] = 3 (Instert spaces)

------------------
-- Parameters   --
------------------	

------------------
-- Call Example --
------------------
-- Dati inesatti
DECLARE @ReturnCode int, @ReturnMessage varchar(1000);
EXEC @ReturnCode =  Ticket.[Extract_PIN01] @Fromdate = '20150211', @ReturnMessage = @ReturnMessage OUTPUT;
SELECT @ReturnCode ReturnCode, @ReturnMessage ReturnMessage

EXEC  Ticket.[Extract_PIN01] @Fromdate = '20150211', @ClubID = '1000296'

EXEC  Ticket.[Extract_PIN01] @Fromdate = '20150222', @ClubID = 1000294

-- Ticket
EXEC  Ticket.[Extract_PIN01] @TicketCode = '525764475876923475'

-- MHx
EXEC  Ticket.[Extract_PIN01] @TicketCode = '1000332HPV201709220001'

-- Multitickets 
EXEC  Ticket.[Extract_PIN01] @TicketCode = '479194386004564610,369456253604773261,525764475876923475,181340809208629093,1000294MHR201502110001'
*/
BEGIN
DECLARE @ReturnCode int = 0;
DECLARE @TableOutput TABLE(ClubID int, TicketCode varchar(40), Ticketvalue int, PrintingMachine varchar(20), PrintingMachineID smallint, PrintingDate datetime, 
						   PayOutMachine varchar(20), PayOutMachineID smallint, PayOutDate datetime, IsPaidCashDesk bit, IsPrintingCashDesk bit, ExpireDate datetime,
						   EventDate datetime, MhMachine varchar(30), MhMachineID smallint, CreationChangeDate datetime);
DECLARE @IsTicket bit = 1,@NumRecord Tinyint;

BEGIN TRY
-- Settaggio Parametri

IF @ToDate IS NULL	
	SET @ToDate = DATEADD(Day, 1, @FromDate);

 --Verifica parametri
IF @ClubID IS NULL AND @TicketCode IS NULL AND @Fromdate IS NULL
BEGIN
  SET @ReturnMessage = FORMATMESSAGE('Occorre inserire oltre la Data almeno il TicketCode o la sala');
  THROW 50000, @ReturnMessage, 1; 
END;

IF NOT @TicketCode IS NULL
BEGIN
	SET @IsTicket = ISNULL(try_parse(@TicketCode as bigint), 0);
	SET @IsMhx = IIF(@IsTicket = 0, 1, 0)
	SET @TicketCode = char(39) + REPLACE(@TicketCode, ',', char(39) + ',' + char(39)) + char(39);
END;

--TRUNCATE TABLE Ticket.Extract;
-----------------------------------------------------------------------------------------------------------
-- Ticket                                                                                                --
-----------------------------------------------------------------------------------------------------------
IF @IsTicket = 1
BEGIN
	DECLARE @StringaWhere VARCHAR(Max) = ''
	DECLARE @StringSQL VARCHAR(Max) = '
	DECLARE @ClubID varchar(10), @TicketValue varchar(20), @TicketCode varchar(max), @Fromdate datetime, @ToDate datetime,@Threshold Bigint

	SET @ClubID = ' + ISNULL(@ClubID, 'NULL') + '
	SET @TicketValue = ' + ISNULL(@TicketValue, 'NULL') + '
	SET @Fromdate = ' + QUOTENAME(CONVERT(CHAR(8), ISNULL(@Fromdate, SPACE(0)), 112), CHAR(39)) + '
	SET @ToDate = ' + QUOTENAME(CONVERT(CHAR(8), ISNULL(@ToDate, SPACE(0)), 112), CHAR(39)) + '
	SET @TicketCode = ' + QUOTENAME(ISNULL(@TicketCode, SPACE(0)), CHAR(39)) + '
	SET @Threshold = ' + ISNULL(@Threshold, 'NULL') + '

	SELECT	TD.ClubID, 
				TD.TicketID as TicketCode, 
				CAST(((CashA+CashB+CashC) * 100) AS BIGINT) AS TicketValue,
				--	Printing Machine
				CreationTime as PrintingDate,
				LEFT(LTRIM(CM.CertificateName), 11) AS PrintingMachine, 
				TD.MachineID as PrintingMachineID,
				-- Payout Machine 
				PayoutTime as PayoutDate,
				LEFT(LTRIM(PM.CertificateName), 11) as PayoutMachine, 
				TD.PayoutMachineID as PayoutMachineID,
				(CASE WHEN NOT PayoutUserID IS NULL THEN 1 ELSE 0 END) as IsPaidCashDesk,
				(CASE WHEN NOT UserID IS NULL THEN 1 ELSE 0 END) as IsPrintingCashDesk,
				ExpireTime as ExpireDate
	FROM NucleusDB.Tito.TicketData (Nolock) TD  
	LEFT OUTER JOIN NucleusDB.Config.Machine CM with (nolock) ON (TD.ClubId = CM.ClubId AND TD.MachineId = CM.RecId) 
	LEFT OUTER JOIN NucleusDB.Config.Machine PM with (nolock) ON (TD.ClubId = PM.ClubId AND TD.PayoutMachineId = PM.RecId) 
	LEFT OUTER JOIN NucleusDB.Users.UsersSite US with (nolock) ON (TD.ClubId = US.ClubId AND TD.UserId = US.RecId)
	LEFT OUTER JOIN NucleusDB.Users.UsersSite PS with (nolock) ON (TD.ClubId = PS.ClubId AND TD.PayoutUserId = PS.RecId) 
	' + char(10)

	-- WHERE Condition
	IF NOT @ClubID IS NULL
		SET @StringaWhere = 	' TD.ClubID = @ClubID AND';
		
	IF NOT @TicketCode IS NULL
		SET @StringaWhere += 	' TD.TicketID IN (' + @TicketCode + ') AND';
		
	IF NOT @TicketValue IS NULL
		SET @StringaWhere = 	' CAST(((CashA+CashB+CashC) * 100) AS BIGINT)  = @TicketValue AND';

	IF NOT @Fromdate IS NULL
		SET @StringaWhere += 	' (
								  (CreationTime > @Fromdate AND CreationTime < @ToDate) OR
								  (PayoutTime > @Fromdate AND PayoutTime < @ToDate)
								  )';
	
	IF  @ISpaid = 1
		SET @StringaWhere += 	' AND PayoutUserID IS NOT NULL';

	IF NOT @Threshold IS NULL
		SET @StringaWhere += 	' AND CAST(((CashA+CashB+CashC) * 100) AS BIGINT) > @Threshold';
	

	SET @StringaWhere =  'WHERE ' + IIF(LEFT(REVERSE(@StringaWhere),3) = 'DNA', REVERSE(SUBSTRING(REVERSE(@StringaWhere),4, 1000)), @StringaWhere);

	SET @StringSQL += @StringaWhere;

	--PRINT @StringSQL
	-- Inserimento in Tabella
	INSERT INTO @TableOutput (ClubID, TicketCode, Ticketvalue, PrintingDate, PrintingMachine, PrintingMachineID , PayOutDate, PayOutMachine, PayOutMachineID , IsPaidCashDesk , IsPrintingCashDesk , ExpireDate)
	EXEC (@StringSQL) AT  [SQL-FINANCE\SQL_FINANCE];
END;

-----------------------------------------------------------------------------------------------------------
-- MHx                                                                                                   --
-----------------------------------------------------------------------------------------------------------
IF @IsMhx = 1
BEGIN
	SET @StringaWhere = ''
	SET @StringSQL = '
	DECLARE @ClubID varchar(10), @TicketCode varchar(max), @Fromdate datetime, @ToDate datetime

	SET @ClubID = ' + ISNULL(@ClubID, 'NULL') + '
	SET @Fromdate = ' + QUOTENAME(CONVERT(CHAR(8), ISNULL(@Fromdate, SPACE(0)), 112), CHAR(39)) + '
	SET @ToDate = ' + QUOTENAME(CONVERT(CHAR(8), ISNULL(@ToDate, SPACE(0)), 112), CHAR(39)) + '
	SET @TicketCode = ' + QUOTENAME(ISNULL(@TicketCode, SPACE(0)), CHAR(39)) + '

	SELECT ST.ClubID, ST.Receipt, 
		-- CAST(ABS(Summary * 100) as int),
		CAST ((CAST (ST.[AddInfo].value(''(/CHandpayVoucherInfo//EventValue/node())[1]'', ''nvarchar(30)'') AS  DECIMAL(13,2)) * 100) AS INT) AS Value,
			 CASE 
				WHEN ST.Type = 36 THEN ST.[AddInfo].value(''(/CHandpayVoucherInfo//EventDateTime/node())[1]'', ''datetime'')
				WHEN ST.Type IN (21, 22, 26, 27) THEN ST.[AddInfo].value(''(/CMachineEventInfo//EventDateTime/node())[1]'', ''datetime'') 
				ELSE NULL
			 END AS EventDate,
			 CASE
				 WHEN LEN(LEFT(RTRIM(LTRIM(M.LabelID)), 11)) < 11 THEN UPPER(LEFT(RTRIM(LTRIM(M.CertificateName)), 11))
				 WHEN LEFT(RTRIM(LTRIM(M.LabelID)), 11) NOT LIKE ''GD%'' THEN UPPER(LEFT(RTRIM(LTRIM(M.CertificateName)), 11))
				 ELSE UPPER(LEFT(RTRIM(LTRIM(M.LabelID)), 11))
			  END AS Machine,
			  ST.[AddInfo].value(''(/CHandpayVoucherInfo//MachID/node())[1]'', ''int'') AS MachineID,
			  RegDateTime
	FROM [NucleusDB].[Cashdesk].[ShiftTransaction] ST with (nolock)
	INNER JOIN NucleusDB.Cashdesk.ShiftTranCurrency STC with (nolock) ON (STC.ClubId = ST.ClubId AND STC.TransactionId = ST.RecId)
	LEFT OUTER JOIN NucleusDB.Config.Machine M with (nolock) ON (M.ClubId = ST.ClubId AND M.RecId = ST.ObjectId)
	WHERE ST.[Type] IN (21, 22, 26, 27,36) AND ' + char(10);
	-- (19, 20, 21, 22, 24, 25, 26, 27, 36) 
	-- WHERE Condition
	IF NOT @ClubID IS NULL
		SET @StringaWhere = 	' ST.ClubID = @ClubID AND';

	IF NOT @TicketCode IS NULL
		SET @StringaWhere += 	' ST.Receipt IN (' + @TicketCode + ') AND';

	--IF NOT @Fromdate IS NULL
	--	SET @StringaWhere += 	' RegDateTime >= @Fromdate AND RegDateTime < @ToDate';

	SET @StringaWhere =  + IIF(LEFT(REVERSE(@StringaWhere),3) = 'DNA', REVERSE(SUBSTRING(REVERSE(@StringaWhere),4, 1000)), @StringaWhere);

	SET @StringSQL += @StringaWhere;

	--PRINT @StringSQL

	INSERT INTO @TableOutput (ClubID, TicketCode, Ticketvalue, EventDate, MhMachine, MhMachineID, CreationChangeDate)
	EXEC (@StringSQL) AT  [SQL-FINANCE\SQL_FINANCE];
	SET @NumRecord = @@ROWCOUNT
	IF @NumRecord = 0
	BEGIN
		SET @StringaWhere = ''
		SET @StringSQL = '
		DECLARE @ClubID varchar(10), @TicketCode varchar(max), @Fromdate datetime, @ToDate datetime

		SET @ClubID = ' + ISNULL(@ClubID, 'NULL') + '
		SET @Fromdate = ' + QUOTENAME(CONVERT(CHAR(8), ISNULL(@Fromdate, SPACE(0)), 112), CHAR(39)) + '
		SET @ToDate = ' + QUOTENAME(CONVERT(CHAR(8), ISNULL(@ToDate, SPACE(0)), 112), CHAR(39)) + '
		SET @TicketCode = ' + QUOTENAME(ISNULL(@TicketCode, SPACE(0)), CHAR(39)) + '	
		SELECT ST.ClubID, ST.Receipt, 
			CASE 
				WHEN ST.Type = 36 THEN CAST ((CAST (ST.[AddInfo].value(''(/CHandpayVoucherInfo//HandpayInfo/EventValue/node())[1]'', ''nvarchar(30)'') AS  DECIMAL(13,2)) * 100) AS INT)
				WHEN ST.Type IN (21, 22, 26, 27) THEN CAST ((CAST (ST.[AddInfo].value(''(/CMachineEventInfo//EventValue/node())[1]'', ''nvarchar(30)'') AS  DECIMAL(13,2)) * 100) AS INT)
				ELSE NULL
			END AS Value,
			CASE 
				WHEN ST.Type = 36 THEN ST.[AddInfo].value(''(CHandpayVoucherInfo//HandpayInfo/EventDateTime/node())[1]'', ''datetime'')
				WHEN ST.Type IN (21, 22, 26, 27) THEN ST.[AddInfo].value(''(/CMachineEventInfo//EventDateTime/node())[1]'', ''datetime'') 
				ELSE NULL
			END AS EventDate,
			 CASE
				 WHEN LEN(LEFT(RTRIM(LTRIM(M.LabelID)), 11)) < 11 THEN UPPER(LEFT(RTRIM(LTRIM(M.CertificateName)), 11))
				 WHEN LEFT(RTRIM(LTRIM(M.LabelID)), 11) NOT LIKE ''GD%'' THEN UPPER(LEFT(RTRIM(LTRIM(M.CertificateName)), 11))
				 ELSE UPPER(LEFT(RTRIM(LTRIM(M.LabelID)), 11))
			  END AS Machine,
			CASE 
				WHEN ST.Type = 36 THEN ST.[AddInfo].value(''(/CHandpayVoucherInfo//HandpayInfo/MachID/node())[1]'', ''int'') 
				WHEN ST.Type IN (21, 22, 26, 27) THEN ST.[AddInfo].value(''(/CMachineEventInfo//MachID/node())[1]'', ''int'')
				ELSE NULL
			END AS MachineID,RegDateTime
		FROM [NucleusDB].[Cashdesk].[ShiftTranClosed] ST with (nolock)
		INNER JOIN NucleusDB.Cashdesk.ShiftTranCurrency STC with (nolock) ON (STC.ClubId = ST.ClubId AND STC.TransactionId = ST.RecId)
		LEFT OUTER JOIN NucleusDB.Config.Machine M with (nolock) ON (M.ClubId = ST.ClubId AND M.RecId = ST.ObjectId)
		WHERE ST.[Type] IN (21, 22, 26, 27,36) AND ' + char(10)
		-- (19, 20, 21, 22, 24, 25, 26, 27, 36) 
		-- WHERE Condition
		IF NOT @ClubID IS NULL
			SET @StringaWhere = 	' ST.ClubID = @ClubID AND';

		IF NOT @TicketCode IS NULL
			SET @StringaWhere += 	' ST.Receipt IN (' + @TicketCode + ') AND';

		--IF NOT @Fromdate IS NULL
		--	SET @StringaWhere += 	' RegDateTime >= @Fromdate AND RegDateTime < @ToDate';

		SET @StringaWhere =  + IIF(LEFT(REVERSE(@StringaWhere),3) = 'DNA', REVERSE(SUBSTRING(REVERSE(@StringaWhere),4, 1000)), @StringaWhere);

		SET @StringSQL += @StringaWhere;

		--PRINT @StringSQL

		INSERT INTO @TableOutput (ClubID, TicketCode, Ticketvalue, EventDate, MhMachine, MhMachineID, CreationChangeDate)
		EXEC (@StringSQL) AT  [SQL-FINANCE\SQL_FINANCE];
	END
END;

-----------------------------------------------
-- Recordset di Uscita                       --
-----------------------------------------------
--INSERT INTO Ticket.Extract(ClubID, TicketCode, Ticketvalue, PrintingDate, PrintingMachine, PrintingMachineID , PayOutDate, PayOutMachine, PayOutMachineID , IsPaidCashDesk , IsPrintingCashDesk , ExpireDate, 	EventDate, MhMachine, MhMachineID, CreationChangeDate)
SELECT	ClubID, TicketCode, Ticketvalue, PrintingDate, PrintingMachine, PrintingMachineID , PayOutDate, PayOutMachine, PayOutMachineID , IsPaidCashDesk , IsPrintingCashDesk , ExpireDate,
			EventDate, MhMachine, MhMachineID, CreationChangeDate
FROM @TableOutput;
RETURN @ReturnCode;

END TRY
BEGIN CATCH
	SET @ReturnMessage = ERROR_MESSAGE();
	SET @ReturnCode = ERROR_NUMBER();
	RETURN @ReturnCode
END CATCH
END