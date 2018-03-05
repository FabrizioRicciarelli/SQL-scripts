IF OBJECT_ID (N'dbo.JSONEscaped') IS NOT NULL     
DROP FUNCTION dbo.JSONEscaped
GO
/*
---------------------------
dbo.JSONEscaped
--------------------------

Function that takes a SQL String with all its clobber and outputs it as a sting with all the JSON escape sequences in it

SELECT dbo.JSONEscaped('"""')

*/ 
CREATE FUNCTION dbo.JSONEscaped (@Unescaped NVARCHAR(MAX)) -- a string with maybe characters that will break json
RETURNS NVARCHAR(MAX)
AS 
BEGIN
	SELECT	@Unescaped = 
			REPLACE(@Unescaped, FROMString, TOString)
	FROM
	(
		SELECT
				'""' AS FROMString, '\"' AS TOString
				UNION ALL SELECT '"""', '\""'
				UNION ALL SELECT '\', '\\'
				UNION ALL SELECT '\\"', '\"'
				UNION ALL SELECT '/', '\/'
				UNION ALL SELECT  CHAR(08),'\b'
				UNION ALL SELECT  CHAR(12),'\f'
				UNION ALL SELECT  CHAR(10),'\n'
				UNION ALL SELECT  CHAR(13),'\r'
				UNION ALL SELECT  CHAR(09),'\t'
	) AS substitutions
	
	RETURN @Unescaped
END
GO
