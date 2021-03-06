/*
DECLARE @JSDATA nvarchar(MAX)
EXEC ETL.[GetDetailSessionDeltaJSON] @requestDetailId=10,@JSONDATA=@JSDATA OUTPUT
SELECT @JSDATA AS JSONDATA
*/
ALTER PROC [ETL].[GetDetailSessionDeltaJSON]
			@requestDetailId int = NULL
			,@JSONdata nvarchar(MAX) OUTPUT
AS
BEGIN TRY
	IF ISNULL(@requestDetailId,0) > 0
		BEGIN
			SELECT @JSONDATA = dbo.FlattenedJSON(
				(
				SELECT
						 requestDetailId AS 'Detail.requestDetailId'
						,requestId AS 'Detail.requestId'
						,ticket AS 'Detail.ticket'
						,clubId AS 'Detail.clubId'
						,ticketDirection AS 'Detail.ticketDirection'
						,univocalLocationCode AS 'Detail.univocalLocationCode' 
						,elabStart AS 'Detail.elabStart'
						,elabEnd AS 'Detail.elabEnd'
						,detailStatusId AS 'Detail.detailStatusId'
						,fileNameSession AS 'Detail.fileNameSession'
						,fileNameDelta AS 'Detail.fileNameDelta'
						,fileNameOperationLog AS 'Detail.fileNameOperationLog'
						,fileNameErrorLog AS 'Detail.fileNameErrorLog'
						,system_date AS 'Detail.system_date'
						,Session =
						(
							SELECT	*
							FROM	[ETL].[vSessionDeltaJSON] S
							WHERE	S.StartTicketCode = D.ticket
							--ORDER BY S.Level
							--FOR JSON PATH 
							ORDER BY S.Level
							FOR		XML AUTO, ROOT('root'), TYPE, ELEMENTS
							--FOR JSON PATH 
						)
				FROM	ETL.requestDetail D WITH(NOLOCK)
				WHERE	requestDetailId = @requestDetailId
				--FOR JSON PATH, WITHOUT_ARRAY_WRAPPER 
				FOR		XML AUTO, ROOT('root'), TYPE, ELEMENTS
			)
		)
		END
END TRY

BEGIN CATCH 
    SELECT
			ERROR_NUMBER() AS ErrorNumber
			,ERROR_SEVERITY() AS Severity
			,ERROR_STATE() AS ErrorState
			,ISNULL(ERROR_PROCEDURE(), ISNULL(dbo.GetProcName(@@PROCID),'*Unknown*')) AS ErrorProcedure  
			,ERROR_LINE() AS ProcedureLine
			,ERROR_MESSAGE() As ErrorMessage
END CATCH 
