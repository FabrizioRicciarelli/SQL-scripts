USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetInfoPaginaXml]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnGetInfoPaginaXml(8754, 8)
*/
CREATE FUNCTION [dbo].[fnGetInfoPaginaXml](@Id_Pagina int = NULL, @Versione int = NULL)
RETURNS XML
AS
BEGIN
	DECLARE @RETVAL XML

	SET @RETVAL =
	(
		SELECT
				NomePagina = ISNULL(C.value('./NomePagina[1]','varchar(max)'),'')
				,Voce = ISNULL(C.value('./Voce[1]','varchar(max)'),'')
				,Categoria = ISNULL(C.value('./Categoria[1]','int'),0)
				,Data = C.value('./Data[1]','datetime')
				,Idlink = ISNULL(C.value('./Idlink[1]','int'),0)
				,areaProtetta = ISNULL(C.value('./areaProtetta[1]','int'),0)
				,idPageLogin = ISNULL(C.value('./idPageLogin[1]','int'),0)
				,Area = ISNULL(C.value('./Area[1]','varchar(max)'),'')
				,Id_Galleria = ISNULL(C.value('./Id_Galleria[1]','int'),0)
		FROM	VSN_Pagina AS T WITH(NOLOCK) 
				CROSS APPLY T.XmlPagina.nodes('/XmlPagina') AS X(C)
		WHERE	(IdPagina = @Id_Pagina OR @ID_Pagina IS NULL)
		AND		(Versione = @Versione OR @Versione IS NULL)
		FOR XML PATH(''), ROOT('InfoPagina')
	)
	RETURN @RETVAL
END

GO
