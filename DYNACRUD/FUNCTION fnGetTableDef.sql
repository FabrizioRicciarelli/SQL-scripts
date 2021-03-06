/*
---------------------------------------------------------------------------------------------
Funzione preposta alla rappresentazione della struttura di una tabella SQL
---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------
Esempi di invocazione:

SELECT * FROM dbo.fnGetTableDef('ENTITA_DETT')
SELECT * FROM dbo.fnGetTableDef('MEMO78')
SELECT * FROM dbo.fnGetTableDef('COMUNICAZIONE_PSR')
*/
ALTER FUNCTION [dbo].[fnGetTableDef](@tableName varchar(128) = NULL)
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
			-- QUESTO CODICE NON GIRA DENTRO LE FUNZIONI...
			--DECLARE @KeyFields TABLE
			--		(
			--			TABLE_QUALIFIER sysname
			--			,TABLE_OWNER varchar(255)
			--			,TABLE_NAME sysname
			--			,COLUMN_NAME sysname
			--			,KEY_SEQ int
			--			,PK_NAME sysname
			--		)

			--INSERT @KeyFields
			--exec sp_pkeys 'ENTITA_DETT'

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
							WHEN st.name IN ('datetime') AND sc.is_nullable = 0
							THEN 'ISNULL(CONVERT(varchar(' + CAST(sc.precision + sc.scale AS varchar(10)) + '),@' + dbo.fnCleanVariableName(LEFT(sc.name,255)) + ',120), GETDATE())'
							WHEN st.name IN ('datetime') AND sc.is_nullable = 1
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
							WHEN LOWER(st.name) = 'datetime' THEN 'DateTime'
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
			WHERE	LOWER(LTRIM(RTRIM(st.name))) <> 'sysname'
			AND		so.type = ('U')
			AND		so.name = @tableName
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
			) IDX
			ON MAIN.colName = IDX.ColumnName
		ORDER BY MAIN.column_id
		END

	RETURN
END