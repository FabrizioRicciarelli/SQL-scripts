/*
SELECT * FROM ETL.vRequestDetail
WHERE requestId=180
*/
ALTER VIEW [ETL].[vRequestDetail]
AS
SELECT	
		 RD.requestDetailId
		,RD.requestId
		,RD.ticket
		,RD.clubId
		,RD.ticketDirection
		,RD.univocalLocationCode
		,RD.elabStart
		,RD.elabEnd
		,RD.detailStatusId
		,RS.requestStatusDesc
		,RD.fileNameSession
		,RD.fileNameDelta
		,RD.fileNameOperationLog
		,RD.fileNameErrorLog
		,RD.system_date
FROM	ETL.RequestDetail RD WITH(NOLOCK)
		LEFT JOIN
		ETL.RequestStatus RS WITH(NOLOCK)
		ON RD.detailStatusId = RS.requestStatusId
GO


