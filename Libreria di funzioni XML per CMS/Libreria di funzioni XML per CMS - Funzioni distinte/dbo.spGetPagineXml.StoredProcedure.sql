USE [Intranetinps_Richieste]
GO
/****** Object:  StoredProcedure [dbo].[spGetPagineXml]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC spGetPagineXml 8754, 9
EXEC spGetPagineXml 8754, NULL
*/
CREATE PROC [dbo].[spGetPagineXml] 
			@Id_Pagina int = NULL
			,@Versione int = NULL
AS
	DECLARE 
			@RETVAL XML
			,@Liste XML
			,@NomePagina varchar(300)
			,@IdVsnTestoSemplice int
			,@IdVsnTestoConImmagine int
			,@IdVsnTestoDoppio int
			,@IdVsnBanner int
			,@IdVsnContenutoNews int
			,@IdVsnGalleria int
			,@IdVsnLista int

	SELECT	
			@IdVsnTestoSemplice = C.value('(//IdVsnTestoSemplice)[1]','int')
			,@IdVsnTestoConImmagine = C.value('(//IdVsnTestoConImmagine)[1]','int')
			,@IdVsnTestoDoppio = C.value('(//IdVsnTestoDoppio)[1]','int')
			,@IdVsnBanner = C.value('(//IdVsnBanner)[1]','int')
			,@IdVsnContenutoNews = C.value('(//IdVsnContenutoNews)[1]','int')
			,@IdVsngalleria = C.value('(//IdVsnGalleria)[1]','int')
			,@IdVsnLista = C.value('(//IdVsnLista)[1]','int')
	FROM	VSN_Pagina AS T WITH(NOLOCK) 
			CROSS APPLY T.XmlPagina.nodes('/') AS X(C)
	WHERE	IdPagina = @ID_Pagina
	AND		Versione = @Versione

	EXEC	dbo.spEstraiListeVSN
			@Id_Pagina = @ID_Pagina
			,@Id_Versione = @Versione
			,@UseRootNodeName = 0
			,@ListeXML = @Liste OUTPUT

	SET	@RETVAL =
		CASE
			WHEN ISNULL(@Versione,0) = 0
			THEN
			(
				SELECT	
						P.*
						,dbo.fnGetTemplateCategoriaXml(P.Id_Pagina,NULL)	
						,dbo.fnGetTestoSempliceXml(P.Id_Pagina, NULL, NULL)
						,dbo.fnGetTestoConImmagineXml(P.Id_Pagina, NULL, NULL)
						,dbo.fnGetTestoDoppioXml(P.Id_Pagina, NULL, NULL)
						,dbo.fnGetBannersXml(P.Id_Pagina, NULL, NULL)
						,dbo.fnGetNewsXml(P.Id_Pagina, NULL, NULL)
						,dbo.fnGetListeXml(P.Id_Pagina, NULL, NULL)
						,dbo.fnGetGallerieXml(P.Id_Pagina, NULL, NULL)
				FROM	Pagine P WITH(NOLOCK)
				WHERE	P.ID_Pagina = @ID_Pagina
				FOR XML PATH(''),ROOT('XmlPagina')
			)
			ELSE
			(
				SELECT
						dbo.fnGetInfoPaginaXml(P.IdPagina,P.Versione)
						,dbo.fnGetTemplateCategoriaXml(P.IdPagina,NULL)	
						,dbo.fnReplaceXmlNodeName(dbo.fnGetTestoDoppioXml(P.IdPagina,NULL,@IdVsnTestoDoppio),'XmlTestoDoppio','TestoDoppio')
						,dbo.fnReplaceXmlNodeName(dbo.fnGetTestoSempliceXml(P.IdPagina,NULL,@IdVsnTestoSemplice),'XmlTestoSemplice','TestoSemplice')
						,dbo.fnReplaceXmlNodeName(dbo.fnGetTestoConImmagineXml(P.IdPagina,NULL,@IdVsnTestoConImmagine),'XmlTestoConImmagine','TestoConImmagine')
						,dbo.fnReplaceXmlNodeName(dbo.fnGetBannersXml(P.IdPagina,NULL,@IdVsnBanner),'XmlBanner','Banners')
						,dbo.fnGetNewsXml(P.IdPagina, NULL, @IdVsnContenutoNews)
						,dbo.fnGetGallerieXml(P.IdPagina, NULL, @IdVsngalleria)
						,@Liste
				FROM	Vsn_Pagina P WITH(NOLOCK)
				WHERE	IdPagina = @ID_Pagina
				AND		Versione = @Versione 
				FOR XML PATH('XMLPageData'), ELEMENTS
			)
		END

	SET @RETVAL = dbo.fnReplaceXmlNodeName(@RETVAL,'XMLPageData','XMLPageData xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"')
	SELECT @RETVAL
GO
