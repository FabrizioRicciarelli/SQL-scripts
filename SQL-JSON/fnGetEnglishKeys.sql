/*
---------------------------
fnGetEnglishKeys
---------------------------

Funzione che ritorna l'elenco delle chiavi presenti nel file JSON "english.json"

-- ESEMPI DI INVOCAZIONE:

SELECT words AS WordList FROM dbo.fnGetEnglishKeys(NULL)
EXEC spGetEnglishDictionary 'Unleash'
EXEC spGetEnglishDictionary 'Leashed'
EXEC spGetEnglishDictionary 'Shrub'
EXEC spGetEnglishDictionary 'Sempre'
EXEC spGetEnglishDictionary 'Coalesce'

EXEC spGetEnglishDictionary 'Natal plum'

SELECT words AS StartingWith_UNL_WordList FROM dbo.fnGetEnglishKeys('UNL')

SELECT words AS StartingWith_RES_WordList FROM dbo.fnGetEnglishKeys('FRE')
EXEC spGetEnglishDictionary 'Fresco'

SELECT words AS StartingWith_RES_WordList FROM dbo.fnGetEnglishKeys('RES')
EXEC spGetEnglishDictionary 'Resonance'

*/
ALTER FUNCTION [dbo].[fnGetEnglishKeys](@startsWith varchar(5) = NULL)
RETURNS @AllKeys TABLE([Words] varchar(512))
AS
BEGIN
	DECLARE	@json nvarchar(MAX)
	SELECT	@json = BulkColumn
	FROM	OPENROWSET (BULK 'C:\SQLDATA\JSON\JSON-DATA\english.json', SINGLE_CLOB) as j

	DECLARE @Keys TABLE([Words] varchar(512))

	INSERT	@Keys([Words])
	SELECT	[key] AS [Words]
	FROM	OPENJSON(@json)

	INSERT	@AllKeys([Words])
	SELECT	[Words]
	FROM	@Keys
	WHERE	([Words] LIKE @startsWith + '%' OR @startsWith IS NULL)
	ORDER BY [Words]

	RETURN
END
