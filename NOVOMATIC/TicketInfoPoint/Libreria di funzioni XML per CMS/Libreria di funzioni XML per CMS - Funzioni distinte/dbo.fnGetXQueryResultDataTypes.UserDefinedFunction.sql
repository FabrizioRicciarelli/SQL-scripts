USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetXQueryResultDataTypes]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetXQueryResultDataTypes
----------------------------------------

FUNZIONE PREPOSTA ALL’ESTRAZIONE DEL TIPO DI DATO DI UN DETERMINATO CAMPO (PREVENTIVAMENTE MAPPATO) DALLA TABELLA DEDICATA XQUERY_RULES 
IN BASE ALL’ID O ALLA DESCRIZIONE

-- ESEMPI DI INVOCAZIONE

SELECT * FROM dbo.fnGetXQueryResultDataTypes(1)
*/
CREATE FUNCTION [dbo].[fnGetXQueryResultDataTypes](@IDGroup int=NULL)
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

GO
