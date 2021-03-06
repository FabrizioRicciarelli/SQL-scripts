USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnReplaceXmlNodeName]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnReplaceXmlNodeName
----------------------------------------

FUNZIONE PREPOSTA AL RIMPIAZZO DEL NOME DI UN NODO XML, PRESENTE ALL'INTERNO DI UNA STRUTTURA XML PREESISTENTE, CON LA STRINGA SPECIFICATA.

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnReplaceXmlNodeName('<XmlTestoDoppio>
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
</XmlTestoDoppio>','XmlTestoDoppio','TestoDoppio')
*/
CREATE FUNCTION [dbo].[fnReplaceXmlNodeName]
				(
					@XmlSource XML
					,@OldNodeName varchar(MAX)
					,@NewNodeName varchar(MAX)
				)
RETURNS XML
AS
BEGIN
	DECLARE 
			@RETVAL XML
			,@VXML nvarchar(MAX)

	IF ISNULL(CAST(@XmlSource AS nvarchar(MAX)),'') != ''
	AND ISNULL(@OldNodeName,'') != ''
	AND ISNULL(@NewNodeName,'') != ''
		BEGIN
			SET @VXML = CAST(@XmlSource AS nvarchar(MAX))
			SET @VXML = REPLACE(@VXML, '<' + @OldNodeName + '>', '<' + @NewNodeName + '>')
			SET @VXML = 
				CASE
					WHEN @NewNodeName LIKE '% %'
					THEN @VXML
					ELSE REPLACE(@VXML, '</' + @OldNodeName + '>', '</' + @NewNodeName + '>')
				END
			SET @RETVAL = CAST(@VXML AS XML)
		END
	RETURN @RETVAL
END
GO
