USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetAllTablesByColumnName]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetAllTablesByColumnName
----------------------------------------

FUNZIONE ATTA RITORNARE L'ELENCO DI TUTTE LE TABELLE CHE CONTENGANO, COME NOME DI COLONNA, IL VALORE SPECIFICATO NEL PARAMETRO "@columnName".
SE IL PARAMETRO SARA' VALORIZZATO A NULL, VERRA' RITORNATO UN RESULTSET CONTENENTE TUTTE LE COLONNE (CON LE RELATIVE PROPRIETA') DI TUTTE LE
TABELLE PRESENTI NEL DATABASE CORRENTE.

-- ESEMPI DI INVOCAZIONE

SELECT * FROM dbo.fnGetAllTablesByColumnName(NULL)
SELECT * FROM dbo.fnGetAllTablesByColumnName('FindEvento')
SELECT * FROM dbo.fnGetAllTablesByColumnName('KeyWord')
*/
CREATE FUNCTION [dbo].[fnGetAllTablesByColumnName](@columnName varchar(max)=NULL)
RETURNS TABLE --WITH SCHEMABINDING
AS
	RETURN
	SELECT	obj.name AS ObjectName
			--,'<-- OBJs | IdentityCols -->' AS '---sep---'
			,col.* 
			,typ.name as typename
	FROM	[syscolumns] col 
			JOIN 
			[sysobjects] obj 
			ON obj.[id] = col.[id]
			join
			[systypes] typ
			ON col.xtype = typ.xtype
	WHERE	(col.name = @columnName OR @columnName IS NULL)
	AND		obj.type = 'U'

GO
