USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnTMPGetStructure]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnTMPGetStructure - SISTEMA TMP
----------------------------------------

NELL'AMBITO DEL MICROSISTEMA DI GESTIONE DI DATI TABELLARI TEMPORANEI (SISTEMA "TMP"), QUESTA FUNZIONE E' PREPOSTA ALLA 
RAPPRESENTAZIONE DELLA STRUTTURA TABELLARE DELLA TABELLA TEMPORANEA CREATA DALLA STORED PROCEDURE "spTMPcreate" E SUCCESSIVAMENTE
MODIFICATA DALLA STORED PROCEDURE "spTMPaddColumns"

-- ESEMPI DI INVOCAZIONE

SELECT * FROM dbo.fnTMPGetStructure()
*/
CREATE FUNCTION [dbo].[fnTMPGetStructure]()
RETURNS @FIELDINFO TABLE
		(
			fieldName varchar(128)
			,castedFieldName varchar(128)
			,fieldType varchar(128)
			,fieldLenght int
			,fieldPrecision int
			,fieldScale int
			,xmlPattern varchar(MAX)
			,fieldWithLength varchar(MAX)
			,OrdinalPosition int --NOT NULL
			,ColumnDefault varchar(MAX) --NULL
			,IsNullable BIT --NOT NULL
			,IsPK BIT --NOT NULL
			,PK varchar(MAX) --NULL
		)
AS
BEGIN
	INSERT	@FIELDINFO
			(
				fieldName
				,castedFieldName
				,fieldType
				,fieldLenght
				,fieldPrecision
				,fieldScale
				,xmlPattern
				,fieldWithLength
				,OrdinalPosition
				,ColumnDefault
				,IsNullable
				,IsPK
				,PK
			)
	SELECT 
			c.name AS fieldName
			,castedFieldName =
				CASE
					WHEN t.name IN('text', 'ntext', 'xml')
					THEN 'CAST(' + c.name  + ' AS varchar(MAX)) AS ' + c.name
					ELSE c.name 
				END
			,t.name AS fieldType
			,c.length AS fieldLenght
			,c.prec AS fieldPrecision
			,c.scale AS fieldScale
			,c.name + ' = XmlData.value(''(//' + c.name + ')[1]'',''' + 
				CASE
					WHEN t.name = 'text'
					THEN 'varchar(MAX)''' 
					WHEN t.name = 'ntext'
					THEN 'nvarchar(MAX)''' 
					WHEN t.name IN ('char','varchar', 'nchar', 'nvarchar')
					AND c.length = -1
					THEN t.name + '(MAX)'''
					WHEN t.name IN ('char','varchar', 'nchar', 'nvarchar')
					AND c.length > 0
					THEN t.name + '(' + CAST(c.length AS varchar(4)) + ')'''
					WHEN t.name IN ('decimal','numeric')
					THEN t.name + '(' + CAST(c.prec AS varchar(4)) + ',' + CAST(c.scale AS varchar(4)) + ')'''
					ELSE t.name + ''''
				END +
				'),' AS xmlPattern
			,c.name + ' ' +
				CASE 
					WHEN t.name IN ('char','varchar', 'nchar', 'nvarchar')
					AND c.length = -1
					THEN t.name + '(MAX)'
					WHEN t.name IN ('char','varchar', 'nchar', 'nvarchar')
					AND c.length > 0
					THEN t.name + '(' + CAST(c.length AS varchar(4)) + ')'
					WHEN t.name IN ('decimal','numeric')
					THEN t.name + '(' + CAST(c.prec AS varchar(4)) + ',' + CAST(c.scale AS varchar(4)) + ')'
					ELSE t.name
				END +
				',' AS fieldWithLength
			,OrdinalPosition = c.colid
			,ColumnDefault = NULL
			,IsNullable = c.isnullable
			,IsPK = 0
			,PK = NULL
	FROM	tempdb..sysobjects o 
			JOIN
			tempdb..syscolumns c
			ON o.id = c.id
			JOIN 
			tempdb..systypes t
			ON t.xusertype = c.xusertype
	WHERE	O.name LIKE '%##__tmpTable%' 
	AND		o.[type] in (N'U')

	RETURN
END

GO
