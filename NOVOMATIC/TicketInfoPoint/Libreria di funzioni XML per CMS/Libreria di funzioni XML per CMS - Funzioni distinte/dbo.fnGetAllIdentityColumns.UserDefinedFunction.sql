USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetAllIdentityColumns]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetAllIdentityColumns
----------------------------------------

FUNZIONE ATTA RITORNARE TUTTE LE INFORMAZIONI RELATIVE ALLA COLONNA DI TIPO IDENTITY (SE PREVISTA/PRESENTE) DELLA TABELLA SPECIFICATA. 
SE IL PARAMETRO OPZIONALE "@tableName" NON VIENE VALORIZZATO (UGUALE A NULL), LA FUNZIONE TORNERA' UN SET DI DATI CONTENENTE TUTTE LE COLONNE IDENTITY
DI TUTTE LE TABELLE PRESENTI NEL DATABASE CORRENTE.

-- ESEMPI DI INVOCAZIONE

SELECT * FROM dbo.fnGetAllIdentityColumns(NULL)
SELECT * FROM dbo.fnGetAllIdentityColumns('FindEvento')
SELECT * FROM dbo.fnGetAllIdentityColumns('KeyWord')
SELECT * FROM dbo.fnGetAllIdentityColumns('VSN_TestoSemplice')
*/
CREATE FUNCTION [dbo].[fnGetAllIdentityColumns](@tableName varchar(max)=NULL)
RETURNS TABLE --WITH SCHEMABINDING
AS
	RETURN
	SELECT	obj.name AS ObjectName
			--,'<-- OBJs | IdentityCols -->' AS '---sep---'
			,col.* 
	FROM	[syscolumns] col 
			JOIN 
			[sysobjects] obj 
			ON obj.[id] = col.[id] 
	WHERE	(obj.name = @tableName OR @tableName IS NULL)
	AND		obj.type = 'U'
	AND		col.[status] = 0x80

GO
