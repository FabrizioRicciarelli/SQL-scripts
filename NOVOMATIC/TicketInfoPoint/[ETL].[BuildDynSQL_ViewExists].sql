/*
SELECT [ETL].[BuildDynSQL_ViewExists] ('AGS_RawData_01','RawData','1000004') AS DynSQL
SELECT [ETL].[BuildDynSQL_ViewExists] ('GMATICA_AGS_RawData_01','RawData_View','1000002') AS DynSQL

DECLARE @SQL Nvarchar(MAX)
SET @SQL = REPLACE([ETL].[BuildDynSQL_ViewExists] ('GMATICA_AGS_RawData','RawData_View','1000002'), CHAR(39)+CHAR(39), CHAR(39))
PRINT(@SQL)
EXEC(@SQL) AT [POM-MON01] 
*/
ALTER FUNCTION [ETL].[BuildDynSQL_ViewExists] (
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
		SELECT	ViewExists =
				CASE
					WHEN	EXISTS(
								SELECT	TOP 1
										VIW.schema_id
								FROM	$.[sys].[views] VIW WITH(NOLOCK)            
										INNER JOIN             
										$.[sys].[schemas] SCH WITH(NOLOCK)             
										ON VIW.schema_id = SCH.schema_id
								WHERE	VIW.name = ''''' + @RawDataTable + '''''
								AND		SCH.Name = ''''' + @ClubID + '''''         
							)
					THEN	1
					ELSE	0
				END
		',
		'$',
		'[' + @RawDataDBname +']'
	)
	
	RETURN @retVal
END