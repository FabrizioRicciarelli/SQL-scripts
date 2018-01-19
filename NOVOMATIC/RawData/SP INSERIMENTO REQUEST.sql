USE AGS_RawData_Elaborate_Stag_Agile;
/*
EXEC	dbo.StartElaborationRequest
		@ClaimantID = 2 -- 2 = Giampiero Andrenacci
		,@ConcessionaryID = 4
		,@lowerLimit = 5
		,@upperLimit = 10
*/
CREATE PROC dbo.StartElaborationRequest
			@ClaimantID int = NULL
			,@ConcessionaryID tinyInt = NULL
			,@lowerLimit int = NULL
			,@upperLimit int = NULL
AS
IF ISNULL(@ClaimantID,0) != 0
AND	ISNULL(@ConcessionaryID,0) != 0
AND	ISNULL(@lowerLimit,0) != 0
AND ISNULL(@upperLimit,0) != 0
DECLARE	@TicketList [ETL].[TicketTbl] -- UDTT, User Defined Table Type
DECLARE	
		@ClaimantName Nvarchar(150)
		,@ClaimantEmail Nvarchar(255)
		,@ClaimantFolder Nvarchar(255)
		,@Info varchar(MAX)

SELECT	TOP 1
		@ClaimantName requestClaimantName
		,@ClaimantEmail requestClaimantEmail
		,@ClaimantFolder requestClaimantFolder
FROM	[ETL].[requestClaimant] WITH(NOLOCK)
WHERE	requestClaimantID = @ClaimantID

IF ISNULL(@ClaimantName,'') != ''
AND ISNULL(@ClaimantEmail,'') != ''
AND ISNULL(@ClaimantFolder,'') != ''
	BEGIN
		EXEC	[ETL].[InsertClaimant]
				@requestClaimantName = @ClaimantName
				,@requestClaimantEmail = @ClaimantEmail
				,@requestClaimantFolder = @ClaimantFolder
				,@requestClaimantID = @ClaimantID OUTPUT

		SELECT	@ClaimantID AS N'@requestClaimantID'

		-- INSERIMENTO RICHIESTA
		INSERT	@TicketList(Ticket, ClubID, ticketDirection) 
		SELECT 
				TicketID AS Ticket
				,NULL AS ClubID
				,1 AS ticketDirection
		FROM	[RAW].[TTForwardIN] WITH(NOLOCK)
		WHERE	(Riga BETWEEN @lowerLimit AND @upperLimit)


		SELECT	*
		FROM	@TicketList

		EXEC	[ETL].[InsertRequest] 
				@requestClaimantId = @ClaimantID
				,@requestDesc = 'Gdf'
				,@requestDetails = @TicketList
				,@ConcessionaryID = @ConcessionaryID		
	
		SET @info =
		'
		Richiesta inserita.

		E'' ora possibile monitorare lo stato dell''elaborazione invocando la presente stored procedure:
		
		EXEC	dbo.CheckElaborationRequestStatus
				@lowerLimit = ' + CAST(@lowerLimit AS varchar(6)) + '
				,@upperLimit = ' + CAST(@lowerLimit AS varchar(6)) + '
		'

	END
GO

/*
EXEC	dbo.CheckElaborationRequestStatus
		@lowerLimit = 5
		,@upperLimit = 1000
*/
CREATE PROC dbo.CheckElaborationRequestStatus
			@lowerLimit int = NULL
			,@upperLimit int = NULL
AS
IF ISNULL(@lowerLimit,0) != 0
AND ISNULL(@upperLimit,0) != 0
	BEGIN
		SELECT	
				RD.RequestDetailID
				,RD.RequestId
				,RD.Ticket
				,RD.ticketDirection AS Direction
				,RD.ElabStart AS StartedON
				,RD.ElabEnd AS FinishedAT
				,RD.DetailStatusID
				,RD.FileName
		FROM	[ETL].[RequestDetail] RD WITH(NOLOCK)
				INNER JOIN
				[RAW].[TTForwardIN] TT WITH(NOLOCK)
				ON RD.ticket = TT.TicketID
				AND (TT.Riga BETWEEN @lowerLimit AND @upperLimit)
		ORDER BY RD.requestDetailID
	END
