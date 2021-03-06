/*
---------------------------------------------------------------------------------------------
Funzione preposta alla rappresentazione della struttura di una tabella SQL
---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------
Esempi di invocazione:

SELECT * FROM dbo.fnGetTableDef('RAW','Delta')
SELECT * FROM dbo.fnGetTableDef('RAW','Session')
SELECT * FROM dbo.fnGetTableDef('ETL','Request')
SELECT * FROM dbo.fnGetTableDef('ETL','RequestDetail')
SELECT * FROM dbo.fnGetTableDef('ETL','vConcessionary')

SELECT cSharpPublicPropertyDef AS "public class RequestClaimantDirect {" FROM dbo.fnGetTableDef('ETL','RequestClaimant')

*/
ALTER FUNCTION [dbo].[fnGetTableDef](@schema varchar(128) = NULL, @tableName varchar(128) = NULL)
RETURNS @tableDef TABLE
		(
			fieldName varchar(255)
			,variableName varchar(256)
			,castedFieldName varchar(512)
			,castedDenulledFieldName varchar(512)
			,fieldType varchar(30)
			,fullFieldType varchar(50)
			,SqlDbType varchar(30)
			,cSharpType varchar(30)
			,cSharpPrivateVariableName varchar(256)
			,cSharpPublicPropertyName varchar(256)
			,cSharpPublicPropertyDef varchar(512)
			,typeScript varchar(512)
			,Ng2SmartTableSettingsColumn varchar(512)
			,Ng2SmartTableFilterColumn varchar(512)
			,Ng2SmartTableArrayPushColumn varchar(512)
			,fieldLength smallint
			,stringFieldLength smallint
			,fieldIsNullable bit
			,fieldIsIdentity bit
			,fieldIsKey bit
			,fieldPrecision tinyint
			,fieldScale tinyint
			,randomData varchar(max)
		)
