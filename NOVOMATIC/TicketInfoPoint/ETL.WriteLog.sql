/*
*/
ALTER PROC	ETL.WriteLog
			@procID int = NULL
			,@Msg varchar(1000) = NULL
			,@TicketCode varchar(50) = NULL
			,@BatchID int = NULL
AS
INSERT ETL.Operationlog 
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
			