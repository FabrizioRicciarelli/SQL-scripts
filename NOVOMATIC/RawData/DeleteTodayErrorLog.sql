/*
EXEC DeleteTodayErrorLog
*/
CREATE PROC dbo.DeleteTodayErrorLog
AS
DELETE
FROM	[ERR].[ErrorLog]
WHERE	YEAR(ErrorTime) = YEAR(GETDATE())
AND		MONTH(ErrorTime) = MONTH(GETDATE())
AND		DAY(ErrorTime) = DAY(GETDATE())


GO


