USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetLinksInGalleriaXml]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetLinksInGalleriaXml(8754,NULL,NULL) AS XmlLinkInGalleria
*/
CREATE FUNCTION [dbo].[fnGetLinksInGalleriaXml](@Id_Pagina int=NULL,@Id_Galleria int = NULL, @Id_Link int=NULL)
RETURNS XML
AS
BEGIN
	DECLARE @RETVAL XML

	SET @RETVAL =
	(
		SELECT
		(
			SELECT	*
			FROM	VW_LinkInGalleria 
			WHERE	(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
			AND		(Id_Galleria = @Id_Galleria OR @ID_Galleria IS NULL)
			AND		(Id_Link = @Id_Link OR @ID_link IS NULL)
			FOR XML PATH('Link'),ROOT('LinksInGalleria')
		)
	)
	RETURN @RETVAL
END		
		
GO
