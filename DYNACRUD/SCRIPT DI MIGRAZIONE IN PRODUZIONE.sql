/*
Run this script on:

        192.168.8.125,2989.IRPEFWEB    -  This database will be modified

to synchronize it with:

        192.168.234.245,2059.IRPEFWEB

You are recommended to back up your database before running this script

Script created by SQL Compare version 10.4.8 from Red Gate Software Ltd at 04/12/2015 17:07:26

*/
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id=OBJECT_ID('tempdb..#tmpErrors')) DROP TABLE #tmpErrors
GO
CREATE TABLE #tmpErrors (Error int)
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO
BEGIN TRANSACTION
GO
PRINT N'Creating types'
GO
CREATE TYPE [dbo].[ENTITA_DETT_TYPE] AS TABLE
(
[CodiceEntita] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CFCreditore] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CFDebitore] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CodicePrestazione] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CodiceSede] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodiceProcedura] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Progressivo] [int] NOT NULL,
[Anno] [int] NOT NULL,
[Mese] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AnnoRif] [int] NULL,
[MeseRif] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ImportoCredito] [decimal] (18, 2) NULL,
[ImportoDebito] [decimal] (18, 2) NOT NULL,
[ImportoSospeso] [decimal] (18, 2) NULL,
[ImportoSospesoInAtto] [decimal] (18, 2) NULL,
[DataInserimento] [datetime] NOT NULL,
[DataUltimaModifica] [datetime] NOT NULL,
[CodiceRegione] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IdStruttura] [int] NOT NULL,
[ChiaveARCAAnagraficaCodice] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChiaveARCAAnagraficaProgressivo] [int] NULL,
[ChiaveARCAPrestazione] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[SourcesRepository]'
GO
CREATE TABLE [dbo].[SourcesRepository]
(
[IDrepository] [int] NOT NULL IDENTITY(1, 1),
[IDrepositoryType] [int] NOT NULL,
[SourceName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Abstract] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contents] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK_SourcesRepository] on [dbo].[SourcesRepository]'
GO
ALTER TABLE [dbo].[SourcesRepository] ADD CONSTRAINT [PK_SourcesRepository] PRIMARY KEY CLUSTERED  ([IDrepository])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[RepositoryTypes]'
GO
CREATE TABLE [dbo].[RepositoryTypes]
(
[IDRepositoryType] [int] NOT NULL IDENTITY(1, 1),
[RepositoryDescription] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK_RepositoryTypes] on [dbo].[RepositoryTypes]'
GO
ALTER TABLE [dbo].[RepositoryTypes] ADD CONSTRAINT [PK_RepositoryTypes] PRIMARY KEY CLUSTERED  ([IDRepositoryType])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[V_SourcesRepository]'
GO
-- SELECT * FROM V_SourcesRepository
CREATE  VIEW [dbo].[V_SourcesRepository]
AS
SELECT 
		SR.IDrepository
		,SR.IDrepositoryType
		,SR.SourceName
		,SR.Abstract
		,SR.Contents
		,RT.RepositoryDescription
FROM	dbo.SourcesRepository SR WITH(NOLOCK)
		INNER JOIN
		RepositoryTypes RT WITH(NOLOCK)
		ON SR.IDRepositoryType = RT.IDRepositoryType

GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[V_RAND_NEWID]'
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
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[V_RAND]'
GO
/*
---------------------------------------------------------------------------------------------
Vista preposta al ritorno di un valore reale (float, double) casuale
---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------
Esempi di invocazione:

SELECT * FROM V_RAND
*/
CREATE VIEW [dbo].[V_RAND]
AS
SELECT RAND() AS RNDVALUE



GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[fnRandomString]'
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
CREATE FUNCTION dbo.fnRandomString(@minLength int, @maxLength int)
RETURNS varchar(max)
AS
BEGIN

	DECLARE @length int, @charpool varchar(max), @LoopCount int, @PoolLength int, @RandomString varchar(max), @rand float
	SELECT @Length = RNDVALUE * @minLength + @maxLength FROM V_RAND
	SET @CharPool = 'abcdefghijkmnopqrstuvwxyzABCDEFGHIJKLMNPQRSTUVWXYZ23456789'-- - .,_!$@#%^&*'
	SET @PoolLength = Len(@CharPool)
	SET @LoopCount = 0
	SET @RandomString = ''

	WHILE (@LoopCount < @Length) 
	BEGIN
		SELECT @RAND =  RNDVALUE *  @PoolLength FROM V_RAND
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
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[fnGetRandomDataByDatatype]'
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
CREATE FUNCTION dbo.fnGetRandomDataByDatatype(@sqlDatatype varchar(20) = NULL, @maxLength int = NULL, @encloseStringsWithQuoteChar char(1) = NULL)
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
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[fnBuildCsharpGridViewCSS]'
GO
/*
---------------------------------------------------------------------------------------------
Funzione preposta alla creazione della definizione degli elementi CSS per un GridView 
partendo dalla struttura di una tabella SQL

N.B.:
Usare sempre la SELECT per invocare la presente funzione; una volta eseguita, copiare 
il contenuto della colonna 'GridViewCssDef' e incollarla all'interno di una 
finestra di Visual Studio preposta al recepimento di un foglio di stile CSS.

Per creare la classe principale in C# della Crud dinamica (DYNACRUD), invocare la funzione
"dbo.fnBuildCsharpClass"

Per creare la definizione degli elementi ASPX per un GridView, invocare la funzione 
"dbo.fnBuildCsharpGridViewASPX".

Per creare la definizione degli elementi CSS per un GridView, invocare la funzione 
invocare la funzione "dbo.fnBuildCsharpGridViewCSS".
		
Per creare il codice C# del CodeBehind di gestione degli eventi di un GridView, invocare la 
funzione "dbo.fnBuildCsharpGridViewCS".

---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------

SELECT dbo.fnBuildCsharpGridViewCSS('ENTITA_DETT') AS GridViewCssDef
---------------------------------------------------------------------------------------------
*/
CREATE FUNCTION [dbo].[fnBuildCsharpGridViewCSS](@tableName SYSNAME)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE 
			@TAB char(1) = CHAR(9)
			,@TAB2 char(2) = CHAR(9) + CHAR(9)
			,@TAB3 char(3) = CHAR(9) + CHAR(9) + CHAR(9)
			,@TAB4 char(4) = CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9)
			,@CR char(1) = CHAR(13)
			,@CR2 char(2) = CHAR(13) + CHAR(13)
			,@DataKeyNames varchar(MAX)
			,@GridViewCssDef varchar(MAX)
			,@GridViewName varchar(128)

	IF ISNULL(@tableName,'') != ''
		BEGIN
			SET	@GridViewName = REPLACE(UPPER(LEFT(@TableName,1)) + LOWER(SUBSTRING(@TableName, 2, LEN(@TableName)-1)),'_','')

			SELECT	@GridViewCssDef = Contents
			FROM	V_SourcesRepository
			WHERE	RepositoryDescription = 'CSS'
			AND		SourceName = 'GridViewStyle'
		END
	RETURN @GridViewCssDef
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[fnBuildCsharpGridViewCS]'
GO
/*
---------------------------------------------------------------------------------------------
Funzione preposta alla creazione del codice C# del CodeBehind di gestione degli eventi di un 
GridView partendo dalla struttura di una tabella SQL

N.B.:
Usare sempre la SELECT per invocare la presente funzione; una volta eseguita, copiare 
il contenuto della colonna 'GridViewCodeBehindEvents' e incollarla all'interno di una 
finestra di Visual Studio preposta al recepimento di una classe CS.

Per creare la classe principale in C# della Crud dinamica (DYNACRUD), invocare la funzione
"dbo.fnBuildCsharpClass"

Per creare la definizione degli elementi ASPX per un GridView, invocare la funzione 
"dbo.fnBuildCsharpGridViewASPX".

Per creare la definizione degli elementi CSS per un GridView, invocare la funzione 
invocare la funzione "dbo.fnBuildCsharpGridViewCSS".
		
Per creare il codice C# del CodeBehind di gestione degli eventi di un GridView, invocare la 
funzione "dbo.fnBuildCsharpGridViewCS".

---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------
Esempi di invocazione: 

SELECT dbo.fnBuildCsharpGridViewCS('ENTITA_DETT') AS GridViewCodeBehindEvents
---------------------------------------------------------------------------------------------
*/
CREATE FUNCTION [dbo].[fnBuildCsharpGridViewCS](@tableName SYSNAME)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE 
			@TAB char(1) = CHAR(9)
			,@TAB2 char(2) = CHAR(9) + CHAR(9)
			,@TAB3 char(3) = CHAR(9) + CHAR(9) + CHAR(9)
			,@TAB4 char(4) = CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9)
			,@CR char(1) = CHAR(13)
			,@CR2 char(2) = CHAR(13) + CHAR(13)
			,@DataKeyNames varchar(MAX)
			,@GridViewName varchar(128)
			,@GridViewCodeBehindEvents varchar(MAX) = NULL

	IF ISNULL(@tableName,'') != ''
		BEGIN
			SET	@GridViewName = REPLACE(UPPER(LEFT(@TableName,1)) + LOWER(SUBSTRING(@TableName, 2, LEN(@TableName)-1)),'_','')

			SELECT	@GridViewCodeBehindEvents =
					REPLACE(Contents,'$TableName', @GridViewName)
					FROM	V_SourcesRepository
					WHERE	RepositoryDescription = 'Funzione C#'
					AND		SourceName = 'GridViewEventsCodeBehind'
		END
	RETURN @GridViewCodeBehindEvents
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[fnCleanVariableName]'
GO
/*
----------------------------------------------------
-- FUNZIONE PREPOSTA AL RIMPIAZZO DI STRINGHE
-- UTILIZZATE COME NOMI DI VARIABLI
--
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
CREATE FUNCTION dbo.fnCleanVariableName(@string varchar(128))
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
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[fnGetTableDef]'
GO
/*
--------------------------------------------
-- Funzione preposta alla rappresentazione
-- della struttura di una tabella SQL
--------------------------------------------
-- Fabrizio Ricciarelli per Eustema SpA
-- 13/11/2015
--
-- Esempi di invocazione:
SELECT * FROM dbo.fnGetTableDef('ENTITA_DETT')
SELECT * FROM dbo.fnGetTableDef('MEMO78')
SELECT * FROM dbo.fnGetTableDef('COMUNICAZIONE_PSR')
*/
CREATE FUNCTION [dbo].[fnGetTableDef](@tableName varchar(128) = NULL)
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
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[fnFillSqlTemplateWithFieldsListOrdered]'
GO
/*
----------------------------------------------------
-- FUNZIONE PREPOSTA AL RIEMPIMENTO DI UN TEMPLATE
-- SOSTITUENDO LE WILDCARDS ($N,$T,$F, ETC.)
-- CON I RISPETTIVI RIMPIAZZI PROVENIENTI DALLA
-- FUNZIONE dbo.fnGetTableDef(@tableName)
--
----------------------------------------------------
--
-- Fabrizio Ricciarelli per Eustema Spa
-- 16/11/2015
--
-- Esempi di invocazione:
DECLARE @replacements varchar(max) = ''
SELECT	@replacements = COALESCE(@replacements,'') + FieldName + ' = ' + WildCard + CHAR(13)
FROM	FILLER_DEC
PRINT(@replacements)

PRINT 
(
	dbo.fnFillSqlTemplateWithFieldsListOrdered
	(
		@replacements
		,'ENTITA_DETT'
		,NULL
	)
)


PRINT (dbo.fnFillSqlTemplateWithFieldsListOrdered('$N, -- (ad es.: $?)' + CHAR(13),'ENTITA_DETT',NULL))
PRINT (dbo.fnFillSqlTemplateWithFieldsListOrdered('AND ($N = $V OR $V IS NULL) -- [$T] $F {$L} -$S- .$I. *$P* #$C#' + CHAR(13),'ENTITA_DETT',NULL))
PRINT (dbo.fnFillSqlTemplateWithFieldsListOrdered('$N IS NOT NULL OR' + CHAR(13),'ENTITA_DETT',NULL))
PRINT (dbo.fnFillSqlTemplateWithFieldsListOrdered('SET @SQL = dbo.fnAddSetParam(@SQL,''$N'', @$N, ''$T'') ' + CHAR(13),'ENTITA_DETT',NULL))
PRINT (dbo.fnFillSqlTemplateWithFieldsListOrdered('_ed.$@ = $?;' + CHAR(13),'ENTITA_DETT',NULL))

DECLARE @TAB2 char(2) = CHAR(9) + CHAR(9), @TAB3 char(3) = CHAR(9) + CHAR(9) + CHAR(9)
SELECT 
(
	REPLACE
	(
		REPLACE
		(
			dbo.fnFillSqlTemplateWithFieldsListOrdered
			(
				@TAB2 + '<asp:TemplateField HeaderText="$@" HeaderStyle-HorizontalAlign="Left">' + CHAR(13) +
				@TAB3 + '<ItemTemplate><asp:Label ID="lbl$@" Text=''<%# Bind("$@") %>'' DataFormatString="{0:F$S}" ApplyFormatInEditMode="true" HtmlEncode="false" runat="server"></asp:Label></ItemTemplate>' + CHAR(13) +
				@TAB3 + '<EditItemTemplate><asp:TextBox ID="txt$@" MaxLength="$S" Text=''<%# Bind("$@") %>'' DataFormatString="{0:F$S}" ApplyFormatInEditMode="true" HtmlEncode="false" runat="server"></asp:TextBox></EditItemTemplate>' + CHAR(13) +
				@TAB3+ '<FooterTemplate><asp:TextBox ID="txt$@" runat="server"></asp:TextBox></FooterTemplate>' + CHAR(13) +
				@TAB2 + '</asp:TemplateField>' + CHAR(13)

				,'ENTITA_DETT',NULL)
			,'_x'
			,''
		)
		,'_PK'
		,''
	)
)
-- 
*/
CREATE FUNCTION [dbo].[fnFillSqlTemplateWithFieldsListOrdered](@SQLbase nvarchar(MAX), @tableName SYSNAME, @orderByDefFieldName SYSNAME=NULL)
RETURNS nvarchar(MAX) AS
BEGIN

