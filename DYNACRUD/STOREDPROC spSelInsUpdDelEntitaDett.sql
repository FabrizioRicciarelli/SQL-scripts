/*
---------------------------------------------------------------------------------------------
STORED PROCEDURE PER CRUD DINAMICA (SIMIL-ENTITY FRAMEWORK) SELECT,INSERT,UPDATE,DELETE
SU TABELLA ENTITA_DETT

SI AVVALE DELLE FUNZIONI DynaCrud 1.0
- dbo.fnGetTableDef
- dbo.fnAddSetParam
- dbo.fnFillSqlTemplateWithFieldsList
- dbo.fnCleanVariableName
PER LA COSTRUZIONE DEL CODICE SQL DINAMICO
A INCAPSULAMENTO ANNIDATO PROGRESSIVO

****************************************************
OGNI QUALVOLTA VIENE MODIFICATO UN NOME DI CAMPO,
AGGIUNTO O RIMOSSO UN CAMPO DALLA TABELLA OGGETTO
DELLA PRESENTE CRUD DINAMICA, OPERARE COME SEGUE:

1.	ESEGUIRE LO STATEMENT SEGUENTE:
	DECLARE @t varchar(MAX), @TAB char(1)=CHAR(9), @TAB3 char(3), @CR char(1)=CHAR(13); SET @TAB3=REPLICATE(@TAB,3) ; SET @t=dbo.fnFillSqlTemplateWithFieldsList(@CR+@TAB3+'$V $F = NULL,','ENTITA_DETT')+@CR+@TAB3+'@OP char(1) = NULL,'+@CR+@TAB3+'@UpdateWhereCondition varchar(MAX) = NULL,'+@CR+@TAB3+'@ReturnValue int OUTPUT'; PRINT(@t)

2.	COPIARE IL RISULTATO DALLA CASELLA "Messages" 
	ED INCOLLARLO IN *SOSTITUZIONE* DELL'ATTUALE
	DEFINIZIONE DEI PARAMETRI DELLA PRESENTE
	STORED PROCEDURE

3.	ESEGUIRE LO STATEMENT SEGUENTE:
	DECLARE @t varchar(MAX); SET @t='EXEC sp_executesql @SQL,@paramDefinitions,' + dbo.fnFillSqlTemplateWithFieldsList('$V,','ENTITA_DETT'); SET @t=LEFT(@t,LEN(@t)-1); PRINT(@t)

4.	COPIARE IL RISULTATO DALLA CASELLA "Messages" 
	ED INCOLLARLO IN *SOSTITUZIONE* DEGLI ATTUALI
	STATEMENTS "EXEC sp_executesql" RELATIVAMENTE
	ALLE OPERAZIONI DI SELECT, INSERT, UPDATE E 
	DELETE: PER L'OPERAZIONE DI *UPDATE*, AGGIUNGERE
	QUESTO IN CODA (SENZA LE VIRGOLETTE): 
	
	",@subSQL=@subSQL OUTPUT"

5.	RIMPIAZZARE, SE LO SI DESIDERA, TUTTA LA SEZIONE
	DEGLI "Esempi di invocazione" AFFINCHE' ANCHE
	QUESTI RAPPRESENTINO LA STRUTTURA AGGIORNATA E
	POSSANO ESSERE NUOVAMENTE VALORIZZATI CON VALORI
	DI TEST E POI INVOCATI SENZA INCORRERE IN ERRORI
****************************************************

---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------
Esempi di invocazione:

----------------------------
-- INSERIMENTO DI UN RECORD
----------------------------
DECLARE @LASTID int
EXEC	spSelInsUpdDelEntitaDett
		@CodiceEntita = 'RIT'
		,@CFCreditore = 'GGGHHH45H28S290W'
		,@CFDebitore = NULL
		,@CodicePrestazione = '12346'
		,@CodiceSede = '000000'
		,@CodiceProcedura = '39B'
		,@Progressivo = 1
		,@Anno = 2015
		,@Mese = '11'
		,@AnnoRif = NULL
		,@MeseRif = NULL
		,@ImportoCredito = 2000.00
		,@ImportoDebito = 1500.23
		,@ImportoSospeso = NULL
		,@ImportoSospesoInAtto = NULL
		,@DataInserimento = NULL
		,@DataUltimaModifica = NULL
		,@CodiceRegione = '00'
		,@IdStruttura = 3
		,@ChiaveARCAAnagraficaCodice = NULL
		,@ChiaveARCAAnagraficaProgressivo = NULL
		,@ChiaveARCAPrestazione = NULL
		,@OP = 'I' -- S = Select, I = Insert, U = Update, D = Delete
		,@UpdateWhereCondition = NULL
		,@ReturnValue =  @LASTID OUTPUT
PRINT(@LASTID)

------------------------------
-- AGGIORNAMENTO DI UN RECORD
------------------------------

-- DATA E ORA CORRENTI (per valorizzare il campo "DataUltimaModifica")
DECLARE @now datetime
SET @now = GETDATE()

-- STRINGA CASUALE DA 128 CARATTERI (per valorizzare il campo "ChiaveARCAPrestazione")
SET NOCOUNT ON;
DECLARE @var TABLE(rndstr varchar(MAX))
DECLARE @rndstr varchar(max)
INSERT @var EXEC sp_RandomString 128
SELECT @rndstr = rndstr FROM @var
SET NOCOUNT OFF;

EXEC	spSelInsUpdDelEntitaDett
		@CodiceEntita = NULL
		,@CFCreditore = NULL
		,@CFDebitore = NULL
		,@CodicePrestazione = '1234A'
		,@CodiceSede = NULL
		,@CodiceProcedura = NULL
		,@Progressivo = NULL
		,@Anno = NULL
		,@Mese = NULL
		,@AnnoRif = NULL
		,@MeseRif = NULL
		,@ImportoCredito = NULL
		,@ImportoDebito = 1800.31
		,@ImportoSospeso = 543.86
		,@ImportoSospesoInAtto = NULL
		,@DataInserimento = NULL
		,@DataUltimaModifica = @now
		,@CodiceRegione = NULL
		,@IdStruttura = 1
		,@ChiaveARCAAnagraficaCodice = NULL
		,@ChiaveARCAAnagraficaProgressivo = NULL
		,@ChiaveARCAPrestazione = @rndstr
		,@OP = 'U' -- S = Select, I = Insert, U = Update, D = Delete
		,@UpdateWhereCondition = 'CFCreditore = ''RCCFRZ67P13F611D'' AND Anno = 2015 AND Mese = ''11'' '
		,@ReturnValue = NULL

------------------------------
-- SELEZIONE DI UNO O PIU'
-- RECORDS CORRISPONDENTI AI
-- VALORI IMPOSTATI
------------------------------
EXEC	spSelInsUpdDelEntitaDett NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'S',NULL,NULL -- SELEZIONA TUTTI I RECORDS

-- oppure

EXEC	spSelInsUpdDelEntitaDett
		@CodiceEntita = NULL
		,@CFCreditore = NULL
		,@CFDebitore = NULL
		,@CodicePrestazione  = NULL
		,@CodiceSede = NULL
		,@CodiceProcedura = NULL
		,@Progressivo = NULL
		,@Anno = NULL
		,@Mese = NULL
		,@AnnoRif = NULL
		,@MeseRif = NULL
		,@ImportoCredito = NULL
		,@ImportoDebito = NULL
		,@ImportoSospeso = NULL
		,@ImportoSospesoInAtto = NULL
		,@DataInserimento = NULL
		,@DataUltimaModifica = NULL
		,@CodiceRegione = NULL
		,@IdStruttura = NULL
		,@ChiaveARCAAnagraficaCodice = NULL
		,@ChiaveARCAAnagraficaProgressivo = NULL
		,@ChiaveARCAPrestazione = NULL
		,@OP = 'S' -- S = Select, I = Insert, U = Update, D = Delete
		,@UpdateWhereCondition = NULL
		,@ReturnValue = NULL


------------------------------
-- ELIMINAZIONE DI UNO O PIU'
-- RECORDS CORRISPONDENTI AI
-- VALORI IMPOSTATI
------------------------------
EXEC	spSelInsUpdDelEntitaDett
		@CodiceEntita = NULL
		,@CFCreditore = NULL
		,@CFDebitore = NULL
		,@CodicePrestazione  = NULL
		,@CodiceSede = NULL
		,@CodiceProcedura = '29'
		,@Progressivo = NULL
		,@Anno = NULL
		,@Mese = NULL
		,@AnnoRif = NULL
		,@MeseRif = NULL
		,@ImportoCredito = NULL
		,@ImportoDebito = NULL
		,@ImportoSospeso = NULL
		,@ImportoSospesoInAtto = NULL
		,@DataInserimento = NULL
		,@DataUltimaModifica = NULL
		,@CodiceRegione = NULL
		,@IdStruttura = NULL
		,@ChiaveARCAAnagraficaCodice = NULL
		,@ChiaveARCAAnagraficaProgressivo = NULL
		,@ChiaveARCAPrestazione = NULL
		,@OP = 'D' -- S = Select, I = Insert, U = Update, D = Delete
		,@UpdateWhereCondition = NULL
		,@ReturnValue = NULL
------------------------------------------------------------
*/
ALTER PROC	[dbo].[spSelInsUpdDelEntitaDett]
			@CodiceEntita varchar(5) = NULL,
			@CFCreditore varchar(16) = NULL,
			@CFDebitore varchar(16) = NULL,
			@CodicePrestazione varchar(5) = NULL,
			@CodiceSede char(6) = NULL,
			@CodiceProcedura varchar(4) = NULL,
			@Progressivo int = NULL,
			@Anno int = NULL,
			@Mese varchar(2) = NULL,
			@AnnoRif int = NULL,
			@MeseRif varchar(2) = NULL,
			@ImportoCredito decimal(18,2) = NULL,
			@ImportoDebito decimal(18,2) = NULL,
			@ImportoSospeso decimal(18,2) = NULL,
			@ImportoSospesoInAtto decimal(18,2) = NULL,
			@DataInserimento datetime = NULL,
			@DataUltimaModifica datetime = NULL,
			@CodiceRegione varchar(2) = NULL,
			@IdStruttura int = NULL,
			@ChiaveARCAAnagraficaCodice varchar(3) = NULL,
			@ChiaveARCAAnagraficaProgressivo int = NULL,
			@ChiaveARCAPrestazione varchar(128) = NULL,
			@OP char(1) = NULL,
			@UpdateWhereCondition varchar(MAX) = NULL,
			@ReturnValue int OUTPUT
