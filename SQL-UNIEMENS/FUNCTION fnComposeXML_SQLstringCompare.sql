/*
FUNZIONE PREPOSTA ALLA CREAZIONE DI UNA STRINGA COMPOSTA DA
UTILIZZARE PER GENERARE RIGHE DI SQL DINAMICO

Esempio di invocazione:
SELECT dbo.fnComposeXML_SQLstringCompare('T.AP_KEYD_SQLCOMMAND_ENPALS', 'VLAVCONTR_DBO', 'V', 'MatricolaLavoratore', 'NUM_MTR_LAV', 'varchar(7)') AS RigaComposta
-- Risultato
'AND		LTRIM(RTRIM(CAST(COALESCE(NULLIF(T.AP_KEYD_SQLCOMMAND_ENPALS.value('(//MatricolaLavoratore)[1]','varchar(max)'),''),'0') AS varchar(7)))) = LTRIM(RTRIM(CAST(COALESCE(NULLIF(CONVERT(varchar(MAX),V.NUM_MTR_LAV),''),'0') AS varchar(7))))'

CREANDO UN'APPOSITA TABELLA TEMPORANEA IN MEMORIA, E' POSSIBILE CONCATENARE PIU' RIGHE IN QUESTO MODO:
-------------------------------------------------------------------------------------------------------
SET NOCOUNT ON;
DECLARE 
		@campiXMLdaConfrontare varchar(MAX)

DECLARE @TABELLACONFRONTOXML_SQL TABLE
		(
			Confronta bit
			,Mostra bit
			,NomeTabellaSQL varchar(128)
			,AliasTabellaSQL varchar(5)
			,NomeColonnaXML varchar(128)
			,NomeColonnaSQL varchar(128)
			,TipoDatoSQL varchar(50)
		)
INSERT	 @TABELLACONFRONTOXML_SQL    
		 (NomeTabellaSQL, AliasTabellaSQL, NomeColonnaXML, NomeColonnaSQL, TipoDatoSQL)
VALUES	 ('VLAVCONTR_DBO', 'V', 'MatricolaLavoratore' ,'NUM_MTR_LAV', 'varchar(7)')
		,('VLAVCONTR_DBO', 'V', 'CodiceFiscaleLavoratore' ,'CF_LAVORATORE', 'varchar(7)')
		,('VLAVCONTR_DBO', 'V', 'Cognome' ,'COGNOME', 'varchar(30)')
		,('VLAVCONTR_DBO', 'V', 'Nome' ,'NOME', 'varchar(20)')

SELECT	@campiXMLdaConfrontare = COALESCE(@campiXMLdaConfrontare, '') + dbo.fnComposeXML_SQLstringCompare('T.AP_KEYD_SQLCOMMAND_ENPALS', NomeTabellaSQL, AliasTabellaSQL, NomeColonnaXML, NomeColonnaSQL, TipoDatoSQL)
FROM	@TABELLACONFRONTOXML_SQL

PRINT(@campiXMLdaConfrontare)
-------------------------------------------------------------------------------------------------------
*/
ALTER FUNCTION	[dbo].[fnComposeXML_SQLstringCompare]
				(
					@OrigineDatiXML varchar(256) = NULL -- COMPRENSIVO DELL'ALIAS, ES.: "T.AP_KEYD_SQLCOMMAND_ENPALS"
					,@NomeTabellaSQL varchar(128) = NULL
					,@AliasTabellaSQL varchar(5) = NULL
					,@NomeColonnaXML varchar(128) = NULL
					,@NomeColonnaSQL varchar(128)
					,@TipoDatoSQL varchar(50) = NULL
				)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @RETVAL varchar(MAX) = NULL

	IF ISNULL(@OrigineDatiXML, '') != ''
	AND ISNULL(@NomeTabellaSQL, '') != ''
	AND ISNULL(@AliasTabellaSQL, '') != ''
	AND ISNULL(@NomeColonnaXML, '') != ''
	AND ISNULL(@NomeColonnaSQL, '') != ''
	AND ISNULL(@TipoDatoSQL, '') != ''
		BEGIN
			SET @RETVAL = 
				'AND		LTRIM(RTRIM(CAST(COALESCE(NULLIF(' + @OrigineDatiXML + '.value(''(//' + 
				@NomeColonnaXML + 
				')[1]'',''varchar(max)''),''''),''0'') AS '  + 
				@TipoDatoSQL + 
				'))) = ' +
				'LTRIM(RTRIM(CAST(COALESCE(NULLIF(CONVERT(varchar(MAX),' + 
				ISNULL(@AliasTabellaSQL, @NomeTabellaSQL) + 
				'.' + 
				@NomeColonnaSQL + 
				'),''''),''0'') AS ' + 
				@TipoDatoSQL + 
				')))' + 
				CHAR(13)
		END
	RETURN @RETVAL
END