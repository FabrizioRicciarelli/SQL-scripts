USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetLinksInListeXml]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetLinksInListeXml(283,NULL,NULL) AS XmlLinkInLista
*/
CREATE FUNCTION [dbo].[fnGetLinksInListeXml](@Id_Pagina int=NULL,@Id_Lista int = NULL, @Id_Link int=NULL)
RETURNS XML
AS
BEGIN
	DECLARE @RETVAL XML

	SET @RETVAL =
	(
		SELECT
		(
			SELECT	*
			FROM	VW_LinkInLista 
			WHERE	(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
			AND		(id_lista = @Id_Lista OR @ID_Lista IS NULL)
			AND		(Id_Link = @Id_Link OR @ID_link IS NULL)
			FOR XML PATH('Link'),ROOT('LinksInLista')
		)
	)
	RETURN @RETVAL
END		
		
GO
