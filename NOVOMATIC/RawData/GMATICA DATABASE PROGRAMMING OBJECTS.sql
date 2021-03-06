USE [GMATICA_AGS_RawData_Elaborate_Stag_Agile]
GO
/****** Object:  Schema [Catalog]    Script Date: 22/12/2017 22:46:03 ******/
CREATE SCHEMA [Catalog]
GO
/****** Object:  Schema [Config]    Script Date: 22/12/2017 22:46:03 ******/
CREATE SCHEMA [Config]
GO
/****** Object:  Schema [Data]    Script Date: 22/12/2017 22:46:03 ******/
CREATE SCHEMA [Data]
GO
/****** Object:  Schema [ERR]    Script Date: 22/12/2017 22:46:03 ******/
CREATE SCHEMA [ERR]
GO
/****** Object:  Schema [ETL]    Script Date: 22/12/2017 22:46:03 ******/
CREATE SCHEMA [ETL]
GO
/****** Object:  Schema [RAW]    Script Date: 22/12/2017 22:46:03 ******/
CREATE SCHEMA [RAW]
GO
/****** Object:  Schema [TMP]    Script Date: 22/12/2017 22:46:03 ******/
CREATE SCHEMA [TMP]
GO
/****** Object:  UserDefinedTableType [ETL].[TicketTbl]    Script Date: 22/12/2017 22:46:03 ******/
CREATE TYPE [ETL].[TicketTbl] AS TABLE(
	[requestDetailId] [int] NULL,
	[requestId] [int] NULL,
	[ticket] [varchar](50) NULL,
	[clubId] [varchar](10) NULL,
	[ticketDirection] [bit] NULL,
	[univocalLocationCode] [varchar](20) NULL,
	[elabStart] [datetime] NULL,
	[elabEnd] [datetime] NULL,
	[detailStatusId] [tinyint] NULL,
	[requestStatusDesc] [varchar](25) NULL,
	[fileNameSession] [varchar](70) NULL,
	[fileNameDelta] [varchar](70) NULL,
	[fileNameOperationLog] [varchar](70) NULL,
	[fileNameErrorLog] [varchar](70) NULL,
	[system_date] [datetime2](3) NULL
)
GO
/****** Object:  UserDefinedFunction [dbo].[CurrentDay]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Ritorna il giorno corrente in forma di stringa a 2 caratteri riempita con zero quando il giorno è inferiore a 10

Esempio:

SELECT  dbo.CurrentDay() AS CM
*/
CREATE FUNCTION [dbo].[CurrentDay]()
RETURNS varchar(2)
AS
BEGIN
	RETURN dbo.PadLeft(CAST(DAY(GETDATE()) AS varchar(2)),NULL,NULL)
END
GO
/****** Object:  UserDefinedFunction [dbo].[CurrentDMY]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Ritorna il giorno, il mese e l'anno  correnti in forma di stringa a 10 caratteri dove il mese e il giorno sono riempiti con uno zero quando questi siano inferiori a 10
Se viene specificato un carattere per il parametro @sep, questo verrà utilizzato come separatore tra il giorno, il mese e l'anno

Esempio:

SELECT  dbo.CurrentDMY(NULL) AS CDMY
SELECT  dbo.CurrentDMY('/') AS CDMY
SELECT  dbo.CurrentDMY('-') AS CDMY
SELECT  dbo.CurrentDMY('_') AS CDMY
SELECT  dbo.CurrentDMY(',') AS CDMY
SELECT  dbo.CurrentDMY('.') AS CDMY
*/
CREATE FUNCTION [dbo].[CurrentDMY](@sep varchar(1) = NULL)
RETURNS varchar(10)
AS
BEGIN
	RETURN dbo.CurrentDay() + ISNULL(@sep,'') + dbo.CurrentMonth()	+ ISNULL(@sep,'') + dbo.CurrentYear() 
END
GO
/****** Object:  UserDefinedFunction [dbo].[CurrentHM]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Ritorna l'ora e il minuto correnti in forma di stringa a 5 caratteri dove l'ora e il minuto sono riempiti con uno zero quando questi siano inferiori a 10
Se viene specificato un carattere per il parametro @sep, questo verrà utilizzato come separatore tra l'ora e il minuto

Esempio:

SELECT  dbo.CurrentHM(NULL) AS CHM
SELECT  dbo.CurrentHM('_') AS CHM
SELECT  dbo.CurrentHM(':') AS CHM
*/
CREATE FUNCTION [dbo].[CurrentHM](@sep varchar(1))
RETURNS varchar(5)
AS
BEGIN
	RETURN dbo.CurrentHour() + ISNULL(@sep,'') + dbo.CurrentMinute()
END
GO
/****** Object:  UserDefinedFunction [dbo].[CurrentHMS]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Ritorna l'ora, il minuto e il secondo correnti in forma di stringa a 8 caratteri dove l'ora, il minuto e il secondo sono riempiti con uno zero quando questi siano inferiori a 10
Se viene specificato un carattere per il parametro @sep, questo verrà utilizzato come separatore tra l'ora, il minuto e il secondo

Esempio:

SELECT  dbo.CurrentHMS(NULL) AS CHMS
SELECT  dbo.CurrentHMS('_') AS CHMS
SELECT  dbo.CurrentHMS(':') AS CHMS
*/
CREATE FUNCTION [dbo].[CurrentHMS](@sep varchar(1))
RETURNS varchar(8)
AS
BEGIN
	RETURN dbo.CurrentHour() + ISNULL(@sep,'') + dbo.CurrentMinute() + ISNULL(@sep,'') + dbo.CurrentSecond()
END
GO
/****** Object:  UserDefinedFunction [dbo].[CurrentHour]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Ritorna l'ora corrente in forma di stringa a 2 caratteri riempita con zero quando l'ora è inferiore a 10

Esempio:

SELECT  dbo.CurrentHour() AS CM
*/
CREATE FUNCTION [dbo].[CurrentHour]()
RETURNS varchar(2)
AS
BEGIN
	RETURN dbo.PadLeft(CAST(DATEPART(HOUR, GETDATE()) AS varchar(2)),NULL,NULL)
END
GO
/****** Object:  UserDefinedFunction [dbo].[CurrentMD]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Ritorna il mese e il giorno correnti in forma di stringa a 7 caratteri dove sia il mese che il giorno è riempito con uno zero quando questo è inferiore a 10
Se viene specificato un carattere per il parametro @sep, questo verrà utilizzato come separatore tra il mese e il giorno

Esempio:

SELECT  dbo.CurrentMD(NULL) AS CYM
SELECT  dbo.CurrentMD('_') AS CYM
SELECT  dbo.CurrentMD(',') AS CYM
*/
CREATE FUNCTION [dbo].[CurrentMD](@sep varchar(1))
RETURNS varchar(7)
AS
BEGIN
	RETURN dbo.CurrentMonth() + ISNULL(@sep,'') + dbo.CurrentDay()
END
GO
/****** Object:  UserDefinedFunction [dbo].[CurrentMinute]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Ritorna il minuto corrente in forma di stringa a 2 caratteri riempita con zero quando l'ora è inferiore a 10

Esempio:

SELECT  dbo.CurrentMinute() AS CM
*/
CREATE FUNCTION [dbo].[CurrentMinute]()
RETURNS varchar(2)
AS
BEGIN
	RETURN dbo.PadLeft(CAST(DATEPART(MINUTE, GETDATE()) AS varchar(2)),NULL,NULL)
END
GO
/****** Object:  UserDefinedFunction [dbo].[CurrentMonth]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Ritorna il mese corrente in forma di stringa a 2 caratteri riempita con zero quando il mese è inferiore a 10

Esempio:

SELECT  dbo.CurrentMonth() AS CM
*/
CREATE FUNCTION [dbo].[CurrentMonth]()
RETURNS varchar(2)
AS
BEGIN
	RETURN dbo.PadLeft(CAST(MONTH(GETDATE()) AS varchar(2)),NULL,NULL)
END
GO
/****** Object:  UserDefinedFunction [dbo].[CurrentSecond]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Ritorna il secondo corrente in forma di stringa a 2 caratteri riempita con zero quando l'ora è inferiore a 10

Esempio:

SELECT  dbo.CurrentSecond() AS CM
*/
CREATE FUNCTION [dbo].[CurrentSecond]()
RETURNS varchar(2)
AS
BEGIN
	RETURN dbo.PadLeft(CAST(DATEPART(SECOND, GETDATE()) AS varchar(2)),NULL,NULL)
END
GO
/****** Object:  UserDefinedFunction [dbo].[CurrentYear]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Ritorna l'anno corrente in forma di stringa a 4 caratteri

Esempio:

SELECT  dbo.CurrentYear() AS CY
*/
CREATE FUNCTION [dbo].[CurrentYear]()
RETURNS varchar(4)
AS
BEGIN
	RETURN CAST(YEAR(GETDATE()) AS varchar(4))
END
GO
/****** Object:  UserDefinedFunction [dbo].[CurrentYM]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Ritorna l'anno e il mese correnti in forma di stringa a 7 caratteri dove il mese è riempito con uno zero quando questo è inferiore a 10
Se viene specificato un carattere per il parametro @sep, questo verrà utilizzato come separatore tra l'anno e il mese

Esempio:

SELECT  dbo.CurrentYM(NULL) AS CYM
SELECT  dbo.CurrentYM('_') AS CYM
SELECT  dbo.CurrentYM(',') AS CYM
*/
CREATE FUNCTION [dbo].[CurrentYM](@sep varchar(1))
RETURNS varchar(7)
AS
BEGIN
	RETURN dbo.CurrentYear() + ISNULL(@sep,'') + dbo.CurrentMonth()
