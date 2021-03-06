USE [Intranetinps_Richieste]
GO
/****** Object:  StoredProcedure [dbo].[spGetMostProbableXmlTagDataType]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
DECLARE @TEMP TABLE(NodeName varchar(MAX), BestDataType varchar(MAX))
INSERT @TEMP
EXEC spGetMostProbableXmlTagDataType 'VSN_Pagina', 'XmlPagina', NULL, ' WHERE IDPagina = 8754 AND Versione = 8'

SELECT	*
FROM	@TEMP 
WHERE	BestDataType IS NOT NULL

DECLARE @fieldsList varchar(MAX)
SELECT	@fieldsList = COALESCE(@fieldsList, '') + '[' + NodeName + '] ' + BestDataType + ', '
FROM	@TEMP
WHERE	BestDataType IS NOT NULL

SELECT dbo.fnTrimCommas(@fieldsList)
*/
CREATE PROC [dbo].[spGetMostProbableXmlTagDataType](@tableName varchar(MAX) = NULL, @XmlFieldName varchar(128) = NULL, @tagName varchar(128) = NULL, @criteria varchar(MAX))
AS

DECLARE @SQL varchar(MAX)
SET @tagName = 
	CASE 
		WHEN @tagName IS NOT NULL 
		THEN '''' + @tagName + '''' 
		ELSE 'NULL' 
	END

SET @SQL =
'
DECLARE @XmlField XML
SELECT	@XmlField = ' + @XmlFieldName + ' 
FROM	' + @tableName + 
@criteria +
'
SELECT	DISTINCT
		NodeName
		--,ParentName
		--,CAST(XmlSource AS XML) AS XmlSource
		,CAST(XmlSource AS XML).value(''(//DataType[../ThisDataTypeOccurrences = max(../ThisDataTypeOccurrences) and not(. < //DataType)])[1]'',''varchar(max)'') AS BestDataType  
FROM	dbo.fnGetGetMostProbableXmlTagDataType(@XmlField,' + @tagName + ')

ORDER BY
		NodeName
		--,ParentName
'
PRINT(@SQL)
EXEC(@SQL)
/*

SELECT	DISTINCT
		XLIST.ParentName
		,XLIST.NodeName
		--,CAST((SELECT * FROM dbo.fnGetAllTablesByColumnName(XLIST.NodeName) FOR XML PATH(''''),TYPE, ELEMENTS) AS varchar(MAX)) AS AllColumnProps
		--,CAST((SELECT DISTINCT ObjectName, name AS ColumnName, typename, [length] FROM dbo.fnGetAllTablesByColumnName(XLIST.NodeName) FOR XML PATH(''''),TYPE, ELEMENTS) AS varchar(MAX)) AS ParentTable_ObjectName
		,CAST((SELECT DISTINCT xtype, [length] FROM dbo.fnGetAllTablesByColumnName(XLIST.NodeName) FOR XML PATH(''''),TYPE, ELEMENTS) AS varchar(MAX)) AS ParentTable_ObjectName
FROM	fnXML2Table(@XmlField) XLIST
WHERE	ParentName IS NOT NULL
ORDER BY
		ParentName
		,NodeName


DECLARE 
		@fieldList varchar(MAX)
		,@fieldListWithDataType varchar(MAX)
SELECT 
		@fieldList = COALESCE(@fieldList, '') + fieldName + ', '
		,@fieldListWithDataType = COALESCE(@fieldListWithDataType, '') + ' ' + fieldWithLength
FROM	fnGetColumnDataType('Pagine',NULL) 

SELECT 
		dbo.fnTrimCommas(@fieldList) AS fieldList
		,dbo.fnTrimCommas(@fieldListWithDataType) AS fieldListWithDataType

SELECT * FROM SYSTYPES
*/
GO
