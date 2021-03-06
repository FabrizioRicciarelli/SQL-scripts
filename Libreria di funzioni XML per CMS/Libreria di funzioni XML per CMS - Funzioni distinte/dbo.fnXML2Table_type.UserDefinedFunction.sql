USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnXML2Table_type]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnXML2Table_type
----------------------------------------

*******************************
*** DA RIVEDERE E SISTEMARE ***
*******************************

FUNZIONE ATTA AL PARSING DI QUALUNQUE STRUTTURA XML, CAPACE DI RITORNARE UNA NUTRITA SERIE DI INFORMAZIONI, IN FORMA TABELLARE, 
INERENTI LA STRUTTURA NODALE, I CAMPI (TAGS) E LORO CARATTERISTICHE (DATATYPE, DATALENGHT)

-- ESEMPI DI INVOCAZIONE

DECLARE @XmlField XML
SELECT @XmlField = XmlPagina FROM VSN_Pagina WHERE IDPagina = 8754 AND Versione = 9
SELECT * FROM fnXML2Table_type(@XmlField)
*/
CREATE FUNCTION [dbo].[fnXML2Table_type](@x XML)  
RETURNS TABLE 
AS 

RETURN 
WITH cte AS 
(  
	SELECT 
			1 AS lvl
			,x.value('local-name(.)','NVARCHAR(MAX)') AS Name
			,(SELECT BestDataType FROM dbo.fnGetMostProbableXmlTagDataType(@x,x.value('local-name(.)','NVARCHAR(MAX)'))) AS [Type]  
			,CAST(NULL AS NVARCHAR(MAX)) AS ParentName 
			,CAST(1 AS INT) AS ParentPosition 
			,CAST(N'Element' AS NVARCHAR(20)) AS NodeType  
			,x.value('local-name(.)','NVARCHAR(MAX)') AS FullPath  
			,x.value('local-name(.)','NVARCHAR(MAX)') + N'[' + CAST(ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS NVARCHAR) + N']' AS XPath  
			,ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS Position 
			,x.value('local-name(.)','NVARCHAR(MAX)') AS Tree  
			,x.value('text()[1]','NVARCHAR(MAX)') AS Value  
			,x.query('.') AS this         
			,x.query('*') AS t  
			,CAST(CAST(1 AS VARBINARY(4)) AS VARBINARY(MAX)) AS Sort  
			,CAST(1 AS INT) AS ID  
	FROM	@x.nodes('/*') a(x)  

	UNION ALL 

	SELECT 
			p.lvl + 1 AS lvl
			,c.value('local-name(.)','NVARCHAR(MAX)') AS Name
			,(SELECT BestDataType FROM dbo.fnGetMostProbableXmlTagDataType(@x,c.value('local-name(.)','NVARCHAR(MAX)'))) AS [Type]  
			,CAST(p.Name AS NVARCHAR(MAX)) AS ParentName
			,CAST(p.Position AS INT) AS ParentPosition
			,CAST(N'Element' AS NVARCHAR(20)) AS NodeType
			,CAST(p.FullPath + N'/' + c.value('local-name(.)','NVARCHAR(MAX)') AS NVARCHAR(MAX)) AS FullPath
			,CAST(p.XPath + N'/'+ c.value('local-name(.)','NVARCHAR(MAX)')+ N'['+ CAST(ROW_NUMBER() OVER(PARTITION BY c.value('local-name(.)','NVARCHAR(MAX)') ORDER BY (SELECT 1)) AS NVARCHAR)+ N']' AS NVARCHAR(MAX)) AS XPath
			,ROW_NUMBER() OVER(PARTITION BY c.value('local-name(.)','NVARCHAR(MAX)') ORDER BY (SELECT 1)) AS Position
			,CAST( SPACE(2 * p.lvl - 1) + N'|' + REPLICATE(N'-', 1) + c.value('local-name(.)','NVARCHAR(MAX)') AS NVARCHAR(MAX)) AS Tree
			,CAST( c.value('text()[1]','NVARCHAR(MAX)') AS NVARCHAR(MAX) ) AS Value, c.query('.') AS this
			,c.query('*') AS t
			,CAST(p.Sort + CAST( (lvl + 1) * 1024 + (ROW_NUMBER() OVER(ORDER BY (SELECT 1)) * 2) AS VARBINARY(4)) AS VARBINARY(MAX) ) AS Sort
			,CAST((lvl + 1) * 1024 + (ROW_NUMBER() OVER(ORDER BY (SELECT 1)) * 2) AS INT)  
	FROM	cte p  
			CROSS APPLY 
			p.t.nodes('*') b(c))
			,cte2 AS 
			(  
                SELECT 
						lvl AS Depth
						,Name AS NodeName 
						,[Type]
						,ParentName
						,ParentPosition
						,NodeType
						,FullPath
						,XPath
						,Position
						,Tree AS TreeView
						,Value
						,this AS XMLData
						,Sort 
						,ID  
                FROM	cte  

				UNION ALL 

				SELECT 
						p.lvl  
						,x.value('local-name(.)','NVARCHAR(MAX)')  
						,(SELECT BestDataType FROM dbo.fnGetMostProbableXmlTagDataType(@x,x.value('local-name(.)','NVARCHAR(MAX)'))) AS [Type]  
						,p.Name 
						,p.Position 
						,CAST(N'Attribute' AS NVARCHAR(20)) 
						,p.FullPath + N'/@' + x.value('local-name(.)','NVARCHAR(MAX)')  
						,p.XPath + N'/@' + x.value('local-name(.)','NVARCHAR(MAX)')  
						,1
						,SPACE(2 * p.lvl - 1) + N'|' + REPLICATE('-', 1)	+ N'@' + x.value('local-name(.)','NVARCHAR(MAX)') 
						,x.value('.','NVARCHAR(MAX)')  
						,NULL  
						,p.Sort 
						,p.ID + 1  
				FROM	cte p  
						CROSS APPLY 
						this.nodes('/*/@*') a(x)  
			)  

SELECT 
        ROW_NUMBER() OVER(ORDER BY Sort, ID) AS ID  
        ,ParentName
		,ParentPosition
		,Depth
		,NodeName
		,[Type]
		,Position   
        ,NodeType
		,FullPath
		,XPath
		,TreeView
		,Value
		,XMLData 
FROM	cte2

GO
