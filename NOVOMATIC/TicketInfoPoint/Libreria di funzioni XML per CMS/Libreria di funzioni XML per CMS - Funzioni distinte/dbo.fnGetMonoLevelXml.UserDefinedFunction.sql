USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetMonoLevelXml]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetMonoLevelXml
----------------------------------------

FUNZIONE CHE RITORNA UNA STRINGA, COMPOSTA DINAMICAMENTE, CORRISPONDENTE AD UNA PORZIONE DI STATEMENT PER LA GENERAZIONE DI CODICE XML 
AL SECONDO LIVELLO DI ANNIDAMENTO (UTILIZZATA DALLA FUNZIONE "dbo.fnGetDualLevelXml", NON USUFRUIBILE A SE STANTE)

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnGetMonoLevelXml('VX_Gruppi', NULL, 'Id_Link', 24577, 0) AS XmlField -- Ritorna ...FOR XML PATH('Gruppi'), ROOT('Gruppis'), TYPE
SELECT dbo.fnGetMonoLevelXml('VX_Gruppi', 'Gruppo', 'Id_Link', 24577, 0) AS XmlField -- Ritorna ...FOR XML PATH('Gruppo'), ROOT('Gruppi'), TYPE
SELECT dbo.fnGetMonoLevelXml('VX_Gruppi', NULL, 'Id_Link', 24577, 1) AS XmlField -- Ritorna ...FOR XML PATH('element'), ROOT('Gruppi'), TYPE
SELECT dbo.fnGetMonoLevelXml('VX_Gruppi', 'Gruppo', 'Id_Link', 24577, 1) AS XmlField -- Ritorna ...FOR XML PATH('Gruppo'), ROOT('Gruppi'), TYPE *** IGNORA il booleano "@useElementTag" ***
*/
CREATE FUNCTION	[dbo].[fnGetMonoLevelXml]
				(
					@level2TableName varchar(128) = NULL
					,@level2Alias varchar(128) = NULL
					,@commonIDfieldName varchar(128) = NULL
					,@commonIDfieldValue int
					,@useElementTag BIT = NULL
				)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE	
			@RETVAL varchar(MAX) = ''
			,@purgedLevel2TableName varchar(MAX)
			,@forXmlStatement varchar(MAX)
			,@criteria varchar(MAX)

	IF ISNULL(@level2TableName,'') != ''
		BEGIN
			SET @purgedLevel2TableName = dbo.fnRightPart(REPLACE(dbo.fnpurge(@level2TableName),'VX_',''),'_')
			--SET @purgedLevel2TableName = REPLACE(dbo.fnpurge(@level2TableName),'VX_','')
			SET @forXmlStatement =
				CASE 
					WHEN ISNULL(@level2Alias,'') != '' 
					AND (ISNULL(@useElementTag,0) = 1 OR ISNULL(@useElementTag,0) = 0)
					THEN 'FOR XML	PATH(''' + @level2Alias + '''), ROOT(''' + @purgedLevel2TableName + '''), TYPE'
					
					WHEN ISNULL(@level2Alias,'') = '' 
					AND ISNULL(@useElementTag,0) = 1 
					THEN 'FOR XML	PATH(''element''), ROOT(''' + REPLACE(@purgedLevel2TableName,'VX_','') + '''), TYPE'
					
					WHEN ISNULL(@level2Alias,'') = ''
					AND  ISNULL(@useElementTag,0) = 0 
					THEN 'FOR XML	PATH(''' + @purgedLevel2TableName + '''), ROOT(''' + @purgedLevel2TableName + 's''), TYPE'
				END

			SET @criteria = ISNULL(@criteria,'')
			SELECT	@criteria = 
					CASE
						WHEN ISNULL(@commonIDFieldName,'') != ''
						AND  ISNULL(@commonIDFieldValue,0) > 0
						THEN 'WHERE	' + @commonIDfieldName + ' = ' + CAST(@commonIDfieldValue AS varchar(20))
						ELSE ''
					END
					
			SET @RETVAL = 
			'
			,(
				SELECT	' + CHAR(13) + 
				dbo.fnGetTableFields(@level2TableName) + '
				FROM	' + @level2TableName + ' WITH(NOLOCK) ' +
				@criteria + CHAR(13) + 
				@forXmlStatement + '
			)
			'
		END

	RETURN @RETVAL
END
GO
