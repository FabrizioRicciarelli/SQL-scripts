USE [TicketInfoPoint]
GO

/****** Object:  View [ETL].[vDelta]    Script Date: 26/01/2018 13:02:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [ETL].[vDelta]
AS
--SELECT *,ROW_NUMBER() OVER(PARTITION BY SessionID ORDER BY SessionID,ServerTime) AS RowNumber
--		  FROM [RAW].[Delta]
SELECT	*
		,ROW_NUMBER() OVER(PARTITION BY SessionID ORDER BY SessionID,ServerTime) AS RowNumber
FROM	[ETL].[Delta]




GO


