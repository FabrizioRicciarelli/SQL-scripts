DECLARE 
		@XML XML
		,@nodes nvarchar(MAX)
        ,@value nvarchar(MAX)
        ,@query nvarchar(MAX)

DECLARE @RESULTS table(ImportoRetribuzione decimal(18,2));

-- ESTRAZIONE XML
SELECT @XML = dbo.fnGetXMLcontr('00937610152', 'BBTCLR54C68Z114Q', '2013-12-01')

-- ESTRAZIONE REGOLA
SELECT 
		@value = '''.'',''' + XQueryResultDataType  + ''''
		,@nodes = XQueryPattern
FROM	dbo.fnGetXQueryResults(NULL, 'ImportoRetribuzionePerCodiceRetribuzioneRN')

-- ESTRAZIONE VALORE DELLA COLONNA 
-- DAL NODO XML IN BASE ALLA REGOLA
SELECT	@query = 
		'
		SELECT	XMLDATA.Col.value( ' + @value + ') 
        FROM	@xml.nodes(''' + REPLACE(@nodes,'''','''''') + ''') AS XMLDATA(Col)
		'
-- ESECUZIONE CODICE SQL DINAMICO CON
-- SCRITTURA DEI RISULTATI IN TABELLA
-- DI APPOGGIO TEMPORANEA
INSERT INTO @RESULTS(ImportoRetribuzione) 
EXEC sp_executesql @query, N'@xml xml', @xml = @xml

-- RESTITUZIONE RISULTATO
SELECT	* 
FROM	@RESULTS