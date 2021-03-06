USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetTemplateCategoriaXml]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetTemplateCategoriaXml(8754,NULL) AS XmlTemplateCategoria -- Restituisce, in formato XML, i dati dalla tabella TemplateCategoriaObject relativi all'"Id_Pagina" specificato (in unione, se indicato, anche all'Id_TemplateCategoria)
*/
CREATE FUNCTION [dbo].[fnGetTemplateCategoriaXml](@Id_Pagina int = NULL, @Id_TemplateCategoria int=NULL)
RETURNS XML
AS
BEGIN
	DECLARE @RETVAL XML

	SET @RETVAL =
	(
		SELECT
		(
			SELECT	
					id_cat
					,voce
					,color_path_img
					,coloredefault
					,coloresfondo
					,colorebordo
					,bullet
					,ordinamento
					,coloreselezionelink
					,descrizione
			FROM	VW_TemplateCategoriePagina WITH(NOLOCK)
			WHERE	(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
			AND		(id_template = @Id_TemplateCategoria OR @Id_TemplateCategoria IS NULL)
			FOR XML PATH(''), ROOT('Categoria'), TYPE
		)
		,
		(
			SELECT
					TPL.id_template
					,TPL.nome_template
					,lista_1sx = CASE WHEN TPL.lista1_sx = 1 THEN 'true' ELSE 'false' END
					,lista_2sx = CASE WHEN TPL.lista2_sx = 1 THEN 'true' ELSE 'false' END
					,lista_3sx = CASE WHEN TPL.lista3_sx  = 1 THEN 'true' ELSE 'false' END
					,lista4_sx = CASE TPL.lista4_sx WHEN 1 THEN 'true' ELSE 'false' END
					,lista5_sx = CASE TPL.lista5_sx WHEN 1 THEN 'true' ELSE 'false' END
					,lista1_dx = CASE TPL.lista1_dx WHEN 1 THEN 'true' ELSE 'false' END
					,lista2_dx = CASE TPL.lista2_dx WHEN 1 THEN 'true' ELSE 'false' END
					,lista3_dx = CASE TPL.lista3_dx WHEN 1 THEN 'true' ELSE 'false' END
					,lista4_dx = CASE TPL.lista4_dx WHEN 1 THEN 'true' ELSE 'false' END
					,lista_centrale = CASE TPL.lista_centrale WHEN 1 THEN 'true' ELSE 'false' END
					,lista2_centrale = CASE TPL.lista2_centrale WHEN 1 THEN 'true' ELSE 'false' END
					,lista3_centrale = CASE TPL.lista3_centrale WHEN 1 THEN 'true' ELSE 'false' END
					,lista4_centrale = CASE TPL.lista4_centrale WHEN 1 THEN 'true' ELSE 'false' END
					,testo_semplice = CASE TPL.testo_semplice WHEN 1 THEN 'true' ELSE 'false' END
					,testo_info = CASE TPL.testo_info WHEN 1 THEN 'true' ELSE 'false' END
					,news_laterale = CASE TPL.news_laterale WHEN 1 THEN 'true' ELSE 'false' END
					,news_centrale = CASE TPL.news_centrale WHEN 1 THEN 'true' ELSE 'false' END
					,banner = CASE TPL.banner WHEN 1 THEN 'true' ELSE 'false' END
					,input_box = CASE TPL.input_box WHEN 1 THEN 'true' ELSE 'false' END
					,link_semplice = CASE TPL.link_semplice WHEN 1 THEN 'true' ELSE 'false' END
					,img_text = CASE TPL.img_text WHEN 1 THEN 'true' ELSE 'false' END
					,TPL.Testo_descrittivo
					,Titolo = CASE TPL.Titolo WHEN 1 THEN 'true' ELSE 'false' END
					,HomePage = CASE TPL.HomePage WHEN 1 THEN 'true' ELSE 'false' END
					,centra = CASE TPL.centra WHEN 1 THEN 'true' ELSE 'false' END
					,abilitato = CASE TPL.abilitato WHEN 1 THEN 'true' ELSE 'false' END
					,[login] = CASE TPL.[login] WHEN 1 THEN 'true' ELSE 'false' END
					,Mappa = CASE TPL.Mappa WHEN 1 THEN 'true' ELSE 'false' END
					,SearchArea = CASE TPL.SearchArea WHEN 1 THEN 'true' ELSE 'false' END
					,Galleria = CASE TPL.Galleria WHEN 1 THEN 'true' ELSE 'false' END
			FROM	Categorie CAT WITH(NOLOCK)
					INNER JOIN
					TemiCategoria TCA WITH(NOLOCK)
					ON CAT.id_tema = TCA.id_tema
					INNER JOIN
					Pagine P WITH(NOLOCK)
					ON CAT.id_cat = P.Categoria
					INNER JOIN
					TipologiePagina TPL WITH(NOLOCK)
					ON TPL.id_template = P.Id_Template
			--FROM	VW_TemplateCategoriePagina TPL WITH(NOLOCK)
			WHERE	(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
			AND		(TPL.id_template = @Id_TemplateCategoria OR @Id_TemplateCategoria IS NULL)
			FOR XML PATH(''), ROOT('Template'), TYPE
		)
		FOR XML PATH(''), TYPE
	)
	RETURN @RETVAL
END		


GO
