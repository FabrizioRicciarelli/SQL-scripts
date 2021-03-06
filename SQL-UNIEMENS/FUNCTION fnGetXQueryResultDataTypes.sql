/*
SELECT * FROM dbo.fnGetXQueryResultDataTypes(1)
*/
ALTER FUNCTION [dbo].[fnGetXQueryResultDataTypes](@IDGroup int=NULL)
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
