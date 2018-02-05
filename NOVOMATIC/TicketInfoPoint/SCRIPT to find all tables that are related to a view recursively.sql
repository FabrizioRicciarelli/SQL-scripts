-- Find all tables that are related to a view recursively

DECLARE 
		@SQL Nvarchar(MAX)
		,@RawDataDBname sysname = 'GMATICA_AGS_RawData'
		,@RawDataTable sysname = 'RawData_View'
		,@ClubID varchar(10) = '1000002'

SET @SQL =	REPLACE(
			N'
			WITH deps ( parent, child ) 
			AS ( 
				SELECT 
						v.name
						,sed.referenced_entity_name
				 FROM   $.[sys].[sql_expression_dependencies] sed
						INNER JOIN 
						$.[sys].[views] v 
						ON sed.referencing_id = v.object_id
				 WHERE  v.name = ISNULL(''[' + @ClubID + '].[' + @RawDataTable + ']'', v.name)
				 UNION ALL
				 SELECT	
						v.name
						,sed.referenced_entity_name
				 FROM   $.[sys].[sql_expression_dependencies] sed
						INNER JOIN 
						$.[sys].[views] v 
						ON sed.referencing_id = v.object_id
						INNER JOIN 
						deps ON deps.child = v.name 
			) 
			SELECT   
					parent
					,child 
			FROM	deps 
			ORDER BY 
					parent
					,child;
			',
			'$',
			'[' + @RawDataDBname +']'
		)

PRINT(@SQL)
EXEC(@SQL) AT [POM-MON01] 

