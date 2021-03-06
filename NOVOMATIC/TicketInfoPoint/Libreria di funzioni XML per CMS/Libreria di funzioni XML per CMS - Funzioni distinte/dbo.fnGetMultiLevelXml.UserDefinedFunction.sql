USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetMultiLevelXml]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetMultiLevelXml
----------------------------------------

FUNZIONE CHE RITORNA UNA STRINGA, COMPOSTA DINAMICAMENTE, IN GRADO DI CREARE LA CORRETTA SEQUENZA DI STATEMENTS PER LA GENERAZIONE 
DI CODICE XML BI-LIVELLO CON SOLE DUE AGGREGAZIONI SUL SECONDO LIVELLO

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnGetMultiLevelXml('Link', '[IntranetInps].[dbo].[KeyWord_Link]', 'Autorizzazioni_NT', 'Id_Link', 24577, 0)
SELECT dbo.fnGetMultiLevelXml('Link', '[IntranetInps].[dbo].[KeyWord_Link]', 'VX_GRUPPI', 'Id_Link', 24577, 1)

------------------------------
DECLARE @SQL varchar(MAX)

-- RITORNO DI UN VALORE XML CON TAGS '<NomeTabella><element>...</element><element>...</element><NomeTabella>' SUI RAGGRUPPAMENTI DI 2° LIVELLO
SELECT @SQL = dbo.fnGetMultiLevelXml('Link', '[IntranetInps].[dbo].[KeyWord_Link]', 'VX_Gruppi', 'Id_Link', 24577, 1)
EXEC(@SQL)

-- RITORNO DI UN VALORE XML CON TAGS '<NomeTabellaS><NomeTabella>...</NomeTabella><NomeTabella>...</NomeTabella></NomeTabellaS>' SUI RAGGRUPPAMENTI DI 2° LIVELLO
SELECT @SQL = dbo.fnGetMultiLevelXml('Link', '[IntranetInps].[dbo].[KeyWord_Link]', 'Autorizzazioni_Nt', 'Id_Link', 24577, 0)
EXEC(@SQL)
------------------------------
*/
CREATE FUNCTION [dbo].[fnGetMultiLevelXml](@masterTableName varchar(128) = NULL, @level1TableName varchar(128) = NULL, @level2TableName varchar(128) = NULL, @commonIDfieldName varchar(128) = NULL, @commonIDfieldValue int, @useElementTag BIT = NULL)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE	
			@RETVAL varchar(MAX) = 'SELECT CAST(( SELECT	M.*' + CHAR(13)
			,@purgedMasterTableName varchar(MAX)
			,@purgedLevel1TableName varchar(MAX)
			,@purgedLevel2TableName varchar(MAX)
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

			IF ISNULL(@level1TableName,'') != ''
				BEGIN
					SET @purgedLevel1TableName = REPLACE(dbo.fnpurge(@level1TableName),'VX_','')
					SET @forXmlStatement =
						CASE @useElementTag
							WHEN 1
							THEN 'FOR XML	PATH(''element''), ROOT(''' + REPLACE(@purgedLevel1TableName,'VX_','') + '''), TYPE'
							ELSE 'FOR XML	PATH(''' + @purgedLevel1TableName + '''), ROOT(''' + @purgedLevel1TableName + 's''), TYPE'
						END
					
					SET @RETVAL += 
					',
					 (
						SELECT	' + CHAR(13) + 
						dbo.fnGetTableFields(@level1TableName) + '
						FROM	' + @level1TableName + ' WITH(NOLOCK) ' +
						@criteria + CHAR(13) + 
						@forXmlStatement + '
					 )
					'
				END
			IF ISNULL(@level2TableName,'') != ''
				BEGIN
					SET @purgedLevel2TableName = REPLACE(dbo.fnpurge(@level2TableName),'VX_','')
					SET @forXmlStatement =
						CASE @useElementTag
							WHEN 1
							THEN 'FOR XML	PATH(''element''), ROOT(''' + REPLACE(@purgedLevel2TableName,'VX_','') + '''), TYPE'
							ELSE 'FOR XML	PATH(''' + @purgedLevel2TableName + '''), ROOT(''' + @purgedLevel2TableName + 's''), TYPE'
						END

					SET @RETVAL += 
					',
					 (
						SELECT	' + CHAR(13) + 
						dbo.fnGetTableFields(@level2TableName) + '
						FROM	' + @level2TableName + ' WITH(NOLOCK) ' +
						@criteria + CHAR(13) + 
						@forXmlStatement + '
					 )
					'
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
