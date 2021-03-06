/*
EXEC [ETL].[FillTestDataRequestMasterDetail]

SELECT * FROM [ETL].[Request]
SELECT * FROM [ETL].[RequestDetail]
SELECT * FROM [ETL].[Session]
SELECT * FROM [ETL].[Delta]
*/
ALTER PROC [ETL].[FillTestDataRequestMasterDetail]
AS

DELETE FROM ETL.requestDetail
DELETE FROM ETL.request
TRUNCATE TABLE ETL.requestDetail
DROP TABLE ETL.Session
DROP TABLE ETL.Delta

SELECT	* 
INTO	ETL.Session
FROM	ETL.Session_OK

SELECT	* 
INTO	ETL.Delta
FROM	ETL.Delta_OK

INSERT	ETL.request 
		(
			requestDesc
			,requestClaimantId
			,requestStatusId
			,elabStart
			,elabEnd
			,system_date
			,ConcessionaryID
			,ClubID
			,TipoRichiesta
		)
SELECT 
		dbo.CurrentYMD(NULL) + '_' + dbo.CurrentHM(NULL) + dbo.PadLeft(CAST(ROW_NUMBER() OVER(ORDER BY S.requestDetailId) AS varchar(5)),2,'0') AS requestDesc --+ '#' + S.StartTicketCode AS requestDesc
		,10 AS requestClaimantId
		,5 AS requestStatusId
		,elabStart = CAST(dbo.CurrentYMD('-') + ' ' + dbo.CurrentHM(':') + ':' + dbo.PadLeft(CAST(dbo.RndGen(1,20) AS varchar(5)),2,'0') AS datetime)
		,elabEnd = CAST(dbo.CurrentYMD('-') + ' ' + dbo.CurrentHM(':') + ':' + dbo.PadLeft(CAST(dbo.RndGen(21,59) AS varchar(5)),2,'0') AS datetime)
		,GETDATE() AS system_date
		,3 AS ConcessionaryID
		,S.requestDetailId AS ClubID
		,1 AS TipoRichiesta
FROM	
(
	SELECT	DISTINCT
			requestDetailId
	FROM	[ETL].[Session] WITH(NOLOCK)
) S

INSERT	ETL.requestDetail
		(
			requestId
			,ticket
			,clubId
			,ticketDirection
			,detailStatusId
			,system_date
		)
SELECT	distinct
		R.requestId
		,S.StartTicketCode AS ticket
		,R.ClubID AS clubid
		,dbo.RndGen(0,1) AS ticketDirection
		,3 AS detailStatusId
		,GETDATE() AS system_date
FROM	ETL.request R WITH(NOLOCK)
		INNER JOIN
		(
			SELECT	DISTINCT	
					StartTicketCode
					,requestDetailId
			FROM	ETL.Session WITH(NOLOCK)
			WHERE	SessionParentID IS NULL
		) S
		ON R.ClubID = S.requestDetailId
ORDER BY requestId
		
UPDATE	ETL.Session
SET		requestDetailID = D.requestDetailID
FROM	ETL.Session S
		INNER JOIN
		ETL.requestDetail D
		ON S.requestDetailID = D.ClubId

UPDATE	ETL.Delta
SET		requestDetailID = D.requestDetailID
FROM	ETL.Delta L
		INNER JOIN
		ETL.requestDetail D
		ON L.requestDetailID = D.ClubId
		 
