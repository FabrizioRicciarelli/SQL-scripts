USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnPurge]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnPurge
----------------------------------------

FUNZIONE ATTA ALLA RIMOZIONE DI DELIMITATORI E PARENTESI QUADRE DAI NOMI COMPLETI DI 
TABELLE, VISTE, STORED PROCEDURES E FUNZIONI, RITORNANDO SOLO IL NOME DELL’OGGETTO

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnPurge('[Intranetinps_Lavoro].[dbo].[Link]') AS PURGEDTABLENAME
SELECT dbo.fnPurge('Intranetinps_Lavoro.IntranetInps.dirforupload_appo') AS PURGEDTABLENAME
*/
CREATE FUNCTION	[dbo].[fnPurge](@tableName varchar(MAX) = NULL)
RETURNS varchar(128)
AS
BEGIN
	DECLARE @RETVAL varchar(128)
	
	IF ISNULL(@tableName,'') != ''
		BEGIN
			SET @RETVAL = REPLACE(REPLACE(@tableName, '[',''),']','')
			SET	@RETVAL = dbo.fnRightPart(@RETVAL, 'dbo.')
			SET	@RETVAL = dbo.fnRightPart(@RETVAL, 'IntranetInps.')
			SET	@RETVAL = dbo.fnRightPart(@RETVAL, 'IntranetInps_Lavoro.')
			SET	@RETVAL = dbo.fnRightPart(@RETVAL, 'IntranetInps_Richieste.')
		END

	RETURN @RETVAL
END

GO