AS

DECLARE 
		@tableName varchar(128) = 'ENTITA_DETT'
		,@SQL Nvarchar(MAX) -- SQL Dinamico di primo livello
		,@subSQL Nvarchar(MAX) -- SQL dinamico di secondo livello
		,@fieldsList varchar(MAX) -- Contenitore per nomi dei campi (CodiceEntita, CFCreditore etc.)
		,@castedDenulledFieldsList varchar(MAX) -- Contenitore per CAST dei campi (ISNULL(@CodiceEntita,''), ISNULL(@CFCreditore,''), ISNULL(CAST(@IDStruttura AS varchar(9)),'') etc.)
		,@paramDefinitions Nvarchar(MAX) -- Contenitore per definizione dei tipi dei parametri (@CodiceEntita varchar(5), @CFCreditore varchar(16) etc.)
		,@baseWhereCondition Nvarchar(MAX) -- Contenitore per criteri di filtro dinamici (AND (CodiceEntita = @CodiceEntita OR @CodiceEntita IS NULL))
		
		------------------------------------------
		-- ESPANSIONE FUTURA PER MULTIANNIDAMENTO
		------------------------------------------
		--,@paramsList Nvarchar(MAX) -- Contenitore per nomi dei parametri (@CodiceEntita,@CFCreditore,@CFdebitore etc.)
		--,@paramDefinitionsLevel2 Nvarchar(MAX) -- Contenitore per definizione dei tipi dei parametri di secondo livello (@CodiceEntita varchar(5), @CFCreditore varchar(16) etc.)
		--SET @paramsList = dbo.fnFillSqlTemplateWithFieldsList('@$N,',@tableName)
		--SET @paramsList = LEFT(@paramsList,LEN(@paramsList)-1) -- Elimina la virgola finale
		------------------------------------------

