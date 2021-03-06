USE [UniemensPosSportSpet]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetXQueryPattern]    Script Date: 08/02/2017 16:23:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetXQueryPattern(1, NULL) AS XQueryPattern
SELECT dbo.fnGetXQueryPattern(NULL, 'ImportoRetribuzionePerCodiceRetribuzioneRN') AS XQueryPattern
SELECT dbo.fnGetXQueryPattern(2, NULL) AS XQueryPattern
SELECT dbo.fnGetXQueryPattern(NULL, 'ContributoNormalePerCodiceRetribuzioneRN') AS XQueryPattern
*/
ALTER FUNCTION [dbo].[fnGetXQueryPattern](@IDXQuery int=NULL, @Descrizione varchar(50)=NULL)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @RETVAL varchar(MAX) = NULL

	IF ISNULL(@IDXQuery,0) != 0
	OR ISNULL(@Descrizione,'') != ''
		BEGIN
			SELECT	@RETVAL = XQueryPattern
			FROM	XQUERY_RULES WITH(NOLOCK)
			WHERE	(IDXQuery = @IDXQuery OR @IDXQuery IS NULL)
			AND		(Descrizione = @Descrizione OR @Descrizione IS NULL)
		END

	RETURN @RETVAL
END
