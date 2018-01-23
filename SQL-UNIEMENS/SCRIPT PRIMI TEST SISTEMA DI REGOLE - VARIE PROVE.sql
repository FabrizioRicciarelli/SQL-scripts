/*
CREATE TYPE [dbo].[RESULTS_TYPE] AS TABLE
			(
				AP_KEYD_IDTRASMIS bigint NOT NULL
				,AP_KEYD_COMPETENZA date NOT NULL
				,AP_KEYD_CFAZIENDA varchar(16) NOT NULL
				,AP_KEYD_CODICEGRUPPO varchar(6) NOT NULL
				,AP_KEYD_NUMEROATTIVITA varchar(3) NOT NULL
				,AP_KEYD_CFLAVORATOREISCRITTO varchar(16) NOT NULL
				,IDXQuery int NULL
				,Descrizione varchar(50) NULL
				,risultato varchar(MAX) NULL
			)
*/

SET NOCOUNT ON;

DECLARE @RESULTS RESULTS_TYPE

DECLARE
		@AP_KEYD_IDTRASMIS bigint
		,@AP_KEYD_COMPETENZA date
		,@AP_KEYD_CFAZIENDA varchar(16)
		,@AP_KEYD_CODICEGRUPPO varchar(6)
		,@AP_KEYD_NUMEROATTIVITA varchar(3)
		,@AP_KEYD_CFLAVORATOREISCRITTO varchar(16)
		,@XML xml
		,@ContributoNormaleRN decimal(18,2)
		,@ImportoRetribuzioneRN decimal(18,2)

DECLARE 
		@nodes nvarchar(MAX)
		,@value nvarchar(MAX)
		,@query nvarchar(MAX)


DECLARE CUR CURSOR READ_ONLY FORWARD_ONLY FAST_FORWARD
FOR
	SELECT	TOP 50
			AP_KEYD_IDTRASMIS
			,AP_KEYD_COMPETENZA
			,AP_KEYD_CFAZIENDA
			,AP_KEYD_CODICEGRUPPO
			,AP_KEYD_NUMEROATTIVITA
			,AP_KEYD_CFLAVORATOREISCRITTO
			,AP_KEYD_SQLCOMMAND_ENPALS
			--,NULL AS ContributoNormaleRN
			--,NULL AS ImportoRetribuzioneRN
	FROM	TB_KEYD_KEYDENINDIVSS_RC M WITH(NOLOCK)
	ORDER BY AP_KEYD_COMPETENZA DESC

OPEN CUR
FETCH NEXT 
FROM CUR	INTO
			@AP_KEYD_IDTRASMIS
			,@AP_KEYD_COMPETENZA
			,@AP_KEYD_CFAZIENDA
			,@AP_KEYD_CODICEGRUPPO
			,@AP_KEYD_NUMEROATTIVITA
			,@AP_KEYD_CFLAVORATOREISCRITTO
			,@XML
			--,@ContributoNormaleRN
			--,@ImportoRetribuzioneRN

