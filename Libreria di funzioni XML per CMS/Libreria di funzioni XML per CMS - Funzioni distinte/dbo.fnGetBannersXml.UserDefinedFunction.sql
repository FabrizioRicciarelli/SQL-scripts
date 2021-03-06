USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetBannersXml]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetBannersXml(8754,NULL,NULL) AS XmlBanner
SELECT dbo.fnGetBannersXml(8754,NULL,11) AS XmlBanner
SELECT dbo.fnGetBannersXml(8754,NULL,-1) AS XmlBanner
*/
CREATE FUNCTION [dbo].[fnGetBannersXml](@Id_Pagina int = NULL, @Id_Banner int = NULL, @Id_Versione int = NULL)
RETURNS XML
AS
BEGIN
	DECLARE @RETVAL XML

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
						FROM	VW_BannerObject 
						WHERE	(Id_Banner = @Id_Banner OR @ID_Banner IS NULL)
						AND		(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
						FOR XML PATH('Banner'), TYPE
					)
					FOR XML PATH(''),ROOT('XmlBanner')
				)
				WHEN ISNULL(@Id_Versione,0) = -1
				THEN  
				(
					SELECT	XmlBanner 
					FROM	VSN_Banner WITH(NOLOCK)
					WHERE	(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
					AND		Id_VsnBanner = 
							(
								SELECT	MAX(Id_VsnBanner)
								FROM	VSN_Banner WITH(NOLOCK)
								WHERE	Id_Pagina = @Id_Pagina
							)
				)
				WHEN ISNULL(@Id_Versione,0) > 0
				THEN  
				(
					SELECT	XmlBanner 
					FROM	VSN_Banner WITH(NOLOCK)
					WHERE	(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
					AND		Id_VsnBanner = @Id_Versione
				)
			END
	)
	RETURN @RETVAL
END		
		
GO
