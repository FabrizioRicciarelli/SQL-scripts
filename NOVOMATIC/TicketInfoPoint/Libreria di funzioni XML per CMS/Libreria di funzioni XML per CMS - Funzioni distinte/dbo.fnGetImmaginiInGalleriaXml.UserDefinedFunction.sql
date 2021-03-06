USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetImmaginiInGalleriaXml]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetImmaginiInGalleriaXml(8754,NULL,NULL) AS XmlLinkInGalleria
*/
CREATE FUNCTION [dbo].[fnGetImmaginiInGalleriaXml](@Id_Pagina int=NULL,@Id_Galleria int = NULL, @Id_ImmagineGalleria int=NULL)
RETURNS XML
AS
BEGIN
	DECLARE @RETVAL XML

	SET @RETVAL =
	(
		SELECT
		(
			SELECT	*
			FROM	VW_ImmagineInGalleria 
			WHERE	(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
			AND		(Id_Galleria = @Id_Galleria OR @ID_Galleria IS NULL)
			AND		(Id_ImmagineGalleria = @Id_ImmagineGalleria OR @Id_ImmagineGalleria IS NULL)
			FOR XML PATH('Immagine'),ROOT('ImmaginiInGalleria')
		)
	)
	RETURN @RETVAL
END		
		
GO
