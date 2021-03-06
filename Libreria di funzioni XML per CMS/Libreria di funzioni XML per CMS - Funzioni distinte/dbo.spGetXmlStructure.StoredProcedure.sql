USE [Intranetinps_Richieste]
GO
/****** Object:  StoredProcedure [dbo].[spGetXmlStructure]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
spGetXmlStructure
----------------------------------------

STORED PROCEDURE CHE RITORNA LA STRUTTURA COMPLETA (ALBERATURA) DI TUTTI I NODI, A QUALSIASI LIVELLO DI ANNIDAMENTO, DELLA COLONNA DI TIPO XML 
PRESENTE NELLA TABELLA/VISTA SPECIFICATA

-- ESEMPI DI INVOCAZIONE

EXEC	dbo.spGetXmlStructure 
		@tableName = 'VXCROSSDB_TestoConImmagine'
		,@xmlFieldName = 'XmlTestoConImmagine'
		,@criteria = 'WHERE ID_VSNTestoConImmagine = 4'
		,@xmlCriteria = 'WHERE	Value IS NULL AND TreeView LIKE ''%|-%'''
*/
CREATE PROC	[dbo].[spGetXmlStructure] 
			@tableName varchar(MAX) = NULL
			,@xmlFieldName varchar(128) = NULL
			,@criteria varchar(MAX) = NULL
			,@xmlCriteria varchar(MAX) = NULL
AS

/*
-- ESEGUIRE IL SEGUENTE STATEMENT SE NEL DB NON E' PRESENTE QUESTO USERTYPE
CREATE TYPE dbo.XMLSTRUCTURE_TYPE AS TABLE
(
	ID int
	,ParentPosition smallint
	,Depth smallint
	,NodeName varchar(128)
	,NodeType varchar(50)
	,FullPath varchar(MAX)
	,XPath varchar(MAX)
	,TreeView varchar(MAX)
	,Value varchar(MAX)
	,XmlData XML
)
*/
DECLARE @SQL varchar(MAX)
IF ISNULL(@tableName,'') != ''
AND ISNULL(@xmlFieldName,'') != ''
	BEGIN
		SET @SQL =
		'
		DECLARE @XML XML
		DECLARE @structure XMLSTRUCTURE_TYPE 

		SELECT	@XML = ' + @xmlFieldName + ' 
		FROM	' + @tableName + ' 
		' + ISNULL(@criteria,'') +
		'
		INSERT	@structure
				(
					ID
					,ParentPosition
					,Depth
					,NodeName
					,NodeType
					,FullPath
					,XPath
					,TreeView
					,Value
					,XmlData
				)

		SELECT 
				ID
				,ParentPosition
				,Depth
				,NodeName
				,NodeType
				,FullPath
				,XPath
				,TreeView
				,Value
				,XmlData
		FROM	dbo.fnXml2Table(@XML)

		SELECT *
		FROM @structure
		' + ISNULL(@XmlCriteria,'')

		--PRINT(@SQL)
		EXEC(@SQL)
	END
GO
