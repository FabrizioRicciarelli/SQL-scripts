USE [Intranetinps_Richieste]
GO
/****** Object:  StoredProcedure [dbo].[spGetDualLevelXml]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
spGetDualLevelXml
----------------------------------------

STORED PROCEDURE ATTA AD ESEGUIRE GLI STATEMENTS GENERATI DALLA FUNZIONE DIPENDENTE "dbo.fnGetDualLevelXml". 
IL VALORE RITORNATO SARÀ UNA TABELLA CONTENENTE UN SINGOLO CAMPO IL CUI TIPO È VARCHAR(MAX) E IL CONTENUTO È IL CODICE XML FRUTTO DELL’ELABORAZIONE

-- ESEMPI DI INVOCAZIONE

-- RITORNO DI UN VALORE XML CON TAGS '<XmlTestoConImmagine><ImmaginiNelTesto><Immagine>...</Immagine></ImmaginiNelTesto><LinkNelTesto><Link>...</Link></LinkNelTesto></XmlTestoConImmagine>' SUI RAGGRUPPAMENTI DI 2° LIVELLO
EXEC	spGetDualLevelXml
		@masterTableName = 'VX_TestoConImmagine'
		,@commaSep2ndLevelTableNames = 'VX_TestoConImmagine_ImmaginiNelTesto/Immagine, VX_TestoConImmagine_LinkNelTesto/Link' -- Utilizza le viste necesessarie (* NOTARE GLI ALIAS *, "VX_ImmaginiNelTesto/Immagine" = "NomeVista/ALIAS")
		,@commonIDfieldName = 'Id_page'
		,@commonIDfieldValue = 8750
		,@useElementTag = 0 -- QUANDO PRESENTI GLI ALIAS, QUESTO BOOLEANO VIENE IGNORATO
		,@RETVAL = NULL

-- RITORNO DI UN VALORE XML CON TAGS '<XmlTestoConImmagine><ImmaginiNelTesto><element>...</element></ImmaginiNelTesto><LinkNelTesto><element>...</element></LinkNelTesto></XmlTestoConImmagine>' SUI RAGGRUPPAMENTI DI 2° LIVELLO
EXEC	spGetDualLevelXml
		@masterTableName = 'VX_TestoConImmagine'
		,@commaSep2ndLevelTableNames = 'VX_TestoConImmagine_ImmaginiNelTesto, VX_TestoConImmagine_LinkNelTesto' -- Utilizza le viste necesessarie
		,@commonIDfieldName = 'Id_page'
		,@commonIDfieldValue = 6153
		,@useElementTag = 1 -- DATO CHE NESSUN ALIAS E' STATO SPECIFICATO, QUESTO BOOLEANO VALORIZZATO A 1 IMPOSTERA' I NOMI DEI SOTTONODI AD "<element>...</element>"

-- RITORNO DI UN VALORE XML CON TAGS '<XmlTestoConImmagine><ImmaginiNelTestoS><ImmaginiNelTesto>...</ImmaginiNelTesto></ImmaginiNelTestoS><LinkNelTestoS><LinkNelTesto>...</LinkNelTesto></LinkNelTestoS></XmlTestoConImmagine>' SUI RAGGRUPPAMENTI DI 2° LIVELLO
EXEC	spGetDualLevelXml
		@masterTableName = 'VX_TestoConImmagine'
		,@commaSep2ndLevelTableNames = 'VX_TestoConImmagine_ImmaginiNelTesto, VX_TestoConImmagine_LinkNelTesto' -- Utilizza una tabella e una vista (il prefisso VX_ sarà rimosso dai tags dell'XML risultante)
		,@commonIDfieldName = 'Id_page'
		,@commonIDfieldValue = 6153
		,@useElementTag = 0 -- DATO CHE NESSUN ALIAS E' STATO SPECIFICATO, QUESTO BOOLEANO VALORIZZATO A 0 IMPOSTERA' I NOMI DEI SOTTONODI A "<KeyWord_Link>...</KeyWord_Link>" E IL NODO PADRE A "<KeyWord_Links>...</KeyWord_Links>" (CON UNA "s" IN FONDO)
*/
CREATE PROC	[dbo].[spGetDualLevelXml]
			@masterTableName varchar(128) = NULL -- Tabella "Master"
			,@commaSep2ndLevelTableNames varchar(MAX) = NULL -- Elenco, separato da virgole, dei nomi di tabella da annidare al secondo livello
			,@commonIDfieldName varchar(128) = NULL -- Nome campo ID comune a tutte le tabelle
			,@commonIDfieldValue int -- Valore campo ID utilizzato come criterio di filtro
			,@useElementTag BIT = NULL -- Flag che determina se utilizzare il tag "element" nei raggruppamenti oppure no
			,@RETVAL XML = NULL OUTPUT
AS

-- VERSIONE *FUNZIONANTE* PER IMPOSTARE UN
-- VALORE DI RITORNO
DECLARE @TABLERET TABLE
		(
			returnvalue XML
		)

DECLARE	
		@SQL varchar(MAX)

SELECT	@SQL = dbo.fnGetDualLevelXml(REPLACE(@masterTableName,'VX_',''), @commaSep2ndLevelTableNames, @commonIDfieldName, @commonIDfieldValue, @useElementTag)

PRINT(@SQL)

INSERT	@TABLERET(returnvalue)
EXEC	(@SQL)

SELECT	TOP 1 
		@RETVAL = returnvalue 
FROM	@TABLERET

SELECT @RETVAL
GO