WHILE @@FETCH_STATUS = 0
	BEGIN
		--INSERT	@RESULTS
		--EXEC	dbo.fnGetXMLValueFromRuleWithKey
		--		@AP_KEYD_IDTRASMIS
		--		,@AP_KEYD_COMPETENZA
		--		,@AP_KEYD_CFAZIENDA
		--		,@AP_KEYD_CODICEGRUPPO
		--		,@AP_KEYD_NUMEROATTIVITA
		--		,@AP_KEYD_CFLAVORATOREISCRITTO
		--		,@AP_KEYD_SQLCOMMAND_ENPALS
		--		,NULL
		--		,'ContributoNormalePerCodiceRetribuzioneRN'
		
		-- ESTRAZIONE REGOLA
		SELECT 
				@value = '''.'',''' + XQueryResultDataType  + ''''
				,@nodes = XQueryPattern
		FROM	dbo.fnGetXQueryResults(NULL, NULL, 'ContributoNormalePerCodiceRetribuzioneRN')

		-- ESTRAZIONE VALORE DELLA COLONNA 
		-- DAL NODO XML IN BASE ALLA REGOLA
		SELECT	@query = 
				'
				SELECT	
						' + CAST(@AP_KEYD_IDTRASMIS AS varchar(20)) + ' AS AP_KEYD_IDTRASMIS
						,''' + CONVERT(varchar(10),@AP_KEYD_COMPETENZA,120) + ''' AS AP_KEYD_COMPETENZA
						,''' + @AP_KEYD_CFAZIENDA + ''' AS AP_KEYD_CFAZIENDA
						,''' + @AP_KEYD_CODICEGRUPPO + ''' AS AP_KEYD_CODICEGRUPPO
						,''' + @AP_KEYD_NUMEROATTIVITA + ''' AS AP_KEYD_NUMEROATTIVITA
						,''' + @AP_KEYD_CFLAVORATOREISCRITTO + ''' AS AP_KEYD_CFLAVORATOREISCRITTO
						,NULL AS IDXQuery
						,''ContributoNormalePerCodiceRetribuzioneRN'' AS Descrizione
						,XMLDATA.Col.value( ' + @value + ') 
				FROM	@xml.nodes(''' + REPLACE(@nodes,'''','''''') + ''') AS XMLDATA(Col)
				'

		PRINT(@query)


		-- ESECUZIONE CODICE SQL DINAMICO CON
		-- SCRITTURA DEI RISULTATI IN TABELLA
		-- DI APPOGGIO TEMPORANEA
		INSERT	@RESULTS
				(
					AP_KEYD_IDTRASMIS
					,AP_KEYD_COMPETENZA
					,AP_KEYD_CFAZIENDA
					,AP_KEYD_CODICEGRUPPO
					,AP_KEYD_NUMEROATTIVITA
					,AP_KEYD_CFLAVORATOREISCRITTO
					,IDXQuery
					,Descrizione
					,risultato
				) 
		EXEC sp_executesql @query, N'@xml xml', @xml = @xml

		-- ESTRAZIONE REGOLA
		SELECT 
				@value = '''.'',''' + XQueryResultDataType  + ''''
				,@nodes = XQueryPattern
		FROM	dbo.fnGetXQueryResults(NULL, NULL, 'ImportoRetribuzionePerCodiceRetribuzioneRN')

		-- ESTRAZIONE VALORE DELLA COLONNA 
		-- DAL NODO XML IN BASE ALLA REGOLA
		SELECT	@query = 
				'
				SELECT	
						' + CAST(@AP_KEYD_IDTRASMIS AS varchar(20)) + ' AS AP_KEYD_IDTRASMIS
						,''' + CONVERT(varchar(10),@AP_KEYD_COMPETENZA,120) + ''' AS AP_KEYD_COMPETENZA
						,''' + @AP_KEYD_CFAZIENDA + ''' AS AP_KEYD_CFAZIENDA
						,''' + @AP_KEYD_CODICEGRUPPO + ''' AS AP_KEYD_CODICEGRUPPO
						,''' + @AP_KEYD_NUMEROATTIVITA + ''' AS AP_KEYD_NUMEROATTIVITA
						,''' + @AP_KEYD_CFLAVORATOREISCRITTO + ''' AS AP_KEYD_CFLAVORATOREISCRITTO
						,NULL AS IDXQuery
						,''ImportoRetribuzionePerCodiceRetribuzioneRN'' AS Descrizione
						,XMLDATA.Col.value( ' + @value + ') 
				FROM	@xml.nodes(''' + REPLACE(@nodes,'''','''''') + ''') AS XMLDATA(Col)
				'
		-- ESECUZIONE CODICE SQL DINAMICO CON
		-- SCRITTURA DEI RISULTATI IN TABELLA
		-- DI APPOGGIO TEMPORANEA
		INSERT	@RESULTS
				(
					AP_KEYD_IDTRASMIS
					,AP_KEYD_COMPETENZA
					,AP_KEYD_CFAZIENDA
					,AP_KEYD_CODICEGRUPPO
					,AP_KEYD_NUMEROATTIVITA
					,AP_KEYD_CFLAVORATOREISCRITTO
					,IDXQuery
					,Descrizione
					,risultato
				) 
		EXEC sp_executesql @query, N'@xml xml', @xml = @xml
		
		FETCH NEXT 
		FROM CUR	INTO
					@AP_KEYD_IDTRASMIS
					,@AP_KEYD_COMPETENZA
					,@AP_KEYD_CFAZIENDA
					,@AP_KEYD_CODICEGRUPPO
					,@AP_KEYD_NUMEROATTIVITA
					,@AP_KEYD_CFLAVORATOREISCRITTO
					,@XML
					--,@ContributoNormaleRN
					--,@ImportoRetribuzioneRN
	END

CLOSE CUR
DEALLOCATE CUR

SELECT *
FROM @RESULTS