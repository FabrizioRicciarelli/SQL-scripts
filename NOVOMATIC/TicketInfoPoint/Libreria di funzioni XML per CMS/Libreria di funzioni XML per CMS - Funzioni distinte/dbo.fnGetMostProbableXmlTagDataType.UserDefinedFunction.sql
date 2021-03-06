USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetMostProbableXmlTagDataType]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetMostProbableXmlTagDataType
----------------------------------------

FUNZIONE CHE PRELEVA TUTTI I TAG PRESENTI ALL'INTERNO DI UN DATO XML (CHE SI PUO', COME  INDICATO NEGLI ESEMPI, PRELEVARE DALLA COLONNA XML DI UNA TABELLA)
E CERCA DI ATTRIBUIRVI IN MODO PREDITTIVO, TRAMITE LA RICERCA DI TUTTE LE COLONNE PRESENTI IN TUTTE LE TABELLE DEL DATABASE CORRENTE, IL TIPO DI DATO PIU'
VEROSIMILE.

L'ANALISI PREDITTIVA E' APPLICABILE IN TUTTI QUEI CASI IN CUI IL DATO XML SIA STATO GENERATO PARTENDO DALLE COLONNE DELLE TABELLE PRESENTI NEL DATABASE SUL
QUALE SI STA INVOCANDO LA FUNZIONE: IN QUESTA SITUAZIONE E' MOLTO PROBABILE, E RICORRENTE, EFFETTUARE UN REVERSE-ENGINEERING DEL DATO NON-TIPIZZATO, OVVERO
QUELLO CORRISPONDENTE AD UN TAG XML *NON LEGATO AD UN NAMESPACE* FORTEMENTE TIPIZZATO

LA RESTITUZIONE DEL TIPO DI DATO PRESUNTO PUO' AVVENIRE RELATIVAMENTE AD UN SINGOLO TAG O A FRONTE DI TUTTI TAG TROVATI ALL'INTERNO DEL DATO XML: SE IL PARAMETRO
OPZIONALE "@tagName" VIENE VALORIZZATO, IL SUO VALORE - SE TROVATO ALL'INTERNO DEL DATO XML - SARA' UTILIZZATO PER LA RICERCA DEL TIPO DI DATO PIU' PROSSIMO
RELATIVAMENTE A QUEL NOME DI COLONNA IN TUTTE LE TABELLE DEL DB CORRENTE.

QUALORA, INVECE, IL PARAMETRO OPZIONALE "@tagName" VENGA VALORIZZATO A NULL, SARANNO PRESI IN ESAME TUTTI I TAGS INDIVIDUATI NEL DATO XML E PER CIASCUNO DI ESSI
VERRA' EFFETTUATA UNA RICERCA PER TUTTE LE COLONNE AVENTI UN NOME CORRISPONDENTE IN TUTTE LE TABELLE DEL DB CORRENTE.

-- ESEMPI DI INVOCAZIONE

DECLARE @XmlField XML
SELECT	@XmlField = XmlPagina 
FROM	VSN_Pagina 
WHERE	IDPagina = 8754 
AND Versione = 9

-- SINGOLO TAG
SELECT * FROM dbo.fnGetMostProbableXmlTagDataType(@XmlField,'Bullet')
SELECT * FROM dbo.fnGetMostProbableXmlTagDataType(@XmlField,'Data_Creazione')
SELECT * FROM dbo.fnGetMostProbableXmlTagDataType(@XmlField,'Testo')
SELECT * FROM dbo.fnGetMostProbableXmlTagDataType(@XmlField,'IdLink')

-- INTERO SET DI TAG
SELECT * FROM dbo.fnGetMostProbableXmlTagDataType(@XmlField,NULL)
*/
CREATE FUNCTION	[dbo].[fnGetMostProbableXmlTagDataType]
				(
					@XmlField XML = NULL
					,@tagName varchar(128) = NULL
				)
RETURNS @TagData TABLE
		(
			NodeName varchar(128)
			,ParentName varchar(128)
			,XmlSource varchar(MAX)
			,BestDataType varchar(MAX)
		)
AS
BEGIN
	INSERT	@TagData
			(
				NodeName
				,ParentName
				,XmlSource
				,BestDataType
			)
	SELECT	DISTINCT
			NodeName
			,ParentName
			,CAST(SourceObject AS varchar(MAX)) AS XmlSource
			,CAST(SourceObject AS XML).value('(//DataType[../ThisDataTypeOccurrences = max(../ThisDataTypeOccurrences) and not(. < //DataType)])[1]','varchar(max)') AS BestDataType  
	FROM
	(
		SELECT	DISTINCT
				XLIST.ParentName
				,XLIST.NodeName
				,CAST
				(
					(
						SELECT	
								XLIST.NodeName AS "@nodename"
								,
								(
									SELECT	DISTINCT
											ObjectName AS TableName
											,DataType =
											CASE 
												WHEN typename in ('char', 'varchar', 'nvarchar', 'varbinary')
												AND [length] != -1
												THEN typename + '(' + CAST([length] AS varchar(26)) + ')'
												WHEN typename in ('char', 'varchar', 'nvarchar', 'varbinary')
												AND [length] = -1
												THEN typename + '(MAX)'
												ELSE typename
											END
											,COUNT(*) OVER (PARTITION BY typename ORDER BY typename) AS ThisDataTypeOccurrences
											,COUNT(*) OVER (PARTITION BY 0) AS TotalDataTypeOccurrences
											,LongestForThisDataType =
											CASE
												WHEN MIN([length]) OVER (PARTITION BY typename ORDER BY typename) = -1
												AND typename in ('char', 'varchar', 'nvarchar', 'varbinary', 'text', 'ntext')
												THEN 'MAX'
												ELSE CAST(MAX([length]) OVER (PARTITION BY typename ORDER BY typename) AS varchar(5))
											END
											,LongestForAllDataTypes =
											CASE
												WHEN MIN([length]) OVER () = -1
												AND typename in ('char', 'varchar', 'nvarchar', 'varbinary', 'text', 'ntext')
												THEN 'MAX'
												ELSE CAST(MAX([length]) OVER () AS varchar(5))
											END
									FROM	dbo.fnGetAllTablesByColumnName(XLIST.NodeName) 
									FOR XML PATH('Source'), TYPE
								)
								FOR XML PATH('DataTypes')
					) 
					AS varchar(MAX)
				) AS SourceObject
		FROM	dbo.fnXML2Table(@XmlField) XLIST
		WHERE	ParentName IS NOT NULL
		AND		(XLIST.NodeName = @tagName OR  @tagName IS NULL)
	) A
	ORDER BY
			A.NodeName
			,A.ParentName
	RETURN 
END
GO
