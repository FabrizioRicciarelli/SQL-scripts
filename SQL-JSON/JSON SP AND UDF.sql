/*
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
CREATE FUNCTION [dbo].[fnGetEnglishKeys](@startsWith varchar(5) = NULL)
RETURNS @AllKeys TABLE([Words] varchar(512))
AS
BEGIN
	DECLARE	@json nvarchar(MAX)
	SELECT	@json = BulkColumn
	FROM	OPENROWSET (BULK 'C:\SQLDATA\JSON\english.json', SINGLE_CLOB) as j

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
GO
/****** Object:  StoredProcedure [dbo].[spGetEnglishDictionary]    Script Date: 27/06/2017 13:55:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC spGetEnglishDictionary 'A'
EXEC spGetEnglishDictionary 'A-'
EXEC spGetEnglishDictionary 'A 1'
EXEC spGetEnglishDictionary 'Refuse'
EXEC spGetEnglishDictionary 'Isethionic'
*/
CREATE PROC [dbo].[spGetEnglishDictionary] @word varchar(128)
AS
DECLARE	
		@sql varchar(MAX)

SET NOCOUNT ON;
SET @sql =
'
DECLARE	
		@json nvarchar(MAX)
SELECT	@json = BulkColumn
FROM	OPENROWSET (BULK ''C:\SQLDATA\JSON\english.json'', SINGLE_CLOB) as j

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
GO
/****** Object:  StoredProcedure [dbo].[spGetEnglishDictionaryCount]    Script Date: 27/06/2017 13:55:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
DECLARE 
		@NumberOfDefinitions int = 0
		,@theKey varchar(512)

SET		@theKey = 'A'
EXEC	spGetEnglishDictionaryCount 
		@theKey
		,@NumberOfDefinitions OUTPUT

PRINT('Key:' + @theKey + ', Definitions: ' + CAST(@NumberOfDefinitions AS varchar(5)))
EXEC spGetEnglishDictionary @theKey

SET		@theKey = 'A-'
EXEC	spGetEnglishDictionaryCount 
		@theKey
		,@NumberOfDefinitions OUTPUT

PRINT('Key:' + @theKey + ', Definitions: ' + CAST(@NumberOfDefinitions AS varchar(5)))
EXEC spGetEnglishDictionary @theKey

SET		@theKey = 'A 1'
EXEC	spGetEnglishDictionaryCount 
		@theKey
		,@NumberOfDefinitions OUTPUT

PRINT('Key:' + @theKey + ', Definitions: ' + CAST(@NumberOfDefinitions AS varchar(5)))
EXEC spGetEnglishDictionary @theKey

SET		@theKey = 'Refuse'
EXEC	spGetEnglishDictionaryCount 
		@theKey
		,@NumberOfDefinitions OUTPUT

PRINT('Key:' + @theKey + ', Definitions: ' + CAST(@NumberOfDefinitions AS varchar(5)))
EXEC spGetEnglishDictionary @theKey

SET		@theKey = 'Regard'
EXEC	spGetEnglishDictionaryCount 
		@theKey
		,@NumberOfDefinitions OUTPUT

PRINT('Key:' + @theKey + ', Definitions: ' + CAST(@NumberOfDefinitions AS varchar(5)))
EXEC spGetEnglishDictionary @theKey

*/
CREATE PROC [dbo].[spGetEnglishDictionaryCount] @key varchar(128), @retval int OUTPUT
AS

SET NOCOUNT ON;
DECLARE	
		@sql varchar(MAX)

DECLARE @temp TABLE([key] varchar(512), [value] varchar(MAX))

SET @sql =
'
DECLARE	
		@json nvarchar(MAX)
SELECT	@json = BulkColumn
FROM	OPENROWSET (BULK ''C:\SQLDATA\JSON\english.json'', SINGLE_CLOB) as j

SELECT
		''' + @key + ''' AS [key]	
		,ss4.[value]
FROM	OPENJSON(@json, ''$."' + @key + '"'') AS letter
		CROSS APPLY 
		(VALUES (''["'' + REPLACE(value, ''"'', ''\"'') + ''"]'')) AS ca(JSONSTR)
		CROSS APPLY 
		OPENJSON(ca.JSONSTR) ss4
'
INSERT @temp
EXEC(@SQL)

SELECT @retval = COUNT(*)
FROM @temp

RETURN @retval
GO
/****** Object:  StoredProcedure [dbo].[spGetEnglishKeys]    Script Date: 27/06/2017 13:55:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
EXEC spGetEnglishKeys
EXEC spGetEnglishKeys 'ABA'
*/
CREATE	PROC [dbo].[spGetEnglishKeys] @startsWith varchar(5) = NULL
AS
DECLARE	@json nvarchar(MAX)
SELECT	@json = BulkColumn
FROM	OPENROWSET (BULK 'C:\SQLDATA\JSON\english.json', SINGLE_CLOB) as j

DECLARE @AllKeys TABLE([key] varchar(512))

INSERT	@AllKeys([key])
SELECT	[key]
FROM	OPENJSON(@json)

SELECT	*
FROM	@AllKeys
WHERE	([key] LIKE @startsWith + '%' OR @startsWith IS NULL)
ORDER BY [key]
GO
