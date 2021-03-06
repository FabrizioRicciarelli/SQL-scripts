USE [Intranetinps_Richieste]
GO
/****** Object:  StoredProcedure [dbo].[spGenSQLCodeForXmlGet]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.spGenSQLCodeForXmlGet
----------------------------------------

STORED PROCEDURE PREPOSTA ALLA GENERAZIONE DINAMICA DI FUNZIONI: SCRIVE CODICE T-SQL E LO ESEGUE DIRETTAMENTE PRODUCENDO FUNZIONI PERMANENTI
IL CUI SCOPO SARA' QUELLO DI ESTRARRE I VALORI DALLE COLONNE XML DALLE RISPETTIVE TABELLE.

DATA, AD ESEMPIO, LA TABELLA VSN_Link, COMPOSTA DALLE SEGUENTI COLONNE:
IdVsnLink int
Data datetime
XmlLink xml
Id_Link int

L'INVOCAZIONE - UNA TANTUM - DELLA PRESENTE SP PRODURRA' LA FUNZIONE *PERMANENTE* DENOMINATA "dbo.fnGetValueFromXmlLink", *PREVIA ELIMINAZIONE* DAL
DATABASE CORRENTE DI UNA FUNZIONE AVENTE LO STESSO NOME.

PER LE MODALITA' DI INVOCAZIONE DELLE FUNZIONI PERMANENTI GENERATE DALLA PRESENTE SP, SI PREGA DI FARE RIFERIMENTO AI COMMENTI PRESENTI NEL CODICE T-SQL
DELLA FUNZIONE "dbo.fnGetValueFromXmlContenutoNews".

PER GENERARE UNA FUNZIONE SVOLGENTE IL SUMMENZIONATO SCOPO (ESTRARRE I VALORI DALLE COLONNE XML DALLE RISPETTIVE TABELLE), SARA' NECESSARIO:
1. INDIVIDUARE LA TABELLA CONTENENTE ALMENO UNA COLONNA DI TIPO XML ED ESTRARRE, DA QUESTA, L'ELENCO DEI TAGS 
   (NELL'ESEMPIO SOTTO RIPORTATO, QUESTA SARA' "dbo.VSN_Link")
2. IDENTIFICARE, NELLA MEDESIMA TABELLA, LA COLONNA DI TIPO XML CONTENENTE LE INFORMAZIONI CHE - SUCCESSIVAMENTE - 
   SARANNO ELABORATE DALLA FUNZIONE (NELL'ESEMPIO QUESTA CORRISPONDE A "XmlLink")
3. IDENTIFICARE, NELLA MEDESIMA TABELLA, LA COLONNA CORRISPONDENTE ALL'ID PRIMARIO (POSSIBILMENTE DI TIPO INTERO, PK, IDENTITY), 
   NELL'ESEMPIO QUESTA CORRISPONDE A "IdVsnLink"
4. IDENTIFICARE LE RIMANENTI COLONNE (OVVERO CHE *NON* SIANO LA COLONNA XML SUINDICATA E *NON* CORRISPONDANO ALLA COLONNA ID PRIMARIO), 
   IN QUESTO ESEMPIO SI TRATTA DELLE COLONNE "Data" E "Id_Link"
5. TRAMITE I SUELENCATI 4 PUNTI, POPOLARE I PARAMETRI DELLA PRESENTE SP ED INVOCARLA AFFINCHE' ESSA PRODUCA LA FUNZIONE PERMANENTE CORRISPONDENTE

N.B.: RELATIVAMENTE AL PUNTO 4. SI TENGA PRESENTE CHE L'ELENCO DELLE RIMANENTI COLONNE VA *OBBLIGATORIAMENTE* COSTRUITO 
IN FORMATO CSV (Comma Separated Values) CON IL PUNTO E VIRGOLA COME SEPARATORE DI COLONNE AD ESEMPIO: 

'Data datetime;Id_Link int'

QUESTA STRINGA, CHE SARA' POI PASSATA AL PARAMETRO "@CSVfields" DELLA PRESENTE SP, PUO' ESSERE GENERATA AUTOMATICAMETE TRAMITE QUESTA FUNZIONE:

DECLARE	@FieldList varchar(MAX)
SELECT @FieldList = dbo.fnGetCSVfieldsList('dbo.VSN_Link', 'IdVsnLink', NULL)
PRINT (@FieldList)

*ALTERNATIVAMENTE*, PASSANDO NULL AL PARAMETRO @CSVfields DELLA PRESENTE SP, QUESTA TENTERA' - AUTOMATICAMENTE - 
DI RILEVARE QUALI SIANO LE COLONNE IDONEE ALLA CREAZIONE DELLA FUNZIONE PERMANENTE

LA PRESENTE STORED PROCEDURE DIPENDE, DIRETTAMENTE O INDIRETTAMENTE, DALLE SEGUENTI FUNZIONI:
- dbo.fnGetCSVfieldsList
- dbo.fnSplit
- dbo.fnLeftPart
- dbo.fnTrimSeparator

----------------------------------------

-- GENERAZIONE DEL CODICE 
EXEC	spGenSQLCodeForXmlGet
		@tableName = 'VSN_Link' -- PARAMETRO OBBLIGATORIO
		,@primaryIdFieldName = 'IdVsnLink' -- PARAMETRO OBBLIGATORIO
		,@xmlFieldName = 'XmlLink' -- PARAMETRO OBBLIGATORIO
		,@CSVfields = NULL -- RILEVAZIONE AUTOMATICA DEI NOMI E DEI TIPI DI COLONNA DELLA TABELLA (@tableName) SPECIFICATA
*/
CREATE PROC	[dbo].[spGenSQLCodeForXmlGet]
			@tableName varchar(MAX) = NULL
			,@primaryIdFieldName varchar(128) = NULL
			,@xmlFieldName varchar(MAX) = NULL
			,@CSVfields varchar(MAX) = NULL
AS
SET NOCOUNT ON;

