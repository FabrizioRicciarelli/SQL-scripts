USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetTestoDoppioXml]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetTestoDoppioXml(8754,NULL,NULL) AS XmlTestoDoppio -- Restituisce, in formato XML, i dati dalla tabella TestoDoppio relativi all'"Id_Pagina" specificato (in unione, se indicato, anche all'Id_TestoDoppio)
SELECT dbo.fnGetTestoDoppioXml(8754,NULL,3) AS XmlTestoDoppio -- Restituisce, in formato XML, i dati dalla tabella VSN_TestoDoppio relativi all'"Id_Pagina" e all'"Id_VsnTestoDoppio" specificati
SELECT dbo.fnGetTestoDoppioXml(8754,NULL,-1) AS XmlTestoDoppio -- Restituisce, in formato XML, i dati dalla tabella VSN_TestoDoppio relativi all'"Id_Pagina" e all'ultima versione, ovvero quella corrispondente al MAX(Id_VsnTestoDoppio)
*/
CREATE FUNCTION [dbo].[fnGetTestoDoppioXml](@Id_Pagina int = NULL, @Id_TestoDoppio int=NULL, @Id_Versione int=NULL)
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
					FROM	TestoDoppio WITH(NOLOCK)
					WHERE	(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
					AND		(id_labeldoppio = @Id_TestoDoppio OR @Id_TestoDoppio IS NULL)
					FOR XML PATH('Label'), ROOT('XmlTestoDoppio'), TYPE
				)
				WHEN ISNULL(@Id_Versione,0) = -1
				THEN  
				(
					SELECT	XmlTestoDoppio 
					FROM	VSN_TestoDoppio WITH(NOLOCK)
					WHERE	(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
					AND		Id_VsnTestoDoppio = 
							(
								SELECT	MAX(Id_VsnTestoDoppio)
								FROM	VSN_TestoDoppio WITH(NOLOCK)
								WHERE	Id_Pagina = @Id_Pagina
							)
				)
				WHEN ISNULL(@Id_Versione,0) > 0
				THEN  
				(
					SELECT	XmlTestoDoppio AS TestoDoppio 
					FROM	VSN_TestoDoppio WITH(NOLOCK)
					WHERE	(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
					AND		Id_VsnTestoDoppio = @Id_Versione
				)
			END
	)
	RETURN @RETVAL
END		


GO
