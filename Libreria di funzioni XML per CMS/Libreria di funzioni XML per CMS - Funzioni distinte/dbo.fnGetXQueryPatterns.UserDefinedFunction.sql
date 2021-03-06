USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetXQueryPatterns]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetXQueryPatterns
----------------------------------------

FUNZIONE PREPOSTA ALL’ESTRAZIONE DEL PATTERN XQUERY DI UN DETERMINATO CAMPO (PREVENTIVAMENTE MAPPATO) DALLA TABELLA DEDICATA XQUERY_RULES 
IN BASE ALL’ID O ALLA DESCRIZIONE

-- ESEMPI DI INVOCAZIONE

SELECT * FROM dbo.fnGetXQueryPatterns(1)
*/
CREATE FUNCTION [dbo].[fnGetXQueryPatterns](@IDGroup int=NULL)
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

GO
