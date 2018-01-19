/*
EXEC DeleteTodayOperationLog
*/
CREATE PROC dbo.DeleteTodayOperationLog
AS
DELETE 
FROM	[ETL].[OperationLog]
WHERE	YEAR(OperationTime) = YEAR(GETDATE())
AND		MONTH(OperationTime) = MONTH(GETDATE())
AND		DAY(OperationTime) = DAY(GETDATE())

