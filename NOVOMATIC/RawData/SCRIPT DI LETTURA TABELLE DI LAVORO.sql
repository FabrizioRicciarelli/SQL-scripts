DECLARE
		@TicketCode Varchar(50) = '4412211590049855'
		,@ConcessionaryID tinyint
		,@ConcessionaryName sysname
		,@TMP sql_variant
		,@TicketList TICKETLIST_TYPE
		,@Tickets TICKET_TYPE
		,@ServerTime_FIRST datetime = '1900-01-01 00:00:00.000'
		,@ServerTime_LAST datetime = '2050-12-31 00:00:00.000'

SELECT * FROM [Config].[Table] WITH(NOLOCK)
SELECT * FROM [TMP].[TicketServerTime] WITH(NOLOCK)
SELECT * FROM [TMP].[CountersCork] WITH(NOLOCK)
SELECT * FROM [dbo].[VLT] WITH(NOLOCK)
SELECT * FROM [dbo].[GamingRoom] WITH(NOLOCK) -- dbo.GamingRoom = SYNONYM

SELECT	TOP 1
		@ConcessionaryID = ConcessionaryID 
		,@ConcessionaryName = ConcessionaryName
FROM	[Config].[Table] WITH(NOLOCK)


INSERT	@TicketList(TicketCode) 
VALUES (@TicketCode)
	
INSERT	@Tickets
EXEC	dbo.GetRemoteTickets
		@LOCALConcessionaryID = @ConcessionaryID
		,@LOCALClubID = '1000296'
		,@LOCALTicketList = @TicketList
		,@LOCALFromDate = @ServerTime_FIRST
		,@LOCALToDate = @ServerTime_LAST
		,@LOCALIsMhx = 0
		,@ReturnMessage = NULL

SELECT * FROM @Tickets

SELECT * FROM dbo.VTodayErrorLog ORDER BY ErrorTime DESC

