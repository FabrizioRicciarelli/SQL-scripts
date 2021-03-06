/*
SELECT * FROM VTodayErrorLog ORDER BY ErrorTime DESC
*/
CREATE VIEW dbo.VTodayErrorLog
AS
SELECT 
		ErrorProcedure
		,ErrorMessage
		,ErrorLine
		,ErrorTime
		,ErrorTicketCode
		,ErrorRequestDetailID
		,ErrorState
		,ErrorNumber
		,ErrorSeverity
FROM	[ERR].[ErrorLog] WITH(NOLOCK)
WHERE	YEAR(ErrorTime) = YEAR(GETDATE())
AND		MONTH(ErrorTime) = MONTH(GETDATE())
AND		DAY(ErrorTime) = DAY(GETDATE())

