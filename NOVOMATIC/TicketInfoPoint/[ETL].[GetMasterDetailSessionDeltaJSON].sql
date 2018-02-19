/*
DECLARE @JSDATA nvarchar(MAX)
EXEC ETL.GetMasterDetailSessionDeltaJSON @requestId=169,@JSONDATA=@JSDATA OUTPUT
SELECT @JSDATA AS JSONDATA
*/
ALTER PROC [ETL].[GetMasterDetailSessionDeltaJSON]
			@requestId int = NULL
			,@JSONdata nvarchar(MAX) OUTPUT
AS
IF ISNULL(@requestId,0) > 0
	BEGIN
		DECLARE @TicketDirectionDesc TABLE 
				(
					ticketDirection bit
					,ticketDirectionDesc varchar(20)
				)
		INSERT	@TicketDirectionDesc(ticketDirection, ticketDirectionDesc)
		VALUES	(0, 'Backward'), (1, 'Forward')

		-- SELECT @JSONDATA = 
		SELECT @JSONDATA = dbo.FlattenedJSON(
			(
				SELECT 	 TOP 1
						 R.requestId AS 'Master.requestId'
						,R.requestDesc AS 'Master.requestDesc'
						,R.requestClaimantId AS 'Master.requestClaimantId'
						,R.elabStart AS 'Master.elabStart'
						,R.elabEnd AS 'Master.elabEnd'
						,R.requestStatusId AS 'Master.requestStatusId'
						,RSS.requestStatusDesc AS 'Master.requestStatusDesc'
						,R.system_date AS 'Master.system_date'
						,R.ConcessionaryID AS 'Master.ConcessionaryID'
						,R.ClubID AS 'Master.ClubID'
						,R.FilterAmount AS 'Master.FilterAmount'
						,R.FilterStartDate AS 'Master.FilterStartDate'
						,R.FilterEndDate AS 'Master.FilterEndDate'
						,R.TipoRichiesta AS 'Master.TipoRichiesta'
						,Detail = dbo.FlattenedJSON (
							(
								SELECT
										D.requestDetailId
										,D.requestId
										,D.ticket
										,D.clubId
										,D.ticketDirection
										,TD.ticketDirectionDesc
										,D.univocalLocationCode 
										,D.elabStart
										,D.elabEnd
										,D.detailStatusId
										,RS.requestDetailStatusDesc
										,D.fileNameSession
										,D.fileNameDelta
										,D.fileNameOperationLog
										,D.fileNameErrorLog
										,D.system_date
										,Session = dbo.FlattenedJSON (
											(
												SELECT	*
												FROM	[ETL].[vSessionDeltaJSON] S
												WHERE	S.StartTicketCode = D.ticket
												ORDER BY S.Level
												FOR		XML AUTO, ROOT('root'), TYPE, ELEMENTS
												--FOR JSON PATH 
											)
										)
								FROM	ETL.requestDetail D WITH(NOLOCK)
										INNER JOIN 
										@TicketDirectionDesc TD
										ON D.ticketDirection = TD.ticketDirection
										INNER JOIN
										ETL.requestDetailStatus RS WITH(NOLOCK)
										ON D.detailStatusId = RS.requestDetailStatusId
								WHERE	R.requestId = D.requestId
								FOR		XML AUTO, ROOT('root'), TYPE, ELEMENTS
								--FOR JSON PATH 
							)
						)
				FROM	ETL.request R WITH(NOLOCK)
						INNER JOIN
						ETL.requestStatus RSS WITH(NOLOCK)
						ON R.requestStatusId = RSS.requestStatusId
				WHERE	R.requestId = @requestId
				FOR		XML AUTO, ROOT('root'), TYPE, ELEMENTS
				--FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			)
		)
		
	END
