USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetNewsXml]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetNewsXml(8754,NULL,NULL) AS XmlNews
SELECT dbo.fnGetNewsXml(8754,NULL,5) AS XmlNews
SELECT dbo.fnGetNewsXml(8754,NULL,-1) AS XmlNews
*/
CREATE FUNCTION [dbo].[fnGetNewsXml](@Id_Pagina int = NULL, @Id_News int = NULL, @Id_Versione int = NULL)
RETURNS XML
AS
BEGIN
	DECLARE 
			@RETVAL XML
			,@FormattazioneNEWS varchar(MAX)

	SELECT	@FormattazioneNEWS =
			CASE C.value('(//formattazione)[1]','int')
				WHEN 1
				THEN 'NewsLaterali'
				ELSE 'NewsCentrali'
			END
	FROM	VSN_NewsInPage NIP WITH(NOLOCK)
			INNER JOIN
			VSN_ContenutoNews CN WITH(NOLOCK)
			ON NIP.IdNewsInPage = CN.Id_NewsInPage
			CROSS APPLY NIP.XmlBloccoNews.nodes('/') AS X(C)
	WHERE	1=1
	AND		IdVsnContenutoNews = @Id_Versione
				

	SET @RETVAL =
	(
		SELECT
			CASE
				WHEN ISNULL(@Id_Versione,0) = 0 
				THEN
				(
					SELECT
					(
						SELECT	* 
						FROM	VW_News 
						WHERE	(Id_NewsInPage = @Id_News OR @ID_News IS NULL)
						AND		(Id_Page = @Id_Pagina OR @ID_Pagina IS NULL)
						FOR XML PATH('News'), TYPE
					)
					FOR XML PATH(''),ROOT('XmlNews')
				)
				WHEN ISNULL(@Id_Versione,0) > 0
				THEN  
				(
					SELECT	dbo.fnReplaceXmlNodeName
							(
								(
									SELECT
											IdVsnContenutoNews
											,C.value('(//id_newsinpage)[1]','varchar(MAX)') AS id_newsinpage
											,C.value('(//id_page)[1]','varchar(MAX)') AS id_page
											,C.value('(//formattazione)[1]','varchar(MAX)') AS formattazione
											,D.value('(//titolo)[1]','varchar(MAX)') AS titolo
											,D.value('(//abstract)[1]','varchar(MAX)') AS abstract
											,D.value('(//testo)[1]','varchar(MAX)') AS testo
											,D.value('(//ordinamento)[1]','varchar(MAX)') AS ordinamento
											,D.value('(//data)[1]','varchar(MAX)') AS data
											,D.value('(//id_contenuto)[1]','varchar(MAX)') AS id_contenuto
											,D.value('(//urlImage)[1]','varchar(MAX)') AS urlImage
											,D.value('(//id_area)[1]','varchar(MAX)') AS id_area
									FROM	VSN_NewsInPage NIP WITH(NOLOCK)
											INNER JOIN
											VSN_ContenutoNews CN WITH(NOLOCK)
											ON NIP.IdNewsInPage = CN.Id_NewsInPage
											CROSS APPLY NIP.XmlBloccoNews.nodes('/') AS X(C)
											CROSS APPLY CN.XmlContenutoNews.nodes('/') AS X2(D)
									WHERE	1=1
									AND		IdVsnContenutoNews = @Id_Versione
									FOR	XML PATH('News'),ROOT('Root'), TYPE, ELEMENTS
								)
								,'Root'
								,@FormattazioneNews 
							)
				)
			END
	)
	RETURN @RETVAL
END		
		
GO