/*
---------------------------------------------------------------------------------
-- SE SOLO FOSSE POSSIBILE ESEGUIRE LA sp_executesql ALL'INTERNO DI UNA FUNZIONE
-- IL CODICE COMMENTATO CHE SEGUE SOSTITUIREBBE INTEGRALMENTE QUELLO ATTUALMENTE
-- IN USO
---------------------------------------------------------------------------------
DECLARE 
		@r varchar(max)
		,@t varchar(max)
		,@function Nvarchar(MAX)
		,@AP varchar(1) = CHAR(39)
		,@TAB2 char(2) = CHAR(9) + CHAR(9)
		,@SQL Nvarchar(MAX) = NULL
		,@parmDef Nvarchar(max) = N'@tableName SYSNAME, @SQLbase Nvarchar(MAX), @SQL Nvarchar(MAX) OUTPUT'

		----------------------------------------------------------------
		-- Da commentare se si può utilizzare una EXEC in una FUNCTION
		-- (decommentando di conseguenza tutto il resto del codice)
		----------------------------------------------------------------
		,@orderByDefFieldName varchar(100) = 'variableName'
		,@tableName SYSNAME = 'ENTITA_DETT'
		,@SQLbase Nvarchar(MAX) = '$V $F,' + CHAR(13)
		----------------------------------------------------------------
SELECT	
		@r = COALESCE(@r,'') + @TAB2 + 'REPLACE(' + CHAR(13)
		,@t = COALESCE(@t,'') + @TAB2 + @AP + LTRIM(RTRIM(WildCard)) + @AP + ',' + LTRIM(RTRIM(FieldName)) + '),' + CHAR(13)
FROM	FILLER_DEC
ORDER BY FieldName

SET @t = LEFT(@t,LEN(@t)-2)
SET @function =	N'SELECT @SQL = COALESCE(@SQL,'''') + ' + CHAR(13) + 
				@r + @TAB2 + '''' + @SQLbase + ''',' + CHAR(13) + 
				@t + CHAR(13) + 
				'FROM dbo.fnGetTableDef('''' + @tableName + '''')' + CHAR(13) + 
				CASE ISNULL(@orderByDefFieldName,'') WHEN '' THEN '' ELSE 'ORDER BY ' + @orderByDefFieldName END
EXEC sp_executesql @function, @parmDef, @tableName, @SQLbase, @SQL=@SQL OUTPUT
SET @SQL = CASE WHEN RIGHT(@SQL,1) = ',' THEN LEFT(@SQL,LEN(@SQL)-1) WHEN RIGHT(@SQL,2) = ',' + CHAR(13) THEN LEFT(@SQL,LEN(@SQL)-2) END
--PRINT(@function)
PRINT(@SQL)
-- RETURN @SQL
*/
	DECLARE
			@retVal nvarchar(MAX)
			,@SQL Nvarchar(MAX)

	IF ISNULL(@SQLbase,'') != ''
	AND ISNULL(@tableName,'') != ''
		BEGIN

			IF ISNULL(@orderByDefFieldName,'') = ''
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
				END

			IF ISNULL(@orderByDefFieldName,'') = 'fieldName'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY fieldName
				END

			IF ISNULL(@orderByDefFieldName,'') = 'variableName'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY variableName
				END

			IF ISNULL(@orderByDefFieldName,'') = 'castedFieldName'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY castedFieldName
				END

			IF ISNULL(@orderByDefFieldName,'') = 'castedDenulledFieldName'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY castedDenulledFieldName
				END

			IF ISNULL(@orderByDefFieldName,'') = 'fieldType'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY fieldType
				END

			IF ISNULL(@orderByDefFieldName,'') = 'fullFieldType'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY fullFieldType
				END

			IF ISNULL(@orderByDefFieldName,'') = 'SqlDbType'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY SqlDbType
				END

			IF ISNULL(@orderByDefFieldName,'') = 'cSharpType'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY cSharpType
				END

			IF ISNULL(@orderByDefFieldName,'') = 'cSharpPrivateVariableName'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY cSharpPrivateVariableName
				END

			IF ISNULL(@orderByDefFieldName,'') = 'cSharpPublicPropertyName'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY cSharpPublicPropertyName
				END

			IF ISNULL(@orderByDefFieldName,'') = 'fieldLength'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY fieldLength
				END

			IF ISNULL(@orderByDefFieldName,'') = 'stringFieldLength'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY stringFieldLength
				END

			IF ISNULL(@orderByDefFieldName,'') = 'fieldIsIdentity'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY fieldIsIdentity
				END

			IF ISNULL(@orderByDefFieldName,'') = 'fieldIsKey'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY fieldIsKey
				END

			IF ISNULL(@orderByDefFieldName,'') = 'fieldPrecision'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY fieldPrecision
				END

			IF ISNULL(@orderByDefFieldName,'') = 'randomData'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY randomData
				END

			IF ISNULL(@orderByDefFieldName,'') = 'fieldScale'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY fieldScale
				END

		END
	RETURN @retVal
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[fnBuildCsharpGridViewASPX]'
GO
/*
---------------------------------------------------------------------------------------------
Funzione preposta alla creazione della definizione degli elementi ASPX per un GridView 
partendo dalla struttura di una tabella SQL

N.B.:
Usare sempre la SELECT per invocare la presente funzione; una volta eseguita, copiare 
il contenuto della colonna 'GridViewAspxDef' e incollarla all'interno di una 
finestra di Visual Studio preposta al recepimento di una definizione ASPX.

Per creare la classe principale in C# della Crud dinamica (DYNACRUD), invocare la funzione
"dbo.fnBuildCsharpClass"

Per creare la definizione degli elementi ASPX per un GridView, invocare la funzione 
"dbo.fnBuildCsharpGridViewASPX".

Per creare la definizione degli elementi CSS per un GridView, invocare la funzione 
invocare la funzione "dbo.fnBuildCsharpGridViewCSS".
		
Per creare il codice C# del CodeBehind di gestione degli eventi di un GridView, invocare la 
funzione "dbo.fnBuildCsharpGridViewCS".

---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------
Esempi di invocazione: 

SELECT dbo.fnBuildCsharpGridView('ENTITA_DETT') AS GridViewAspxDef
---------------------------------------------------------------------------------------------
*/
CREATE FUNCTION [dbo].[fnBuildCsharpGridViewASPX](@tableName SYSNAME)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE 
			@TAB char(1) = CHAR(9)
			,@TAB2 char(2) = CHAR(9) + CHAR(9)
			,@TAB3 char(3) = CHAR(9) + CHAR(9) + CHAR(9)
			,@TAB4 char(4) = CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9)
			,@CR char(1) = CHAR(13)
			,@CR2 char(2) = CHAR(13) + CHAR(13)
			,@DataKeyNames varchar(MAX)
			,@GridViewDef varchar(MAX)
			,@GridViewName varchar(128)

	IF ISNULL(@tableName,'') != ''
		BEGIN
			SET	@GridViewName = REPLACE(UPPER(LEFT(@TableName,1)) + LOWER(SUBSTRING(@TableName, 2, LEN(@TableName)-1)),'_','')

			SELECT  @DataKeyNames = COALESCE(@DataKeyNames, '') + REPLACE(CsharpPublicPropertyName,'_PK','') + ',' 
			FROM	dbo.fnGetTableDef(@tableName)
			WHERE	fieldIsKey = 1

			SELECT	@DataKeyNames = LTRIM(RTRIM(LEFT(@DataKeyNames, LEN(@DataKeyNames) -1)))

			SELECT	@GridViewDef =
					(
						SELECT	REPLACE(Contents,'$TableName', @GridViewName)
						FROM	V_SourcesRepository
						WHERE	RepositoryDescription = 'Funzione C#'
						AND		SourceName = 'GridViewAspxElementsTop'
					) +  @CR2 + 
					(
						REPLACE
						(
							REPLACE
							(
								dbo.fnFillSqlTemplateWithFieldsListOrdered
								(
									@TAB2 + '<asp:TemplateField HeaderText="$@" HeaderStyle-HorizontalAlign="Left">' + CHAR(13) +
									@TAB3 + '<ItemTemplate><asp:Label ID="lbl$@" Text=''<%# Bind("$@") %>'' DataFormatString="{0:F$S}" ApplyFormatInEditMode="true" HtmlEncode="false" runat="server"></asp:Label></ItemTemplate>' + CHAR(13) +
									@TAB3 + '<EditItemTemplate><asp:TextBox ID="txt$@" MaxLength="$S" Text=''<%# Bind("$@") %>'' DataFormatString="{0:F$S}" ApplyFormatInEditMode="true" HtmlEncode="false" runat="server"></asp:TextBox></EditItemTemplate>' + CHAR(13) +
									@TAB3+ '<FooterTemplate><asp:TextBox ID="txt$@" runat="server"></asp:TextBox></FooterTemplate>' + CHAR(13) +
									@TAB2 + '</asp:TemplateField>' + CHAR(13)

									,@tableName,NULL)
								,'_x'
								,''
							)
							,'_PK'
							,''
						)
					) +
					(
						SELECT	REPLACE(Contents,'$TableName', @GridViewName)
						FROM	V_SourcesRepository
						WHERE	RepositoryDescription = 'Funzione C#'
						AND		SourceName = 'GridViewAspxElementsBottom'
					)
		END
	RETURN @GridViewDef
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[fnAddSetParam]'
GO
/*
----------------------------------------
-- FUNZIONE PREPOSTA ALLA ELENCAZIONE DI
-- UN INSIEME DI "SET" DI NOMI DI CAMPO
-- PER LA CREAZIONE DI UNO STATEMENT DI
-- UPDATE
----------------------------------------
--
-- Fabrizio Ricciarelli per Eustema Spa
-- 12/11/2015
--
-- Esempi di invocazione:
--
PRINT(dbo.fnAddSetParam('UPDATE ADDIZIONALE_COMUNALE_DETT', 'CFCreditore', 'RCCFRZ67P13F611D','STR'))
PRINT(dbo.fnAddSetParam('UPDATE ADDIZIONALE_COMUNALE_DETT', 'CFCreditore', 'RCCFRZ67P13F611D','VARCHAR'))
PRINT(dbo.fnAddSetParam('UPDATE ADDIZIONALE_COMUNALE_DETT SET CFCreditore = ''RCCFRZ67P13F611D''', 'ImportoAcconto', '140.21', 'INT'))
PRINT(dbo.fnAddSetParam('UPDATE ADDIZIONALE_COMUNALE_DETT SET CFCreditore = ''RCCFRZ67P13F611D'', ImportoAcconto = 140.21', 'DataInserimento', '2015-10-11 17:35:44', 'DAT'))
*/
CREATE FUNCTION	dbo.fnAddSetParam(@SQLbase varchar(MAX), @fieldName varchar(128), @fieldValue varchar(128), @fieldType varchar(20))
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @retVal varchar(MAX)
	SET @retVal = ISNULL(@SQLbase,'')

	IF ISNULL(@SQLbase,'') != ''
	AND ISNULL(@fieldName,'') != ''
	AND ISNULL(@fieldValue,'') != ''
		BEGIN
			SET @fieldType = UPPER(@fieldType)

			IF @SQLbase NOT LIKE '%SET%'
				BEGIN
					SET @retVal = @SQLbase + CHAR(13) + 'SET '
				END
			ELSE
				BEGIN
					SET @retVal = @SQLbase + ', '
				END
			SET @retVal = @retVal + @fieldName + ' = '

			IF @fieldType = 'BIT'
				BEGIN
					SET @retVal = @retVal + CONVERT(varchar(1),@fieldValue)
				END
			IF @fieldType = 'INT'
				BEGIN
					SET @retVal = @retVal + CONVERT(varchar(9),@fieldValue)
				END
			IF @fieldType IN ('BIG','BIGINT') -- BigInt
				BEGIN
					SET @retVal = @retVal + CONVERT(varchar(16),@fieldValue)
				END
			IF @fieldType IN ('DEC','DECIMAL') -- Decimal(18,2)
				BEGIN
					SET @retVal = @retVal + CONVERT(varchar(21),@fieldValue)
				END
			IF @fieldType IN ('DAT','DATETIME') -- DateTime
				BEGIN
					SET @retVal = @retVal + '''' + CONVERT(varchar(26),@fieldValue) + ''''
				END
			IF @fieldType IN ('STR','CHAR','VARCHAR') -- Char, Varchar
				BEGIN
					SET @retVal = @retVal + '''' + @fieldValue + ''''
				END

		END

	RETURN @retVal
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[fnFillSqlTemplateWithFieldsList]'
GO
/*
----------------------------------------------------
-- FUNZIONE PREPOSTA AL RIEMPIMENTO DI UN TEMPLATE
-- SOSTITUENDO LE WILDCARDS ($N,$T,$F, ETC.)
-- CON I RISPETTIVI RIMPIAZZI PROVENIENTI DALLA
-- FUNZIONE dbo.fnGetTableDef(@tableName)
--
----------------------------------------------------
--
-- Fabrizio Ricciarelli per Eustema Spa
-- 16/11/2015
--
-- Esempi di invocazione:
--
------------------------------
-- Esempio di creazione di 
-- elenchi per C#
------------------------------
-- 1. Classi C# (vedere anche la funzione ad-hoc "fnBuildCsharpClass")
------------------------------
DECLARE 
		@CR char(1) = CHAR(13)
		,@TAB char(1) = CHAR(9)
		,@TAB2 char(2) = CHAR(9) + CHAR(9)
		,@TAB3 char(3) = CHAR(9) + CHAR(9) + CHAR(9)
		,@regionPrivate varchar(50)
		,@regionPublic varchar(50)
		,@endregion varchar(20)
		,@summary varchar(100)

SET @regionPrivate = @TAB2 + '#region Variabili private' + @CR
SET @regionPublic = @TAB2 + '#region Proprietà pubbliche' + @CR
SET @endRegion = @TAB2 + '#endregion' + @CR
SET @summary = @CR + @TAB2 + '/// <summary>' + @CR + @TAB2 + '///' + @CR + @TAB2 + '/// </summary>' + @CR

PRINT (@regionPrivate + dbo.fnFillSqlTemplateWithFieldsList(@TAB2 + 'private $# $^;' + CHAR(13),'ENTITA_DETT') + @endregion) -- classe C# (Variabili private)
PRINT (@regionPublic + dbo.fnFillSqlTemplateWithFieldsList(@summary + @TAB2 + 'public $# $@' + @CR + @TAB2 + '{' + @CR + @TAB3 + 'get { return $^; }' + @CR + @TAB3 + 'set { $^ = ($#)value; }' + @CR + @TAB2 +' }' + CHAR(13),'ENTITA_DETT') + @endregion) -- classe C# (Proprietà pubbliche)

------------------------------
-- 2. Parametri DataAccessLayer C#
------------------------------
PRINT (dbo.fnFillSqlTemplateWithFieldsList('SqlParameter p$@ = new SqlParameter("$V",$Q);' + CHAR(13) + 'p$@.Size = $S;' + CHAR(13) + 'p$@.Precision = $P;' + CHAR(13) + 'p$@.Scale = $C;' + CHAR(13) + 'p$@.Value = $^;' + CHAR(13),'ENTITA_DETT')) 

------------------------------
-- Esempi di creazione di 
-- elenchi per T-SQL
------------------------------
PRINT (dbo.fnFillSqlTemplateWithFieldsList('$N,' + CHAR(13),'ENTITA_DETT'))
PRINT (dbo.fnFillSqlTemplateWithFieldsList('AND ($N = $V OR $V IS NULL) -- [$T] $F {$L} -$S- .$I. *$P* #$C#' + CHAR(13),'ENTITA_DETT'))
PRINT (dbo.fnFillSqlTemplateWithFieldsList('$N IS NOT NULL OR' + CHAR(13),'ENTITA_DETT'))
PRINT (dbo.fnFillSqlTemplateWithFieldsList('SET @SQL = dbo.fnAddSetParam(@SQL,''$N'', @$N, ''$T'') ' + CHAR(13),'ENTITA_DETT'))
-- 
*/
CREATE FUNCTION [dbo].[fnFillSqlTemplateWithFieldsList](@SQLbase nvarchar(MAX), @tableName SYSNAME)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @retVal varchar(MAX)
	SET @retVal = dbo.fnFillSqlTemplateWithFieldsListOrdered(@SQLbase, @tableName, NULL)
	RETURN @retVal
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[spSelInsUpdDelEntitaDett]'
GO
/*
------------------------------------------------------------
STORED PROCEDURE PER CRUD DINAMICA (SIMIL-ENTITY FRAMEWORK)
(SELECT,INSERT,UPDATE,DELETE)
SU TABELLA ENTITA_DETT

SI AVVALE DELLE FUNZIONI 
- dbo.fnGetTableDef
- dbo.fnAddSetParam
- dbo.fnFillSqlTemplateWithFieldsList
- dbo.fnCleanVariableName
PER LA COSTRUZIONE DEL CODICE SQL DINAMICO
A INCAPSULAMENTO ANNIDATO PROGRESSIVO

****************************************************
OGNI QUALVOLTA VIENE MODIFICATO UN NOME DI CAMPO,
AGGIUNTO O RIMOSSO UN CAMPO DALLA TABELLA OGGETTO
DELLA PRESENTE CRUD DINAMICA, OPERARE COME SEGUE:

1.	ESEGUIRE LO STATEMENT SEGUENTE:
	DECLARE @t varchar(MAX), @TAB char(1)=CHAR(9), @TAB3 char(3), @CR char(1)=CHAR(13); SET @TAB3=REPLICATE(@TAB,3) ; SET @t=dbo.fnFillSqlTemplateWithFieldsList(@CR+@TAB3+'$V $F = NULL,','ENTITA_DETT')+@CR+@TAB3+'@OP char(1) = NULL,'+@CR+@TAB3+'@UpdateWhereCondition varchar(MAX) = NULL,'+@CR+@TAB3+'@ReturnValue int OUTPUT'; PRINT(@t)

2.	COPIARE IL RISULTATO DALLA CASELLA "Messages" 
	ED INCOLLARLO IN *SOSTITUZIONE* DELL'ATTUALE
	DEFINIZIONE DEI PARAMETRI DELLA PRESENTE
	STORED PROCEDURE

3.	ESEGUIRE LO STATEMENT SEGUENTE:
	DECLARE @t varchar(MAX); SET @t='EXEC sp_executesql @SQL,@paramDefinitions,' + dbo.fnFillSqlTemplateWithFieldsList('$V,','ENTITA_DETT'); SET @t=LEFT(@t,LEN(@t)-1); PRINT(@t)

4.	COPIARE IL RISULTATO DALLA CASELLA "Messages" 
	ED INCOLLARLO IN *SOSTITUZIONE* DEGLI ATTUALI
	STATEMENTS "EXEC sp_executesql" RELATIVAMENTE
	ALLE OPERAZIONI DI SELECT, INSERT, UPDATE E 
	DELETE: PER L'OPERAZIONE DI *UPDATE*, AGGIUNGERE
	QUESTO IN CODA (SENZA LE VIRGOLETTE): 
	
	",@subSQL=@subSQL OUTPUT"

5.	RIMPIAZZARE, SE LO SI DESIDERA, TUTTA LA SEZIONE
	DEGLI "Esempi di invocazione" AFFINCHE' ANCHE
	QUESTI RAPPRESENTINO LA STRUTTURA AGGIORNATA E
	POSSANO ESSERE NUOVAMENTE VALORIZZATI CON VALORI
	DI TEST E POI INVOCATI SENZA INCORRERE IN ERRORI
****************************************************

------------------------------------------------------------

Fabrizio Ricciarelli per Eustema Spa
17/11/2015

Esempi di invocazione:

----------------------------
-- INSERIMENTO DI UN RECORD
----------------------------
DECLARE @LASTID int
EXEC	spSelInsUpdDelEntitaDett
		@CodiceEntita = 'RIT'
		,@CFCreditore = 'GGGHHH45H28S290W'
		,@CFDebitore = NULL
		,@CodicePrestazione = '12346'
		,@CodiceSede = '000000'
		,@CodiceProcedura = '39B'
		,@Progressivo = 1
		,@Anno = 2015
		,@Mese = '11'
		,@AnnoRif = NULL
		,@MeseRif = NULL
		,@ImportoCredito = 2000.00
		,@ImportoDebito = 1500.23
		,@ImportoSospeso = NULL
		,@ImportoSospesoInAtto = NULL
		,@DataInserimento = NULL
		,@DataUltimaModifica = NULL
		,@CodiceRegione = '00'
		,@IdStruttura = 3
		,@ChiaveARCAAnagraficaCodice = NULL
		,@ChiaveARCAAnagraficaProgressivo = NULL
		,@ChiaveARCAPrestazione = NULL
		,@OP = 'I' -- S = Select, I = Insert, U = Update, D = Delete
		,@UpdateWhereCondition = NULL
		,@ReturnValue =  @LASTID OUTPUT
PRINT(@LASTID)

------------------------------
-- AGGIORNAMENTO DI UN RECORD
------------------------------

-- DATA E ORA CORRENTI (per valorizzare il campo "DataUltimaModifica")
DECLARE @now datetime
SET @now = GETDATE()

-- STRINGA CASUALE DA 128 CARATTERI (per valorizzare il campo "ChiaveARCAPrestazione")
SET NOCOUNT ON;
DECLARE @var TABLE(rndstr varchar(MAX))
DECLARE @rndstr varchar(max)
INSERT @var EXEC sp_RandomString 128
SELECT @rndstr = rndstr FROM @var
SET NOCOUNT OFF;

EXEC	spSelInsUpdDelEntitaDett
		@CodiceEntita = NULL
		,@CFCreditore = NULL
		,@CFDebitore = NULL
		,@CodicePrestazione = '1234A'
		,@CodiceSede = NULL
		,@CodiceProcedura = NULL
		,@Progressivo = NULL
		,@Anno = NULL
		,@Mese = NULL
		,@AnnoRif = NULL
		,@MeseRif = NULL
		,@ImportoCredito = NULL
		,@ImportoDebito = 1800.31
		,@ImportoSospeso = 543.86
		,@ImportoSospesoInAtto = NULL
		,@DataInserimento = NULL
		,@DataUltimaModifica = @now
		,@CodiceRegione = NULL
		,@IdStruttura = 1
		,@ChiaveARCAAnagraficaCodice = NULL
		,@ChiaveARCAAnagraficaProgressivo = NULL
		,@ChiaveARCAPrestazione = @rndstr
		,@OP = 'U' -- S = Select, I = Insert, U = Update, D = Delete
		,@UpdateWhereCondition = 'CFCreditore = ''RCCFRZ67P13F611D'' AND Anno = 2015 AND Mese = ''11'' '
		,@ReturnValue = NULL

------------------------------
-- SELEZIONE DI UNO O PIU'
-- RECORDS CORRISPONDENTI AI
-- VALORI IMPOSTATI
------------------------------
EXEC	spSelInsUpdDelEntitaDett NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'S',NULL,NULL -- SELEZIONA TUTTI I RECORDS

-- oppure

EXEC	spSelInsUpdDelEntitaDett
		@CodiceEntita = NULL
		,@CFCreditore = NULL
		,@CFDebitore = NULL
		,@CodicePrestazione  = NULL
		,@CodiceSede = NULL
		,@CodiceProcedura = NULL
		,@Progressivo = NULL
		,@Anno = NULL
		,@Mese = NULL
		,@AnnoRif = NULL
		,@MeseRif = NULL
		,@ImportoCredito = NULL
		,@ImportoDebito = NULL
		,@ImportoSospeso = NULL
		,@ImportoSospesoInAtto = NULL
		,@DataInserimento = NULL
		,@DataUltimaModifica = NULL
		,@CodiceRegione = NULL
		,@IdStruttura = NULL
		,@ChiaveARCAAnagraficaCodice = NULL
		,@ChiaveARCAAnagraficaProgressivo = NULL
		,@ChiaveARCAPrestazione = NULL
		,@OP = 'S' -- S = Select, I = Insert, U = Update, D = Delete
		,@UpdateWhereCondition = NULL
		,@ReturnValue = NULL


------------------------------
-- ELIMINAZIONE DI UNO O PIU'
-- RECORDS CORRISPONDENTI AI
-- VALORI IMPOSTATI
------------------------------
EXEC	spSelInsUpdDelEntitaDett
		@CodiceEntita = NULL
		,@CFCreditore = NULL
		,@CFDebitore = NULL
		,@CodicePrestazione  = NULL
		,@CodiceSede = NULL
		,@CodiceProcedura = '29'
		,@Progressivo = NULL
		,@Anno = NULL
		,@Mese = NULL
		,@AnnoRif = NULL
		,@MeseRif = NULL
		,@ImportoCredito = NULL
		,@ImportoDebito = NULL
		,@ImportoSospeso = NULL
		,@ImportoSospesoInAtto = NULL
		,@DataInserimento = NULL
		,@DataUltimaModifica = NULL
		,@CodiceRegione = NULL
		,@IdStruttura = NULL
		,@ChiaveARCAAnagraficaCodice = NULL
		,@ChiaveARCAAnagraficaProgressivo = NULL
		,@ChiaveARCAPrestazione = NULL
		,@OP = 'D' -- S = Select, I = Insert, U = Update, D = Delete
		,@UpdateWhereCondition = NULL
		,@ReturnValue = NULL
------------------------------------------------------------
*/
CREATE PROC	[dbo].[spSelInsUpdDelEntitaDett]
			@CodiceEntita varchar(5) = NULL,			@CFCreditore varchar(16) = NULL,			@CFDebitore varchar(16) = NULL,			@CodicePrestazione varchar(5) = NULL,			@CodiceSede char(6) = NULL,			@CodiceProcedura varchar(4) = NULL,			@Progressivo int = NULL,			@Anno int = NULL,			@Mese varchar(2) = NULL,			@AnnoRif int = NULL,			@MeseRif varchar(2) = NULL,			@ImportoCredito decimal(18,2) = NULL,			@ImportoDebito decimal(18,2) = NULL,			@ImportoSospeso decimal(18,2) = NULL,			@ImportoSospesoInAtto decimal(18,2) = NULL,			@DataInserimento datetime = NULL,			@DataUltimaModifica datetime = NULL,			@CodiceRegione varchar(2) = NULL,			@IdStruttura int = NULL,			@ChiaveARCAAnagraficaCodice varchar(3) = NULL,			@ChiaveARCAAnagraficaProgressivo int = NULL,			@ChiaveARCAPrestazione varchar(128) = NULL,			@OP char(1) = NULL,			@UpdateWhereCondition varchar(MAX) = NULL,			@ReturnValue int OUTPUT
