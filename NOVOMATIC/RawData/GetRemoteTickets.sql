/*
DECLARE	@lista TICKETLIST_TYPE
INSERT	@lista (TicketCode)
VALUES	('4412211590049855')

EXEC	dbo.GetRemoteTickets
		 @LOCALConcessionaryID = 7
		,@LOCALClubID = '1000296'
		,@LOCALTicketList = @lista
		,@LOCALFromDate = '1900-01-01 00:00:00.000'
		,@LOCALToDate = '2050-12-31 00:00:00.000'
		,@LOCALIsMhx = 1
		,@ReturnMessage = NULL


DECLARE	@lista TICKETLIST_TYPE
INSERT	@lista (TicketCode)
VALUES	('4412211590049855')
		,('4410150034342200')
		,('4410149795967566')
		,('4409462773233281')
		,('4408088184213495')

EXEC	dbo.GetRemoteTickets
		 @LOCALConcessionaryID = 7
		,@LOCALClubID = '1000296'
		,@LOCALTicketList = @lista
		,@LOCALFromDate = '2016-01-01 00:00:00.000'
		,@LOCALToDate = '2016-12-31 00:00:00.000'
		,@LOCALIsMhx = 1
		,@LOCALBatchID = NULL
		,@ReturnMessage = NULL
*/
ALTER PROC	[dbo].[GetRemoteTickets]
			 @LOCALConcessionaryID tinyint = NULL
			,@LOCALClubID varchar(10) = NULL
			,@LOCALTicketList TICKETLIST_TYPE READONLY
			,@LOCALFromDate datetime = NULL
			,@LOCALToDate datetime = NULL
			,@LOCALIsMhx Bit = 1
			,@LOCALBatchID int = NULL
			,@ReturnMessage varchar(1000) = NULL OUTPUT
AS
SET NOCOUNT ON;

DECLARE
		@SQL Nvarchar(MAX)
		,@ticketList Nvarchar(MAX)
		,@params Nvarchar(MAX)

SELECT	@ticketList = COALESCE(@ticketList, '') + '(' + QUOTENAME(TicketCode,CHAR(39)) + '),'
FROM	@LOCALTicketList
SELECT	@ticketList = LEFT(@ticketList, LEN(@ticketList) - 1)

SELECT @LOCALIsMhx = ISNULL(@LOCALIsMhx,0)

SELECT @params =	'@TicketList = @lista '
SELECT @params +=	CASE WHEN ISNULL(@LOCALConcessionaryID, 0) != 0	THEN ',@ConcessionaryID = '	+ CAST (@LOCALConcessionaryID AS varchar(3)) ELSE '' END
SELECT @params +=	CASE WHEN ISNULL(@LOCALClubID, '') != ''		THEN ',@ClubID = '			+ QUOTENAME(@LOCALClubID, CHAR(39)) ELSE '' END
SELECT @params +=	CASE WHEN ISNULL(@LOCALFromDate, '') != ''		THEN ',@FromDate = '		+ QUOTENAME(@LOCALFromDate, CHAR(39)) ELSE '' END
SELECT @params +=	CASE WHEN ISNULL(@LOCALToDate, '') != ''		THEN ',@ToDate = '			+ QUOTENAME(@LOCALToDate, CHAR(39)) ELSE '' END
SELECT @params +=	CASE WHEN ISNULL(@LOCALIsMhx ,0) != 0			THEN ',@IsMhx = '			+ CAST (@LOCALIsMhx AS char(1)) ELSE '' END
SELECT @params +=	CASE WHEN ISNULL(@LOCALBatchID, 0) != 0			THEN ',@BatchID = '			+ CAST (@LOCALBatchID AS varchar(5)) ELSE '' END
SELECT @params +=	',@ReturnMessage = NULL'

SELECT @SQL = 
N'
USE Staging;

DECLARE	@lista dbo.TICKETLIST_TYPE
INSERT	@lista (TicketCode) VALUES ' + @ticketList + '
EXEC	Ticket.spGetTickets ' + @params

--PRINT(@SQL)
EXEC [POM-MON01].[Staging].[dbo].sp_executesql @SQL -- Equivalente della EXEC(@SQL) AT [POM-MON01], ma con un utilizzo migliore del piano di esecuzione