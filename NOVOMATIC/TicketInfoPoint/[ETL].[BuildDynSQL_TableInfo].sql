/*
SELECT [ETL].[BuildDynSQL_TableInfo] ('AGS_RawData_01','RawData','1000004') AS DynSQL
SELECT [ETL].[BuildDynSQL_TableInfo] ('GMATICA_AGS_RawData_01','RawData_View','1000002') AS DynSQL

DECLARE @SQL Nvarchar(MAX)
SET @SQL = REPLACE([ETL].[BuildDynSQL_TableInfo] ('GMATICA_AGS_RawData','RawData_View','1000002'), CHAR(39)+CHAR(39), CHAR(39))
PRINT(@SQL)
EXEC(@SQL) AT [POM-MON01] 
*/
ALTER FUNCTION [ETL].[BuildDynSQL_TableInfo] (
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
		SELECT	TableInfo =
				CAST(SUM(I.RowsCount) AS varchar(15)) + CHAR(44) +      
				CONVERT(varchar(26), MAX(I.MinDate), 120) + CHAR(44) +      
				CONVERT(varchar(26), MAX(I.MaxDate), 120)    
		FROM (
			SELECT	TOP 1
					PS.row_count AS RowsCount
					,NULL AS MinDate
					,NULL AS MaxDate
			FROM	$.[sys].[tables] TBL WITH(NOLOCK)            
					INNER JOIN             
					$.[sys].[schemas] SCH WITH(NOLOCK)             
					ON TBL.schema_id = SCH.schema_id
					INNER JOIN
					$.[sys].[dm_db_partition_stats] PS WITH(NOLOCK)
					ON TBL.object_id = PS.object_id          
			WHERE	TBL.name = ''''' + @RawDataTable + '''''           
			AND		SCH.Name = ''''' + @ClubID + '''''         
			AND		PS.index_id < 2
			UNION ALL
			SELECT
					NULL AS	RowsCount
					,MIN(ServerTime) AS MinDate
					,MAX(ServerTime) AS MaxDate
			FROM	$.[' + @ClubID + '].[' + @RawDataTable + ']
		) I
		',
		'$',
		'[' + @RawDataDBname +']'
	)
	RETURN @retVal
END