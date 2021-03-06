/*
---------------------------------------------------------------------------------------------
Funzione preposta alla rappresentazione della struttura di una SP SQL
---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------
Esempi di invocazione:

SELECT * FROM dbo.fnGetSpDef('dbo.sp_DEL_ENTITY_byCodiceFlusso')
SELECT * FROM dbo.fnGetSpDef('sp_mappaNuovoCodiceSAP')
SELECT * FROM dbo.fnGetSpDef('spF24EpAssFiscAddizionaleRegionalePerCodiceTributo')
*/
ALTER FUNCTION [dbo].[fnGetSpDef](@spName SYSNAME = NULL)
RETURNS @spDef TABLE
		(
			paramName varchar(255)
			,paramType varchar(30)
			,fullparamType varchar(50)
			,SqlDbType varchar(30)
			,cSharpType varchar(30)
			,cSharpPrivateVariableName varchar(256)
			,cSharpPublicPropertyName varchar(256)
			,paramLength smallint
			,stringparamLength smallint
			,paramPrecision tinyint
			,paramScale tinyint
		)
AS
BEGIN
	IF ISNULL(@spName,'') != ''
		BEGIN
			INSERT	@spDef
					(
						paramName
						,paramType
						,fullparamType
						,SqlDbType
						,cSharpType
						,cSharpPrivateVariableName
						,cSharpPublicPropertyName
						,paramLength
						,stringparamLength
						,paramPrecision
						,paramScale
					)
			SELECT 
					LEFT(name,255) AS paramName
					,LEFT(type_name(user_type_id),30) AS paramType
					,fullparamType = 
						CASE 
							WHEN type_name(user_type_id) IN ('char', 'varchar', 'nvarchar')
							THEN type_name(user_type_id) + '(' + CAST(max_length AS varchar(5)) + ')'
							WHEN type_name(user_type_id) IN ('decimal', 'numeric')
							THEN type_name(user_type_id) + '(' + CAST(OdbcPrec(system_type_id, max_length, precision) AS varchar(2)) + ',' + CAST(OdbcScale(system_type_id, scale) AS varchar(2)) + ')'
							ELSE type_name(user_type_id)
						END
					,SqlDbType = 'SqlDbType.' +
						CASE
							WHEN LOWER(type_name(user_type_id)) = 'bigint' THEN 'BigInt'
							WHEN LOWER(type_name(user_type_id)) = 'binary' THEN 'Binary'
							WHEN LOWER(type_name(user_type_id)) = 'bit' THEN 'Bit'
							WHEN LOWER(type_name(user_type_id)) = 'char' THEN 'Char'
							WHEN LOWER(type_name(user_type_id)) = 'decimal' THEN 'Decimal'
							WHEN LOWER(type_name(user_type_id)) = 'datetime' THEN 'DateTime'
							WHEN LOWER(type_name(user_type_id)) = 'float' THEN 'Float'
							WHEN LOWER(type_name(user_type_id)) = 'image' THEN 'Image'
							WHEN LOWER(type_name(user_type_id)) = 'int' THEN 'Int'
							WHEN LOWER(type_name(user_type_id)) = 'money' THEN 'Money'
							WHEN LOWER(type_name(user_type_id)) = 'nchar' THEN 'NChar'
							WHEN LOWER(type_name(user_type_id)) = 'ntext' THEN 'NText'
							WHEN LOWER(type_name(user_type_id)) = 'nvarchar' THEN 'NVarChar'
							WHEN LOWER(type_name(user_type_id)) = 'real' THEN 'Real'
							WHEN LOWER(type_name(user_type_id)) = 'smalldatetime' THEN 'SmallDateTime'
							WHEN LOWER(type_name(user_type_id)) = 'smallint' THEN 'SmallInt'
							WHEN LOWER(type_name(user_type_id)) = 'smallmoney' THEN 'SmallMoney'
							WHEN LOWER(type_name(user_type_id)) = 'structured' THEN 'Structured'
							WHEN LOWER(type_name(user_type_id)) = 'text' THEN 'Text'
							WHEN LOWER(type_name(user_type_id)) = 'time' THEN 'Time'
							WHEN LOWER(type_name(user_type_id)) = 'timestamp' THEN 'TimeStamp'
							WHEN LOWER(type_name(user_type_id)) = 'tinyint' THEN 'TinyInt'
							WHEN LOWER(type_name(user_type_id)) = 'udt' THEN 'Udt'
							WHEN LOWER(type_name(user_type_id)) = 'uniqueidentifier' THEN 'UniqueIdentifier'
							WHEN LOWER(type_name(user_type_id)) = 'varbinary' THEN 'VarBinary'
							WHEN LOWER(type_name(user_type_id)) = 'varchar' THEN 'VarChar'
							WHEN LOWER(type_name(user_type_id)) = 'variant' THEN 'Variant'
							WHEN LOWER(type_name(user_type_id)) = 'xml' THEN 'Xml'
						END
					,cSharpType =
						CASE 
							WHEN LOWER(type_name(user_type_id)) IN('char', 'ntext', 'nvarchar', 'text', 'varchar')
							THEN 'String'
							WHEN LOWER(type_name(user_type_id)) IN('decimal', 'money', 'numeric', 'smallmoney')
							THEN 'Decimal'
							WHEN LOWER(type_name(user_type_id)) IN('binary', 'image', 'varbinary')
							THEN 'Byte[]'
							WHEN LOWER(type_name(user_type_id)) IN('date', 'datetime', 'datetime2', 'smalldatetime', 'timestamp')
							THEN 'DateTime'
							WHEN LOWER(type_name(user_type_id)) = 'bigint' THEN 'long'
							WHEN LOWER(type_name(user_type_id)) = 'bit' THEN 'Boolean'
							WHEN LOWER(type_name(user_type_id)) = 'datetimeoffset' THEN 'DateTimeOffset'
							WHEN LOWER(type_name(user_type_id)) = 'float' THEN 'float'
							WHEN LOWER(type_name(user_type_id)) = 'int' THEN 'int'
							WHEN LOWER(type_name(user_type_id)) = 'nchar' THEN 'Char'
							WHEN LOWER(type_name(user_type_id)) = 'real' THEN 'Double'
							WHEN LOWER(type_name(user_type_id)) = 'smallint' THEN 'short'
							WHEN LOWER(type_name(user_type_id)) = 'time' THEN 'TimeSpan'
							WHEN LOWER(type_name(user_type_id)) = 'tinyint' THEN 'Byte'
							WHEN LOWER(type_name(user_type_id)) = 'uniqueidentifier' THEN 'Guid'
							ELSE 'UNKNOWN_' + LOWER(type_name(user_type_id))
						END
					,'_' + LOWER(LEFT( REPLACE(LEFT(name,255),'@','') ,1)) + SUBSTRING(REPLACE(LEFT(name,255),'@',''),2,LEN(REPLACE(LEFT(name,255),'@',''))-1) AS cSharpPrivateVariableName
					,REPLACE(LEFT(name,255),'@','') AS cSharpPublicPropertyName
					,CAST(max_length AS smallint) AS paramLength
					,stringparamLenght =
						CASE
							WHEN ISNULL(OdbcPrec(system_type_id, max_length, precision),0) > 0
							THEN CAST(OdbcPrec(system_type_id, max_length, precision) + ISNULL(OdbcScale(system_type_id, scale),0) AS smallint)
							ELSE CAST(max_length AS smallint)
						END
					,CAST(OdbcPrec(system_type_id, max_length, precision) AS tinyint) AS paramPrecision
					,CAST(OdbcScale(system_type_id, scale) AS tinyint) AS paramScale

				  FROM	sys.parameters 
				  WHERE	object_id = object_id(@spName)
				  ORDER BY parameter_id
		END

	RETURN
END