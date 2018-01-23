/*
CRUD COMPLETA PER L'INSERIMENTO, LA MODIFICA, LA CANCELLAZIONE E LA COPIA (DUPLICATO)
DEI JOINSTABELLAREGOLA ALL'INTERNO DELLA TABELLA "RULES_JOINS"

LA PRESENTE STORED PROCEDURE INVOCA LA SP "GEMELLA" spSelInsUpdDelCpyRULEJOIN_N: AL POSTO, PERO'
DEGLI IDTABELLA (@LeftTABObjectID E @RightTABObjectID) UTILIZZA I NOMI DEGLI OGGETTI (@LeftTableName E @RightTableName)

ESEMPI DI INVOCAZIONE:
--------------------------------------------------------
-- SELEZIONE (SELECT)
--------------------------------------------------------
EXEC	spSelInsUpdDelCpyRULEJOIN_N 
		'SEL' -- @OP -- (MOSTRA TUTTE LE RIGHE)
		-- @IDRuleJOIN 
		-- @IDRule
		-- @LeftTableName
		-- @RightTableName 
		-- @JoinType
		-- @ALIAS
		-- @ExtendedDescription

EXEC	spSelInsUpdDelCpyRULEJOIN_N 
		'SEL' -- @OP
		,1 -- @IDRuleJOIN -- (MOSTRA SOLO LA TABELLA CORRISPONDENTE AL VALORE SPECIFICATO NEL PARAMETRO, CHE IN QUESTO CASO E' CHIAVE NUMERICA PRIMARIA)
		-- @IDRule
		-- @LeftTableName
		-- @RightTableName
		-- @JoinType 
		-- @ALIAS
		-- @ExtendedDescription

EXEC	spSelInsUpdDelCpyRULEJOIN_N 
		'SEL' -- @OP
		-- @IDRuleJOIN
		,@IDRule = 1
		-- @LeftTableName
		-- @RightTableName
		-- @JoinType 
		-- @ALIAS
		-- @ExtendedDescription

EXEC	spSelInsUpdDelCpyRULEJOIN_N 
		'SEL' -- @OP
		-- @IDRuleJOIN 
		-- @IDRule
		,@LeftTableName = 'var.TAB_CONTR_031CM' -- (MOSTRA SOLO LE RIGHE IL CUI NOME DI TABELLA CORRISPONDE A QUANTO SPECIFICATO)
		-- @RightTableName 
		-- @JoinType
		-- @ALIAS
		-- @ExtendedDescription

EXEC	spSelInsUpdDelCpyRULEJOIN_N 
		'SEL' -- @OP
		-- @IDRuleJOIN 
		-- @IDRule
		,@LeftTableName = 'dbo.TAB_CONTR_031CM'
		,@RightTableName = 'dbo.TAB_LAV_031CM' -- (MOSTRA SOLO LE RIGHE IL CUI IDENTIFICATIVO DI COLONNA CORRISPONDE AL PARAMETRO PASSATO - DA UTILIZZARE PREFERIBILMENTE IN CONGIUNZIONE CON IL PARAMETRO @LeftTableName)
		-- @JoinType
		-- @ALIAS
		-- @ExtendedDescription

EXEC	spSelInsUpdDelCpyRULEJOIN_N 
		'SEL' -- @OP
		-- @IDRuleJOIN 
		-- @IDRule
		,@LeftTableName = 'var.TAB_CONTR_031CM'
		,@RightTableName = 'var.TAB_LAV_031CM' -- (MOSTRA SOLO LE RIGHE IL CUI IDENTIFICATIVO DI COLONNA CORRISPONDE AL PARAMETRO PASSATO - DA UTILIZZARE PREFERIBILMENTE IN CONGIUNZIONE CON IL PARAMETRO @LeftTableName)
		-- @JoinType
		-- @ALIAS
		-- @ExtendedDescription

EXEC	spSelInsUpdDelCpyRULEJOIN_N 
		'SEL' -- @OP
		-- @IDRule
		-- @IDRuleJOIN 
		-- @LeftTableName
		-- @RightTableName
		,@JoinType = 'INNER' -- (MOSTRA TUTTE LE RIGHE NEL CUI FieldName SIA CONTENUTO IL VALORE SPECIFICATO DAL PARAMETRO @JoinType)
		-- @ALIAS
		-- @ExtendedDescription

EXEC	spSelInsUpdDelCpyRULEJOIN_N 
		'SEL' -- @OP
		-- @IDRuleJOIN 
		-- @IDRule
		-- @LeftTableName
		-- @RightTableName
		-- @JoinType 
		,@ALIAS = 'BASE' -- (MOSTRA TUTTE LE RIGHE NEL CUI ALIAS SIA CONTENUTO IL VALORE SPECIFICATO DAL PARAMETRO @ALIAS - UTILIZZA LA LIKE)
		-- @ExtendedDescription

EXEC	spSelInsUpdDelCpyRULEJOIN_N 
		'SEL' -- @OP
		-- @IDRuleJOIN 
		-- @LeftTableName
		-- @RightTableName 
		-- @JoinType 
		-- @ALIAS
		,@ExtendedDescription = 'Contributo' -- (MOSTRA TUTTE LE RIGHE NELLA CUI DESCRIZIONE ESTESA SIA CONTENUTO IL VALORE SPECIFICATO DAL PARAMETRO @ExtendedDescription - UTILIZZA LA LIKE)
--------------------------------------------------------


--------------------------------------------------------
-- INSERIMENTO
--------------------------------------------------------
DECLARE @LASTID int, @LTID int, @RTID int
SET @LTID = dbo.fnGetObjectID('dbo.TAB_CONTR_031CM') -- METODO DI ESTRAZIONE ALTERNATIVO DELL'ID DI TABELLA
SET @RTID = dbo.fnGetObjectID('dbo.TAB_LAV_031CM') -- METODO DI ESTRAZIONE ALTERNATIVO DELL'ID DI TABELLA

EXEC	@LASTID = spSelInsUpdDelCpyRULEJOIN_N 
		'INS' -- @OP
		,NULL -- @IDRuleJOIN (LA COLONNA CORRISPONDENTE A QUESTO PARAMETRO E' UNA PRIMARY KEY IDENTITY(1,1) QUINDI NON VA VALORIZZATA IN CASO DI INSERIMENTO - IL PARAMETRO SARA' COMUNQUE IGNORATO IN CASO DI VALORIZZAZIONE ACCIDENTALE)
		,1 -- @IDRule (REGOLA MASTER A CUI APPARTIENE LA JOIN)
		,@LTID -- @LeftTableName (NOTARE CHE IL NOME DELLA TABELLA FISICA E' COMPRENSIVO DELLO SCHEMA "dbo.": LO SCHEMA NON VA OBBLIGATORIAMENTE SPECIFICATO - SARA' AGGIUNTO AUTOMATICAMENTE IL PREFISSO "dbo." - SE NON IN QUEI CASI NEI QUALI ESISTONO TABELLE AVENTI LO STESSO NOME MA UN DIVERSO SCHEMA)
		,@RTID -- @RightTableName (VEDI NOTA PRECEDENTE) 
		-- @JoinType (PARAMETRO NON VALORIZZATO IN QUANTO UTILIZZATO SOLO CON L'OPZIONE 'SEL' A TITOLO DI FILTRO)
		,'JOINTEST' -- @ALIAS
		,'Join di prova tra i contributi e i lavoratori' -- @ExtendedDescription
PRINT (@LASTID)
--------------------------------------------------------


--------------------------------------------------------
-- VARIAZIONE
--------------------------------------------------------
-- PRIMO ESEMPIO

DECLARE @LTID int, @RTID int
SET @LTID = dbo.fnGetObjectID('dbo.TAB_CONTR_031CM') -- METODO DI ESTRAZIONE ALTERNATIVO DELL'ID DI TABELLA
SET @RTID = dbo.fnGetObjectID('dbo.TAB_LAV_031CM') -- METODO DI ESTRAZIONE ALTERNATIVO DELL'ID DI TABELLA

EXEC	spSelInsUpdDelCpyRULEJOIN_N 
		'UPD' -- @OP
		,2 -- @IDRuleJOIN (CRITERIO DI SELEZIONE DELLA RIGA DA AGGIORNARE, DA SPECIFICARE OBBLIGATORIAMENTE)
		-- @IDRule
		,@LTID -- @LeftTableName (NOTARE CHE IL NOME DELLA TABELLA FISICA E' COMPRENSIVO DELLO SCHEMA "dbo.": LO SCHEMA NON VA OBBLIGATORIAMENTE SPECIFICATO - SARA' AGGIUNTO AUTOMATICAMENTE IL PREFISSO "dbo." - SE NON IN QUEI CASI NEI QUALI ESISTONO TABELLE AVENTI LO STESSO NOME MA UN DIVERSO SCHEMA)
		,@RTID -- @RightTableName (VEDI NOTA PRECEDENTE) 
		-- @JoinType (PARAMETRO NON VALORIZZATO IN QUANTO UTILIZZATO SOLO CON L'OPZIONE 'SEL' A TITOLO DI FILTRO)
		-- @ALIAS -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		-- @ExtendedDescription -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)


EXEC	spSelInsUpdDelCpyRULEJOIN_N 
		'UPD' -- @OP
		,1 -- @IDRuleJOIN (CRITERIO DI SELEZIONE DELLA RIGA DA AGGIORNARE, DA SPECIFICARE OBBLIGATORIAMENTE)
		-- @IDRule
		-- @LeftTableName (NOTARE CHE IL NOME DELLA TABELLA FISICA E' COMPRENSIVO DELLO SCHEMA "dbo.": LO SCHEMA NON VA OBBLIGATORIAMENTE SPECIFICATO - SARA' AGGIUNTO AUTOMATICAMENTE IL PREFISSO "dbo." - SE NON IN QUEI CASI NEI QUALI ESISTONO TABELLE AVENTI LO STESSO NOME MA UN DIVERSO SCHEMA)
		-- @RightTableName (VEDI NOTA PRECEDENTE) 
		,@JoinType = 'LEFT JOIN' -- (PARAMETRO NON VALORIZZATO IN QUANTO UTILIZZATO SOLO CON L'OPZIONE 'SEL' A TITOLO DI FILTRO)
		-- @ALIAS -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		-- @ExtendedDescription -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)

-- SECONDO ESEMPIO: NOTARE CHE IL NOME DEL PARAMETRO @ALIAS E' STATO ESPRESSAMENTE SPECIFICATO 
-- IN QUANTO I PARAMETRI @LeftTableName E @RightTableName SONO STATI OMESSI. QUESTI ULTIMI, PERTANTO, MANTERRANNO I LORO VALORI ORIGINARI)

EXEC	spSelInsUpdDelCpyRULEJOIN_N 
		'UPD' -- @OP
		,2 -- @IDRuleJOIN (CRITERIO DI SELEZIONE DELLA RIGA DA AGGIORNARE, DA SPECIFICARE OBBLIGATORIAMENTE)
		-- @IDRule
		-- @LeftTableName (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		-- @RightTableName -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		-- @JoinType (PARAMETRO NON VALORIZZATO IN QUANTO UTILIZZATO SOLO CON L'OPZIONE 'SEL' A TITOLO DI FILTRO)
		,@ALIAS = 'JOINTEST' -- (VARIARE L'ALIAS DI UNA COLONNA PUO' COMPORTARE LA PERDITA DEL RIFERIMENTO DA PARTE DI ALCUNE FUNZIONI CHE UTILIZZANO L'ALIAS PER RISALIRE ALL'OGGETTO)
		-- @ExtendedDescription -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)


-- QUARTO ESEMPIO: NOTARE CHE IL NOME DEL PARAMETRO @ExtendedDescription E' STATO ESPRESSAMENTE SPECIFICATO 
-- IN QUANTO I PARAMETRI @LeftTableName, @RightTableName E @ALIAS SONO STATI OMESSI. QUESTI ULTIMI, PERTANTO, MANTERRANNO I LORO VALORI ORIGINARI)

EXEC	spSelInsUpdDelCpyRULEJOIN_N 
		'UPD' -- @OP
		,2 -- @IDRuleJOIN (CRITERIO DI SELEZIONE DELLA RIGA DA AGGIORNARE, DA SPECIFICARE OBBLIGATORIAMENTE)
		-- @IDRule
		-- @LeftTableName (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		-- @RightTableName -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		-- @JoinType (PARAMETRO NON VALORIZZATO IN QUANTO UTILIZZATO SOLO CON L'OPZIONE 'SEL' A TITOLO DI FILTRO)
		-- @ALIAS -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		,@ExtendedDescription = 'Nuova descrizione estesa' -- (VARIANDO LA DESCRIZIONE ESTESA NON SARANNO OSSERVABILI IMPATTI DI ALCUN TIPO)
--------------------------------------------------------


--------------------------------------------------------
-- ELIMINAZIONE 
--------------------------------------------------------
-- PRIMO ESEMPIO

EXEC	spSelInsUpdDelCpyRULEJOIN_N 
		'DEL' -- @OP
		,2 -- @IDRuleJOIN (ELIMINAZIONE PER CHIAVE PRIMARIA, ELIMINA UNA SOLA RIGA, SE TROVA LA CORRISPONDENZA)
		-- @IDRule
		-- @LeftTableName -- (PARAMETRO INUTILIZZATO)
		-- @RightTableName -- (PARAMETRO INUTILIZZATO)
		-- @JoinType (PARAMETRO NON VALORIZZATO IN QUANTO UTILIZZATO SOLO CON L'OPZIONE 'SEL' A TITOLO DI FILTRO)
		-- @ALIAS -- (PARAMETRO INUTILIZZATO)
		-- @ExtendedDescription (PARAMETRO INUTILIZZATO)


-- SECONDO ESEMPIO: NOTARE CHE IL NOME DEL PARAMETRO @LeftTableName E' STATO ESPRESSAMENTE SPECIFICATO 
-- IN QUANTO IL PARAMETRO @IDRuleJOIN E' STATO OMESSO

EXEC	spSelInsUpdDelCpyRULEJOIN_N 
		'DEL' -- @OP
		-- @IDRuleJOIN (PARAMETRO INUTILIZZATO)
		-- @IDRule
		,@LeftTableName = 'dbo.TAB_CONTR_031CM' -- (VALORIZZANDO QUESTO PARAMETRO SENZA SPECIFICARE UN VALORE PER IL PARAMETRO SUCCESSIVO - @RightTableName - IN FASE DI ELIMINAZIONE, PRODURRA' L'ELIMINAZIONE DI TUTTE LE COLONNE RELATIVE ALLA TABELLA SPECIFICATA. OVVIAMENTE NON DALLA TABELLA FISICA MA DA QUELLA DELLE REGOLE "RULES_JOINS")
		,@RightTableName -- (PARAMETRO INUTILIZZATO)
		-- @JoinType (PARAMETRO NON VALORIZZATO IN QUANTO UTILIZZATO SOLO CON L'OPZIONE 'SEL' A TITOLO DI FILTRO)
		-- @ALIAS -- (PARAMETRO INUTILIZZATO)
		-- @ExtendedDescription (PARAMETRO INUTILIZZATO)


-- TERZO ESEMPIO: NOTARE CHE I NOMI DEL PARAMETRO @LeftTableName E @RightTableName SONO STATI ESPRESSAMENTE SPECIFICATI
-- IN QUANTO IL PARAMETRO @IDRuleJOIN E' STATO OMESSO

EXEC	spSelInsUpdDelCpyRULEJOIN_N 
		'DEL' -- @OP
		-- @IDRuleJOIN (PARAMETRO INUTILIZZATO)
		-- @IDRule
		,@LeftTableName = 'dbo.TAB_CONTR_031CM' -- (ELIMINA UNA SOLA RIGA IN QUANTO COMBINATO CON IL PARAMETRO SUCCESSIVO)
		,@RightTableName = 'dbo.TAB_LAV_031CM' -- (ELIMINA UNA SOLA RIGA IN QUANTO COMBINATO CON IL PARAMETRO PRECEDENTE)
		,@JoinType = 'INNER' (ELIMINA UNA SOLA RIGA IN QUANTO COMBINATO CON IL PARAMETRO SUCCESSIVO)
		-- @ALIAS -- (PARAMETRO INUTILIZZATO)
		-- @ExtendedDescription (PARAMETRO INUTILIZZATO)


-- QUARTO ESEMPIO: NOTARE CHE IL NOME DEL PARAMETRO @ALIAS E' STATO ESPRESSAMENTE SPECIFICATO 
-- IN QUANTO I PARAMETRI  @IDRuleJOIN, @LeftTableName E @RightTableName SONO STATI OMESSI
EXEC	spSelInsUpdDelCpyRULEJOIN_N 
		'DEL' -- @OP
		-- @IDRuleJOIN (PARAMETRO INUTILIZZATO)
		-- @IDRule
		-- @LeftTableName -- (PARAMETRO INUTILIZZATO)
		-- @RightTableName -- (PARAMETRO INUTILIZZATO)
		-- @JoinType (PARAMETRO NON VALORIZZATO IN QUANTO UTILIZZATO SOLO CON L'OPZIONE 'SEL' A TITOLO DI FILTRO)
		,@ALIAS = 'JOINTEST' -- (ELIMINA UNA SOLA RIGA - IL VALORE DELLA COLONNA "ALIAS" HA UN INDICE UNIQUE -, SE TROVA LA CORRISPONDENZA)
		-- @ExtendedDescription (PARAMETRO INUTILIZZATO)
--------------------------------------------------------


--------------------------------------------------------
-- COPIA (O DUPLICAZIONE)
-- LA COPIA PUO' ESSERE EFFETTUATA ESCLUSIVAMENTE
-- PARTENDO DA UN IDRule ESISTENTE O DA UN RuleName 
-- ESISTENTE
--------------------------------------------------------
-- PRIMO ESEMPIO

EXEC	spSelInsUpdDelCpyRULEJOIN_N 
		'CPY' -- @OP
		,1 -- @IDRuleJOIN (CREA UNA RIGA CLONE DEL CAMPO CORRISPONDENTE ALLA COLONNA CHIAVE, DIVERSIFICANDOLA DALLA RIGA ORIGINE VARIANDO LA COLONNA ALIAS - SARA' AGGIUNTO, IN CODA AL PREESISTENTE VALORE DELLA COLONNA ALIAS, UN NUMERO PROGRESSIVO CONSECUTIVO AUTOMATICO DEL TIPO "AliasColonna(1)")
		-- @IDRuleJOIN (PARAMETRO INUTILIZZATO)
		-- @IDRule
		-- @LeftTableName -- (PARAMETRO INUTILIZZATO)
		-- @RightTableName -- (PARAMETRO INUTILIZZATO)
		-- @JoinType (PARAMETRO NON VALORIZZATO IN QUANTO UTILIZZATO SOLO CON L'OPZIONE 'SEL' A TITOLO DI FILTRO)
		-- @ALIAS -- (PARAMETRO INUTILIZZATO)
		-- @ExtendedDescription (PARAMETRO INUTILIZZATO)
		-- @UseFlag (PARAMETRO INUTILIZZATO)


-- SECONDO ESEMPIO: NOTARE CHE IL NOME DEL PARAMETRO @ALIAS E' STATO ESPRESSAMENTE SPECIFICATO 
-- IN QUANTO I PARAMETRI @IDRuleJOIN, @LeftTableName, @IDRule, @RightTableName E @JoinType SONO STATI OMESSI

EXEC	spSelInsUpdDelCpyRULEJOIN_N 
		'CPY' -- @OP
		-- @IDRuleJOIN (PARAMETRO INUTILIZZATO)
		-- @IDRule
		-- @LeftTableName -- (PARAMETRO INUTILIZZATO)
		-- @RightTableName -- (PARAMETRO INUTILIZZATO)
		-- @JoinType (PARAMETRO NON VALORIZZATO IN QUANTO UTILIZZATO SOLO CON L'OPZIONE 'SEL' A TITOLO DI FILTRO)
		,@ALIAS = 'JOINTEST' -- (CREA UNA RIGA CLONE DELLA REGOLA LA CUI COLONNA ALIAS CORRISPONDE A QUANTO SPECIFICATO NEL PARAMETRO, DIVERSIFICANDOLA DALLA RIGA ORIGINE IN QUANTO, NELLA NUOVA RIGA, ALLA COLONNA ALIAS SARA' AGGIUNTO, IN CODA AL PREESISTENTE VALORE, UN NUMERO PROGRESSIVO CONSECUTIVO AUTOMATICO DEL TIPO "AliasColonna(1)")
		-- @ExtendedDescription (PARAMETRO INUTILIZZATO)
		-- @UseFlag (PARAMETRO INUTILIZZATO)
*/
ALTER PROC	spSelInsUpdDelCpyRULEJOIN_N
			@OP varchar(3) -- 'SEL', 'INS', 'UPD', 'DEL', 'CPY'
			,@IDRulejOIN int = NULL
			,@IDRule int = NULL
			,@LeftTableName varchar(128) = NULL
			,@RightTableName varchar(128) = NULL
			,@JoinType varchar(15) = NULL
			,@ALIAS varchar(128) = NULL
			,@ExtendedDescription varchar(MAX) = NULL
AS

IF ISNULL(@OP,'') != ''
	BEGIN
		DECLARE 
				@LeftTableID int = NULL
				,@RightTableID int = NULL
				,@fieldName varchar(128) = NULL

		IF @LeftTableName IS NOT NULL
		AND @RightTableName IS NOT NULL
			BEGIN
				SELECT @LeftTableID = dbo.fnGetObjectID(@LeftTableName)
				SELECT @RightTableID = dbo.fnGetObjectID(@RightTableName)
			END
						
		EXEC	spSelInsUpdDelCpyRULEJOIN
				@OP
				,@IDRuleJoin
				,@IDRule
				,@LeftTableID
				,@RightTableID
				,@JoinType
				,@ALIAS
				,@ExtendedDescription
	END