AS

DECLARE 
		@tableName varchar(128) = 'ENTITA_DETT'
		,@SQL Nvarchar(MAX) -- SQL Dinamico di primo livello
		,@subSQL Nvarchar(MAX) -- SQL dinamico di secondo livello
		,@fieldsList varchar(MAX) -- Contenitore per nomi dei campi (CodiceEntita, CFCreditore etc.)
		,@castedDenulledFieldsList varchar(MAX) -- Contenitore per CAST dei campi (ISNULL(@CodiceEntita,''), ISNULL(@CFCreditore,''), ISNULL(CAST(@IDStruttura AS varchar(9)),'') etc.)
		,@paramDefinitions Nvarchar(MAX) -- Contenitore per definizione dei tipi dei parametri (@CodiceEntita varchar(5), @CFCreditore varchar(16) etc.)
		,@baseWhereCondition Nvarchar(MAX) -- Contenitore per criteri di filtro dinamici (AND (CodiceEntita = @CodiceEntita OR @CodiceEntita IS NULL))
		
		------------------------------------------
		-- ESPANSIONE FUTURA PER MULTIANNIDAMENTO
		------------------------------------------
		--,@paramsList Nvarchar(MAX) -- Contenitore per nomi dei parametri (@CodiceEntita,@CFCreditore,@CFdebitore etc.)
		--,@paramDefinitionsLevel2 Nvarchar(MAX) -- Contenitore per definizione dei tipi dei parametri di secondo livello (@CodiceEntita varchar(5), @CFCreditore varchar(16) etc.)
		--SET @paramsList = dbo.fnFillSqlTemplateWithFieldsList('@$N,',@tableName)
		--SET @paramsList = LEFT(@paramsList,LEN(@paramsList)-1) -- Elimina la virgola finale
		------------------------------------------

