/*
*/
ALTER PROC	[ETL].[WriteLog]
			@procID int = NULL
			,@Msg varchar(1000) = NULL
			,@TicketCode varchar(50) = NULL
			,@BatchID int = NULL
AS
BEGIN TRY
	INSERT	ETL.Operationlog 
			(
				OperationTime
				,ProcedureName 
				,OperationMsg
				,OperationTicketCode
				,OperationRequestDetailID
			)
	SELECT	
			GETDATE() AS OperationTime 
			,dbo.GetProcName(@procID) AS ProcedureName
			,@Msg AS OperationMsg 
			,@TicketCode AS OperationTicketCode 
			,@BatchID AS OperationRequestDetailID
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
			