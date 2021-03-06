USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetIDcolumn]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetIDcolumn
----------------------------------------

FUNZIONE ATTA A RITORNARE LA COLONNA IDENTITY (QUANDO PRESENTE) DELLA TABELLA SPECIFICATA NEL PARAMETRO "@tableName". SE NON SONO PRESENTI
COLONNE DI TIPO IDENTITY, LA FUNZIONE RITORNERA' LA PRIMA COLONNA DI TIPO PRIMARY KEY

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnGetIDcolumn('Aree') AS ID
SELECT dbo.fnGetIDcolumn('Link') AS ID
SELECT dbo.fnGetIDcolumn('Pagine') AS ID
SELECT dbo.fnGetIDcolumn('TestoConImmagine') AS ID
SELECT dbo.fnGetIDcolumn('TestoDoppio') AS ID
*/
CREATE FUNCTION [dbo].[fnGetIDcolumn](@tableName varchar(128)=NULL)
RETURNS varchar(128)
AS
BEGIN
	DECLARE	@RETVAL varchar(128) = NULL

	IF ISNULL(@tableName,'') != ''
		BEGIN
			SELECT	@RETVAL = 
					ColumnName 
			FROM	dbo.fnGetIDcolumnProp(@tableName)
		END
	RETURN @RETVAL
END


GO
