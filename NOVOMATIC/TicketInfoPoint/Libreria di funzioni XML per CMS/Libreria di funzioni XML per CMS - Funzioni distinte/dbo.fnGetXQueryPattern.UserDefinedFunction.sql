USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetXQueryPattern]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetXQueryPattern
----------------------------------------

FUNZIONE PREPOSTA ALL’ESTRAZIONE DEL PATTERN XQUERY DI UN DETERMINATO CAMPO (PREVENTIVAMENTE MAPPATO) DALLA TABELLA DEDICATA XQUERY_RULES 
IN BASE ALL’ID O ALLA DESCRIZIONE

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnGetXQueryPattern(1, NULL) AS XQueryPattern
SELECT dbo.fnGetXQueryPattern(NULL, 'Galleria_IDgalleria') AS XQueryPattern
SELECT dbo.fnGetXQueryPattern(2, NULL) AS XQueryPattern
SELECT dbo.fnGetXQueryPattern(NULL, 'Galleria_Titolo') AS XQueryPattern
*/
CREATE FUNCTION [dbo].[fnGetXQueryPattern](@IDXQuery int=NULL, @Descrizione varchar(50)=NULL, @elementIndex int = NULL)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @RETVAL varchar(MAX) = NULL

	IF ISNULL(@IDXQuery,0) != 0
	OR ISNULL(@Descrizione,'') != ''
		BEGIN
			SELECT	@RETVAL = 
					CASE
						WHEN ISNULL(@elementIndex,0) = 0
						THEN XQueryPattern
						ELSE REPLACE(XQueryPattern,'[1]','[' + CAST(@elementIndex AS varchar(5)) + ']')
					END
			FROM	XQUERY_RULES WITH(NOLOCK)
			WHERE	(IDXQuery = @IDXQuery OR @IDXQuery IS NULL)
			AND		(Descrizione = @Descrizione OR @Descrizione IS NULL)
		END

	RETURN @RETVAL
END

GO
