/*
Stored procedure di estrazione rapida dei Tickets
*/
ALTER PROC	[Ticket].[spGetTickets]
			@ConcessionaryID tinyint = NULL
			,@ClubID varchar(10) = NULL
			,@TicketList TICKETLIST_TYPE READONLY
			,@FromDate datetime = NULL
			,@ToDate datetime = NULL
			,@IsMhx bit = 1
			,@BatchID int = NULL
			,@ReturnMessage varchar(1000) = NULL OUTPUT
AS
SET NOCOUNT ON;
DECLARE @tickets TICKET_TYPE
DECLARE 
		@RemoteSql varchar(MAX)
		,@TicketCode varchar(MAX)
		,@ConcessionaryName varchar(100)
		,@LinkedServer varchar(100)
		,@CQIDB varchar(100)
		,@BatchIDtoReturn varchar(100)
		,@Criteria varchar(MAX)
		,@counter int = 0
		,@ReturnCode int = 0
		,@LOCALTicketList TICKETLIST_TYPE

INSERT	@LOCALTicketList
SELECT	TicketCode
FROM	@TicketList

SELECT	@BatchIDtoReturn =
		CASE
			WHEN @BatchID IS NULL
			THEN 'NULL'
			ELSE CAST(@BatchID AS varchar(5))
		END

SELECT	@Criteria = 
		CASE WHEN @ClubID IS NOT NULL THEN ' @ClubID = ' + QUOTENAME(@ClubID, char(39)) ELSE '' END +
		CASE WHEN @FromDate IS NOT NULL THEN ', @FromDate = ' + QUOTENAME(CONVERT(char(8), @FromDate, 112), char(39))  ELSE '' END +
		CASE WHEN @ToDate IS NOT NULL THEN ', @ToDate = ' + QUOTENAME(CONVERT(char(8), @ToDate, 112), char(39))  ELSE '' END +
		CASE WHEN @ISMhx IS NOT NULL THEN ', @ISMhx = ' + QUOTENAME(CONVERT(char(1), @ISMhx, 112), char(39)) ELSE '' END

SELECT	TOP 1
		@ConcessionaryName = ConcessionaryName
		,@LinkedServer = LinkedServer
FROM	[AGS].[Type].[Concessionary] WITH(NOLOCK)
WHERE	ConcessionarySK = @ConcessionaryID

IF @fromDate IS NOT NULL 
	SET @ToDate = ISNULL(@ToDate, DATEADD(DAY, 1, @fromDate))

SELECT	@counter = COUNT(*)
FROM	@LOCALTicketList


-----------------------------------------------------------------------------
---- DA RIPRISTINARE UNA VOLTA CHE LA SP [AGS_ETL].[Ticket].[Extract_PIN01] 
---- AVRA' LA FUNZIONALITA' "MULTITICKET" FUNZIONANTE
-----------------------------------------------------------------------------
--IF @counter > 1
--	BEGIN
--		SELECT	@TicketCode = COALESCE(@TicketCode,'') + TicketCode + ','
--		FROM	@LOCALTicketList
--		SET @TicketCode = LEFT(@TicketCode,LEN(@TicketCode)-1)
--	END
--ELSE
--	BEGIN
--		SELECT	TOP 1
--				@TicketCode =  TicketCode 
--		FROM	@LOCALTicketList
--	END

--SELECT @RemoteSql = 
--'
--EXEC [AGS_ETL].[Ticket].[Extract_PIN01] ' + @Criteria + ', @TicketCode = ' + QUOTENAME(@TicketCode, CHAR(39)) + ';
--SELECT ' + @BatchIDtoReturn + ' AS BatchID, ClubID, TicketCode, Ticketvalue, PrintingDate AS PrintingData, PrintingMachine, PrintingMachineID, PayOutDate AS PayoutData, PayOutMachine, PayOutMachineID, IsPrintingCashDesk, IsPaidCashDesk, EventDate, MhMachine, MhMachineID, CreationChangeDate, [ExpireDate] 
--FROM [AGS_ETL].[Ticket].[Extract] WITH(NOLOCK)
--'
--IF @ConcessionaryName = 'GMATICA' INSERT @tickets EXEC (@RemoteSql) AT[GMatica_Pin01\DW];
--IF @ConcessionaryName = 'NETWIN' INSERT @tickets EXEC (@RemoteSql) AT[Netwin_Pin01\DW];
--IF @ConcessionaryName = 'NTS' INSERT @tickets EXEC (@RemoteSql) AT[NTS_Pin01\DW];
--IF @ConcessionaryName = 'INTRALOT' INSERT @tickets EXEC (@RemoteSql) AT[INTRALOT_Pin01\DW];
--IF @ConcessionaryName = 'HBG' INSERT @tickets EXEC (@RemoteSql) AT[HBG_Pin01\DW];
--IF @ConcessionaryName = 'SISAL' INSERT @tickets EXEC (@RemoteSql) AT[SISAL_Pin01\DW];
--IF @ConcessionaryName = 'SNAI' INSERT @tickets EXEC (@RemoteSql) AT[SNAI_Pin01\DW];
--IF @ConcessionaryName = 'CODERE' INSERT @tickets EXEC (@RemoteSql) AT[CODERE_Pin01\DW];
--IF @ConcessionaryName = 'BPLUS' INSERT @tickets EXEC (@RemoteSql) AT[BPLUS_Pin01\DW];
--IF @ConcessionaryName = 'CIRSA' INSERT @tickets EXEC (@RemoteSql) AT[CIRSA_Pin01\DW];
--IF @ConcessionaryName = 'GAMENET' INSERT @tickets EXEC (@RemoteSql) AT[GAMENET_Pin01\DW];
--IF @ConcessionaryName = 'GTECH' INSERT @tickets EXEC (@RemoteSql) AT[GTECH_Pin01\DW];
--IF @ConcessionaryName = 'COGETECH' INSERT @tickets EXEC (@RemoteSql) AT[COGETECH_Pin01\DW];

