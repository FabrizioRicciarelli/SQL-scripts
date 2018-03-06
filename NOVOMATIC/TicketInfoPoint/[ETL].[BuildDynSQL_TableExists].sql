/*
SELECT [ETL].[BuildDynSQL_TableExists] ('AGS_RawData_01','RawData','1000004') AS DynSQL
SELECT [ETL].[BuildDynSQL_TableExists] ('GMATICA_AGS_RawData','RawData_View','1000002') AS DynSQL

DECLARE @SQL Nvarchar(MAX)
SET @SQL = REPLACE([ETL].[BuildDynSQL_TableExists] ('GMATICA_AGS_RawData','RawData_View','1000002'), CHAR(39)+CHAR(39), CHAR(39))
PRINT(@SQL)
EXEC(@SQL) AT [POM-MON01] 
*/
ALTER FUNCTION [ETL].[BuildDynSQL_TableExists] (
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
		SELECT	TableExists =
				CASE
					WHEN	EXISTS(
								SELECT	TOP 1
										TBL.schema_id
								FROM	$.[sys].[tables] TBL WITH(NOLOCK)            
										INNER JOIN             
										$.[sys].[schemas] SCH WITH(NOLOCK)             
										ON TBL.schema_id = SCH.schema_id
								WHERE	TBL.name = ''''' + @RawDataTable + '''''
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