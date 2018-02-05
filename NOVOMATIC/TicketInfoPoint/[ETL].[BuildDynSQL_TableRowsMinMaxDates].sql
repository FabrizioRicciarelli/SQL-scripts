/*
SELECT [ETL].[BuildDynSQL_TableRowsMinMaxDates] ('AGS_RawData_01','RawData','1000296') AS DynSQL
SELECT [ETL].[BuildDynSQL_TableRowsMinMaxDates] ('GMATICA_AGS_RawData_01','RawData','1000002') AS DynSQL

DECLARE @SQL Nvarchar(MAX)
SET @SQL = REPLACE([ETL].[BuildDynSQL_TableRowsMinMaxDates] ('GMATICA_AGS_RawData','RawData','1000002'), CHAR(39)+CHAR(39), CHAR(39))
PRINT(@SQL)
EXEC(@SQL) AT [POM-MON01] 
*/
ALTER FUNCTION [ETL].[BuildDynSQL_TableRowsMinMaxDates] (
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
		SELECT CAST(
			(
			SELECT	
					(
						SELECT	TOP 1 ISNULL(PS.row_count,0)
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
					) AS RowsCount
					,MIN(ServerTime) AS MinDate
					,MAX(ServerTime) AS MaxDate
			FROM	$.[' + @ClubID + '].[' + @RawDataTable + ']
			FOR		XML RAW(''''TableInfo''''), TYPE
		) AS varchar(MAX))
		',
		'$',
		'[' + @RawDataDBname +']'
	)
	RETURN @retVal
END