END
GO
/****** Object:  UserDefinedFunction [dbo].[CurrentYMD]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Ritorna l'anno, il mese e il giorno correnti in forma di stringa a 10 caratteri dove il mese e il giorno sono riempiti con uno zero quando questi siano inferiori a 10
Se viene specificato un carattere per il parametro @sep, questo verrà utilizzato come separatore tra l'anno, il mese e il giorno

Esempio:

SELECT  dbo.CurrentYMD(NULL) AS CYMD
SELECT  dbo.CurrentYMD('_') AS CYMD
SELECT  dbo.CurrentYMD(',') AS CYMD
*/
CREATE FUNCTION [dbo].[CurrentYMD](@sep varchar(1))
RETURNS varchar(10)
AS
BEGIN
	RETURN dbo.CurrentYear() + ISNULL(@sep,'') + dbo.CurrentMonth()	+ ISNULL(@sep,'') + dbo.CurrentDay()
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnCleanVariableName]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------------------
-- FUNZIONE PREPOSTA AL RIMPIAZZO DI STRINGHE
-- UTILIZZATE COME NOMI DI VARIABLI
----------------------------------------------------
--
-- Fabrizio Ricciarelli per Eustema Spa
-- 16/11/2015
--
-- Esempi di invocazione:
--
PRINT (dbo.fnCleanVariableName('@giachiocciolata'))
PRINT (dbo.fnCleanVariableName('Segno_d’archivio'))
PRINT (dbo.fnCleanVariableName('Dati per DC Finanza'))
PRINT (dbo.fnCleanVariableName('Da inserire nella comunica-zione'))
-- 
*/
CREATE FUNCTION [dbo].[fnCleanVariableName](@string varchar(128))
RETURNS varchar(128)
AS
BEGIN
	DECLARE @retVal varchar(128)
	SET		@retVal =
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			@string,
			' ','_'),
			CHAR(160),'_'),
			'-','_' + CAST(ASCII('-') AS varchar(5)) + '_'),
			'+','_' + CAST(ASCII('+') AS varchar(5)) + '_'),
			'*','_' + CAST(ASCII('*') AS varchar(5)) + '_'),
			'/','_' + CAST(ASCII('/') AS varchar(5)) + '_'),
			'’','_' + CAST(ASCII('’') AS varchar(5)) + '_'),
			'@','_' + CAST(ASCII('@') AS varchar(5)) + '_'),
			'#','_' + CAST(ASCII('#') AS varchar(5)) + '_'),
			'§','_' + CAST(ASCII('§') AS varchar(5)) + '_'),
			'\','_' + CAST(ASCII('\') AS varchar(5)) + '_'),
			'$','_' + CAST(ASCII('$') AS varchar(5)) + '_')

	RETURN @retVal
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetRandomDataByDatatype]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------------------
-- FUNZIONE CHE RITORNA UNA STRINGA CASUALE
-- DI LUNGHEZZA SPECIFICA IN BASE AL TIPO DI
-- DATO SPECIFICATO.
-- SE INDICATO, PUO' RACCHIUDERE IL DATO 
-- CASUALE TRA DELIMITATORI
----------------------------------------------------
--
-- Fabrizio Ricciarelli per Eustema Spa
-- 27/11/2015
--
-- Esempi di invocazione:
--
PRINT(dbo.fnGetRandomDataByDatatype('bit',10,NULL))
PRINT(dbo.fnGetRandomDataByDatatype('int',10,NULL))
PRINT(dbo.fnGetRandomDataByDatatype('decimal',20,NULL))
PRINT(dbo.fnGetRandomDataByDatatype('varchar',100,'"'))
PRINT(dbo.fnGetRandomDataByDatatype('datetime',26,NULL))
PRINT(dbo.fnGetRandomDataByDatatype('datetime',26,''''))
*/
CREATE FUNCTION [dbo].[fnGetRandomDataByDatatype](@sqlDatatype varchar(20) = NULL, @maxLength int = NULL, @encloseStringsWithQuoteChar char(1) = NULL)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @retVal varchar(MAX) = NULL
	
	IF ISNULL(@sqlDatatype,'') != ''
	AND ISNULL(@maxLength,'') != ''
		BEGIN
			SELECT @retVal =
					CASE 
						WHEN @sqlDatatype in ('bit') 
						THEN CAST(BITVALUE AS char(1))
						WHEN @sqlDatatype in ('bigint','int','smallint','tinyint') 
						THEN LEFT(CAST(CAST(RNDVALUE * 1000000 AS int) AS varchar(MAX)),@maxLength)
						WHEN @sqlDatatype in ('float','decimal','numeric','money','smallmoney','real') 
						THEN LEFT(CAST(CAST(RNDVALUE * 1000000.999 AS decimal(18,2)) AS varchar(MAX)),@maxLength)
						WHEN @sqlDatatype in ('binary','varbinary') 
						THEN ISNULL(@encloseStringsWithQuoteChar,'') + LEFT('0x546869732069732044756D6D792044617461',@maxLength) + ISNULL(@encloseStringsWithQuoteChar,'')
						WHEN @sqlDatatype In ('varchar','char','text') 
						THEN ISNULL(@encloseStringsWithQuoteChar,'') + dbo.fnRandomString(1,@maxLength) + ISNULL(@encloseStringsWithQuoteChar,'')
						WHEN @sqlDatatype In ('nchar','nvarchar','ntext') 
						THEN ISNULL(@encloseStringsWithQuoteChar,'') + dbo.fnRandomString(1,@maxLength / 2) + ISNULL(@encloseStringsWithQuoteChar,'')
						WHEN @sqlDatatype in('date','time','datetime','datetime2','smalldatetime','datetimeoffset')
						THEN ISNULL(@encloseStringsWithQuoteChar,'') + CONVERT(varchar(50),dateadd(D,ROUND(RNDVALUE * 1000,1),GETDATE()),121) + ISNULL(@encloseStringsWithQuoteChar,'')
						WHEN @sqlDatatype in ('uniqueidentifier') 
						THEN ISNULL(@encloseStringsWithQuoteChar,'') + CAST(NEWIDVALUE AS varchar(33)) + ISNULL(@encloseStringsWithQuoteChar,'')
						ELSE ''
					END
			FROM	V_RAND_NEWID
		END

	RETURN @retVal
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetTableDef]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
CREATE FUNCTION [dbo].[fnGetTableDef](@schema varchar(128) = NULL, @tableName varchar(128) = NULL)
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
GO
/****** Object:  UserDefinedFunction [dbo].[fnRandomString]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------------------
-- FUNZIONE CHE RITORNA UNA STRINGA CASUALE
-- DI LUNGHEZZA SPECIFICA
----------------------------------------------------
--
-- Fabrizio Ricciarelli per Eustema Spa
-- 16/11/2015
--
-- Esempi di invocazione:
--
PRINT dbo.fnRandomString(1,5)
PRINT dbo.fnRandomString(128,128)
PRINT dbo.fnRandomString(255,255)
PRINT dbo.fnRandomString(1023,1023)
PRINT dbo.fnRandomString(8000,8000) -- IL MASSIMO RAPPRESENTABILE ALL'INTERNO DEL CLIENT Microsoft Sql Management Studio
*/
CREATE FUNCTION [dbo].[fnRandomString](@minLength int, @maxLength int)
RETURNS varchar(max)
AS
BEGIN

	DECLARE @length int, @charpool varchar(max), @LoopCount int, @PoolLength int, @RandomString varchar(max), @rand float
	SELECT @Length = RNDVALUE * @minLength + @maxLength FROM V_RAND_NEWID
	SET @CharPool = 'abcdefghijkmnopqrstuvwxyzABCDEFGHIJKLMNPQRSTUVWXYZ23456789'-- - .,_!$@#%^&*'
	SET @PoolLength = Len(@CharPool)
	SET @LoopCount = 0
	SET @RandomString = ''

	WHILE (@LoopCount < @Length) 
	BEGIN
		SELECT @RAND =  RNDVALUE *  @PoolLength FROM V_RAND_NEWID
		SELECT @RandomString = @RandomString + SUBSTRING(@Charpool, CONVERT(int, @rand), 1)
		SELECT @LoopCount = @LoopCount + 1
	END

	RETURN UPPER(LEFT(@RandomString,@maxLength))
END
/*
-- per ovviare al problema "Msg 443, Level 16, State 1, Procedure ufnGetRandomNumber, Line 5 Invalid use of a side-effecting operator ‘rand’ within a function."
ALTER VIEW V_RAND
AS
SELECT RAND() AS RNDVALUE
*/
GO
/****** Object:  UserDefinedFunction [dbo].[Now]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Ritorna data ed ora correnti riempiendo con uno zero il mese, il giorno, l'ora, il minuto e il secondo qualora uno di questi sia inferiore a 10
Se viene specificato un carattere per il parametro @sep, questo verrà utilizzato come separatore tra la data (Anno, Mese, Giorno) e l'orario (Ore, Minuti, Secondi)
Se viene specificato un carattere per il parametro @sepYMD, questo verrà utilizzato come separatore tra gli elementi della data (Anno, Mese, Giorno)
Se viene specificato un carattere per il parametro @sepHMS, questo verrà utilizzato come separatore tra gli elementi dell'orario (Ore, Minuti, Secondi)

Esempio:

SELECT  dbo.Now(NULL,NULL,NULL) AS NOW -- ritorna una stringa del tipo "20171212105607"
SELECT  dbo.Now('_',NULL,NULL) AS NOW -- ritorna una stringa del tipo "20171212_105537"
SELECT  dbo.Now('T','-',':') AS NOW	-- ritorna una stringa del tipo "2017-12-12T10:53:24"
*/
CREATE FUNCTION [dbo].[Now](@sep varchar(1) = NULL, @sepYMD varchar(1) = NULL, @sepHMS varchar(1) = NULL)
RETURNS varchar(19)
AS
BEGIN
	RETURN dbo.CurrentYMD(@sepYMD) + ISNULL(@sep,'') + dbo.CurrentHMS(@sepHMS)
END
GO
/****** Object:  UserDefinedFunction [dbo].[NowIT]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Ritorna data ed ora correnti, in forma DMY, riempiendo con uno zero il mese, il giorno, l'ora, il minuto e il secondo qualora uno di questi sia inferiore a 10
Se viene specificato un carattere per il parametro @sep, questo verrà utilizzato come separatore tra la data (Giorno, Mese, Anno) e l'orario (Ore, Minuti, Secondi)
Se viene specificato un carattere per il parametro @sepYMD, questo verrà utilizzato come separatore tra gli elementi della data (Giorno, Mese, Anno)
Se viene specificato un carattere per il parametro @sepHMS, questo verrà utilizzato come separatore tra gli elementi dell'orario (Ore, Minuti, Secondi)

Esempio:

SELECT  dbo.NowIT(NULL,NULL,NULL) AS NOW -- ritorna una stringa del tipo "20171212105607"
SELECT  dbo.NowIT('_',NULL,NULL) AS NOW -- ritorna una stringa del tipo "20171212_105537"
SELECT  dbo.NowIT('T','-',':') AS NOW	-- ritorna una stringa del tipo "2017-12-12T10:53:24"
*/
CREATE FUNCTION [dbo].[NowIT](@sep varchar(1) = NULL, @sepYMD varchar(1) = NULL, @sepHMS varchar(1) = NULL)
RETURNS varchar(19)
AS
BEGIN
	RETURN dbo.CurrentDMY(@sepYMD) + ISNULL(@sep,'') + dbo.CurrentHMS(@sepHMS)
END
GO
/****** Object:  UserDefinedFunction [dbo].[NowITsmall]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Ritorna data ed ora correnti, in forma DMY, riempiendo con uno zero il mese, il giorno, l'ora e il minuto qualora uno di questi sia inferiore a 10
Se viene specificato un carattere per il parametro @sep, questo verrà utilizzato come separatore tra la data (Giorno, Mese, Anno) e l'orario (Ore, Minuti)
Se viene specificato un carattere per il parametro @sepYMD, questo verrà utilizzato come separatore tra gli elementi della data (Giorno, Mese, Anno)
Se viene specificato un carattere per il parametro @sepHM, questo verrà utilizzato come separatore tra gli elementi dell'orario (Ore, Minuti)

Esempio:

SELECT  dbo.NowITsmall(NULL,NULL,NULL) AS NOW -- ritorna una stringa del tipo ""
SELECT  dbo.NowITsmall('_',NULL,NULL) AS NOW -- ritorna una stringa del tipo ""
SELECT  dbo.Nowitsmall(' ','/',':') AS NOW	-- ritorna una stringa del tipo ""
*/
CREATE FUNCTION [dbo].[NowITsmall](@sep varchar(1) = NULL, @sepYMD varchar(1) = NULL, @sepHM varchar(1) = NULL)
RETURNS varchar(19)
AS
BEGIN
	RETURN dbo.CurrentDMY(@sepYMD) + ISNULL(@sep,'') + dbo.CurrentHM(@sepHM)
END
GO
/****** Object:  UserDefinedFunction [dbo].[Nowsmall]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Ritorna data ed ora correnti riempiendo con uno zero il mese, il giorno, l'ora e il minuto qualora uno di questi sia inferiore a 10
Se viene specificato un carattere per il parametro @sep, questo verrà utilizzato come separatore tra la data (Anno, Mese, Giorno) e l'orario (Ore, Minuti)
Se viene specificato un carattere per il parametro @sepYMD, questo verrà utilizzato come separatore tra gli elementi della data (Anno, Mese, Giorno)
Se viene specificato un carattere per il parametro @sepHM, questo verrà utilizzato come separatore tra gli elementi dell'orario (Ore, Minuti)

Esempio:

SELECT  dbo.Nowsmall(NULL,NULL,NULL) AS NOW -- ritorna una stringa del tipo "201712121056"
SELECT  dbo.Nowsmall('_',NULL,NULL) AS NOW -- ritorna una stringa del tipo "20171212_1055"
SELECT  dbo.Nowsmall('T','-',':') AS NOW	-- ritorna una stringa del tipo "2017-12-12T10:53"
*/
CREATE FUNCTION [dbo].[Nowsmall](@sep varchar(1) = NULL, @sepYMD varchar(1) = NULL, @sepHM varchar(1) = NULL)
RETURNS varchar(19)
AS
BEGIN
	RETURN dbo.CurrentYMD(@sepYMD) + ISNULL(@sep,'') + dbo.CurrentHM(@sepHM)
END
GO
/****** Object:  UserDefinedFunction [dbo].[PadLeft]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Riempimento di una stringa con un determinato numero di caratteri (filler)

Esempio:

SELECT  dbo.PadLeft(NULL, 3, '0') AS filled	 -- RITORNA NULL IN QUANTO NESSUNA STRINGA DA RIEMPIRE E' STATA SPECIFICATA
SELECT  dbo.PadLeft('1', 3, '0') AS filled -- RITORNA '001' POICHE' E' STATO RICHIESTO DI PRODURRE UNA STRINGA FINALE LUNGA 3 CARATTERI (PARTENDO DALLA STRINGA "1") RIEMPIENDOLA DI ZERI SULLA SINISTRA
SELECT  dbo.PadLeft('1', NULL, NULL) AS filled -- RITORNA '01' POICHE', DI DEFAULT, LA FUNZIONE AGGIUNGE UNO ZERO DAVANTI AD UNA STRINGA SE QUESTA E' PIU' CORTA DI DUE CARATTERI
*/
CREATE FUNCTION [dbo].[PadLeft](@Str varchar(max), @Length int = NULL, @Filler varchar(1) = '0')
RETURNS VARCHAR(max)
AS
BEGIN
	DECLARE @RETVAL varchar(MAX) = NULL
	IF ISNULL(@Str,'') != ''
		BEGIN
			SET @filler = ISNULL(@filler, '0')
			SET @Length	= ISNULL(@Length, 2)
			SET @RETVAL = RIGHT(REPLICATE(@Filler, @Length) + @Str, @Length)
		END
	RETURN @RETVAL
END
GO
/****** Object:  UserDefinedFunction [dbo].[RndGen]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.RndGen(1,13) AS NUM
*/
CREATE FUNCTION [dbo].[RndGen](@lower int=1, @upper int=13)
RETURNS int
AS
BEGIN
	DECLARE @RND int
	SELECT	@RND = ROUND(((@upper - @lower) * RNDVALUE + @lower), 0)
	FROM	[dbo].[V_RAND_NEWID]
	RETURN	@RND
END
GO
/****** Object:  UserDefinedFunction [dbo].[RndGenTest]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT * FROM dbo.RndGenTest(100000,1,6)
*/
CREATE FUNCTION [dbo].[RndGenTest](@iterations int = 1000, @lower int=1, @upper int=13)
RETURNS @RNDNUM TABLE (NUM int, Occurrences int)
AS
BEGIN
	DECLARE	@RND TABLE (NUM int)
	DECLARE @I INT = 1
	
	WHILE @I < @iterations
		BEGIN
			INSERT	@RND(NUM)
			SELECT	dbo.RndGen(@lower,@upper) AS NUM
			-- oppure
			--SELECT	ROUND(((@upper - @lower) * RNDVALUE + @lower), 0) AS NUM
			--FROM	[dbo].[V_RAND_NEWID]
			SET @I += 1
		END
	
	INSERT  @RNDNUM (NUM, Occurrences)
	SELECT	NUM, COUNT(*) AS Occurrences
	FROM	@RND
	GROUP BY NUM
	ORDER BY NUM

	RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[ToISOdate]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.ToISOdate(GETDATE()) AS ISODATENOW
*/
CREATE FUNCTION [dbo].[ToISOdate](@inputdate datetime = null)
RETURNS varchar(10)
AS
BEGIN
	DECLARE @RETVAL varchar(10) = NULL	
	IF @inputdate IS NOT NULL
		BEGIN
			SET @RETVAL = CAST(YEAR(@inputdate) AS varchar(4)) + '-' + CAST(MONTH(@inputdate) AS varchar(2)) + '-' + REPLACE(STR(DAY(@inputdate), 2), SPACE(1), '0')
		END

	RETURN @RETVAL
END
GO
/****** Object:  View [ETL].[vConcessionary]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: Fabio De Stefani
Creation Date.......: 2017-09-07 
Description.........: Concessionary

Revision			 

Note
- Use [Tab size] = 3 and [Indent size] = 3 (Insert space) 


------------------
-- Note         --
------------------	
SELECT * FROM ETL.vConcessionary
*/

CREATE VIEW [ETL].[vConcessionary]

AS

select ConcessionarySK,	ConcessionaryName from [600DWH].dim.Concessionary

GO
/****** Object:  View [ETL].[vRequest]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: Fabio De Stefani
Creation Date.......: 2017-09-07 
Description.........: Concessionary

Revision			 

Note
- Use [Tab size] = 3 and [Indent size] = 3 (Insert space) 


------------------
-- Note         --
------------------	
*/
CREATE VIEW [ETL].[vRequest]
AS
SELECT        
		 R.requestId
		,R.requestDesc
		,R.requestClaimantId
		,C.requestClaimantName
		,R.elabStart
		,R.elabEnd
		,R.requestStatusId
		,RS.requestStatusDesc AS requestStatusDesc
		,R.system_date
		,R.ConcessionaryID
		,VC.ConcessionaryName
		,R.ClubID
		,R.FilterAmount
		,R.FilterStartDate
		,R.FilterEndDate
FROM	ETL.request R WITH(NOLOCK) 
		INNER JOIN
        ETL.requestClaimant C WITH(NOLOCK) 
		ON R.requestClaimantId = C.requestClaimantId 
		INNER JOIN
        ETL.requestStatus RS WITH(NOLOCK) 
		ON R.requestStatusId = RS.requestStatusId 
		INNER JOIN
        ETL.vConcessionary VC WITH(NOLOCK) 
		ON R.ConcessionaryID = VC.ConcessionarySK
GO
/****** Object:  View [dbo].[V_RAND_NEWID]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
---------------------------------------------------------------------------------------------
Vista preposta al ritorno di 
- un valore reale (float, double) casuale 
- un GUID casuale
- un BIT casuale
---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------
Esempi di invocazione:

SELECT * FROM V_RAND_NEWID
*/
CREATE VIEW [dbo].[V_RAND_NEWID]
AS
SELECT 
		RAND() AS RNDVALUE
		,NEWID() AS NEWIDVALUE
		,BITVALUE =
			CASE 
				WHEN RAND(CAST(NEWID() AS binary(8))) < 0.5 
				THEN 0 
				ELSE 1 
			END
GO
/****** Object:  View [ETL].[vActivity]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [ETL].[vActivity]

AS
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: Squilibrium
Creation Date.......: 2016-08-11 
Description.........: Activity and Subactivity info

Revision			 

Note
- Use [Tab size] = 3 and [Indent size] = 3 (Insert space) 


------------------
-- Note         --
------------------	
*/
SELECT --ACTIVITY FIELDS
	   A.[ActivityID] AS MainActivityID
      ,A.[StartDate] AS MainActivityStartDate
      ,A.[EndDate] AS MainActivityEndDate
      ,A.[ElapsedTime] AS MainActivityElapsedTime
	  ,ATY.ActivityTypeID  AS MainActivityTypeID
      ,ATY.ActivityType AS MainActivityType
	  ,AST.ActivityStateID as MainActivityStateID
      ,AST.[ActivityState] AS MainActivityState
      ,A.[Message] AS MainActivityMessage
      ,A.[AddInfo] AS MainActivityInfo
	  --SUBACTIVITY FIELDS
	  ,SA.SubActivityID
	  ,SA.StartDate AS SubActivityStartDate
	  ,SA.EndDate AS SubActivityEndDate
	  ,SA.[ElapsedTime] AS SubActivityElapsedTime
	  ,SAT.SubActivityTypeID
	  ,SAT.SubActivityType
	  ,SAST.ActivityStateID as SubActivityStateID
	  ,SAST.ActivityState as SubActivityState
	  ,SA.[RowsInserted] as SubActivityRowInserted
	  ,SA.[Message] as SubActivityMessage
	  ,SA.AddInfo as SubActivityInfo
FROM [Data].[Activity] A
INNER JOIN [Catalog].[ActivityType] ATY ON A.ActivityTypeID = ATY.ActivityTypeID
INNER JOIN [Catalog].[ActivityState]  AST ON A.ActivityStateID = AST.ActivityStateID
LEFT JOIN [Data].[SubActivity] SA ON A.ActivityID = SA.ActivityID
LEFT JOIN [Catalog].[SubActivityType] SAT ON SA.SubActivityTypeID = SAT.SubActivityTypeID
LEFT JOIN [Catalog].[ActivityState]  SAST ON SA.ActivityStateID = SAST.ActivityStateID

GO
/****** Object:  View [ETL].[vRequestDetail]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT * FROM ETL.vRequestDetail
*/
CREATE VIEW [ETL].[vRequestDetail]
AS
SELECT	
		 RD.requestDetailId
		,RD.requestId
		,RD.ticket
		,RD.clubId
		,RD.ticketDirection
		,RD.univocalLocationCode
		,RD.elabStart
		,RD.elabEnd
		,RD.detailStatusId
		,RS.requestStatusDesc
		,RD.fileNameSession
		,RD.fileNameDelta
		,RD.fileNameOperationLog
		,RD.fileNameErrorLog
		,RD.system_date
FROM	ETL.RequestDetail RD WITH(NOLOCK)
		LEFT JOIN
		ETL.RequestStatus RS WITH(NOLOCK)
		ON RD.detailStatusId = RS.requestStatusId
GO
/****** Object:  View [ETL].[vRequestMasterRequestDetailSessionDelta]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT * FROM ETL.vRequestMasterRequestDetailSessionDelta
--ORDER BY "Master/requestId"
FOR XML PATH
 
*/
CREATE VIEW [ETL].[vRequestMasterRequestDetailSessionDelta]
AS
SELECT 
		 R.requestId AS "Master/requestId"
		,R.requestDesc AS "Master/requestDesc"
		,R.requestClaimantId AS "Master/requestClaimantId"
		,R.elabStart AS "Master/elabStart"
		,R.elabEnd AS "Master/elabEnd"
		,R.requestStatusId AS "Master/requestStatusId"
		,R.system_date AS "Master/system_date"
		,R.ConcessionaryID AS "Master/ConcessionaryID"
		,R.ClubID AS "Master/ClubID"
		,R.FilterAmount AS "Master/FilterAmount"
		,R.FilterStartDate AS "Master/FilterStartDate"
		,R.FilterEndDate AS "Master/FilterEndDate"
		,R.TipoRichiesta AS "Master/TipoRichiesta"

		,D.requestDetailId  AS "Master/Detail/requestDetailId"
		,D.requestId AS "Master/Detail/requestId"
		,D.ticket AS "Master/Detail/ticket"
		,D.clubId AS "Master/Detail/clubId"
		,D.ticketDirection AS "Master/Detail/ticketDirection"
		,D.univocalLocationCode AS "Master/Detail/univocalLocationCode" 
		,D.elabStart AS "Master/Detail/elabStart"
		,D.elabEnd AS "Master/Detail/elabEnd"
		,D.detailStatusId AS "Master/Detail/detailStatusId"
		,D.fileNameSession AS "Master/Detail/fileNameSession"
		,D.fileNameDelta AS "Master/Detail/fileNameDelta"
		,D.fileNameOperationLog AS "Master/Detail/fileNameOperationLog"
		,D.fileNameErrorLog AS "Master/Detail/fileNameErrorLog"
		,D.system_date AS "Master/Detail/system_date"

 	--	,S.RecID AS "Session.RecID"
		--,S.requestDetailId AS "Session.requestDetailId"
		--,S.SessionID AS "Session.SessionID"
		--,S.SessionParentID AS "Session.SessionParentID"
		--,S.Level AS "Session.Level"
		--,S.UnivocalLocationCode AS "Session.UnivocalLocationCode"
		--,S.MachineID AS "Session.MachineID"
		--,S.GD AS "Session.GD"
		--,S.AamsMachineCode AS "Session.AamsMachineCode"
		--,S.StartServerTime AS "Session.StartServerTime"
		--,S.EndServerTime AS "Session.EndServerTime"
		--,S.TotalRows AS "Session.TotalRows"
		--,S.TotalBillIn AS "Session.TotalBillIn"
		--,S.TotalCoinIN AS "Session.TotalCoinIN"
		--,S.TotalTicketIn AS "Session.TotalTicketIn"
		--,S.TotalBetValue AS "Session.TotalBetValue"
		--,S.TotalBetNum AS "Session.TotalBetNum"
		--,S.TotalWinValue AS "Session.TotalWinValue"
		--,S.TotalWinNum AS "Session.TotalWinNum"
		--,S.Tax AS "Session.Tax"
		--,S.TotalIn AS "Session.TotalIn"
		--,S.TotalOut AS "Session.TotalOut"
		--,S.FlagMinVltCredit AS "Session.FlagMinVltCredit"
		--,S.StartTicketCode AS "Session.StartTicketCode"

		--,L.RecID AS "Delta.RecID"
		--,L.requestDetailId AS "Delta.requestDetailId"
		--,L.RowID AS "Delta.RowID"
		--,L.UnivocalLocationCode AS "Delta.UnivocalLocationCode"
		--,L.ServerTime AS "Delta.ServerTime"
		--,L.MachineID AS "Delta.MachineID"
		--,L.GD AS "Delta.GD"
		--,L.AamsMachineCode AS "Delta.AamsMachineCode"
		--,L.GameID AS "Delta.GameID"
		--,L.GameName AS "Delta.GameName"
		--,L.VLTCredit AS "Delta.VLTCredit"
		--,L.TotalBet AS "Delta.TotalBet"
		--,L.TotalWon AS "Delta.TotalWon"
		--,L.TotalBillIn AS "Delta.TotalBillIn"
		--,L.TotalCoinIn AS "Delta.TotalCoinIn"
		--,L.TotalTicketIn AS "Delta.TotalTicketIn"
		--,L.TotalHandPay AS "Delta.TotalHandPay"
		--,L.TotalTicketOut AS "Delta.TotalTicketOut"
		--,L.Tax AS "Delta.Tax"
		--,L.TotalIn AS "Delta.TotalIn"
		--,L.TotalOut AS "Delta.TotalOut"
		--,L.WrongFlag AS "Delta.WrongFlag"
		--,L.TicketCode AS "Delta.TicketCode"
		--,L.SessionID AS "Delta.SessionID"
FROM	ETL.request R WITH(NOLOCK)
		INNER JOIN
		ETL.requestDetail D WITH(NOLOCK)
		ON R.requestId = D.requestId
		--LEFT JOIN
		--ETL.Session S WITH(NOLOCK)
		--ON D.requestDetailId = S.requestDetailId
		--LEFT JOIN
		--ETL.Delta L WITH(NOLOCK)
		--ON S.SessionID = L.SessionID
GO
/****** Object:  View [ETL].[VSessionDelta]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [ETL].[VSessionDelta]
AS
SELECT	
		S.requestDetailId
		, S.StartTicketCode
		,D.RecID, D.RowID, D.UnivocalLocationCode, D.ServerTime, D.MachineID, D.GD, D.AamsMachineCode, D.GameID, D.GameName, D.VLTCredit, D.TotalBet, D.TotalWon, D.TotalBillIn, D.TotalCoinIn, D.TotalTicketIn, D.TotalHandPay, D.TotalTicketOut, D.Tax, D.TotalIn, D.TotalOut, D.WrongFlag, D.TicketCode, D.SessionID
FROM	ETL.Delta D WITH(NOLOCK)
		INNER JOIN
		ETL.Session S WITH(NOLOCK)
		ON D.SessionID = S.SessionID
		--AND D.requestDetailId = S.requestDetailId
GO
/****** Object:  View [ETL].[vSessionDeltaJSON]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
SELECT	* 
FROM	[ETL].[vSessionDeltaJSON]	
WHERE	requestDetailId = 9
ORDER BY Level
*/
CREATE VIEW [ETL].[vSessionDeltaJSON]
AS
SELECT
 		S.RecID
		,S.requestDetailId
		,S.SessionID
		,S.SessionParentID
		,S.[Level]
		,S.UnivocalLocationCode
		,S.MachineID
		,S.GD
		,S.AamsMachineCode
		,S.StartServerTime
		,S.EndServerTime
		,S.TotalRows
		,S.TotalBillIn
		,S.TotalCoinIN
		,S.TotalTicketIn
		,S.TotalBetValue
		,S.TotalBetNum
		,S.TotalWinValue
		,S.TotalWinNum
		,S.Tax
		,S.TotalIn
		,S.TotalOut
		,S.FlagMinVltCredit
		,S.StartTicketCode
		,Delta =
		(
			SELECT
					L.RecID
					,L.requestDetailId
					,L.RowID
					,L.UnivocalLocationCode
					,L.ServerTime
					,L.MachineID
					,L.GD
					,L.AamsMachineCode
					,L.GameID
					,L.GameName
					,L.VLTCredit
					,L.TotalBet
					,L.TotalWon
					,L.TotalBillIn
					,L.TotalCoinIn
					,L.TotalTicketIn
					,L.TotalHandPay
					,L.TotalTicketOut
					,L.Tax
					,L.TotalIn
					,L.TotalOut
					,L.WrongFlag
					,L.TicketCode
					,L.SessionID
			FROM	ETL.Delta L WITH(NOLOCK)
			WHERE	L.SessionID = S.SessionID
			AND		L.requestDetailId = S.requestDetailId
			AND		L.UnivocalLocationCode = S.UnivocalLocationCode
			AND		L.MachineID = S.MachineID
			AND		L.AamsMachineCode = S.AamsMachineCode
			AND		L.GD = S.GD
			FOR JSON PATH 
		)
FROM	[ETL].[Session] S WITH(NOLOCK)
GO
/****** Object:  View [TMP].[RawData_View]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Se ho anche o solo RawData_01
			  CREATE view [TMP].[RawData_View]
				AS
				SELECT RowID, ServerTime, MachineTime, MachineID, GameID, LoginFlag, TotalBet, Win, GamesPlayed, GamesWon, TotalHandpay, TotalHPCC, TotalJPCC, TotalRemote, TotalWon, TotalDrop, TotalIn, TotalOut, TotalBillIn, TotalBillChange, TotalCoinIn, TotalCoinInDrop, TotalCoinInHopper, TotalHopperOut, TotalHopperFill, TotalTicketIn, TotalTicketOut, TotalBillInNumber, BillIn1, BillIn2, BillIn3, BillIn4, BillIn5, BillIn6, BillIn7, BillIn8, TotalBillChangeNumber, BillChange1, BillChange2, BillChange3, BillChange4, BillChange5, BillChange6, BillChange7, TotalCoinInNumber, CoinIn3, CoinIn4, CoinIn5, CoinIn6, CoinIn7, CoinIn8, TotalCoinInDropNumber, CoinInDrop3, CoinInDrop4, CoinInDrop5, CoinInDrop6, CoinInDrop7, CoinInDrop8, TotalCoinInHopperNumber, CoinInHopper3, CoinInHopper4, TicketInA, TicketInB, TicketInC, TicketOutA, TicketOutB, TicketOutC, CurrentCreditA, CurrentCreditB, CurrentCreditC, TotalBetA, TotalBetB, TotalBetC, WinA, WinB, WinC, WinD, TotalHPCCA
					   FROM [POM-MON01].[GMATICA_AGS_RawData_01].[1000294].[RawData]
					   WHERE ServerTime >= '20120101' AND ServerTime < '20151117'
				UNION ALL
				SELECT (RowID + 2147483649), ServerTime, MachineTime, MachineID, GameID, LoginFlag, TotalBet, Win, GamesPlayed, GamesWon, TotalHandpay, TotalHPCC, TotalJPCC, TotalRemote, TotalWon, TotalDrop, TotalIn, TotalOut, TotalBillIn, TotalBillChange, TotalCoinIn, TotalCoinInDrop, TotalCoinInHopper, TotalHopperOut, TotalHopperFill, TotalTicketIn, TotalTicketOut, TotalBillInNumber, BillIn1, BillIn2, BillIn3, BillIn4, BillIn5, BillIn6, BillIn7, BillIn8, TotalBillChangeNumber, BillChange1, BillChange2, BillChange3, BillChange4, BillChange5, BillChange6, BillChange7, TotalCoinInNumber, CoinIn3, CoinIn4, CoinIn5, CoinIn6, CoinIn7, CoinIn8, TotalCoinInDropNumber, CoinInDrop3, CoinInDrop4, CoinInDrop5, CoinInDrop6, CoinInDrop7, CoinInDrop8, TotalCoinInHopperNumber, CoinInHopper3, CoinInHopper4, TicketInA, TicketInB, TicketInC, TicketOutA, TicketOutB, TicketOutC, CurrentCreditA, CurrentCreditB, CurrentCreditC, TotalBetA, TotalBetB, TotalBetC, WinA, WinB, WinC, WinD, TotalHPCCA
						FROM [POM-MON01].[GMATICA_AGS_RawData].[1000294].[RawData]
						WHERE ServerTime >= '20151117'
						
GO
/****** Object:  StoredProcedure [dbo].[USP_StoredProcedureTemplate]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- EXEC [dbo].[USP_StoredProcedureTemplate]

CREATE PROCEDURE [dbo].[USP_StoredProcedureTemplate]
    @p1 varchar(10) = NULL,
    @p2 varchar(10) = NULL
AS
BEGIN

 DECLARE @p11 char(2), @p21 char(2)
 SET @p11 = 'p1'
 SET @p21 = 'p2'
 IF (@p1 IS NOT NULL)
  SET @p11 = @p1
 IF (@p2 IS NOT NULL)
  SET @p21 = @p2

 PRINT 'USE [<database_name>]'
 PRINT 'GO'
 PRINT 'SET ANSI_NULLS ON'
 PRINT 'GO'
 PRINT 'SET QUOTED_IDENTIFIER ON'
 PRINT 'GO '
		 
 PRINT 'CREATE PROCEDURE <procedure_name,>'
 PRINT '  <@Param1, sysname, @' + @p11 + '> <datatype_for_param1,> = <default_value_for_param1,>,'
 PRINT '  <@Param2, sysname, @' + @p21 + '> <datatype_for_param2,> = <default_value_for_param2,>'
 PRINT 'AS'

 PRINT '/*'
 PRINT 'Template NIS (1.1 - 2015-04-01)'
 PRINT ''
 PRINT CHAR(30)
 PRINT 'NOVOMATIC'
 PRINT CHAR(13)
 PRINT '– Author..............: ' + SUSER_SNAME()
 PRINT '– Creation Date.......: ' + CONVERT(VARCHAR, GETDATE(), 103)
 PRINT '– Description.........: <description,,>'
 PRINT CHAR(8)
 PRINT 'Revision'
 PRINT 'Note'
 PRINT '- Use [Tab size] = 3 and [Indent size] = 3'
 PRINT '------------------'
 PRINT '-- Parameters   --'
 PRINT '------------------'
 PRINT CHAR(8)
 PRINT '------------------'
 PRINT '-- Call Example --'
 PRINT '------------------'
 PRINT CHAR(8)
 PRINT '[STAG].[CopyProdTable] @ClubID = 1000400'
 PRINT CHAR(8)
 PRINT '*/'
 PRINT CHAR(10)
 
		 
 PRINT 'BEGIN'
 PRINT 'SET NOCOUNT ON;'

 PRINT CHAR(10)
 PRINT '  – Insert your SQL Statements here'

 PRINT CHAR(10)
 PRINT 'END'
 PRINT 'GO '

END
GO
/****** Object:  StoredProcedure [ERR].[uspLogError]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- uspLogError logs error information in the ErrorLog table about the 
-- error that caused execution to jump to the CATCH block of a 
-- TRY...CATCH construct. This should be executed from within the scope 
-- of a CATCH block otherwise it will return without inserting error 
-- information. 
CREATE PROCEDURE [ERR].[uspLogError] 
    @ErrorLogID [int] = 0 OUTPUT,
	 @ErrorTicket Varchar(50) = NULL,
	 @ErrorRequestDetailID Int = NULL
	  -- contains the ErrorLogID of the row inserted
AS                               -- by uspLogError in the ErrorLog table
BEGIN
    SET NOCOUNT ON;

    -- Output parameter value of 0 indicates that error 
    -- information was not logged
    SET @ErrorLogID = 0;

    BEGIN TRY
        -- Return if there is no error information to log
        IF ERROR_NUMBER() IS NULL
            RETURN;

        -- Return if inside an uncommittable transaction.
        -- Data insertion/modification is not allowed when 
        -- a transaction is in an uncommittable state.
        IF XACT_STATE() = -1
        BEGIN
            PRINT 'Cannot log error since the current transaction is in an uncommittable state. ' 
                + 'Rollback the transaction before executing uspLogError in order to successfully log error information.';
            RETURN;
        END

        INSERT [Err].[ErrorLog] 
            (
            [UserName], 
            [ErrorNumber], 
            [ErrorSeverity], 
            [ErrorState], 
            [ErrorProcedure], 
            [ErrorLine], 
            [ErrorMessage],
				[ErrorTicketCode],
				[ErrorRequestDetailID]
            ) 
        VALUES 
            (
            CONVERT(sysname, CURRENT_USER), 
            ERROR_NUMBER(),
            ERROR_SEVERITY(),
            ERROR_STATE(),
            ERROR_PROCEDURE(),
            ERROR_LINE(),
            ERROR_MESSAGE(),
				@ErrorTicket,
				@ErrorRequestDetailID
            );

        -- Pass back the ErrorLogID of the row inserted
        SET @ErrorLogID = @@IDENTITY;
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred in stored procedure uspLogError: ';
        EXECUTE [ERR].[uspPrintError];
        RETURN -1;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [ERR].[uspPrintError]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- uspPrintError prints error information about the error that caused 
-- execution to jump to the CATCH block of a TRY...CATCH construct. 
-- Should be executed from within the scope of a CATCH block otherwise 
-- it will return without printing any error information.
Create PROCEDURE [ERR].[uspPrintError] 
AS
BEGIN
    SET NOCOUNT ON;

    -- Print error information. 
    PRINT 'Error ' + CONVERT(varchar(50), ERROR_NUMBER()) +
          ', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) +
          ', State ' + CONVERT(varchar(5), ERROR_STATE()) + 
          ', Procedure ' + ISNULL(ERROR_PROCEDURE(), '-') + 
          ', Line ' + CONVERT(varchar(5), ERROR_LINE());
    PRINT ERROR_MESSAGE();
END;

GO
/****** Object:  StoredProcedure [ETL].[Activity]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [ETL].[Activity]
@ActivityID int = NULL OUTPUT,
@Activity varchar(20),
@ActivityTypeID smallint = NULL,
@Message varchar(max) = NULL,
@AddInfo XML = NUL,
@ReturnMessage varchar(1000) = NULL OUTPUT
AS
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: Jena
Creation Date.......: 2016-08-05 
Description.........: 

Revision			 
2016-08-08(Jena).....................: Modifica

Note
- Use [Tab size] = 3 and [Indent size] = 3 (Insert space) 

------------------
-- Parameters   --
------------------	
Activity
- [Start]
- [End]
- [Error]

------------------
-- Note         --
------------------	

------------------
-- Call Example --
------------------
DECLARE @ReturnCode int, @ReturnMessage varchar(1000), @ActivityID int
EXEC @ReturnCode = ETL.Activity @Activity = 'Start', @ActivityID = @ActivityID OUTPUT,  @ActivityTypeID = 1, @ReturnMessage =  @ReturnMessage  OUTPUT
SELECT @ReturnCode ReturnCode, @ReturnMessage ReturnMessage, @ActivityID ActivityID 
*/
BEGIN
SET NOCOUNT ON;
DECLARE @ReturnCode int = 0, @ActivityStateID tinyint, @IsInsert bit = IIF(@ActivityID IS NULL, 1, 0), @IsUpdate bit = IIF(NOT @ActivityID IS NULL, 1, 0);

SET @ActivityStateID = (CASE @Activity WHEN 'Start' THEN 1 WHEN 'End' THEN 2 WHEN 'Error' THEN 3 WHEN 'Warning' THEN 4 END);

--
IF @IsInsert = 1
BEGIN
   INSERT INTO Data.Activity (ActivityTypeID, ActivityStateID) VALUES (@ActivityTypeID, @ActivityStateID)
   SET @ActivityID = SCOPE_IDENTITY();
END;

-- 
IF @IsUpdate = 1
BEGIN
   UPDATE Data.Activity 
   SET ActivityStateID = @ActivityStateID,
       EndDate = SYSDATETIME(),
       Message = @Message,
       AddInfo = @AddInfo
   WHERE ActivityID = @ActivityID;
END;

RETURN @ReturnCode;

END



GO
/****** Object:  StoredProcedure [ETL].[FillTestDataRequestMasterDetail]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC [ETL].[FillTestDataRequestMasterDetail]

SELECT * FROM [ETL].[Request]
SELECT * FROM [ETL].[RequestDetail]
SELECT * FROM [ETL].[Session]
SELECT * FROM [ETL].[Delta]
*/
CREATE PROC [ETL].[FillTestDataRequestMasterDetail]
AS

DELETE FROM ETL.requestDetail
DELETE FROM ETL.request
TRUNCATE TABLE ETL.requestDetail
DROP TABLE ETL.Session
DROP TABLE ETL.Delta

SELECT	* 
INTO	ETL.Session
FROM	ETL.Session_OK

SELECT	* 
INTO	ETL.Delta
FROM	ETL.Delta_OK

INSERT	ETL.request 
		(
			requestDesc
			,requestClaimantId
			,requestStatusId
			,system_date
			,ConcessionaryID
			,ClubID
			,TipoRichiesta
		)
SELECT 
		dbo.CurrentYMD(NULL) + '_' + dbo.CurrentHM(NULL) + dbo.PadLeft(CAST(ROW_NUMBER() OVER(ORDER BY S.requestDetailId) AS varchar(5)),2,'0') AS requestDesc --+ '#' + S.StartTicketCode AS requestDesc
		,10 AS requestClaimantId
		,1 AS requestStatusId
		,GETDATE() AS system_date
		,3 AS ConcessionaryID
		,S.requestDetailId AS ClubID
		,1 AS TipoRichiesta
FROM	
(
	SELECT	DISTINCT
			requestDetailId
	FROM	[ETL].[Session] WITH(NOLOCK)
) S

INSERT	ETL.requestDetail
		(
			requestId
			,ticket
			,clubId
			,ticketDirection
			,detailStatusId
			,system_date
		)
SELECT	distinct
		R.requestId
		,S.StartTicketCode AS ticket
		,R.ClubID AS clubid
		,dbo.RndGen(0,1) AS ticketDirection
		,1 AS detailStatusId
		,GETDATE() AS system_date
FROM	ETL.request R WITH(NOLOCK)
		INNER JOIN
		(
			SELECT	DISTINCT	
					StartTicketCode
					,requestDetailId
			FROM	ETL.Session WITH(NOLOCK)
			WHERE	SessionParentID IS NULL
		) S
		ON R.ClubID = S.requestDetailId
ORDER BY requestId
		
UPDATE	ETL.Session
SET		requestDetailID = D.requestDetailID
FROM	ETL.Session S
		INNER JOIN
		ETL.requestDetail D
		ON S.requestDetailID = D.ClubId

UPDATE	ETL.Delta
SET		requestDetailID = D.requestDetailID
FROM	ETL.Delta L
		INNER JOIN
		ETL.requestDetail D
		ON L.requestDetailID = D.ClubId
		 
GO
/****** Object:  StoredProcedure [ETL].[GetDetailSessionDeltaJSON]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
DECLARE @JSDATA nvarchar(MAX)
EXEC ETL.[GetDetailSessionDeltaJSON] @requestDetailId=10,@JSONDATA=@JSDATA OUTPUT
SELECT @JSDATA AS JSONDATA
*/
CREATE PROC [ETL].[GetDetailSessionDeltaJSON]
			@requestDetailId int = NULL
			,@JSONdata nvarchar(MAX) OUTPUT
AS
IF ISNULL(@requestDetailId,0) > 0
	BEGIN
		SELECT @JSONDATA = 
		(
			SELECT
					 requestDetailId AS 'Detail.requestDetailId'
					,requestId AS 'Detail.requestId'
					,ticket AS 'Detail.ticket'
					,clubId AS 'Detail.clubId'
					,ticketDirection AS 'Detail.ticketDirection'
					,univocalLocationCode AS 'Detail.univocalLocationCode' 
					,elabStart AS 'Detail.elabStart'
					,elabEnd AS 'Detail.elabEnd'
					,detailStatusId AS 'Detail.detailStatusId'
					,fileNameSession AS 'Detail.fileNameSession'
					,fileNameDelta AS 'Detail.fileNameDelta'
					,fileNameOperationLog AS 'Detail.fileNameOperationLog'
					,fileNameErrorLog AS 'Detail.fileNameErrorLog'
					,system_date AS 'Detail.system_date'
					,Session =
					(
						SELECT	*
						FROM	[ETL].[vSessionDeltaJSON] S
						WHERE	S.StartTicketCode = D.ticket
						ORDER BY S.Level
						FOR JSON PATH 
					)
			FROM	ETL.requestDetail D WITH(NOLOCK)
			WHERE	requestDetailId = @requestDetailId
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER 
		)
	END
GO
/****** Object:  StoredProcedure [ETL].[GetFilteredProcessingRequest]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: Valerio, Fabrizio
Creation Date.......: 2017-09-25
Last modified date..: 2017-10-25
Description.........: Recupera le richieste filtrate

Revision			 
Fabrizio: aggiunto intervallo condizionale sulla system date (se impostati entrambi gli estremi)

Note
- Use [Tab size] = 2 and [Indent size]

------------------
-- Parameters   --
------------------	
- ConcessionaryID: ID del concessionario;
- DeteFrom: Dalla data;
- DateTo: Alla data;
- RequestDescription: Descrizione della richiesta;
- RequestStatusID: ID dello stato della richiesta;
- TicketID: ID del ticket;
- RequestClaimantID: ID dell'utente

------------------
-- Call Example --
------------------
DECLARE 
		@testFrom DATETIME = '2017-12-18T00:00:00.000Z' 
		,@testTo DATETIME = '2017-12-18T00:00:00.000Z'
--EXEC ETL.GetFilteredProcessingRequest @dateFrom = '2017-12-18', @dateTo = '2017-12-18'
EXEC ETL.GetFilteredProcessingRequest @dateFrom = @testFrom, @dateTo = @testTo
*/

CREATE PROC	[ETL].[GetFilteredProcessingRequest]
			@ConcessionaryID tinyint = NULL
			,@DateFrom datetime = NULL
			,@DateTo datetime = NULL
			,@RequestDescription nvarchar(150) = NULL
			,@RequestStatusID tinyint = NULL
			,@TicketID varchar(50) = NULL
			,@RequestClaimantID smallint = NULL
AS

BEGIN
	
	DECLARE 
			@FROM varchar(10) = NULL
			,@TO varchar(10) = NULL

	IF ISNULL(@DateFrom,'') != ''
	AND ISNULL(@DateTo,'') != ''
		BEGIN
			SET @FROM = dbo.ToISOdate(@DateFrom)
			SET @TO = dbo.ToISOdate(@DateTo)
		END
	
	SELECT	*
	FROM	vRequest
	WHERE	(ConcessionaryID = @ConcessionaryID OR @ConcessionaryID IS NULL)
	AND		1 = 
			CASE	
				WHEN @FROM IS NOT NULL
				THEN 
					CASE
						WHEN (dbo.ToISOdate(system_date) BETWEEN @FROM AND @TO)
						THEN 1
						ELSE 0
					END
				ELSE 1
			END
	AND		(requestDesc = @RequestDescription OR @RequestDescription IS NULL)
	AND		(requestStatusId = @RequestStatusID OR @RequestStatusID IS NULL)
	AND		(requestClaimantId = @RequestClaimantID OR @RequestClaimantID IS NULL)

END
GO
/****** Object:  StoredProcedure [ETL].[GetMasterDetailSessionDeltaJSON]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
DECLARE @JSDATA nvarchar(MAX)
EXEC ETL.GetMasterDetailSessionDeltaJSON @requestId=174,@JSONDATA=@JSDATA OUTPUT
SELECT @JSDATA AS JSONDATA
*/
CREATE PROC [ETL].[GetMasterDetailSessionDeltaJSON]
			@requestId int = NULL
			,@JSONdata nvarchar(MAX) OUTPUT
AS
IF ISNULL(@requestId,0) > 0
	BEGIN
		SELECT @JSONDATA = 
		(
			SELECT 	 TOP 1
					 R.requestId AS 'Master.requestId'
					,R.requestDesc AS 'Master.requestDesc'
					,R.requestClaimantId AS 'Master.requestClaimantId'
					,R.elabStart AS 'Master.elabStart'
					,R.elabEnd AS 'Master.elabEnd'
					,R.requestStatusId AS 'Master.requestStatusId'
					,R.system_date AS 'Master.system_date'
					,R.ConcessionaryID AS 'Master.ConcessionaryID'
					,R.ClubID AS 'Master.ClubID'
					,R.FilterAmount AS 'Master.FilterAmount'
					,R.FilterStartDate AS 'Master.FilterStartDate'
					,R.FilterEndDate AS 'Master.FilterEndDate'
					,R.TipoRichiesta AS 'Master.TipoRichiesta'
					,Detail =
					(
						SELECT
								D.requestDetailId
								,D.requestId
								,D.ticket
								,D.clubId
								,D.ticketDirection
								,D.univocalLocationCode 
								,D.elabStart
								,D.elabEnd
								,D.detailStatusId
								,D.fileNameSession
								,D.fileNameDelta
								,D.fileNameOperationLog
								,D.fileNameErrorLog
								,D.system_date
								,Session =
								(
									SELECT	*
									FROM	[ETL].[vSessionDeltaJSON] S --[ETL].[Session] S WITH(NOLOCK)
									WHERE	S.StartTicketCode = D.ticket
									ORDER BY S.Level
									FOR JSON PATH 
								)
						FROM	ETL.requestDetail D WITH(NOLOCK)
						WHERE	R.requestId = D.requestId
						FOR JSON PATH 
					)
			FROM	ETL.request R WITH(NOLOCK)
			WHERE	R.requestId = @requestId
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		)  
	END
GO
/****** Object:  StoredProcedure [ETL].[GetRemoteConcessionary]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
RECUPERO DELLA LISTA COMPLETA (O DI UNA QUOTA PARTE DI ESSI) DEI CONCESSIONARI DA 600DWH

ESEMPI DI INVOCAZIONE:

EXEC [ETL].[GetRemoteConcessionary] -- RITORNA LA LISTA COMPLETA
EXEC [ETL].[GetRemoteConcessionary] @ExcludedID=7 -- RITORNA LA LISTA COMPLETA, AD ESCLUSIONE DI "GMatica"
EXEC [ETL].[GetRemoteConcessionary] @ID=7-- RITORNA SOLO IL SECONDO ELEMENTO (AD OGGI "GMatica")
EXEC [ETL].[GetRemoteConcessionary] @Name='Gmatic' -- RITORNA IL SETTIMO ELEMENTO (AD OGGI "GMatica"); NOTARE CHE NEL PARAMETRO MANCA LA "A" FINALE... LA RICERCA AVVIENE PER LIKE
EXEC [ETL].[GetRemoteConcessionary] @SystemCode='1411000' -- RITORNA IL SETTIMO ELEMENTO (AD OGGI "GMatica"); NOTARE CHE NEL PARAMETRO MANCANO LE TRE CIFRE FINALI... LA RICERCA AVVIENE PER LIKE
EXEC [ETL].[GetRemoteConcessionary] @Letter='D' -- RITORNA IL SETTIMO ELEMENTO (AD OGGI "GMatica");
EXEC [ETL].[GetRemoteConcessionary] @Number=1 -- RITORNA IL SETTIMO ELEMENTO (AD OGGI "GMatica");

*/
CREATE PROC	[ETL].[GetRemoteConcessionary]
			@ID int = NULL
			,@ExcludedID int = NULL
			,@Name varchar(50) = NULL
			,@SystemCode varchar(1000) = NULL
			,@Letter char(1) = NULL
			,@Number tinyint = NULL
AS
SELECT	
		ConcessionarySK
		,ConcessionaryName 
		,ConcessionarySystemCode
		,ConcessionaryLetter
		,ConcessionaryNumber
FROM	[600DWH].[dim].[Concessionary] WITH(NOLOCK)
WHERE	(ConcessionarySK = @ID OR @ID IS NULL)
AND		(ConcessionarySK != @ExcludedID OR @ExcludedID IS NULL)
AND		(ConcessionaryName LIKE '%' + @Name + '%' OR @Name IS NULL)
AND		(ConcessionarySystemCode LIKE '%' + @SystemCode + '%' OR @SystemCode IS NULL)
AND		(ConcessionaryLetter = @Letter OR @Letter IS NULL)
AND		(ConcessionaryNumber = @Number OR @Number IS NULL)
GO
/****** Object:  StoredProcedure [ETL].[GetRequestClaimant]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
RECUPERO DELLA LISTA COMPLETA (O DI UNA QUOTA PARTE DI ESSI) DEI CLAIMANTS

ESEMPI DI INVOCAZIONE:

EXEC [ETL].[GetRequestClaimant] -- RITORNA LA LISTA COMPLETA
EXEC [ETL].[GetRequestClaimant] @ID=10 -- RITORNA SOLO IL SECONDO ELEMENTO (AD OGGI "Administrator")
EXEC [ETL].[GetRequestClaimant] @Name='ANDREN' -- RITORNA IL SETTIMO ELEMENTO (AD OGGI "Gianpiero Andrenacci"); NOTARE CHE NEL PARAMETRO MANCA LA PARTE FINALE... LA RICERCA AVVIENE PER LIKE
EXEC [ETL].[GetRequestClaimant] @Email='MICUCCI' -- RITORNA IL SETTIMO ELEMENTO (AD OGGI "o.micucci@novomatic.it"); NOTARE CHE NEL PARAMETRO MANCANO LA PARTE FINALE ED INIZIALE... LA RICERCA AVVIENE PER LIKE
EXEC [ETL].[GetRequestClaimant] @Email='ALIF' -- RITORNA IL SETTIMO ELEMENTO (AD OGGI "Califfa"); NOTARE CHE NEL PARAMETRO MANCANO LA PARTE FINALE ED INIZIALE... LA RICERCA AVVIENE PER LIKE

*/
CREATE PROC	[ETL].[GetRequestClaimant]
			@ID smallint = NULL
			,@Name nvarchar(150) = NULL
			,@Email nvarchar(150) = NULL
			,@Folder nvarchar(150) = NULL
AS
SELECT	
		 requestClaimantId 
		,requestClaimantName 
		,requestClaimantEmail
		,requestClaimantFolder

FROM	[ETL].[requestClaimant] WITH(NOLOCK)
WHERE	(requestClaimantId = @ID OR @ID IS NULL)
AND		(requestClaimantName LIKE '%' + @Name + '%' OR @Name IS NULL)
AND		(requestClaimantEmail LIKE '%' + @Email + '%' OR @Email IS NULL)
AND		(requestClaimantFolder LIKE '%' + @Folder + '%' OR @Folder IS NULL)
GO
/****** Object:  StoredProcedure [ETL].[GetRequestStatus]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
RECUPERO DELLA LISTA COMPLETA (O DI UNA QUOTA PARTE DI ESSI) DEI CLAIMANTS

ESEMPI DI INVOCAZIONE:

EXEC [ETL].[GetRequestStatus] -- RITORNA LA LISTA COMPLETA
EXEC [ETL].[GetRequestStatus] @ID=1 -- RITORNA SOLO IL PRIMO ELEMENTO (AD OGGI "pending")
EXEC [ETL].[GetRequestStatus] @Desc='pend' -- RITORNA IL PRIMO ELEMENTO (AD OGGI "pending"); NOTARE CHE NEL PARAMETRO MANCA LA PARTE FINALE... LA RICERCA AVVIENE PER LIKE
EXEC [ETL].[GetRequestStatus] @Date='2017-05-25 11:55' -- RITORNA IL SETTIMO ELEMENTO (AD OGGI "o.micucci@novomatic.it"); NOTARE CHE NEL PARAMETRO MANCANO LA PARTE FINALE ED INIZIALE... LA RICERCA AVVIENE PER LIKE

*/
CREATE PROC	[ETL].[GetRequestStatus]
			@ID tinyint = NULL
			,@Desc varchar(25) = NULL
			,@Date datetime2(3) = NULL
AS

DECLARE	@strDATE varchar(26)
IF ISNULL(@Date,'') != ''
	SET	@strDATE = REPLACE(REPLACE(REPLACE(CAST(@DATE AS varchar(26)),'.000',''),':00',''),' 00','') 

SELECT	
		 requestStatusId 
		,requestStatusDesc 
		,system_date

FROM	[ETL].[requestStatus] WITH(NOLOCK)
WHERE	(requestStatusId = @ID OR @ID IS NULL)
AND		(requestStatusDesc LIKE '%' + @Desc + '%' OR @Desc IS NULL)
AND		(CONVERT(DATETIME,SUBSTRING(CAST(system_date AS varchar(26)),1,LEN(@strDATE)),120) = CONVERT(DATETIME, @strDate, 120) OR @Date IS NULL)
GO
/****** Object:  StoredProcedure [ETL].[GetSessionDeltaJSON]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
DECLARE @JSDATA nvarchar(MAX)
EXEC ETL.GetSessionDeltaJSON @requestDetailId=1, @SessionID=-2147483648,@JSONDATA=@JSDATA OUTPUT
SELECT @JSDATA AS JSONDATA
*/
CREATE PROC [ETL].[GetSessionDeltaJSON]
			@requestDetailId int = NULL
			,@SessionID int = NULL
			,@JSONdata nvarchar(MAX) OUTPUT
AS
IF ISNULL(@requestDetailId,0) > 0
AND @SessionID IS NOT NULL -- NON USARE QUI "ISNULL(@SessionID,0) > 0" PERCHE' ESISTONO SessionID NEGATIVI
	BEGIN
		SELECT @JSONDATA = 
		(
			SELECT	TOP 1
 					 RecID AS 'Session.RecID'
					,requestDetailId AS 'Session.requestDetailId'
					,SessionID AS 'Session.SessionID'
					,SessionParentID AS 'Session.SessionParentID'
					,[Level] AS 'Session.Level'
					,UnivocalLocationCode AS 'Session.UnivocalLocationCode'
					,MachineID AS 'Session.MachineID'
					,GD AS 'Session.GD'
					,AamsMachineCode AS 'Session.AamsMachineCode'
					,StartServerTime AS 'Session.StartServerTime'
					,EndServerTime AS 'Session.EndServerTime'
					,TotalRows AS 'Session.TotalRows'
					,TotalBillIn AS 'Session.TotalBillIn'
					,TotalCoinIN AS 'Session.TotalCoinIN'
					,TotalTicketIn AS 'Session.TotalTicketIn'
					,TotalBetValue AS 'Session.TotalBetValue'
					,TotalBetNum AS 'Session.TotalBetNum'
					,TotalWinValue AS 'Session.TotalWinValue'
					,TotalWinNum AS 'Session.TotalWinNum'
					,Tax AS 'Session.Tax'
					,TotalIn AS 'Session.TotalIn'
					,TotalOut AS 'Session.TotalOut'
					,FlagMinVltCredit AS 'Session.FlagMinVltCredit'
					,StartTicketCode AS 'Session.StartTicketCode'
					,Delta =
					(
						SELECT
								 RecID
								,requestDetailId
								,RowID
								,UnivocalLocationCode
								,ServerTime
								,MachineID
								,GD
								,AamsMachineCode
								,GameID
								,GameName
								,VLTCredit
								,TotalBet
								,TotalWon
								,TotalBillIn
								,TotalCoinIn
								,TotalTicketIn
								,TotalHandPay
								,TotalTicketOut
								,Tax
								,TotalIn
								,TotalOut
								,WrongFlag
								,TicketCode
								,SessionID
						FROM	ETL.Delta L WITH(NOLOCK)
						WHERE	L.SessionID = S.SessionID
						AND		L.requestDetailId = S.requestDetailId
						FOR JSON PATH 
					)
			FROM	[ETL].[Session] S WITH(NOLOCK)
			WHERE	requestDetailId = @requestDetailId
			AND		SessionID = @SessionID
			ORDER BY RecID DESC
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		)
	END
GO
/****** Object:  StoredProcedure [ETL].[GetTicketFromSelect]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [ETL].[GetTicketFromSelect]
@requestId int,
@ConcessionaryID tinyint = NULL,
@ClubID varchar(10) = NULL,
@FromDate datetime = NULL,
@ToDate datetime = NULL,
@ISpaid tinyint= 1 ,
@Threshold int = 100000,
@LoadTicketToCalc tinyint = 1,
@ReturnMessage varchar(1000) = NULL OUTPUT 
AS
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: GA
Creation Date.......: 2017-05-22
Description.........: Calcola la sessione da Out a Out

Note
- Use [Tab size] = 3 and [Indent size] 3 (Insert spaces)

------------------
-- Parameters   --
------------------	

------------------
-- Call Example --
------------------  
EXEC [ETL].[RequestElaborate]
*/
BEGIN
	SET NOCOUNT ON;

		BEGIN TRY
		 -- -- tutti i ticket del 2013
			--DECLARE @ReturnCode int, @ReturnMessage varchar(1000) 
			--EXEC @ReturnCode = [Ticket].[Extract_Pomezia]  @ConcessionaryID = 7,  @FromDate = '20130101',@ToDate = '20140101',@ISpaid = 1,@Threshold = 100000,@LoadTicketToCalc = 1,@ReturnMessage = @ReturnMessage OUTPUT
			--SELECT @ReturnCode ReturnCode, @ReturnMessage ReturnMessage 
			--INSERT INTO [ETL].[requestDetail] ()
			--select * from [RAW].[TTicketIN]
			declare @tt table (Ticket varchar(20),direction bit,ClubId varchar(20))

			INSERT INTO [ETL].[requestDetail] ([requestId],[ticket],[ticketDirection],[clubId])
			VALUES (@RequestId,'',0,NULL),
			(@RequestId,'',0,NULL),
			(@RequestId,'',0,NULL), 
			(@RequestId,'',0,NULL),
			(@RequestId,'',0,NULL), 
			(@RequestId,'',0,NULL), 
			(@RequestId,'',0,NULL), 
			(@RequestId,'',0,NULL)
			
		END TRY
		-- Gestione Errore
			BEGIN CATCH	
				SET @ReturnMessage = ERROR_MESSAGE();
			END CATCH
			-- fine calcoli
END
GO
/****** Object:  StoredProcedure [ETL].[GettingSubActivityType]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL].[GettingSubActivityType]
	@ConcessionaryName VARCHAR(100) = 'GMatica',
	@Step TINYINT = 1,
	@SubActivityTypeID SMALLINT OUTPUT

	-- Add the parameters for the stored procedure here
AS
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............:  Antonella Borrelli
Creation Date.......:  
Description.........:  

Revision			 

Note

- Use [Tab size] = 3 and [Indent size] 3 (Insert spaces)


------------------
-- Parameters   --
------------------	

------------------
-- Call Example --
------------------

DECLARE	@return_value int,
		@SubActivityTypeID smallint

EXEC	[ETL].[GettingSubActivityType]
		@ConcessionaryName = 'GMatica',
		@Step = 1,
		@SubActivityTypeID = @SubActivityTypeID OUTPUT

SELECT	@SubActivityTypeID as N'@SubActivityTypeID'

*/

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

IF @Step = 1
BEGIN
	SELECT @SubActivityTypeID = S.SubActivityTypeID
	  FROM Catalog.SubActivityType S
	WHERE  S.SubActivityType = 'Load Staging ' + @ConcessionaryName
END

IF @Step = 2
BEGIN
	SELECT @SubActivityTypeID = S.SubActivityTypeID
	  FROM Catalog.SubActivityType S
	WHERE  S.SubActivityType = 'Load Dimension ' + @ConcessionaryName
END

IF @Step = 3
BEGIN
	SELECT @SubActivityTypeID = S.SubActivityTypeID
	  FROM Catalog.SubActivityType S
	WHERE  S.SubActivityType = 'Load Daily Vlt ' + @ConcessionaryName
END

IF @Step = 4
BEGIN
	SELECT @SubActivityTypeID = S.SubActivityTypeID
	  FROM Catalog.SubActivityType S
	WHERE  S.SubActivityType = 'Load Daily Game ' + @ConcessionaryName
END

END



GO
/****** Object:  StoredProcedure [ETL].[InsertTicketFromImportOrManual]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: Fabrizio Ricciarelli
Creation Date.......: 2017-12-06
Description.........: SP per inserimento nelle tabelle master e di dettaglio richiesta da input manuale e/o importazione da CSV

------------------
-- Parameters   --
------------------	
@requestDesc varchar(150) * mandatory
@requestClaimantId smallint * mandatory
@ConcessionaryID tinyint * mandatory
@ticketList ETL.TicketTbl READONLY
@ReturnMessage varchar(1000) OUTPUT 

------------------
-- Call Example --
------------------
DECLARE	@mylist ETL.TicketTbl, @ReturnMessage varchar(1000), @LASTMASTERID INT
INSERT @mylist (ticket, ticketDirection, clubId)
VALUES 
		('58422214835338610',0,'0'),
		('58707400519556830',0,'0'),
		('64492000056259545',1,'0'), 
		('67967006555949464',1,'0'),
		('68795144968901671',1,'0'), 
		('90086637885313270',1,'0'), 
		('94076559426442391',0,'0'), 
		('94890953944170659',0,'0')
EXEC	@LASTMASTERID = ETL.InsertTicketFromImportOrManual @requestDesc='20171206_1544', @requestClaimantId=10, @ConcessionaryID=7, @ticketList=@mylist, @ReturnMessage = @ReturnMessage OUTPUT
SELECT	@ReturnMessage AS OperationResults
IF @LASTMASTERID > 0
	BEGIN 
		SELECT * FROM ETL.request WHERE requestID = @LASTMASTERID
		SELECT * FROM ETL.requestDetail WHERE requestID = @LASTMASTERID
	END
*/
CREATE PROC	[ETL].[InsertTicketFromImportOrManual]
			@requestDesc varchar(150) = NULL
			,@requestClaimantId smallint = NULL
			,@ConcessionaryID tinyint = NULL
			,@ticketList ETL.TicketTbl READONLY												
			,@ReturnMessage varchar(1000) = NULL OUTPUT 							  
AS
SET NOCOUNT ON;

BEGIN TRY
	------------------------------------------------------------------
	-- 0. DEFINIZIONE VARIABILI DI SERVIZIO
	------------------------------------------------------------------
	DECLARE
			@requestId int = 0 -- Identificativo chiave della tabella master, ritornato dalla SCOPE_IDENTITY in fase di inserimento
			,@requestTypeId int = 0 -- Identificativo del tipo di richiesta (manuale/importazione = 1, da CQI/selezione = 2)
			,@requestStatusId int = 0 -- Identificativo dello stato della richiesta (pending = 1, elaboration = 2, failed = 3, partially completed = 4, fully completed = 5)
			,@FOUND int = 0 -- Numero di records passati nella lista dei ticket
			,@INSERTED int = 0 -- Numero di records inseriti nella tabella di destinazione
			,@DUPLICATEDONMASTER int = 0 -- Numero di records NON inseriti nella tabella MASTER di destinazione in quanto rilevati come duplicati
			,@DUPLICATEDONDETAIL int = 0 -- Numero di records NON inseriti nella tabella DETTAGLIO di destinazione in quanto rilevati come duplicati
			,@ReturnCode int = 0 -- Codice ritornato dalle SP/Funzioni invocate
	------------------------------------------------------------------

	IF ISNULL(@requestDesc,'') != ''
	AND ISNULL(@requestClaimantId,0) > 0
	AND ISNULL(@ConcessionaryID,0) > 0
		BEGIN

			------------------------------------------------------------------
			-- 1. TABELLA DI TRANSITO PER BYPASS DUPLICATI
			------------------------------------------------------------------
			DECLARE @PRE TABLE (
					requestDesc varchar(150)
					,requestClaimantId smallint
					,requestStatusId tinyint
					,ConcessionaryID tinyint
				)

			-- CONTEGGIO RECORDS VOCI DI DETTAGLIO PASSATE IN INGRESSO COME PARAMETRO
			SELECT	@FOUND = COUNT(*)
			FROM	@ticketList

			IF @FOUND > 0
				BEGIN
					---------------------------------------------------------------------------
					-- 1a. POPOLAMENTO TABELLA DI TRANSITO PER SUCCESSIVA ESCLUSIONE DUPLICATI
					---------------------------------------------------------------------------
					INSERT @PRE(requestDesc, requestClaimantId, ConcessionaryID, requestStatusId)
					SELECT 
							@requestDesc AS requestDesc															 
							,@requestClaimantId AS requestClaimantId
							,@ConcessionaryID AS ConcessionaryID
							,(SELECT requestStatusId FROM ETL.requestStatus WITH(NOLOCK) WHERE requestStatusDesc LIKE '%pending%') AS requestStatusId


					------------------------------------------------------------------
					-- 2. POPOLAMENTO TABELLA MASTER CON ESCLUSIONE DUPLICATI
					------------------------------------------------------------------
					-- CONTEGGIO DUPLICATI (SE PRESENTI)
					SELECT	@DUPLICATEDONMASTER = COUNT(*)
					FROM	@PRE P
							INNER JOIN
							ETL.request R WITH(NOLOCK)
							ON P.requestClaimantId = R.requestClaimantId
							AND P.ConcessionaryID = R.ConcessionaryID
							AND P.requestStatusId = R.requestStatusId
							AND P.requestDesc = R.requestDesc
					--WHERE	R.requestDesc IS NOT NULL -- DUPLICATI

					IF ISNULL(@DUPLICATEDONMASTER,0) < 1
						BEGIN 
							INSERT ETL.request(requestDesc, requestClaimantId, ConcessionaryID, requestStatusId, TipoRichiesta, system_date)
							SELECT 
									P.requestDesc															 
									,P.requestClaimantId
									,P.ConcessionaryID
									,P.requestStatusId
									,(SELECT requestTypeId FROM ETL.requestType WITH(NOLOCK) WHERE requestTypeDesc LIKE '%manuale%') AS TipoRichiesta
									,GETDATE() AS system_date
							FROM	@PRE P
									LEFT JOIN
									ETL.request R WITH(NOLOCK)
									ON P.requestClaimantId = R.requestClaimantId
									AND P.ConcessionaryID = R.ConcessionaryID
									AND P.requestStatusId = R.requestStatusId
									AND P.requestDesc = R.requestDesc
							WHERE	R.requestDesc IS NULL -- IMPEDISCE I DUPLICATI

							SET @requestId = SCOPE_IDENTITY()

							IF ISNULL(@requestId,0) > 0
								BEGIN
									------------------------------------------------------------------
									-- 3. POPOLAMENTO TABELLA DI DETTAGLIO CON ESCLUSIONE DUPLICATI
									------------------------------------------------------------------
			
									-- CONTEGGIO DUPLICATI (SE PRESENTI)
									SELECT	@DUPLICATEDONDETAIL = COUNT(*)
									FROM	@ticketList P
											LEFT JOIN
											ETL.requestDetail RD WITH(NOLOCK)
											ON RD.requestId = @requestId 
											AND P.clubId = ISNULL(RD.clubId,'0') -- SUL LATO "PRE" IL CLUBID E' GIA' SICURAMENTE DIVERSO DA NULL
											AND P.ticket = LTRIM(RTRIM(ISNULL(RD.ticket,''))) -- SUL LATO "PRE" IL TICKET E' GIA' TRIMMATO E SICURAMENTE DIVERSO DA NULL
									WHERE	RD.requestId IS NOT NULL -- DUPLICATI

									-- INSERIMENTO NELLA TABELLA FINALE DI DETTAGLIO RICHIESTE, SENZA DUPLICATI
									INSERT	ETL.requestDetail 
											(
												requestId
												,ticket
												,clubId
												,ticketDirection
												,univocalLocationCode
												,elabStart
												,elabEnd
												,detailStatusId
												,fileNameSession
												,fileNameDelta
												,fileNameOperationLog
												,fileNameErrorLog
												,system_date
											)
									SELECT	@requestId
											,P.ticket
											,P.clubId
											,P.ticketDirection
											,P.univocalLocationCode
											,P.elabStart
											,P.elabEnd
											,P.detailStatusId
											,P.fileNameSession
											,P.fileNameDelta
											,P.fileNameOperationLog
											,P.fileNameErrorLog
											,ISNULL(P.system_date,GETDATE()) AS system_date 
									FROM	@ticketList P
											LEFT JOIN
											ETL.requestDetail RD WITH(NOLOCK)
											ON RD.requestId = @requestId
											AND ISNULL(P.clubId,'0') = ISNULL(RD.clubId,'0')
											AND LTRIM(RTRIM(ISNULL(P.ticket,''))) = LTRIM(RTRIM(ISNULL(RD.ticket,'')))
									WHERE	RD.requestId IS NULL -- IMPEDISCE I DUPLICATI

									SET @INSERTED = @@ROWCOUNT

									SET @ReturnMessage = 
										'FOUND ON INPUT: ' + CAST(@FOUND AS varchar(20)) + ' RECORDS, INSERTED: ' + CAST(@INSERTED AS varchar(20)) + ' RECORDS, DUPLICATES EXCLUDED: ' + CAST(@DUPLICATEDONDETAIL AS varchar(20)) + ' RECORDS'
									------------------------------------------------------------------
								END
							ELSE
								BEGIN
									SET @ReturnMessage = 'CAN''T CREATE THE MASTER RECORD - NO DATA INSERTED.'	
								END
						END
					ELSE
						BEGIN
							SET @ReturnMessage = 'MASTER RECORD DUPLICATED - NO DATA INSERTED.'	
						END
				END
			ELSE
				BEGIN
					SET @ReturnMessage = 'NO DATA TO BE PROCESSED.'	
				END
		END	
		
		RETURN @requestId	
END TRY

BEGIN CATCH	
	SET @ReturnMessage = ERROR_MESSAGE();
	RETURN -1
END CATCH
GO
/****** Object:  StoredProcedure [ETL].[InsertTicketFromSelect]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: Fabrizio Ricciarelli
Creation Date.......: 2017-12-06
Description.........: SP per inserimento in tabella di dettaglio richiesta da prelievo CQI

------------------
-- Parameters   --
------------------	
@requestId int nullable
@ClaimantID tinyint nullable
@ConcessionaryID tinyint nullable
@ClubID varchar(10) nullable
@FromDate datetime nulable
@ToDate datetime nullable
@ISpaid tinyint default 1
@Threshold int default 100000 (which is interpreted as 1000,00)
@LoadTicketToCalc tinyint default 1
@COUNTONLY bit default 0
@ReturnMessage varchar(1000) OUTPUT 

------------------
-- Call Example --
------------------
DECLARE	@ReturnMessage varchar(1000)  
EXEC	ETL.InsertTicketFromSelect
		@requestId = 76  -- se specificato, aggiunge solo le righe di dettaglio (se non duplicate), altrimenti, se NULL o ZERO, inserisce una nuova richiesta master e vi appende le righe di dettaglio
		,@ClaimantID = 10
		,@ConcessionaryID = 4
		,@COUNTONLY = 1
		,@ReturnMessage = @ReturnMessage OUTPUT
SELECT	@ReturnMessage AS OperationResults
*/
CREATE PROC	[ETL].[InsertTicketFromSelect]
			@requestId int = null
			,@ClaimantID tinyint = NULL
			,@ConcessionaryID tinyint = NULL
			,@ClubID varchar(10) = NULL
			,@FromDate datetime = NULL
			,@ToDate datetime = NULL
			,@ISpaid tinyint= 1
			,@Threshold int = 100000
			,@LoadTicketToCalc tinyint = 1
			,@COUNTONLY bit = 0
			,@ReturnMessage varchar(1000) = NULL OUTPUT 
AS
SET NOCOUNT ON;

BEGIN TRY
	------------------------------------------------------------------
	-- 0. DEFINIZIONE VARIABILI DI SERVIZIO
	------------------------------------------------------------------
	DECLARE
			@USESTUB bit = 1 -- *** ATTENZIONE !!! IMPOSTARE A 0 UNA VOLTA ALLINEATI I DB, OVVERO, QUANDO LA SP [Ticket].[Extract_Pomezia] SARA' RAGGIUNGIBILE DA QUESTO SERVER
			
			,@MASTER_RECORD_OK bit = 0 -- Identifica la corretta creazione del record di riferimento nella tabella master (ETL.Request)
			,@FOUND int = 0 -- Numero di records trovati in CQI corrispondenti ai criteri di ricerca
			,@INSERTED int = 0 -- Numero di records inseriti nella tabella di destinazione
			,@DUPLICATED int = 0 -- Numero di records NON inseriti nella tabella di destinazione in quanto rilevati come duplicati
			,@MAXID int = 0 -- Massimo valore contenuto nella colonna ID della tabella di prelievo (dove verranno riversati i dati da CQI)
			,@LASTID int = 0 -- Massimo valore contenuto nella colonna ID della tabella di prelievo dopo lo scarico (dove sono stati riversati i dati da CQI)
			,@ReturnCode int = 0 -- Codice ritornato dalle SP/Funzioni invocate

	------------------------------------------------------------------
	-- 1. TABELLA DI TRANSITO PER BYPASS DUPLICATI
	------------------------------------------------------------------
	DECLARE	@PRE TABLE
			(
				requestId int NOT NULL
				,ticket varchar(50) NULL
				,clubId varchar(10) NULL
				,ticketDirection bit NULL
			)

	----------------------------------------------------------------
	-- 1.a IDENTIFICAZIONE CORRETTO REQUESTID	PER INSERIMENTO 
	-- FITTIZIO NELLE TABELLE PRE
	----------------------------------------------------------------
	IF @COUNTONLY = 1
		BEGIN
			SELECT	@RequestId =
					CASE
						WHEN	ISNULL(@requestId,0) <= 0 -- SE IL VALORE SPECIFICATO E' NULL/INFERIORE/UGUALE A ZERO
						THEN	(SELECT ISNULL(MAX(requestId),0)+1 FROM ETL.request) -- ALLORA PRELEVA L'ID PIU' ALTO E VI AGGIUNGE 1 (SE LA TABELLA E' COMPLETAMENTE VUOTA GENERERA' L'ID NUMERO 1)
						ELSE	@RequestId -- ALTRIMENTI UTILIZZA IL VALORE SPECIFICATO
					END
		END		
	-----------------------------------------------------------------------------------
	-- 1.b PREPARAZIONE RECORD RICHIESTA MASTER	(se requestID non è stato specificato)
	-----------------------------------------------------------------------------------
	IF ISNULL(@requestId,0) <= 0 -- SE IL VALORE SPECIFICATO E' NULL/INFERIORE/UGUALE A ZERO
	AND @COUNTONLY = 0 -- E NON E' STATO RICHIESTO IL SOLO CONTEGGIO
		BEGIN
			INSERT ETL.request([requestDesc], [requestClaimantId], [ConcessionaryID], [ClubID], [requestStatusId], [TipoRichiesta], [system_date])
			SELECT
					dbo.Nowsmall('_',NULL,NULL) AS requestDesc -- ritorna una stringa del tipo "20171212_1055"
					,@ClaimantID AS requestClaimantId 
					,@ConcessionaryID AS ConcessionaryID
					,@ClubID AS ClubID
					,(SELECT ISNULL(requestStatusId,1) FROM ETL.requestStatus WITH(NOLOCK) WHERE requestStatusDesc LIKE '%pending%') AS requestStatusId
					,(SELECT ISNULL(RequestTypeId,2) FROM ETL.requestType WITH(NOLOCK) WHERE requestTypeDesc LIKE '%selezione%') AS TipoRichiesta
					,GETDATE() AS system_date

			SET @requestId = SCOPE_IDENTITY()
		END

	IF @USESTUB = 0
		BEGIN
			----------------------------------------------------------------
			-- 2.a FUNZIONE REALE
			----------------------------------------------------------------
			BEGIN TRAN -- Operazione svolta in transazione a garanzia di isolamento degli estremi superiore ed inferiore del set di record inserito

				-- PRELIEVO MASSIMO ID DALLA TABELLA DI PRELIEVO (DATI CQI) PRIMA DEL SUO POPOLAMENTO (PER ESCLUDERE QUANTO PRESENTE IN PRECEDENZA)
				SELECT	@MAXID = MAX(ID)
				FROM	RAW.TTicketIN
	
				-- INVOCAZIONE SP REMOTA SU CQI CON POPOLAMENTO TABELLA LOCALE DI PRELIEVO (RAW.TTicketIN)
				EXEC	@ReturnCode = 
						[POM-MON01].[GMATICA_AGS_RawData_Elaborate_Agile].[Ticket].[Extract_Pomezia] -- ESTRAZIONE, DA CQI, DEI TICKETS CORRISPONDENTI AI CRITERI IMPOSTATI 
							@ConcessionaryID = @ConcessionaryID
							,@FromDate = @FromDate
							,@ToDate = @ToDate
							,@ISpaid = @ISpaid										
							,@Threshold = @Threshold
							,@LoadTicketToCalc = @LoadTicketToCalc
							,@ReturnMessage = @ReturnMessage OUTPUT
	
				-- PRELIEVO MASSIMO ID DALLA TABELLA DI PRELIEVO (DATI CQI) DOPO IL SUO POPOLAMENTO (PER ESCLUDERE QUANTO PRESENTE IN PRECEDENZA)
				SELECT	@LASTID = MAX(ID)
				FROM	RAW.TTicketIN

			COMMIT TRAN


			IF LTRIM(RTRIM(@ReturnMessage)) = '' -- Se la SP non ha ritornato errori, procede
				BEGIN
					-- POPOLAMENTO TABELLA DI TRANSITO CON TUTTI I RECORDS RITORNATI DALL'ESTRAZIONE DA CQI
					INSERT @PRE (requestId, ticket, ticketDirection, clubId)
					SELECT	
							@requestId AS requestId
							,LTRIM(RTRIM(ISNULL(TicketID,''))) AS Ticket
							,0 AS ticketDirection
							,ISNULL(clubId,'0') AS ClubID
					FROM	RAW.TTicketIN WITH(NOLOCK)
					WHERE	(ID BETWEEN @MAXID AND @LASTID)	-- Soltanto i records inseriti dalla precedente chiamata: quanto presente in precedenza o successivamente sarà ignorato
			
					SET @FOUND = @@ROWCOUNT -- Valorizzato soltanto nel caso in cui la precedente SP ha ritornato, senza errori, almeno un record

					-- PULIZIA DELLA TABELLA DI PRELIEVO
					-- (Non resterà traccia dei dati appoggiati)
					DELETE
					FROM	RAW.TTicketIN
					WHERE	(ID BETWEEN @MAXID AND @LASTID)
				END
			ELSE
				BEGIN
					SET @ReturnMessage = @ReturnMessage
				END
			----------------------------------------------------------------
		END	
	ELSE
		BEGIN
			------------------------------------------------------------------
			-- 2.b STUB
			------------------------------------------------------------------
			INSERT @PRE (requestId, ticket, ticketDirection, clubId)
			VALUES 
					(@RequestId,'11111111111111111',0,'0'),
					(@RequestId,'22222222222222222',0,'0'),
					(@RequestId,'33333333333333333',1,'0'), 
					(@RequestId,'44444444444444444',1,'0'),
					(@RequestId,'55555555555555555',1,'0'), 
					(@RequestId,'66666666666666666',1,'0'), 
					(@RequestId,'77777777777777777',0,'0'), 
					(@RequestId,'88888888888888888',0,'0'),
					(@RequestId,'99999999999999999',0,'0')

			SET @FOUND = 8 -- NUMERO DI RECORD INSERITI MANUALMENTE (VALUES)
			------------------------------------------------------------------
		END

	IF @FOUND > 0
		BEGIN
			------------------------------------------------------------------
			-- 3. POPOLAMENTO TABELLA DI DESTINAZIONE CON ESCLUSIONE DUPLICATI
			------------------------------------------------------------------
			
			-- CONTEGGIO DUPLICATI (SE PRESENTI)
			SELECT	@DUPLICATED = COUNT(*)
			FROM	@PRE P
					LEFT JOIN
					ETL.requestDetail RD WITH(NOLOCK)
					ON P.requestId = RD.requestId
					AND P.clubId = ISNULL(RD.clubId,'0') -- SUL LATO "PRE" IL CLUBID E' GIA' SICURAMENTE DIVERSO DA NULL
					AND P.ticket = LTRIM(RTRIM(ISNULL(RD.ticket,''))) -- SUL LATO "PRE" IL TICKET E' GIA' TRIMMATO E SICURAMENTE DIVERSO DA NULL
			WHERE	RD.requestId IS NOT NULL -- DUPLICATI

			IF @COUNTONLY = 0
				BEGIN
					-- INSERIMENTO NELLA TABELLA FINALE DI DETTAGLIO RICHIESTE, SENZA DUPLICATI
					INSERT	ETL.requestDetail (requestId, ticket, ticketDirection, clubId)
					SELECT	P.requestId, P.ticket, P.ticketDirection, P.clubId
					FROM	@PRE P
							LEFT JOIN
							ETL.requestDetail RD WITH(NOLOCK)
							ON P.requestId = RD.requestId
							AND P.clubId = ISNULL(RD.clubId,'0') -- SUL LATO "PRE" IL CLUBID E' GIA' SICURAMENTE DIVERSO DA NULL
							AND P.ticket = LTRIM(RTRIM(ISNULL(RD.ticket,''))) -- SUL LATO "PRE" IL TICKET E' GIA' TRIMMATO E SICURAMENTE DIVERSO DA NULL
					WHERE	RD.requestId IS NULL -- IMPEDISCE I DUPLICATI

					SET @INSERTED = @@ROWCOUNT
				END

			SET @ReturnMessage = 
				CASE 
					WHEN @USESTUB = 1
					THEN '*** STUB IN USE *** ' 
					ELSE ''
				END +
				CASE
					WHEN @COUNTONLY = 0
					THEN 'FOUND ON CQI: ' + CAST(@FOUND AS varchar(20)) + ' RECORDS, INSERTED: ' + CAST(@INSERTED AS varchar(20)) + ' RECORDS, DUPLICATES EXCLUDED: ' + CAST(@DUPLICATED AS varchar(20)) + ' RECORDS'
					ELSE 'RECORDS WHICH WILL BE INSERTED INTO THE NEW REQUEST: ' + CAST(@FOUND AS varchar(20))
				END
			------------------------------------------------------------------
		END
	ELSE
		BEGIN
			SET @ReturnMessage = 'NO DATA TO BE PROCESSED.'	
		END
			
END TRY

BEGIN CATCH	
	SET @ReturnMessage = ERROR_MESSAGE();
END CATCH
GO
/****** Object:  StoredProcedure [ETL].[pLogCrud]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [ETL].[pLogCrud]
      @OperationType char(1)
      ,@DatabaseName varchar(50)
      ,@TableName varchar(50)
      ,@TableSkValue int
      ,@XmlInfo xml
AS

INSERT INTO [Data].[LogCrud]
           ([OperationType]
           ,[DatabaseName]
           ,[TableName]
           ,TableSkValue
           ,[XmlInfo])
     VALUES
           (@OperationType
           ,@DatabaseName
           ,@TableName
           ,@TableSkValue
           ,@XmlInfo)


GO
/****** Object:  StoredProcedure [ETL].[RequestElaborate]    Script Date: 22/12/2017 22:46:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Batch submitted through debugger: SQLQuery3.sql|7|0|C:\Users\GD2B2~1.AND\AppData\Local\Temp\~vsE26F.sql
CREATE PROCEDURE [ETL].[RequestElaborate]
@Level Int = Null
AS
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: GA
Creation Date.......: 2017-05-22
Description.........: Calcola la sessione da Out a Out

Note
- Use [Tab size] = 3 and [Indent size] 3 (Insert spaces)

------------------
-- Parameters   --
------------------	

------------------
-- Call Example --
------------------  
EXEC [ETL].[RequestElaborate]
*/
BEGIN
SET NOCOUNT ON;
-- Variabili
DECLARE   @Message VARCHAR(1000), @DataStart Datetime2(3), @FromServerTime Datetime2(3),@ToServerTime Datetime2(3),
		  @StartCalculation datetime2(3),@CalcDurationSS Int,@ClubID varchar(10),@MachineID SmallInt,@SessionID Int, @StartTicketCode Varchar(50),
		  @Msg VARCHAR(1000),@TicketCode Varchar(50),@BatchID Int,@Direction Bit,@UnivocalLocationCode Varchar(30);
		 
	
-- Costanti
DECLARE @ServerTime_FIRST datetime = '1900-01-01 00:00:00.000', @ServerTime_Last datetime = '2050-12-31 00:00:00.000', @DailyLoadingType_Delta tinyint = 1;
BEGIN TRY


--Select @DataStart = SYSDATETIME
SELECT @BatchID = [requestId],@TicketCode = [ticket],@ClubID = [clubId] ,@Direction = [ticketDirection], @UnivocalLocationCode = [univocalLocationCode]
       FROM [ETL].[requestDetail]



--,[elabStart]
--      ,[elabEnd]
--      ,[detailStatusId]
--      ,[system_date]

END TRY
-- Gestione Errore
	BEGIN CATCH	
		SET @Message = ERROR_MESSAGE();
	END CATCH
	-- fine calcoli
END
GO
/****** Object:  StoredProcedure [ETL].[SubActivity]    Script Date: 22/12/2017 22:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [ETL].[SubActivity]
@ActivityID int = NULL,
@SubActivityID int = NULL OUTPUT,
@SubActivity varchar(20),
@SubActivityTypeID smallint = NULL,
@RowsInserted int = NULL,
@Message varchar(max) = NULL,
@AddInfo XML = NULL,
@ReturnMessage varchar(1000) = NULL OUTPUT
AS
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: Jena
Creation Date.......: 2016-08-05 
Description.........: 

Revision			 


Note
- Use [Tab size] = 3 and [Indent size] = 3 (Insert space) 

------------------
-- Parameters   --
------------------	
Activity
- [Start]
- [End]
- [Error]

------------------
-- Note         --
------------------	

------------------
-- Call Example --
------------------
DECLARE @ReturnCode int, @ReturnMessage varchar(1000), @SubActivityID int
EXEC @ReturnCode = ETL.SubActivity ActivityID = -2147483648, @SubActivity = 'Start', @SubActivityTypeID  = 1, @SubActivityID = @SubActivityID OUTPUT,  @ReturnMessage =  @ReturnMessage  OUTPUT
SELECT @ReturnCode ReturnCode, @ReturnMessage ReturnMessage, @SubActivityID SubActivityID 
*/
BEGIN
SET NOCOUNT ON;
DECLARE @ReturnCode int = 0, @ActivityStateID tinyint, @IsInsert bit = IIF(@SubActivityID IS NULL, 1, 0), @IsUpdate bit = IIF(NOT @SubActivityID IS NULL, 1, 0);

SET @ActivityStateID = (CASE @SubActivity WHEN 'Start' THEN 1 WHEN 'End' THEN 2 WHEN 'Error' THEN 3 WHEN 'Warning' THEN 4 END);

--
IF @IsInsert = 1
BEGIN
   INSERT INTO Data.SubActivity (ActivityID, SubActivityTypeID, ActivityStateID) VALUES (@ActivityID, @SubActivityTypeID, @ActivityStateID)
   SET @SubActivityID = SCOPE_IDENTITY();
END;

-- 
IF @IsUpdate = 1
BEGIN
   UPDATE Data.SubActivity 
   SET ActivityStateID = @ActivityStateID,
       EndDate = SYSDATETIME(),
       RowsInserted = @RowsInserted,
       Message = @Message,
       AddInfo = @AddInfo
   WHERE SubActivityID = @SubActivityID;
END;

RETURN @ReturnCode;
END



GO
/****** Object:  StoredProcedure [RAW].[___CalcAllLevel_bak]    Script Date: 22/12/2017 22:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [RAW].[___CalcAllLevel_bak]
@ConcessionaryID tinyint,
@Direction Bit,
@TicketCode Varchar(50),
@BatchID Int,
@MaxLevel SmallInt
AS
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: GA
Creation Date.......: 2017-05-23 
Description.........: Calcola tutti i livelli delta,sessioni,ticket

Revision			 

Note
- Use [Tab size] = 3 and [Indent size] 3

------------------
-- Parameters   --
------------------	

------------------
-- Call Example --
------------------  
EXEC [RAW].[CalcAllLevel] @ConcessionaryID = 1, @Direction = 1,@TicketCode = '332122408485739486' ,@BatchID = 1,@MaxLevel = 50
*/
BEGIN
SET NOCOUNT ON;
DECLARE @ConcessionaryDB varchar(50),@DataStart Datetime2(3),@Message Varchar(1000),@ClubID Varchar(10), @Level Int,
        @CalcEnd BIT,@VltEndCredit Int
--Inizializzo
Truncate table [RAW].[Delta]
Truncate table [RAW].[Session]
Truncate table [RAW].[TicketToCalc]
TRUNCATE TABLE [RAW].[TicketMatched]
Truncate Table [TMP].[Ticket]
SET @CalcEnd = 0
SET @VltEndCredit = (SELECT [MinVltEndCredit] FROM [Config].[Table])
-- Livello
SET @Level = 0

BEGIN TRY
-- Inserisco il ticket tra quelli da calcolare 
INSERT INTO [RAW].[TicketToCalc](TicketCode,FlagCalc,Level)
Select @TicketCode,0,@Level
-- Ciclo sui ticket
WHILE EXISTS (Select  TicketCode FROM  [RAW].[TicketToCalc] WHERE  FlagCalc = 0) AND (@Level <= @MaxLevel) AND
				 (@CalcEnd = 0)
BEGIN
--SELECT @ConcessionaryDB = ConcessionaryDB, @ConcessionaryID = ConcessionaryID, @ConcessionaryName =  ConcessionaryDB FROM [Config].[Data](@ConcessionaryID);
   SET @DataStart = SYSDATETIME(); 
	-- Prendo il ticket da calcolare
	Select @TicketCode = TicketCode FROM [RAW].[TicketToCalc] WHERE FlagCalc = 0
	-- Trova il servertime corrispondente al ticket
	EXEC [RAW].[TicketOutServerTime] @TicketCode = @TicketCode,@Direction = @Direction
	-- Se è il primo livello in avanti ed è stampato da cashde
	IF (@Direction = 1) AND ((SELECT [IsPaidCashdesk] FROM [TMP].[TicketStart] WHERE TicketCode = @TicketCode) = 1)
	BEGIN
	-- Inserisco nella session il ticket pagato da cashdesk come ticket finale
	 SET @CalcEnd = 1
	 INSERT INTO [RAW].[Session](StartTicketCode,[Level])
	 Select @TicketCode,@Level
	END
	ELSE BEGIN
	-- Trova il tappo
	EXEC [RAW].[FindCountersCork] @Direction = @Direction
	-- Calcola i delta
	EXEC [RAW].[CalculateDeltaFromTicketOut]
	-- Matching dei ticket
	EXEC [RAW].[TicketMatching] @Direction = @Direction
	-- Calcola le sessioni
	EXEC [RAW].[CalcSession] @Level = @Level 
	-- Passo al livello siccessivo
	Set @Level += 1
	-- Inserisco il ticket tra quelli calcolati se l'ho matchato
	MERGE [RAW].[TicketToCalc] AS target  
	USING (SELECT @TicketCode AS TicketCode) AS source
	ON (target.TicketCode = source.TicketCode)  
	WHEN MATCHED THEN  UPDATE SET FlagCalc = 1;

------------------------------------------------------------------------------------------------
-- Salvo i ticket da calcolare per iterare
------------------------------------------------------------------------------------------------
IF @Direction = 0
BEGIN
   -- TicketIN
	MERGE [RAW].[TicketToCalc] AS target  
	USING (SELECT TicketCode FROM Tmp.Delta WHERE  TotalTicketIn <> 0 AND TicketCode IS NOT NULL) AS source
	ON (target.TicketCode = source.TicketCode) 
	WHEN NOT MATCHED THEN 
	INSERT (TicketCode, FlagCalc,Level)  
   VALUES (source.TicketCode, 0,@Level);
	
END ELSE 
BEGIN
	-- TicketOut
	IF NOT EXISTS (SELECT * FROM [TMP].[Delta] WHERE  VLTCredit <= @VltEndCredit AND  ISNULL(TotalOut,0) = 0)
	BEGIN
		MERGE [RAW].[TicketToCalc] AS target  
		USING (SELECT TicketCode FROM Tmp.Delta WHERE  TotalOut <> 0 AND TicketCode IS NOT NULL) AS source
		ON (target.TicketCode = source.TicketCode) 
		WHEN NOT MATCHED THEN 
		INSERT (TicketCode, FlagCalc,Level)  
		VALUES (source.TicketCode, 0,@Level);
	END
	ELSE SET @CalcEnd = 1
		END  
-- Fine Calcoli
	END
-- Fine Ciclo
END


END TRY
	-- Gestione Errore
		BEGIN CATCH
		Declare	@BatchType SmallInt = 6; 
			--SELECT @BatchID = [BatchID] FROM [TMP].[TicketStart]
			SET @Message = ERROR_MESSAGE();
			--PRINT(@Message);
			INSERT INTO ETL.BatchError(BatchID, BatchType, DataStart, ClubID,MachineID, Message)
			VALUES(@BatchID,@BatchType, @DataStart,  @ClubID,NULL , @Message)
		END CATCH;	
END

GO
/****** Object:  StoredProcedure [RAW].[CalcAllLevel]    Script Date: 22/12/2017 22:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RAW].[CalcAllLevel]
@ConcessionaryID tinyint,
@Direction Bit,
@TicketCode Varchar(50),
@BatchID Int,
@MaxLevel SmallInt,
@ClubID Varchar(10) = NULL,
@ReturnCode Int = NULL Output 
AS
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: GA
Creation Date.......: 2017-05-23 
Description.........: Calcola tutti i livelli delta,sessioni,ticket

Revision			 

Note
- Use [Tab size] = 3 and [Indent size] 3

------------------
-- Parameters   --
------------------	

------------------
-- Call Example --
------------------ 
DECLARE @ReturnCode int
EXEC [RAW].[CalcAllLevel] @ConcessionaryID = 7, @Direction = 1,@TicketCode = '332122408485739486' ,@BatchID = 1,@MaxLevel = 50,@ReturnCode = @ReturnCode Output
Select @ReturnCode

DECLARE @ReturnCode int
EXEC [RAW].[CalcAllLevel] @ConcessionaryID = 7, @Direction = 0,@TicketCode = '1000294MHR201502110001' ,@BatchID = 1,@MaxLevel = 50,@ReturnCode = @ReturnCode Output
Select @ReturnCode

EXEC [RAW].[CalcAllLevel] @ConcessionaryID = 1, @Direction = 0,@TicketCode = '116136268470765059' ,@BatchID = 1,@MaxLevel = 10

DECLARE @ReturnCode int
EXEC [RAW].[CalcAllLevel] @ConcessionaryID = 7, @Direction = 1,@TicketCode = 'dddds' ,@BatchID = 1,@MaxLevel = 50,@ReturnCode = @ReturnCode Output
Select @ReturnCode

*/
BEGIN
SET NOCOUNT ON;

DECLARE @ConcessionaryDB varchar(50),@DataStart Datetime2(3),@Message Varchar(1000), @Level Int,@Msg vARCHAR(1000), @ReturnCodeInternal Int, @ReturnCodeGlobal Int,
        @CalcEnd BIT,@VltEndCredit Int,@CashDesk  TinyInt = 0,@PayoutData DateTime2(3),@ProcedureName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) +'.'+QUOTENAME(OBJECT_NAME(@@PROCID));

BEGIN TRY

-- Log operazione
SET @Msg  = 'Calcolo globale iniziato'
INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
Select @ProcedureName,@Msg,@TicketCode,@BatchID

--Inizializzo
TRUNCATE table [RAW].[Delta]
TRUNCATE table [RAW].[Session]
TRUNCATE table [RAW].[TicketToCalc]
TRUNCATE TABLE [RAW].[TicketMatched]
TRUNCATE Table [TMP].[Ticket]

SET @CalcEnd = 0
IF  @ClubID = NULL 
		(Select @ClubID = ClubID From [TMP].[TicketStart])
SET @VltEndCredit = (SELECT [MinVltEndCredit] FROM [Config].[Table])
-- Livello
SET @Level = 0
SET @ReturnCode = 0;

-- Inserisco il ticket tra quelli da calcolare 
INSERT INTO [RAW].[TicketToCalc](TicketCode,FlagCalc,Level)
Select @TicketCode,0,@Level

-- Ciclo sui livelli
WHILE EXISTS (Select TicketCode FROM  [RAW].[TicketToCalc] WHERE  FlagCalc = 0 AND Level = @Level) AND (@Level <= @MaxLevel)
		AND (@CalcEnd = 0)
BEGIN
--SELECT @ConcessionaryDB = ConcessionaryDB, @ConcessionaryID = ConcessionaryID, @ConcessionaryName =  ConcessionaryDB FROM [Config].[Data](@ConcessionaryID);
   SET @DataStart = SYSDATETIME(); 
	-- Prendo il ticket da calcolare
	Select @TicketCode = TicketCode FROM [RAW].[TicketToCalc] WHERE FlagCalc = 0
	-- Trova il servertime corrispondente al ticket
	EXEC @ReturnCodeInternal =  [RAW].[TicketOutServerTime] @TicketCode = @TicketCode,@Direction = @Direction,@BatchID = @BatchID
	-- Se è in avanti ed è pagato da cashdesk non calcolo la sessione
	IF (@Direction = 1) AND ((SELECT [IsPaidCashdesk] FROM [TMP].[TicketStart] WHERE TicketCode = @TicketCode) = 1)
	BEGIN
	-- Inserisco nella session il ticket pagato da cashdesk come ticket finale
		SET @CalcEnd = 1
		SELECT @PayoutData = [PayoutData]  FROM [TMP].[TicketStart] WHERE TicketCode = @TicketCode
		INSERT INTO [RAW].[Session](MachineID,StartServerTime,StartTicketCode,[Level])
		Select @CashDesk,@PayoutData,@TicketCode,@Level
	END  
	ELSE IF
	-- Se non è né stampato né pagato da cashdesk o è MHR
	((@Direction = 0) AND ((SELECT ISNULL([IsPrintingCashDesk],0) FROM [TMP].[TicketStart] WHERE TicketCode = @TicketCode) = 0)) OR
	((@Direction = 1) AND ((SELECT [IsPaidCashdesk] FROM [TMP].[TicketStart] WHERE TicketCode = @TicketCode) = 0))
	
	-- Calcoli
	BEGIN
		-- Trova il tappo
		EXEC @ReturnCodeInternal =  [RAW].[FindCountersCork] @Direction = @Direction
		-- Calcola i delta
		EXEC @ReturnCodeInternal =  [RAW].[CalculateDeltaFromTicketOut]
		-- Matching dei ticket
		EXEC @ReturnCodeInternal =  [RAW].[TicketMatching] @Direction = @Direction
		-- Calcola le sessioni
		EXEC @ReturnCodeInternal =  [RAW].[CalcSession] @Level = @Level 
	END
		-- Inserisco il ticket tra quelli calcolati se l'ho matchato
		MERGE [RAW].[TicketToCalc] AS target  
		USING (SELECT @TicketCode AS TicketCode) AS source
		ON (target.TicketCode = source.TicketCode)  
		WHEN MATCHED THEN  UPDATE SET FlagCalc = 1;

		-- Passo al livello successivo
		IF NOT EXISTS (Select TicketCode FROM  [RAW].[TicketToCalc] WHERE  FlagCalc = 0 AND Level = @Level) 
			Set @Level += 1
		
------------------------------------------------------------------------------------------------
-- Salvo i ticket da calcolare per iterare
------------------------------------------------------------------------------------------------
		IF @Direction = 0
		BEGIN
			-- Scrivo ticket da calcolare
			IF NOT EXISTS (SELECT * FROM [TMP].[Delta] WHERE  VLTCredit <= @VltEndCredit AND  ISNULL(TotalOut,0) = 0)
			BEGIN
				-- Scrivo ticket da calcolare
				MERGE [RAW].[TicketToCalc] AS target  
				USING (SELECT TicketCode FROM Tmp.Delta WHERE  TotalTicketIn <> 0 AND TicketCode IS NOT NULL) AS source
				ON (target.TicketCode = source.TicketCode) 
				WHEN NOT MATCHED THEN 
				INSERT (TicketCode, FlagCalc,Level)  
				VALUES (source.TicketCode, 0,@Level);
			END ELSE SET @CalcEnd = 1
		END ELSE 
		BEGIN
			-- Scrivo ticket da calcolare
			IF NOT EXISTS (SELECT * FROM [TMP].[Delta] WHERE  VLTCredit <= @VltEndCredit AND  ISNULL(TotalOut,0) = 0)
			BEGIN
				MERGE [RAW].[TicketToCalc] AS target  
				USING (SELECT TicketCode FROM Tmp.Delta WHERE  TotalOut <> 0 AND TicketCode IS NOT NULL) AS source
				ON (target.TicketCode = source.TicketCode) 
				WHEN NOT MATCHED THEN 
				INSERT (TicketCode, FlagCalc,Level)  
				VALUES (source.TicketCode, 0,@Level);
			END
			-- Esci dai calcoli
			ELSE SET @CalcEnd = 1
			-- Fine Calcoli
		END  
	-- Fine Ciclo
END

-- Log operazione
SET @Msg  = 'Calcolo globale terminato'
INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
Select @ProcedureName,@Msg,@TicketCode,@BatchID

	-- Errore specifico
	IF @ReturnCodeInternal <> 0
		BEGIN
			SET @Msg = 'Internal procedure Error'
			RAISERROR (@Msg,16,1);
		END

END TRY
	-- Gestione Errore
		   BEGIN CATCH
				EXECUTE [ERR].[UspLogError]  @ErrorTicket = @TicketCode,@ErrorRequestDetailID  = @BatchID
            SET @ReturnCode = -1;
       END CATCH
      
RETURN 
--@ReturnCode Output
	-- fine calcoli
END

GO
/****** Object:  StoredProcedure [RAW].[CalcSession]    Script Date: 22/12/2017 22:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Batch submitted through debugger: SQLQuery3.sql|7|0|C:\Users\GD2B2~1.AND\AppData\Local\Temp\~vsE26F.sql
CREATE PROCEDURE [RAW].[CalcSession]
@Level Int = Null,
@ReturnCode Int = 0 Output
AS
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: GA
Creation Date.......: 2017-05-22
Description.........: Calcola la sessione da Out a Out

Note
- Use [Tab size] = 3 and [Indent size] 3 (Insert spaces)

------------------
-- Parameters   --
------------------	

------------------
-- Call Example --
------------------ 
DECLARE @ReturnCode int
EXEC @ReturnCode =  [RAW].[CalcSession]
SELECT @ReturnCode ReturnCode  

*/
BEGIN
SET NOCOUNT ON;
-- Variabili
DECLARE @Message VARCHAR(1000),@DataInizioImportazione datetime, @DataStart Datetime2(3),@Stringa varchar(100), @ServerTime_Delta datetime, @FromServerTime Datetime2(3),@ToServerTime Datetime2(3),
		  @StartCalculation datetime2(3),@CalcDurationSS Int,@ClubID varchar(10),@MachineID SmallInt,@SessionID Int, @StartTicketCode Varchar(50),@Msg VARCHAR(1000),@TicketCode Varchar(50),
		  @SessionCalc TinyInt;
DECLARE @ProcedureName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) +'.'+QUOTENAME(OBJECT_NAME(@@PROCID)),@BatchID Int;	
-- Costanti
DECLARE @ServerTime_FIRST datetime = '1900-01-01 00:00:00.000', @ServerTime_Last datetime = '2050-12-31 00:00:00.000', @DailyLoadingType_Delta tinyint = 1;
BEGIN TRY
	 -- Inizio procedura
	Select @TicketCode= TicketCode ,@BatchID = BatchID From [TMP].[TicketStart]
	-- Log operazione
	SET @Msg  = 'Calcolo sessioni iniziato'
	INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
	Select @ProcedureName,@Msg,@TicketCode,@BatchID

	Set @DataStart = SYSDATETIME() 
	SET @SessionCalc = 0 
	-----------------			                   
	-- Inizializzo
	-----------------
	SELECT @MachineID = MachineID,@ClubID  = ClubID  FROM  [TMP].[CountersCork]			
	SELECT @StartTicketCode = TicketCode FROM [TMP].[TicketStart]

	IF @MachineID is Not NULL
	BEGIN
		INSERT INTO [RAW].[Session] (MachineID,[StartServerTime] ,[EndServerTime] ,[TotalRows] ,[TotalBillIn],[TotalCoinIN]
					  ,[TotalTicketIn] ,[TotalBetValue],[TotalBetNum],[TotalWinValue] ,[TotalWinNum] ,[Tax] ,[TotalIn],[TotalOut],[FlagMinVLtCredit],StartTicketCode,[Level])
		-- Aggregazione per sessione			 
		Select	@MachineID, MIN(ServerTime) AS [StartServerTime],MAX(ServerTime) AS [EndServerTime],Count(*)  AS [TotalRows] ,ISNULL(Count([TotalBillIn]),0) AS [TotalBillIn],Count([TotalCoinIN])  AS [TotalCoinIN],Count([TotalTicketIn]) AS [TotalTicketIn],
					ISNULL(SUM(TotalBet),0) AS [TotalBetValue],Count(TotalBet)  AS [TotalBetNum],
					ISNULL(SUM([TotalWon]),0) AS [TotalWinValue],Count([TotalWon]) AS [TotalWinNum],ISNULL(SUM([Tax]),0) AS [Tax],SUM([TotalIn]) AS [TotalIn],
					SUM([TotalOut]) AS [TotalOut],Max(Cast([FlagMinVLtCredit] AS tinyint)),@StartTicketCode,@level FROM [TMP].[Delta] 
	
		SET @SessionCalc = @@RowCount 
		Select @SessionID = Max(SessionID) FROM [RAW].[Session]
	END

	IF @SessionCalc > 0
	BEGIN
	------------------------------------------------------------------------------------------------
	-- Inserisci i delta --
	------------------------------------------------------------------------------------------------
		INSERT INTO [RAW].[Delta]  (RowID ,[ServerTime],[MachineID],[GameID] ,[VLTCredit]   ,[TotalBet] ,[TotalWon]
						,[TotalBillIn],[TotalCoinIn] ,[TotalTicketIn] ,[TotalHandPay],[TotalTicketOut] ,[Tax] ,[TotalIn]
						,[TotalOut] ,[TicketCode],[FlagMinVLtCredit],[SessionID])

		SELECT RowID,[ServerTime],[MachineID],[GameID]  ,[VLTCredit] ,[TotalBet] ,[TotalWon]
				,[TotalBillIn] ,[TotalCoinIn],[TotalTicketIn],[TotalHandPay],[TotalTicketOut],[Tax]
				,[TotalIn],[TotalOut],[TicketCode],[FlagMinVLtCredit],@SessionID FROM [TMP].[Delta]
	END

	--- fine procedura
	-- Log operazione
	SET @Msg  = 'Calcolo sessioni terminato'
	INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
	Select @ProcedureName,@Msg,@TicketCode,@BatchID

	-- Errore specifico
	IF @SessionCalc <> 1
		BEGIN
			SET @Msg = 'Session has not been calculated'
			RAISERROR (@Msg,16,1);
		END

END TRY
	-- Gestione Errore
		   BEGIN CATCH
				SELECT @BatchID = [BatchID] FROM [TMP].[TicketStart]
				EXECUTE [ERR].[UspLogError]  @ErrorTicket = @TicketCode,@ErrorRequestDetailID = @BatchID
            SET @ReturnCode = -1;
       END CATCH
      
RETURN @ReturnCode
	-- fine calcoli
END
GO
/****** Object:  StoredProcedure [RAW].[CalculateDeltaFromTicketOut]    Script Date: 22/12/2017 22:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RAW].[CalculateDeltaFromTicketOut]
@ReturnCode Int = 0 Output
AS
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: GA
Creation Date.......: 2017-05-22
Description.........: Calcola i Delta in runtime da Out a Out

Note
- Use [Tab size] = 3 and [Indent size] 3 (Insert spaces)

------------------
-- Parameters   --
------------------	

------------------
-- Call Example --
------------------ 
DECLARE @ReturnCode int
EXEC @ReturnCode =  [RAW].[CalculateDeltaFromTicketOut]
SELECT @ReturnCode ReturnCode 
*/
BEGIN
SET NOCOUNT ON;
		             
BEGIN TRY  
	-- Tabelle
	DECLARE @TableMaxCounters TABLE (TotalBet bigint, TotalWon bigint, WinD bigint, TotalBillIn bigint, TotalCoinIn bigint, TotalTicketIn bigint, TotalTicketOut bigint, TotalHandPay bigint, TotalOut bigint, TotalIn bigint);

	-- Variabili
	DECLARE @Message VARCHAR(1000),@Stringa varchar(100), @ServerTime_Delta datetime, @FromServerTime Datetime2(3),@ToServerTime Datetime2(3),
		     @CalcDurationSS Int,@ClubID varchar(10),@MachineID SmallInt,@Msg VARCHAR(1000),@TicketCode Varchar(50);
	DECLARE @ProcedureName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) +'.'+QUOTENAME(OBJECT_NAME(@@PROCID)),@BatchID Int;
	-- Costanti
	DECLARE @ServerTime_FIRST datetime = '1900-01-01 00:00:00.000', @ServerTime_Last datetime = '2050-12-31 00:00:00.000', @DailyLoadingType_Delta tinyint = 1;

   -----------------			                   
	-- Inizializzo
	-----------------
	-- MachineID
	SELECT @MachineID = MachineID,@ClubID  = ClubID  FROM  [TMP].[CountersCork]			
	Select @TicketCode= TicketCode ,@BatchID = BatchID From [TMP].[TicketStart]
	-- Log operazione
	SET @Msg  = 'Calcolo delta iniziato'
	INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
	Select @ProcedureName,@Msg,@TicketCode,@BatchID
	-- pulisco
	DELETE FROM @TableMaxCounters;
	DELETE FROM [TMP].[Delta]


	-- Calcolo dall' ultimo totalout presente nel tappo 
		SELECT @FromServerTime = FromOut FROM [TMP].[CountersCork] WHERE ClubID = @ClubID AND MachineID = @MachineID
		SELECT @ToServerTime  = ToOut FROM [TMP].[CountersCork] WHERE ClubID = @ClubID AND MachineID = @MachineID				
		-------------------------------------------------------
		-- Valori dei contatori di partenza
		-------------------------------------------------------
		INSERT INTO @TableMaxCounters(TotalBet, TotalWon,  WinD, TotalBillIn , TotalCoinIn , TotalTicketIn , TotalTicketOut , TotalHandPay, TotalOut, TotalIn)
		SELECT TotalBet, TotalWon,  WinD, TotalBillIn , TotalCoinIn , TotalTicketIn , TotalTicketOut , TotalHandPay, TotalOut, TotalIn
						FROM [TMP].[CountersCork] WHERE ClubID = @ClubID AND MachineID = @MachineID
		
		-- Controllo se l'intervallo dei ricalcoli 	-- Se ho le date di confine inizio i calcoli	(Il resto dei controlli lo effettuo nella FindCork)
		IF (@ToServerTime IS NOT NULL AND @FromServerTime IS NOT NULL)
		BEGIN	
      -- Calcoli 	
		;WITH TableRawDataCTE AS (
		-- tappo iniziale
		SELECT NULL AS RowID,@FromServerTime  AS ServerTime,@FromServerTime AS MachineTime,@MachineID AS MachineID,NULL AS GameID,1 AS LoginFlag2,
				-- NULL AS OutCount
					TotalBet,TotalWon,TotalBillIn,TotalCoinIn,TotalTicketIn,TotalTicketOut,TotalHandPay,WinD,TotalOut,TotalIn FROM 
					@TableMaxCounters
		UNION ALL
		-- dati				
		SELECT RowID, ServerTime, MachineTime,@MachineID AS MachineID,GameID,
					IIF(LoginFlag = 0 OR (LoginFlag= 1 AND (ISNULL(TotalBet,0) + ISNULL(TotalWon,0) + ISNULL(TotalBillIn,0) + ISNULL(TotalCoinIn,0) +
					ISNULL(TotalTicketIn,0) + ISNULL(TotalTicketOut,0) + ISNULL(TotalHandPay,0)+ ISNULL(WinD,0) + ISNULL(TotalOut,0) + ISNULL(TotalIn,0)  > 0)),NULL,LoginFlag) AS LoginFlag2,
					--IIF(LoginFlag = 0 AND TotalOut > 0,1,NULL) AS OutCount,
					TotalBet, 
					TotalWon ,TotalBillIn , TotalCoinIn , TotalTicketIn, TotalTicketOut , TotalHandPay , WinD , TotalOut ,TotalIn
					FROM [TMP].[RawData_View]  (nolock) 
					WHERE MachineID = @MachineID AND  (ServerTime > @FromServerTime AND ServerTime <= @ToServerTime)	
						),
		--Select * FROM TableRawDataCTE
		TabellaDelta01 AS (
		SELECT RowID,ServerTime, MachineTime, MachineID, GameID,LoginFlag2, 
				COUNT(LoginFlag2) OVER (ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS C1,
				--OutCount,
				--IIF((OutCount IS NULL), (COUNT(OutCount) OVER (ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) ,
				--(COUNT(OutCount) OVER (ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) -1) AS C2,
				TotalBet , TotalWon ,TotalBillIn , TotalCoinIn , TotalTicketIn, TotalTicketOut , TotalHandPay , WinD , TotalOut ,TotalIn
		FROM TableRawDataCTE										   
							),
--Select * FROM TabellaDelta01
		TabellaDelta02 AS (
		SELECT RowID, ServerTime, MachineTime, MachineID, GameID,LoginFlag2, C1,
		--C2,
				TotalBet = TotalBet - ISNULL(MAX(TotalBet)  OVER (PARTITION BY C1 ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0),
				TotalWon = TotalWon - ISNULL(MAX(TotalWon)  OVER (PARTITION BY C1 ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0),
				WinD = WinD - ISNULL(MAX(WinD)  OVER (PARTITION BY C1 ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0),
				TotalBillIn = TotalBillIn - ISNULL(MAX(TotalBillIn)  OVER (PARTITION BY C1 ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0),
				TotalCoinIn = TotalCoinIn - ISNULL(MAX(TotalCoinIn)  OVER (PARTITION BY C1 ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0),
				TotalTicketIn = TotalTicketIn - ISNULL(MAX(TotalTicketIn)  OVER (PARTITION BY C1 ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0),
				TotalTicketOut = TotalTicketOut - ISNULL(MAX(TotalTicketOut)  OVER (PARTITION BY C1 ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0),
				TotalHandPay = TotalHandPay - ISNULL(MAX(TotalHandPay)  OVER (PARTITION BY C1 ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0),
				TotalOut = TotalOut - ISNULL(MAX(TotalOut)  OVER (PARTITION BY C1 ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0),
				TotalIn = TotalIn - ISNULL(MAX(TotalIn)  OVER (PARTITION BY C1 ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0) 
			FROM TabellaDelta01
			)
--Select * FROM TabellaDelta02 where LoginFlag2 IS NULL
			,TabellaDelta03 as (
			SELECT  RowID, ServerTime, MachineTime, MachineID, GameID, LoginFlag2,
			--C2,
					TotalBet, TotalWon, WinD, TotalBillIn, TotalCoinIn, TotalTicketIn, TotalTicketOut,TotalHandPay, TotalOut,TotalIn,
					CASE WHEN (ISNULL(TotalOut,0) > 0 ) AND (ISNULL(TotalBet,0) + ISNULL(TotalWon,0) + ISNULL(TotalBillIn,0) + ISNULL(TotalCoinIn,0) + 
						ISNULL(TotalTicketIn,0)  + ISNULL(WinD,0) +  ISNULL(TotalIn,0)  > 0) THEN  0 
						ELSE cast((IsNull(TotalIn, 0) + IsNULL(TotalWon,0))  as bigint) - cast((IsNULL(TotalBet,0) + IsNULL(TotalOut,0) + IsNULL(WinD,0)) as bigint) 
					END AS VltCredit								
			FROM TabellaDelta02 t1 WHERE (LoginFlag2 IS NULL) AND NOT (TotalBet = 0 AND TotalOut = 0 AND totalIN = 0)
								) 	
--Select * FROM  TabellaDelta03
			,TabellaDelta04 as (
			SELECT RowID,ServerTime, MachineTime, MachineID, GameID,0 AS LoginFlag,
				CASE WHEN (TotalOut IS NOT NULL)
						AND (ISNULL(TotalBet,0) + ISNULL(TotalWon,0) + ISNULL(TotalBillIn,0) + ISNULL(TotalCoinIn,0) +ISNULL(TotalTicketIn,0) + ISNULL(WinD,0) +  ISNULL(TotalIn,0)  = 0)  THEN  0 
						ELSE 
						SUM(VLTCredit) OVER (PARTITION BY MachineID ORDER BY ServerTime ROWS UNBOUNDED PRECEDING) END AS SumVltCredit,
						TotalBet,TotalWon,TotalBillIn,TotalCoinIn,TotalTicketIn,TotalTicketOut,TotalHandPay,WinD AS Tax,TotalIn,TotalOut 
			FROM TabellaDelta03 )
			-- Tabella finale  
			INSERT INTO  [TMP].Delta (RowID,ServerTime, MachineTime, MachineID, GameID,LoginFlag,VLTCredit,TotalBet,TotalWon,TotalBillIn,TotalCoinIn,
											TotalTicketIn,TotalTicketOut, TotalHandPay,Tax,TotalIn,TotalOut,[FlagMinVLtCredit])

			SELECT RowID,ServerTime, MachineTime, MachineID, GameID,LoginFlag,SumVltCredit,TotalBet,TotalWon,TotalBillIn,TotalCoinIn,
				TotalTicketIn,TotalTicketOut, TotalHandPay,Tax,TotalIn,TotalOut,IIF(SumVltCredit <= (SELECT [MinVltEndCredit] FROM [Config].[Table]) AND (ISNULL(TotalOut,0) = 0),1,0) -- sono campi calcolati
			FROM TabellaDelta04

			-- Log operazione
			SET @Msg  = 'Calcolo delta terminato'
			INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
			Select @ProcedureName,@Msg,@TicketCode,@BatchID
		 END ELSE 
		 -- Errore specifico
		 BEGIN
		 	SET @Msg = '@FromServerTime OR @ToServerTime is Null'
			RAISERROR (@Msg,16,1);
		 END	
		-- Errore specifico
	   IF NOT EXISTS (Select TOP 1 * FROM [TMP].[Delta])
		BEGIN
			SET @Msg = 'Empty table [TMP].[Delta]'
			RAISERROR (@Msg,16,1);
		END

END TRY
	-- Gestione Errore
		   BEGIN CATCH
				EXECUTE [ERR].[UspLogError]  @ErrorTicket = @TicketCode,@ErrorRequestDetailID  = @BatchID
            SET @ReturnCode = -1;
       END CATCH
      
RETURN @ReturnCode

END
	
GO
/****** Object:  StoredProcedure [RAW].[CreateNewViewRawID]    Script Date: 22/12/2017 22:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RAW].[CreateNewViewRawID]
@ClubID varchar(10) = NULL
AS
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: Jena
Creation Date.......: 2015-11-24 
Description.........: Crea schema, RawID e vista per un nuovo ClubID

Revision			 

Note
- Use [Tab size] = 2 and [Indent size]

------------------
-- Parameters   --
------------------	

------------------
-- Call Example --
------------------  
EXEC [RAW].[CreateNewViewRawID] @ClubID =  1000171
EXEC [RAW].[CreateNewViewRawID] @ClubID =  1000432

*/
BEGIN
DECLARE @VerifyStr NVARCHAR(MAX), @CreateViewStr NVARCHAR(MAX), @Position sysname,  @RawDataDB sysname,@RawDataDB_01 sysname,@ConcessionaryName sysname,
		@FlagDbArchive Bit
-- inizializzo
SELECT @Position = Position,@ConcessionaryName = ConcessionaryName  FROM Config.[Table]

SET @RawDataDB = @ConcessionaryName + '_AGS_RawData'
SET @RawDataDB_01 = @ConcessionaryName + '_AGS_RawData_01'


-- Elimino vista
-- Verifico se c'è Raw_Data_01
SET @VerifyStr = '
Declare @Db01 Bit = NULL
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N''[Tmp].RawData_View'') ) DROP VIEW [Tmp].RawData_View
IF EXISTS(SELECT * FROM [' + @Position + '].[' + @RawDataDB_01 +'].sys.tables TBL
			  INNER JOIN [' + @Position + '].[' + @RawDataDB_01 +'].sys.partitions PART ON TBL.object_id = PART.object_id
			  INNER JOIN [' + @Position + '].[' + @RawDataDB_01 +'].sys.indexes IDX ON PART.object_id = IDX.object_id
			  INNER JOIN [' + @Position + '].[' + @RawDataDB_01 +'].sys.schemas SCH ON TBL.schema_id = SCH.schema_id
			  WHERE TBL.name = ''RawData'' and SCH.Name = ''' + @ClubID + ''')			  
				   Select @Db01 = 1
			  Else Select @Db01 = 0
			  Update [Config].[Table] SET FlagDbArchive = @Db01'

EXEC sp_executesql @VerifyStr

Select @FlagDbArchive = FlagDbArchive From Config.[Table]
 
------------------------------------------------------------------------------------------------------------
-- Creazione Vista                                                                                                 --
------------------------------------------------------------------------------------------------------------
IF @FlagDbArchive = 1

	SET @CreateViewStr = '--Se ho anche o solo RawData_01
			  CREATE view [TMP].[RawData_View]
				AS
				SELECT RowID, ServerTime, MachineTime, MachineID, GameID, LoginFlag, TotalBet, Win, GamesPlayed, GamesWon, TotalHandpay, TotalHPCC, TotalJPCC, TotalRemote, TotalWon, TotalDrop, TotalIn, TotalOut, TotalBillIn, TotalBillChange, TotalCoinIn, TotalCoinInDrop, TotalCoinInHopper, TotalHopperOut, TotalHopperFill, TotalTicketIn, TotalTicketOut, TotalBillInNumber, BillIn1, BillIn2, BillIn3, BillIn4, BillIn5, BillIn6, BillIn7, BillIn8, TotalBillChangeNumber, BillChange1, BillChange2, BillChange3, BillChange4, BillChange5, BillChange6, BillChange7, TotalCoinInNumber, CoinIn3, CoinIn4, CoinIn5, CoinIn6, CoinIn7, CoinIn8, TotalCoinInDropNumber, CoinInDrop3, CoinInDrop4, CoinInDrop5, CoinInDrop6, CoinInDrop7, CoinInDrop8, TotalCoinInHopperNumber, CoinInHopper3, CoinInHopper4, TicketInA, TicketInB, TicketInC, TicketOutA, TicketOutB, TicketOutC, CurrentCreditA, CurrentCreditB, CurrentCreditC, TotalBetA, TotalBetB, TotalBetC, WinA, WinB, WinC, WinD, TotalHPCCA
					   FROM [' + @Position + '].[' + @RawDataDB_01 +'].[' + @ClubID + '].[RawData]
					   WHERE ServerTime >= ''20120101'' AND ServerTime < ''20151117''
				UNION ALL
				SELECT (RowID + 2147483649), ServerTime, MachineTime, MachineID, GameID, LoginFlag, TotalBet, Win, GamesPlayed, GamesWon, TotalHandpay, TotalHPCC, TotalJPCC, TotalRemote, TotalWon, TotalDrop, TotalIn, TotalOut, TotalBillIn, TotalBillChange, TotalCoinIn, TotalCoinInDrop, TotalCoinInHopper, TotalHopperOut, TotalHopperFill, TotalTicketIn, TotalTicketOut, TotalBillInNumber, BillIn1, BillIn2, BillIn3, BillIn4, BillIn5, BillIn6, BillIn7, BillIn8, TotalBillChangeNumber, BillChange1, BillChange2, BillChange3, BillChange4, BillChange5, BillChange6, BillChange7, TotalCoinInNumber, CoinIn3, CoinIn4, CoinIn5, CoinIn6, CoinIn7, CoinIn8, TotalCoinInDropNumber, CoinInDrop3, CoinInDrop4, CoinInDrop5, CoinInDrop6, CoinInDrop7, CoinInDrop8, TotalCoinInHopperNumber, CoinInHopper3, CoinInHopper4, TicketInA, TicketInB, TicketInC, TicketOutA, TicketOutB, TicketOutC, CurrentCreditA, CurrentCreditB, CurrentCreditC, TotalBetA, TotalBetB, TotalBetC, WinA, WinB, WinC, WinD, TotalHPCCA
						FROM [' + @Position + '].[' + @RawDataDB +'].[' + @ClubID + '].[RawData]
						WHERE ServerTime >= ''20151117''
						'
ELSE			  
	SET @CreateViewStr = '			
			 -- Se ho solo RawData
			  CREATE view [TMP].[RawData_View]
					  AS
					  SELECT RowID, ServerTime, MachineTime, MachineID, GameID, LoginFlag, TotalBet, Win, GamesPlayed, GamesWon, TotalHandpay, TotalHPCC, TotalJPCC, TotalRemote, TotalWon, TotalDrop, TotalIn, TotalOut, TotalBillIn, TotalBillChange, TotalCoinIn, TotalCoinInDrop, TotalCoinInHopper, TotalHopperOut, TotalHopperFill, TotalTicketIn, TotalTicketOut, TotalBillInNumber, BillIn1, BillIn2, BillIn3, BillIn4, BillIn5, BillIn6, BillIn7, BillIn8, TotalBillChangeNumber, BillChange1, BillChange2, BillChange3, BillChange4, BillChange5, BillChange6, BillChange7, TotalCoinInNumber, CoinIn3, CoinIn4, CoinIn5, CoinIn6, CoinIn7, CoinIn8, TotalCoinInDropNumber, CoinInDrop3, CoinInDrop4, CoinInDrop5, CoinInDrop6, CoinInDrop7, CoinInDrop8, TotalCoinInHopperNumber, CoinInHopper3, CoinInHopper4, TicketInA, TicketInB, TicketInC, TicketOutA, TicketOutB, TicketOutC, CurrentCreditA, CurrentCreditB, CurrentCreditC, TotalBetA, TotalBetB, TotalBetC, WinA, WinB, WinC, WinD, TotalHPCCA
					  FROM [' + @Position + '].[' + @RawDataDB +'].[' + @ClubID + '].[RawData]
					'
EXEC sp_executesql @CreateViewStr

END


GO
/****** Object:  StoredProcedure [RAW].[FindCountersCork]    Script Date: 22/12/2017 22:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RAW].[FindCountersCork]
@Direction BIT,
@ReturnCode Int = 0 Output
AS
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: GA
Creation Date.......: 2017-01-30
Description.........: Calcola i valori di tutti i contatori non nulli precedenti all'ultimo calcolo dei delta effettuato

Revision			 
GA 2017-01-30..: Aggiunto creazione tappo caso senza riavvi, controlli (VltDismesse, Aggiornamento contatori,IsReadyForCork)
Note
- Use [Tab size] = 2 and [Indent size]

------------------
-- Parameters   --
------------------	

------------------
-- Call Example --
------------------
DECLARE @ReturnCode int
EXEC @ReturnCode =   [RAW].[FindCountersCork] @Direction = 1
SELECT @ReturnCode ReturnCode 
*/
BEGIN
SET NOCOUNT ON;

BEGIN TRY
	DECLARE @TableMaxCounters TABLE (TotalBet bigint, TotalWon bigint, WinD bigint, TotalBillIn bigint, TotalCoinIn bigint, TotalTicketIn bigint, TotalTicketOut bigint, TotalHandPay bigint, TotalOut bigint, TotalIn bigint);
	DECLARE @TableNumbered TABLE(Col Varchar(50),Value Bigint, ServerTime Datetime2(3) , Rn int)
	-- Variabili
	DECLARE @Message VARCHAR(1000);
	DECLARE @ServerTimeMaxCounters datetime2(3),@Stringa Varchar(500), @FromServerTime Datetime2(3),@ToServerTime Datetime2(3),
	@RestartTime Datetime2(3),@CalcDurationSS Int,@CtnNumbered Int
	DECLARE @UpdateCalc bit,@GD Varchar(30),@Msg VARCHAR(1000),@TicketCode Varchar(50),@BatchID Int;
	DECLARE @FromOut DateTime2(3) = NULL,@ToOut DateTime2(3) = NULL, @OFFSETOUT SmallInt = 3600,@ClubID varchar(10), @MachineID SmallInt;
	-- Costanti
	DECLARE @ServerTime_FIRST datetime = '1900-01-01 00:00:00.000', @ServerTime_Last datetime = '2050-12-31 00:00:00.000';	
	DECLARE @ProcedureName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + '.'+QUOTENAME(OBJECT_NAME(@@PROCID));

	------------------------------------------------------
	-- Calcolo VLT       --
	------------------------------------------------------
	-- Inizializzo
	TRUNCATE TABLE [TMP].[CountersCork]
	-- Log operazione			
	Select @TicketCode= TicketCode ,@BatchID = BatchID From [TMP].[TicketStart]
	SET @Msg  = 'Calcolo  tappo Ticket Code iniziato'
	INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
	Select @ProcedureName,@Msg,@TicketCode,@BatchID

	-- Tracking indietro 
	IF @Direction = 0
	BEGIN
	-- date di inizio e fine
		SELECT @MachineID = ISNULL(PrintingMachineID,MhMachineID),@ClubID  = ClubID  FROM [TMP].[TicketStart]
		SELECT @ToOut =  ISNULL((Select ServerTime FROM [TMP].[TicketServerTime]),@ServerTime_FIRST)
		SET @FromOut = ISNULL((Select MAX(Servertime) FROM  [TMP].RawData_View where TotalOut > 0 AND MachineID = @MachineID AND LoginFlag = 0 AND ServerTime < @ToOut),@ServerTime_FIRST)
	END ELSE IF @Direction = 1
	-- Tracking in avanti -- va preso il serverTime di IN di questo ticket
	BEGIN
	-- date di inizio e fine
		SELECT @MachineID = PayOutMachineID,@ClubID  = ClubID  FROM [TMP].[TicketStart]
		SELECT @FromOut = ISNULL((Select ServerTime FROM [TMP].[TicketServerTime]),@ServerTime_Last)
		SET @ToOut= ISNULL((Select MIN(Servertime) FROM  [TMP].RawData_View where TotalOut > 0 AND MachineID = @MachineID AND LoginFlag = 0 AND ServerTime > @FromOut),@ServerTime_Last)
	END
-- Controllo se posso effettuare il calcolo
 IF  (@FromOut <> @ServerTime_Last ) AND (@ToOut <> @ServerTime_FIRST)
	--Calcoli
	BEGIN
	-- Ultimo riavvio prima dei calcoli
		SET @RestartTime = 
						ISNULL((SELECT max(serverTime) AS serverTime FROM  [TMP].[RawData_View] t1 (nolock)						
								WHERE MachineID  = @MachineID AND ServerTime <= @FromOut
								AND LoginFlag = 1 
								AND TotalBet IS NOT NULL AND TotalWon IS NOT NULL AND WinD IS NOT NULL AND TotalBillIn IS NOT NULL 
								AND TotalCoinIn IS NOT NULL AND TotalTicketIn IS NOT NULL AND TotalTicketOut IS NOT NULL AND TotalHandPay IS NOT NULL 
								AND TotalOut IS NOT NULL AND TotalIn IS NOT NULL
							),@ServerTime_First)
	--Select @MachineID,@LastRawDataOut,@LastDeltaTotalOut,@RestartTime,'Incremental'
	--select @RestartTime
	IF @RestartTime  <> @ServerTime_FIRST 
	BEGIN											
		-- Creazione tappo 
			;With NumberedNext AS (
			SELECT Col,Value,ROW_NUMBER() OVER (PARTITION BY Col ORDER BY ServerTime desc) rn
						FROM [TMP].RawData_View (nolock)
						unpivot (Value for Col in (TotalBet,TotalWon,WinD,TotalBillIn,TotalCoinIn,TotalTicketIn,TotalTicketOut,TotalHandPay,TotalOut,TotalIn)) p							
						WHERE ServerTime Between @RestartTime AND @FromOut AND MachineID = @MachineID
											)
			-- popolo tabella [TMP].[CountersCork] per i calcoli successivi										 						
			INSERT INTO @TableMaxCounters(TotalBet, TotalWon,  WinD, TotalBillIn , TotalCoinIn , TotalTicketIn , TotalTicketOut , TotalHandPay, TotalOut, TotalIn)
 			SELECT
				  max(case when Col = 'TotalBet' then Value end) TotalBet,
				  max(case when Col = 'TotalWon' then Value end) TotalWon,
				  max(case when Col = 'WinD' then Value end) WinD,
				  max(case when Col = 'TotalBillIn' then Value end) TotalBillIn,
				  max(case when Col = 'TotalCoinIn' then Value end) TotalCoinIn,
				  max(case when Col = 'TotalTicketIn' then Value end) TotalTicketIn,
				  max(case when Col = 'TotalTicketOut' then Value end) TotalTicketOut,
				  max(case when Col = 'TotalHandPay' then Value end) TotalHandPay,
				  max(case when Col = 'TotalOut' then Value end) TotalOut,
				  max(case when Col = 'TotalIn' then Value end) TotalIn
			FROM NumberedNext where  rn = 1 
			--Fine creazione tappo 
		END
	END
	--Aggiorno i contatori
			INSERT [TMP].[CountersCork]  (ClubID, MachineID, FromOut,ToOut,TotalBet, TotalWon, WinD, TotalBillIn, TotalCoinIn, TotalTicketIn, TotalTicketOut, TotalHandPay, TotalOut, TotalIn)
			SELECT @ClubID, @MachineID,@FromOut,@ToOut, TMCN.TotalBet, TMCN.TotalWon,  TMCN.WinD, TMCN.TotalBillIn , TMCN.TotalCoinIn , TMCN.TotalTicketIn , TMCN.TotalTicketOut , TMCN.TotalHandPay, TMCN.TotalOut, TMCN.TotalIn
					 FROM @TableMaxCounters AS  TMCN					
	-- Verifiche finali
	SET @Msg  = 'Calcolo tappo terminato'
	INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
	Select @ProcedureName,@Msg,@TicketCode,@BatchID
	-- Errore specifico
	IF NOT EXISTS (Select * From [TMP].[CountersCork])
		BEGIN
		SET @Msg = 'Empty table [TMP].[CountersCork]'
		RAISERROR (@Msg,16,1);
	END

	END TRY
		-- Gestione Errore
				BEGIN CATCH
					EXECUTE [ERR].[UspLogError]  @ErrorTicket = @TicketCode,@ErrorRequestDetailID  = @BatchID
					SET @ReturnCode = -1;
			 END CATCH
      
	RETURN @ReturnCode

END
GO
/****** Object:  StoredProcedure [RAW].[TicketMatching]    Script Date: 22/12/2017 22:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RAW].[TicketMatching]
@Direction Bit,
@ReturnCode Int = 0 Output
AS
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: GA
Creation Date.......: 2016-02-24 
Description.........: Calcola i Delta

Note
- Use [Tab size] = 3 and [Indent size] 3 (Insert spaces)

------------------
-- Parameters   --
------------------	

------------------
-- Call Example --
------------------  

DECLARE @ReturnCode int
EXEC @ReturnCode = [RAW].[TicketMatching] @Direction = 0

DECLARE @ReturnCode int, @ReturnMessage varchar(1000) 
EXEC @ReturnCode = [pom-mon01].[Staging].[Ticket].[Extract_Pomezia]  @ConcessionaryNumber = 1, @ClubID = 1000432, @Fromdate = '20150211', @ReturnMessage = @ReturnMessage OUTPUT
SELECT @ReturnCode ReturnCode, @ReturnMessage ReturnMessage 

DECLARE @ReturnCode int, @ReturnMessage varchar(1000) 
EXEC @ReturnCode =  [pom-mon01].[Staging].[Ticket].[Extract_Pomezia]  @ConcessionaryNumber = 1,  @TicketCode = '525764475876923475', @ReturnMessage = @ReturnMessage OUTPUT
SELECT @ReturnCode ReturnCode, @ReturnMessage ReturnMessage 
*/
BEGIN
SET NOCOUNT ON;

-- Variabili
DECLARE @Message VARCHAR(1000),@DataInizioImportazione datetime		  
-- Costanti
DECLARE @ServerTime_FIRST datetime = '1900-01-01 00:00:00.000', @ServerTime_Last datetime = '2050-12-31 00:00:00.000', @DailyLoadingType_Delta tinyint = 1,
		  @OffSetOut Int, @OffSetIn Int,  @OffSetMH Int,  @FromServerTime DateTime2(3), @ToServerTime DateTime2(3),
		  @GD Varchar(30) = 'GD016013368',@OffSetImport int = 48,@DataStart Datetime2(3),@PayOutMinData Datetime2(3),
		  @PayOutMaxData Datetime2(3),@PrintingMinData Datetime2(3),@PrintingMaxData Datetime2(3),@TicketDataFrom  Datetime2(3),
		  @TicketDataTo  Datetime2(3),@OutCount Int,@InCount Int,@MhCount Int,@IterationNum TinyInt,@ClubID varchar(10),@MachineID varchar(5),
		  @HourRange Smallint,@TckMaxData Datetime2(3),@TckMinData  Datetime2(3), @TicketDownload BIT, @DDRange SmallInt,@MatchedCount Int,@Msg VARCHAR(1000),@TicketCode Varchar(50),@OutMatched BIT,@InMatched Bit;
DECLARE @ReturnCode2 int, @ReturnMessage varchar(1000),@MatchedCountTotOut Int,@MatchedCountTotIn Int; 
DECLARE @ProcedureName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) +'.'+QUOTENAME(OBJECT_NAME(@@PROCID)),@BatchID Int;
DECLARE @TableDateRange TABLE(MAX_MIN_TicketData datetime2(3));	

BEGIN TRY
-- Log operazione
Select @TicketCode= TicketCode ,@BatchID = BatchID From [TMP].[TicketStart]
SET @Msg  = 'Matching ticket iniziato'
INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
Select @ProcedureName,@Msg,@TicketCode,@BatchID

--Inizializzo
Set @DataStart = SYSDATETIME()  
SET @IterationNum = 1
SET @TicketDownload = 0
SET @HourRange = 36
SET @OutCount = 0
SET @InCount = 0
SET @DDRange = 2
SET @MatchedCount = 0

Truncate Table [TMP].[DeltaTicketIn]
Truncate Table [TMP].[DeltaTicketOut]
Truncate Table [TMP].[TicketMatched]

Select @OffSetOut = OffSetOut,@OffSetIn = OffSetIn,@OffSetMH = OffSetMH FROM Config.[Table]

-- Intervallo di calcolo
Select @FromServerTime = FromOut,@ToServerTime = ToOut,@ClubID = ClubID FROM [TMP].CountersCork 

-- Caricamento ticket
IF NOT EXISTS (Select Top 1 * FROM  [TMP].[Ticket])
	BEGIN
	-- Primo inserimento ticket indietro
	IF @Direction = 0 
	BEGIN
		 SET @TicketDataTO = Dateadd(DD,1,@ToServerTime) 
		 SET @TicketDataFrom = Dateadd(DD,-@DDRange,@FromServerTime)
	END
	-- Primo inserimento ticket in avanti
	IF @Direction = 1
	BEGIN
		 SET @TicketDataTO = Dateadd(DD,@DDRange,@ToServerTime) 
		 SET @TicketDataFrom = Dateadd(DD,-1,@FromServerTime)
	END
	-- scarico i ticket
	--Select @TicketDataFrom,@TicketDataTO
	EXEC @ReturnCode2 = [pom-mon01].[Staging].[Ticket].[Extract_Pomezia]  @ConcessionaryNumber = 1, @ClubID = @ClubID, @Fromdate = @TicketDataFrom,@ToDate = @TicketDataTO,@IsMhx = 1,  @ReturnMessage = @ReturnMessage OUTPUT
END

ELSE
-- Caricamenti successivi
BEGIN
	-- PayOut
	Select @PayOutMinData = MIN([PayOutData]) FROM [TMP].[Ticket]
	Select @PayOutMaxData = MAX([PayOutData]) FROM [TMP].[Ticket]
	-- Printing
	Select @PrintingMinData = MIN([PrintingData]) FROM [TMP].[Ticket]
	Select @PrintingMaxData = MAX([PrintingData]) FROM [TMP].[Ticket]

	-- Indietro
	IF @Direction = 0
	BEGIN
		---- controllo e scarico se necessario
		IF Dateadd(SS,-@OffSetOut * 30,@FromServerTime)  < @PayOutMinData
		BEGIN
		-- Se vado indietro prendo i ticket indietro
			 SET @TicketDataTO = @PayOutMinData
			 SET @TicketDataFrom = Dateadd(DD,-@DDRange,@PayOutMinData) 
			 Set @TicketDownload = 1
		END
	END
	--avanti
	IF @Direction = 1
	BEGIN
		IF Dateadd(SS,@OffSetOut * 30,@ToServerTime)  > @PrintingMaxData
		-- Se vado avanti prendo i ticket in avanti
		BEGIN
			 SET @TicketDataFrom = @PrintingMaxData
			 SET @TicketDataTo= Dateadd(DD,+@DDRange,@PrintingMaxData) 
			 Set @TicketDownload = 1
		END
	END
	--Scarico i ticket
	IF  @TicketDownload = 1
	BEGIN
		EXEC @ReturnCode2 = [pom-mon01].[Staging].[Ticket].[Extract_Pomezia]  @ConcessionaryNumber = 1, @ClubID = @ClubID, @Fromdate = @TicketDataFrom,@ToDate = @TicketDataTO,  @ReturnMessage = @ReturnMessage OUTPUT
	END
END

------------------------------
-- Matching TicketOut --
--------------------------------
--Totalout da Matchare

INSERT INTO [TMP].[DeltaTicketOut](RowID,TotalOut,Servertime,MachineID)
SELECT RowID,TotalOut,Servertime,MachineID FROM Tmp.Delta WHERE  TotalOut <> 0 AND TicketCode IS NULL
SET @OutCount = @@ROWCOUNT
-- Massimo un TotalOut
SET @MatchedCountTotOut = 0
-- iterazioni
WHILE  (@IterationNum <= 3) AND (@MatchedCountTotOut < @OutCount)
BEGIN
-- iterazioni successive
	IF @IterationNum = 2 
		BEGIN
			SELECT @OFFSETOUT = @OFFSETOUT * 6
			SELECT @OffSetMH = @OffSetMH * 12
		END
		ELSE IF @IterationNum = 3
		BEGIN
			SELECT @OFFSETOUT = @OFFSETOUT * 60
			SELECT @OffSetMH = @OffSetMH * 30
		END

-- Matching ticket OUT
;WITH CTE_TCK_OUT AS (
	SELECT   TicketCode,ServerTime,MachineID,TicketValue, RANK() OVER  (PARTITION BY TicketValue ORDER BY 
				ABS(datediff(second,ServerTime,PrintingData)) asc) AS RowRank,T1.RowID  AS RowID FROM
							(
			SELECT RowID,TotalOut,Servertime,MachineID FROM [TMP].[DeltaTicketOut]) T1 
					 INNER JOIN TMP.Ticket T2 ON PrintingData Between dateadd(second,-@OffSetOut,ServerTime) 
					 AND dateadd(second,@OffSetOut,ServerTime) AND T1.TotalOut = T2.TicketValue 
					 AND PrintingMachineID = MachineID 
					 -- Escludo quelli già linkati
					 AND TicketCode NOT IN (Select TicketCode FROM [RAW].[TicketMatched] WHERE Out = 1)
							)
	-- inserisco ticket matchati
	INSERT INTO [TMP].[TicketMatched](TicketCode,RowID)
	SELECT   TicketCode,RowID FROM CTE_TCK_OUT WHERE RowRank = 1
	SET @MatchedCount = @@ROWCOUNT
	SET @MatchedCountTotOut += @MatchedCount
	----------------------------------------------------------------
	-- Aggiorna tabella delta --
	----------------------------------------------------------------
	IF @MatchedCount > 0
	BEGIN
		 MERGE [TMP].[Delta] AS target  
			 USING (SELECT TicketCode, RowID FROM [TMP].[TicketMatched]) AS source
			 ON (target.RowID = source.RowID)  
			 WHEN MATCHED THEN  UPDATE SET TicketCode = source.TicketCode
			 OUTPUT inserted.TicketCode,1
			-- salvo i ticket Matchati
			INTO [RAW].[TicketMatched](TicketCode,Out);	
	END
	-- Provo con i pagamenti remoti
	ELSE
	BEGIN
		----------------------------------------------------------------
		-- Matching MH --
		----------------------------------------------------------------
		;WITH CTE_TCK_MH AS (
			SELECT   TicketCode,ServerTime,MachineID,TicketValue, RANK() OVER  (PARTITION BY TicketValue ORDER BY 
						ABS(datediff(second,ServerTime,PrintingData)) asc) AS RowRank,T1.RowID  AS RowID FROM
							 (
					-- scarto i matchati
					SELECT RowID,TotalOut,Servertime,MachineID FROM [TMP].[DeltaTicketOut] 
					) T1 
							 INNER JOIN  TMP.Ticket T2 ON EventDate Between dateadd(second,-@OffSetMH,ServerTime) 
							 AND dateadd(second,@OffSetMH,ServerTime) AND T1.TotalOut = T2.TicketValue 
							 AND MhMachineID = MachineID  AND TicketCode NOT IN (Select TicketCode FROM [RAW].[TicketMatched]
							 WHERE Out = 1)
									)
			-- inserisco ticket matchati
			INSERT INTO [TMP].[TicketMatched](TicketCode,RowID)
			SELECT   TicketCode,RowID FROM CTE_TCK_MH WHERE RowRank = 1
		   SET @MatchedCount = @@ROWCOUNT
			SET @MatchedCountTotOut += @MatchedCount
			----------------------------------------------------------------
			-- Aggiorna tabella delta --
			----------------------------------------------------------------		
			IF @MatchedCount > 0
				BEGIN
					 MERGE [TMP].[Delta] AS target  
						 USING (SELECT TicketCode, RowID FROM [TMP].[TicketMatched]) AS source
						 ON (target.RowID = source.RowID)  
						 WHEN MATCHED THEN  UPDATE SET TicketCode = source.TicketCode
						 OUTPUT inserted.TicketCode,1
						 -- Tabella finale
						 INTO [RAW].[TicketMatched](TicketCode,Out);
				END
			END
----------------------------------------------------------------
----iterazione successiva
----------------------------------------------------------------
	SET @IterationNum += 1
END
--------------------------------
-- Matching TicketIN --
--------------------------------		
SET @IterationNum = 1
SET @MatchedCountTotIn = 0

--TicketIn Da Matchare
INSERT INTO [TMP].[DeltaTicketIN](RowID,TotalTicketIn,Servertime,MachineID)
SELECT RowID,TotalTicketIn,Servertime,MachineID FROM Tmp.Delta WHERE  TotalTicketIN <> 0 AND TicketCode IS NULL
SET @INCount = @@ROWCOUNT

-- Ciclo Iterazioni
WHILE  (@IterationNum <= 3) AND (@MatchedCountTotIn < @InCount)
BEGIN
	-- inizializzo
    Truncate Table [TMP].[TicketMatched]
	SET @MatchedCount = 0
	--iterazioni successive
	IF @IterationNum = 2 
		SELECT @OffSetIn = @OffSetIn * 5
	IF @IterationNum = 3
		SELECT @OffSetIn = @OffSetIn * 50

-- Matching ticket
;WITH CTE_TCK_IN AS (

	SELECT TicketCode,RoWID FROM  [TMP].[DeltaTicketIN] DT

			CROSS APPLY (Select TOP 1 * FROM TMP.Ticket T1 where  PayOutData Between dateadd(second,-@OffSetIn,ServerTime) 
						AND dateadd(second,@OffSetIn,ServerTime) AND DT.TotalTicketIn = T1.TicketValue 
						AND PayoutMachineID = MachineID  
						AND TicketCode NOT IN 
						(Select TicketCode FROM [RAW].[TicketMatched] WHERE Out = 0)
					) TI
		
	)
	-- inserisco ticket matchati
	INSERT INTO [TMP].[TicketMatched](TicketCode,RowID)
	SELECT   TicketCode,RowID FROM CTE_TCK_IN 
	SET @MatchedCount = @@ROWCOUNT
	SET @MatchedCountTotIn += @MatchedCount

	IF @MatchedCount > 0
	BEGIN
	-- aggiorno delta
			MERGE [TMP].[Delta] AS target  
			USING (SELECT TicketCode, RowID FROM [TMP].[TicketMatched]) AS source
			ON (target.RowID = source.RowID)  
			WHEN MATCHED THEN  UPDATE SET TicketCode = source.TicketCode
			OUTPUT inserted.TicketCode,0
			-- Tabella finale
			INTO [RAW].[TicketMatched](TicketCode,Out);
	END
    
	-- ticketIn Rimanenti da Matchare
	TRUNCATE TABLE [TMP].[DeltaTicketIn]
	INSERT INTO [TMP].[DeltaTicketIn](RowID,TotalTicketIn,Servertime,MachineID)
	SELECT RowID,TotalTicketIn,Servertime,MachineID FROM Tmp.Delta WHERE  TotalTicketIn <> 0 AND TicketCode IS NULL
	
	-- Iterazioni successive
	SET @IterationNum += 1
END

-- Controlli Finali
IF @MatchedCountTotIN = @InCount SET @InMatched  = 1
IF @MatchedCountTotOut = @OutCount SET @OutMatched  = 1

	-- Log operazione
	SET @Msg  = 'Matching ticket terminato'
	INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
	Select @ProcedureName,@Msg,@TicketCode,@BatchID

-- Errore specifico
	IF @InMatched <> 1 OR @OutMatched <> 1
		BEGIN
			SET @Msg = 'Not every ticket has been matched'
			RAISERROR (@Msg,16,1);
		END

	IF @MatchedCountTotIN = 0 AND @MatchedCountTotout = 0
	BEGIN
			SET @Msg = 'None of the tickets has been matched'
			RAISERROR (@Msg,16,1);
	END

END TRY
	-- Gestione Errore
		   BEGIN CATCH
				EXECUTE [ERR].[UspLogError]  @ErrorTicket = @TicketCode,@ErrorRequestDetailID = @BatchID
            SET @ReturnCode = -1;
			END CATCH
      
RETURN @ReturnCode
	     	-- fine calcoli 
END
GO
/****** Object:  StoredProcedure [RAW].[TicketOutServerTime]    Script Date: 22/12/2017 22:46:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RAW].[TicketOutServerTime] 
@TicketCode Varchar(50),
@Direction BIT,
@ReturnCode Int = 0 Output,
@ClubID varchar(10) = NULL,
@BatchID Int
AS
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: GA
Creation Date.......: 2017-05-19
Description.........: Parte da un ticketOut o MH remoto e trova il corrispondente Servertime sui delta

Revision			 

Note
- Use [Tab size] = 2 and [Indent size]

------------------
-- Parameters   --
------------------	

------------------
-- Call Example --
-----------------
DECLARE @ReturnCode int
EXEC @ReturnCode =   [RAW].[TicketOutServerTime] @TicketCode = '332122408485739486',@Direction = 0,@BatchID = 1
SELECT @ReturnCode ReturnCode 

DECLARE @ReturnCode int
EXEC @ReturnCode =   [RAW].[TicketOutServerTime] @TicketCode = '1000294MHR201502110001',@Direction = 0,@BatchID = 1
SELECT @ReturnCode ReturnCode 

EXEC [RAW].[TicketOutServerTime] @TicketCode = '355536370074870687',@Direction = 1,@BatchID = 1
*/
BEGIN
SET NOCOUNT ON;

-- Variabili
DECLARE @OFFSET INT,@Rank SmallInt,@IterationNum TinyInt,@Rn SmallInt,@ServerTime DateTime2(3),@DifferenceSS Int,@TicketValue INT,@TotalOutDiff Int,
		  @NumRecord Int,@DataStart Datetime2(3),@PrintingData DateTime2(0) = NULL,@MachineID SmallInt,@TotalOut Int, @ViewString Varchar(5000),
		  @FromServerTimeOut DateTime2(3), @ToServerTimeOut DateTime2(3),@FromServerTimeOutTMP  DateTime2(3),@PayOutData DateTime2(3),@Msg Varchar(1000),
		  @ReturnMessage varchar(1000),@Message VARCHAR(1000),@ReturnCode2 int, @ReturnMessage2  varchar(1000); 
DECLARE @ServerTimeTable TABLE([ServerTime] DateTime2(3),[Rn] SmallInt,DifferenceSS Int);	
DECLARE @TotalOutTable TABLE([ServerTime] DateTime2(3),TotalOut Int);	
DECLARE @ServerTime_FIRST datetime = '1900-01-01 00:00:00.000', @ServerTime_Last datetime = '2050-12-31 00:00:00.000';
DECLARE @ProcedureName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) +'.'+QUOTENAME(OBJECT_NAME(@@PROCID));

BEGIN TRY
-- Inizializzo
Select @OffSet = OffSetOut FROM Config.[Table]
SET @ServerTime = NULL
SET @IterationNum = 1
Set @DataStart = SYSDATETIME()
SET @NumRecord = 0

TRUNCATE TABLE [TMP].[TicketServerTime]
TRUNCATE TABLE [TMP].[TicketStart]

-- Log operazione
SET @Msg  = 'Calcolo TicketOutServerTime iniziato'
INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
Select @ProcedureName,@Msg,@TicketCode,@BatchID

--Prendo i dati del ticket MH di partenza
EXEC @ReturnCode2 =  [pom-mon01].[Staging].[Ticket].[Extract_Pomezia]  @ConcessionaryNumber = 1,  @TicketCode = @TicketCode ,@ClubID = @ClubID, @ReturnMessage = @ReturnMessage2 OUTPUT
--SELECT @ReturnCode ReturnCode, @ReturnMessage ReturnMessage 

-- Selezioni il clubID e creo la vista
SELECT @ClubID = ClubID From [TMP].[TicketStart]
SELECT @ViewString = (Select OBJECT_DEFINITION (OBJECT_ID(N'[Tmp].RawData_View')))

IF NOT @ViewString Like   '%![' + @ClubID + '!]%' ESCAPE '!'
	EXEC [RAW].[CreateNewViewRawID] @ClubID =  @ClubID

-- Errore specifico
IF (Select Count(*) FROM [TMP].[TicketStart]) <> 1 
BEGIN
		SET @Msg = 'Numero ticket di partenza errato'
		RAISERROR (@Msg,16,1);
END

-- Tracciamento in avanti
IF @Direction  = 1
BEGIN
	-- PrintingData
	SELECT @PayOutData = [PayOutData],@ClubID = ClubID,@MachineID = PayOutMachineID FROM [TMP].[TicketStart]
		-- Prendo il primo Out prima dell'IN
	SET @FromServerTimeOut = ISNULL((Select Max(ServerTime) FROM [TMP].[RawData_View]  WHERE TotalOut > 0 AND ServerTime < @PayOutData AND MachineID = @MachineID),@ServerTime_FIRST)
	-- Inserisco i dati
	INSERT INTO [TMP].[TicketServerTime] ([ServerTime],Direction,MachineID)
	Select  @FromServerTimeOut,@Direction,@MachineID 
END

-- Tracciamento indietro
IF @Direction  = 0
BEGIN
	-- PrintingData
	SELECT @PrintingData = [PrintingData],@ClubID = ClubID,@MachineID = PrintingMachineID FROM [TMP].[TicketStart]
	-- Controlla se MH o ticket----
	IF @PrintingData IS NULL 
	BEGIN
		SELECT @PrintingData = EventDate,@ClubID = ClubID,@MachineID = MhMachineID FROM [TMP].[TicketStart]
		SELECT @OffSet = OffSetMH FROM Config.[Table]
	END
		-- Intervallo per gli out nel range massimo di ricerca
		SET @FromServerTimeOut = ISNULL((Select Max(ServerTime) FROM [TMP].[RawData_View]  WHERE TotalOut > 0 AND LoginFlag = 0 AND ServerTime < DATEADD(SS,-@OFFSET * 30,@PrintingData) AND MachineID = @MachineID),@ServerTime_FIRST)
		--SET @FromServerTimeOut = ISNULL((Select Max(ServerTime) FROM [TMP].[RawData_View]  WHERE TotalOut > 0 AND ServerTime < @FromServerTimeOutTMP AND MachineID = @MachineID),@ServerTime_FIRST)
		SET @ToServerTimeOut =	 ISNULL((Select MIN(ServerTime) FROM [TMP].[RawData_View]  WHERE TotalOut > 0 AND LoginFlag = 0 AND ServerTime > DATEADD(SS, @OFFSET * 30,@PrintingData) AND MachineID = @MachineID),@ServerTime_LAST)

	-- Calcolo i TotalOut
	;WITH CTE_TotalOut AS
	(
	SELECT   ServerTime,TotalOut = TotalOut - ISNULL(MAX(TotalOut)  OVER (ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0)  
			 FROM [TMP].[RawData_View] WHERE TotalOut > 0
			 AND ServerTime Between @FromServerTimeOut AND @ToServerTimeOut
			 AND MachineID = @MachineID AND LoginFlag = 0
	)

	INSERT INTO @TotalOutTable(ServerTime,TotalOut)
	Select ServerTime,TotalOut FROM CTE_TotalOut WHERE ServerTime > @FromServerTimeOut

	-- iterazioni
	WHILE  (@NumRecord = 0 AND @IterationNum <= 3)
	BEGIN
		-- Matching ticket OUT
		;WITH CTE_TCK_OUT AS (
			SELECT   ServerTime,ABS(datediff(second,ServerTime,ISNULL(PrintingData,EventDate))) AS DifferenceSS, RANK() OVER  (PARTITION BY TicketValue ORDER BY 
						ABS(datediff(second,ServerTime,ISNULL(PrintingData,EventDate))) asc) AS RowRank FROM
									(
					SELECT Servertime,TotalOut FROM @TotalOutTable) T1 
							 INNER JOIN  [TMP].[TicketStart] T2 ON ISNULL(PrintingData,EventDate) Between dateadd(second,-@OffSet,ServerTime) 
							 AND dateadd(second,@OffSet,ServerTime) AND T1.TotalOut = T2.TicketValue
									)
			 -- Inserisco i ticket matchati
			INSERT INTO @ServerTimeTable(ServerTime,Rn,DifferenceSS)
			Select ServerTime,RowRank,DifferenceSS FROM CTE_TCK_OUT WHERE  RowRank = 1
			SET @NumRecord = @@RowCount

			-- Se ho trovato inserisco i riusultati finali
				IF @NumRecord > 0
				BEGIN
					INSERT INTO [TMP].[TicketServerTime] ([ServerTime] ,[IterationNum],[Rn],DifferenceSS,Direction,MachineID)
					Select ServerTime,@IterationNum,Rn,DifferenceSS,@Direction,@MachineID FROM @ServerTimeTable
				END

			--Incremento ciclo
			SET @IterationNum += 1;
	
			IF (@IterationNum = 2)
							SET @OFFSET = @OFFSET * 6

			IF @IterationNum = 3
							SET @OFFSET = @OFFSET * 30
		END
		-- fine calcoli
END 
-- Controlli Finali
	-- Log operazione
	SET @Msg  = 'Calcolo TicketOutServerTime terminato'
	INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
	Select @ProcedureName,@Msg,@TicketCode,@BatchID
-- Errore specifico
	IF NOT EXISTS (Select ServerTime FROM [TMP].[TicketServerTime])
	BEGIN
		SET @Msg = 'Empty table [TMP].[TicketServerTime]'
		RAISERROR (@Msg,16,1);
	END

END TRY
	-- Gestione Errore
		   BEGIN CATCH
				EXECUTE [ERR].[UspLogError]  @ErrorTicket = @TicketCode,@ErrorRequestDetailID  = @BatchID;
            SET @ReturnCode = -1;
       END CATCH
      
RETURN @ReturnCode

END
GO
