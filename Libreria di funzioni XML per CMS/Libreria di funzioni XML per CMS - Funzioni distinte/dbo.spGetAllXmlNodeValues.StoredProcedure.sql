USE [Intranetinps_Richieste]
GO
/****** Object:  StoredProcedure [dbo].[spGetAllXmlNodeValues]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
spGetAllXmlNodeValues
----------------------------------------

STORED PROCEDURE ATTA A RITORNARE, IN FORMA TABELLARE, IL CONTENUTO DI QUALSIASI COLONNA XML, ANCHE SE IL LIVELLO DI ANNIDAMENTO E' PARTICOLARMENTE ONEROSO.
COME PARAMETRI IN INGRESSO ACCETTA IL NOME DELLA TABELLA, IL NOME DELLA COLONNA XML CONTENENTE LA STRUTTURA, UN CRITERIO DI FILTRO CHE SARA' APPLICATO ALLE 
COLONNE *NON XML* DELLA TABELLA SPECIFICATA

-- ESEMPI DI INVOCAZIONE

EXEC spGetAllXmlNodeValues 'VSN_LINK','XmlLink','ID_Link = 15122'
EXEC spGetAllXmlNodeValues 'VSN_Banner','XmlBanner','Id_VsnBanner = 10'
EXEC spGetAllXmlNodeValues 'VSN_Lista','XmlLista','IdVsnLista = 17'
EXEC spGetAllXmlNodeValues 'VSN_Galleria','XmlGalleria','IdGalleria = 1109170 AND Id_VsnGalleria = 36'
EXEC spGetAllXmlNodeValues 'VSN_Pagina','XmlPagina','IDPagina = 8754 AND Versione = 9'

-- Vedere anche la seguente SP, capace di identificare con esattezza il tipo di dato di ciascuna colonna corrispondente ai vari tag presenti nell'Xml (incapace, però, di estrarre i dati delle strutture annidate)
EXEC spXML2Table 'VSN_LINK','XmlLink','ID_Link = 15122'
EXEC spXML2Table 'VSN_Banner','XmlBanner','Id_VsnBanner = 10' -- va in errore
EXEC spXML2Table 'VSN_Lista','XmlLista','IdVsnLista = 17'
EXEC spXML2Table 'VSN_Galleria','XmlGalleria','IdGalleria = 1109170 AND Id_VsnGalleria = 36'
EXEC spXML2Table 'VSN_Pagina','XmlPagina','IDPagina = 8754 AND Versione = 9'
*/
CREATE PROC [dbo].[spGetAllXmlNodeValues]
			@tableName varchar(MAX)=NULL
			,@xmlFieldName varchar(128)=NULL
			,@criteria varchar(MAX)=NULL
AS
IF ISNULL(@tableName,'') != ''
AND ISNULL(@xmlFieldName,'') != ''
	BEGIN
		SET @criteria = dbo.fnCompleteCriteria(@criteria)
	
		DECLARE 
				@SQL Nvarchar(MAX)
				,@XmlFieldContents XML   
				,@ParmDefinition Nvarchar(500);		
		
		SET @SQL =
		N'
		DECLARE @XmlField XML
		SELECT @XmlFieldContentsOUT = ' + @xmlFieldName + ' FROM ' + @tableName + @criteria + '
		'
		SET @ParmDefinition = N'@XmlFieldContentsOUT XML OUTPUT';

		EXEC sp_executesql @SQL, @ParmDefinition, @XmlFieldContentsOUT = @XmlFieldContents OUTPUT;
		
		--SELECT NodeName AS TagName, Value FROM fnXML2Table(@XmlFieldContents) WHERE Value IS NOT NULL

		DECLARE @Names TABLE (NodeName varchar(128))
		INSERT	@Names
		SELECT	DISTINCT
				NodeName
		FROM	fnXML2Table(@XmlFieldContents) 
		WHERE	Value IS NOT NULL
		ORDER BY NodeName


		DECLARE	@columns NVARCHAR(MAX)
		SET		@columns = N'';

		SELECT	@columns += N', B.' + QUOTENAME(NodeName)
		FROM	@Names 

		SET @SQL = N'
		SELECT ' + STUFF(@columns, 1, 2, '') + '
		FROM
		(
			SELECT	
					Depth
					,ParentPosition
					,NodeName 
					,Value
			FROM	fnXML2Table(''' + CAST(@XmlFieldContents AS varchar(MAX)) + ''') 
			WHERE	Value IS NOT NULL
		) AS A
		PIVOT
		(
		  MAX(Value) FOR NodeName IN ('
		  + STUFF(REPLACE(@columns, ', B.[', ',['), 1, 1, '')
		  + ')
		) AS B;';
		PRINT @SQL;
		EXEC sp_executesql @SQL;
	END

GO
