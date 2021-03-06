/*
SELECT [ETL].[BuildDynSQL_ViewTables] ('AGS_RawData_01','1000296') AS DynSQL
SELECT [ETL].[BuildDynSQL_ViewTables] ('GMATICA_AGS_RawData_01','1000002') AS DynSQL

DECLARE @SQL Nvarchar(MAX)
SET @SQL = REPLACE([ETL].[BuildDynSQL_TableInfo] ('GMATICA_AGS_RawData','RawData','1000002'), CHAR(39)+CHAR(39), CHAR(39))
PRINT(@SQL)
EXEC(@SQL) AT [POM-MON01] 
*/
ALTER FUNCTION [ETL].[BuildDynSQL_ViewTables] (
				@RawDataDBname sysname
				,@ClubID varchar(10)
)
RETURNS Nvarchar(MAX)
AS
BEGIN
	DECLARE @retVal Nvarchar(MAX)
	SET @retVal = REPLACE(
		N'
		SELECT CAST( 
			(
				SELECT	TOP 10
						DEP.referenced_database_name + CHAR(46) + DEP.referenced_schema_name + CHAR(46) + DEP.referenced_entity_name AS FullTableName
						,DEP.referenced_database_name AS DatabaseName
						,DEP.referenced_schema_name AS SchemaName
						,DEP.referenced_entity_name AS TableName
				FROM	$.[sys].[views] V WITH(NOLOCK)
						INNER JOIN
						$.[sys].[schemas] SCH WITH(NOLOCK) 
						ON V.schema_id = SCH.schema_id
						INNER JOIN
						$.[sys].[sql_expression_dependencies] DEP WITH(NOLOCK)
						ON DEP.referenced_schema_name = SCH.name
				WHERE	DEP.referencing_class = 1 -- OBJECT_OR_COLUMN 
				AND		DEP.referenced_database_name IS NOT NULL -- INCLUDE SOLO LE VISTE CROSS-DATABASE
				AND		DEP.referenced_server_name IS NULL -- EVITA LE DIPENDENZE CROSS-LINKED SERVER
				AND		DEP.referenced_schema_name = ''''' + @ClubID + '''''
				FOR		XML RAW(''''Tables''''), TYPE
			) AS varchar(MAX)
		)
		',
		'$',
		'[' + @RawDataDBname +']'
	)
	RETURN @retVal
END