/*
SELECT [ETL].[BuildDynSQL_DBExists] ('AGS_RawData_01') AS DynSQL
*/
CREATE FUNCTION [ETL].[BuildDynSQL_DBExists] (
				@RawDataDBname sysname
)
RETURNS Nvarchar(MAX)
AS
BEGIN
	DECLARE @retVal Nvarchar(MAX)
	SET @retVal = 
	N'
	SELECT	bitValue =
			CASE
				WHEN	EXISTS(
							SELECT	TOP 1
									name
							FROM	sys.databases
							WHERE	name = ''''' + @RawDataDBname + '''''
						)
				THEN	1
				ELSE	0
			END
	'
	
	RETURN @retVal
END