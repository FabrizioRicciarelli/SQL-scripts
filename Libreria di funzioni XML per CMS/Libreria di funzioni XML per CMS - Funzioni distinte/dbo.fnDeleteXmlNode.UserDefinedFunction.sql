USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnDeleteXmlNode]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnDeleteXmlNode
----------------------------------------

FUNZIONE PREPOSTA ALL'ELIMINAZIONE DI UNO O PIU' NODI XML, ANCHE COMPLESSI, PRESENTI ALL'INTERNO DI UNA STRUTTURA XML PREESISTENTE.

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnDeleteXmlNode('<XmlTestoDoppio>
  <NewNode>NewContent</NewNode>
  <Label>
    <id_labeldoppio>2953</id_labeldoppio>
    <label1>Nome</label1>
    <label2>Roberto</label2>
    <id_Pagina>8754</id_Pagina>
    <id_Image>79</id_Image>
    <ordinamento>1</ordinamento>
  </Label>
  <Label>
    <id_labeldoppio>2954</id_labeldoppio>
    <label1>Cognome</label1>
    <label2>Nacchia</label2>
    <id_Pagina>8754</id_Pagina>
    <id_Image>79</id_Image>
    <ordinamento>2</ordinamento>
  </Label>
</XmlTestoDoppio>','XmlTestoDoppio')
*/
CREATE FUNCTION [dbo].[fnDeleteXmlNode]
				(
					@XmlSource XML
					,@XmlPath varchar(MAX)
				)
RETURNS XML
AS
BEGIN
	DECLARE @RETVAL XML

	IF ISNULL(CAST(@XmlSource AS nvarchar(MAX)),'') != ''
	AND ISNULL(@XmlPath,'') != ''
		BEGIN
			SET @XmlSource.modify('delete (//*[local-name()=sql:variable("@Xmlpath")])')
			SET @RETVAL = @XmlSource
		END
	
	RETURN @RETVAL
END
GO
