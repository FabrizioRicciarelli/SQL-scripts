USE [Intranetinps_Richieste]
GO
/****** Object:  StoredProcedure [dbo].[spGetXmlFieldValues]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
spGetXmlFieldValues
----------------------------------------

STORED PROCEDURE CHE RITORNA, IN FORMA TABELLARE, TUTTI I VALORI POPOLATI NEI CORRISPONDENTI NODI CONTENUTI NELLA COLONNA DI TIPO XML 
PRESENTE IN UNA TABELLA, IN UNA VISTA, O NEL RESULTSET DERIVANTE DA UN’OPERAZIONE DI JOIN TRA DUE OGGETTI (TABELLE E/O VISTE) SPECIFICATI

-- ESEMPI DI INVOCAZIONE

EXEC	spGetXmlFieldValues 
		@tableName = 'VXCROSSDB_TestoConImmagine' -- E' POSSIBILE UTILIZZARE LA FORMA A TRE PARTI PER PUNTARE AD UN DB DIVERSO DA QUELLO CORRENTE
		,@OP = NULL -- SE NULL ASSUME "SELECT"
		,@joinedTableName = NULL -- SE NULL ASSUME "VSN_" + @tableName (SUL DB CORRENTE5) *SOLO* SE ENTRAMBI I "@joinField" SONO VALORIZZATI
		,@joinFieldA = NULL
		,@joinFieldB = NULL
		,@xmlFieldName = NULL -- SE NULL ASSUME "Xml" + @tableName

EXEC	spGetXmlFieldValues 
		@tableName = '[Intranetinps_Lavoro].[dbo].[TestoConImmagine]' -- E' POSSIBILE UTILIZZARE LA FORMA A TRE PARTI PER PUNTARE AD UN DB DIVERSO DA QUELLO CORRENTE
		,@OP = NULL -- SE NULL ASSUME "SELECT"
		,@joinedTableName = NULL -- SE NULL ASSUME "VSN_" + @tableName (SUL DB CORRENTE5) *SOLO* SE ENTRAMBI I "@joinField" SONO VALORIZZATI
		,@joinFieldA = NULL
		,@joinFieldB = NULL
		,@xmlFieldName = NULL -- SE NULL ASSUME "Xml" + @tableName

EXEC	spGetXmlFieldValues 
		@tableName = '[Intranetinps_Richieste].[dbo].[VSN_TestoConImmagine]' -- E' POSSIBILE UTILIZZARE LA FORMA A TRE PARTI PER PUNTARE AD UN DB DIVERSO DA QUELLO CORRENTE
		,@OP = NULL -- SE NULL ASSUME "SELECT"
		,@joinedTableName = NULL -- SE NULL ASSUME "VSN_" + @tableName (SUL DB CORRENTE5) *SOLO* SE ENTRAMBI I "@joinField" SONO VALORIZZATI
		,@joinFieldA = NULL
		,@joinFieldB = NULL
		,@xmlFieldName = 'XmlTestoConImmagine' -- SE NULL ASSUME "Xml" + @tableName

EXEC	spGetXmlFieldValues 
		@tableName = '[Intranetinps_Lavoro].[dbo].[TestoConImmagine]' -- E' POSSIBILE UTILIZZARE LA FORMA A TRE PARTI PER PUNTARE AD UN DB DIVERSO DA QUELLO CORRENTE
		,@OP = NULL -- SE NULL ASSUME "SELECT"
		,@joinedTableName = NULL -- SE NULL ASSUME "VSN_" + @tableName (SUL DB CORRENTE5) *SOLO* SE ENTRAMBI I "@joinField" SONO VALORIZZATI
		,@joinFieldA = 'IdPagina'
		,@joinFieldB = 'id_page'
		,@xmlFieldName = NULL -- SE NULL ASSUME "Xml" + @tableName
		,@criteria = 'WHERE ID_TestoImmagine = 956'

-- RIPRISTINO DEI CONTENUTI DI UNA TABELLA PRELEVANDO I VALORI DELLE COLONNE DAI CORRISPONDENTI TAG XML DELLA TABELLA DI VERSIONAMENTO
BEGIN TRAN
EXEC	spGetXmlFieldValues 
		@tableName = 'TestoConImmagine'
		,@OP = 'UPDATE' -- SE NULL ASSUME "SELECT"
		,@joinedTableName = NULL -- SE NULL ASSUME "VSN_" + @tableName *SOLO* SE ENTRAMBI I "@joinField" SONO VALORIZZATI
		,@joinFieldA = 'IdPagina'
		,@joinFieldB = 'id_page'
		,@xmlFieldName = NULL -- SE NULL ASSUME "Xml" + @tableName
		,@criteria = 'WHERE ID_TestoImmagine = 956'
ROLLBACK TRAN

EXEC	spGetXmlFieldValues 
		@tableName = '[Intranetinps_Lavoro].[dbo].[Galleria]'
		,@OP = NULL -- SE NULL ASSUME "SELECT"
		,@joinedTableName = NULL -- SE NULL ASSUME "VSN_" + @tableName *SOLO* SE ENTRAMBI I "@joinField" SONO VALORIZZATI
		,@joinFieldA = 'Id_Galleria'
		,@joinFieldB = 'IdGalleria'
		,@xmlFieldName = NULL -- SE NULL ASSUME "Xml" + @tableName

*/
CREATE PROC [dbo].[spGetXmlFieldValues] 
			@tableName varchar(128)
			,@OP varchar(20) = NULL -- SE NULL ASSUME "SELECT"
			,@joinedTableName varchar(128) = NULL -- SE NULL ASSUME "VSN_" + @tableName *SOLO* SE ENTRAMBI I "@joinField" SONO VALORIZZATI
			,@joinFieldA varchar(128) = NULL
			,@joinFieldB varchar(128) = NULL
			,@xmlFieldName varchar(128) = NULL -- SE NULL ASSUME "Xml" + @tableName
			,@criteria varchar(MAX) = NULL 