SET @fieldsList = dbo.fnFillSqlTemplateWithFieldsList('$N,',@tableName)
SET @fieldsList = LEFT(@fieldsList,LEN(@fieldsList)-1) -- Elimina la virgola finale

SET @castedDenulledFieldsList = dbo.fnFillSqlTemplateWithFieldsList('$M,',@tableName)
SET @castedDenulledFieldsList = LEFT(@castedDenulledFieldsList,LEN(@castedDenulledFieldsList)-1) -- Elimina la virgola finale


SET @paramDefinitions = dbo.fnFillSqlTemplateWithFieldsList('$V $F,',@tableName)
SET @paramDefinitions = LEFT(@paramDefinitions,LEN(@paramDefinitions)-1) -- Elimina la virgola finale

SET @baseWhereCondition = dbo.fnFillSqlTemplateWithFieldsList('AND ($N = $V OR $V IS NULL)' + CHAR(13),@tableName)
SET @ReturnValue = 0


-----------------------------------------------------------
-- OPERAZIONE DI SELECT (SQL DINAMICO, NESSUN ANNIDAMENTO)
-----------------------------------------------------------
IF @OP = 'S'
	BEGIN
		SET @SQL =
		N'
		SELECT ' + @fieldsList + '
		FROM	' + @tableName + ' WITH(NOLOCK)
		WHERE	1=1 ' + CHAR(13) + @baseWhereCondition
		EXEC sp_executesql @SQL,@paramDefinitions,@CodiceEntita,@CFCreditore,@CFDebitore,@CodicePrestazione,@CodiceSede,@CodiceProcedura,@Progressivo,@Anno,@Mese,@AnnoRif,@MeseRif,@ImportoCredito,@ImportoDebito,@ImportoSospeso,@ImportoSospesoInAtto,@DataInserimento,@DataUltimaModifica,@CodiceRegione,@IdStruttura,@ChiaveARCAAnagraficaCodice,@ChiaveARCAAnagraficaProgressivo,@ChiaveARCAPrestazione

		SET @ReturnValue = @@ROWCOUNT
	END


