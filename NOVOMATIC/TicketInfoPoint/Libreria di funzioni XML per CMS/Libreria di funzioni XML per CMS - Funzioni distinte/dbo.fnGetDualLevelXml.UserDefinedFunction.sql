USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetDualLevelXml]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetDualLevelXml
----------------------------------------

FUNZIONE CHE RITORNA UNA STRINGA, COMPOSTA DINAMICAMENTE, IN GRADO DI CREARE LA CORRETTA SEQUENZA DI STATEMENTS PER LA GENERAZIONE DI CODICE 
XML BI-LIVELLO CON UN NUMERO PRESSOCHÉ INFINITO DI AGGREGAZIONI SUL SECONDO LIVELLO

-- ESEMPI DI INVOCAZIONE
H
SELECT dbo.fnGetDualLevelXml('[Intranetinps_Lavoro].[dbo].[Contenuto_News]', '[IntranetInps].[dbo].[KeyWord_Link]/Contenuto_News, VX_GRUPPI/Gruppo', 'Id_Link', 24577, 0)
SELECT dbo.fnGetDualLevelXml('Link', '[IntranetInps].[dbo].[KeyWord_Link], VX_GRUPPI', 'Id_Link', 24577, 1)

------------------------------
DECLARE @SQL varchar(MAX)

-- RITORNO DI UN VALORE XML CON TAGS '<NomeTabella><element>...</element><element>...</element><NomeTabella>' SUI RAGGRUPPAMENTI DI 2° LIVELLO
SELECT @SQL = dbo.fnGetDualLevelXml('Link', '[IntranetInps].[dbo].[KeyWord_Link]/Link, VX_Gruppi/Gruppo', 'Id_Link', 24577, 1)
EXEC(@SQL)

-- RITORNO DI UN VALORE XML CON TAGS '<NomeTabellaS><NomeTabella>...</NomeTabella><NomeTabella>...</NomeTabella></NomeTabellaS>' SUI RAGGRUPPAMENTI DI 2° LIVELLO
SELECT @SQL = dbo.fnGetDualLevelXml('Link', '[IntranetInps].[dbo].[KeyWord_Link], Autorizzazioni_Nt', 'Id_Link', 24577, 0)
EXEC(@SQL)
------------------------------
*/
CREATE FUNCTION	[dbo].[fnGetDualLevelXml]
				(
					@masterTableName varchar(128) = NULL
					,@commaSep2ndLevelTableNames varchar(MAX) = NULL
					,@commonIDfieldName varchar(128) = NULL
					,@commonIDfieldValue int, @useElementTag BIT = NULL
				)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE	
			@RETVAL varchar(MAX) = 'SELECT CAST(( SELECT	M.*' + CHAR(13)
			,@purgedMasterTableName varchar(MAX)
			,@forXmlStatement varchar(MAX)
			,@criteria varchar(MAX)

	IF ISNULL(@masterTableName,'') != ''
		BEGIN
			SET @purgedMasterTableName = dbo.fnpurge(@masterTableName)
			SET @useElementTag = ISNULL(@useElementTag,0)
			SET @criteria = ISNULL(@criteria,'')
			SELECT	@criteria = 
					CASE
						WHEN ISNULL(@commonIDFieldName,'') != ''
						AND  ISNULL(@commonIDFieldValue,0) > 0
						THEN 'WHERE	' + @commonIDfieldName + ' = ' + CAST(@commonIDfieldValue AS varchar(20))
						ELSE ''
					END

			IF ISNULL(@commaSep2ndLevelTableNames,'') != ''
				BEGIN
					DECLARE @tablesAndAliases TABLE(tableName varchar(MAX), alias varchar(MAX))
					INSERT	@tablesAndAliases(tableName, alias)
					SELECT
							tableName =
								CASE
									WHEN item LIKE '%/%'	
									THEN dbo.fnLeftPart(item,'/')
									--THEN SUBSTRING(item,1,CHARINDEX('/',item) - 1)
									ELSE item
								END
							,alias =
								CASE
									WHEN item LIKE '%/%'
									THEN dbo.fnRightPart(item,'/')
									--THEN SUBSTRING(item,CHARINDEX('/',item) + 1, LEN(item)-CHARINDEX(item,'/'))   
									ELSE NULL
								END
					FROM	dbo.fnSplit(@commaSep2ndLevelTableNames,',')

					SELECT	@RETVAL = COALESCE(@RETVAL, '') + dbo.fnGetMonoLevelXml(tableName, alias, @commonIDfieldName, @commonIDfieldValue, @useElementTag)
					FROM	@tablesAndAliases


				END

			SET @RETVAL += 
			'
			FROM	' + @masterTableName + ' AS M WITH(NOLOCK) ' +
			@criteria + CHAR(13) + 
			'FOR XML	PATH(''Xml' + @purgedMasterTableName + ''')) AS XML) AS Xml' + @purgedMasterTableName
		END

	RETURN @RETVAL
END
GO
