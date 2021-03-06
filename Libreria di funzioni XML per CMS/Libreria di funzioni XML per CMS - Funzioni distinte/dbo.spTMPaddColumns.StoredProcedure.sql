USE [Intranetinps_Richieste]
GO
/****** Object:  StoredProcedure [dbo].[spTMPaddColumns]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.spTMPaddColumns - SISTEMA TMP
----------------------------------------

NELL'AMBITO DEL MICROSISTEMA DI GESTIONE DI DATI TABELLARI TEMPORANEI (SISTEMA "TMP"), QUESTA STORED PROCEDURE E' PREPOSTA ALL'AGGIUNTA
IN TEMPO REALE DI QUALUNQUE TIPO DI COLONNA SI RENDA NECESSARIO ALLA TABELLA TEMPORANEA PREVENTIVAMENTE CREATA DALLA STORED PROCEDURE "spTMPcreate"

IL PARAMETRO IN INGRESSO "@CSVColNamesAndTypes" PREVEDE CHE VI SI PASSI UN ELENCO, SEPARATO DA VIRGOLE, DI NOMI DI COLONNA E I LORO TIPI DI DATI
ASSOCIATI: TRA IL NOME DELLA COLONNA DA AGGIUNGERE ALLA TABELLA TEMPORANEA E IL TIPO DI DATO CHE QUALIFICA LA COLONNA STESSA, E' NECESSARIO INTERPORRE UNO SPAZIO,
COME DA ESEMPI DI SEGUITO RIPORTATI

-- ESEMPI DI INVOCAZIONE


-- CREAZIONE TABELLA TEMPORANEA IN MEMORIA
EXEC spTMPcreate

-- AGGIUNTA DELLE COLONNE A RUN-TIME
EXEC dbo.spTMPaddColumns 'added nvarchar(max), added2 varchar(20), added3 datetime'

-- POPOLAMENTO DELLE NUOVE COLONNE
INSERT ##__tmpTable(added, added2, added3)
VALUES
		('NEW','PIPPO', GETDATE())
		,('OLD', 'PLUTO', NULL)

-- RAPPRESENTAZIONE DEI CONTENUTI APPENA INSERITI
EXEC spTMPGetAll -- (OPPURE SELECT * FROM ##__tmpTable)

-- DISTRUZIONE DELLA TABELLA TEMPORANEA
EXEC spTMPdestroy

-----------------------
PROCEDURE E FUNZIONI
DALLE QUALI DIPENDE LA
PRESENTE SP
-----------------------
ALTER PROC	dbo.spTMPdestroy
AS
IF	EXISTS
	(
		SELECT	* 
		FROM	tempdb..sysobjects 
		where	name LIKE '%##__tmpTable%' 
		AND		[type] in (N'U')
	)
	BEGIN
		DROP TABLE ##__tmpTable
	END
GO
--------------------------
ALTER PROC dbo.spTMPcreate
AS
EXEC spTMPdestroy
CREATE TABLE ##__tmpTable(__id int IDENTITY(1,1) PRIMARY KEY CLUSTERED NOT NULL)
GO
--------------------------
ALTER FUNCTION [dbo].[fnRightPart](@str varchar(MAX) = NULL, @what varchar(MAX))
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @RETVAL varchar(MAX) = NULL

	SELECT	@RETVAL =
			CASE
				WHEN @str IS NOT NULL
				AND @what IS NOT NULL
				AND dbo.fnCountStringOccurrences(@str,@what) > 0
				THEN SUBSTRING(@str, CHARINDEX(@what,@str) + LEN(@what), LEN(@str)-LEN(CHARINDEX(@what,@str)- 1))
				ELSE @str
			END

	RETURN @RETVAL
END
--------------------------
ALTER FUNCTION [dbo].[fnLeftPart](@str varchar(MAX) = NULL, @what varchar(MAX))
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @RETVAL varchar(MAX) = NULL

	SELECT	@RETVAL =
			CASE
				WHEN @str IS NOT NULL
				AND @what IS NOT NULL
				AND dbo.fnCountStringOccurrences(@str,@what) > 0
				THEN SUBSTRING(@str, 1, CHARINDEX(@what,@str) - 1)
				ELSE @str
			END

	RETURN @RETVAL
END
--------------------------
ALTER FUNCTION [dbo].[fnSplit]
(
   @List       NVARCHAR(MAX),
   @Delimiter  NVARCHAR(255) = NULL
)
RETURNS TABLE
WITH SCHEMABINDING
AS
   RETURN 
   (  
      SELECT Item = LTRIM(RTRIM(y.i.value('(./text())[1]', 'nvarchar(4000)')))
      FROM 
      ( 
        SELECT x = CONVERT(XML, '<i>' 
          + REPLACE(@List, ISNULL(@Delimiter,','), '</i><i>') 
          + '</i>').query('.')
      ) AS a CROSS APPLY x.nodes('i') AS y(i)
   );
--------------------------
ALTER PROC dbo.spTMPGetAll
AS
IF	EXISTS
	(
		SELECT	* 
		FROM	tempdb..sysobjects 
		where	name LIKE '%##__tmpTable%' 
		AND		[type] in (N'U')
	)
	BEGIN
		SELECT * FROM ##__tmpTable
	END
ELSE
	BEGIN
		PRINT('TABELLA TEMPORANEA INESISTENTE, CREARNE UNA TRAMITE LA SP "spTMPcreate" E AGGIUNGERVI COLONNE TRAMITE LA SP "spTMPaddColumns @CSVColNamesAndTypes", QUINDI POPOLARLA CON I DATI DESIDERATI E RIESEGUIRE LA PRESENTE SP.')
	END
*/
CREATE PROC [dbo].[spTMPaddColumns] @CSVColNamesAndTypes varchar(MAX) = NULL
AS
SET NOCOUNT ON;

