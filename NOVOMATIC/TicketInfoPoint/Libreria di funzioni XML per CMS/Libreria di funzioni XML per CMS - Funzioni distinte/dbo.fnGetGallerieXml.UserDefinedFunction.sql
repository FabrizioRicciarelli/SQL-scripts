USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetGallerieXml]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetGallerieXml
----------------------------------------

FUNZIONE CHE ESTRAE LA STRUTTURA XML DALLE TABELLE PREDISPOSTE PER RECEPIRE I DATI DELLE GALLERIE.
LA MODALITA' DI ESTRAZIONE VARIA A SECONDA DELLA VALORIZZAZIONE DEL PARAMETRO "@Id_Versione": SE QUESTO E' VALORIZZATO A NULL I DATI
SARANNO PRELEVATI DALLA TABELLA "Galleria" E SUE TABELLE ACCESSORIE; IN CASO CONTRARIO I DATI SARANNO PRELEVATI DALLA TABELLA DI VERSIONAMENTO "VSN_Galleria"
E L'OUTPUT SARA' FORMATTATO IN MODO CHE ESSO SIA ADERENTE AL MODELLO XSD DEL PORTALE STATICO

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnGetGallerieXml(8754,1454,null) AS XmlGalleria
SELECT dbo.fnGetGallerieXml(8754,1109170,36) AS XmlGalleria
*/
CREATE FUNCTION [dbo].[fnGetGallerieXml](@Id_Pagina int = NULL, @Id_Galleria int = NULL, @Id_Versione int = NULL)
RETURNS XML
AS
BEGIN
	DECLARE 
			@RETVAL XML
			,@XmlSource XML
			,@RootNode XML

	IF ISNULL(@Id_Versione,0) > 0
		BEGIN
			SELECT	
					@XmlSource = XmlGalleria
			FROM	VSN_Galleria WITH(NOLOCK)
			WHERE	(IdGalleria = @Id_Galleria OR @Id_Galleria IS NULL)
			AND		Id_VsnGalleria = @Id_Versione

			SET @RootNode = @XmlSource
			SET @RootNode.modify('delete //Immagini')
		END

	SET @RETVAL =
	(
	SELECT
			CASE
				WHEN ISNULL(@Id_Versione,0) = 0 
				THEN
				(
					SELECT
					(
						SELECT	G.*
								,dbo.fnGetLinksInGalleriaXml(PG.Id_Pagina, PG.Id_Galleria, NULL)
								,dbo.fnGetImmaginiInGalleriaXml(PG.Id_Pagina, PG.Id_Galleria, NULL)
						FROM	Galleria G WITH(NOLOCK)
								INNER JOIN
								VW_PagineGallerie_REL PG
								ON G.Id_Galleria = PG.Id_Galleria
						WHERE	(PG.Id_Galleria = @Id_Galleria OR @Id_Galleria IS NULL)
						AND		(PG.Id_Pagina = @Id_Pagina OR @Id_Pagina IS NULL)
						FOR XML PATH('Galleria'), TYPE
					)
				)
				WHEN ISNULL(@Id_Versione,0) > 0
				THEN  
				(
					SELECT
							Galleria.query('(//Id_Galleria)[1]')
							,Galleria.query('(//Titolo)[1]')
							,CASE WHEN @RootNode.exist('/url') = 1 THEN Galleria.query('(//url)[1]') ELSE '' END AS Url 
							,CASE WHEN @RootNode.exist('/Id_Link') = 1 THEN Galleria.query('(//Id_Link)[1]') ELSE '0' END AS Id_Link 
							,CASE WHEN @RootNode.exist('/RowNumber') = 1 THEN Galleria.query('(//RowNumber)[1]') ELSE '0' END AS RowNumber 
							,CASE WHEN @RootNode.exist('/TotalRow') = 1 THEN Galleria.query('(//TotalRow)[1]') ELSE '0' END AS TotalRow 
							,
							(
								SELECT	
										CAST
										(
											REPLACE
											(
												REPLACE
												(
													CAST
													(
														(
														SELECT
																Immagine.query('.')
																,0 AS RowNumber
																,0 AS TotalRows
														FROM	@XmlSource.nodes('//Immagine') AS X(Immagine)
														FOR XML PATH(''), ROOT('Immagini'), TYPE
														)
														AS varchar(MAX)
													)
													,'</Immagine><RowNumber>'
													,'<RowNumber>'
												)
												,'</TotalRows>'
												,'</TotalRows></Immagine>'
											) 
											AS XML
										)
							)
					FROM	@RootNode.nodes('/') AS Y(Galleria)
					FOR XML	PATH(''), ROOT('XmlGalleria'), TYPE
				)
			END
	)

	IF ISNULL(@Id_Versione,0) > 0
		BEGIN
			SET @RETVAL.modify('delete //Immagine/Id_Galleria')
			SET @RETVAL.modify('delete //Immagine/IdArea')
			SET @RETVAL.modify('delete //Immagine/IdCartella')

			SET @RETVAL = dbo.fnReplaceXmlNodeName(@RETVAL,'url','Url')
			SET @RETVAL = dbo.fnReplaceXmlNodeName(@RETVAL,'Id_Galleria','Id_galleria')
			SET @RETVAL = dbo.fnReplaceXmlNodeName(@RETVAL,'Immagine','ImmagineGalleria')
			SET @RETVAL = dbo.fnReplaceXmlNodeName(@RETVAL,'XmlGalleria','Galleria')
		END

	RETURN @RETVAL
END		

GO
