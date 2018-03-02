DECLARE	@elabid int = 4	--4,7,12,16,82

SELECT	TicketCode 
FROM	[GMATICA_AGS_RawData_Elaborate_GdF].[GDF].[Elaboration] WITH(NOLOCK) 
WHERE	ElaborationID IN(4,7,12,16,82)

SELECT	
		TicketCode
		,ElapsedTime/1000 as ElabSeconds
FROM	[GMATICA_AGS_RawData_Elaborate_GdF].[GDF].[ElaborationTime] WITH(NOLOCK) 
WHERE	TicketCode = (
			SELECT	TicketCode 
			FROM	[GMATICA_AGS_RawData_Elaborate_GdF].[GDF].[Elaboration] WITH(NOLOCK) 
			WHERE	ElaborationID = @Elabid
		)

SELECT	'Elaboration' AS TABELLA, *
FROM	[GMATICA_AGS_RawData_Elaborate_GdF].[GDF].[Elaboration] WITH(NOLOCK) 
WHERE	ElaborationID = @Elabid

SELECT	'Session' AS TABELLA, *
FROM	[GMATICA_AGS_RawData_Elaborate_GdF].[GDF].[Session] WITH(NOLOCK) 
WHERE	ElaborationID = @Elabid

SELECT	'MainSessionDetail (Delta, Level 0)' AS TABELLA, *
FROM	[GMATICA_AGS_RawData_Elaborate_GdF].[GDF].[MainSessionDetail] WITH(NOLOCK) 
WHERE	ElaborationID = @Elabid

SELECT	'OtherSessionDetail (Delta, Level 1+)' AS TABELLA, *
FROM	[GMATICA_AGS_RawData_Elaborate_GdF].[GDF].[OtherSessionDetail] WITH(NOLOCK) 
WHERE	ElaborationID = @Elabid