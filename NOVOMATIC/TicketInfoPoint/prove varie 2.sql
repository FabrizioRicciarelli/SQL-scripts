/*
DECLARE @returnValue xml
SELECT @returnValue = CAST((SELECT * FROM OPENQUERY([POM-MON01],'
SELECT * FROM OPENQUERY([GMatica_PIN01\DW],''
	SELECT	TOP 10000 
			*
	FROM	[AGS_RawData].[1000114].[RawData_View] WITH(NOLOCK)
	WHERE	(ServerTime BETWEEN ''''20151101'''' AND ''''20151130'''')
	AND		MachineID IN (2,20,26,27)
	'')
') FOR XML RAW('XRD'),TYPE) AS Nvarchar(MAX))

SELECT @returnValue

DECLARE @returnValue xml
SELECT @returnValue = CAST((SELECT * FROM OPENQUERY([POM-MON01],'
	SELECT	
			COUNT(*) AS Rows
			,MIN(ServerTime) AS MinDate
			,MAX(ServerTime) AS MaxDate
	FROM	[GMATICA_AGS_RawData_01].[1000002].[RawData] WITH(NOLOCK)
') FOR XML RAW('DATES'),TYPE) AS Nvarchar(MAX))

SELECT @returnValue
*/
DECLARE @SQL Nvarchar(MAX)

SET @SQL = 
N'
SELECT TableInfo =      
	CASE       
		WHEN	EXISTS(
					SELECT	TOP 1
							name
					FROM	sys.databases
					WHERE	name = ''AGS_RawData_01''
				)
		AND		EXISTS(          
					SELECT	TOP 1           
							TBL.schema_id          
					FROM	[AGS_RawData_01].[sys].[tables] TBL WITH(NOLOCK)                        
							INNER JOIN                         
							[AGS_RawData_01].[sys].[schemas] SCH WITH(NOLOCK)                         
							ON TBL.schema_id = SCH.schema_id            
							INNER JOIN            
							[AGS_RawData_01].[sys].[dm_db_partition_stats] PS WITH(NOLOCK)            
							ON TBL.object_id = PS.object_id                    
					WHERE	TBL.name = ''RawData''                     
					AND		SCH.Name = ''1000004''                  
				)       
		THEN	(          
					SELECT  1          
					--		CAST(SUM(I.RowsCount) AS varchar(15)) + CHAR(44) +                  
					--		CONVERT(varchar(26), MAX(I.MinDate), 120) + CHAR(44) +                  
					--		CONVERT(varchar(26), MAX(I.MaxDate), 120)              
					--FROM(                    
					--	SELECT	TOP 1             
					--			PS.row_count AS RowsCount             
					--			,NULL AS MinDate             
					--			,NULL AS MaxDate           
					--	FROM	[AGS_RawData_01].[sys].[tables] TBL WITH(NOLOCK)                         
					--			INNER JOIN                          
					--			[AGS_RawData_01].[sys].[schemas] SCH WITH(NOLOCK)                          
					--			ON TBL.schema_id = SCH.schema_id             
					--			INNER JOIN             
					--			[AGS_RawData_01].[sys].[dm_db_partition_stats] PS WITH(NOLOCK)             
					--			ON TBL.object_id = PS.object_id                     
					--	WHERE	TBL.name = ''RawData''                      
					--	AND		SCH.Name = ''1000004''                    
					--	AND		PS.index_id < 2           
					--	UNION ALL           
					--	SELECT             
					--			NULL AS RowsCount             
					--			,MIN(ServerTime) AS MinDate             
					--			,MAX(ServerTime) AS MaxDate           
					--	FROM	[AGS_RawData_01].[1000004].[RawData]          
					--) I         
				)       
		ELSE NULL       
	END    
'
SET @SQL = 'SELECT * FROM OPENQUERY([GMATICA_PIN01\DW],''' + REPLACE(@SQL,CHAR(39), CHAR(39)+CHAR(39)) + ''')'
PRINT(@SQL)
EXEC(@SQL) AT [POM-MON01]
