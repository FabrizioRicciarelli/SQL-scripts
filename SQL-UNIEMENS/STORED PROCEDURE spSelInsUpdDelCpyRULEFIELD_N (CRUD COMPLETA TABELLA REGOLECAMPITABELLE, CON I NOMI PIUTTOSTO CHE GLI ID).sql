/*
CRUD COMPLETA PER L'INSERIMENTO, LA MODIFICA, LA CANCELLAZIONE E LA COPIA (DUPLICATO)
DEI CAMPITABELLAREGOLA ALL'INTERNO DELLA TABELLA "RULES_FIELDS"

LA PRESENTE STORED PROCEDURE INVOCA LA SP "GEMELLA" spSelInsUpdDelCpyRULEFIELD: AL POSTO, PERO'
DEGLI IDTABELLA E IDCOLONNA (@IDRuleTAB E @ColumnID) UTILIZZA I NOMI DEGLI OGGETTI (@RulesTableName E @RulesColumnName)

SELECT * FROM RULES_FIELDS
SELECT * FROM VTABLESSCHEMASCOLUMNS ORDER BY FULLOBJECTNAME, FULLFIELDNAME


ESEMPI DI INVOCAZIONE:
--------------------------------------------------------
-- SELEZIONE (SELECT)
--------------------------------------------------------
EXEC	spSelInsUpdDelCpyRULEFIELD_N
		'SEL' -- @OP -- (MOSTRA TUTTE LE RIGHE)
		-- @IDRuleFIELD 
		-- @RulesTableName
		-- @RulesColumnName
		-- @ALIAS
		-- @ExtendedDescription
		-- @UseFlag

EXEC	spSelInsUpdDelCpyRULEFIELD_N
		'SEL' -- @OP
		,4 -- @IDRuleFIELD -- (MOSTRA SOLO LA TABELLA CORRISPONDENTE AL VALORE SPECIFICATO NEL PARAMETRO, CHE IN QUESTO CASO E' CHIAVE NUMERICA PRIMARIA)
		-- @RulesTableName
		-- @RulesColumnName
		-- @ALIAS
		-- @ExtendedDescription
		-- @UseFlag

EXEC	spSelInsUpdDelCpyRULEFIELD_N
		'SEL' -- @OP
		-- @IDRuleFIELD 
		,@RulesTableName = 'var.TAB_CONTR_031CM' -- (MOSTRA SOLO LE RIGHE IL CUI NOME DI TABELLA CORRISPONDE A QUANTO SPECIFICATO)
		-- @RulesColumnName
		-- @ALIAS
		-- @ExtendedDescription
		-- @UseFlag

EXEC	spSelInsUpdDelCpyRULEFIELD_N
		'SEL' -- @OP
		-- @IDRuleFIELD 
		,@RulesTableName = 'var.TAB_CONTR_031CM' -- (MOSTRA SOLO LE RIGHE IL CUI NOME DI TABELLA CORRISPONDE A QUANTO SPECIFICATO)
		,@RulesFieldName = 'ID_CONTR' -- (MOSTRA SOLO LE RIGHE IL CUI NOME DI COLONNA CORRISPONDE A QUANTO SPECIFICATO)
		-- @ALIAS
		-- @ExtendedDescription
		-- @UseFlag

EXEC	spSelInsUpdDelCpyRULEFIELD_N
		'SEL' -- @OP
		-- @IDRuleFIELD 
		-- @RulesTableName
		-- @RulesFieldName
		,@ALIAS = 'BASE' -- (MOSTRA TUTTE LE RIGHE NEL CUI ALIAS SIA CONTENUTO IL VALORE SPECIFICATO DAL PARAMETRO @ALIAS - UTILIZZA LA LIKE)
		-- @ExtendedDescription
		-- @UseFlag

EXEC	spSelInsUpdDelCpyRULEFIELD_N
		'SEL' -- @OP
		-- @IDRuleFIELD 
		-- @RulesTableName
		-- @RulesFieldName
		-- @ALIAS
		,@ExtendedDescription = 'Contributo' -- (MOSTRA TUTTE LE RIGHE NELLA CUI DESCRIZIONE ESTESA SIA CONTENUTO IL VALORE SPECIFICATO DAL PARAMETRO @ExtendedDescription - UTILIZZA LA LIKE)
		-- @UseFlag

EXEC	spSelInsUpdDelCpyRULEFIELD_N
		'SEL' -- @OP
		-- @IDRuleFIELD 
		-- @RulesTableName
		-- @RulesFieldName
		-- @ALIAS
		-- @ExtendedDescription
		,@UseFlag = 2 -- (MOSTRA TUTTE LE RIGHE SPECIFICANTI IL TIPO DI UTILIZZO DEL CAMPO, DOVE: NULL o 0 = visualizza e usa in JOIN/WHERE, 1 = visualizza soltanto, 2 = utilizza solo in JOIN/WHERE senza visualizzare)
--------------------------------------------------------


--------------------------------------------------------
-- INSERIMENTO
--------------------------------------------------------
DECLARE @LASTID int
EXEC	@LASTID = spSelInsUpdDelCpyRULEFIELD_N
		'INS' -- @OP
		,NULL -- @IDRuleFIELD (LA COLONNA CORRISPONDENTE A QUESTO PARAMETRO E' UNA PRIMARY KEY IDENTITY(1,1) QUINDI NON VA VALORIZZATA IN CASO DI INSERIMENTO - IL PARAMETRO SARA' COMUNQUE IGNORATO IN CASO DI VALORIZZAZIONE ACCIDENTALE)
		,'dbo.TAB_CONTR_031CM' -- @RulesTableName (NOTARE CHE IL NOME DELLA TABELLA FISICA E' COMPRENSIVO DELLO SCHEMA "dbo.": LO SCHEMA NON VA OBBLIGATORIAMENTE SPECIFICATO - SARA' AGGIUNTO AUTOMATICAMENTE IL PREFISSO "dbo." - SE NON IN QUEI CASI NEI QUALI ESISTONO TABELLE AVENTI LO STESSO NOME MA UN DIVERSO SCHEMA)
		,'COD_AGEV' -- @RulesFieldName
		,'FIELDTEST' -- @ALIAS
		,'CAMPO DI PROVA COLLEGATO ALLA TABELLA BASE' -- @ExtendedDescription
		,2 -- @UseFlag
PRINT (@LASTID) -- SE RITORNA "-4" POTREBBE SIGNIFICARE CHE IL CRITERIO DI UNIQUE, APPLICATO ALLA TABELLA RULES_FIELDS PER I CAMPI "IDRuleTAB" E "ColumnID", E' STATO VIOLATO (NON E' CONSENTITO INSERIRE PIU' VOLTE LO STESSO CAMPO RIFERENTESI ALLA MEDESIMA TABELLA)
--------------------------------------------------------


--------------------------------------------------------
-- VARIAZIONE
--------------------------------------------------------
-- PRIMO ESEMPIO (RIMPIAZZA LA TABELLA DI APPARTENZA DELLA COLONNA SPECIFICATA DAL PARAMETRO @IDRuleFIELD)

EXEC	spSelInsUpdDelCpyRULEFIELD_N 
		'UPD' -- @OP
		,2 -- @IDRuleFIELD (CRITERIO DI SELEZIONE DELLA RIGA DA AGGIORNARE, DA SPECIFICARE OBBLIGATORIAMENTE)
		,'var.TAB_CONTR_031CM' -- @RulesTableName (NOTARE CHE IL NOME DELLA TABELLA FISICA E' COMPRENSIVO DELLO SCHEMA "dbo.": LO SCHEMA NON VA OBBLIGATORIAMENTE SPECIFICATO - SARA' AGGIUNTO AUTOMATICAMENTE IL PREFISSO "dbo." - SE NON IN QUEI CASI NEI QUALI ESISTONO TABELLE AVENTI LO STESSO NOME MA UN DIVERSO SCHEMA)
		-- @RulesFieldName
		-- @ALIAS -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		-- @ExtendedDescription -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		-- @UseFlag -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)


-- SECONDO ESEMPIO: NOTARE CHE IL NOME DEL PARAMETRO @ALIAS E' STATO ESPRESSAMENTE SPECIFICATO 
-- IN QUANTO I PARAMETRI @IDRuleTAB E @ColumnID SONO STATI OMESSI. QUESTI ULTIMI, PERTANTO, MANTERRANNO I LORO VALORI ORIGINARI)

EXEC	spSelInsUpdDelCpyRULEFIELD_N 
		'UPD' -- @OP
		,2 -- @IDRuleFIELD (CRITERIO DI SELEZIONE DELLA RIGA DA AGGIORNARE, DA SPECIFICARE OBBLIGATORIAMENTE)
		-- @RulesTableName (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		-- @RulesFieldName -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		,@ALIAS = 'TESTTABLE' -- (VARIARE L'ALIAS DI UNA COLONNA PUO' COMPORTARE LA PERDITA DEL RIFERIMENTO DA PARTE DI ALCUNE FUNZIONI CHE UTILIZZANO L'ALIAS PER RISALIRE ALL'OGGETTO)
		-- @ExtendedDescription -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		-- @UseFlag -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)


-- QUARTO ESEMPIO: NOTARE CHE IL NOME DEL PARAMETRO @ExtendedDescription E' STATO ESPRESSAMENTE SPECIFICATO 
-- IN QUANTO I PARAMETRI @IDRuleTAB, @ColumnID E @ALIAS SONO STATI OMESSI. QUESTI ULTIMI, PERTANTO, MANTERRANNO I LORO VALORI ORIGINARI)

EXEC	spSelInsUpdDelCpyRULEFIELD_N 
		'UPD' -- @OP
		,2 -- @IDRuleFIELD (CRITERIO DI SELEZIONE DELLA RIGA DA AGGIORNARE, DA SPECIFICARE OBBLIGATORIAMENTE)
		-- @RulestableName (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		-- @RulesFieldName -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		-- @ALIAS -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		,@ExtendedDescription = 'Nuova descrizione estesa' -- (VARIANDO LA DESCRIZIONE ESTESA NON SARANNO OSSERVABILI IMPATTI DI ALCUN TIPO)
		-- @UseFlag
--------------------------------------------------------


--------------------------------------------------------
-- ELIMINAZIONE 
--------------------------------------------------------
-- PRIMO ESEMPIO

EXEC	spSelInsUpdDelCpyRULEFIELD_N 
		'DEL' -- @OP
		,2 -- @IDRuleFIELD (ELIMINAZIONE PER CHIAVE PRIMARIA, ELIMINA UNA SOLA RIGA, SE TROVA LA CORRISPONDENZA)
		-- @RulesTableName -- (PARAMETRO INUTILIZZATO)
		-- @RulesFieldName -- (PARAMETRO INUTILIZZATO)
		-- @ALIAS -- (PARAMETRO INUTILIZZATO)
		-- @ExtendedDescription (PARAMETRO INUTILIZZATO)
		-- @UseFlag (PARAMETRO INUTILIZZATO)


-- SECONDO ESEMPIO: NOTARE CHE I NOMI DEL PARAMETRO @RulesTableName E @RulesFieldName SONO STATI ESPRESSAMENTE SPECIFICATI
-- IN QUANTO IL PARAMETRO @IDRuleFIELD E' STATO OMESSO

EXEC	spSelInsUpdDelCpyRULEFIELD_N 
		'DEL' -- @OP
		-- @IDRuleFIELD (PARAMETRO INUTILIZZATO)
		,@RulesTableName = 'dbo.TAB_CONTR_031CM' -- (ELIMINA UNA SOLA RIGA IN QUANTO COMBINATO CON IL PARAMETRO SUCCESSIVO)
		,@RulesFieldName = 'COD_AGEV' -- (ELIMINA UNA SOLA RIGA IN QUANTO COMBINATO CON IL PARAMETRO PRECEDENTE)
		-- @ALIAS -- (PARAMETRO INUTILIZZATO)
		-- @ExtendedDescription (PARAMETRO INUTILIZZATO)
		-- @UseFlag (PARAMETRO INUTILIZZATO)


-- TERZO ESEMPIO: NOTARE CHE IL NOME DEL PARAMETRO @ALIAS E' STATO ESPRESSAMENTE SPECIFICATO 
-- IN QUANTO I PARAMETRI  @IDRuleFIELD, @RulestableName E @RulesFieldName SONO STATI OMESSI
EXEC	spSelInsUpdDelCpyRULEFIELD_N 
		'DEL' -- @OP
		-- @IDRuleFIELD (PARAMETRO INUTILIZZATO)
		-- @RulesTableName -- (PARAMETRO INUTILIZZATO)
		-- @RulesFieldName -- (PARAMETRO INUTILIZZATO)
		,@ALIAS = 'FIELDTEST' -- (ELIMINA UNA SOLA RIGA - IL VALORE DELLA COLONNA "ALIAS" HA UN INDICE UNIQUE -, SE TROVA LA CORRISPONDENZA)
		-- @ExtendedDescription (PARAMETRO INUTILIZZATO)
		-- @UseFlag (PARAMETRO INUTILIZZATO)
--------------------------------------------------------


--------------------------------------------------------
-- COPIA (O DUPLICAZIONE)
-- LA COPIA PUO' ESSERE EFFETTUATA ESCLUSIVAMENTE
-- PARTENDO DA UN IDRule ESISTENTE O DA UN RuleName 
-- ESISTENTE
--------------------------------------------------------
-- PRIMO ESEMPIO

EXEC	spSelInsUpdDelCpyRULEFIELD_N 
		'CPY' -- @OP
		,1 -- @IDRuleFIELD (CREA UNA RIGA CLONE DEL CAMPO CORRISPONDENTE ALLA COLONNA CHIAVE, DIVERSIFICANDOLA DALLA RIGA ORIGINE VARIANDO LA COLONNA RuleName - SARA' AGGIUNTO, IN CODA AL PREESISTENTE VALORE DELLA COLONNA ALIAS, UN NUMERO PROGRESSIVO CONSECUTIVO AUTOMATICO DEL TIPO "AliasColonna(1)")
		-- @IDRuleFIELD (PARAMETRO INUTILIZZATO)
		-- @RulestableName -- (PARAMETRO INUTILIZZATO)
		-- @RulesFieldName -- (PARAMETRO INUTILIZZATO)
		-- @ALIAS -- (PARAMETRO INUTILIZZATO)
		-- @ExtendedDescription (PARAMETRO INUTILIZZATO)
		-- @UseFlag (PARAMETRO INUTILIZZATO)


-- SECONDO ESEMPIO: NOTARE CHE IL NOME DEL PARAMETRO @ALIAS E' STATO ESPRESSAMENTE SPECIFICATO 
-- IN QUANTO I PARAMETRI @IDRuleFIELD, @RulestableName, @RulesFieldName, SONO STATI OMESSI

EXEC	spSelInsUpdDelCpyRULEFIELD_N 
		'CPY' -- @OP
		-- @IDRuleFIELD (PARAMETRO INUTILIZZATO)
		-- @RulestableName -- (PARAMETRO INUTILIZZATO)
		-- @RulesFieldName -- (PARAMETRO INUTILIZZATO)
		,@ALIAS = 'AliasColonna' (CREA UNA RIGA CLONE DELLA REGOLA LA CUI COLONNA ALIAS CORRISPONDE A QUANTO SPECIFICATO NEL PARAMETRO, DIVERSIFICANDOLA DALLA RIGA ORIGINE IN QUANTO, NELLA NUOVA RIGA, ALLA COLONNA ALIAS SARA' AGGIUNTO, IN CODA AL PREESISTENTE VALORE, UN NUMERO PROGRESSIVO CONSECUTIVO AUTOMATICO DEL TIPO "AliasColonna(1)")
		-- @ExtendedDescription (PARAMETRO INUTILIZZATO)
		-- @UseFlag (PARAMETRO INUTILIZZATO)
*/
ALTER PROC	dbo.spSelInsUpdDelCpyRULEFIELD_N
			@OP varchar(3) -- 'SEL', 'INS', 'UPD', 'DEL', 'CPY'
			,@IDRuleField int = NULL
			,@RulesTableName varchar(128) = NULL
			,@RulesFieldName varchar(128) = NULL
			,@ALIAS varchar(128) = NULL
			,@ExtendedDescription varchar(MAX) = NULL
			,@UseFlag smallInt = NULL
AS

IF ISNULL(@OP,'') != ''
	BEGIN
		DECLARE 
				@tabID int = NULL
				,@colID int = NULL
				,@fieldName varchar(128) = NULL

		IF @RulesTableName IS NOT NULL
		AND @RulesFieldName IS NOT NULL
			BEGIN
				SELECT @tabID = IDRuleTAB, @colID = ColumnID FROM dbo.fnGetFieldID(@RulesFieldName,@RulesTableName)
				SELECT	@FieldName = fieldName
				FROM	VRULES_FIELDS V
				WHERE	ParentID = @tabID
				AND		ColumnID = @colID
			END
		IF @RulesTableName IS NOT NULL
		AND @RulesFieldName IS NULL
			BEGIN
				SET @tabID = dbo.fnGetObjectID(@RulesTableName)
			END
		
		PRINT(@ALIAS)
						
		EXEC	spSelInsUpdDelCpyRULEFIELD
				@OP
				,@IDRuleField
				,@tabID
				,@colID
				,@FieldName
				,@ALIAS
				,@ExtendedDescription
				,@UseFlag
	END
