-- Find all tables that are related to a view recursively
DECLARE
		@tables TABLE(tableName Nvarchar(MAX))
DECLARE 
		@SQL Nvarchar(MAX)
		,@OUTERMOSTSQL  Nvarchar(MAX)
		,@RawDataDBname sysname = 'GMATICA_AGS_RawData'
		,@RawDataTable sysname = 'RawData_View'
		,@ClubID varchar(10) = '1000002'
		,@xmlTABLES varchar(MAX)

-- CICLO DI ESTRAZIONE DEI NOMI DELLE TABELLE REFERENZIATE
-- ALL'INTERNO DI UNA VISTA E, PER CIASCUNA DI QUESTE 
-- ESTRAZIONE DEL NUMERO DI RIGHE DI CUI SONO COMPOSTE
-- TRAMITE METODO FASTCOUNT

SET @SQL =	REPLACE(
			N'
			SELECT CAST( 
				(
					SELECT	DEP.referenced_database_name + CHAR(46) + DEP.referenced_schema_name + CHAR(46) + DEP.referenced_entity_name AS TableName
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
					AND		DEP.referenced_schema_name = ''' + @ClubID + '''
					FOR		XML RAW(''Tables''), TYPE
				) AS varchar(MAX)
			)
			',
			'$',
			'[' + @RawDataDBname +']'
		)

PRINT(@SQL)
SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@SQL)
EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue varchar(MAX) OUT', @returnValue=@xmlTABLES OUT
SELECT CAST(@xmlTABLES AS XML)
/*	
SET @SQL =	REPLACE(
			N'
			SELECT	ISNULL(PS.row_count,0)
			FROM	$.[sys].[tables] TBL WITH(NOLOCK)            
					INNER JOIN             
					$.[sys].[schemas] SCH WITH(NOLOCK)             
					ON TBL.schema_id = SCH.schema_id
					INNER JOIN
					$.[sys].[dm_db_partition_stats] PS WITH(NOLOCK)
					ON TBL.object_id = PS.object_id          
			WHERE	TBL.name = ''' + @RawDataTable + '''           
			AND		SCH.Name = ''' + @ClubID + '''         
			AND		PS.index_id < 2
			',
			'$',
			'[' + @RawDataDBname +']'
		)

PRINT(@SQL)
EXEC(@SQL) AT [POM-MON01] 

*/