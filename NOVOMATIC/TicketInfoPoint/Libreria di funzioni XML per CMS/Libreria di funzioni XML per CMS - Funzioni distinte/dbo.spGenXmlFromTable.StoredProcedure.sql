USE [Intranetinps_Richieste]
GO
/****** Object:  StoredProcedure [dbo].[spGenXmlFromTable]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
spGenXmlFromTable
----------------------------------------

STORED PROCEDURE IL CUI SCOPO E' QUELLO DI GENERARE UNA STRUTTURA XML PARTENDO DALLA TABELLA SPECIFICATA ALLA QUALE SONO STATI APPLICATI GLI EVENTUALI
CRITERI DI FILTRO COMPOSTI DAL CAMPO ID O DA UNA WHERECONDITION. LA STORED PROCEDURE PREVEDE ANCHE CHE POSSA ESSERE SPECIFICATO UN CRITERIO DI ORDINAMENTO

-- ESEMPI DI INVOCAZIONE

EXEC spGenXmlFromTable 'Link'

EXEC	spGenXmlFromTable 
		@tableName = '[Intranetinps_Lavoro].[dbo].[Link]' -- E' POSSIBILE UTILIZZARE LA FORMA A TRE PARTI PER PUNTARE AD UN DB DIVERSO DA QUELLO CORRENTE
		,@ID = NULL
		,@wherecondition = 'WHERE id_cat = 8'

EXEC	spGenXmlFromTable 
		@tableName = 'Link'
		,@ID = NULL
		,@wherecondition = 'id_cat = 8' -- LA PAROLA 'WHERE' SI PUO' OMETTERE (IN CASO DI ASSENZA ESSA SARA' AGGIUNTA AUTOMATICAMENTE)

EXEC	spGenXmlFromTable 
		@tableName = 'Link'
		,@ID = NULL
		,@wherecondition = 'id_cat = 8' -- LA PAROLA 'WHERE' SI PUO' OMETTERE (IN CASO DI ASSENZA ESSA SARA' AGGIUNTA AUTOMATICAMENTE)
		,@orderby ='id_link' -- L'ORDINE DI RAPPRESENTAZIONE DEI NODI

EXEC	spGenXmlFromTable 
		@tableName = 'Link'
		,@ID = 207
		,@wherecondition = NULL
		,@orderby = NULL -- NON AVREBBE SENSO SPECIFICARE UN CRITERIO DI ORDINAMENTO IN QUANTO VIENE RITORNATO UN SOLO RECORD QUINDI SI UTILIZZERA' LA CHIAMATA CHE SEGUE:

EXEC	spGenXmlFromTable 
		@tableName = 'Link'
		,@ID = 207
*/
CREATE PROC	[dbo].[spGenXmlFromTable]
			(
				@tableName varchar(128) = NULL
				,@ID int = NULL
				,@wherecondition varchar(MAX) = NULL
				,@orderby varchar(128) = NULL
			)
AS

SET NOCOUNT ON;
DECLARE	
		@SQL varchar(MAX)
		,@purgedTableName varchar(128)
		,@criteria varchar(MAX)

IF @tableName IS NOT NULL
	BEGIN
		SET	@purgedTableName = dbo.fnpurge(@tablename)

		SELECT	@whereCondition =
				CASE
					WHEN @whereCondition LIKE 'WHERE%'
					THEN @whereCondition
					ELSE 'WHERE ' + @whereCondition
				END

		SELECT	@criteria =
				CASE
					WHEN	ISNULL(@ID,0) != 0
					AND		ISNULL(dbo.fnGetIDColumn(@tableName),'') != ''
					THEN	'WHERE ' + dbo.fnGetIDColumn(@tableName) + ' = ' + CAST(@ID AS varchar(20)) + CHAR(13)
					WHEN	@ID IS NULL
					AND		@wherecondition IS NOT NULL
					THEN	@wherecondition + CHAR(13)
					ELSE	''
				END
		
		SELECT	@orderby =
				CASE
					WHEN	ISNULL(@orderby,'') != ''
					THEN	'ORDER BY ' + @orderby + CHAR(13)
					ELSE	''
				END

		SET @SQL =
		'
		SELECT
		(
		SELECT	*
		FROM	' + 
		@tableName + 
		CHAR(13) +
		@criteria + 
		CHAR(13) +
		@orderby +
		'FOR		XML PATH(''' + @purgedTableName + '''), ROOT(''Xml' + @purgedTableName + '''), TYPE
		) AS Xml' + @purgedTableName
		
		--PRINT(@SQL)
		EXEC(@SQL)
	END



GO
