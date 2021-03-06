USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetTestoConImmagineXml]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetTestoConImmagineXml(8754,NULL,NULL) AS XmlTestoConImmagine
SELECT dbo.fnGetTestoConImmagineXml(8754,NULL,21) AS XmlTestoConImmagine -- Restituisce, in formato XML, i dati dalla tabella VSN_TestoConImmagine relativi all'"Id_Pagina" e all'"Id_VsnTestoConImmagine" specificati
SELECT dbo.fnGetTestoConImmagineXml(8754,NULL,-1) AS XmlTestoConImmagine -- Restituisce, in formato XML, i dati dalla tabella VSN_TestoConImmagine relativi all'"Id_Pagina" e all'ultima versione, ovvero quella corrispondente al MAX(Id_VsnTestoConImmagine)
*/
CREATE FUNCTION [dbo].[fnGetTestoConImmagineXml](@Id_Pagina int = NULL, @Id_TestoImmagine int=NULL, @Id_Versione int = NULL)
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
					SELECT	* 
					FROM	TestoConImmagine WITH(NOLOCK)
					WHERE	(Id_Page = @Id_Pagina OR @ID_Pagina IS NULL)
					AND		(Id_TestoImmagine = @Id_TestoImmagine OR @Id_TestoImmagine IS NULL)
					FOR XML PATH(''), ROOT('XmlTestoConImmagine'), TYPE
				)
				WHEN ISNULL(@Id_Versione,0) = -1
				THEN  
				(
					SELECT	XmlTestoConImmagine 
					FROM	VSN_TestoConImmagine WITH(NOLOCK)
					WHERE	(IdPagina = @Id_Pagina OR @ID_Pagina IS NULL)
					AND		Id_VsnTestoConImmagine = 
							(
								SELECT	MAX(Id_VsnTestoConImmagine)
								FROM	VSN_TestoConImmagine WITH(NOLOCK)
								WHERE	IdPagina = @Id_Pagina
							)
				)
				WHEN ISNULL(@Id_Versione,0) > 0
				THEN  
				(
					SELECT	XmlTestoConImmagine 
					FROM	VSN_TestoConImmagine WITH(NOLOCK)
					WHERE	(IdPagina = @Id_Pagina OR @ID_Pagina IS NULL)
					AND		Id_VsnTestoConImmagine = @Id_Versione
				)
			END
	)
	RETURN @RETVAL
END		


GO
