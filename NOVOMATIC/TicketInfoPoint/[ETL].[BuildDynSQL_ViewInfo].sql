/*
SELECT [ETL].[BuildDynSQL_ViewInfo] ('AGS_RawData_01','RawData','1000004') AS DynSQL
SELECT [ETL].[BuildDynSQL_ViewInfo] ('GMATICA_AGS_RawData_01','RawData_View','1000002') AS DynSQL

DECLARE @SQL Nvarchar(MAX)
SET @SQL = REPLACE([ETL].[BuildDynSQL_ViewInfo] ('GMATICA_AGS_RawData','RawData_View','1000002'), CHAR(39)+CHAR(39), CHAR(39))
PRINT(@SQL)
EXEC(@SQL) AT [POM-MON01] 

*/
ALTER FUNCTION [ETL].[BuildDynSQL_ViewInfo] (
				@RawDataDBname sysname
				,@RawDataTable sysname
				,@ClubID varchar(10)
)
RETURNS Nvarchar(MAX)
AS
BEGIN
	DECLARE @retVal Nvarchar(MAX)

	SET @retVal = REPLACE(
		N'
		SELECT	ViewInfo =
				CAST(COUNT_BIG(*) AS varchar(15)) + CHAR(44) +      
				CONVERT(varchar(26), MIN(ServerTime), 120) + CHAR(44) +      
				CONVERT(varchar(26), MAX(ServerTime), 120)    
		FROM	$.[' + @ClubID + '].[' + @RawDataTable + ']
		',
		'$',
		'[' + @RawDataDBname +']'
	)

	RETURN @retVal
END