USE [Intranetinps_Richieste]
GO
/****** Object:  StoredProcedure [dbo].[spXML2Table]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
spXML2Table
----------------------------------------

STORED PROCEDURE CHE RITORNA LA STRUTTURA COMPLETA (ALBERATURA) DI TUTTI I NODI, A QUALSIASI LIVELLO DI ANNIDAMENTO, DELLA COLONNA DI TIPO XML 
PRESENTE NELLA TABELLA/VISTA SPECIFICATA. SE LA STRUTTURA NODALE DELLA COLONNA XML E' PARTICOLARMENTE ANNIDATA, EFFETTUA LO "SCHIACCIAMENTO" DEI VALORI
NELLA COLONNA/TAG PIU' PROSSIMA

-- ESEMPI DI INVOCAZIONE

EXEC	spXML2Table
		@tableName = 'VSN_Pagina'
		,@xmlFieldName = 'XmlPagina'
		,@criteria = 'IDPagina = 8754 AND Versione = 9'

EXEC	spXML2Table
		@tableName = 'VSN_LINK'
		,@xmlFieldName = 'XmlLink'
		,@criteria = 'ID_Link = 15122'

 -- va in errore
EXEC	spXML2Table
		@tableName = 'VSN_Banner'
		,@xmlFieldName = 'XmlBanner'
		,@criteria = 'Id_VsnBanner = 10'


-- Vedere anche la seguente SP (la quale, però, non è in grado di determinare il tipo di dato di ciascuna colonna)
EXEC	spGetAllXmlNodeValues 
		@tableName = 'VSN_Pagina'
		,@xmlFieldName = 'XmlPagina'
		,@criteria = 'IDPagina = 8754 AND Versione = 9'
*/
CREATE PROC [dbo].[spXML2Table]
			@tableName varchar(128) = NULL
			,@xmlFieldName varchar(128) = NULL
			,@criteria varchar(MAX) = NULL
AS

IF ISNULL(@tableName,'') != ''
AND ISNULL(@xmlFieldName,'') != ''
	BEGIN
		SET @criteria = dbo.fnCompleteCriteria(@criteria)

		DECLARE 
				@SQL varchar(MAX)
				,@fieldsList varchar(MAX)
				,@xmlFields varchar(MAX)

		DECLARE	@TEMP TABLE
				(
					NodeName varchar(MAX)
					,BestDataType varchar(MAX)
				)
		INSERT	@TEMP
		EXEC	spGetMostProbableXmlTagDataType 
				@tableName
				,@xmlFieldName
				,NULL -- TagName
				,@criteria

		SELECT	
				@fieldsList = COALESCE(@fieldsList, '') + '[' + NodeName + '] ' + BestDataType + ', '
				,@xmlFields = COALESCE(@xmlFields, '') + NodeName + ' = C.value(''(//' + NodeName + ')[1]'',''' + CASE BestDataType WHEN 'text' THEN 'varchar(MAX)' ELSE BestDataType END + '''), '  + CHAR(13)
		FROM	@TEMP
		WHERE	BestDataType IS NOT NULL

		SET @SQL =
		'
		DECLARE @' + @tableName + ' TABLE(' + dbo.fnTrimCommas(@fieldsList) + ')'  + CHAR(13) + '
		INSERT @' + @tableName + ' 
		SELECT ' + dbo.fnTrimCommas(@XmlFields) + CHAR(13) + '
		FROM '  + @tableName + ' AS T WITH(NOLOCK) ' + CHAR(13) + '
		CROSS APPLY T.' + @xmlFieldName + '.nodes(''/'') AS X(C)' + CHAR(13) +
		@criteria + CHAR(13) + '
		SELECT * FROM @' + @tableName

		PRINT(@SQL)
		EXEC(@SQL)
	END
GO