--PRINT(@RemoteSql)		
--SELECT * FROM @tickets

-----------------------------------------------------------------------------
-- IN ATTESA CHE LA FUNZIONALITA' MULTITICKET VENGA RIPRISTINATA SI 
-- UTILIZZA UNA RICORSIONE
-----------------------------------------------------------------------------
WHILE @counter > 0
	BEGIN
		SELECT	TOP 1
				@TicketCode = TicketCode
		FROM	@LOCALTicketList
		WHERE	TicketCode IS NOT NULL

		SELECT @RemoteSql = 
		'
		EXEC [AGS_ETL].[Ticket].[Extract_PIN01] ' + @Criteria + ', @TicketCode = ''' + @TicketCode + ''';
		SELECT ' + @BatchIDtoReturn + ' AS BatchID, ClubID, TicketCode, Ticketvalue, PrintingDate AS PrintingData, PrintingMachine, PrintingMachineID, PayOutDate AS PayoutData, PayOutMachine, PayOutMachineID, IsPrintingCashDesk, IsPaidCashDesk, EventDate, MhMachine, MhMachineID, CreationChangeDate, [ExpireDate] 
		FROM [AGS_ETL].[Ticket].[Extract] WITH(NOLOCK)
		'
		UPDATE	@LOCALTicketList
		SET		TicketCode = NULL
		WHERE	TicketCode = @TicketCode

		IF @ConcessionaryName = 'GMATICA' INSERT @tickets EXEC (@RemoteSql) AT[GMatica_Pin01\DW];
		IF @ConcessionaryName = 'NETWIN' INSERT @tickets EXEC (@RemoteSql) AT[Netwin_Pin01\DW];
		IF @ConcessionaryName = 'NTS' INSERT @tickets EXEC (@RemoteSql) AT[NTS_Pin01\DW];
		IF @ConcessionaryName = 'INTRALOT' INSERT @tickets EXEC (@RemoteSql) AT[INTRALOT_Pin01\DW];
		IF @ConcessionaryName = 'HBG' INSERT @tickets EXEC (@RemoteSql) AT[HBG_Pin01\DW];
		IF @ConcessionaryName = 'SISAL' INSERT @tickets EXEC (@RemoteSql) AT[SISAL_Pin01\DW];
		IF @ConcessionaryName = 'SNAI' INSERT @tickets EXEC (@RemoteSql) AT[SNAI_Pin01\DW];
		IF @ConcessionaryName = 'CODERE' INSERT @tickets EXEC (@RemoteSql) AT[CODERE_Pin01\DW];
		IF @ConcessionaryName = 'BPLUS' INSERT @tickets EXEC (@RemoteSql) AT[BPLUS_Pin01\DW];
		IF @ConcessionaryName = 'CIRSA' INSERT @tickets EXEC (@RemoteSql) AT[CIRSA_Pin01\DW];
		IF @ConcessionaryName = 'GAMENET' INSERT @tickets EXEC (@RemoteSql) AT[GAMENET_Pin01\DW];
		IF @ConcessionaryName = 'GTECH' INSERT @tickets EXEC (@RemoteSql) AT[GTECH_Pin01\DW];
		IF @ConcessionaryName = 'COGETECH' INSERT @tickets EXEC (@RemoteSql) AT[COGETECH_Pin01\DW];
		
		SET @counter -= 1
	END

SELECT * FROM @tickets