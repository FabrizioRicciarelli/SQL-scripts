USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetListeXml]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetListeXml(8754,NULL,NULL) AS XmlLista
*/
CREATE FUNCTION [dbo].[fnGetListeXml](@Id_Pagina int = NULL, @Id_Lista int = NULL, @Id_Versione int = NULL)
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
								,dbo.fnGetLinksInListeXml(Id_Pagina, Id_Lista,NULL)
								FROM	VW_ListaObject 
								WHERE	(Id_Lista = @Id_Lista OR @ID_Lista IS NULL)
								AND		(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
								FOR XML PATH('Lista'), TYPE
					)
					FOR XML PATH(''),ROOT('XmlLista')
				)
				WHEN ISNULL(@Id_Versione,0) > 0
				THEN  
				(
					-- !!! DA VERIFICARE !!! (AL MOMENTO, PER IL PORTALE STATICO, VIENE UTILIZZATA LA CHIAMATA ALLA spEstraiListeVSN INCORPORATA NELLA SP WRAPPER spGetPagineXml)
					SELECT	dbo.fnMergeXmlListaLink(@Id_Versione) as XMLLista
				)
			END
	)
	RETURN @RETVAL
END		

GO
