IF OBJECT_ID (N'dbo.XMLEscaped') IS NOT NULL     
DROP FUNCTION dbo.XMLEscaped
GO
/*
---------------------------
dbo.XMLEscaped
--------------------------

Function that takes a SQL String with all its clobber and outputs it as a sting with all the XML escape sequences in it

SELECT dbo.XMLEscaped('<Field maxlen="45">FieldName</Field>')

*/ 
CREATE FUNCTION dbo.XMLEscaped (@Unescaped NVARCHAR(MAX)) -- a string with maybe characters that will break json
RETURNS nvarchar(MAX)
AS
BEGIN
    DECLARE @return nvarchar(MAX)
    SELECT @return = 
    REPLACE
	(
        REPLACE
		(
            REPLACE
			(
	            REPLACE
				(
					REPLACE
					(
						REPLACE
						(
							REPLACE
							(
								@Unescaped
								,'&'
								,'&amp;'
							)
							,'<'
							,'&lt;'
						)
						,'>'
						,'&gt;'
					)
					,'\"'
					,'&quot;'
				)
				,'""'
				,'&quot;'
			)
			,'"'
			,'&quot;'
		)
		,''''
		,'&#39;'
	)

	RETURN @return
END
GO
