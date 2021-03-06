/*
---------------------------
spGetEnglishDictionary
---------------------------

Stored procedure che ritorna la chiave e la descrizione, corrispondenti alla chiave specificata nel parametro @word, relativamente al dizionario
inglese contenuto nel file english.json

-- ESEMPI DI INVOCAZIONE:

EXEC spGetEnglishDictionary 'A'
EXEC spGetEnglishDictionary 'A-'
EXEC spGetEnglishDictionary 'A 1'
EXEC spGetEnglishDictionary 'Refuse'
EXEC spGetEnglishDictionary 'Isethionic'
*/
ALTER PROC [dbo].[spGetEnglishDictionary] @word varchar(128)
AS
DECLARE	
		@sql varchar(MAX)

SET NOCOUNT ON;
SET @sql =
'
DECLARE	
		@json nvarchar(MAX)
SELECT	@json = BulkColumn
FROM	OPENROWSET (BULK ''C:\SQLDATA\JSON\JSON-DATA\english.json'', SINGLE_CLOB) as j

SELECT
		''' + @word + ''' AS [Word]	
		,descriptions.[value] AS [Description]
FROM	OPENJSON(@json, ''$."' + @word + '"'') AS letter
		CROSS APPLY 
		(VALUES (''["'' + REPLACE(value, ''"'', ''\"'') + ''"]'')) AS ca(JSONSTR)
		CROSS APPLY 
		OPENJSON(ca.JSONSTR) descriptions
'
EXEC(@SQL)
