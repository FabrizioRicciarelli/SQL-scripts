/*
SELECT dbo.fnGetXQueryResultDataType(1, NULL) AS XQueryResultDataType
SELECT dbo.fnGetXQueryResultDataType(NULL, 'ImportoRetribuzionePerCodiceRetribuzioneRN') AS XQueryResultDataType
SELECT dbo.fnGetXQueryResultDataType(2, NULL) AS XQueryResultDataType
SELECT dbo.fnGetXQueryResultDataType(NULL, 'ContributoNormalePerCodiceRetribuzioneRN') AS XQueryResultDataType
*/
ALTER FUNCTION [dbo].[fnGetXQueryResultDataType](@IDXQuery int=NULL, @Descrizione varchar(50)=NULL)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @RETVAL varchar(MAX) = NULL

	IF ISNULL(@IDXQuery,0) != 0
	OR ISNULL(@Descrizione,'') != ''
		BEGIN
			SELECT	@RETVAL = XQueryResultDataType
			FROM	XQUERY_RULES WITH(NOLOCK)
			WHERE	(IDXQuery = @IDXQuery OR @IDXQuery IS NULL)
			AND		(Descrizione = @Descrizione OR @Descrizione IS NULL)
		END

	RETURN @RETVAL
END
