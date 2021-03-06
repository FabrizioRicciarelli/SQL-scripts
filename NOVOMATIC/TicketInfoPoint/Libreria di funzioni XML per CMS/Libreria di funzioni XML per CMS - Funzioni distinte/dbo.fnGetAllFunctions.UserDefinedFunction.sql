USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetAllFunctions]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetAllFunctions
----------------------------------------

FUNZIONE CHE RITORNA L'ELENCO DELLE FUNZIONI PRESENTI NEL DB CORRENTE, CORREDATE DEL LORO CODICE T-SQL E LA LORO TIPOLOGIA

-- ESEMPI DI INVOCAZIONE

SELECT * FROM dbo.fnGetAllFunctions() ORDER BY FunctionType,[Name]
SELECT * FROM dbo.fnGetAllFunctions() ORDER BY [Name], FunctionType
*/
CREATE FUNCTION [dbo].[fnGetAllFunctions]()
RETURNS	@FUNCLIST TABLE
		(
			[Name] sysname
			,[Definition] varchar(MAX)
			,FunctionType varchar(255)
		)
AS
BEGIN
	INSERT	@FUNCLIST 
			(
				[Name]
				,[Definition]
				,FunctionType
			)
	SELECT
			name AS [Name]
			,definition AS [Definition]
			,type_desc AS FunctionType
	FROM	sys.sql_modules m 
			INNER JOIN 
			sys.objects o 
			ON m.object_id = o.object_id
	WHERE	type_desc like '%function%'

	RETURN
END
GO