IF ISNULL(@CSVColNamesAndTypes,'') != ''
AND EXISTS
	(
		SELECT	* 
		FROM	tempdb..sysobjects 
		where	name LIKE '%##__tmpTable%' 
		AND		[type] in (N'U')
	)
	BEGIN

		DECLARE	@tableStructure TABLE(columnName sysname, columnDataType varchar(MAX))
		DECLARE @csvColAndTypes TABLE(colAndType varchar(MAX) NOT NULL, columnName sysname NULL, columnDataType varchar(MAX) NULL)
		DECLARE @csvColumns TABLE(columnName sysname, columnDataType varchar(MAX))

		DECLARE 
				@SQL nvarchar(MAX)
				,@fieldsList varchar(MAX)

		INSERT	@tableStructure(columnName, columnDataType)
		SELECT	
				fieldName AS columnName
				,dbo.fnTrimCommas(fieldWithLength)
		FROM	fnGetColumnDataType('##__tmpTable',NULL) 

		INSERT	@csvColAndTypes(colAndType)
		SELECT  item AS colAndType 
		FROM	dbo.fnSplit(@CSVColNamesAndTypes,',') 

		UPDATE	@csvColAndTypes
		SET		
				columnName = LTRIM(RTRIM(dbo.fnLeftPart(colAndType,' ')))
				,columnDataType = LTRIM(RTRIM(dbo.fnRightPart(colAndType,' ')))
		WHERE	columnName IS NULL

		INSERT	@csvColumns(columnName, columnDataType)
		SELECT  
				CSV.columnName
				,CSV.columnDataType
		FROM	@csvColAndTypes CSV
				LEFT JOIN
				@tableStructure TS
				ON CSV.columnName = TS.columnName
		WHERE	TS.columnName IS NULL

		SELECT	@fieldsList = COALESCE(@fieldsList,'') + ',' + columnName + ' ' + columnDataType + CHAR(13)
		FROM	@csvColumns
				
		SELECT @SQL = N'ALTER TABLE ##__tmpTable ADD ' + CHAR(13) + dbo.fnTrimCommas(@fieldsList) + '; '
		--PRINT(@SQL)
		EXEC(@sql)

	END

GO
