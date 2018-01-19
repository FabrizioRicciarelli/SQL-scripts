/*
*/
ALTER FUNCTION dbo.GetProcName(@procID int)
RETURNS sysname
AS
BEGIN
	DECLARE @retVal sysname = NULL
	
	IF ISNULL(@procID,0) != 0
		BEGIN
			SET @retVal = Quotename(Object_schema_name(@procID)) + '.' + Quotename(Object_name(@procID))
		END
	
	RETURN @retVal
END