AS
BEGIN
	IF ISNULL(@tableName,'') != ''
		BEGIN
			INSERT	@tableDef
					(
						fieldName
						,variableName
						,castedFieldName
						,castedDenulledFieldName
						,fieldType
						,fullFieldType
						,SqlDbType
						,cSharpType
						,cSharpPrivateVariableName
						,cSharpPublicPropertyName
						,cSharpPublicPropertyDef
						,typeScript
						,Ng2SmartTableSettingsColumn
						,Ng2SmartTableFilterColumn
						,Ng2SmartTableArrayPushColumn
						,fieldLength
						,stringFieldLength
						,fieldIsNullable
						,fieldIsIdentity
						,fieldIsKey
						,fieldPrecision
						,fieldScale
						,randomData
					)
			SELECT	
					MAIN.fieldName
					,MAIN.variableName
					,MAIN.castedFieldName
					,MAIN.castedDenulledFieldName
					,MAIN.fieldType
					,MAIN.fullFieldType
					,MAIN.SqlDbType
					,MAIN.cSharpType
					,cSharpPrivateVariableName =
						CASE
							WHEN ISNULL(IDX.is_primary_key,0) = 0
							THEN MAIN.cSharpPrivateVariableName
							ELSE MAIN.cSharpPrivateVariableName + '_PK'
						END
					,cSharpPublicPropertyName =
						CASE
							WHEN ISNULL(IDX.is_primary_key,0) = 0
							THEN MAIN.cSharpPublicPropertyName
							ELSE MAIN.cSharpPublicPropertyName + '_PK'
						END
					,cSharpPublicPropertyDef = 'public ' + MAIN.cSharpType + ' ' + MAIN.colName + ' { get; set; }'
					,MAIN.typeScript
					,Ng2SmartTableSettingsColumn = REPLACE('$field: { title: ''$field'', filter: { config: { text: ''Type to filter by $field'', selectText: ''Type to filter by $field'', } } },','$field', MAIN.colName)
					,Ng2SmartTableFilterColumn = REPLACE('{ field: ''$field'', search: '''' },','$field', MAIN.colName)
					,Ng2SmartTableArrayPushColumn= REPLACE('$field: currentRow.$field,','$field', MAIN.colName)
					,MAIN.fieldLength
					,MAIN.stringFieldLenght
					,MAIN.fieldIsNullable
					,MAIN.fieldIsIdentity
					,CAST(ISNULL(IDX.is_primary_key,0) AS BIT)  AS fieldIsKey
					,MAIN.fieldPrecision
					,MAIN.fieldScale
					,MAIN.randomData
			FROM
			(
			SELECT 
					sc.name AS colName
					,'[' + LEFT(sc.name,255) + ']' AS fieldName
					,'@' + dbo.fnCleanVariableName(LEFT(sc.name,255)) AS variableName
					,castedFieldName = 
						CASE
							WHEN st.name IN ('char', 'nchar', 'varchar', 'nvarchar')
							THEN '@' + dbo.fnCleanVariableName(LEFT(sc.name,255))
							WHEN st.name IN ('datetime')
							THEN 'CONVERT(varchar(' + CAST(sc.precision + sc.scale AS varchar(10)) + '),@' + dbo.fnCleanVariableName(LEFT(sc.name,255)) + ',120)'
							WHEN st.name IN ('int','bigint','smallint','tinyint','binary','image','decimal','money','smallmoney','time','timestamp','variant','xml','float','bit')
							THEN 'CAST(@' + dbo.fnCleanVariableName(LEFT(sc.name,255)) + ' AS varchar(' + CAST(sc.precision + sc.scale AS varchar(10)) + '))'
						END 
					,castedDenulledFieldName = 
						CASE
							WHEN st.name IN ('char', 'nchar', 'varchar', 'nvarchar') AND sc.is_nullable = 0
							THEN 'ISNULL(@' + dbo.fnCleanVariableName(LEFT(sc.name,255)) + ',' + ''''')'
							WHEN st.name IN ('char', 'nchar', 'varchar', 'nvarchar') AND sc.is_nullable = 1
							THEN '@' + dbo.fnCleanVariableName(LEFT(sc.name,255))
							WHEN st.name IN ('datetime', 'datetime2') AND sc.is_nullable = 0
							THEN 'ISNULL(CONVERT(varchar(' + CAST(sc.precision + sc.scale AS varchar(10)) + '),@' + dbo.fnCleanVariableName(LEFT(sc.name,255)) + ',120), GETDATE())'
							WHEN st.name IN ('datetime','datetime2') AND sc.is_nullable = 1
							THEN 'CONVERT(varchar(' + CAST(sc.precision + sc.scale AS varchar(10)) + '),@' + dbo.fnCleanVariableName(LEFT(sc.name,255)) + ',120)'
							WHEN st.name IN ('int','bigint','smallint','tinyint','binary','image','decimal','money','smallmoney','time','timestamp','variant','xml','float','bit') AND sc.is_nullable = 0
							THEN 'ISNULL(CAST(@' + dbo.fnCleanVariableName(LEFT(sc.name,255)) + ' AS varchar(' + CAST(sc.precision + sc.scale AS varchar(10)) + ')), '''')'
							WHEN st.name IN ('int','bigint','smallint','tinyint','binary','image','decimal','money','smallmoney','time','timestamp','variant','xml','float','bit') AND sc.is_nullable = 1
							THEN 'CAST(@' + dbo.fnCleanVariableName(LEFT(sc.name,255)) + ' AS varchar(' + CAST(sc.precision + sc.scale AS varchar(10)) + '))'
						END 
					,LEFT(st.name,30) AS fieldType
					,fullFieldType = 
						CASE 
							WHEN st.name IN ('char', 'varchar', 'nvarchar')
							THEN st.name + '(' + CAST(sc.max_length AS varchar(5)) + ')'
							WHEN st.name IN ('decimal', 'numeric')
							THEN st.name + '(' + CAST(sc.precision AS varchar(2)) + ',' + CAST(sc.scale AS varchar(2)) + ')'
							ELSE st.name
						END
					,SqlDbType = 'SqlDbType.' +
						CASE
							WHEN LOWER(st.name) = 'bigint' THEN 'BigInt'
							WHEN LOWER(st.name) = 'binary' THEN 'Binary'
							WHEN LOWER(st.name) = 'bit' THEN 'Bit'
							WHEN LOWER(st.name) = 'char' THEN 'Char'
							WHEN LOWER(st.name) = 'decimal' THEN 'Decimal'
							WHEN LOWER(st.name) IN ('datetime', 'datetime2') THEN 'DateTime'
							WHEN LOWER(st.name) = 'float' THEN 'Float'
							WHEN LOWER(st.name) = 'image' THEN 'Image'
							WHEN LOWER(st.name) = 'int' THEN 'Int'
							WHEN LOWER(st.name) = 'money' THEN 'Money'
							WHEN LOWER(st.name) = 'nchar' THEN 'NChar'
							WHEN LOWER(st.name) = 'ntext' THEN 'NText'
							WHEN LOWER(st.name) = 'nvarchar' THEN 'NVarChar'
							WHEN LOWER(st.name) = 'real' THEN 'Real'
							WHEN LOWER(st.name) = 'smalldatetime' THEN 'SmallDateTime'
							WHEN LOWER(st.name) = 'smallint' THEN 'SmallInt'
							WHEN LOWER(st.name) = 'smallmoney' THEN 'SmallMoney'
							WHEN LOWER(st.name) = 'structured' THEN 'Structured'
							WHEN LOWER(st.name) = 'text' THEN 'Text'
							WHEN LOWER(st.name) = 'time' THEN 'Time'
							WHEN LOWER(st.name) = 'timestamp' THEN 'TimeStamp'
							WHEN LOWER(st.name) = 'tinyint' THEN 'TinyInt'
							WHEN LOWER(st.name) = 'udt' THEN 'Udt'
							WHEN LOWER(st.name) = 'uniqueidentifier' THEN 'UniqueIdentifier'
							WHEN LOWER(st.name) = 'varbinary' THEN 'VarBinary'
							WHEN LOWER(st.name) = 'varchar' THEN 'VarChar'
							WHEN LOWER(st.name) = 'variant' THEN 'Variant'
							WHEN LOWER(st.name) = 'xml' THEN 'Xml'
						END
					,cSharpType =
						CASE 
							WHEN LOWER(st.name) IN('char', 'ntext', 'nvarchar', 'text', 'varchar')
							THEN 'String'
							WHEN LOWER(st.name) IN('decimal', 'money', 'numeric', 'smallmoney')
							THEN 'Decimal'
							WHEN LOWER(st.name) IN('binary', 'image', 'varbinary')
							THEN 'Byte[]'
							WHEN LOWER(st.name) IN('date', 'datetime', 'datetime2', 'smalldatetime', 'timestamp')
							THEN 'DateTime'
							WHEN LOWER(st.name) = 'bigint' THEN 'long'
							WHEN LOWER(st.name) = 'bit' THEN 'Boolean'
							WHEN LOWER(st.name) = 'datetimeoffset' THEN 'DateTimeOffset'
							WHEN LOWER(st.name) = 'float' THEN 'float'
							WHEN LOWER(st.name) = 'int' THEN 'int'
							WHEN LOWER(st.name) = 'nchar' THEN 'Char'
							WHEN LOWER(st.name) = 'real' THEN 'Double'
							WHEN LOWER(st.name) = 'smallint' THEN 'short'
							WHEN LOWER(st.name) = 'time' THEN 'TimeSpan'
							WHEN LOWER(st.name) = 'tinyint' THEN 'Byte'
							WHEN LOWER(st.name) = 'uniqueidentifier' THEN 'Guid'
							ELSE 'UNKNOWN_' + LOWER(st.name)
						END +
						CASE 
							WHEN sc.is_nullable = 1 
							AND LOWER(st.name) IN('bigint', 'bit', 'date', 'datetime', 'datetime2', 'datetimeoffset', 'decimal', 'float', 'int', 'money', 'numeric', 'real', 'smalldatetime', 'smallint', 'smallmoney', 'time', 'tinyint', 'uniqueidentifier') 
							THEN '?' 
							ELSE '' 
						END 
					,cSharpPrivateVariableName =
					'_' + LOWER(LEFT(dbo.fnCleanVariableName(LEFT(sc.name,255)),1)) + SUBSTRING(dbo.fnCleanVariableName(LEFT(sc.name,255)),2,LEN(dbo.fnCleanVariableName(LEFT(sc.name,255)))-1) +
						CASE
							WHEN sc.is_nullable = 1 
							THEN '_x'
							ELSE ''
						END
					,cSharpPublicPropertyName = dbo.fnCleanVariableName(LEFT(sc.name,255)) + 
						CASE
							WHEN sc.is_nullable = 1 
							THEN '_x'
							ELSE ''
						END
					,typescript = sc.name + ':' + 
						CASE 
							WHEN LOWER(st.name) IN('char', 'nchar', 'ntext', 'nvarchar', 'text', 'varchar')
							THEN 'string'
							WHEN LOWER(st.name) IN('int', 'tinyint', 'smallint', 'bigint', 'float', 'real', 'decimal', 'money', 'numeric', 'smallmoney')
							THEN 'number'
							WHEN LOWER(st.name) IN('binary', 'image', 'varbinary')
							THEN 'byte[]'
							WHEN LOWER(st.name) IN('date', 'datetime', 'datetime2', 'smalldatetime', 'timestamp')
							THEN 'Date'
							WHEN LOWER(st.name) = 'bit' THEN 'boolean'
							ELSE 'UNKNOWN_' + LOWER(st.name)
						END +
						CASE 
							WHEN sc.is_nullable = 1 
							THEN ' | null' 
							ELSE '' 
						END + ';' 
					,CAST(sc.max_length AS smallint) AS fieldLength
					,stringFieldLenght =
						CASE
							WHEN ISNULL(sc.precision,0) > 0
							THEN CAST(sc.precision + sc.scale AS smallint)
							ELSE CAST(sc.max_length AS smallint)
						END
					,CAST(sc.is_nullable AS bit) AS fieldIsNullable
					,CAST(sc.is_identity AS bit) AS fieldIsIdentity
					,CAST(sc.precision AS tinyint) AS fieldPrecision
					,CAST(sc.scale AS tinyint) AS fieldScale
					,randomData = LTRIM(RTRIM(dbo.fnGetRandomDataByDatatype(st.name,sc.max_length,'"')))
					,sc.column_id
			FROM	sys.columns sc WITH(NOLOCK)
					INNER JOIN
					sys.types st WITH(NOLOCK)
					ON sc.user_type_id = st.user_type_id
					INNER JOIN
					sys.objects so WITH(NOLOCK)
					ON sc.object_id = so.object_id 
					INNER JOIN
					sys.schemas ss WITH(NOLOCK)
					ON so.schema_id = ss.schema_id
			WHERE	LOWER(LTRIM(RTRIM(st.name))) <> 'sysname'
			AND		so.type = ('U')
			AND		so.name = @tableName
			AND		(ss.name = @schema OR @schema IS NULL)
			)	 MAIN
				LEFT JOIN
			(
			SELECT
					schema_name(ta.schema_id)  SchemaName
					,ta.name  TableName
					,ind.name
					,indcol.key_ordinal Ord
					,col.name  ColumnName
					,ind.type_desc
					,ind.fill_factor
					,ind.is_primary_key
			FROM	sys.tables ta
					left join 
					sys.indexes ind
					on ind.object_id = ta.object_id
					inner join 
					sys.index_columns indcol
					on indcol.object_id = ta.object_id
					and indcol.index_id = ind.index_id
					inner join 
					sys.columns col
					on col.object_id = ta.object_id
					and col.column_id = indcol.column_id
			 WHERE	ind.is_primary_key = 1
			 AND	ta.name =  @tableName
			 AND	(schema_name(ta.schema_id) = @schema OR @schema IS NULL)		
			) IDX
			ON MAIN.colName = IDX.ColumnName
		ORDER BY MAIN.column_id
		END

	RETURN
END
