USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetIDcolumnProp]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetIDcolumnProp
----------------------------------------

FUNZIONE CHE RITORNA UNA TABELLA A DUE COLONNE RIPORTANTI (QUANDO PRESENTI) SIA IL NOME DEL PRIMO CAMPO IDENTITY E/O PRIMARY KEY 
DELLA TABELLA SPECIFICATA NONCHÉ UN VALORE BOOLEANO SPECIFICANTE SE IL CAMPO È DI TIPO IDENTITY O MENO

-- ESEMPI DI INVOCAZIONE

SELECT ColumnName AS ID FROM dbo.fnGetIDcolumnProp('Aree')
SELECT * FROM dbo.fnGetIDcolumnProp('Aree')

SELECT ColumnName AS ID FROM dbo.fnGetIDcolumnProp('Link')
SELECT * FROM dbo.fnGetIDcolumnProp('Link')

SELECT * FROM dbo.fnGetIDcolumnProp('Pagine')
SELECT * FROM dbo.fnGetIDcolumnProp('TestoConImmagine')
SELECT * FROM dbo.fnGetIDcolumnProp('TestoDoppio')
*/
CREATE FUNCTION [dbo].[fnGetIDcolumnProp](@tableName varchar(128)=NULL)
RETURNS @IDproperties TABLE
	(
		ColumnName varchar(128)
		,IsIdentity bit
	)
AS
BEGIN
	DECLARE	@RETVAL varchar(128) = NULL

	IF ISNULL(@tableName,'') != ''
		BEGIN

			INSERT	@IDProperties
					(
						ColumnName
						,IsIdentity
					)
			SELECT	TOP 1
					A.columnname
					,A.isIdentity
			FROM
			(
				-- RICERCA DELLA COLONNA IDENTITY
				SELECT	
						ic.name AS columnname
						,1 AS isIdentity
						,0 AS ColumnOrder
				FROM	sys.objects AS t
						INNER JOIN 
						sys.identity_columns ic 
						ON t.object_id = ic.object_id
				WHERE	t.Name = @tableName

				UNION

				-- RICERCA DELLA PRIMARY KEY PIU' SIMILE AD UNA IDENTITY
				SELECT
						c.name AS columnname
						,0 AS isIdentity
						,c.column_id AS ColumnOrder
				FROM	sys.objects AS t
						INNER JOIN 
						sys.columns c 
						ON t.object_id = c.object_id
						INNER JOIN
						sys.indexes i 
						on i.object_id = t.object_id
				WHERE	t.Name = @tableName
				AND		i.is_primary_key = 1
				AND		i.is_unique = 1
				AND		c.is_nullable = 0
				AND		c.system_type_id = 56
			) A
			ORDER BY A.ColumnOrder
		END

	RETURN
	
	/*
	-- BASE PER PROVE
	SELECT
			t.name AS tablename
			,c.name AS columnname
			,ic.name AS identitycolumnname
			,i.name AS keyname
			,C.*
	FROM	sys.objects AS t
			INNER JOIN 
			sys.columns c 
			ON t.object_id = c.object_id
			LEFT JOIN 
			sys.identity_columns ic 
			ON t.object_id = ic.object_id
			INNER JOIN
			sys.indexes i 
			on i.object_id = t.object_id
	WHERE	1=1--t.Name = 'Link'
	AND		i.is_primary_key = 1
	AND		i.is_unique = 1
	AND		c.is_nullable = 0
	AND		c.system_type_id = 56
	*/

END
GO
