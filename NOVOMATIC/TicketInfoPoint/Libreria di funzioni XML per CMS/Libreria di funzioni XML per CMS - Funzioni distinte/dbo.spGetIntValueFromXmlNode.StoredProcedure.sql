USE [Intranetinps_Richieste]
GO
/****** Object:  StoredProcedure [dbo].[spGetIntValueFromXmlNode]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
spGetIntValueFromXmlNode
----------------------------------------

STORED PROCEDURE CHE RITORNA UNA TABELLA DI VALORI INTERI CORRISPONDENTI AD UN DETERMINATO XPATH CONTENUTO ALL'INTERNO DELLA COLONNA XML "XmlPagina" 
DELLA TABELLA VSN_PAGINA. I DATI SI RIFERISCONO AL CRITERIO DI FILTRO APPLICATO AL LIVELLO SUPERIORE (QUINDI DI TABELLA, NON DI TAG XML) IN RELAZIONE
AI VALORI SPECIFICATI PER I PARAMETRI "@Id_Pagina" E "@Id_Versione"

-- ESEMPI DI INVOCAZIONE

EXEC	spGetIntValueFromXmlNode
		'/XmlPagina/Liste/Lista'
		,'id_lista'
		,8754
		,8
*/
CREATE PROC	[dbo].[spGetIntValueFromXmlNode]
			@XmlRootNode varchar(MAX) = NULL
			,@XmlNodeName varchar(MAX) = NULL
			,@Id_Pagina int = NULL
			,@Id_Versione int = NULL
AS

DECLARE	@SQL varchar(MAX)

SET @SQL =
'
	SELECT	
			IntValue = CAST(REPLACE(REPLACE(CAST(C.query(''./' + @XmlNodeName + ''') AS nvarchar(MAX)),''<'  + @XmlNodeName + '>'',''''),''</' + @XmlNodeName + '>'','''') AS int)
	FROM	VSN_Pagina AS T WITH(NOLOCK) 
			CROSS APPLY T.XmlPagina.nodes(''' + @XmlRootNode +''') AS X(C)
	WHERE	IdPagina = ' + CAST(@Id_Pagina AS varchar(26)) + '
	AND		Versione = ' + CAST(@Id_versione AS varchar(26)) + '
'
PRINT(@SQL)
EXEC(@SQL)
GO
