﻿/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: FR
Creation Date.......: 2017/07/10
Description.........: Estrazione rapida dei tickets

Revision 1			 

------------------
-- Parameters   --
------------------	
@ConcessionaryID tinyint
@ClubID varchar(10)
@TicketList TICKETLIST_TYPE READONLY
@FromDate datetime
@ToDate datetime
@IsMhx Bit
@ReturnMessage OUTPUT

------------------
-- Call Example --
------------------  
DECLARE	@lista TICKETLIST_TYPE
INSERT	@lista (TicketCode)
VALUES	('4412211590049855')
		,('4410150034342200')
		,('4410149795967566')
		,('4409462773233281')
		,('4408088184213495')

EXEC	Ticket.spGetTickets
		@ConcessionaryID = 7
		,@ClubID = '1000296'
		,@TicketList = @lista
		,@FromDate = '2016-01-01'
		,@ToDate = '2016-12-31'
		,@IsMhx = 1
		,@ReturnMessage = NULL
*/
CREATE PROC	Ticket.spGetTickets
			@ConcessionaryID tinyint = NULL
			,@ClubID varchar(10) = NULL
			,@TicketList TICKETLIST_TYPE READONLY
			,@FromDate datetime = NULL
			,@ToDate datetime = NULL
			,@IsMhx Bit = 1
			,@ReturnMessage varchar(1000) = NULL OUTPUT
			
AS
SET NOCOUNT ON;

DECLARE @tickets TABLE(
		[ClubID] [int] NULL,
		[TicketCode] [varchar](40) NULL,
		[Ticketvalue] [int] NULL,
		[PrintingMachine] [varchar](20) NULL,
		[PrintingMachineID] [smallint] NULL,
		[PrintingDate] [datetime] NULL,
		[PayOutMachine] [varchar](20) NULL,
		[PayOutMachineID] [smallint] NULL,
		[PayOutDate] [datetime] NULL,
		[IsPaidCashDesk] [bit] NULL,
		[IsPrintingCashDesk] [bit] NULL,
		[ExpireDate] [datetime] NULL,
		[EventDate] [datetime] NULL,
		[MhMachine] [varchar](30) NULL,
		[MhMachineID] [smallint] NULL,
		[CreationChangeDate] [datetime] NULL
)

DECLARE	
		@RemoteSql varchar(MAX)
		,@TicketCode varchar(MAX)
		,@ConcessionaryName varchar(100)
		,@LinkedServer varchar(100)
		,@CQIDB varchar(100)
		,@Criteria varchar(MAX)
		,@counter int = 0
		,@ReturnCode int = 0

DECLARE @LOCALTicketList TICKETLIST_TYPE
INSERT	@LOCALTicketList
SELECT	TicketCode
FROM	@TicketList

SELECT	@Criteria = 
		CASE WHEN @ClubID IS NOT NULL		THEN ' @ClubID = ' + @ClubID ELSE '' END +
		CASE WHEN @FromDate IS NOT NULL		THEN ', @FromDate = ' + QUOTENAME(CONVERT(char(8), @FromDate, 112), char(39)) ELSE '' END +
		CASE WHEN @ToDate IS NOT NULL		THEN ', @ToDate = ' + QUOTENAME(CONVERT(char(8), @ToDate, 112), char(39)) ELSE '' END +
		CASE WHEN @ISMhx IS NOT NULL		THEN ', @ISMhx = ' + QUOTENAME(CONVERT(char(1), @ISMhx, 112), char(39)) ELSE '' END

SELECT	TOP 1
		@ConcessionaryName = ConcessionaryName
		,@LinkedServer = LinkedServer
FROM	[AGS].[Type].[Concessionary] WITH(NOLOCK)
WHERE	ConcessionarySK = @ConcessionaryID;

IF @fromDate IS NOT NULL 
	SET @ToDate = ISNULL(@ToDate, DATEADD(DAY, 1, @fromDate));

SELECT	@counter = COUNT(*)
FROM	@LOCALTicketList

WHILE @counter > 0
	BEGIN
		SELECT	TOP 1
				@TicketCode = TicketCode
		FROM	@LOCALTicketList
		WHERE	TicketCode IS NOT NULL

		SELECT	@RemoteSql = 
		'
		EXEC	[AGS_ETL].[Ticket].[Extract_PIN01] ' + @Criteria + ', @TicketCode = ''' + @TicketCode + ''';
		SELECT	ClubID, TicketCode, Ticketvalue, PrintingMachine, PrintingMachineID, PrintingDate, PayOutMachine, PayOutMachineID, PayOutDate, IsPaidCashDesk, IsPrintingCashDesk, [ExpireDate], EventDate, MhMachine, MhMachineID, CreationChangeDate
		FROM	[AGS_ETL].[Ticket].[Extract];
		'

		UPDATE	@LOCALTicketList
		SET		TicketCode = NULL
		WHERE	TicketCode = @TicketCode

		IF @ConcessionaryName = 'GMATICA'  INSERT @tickets EXEC (@RemoteSql) AT[GMatica_Pin01\DW];
		IF @ConcessionaryName = 'NETWIN'   INSERT @tickets EXEC (@RemoteSql) AT[Netwin_Pin01\DW];
		IF @ConcessionaryName = 'NTS'      INSERT @tickets EXEC (@RemoteSql) AT[NTS_Pin01\DW];
		IF @ConcessionaryName = 'INTRALOT' INSERT @tickets EXEC (@RemoteSql) AT[INTRALOT_Pin01\DW];
		IF @ConcessionaryName = 'HBG'      INSERT @tickets EXEC (@RemoteSql) AT[HBG_Pin01\DW];
		IF @ConcessionaryName = 'SISAL'    INSERT @tickets EXEC (@RemoteSql) AT[SISAL_Pin01\DW];
		IF @ConcessionaryName = 'SNAI'     INSERT @tickets EXEC (@RemoteSql) AT[SNAI_Pin01\DW];
		IF @ConcessionaryName = 'CODERE'   INSERT @tickets EXEC (@RemoteSql) AT[CODERE_Pin01\DW];
		IF @ConcessionaryName = 'BPLUS'    INSERT @tickets EXEC (@RemoteSql) AT[BPLUS_Pin01\DW];
		IF @ConcessionaryName = 'CIRSA'    INSERT @tickets EXEC (@RemoteSql) AT[CIRSA_Pin01\DW];
		IF @ConcessionaryName = 'GAMENET'  INSERT @tickets EXEC (@RemoteSql) AT[GAMENET_Pin01\DW];
		IF @ConcessionaryName = 'GTECH'    INSERT @tickets EXEC (@RemoteSql) AT[GTECH_Pin01\DW];
		IF @ConcessionaryName = 'COGETECH' INSERT @tickets EXEC (@RemoteSql) AT[COGETECH_Pin01\DW];
		
		SET		@counter -= 1
	END

SELECT	* FROM @tickets