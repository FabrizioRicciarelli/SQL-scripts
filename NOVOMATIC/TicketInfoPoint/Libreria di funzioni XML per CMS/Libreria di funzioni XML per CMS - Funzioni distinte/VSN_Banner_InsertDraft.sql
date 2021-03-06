
ALTER PROCEDURE [dbo].[VSN_Banner_InsertDraft]
( 
@Autore varchar(100)
,@IdPagina int
)
AS
Declare @BannerXml Xml

  SET @BannerXml = (SELECT(SELECT DISTINCT id_pagina 
								FROM Intranetinps_Lavoro.dbo.BannerObject
								WHERE id_pagina=@IdPagina
						    FOR
							XML PATH(''),
							TYPE
						),
						(SELECT B.id_banner, B.id_pagina, B.url_img, B.alternate, B.link, B.ordinamento, B.Id_Link 
								  FROM Intranetinps_Lavoro.dbo.BannerObject B
								  JOIN Intranetinps_Lavoro.dbo.ListaBanners LB ON B.url_img=LB.url 
								  WHERE id_pagina=@IdPagina
						    FOR
							XML PATH('Banner'),
							TYPE
						)AS Banner

						FOR XML PATH(''),
				ROOT('XmlBanner'))

INSERT INTO [dbo].[VSN_Banner]
           ([Data]
           ,[XmlBanner]
           ,[Autore]
		   ,[id_Pagina])
     VALUES
           (Getdate(),@BannerXml,@Autore,@IdPagina)