SET @fieldsList = dbo.fnFillSqlTemplateWithFieldsList('$N,',@tableName)
SET @fieldsList = LEFT(@fieldsList,LEN(@fieldsList)-1) -- Elimina la virgola finale

SET @castedDenulledFieldsList = dbo.fnFillSqlTemplateWithFieldsList('$M,',@tableName)
SET @castedDenulledFieldsList = LEFT(@castedDenulledFieldsList,LEN(@castedDenulledFieldsList)-1) -- Elimina la virgola finale


SET @paramDefinitions = dbo.fnFillSqlTemplateWithFieldsList('$V $F,',@tableName)
SET @paramDefinitions = LEFT(@paramDefinitions,LEN(@paramDefinitions)-1) -- Elimina la virgola finale

SET @baseWhereCondition = dbo.fnFillSqlTemplateWithFieldsList('AND ($N = $V OR $V IS NULL)' + CHAR(13),@tableName)
SET @ReturnValue = 0


-----------------------------------------------------------
-- OPERAZIONE DI SELECT (SQL DINAMICO, NESSUN ANNIDAMENTO)
-----------------------------------------------------------
IF @OP = 'S'
	BEGIN
		SET @SQL =
		N'
		SELECT ' + @fieldsList + '
		FROM	' + @tableName + ' WITH(NOLOCK)
		WHERE	1=1 ' + CHAR(13) + @baseWhereCondition
		EXEC sp_executesql @SQL,@paramDefinitions,@CodiceEntita,@CFCreditore,@CFDebitore,@CodicePrestazione,@CodiceSede,@CodiceProcedura,@Progressivo,@Anno,@Mese,@AnnoRif,@MeseRif,@ImportoCredito,@ImportoDebito,@ImportoSospeso,@ImportoSospesoInAtto,@DataInserimento,@DataUltimaModifica,@CodiceRegione,@IdStruttura,@ChiaveARCAAnagraficaCodice,@ChiaveARCAAnagraficaProgressivo,@ChiaveARCAPrestazione

		SET @ReturnValue = @@ROWCOUNT
	END


