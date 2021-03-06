USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetXQueryResultDataType]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetXQueryResultDataType
----------------------------------------

FUNZIONE PREPOSTA ALL’ESTRAZIONE DEL TIPO DI DATO DI UN DETERMINATO CAMPO (PREVENTIVAMENTE MAPPATO) DALLA TABELLA DEDICATA XQUERY_RULES 
IN BASE ALL’ID O ALLA DESCRIZIONE

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnGetXQueryResultDataType(1, NULL) AS XQueryResultDataType
SELECT dbo.fnGetXQueryResultDataType(NULL, 'Galleria_Titolo') AS XQueryResultDataType
SELECT dbo.fnGetXQueryResultDataType(2, NULL) AS XQueryResultDataType
SELECT dbo.fnGetXQueryResultDataType(NULL, 'Galleria_IDgalleria') AS XQueryResultDataType
*/
CREATE FUNCTION [dbo].[fnGetXQueryResultDataType](@IDXQuery int=NULL, @Descrizione varchar(50)=NULL)
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

GO