-----------------------------------------------------------
-- OPERAZIONE DI INSERT (SQL DINAMICO, NESSUN ANNIDAMENTO)
-----------------------------------------------------------
IF @OP = 'I'
	BEGIN
		SET @SQL =
		N'
		INSERT	' + @tableName + '(' + @fieldsList + ')
		VALUES(' + @castedDenulledFieldsList + ')'
		EXEC sp_executesql @SQL,@paramDefinitions,@CodiceEntita,@CFCreditore,@CFDebitore,@CodicePrestazione,@CodiceSede,@CodiceProcedura,@Progressivo,@Anno,@Mese,@AnnoRif,@MeseRif,@ImportoCredito,@ImportoDebito,@ImportoSospeso,@ImportoSospesoInAtto,@DataInserimento,@DataUltimaModifica,@CodiceRegione,@IdStruttura,@ChiaveARCAAnagraficaCodice,@ChiaveARCAAnagraficaProgressivo,@ChiaveARCAPrestazione

		SET @ReturnValue = @@ROWCOUNT -- la funzione SCOPE_IDENTITY() può essere invocata solo se esiste una colonna IDENTITY
	END


-----------------------------------------------------------
-- OPERAZIONE DI UPDATE (SQL DINAMICO, UN SOLO ANNIDAMENTO)
-----------------------------------------------------------
IF @OP = 'U'
AND	@UpdateWhereCondition IS NOT NULL
	BEGIN
		SET @paramDefinitions += N',@subSQL nvarchar(MAX) output'
		SET @SQL = 'SET @subSQL = ''UPDATE ' + @tableName + '''' + CHAR(13)
		SET	@SQL += dbo.fnFillSqlTemplateWithFieldsList('SELECT @subSQL = dbo.fnAddSetParam(@subSQL,''$N'', '''' + $K + '''', ''$T'') ' + CHAR(13), @tableName)
		SET @SQL += CHAR(13) + 'SET @subSQL += ''WHERE ' + REPLACE(@UpdateWhereCondition,CHAR(39), CHAR(39)+CHAR(39)) + ''''
		--PRINT(@SQL)
		EXEC sp_executesql @SQL,@paramDefinitions,@CodiceEntita,@CFCreditore,@CFDebitore,@CodicePrestazione,@CodiceSede,@CodiceProcedura,@Progressivo,@Anno,@Mese,@AnnoRif,@MeseRif,@ImportoCredito,@ImportoDebito,@ImportoSospeso,@ImportoSospesoInAtto,@DataInserimento,@DataUltimaModifica,@CodiceRegione,@IdStruttura,@ChiaveARCAAnagraficaCodice,@ChiaveARCAAnagraficaProgressivo,@ChiaveARCAPrestazione,@subSQL=@subSQL OUTPUT
		EXEC(@subSQL)
		--PRINT(@subSQL)

		SET @ReturnValue = @@ROWCOUNT
	END


-----------------------------------------------------------
-- OPERAZIONE DI DELETE (SQL DINAMICO, NESSUN ANNIDAMENTO)
-----------------------------------------------------------
IF @OP = 'D'
	BEGIN
		SET @SQL =
		N'
		DELETE 
		FROM	' + @tableName + '
		WHERE	1=1 ' + CHAR(13) + @baseWhereCondition
		EXEC sp_executesql @SQL,@paramDefinitions,@CodiceEntita,@CFCreditore,@CFDebitore,@CodicePrestazione,@CodiceSede,@CodiceProcedura,@Progressivo,@Anno,@Mese,@AnnoRif,@MeseRif,@ImportoCredito,@ImportoDebito,@ImportoSospeso,@ImportoSospesoInAtto,@DataInserimento,@DataUltimaModifica,@CodiceRegione,@IdStruttura,@ChiaveARCAAnagraficaCodice,@ChiaveARCAAnagraficaProgressivo,@ChiaveARCAPrestazione

		SET @ReturnValue = @@ROWCOUNT
	END