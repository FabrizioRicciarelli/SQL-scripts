USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetTestoSempliceXml]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetTestoSempliceXml(8754,NULL,NULL) AS XmlTestoSemplice -- Restituisce, in formato XML, i dati dalla tabella TestoSempliceObject relativi all'"Id_Pagina" specificato (in unione, se indicato, anche all'Id_TestoSemplice)
SELECT dbo.fnGetTestoSempliceXml(8754,NULL,7) AS XmlTestoSemplice -- Restituisce, in formato XML, i dati dalla tabella VSN_TestoSemplice relativi all'"Id_Pagina" e all'"Id_VsnTestoSemplice" specificati
SELECT dbo.fnGetTestoSempliceXml(8754,NULL,-1) AS XmlTestoSemplice -- Restituisce, in formato XML, i dati dalla tabella VSN_TestoSemplice relativi all'"Id_Pagina" e all'ultima versione, ovvero quella corrispondente al MAX(Id_VsnTestoSemplice)
*/
CREATE FUNCTION [dbo].[fnGetTestoSempliceXml](@Id_Pagina int = NULL, @Id_TestoSemplice int=NULL, @Id_Versione int=NULL)
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
					FROM	TestoSempliceObject WITH(NOLOCK)
					WHERE	(Id_Pagina = @Id_Pagina OR @ID_Pagina IS NULL)
					AND		(id_testosemplice = @Id_TestoSemplice OR @Id_TestoSemplice IS NULL)
					FOR XML PATH(''), ROOT('XmlTestoSemplice'), TYPE
				)
				WHEN ISNULL(@Id_Versione,0) = -1
				THEN  
				(
					SELECT	XmlTestoSemplice 
					FROM	VSN_TestoSemplice WITH(NOLOCK)
					WHERE	(IdPagina = @Id_Pagina OR @ID_Pagina IS NULL)
					AND		Id_VsnTestoSemplice = 
							(
								SELECT	MAX(Id_VsnTestoSemplice)
								FROM	VSN_TestoSemplice WITH(NOLOCK)
								WHERE	IdPagina = @Id_Pagina
							)
				)
				WHEN ISNULL(@Id_Versione,0) > 0
				THEN  
				(
					SELECT	XmlTestoSemplice 
					FROM	VSN_TestoSemplice WITH(NOLOCK)
					WHERE	(IdPagina = @Id_Pagina OR @ID_Pagina IS NULL)
					AND		Id_VsnTestoSemplice = @Id_Versione
				)
			END
	)
	RETURN @RETVAL
END		


GO
