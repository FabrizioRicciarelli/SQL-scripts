USE [Intranetinps_Richieste]
GO
/****** Object:  StoredProcedure [dbo].[spGenSQLCodeForXmlGet]    Script Date: 23/06/2017 11:04:25 ******/
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
