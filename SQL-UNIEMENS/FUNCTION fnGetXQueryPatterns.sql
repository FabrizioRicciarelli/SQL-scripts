/*
SELECT * FROM dbo.fnGetXQueryPatterns(1)
*/
ALTER FUNCTION [dbo].[fnGetXQueryPatterns](@IDGroup int=NULL)
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