-----------------------------------------------------------
-- OPERAZIONE DI INSERT (SQL DINAMICO, NESSUN ANNIDAMENTO)
-----------------------------------------------------------
IF @OP = 'I'
	BEGIN
		SET @SQL =
		N'
		INSERT	' + @tableName + '(' + @fieldsList + ')
		VALUES(' + @castedDenulledFieldsList + ')'
		EXEC sp_executesql @SQL,@paramDefinitions,@CodiceEntita,@CFCreditore,@CFDebitore,@CodicePrestazione,@CodiceSede,@CodiceProcedura,@Progressivo,@Anno,@Mese,@AnnoRif,@MeseRif,@ImportoCredito,@ImportoDebito,@ImportoSospeso,@ImportoSospesoInAtto,@DataInserimento,@DataUltimaModifica,@CodiceRegione,@IdStruttura,@ChiaveARCAAnagraficaCodice,@ChiaveARCAAnagraficaProgressivo,@ChiaveARCAPrestazione

		SET @ReturnValue = @@ROWCOUNT -- la funzione SCOPE_IDENTITY() può essere invocata solo se esiste una colonna IDENTITY
	END


-----------------------------------------------------------
-- OPERAZIONE DI UPDATE (SQL DINAMICO, UN SOLO ANNIDAMENTO)
-----------------------------------------------------------
IF @OP = 'U'
AND	@UpdateWhereCondition IS NOT NULL
	BEGIN
		SET @paramDefinitions += N',@subSQL nvarchar(MAX) output'
		SET @SQL = 'SET @subSQL = ''UPDATE ' + @tableName + '''' + CHAR(13)
		SET	@SQL += dbo.fnFillSqlTemplateWithFieldsList('SELECT @subSQL = dbo.fnAddSetParam(@subSQL,''$N'', '''' + $K + '''', ''$T'') ' + CHAR(13), @tableName)
		SET @SQL += CHAR(13) + 'SET @subSQL += ''WHERE ' + REPLACE(@UpdateWhereCondition,CHAR(39), CHAR(39)+CHAR(39)) + ''''
		--PRINT(@SQL)
		EXEC sp_executesql @SQL,@paramDefinitions,@CodiceEntita,@CFCreditore,@CFDebitore,@CodicePrestazione,@CodiceSede,@CodiceProcedura,@Progressivo,@Anno,@Mese,@AnnoRif,@MeseRif,@ImportoCredito,@ImportoDebito,@ImportoSospeso,@ImportoSospesoInAtto,@DataInserimento,@DataUltimaModifica,@CodiceRegione,@IdStruttura,@ChiaveARCAAnagraficaCodice,@ChiaveARCAAnagraficaProgressivo,@ChiaveARCAPrestazione,@subSQL=@subSQL OUTPUT
		EXEC(@subSQL)
		--PRINT(@subSQL)

		SET @ReturnValue = @@ROWCOUNT
	END


