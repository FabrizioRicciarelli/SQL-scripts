USE [Intranetinps_Richieste]
GO
/****** Object:  StoredProcedure [dbo].[spGetMultiXml]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
spGetMultiXml
----------------------------------------

STORED PROCEDURE ATTA AD ESEGUIRE GLI STATEMENTS GENERATI DALLA FUNZIONE DIPENDENTE dbo.fnGetMultiLevelXml. 
IL VALORE RITORNATO SARÀ UNA TABELLA CONTENENTE UN SINGOLO CAMPO IL CUI TIPO È VARCHAR(MAX) E IL CONTENUTO È IL CODICE XML FRUTTO DELL’ELABORAZIONE

-- ESEMPI DI INVOCAZIONE

-- RITORNO DI UN VALORE XML CON TAGS '<NomeTabella><element>...</element><element>...</element><NomeTabella>' SUI RAGGRUPPAMENTI DI 2° LIVELLO
EXEC	spGetMultiXml
		@masterTableName = 'Link'
		,@level1TableName = '[IntranetInps].[dbo].[KeyWord_Link]'
		,@level2TableName = 'VX_Gruppi'
		,@commonIDfieldName = 'Id_Link'
		,@commonIDfieldValue = 24577
		,@useElementTag = 1

-- RITORNO DI UN VALORE XML CON TAGS '<NomeTabellaS><NomeTabella>...</NomeTabella><NomeTabella>...</NomeTabella></NomeTabellaS>' SUI RAGGRUPPAMENTI DI 2° LIVELLO
EXEC	spGetMultiXml
		@masterTableName = 'Link'
		,@level1TableName = '[IntranetInps].[dbo].[KeyWord_Link]'
		,@level2TableName = 'VX_Gruppi' -- Utilizza una vista (il prefisso VX_ sarà rimosso dai tags dell'XML risultante)
		,@commonIDfieldName = 'Id_Link'
		,@commonIDfieldValue = 24577
		,@useElementTag = 0
*/
CREATE PROC	[dbo].[spGetMultiXml]
			@masterTableName varchar(128) = NULL -- Tabella "Master"
			,@level1TableName varchar(128) = NULL -- Prima tabella annidata
			,@level2TableName varchar(128) = NULL -- Seconda tabella annidata
			,@commonIDfieldName varchar(128) = NULL -- Nome campo ID comune a tutte le tabelle
			,@commonIDfieldValue int -- Valore campo ID utilizzato come criterio di filtro
			,@useElementTag BIT = NULL -- Flag che determina se utilizzare il tag "element" nei raggruppamenti oppure no
AS
DECLARE	@SQL varchar(MAX)
SELECT	@SQL = dbo.fnGetMultiLevelXml(@masterTableName, @level1TableName, @level2TableName, @commonIDfieldName, @commonIDfieldValue, @useElementTag)
EXEC(@SQL)

GO