IF ISNULL(@tableName,'') != ''
AND ISNULL(@primaryIdFieldName,'') != ''
AND ISNULL(@xmlFieldName,'') != ''
	BEGIN
		SELECT	@CSVfields = 
				CASE
					WHEN @CSVfields IS NULL
					THEN dbo.fnGetCSVfieldsList(@tableName, @primaryIdFieldName, NULL)
					ELSE @CSVfields
				END

		DECLARE 
				@SQL varchar(MAX)
				,@PARAMS_PARAMTYPES_NULL varchar(MAX)
				,@ANDFIELDLIST_PARAMSOR_PARAMSISNULL varchar(MAX)

		DECLARE @csvColAndTypes TABLE(colAndType varchar(MAX) NOT NULL, columnName sysname NULL, columnDataType varchar(MAX) NULL)
		DECLARE @csvColumns TABLE(columnName sysname, columnDataType varchar(MAX))

		INSERT	@csvColAndTypes(colAndType)
		SELECT  item AS colAndType 
		FROM	dbo.fnSplit(@CSVfields,';') 

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

		SELECT	@PARAMS_PARAMTYPES_NULL = COALESCE(@PARAMS_PARAMTYPES_NULL,'') + ',@' + columnName + ' ' + columnDataType + ' = NULL' + CHAR(13)
		FROM	@csvColumns

		SELECT	@ANDFIELDLIST_PARAMSOR_PARAMSISNULL = COALESCE(@ANDFIELDLIST_PARAMSOR_PARAMSISNULL,'') + 'AND (' + columnName + ' = @' + columnName + ' OR @' + columnName + ' IS NULL)' + CHAR(13)
		FROM	@csvColumns


		SET @SQL =
		'
		IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id (N''[dbo].[fnGetValueFrom$xmlFieldName]'') AND xtype = ''FN'')
			BEGIN 
				DROP function dbo.fnGetValueFrom$xmlFieldName
			END
		;
		'
		SET @SQL = REPLACE(@SQL,'$xmlFieldName', @xmlFieldName)
		PRINT(@SQL)
		EXEC(@SQL)

		SET @SQL =
		'CREATE FUNCTION dbo.fnGetValueFrom$xmlFieldName
						(
							@XmlPath varchar(MAX) = NULL
							,$PRIMARYIDFIELDNAMEPARAM_NULL
							$PARAMS_PARAMTYPES_NULL
							,@separator char(1) = NULL
						)
		RETURNS varchar(MAX)
		AS
		BEGIN
			DECLARE @RETVAL varchar(MAX) = NULL

			IF ISNULL(@XmlPath,'''') != ''''
			AND ISNULL(@$primaryIdFieldName,0) != 0
				BEGIN
					SELECT	@RETVAL =
							C.value(''(//*[local-name()=sql:variable("@Xmlpath")])[1]'',''varchar(max)'')
					FROM	$tableName AS T WITH(NOLOCK)
							CROSS APPLY T.$xmlFieldName.nodes(''$xmlFieldName'') AS X(C)
					WHERE	($primaryIdFieldName = @$primaryIdFieldName)
					$ANDFIELDLIST_PARAMSOR_PARAMSISNULL
				END
	
			IF ISNULL(@XmlPath,'''') != ''''
			AND ISNULL(@$primaryIdFieldName,0) = 0
				BEGIN
					SET @separator = ISNULL(@separator,'','')
					SELECT	@RETVAL = 
							dbo.fnTrimSeparator
							(
								CAST
								(
									(
										SELECT	DISTINCT
												REPLACE
												(
													REPLACE
													(
														CAST(C.query(''(//.[local-name()=sql:variable("@Xmlpath")])'') AS varchar(MAX))
														,''<'' + @Xmlpath + ''>''
														,@separator
													)
													,''</'' + @Xmlpath + ''>''
													, ''''
												)
										FROM	$tableName AS T WITH(NOLOCK)
												CROSS APPLY T.$xmlFieldName.nodes(''$xmlFieldName'') AS X(C)
										WHERE   1 = 1
										$ANDFIELDLIST_PARAMSOR_PARAMSISNULL
										FOR XML PATH(''''), TYPE, ELEMENTS
									)
									AS varchar(MAX)
								)
								,@separator
							)
				END
	
			IF ISNULL(@XmlPath,'''') = ''''
			AND ISNULL(@$primaryIdFieldName,0) != 0
				BEGIN
					SELECT	@RETVAL =
							CAST(T.$xmlFieldName AS varchar(MAX))
					FROM	$tableName AS T WITH(NOLOCK)
					WHERE	($primaryIdFieldName = @$primaryIdFieldName)
					$ANDFIELDLIST_PARAMSOR_PARAMSISNULL
				END
			RETURN @RETVAL
		END
		'

		SET @SQL = REPLACE(@SQL,'$TableName', @tableName)
		SET @SQL = REPLACE(@SQL,'$PRIMARYIDFIELDNAMEPARAM_NULL', '@' + @primaryIdFieldName + ' int = NULL')
		SET @SQL = REPLACE(@SQL,'$primaryIdFieldName', @primaryIdFieldName)
		SET @SQL = REPLACE(@SQL,'$xmlFieldName', @xmlFieldName)
		SET @SQL = REPLACE(@SQL,'$PARAMS_PARAMTYPES_NULL', @PARAMS_PARAMTYPES_NULL)
		SET @SQL = REPLACE(@SQL,'$ANDFIELDLIST_PARAMSOR_PARAMSISNULL', @ANDFIELDLIST_PARAMSOR_PARAMSISNULL)

		PRINT(@SQL)
		EXEC(@SQL)
	END
GO
/****** Object:  StoredProcedure [dbo].[spGenXmlFromTable]    Script Date: 23/06/2017 11:07:20 ******/
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
/****** Object:  StoredProcedure [dbo].[spGetAllXmlNodeValues]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
spGetAllXmlNodeValues
----------------------------------------

STORED PROCEDURE ATTA A RITORNARE, IN FORMA TABELLARE, IL CONTENUTO DI QUALSIASI COLONNA XML, ANCHE SE IL LIVELLO DI ANNIDAMENTO E' PARTICOLARMENTE ONEROSO.
COME PARAMETRI IN INGRESSO ACCETTA IL NOME DELLA TABELLA, IL NOME DELLA COLONNA XML CONTENENTE LA STRUTTURA, UN CRITERIO DI FILTRO CHE SARA' APPLICATO ALLE 
COLONNE *NON XML* DELLA TABELLA SPECIFICATA

-- ESEMPI DI INVOCAZIONE

EXEC spGetAllXmlNodeValues 'VSN_LINK','XmlLink','ID_Link = 15122'
EXEC spGetAllXmlNodeValues 'VSN_Banner','XmlBanner','Id_VsnBanner = 10'
EXEC spGetAllXmlNodeValues 'VSN_Lista','XmlLista','IdVsnLista = 17'
EXEC spGetAllXmlNodeValues 'VSN_Galleria','XmlGalleria','IdGalleria = 1109170 AND Id_VsnGalleria = 36'
EXEC spGetAllXmlNodeValues 'VSN_Pagina','XmlPagina','IDPagina = 8754 AND Versione = 9'

-- Vedere anche la seguente SP, capace di identificare con esattezza il tipo di dato di ciascuna colonna corrispondente ai vari tag presenti nell'Xml (incapace, però, di estrarre i dati delle strutture annidate)
EXEC spXML2Table 'VSN_LINK','XmlLink','ID_Link = 15122'
EXEC spXML2Table 'VSN_Banner','XmlBanner','Id_VsnBanner = 10' -- va in errore
EXEC spXML2Table 'VSN_Lista','XmlLista','IdVsnLista = 17'
EXEC spXML2Table 'VSN_Galleria','XmlGalleria','IdGalleria = 1109170 AND Id_VsnGalleria = 36'
EXEC spXML2Table 'VSN_Pagina','XmlPagina','IDPagina = 8754 AND Versione = 9'
*/
CREATE PROC [dbo].[spGetAllXmlNodeValues]
			@tableName varchar(MAX)=NULL
			,@xmlFieldName varchar(128)=NULL
			,@criteria varchar(MAX)=NULL
AS
IF ISNULL(@tableName,'') != ''
AND ISNULL(@xmlFieldName,'') != ''
	BEGIN
		SET @criteria = dbo.fnCompleteCriteria(@criteria)
	
		DECLARE 
				@SQL Nvarchar(MAX)
				,@XmlFieldContents XML   
				,@ParmDefinition Nvarchar(500);		
		
		SET @SQL =
		N'
		DECLARE @XmlField XML
		SELECT @XmlFieldContentsOUT = ' + @xmlFieldName + ' FROM ' + @tableName + @criteria + '
		'
		SET @ParmDefinition = N'@XmlFieldContentsOUT XML OUTPUT';

		EXEC sp_executesql @SQL, @ParmDefinition, @XmlFieldContentsOUT = @XmlFieldContents OUTPUT;
		
		--SELECT NodeName AS TagName, Value FROM fnXML2Table(@XmlFieldContents) WHERE Value IS NOT NULL

		DECLARE @Names TABLE (NodeName varchar(128))
		INSERT	@Names
		SELECT	DISTINCT
				NodeName
		FROM	fnXML2Table(@XmlFieldContents) 
		WHERE	Value IS NOT NULL
		ORDER BY NodeName


		DECLARE	@columns NVARCHAR(MAX)
		SET		@columns = N'';

		SELECT	@columns += N', B.' + QUOTENAME(NodeName)
		FROM	@Names 

		SET @SQL = N'
		SELECT ' + STUFF(@columns, 1, 2, '') + '
		FROM
		(
			SELECT	
					Depth
					,ParentPosition
					,NodeName 
					,Value
			FROM	fnXML2Table(''' + CAST(@XmlFieldContents AS varchar(MAX)) + ''') 
			WHERE	Value IS NOT NULL
		) AS A
		PIVOT
		(
		  MAX(Value) FOR NodeName IN ('
		  + STUFF(REPLACE(@columns, ', B.[', ',['), 1, 1, '')
		  + ')
		) AS B;';
		PRINT @SQL;
		EXEC sp_executesql @SQL;
	END

GO
/****** Object:  StoredProcedure [dbo].[spGetCrossDbColumns]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC spGetCrossDbColumns 'Intranetinps_Lavoro', 'vwDocumentiPagine' 
*/
CREATE PROC [dbo].[spGetCrossDbColumns]
			@dbname sysname
			,@tablename sysname
AS

DECLARE @Tables table 
		(
			DbName sysname
			,SchemaName sysname
			,TableName sysname
			,columnobjectid int
			,columnName sysname
			,columnid int
			,maxlen int
			,prec int
			,scal int
			,nullable bit
			,isidentity bit
			,TypeName sysname
		)

DECLARE @SQL nvarchar(4000)

SET @SQL='
select	''?'' as 
		DbName
		,s.name as SchemaName
		,t.name as TableName
		,c.object_id as columnobjectid
		,c.name as columnName
		,c.column_id as columnid
		,c.max_length as maxlen
		,c.precision as prec
		,c.scale as scal
		,c.is_nullable as nullable
		,c.is_identity as isidentity
		,tp.name as TypeName
from	[?].sys.tables t 
		inner join 
		[?].sys.schemas s 
		on t.schema_id=s.schema_id 
		Inner join 
		[?].sys.columns c 
		on t.object_id = c.object_id
		Inner Join 
		[?].sys.types Tp 
		on tp.system_type_id = c.system_type_id
where	tp.name IN
		(
			''char'', ''nchar'',
			''varchar'', ''nvarchar'',
			''text'', ''ntext''
		)'

INSERT	@Tables 
		(
			DbName
			,SchemaName
			,TableName
			,columnobjectid
			,columnName
			,columnid
			,maxlen
			,prec
			,scal
			,nullable
			,isidentity
			,TypeName
		)
EXEC	sp_msforeachdb @SQL
SET NOCOUNT OFF

SELECT	* 
FROM	@Tables 
WHERE	DbName = @dbname
AND		TableName = @tableName
ORDER BY 
		DbName
		,SchemaName
		,TableName
		,columnid

GO
/****** Object:  StoredProcedure [dbo].[spGetDualLevelXml]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
spGetDualLevelXml
----------------------------------------

STORED PROCEDURE ATTA AD ESEGUIRE GLI STATEMENTS GENERATI DALLA FUNZIONE DIPENDENTE "dbo.fnGetDualLevelXml". 
IL VALORE RITORNATO SARÀ UNA TABELLA CONTENENTE UN SINGOLO CAMPO IL CUI TIPO È VARCHAR(MAX) E IL CONTENUTO È IL CODICE XML FRUTTO DELL’ELABORAZIONE

-- ESEMPI DI INVOCAZIONE

-- RITORNO DI UN VALORE XML CON TAGS '<XmlTestoConImmagine><ImmaginiNelTesto><Immagine>...</Immagine></ImmaginiNelTesto><LinkNelTesto><Link>...</Link></LinkNelTesto></XmlTestoConImmagine>' SUI RAGGRUPPAMENTI DI 2° LIVELLO
EXEC	spGetDualLevelXml
		@masterTableName = 'VX_TestoConImmagine'
		,@commaSep2ndLevelTableNames = 'VX_TestoConImmagine_ImmaginiNelTesto/Immagine, VX_TestoConImmagine_LinkNelTesto/Link' -- Utilizza le viste necesessarie (* NOTARE GLI ALIAS *, "VX_ImmaginiNelTesto/Immagine" = "NomeVista/ALIAS")
		,@commonIDfieldName = 'Id_page'
		,@commonIDfieldValue = 8750
		,@useElementTag = 0 -- QUANDO PRESENTI GLI ALIAS, QUESTO BOOLEANO VIENE IGNORATO
		,@RETVAL = NULL

-- RITORNO DI UN VALORE XML CON TAGS '<XmlTestoConImmagine><ImmaginiNelTesto><element>...</element></ImmaginiNelTesto><LinkNelTesto><element>...</element></LinkNelTesto></XmlTestoConImmagine>' SUI RAGGRUPPAMENTI DI 2° LIVELLO
EXEC	spGetDualLevelXml
		@masterTableName = 'VX_TestoConImmagine'
		,@commaSep2ndLevelTableNames = 'VX_TestoConImmagine_ImmaginiNelTesto, VX_TestoConImmagine_LinkNelTesto' -- Utilizza le viste necesessarie
		,@commonIDfieldName = 'Id_page'
		,@commonIDfieldValue = 6153
		,@useElementTag = 1 -- DATO CHE NESSUN ALIAS E' STATO SPECIFICATO, QUESTO BOOLEANO VALORIZZATO A 1 IMPOSTERA' I NOMI DEI SOTTONODI AD "<element>...</element>"

-- RITORNO DI UN VALORE XML CON TAGS '<XmlTestoConImmagine><ImmaginiNelTestoS><ImmaginiNelTesto>...</ImmaginiNelTesto></ImmaginiNelTestoS><LinkNelTestoS><LinkNelTesto>...</LinkNelTesto></LinkNelTestoS></XmlTestoConImmagine>' SUI RAGGRUPPAMENTI DI 2° LIVELLO
EXEC	spGetDualLevelXml
		@masterTableName = 'VX_TestoConImmagine'
		,@commaSep2ndLevelTableNames = 'VX_TestoConImmagine_ImmaginiNelTesto, VX_TestoConImmagine_LinkNelTesto' -- Utilizza una tabella e una vista (il prefisso VX_ sarà rimosso dai tags dell'XML risultante)
		,@commonIDfieldName = 'Id_page'
		,@commonIDfieldValue = 6153
		,@useElementTag = 0 -- DATO CHE NESSUN ALIAS E' STATO SPECIFICATO, QUESTO BOOLEANO VALORIZZATO A 0 IMPOSTERA' I NOMI DEI SOTTONODI A "<KeyWord_Link>...</KeyWord_Link>" E IL NODO PADRE A "<KeyWord_Links>...</KeyWord_Links>" (CON UNA "s" IN FONDO)
*/
CREATE PROC	[dbo].[spGetDualLevelXml]
			@masterTableName varchar(128) = NULL -- Tabella "Master"
			,@commaSep2ndLevelTableNames varchar(MAX) = NULL -- Elenco, separato da virgole, dei nomi di tabella da annidare al secondo livello
			,@commonIDfieldName varchar(128) = NULL -- Nome campo ID comune a tutte le tabelle
			,@commonIDfieldValue int -- Valore campo ID utilizzato come criterio di filtro
			,@useElementTag BIT = NULL -- Flag che determina se utilizzare il tag "element" nei raggruppamenti oppure no
			,@RETVAL XML = NULL OUTPUT
AS

-- VERSIONE *FUNZIONANTE* PER IMPOSTARE UN
-- VALORE DI RITORNO
DECLARE @TABLERET TABLE
		(
			returnvalue XML
		)

DECLARE	
		@SQL varchar(MAX)

SELECT	@SQL = dbo.fnGetDualLevelXml(REPLACE(@masterTableName,'VX_',''), @commaSep2ndLevelTableNames, @commonIDfieldName, @commonIDfieldValue, @useElementTag)

PRINT(@SQL)

INSERT	@TABLERET(returnvalue)
EXEC	(@SQL)

SELECT	TOP 1 
		@RETVAL = returnvalue 
FROM	@TABLERET

SELECT @RETVAL
GO
/****** Object:  StoredProcedure [dbo].[spGetIntValueFromXmlNode]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
spGetIntValueFromXmlNode
----------------------------------------

STORED PROCEDURE CHE RITORNA UNA TABELLA DI VALORI INTERI CORRISPONDENTI AD UN DETERMINATO XPATH CONTENUTO ALL'INTERNO DELLA COLONNA XML "XmlPagina" 
DELLA TABELLA VSN_PAGINA. I DATI SI RIFERISCONO AL CRITERIO DI FILTRO APPLICATO AL LIVELLO SUPERIORE (QUINDI DI TABELLA, NON DI TAG XML) IN RELAZIONE
AI VALORI SPECIFICATI PER I PARAMETRI "@Id_Pagina" E "@Id_Versione"

-- ESEMPI DI INVOCAZIONE

EXEC	spGetIntValueFromXmlNode
		'/XmlPagina/Liste/Lista'
		,'id_lista'
		,8754
		,8
*/
CREATE PROC	[dbo].[spGetIntValueFromXmlNode]
			@XmlRootNode varchar(MAX) = NULL
			,@XmlNodeName varchar(MAX) = NULL
			,@Id_Pagina int = NULL
			,@Id_Versione int = NULL
AS

DECLARE	@SQL varchar(MAX)

SET @SQL =
'
	SELECT	
			IntValue = CAST(REPLACE(REPLACE(CAST(C.query(''./' + @XmlNodeName + ''') AS nvarchar(MAX)),''<'  + @XmlNodeName + '>'',''''),''</' + @XmlNodeName + '>'','''') AS int)
	FROM	VSN_Pagina AS T WITH(NOLOCK) 
			CROSS APPLY T.XmlPagina.nodes(''' + @XmlRootNode +''') AS X(C)
	WHERE	IdPagina = ' + CAST(@Id_Pagina AS varchar(26)) + '
	AND		Versione = ' + CAST(@Id_versione AS varchar(26)) + '
'
PRINT(@SQL)
EXEC(@SQL)
GO
/****** Object:  StoredProcedure [dbo].[spGetMostProbableXmlTagDataType]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
DECLARE @TEMP TABLE(NodeName varchar(MAX), BestDataType varchar(MAX))
INSERT @TEMP
EXEC spGetMostProbableXmlTagDataType 'VSN_Pagina', 'XmlPagina', NULL, ' WHERE IDPagina = 8754 AND Versione = 8'

SELECT	*
FROM	@TEMP 
WHERE	BestDataType IS NOT NULL

DECLARE @fieldsList varchar(MAX)
SELECT	@fieldsList = COALESCE(@fieldsList, '') + '[' + NodeName + '] ' + BestDataType + ', '
FROM	@TEMP
WHERE	BestDataType IS NOT NULL

SELECT dbo.fnTrimCommas(@fieldsList)
*/
CREATE PROC [dbo].[spGetMostProbableXmlTagDataType](@tableName varchar(MAX) = NULL, @XmlFieldName varchar(128) = NULL, @tagName varchar(128) = NULL, @criteria varchar(MAX))
AS

DECLARE @SQL varchar(MAX)
SET @tagName = 
	CASE 
		WHEN @tagName IS NOT NULL 
		THEN '''' + @tagName + '''' 
		ELSE 'NULL' 
	END

SET @SQL =
'
DECLARE @XmlField XML
SELECT	@XmlField = ' + @XmlFieldName + ' 
FROM	' + @tableName + 
@criteria +
'
SELECT	DISTINCT
		NodeName
		--,ParentName
		--,CAST(XmlSource AS XML) AS XmlSource
		,CAST(XmlSource AS XML).value(''(//DataType[../ThisDataTypeOccurrences = max(../ThisDataTypeOccurrences) and not(. < //DataType)])[1]'',''varchar(max)'') AS BestDataType  
FROM	dbo.fnGetGetMostProbableXmlTagDataType(@XmlField,' + @tagName + ')

ORDER BY
		NodeName
		--,ParentName
'
PRINT(@SQL)
EXEC(@SQL)
/*

SELECT	DISTINCT
		XLIST.ParentName
		,XLIST.NodeName
		--,CAST((SELECT * FROM dbo.fnGetAllTablesByColumnName(XLIST.NodeName) FOR XML PATH(''''),TYPE, ELEMENTS) AS varchar(MAX)) AS AllColumnProps
		--,CAST((SELECT DISTINCT ObjectName, name AS ColumnName, typename, [length] FROM dbo.fnGetAllTablesByColumnName(XLIST.NodeName) FOR XML PATH(''''),TYPE, ELEMENTS) AS varchar(MAX)) AS ParentTable_ObjectName
		,CAST((SELECT DISTINCT xtype, [length] FROM dbo.fnGetAllTablesByColumnName(XLIST.NodeName) FOR XML PATH(''''),TYPE, ELEMENTS) AS varchar(MAX)) AS ParentTable_ObjectName
FROM	fnXML2Table(@XmlField) XLIST
WHERE	ParentName IS NOT NULL
ORDER BY
		ParentName
		,NodeName


DECLARE 
		@fieldList varchar(MAX)
		,@fieldListWithDataType varchar(MAX)
SELECT 
		@fieldList = COALESCE(@fieldList, '') + fieldName + ', '
		,@fieldListWithDataType = COALESCE(@fieldListWithDataType, '') + ' ' + fieldWithLength
FROM	fnGetColumnDataType('Pagine',NULL) 

SELECT 
		dbo.fnTrimCommas(@fieldList) AS fieldList
		,dbo.fnTrimCommas(@fieldListWithDataType) AS fieldListWithDataType

SELECT * FROM SYSTYPES
*/
GO
/****** Object:  StoredProcedure [dbo].[spGetMultiXml]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
spGetMultiXml
----------------------------------------

STORED PROCEDURE ATTA AD ESEGUIRE GLI STATEMENTS GENERATI DALLA FUNZIONE DIPENDENTE dbo.fnGetMultiLevelXml. 
IL VALORE RITORNATO SARÀ UNA TABELLA CONTENENTE UN SINGOLO CAMPO IL CUI TIPO È VARCHAR(MAX) E IL CONTENUTO È IL CODICE XML FRUTTO DELL’ELABORAZIONE

-- ESEMPI DI INVOCAZIONE

-- RITORNO DI UN VALORE XML CON TAGS '<NomeTabella><element>...</element><element>...</element><NomeTabella>' SUI RAGGRUPPAMENTI DI 2° LIVELLO
EXEC	spGetMultiXml
		@masterTableName = 'Link'
		,@level1TableName = '[IntranetInps].[dbo].[KeyWord_Link]'
		,@level2TableName = 'VX_Gruppi'
		,@commonIDfieldName = 'Id_Link'
		,@commonIDfieldValue = 24577
		,@useElementTag = 1

-- RITORNO DI UN VALORE XML CON TAGS '<NomeTabellaS><NomeTabella>...</NomeTabella><NomeTabella>...</NomeTabella></NomeTabellaS>' SUI RAGGRUPPAMENTI DI 2° LIVELLO
EXEC	spGetMultiXml
		@masterTableName = 'Link'
		,@level1TableName = '[IntranetInps].[dbo].[KeyWord_Link]'
		,@level2TableName = 'VX_Gruppi' -- Utilizza una vista (il prefisso VX_ sarà rimosso dai tags dell'XML risultante)
		,@commonIDfieldName = 'Id_Link'
		,@commonIDfieldValue = 24577
		,@useElementTag = 0
*/
CREATE PROC	[dbo].[spGetMultiXml]
			@masterTableName varchar(128) = NULL -- Tabella "Master"
			,@level1TableName varchar(128) = NULL -- Prima tabella annidata
			,@level2TableName varchar(128) = NULL -- Seconda tabella annidata
			,@commonIDfieldName varchar(128) = NULL -- Nome campo ID comune a tutte le tabelle
			,@commonIDfieldValue int -- Valore campo ID utilizzato come criterio di filtro
			,@useElementTag BIT = NULL -- Flag che determina se utilizzare il tag "element" nei raggruppamenti oppure no
AS
DECLARE	@SQL varchar(MAX)
SELECT	@SQL = dbo.fnGetMultiLevelXml(@masterTableName, @level1TableName, @level2TableName, @commonIDfieldName, @commonIDfieldValue, @useElementTag)
EXEC(@SQL)

GO
/****** Object:  StoredProcedure [dbo].[spGetPagineXml]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC spGetPagineXml 8754, 9
EXEC spGetPagineXml 8754, NULL
*/
CREATE PROC [dbo].[spGetPagineXml] 
			@Id_Pagina int = NULL
			,@Versione int = NULL
AS
	DECLARE 
			@RETVAL XML
			,@Liste XML
			,@NomePagina varchar(300)
			,@IdVsnTestoSemplice int
			,@IdVsnTestoConImmagine int
			,@IdVsnTestoDoppio int
			,@IdVsnBanner int
			,@IdVsnContenutoNews int
			,@IdVsnGalleria int
			,@IdVsnLista int

	SELECT	
			@IdVsnTestoSemplice = C.value('(//IdVsnTestoSemplice)[1]','int')
			,@IdVsnTestoConImmagine = C.value('(//IdVsnTestoConImmagine)[1]','int')
			,@IdVsnTestoDoppio = C.value('(//IdVsnTestoDoppio)[1]','int')
			,@IdVsnBanner = C.value('(//IdVsnBanner)[1]','int')
			,@IdVsnContenutoNews = C.value('(//IdVsnContenutoNews)[1]','int')
			,@IdVsngalleria = C.value('(//IdVsnGalleria)[1]','int')
			,@IdVsnLista = C.value('(//IdVsnLista)[1]','int')
	FROM	VSN_Pagina AS T WITH(NOLOCK) 
			CROSS APPLY T.XmlPagina.nodes('/') AS X(C)
	WHERE	IdPagina = @ID_Pagina
	AND		Versione = @Versione

	EXEC	dbo.spEstraiListeVSN
			@Id_Pagina = @ID_Pagina
			,@Id_Versione = @Versione
			,@UseRootNodeName = 0
			,@ListeXML = @Liste OUTPUT

	SET	@RETVAL =
		CASE
			WHEN ISNULL(@Versione,0) = 0
			THEN
			(
				SELECT	
						P.*
						,dbo.fnGetTemplateCategoriaXml(P.Id_Pagina,NULL)	
						,dbo.fnGetTestoSempliceXml(P.Id_Pagina, NULL, NULL)
						,dbo.fnGetTestoConImmagineXml(P.Id_Pagina, NULL, NULL)
						,dbo.fnGetTestoDoppioXml(P.Id_Pagina, NULL, NULL)
						,dbo.fnGetBannersXml(P.Id_Pagina, NULL, NULL)
						,dbo.fnGetNewsXml(P.Id_Pagina, NULL, NULL)
						,dbo.fnGetListeXml(P.Id_Pagina, NULL, NULL)
						,dbo.fnGetGallerieXml(P.Id_Pagina, NULL, NULL)
				FROM	Pagine P WITH(NOLOCK)
				WHERE	P.ID_Pagina = @ID_Pagina
				FOR XML PATH(''),ROOT('XmlPagina')
			)
			ELSE
			(
				SELECT
						dbo.fnGetInfoPaginaXml(P.IdPagina,P.Versione)
						,dbo.fnGetTemplateCategoriaXml(P.IdPagina,NULL)	
						,dbo.fnReplaceXmlNodeName(dbo.fnGetTestoDoppioXml(P.IdPagina,NULL,@IdVsnTestoDoppio),'XmlTestoDoppio','TestoDoppio')
						,dbo.fnReplaceXmlNodeName(dbo.fnGetTestoSempliceXml(P.IdPagina,NULL,@IdVsnTestoSemplice),'XmlTestoSemplice','TestoSemplice')
						,dbo.fnReplaceXmlNodeName(dbo.fnGetTestoConImmagineXml(P.IdPagina,NULL,@IdVsnTestoConImmagine),'XmlTestoConImmagine','TestoConImmagine')
						,dbo.fnReplaceXmlNodeName(dbo.fnGetBannersXml(P.IdPagina,NULL,@IdVsnBanner),'XmlBanner','Banners')
						,dbo.fnGetNewsXml(P.IdPagina, NULL, @IdVsnContenutoNews)
						,dbo.fnGetGallerieXml(P.IdPagina, NULL, @IdVsngalleria)
						,@Liste
				FROM	Vsn_Pagina P WITH(NOLOCK)
				WHERE	IdPagina = @ID_Pagina
				AND		Versione = @Versione 
				FOR XML PATH('XMLPageData'), ELEMENTS
			)
		END

	SET @RETVAL = dbo.fnReplaceXmlNodeName(@RETVAL,'XMLPageData','XMLPageData xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"')
	SELECT @RETVAL
GO
/****** Object:  StoredProcedure [dbo].[spGetSingleNodeValue]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
spGetSingleNodeValue
----------------------------------------

STORED PROCEDURE ATTA ALL’ESTRAZIONE DEL VALORE POPOLATO IN PROSSIMITÀ DEL NODO XML SPECIFICATO

-- ESEMPI DI INVOCAZIONE

EXEC	dbo.spGetSingleNodeValue
		@tableName = '[Intranetinps_Richieste].[dbo].[VSN_Galleria]' -- E' POSSIBILE UTILIZZARE LA FORMA A TRE PARTI PER PUNTARE AD UN DB DIVERSO DA QUELLO CORRENTE
		,@xmlFieldName = 'XmlGalleria'
		,@nodeName = 'FileAssociato'
		,@nodeID = NULL -- QUANDO "NULL", ESTRAE IL VALORE CORRISPONDENTE AL PRIMO NODO ('(//NodeName)[1]' NEL CASO IN CUI CE NE SIA PIU' DI UNO)
		,@criteria = 'id_VsnGalleria = 13'

EXEC	dbo.spGetSingleNodeValue
		@tableName = '[Intranetinps_Richieste].[dbo].[VSN_Galleria]' -- E' POSSIBILE UTILIZZARE LA FORMA A TRE PARTI PER PUNTARE AD UN DB DIVERSO DA QUELLO CORRENTE
		,@xmlFieldName = 'XmlGalleria'
		,@nodeName = 'FileAssociato'
		,@nodeID = 2
		,@criteria = 'id_VsnGalleria = 13'
*/
CREATE PROC	[dbo].[spGetSingleNodeValue]
			@tableName varchar(128) = NULL
			,@xmlFieldName varchar(128) = NULL
			,@nodeName varchar(128) = NULL
			,@nodeID int = NULL
			,@criteria varchar(MAX) = NULL
AS

IF ISNULL(@tableName,'') != ''
AND ISNULL(@xmlFieldName,'') != ''
AND ISNULL(@nodeName,'') != ''
AND ISNULL(@criteria,'') != ''
	BEGIN
		DECLARE @SQL varchar(MAX)

		SELECT	@nodeID =
				CASE
					WHEN @nodeID IS NULL
					THEN '1'
					ELSE @nodeID
				END

		SELECT	@criteria =
				CASE
					WHEN @criteria LIKE 'WHERE%'
					THEN @criteria
					ELSE 'WHERE ' + @criteria
				END

		SET	@SQL = 
		'SELECT ' +
		@nodeName + ' = C.value(''(//' + @nodeName + ')[' + CAST(@nodeID AS varchar(20)) + ']'',''varchar(MAX)'')'  + CHAR(13) + 
		'FROM '  + @tableName + ' AS T WITH(NOLOCK) ' + CHAR(13) +
		'CROSS APPLY T.' + @xmlFieldName + '.nodes(''/'') AS X(C)' + CHAR(13) +
		@criteria

		PRINT(@SQL)
		EXEC(@SQL)
	END


GO
/****** Object:  StoredProcedure [dbo].[spGetVSNXml]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC spGetVSNXml 'VSN_LINK','XmlLink','ID_Link = 15122'
EXEC spGetVSNXml 'VSN_Pagina','XmlPagina','IdPagina = 8754 AND Versione = 3'
*/
CREATE PROC	[dbo].[spGetVSNXml]
			@VSNTableName varchar(MAX)=NULL
			,@VSNXmlColumnName varchar(128) = NULL
			,@VSNCriteria varchar(MAX) = NULL
AS
IF ISNULL(@VSNTableName,'') != ''
AND ISNULL(@VSNXmlColumnName,'') != ''
	BEGIN
		IF ISNULL(@VSNCriteria,'') != ''
			BEGIN
				SET @VSNCriteria =
					CASE
					WHEN LTRIM(REPLACE(@VSNCriteria,CHAR(13),'')) LIKE 'WHERE%'
					THEN ''
					ELSE ' WHERE ' + @VSNCriteria
				END
			END
			DECLARE 
					@SQL Nvarchar(MAX)
			
			SET @SQL = 'SELECT ' + 	@VSNXmlColumnName + ' FROM ' + @VSNTableName + ' ' + @VSNCriteria
			EXEC(@SQL)
	END	

GO
/****** Object:  StoredProcedure [dbo].[spGetXmlFieldValues]    Script Date: 23/06/2017 11:07:20 ******/
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
/****** Object:  StoredProcedure [dbo].[spGetXmlStructure]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
spGetXmlStructure
----------------------------------------

STORED PROCEDURE CHE RITORNA LA STRUTTURA COMPLETA (ALBERATURA) DI TUTTI I NODI, A QUALSIASI LIVELLO DI ANNIDAMENTO, DELLA COLONNA DI TIPO XML 
PRESENTE NELLA TABELLA/VISTA SPECIFICATA

-- ESEMPI DI INVOCAZIONE

EXEC	dbo.spGetXmlStructure 
		@tableName = 'VXCROSSDB_TestoConImmagine'
		,@xmlFieldName = 'XmlTestoConImmagine'
		,@criteria = 'WHERE ID_VSNTestoConImmagine = 4'
		,@xmlCriteria = 'WHERE	Value IS NULL AND TreeView LIKE ''%|-%'''
*/
CREATE PROC	[dbo].[spGetXmlStructure] 
			@tableName varchar(MAX) = NULL
			,@xmlFieldName varchar(128) = NULL
			,@criteria varchar(MAX) = NULL
			,@xmlCriteria varchar(MAX) = NULL
AS

/*
-- ESEGUIRE IL SEGUENTE STATEMENT SE NEL DB NON E' PRESENTE QUESTO USERTYPE
CREATE TYPE dbo.XMLSTRUCTURE_TYPE AS TABLE
(
	ID int
	,ParentPosition smallint
	,Depth smallint
	,NodeName varchar(128)
	,NodeType varchar(50)
	,FullPath varchar(MAX)
	,XPath varchar(MAX)
	,TreeView varchar(MAX)
	,Value varchar(MAX)
	,XmlData XML
)
*/
DECLARE @SQL varchar(MAX)
IF ISNULL(@tableName,'') != ''
AND ISNULL(@xmlFieldName,'') != ''
	BEGIN
		SET @SQL =
		'
		DECLARE @XML XML
		DECLARE @structure XMLSTRUCTURE_TYPE 

		SELECT	@XML = ' + @xmlFieldName + ' 
		FROM	' + @tableName + ' 
		' + ISNULL(@criteria,'') +
		'
		INSERT	@structure
				(
					ID
					,ParentPosition
					,Depth
					,NodeName
					,NodeType
					,FullPath
					,XPath
					,TreeView
					,Value
					,XmlData
				)

		SELECT 
				ID
				,ParentPosition
				,Depth
				,NodeName
				,NodeType
				,FullPath
				,XPath
				,TreeView
				,Value
				,XmlData
		FROM	dbo.fnXml2Table(@XML)

		SELECT *
		FROM @structure
		' + ISNULL(@XmlCriteria,'')

		--PRINT(@SQL)
		EXEC(@SQL)
	END
GO
/****** Object:  StoredProcedure [dbo].[spTMPaddColumns]    Script Date: 23/06/2017 11:07:20 ******/
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
/****** Object:  StoredProcedure [dbo].[spTMPcreate]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.spTMPcreate - SISTEMA TMP
----------------------------------------

NELL'AMBITO DEL MICROSISTEMA DI GESTIONE DI DATI TABELLARI TEMPORANEI (SISTEMA "TMP"), QUESTA STORED PROCEDURE E' PREPOSTA ALLA CREAZIONE IN TEMPO
REALE DI UNA TABELLA TEMPORANEA GLOBALE (UBICATA NEL DATABASE "tempdb", MA LA CUI ALLOCAZIONE E' TOTALMENTE TRASPARENTE ALL'UTENTE CHE LA IMPIEGA)

L'INVOCAZIONE DELLA PRESENTE SP PROVVEDERA' ALLA DISTRUZIONE PREVENTIVA DI UNA TABELLA - IDENTICA NEL NOME E NELL'UBICAZIONE - EVENTUALMENTE CREATA IN PRECENZA;
SI CONSIGLIA PERTANTO, PRIMA DI INVOCARLA, DI ACCERTARSI (TRAMITE L'INVOCAZIONE DELLA SP "spTMPgetAll") CHE IN TALE TABELLA TEMPORANEA NON SIANO
PRESENTI DATI IMPORTANTI PRECEDENTEMENTE MEMORIZZATI IN ESSA

-- ESEMPI DI INVOCAZIONE

EXEC spTMPcreate
EXEC spTMPgetAll -- oppure SELECT * FROM ##__tmpTable
EXEC spTMPaddColumns 'added nvarchar(max), added2 varchar(20), added3 datetime'

INSERT ##__tmpTable(added, added2, added3)
VALUES
		('NEW','PIPPO', GETDATE())
		,('OLD', 'PLUTO', NULL)

EXEC spTMPgetAll -- oppure SELECT * FROM ##__tmpTable
*/
CREATE PROC [dbo].[spTMPcreate]
AS
EXEC spTMPdestroy
CREATE TABLE ##__tmpTable(__id int IDENTITY(1,1) PRIMARY KEY CLUSTERED NOT NULL)

GO
/****** Object:  StoredProcedure [dbo].[spTMPdestroy]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.spTMPdestroy - SISTEMA TMP
----------------------------------------

NELL'AMBITO DEL MICROSISTEMA DI GESTIONE DI DATI TABELLARI TEMPORANEI (SISTEMA "TMP"), QUESTA STORED PROCEDURE E' PREPOSTA ALLA DISTRUZIONE, SENZA
ULTERIORI RICHIESTE DI CONFERMA, DI UNA TABELLA TEMPORANEA GLOBALE (UBICATA NEL DATABASE "tempdb").

QUESTA SP VIENE INVOCATA AUTOMATICAMENTE OGNI QUALVOLTA VIENE ESEGUITA LA SP "spTMPcreate": QUESTO SIGNIFICA CHE PRIMA CHE LA TABELLA VENGA CREATA,
ESSA SARA' DA QUESTA SP DISTRUTTA (E CON ESSA TUTTI I DATI IVI CONTENUTI)

-- ESEMPI DI INVOCAZIONE

EXEC spTMPdestroy
*/
CREATE PROC	[dbo].[spTMPdestroy]
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
/****** Object:  StoredProcedure [dbo].[spTMPGetAll]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.spTMPGetAll - SISTEMA TMP
----------------------------------------

NELL'AMBITO DEL MICROSISTEMA DI GESTIONE DI DATI TABELLARI TEMPORANEI (SISTEMA "TMP"), QUESTA STORED PROCEDURE E' PREPOSTA ALLA RESTITUZIONE DI TUTTI I
DATI PRESENTI ALL'INTERNO DELLA TABELLA TEMPORANEA PRECEDENTEMENTE CREATA DALLA SP "spTMPcreate", QUINDI ARRICCHITA DELLE COLONNE NECESSARIE TRAMITE LA
SP "spTMPaddColumns" E POPOLATA CON I VALORI VOLUTI ATTRAVERSO GLI STATEMENTS INSERT/UPDATE

-- ESEMPI DI INVOCAZIONE

EXEC spTMPcreate
EXEC spTMPgetAll -- oppure SELECT * FROM ##__tmpTable
EXEC spTMPaddColumns 'added nvarchar(max), added2 varchar(20), added3 datetime'

INSERT ##__tmpTable(added, added2, added3)
VALUES
		('NEW','PIPPO', GETDATE())
		,('OLD', 'PLUTO', NULL)

EXEC spTMPgetAll -- oppure SELECT * FROM ##__tmpTable
*/
CREATE PROC [dbo].[spTMPGetAll]
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
GO
/****** Object:  StoredProcedure [dbo].[spVSN_Link]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC spVSN_Link 24577
*/
CREATE PROC [dbo].[spVSN_Link] 
			@IDlink int = NULL
AS
IF ISNULL(@IDlink,0) > 0
	BEGIN
		DECLARE	
				@xmlField XML -- VARIABILE PREPOSTA AL RECEPIMENTO DEL CONTENUTO DELLA COLONNA XML

		SET NOCOUNT ON; -- DISABILITA TEMPORANEAMENTE IL CONTEGGIO DELLE RIGHE 

		-- POPOLAMENTO DELLA TABELLA IN MEMORIA CON IL RISULTATO DELLA CHIAMATA ALLA SP DI GENERAZIONE DELL'XML
		EXEC	spGetDualLevelXml
				'Link' -- @masterTableName
				,'[IntranetInps].[dbo].[KeyWord_Link]/Link, VX_Gruppi/Gruppo' -- @commaSep2ndLevelTableNames
				,'Id_Link' -- @commonIDfieldName
				,@IDLink -- @commonIDfieldValue
				,0 -- @useElementTag
				,@xmlField OUTPUT

		SET NOCOUNT OFF; -- RIABILITA IL CONTEGGIO DELLE RIGHE 

		-- POPOLAMENTO DELLA TABELLA "VSN" DI DESTINAZIONE, CON ESCLUSIONE DEI DUPLICATI
		BEGIN TRAN
			INSERT	VSN_Link
					(
						Id_Link
						,XmlLink
						,Data
					)
			SELECT
					L.Id_Link
					,@xmlField AS XmlLink
					,GETDATE() AS Data
			FROM	Link L WITH(NOLOCK)
					LEFT JOIN
					VSN_Link R WITH(NOLOCK)
					ON L.ID_Link = R.Id_Link
					AND dbo.fnCompareXML(@xmlField, R.XmlLink) = 1
			WHERE	L.ID_Link = @IDLink
			AND		R.Id_Link IS NULL -- IMPEDISCE I DUPLICATI
		COMMIT TRAN
	END

GO
/****** Object:  StoredProcedure [dbo].[spXML2Table]    Script Date: 23/06/2017 11:07:20 ******/
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
/****** Object:  UserDefinedFunction [dbo].[fnAddXmlNode]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnAddXmlNode
----------------------------------------

FUNZIONE PREPOSTA ALL'INSERIMENTO DI UNO O PIU' NODI XML, ANCHE COMPLESSI, ALL'INTERNO DI UNA STRUTTURA XML PREESISTENTE.
SI NOTI, OSSERVANDO IL CODICE CHE COMPONE LA PRESENTE FUNZIONE, CHE IL POSIZIONAMENTO DEL NUOVO NODO PUO' AVVENIRE SECONDO
DIFFERENTI MODALITA', OVVERO:

- prima del primo elemento figlio incluso nel nodo puntato dall'xpath
- dopo l'ultimo elemento figlio incluso nel nodo puntato dall'xpath
- prima del primo nodo puntato dall'xpath
- dopo la chiusura del nodo specificato dall'xpath

AFFINCHE' CIO' AVVENGA, E' NECESSARIO MODIFICARE LA STRUTTURA DEL CODICE, COMMENTANDO/DECOMMENTANDO OPPORTUNAMENTE LE RIGHE 
PREPOSTE AL RISULTATO DESIDERATO.

VEDERE ANCHE LE FUNZIONI EQUIVALENTI:
- fnDeleteXmlNode
- fnReplaceXmlNodeName

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnAddXmlNode('<XmlTestoDoppio>
  <Label>
    <id_labeldoppio>2953</id_labeldoppio>
    <label1>Nome</label1>
    <label2>Roberto</label2>
    <id_Pagina>8754</id_Pagina>
    <id_Image>79</id_Image>
    <ordinamento>1</ordinamento>
  </Label>
  <Label>
    <id_labeldoppio>2954</id_labeldoppio>
    <label1>Cognome</label1>
    <label2>Nacchia</label2>
    <id_Pagina>8754</id_Pagina>
    <id_Image>79</id_Image>
    <ordinamento>2</ordinamento>
  </Label>
</XmlTestoDoppio>','XmlTestoDoppio','<NewNode>NewContent</NewNode>')
*/
CREATE FUNCTION [dbo].[fnAddXmlNode]
				(
					@XmlSource XML
					,@XmlPath varchar(MAX)
					,@NewNodeContent XML
				)
RETURNS XML
AS
BEGIN
	DECLARE @RETVAL XML

	IF ISNULL(CAST(@XmlSource AS nvarchar(MAX)),'') != ''
	AND ISNULL(@XmlPath,'') != ''
	AND ISNULL(CAST(@NewNodeContent AS varchar(MAX)),'') != ''
		BEGIN
			SET @XmlSource.modify('insert sql:variable("@NewNodeContent") as first into (//*[local-name()=sql:variable("@Xmlpath")])[1]') -- prima del primo elemento figlio incluso nel nodo puntato dall'xpath
			--SET @XmlSource.modify('insert sql:variable("@NewNodeContent") as last into (//*[local-name()=sql:variable("@Xmlpath")])[1]') -- dopo l'ultimo elemento figlio incluso nel nodo puntato dall'xpath
			--SET @XmlSource.modify('insert sql:variable("@NewNodeContent") before (//*[local-name()=sql:variable("@Xmlpath")])[1]') -- prima del primo nodo puntato dall'xpath
			--SET @XmlSource.modify('insert sql:variable("@NewNodeContent") after (//*[local-name()=sql:variable("@Xmlpath")])[1]') -- dopo la chiusura del nodo specificato dall'xpath
			SET @RETVAL = @XmlSource
		END
	
	RETURN @RETVAL
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnCercaNelCodice]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT * FROM dbo.fnCercaNelCodice('IMP_RETR_COMPL')
SELECT * FROM dbo.fnCercaNelCodice('IMP_RETR_COMPL') WHERE ObjectType = 'TF'
SELECT * FROM dbo.fnCercaNelCodice('IMP_RETR_COMPL') WHERE ObjectType = 'P'

SELECT * FROM dbo.fnCercaNelCodice('COD_RETR')
SELECT * FROM dbo.fnCercaNelCodice('COD_RETR') WHERE ObjectType = 'TF'
SELECT * FROM dbo.fnCercaNelCodice('COD_RETR') WHERE ObjectType = 'P'

SELECT * FROM dbo.fnCercaNelCodice('CONTR_BASE_MOD')
SELECT * FROM dbo.fnCercaNelCodice('CONTR_BASE_MOD') WHERE ObjectType = 'TF'
SELECT * FROM dbo.fnCercaNelCodice('CONTR_BASE_MOD') WHERE ObjectType = 'P'
*/
CREATE FUNCTION [dbo].[fnCercaNelCodice] (@textToSearch varchar(MAX) = NULL)
RETURNS @RESULTS TABLE
		(
			ObjectName varchar(128)
			,ObjectType varchar(10)
		)
AS
BEGIN
	IF ISNULL(@textToSearch,'') != ''
		BEGIN
			IF LEN(@textToSearch) > 2
				BEGIN
					DECLARE @Numbers TABLE (Num INT NOT NULL PRIMARY KEY CLUSTERED)
					DECLARE @i int

					SET @i = 1

					WHILE @i <= 10000
						BEGIN
							INSERT @Numbers(Num) VALUES (@i)
							SELECT @i = @i + 1
						END

					INSERT	@RESULTS
							(
								ObjectName
								,ObjectType
							)
					SELECT	DISTINCT	
							O.Name AS ObjectName
							,O.Type AS ObjectType
					FROM
					(
						SELECT 
								Id
								,CAST(COALESCE(MIN(CASE WHEN sc.colId = Num-1 THEN sc.text END), '') AS VARCHAR(MAX)) +
								CAST(COALESCE(MIN(CASE WHEN sc.colId = Num THEN sc.text END), '') AS VARCHAR(MAX)) AS [text]
						FROM	SysComments SC
								INNER JOIN 
								@Numbers N
								ON N.Num = SC.colid
								OR N.num-1 = SC.colid
						WHERE	N.Num < 30
						GROUP BY 
								Id
								,Num
					)	C
						INNER JOIN sysobjects O
						ON C.id = O.Id
					WHERE C.text LIKE '%' + @textToSearch + '%'
					ORDER BY 
							ObjectName
							,ObjectType
				END
			ELSE
				BEGIN
					INSERT	@RESULTS
							(
								ObjectName
								,ObjectType
							)
					VALUES	('CERCARE CON UNA STRINGA LUNGA ALMENO 3 CARATTERI', 'ERR')
				END
		END
	ELSE
		BEGIN
			INSERT	@RESULTS
					(
						ObjectName
						,ObjectType
					)
			VALUES	('SPECIFICARE UN TESTO DA RICERCARE', 'ERR')
		END
	RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnCompareXML]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnCompareXML('<PIPPO></PIPPO>', '<PIPPO></PIPPO>')
SELECT dbo.fnCompareXML('<PIPPO></PIPPO>', '<PLUTO></PLUTO>')
*/
CREATE FUNCTION	[dbo].[fnCompareXML](@firstXML XML = NULL, @secondXML XML = NULL)
RETURNS BIT
AS
BEGIN
	DECLARE @RETVAL BIT = 0
		IF @firstXML IS NOT NULL
		AND @secondXML IS NOT NULL
			BEGIN
				SELECT @RETVAL = 
					CASE
						WHEN CONVERT(varchar(max),@firstXML) = CONVERT(varchar(max), @secondXML)
						THEN 1
						ELSE 0
					END
			END
	RETURN @RETVAL
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnCountStringOccurrences]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnCountStringOccurrences
----------------------------------------
FUNZIONE CHE EFFETTUA IL CONTEGGIO, ALL'INTERNO DELLA STRINGA PASSATA NEL PARAMETRO "@string" DELLE OCCORRENZE CORRISPONDENTI AL VALORE
SPECIFICATO NEL PARAMETRO "@charToCount"

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnCountStringOccurrences('added nvarchar(max)',' ') AS Occorrenze
SELECT dbo.fnCountStringOccurrences('Intranetinps_Lavoro.IntranetInps.dirforupload_appo','dbo.') AS Occorrenze
*/
CREATE FUNCTION [dbo].[fnCountStringOccurrences](@string varchar(MAX), @charToCount varchar(128))
RETURNS int 
AS
BEGIN
	DECLARE @RETVAL int
		IF @string IS NOT NULL
		AND @charToCount IS NOT NULL
			BEGIN
				SELECT @RETVAL = LEN(@string) - LEN(REPLACE(@string, @charToCount, ''))
			END
	RETURN @RETVAL
END

GO
/****** Object:  UserDefinedFunction [dbo].[fnDeleteXmlNode]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnDeleteXmlNode
----------------------------------------

FUNZIONE PREPOSTA ALL'ELIMINAZIONE DI UNO O PIU' NODI XML, ANCHE COMPLESSI, PRESENTI ALL'INTERNO DI UNA STRUTTURA XML PREESISTENTE.

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnDeleteXmlNode('<XmlTestoDoppio>
  <NewNode>NewContent</NewNode>
  <Label>
    <id_labeldoppio>2953</id_labeldoppio>
    <label1>Nome</label1>
    <label2>Roberto</label2>
    <id_Pagina>8754</id_Pagina>
    <id_Image>79</id_Image>
    <ordinamento>1</ordinamento>
  </Label>
  <Label>
    <id_labeldoppio>2954</id_labeldoppio>
    <label1>Cognome</label1>
    <label2>Nacchia</label2>
    <id_Pagina>8754</id_Pagina>
    <id_Image>79</id_Image>
    <ordinamento>2</ordinamento>
  </Label>
</XmlTestoDoppio>','XmlTestoDoppio')
*/
CREATE FUNCTION [dbo].[fnDeleteXmlNode]
				(
					@XmlSource XML
					,@XmlPath varchar(MAX)
				)
RETURNS XML
AS
BEGIN
	DECLARE @RETVAL XML

	IF ISNULL(CAST(@XmlSource AS nvarchar(MAX)),'') != ''
	AND ISNULL(@XmlPath,'') != ''
		BEGIN
			SET @XmlSource.modify('delete (//*[local-name()=sql:variable("@Xmlpath")])')
			SET @RETVAL = @XmlSource
		END
	
	RETURN @RETVAL
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetAllFunctions]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetAllFunctions
----------------------------------------

FUNZIONE CHE RITORNA L'ELENCO DELLE FUNZIONI PRESENTI NEL DB CORRENTE, CORREDATE DEL LORO CODICE T-SQL E LA LORO TIPOLOGIA

-- ESEMPI DI INVOCAZIONE

SELECT * FROM dbo.fnGetAllFunctions() ORDER BY FunctionType,[Name]
SELECT * FROM dbo.fnGetAllFunctions() ORDER BY [Name], FunctionType
*/
CREATE FUNCTION [dbo].[fnGetAllFunctions]()
RETURNS	@FUNCLIST TABLE
		(
			[Name] sysname
			,[Definition] varchar(MAX)
			,FunctionType varchar(255)
		)
AS
BEGIN
	INSERT	@FUNCLIST 
			(
				[Name]
				,[Definition]
				,FunctionType
			)
	SELECT
			name AS [Name]
			,definition AS [Definition]
			,type_desc AS FunctionType
	FROM	sys.sql_modules m 
			INNER JOIN 
			sys.objects o 
			ON m.object_id = o.object_id
	WHERE	type_desc like '%function%'

	RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetBannersXml]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetBannersXml(8754,NULL,NULL) AS XmlBanner
SELECT dbo.fnGetBannersXml(8754,NULL,11) AS XmlBanner
SELECT dbo.fnGetBannersXml(8754,NULL,-1) AS XmlBanner
*/
CREATE FUNCTION [dbo].[fnGetBannersXml](@Id_Pagina int = NULL, @Id_Banner int = NULL, @Id_Versione int = NULL)
RETURNS XML
AS
BEGIN
	DECLARE @RETVAL XML

	SET @RETVAL =
	(
	SELECT
			CASE
				WHEN ISNULL(@Id_Versione,0) = 0 
				THEN
				(
					SELECT
					(
						SELECT	* 
						FROM	VW_BannerObject 
						WHERE	(Id_Banner = @Id_Banner OR @ID_Banner IS NULL)
						AND		(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
						FOR XML PATH('Banner'), TYPE
					)
					FOR XML PATH(''),ROOT('XmlBanner')
				)
				WHEN ISNULL(@Id_Versione,0) = -1
				THEN  
				(
					SELECT	XmlBanner 
					FROM	VSN_Banner WITH(NOLOCK)
					WHERE	(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
					AND		Id_VsnBanner = 
							(
								SELECT	MAX(Id_VsnBanner)
								FROM	VSN_Banner WITH(NOLOCK)
								WHERE	Id_Pagina = @Id_Pagina
							)
				)
				WHEN ISNULL(@Id_Versione,0) > 0
				THEN  
				(
					SELECT	XmlBanner 
					FROM	VSN_Banner WITH(NOLOCK)
					WHERE	(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
					AND		Id_VsnBanner = @Id_Versione
				)
			END
	)
	RETURN @RETVAL
END		
		
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetColInfo]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT * FROM dbo.fnGetColInfo('VSN_TestoConImmagine')
SELECT * FROM dbo.fnGetColInfo('[Intranetinps_Lavoro].[dbo].[vwDocumentiPagine]')
SELECT * FROM dbo.fnGetColInfo('IntranetInps.dbo.KeyWord_Link')
SELECT * FROM dbo.fnGetColInfo('ImmagineGalleria')
*/
CREATE FUNCTION [dbo].[fnGetColInfo](@tableName varchar(MAX))
RETURNS @COLINFO TABLE
		(
			TableCatalog varchar(128) --NOT NULL
			,TableSchema varchar(128) --NOT NULL
			,TableName varchar(128) --NOT NULL
			,ColumnName varchar(128) --NOT NULL
			,OrdinalPosition int --NOT NULL
			,ColumnDefault varchar(MAX) --NULL
			,IsNullable BIT --NOT NULL
			,DataType varchar(128) --NOT NULL
			,MaxLength int --NULL
			,Precision int --NULL
			,Scale int --NULL
			,IsIdentity BIT --NOT NULL
			,IsPK BIT --NOT NULL
			,PK varchar(MAX) --NULL
		)
AS
BEGIN
	IF ISNULL(@tableName,'') != ''
		BEGIN
			DECLARE 
					@Catalog varchar(128)
					,@Schema varchar(128)
					,@Table varchar(128)
					,@DEBUG bit = 0

			SET @tableName = REPLACE(REPLACE(@tableName, '[',''),']','')
			
			SET @Schema = 
				CASE
					WHEN dbo.fnMiddlePart(@tableName,'.') IS NULL
					THEN 'dbo'
					ELSE dbo.fnMiddlePart(@tableName,'.')

				END

			SET @Catalog = 
				CASE
					WHEN dbo.fnLeftPart(@tableName,'.dbo') IS NULL 
					OR dbo.fnLeftPart(@tableName,'.dbo') = @tableName
					THEN DB_NAME()
					ELSE dbo.fnLeftPart(@tableName,'.dbo')
				END
			
			SET @Table = ISNULL(dbo.fnRightPart(@tableName, @Schema + '.'),@tableName)

			IF @DEBUG = 1
				BEGIN
					INSERT	@COLINFO
							(
								TableCatalog
								,TableSchema
								,TableName
							)
					SELECT
							@Catalog AS TableCatalog, @Schema AS TableSchema, @Table AS Tablet
				END
			ELSE
				BEGIN
					INSERT	@COLINFO
							(
								TableCatalog
								,TableSchema
								,TableName
								,ColumnName
								,OrdinalPosition
								,ColumnDefault
								,IsNullable
								,DataType
								,MaxLength
								,Precision
								,Scale
								,IsIdentity
								,IsPK
								,PK
							)
					SELECT	
							TC.TABLE_CATALOG AS TableCatalog
							,TC.TABLE_SCHEMA AS TableSchema
							,TC.TABLE_NAME AS TableName
							,TC.COLUMN_NAME AS Columname
							,TC.ORDINAL_POSITION AS OrdinalPosition
							,TC.COLUMN_DEFAULT AS ColumnDefault
							,IsNullable = CASE TC.IS_NULLABLE WHEN 'YES' THEN 1 ELSE 0 END
							,TC.DATA_TYPE AS DataType
							,TC.CHARACTER_MAXIMUM_LENGTH AS MaxLength
							,TC.NUMERIC_PRECISION AS Precision
							,TC.NUMERIC_SCALE AS Scale
							,IsIdentity = COLUMNPROPERTY(object_id(TC.TABLE_SCHEMA + '.' + TC.TABLE_NAME), TC.COLUMN_NAME, 'IsIdentity')
							,IsPK = 
								CASE
									WHEN TC.COLUMN_NAME = CCU.COLUMN_NAME
									THEN 1
									ELSE 0
								END
							,PK =
								CASE
									WHEN TC.COLUMN_NAME = CCU.COLUMN_NAME
									THEN ccu.CONSTRAINT_NAME
									ELSE ''
								END
					FROM	INFORMATION_SCHEMA.COLUMNS TC
							LEFT JOIN
							INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TCN
							ON TCN.TABLE_CATALOG = TC.TABLE_CATALOG
							AND TCN.TABLE_NAME = TC.TABLE_NAME
							AND TCN.TABLE_SCHEMA = TC.TABLE_SCHEMA
							LEFT JOIN 
							INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
							ON TCN.CONSTRAINT_NAME = CCU.CONSTRAINT_NAME
					WHERE	TCN.TABLE_CATALOG = @Catalog
							AND TCN.TABLE_SCHEMA = @schema
							AND TCN.TABLE_NAME = @table
							AND TCN.CONSTRAINT_TYPE = 'PRIMARY KEY'
			END
		END

		RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetColumnDataType]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
-----------------------------------------
SELECT	
		fieldName
		,fieldType
		,fieldLenght
		,fieldPrecision
		,fieldScale
		,xmlPattern
		,fieldWithLength
		,OrdinalPosition
		,ColumnDefault
		,IsNullable
		,IsIdentity
		,IsPK
		,PK
FROM	fnGetColumnDataType('VSN_Pagina',NULL) 
WHERE	fieldName = 'idVsnPagina' -- TABELLA SU DATABASE CORRENTE
-----------------------------------------
DECLARE 
		@fieldList varchar(MAX)
		,@fieldListWithDataType varchar(MAX)
SELECT 
		@fieldList = COALESCE(@fieldList, '') + fieldName + ', '
		,@fieldListWithDataType = COALESCE(@fieldListWithDataType, '') + ' ' + fieldWithLength
FROM	fnGetColumnDataType('Pagine',NULL) 
PRINT(dbo.fnTrimCommas(@fieldList) + CHAR(13) + dbo.fnTrimCommas(@fieldListWithDataType))
-----------------------------------------
SELECT * FROM fnGetColumnDataType('VSN_Pagina',NULL) -- TABELLA SU DATABASE CORRENTE
SELECT * FROM fnGetColumnDataType('[Intranetinps_Richieste].[dbo].[VSN_TestoConImmagine]',NULL) -- TABELLA SU DATABASE CORRENTE (SPECIFICATO NELLA FORMA A TRE PARTI)
SELECT * FROM fnGetColumnDataType('[Intranetinps_Lavoro].[dbo].[TestoConImmagine]',NULL) -- TABELLA SU DATABASE ESTERNO
SELECT * FROM fnGetColumnDataType('vx_gruppi','T.') -- VISTA SU DATABASE CORRENTE; ALIAS SU CIASCUN NOME DI COLONNA
SELECT * FROM fnGetColumnDataType('[Intranetinps_Lavoro].[dbo].[vwDocumentiPagine]','T.') -- VISTA SU DATABASE REMOTO
SELECT * FROM fnGetColumnDataType('[Intranetinps].[dbo].[KeyWord_Link]','T.') -- VISTA SU DATABASE REMOTO
*/
CREATE FUNCTION [dbo].[fnGetColumnDataType](@objectName varchar(MAX)=NULL, @AliasPrefix varchar(20) = NULL)
RETURNS @FIELDINFO TABLE
		(
			fieldName varchar(128)
			,castedFieldName varchar(128)
			,fieldType varchar(128)
			,fieldLenght int
			,fieldPrecision int
			,fieldScale int
			,xmlPattern varchar(MAX)
			,fieldWithLength varchar(MAX)
			,OrdinalPosition int --NOT NULL
			,ColumnDefault varchar(MAX) --NULL
			,IsNullable BIT --NOT NULL
			,IsIdentity BIT --NOT NULL
			,IsPK BIT --NOT NULL
			,PK varchar(MAX) --NULL
		)
AS
BEGIN
	IF ISNULL(@objectName,'') != ''
		BEGIN
			SET @AliasPrefix = ISNULL(@AliasPrefix,'')

			IF dbo.fnCountStringOccurrences(@objectName, '.') > 1
			AND (@objectName LIKE '%IntranetInps.%' OR @objectName LIKE '%IntranetInps].%')
				BEGIN
					INSERT	@FIELDINFO
							(
								fieldName
								,castedFieldName
								,fieldType
								,fieldLenght
								,fieldPrecision
								,fieldScale
								,xmlPattern
								,fieldWithLength
								,OrdinalPosition
								,ColumnDefault
								,IsNullable
								,IsIdentity
								,IsPK
								,PK
							)
					SELECT 
							TC.COLUMN_NAME AS fieldName
							,castedFieldName =
								CASE
									WHEN DATA_TYPE IN('text', 'ntext', 'xml')
									THEN 'CAST(' + @AliasPrefix + TC.COLUMN_NAME + ' AS varchar(MAX)) AS ' + TC.COLUMN_NAME
									ELSE @AliasPrefix + TC.COLUMN_NAME
								END
							,TC.DATA_TYPE AS fieldType
							,TC.CHARACTER_MAXIMUM_LENGTH AS fieldLenght
							,TC.NUMERIC_PRECISION AS fieldPrecision
							,TC.NUMERIC_SCALE AS fieldScale
							,@AliasPrefix + TC.COLUMN_NAME + ' = XmlData.value(''(//' + TC.COLUMN_NAME + ')[1]'',''' + 
								CASE 
									WHEN TC.DATA_TYPE = 'text'
									THEN 'varchar(MAX)''' 
									WHEN TC.DATA_TYPE = 'ntext'
									THEN 'nvarchar(MAX)''' 
									WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
									AND TC.CHARACTER_MAXIMUM_LENGTH = -1
									THEN TC.DATA_TYPE + '(MAX)'''
									WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
									AND TC.CHARACTER_MAXIMUM_LENGTH > 0
									THEN TC.DATA_TYPE + '(' + CAST(TC.CHARACTER_MAXIMUM_LENGTH AS varchar(4)) + ')'''
									WHEN TC.DATA_TYPE IN ('decimal','numeric')
									THEN TC.DATA_TYPE + '(' + CAST(TC.NUMERIC_PRECISION AS varchar(4)) + ',' + CAST(TC.NUMERIC_SCALE AS varchar(4)) + ')'''
									ELSE TC.DATA_TYPE + ''''
								END +
								',' AS xmlPattern
							,@AliasPrefix + TC.COLUMN_NAME + ' ' +
								CASE 
									WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
									AND TC.CHARACTER_MAXIMUM_LENGTH = -1
									THEN TC.DATA_TYPE + '(MAX)'
									WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
									AND TC.CHARACTER_MAXIMUM_LENGTH > 0
									THEN TC.DATA_TYPE + '(' + CAST(TC.CHARACTER_MAXIMUM_LENGTH AS varchar(4)) + ')'
									WHEN TC.DATA_TYPE IN ('decimal','numeric')
									THEN TC.DATA_TYPE + '(' + CAST(TC.NUMERIC_PRECISION AS varchar(4)) + ',' + CAST(TC.NUMERIC_SCALE AS varchar(4)) + ')'
									ELSE TC.DATA_TYPE
								END +
								'),' AS fieldWithLength
							,TC.ORDINAL_POSITION AS OrdinalPosition
							,TC.COLUMN_DEFAULT AS ColumnDefault
							,IsNullable = CASE TC.IS_NULLABLE WHEN 'YES' THEN 1 ELSE 0 END
							,IsIdentity = COLUMNPROPERTY(object_id(TC.TABLE_SCHEMA + '.' + TC.TABLE_NAME), TC.COLUMN_NAME, 'IsIdentity')
							,IsPK = 
								CASE
									WHEN TC.COLUMN_NAME = CCU.COLUMN_NAME
									THEN 1
									ELSE 0
								END
							,PK =
								CASE
									WHEN TC.COLUMN_NAME = CCU.COLUMN_NAME
									THEN ccu.CONSTRAINT_NAME
									ELSE ''
								END
					FROM	IntranetInps.INFORMATION_SCHEMA.COLUMNS TC
							LEFT JOIN
							IntranetInps.INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TCN
							ON TCN.TABLE_CATALOG = TC.TABLE_CATALOG
							AND TCN.TABLE_NAME = TC.TABLE_NAME
							AND TCN.TABLE_SCHEMA = TC.TABLE_SCHEMA
							LEFT JOIN 
							IntranetInps.INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
							ON TCN.CONSTRAINT_NAME = CCU.CONSTRAINT_NAME
					WHERE	TC.table_name = dbo.fnpurge(@objectName) 
					AND		TC.table_schema = 'dbo'
				END 
			ELSE
				BEGIN
					IF dbo.fnCountStringOccurrences(@objectName, '.') > 1
					AND (@objectName LIKE '%IntranetInps_Lavoro.%' OR @objectName LIKE '%IntranetInps_Lavoro].%')
						BEGIN
							INSERT	@FIELDINFO
									(
										fieldName
										,castedFieldName
										,fieldType
										,fieldLenght
										,fieldPrecision
										,fieldScale
										,xmlPattern
										,fieldWithLength
										,OrdinalPosition
										,ColumnDefault
										,IsNullable
										,IsIdentity
										,IsPK
										,PK
									)
							SELECT 
									TC.COLUMN_NAME AS fieldName
									,castedFieldName =
										CASE
											WHEN TC.DATA_TYPE IN('text', 'ntext', 'xml')
											THEN 'CAST(' + @AliasPrefix + TC.COLUMN_NAME + ' AS varchar(MAX)) AS ' + TC.COLUMN_NAME
											ELSE @AliasPrefix + TC.COLUMN_NAME
										END
									,TC.DATA_TYPE AS fieldType
									,TC.CHARACTER_MAXIMUM_LENGTH AS fieldLenght
									,TC.NUMERIC_PRECISION AS fieldPrecision
									,TC.NUMERIC_SCALE AS fieldScale
									,@AliasPrefix + TC.COLUMN_NAME + ' = XmlData.value(''(//' + TC.COLUMN_NAME + ')[1]'',''' + 
										CASE 
											WHEN TC.DATA_TYPE = 'text'
											THEN 'varchar(MAX)''' 
											WHEN TC.DATA_TYPE = 'ntext'
											THEN 'nvarchar(MAX)''' 
											WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
											AND TC.CHARACTER_MAXIMUM_LENGTH = -1
											THEN TC.DATA_TYPE + '(MAX)'''
											WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
											AND TC.CHARACTER_MAXIMUM_LENGTH > 0
											THEN TC.DATA_TYPE + '(' + CAST(TC.CHARACTER_MAXIMUM_LENGTH AS varchar(4)) + ')'''
											WHEN TC.DATA_TYPE IN ('decimal','numeric')
											THEN TC.DATA_TYPE + '(' + CAST(TC.NUMERIC_PRECISION AS varchar(4)) + ',' + CAST(TC.NUMERIC_SCALE AS varchar(4)) + ')'''
											ELSE TC.DATA_TYPE + ''''
										END +
										'),' AS xmlPattern
									,@AliasPrefix + TC.COLUMN_NAME + ' ' +
										CASE 
											WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
											AND TC.CHARACTER_MAXIMUM_LENGTH = -1
											THEN TC.DATA_TYPE + '(MAX)'
											WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
											AND TC.CHARACTER_MAXIMUM_LENGTH > 0
											THEN TC.DATA_TYPE + '(' + CAST(TC.CHARACTER_MAXIMUM_LENGTH AS varchar(4)) + ')'
											WHEN TC.DATA_TYPE IN ('decimal','numeric')
											THEN TC.DATA_TYPE + '(' + CAST(TC.NUMERIC_PRECISION AS varchar(4)) + ',' + CAST(TC.NUMERIC_SCALE AS varchar(4)) + ')'
											ELSE TC.DATA_TYPE
										END +
										',' AS fieldWithLength
									,TC.ORDINAL_POSITION AS OrdinalPosition
									,TC.COLUMN_DEFAULT AS ColumnDefault
									,IsNullable = CASE TC.IS_NULLABLE WHEN 'YES' THEN 1 ELSE 0 END
									,IsIdentity = COLUMNPROPERTY(object_id(TC.TABLE_SCHEMA + '.' + TC.TABLE_NAME), TC.COLUMN_NAME, 'IsIdentity')
									,IsPK = 
										CASE
											WHEN TC.COLUMN_NAME = CCU.COLUMN_NAME
											THEN 1
											ELSE 0
										END
									,PK =
										CASE
											WHEN TC.COLUMN_NAME = CCU.COLUMN_NAME
											THEN ccu.CONSTRAINT_NAME
											ELSE ''
										END
							FROM	IntranetInps_Lavoro.INFORMATION_SCHEMA.COLUMNS TC
									LEFT JOIN
									IntranetInps_Lavoro.INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TCN
									ON TCN.TABLE_CATALOG = TC.TABLE_CATALOG
									AND TCN.TABLE_NAME = TC.TABLE_NAME
									AND TCN.TABLE_SCHEMA = TC.TABLE_SCHEMA
									LEFT JOIN 
									IntranetInps_Lavoro.INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
									ON TCN.CONSTRAINT_NAME = CCU.CONSTRAINT_NAME
							WHERE	TC.table_name = dbo.fnpurge(@objectName) 
							AND		TC.table_schema = 'dbo'
						END 
					ELSE
						BEGIN
							IF dbo.fnCountStringOccurrences(@objectName, '.') > 1
							AND (@objectName LIKE '%IntranetInps_Richieste.%' OR @objectName LIKE '%IntranetInps_Richieste].%')
								BEGIN
									INSERT	@FIELDINFO
											(
												fieldName
												,castedFieldName
												,fieldType
												,fieldLenght
												,fieldPrecision
												,fieldScale
												,xmlPattern
												,fieldWithlength
												,OrdinalPosition
												,ColumnDefault
												,IsNullable
												,IsIdentity
												,IsPK
												,PK
											)
									SELECT 
											TC.COLUMN_NAME AS fieldName
											,castedFieldName =
												CASE
													WHEN TC.DATA_TYPE IN('text', 'ntext', 'xml')
													THEN 'CAST(' + @AliasPrefix + TC.COLUMN_NAME + ' AS varchar(MAX)) AS ' + TC.COLUMN_NAME
													ELSE @AliasPrefix + TC.COLUMN_NAME
												END
											,TC.DATA_TYPE AS fieldType
											,TC.CHARACTER_MAXIMUM_LENGTH AS fieldLenght
											,TC.NUMERIC_PRECISION AS fieldPrecision
											,TC.NUMERIC_SCALE AS fieldScale
											,@AliasPrefix + TC.COLUMN_NAME + ' = XmlData.value(''(//' + TC.COLUMN_NAME + ')[1]'',''' + 
												CASE 
													WHEN TC.DATA_TYPE = 'text'
													THEN 'varchar(MAX)''' 
													WHEN TC.DATA_TYPE = 'ntext'
													THEN 'nvarchar(MAX)''' 
													WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
													AND TC.CHARACTER_MAXIMUM_LENGTH = -1
													THEN TC.DATA_TYPE + '(MAX)'''
													WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
													AND TC.CHARACTER_MAXIMUM_LENGTH > 0
													THEN TC.DATA_TYPE + '(' + CAST(TC.CHARACTER_MAXIMUM_LENGTH AS varchar(4)) + ')'''
													WHEN TC.DATA_TYPE IN ('decimal','numeric')
													THEN TC.DATA_TYPE + '(' + CAST(TC.NUMERIC_PRECISION AS varchar(4)) + ',' + CAST(TC.NUMERIC_SCALE AS varchar(4)) + ')'''
													ELSE TC.DATA_TYPE + ''''
												END +
												'),' AS xmlPattern
											,@AliasPrefix + TC.COLUMN_NAME + ' ' +
												CASE 
													WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
													AND TC.CHARACTER_MAXIMUM_LENGTH = -1
													THEN TC.DATA_TYPE + '(MAX)'
													WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
													AND TC.CHARACTER_MAXIMUM_LENGTH > 0
													THEN TC.DATA_TYPE + '(' + CAST(TC.CHARACTER_MAXIMUM_LENGTH AS varchar(4)) + ')'
													WHEN TC.DATA_TYPE IN ('decimal','numeric')
													THEN TC.DATA_TYPE + '(' + CAST(TC.NUMERIC_PRECISION AS varchar(4)) + ',' + CAST(TC.NUMERIC_SCALE AS varchar(4)) + ')'
													ELSE TC.DATA_TYPE
												END +
												',' AS fieldWithLength
											,TC.ORDINAL_POSITION AS OrdinalPosition
											,TC.COLUMN_DEFAULT AS ColumnDefault
											,IsNullable = CASE TC.IS_NULLABLE WHEN 'YES' THEN 1 ELSE 0 END
											,IsIdentity = COLUMNPROPERTY(object_id(TC.TABLE_SCHEMA + '.' + TC.TABLE_NAME), TC.COLUMN_NAME, 'IsIdentity')
											,IsPK = 
												CASE
													WHEN TC.COLUMN_NAME = CCU.COLUMN_NAME
													THEN 1
													ELSE 0
												END
											,PK =
												CASE
													WHEN TC.COLUMN_NAME = CCU.COLUMN_NAME
													THEN ccu.CONSTRAINT_NAME
													ELSE ''
												END
									FROM	IntranetInps_Richieste.INFORMATION_SCHEMA.COLUMNS TC
											LEFT JOIN
											IntranetInps_Richieste.INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TCN
											ON TCN.TABLE_CATALOG = TC.TABLE_CATALOG
											AND TCN.TABLE_NAME = TC.TABLE_NAME
											AND TCN.TABLE_SCHEMA = TC.TABLE_SCHEMA
											LEFT JOIN 
											IntranetInps_Richieste.INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
											ON TCN.CONSTRAINT_NAME = CCU.CONSTRAINT_NAME
									WHERE	TC.table_name = dbo.fnpurge(@objectName) 
									AND		TC.table_schema = 'dbo'
								END
							ELSE 
								BEGIN
									INSERT	@FIELDINFO
											(
												fieldName
												,castedFieldName
												,fieldType
												,fieldLenght
												,fieldPrecision
												,fieldScale
												,xmlPattern
												,fieldWithLength
												,OrdinalPosition
												,ColumnDefault
												,IsNullable
												,IsIdentity
												,IsPK
												,PK
											)
									SELECT 
											c.name AS fieldName
											,castedFieldName =
												CASE
													WHEN t.name IN('text', 'ntext', 'xml')
													THEN 'CAST(' + @AliasPrefix + c.name  + ' AS varchar(MAX)) AS ' + c.name
													ELSE @AliasPrefix + c.name 
												END
											,t.name AS fieldType
											,c.max_length AS fieldLenght
											,c.precision AS fieldPrecision
											,c.scale AS fieldScale
											,@AliasPrefix + c.name + ' = XmlData.value(''(//' + c.name + ')[1]'',''' + 
												CASE
													WHEN t.name = 'text'
													THEN 'varchar(MAX)''' 
													WHEN t.name = 'ntext'
													THEN 'nvarchar(MAX)''' 
													WHEN t.name IN ('char','varchar', 'nchar', 'nvarchar')
													AND c.max_length = -1
													THEN t.name + '(MAX)'''
													WHEN t.name IN ('char','varchar', 'nchar', 'nvarchar')
													AND c.max_length > 0
													THEN t.name + '(' + CAST(c.max_length AS varchar(4)) + ')'''
													WHEN t.name IN ('decimal','numeric')
													THEN t.name + '(' + CAST(c.precision AS varchar(4)) + ',' + CAST(c.scale AS varchar(4)) + ')'''
													ELSE t.name + ''''
												END +
												'),' AS xmlPattern
											,@AliasPrefix + c.name + ' ' +
												CASE 
													WHEN t.name IN ('char','varchar', 'nchar', 'nvarchar')
													AND c.max_length = -1
													THEN t.name + '(MAX)'
													WHEN t.name IN ('char','varchar', 'nchar', 'nvarchar')
													AND c.max_length > 0
													THEN t.name + '(' + CAST(c.max_length AS varchar(4)) + ')'
													WHEN t.name IN ('decimal','numeric')
													THEN t.name + '(' + CAST(c.precision AS varchar(4)) + ',' + CAST(c.scale AS varchar(4)) + ')'
													ELSE t.name
												END +
												',' AS fieldWithLength
											,OrdinalPosition = c.column_id
											,ColumnDefault = NULL
											,IsNullable = c.is_nullable
											,IsIdentity = c.is_identity
											,IsPK = 0
											,PK = NULL
									FROM	sys.columns c
											JOIN 
											sys.types t
											ON t.user_type_id = c.user_type_id
											AND t.system_type_id = c.system_type_id
									WHERE	object_id = OBJECT_ID(@objectName)
								END
							END
						END
		END
	
	RETURN 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetCSVfieldsList]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetCSVfieldsList
----------------------------------------

FUNZIONE CHE RITORNA UNA STRINGA, COMPOSTA DINAMICAMENTE, CONTENENTE L'ELENCO DEI CAMPI - E IL LORO TIPO DI DATO - PRESENTI NELLA TABELLA SPECIFICATA.
L'ELENCO, SE NON DIVERSAMENTE SPECIFICATO (QUINDI CON IL PARAMETRO "@separator" VALORIZZATO A NULL) VEDRA' I CAMPI SEPARATI TRA LORO DA UN PUNTO E VIRGOLA.

L'ELENCO RITORNATO NON VEDRA' PRESENTI:
- LA COLONNA IL CUI NOME CORRISPONDE AL NOME SPECIFICATO NEL PARAMETRO "@primaryIdFieldName" 
- I NOMI DI COLONNA CORRISPONDENTI A CAMPI DI TIPO XML 

QUESTO PERCHE' LA PRESENTE FUNZIONE E' STATA APPOSITAMENTE DISEGNATA PER POTER ESSERE IMPIEGATA NELLA STORED PROCEDURE DI GENERAZIONE DI CODICE AUTOMATICO
DENOMINATA "spGenSQLCodeForXmlGet"

PER AVERE L'ELENCO *COMPLETO* DEI CAMPI, SEPARATO DA VIRGOLE, PRESENTI IN UNA TABELLA SI VEDA LA FUNZIONE "dbo.fnGetTableFields"

-- ESEMPI DI INVOCAZIONE

SELECT	dbo.fnGetCSVfieldsList('dbo.VSN_Link', 'IdVsnLink', NULL) AS CSVFieldList
*/
CREATE FUNCTION	[dbo].[fnGetCSVfieldsList]
				(
					@tableName varchar(MAX) = NULL
					,@primaryIdFieldName varchar(128) = NULL
					,@separator CHAR(1) = NULL
				)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @RETVAL varchar(MAX) = NULL

	IF ISNULL(@tableName,'') != ''
	AND ISNULL(@primaryIdFieldName,'') != ''
		BEGIN

			DECLARE 
					@FieldList varchar(MAX)

			SET		@separator = ISNULL(@separator,';')

			SELECT	@FieldList = COALESCE(@FieldList,'') + ColumnName + ' ' + DataType + ';'
			FROM	dbo.fnGetColInfo(@tableName)
			WHERE	DataType != 'xml'
			AND		ColumnName != @primaryIdFieldName
			
			SET		@FieldList = dbo.fnTrimSeparator(@FieldList,';')
			SET		@RETVAL = @FieldList
		END

	RETURN @RETVAL

END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetDualLevelXml]    Script Date: 23/06/2017 11:07:20 ******/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetExplicitXmlTableFields]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetExplicitXmlTableFields
----------------------------------------

****************
* DA TERMINARE *
****************

FUNZIONE PREPOSTA ALLA RAPPRESENTAZIONE IN FORMATO XML EXPLICIT DI UNA QUALSIASI TABELLA SECONDO SPECIFICI LIVELLI 
DI ANNIDAMENTO

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnGetExplicitXmlTableFields('Link_RichiesteCancellazione',1) AS fieldsList
*/
CREATE FUNCTION	[dbo].[fnGetExplicitXmlTableFields](@tableName varchar(128) = NULL, @level int = NULL)
RETURNS Nvarchar(MAX)
AS
BEGIN
	DECLARE	
			@RETVAL nvarchar(MAX) = NULL
			,@purgedTableName nvarchar(MAX)
			,@orderby nvarchar(MAX)
			,@strLevel nvarchar(5)
			,@masterTag nvarchar(MAX)

	IF ISNULL(@tableName,'') != ''
	AND ISNULL(@level,0) > 0
		BEGIN
			SET @purgedTableName = CAST(dbo.fnpurge(@tableName) AS Nvarchar(MAX))
			SET @masterTag = CAST('Xml' + @purgedTableName AS Nvarchar(MAX))
			SET @strLevel = CAST('!' + CAST(ISNULL(@level,1) AS varchar(5)) + '!' AS Nvarchar(5))
			
			SELECT	TOP 1 @orderby =
					CAST
					(
						'ORDER BY [' + @masterTag + @strLevel + c.Name + '!element]' + CHAR(13) 
						AS nvarchar(MAX)
					)
			FROM	SYS.OBJECTS O
					INNER JOIN
					SYS.COLUMNS C
					ON O.object_id = C.object_id
			WHERE	O.name = @purgedTableName
			ORDER BY C.column_id

			SELECT	@RETVAL = 
					CAST
					(
						COALESCE(@RETVAL, '') + ',' + c.Name + ' AS [' + @masterTag + @strLevel + c.Name + '!element]' + CHAR(13)
						AS Nvarchar(MAX)
					)
			FROM	SYS.OBJECTS O
					INNER JOIN
					SYS.COLUMNS C
					ON O.object_id = C.object_id
			WHERE	O.name = @purgedTableName
			ORDER BY C.column_id

			SELECT	@RETVAL = 
					CAST
					(
						'SELECT 1 AS TAG, NULL AS parent' + CHAR(13) +
						@RETVAL +
						'FROM ' + @tableName + ' WITH(NOLOCK)' + CHAR(13) +
						@orderby +
						'FOR XML EXPLICIT, ROOT(''Xml' + @purgedTableName + '''), TYPE' + CHAR(13)
						AS Nvarchar(MAX)
					)
		END
	RETURN @RETVAL
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetGallerieXml]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetGallerieXml
----------------------------------------

FUNZIONE CHE ESTRAE LA STRUTTURA XML DALLE TABELLE PREDISPOSTE PER RECEPIRE I DATI DELLE GALLERIE.
LA MODALITA' DI ESTRAZIONE VARIA A SECONDA DELLA VALORIZZAZIONE DEL PARAMETRO "@Id_Versione": SE QUESTO E' VALORIZZATO A NULL I DATI
SARANNO PRELEVATI DALLA TABELLA "Galleria" E SUE TABELLE ACCESSORIE; IN CASO CONTRARIO I DATI SARANNO PRELEVATI DALLA TABELLA DI VERSIONAMENTO "VSN_Galleria"
E L'OUTPUT SARA' FORMATTATO IN MODO CHE ESSO SIA ADERENTE AL MODELLO XSD DEL PORTALE STATICO

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnGetGallerieXml(8754,1454,null) AS XmlGalleria
SELECT dbo.fnGetGallerieXml(8754,1109170,36) AS XmlGalleria
*/
CREATE FUNCTION [dbo].[fnGetGallerieXml](@Id_Pagina int = NULL, @Id_Galleria int = NULL, @Id_Versione int = NULL)
RETURNS XML
AS
BEGIN
	DECLARE 
			@RETVAL XML
			,@XmlSource XML
			,@RootNode XML

	IF ISNULL(@Id_Versione,0) > 0
		BEGIN
			SELECT	
					@XmlSource = XmlGalleria
			FROM	VSN_Galleria WITH(NOLOCK)
			WHERE	(IdGalleria = @Id_Galleria OR @Id_Galleria IS NULL)
			AND		Id_VsnGalleria = @Id_Versione

			SET @RootNode = @XmlSource
			SET @RootNode.modify('delete //Immagini')
		END

	SET @RETVAL =
	(
	SELECT
			CASE
				WHEN ISNULL(@Id_Versione,0) = 0 
				THEN
				(
					SELECT
					(
						SELECT	G.*
								,dbo.fnGetLinksInGalleriaXml(PG.Id_Pagina, PG.Id_Galleria, NULL)
								,dbo.fnGetImmaginiInGalleriaXml(PG.Id_Pagina, PG.Id_Galleria, NULL)
						FROM	Galleria G WITH(NOLOCK)
								INNER JOIN
								VW_PagineGallerie_REL PG
								ON G.Id_Galleria = PG.Id_Galleria
						WHERE	(PG.Id_Galleria = @Id_Galleria OR @Id_Galleria IS NULL)
						AND		(PG.Id_Pagina = @Id_Pagina OR @Id_Pagina IS NULL)
						FOR XML PATH('Galleria'), TYPE
					)
				)
				WHEN ISNULL(@Id_Versione,0) > 0
				THEN  
				(
					SELECT
							Galleria.query('(//Id_Galleria)[1]')
							,Galleria.query('(//Titolo)[1]')
							,CASE WHEN @RootNode.exist('/url') = 1 THEN Galleria.query('(//url)[1]') ELSE '' END AS Url 
							,CASE WHEN @RootNode.exist('/Id_Link') = 1 THEN Galleria.query('(//Id_Link)[1]') ELSE '0' END AS Id_Link 
							,CASE WHEN @RootNode.exist('/RowNumber') = 1 THEN Galleria.query('(//RowNumber)[1]') ELSE '0' END AS RowNumber 
							,CASE WHEN @RootNode.exist('/TotalRow') = 1 THEN Galleria.query('(//TotalRow)[1]') ELSE '0' END AS TotalRow 
							,
							(
								SELECT	
										CAST
										(
											REPLACE
											(
												REPLACE
												(
													CAST
													(
														(
														SELECT
																Immagine.query('.')
																,0 AS RowNumber
																,0 AS TotalRows
														FROM	@XmlSource.nodes('//Immagine') AS X(Immagine)
														FOR XML PATH(''), ROOT('Immagini'), TYPE
														)
														AS varchar(MAX)
													)
													,'</Immagine><RowNumber>'
													,'<RowNumber>'
												)
												,'</TotalRows>'
												,'</TotalRows></Immagine>'
											) 
											AS XML
										)
							)
					FROM	@RootNode.nodes('/') AS Y(Galleria)
					FOR XML	PATH(''), ROOT('XmlGalleria'), TYPE
				)
			END
	)

	IF ISNULL(@Id_Versione,0) > 0
		BEGIN
			SET @RETVAL.modify('delete //Immagine/Id_Galleria')
			SET @RETVAL.modify('delete //Immagine/IdArea')
			SET @RETVAL.modify('delete //Immagine/IdCartella')

			SET @RETVAL = dbo.fnReplaceXmlNodeName(@RETVAL,'url','Url')
			SET @RETVAL = dbo.fnReplaceXmlNodeName(@RETVAL,'Id_Galleria','Id_galleria')
			SET @RETVAL = dbo.fnReplaceXmlNodeName(@RETVAL,'Immagine','ImmagineGalleria')
			SET @RETVAL = dbo.fnReplaceXmlNodeName(@RETVAL,'XmlGalleria','Galleria')
		END

	RETURN @RETVAL
END		

GO
/****** Object:  UserDefinedFunction [dbo].[fnGetIDcolumn]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetIDcolumn
----------------------------------------

FUNZIONE ATTA A RITORNARE LA COLONNA IDENTITY (QUANDO PRESENTE) DELLA TABELLA SPECIFICATA NEL PARAMETRO "@tableName". SE NON SONO PRESENTI
COLONNE DI TIPO IDENTITY, LA FUNZIONE RITORNERA' LA PRIMA COLONNA DI TIPO PRIMARY KEY

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnGetIDcolumn('Aree') AS ID
SELECT dbo.fnGetIDcolumn('Link') AS ID
SELECT dbo.fnGetIDcolumn('Pagine') AS ID
SELECT dbo.fnGetIDcolumn('TestoConImmagine') AS ID
SELECT dbo.fnGetIDcolumn('TestoDoppio') AS ID
*/
CREATE FUNCTION [dbo].[fnGetIDcolumn](@tableName varchar(128)=NULL)
RETURNS varchar(128)
AS
BEGIN
	DECLARE	@RETVAL varchar(128) = NULL

	IF ISNULL(@tableName,'') != ''
		BEGIN
			SELECT	@RETVAL = 
					ColumnName 
			FROM	dbo.fnGetIDcolumnProp(@tableName)
		END
	RETURN @RETVAL
END


GO
/****** Object:  UserDefinedFunction [dbo].[fnGetIDcolumnProp]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetIDcolumnProp
----------------------------------------

FUNZIONE CHE RITORNA UNA TABELLA A DUE COLONNE RIPORTANTI (QUANDO PRESENTI) SIA IL NOME DEL PRIMO CAMPO IDENTITY E/O PRIMARY KEY 
DELLA TABELLA SPECIFICATA NONCHÉ UN VALORE BOOLEANO SPECIFICANTE SE IL CAMPO È DI TIPO IDENTITY O MENO

-- ESEMPI DI INVOCAZIONE

SELECT ColumnName AS ID FROM dbo.fnGetIDcolumnProp('Aree')
SELECT * FROM dbo.fnGetIDcolumnProp('Aree')

SELECT ColumnName AS ID FROM dbo.fnGetIDcolumnProp('Link')
SELECT * FROM dbo.fnGetIDcolumnProp('Link')

SELECT * FROM dbo.fnGetIDcolumnProp('Pagine')
SELECT * FROM dbo.fnGetIDcolumnProp('TestoConImmagine')
SELECT * FROM dbo.fnGetIDcolumnProp('TestoDoppio')
*/
CREATE FUNCTION [dbo].[fnGetIDcolumnProp](@tableName varchar(128)=NULL)
RETURNS @IDproperties TABLE
	(
		ColumnName varchar(128)
		,IsIdentity bit
	)
AS
BEGIN
	DECLARE	@RETVAL varchar(128) = NULL

	IF ISNULL(@tableName,'') != ''
		BEGIN

			INSERT	@IDProperties
					(
						ColumnName
						,IsIdentity
					)
			SELECT	TOP 1
					A.columnname
					,A.isIdentity
			FROM
			(
				-- RICERCA DELLA COLONNA IDENTITY
				SELECT	
						ic.name AS columnname
						,1 AS isIdentity
						,0 AS ColumnOrder
				FROM	sys.objects AS t
						INNER JOIN 
						sys.identity_columns ic 
						ON t.object_id = ic.object_id
				WHERE	t.Name = @tableName

				UNION

				-- RICERCA DELLA PRIMARY KEY PIU' SIMILE AD UNA IDENTITY
				SELECT
						c.name AS columnname
						,0 AS isIdentity
						,c.column_id AS ColumnOrder
				FROM	sys.objects AS t
						INNER JOIN 
						sys.columns c 
						ON t.object_id = c.object_id
						INNER JOIN
						sys.indexes i 
						on i.object_id = t.object_id
				WHERE	t.Name = @tableName
				AND		i.is_primary_key = 1
				AND		i.is_unique = 1
				AND		c.is_nullable = 0
				AND		c.system_type_id = 56
			) A
			ORDER BY A.ColumnOrder
		END

	RETURN
	
	/*
	-- BASE PER PROVE
	SELECT
			t.name AS tablename
			,c.name AS columnname
			,ic.name AS identitycolumnname
			,i.name AS keyname
			,C.*
	FROM	sys.objects AS t
			INNER JOIN 
			sys.columns c 
			ON t.object_id = c.object_id
			LEFT JOIN 
			sys.identity_columns ic 
			ON t.object_id = ic.object_id
			INNER JOIN
			sys.indexes i 
			on i.object_id = t.object_id
	WHERE	1=1--t.Name = 'Link'
	AND		i.is_primary_key = 1
	AND		i.is_unique = 1
	AND		c.is_nullable = 0
	AND		c.system_type_id = 56
	*/

END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetImmaginiInGalleriaXml]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetImmaginiInGalleriaXml(8754,NULL,NULL) AS XmlLinkInGalleria
*/
CREATE FUNCTION [dbo].[fnGetImmaginiInGalleriaXml](@Id_Pagina int=NULL,@Id_Galleria int = NULL, @Id_ImmagineGalleria int=NULL)
RETURNS XML
AS
BEGIN
	DECLARE @RETVAL XML

	SET @RETVAL =
	(
		SELECT
		(
			SELECT	*
			FROM	VW_ImmagineInGalleria 
			WHERE	(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
			AND		(Id_Galleria = @Id_Galleria OR @ID_Galleria IS NULL)
			AND		(Id_ImmagineGalleria = @Id_ImmagineGalleria OR @Id_ImmagineGalleria IS NULL)
			FOR XML PATH('Immagine'),ROOT('ImmaginiInGalleria')
		)
	)
	RETURN @RETVAL
END		
		
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetInfoPaginaXml]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetInfoPaginaXml(8754, 8)
*/
CREATE FUNCTION [dbo].[fnGetInfoPaginaXml](@Id_Pagina int = NULL, @Versione int = NULL)
RETURNS XML
AS
BEGIN
	DECLARE @RETVAL XML

	SET @RETVAL =
	(
		SELECT
				NomePagina = ISNULL(C.value('./NomePagina[1]','varchar(max)'),'')
				,Voce = ISNULL(C.value('./Voce[1]','varchar(max)'),'')
				,Categoria = ISNULL(C.value('./Categoria[1]','int'),0)
				,Data = C.value('./Data[1]','datetime')
				,Idlink = ISNULL(C.value('./Idlink[1]','int'),0)
				,areaProtetta = ISNULL(C.value('./areaProtetta[1]','int'),0)
				,idPageLogin = ISNULL(C.value('./idPageLogin[1]','int'),0)
				,Area = ISNULL(C.value('./Area[1]','varchar(max)'),'')
				,Id_Galleria = ISNULL(C.value('./Id_Galleria[1]','int'),0)
		FROM	VSN_Pagina AS T WITH(NOLOCK) 
				CROSS APPLY T.XmlPagina.nodes('/XmlPagina') AS X(C)
		WHERE	(IdPagina = @Id_Pagina OR @ID_Pagina IS NULL)
		AND		(Versione = @Versione OR @Versione IS NULL)
		FOR XML PATH(''), ROOT('InfoPagina')
	)
	RETURN @RETVAL
END

GO
/****** Object:  UserDefinedFunction [dbo].[fnGetLinksInGalleriaXml]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetLinksInGalleriaXml(8754,NULL,NULL) AS XmlLinkInGalleria
*/
CREATE FUNCTION [dbo].[fnGetLinksInGalleriaXml](@Id_Pagina int=NULL,@Id_Galleria int = NULL, @Id_Link int=NULL)
RETURNS XML
AS
BEGIN
	DECLARE @RETVAL XML

	SET @RETVAL =
	(
		SELECT
		(
			SELECT	*
			FROM	VW_LinkInGalleria 
			WHERE	(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
			AND		(Id_Galleria = @Id_Galleria OR @ID_Galleria IS NULL)
			AND		(Id_Link = @Id_Link OR @ID_link IS NULL)
			FOR XML PATH('Link'),ROOT('LinksInGalleria')
		)
	)
	RETURN @RETVAL
END		
		
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetLinksInListeXml]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetLinksInListeXml(283,NULL,NULL) AS XmlLinkInLista
*/
CREATE FUNCTION [dbo].[fnGetLinksInListeXml](@Id_Pagina int=NULL,@Id_Lista int = NULL, @Id_Link int=NULL)
RETURNS XML
AS
BEGIN
	DECLARE @RETVAL XML

	SET @RETVAL =
	(
		SELECT
		(
			SELECT	*
			FROM	VW_LinkInLista 
			WHERE	(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
			AND		(id_lista = @Id_Lista OR @ID_Lista IS NULL)
			AND		(Id_Link = @Id_Link OR @ID_link IS NULL)
			FOR XML PATH('Link'),ROOT('LinksInLista')
		)
	)
	RETURN @RETVAL
END		
		
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetListeXml]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetListeXml(8754,NULL,NULL) AS XmlLista
*/
CREATE FUNCTION [dbo].[fnGetListeXml](@Id_Pagina int = NULL, @Id_Lista int = NULL, @Id_Versione int = NULL)
RETURNS XML
AS
BEGIN
	DECLARE @RETVAL XML

	SET @RETVAL =
	(
	SELECT
			CASE
				WHEN ISNULL(@Id_Versione,0) = 0 
				THEN
				(
					SELECT
					(
						SELECT	* 
								,dbo.fnGetLinksInListeXml(Id_Pagina, Id_Lista,NULL)
								FROM	VW_ListaObject 
								WHERE	(Id_Lista = @Id_Lista OR @ID_Lista IS NULL)
								AND		(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
								FOR XML PATH('Lista'), TYPE
					)
					FOR XML PATH(''),ROOT('XmlLista')
				)
				WHEN ISNULL(@Id_Versione,0) > 0
				THEN  
				(
					-- !!! DA VERIFICARE !!! (AL MOMENTO, PER IL PORTALE STATICO, VIENE UTILIZZATA LA CHIAMATA ALLA spEstraiListeVSN INCORPORATA NELLA SP WRAPPER spGetPagineXml)
					SELECT	dbo.fnMergeXmlListaLink(@Id_Versione) as XMLLista
				)
			END
	)
	RETURN @RETVAL
END		

GO
/****** Object:  UserDefinedFunction [dbo].[fnGetMonoLevelXml]    Script Date: 23/06/2017 11:07:20 ******/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetMostProbableXmlTagDataType]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetMostProbableXmlTagDataType
----------------------------------------

FUNZIONE CHE PRELEVA TUTTI I TAG PRESENTI ALL'INTERNO DI UN DATO XML (CHE SI PUO', COME  INDICATO NEGLI ESEMPI, PRELEVARE DALLA COLONNA XML DI UNA TABELLA)
E CERCA DI ATTRIBUIRVI IN MODO PREDITTIVO, TRAMITE LA RICERCA DI TUTTE LE COLONNE PRESENTI IN TUTTE LE TABELLE DEL DATABASE CORRENTE, IL TIPO DI DATO PIU'
VEROSIMILE.

L'ANALISI PREDITTIVA E' APPLICABILE IN TUTTI QUEI CASI IN CUI IL DATO XML SIA STATO GENERATO PARTENDO DALLE COLONNE DELLE TABELLE PRESENTI NEL DATABASE SUL
QUALE SI STA INVOCANDO LA FUNZIONE: IN QUESTA SITUAZIONE E' MOLTO PROBABILE, E RICORRENTE, EFFETTUARE UN REVERSE-ENGINEERING DEL DATO NON-TIPIZZATO, OVVERO
QUELLO CORRISPONDENTE AD UN TAG XML *NON LEGATO AD UN NAMESPACE* FORTEMENTE TIPIZZATO

LA RESTITUZIONE DEL TIPO DI DATO PRESUNTO PUO' AVVENIRE RELATIVAMENTE AD UN SINGOLO TAG O A FRONTE DI TUTTI TAG TROVATI ALL'INTERNO DEL DATO XML: SE IL PARAMETRO
OPZIONALE "@tagName" VIENE VALORIZZATO, IL SUO VALORE - SE TROVATO ALL'INTERNO DEL DATO XML - SARA' UTILIZZATO PER LA RICERCA DEL TIPO DI DATO PIU' PROSSIMO
RELATIVAMENTE A QUEL NOME DI COLONNA IN TUTTE LE TABELLE DEL DB CORRENTE.

QUALORA, INVECE, IL PARAMETRO OPZIONALE "@tagName" VENGA VALORIZZATO A NULL, SARANNO PRESI IN ESAME TUTTI I TAGS INDIVIDUATI NEL DATO XML E PER CIASCUNO DI ESSI
VERRA' EFFETTUATA UNA RICERCA PER TUTTE LE COLONNE AVENTI UN NOME CORRISPONDENTE IN TUTTE LE TABELLE DEL DB CORRENTE.

-- ESEMPI DI INVOCAZIONE

DECLARE @XmlField XML
SELECT	@XmlField = XmlPagina 
FROM	VSN_Pagina 
WHERE	IDPagina = 8754 
AND Versione = 9

-- SINGOLO TAG
SELECT * FROM dbo.fnGetMostProbableXmlTagDataType(@XmlField,'Bullet')
SELECT * FROM dbo.fnGetMostProbableXmlTagDataType(@XmlField,'Data_Creazione')
SELECT * FROM dbo.fnGetMostProbableXmlTagDataType(@XmlField,'Testo')
SELECT * FROM dbo.fnGetMostProbableXmlTagDataType(@XmlField,'IdLink')

-- INTERO SET DI TAG
SELECT * FROM dbo.fnGetMostProbableXmlTagDataType(@XmlField,NULL)
*/
CREATE FUNCTION	[dbo].[fnGetMostProbableXmlTagDataType]
				(
					@XmlField XML = NULL
					,@tagName varchar(128) = NULL
				)
RETURNS @TagData TABLE
		(
			NodeName varchar(128)
			,ParentName varchar(128)
			,XmlSource varchar(MAX)
			,BestDataType varchar(MAX)
		)
AS
BEGIN
	INSERT	@TagData
			(
				NodeName
				,ParentName
				,XmlSource
				,BestDataType
			)
	SELECT	DISTINCT
			NodeName
			,ParentName
			,CAST(SourceObject AS varchar(MAX)) AS XmlSource
			,CAST(SourceObject AS XML).value('(//DataType[../ThisDataTypeOccurrences = max(../ThisDataTypeOccurrences) and not(. < //DataType)])[1]','varchar(max)') AS BestDataType  
	FROM
	(
		SELECT	DISTINCT
				XLIST.ParentName
				,XLIST.NodeName
				,CAST
				(
					(
						SELECT	
								XLIST.NodeName AS "@nodename"
								,
								(
									SELECT	DISTINCT
											ObjectName AS TableName
											,DataType =
											CASE 
												WHEN typename in ('char', 'varchar', 'nvarchar', 'varbinary')
												AND [length] != -1
												THEN typename + '(' + CAST([length] AS varchar(26)) + ')'
												WHEN typename in ('char', 'varchar', 'nvarchar', 'varbinary')
												AND [length] = -1
												THEN typename + '(MAX)'
												ELSE typename
											END
											,COUNT(*) OVER (PARTITION BY typename ORDER BY typename) AS ThisDataTypeOccurrences
											,COUNT(*) OVER (PARTITION BY 0) AS TotalDataTypeOccurrences
											,LongestForThisDataType =
											CASE
												WHEN MIN([length]) OVER (PARTITION BY typename ORDER BY typename) = -1
												AND typename in ('char', 'varchar', 'nvarchar', 'varbinary', 'text', 'ntext')
												THEN 'MAX'
												ELSE CAST(MAX([length]) OVER (PARTITION BY typename ORDER BY typename) AS varchar(5))
											END
											,LongestForAllDataTypes =
											CASE
												WHEN MIN([length]) OVER () = -1
												AND typename in ('char', 'varchar', 'nvarchar', 'varbinary', 'text', 'ntext')
												THEN 'MAX'
												ELSE CAST(MAX([length]) OVER () AS varchar(5))
											END
									FROM	dbo.fnGetAllTablesByColumnName(XLIST.NodeName) 
									FOR XML PATH('Source'), TYPE
								)
								FOR XML PATH('DataTypes')
					) 
					AS varchar(MAX)
				) AS SourceObject
		FROM	dbo.fnXML2Table(@XmlField) XLIST
		WHERE	ParentName IS NOT NULL
		AND		(XLIST.NodeName = @tagName OR  @tagName IS NULL)
	) A
	ORDER BY
			A.NodeName
			,A.ParentName
	RETURN 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetMultiLevelXml]    Script Date: 23/06/2017 11:07:20 ******/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetNewsXml]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetNewsXml(8754,NULL,NULL) AS XmlNews
SELECT dbo.fnGetNewsXml(8754,NULL,5) AS XmlNews
SELECT dbo.fnGetNewsXml(8754,NULL,-1) AS XmlNews
*/
CREATE FUNCTION [dbo].[fnGetNewsXml](@Id_Pagina int = NULL, @Id_News int = NULL, @Id_Versione int = NULL)
RETURNS XML
AS
BEGIN
	DECLARE 
			@RETVAL XML
			,@FormattazioneNEWS varchar(MAX)

	SELECT	@FormattazioneNEWS =
			CASE C.value('(//formattazione)[1]','int')
				WHEN 1
				THEN 'NewsLaterali'
				ELSE 'NewsCentrali'
			END
	FROM	VSN_NewsInPage NIP WITH(NOLOCK)
			INNER JOIN
			VSN_ContenutoNews CN WITH(NOLOCK)
			ON NIP.IdNewsInPage = CN.Id_NewsInPage
			CROSS APPLY NIP.XmlBloccoNews.nodes('/') AS X(C)
	WHERE	1=1
	AND		IdVsnContenutoNews = @Id_Versione
				

	SET @RETVAL =
	(
		SELECT
			CASE
				WHEN ISNULL(@Id_Versione,0) = 0 
				THEN
				(
					SELECT
					(
						SELECT	* 
						FROM	VW_News 
						WHERE	(Id_NewsInPage = @Id_News OR @ID_News IS NULL)
						AND		(Id_Page = @Id_Pagina OR @ID_Pagina IS NULL)
						FOR XML PATH('News'), TYPE
					)
					FOR XML PATH(''),ROOT('XmlNews')
				)
				WHEN ISNULL(@Id_Versione,0) > 0
				THEN  
				(
					SELECT	dbo.fnReplaceXmlNodeName
							(
								(
									SELECT
											IdVsnContenutoNews
											,C.value('(//id_newsinpage)[1]','varchar(MAX)') AS id_newsinpage
											,C.value('(//id_page)[1]','varchar(MAX)') AS id_page
											,C.value('(//formattazione)[1]','varchar(MAX)') AS formattazione
											,D.value('(//titolo)[1]','varchar(MAX)') AS titolo
											,D.value('(//abstract)[1]','varchar(MAX)') AS abstract
											,D.value('(//testo)[1]','varchar(MAX)') AS testo
											,D.value('(//ordinamento)[1]','varchar(MAX)') AS ordinamento
											,D.value('(//data)[1]','varchar(MAX)') AS data
											,D.value('(//id_contenuto)[1]','varchar(MAX)') AS id_contenuto
											,D.value('(//urlImage)[1]','varchar(MAX)') AS urlImage
											,D.value('(//id_area)[1]','varchar(MAX)') AS id_area
									FROM	VSN_NewsInPage NIP WITH(NOLOCK)
											INNER JOIN
											VSN_ContenutoNews CN WITH(NOLOCK)
											ON NIP.IdNewsInPage = CN.Id_NewsInPage
											CROSS APPLY NIP.XmlBloccoNews.nodes('/') AS X(C)
											CROSS APPLY CN.XmlContenutoNews.nodes('/') AS X2(D)
									WHERE	1=1
									AND		IdVsnContenutoNews = @Id_Versione
									FOR	XML PATH('News'),ROOT('Root'), TYPE, ELEMENTS
								)
								,'Root'
								,@FormattazioneNews 
							)
				)
			END
	)
	RETURN @RETVAL
END		
		
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetPagineXml]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetPagineXml(8754, 8)
*/
CREATE FUNCTION [dbo].[fnGetPagineXml](@Id_Pagina int = NULL, @Versione int = NULL)
RETURNS XML
AS
BEGIN
	DECLARE 
			@RETVAL XML
			,@NomePagina varchar(300)
			,@IdVsnTestoSemplice int
			,@IdVsnTestoConImmagine int
			,@IdVsnTestoDoppio int
			,@IdVsnBanner int

	SELECT				@IdVsnTestoSemplice = C.value('(//IdVsnTestoSemplice)[1]','int')			,@IdVsnTestoConImmagine = C.value('(//IdVsnTestoConImmagine)[1]','int')			,@IdVsnTestoDoppio = C.value('(//IdVsnTestoDoppio)[1]','int')			,@IdVsnBanner = C.value('(//IdVsnBanner)[1]','int')			--,@IdVsnContenutoNews = C.value('(//IdVsnBanner)[1]','int')	FROM	VSN_Pagina AS T WITH(NOLOCK) 			CROSS APPLY T.XmlPagina.nodes('/') AS X(C)	WHERE	IdPagina = @ID_Pagina
	AND		Versione = @Versione

	SET	@RETVAL =
		CASE
			WHEN ISNULL(@Versione,0) = 0
			THEN
			(
				SELECT	
						P.*
						,dbo.fnGetTemplateCategoriaXml(P.Id_Pagina,NULL)	
						,dbo.fnGetTestoSempliceXml(P.Id_Pagina, NULL, NULL)
						,dbo.fnGetTestoConImmagineXml(P.Id_Pagina, NULL, NULL)
						,dbo.fnGetTestoDoppioXml(P.Id_Pagina, NULL, NULL)
						,dbo.fnGetBannersXml(P.Id_Pagina, NULL, NULL)
						,dbo.fnGetNewsXml(P.Id_Pagina, NULL, NULL)
						,dbo.fnGetListeXml(P.Id_Pagina, NULL)
						,dbo.fnGetGallerieXml(P.Id_Pagina, NULL)
				FROM	Pagine P WITH(NOLOCK)
				WHERE	P.ID_Pagina = @ID_Pagina
				FOR XML PATH(''),ROOT('XmlPagina')
			)
			ELSE
			(
				SELECT
						dbo.fnGetInfoPaginaXml(P.IdPagina,P.Versione)
						,dbo.fnGetTemplateCategoriaXml(P.IdPagina,NULL)	
						,dbo.fnReplaceXmlNodeName(dbo.fnGetTestoDoppioXml(P.IdPagina,NULL,@IdVsnTestoDoppio),'XmlTestoDoppio','TestoDoppio') AS 'TestoDoppio'
						,dbo.fnReplaceXmlNodeName(dbo.fnGetTestoSempliceXml(P.IdPagina,NULL,@IdVsnTestoSemplice),'XmlTestoSemplice','TestoSemplice')
						,dbo.fnReplaceXmlNodeName(dbo.fnGetTestoConImmagineXml(P.IdPagina,NULL,@IdVsnTestoConImmagine),'XmlTestoConImmagine','TestoConImmagine')
						,dbo.fnReplaceXmlNodeName(dbo.fnGetBannersXml(P.IdPagina,NULL,@IdVsnBanner),'XmlBanner','Banners')
						--,dbo.fnGetNewsXml(P.Id_Pagina, NULL)
						--,dbo.fnGetListeXml(P.Id_Pagina, NULL)
						--,dbo.fnGetGallerieXml(P.Id_Pagina, NULL)
				FROM	Vsn_Pagina P WITH(NOLOCK)
				WHERE	IdPagina = @ID_Pagina
				AND		Versione = @Versione 
				FOR XML PATH('XmlPageData'), ELEMENTS
			)
		END

	SET @RETVAL = dbo.fnReplaceXmlNodeName(@RETVAL,'XmlPageData','XmlPageData xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"')
	RETURN @RETVAL
END		

GO
/****** Object:  UserDefinedFunction [dbo].[fnGetTableFields]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetTableFields
----------------------------------------

FUNZIONE CHE RITORNA UNA STRINGA, COMPOSTA DINAMICAMENTE, CONTENENTE L'ELENCO DEI CAMPI - SENZA TIPO DI DATO - PRESENTI NELLA TABELLA SPECIFICATA.
L'ELENCO VEDRA' I CAMPI SEPARATI TRA LORO DA UNA VIRGOLA. LA PRESENTE FUNZIONE E' IN GRADO DI RESTITUIRE TUTTE LE COLONNE PRESENTI NEI TRE DATABASES
INERENTI LA INTRANET INPS, PERTANTO:

- IntranetInps
- IntranetInps_Lavoro
- IntranetInps_Richieste

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnGetTableFields('Link_RichiesteCancellazione') AS fieldsList
SELECT dbo.fnGetTableFields('[IntranetInps].[dbo].[KeyWord_Link]') AS fieldsList
SELECT dbo.fnGetTableFields('[IntranetInps_Lavoro].[dbo].[AreeArchiviate]') AS fieldsList
SELECT dbo.fnGetTableFields('[IntranetInps_Richieste].[dbo].[VSN_NewsInPage]') AS fieldsList
*/
CREATE FUNCTION	[dbo].[fnGetTableFields](@tableName varchar(128) = NULL)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE	@RETVAL varchar(MAX) = NULL

	IF ISNULL(@tableName,'') != ''
		BEGIN
			IF dbo.fnCountStringOccurrences(@tableName, '.') > 1
			AND (@tableName LIKE '%IntranetInps.%' OR @tableName LIKE '%IntranetInps].%')
				BEGIN
					SELECT	@RETVAL = COALESCE(@RETVAL, '') + ',' + LTRIM(RTRIM(column_name)) + CHAR(13)  
					FROM	IntranetInps.INFORMATION_SCHEMA.COLUMNS
					WHERE	table_name = dbo.fnpurge(@tableName) 
					AND		table_schema = 'dbo'
				END 
			ELSE
				BEGIN
					IF dbo.fnCountStringOccurrences(@tableName, '.') > 1
					AND (@tableName LIKE '%IntranetInps_Lavoro.%' OR @tableName LIKE '%IntranetInps_Lavoro].%')
						BEGIN
							SELECT	@RETVAL = COALESCE(@RETVAL, '') + ',' + column_name + CHAR(13)  
							FROM	IntranetInps_Lavoro.INFORMATION_SCHEMA.COLUMNS
							WHERE	table_name = dbo.fnpurge(@tableName) 
							AND		table_schema = 'dbo'
						END 
					ELSE
						BEGIN
							IF dbo.fnCountStringOccurrences(@tableName, '.') > 1
							AND (@tableName LIKE '%IntranetInps_Richieste.%' OR @tableName LIKE '%IntranetInps_Richieste].%')
								BEGIN
									SELECT	@RETVAL = COALESCE(@RETVAL, '') + ',' + column_name + CHAR(13)  
									FROM	IntranetInps_Richieste.INFORMATION_SCHEMA.COLUMNS
									WHERE	table_name = dbo.fnpurge(@tableName) 
									AND		table_schema = 'dbo'
								END
							ELSE 
								BEGIN
									SELECT	@RETVAL = COALESCE(@RETVAL, '') + ',' + c.Name + CHAR(13)
									FROM	SYS.OBJECTS O
											INNER JOIN
											SYS.COLUMNS C
											ON O.object_id = C.object_id
									WHERE	O.name = @tableName
									ORDER BY C.column_id
								END
							END
				END
			IF @@ROWCOUNT > 0
				BEGIN
					SET @RETVAL = RIGHT(@RETVAL,LEN(@RETVAL)-1)
				END
		END
	RETURN @RETVAL
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetTableFieldsWithAliasPrefix]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetTableFieldsWithAliasPrefix
----------------------------------------

QUASI IDENTICA ALLA FUNZIONE GEMELLA  "fnGetTableFields" ANCHE QUESTA FUNZIONE RITORNA UNA STRINGA, COMPOSTA DINAMICAMENTE, CONTENENTE L'ELENCO DEI CAMPI 
- SEMPRE SENZA TIPO DI DATO - PRESENTI NELLA TABELLA SPECIFICATA; A DIFFERENZA DELL'ALTRA, CON QUESTA FUNZIONE E' POSSIBILE SPECIFICARE UN ALIAS DA ANTEPORRE
AI NOMI DELLE COLONNE RITORNATE NELL'ELENCO.
L'ELENCO VEDRA' I CAMPI SEPARATI TRA LORO DA UNA VIRGOLA. LA PRESENTE FUNZIONE E' IN GRADO DI RESTITUIRE TUTTE LE COLONNE PRESENTI NEI TRE DATABASES
INERENTI LA INTRANET INPS, PERTANTO:

- IntranetInps
- IntranetInps_Lavoro
- IntranetInps_Richieste

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnGetTableFieldsWithAliasPrefix('Link_RichiesteCancellazione',NULL) AS fieldsList
SELECT dbo.fnGetTableFieldsWithAliasPrefix('[IntranetInps].[dbo].[KeyWord_Link]','A') AS fieldsList
SELECT dbo.fnGetTableFieldsWithAliasPrefix('[IntranetInps_Lavoro].[dbo].[AreeArchiviate]','AREEAR') AS fieldsList
SELECT dbo.fnGetTableFieldsWithAliasPrefix('[IntranetInps_Richieste].[dbo].[VSN_NewsInPage]','NIP') AS fieldsList
*/
CREATE FUNCTION	[dbo].[fnGetTableFieldsWithAliasPrefix](@tableName varchar(128) = NULL, @AliasPrefix varchar(20))
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE	@RETVAL varchar(MAX) = NULL

	IF ISNULL(@tableName,'') != ''
		BEGIN
			SET @AliasPrefix = ISNULL(@AliasPrefix,'T.')
			SET @AliasPrefix = 
				CASE 
					WHEN dbo.fnCountStringOccurrences(@AliasPrefix, '.') < 1
					THEN @AliasPrefix + '.'
					ELSE @AliasPrefix
				END

			IF dbo.fnCountStringOccurrences(@tableName, '.') > 1
			AND (@tableName LIKE '%IntranetInps.%' OR @tableName LIKE '%IntranetInps].%')
				BEGIN
					SELECT	@RETVAL = COALESCE(@RETVAL, '') + ',' + @AliasPrefix + column_name + CHAR(13)  
					FROM	IntranetInps.INFORMATION_SCHEMA.COLUMNS
					WHERE	table_name = dbo.fnpurge(@tableName) 
					AND		table_schema = 'dbo'
				END 
			ELSE
				BEGIN
					IF dbo.fnCountStringOccurrences(@tableName, '.') > 1
					AND (@tableName LIKE '%IntranetInps_Lavoro.%' OR @tableName LIKE '%IntranetInps_Lavoro].%')
						BEGIN
							SELECT	@RETVAL = COALESCE(@RETVAL, '') + ',' + @AliasPrefix + column_name + CHAR(13)  
							FROM	IntranetInps_Lavoro.INFORMATION_SCHEMA.COLUMNS
							WHERE	table_name = dbo.fnpurge(@tableName) 
							AND		table_schema = 'dbo'
						END 
					ELSE
						BEGIN
							IF dbo.fnCountStringOccurrences(@tableName, '.') > 1
							AND (@tableName LIKE '%IntranetInps_Richieste.%' OR @tableName LIKE '%IntranetInps_Richieste].%')
								BEGIN
									SELECT	@RETVAL = COALESCE(@RETVAL, '') + ',' + @AliasPrefix + column_name + CHAR(13)  
									FROM	IntranetInps_Richieste.INFORMATION_SCHEMA.COLUMNS
									WHERE	table_name = dbo.fnpurge(@tableName) 
									AND		table_schema = 'dbo'
								END
							ELSE 
								BEGIN
									SELECT	@RETVAL = COALESCE(@RETVAL, '') + ',' + @AliasPrefix + c.Name + CHAR(13)
									FROM	SYS.OBJECTS O
											INNER JOIN
											SYS.COLUMNS C
											ON O.object_id = C.object_id
									WHERE	O.name = @tableName
									ORDER BY C.column_id
								END
							END
				END
			IF @@ROWCOUNT > 0
				BEGIN
					SET @RETVAL = RIGHT(@RETVAL,LEN(@RETVAL)-1)
				END
		END
	RETURN @RETVAL
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetTemplateCategoriaXml]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetTemplateCategoriaXml(8754,NULL) AS XmlTemplateCategoria -- Restituisce, in formato XML, i dati dalla tabella TemplateCategoriaObject relativi all'"Id_Pagina" specificato (in unione, se indicato, anche all'Id_TemplateCategoria)
*/
CREATE FUNCTION [dbo].[fnGetTemplateCategoriaXml](@Id_Pagina int = NULL, @Id_TemplateCategoria int=NULL)
RETURNS XML
AS
BEGIN
	DECLARE @RETVAL XML

	SET @RETVAL =
	(
		SELECT
		(
			SELECT	
					id_cat
					,voce
					,color_path_img
					,coloredefault
					,coloresfondo
					,colorebordo
					,bullet
					,ordinamento
					,coloreselezionelink
					,descrizione
			FROM	VW_TemplateCategoriePagina WITH(NOLOCK)
			WHERE	(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
			AND		(id_template = @Id_TemplateCategoria OR @Id_TemplateCategoria IS NULL)
			FOR XML PATH(''), ROOT('Categoria'), TYPE
		)
		,
		(
			SELECT
					TPL.id_template
					,TPL.nome_template
					,lista_1sx = CASE WHEN TPL.lista1_sx = 1 THEN 'true' ELSE 'false' END
					,lista_2sx = CASE WHEN TPL.lista2_sx = 1 THEN 'true' ELSE 'false' END
					,lista_3sx = CASE WHEN TPL.lista3_sx  = 1 THEN 'true' ELSE 'false' END
					,lista4_sx = CASE TPL.lista4_sx WHEN 1 THEN 'true' ELSE 'false' END
					,lista5_sx = CASE TPL.lista5_sx WHEN 1 THEN 'true' ELSE 'false' END
					,lista1_dx = CASE TPL.lista1_dx WHEN 1 THEN 'true' ELSE 'false' END
					,lista2_dx = CASE TPL.lista2_dx WHEN 1 THEN 'true' ELSE 'false' END
					,lista3_dx = CASE TPL.lista3_dx WHEN 1 THEN 'true' ELSE 'false' END
					,lista4_dx = CASE TPL.lista4_dx WHEN 1 THEN 'true' ELSE 'false' END
					,lista_centrale = CASE TPL.lista_centrale WHEN 1 THEN 'true' ELSE 'false' END
					,lista2_centrale = CASE TPL.lista2_centrale WHEN 1 THEN 'true' ELSE 'false' END
					,lista3_centrale = CASE TPL.lista3_centrale WHEN 1 THEN 'true' ELSE 'false' END
					,lista4_centrale = CASE TPL.lista4_centrale WHEN 1 THEN 'true' ELSE 'false' END
					,testo_semplice = CASE TPL.testo_semplice WHEN 1 THEN 'true' ELSE 'false' END
					,testo_info = CASE TPL.testo_info WHEN 1 THEN 'true' ELSE 'false' END
					,news_laterale = CASE TPL.news_laterale WHEN 1 THEN 'true' ELSE 'false' END
					,news_centrale = CASE TPL.news_centrale WHEN 1 THEN 'true' ELSE 'false' END
					,banner = CASE TPL.banner WHEN 1 THEN 'true' ELSE 'false' END
					,input_box = CASE TPL.input_box WHEN 1 THEN 'true' ELSE 'false' END
					,link_semplice = CASE TPL.link_semplice WHEN 1 THEN 'true' ELSE 'false' END
					,img_text = CASE TPL.img_text WHEN 1 THEN 'true' ELSE 'false' END
					,TPL.Testo_descrittivo
					,Titolo = CASE TPL.Titolo WHEN 1 THEN 'true' ELSE 'false' END
					,HomePage = CASE TPL.HomePage WHEN 1 THEN 'true' ELSE 'false' END
					,centra = CASE TPL.centra WHEN 1 THEN 'true' ELSE 'false' END
					,abilitato = CASE TPL.abilitato WHEN 1 THEN 'true' ELSE 'false' END
					,[login] = CASE TPL.[login] WHEN 1 THEN 'true' ELSE 'false' END
					,Mappa = CASE TPL.Mappa WHEN 1 THEN 'true' ELSE 'false' END
					,SearchArea = CASE TPL.SearchArea WHEN 1 THEN 'true' ELSE 'false' END
					,Galleria = CASE TPL.Galleria WHEN 1 THEN 'true' ELSE 'false' END
			FROM	Categorie CAT WITH(NOLOCK)
					INNER JOIN
					TemiCategoria TCA WITH(NOLOCK)
					ON CAT.id_tema = TCA.id_tema
					INNER JOIN
					Pagine P WITH(NOLOCK)
					ON CAT.id_cat = P.Categoria
					INNER JOIN
					TipologiePagina TPL WITH(NOLOCK)
					ON TPL.id_template = P.Id_Template
			--FROM	VW_TemplateCategoriePagina TPL WITH(NOLOCK)
			WHERE	(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
			AND		(TPL.id_template = @Id_TemplateCategoria OR @Id_TemplateCategoria IS NULL)
			FOR XML PATH(''), ROOT('Template'), TYPE
		)
		FOR XML PATH(''), TYPE
	)
	RETURN @RETVAL
END		


GO
/****** Object:  UserDefinedFunction [dbo].[fnGetTestoConImmagineXml]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetTestoConImmagineXml(8754,NULL,NULL) AS XmlTestoConImmagine
SELECT dbo.fnGetTestoConImmagineXml(8754,NULL,21) AS XmlTestoConImmagine -- Restituisce, in formato XML, i dati dalla tabella VSN_TestoConImmagine relativi all'"Id_Pagina" e all'"Id_VsnTestoConImmagine" specificati
SELECT dbo.fnGetTestoConImmagineXml(8754,NULL,-1) AS XmlTestoConImmagine -- Restituisce, in formato XML, i dati dalla tabella VSN_TestoConImmagine relativi all'"Id_Pagina" e all'ultima versione, ovvero quella corrispondente al MAX(Id_VsnTestoConImmagine)
*/
CREATE FUNCTION [dbo].[fnGetTestoConImmagineXml](@Id_Pagina int = NULL, @Id_TestoImmagine int=NULL, @Id_Versione int = NULL)
RETURNS XML
AS
BEGIN
	DECLARE @RETVAL XML

	SET @RETVAL =
	(
		SELECT
			CASE
				WHEN ISNULL(@Id_Versione,0) = 0 
				THEN
				(
					SELECT	* 
					FROM	TestoConImmagine WITH(NOLOCK)
					WHERE	(Id_Page = @Id_Pagina OR @ID_Pagina IS NULL)
					AND		(Id_TestoImmagine = @Id_TestoImmagine OR @Id_TestoImmagine IS NULL)
					FOR XML PATH(''), ROOT('XmlTestoConImmagine'), TYPE
				)
				WHEN ISNULL(@Id_Versione,0) = -1
				THEN  
				(
					SELECT	XmlTestoConImmagine 
					FROM	VSN_TestoConImmagine WITH(NOLOCK)
					WHERE	(IdPagina = @Id_Pagina OR @ID_Pagina IS NULL)
					AND		Id_VsnTestoConImmagine = 
							(
								SELECT	MAX(Id_VsnTestoConImmagine)
								FROM	VSN_TestoConImmagine WITH(NOLOCK)
								WHERE	IdPagina = @Id_Pagina
							)
				)
				WHEN ISNULL(@Id_Versione,0) > 0
				THEN  
				(
					SELECT	XmlTestoConImmagine 
					FROM	VSN_TestoConImmagine WITH(NOLOCK)
					WHERE	(IdPagina = @Id_Pagina OR @ID_Pagina IS NULL)
					AND		Id_VsnTestoConImmagine = @Id_Versione
				)
			END
	)
	RETURN @RETVAL
END		


GO
/****** Object:  UserDefinedFunction [dbo].[fnGetTestoDoppioXml]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetTestoDoppioXml(8754,NULL,NULL) AS XmlTestoDoppio -- Restituisce, in formato XML, i dati dalla tabella TestoDoppio relativi all'"Id_Pagina" specificato (in unione, se indicato, anche all'Id_TestoDoppio)
SELECT dbo.fnGetTestoDoppioXml(8754,NULL,3) AS XmlTestoDoppio -- Restituisce, in formato XML, i dati dalla tabella VSN_TestoDoppio relativi all'"Id_Pagina" e all'"Id_VsnTestoDoppio" specificati
SELECT dbo.fnGetTestoDoppioXml(8754,NULL,-1) AS XmlTestoDoppio -- Restituisce, in formato XML, i dati dalla tabella VSN_TestoDoppio relativi all'"Id_Pagina" e all'ultima versione, ovvero quella corrispondente al MAX(Id_VsnTestoDoppio)
*/
CREATE FUNCTION [dbo].[fnGetTestoDoppioXml](@Id_Pagina int = NULL, @Id_TestoDoppio int=NULL, @Id_Versione int=NULL)
RETURNS XML
AS
BEGIN
	DECLARE @RETVAL XML

	SET @RETVAL =
	(
		SELECT
			CASE
				WHEN ISNULL(@Id_Versione,0) = 0 
				THEN
				(
					SELECT	* 
					FROM	TestoDoppio WITH(NOLOCK)
					WHERE	(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
					AND		(id_labeldoppio = @Id_TestoDoppio OR @Id_TestoDoppio IS NULL)
					FOR XML PATH('Label'), ROOT('XmlTestoDoppio'), TYPE
				)
				WHEN ISNULL(@Id_Versione,0) = -1
				THEN  
				(
					SELECT	XmlTestoDoppio 
					FROM	VSN_TestoDoppio WITH(NOLOCK)
					WHERE	(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
					AND		Id_VsnTestoDoppio = 
							(
								SELECT	MAX(Id_VsnTestoDoppio)
								FROM	VSN_TestoDoppio WITH(NOLOCK)
								WHERE	Id_Pagina = @Id_Pagina
							)
				)
				WHEN ISNULL(@Id_Versione,0) > 0
				THEN  
				(
					SELECT	XmlTestoDoppio AS TestoDoppio 
					FROM	VSN_TestoDoppio WITH(NOLOCK)
					WHERE	(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
					AND		Id_VsnTestoDoppio = @Id_Versione
				)
			END
	)
	RETURN @RETVAL
END		


GO
/****** Object:  UserDefinedFunction [dbo].[fnGetTestoSempliceXml]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetTestoSempliceXml(8754,NULL,NULL) AS XmlTestoSemplice -- Restituisce, in formato XML, i dati dalla tabella TestoSempliceObject relativi all'"Id_Pagina" specificato (in unione, se indicato, anche all'Id_TestoSemplice)
SELECT dbo.fnGetTestoSempliceXml(8754,NULL,7) AS XmlTestoSemplice -- Restituisce, in formato XML, i dati dalla tabella VSN_TestoSemplice relativi all'"Id_Pagina" e all'"Id_VsnTestoSemplice" specificati
SELECT dbo.fnGetTestoSempliceXml(8754,NULL,-1) AS XmlTestoSemplice -- Restituisce, in formato XML, i dati dalla tabella VSN_TestoSemplice relativi all'"Id_Pagina" e all'ultima versione, ovvero quella corrispondente al MAX(Id_VsnTestoSemplice)
*/
CREATE FUNCTION [dbo].[fnGetTestoSempliceXml](@Id_Pagina int = NULL, @Id_TestoSemplice int=NULL, @Id_Versione int=NULL)
RETURNS XML
AS
BEGIN
	DECLARE @RETVAL XML

	SET @RETVAL =
	(
		SELECT
			CASE
				WHEN ISNULL(@Id_Versione,0) = 0 
				THEN
				(
					SELECT	* 
					FROM	TestoSempliceObject WITH(NOLOCK)
					WHERE	(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
					AND		(id_testosemplice = @Id_TestoSemplice OR @Id_TestoSemplice IS NULL)
					FOR XML PATH(''), ROOT('XmlTestoSemplice'), TYPE
				)
				WHEN ISNULL(@Id_Versione,0) = -1
				THEN  
				(
					SELECT	XmlTestoSemplice 
					FROM	VSN_TestoSemplice WITH(NOLOCK)
					WHERE	(IdPagina = @Id_Pagina OR @ID_Pagina IS NULL)
					AND		Id_VsnTestoSemplice = 
							(
								SELECT	MAX(Id_VsnTestoSemplice)
								FROM	VSN_TestoSemplice WITH(NOLOCK)
								WHERE	IdPagina = @Id_Pagina
							)
				)
				WHEN ISNULL(@Id_Versione,0) > 0
				THEN  
				(
					SELECT	XmlTestoSemplice 
					FROM	VSN_TestoSemplice WITH(NOLOCK)
					WHERE	(IdPagina = @Id_Pagina OR @ID_Pagina IS NULL)
					AND		Id_VsnTestoSemplice = @Id_Versione
				)
			END
	)
	RETURN @RETVAL
END		


GO
/****** Object:  UserDefinedFunction [dbo].[fnGetValueFromXmlContenutoNews]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetValueFromXmlContenutoNews
----------------------------------------

FUNZIONE ATTA ALL'ESTRAZIONE DEI VALORI CONTENUTI ALL'INTERNO DELLA COLONNA XML PRESENTE NELLA TABELLA SPECIFICA CUI LA FUNZIONE 
E' STRETTAMENTE CONNESSA (IN QUESTO CASO SPECIFICO SI TRATTA DELLA TABELLA "VSN_ContenutoNews").

LA PRESENTE FUNZIONE, COME LE ALTRE RIPORTANTE IL MEDESIMO PREFISSO "fnGetValueFromXml..." E' STATA GENERATA AUTOMATICAMENTE DALLA
STORED PROCEDURE "dbo.spGenSQLCodeForXmlGet" LE CUI ISTRUZIONI CIRCA IL RICHIAMO ED IL FUNZIONAMENTO SONO RIPORTATE IN TESTA ALLA
SP MEDESIMA.

SCOPO PRINCIPALE DELLA PRESENTE FUNZIONE E' QUELLO DI CONSENTIRE L'ACCESSO AI VALORI INCLUSI ALL'INTERNO DEI TAG PRESENTI IN UNA
DETERMINATA COLONNA XML E POTER TRATTARE QUESTI ULTIMI COME SE FOSSERO ACCESSIBILI DIRETTAMENTE, OVVERO COME SE FOSSERO DELLE COLONNE
DI PIU' ALTO LIVELLO (E NON, QUINDI, INCAPSULATE IN UN CONTENITORE QUALE LA COLONNA XML NELLA QUALE SONO INVECE CONTENUTE) .

FUNZIONI DI QUESTO TIPO, OVVERO GENERATE UNA TANTUM DINAMICAMENTE DALLA SUMMENZIONATA STORED PROCEDURE, HANNO A CORREDO UN NUMERO 
DI PARAMETRI VARIABILE, STRETTAMENTE DIPENDENTE DAL NUMERO DI COLONNE *NON XML* COMPONENTI LA TABELLA CUI SI RIFERISCONO.

TALI PARAMETRI - QUASI TUTTI OPZIONALI - SERVONO QUASI SEMPRE A TITOLO DI CRITERIO DI FILTRO, CONSENTONO CIOE' DI RESTRINGERE IL SET
DI RISULTATI CHE LA FUNZIONE DOVRA' RITORNARE: SOLO IL PRIMO E L'ULTIMO PARAMETRO DELLA FUNZIONE (OVVERO "@XmlPath" E "@separator")
SONO FISSI E COMUNI A TUTTE LE FUNZIONI DI QUESTO TIPO ("fnGetValueFromXml..."), IL TERZO PARAMETRO ("@IdVsnContenutoNews" IN QUESTO 
CASO SPECIFICO) SARA' SEMPRE CORRISPONDENTE AL CAMPO ID PRIMARIO DELLA TABELLA.

IN TUTTE LE FUNZIONI DI QUESTO TIPO, TRA L'ALTRO, NON E' PRATICAMENTE *MAI* PRESENTE UNA COLONNA DI TIPO XML IN QUANTO QUEST'ULTIMA,
PRESENTE INVECE NELLA TABELLA CUI LA FUNZIONE SI RIFERISCE, E' UTILIZZATA INTERNAMENTE DALLA FUNZIONE PER SVOLGERE TUTTE LE OPERAZIONI
DI ESTRAZIONE E MANIPOLAZIONE DEI DATI.

LA PRESENTE FUNZIONE (E TUTTE LE ALTRE DI QUESTO TIPO) E' IN GRADO DI RITORNARE I DATI CONTENUTI NELLA COLONNA XML DELLA TABELLA DI 
RIFERIMENTO IN DIVERSI MODI:
- POSSONO ESSERE RITORNATI VALORI SINGOLI, RELATIVI AL CONTENUTO DI UN SINGOLO TAG, AVVALENDOSI ANCHE (MA NON OBBLIGATORIAMENTE) DI
  CRITERI DI FILTRO APPLICATI ALLE COLONNE *NON* XML DELLA TABELLA DI RIFERIMENTO
- POSSONO ESSERE RITORNATI INTERI SET DI DATI, IN FORMA TABELLARE, LADDOVE UN DETERMINATO TAG SI PRESENTI PIU' VOLTE ALLO STESSO LIVELLO
  DI ANNIDAMENTO
- VALORI SINGOLI O TABELLARI POSSONO ESSERE IMPIEGATI *DIRETTAMENTE* ALL'INTERNO DI JOIN, AVVALENDOSI O MENO DEI VARI CRITERI DI FILTRO
  APPLICATI ALLE COLONNE NON XML
- PUO' ESSERE RITORNATO, OVVIAMENTE, IL CONTENUTO DELL'INTERA COLONNA XML COSI' COME E' STATA MEMORIZZATA IN FASE DI INSERIMENTO O AGGIORNAMENTO 

-- ESEMPIO DI ESTRAZIONE DATI DA UN'ALTRA TABELLA UTILIZZANDO COME CRITERIO IL VALORE DI UNO SPECIFICO TAG ALL'INTERNO DI UNA COLONNA XML
SELECT	NIP.*
FROM	VSN_NewsInPage AS NIP WITH(NOLOCK)
WHERE	NIP.IdNewsInPage = CAST(dbo.fnGetValueFromXmlContenutoNews('id_NewsInPage',NULL,NULL,3201,NULL,NULL,NULL,NULL) AS int)

-- IDEM C.S. (NON RITORNA NESSUNA RIGA)
SELECT	NIP.*
FROM	VSN_NewsInPage AS NIP WITH(NOLOCK)
WHERE	NIP.IdNewsInPage = CAST(dbo.fnGetValueFromXmlContenutoNews('id_NewsInPage',NULL,NULL,3209,NULL,NULL,NULL,NULL) AS int)

-- ESEMPIO DI JOIN TRA DUE TABELLE UTILIZZANDO IL VALORE DI UNO SPECIFICO TAG ALL'INTERNO DI UNA COLONNA XML
SELECT
		NIP.*
		,CN.*
FROM	VSN_NewsInPage AS NIP WITH(NOLOCK)
		RIGHT JOIN
		VSN_ContenutoNews AS CN WITH(NOLOCK)
		ON NIP.IdNewsInPage IN (SELECT CAST(Item AS int) AS id_NewsInPage FROM dbo.fnSplit(dbo.fnGetValueFromXmlContenutoNews('id_NewsInPage',NULL,NULL,CN.IdContenutoNews,NULL,NULL,NULL,NULL),NULL))

SELECT
		CN.*
		,NIP.*
FROM	VSN_ContenutoNews AS CN WITH(NOLOCK)
		LEFT JOIN
		VSN_NewsInPage AS NIP WITH(NOLOCK)
		ON NIP.IdNewsInPage IN (SELECT CAST(Item AS int) AS id_NewsInPage FROM dbo.fnSplit(dbo.fnGetValueFromXmlContenutoNews('id_NewsInPage',NULL,NULL,CN.IdContenutoNews,NULL,NULL,NULL,NULL),NULL))

-- ALTRO ESEMPIO DI JOIN TRA DUE TABELLE UTILIZZANDO IL VALORE DI UNO SPECIFICO TAG ALL'INTERNO DI UNA COLONNA XML
SELECT	CAST(A.VXML AS XML) AS XmlBloccoNews
FROM
(
	SELECT
			--DISTINCT 
			CAST(NIP.XmlBloccoNews AS varchar(MAX)) AS VXML
	FROM	VSN_ContenutoNews AS CN WITH(NOLOCK)
			LEFT JOIN
			VSN_NewsInPage AS NIP WITH(NOLOCK)
			ON NIP.IdNewsInPage IN (SELECT CAST(Item AS int) AS id_NewsInPage FROM dbo.fnSplit(dbo.fnGetValueFromXmlContenutoNews('id_NewsInPage',NULL,NULL,CN.IdContenutoNews,NULL,NULL,NULL,NULL),NULL))
) A

-- ALTRO ESEMPIO DI JOIN TRA DUE TABELLE UTILIZZANDO IL VALORE DI UNO SPECIFICO TAG ALL'INTERNO DI UNA COLONNA XML
SELECT
		DISTINCT 
		CAST(NIP.[Data] AS DateTime) AS [Data]
FROM	VSN_ContenutoNews AS CN WITH(NOLOCK)
		LEFT JOIN
		VSN_NewsInPage AS NIP WITH(NOLOCK)
		ON NIP.IdNewsInPage IN (SELECT CAST(Item AS int) AS id_NewsInPage FROM dbo.fnSplit(dbo.fnGetValueFromXmlContenutoNews('id_NewsInPage',NULL,NULL,CN.IdContenutoNews,NULL,NULL,NULL,NULL),NULL))

-- ALTRO ESEMPIO DI JOIN TRA DUE TABELLE UTILIZZANDO IL VALORE DI UNO SPECIFICO TAG ALL'INTERNO DI UNA COLONNA XML
SELECT
		CAST(NIP.[Data] AS DateTime) AS [Data]
FROM	VSN_ContenutoNews AS CN WITH(NOLOCK)
		INNER JOIN
		VSN_NewsInPage AS NIP WITH(NOLOCK)
		ON NIP.IdNewsInPage IN (SELECT CAST(Item AS int) AS id_NewsInPage FROM dbo.fnSplit(dbo.fnGetValueFromXmlContenutoNews('id_NewsInPage',NULL,NULL,CN.IdContenutoNews,NULL,NULL,NULL,NULL),NULL))

-- ESTRAZIONE DELL'INTERA COLONNA XML, CORRISPONDENTE ALL'ID PRIMARIO DELLA TABELLA CONTENITRICE
SELECT CAST(dbo.fnGetValueFromXmlContenutoNews(NULL,4,NULL,NULL,NULL,NULL,NULL,NULL) AS XML) AS XmlContenutoNews

-- ESTRAZIONE DI UN SINGOLO VALORE, CONTENUTO NELL'XML IN CORRISPONDENZA DEL TAG SPECIFICATO, CORRISPONDENTE ALL'ID_CONTENUTONEWS DELLA TABELLA CONTENITRICE
SELECT CAST(dbo.fnGetValueFromXmlContenutoNews('id_NewsInPage',NULL,NULL,3209,NULL,NULL,NULL,NULL) AS int) AS id_NewsInPage
SELECT CAST(dbo.fnGetValueFromXmlContenutoNews('id_NewsInPage',NULL,NULL,3207,NULL,NULL,NULL,NULL) AS int) AS id_NewsInPage
SELECT CAST(dbo.fnGetValueFromXmlContenutoNews('id_NewsInPage',NULL,NULL,3201,NULL,NULL,NULL,NULL) AS int) AS id_NewsInPage

-- ESTRAZIONE DI UN SINGOLO VALORE, CONTENUTO NELL'XML IN CORRISPONDENZA DEL TAG SPECIFICATO, CORRISPONDENTE ALL'ID PRIMARIO DELLA TABELLA CONTENITRICE
SELECT dbo.fnGetValueFromXmlContenutoNews('titolo',4,NULL,NULL,NULL,NULL,NULL,NULL) AS titolo
SELECT dbo.fnGetValueFromXmlContenutoNews('testo',4,NULL,NULL,NULL,NULL,NULL,NULL) AS testo
SELECT CAST(dbo.fnGetValueFromXmlContenutoNews('id_NewsInPage',4,NULL,NULL,NULL,NULL,NULL,NULL) AS int) AS id_NewsInPage

-- ESTRAZIONE, SEPARANDOLI TRAMITE UN SEPARATORE DEFINITO DALL'UTENTE, DEI VALORI (DISTINCT) CONTENUTI NELL'XML IN CORRISPONDENZA DEL TAG SPECIFICATO
SELECT dbo.fnGetValueFromXmlContenutoNews('id_NewsInPage',NULL,NULL,NULL,NULL,NULL,NULL,NULL) AS CSV_id_NewsInPage
SELECT dbo.fnGetValueFromXmlContenutoNews('titolo',NULL,NULL,NULL,NULL,NULL,NULL,'#') AS CSV_titolo
SELECT dbo.fnGetValueFromXmlContenutoNews('testo',NULL,NULL,NULL,NULL,NULL,NULL,'|') AS CSV_testo

-- ESTRAZIONE, RIPARTENDOLI PER RIGHE, DEI VALORI (DISTINCT) CONTENUTI NELL'XML IN CORRISPONDENZA DEL TAG SPECIFICATO
SELECT CAST(Item AS int) AS id_NewsInPage FROM dbo.fnSplit(dbo.fnGetValueFromXmlContenutoNews('id_NewsInPage',NULL,NULL,NULL,NULL,NULL,NULL,NULL),NULL)
SELECT Item AS titolo FROM dbo.fnSplit(dbo.fnGetValueFromXmlContenutoNews('titolo',NULL,NULL,NULL,NULL,NULL,NULL,'#'),'#')
SELECT Item AS testo FROM dbo.fnSplit(dbo.fnGetValueFromXmlContenutoNews('testo',NULL,NULL,NULL,NULL,NULL,NULL,'|'),'|')

*/
CREATE FUNCTION [dbo].[fnGetValueFromXmlContenutoNews]
				(
					@XmlPath varchar(MAX) = NULL
					,@IdVsnContenutoNews int = NULL
					,@Autore varchar(MAX) = NULL
					,@IdContenutoNews int = NULL
					,@Id_NewsInPage int = NULL
					,@NewsInPage bit = NULL
					,@IdStato int = NULL
					,@separator char(1) = NULL
				)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @RETVAL varchar(MAX) = NULL

	IF ISNULL(@XmlPath,'') != ''
	AND ISNULL(@IdVsnContenutoNews,0) != 0
		BEGIN
			SELECT	@RETVAL =
					C.value('(//*[local-name()=sql:variable("@Xmlpath")])[1]','varchar(max)')
			FROM	VSN_ContenutoNews AS T WITH(NOLOCK)
					CROSS APPLY T.XmlContenutoNews.nodes('/XmlContenutoNews') AS X(C)
			WHERE	(IdVsnContenutoNews = @IdVsnContenutoNews)
			AND		(Autore = @Autore OR @Autore IS NULL)
			AND		(IdContenutoNews = @IdContenutoNews OR @IdContenutoNews IS NULL)
			AND		(Id_NewsInPage = @Id_NewsInPage OR @Id_NewsInPage IS NULL)
			AND		(NewsInPage = @NewsInPage OR @NewsInPage IS NULL)
			AND		(IdStato = @IdStato OR @IdStato IS NULL)
		END
	
	IF ISNULL(@XmlPath,'') != ''
	AND ISNULL(@IdVsnContenutoNews,0) = 0
		BEGIN
			SET @separator = ISNULL(@separator,',')
			SELECT	@RETVAL = 
					dbo.fnTrimSeparator
					(
						CAST
						(
							(
								SELECT	DISTINCT
										REPLACE
										(
											REPLACE
											(
												CAST(C.query('(//.[local-name()=sql:variable("@Xmlpath")])') AS varchar(MAX))
												,'<' + @Xmlpath + '>'
												,@separator
											)
											,'</' + @Xmlpath + '>'
											, ''
										)
								FROM	VSN_ContenutoNews AS T WITH(NOLOCK)
										CROSS APPLY T.XmlContenutoNews.nodes('/XmlContenutoNews') AS X(C)
								WHERE	(Autore = @Autore OR @Autore IS NULL)
								AND		(IdContenutoNews = @IdContenutoNews OR @IdContenutoNews IS NULL)
								AND		(Id_NewsInPage = @Id_NewsInPage OR @Id_NewsInPage IS NULL)
								AND		(NewsInPage = @NewsInPage OR @NewsInPage IS NULL)
								AND		(IdStato = @IdStato OR @IdStato IS NULL)
								FOR XML PATH(''), TYPE, ELEMENTS
							)
							AS varchar(MAX)
						)
						,@separator
					)
		END
	
	IF ISNULL(@XmlPath,'') = ''
	AND ISNULL(@IdVsnContenutoNews,0) != 0
		BEGIN
			SELECT	@RETVAL =
					CAST(T.XmlContenutoNews AS varchar(MAX))
			FROM	VSN_ContenutoNews AS T WITH(NOLOCK)
			WHERE	(IdVsnContenutoNews = @IdVsnContenutoNews OR @IdVsnContenutoNews IS NULL)
			AND		(Autore = @Autore OR @Autore IS NULL)
			AND		(IdContenutoNews = @IdContenutoNews OR @IdContenutoNews IS NULL)
			AND		(Id_NewsInPage = @Id_NewsInPage OR @Id_NewsInPage IS NULL)
			AND		(NewsInPage = @NewsInPage OR @NewsInPage IS NULL)
			AND		(IdStato = @IdStato OR @IdStato IS NULL)
		END
	RETURN @RETVAL
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetValueFromXmlLink]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnGetValueFromXmlLink]
						(
							@XmlPath varchar(MAX) = NULL
							,@IdVsnLink int = NULL
							,@Data datetime = NULL,@Id_Link int = NULL
							,@separator char(1) = NULL
						)
		RETURNS varchar(MAX)
		AS
		BEGIN
			DECLARE @RETVAL varchar(MAX) = NULL

			IF ISNULL(@XmlPath,'') != ''
			AND ISNULL(@IdVsnLink,0) != 0
				BEGIN
					SELECT	@RETVAL =
							C.value('(//*[local-name()=sql:variable("@Xmlpath")])[1]','varchar(max)')
					FROM	VSN_Link AS T WITH(NOLOCK)
							CROSS APPLY T.XmlLink.nodes('XmlLink') AS X(C)
					WHERE	(IdVsnLink = @IdVsnLink)
					AND (Data = @Data OR @Data IS NULL)AND (Id_Link = @Id_Link OR @Id_Link IS NULL)
				END
	
			IF ISNULL(@XmlPath,'') != ''
			AND ISNULL(@IdVsnLink,0) = 0
				BEGIN
					SET @separator = ISNULL(@separator,',')
					SELECT	@RETVAL = 
							dbo.fnTrimSeparator
							(
								CAST
								(
									(
										SELECT	DISTINCT
												REPLACE
												(
													REPLACE
													(
														CAST(C.query('(//.[local-name()=sql:variable("@Xmlpath")])') AS varchar(MAX))
														,'<' + @Xmlpath + '>'
														,@separator
													)
													,'</' + @Xmlpath + '>'
													, ''
												)
										FROM	VSN_Link AS T WITH(NOLOCK)
												CROSS APPLY T.XmlLink.nodes('XmlLink') AS X(C)
										WHERE   1 = 1
										AND (Data = @Data OR @Data IS NULL)AND (Id_Link = @Id_Link OR @Id_Link IS NULL)
										FOR XML PATH(''), TYPE, ELEMENTS
									)
									AS varchar(MAX)
								)
								,@separator
							)
				END
	
			IF ISNULL(@XmlPath,'') = ''
			AND ISNULL(@IdVsnLink,0) != 0
				BEGIN
					SELECT	@RETVAL =
							CAST(T.XmlLink AS varchar(MAX))
					FROM	VSN_Link AS T WITH(NOLOCK)
					WHERE	(IdVsnLink = @IdVsnLink)
					AND (Data = @Data OR @Data IS NULL)AND (Id_Link = @Id_Link OR @Id_Link IS NULL)
				END
			RETURN @RETVAL
		END
		
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetXQueryPattern]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetXQueryPattern
----------------------------------------

FUNZIONE PREPOSTA ALL’ESTRAZIONE DEL PATTERN XQUERY DI UN DETERMINATO CAMPO (PREVENTIVAMENTE MAPPATO) DALLA TABELLA DEDICATA XQUERY_RULES 
IN BASE ALL’ID O ALLA DESCRIZIONE

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnGetXQueryPattern(1, NULL) AS XQueryPattern
SELECT dbo.fnGetXQueryPattern(NULL, 'Galleria_IDgalleria') AS XQueryPattern
SELECT dbo.fnGetXQueryPattern(2, NULL) AS XQueryPattern
SELECT dbo.fnGetXQueryPattern(NULL, 'Galleria_Titolo') AS XQueryPattern
*/
CREATE FUNCTION [dbo].[fnGetXQueryPattern](@IDXQuery int=NULL, @Descrizione varchar(50)=NULL, @elementIndex int = NULL)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @RETVAL varchar(MAX) = NULL

	IF ISNULL(@IDXQuery,0) != 0
	OR ISNULL(@Descrizione,'') != ''
		BEGIN
			SELECT	@RETVAL = 
					CASE
						WHEN ISNULL(@elementIndex,0) = 0
						THEN XQueryPattern
						ELSE REPLACE(XQueryPattern,'[1]','[' + CAST(@elementIndex AS varchar(5)) + ']')
					END
			FROM	XQUERY_RULES WITH(NOLOCK)
			WHERE	(IDXQuery = @IDXQuery OR @IDXQuery IS NULL)
			AND		(Descrizione = @Descrizione OR @Descrizione IS NULL)
		END

	RETURN @RETVAL
END

GO
/****** Object:  UserDefinedFunction [dbo].[fnGetXQueryPatterns]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetXQueryPatterns
----------------------------------------

FUNZIONE PREPOSTA ALL’ESTRAZIONE DEL PATTERN XQUERY DI UN DETERMINATO CAMPO (PREVENTIVAMENTE MAPPATO) DALLA TABELLA DEDICATA XQUERY_RULES 
IN BASE ALL’ID O ALLA DESCRIZIONE

-- ESEMPI DI INVOCAZIONE

SELECT * FROM dbo.fnGetXQueryPatterns(1)
*/
CREATE FUNCTION [dbo].[fnGetXQueryPatterns](@IDGroup int=NULL)
RETURNS	@PATTERNS TABLE
		(
			IDXQuery int
			,Descrizione varchar(50)
			,XQueryPattern varchar(MAX)
		)
AS
BEGIN
	IF ISNULL(@IDGroup,0) != 0
		BEGIN
			INSERT	@PATTERNS
					(
						IDXQuery
						,Descrizione
						,XQueryPattern
					)
			SELECT	
					IDXQuery
					,Descrizione
					,XQueryPattern
			FROM	XQUERY_RULES WITH(NOLOCK)
			WHERE	IDGroup = @IDGroup
		END

	RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[fnGetXQueryResultDataType]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetXQueryResultDataType
----------------------------------------

FUNZIONE PREPOSTA ALL’ESTRAZIONE DEL TIPO DI DATO DI UN DETERMINATO CAMPO (PREVENTIVAMENTE MAPPATO) DALLA TABELLA DEDICATA XQUERY_RULES 
IN BASE ALL’ID O ALLA DESCRIZIONE

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnGetXQueryResultDataType(1, NULL) AS XQueryResultDataType
SELECT dbo.fnGetXQueryResultDataType(NULL, 'Galleria_Titolo') AS XQueryResultDataType
SELECT dbo.fnGetXQueryResultDataType(2, NULL) AS XQueryResultDataType
SELECT dbo.fnGetXQueryResultDataType(NULL, 'Galleria_IDgalleria') AS XQueryResultDataType
*/
CREATE FUNCTION [dbo].[fnGetXQueryResultDataType](@IDXQuery int=NULL, @Descrizione varchar(50)=NULL)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @RETVAL varchar(MAX) = NULL

	IF ISNULL(@IDXQuery,0) != 0
	OR ISNULL(@Descrizione,'') != ''
		BEGIN
			SELECT	@RETVAL = XQueryResultDataType
			FROM	XQUERY_RULES WITH(NOLOCK)
			WHERE	(IDXQuery = @IDXQuery OR @IDXQuery IS NULL)
			AND		(Descrizione = @Descrizione OR @Descrizione IS NULL)
		END

	RETURN @RETVAL
END

GO
/****** Object:  UserDefinedFunction [dbo].[fnGetXQueryResultDataTypes]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetXQueryResultDataTypes
----------------------------------------

FUNZIONE PREPOSTA ALL’ESTRAZIONE DEL TIPO DI DATO DI UN DETERMINATO CAMPO (PREVENTIVAMENTE MAPPATO) DALLA TABELLA DEDICATA XQUERY_RULES 
IN BASE ALL’ID O ALLA DESCRIZIONE

-- ESEMPI DI INVOCAZIONE

SELECT * FROM dbo.fnGetXQueryResultDataTypes(1)
*/
CREATE FUNCTION [dbo].[fnGetXQueryResultDataTypes](@IDGroup int=NULL)
RETURNS	@PATTERNS TABLE
		(
			IDXQuery int
			,Descrizione varchar(250)
			,XQueryResultDataType varchar(MAX)
		)
AS
BEGIN
	IF ISNULL(@IDGroup,0) != 0
		BEGIN
			INSERT	@PATTERNS
					(
						IDXQuery
						,Descrizione
						,XQueryResultDataType
					)
			SELECT	
					IDXQuery
					,Descrizione
					,XQueryResultDataType
			FROM	XQUERY_RULES WITH(NOLOCK)
			WHERE	IDGroup = @IDGroup
		END

	RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[fnLeftPart]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnLeftPart
----------------------------------------

FUNZIONE CHE RITORNA LA PORZIONE DI STRINGA CHE SI TROVA ALLA SINISTRA DEL DELIMITATORE SPECIFICATO

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnLeftPart('added nvarchar(max)',' ') AS LEFTPART
SELECT dbo.fnLeftPart('dbo.VSN_TestoConImmagine','.dbo') AS LEFTPART
SELECT dbo.fnLeftPart('Intranetinps_Richieste.dbo.VSN_Link','.dbo') AS LEFTPART
SELECT dbo.fnLeftPart('Intranetinps_Lavoro.IntranetInps.dirforupload_appo','.IntranetInps') AS LEFTPART
*/
CREATE FUNCTION [dbo].[fnLeftPart](@str varchar(MAX) = NULL, @what varchar(MAX))
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

GO
/****** Object:  UserDefinedFunction [dbo].[fnMiddlePart]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnMiddlePart
----------------------------------------

FUNZIONE CHE RITORNA LA PORZIONE DI STRINGA CHE SI TROVA IN MEZZO A DUE OCCORRENZE DEL DELIMITATORE SPECIFICATO

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnMiddlePart('Intranetinps_Richieste.dbo.VSN_Link','.') AS MIDDLEPART
SELECT dbo.fnMiddlePart('Intranetinps_Lavoro.IntranetInps.dirforupload_appo','.') AS MIDDLEPART
*/
CREATE FUNCTION [dbo].[fnMiddlePart](@str varchar(MAX) = NULL, @what varchar(MAX))
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE 
			@RETVAL varchar(MAX) = NULL
			,@FIRSTPOS int
			,@LASTPOS int
			,@WIDTH int

	IF ISNULL(@str,'') != ''
	AND ISNULL(@what,'') != ''
	AND dbo.fnCountStringOccurrences(@str,@what) = 2
		BEGIN
			SET @FIRSTPOS = CHARINDEX(@what, @str)
			SET @LASTPOS = CHARINDEX(@what, @str, @FIRSTPOS +1 )
			SET @WIDTH = @LASTPOS - @FIRSTPOS - 1

			SELECT	@RETVAL = 
					CASE
						WHEN @FIRSTPOS > 0
						AND @LASTPOS >= @FIRSTPOS
						AND @WIDTH > 0
						THEN SUBSTRING(@str, @FIRSTPOS + 1, @WIDTH)
						ELSE @str
					END
		END
	RETURN @RETVAL
END

GO
/****** Object:  UserDefinedFunction [dbo].[fnPurge]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnPurge
----------------------------------------

FUNZIONE ATTA ALLA RIMOZIONE DI DELIMITATORI E PARENTESI QUADRE DAI NOMI COMPLETI DI 
TABELLE, VISTE, STORED PROCEDURES E FUNZIONI, RITORNANDO SOLO IL NOME DELL’OGGETTO

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnPurge('[Intranetinps_Lavoro].[dbo].[Link]') AS PURGEDTABLENAME
SELECT dbo.fnPurge('Intranetinps_Lavoro.IntranetInps.dirforupload_appo') AS PURGEDTABLENAME
*/
CREATE FUNCTION	[dbo].[fnPurge](@tableName varchar(MAX) = NULL)
RETURNS varchar(128)
AS
BEGIN
	DECLARE @RETVAL varchar(128)
	
	IF ISNULL(@tableName,'') != ''
		BEGIN
			SET @RETVAL = REPLACE(REPLACE(@tableName, '[',''),']','')
			SET	@RETVAL = dbo.fnRightPart(@RETVAL, 'dbo.')
			SET	@RETVAL = dbo.fnRightPart(@RETVAL, 'IntranetInps.')
			SET	@RETVAL = dbo.fnRightPart(@RETVAL, 'IntranetInps_Lavoro.')
			SET	@RETVAL = dbo.fnRightPart(@RETVAL, 'IntranetInps_Richieste.')
		END

	RETURN @RETVAL
END

GO
/****** Object:  UserDefinedFunction [dbo].[fnReplaceXmlNodeName]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnReplaceXmlNodeName
----------------------------------------

FUNZIONE PREPOSTA AL RIMPIAZZO DEL NOME DI UN NODO XML, PRESENTE ALL'INTERNO DI UNA STRUTTURA XML PREESISTENTE, CON LA STRINGA SPECIFICATA.

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnReplaceXmlNodeName('<XmlTestoDoppio>
  <Label>
    <id_labeldoppio>2953</id_labeldoppio>
    <label1>Nome</label1>
    <label2>Roberto</label2>
    <id_Pagina>8754</id_Pagina>
    <id_Image>79</id_Image>
    <ordinamento>1</ordinamento>
  </Label>
  <Label>
    <id_labeldoppio>2954</id_labeldoppio>
    <label1>Cognome</label1>
    <label2>Nacchia</label2>
    <id_Pagina>8754</id_Pagina>
    <id_Image>79</id_Image>
    <ordinamento>2</ordinamento>
  </Label>
</XmlTestoDoppio>','XmlTestoDoppio','TestoDoppio')
*/
CREATE FUNCTION [dbo].[fnReplaceXmlNodeName]
				(
					@XmlSource XML
					,@OldNodeName varchar(MAX)
					,@NewNodeName varchar(MAX)
				)
RETURNS XML
AS
BEGIN
	DECLARE 
			@RETVAL XML
			,@VXML nvarchar(MAX)

	IF ISNULL(CAST(@XmlSource AS nvarchar(MAX)),'') != ''
	AND ISNULL(@OldNodeName,'') != ''
	AND ISNULL(@NewNodeName,'') != ''
		BEGIN
			SET @VXML = CAST(@XmlSource AS nvarchar(MAX))
			SET @VXML = REPLACE(@VXML, '<' + @OldNodeName + '>', '<' + @NewNodeName + '>')
			SET @VXML = 
				CASE
					WHEN @NewNodeName LIKE '% %'
					THEN @VXML
					ELSE REPLACE(@VXML, '</' + @OldNodeName + '>', '</' + @NewNodeName + '>')
				END
			SET @RETVAL = CAST(@VXML AS XML)
		END
	RETURN @RETVAL
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnRightPart]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnRightPart
----------------------------------------

FUNZIONE CHE RITORNA LA PORZIONE DI STRINGA CHE SI TROVA ALLA DESTRA DEL DELIMITATORE SPECIFICATO

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnRightPart('Intranetinps_Richieste.dbo.VSN_Link','dbo.') AS RIGHTPART
SELECT dbo.fnRightPart('Intranetinps_Lavoro.IntranetInps.dirforupload_appo','IntranetInps.') AS RIGHTPART
*/
CREATE FUNCTION [dbo].[fnRightPart](@str varchar(MAX) = NULL, @what varchar(MAX))
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

GO
/****** Object:  UserDefinedFunction [dbo].[fnTMPGetStructure]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnTMPGetStructure - SISTEMA TMP
----------------------------------------

NELL'AMBITO DEL MICROSISTEMA DI GESTIONE DI DATI TABELLARI TEMPORANEI (SISTEMA "TMP"), QUESTA FUNZIONE E' PREPOSTA ALLA 
RAPPRESENTAZIONE DELLA STRUTTURA TABELLARE DELLA TABELLA TEMPORANEA CREATA DALLA STORED PROCEDURE "spTMPcreate" E SUCCESSIVAMENTE
MODIFICATA DALLA STORED PROCEDURE "spTMPaddColumns"

-- ESEMPI DI INVOCAZIONE

SELECT * FROM dbo.fnTMPGetStructure()
*/
CREATE FUNCTION [dbo].[fnTMPGetStructure]()
RETURNS @FIELDINFO TABLE
		(
			fieldName varchar(128)
			,castedFieldName varchar(128)
			,fieldType varchar(128)
			,fieldLenght int
			,fieldPrecision int
			,fieldScale int
			,xmlPattern varchar(MAX)
			,fieldWithLength varchar(MAX)
			,OrdinalPosition int --NOT NULL
			,ColumnDefault varchar(MAX) --NULL
			,IsNullable BIT --NOT NULL
			,IsPK BIT --NOT NULL
			,PK varchar(MAX) --NULL
		)
AS
BEGIN
	INSERT	@FIELDINFO
			(
				fieldName
				,castedFieldName
				,fieldType
				,fieldLenght
				,fieldPrecision
				,fieldScale
				,xmlPattern
				,fieldWithLength
				,OrdinalPosition
				,ColumnDefault
				,IsNullable
				,IsPK
				,PK
			)
	SELECT 
			c.name AS fieldName
			,castedFieldName =
				CASE
					WHEN t.name IN('text', 'ntext', 'xml')
					THEN 'CAST(' + c.name  + ' AS varchar(MAX)) AS ' + c.name
					ELSE c.name 
				END
			,t.name AS fieldType
			,c.length AS fieldLenght
			,c.prec AS fieldPrecision
			,c.scale AS fieldScale
			,c.name + ' = XmlData.value(''(//' + c.name + ')[1]'',''' + 
				CASE
					WHEN t.name = 'text'
					THEN 'varchar(MAX)''' 
					WHEN t.name = 'ntext'
					THEN 'nvarchar(MAX)''' 
					WHEN t.name IN ('char','varchar', 'nchar', 'nvarchar')
					AND c.length = -1
					THEN t.name + '(MAX)'''
					WHEN t.name IN ('char','varchar', 'nchar', 'nvarchar')
					AND c.length > 0
					THEN t.name + '(' + CAST(c.length AS varchar(4)) + ')'''
					WHEN t.name IN ('decimal','numeric')
					THEN t.name + '(' + CAST(c.prec AS varchar(4)) + ',' + CAST(c.scale AS varchar(4)) + ')'''
					ELSE t.name + ''''
				END +
				'),' AS xmlPattern
			,c.name + ' ' +
				CASE 
					WHEN t.name IN ('char','varchar', 'nchar', 'nvarchar')
					AND c.length = -1
					THEN t.name + '(MAX)'
					WHEN t.name IN ('char','varchar', 'nchar', 'nvarchar')
					AND c.length > 0
					THEN t.name + '(' + CAST(c.length AS varchar(4)) + ')'
					WHEN t.name IN ('decimal','numeric')
					THEN t.name + '(' + CAST(c.prec AS varchar(4)) + ',' + CAST(c.scale AS varchar(4)) + ')'
					ELSE t.name
				END +
				',' AS fieldWithLength
			,OrdinalPosition = c.colid
			,ColumnDefault = NULL
			,IsNullable = c.isnullable
			,IsPK = 0
			,PK = NULL
	FROM	tempdb..sysobjects o 
			JOIN
			tempdb..syscolumns c
			ON o.id = c.id
			JOIN 
			tempdb..systypes t
			ON t.xusertype = c.xusertype
	WHERE	O.name LIKE '%##__tmpTable%' 
	AND		o.[type] in (N'U')

	RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[fnTrimCommas]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnTrimCommas
----------------------------------------

FUNZIONE CHE RIMUOVE QUALUNQUE PUNTEGGIATURA CHE SI TROVI ALL'INIZIO E/O ALLA FINE DELLA STRINGA PASSATA. TRA I CARATTERI CHE SARANNO RIMOSSI 
E' COMPRESO IL RITORNO-CARRELLO

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnTrimCommas('Stringa terminante per virgola spazio, ')
SELECT dbo.fnTrimCommas(' .Stringa iniziante per spazio punto')
SELECT dbo.fnTrimCommas('Stringa terminante per tre punti...')
SELECT dbo.fnTrimCommas(',,,,,Stringa iniziante per cinque virgole, '+CHAR(13)+CHAR(13))
*/
CREATE FUNCTION	[dbo].[fnTrimCommas](@stringToTrim varchar(MAX))
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE 
			@RETVAL varchar(MAX)
	
	SET @RETVAL = @stringToTrim

	IF ISNULL(@stringToTrim,'') != ''
		BEGIN
			SET @RETVAL = LTRIM(RTRIM(@stringToTrim))
			WHILE (RIGHT(@RETVAL,1) IN (',','.',';',':',' ',CHAR(13)) OR LEFT(@RETVAL,1) IN (',','.',';',':',' ',CHAR(13)))
				BEGIN
					SET @RETVAL =
						CASE
							WHEN RIGHT(@RETVAL,1) IN (',','.',';',':',' ',CHAR(13))
							THEN LEFT(@RETVAL,LEN(@RETVAL)-1)
							WHEN LEFT(@RETVAL,1) IN (',','.',';',':',' ',CHAR(13))
							THEN RIGHT(@RETVAL,LEN(@RETVAL)-1)
						END
				END
		END
	
	RETURN @RETVAL
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnTrimSeparator]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnTrimSeparator
----------------------------------------

FUNZIONE CHE RIMUOVE OGNI OCCORRENZA DEL CARATTERE SPECIFICATO NEL PARAMETRO "@separator" CHE SI TROVI ALL'INIZIO E/O ALLA FINE DELLA STRINGA PASSATA. 
TRA I CARATTERI CHE SARANNO RIMOSSI *NON* E' COMPRESO IL RITORNO-CARRELLO

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnTrimSeparator('Stringa terminante per virgola,', NULL)
SELECT dbo.fnTrimSeparator('Stringa terminante per virgola,', ',')
SELECT dbo.fnTrimSeparator(',,,,,Stringa iniziante per cinque virgole,',',')

SELECT dbo.fnTrimSeparator('.Stringa iniziante per punto', '.')
SELECT dbo.fnTrimSeparator('Stringa terminante per tre punti...', '.')
SELECT dbo.fnTrimSeparator('#Stringa tra #HashTags#','#')
*/
CREATE FUNCTION	[dbo].[fnTrimSeparator](@stringToTrim varchar(MAX)=NULL,@separator char(1)=NULL)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE 
			@RETVAL varchar(MAX)
	
	SET @RETVAL = @stringToTrim
	SET @separator = ISNULL(@separator,',')

	IF ISNULL(@stringToTrim,'') != ''
		BEGIN
			SET @RETVAL = LTRIM(RTRIM(@stringToTrim))
			WHILE (RIGHT(@RETVAL,1) = @separator OR LEFT(@RETVAL,1) = @separator)
				BEGIN
					SET @RETVAL =
						CASE
							WHEN RIGHT(@RETVAL,1) = @separator
							THEN LEFT(@RETVAL,LEN(@RETVAL)-1)
							WHEN LEFT(@RETVAL,1) = @separator
							THEN RIGHT(@RETVAL,LEN(@RETVAL)-1)
						END
				END
		END
	
	RETURN @RETVAL
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetAllIdentityColumns]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetAllIdentityColumns
----------------------------------------

FUNZIONE ATTA RITORNARE TUTTE LE INFORMAZIONI RELATIVE ALLA COLONNA DI TIPO IDENTITY (SE PREVISTA/PRESENTE) DELLA TABELLA SPECIFICATA. 
SE IL PARAMETRO OPZIONALE "@tableName" NON VIENE VALORIZZATO (UGUALE A NULL), LA FUNZIONE TORNERA' UN SET DI DATI CONTENENTE TUTTE LE COLONNE IDENTITY
DI TUTTE LE TABELLE PRESENTI NEL DATABASE CORRENTE.

-- ESEMPI DI INVOCAZIONE

SELECT * FROM dbo.fnGetAllIdentityColumns(NULL)
SELECT * FROM dbo.fnGetAllIdentityColumns('FindEvento')
SELECT * FROM dbo.fnGetAllIdentityColumns('KeyWord')
SELECT * FROM dbo.fnGetAllIdentityColumns('VSN_TestoSemplice')
*/
CREATE FUNCTION [dbo].[fnGetAllIdentityColumns](@tableName varchar(max)=NULL)
RETURNS TABLE --WITH SCHEMABINDING
AS
	RETURN
	SELECT	obj.name AS ObjectName
			--,'<-- OBJs | IdentityCols -->' AS '---sep---'
			,col.* 
	FROM	[syscolumns] col 
			JOIN 
			[sysobjects] obj 
			ON obj.[id] = col.[id] 
	WHERE	(obj.name = @tableName OR @tableName IS NULL)
	AND		obj.type = 'U'
	AND		col.[status] = 0x80

GO
/****** Object:  UserDefinedFunction [dbo].[fnGetAllTablesByColumnName]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetAllTablesByColumnName
----------------------------------------

FUNZIONE ATTA RITORNARE L'ELENCO DI TUTTE LE TABELLE CHE CONTENGANO, COME NOME DI COLONNA, IL VALORE SPECIFICATO NEL PARAMETRO "@columnName".
SE IL PARAMETRO SARA' VALORIZZATO A NULL, VERRA' RITORNATO UN RESULTSET CONTENENTE TUTTE LE COLONNE (CON LE RELATIVE PROPRIETA') DI TUTTE LE
TABELLE PRESENTI NEL DATABASE CORRENTE.

-- ESEMPI DI INVOCAZIONE

SELECT * FROM dbo.fnGetAllTablesByColumnName(NULL)
SELECT * FROM dbo.fnGetAllTablesByColumnName('FindEvento')
SELECT * FROM dbo.fnGetAllTablesByColumnName('KeyWord')
*/
CREATE FUNCTION [dbo].[fnGetAllTablesByColumnName](@columnName varchar(max)=NULL)
RETURNS TABLE --WITH SCHEMABINDING
AS
	RETURN
	SELECT	obj.name AS ObjectName
			--,'<-- OBJs | IdentityCols -->' AS '---sep---'
			,col.* 
			,typ.name as typename
	FROM	[syscolumns] col 
			JOIN 
			[sysobjects] obj 
			ON obj.[id] = col.[id]
			join
			[systypes] typ
			ON col.xtype = typ.xtype
	WHERE	(col.name = @columnName OR @columnName IS NULL)
	AND		obj.type = 'U'

GO
/****** Object:  UserDefinedFunction [dbo].[fnSplit]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnSplit
----------------------------------------

FUNZIONE PREPOSTA ALLA TRASFORMAZIONE DI UN ELENCO CSV (COMMA SEPARATED VALUES) IN UNA TABELLA 
DOVE CIASCUNA RIGA CONTIENE CIASCUN ELEMENTO DELL’ELENCO

-- ESEMPI DI INVOCAZIONE

SELECT * FROM dbo.fnSplit('Pippo, Pluto, Paperino', ',')
SELECT * FROM dbo.fnSplit('Pippo, Pluto, Paperino', NULL)
*/
CREATE FUNCTION [dbo].[fnSplit]
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

GO
/****** Object:  UserDefinedFunction [dbo].[fnXML2Table]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnXML2Table
----------------------------------------

FUNZIONE ATTA AL PARSING DI QUALUNQUE STRUTTURA XML, CAPACE DI RITORNARE UNA NUTRITA SERIE DI INFORMAZIONI, IN FORMA TABELLARE, 
INERENTI LA STRUTTURA NODALE, I CAMPI (TAGS) E LORO CARATTERISTICHE (DATATYPE, DATALENGHT)

-- ESEMPI DI INVOCAZIONE

DECLARE @XmlField XML
SELECT @XmlField = XmlPagina FROM VSN_Pagina WHERE IDPagina = 8754 AND Versione = 9
SELECT * FROM fnXML2Table(@XmlField)
*/
CREATE FUNCTION [dbo].[fnXML2Table](@x XML)  
RETURNS TABLE 
AS 

RETURN 
WITH cte AS 
(  
	SELECT 
			1 AS lvl
			,x.value('local-name(.)','NVARCHAR(MAX)') AS Name
			,CAST(NULL AS NVARCHAR(MAX)) AS ParentName 
			,CAST(1 AS INT) AS ParentPosition 
			,CAST(N'Element' AS NVARCHAR(20)) AS NodeType  
			,x.value('local-name(.)','NVARCHAR(MAX)') AS FullPath  
			,x.value('local-name(.)','NVARCHAR(MAX)') + N'[' + CAST(ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS NVARCHAR) + N']' AS XPath  
			,ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS Position 
			,x.value('local-name(.)','NVARCHAR(MAX)') AS Tree  
			,x.value('text()[1]','NVARCHAR(MAX)') AS Value  
			,x.query('.') AS this         
			,x.query('*') AS t  
			,CAST(CAST(1 AS VARBINARY(4)) AS VARBINARY(MAX)) AS Sort  
			,CAST(1 AS INT) AS ID  
	FROM	@x.nodes('/*') a(x)  

	UNION ALL 

	SELECT 
			p.lvl + 1 AS lvl
			,c.value('local-name(.)','NVARCHAR(MAX)') AS Name
			,CAST(p.Name AS NVARCHAR(MAX)) AS ParentName
			,CAST(p.Position AS INT) AS ParentPosition
			,CAST(N'Element' AS NVARCHAR(20)) AS NodeType
			,CAST(p.FullPath + N'/' + c.value('local-name(.)','NVARCHAR(MAX)') AS NVARCHAR(MAX)) AS FullPath
			,CAST(p.XPath + N'/'+ c.value('local-name(.)','NVARCHAR(MAX)')+ N'['+ CAST(ROW_NUMBER() OVER(PARTITION BY c.value('local-name(.)','NVARCHAR(MAX)') ORDER BY (SELECT 1)) AS NVARCHAR)+ N']' AS NVARCHAR(MAX)) AS XPath
			,ROW_NUMBER() OVER(PARTITION BY c.value('local-name(.)','NVARCHAR(MAX)') ORDER BY (SELECT 1)) AS Position
			,CAST( SPACE(2 * p.lvl - 1) + N'|' + REPLICATE(N'-', 1) + c.value('local-name(.)','NVARCHAR(MAX)') AS NVARCHAR(MAX)) AS Tree
			,CAST( c.value('text()[1]','NVARCHAR(MAX)') AS NVARCHAR(MAX) ) AS Value, c.query('.') AS this
			,c.query('*') AS t
			,CAST(p.Sort + CAST( (lvl + 1) * 1024 + (ROW_NUMBER() OVER(ORDER BY (SELECT 1)) * 2) AS VARBINARY(4)) AS VARBINARY(MAX) ) AS Sort
			,CAST((lvl + 1) * 1024 + (ROW_NUMBER() OVER(ORDER BY (SELECT 1)) * 2) AS INT)  
	FROM	cte p  
			CROSS APPLY 
			p.t.nodes('*') b(c))
			,cte2 AS 
			(  
                SELECT 
						lvl AS Depth
						,Name AS NodeName 
						,ParentName
						,ParentPosition
						,NodeType
						,FullPath
						,XPath
						,Position
						,Tree AS TreeView
						,Value
						,this AS XMLData
						,Sort 
						,ID  
                FROM	cte  

				UNION ALL 

				SELECT 
						p.lvl  
						,x.value('local-name(.)','NVARCHAR(MAX)')  
						,p.Name 
						,p.Position 
						,CAST(N'Attribute' AS NVARCHAR(20)) 
						,p.FullPath + N'/@' + x.value('local-name(.)','NVARCHAR(MAX)')  
						,p.XPath + N'/@' + x.value('local-name(.)','NVARCHAR(MAX)')  
						,1
						,SPACE(2 * p.lvl - 1) + N'|' + REPLICATE('-', 1)	+ N'@' + x.value('local-name(.)','NVARCHAR(MAX)') 
						,x.value('.','NVARCHAR(MAX)')  
						,NULL  
						,p.Sort 
						,p.ID + 1  
				FROM	cte p  
						CROSS APPLY 
						this.nodes('/*/@*') a(x)  
			)  

SELECT 
        ROW_NUMBER() OVER(ORDER BY Sort, ID) AS ID  
        ,ParentName
		,ParentPosition
		,Depth
		,NodeName
		,Position   
        ,NodeType
		,FullPath
		,XPath
		,TreeView
		,Value
		,XMLData 
FROM	cte2

GO
/****** Object:  UserDefinedFunction [dbo].[fnXML2Table_type]    Script Date: 23/06/2017 11:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnXML2Table_type
----------------------------------------

*******************************
*** DA RIVEDERE E SISTEMARE ***
*******************************

FUNZIONE ATTA AL PARSING DI QUALUNQUE STRUTTURA XML, CAPACE DI RITORNARE UNA NUTRITA SERIE DI INFORMAZIONI, IN FORMA TABELLARE, 
INERENTI LA STRUTTURA NODALE, I CAMPI (TAGS) E LORO CARATTERISTICHE (DATATYPE, DATALENGHT)

-- ESEMPI DI INVOCAZIONE

DECLARE @XmlField XML
SELECT @XmlField = XmlPagina FROM VSN_Pagina WHERE IDPagina = 8754 AND Versione = 9
SELECT * FROM fnXML2Table_type(@XmlField)
*/
CREATE FUNCTION [dbo].[fnXML2Table_type](@x XML)  
RETURNS TABLE 
AS 

RETURN 
WITH cte AS 
(  
	SELECT 
			1 AS lvl
			,x.value('local-name(.)','NVARCHAR(MAX)') AS Name
			,(SELECT BestDataType FROM dbo.fnGetMostProbableXmlTagDataType(@x,x.value('local-name(.)','NVARCHAR(MAX)'))) AS [Type]  
			,CAST(NULL AS NVARCHAR(MAX)) AS ParentName 
			,CAST(1 AS INT) AS ParentPosition 
			,CAST(N'Element' AS NVARCHAR(20)) AS NodeType  
			,x.value('local-name(.)','NVARCHAR(MAX)') AS FullPath  
			,x.value('local-name(.)','NVARCHAR(MAX)') + N'[' + CAST(ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS NVARCHAR) + N']' AS XPath  
			,ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS Position 
			,x.value('local-name(.)','NVARCHAR(MAX)') AS Tree  
			,x.value('text()[1]','NVARCHAR(MAX)') AS Value  
			,x.query('.') AS this         
			,x.query('*') AS t  
			,CAST(CAST(1 AS VARBINARY(4)) AS VARBINARY(MAX)) AS Sort  
			,CAST(1 AS INT) AS ID  
	FROM	@x.nodes('/*') a(x)  

	UNION ALL 

	SELECT 
			p.lvl + 1 AS lvl
			,c.value('local-name(.)','NVARCHAR(MAX)') AS Name
			,(SELECT BestDataType FROM dbo.fnGetMostProbableXmlTagDataType(@x,c.value('local-name(.)','NVARCHAR(MAX)'))) AS [Type]  
			,CAST(p.Name AS NVARCHAR(MAX)) AS ParentName
			,CAST(p.Position AS INT) AS ParentPosition
			,CAST(N'Element' AS NVARCHAR(20)) AS NodeType
			,CAST(p.FullPath + N'/' + c.value('local-name(.)','NVARCHAR(MAX)') AS NVARCHAR(MAX)) AS FullPath
			,CAST(p.XPath + N'/'+ c.value('local-name(.)','NVARCHAR(MAX)')+ N'['+ CAST(ROW_NUMBER() OVER(PARTITION BY c.value('local-name(.)','NVARCHAR(MAX)') ORDER BY (SELECT 1)) AS NVARCHAR)+ N']' AS NVARCHAR(MAX)) AS XPath
			,ROW_NUMBER() OVER(PARTITION BY c.value('local-name(.)','NVARCHAR(MAX)') ORDER BY (SELECT 1)) AS Position
			,CAST( SPACE(2 * p.lvl - 1) + N'|' + REPLICATE(N'-', 1) + c.value('local-name(.)','NVARCHAR(MAX)') AS NVARCHAR(MAX)) AS Tree
			,CAST( c.value('text()[1]','NVARCHAR(MAX)') AS NVARCHAR(MAX) ) AS Value, c.query('.') AS this
			,c.query('*') AS t
			,CAST(p.Sort + CAST( (lvl + 1) * 1024 + (ROW_NUMBER() OVER(ORDER BY (SELECT 1)) * 2) AS VARBINARY(4)) AS VARBINARY(MAX) ) AS Sort
			,CAST((lvl + 1) * 1024 + (ROW_NUMBER() OVER(ORDER BY (SELECT 1)) * 2) AS INT)  
	FROM	cte p  
			CROSS APPLY 
			p.t.nodes('*') b(c))
			,cte2 AS 
			(  
                SELECT 
						lvl AS Depth
						,Name AS NodeName 
						,[Type]
						,ParentName
						,ParentPosition
						,NodeType
						,FullPath
						,XPath
						,Position
						,Tree AS TreeView
						,Value
						,this AS XMLData
						,Sort 
						,ID  
                FROM	cte  

				UNION ALL 

				SELECT 
						p.lvl  
						,x.value('local-name(.)','NVARCHAR(MAX)')  
						,(SELECT BestDataType FROM dbo.fnGetMostProbableXmlTagDataType(@x,x.value('local-name(.)','NVARCHAR(MAX)'))) AS [Type]  
						,p.Name 
						,p.Position 
						,CAST(N'Attribute' AS NVARCHAR(20)) 
						,p.FullPath + N'/@' + x.value('local-name(.)','NVARCHAR(MAX)')  
						,p.XPath + N'/@' + x.value('local-name(.)','NVARCHAR(MAX)')  
						,1
						,SPACE(2 * p.lvl - 1) + N'|' + REPLICATE('-', 1)	+ N'@' + x.value('local-name(.)','NVARCHAR(MAX)') 
						,x.value('.','NVARCHAR(MAX)')  
						,NULL  
						,p.Sort 
						,p.ID + 1  
				FROM	cte p  
						CROSS APPLY 
						this.nodes('/*/@*') a(x)  
			)  

SELECT 
        ROW_NUMBER() OVER(ORDER BY Sort, ID) AS ID  
        ,ParentName
		,ParentPosition
		,Depth
		,NodeName
		,[Type]
		,Position   
        ,NodeType
		,FullPath
		,XPath
		,TreeView
		,Value
		,XMLData 
FROM	cte2

GO