-----------------------------------------------------------
-- OPERAZIONE DI DELETE (SQL DINAMICO, NESSUN ANNIDAMENTO)
-----------------------------------------------------------
IF @OP = 'D'
	BEGIN
		SET @SQL =
		N'
		DELETE 
		FROM	' + @tableName + '
		WHERE	1=1 ' + CHAR(13) + @baseWhereCondition
		EXEC sp_executesql @SQL,@paramDefinitions,@CodiceEntita,@CFCreditore,@CFDebitore,@CodicePrestazione,@CodiceSede,@CodiceProcedura,@Progressivo,@Anno,@Mese,@AnnoRif,@MeseRif,@ImportoCredito,@ImportoDebito,@ImportoSospeso,@ImportoSospesoInAtto,@DataInserimento,@DataUltimaModifica,@CodiceRegione,@IdStruttura,@ChiaveARCAAnagraficaCodice,@ChiaveARCAAnagraficaProgressivo,@ChiaveARCAPrestazione

		SET @ReturnValue = @@ROWCOUNT
	END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[fnBuildCsharpClass]'
GO
/*
---------------------------------------------------------------------------------------------
Funzione preposta alla creazione di una classe C# partendo dalla struttura di una tabella SQL

Si avvale delle seguenti funzioni subordinate:
- dbo.fnGetTableDef
- dbo.fnFillSqlTemplateWithFieldsList
- dbo.fnCleanVariableName

N.B.:
Usare sempre la SELECT per invocare la presente funzione; una volta eseguita, copiare 
il contenuto della colonna 'EntityClass' e incollarla all'interno di una finestra di 
Visual Studio preposta al recepimento di una classe CS.

Per creare la classe principale in C# della Crud dinamica (DYNACRUD), invocare la funzione
"dbo.fnBuildCsharpClass"

Per creare la definizione degli elementi ASPX per un GridView, invocare la funzione 
"dbo.fnBuildCsharpGridViewASPX".

Per creare la definizione degli elementi CSS per un GridView, invocare la funzione 
invocare la funzione "dbo.fnBuildCsharpGridViewCSS".
		
Per creare il codice C# del CodeBehind di gestione degli eventi di un GridView, invocare la 
funzione "dbo.fnBuildCsharpGridViewCS".

---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------
Esempi di invocazione:

SELECT dbo.fnBuildCsharpClass('ENTITA_DETT') AS EntityClass
SELECT dbo.fnBuildCsharpClass('MEMO78') AS EntityClass
SELECT dbo.fnBuildCsharpClass('COMUNICAZIONE_PSR') AS EntityClass
---------------------------------------------------------------------------------------------
*/
CREATE FUNCTION	[dbo].[fnBuildCsharpClass](@TableName SYSNAME)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE 
			@CR char(1) = CHAR(13)
			,@CR2 char(2) = CHAR(13) + CHAR(13)
			,@TAB char(1) = CHAR(9)
			,@TAB2 char(2) = CHAR(9) + CHAR(9)
			,@TAB3 char(3) = CHAR(9) + CHAR(9) + CHAR(9)
			,@TAB4 char(4) = REPLICATE(CHAR(9),4)
			,@TAB5 char(5) = REPLICATE(CHAR(9),5)
			,@TAB6 char(6) = REPLICATE(CHAR(9),6)
			,@TAB7 char(7) = REPLICATE(CHAR(9),7)
			,@TAB8 char(8) = REPLICATE(CHAR(9),8)
			,@class varchar(MAX)
			,@className SYSNAME
			,@regionPrivate varchar(50)
			,@regionPublic varchar(50)
			,@regionConstructors varchar(50)
			,@connectionString varchar(2048)
			,@dynamicCRUDspName varchar(100) 
			,@regionPublicMethods varchar(50)
			,@endregion varchar(20)
			,@summary varchar(100)
			,@functionsAccessories varchar(MAX)

	--------------------------------------------------------------------------
	-- Valorizzazione delle costanti
	--------------------------------------------------------------------------
	SET @regionPrivate = @TAB2 + '#region Variabili private' + @CR
	SET @regionPublic = @CR + @TAB2 + '#region Proprietà pubbliche' + @CR
	SET @regionConstructors = @CR + @TAB2 + '#region Costruttori' + @CR
	SET @regionPublicMethods = @CR + @TAB2 + '#region Metodi pubblici' + @CR
	SET @endRegion = @TAB2 + '#endregion' + @CR
	SET @summary = @TAB2 + '/// <summary>' + @CR + @TAB2 + '///' + @CR + @TAB2 + '/// </summary>' + @CR
	
	SET @connectionString = '"Initial Catalog=Irpefweb;Data Source=SQLINPSSVIL06,2059;user id=IRPEFWEB;password=ops36mm89"; // commentare o rimpiazzare con eventuale stringa di connessione già presente'
	SET @dynamicCRUDspName = '"spSelInsUpdDel' + REPLACE(@tableName,'_','') + '"'
	SET @className = LOWER(@TableName)
	SET @class = ''
	--------------------------------------------------------------------------


	--------------------------------------------------------------------------
	-- PRELIEVO DELLE FUNZIONI (METODI) ACCESSORI DAL REPOSITORY DEI SORGENTI
	--------------------------------------------------------------------------
	SELECT	@functionsAccessories = COALESCE(@functionsAccessories,'') + @CR2 + Contents
	FROM	V_SourcesRepository
	WHERE	RepositoryDescription = 'Funzione C#'


	--------------------------------------------------------------------------
	-- Rimpiazzo di tutti i placeholders dei nomi di tabella (nome della classe) 
	-- con il nome della tabella corrente, in minuscolo
	--------------------------------------------------------------------------
	SELECT	@functionsAccessories = REPLACE(@functionsAccessories, '$className', @className)
	--------------------------------------------------------------------------


	--------------------------------------------------------------------------
	-- INTESTAZIONE DELLA CLASSE
	--------------------------------------------------------------------------
	SET @class +=	'using System;' + @CR + 
					'using System.Data; ' + @CR + 
					'using System.Data.SqlClient;' + @CR +
					'using System.Reflection;' + @CR + 
					'using System.Text.RegularExpressions;' + @CR2 + 

					'namespace ' + UPPER(@TableName) + '.Base' + @CR + 
					'{' + @CR + 
					REPLACE(@summary,@TAB2,@TAB) +
					@TAB + 'public class ' + @className + @CR + 
					@TAB + '{' + @CR

	--------------------------------------------------------------------------
	-- VARIABILI PRIVATE DELLA CLASSE
	--------------------------------------------------------------------------
	SET @class +=	@regionPrivate +
					@TAB2 + '// Le variabili private di classe terminanti col suffisso "_x" sono quelle corrispondenti alle colonne "nullabili" della tabella fisica.' + @CR + 
					dbo.fnFillSqlTemplateWithFieldsListOrdered(@TAB2 + 'private $# $^;' + @CR,@TableName,'cSharpPublicPropertyName') + @CR +
					@TAB2 + '// Variabili private "speciali" che non sono collegate in nessun modo ai campi fisici della tabella' + @CR + 
					@TAB2 + 'private String _connectionString__;' + @CR + 
					@TAB2 + 'private String _spName__;' + @CR +
					@endregion -- classe c# (Variabili private)

	--------------------------------------------------------------------------
	-- PROPRIETA' PUBBLICHE DELLA CLASSE
	--------------------------------------------------------------------------
	SET @class +=	@regionPublic + 
					dbo.fnFillSqlTemplateWithFieldsListOrdered(@summary + @TAB2 + 'public $# $@' + @CR + @TAB2 + '{' + @CR + @TAB3 + 'get { return $^; }' + @CR + @TAB3 + 'set { $^ = ($#)value; }' + @CR + @TAB2 +' }' + @CR2, @TableName, 'cSharpPublicPropertyName') + @CR +
					@TAB2 + '// Proprietà pubbliche "speciali" che non sono collegate in nessun modo ai campi fisici della tabella' + @CR + 
					@summary + @TAB2 + 'public String ConnectionString__' + @CR + @TAB2 + '{' + @CR + @TAB3 + 'get { return _connectionString__; }' + @CR + @TAB3 + 'set { _connectionString__ = (String)value; }' + @CR + @TAB2 +' }' + @CR2 +
					@summary + @TAB2 + 'public String SpName__' + @CR + @TAB2 + '{' + @CR + @TAB3 + 'get { return _spName__; }' + @CR + @TAB3 + 'set { _spName__ = (String)value; }' + @CR + @TAB2 +' }' + @CR +
					@endregion -- classe c# (Proprietà pubbliche)

	--------------------------------------------------------------------------
	-- COSTRUTTORI
	--------------------------------------------------------------------------
	SET @class +=	@regionConstructors + 
					@summary +
					@TAB2 + 'public entita_dett()' + @CR + 
					@TAB2 + '{' + @CR + 
					@TAB3 + 'PropertyInfo[]' + @CR + 
					@TAB4 + '_properties = null;' + @CR2 + 

					@TAB3 + '_properties = typeof(entita_dett).GetProperties();' + @CR2 + 

					@TAB3 + 'foreach (PropertyInfo property in _properties)' + @CR + 
					@TAB3 + '{' + @CR + 
					@TAB4 + 'property.SetValue(this, null, null);' + @CR + 
					@TAB3 + '}' + @CR + 
					@TAB2 + '}' + @CR2 +
					@summary +
					@TAB2 + 'public entita_dett(Boolean pForceDefaultValue)' + @CR + 
					@TAB2 + '{' + @CR + 
					@TAB2 + 'if(pForceDefaultValue)' + @CR + 
					@TAB2 + '{' + @CR + 
					dbo.fnFillSqlTemplateWithFieldsListOrdered
					(
						@TAB3 + '$^ = ($#)NullOrValue("$@",true);' + @CR
						,@TableName,'cSharpPublicPropertyName'
					) +
					@TAB2 + '}' + @CR + 
					@TAB2 + '}' + @CR + 
					@endregion -- classe c# (Proprietà pubbliche)

	--------------------------------------------------------------------------
	-- METODI PUBBLICI
	--------------------------------------------------------------------------
	SET @class +=	@regionPublicMethods + 
					@TAB2 + '/// <summary>' + @CR +
					@TAB2 + '/// Funzione principale per le operazioni di SELECT, INSERT, UPDATE e DELETE sulla tabella fisica' + @CR +
					@TAB2 + '/// alla quale la presente classe fa riferimento' + @CR +
					@TAB2 + '/// </summary>' + @CR +
					@TAB2 + '/// <param name="pOperazione">Operazione da effettuare: S = SELECT, I = INSERT, U = UPDATE, D = DELETE</param>' + @CR +
					@TAB2 + '/// <param name="pUpdateWhereCondition">Stringa contenente il criterio da utilizzare *ESCLUSIVAMENTE* per l''operazione di UPDATE</param>' + @CR +
					@TAB2 + '/// <param name="pForceDefaultValue">Booleano che specifica se forzare/specificare (TRUE) i valori di default per le proprietà non valorizzate, oppure (FALSE) se ignorarli</param>' + @CR +
					@TAB2 + '/// <param name="pReturnValue">Int, il numero delle righe che sono state interessate dall''operazione (0 se nulla è cambiato sul DB)</param>' + @CR +
					@TAB2 + '/// <returns>DataTable, riempito *ESCLUSIVAMENTE* per l''operazione di SELECT, NULL altrimenti</returns>' + @CR +
					@TAB2 + 'public DataTable SelInsUpdDel(String pOperazione, String pUpdateWhereCondition, Boolean pForceDefaultValue, out int pReturnValue)' + @CR + 
					@TAB2 + '{' + @CR + 
					@TAB3 + 'DataTable retVal = new DataTable();' + @CR +
					@TAB3 + 'SqlConnection conn = new SqlConnection(); // commentare o rimpiazzare con eventuale oggetto connessione già presente' + @CR + 
					@TAB3 + 'SqlDataAdapter da = new SqlDataAdapter();' + @CR2 + 
					@TAB3 + 'String command = String.Empty;' + @CR +

					@TAB3 + 'command = (!String.IsNullOrEmpty(_spName__)) ? _spName__ : ' + @dynamicCRUDspName + ';' + @CR + 
					@TAB3 + 'conn.ConnectionString = (!String.IsNullOrEmpty(_connectionString__)) ? _connectionString__ : ' + @connectionString + @CR2 + 
					@TAB3 + 'SqlCommand cmd = new SqlCommand(command); // rimpiazzare eventualmente con altro nome di stored procedure di CRUD DINAMICA' + @CR + 
					@TAB3 + 'cmd.Connection = conn;' + @CR + 
					@TAB3 + 'cmd.CommandType = CommandType.StoredProcedure;' + @CR2 + 

					dbo.fnFillSqlTemplateWithFieldsListOrdered
					(
						@TAB3 + 'SqlParameter psql$@ = new SqlParameter("$V", $Q);' + @CR
						,@TableName,'cSharpPublicPropertyName'
					) + @CR +
					dbo.fnFillSqlTemplateWithFieldsListOrdered
					(
						@TAB4 + 'psql$@.Size = $S;' + @CR + 
						@TAB4 + 'psql$@.Precision = $P;' + @CR + 
						@TAB4 + 'psql$@.Scale = $C;' + @CR +
						@TAB4 + 'psql$@.Value = NullOrValue("$@", pForceDefaultValue);' + @CR
						,@TableName,'cSharpPublicPropertyName'
					) + @CR +
					dbo.fnFillSqlTemplateWithFieldsListOrdered
					(
						@TAB3 + 'cmd.Parameters.Add(psql$@);' + @CR
						,@TableName,'cSharpPublicPropertyName'
					) + @CR +
					@TAB3 + 'SqlParameter psqlOP = new SqlParameter("@OP", SqlDbType.Char);' + @CR + 
					@TAB3 + 'psqlOP.Size = 1;' + @CR + 
					@TAB3 + 'psqlOP.Precision = 0;' + @CR + 
					@TAB3 + 'psqlOP.Scale = 0;' + @CR + 
					@TAB3 + 'psqlOP.Value = pOperazione;' + @CR + 
					@TAB3 + 'cmd.Parameters.Add(psqlOP);' + @CR + 
					@TAB3 + 'SqlParameter psqlUpdateWhereCondition = new SqlParameter("@UpdateWhereCondition", SqlDbType.VarChar);' + @CR + 
					@TAB3 + 'psqlUpdateWhereCondition.Size = 8000;' + @CR + 
					@TAB3 + 'psqlUpdateWhereCondition.Precision = 0;' + @CR + 
					@TAB3 + 'psqlUpdateWhereCondition.Scale = 0;' + @CR + 
					@TAB3 + 'psqlUpdateWhereCondition.Value = pUpdateWhereCondition;' + @CR + 
					@TAB3 + 'cmd.Parameters.Add(psqlUpdateWhereCondition);' + @CR + 
					@TAB3 + 'SqlParameter psqlReturnValue = new SqlParameter("@ReturnValue", SqlDbType.Int);' + @CR + 
					@TAB3 + 'psqlReturnValue.Size = 10;' + @CR + 
					@TAB3 + 'psqlReturnValue.Precision = 0;' + @CR + 
					@TAB3 + 'psqlReturnValue.Scale = 0;' + @CR + 
					@TAB3 + 'psqlReturnValue.Direction = ParameterDirection.Output;' + @CR + 
					@TAB3 + 'cmd.Parameters.Add(psqlReturnValue);' + @CR2 +

					@TAB3 + '// Per debug' + @CR + 
					@TAB3 + '//foreach (SqlParameter par in cmd.Parameters)' + @CR + 
					@TAB3 + '//{' + @CR + 
					@TAB3 + '//    parValue = (par.Value == null) ? "null" : par.Value.ToString();' + @CR + 
					@TAB3 + '//    Console.WriteLine(String.Format("{0} = {1}", par.ParameterName, parValue));' + @CR + 
					@TAB3 + '//}' + @CR2 +

					@TAB3 + 'conn.Open();' + @CR2 + 

					@TAB3 + 'if(pOperazione.ToUpper() != "S")' + @CR +
					@TAB3 + '{' + @CR +
					@TAB4 + 'cmd.ExecuteNonQuery();' + @CR + 
					@TAB3 + '}' + @CR +
					@TAB3 + 'else' + @CR +
					@TAB3 + '{' + @CR +
					@TAB4 + 'retVal.Load(cmd.ExecuteReader());' + @CR +
					@TAB3 + '}' + @CR +
					@TAB3 + 'conn.Close();' + @CR2 + 

					@TAB3 + 'pReturnValue = (int)psqlReturnValue.Value;' + @CR2 + 

					@TAB3 + 'return retVal;' + @CR +
					@TAB2 + '}'

	--------------------------------------------------------------------------
	-- AGGIUNTA DELLE FUNZIONI (METODI) ACCESSORI 
	-- PRELEVATI DAL REPOSITORY DEI SORGENTI
	--------------------------------------------------------------------------
	SET @class +=	@functionsAccessories + @CR + 
					@endregion -- classe c# (Metodi pubblici)

	SET @class +=	@TAB + '}' + @CR + '}'


	RETURN @class
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[fnGetCsharpSqlMapperClass]'
GO
/*
----------------------------------------------------
-- FUNZIONE PREPOSTA ALLA CREAZIONE DELLA CLASSE C#
-- STATICA 'SqlMapper' LA QUALE PROVVEDERE A FORNIRE
-- I METODI PER LA CONVERSIONE DA SqlDbType A Type
-- E VICEVERSA
--
----------------------------------------------------
--
-- Fabrizio Ricciarelli per Eustema Spa
-- 16/11/2015
--
-- Esempi di invocazione:
--
PRINT (dbo.fnGetCSharpSqlMapperClass())
*/
CREATE FUNCTION dbo.fnGetCSharpSqlMapperClass()
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @reTVal varchar(MAX)
	SET @retVal = 
	'
