USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnAddXmlNode]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnAddXmlNode
----------------------------------------

FUNZIONE PREPOSTA ALL'INSERIMENTO DI UNO O PIU' NODI XML, ANCHE COMPLESSI, ALL'INTERNO DI UNA STRUTTURA XML PREESISTENTE.
SI NOTI, OSSERVANDO IL CODICE CHE COMPONE LA PRESENTE FUNZIONE, CHE IL POSIZIONAMENTO DEL NUOVO NODO PUO' AVVENIRE SECONDO
DIFFERENTI MODALITA', OVVERO:

- prima del primo elemento figlio incluso nel nodo puntato dall'xpath
- dopo l'ultimo elemento figlio incluso nel nodo puntato dall'xpath
- prima del primo nodo puntato dall'xpath
- dopo la chiusura del nodo specificato dall'xpath

AFFINCHE' CIO' AVVENGA, E' NECESSARIO MODIFICARE LA STRUTTURA DEL CODICE, COMMENTANDO/DECOMMENTANDO OPPORTUNAMENTE LE RIGHE 
PREPOSTE AL RISULTATO DESIDERATO.

VEDERE ANCHE LE FUNZIONI EQUIVALENTI:
- fnDeleteXmlNode
- fnReplaceXmlNodeName

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnAddXmlNode('<XmlTestoDoppio>
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
</XmlTestoDoppio>','XmlTestoDoppio','<NewNode>NewContent</NewNode>')
*/
CREATE FUNCTION [dbo].[fnAddXmlNode]
				(
					@XmlSource XML
					,@XmlPath varchar(MAX)
					,@NewNodeContent XML
				)
RETURNS XML
AS
BEGIN
	DECLARE @RETVAL XML

	IF ISNULL(CAST(@XmlSource AS nvarchar(MAX)),'') != ''
	AND ISNULL(@XmlPath,'') != ''
	AND ISNULL(CAST(@NewNodeContent AS varchar(MAX)),'') != ''
		BEGIN
			SET @XmlSource.modify('insert sql:variable("@NewNodeContent") as first into (//*[local-name()=sql:variable("@Xmlpath")])[1]') -- prima del primo elemento figlio incluso nel nodo puntato dall'xpath
			--SET @XmlSource.modify('insert sql:variable("@NewNodeContent") as last into (//*[local-name()=sql:variable("@Xmlpath")])[1]') -- dopo l'ultimo elemento figlio incluso nel nodo puntato dall'xpath
			--SET @XmlSource.modify('insert sql:variable("@NewNodeContent") before (//*[local-name()=sql:variable("@Xmlpath")])[1]') -- prima del primo nodo puntato dall'xpath
			--SET @XmlSource.modify('insert sql:variable("@NewNodeContent") after (//*[local-name()=sql:variable("@Xmlpath")])[1]') -- dopo la chiusura del nodo specificato dall'xpath
			SET @RETVAL = @XmlSource
		END
	
	RETURN @RETVAL
END
GO
