/*
EXEC	spConfrontoVariazioneBase
		@PeriodoCompetenza = '2013-12-01' -- '2014-12-01' 
		,@CodiceGruppo = '223416' -- '015822'
		,@NumeroAttivita = '001'
		,@Elimina = 0
		,@CFLavoratore = 'MRTNRL95H50Z514W' -- 'BBTCLR54C68Z114Q'
*/
ALTER PROC	dbo.spConfrontoVariazioneBase
			@PeriodoCompetenza date=NULL
			,@CodiceGruppo varchar(6)=NULL
			,@NumeroAttivita varchar(3)=NULL
			,@CFLavoratore varchar(16)=NULL
			,@Elimina bit=NULL
AS			

SET NOCOUNT ON;

------------------------------------------------------------------------------------
-- DICHIARAZIONE VARIABILI DI LAVORO
------------------------------------------------------------------------------------
DECLARE 
		@SQL varchar(MAX)
		,@campiXMLdaConfrontare varchar(MAX)
		,@campiXMLdaMostrare varchar(MAX)
		,@whereCondition varchar(MAX) = 'WHERE	1=1' + CHAR(13)
------------------------------------------------------------------------------------


------------------------------------------------------------------------------------
-- COMPOSIZIONE DELLA STRINGA CHE FUNGERA' DA WHERECONDITION ALL'INTERNO DELLA
-- QUERY NELL'SQL DINAMICO: LA COSTRUZIONE E' ANCH'ESSA DINAMICA POICHE'
-- AGGIUNGE RIGHE SOLO SE I PARAMETRI DELLA PRESENTE STORED PROCEDURE SONO STATI
-- VALORIZZATI
------------------------------------------------------------------------------------
SET	@whereCondition += CASE WHEN @PeriodoCompetenza IS NOT NULL THEN 'AND		AP_KEYD_COMPETENZA = ''' + CONVERT(varchar(10), @PeriodoCompetenza, 120) + '''' + CHAR(13) ELSE '' END
SET	@whereCondition += CASE WHEN @CodiceGruppo IS NOT NULL THEN 'AND		AP_KEYD_CODICEGRUPPO = ''' + @CodiceGruppo + '''' + CHAR(13) ELSE '' END
SET	@whereCondition += CASE WHEN @NumeroAttivita IS NOT NULL THEN 'AND		AP_KEYD_NUMEROATTIVITA = ''' + @NumeroAttivita + '''' + CHAR(13) ELSE '' END
SET	@whereCondition += CASE WHEN @CFLavoratore IS NOT NULL THEN 'AND		AP_KEYD_CFLAVORATOREISCRITTO = ''' + @CFLavoratore + '''' + CHAR(13) ELSE '' END
SET	@whereCondition += CASE WHEN @Elimina IS NOT NULL THEN 'AND		AP_KEYD_ELIMINA = ''' + CAST(@Elimina AS char(1)) + '''' + CHAR(13) ELSE '' END
------------------------------------------------------------------------------------


------------------------------------------------------------------------------------
-- DICHIARAZIONE DELLA TABELLA TEMPORANEA (IN MEMORIA) CHE CONTERRA' IL MAPPING
-- TRA I NODI XML E LE COLONNE SQL DELLA VISTA "VLAVCONTR_DBO" (MODIFICABILE A
-- PIACIMENTO)
------------------------------------------------------------------------------------
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
------------------------------------------------------------------------------------


------------------------------------------------------------------------------------
-- POPOLAMENTO DELLA TABELLA DI MAPPING CON VALORI STATICI DEFINITI ESCLUSIVAMENTE
-- IN QUESTA STORED PROCEDURE: E' POSSIBILE TRASFORMARE QUESTA TABELLA TEMPORANEA
-- IN UNA TABELLA FISICA E POPOLARLA ATTRAVERSO ALTRI MECCANISMI DI CRUD
------------------------------------------------------------------------------------
INSERT	 @TABELLACONFRONTOXML_SQL    
		 (Confronta, Mostra, NomeTabellaSQL, AliasTabellaSQL, NomeColonnaXML, NomeColonnaSQL, TipoDatoSQL)
VALUES	 (1, 1, 'VLAVCONTR_DBO', 'V', 'MatricolaLavoratore' ,'NUM_MTR_LAV', 'varchar(7)')
		,(1, 1, 'VLAVCONTR_DBO', 'V', 'CodiceFiscaleLavoratore' ,'CF_LAVORATORE', 'varchar(7)')
		,(1, 1, 'VLAVCONTR_DBO', 'V', 'Cognome' ,'COGNOME', 'varchar(30)')
		,(1, 1, 'VLAVCONTR_DBO', 'V', 'Nome' ,'NOME', 'varchar(20)')
		,(1, 1, 'VLAVCONTR_DBO', 'V', 'RetribuzionePrecedente' ,'IMP_RETRIB_PREC', 'decimal(13,2)')
		,(1, 1, 'VLAVCONTR_DBO', 'V', 'GiorniFascia' ,'GG_FASCIA', 'int')
		,(1, 1, 'VLAVCONTR_DBO', 'V', 'DataInizio' ,'DATA_INI_PRDO', 'date')
		,(1, 1, 'VLAVCONTR_DBO', 'V', 'DataFine' ,'DATA_FINE_PRDO','date')
		,(1, 1, 'VLAVCONTR_DBO', 'V', 'NumeroGiorniLavorati' ,'NUM_GIORNI', 'int')
		,(0, 1, 'VLAVCONTR_DBO', 'V', 'CodiceQualifica' ,'COD_CAT_LAV', 'char(3)') -- COD_CAT_LAV sempre uguale a zero nei dati utilizzati (mentre nell'XML il valore VA DA "025", "026", "032" ... fino a "132", "214", "216" )
		,(0, 1, 'VLAVCONTR_DBO', 'V', 'TipoRapporto' ,'TIPO_RAPP_LAV', 'varchar(1)') -- TIPO_RAPP_LAV sempre uguale a zero nei dati utilizzati (mentre nell'XML il valore è 1 oppure 2)
		,(1, 1, 'VLAVCONTR_DBO', 'V', 'CodiceRetribuzione' ,'COD_RETR', 'char(2)')
		,(1, 1, 'VLAVCONTR_DBO', 'V', 'ImportoRetribuzione' ,'IMP_RETR_COMPL_100', 'decimal(13,2)') -- COLONNA SQL "IMP_RETR_COMPL" MOLTIPLICATA PER 100 NELLA VISTA (POICHE' NEL NODO XML "ImportoRetribuzione" IL VALORE E' 100 VOLTE INFERIORE)
		,(1, 1, 'VLAVCONTR_DBO', 'V', 'CodiceAliquota' ,'COD_ALIQ', 'char(2)')
		,(1, 1, 'VLAVCONTR_DBO', 'V', 'Codice' ,'COD_AGEV', 'char(2)')
		,(1, 1, 'VLAVCONTR_DBO', 'V', 'ImportoAgevolato ' ,'IMP_AGEV', 'decimal(13,2)')
		,(1, 1, 'VLAVCONTR_DBO', 'V', 'Normale' ,'CONTR_BASE_MOD_100', 'decimal(13,2)') -- COLONNA SQL "CONTR_BASE_MOD" MOLTIPLICATA PER 100 NELLA VISTA (POICHE' NEL NODO XML "Normale" IL VALORE E' 100 VOLTE INFERIORE)
		,(1, 1, 'VLAVCONTR_DBO', 'V', 'Aggiuntivo' ,'CONTR_AGG_MOD', 'decimal(13,2)')
		,(1, 1, 'VLAVCONTR_DBO', 'V', 'Solidarieta' ,'CONTR_SOLID_MOD', 'decimal(13,2)')
------------------------------------------------------------------------------------


------------------------------------------------------------------------------------
-- COSTRUZIONE DELLE STRINGHE DI CONFRONTO TRA I CAMPI XML E LE COLONNE DELLA VISTA
-- PER FORMARE UNA RIGA DEL TIPO:
-- "AND LTRIM(RTRIM(CAST(COALESCE(NULLIF(T.AP_KEYD_SQLCOMMAND_ENPALS.value('(//MatricolaLavoratore)[1]','varchar(max)'),''),'0') AS varchar(7)))) = LTRIM(RTRIM(CAST(COALESCE(NULLIF(CONVERT(varchar(MAX),V.NUM_MTR_LAV),''),'0') AS varchar(7))))"
-- CHE VERRA' AGGIUNTA ALLE PRECEDENTI RIGHE COMPONENTI LA WHERE CONDITION
------------------------------------------------------------------------------------
SELECT	@campiXMLdaConfrontare = 
		COALESCE(@campiXMLdaConfrontare, '') + 
		dbo.fnComposeXML_SQLstringCompare('T.AP_KEYD_SQLCOMMAND_ENPALS', NomeTabellaSQL, AliasTabellaSQL, NomeColonnaXML, NomeColonnaSQL, TipoDatoSQL)
FROM	@TABELLACONFRONTOXML_SQL
WHERE	Confronta = 1
------------------------------------------------------------------------------------


------------------------------------------------------------------------------------
-- COSTRUZIONE DELLE STRINGHE DI CONTENENTI I CAMPI DA AGGIUNGERE ALLA SELECT
-- PER FORMARE UNA RIGA DEL TIPO:
-- ",V.NUM_MTR_LAV"
------------------------------------------------------------------------------------
SELECT	@campiXMLdaMostrare = 
		COALESCE(@campiXMLdaMostrare, '') + 
		'		,' +
		ISNULL(AliasTabellaSQL, NomeTabellaSQL) + 
		'.' + 
		NomeColonnaSQL + 
		CHAR(13)
FROM	@TABELLACONFRONTOXML_SQL
WHERE	Mostra = 1
------------------------------------------------------------------------------------


------------------------------------------------------------------------------------
-- COMPOSIZIONE FINALE DELLA QUERY DA ESEGUIRE COME SQL DINAMICO
------------------------------------------------------------------------------------
SET @SQL =
'
SELECT 
		T.AP_KEYD_IDTRASMIS
		,T.AP_KEYD_COMPETENZA
		,T.AP_KEYD_CFAZIENDA
		,T.AP_KEYD_CODICEGRUPPO
		,T.AP_KEYD_NUMEROATTIVITA
		,T.AP_KEYD_CFLAVORATOREISCRITTO
		,T.AP_KEYD_SQLCOMMAND
		,T.AP_KEYD_SQLCOMMAND_ENPALS
		,T.AP_KEYD_TSINSERIM
		,T.AP_KEYD_ID
		,T.AP_KEYD_ELIMINA
		,T.AP_KEYD_DT_LAVORATO
' + @campiXMLdaMostrare +
'FROM	TB_KEYD_KEYDENINDIVSS_RC T WITH(NOLOCK)
		INNER JOIN
		VLAVCONTR_DBO V
		ON T.AP_KEYD_CFLAVORATOREISCRITTO = V.CF_LAVORATORE
		AND T.AP_KEYD_COMPETENZA = V.DT_MESE_CONTR
' + @whereCondition + CHAR(13) + @campiXMLdaConfrontare
------------------------------------------------------------------------------------

PRINT(@SQL) -- QUESTA LINEA DI COMANDO PUO' ESSERE COMMENTATA: SERVE SOLO A MOSTRARE LA QUERY COMPOSTA

SET NOCOUNT OFF;

------------------------------------------------------------------------------------
-- ESECUZIONE DELLA STRINGA CONTENENTE L'SQL DINAMICO
------------------------------------------------------------------------------------
EXEC(@SQL)