public static class SqlMapper
{
    private static readonly Dictionary<Type, DbType> TypeToDbType = new Dictionary<Type, DbType>
	{
		{typeof (byte), DbType.Byte},
		{typeof (sbyte), DbType.SByte},
		{typeof (short), DbType.Int16},
		{typeof (ushort), DbType.UInt16},
		{typeof (int), DbType.Int32},
		{typeof (uint), DbType.UInt32},
		{typeof (long), DbType.Int64},
		{typeof (ulong), DbType.UInt64},
		{typeof (float), DbType.Single},
		{typeof (double), DbType.Double},
		{typeof (decimal), DbType.Decimal},
		{typeof (bool), DbType.Boolean},
		{typeof (string), DbType.String},
		{typeof (char), DbType.StringFixedLength},
		{typeof (Guid), DbType.Guid},
		{typeof (DateTime), DbType.DateTime},
		{typeof (DateTimeOffset), DbType.DateTimeOffset},
		{typeof (byte[]), DbType.Binary},
		{typeof (byte?), DbType.Byte},
		{typeof (sbyte?), DbType.SByte},
		{typeof (short?), DbType.Int16},
		{typeof (ushort?), DbType.UInt16},
		{typeof (int?), DbType.Int32},
		{typeof (uint?), DbType.UInt32},
		{typeof (long?), DbType.Int64},
		{typeof (ulong?), DbType.UInt64},
		{typeof (float?), DbType.Single},
		{typeof (double?), DbType.Double},
		{typeof (decimal?), DbType.Decimal},
		{typeof (bool?), DbType.Boolean},
		{typeof (char?), DbType.StringFixedLength},
		{typeof (Guid?), DbType.Guid},
		{typeof (DateTime?), DbType.DateTime},
		{typeof (DateTimeOffset?), DbType.DateTimeOffset},
		{typeof (System.Data.Linq.Binary), DbType.Binary}
	};