AS
DECLARE	
		@SQL varchar(MAX)
		,@purgedtableName varchar(128)
		,@xmlFields varchar(MAX)
		,@JOINSTATEMENT varchar(MAX)
		,@CROSSJOINTABLEALIAS varchar(MAX)
		,@OPSTATEMENT varchar(MAX)
		,@CR char(1) = CHAR(13)

SET	@purgedtableName = dbo.fnpurge(@tablename)
SET @OP = ISNULL(@OP,'SELECT')
SET @xmlFieldName = ISNULL(@xmlFieldName,'Xml' + REPLACE(REPLACE(@purgedtableName,'VSN_',''),'VXCROSSDB_',''))
SET @joinedTableName = REPLACE(ISNULL(@joinedTableName,'VSN_' + @purgedtableName),'VSN_VSN_','VSN_')
SET @criteria = ISNULL(@criteria,'')

-- DETERMINAZIONE DEL TIPO COLONNA DA UTILIZZARE IN FUNZIONE DELL'OPERAZIONE
-- (SE SI TRATTA DI "UPDATE" UTILIZZA IL COSTRUTTO NOMECAMPO = XmlData.value('(//NOMECAMPO)[1]','int'),
SELECT	@xmlFields = 
		CASE 
			WHEN	@OP = 'SELECT'
			AND		((@joinFieldA IS NOT NULL AND @joinFieldB IS NOT NULL) OR @purgedtableName LIKE 'VXCROSSDB_%')
			THEN	COALESCE(@xmlFields, '') + XmlPattern + @CR
			WHEN	@OP = 'SELECT'
			AND		(@joinFieldA IS NULL OR @joinFieldB IS NULL AND @purgedtableName NOT LIKE 'VXCROSSDB_%')
			THEN	COALESCE(@xmlFields, '') + ',' + fieldName + @CR
			ELSE	COALESCE(@xmlFields, '') + XmlPattern + @CR
		END
FROM	dbo.fnGetColumnDataType(@tablename,'T.')

-- RIMOZIONE DELL'ALIAS IN CASO DI UPDATE
SELECT	@xmlFields = 
		CASE 
			WHEN	@OP = 'SELECT'
			AND		((@joinFieldA IS NULL OR @joinFieldB IS NULL) AND @purgedtableName NOT LIKE 'VXCROSSDB_%')
			THEN	@xmlFields
			ELSE	REPLACE(@xmlFields,'T.', '') 
		END
FROM	dbo.fnGetColumnDataType(@tablename,'T.')

SELECT	@xmlFields =
		CASE
			WHEN RIGHT(@xmlFields,2) = ',' + @CR
			THEN LEFT(@xmlFields,LEN(@xmlFields)-2)
			WHEN RIGHT(@xmlFields,1) = ','
			THEN LEFT(@xmlFields,LEN(@xmlFields)-1)
			WHEN LEFT(@xmlFields,1) = ','
			THEN RIGHT(@xmlFields,LEN(@xmlFields)-1)
			ELSE @xmlFields
		END

--PRINT(@xmlFields)
--RETURN


--SELECT	@xmlFields = 
--		COALESCE(@xmlFields, '') + 
--		ISNULL
--		(
--			ALIAS
--			,REPLACE
--			(
--				REPLACE
--				(
--					XQ.XQueryPattern
--					,')[1]'
--					,''
--				)
--				,'(//'
--				,''
--			)
--		) + 
--		' = XmlData.value(''' + 
--		XQ.XQueryPattern + 
--		''',''' + 
--		XQueryResultDataType +
--		'''),' + 
--		@CR
--FROM	XQUERY_RULES XQ WITH(NOLOCK)
--WHERE	Descrizione LIKE @purgedtableName + '_%'
--
--SET @xmlfields = LEFT(@xmlFields,LEN(@xmlFields)-2)
--PRINT(@xmlFields)

SELECT	@JOINSTATEMENT =
		CASE
			WHEN	((@joinFieldA IS NOT NULL AND @joinFieldB IS NOT NULL) AND @purgedtableName NOT LIKE 'VXCROSSDB_%')
			THEN
					'JOIN ' + @CR + 
					@joinedtableName + ' AS T2 WITH(NOLOCK) ' + @CR +
					'ON ' + @joinFieldA + ' = ' + @joinFieldB 
			ELSE	''
		END
--PRINT(@JOINSTATEMENT)

SELECT	@CROSSJOINTABLEALIAS =
		CASE @JOINSTATEMENT
			WHEN '' 
			THEN 'T'
			ELSE 'T2'
		END
--PRINT(@CROSSJOINTABLEALIAS)
--RETURN

SELECT	@OPSTATEMENT =
		CASE @OP
			WHEN 'SELECT'
			--THEN  @OP + + @CR 
			 THEN  @OP + ' DISTINCT' + @CR -- The text/xml data type cannot be selected as DISTINCT because it is not comparable.
			WHEN 'UPDATE'
			THEN @OP +  ' ' + @tableName + @CR + 'SET ' + @CR
		END
--PRINT(@OPSTATEMENT)

SET	@SQL = 
@OPSTATEMENT +
@xmlFields + @CR +
'FROM '  + @tableName + ' AS T WITH(NOLOCK) ' + @CR +
@JOINSTATEMENT + @CR +
'CROSS APPLY ' + @CROSSJOINTABLEALIAS + '.' + @xmlFieldName + '.nodes(''/'') AS X(XmlData)' + @CR +
@criteria

IF @OP LIKE '%UPDATE%'
AND @criteria = ''
	BEGIN
		PRINT 'UPDATE SENZA WHERE !!! ESECUZIONE STORED PROCEDURE NON EFFETTUATA.'
	END
ELSE
	BEGIN
		PRINT(@SQL)
		EXEC(@SQL)
	END


GO