    private static readonly Dictionary<SqlDbType, Type> SqlDbTypeToType = new Dictionary<SqlDbType, Type>
    {
        {SqlDbType.BigInt, typeof (long)},
        {SqlDbType.Binary, typeof (byte[])},
        {SqlDbType.Image, typeof (byte[])},
        {SqlDbType.Timestamp, typeof (byte[])},
        {SqlDbType.VarBinary, typeof (byte[])},
        {SqlDbType.Bit, typeof (bool)},
        {SqlDbType.Char, typeof (string)},
        {SqlDbType.NChar, typeof (string)},
        {SqlDbType.NText, typeof (string)},
        {SqlDbType.NVarChar, typeof (string)},
        {SqlDbType.Text, typeof (string)},
        {SqlDbType.VarChar, typeof (string)},
        {SqlDbType.Xml, typeof (string)},
        {SqlDbType.DateTime, typeof (DateTime)},
        {SqlDbType.SmallDateTime, typeof (DateTime)},
        {SqlDbType.Date, typeof (DateTime)},
        {SqlDbType.Time, typeof (DateTime)},
        {SqlDbType.DateTime2, typeof (DateTime)},
        {SqlDbType.Decimal, typeof (decimal)},
        {SqlDbType.Money, typeof (decimal)},
        {SqlDbType.SmallMoney, typeof (decimal)},
        {SqlDbType.Float, typeof (double)},
        {SqlDbType.Int, typeof (int)},
        {SqlDbType.Real, typeof (float)},
        {SqlDbType.UniqueIdentifier, typeof (Guid)},
        {SqlDbType.SmallInt, typeof (short)},
        {SqlDbType.TinyInt, typeof (byte)},
        {SqlDbType.Variant, typeof (object)},
        {SqlDbType.Udt, typeof (object)},
        {SqlDbType.Structured, typeof (DataTable)},
        {SqlDbType.DateTimeOffset, typeof (DateTimeOffset)}
    };

    private static readonly Dictionary<SqlDbType, Type> SqlDbTypeToNullableType = new Dictionary<SqlDbType, Type>
    {
        {SqlDbType.BigInt, typeof (long?)},
        {SqlDbType.Binary, typeof (byte[])},
        {SqlDbType.Image, typeof (byte[])},
        {SqlDbType.Timestamp, typeof (byte[])},
        {SqlDbType.VarBinary, typeof (byte[])},
        {SqlDbType.Bit, typeof (bool?)},
        {SqlDbType.Char, typeof (string)},
        {SqlDbType.NChar, typeof (string)},
        {SqlDbType.NText, typeof (string)},
        {SqlDbType.NVarChar, typeof (string)},
        {SqlDbType.Text, typeof (string)},
        {SqlDbType.VarChar, typeof (string)},
        {SqlDbType.Xml, typeof (string)},
        {SqlDbType.DateTime, typeof (DateTime?)},
        {SqlDbType.SmallDateTime, typeof (DateTime?)},
        {SqlDbType.Date, typeof (DateTime?)},
        {SqlDbType.Time, typeof (DateTime?)},
        {SqlDbType.DateTime2, typeof (DateTime?)},
        {SqlDbType.Decimal, typeof (decimal?)},
        {SqlDbType.Money, typeof (decimal?)},
        {SqlDbType.SmallMoney, typeof (decimal?)},
        {SqlDbType.Float, typeof (double?)},
        {SqlDbType.Int, typeof (int?)},
        {SqlDbType.Real, typeof (float?)},
        {SqlDbType.UniqueIdentifier, typeof (Guid?)},
        {SqlDbType.SmallInt, typeof (short?)},
        {SqlDbType.TinyInt, typeof (byte?)},
        {SqlDbType.Variant, typeof (object)},
        {SqlDbType.Udt, typeof (object)},
        {SqlDbType.Structured, typeof (DataTable)},
        {SqlDbType.DateTimeOffset, typeof (DateTimeOffset)}
    };

    private static readonly Dictionary<DbType, Type> DbTypeMapToType = new Dictionary<DbType, Type>
    {
        {DbType.Byte, typeof (byte)},
        {DbType.SByte, typeof (sbyte)},
        {DbType.Int16, typeof (short)},
        {DbType.UInt16, typeof (ushort)},
        {DbType.Int32, typeof (int)},
        {DbType.UInt32, typeof (uint)},
        {DbType.Int64, typeof (long)},
        {DbType.UInt64, typeof (ulong)},
        {DbType.Single, typeof (float)},
        {DbType.Double, typeof (double)},
        {DbType.Decimal, typeof (decimal)},
        {DbType.Boolean, typeof (bool)},
        {DbType.String, typeof (string)},
        {DbType.StringFixedLength, typeof (char)},
        {DbType.Guid, typeof (Guid)},
        {DbType.DateTime, typeof (DateTime)},
        {DbType.DateTimeOffset, typeof (DateTimeOffset)},
        {DbType.Binary, typeof (byte[])}
    };

    private static readonly Dictionary<DbType, Type> DbTypeMapToNullableType = new Dictionary<DbType, Type>
    {
        {DbType.Byte, typeof (byte?)},
        {DbType.SByte, typeof (sbyte?)},
        {DbType.Int16, typeof (short?)},
        {DbType.UInt16, typeof (ushort?)},
        {DbType.Int32, typeof (int?)},
        {DbType.UInt32, typeof (uint?)},
        {DbType.Int64, typeof (long?)},
        {DbType.UInt64, typeof (ulong?)},
        {DbType.Single, typeof (float?)},
        {DbType.Double, typeof (double?)},
        {DbType.Decimal, typeof (decimal?)},
        {DbType.Boolean, typeof (bool?)},
        {DbType.StringFixedLength, typeof (char?)},
        {DbType.Guid, typeof (Guid?)},
        {DbType.DateTime, typeof (DateTime?)},
        {DbType.DateTimeOffset, typeof (DateTimeOffset?)},
        {DbType.Binary, typeof(byte[])}
    };
    
    public static DbType ToDbType(this Type type)
    {
        DbType dbType;
        if (TypeToDbType.TryGetValue(type, out dbType)) return dbType;
        throw new ArgumentOutOfRangeException("type", type, "Cannot map the Type to DbType");
    }

    public static Type ToClrType(this DbType dbType)
    {
        Type type;
        if (DbTypeMapToType.TryGetValue(dbType, out type)) return type;
        throw new ArgumentOutOfRangeException("dbType", dbType, "Cannot map the DbType to Type");
    }

    public static Type ToNullableClrType(this DbType dbType)
    {
        Type type;
        if (DbTypeMapToNullableType.TryGetValue(dbType, out type)) return type;
        throw new ArgumentOutOfRangeException("dbType", dbType, "Cannot map the DbType to Nullable Type");
    }

    public static Type ToClrType(this SqlDbType sqlDbType)
    {
        Type type;
        if (SqlDbTypeToType.TryGetValue(sqlDbType, out type)) return type;
        throw new ArgumentOutOfRangeException("sqlDbType", sqlDbType, "Cannot map the SqlDbType to Type");
    }

    public static Type ToNullableClrType(this SqlDbType sqlDbType)
    {
        Type type;
        if (SqlDbTypeToNullableType.TryGetValue(sqlDbType, out type)) return type;
        throw new ArgumentOutOfRangeException("sqlDbType", sqlDbType, "Cannot map the SqlDbType to Nullable Type");
    }
}
	'
	RETURN @retVal
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[fnGetSpDef]'
GO
/*
--------------------------------------------
-- Funzione preposta alla rappresentazione
-- della struttura di una SP SQL
--------------------------------------------
-- Fabrizio Ricciarelli per Eustema SpA
-- 13/11/2015
--
-- Esempi di invocazione:
SELECT * FROM dbo.fnGetSpDef('dbo.sp_DEL_ENTITY_byCodiceFlusso')
SELECT * FROM dbo.fnGetSpDef('sp_mappaNuovoCodiceSAP')
SELECT * FROM dbo.fnGetSpDef('spF24EpAssFiscAddizionaleRegionalePerCodiceTributo')
*/
CREATE FUNCTION [dbo].[fnGetSpDef](@spName SYSNAME = NULL)
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
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[sp_RandomString]'
GO
/*
----------------------------------------------------
-- STORED PROCEDURE CHE RITORNA UNA STRINGA CASUALE
-- DI LUNGHEZZA SPECIFICA
----------------------------------------------------
--
-- Fabrizio Ricciarelli per Eustema Spa
-- 16/11/2015
--
-- Esempi di invocazione:
--
SET NOCOUNT ON;
DECLARE @var TABLE(rndstr varchar(MAX))
DECLARE @rndstr varchar(max)
INSERT @var EXEC sp_RandomString 128
SELECT @rndstr = rndstr FROM @var
PRINT(@rndstr)
SET NOCOUNT OFF;

EXEC sp_RandomString 128
EXEC sp_RandomString 255
EXEC sp_RandomString 1023
EXEC sp_RandomString 8000 -- IL MASSIMO RAPPRESENTABILE ALL'INTERNO DEL CLIENT Microsoft Sql Management Studio
-- 
*/
CREATE PROC	dbo.sp_RandomString 
			@maxLen int 
AS
SELECT LEFT(REPLACE(REPLICATE(CONVERT(varchar(255), NEWID()),10),'-',''),@maxLen) AS RNDSTR

GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
IF EXISTS (SELECT * FROM #tmpErrors) ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT>0 BEGIN
PRINT 'The database update succeeded'
COMMIT TRANSACTION
END
ELSE PRINT 'The database update failed'
GO
DROP TABLE #tmpErrors
GO
