USE [UniemensPosSportSpet]
GO
/****** Object:  StoredProcedure [dbo].[spSelInsUpdDelCpyRULEJOIN]    Script Date: 17/02/2017 16:39:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
CRUD COMPLETA PER L'INSERIMENTO, LA MODIFICA, LA CANCELLAZIONE E LA COPIA (DUPLICATO)
DEI JOINTABELLAREGOLA ALL'INTERNO DELLA TABELLA "RULES_JOINS"

SELECT * FROM RULES_TABLES
SELECT * FROM RULES_JOINS
SELECT * FROM VTABLESSCHEMASCOLUMNS ORDER BY FULLOBJECTNAME, FULLFIELDNAME


ESEMPI DI INVOCAZIONE:
--------------------------------------------------------
-- SELEZIONE (SELECT)
--------------------------------------------------------
EXEC	spSelInsUpdDelCpyRULEJOIN 
		'SEL' -- @OP -- (MOSTRA TUTTE LE RIGHE)
		-- @IDRuleJOIN 
		-- @IDRule
		-- @LeftTABObjectID
		-- @RightTABObjectID 
		-- @JoinType
		-- @ALIAS
		-- @ExtendedDescription

EXEC	spSelInsUpdDelCpyRULEJOIN 
		'SEL' -- @OP
		,1 -- @IDRuleJOIN -- (MOSTRA SOLO LA TABELLA CORRISPONDENTE AL VALORE SPECIFICATO NEL PARAMETRO, CHE IN QUESTO CASO E' CHIAVE NUMERICA PRIMARIA)
		-- @IDRule
		-- @LeftTABObjectID
		-- @RightTABObjectID
		-- @JoinType 
		-- @ALIAS
		-- @ExtendedDescription

EXEC	spSelInsUpdDelCpyRULEJOIN 
		'SEL' -- @OP
		-- @IDRuleJOIN
		,@IDRule = 1
		-- @LeftTABObjectID
		-- @RightTABObjectID
		-- @JoinType 
		-- @ALIAS
		-- @ExtendedDescription

DECLARE @oid int
SET @oid = dbo.fnGetObjectID('dbo.TAB_CONTR_031CM')
EXEC	spSelInsUpdDelCpyRULEJOIN 
		'SEL' -- @OP
		-- @IDRuleJOIN 
		-- @IDRule
		,@LeftTABObjectID = @oid -- (MOSTRA SOLO LE RIGHE IL CUI NOME DI TABELLA CORRISPONDE A QUANTO RESTITUITO DALLA FUNZIONE DI CONVERSIONE Nome/ObjectID)
		-- @RightTABObjectID 
		-- @JoinType
		-- @ALIAS
		-- @ExtendedDescription

DECLARE @LTID int, @RTID int
SET @LTID = dbo.fnGetObjectID('dbo.TAB_CONTR_031CM')
SET @RTID = dbo.fnGetObjectID('dbo.TAB_LAV_031CM')
EXEC	spSelInsUpdDelCpyRULEJOIN 
		'SEL' -- @OP
		-- @IDRuleJOIN 
		-- @IDRule
		,@LeftTABObjectID = @LTID
		,@RightTABObjectID = @RTID -- (MOSTRA SOLO LE RIGHE IL CUI IDENTIFICATIVO DI COLONNA CORRISPONDE AL PARAMETRO PASSATO - DA UTILIZZARE PREFERIBILMENTE IN CONGIUNZIONE CON IL PARAMETRO @LeftTABObjectID)
		-- @JoinType
		-- @ALIAS
		-- @ExtendedDescription

EXEC	spSelInsUpdDelCpyRULEJOIN 
		'SEL' -- @OP
		-- @IDRuleJOIN 
		-- @IDRule
		-- @LeftTABObjectID
		-- @RightTABObjectID
		,@JoinType = 'INNER' -- (MOSTRA TUTTE LE RIGHE NEL CUI JoinType SIA CONTENUTO IL VALORE SPECIFICATO DAL PARAMETRO @JoinType)
		-- @ALIAS
		-- @ExtendedDescription

EXEC	spSelInsUpdDelCpyRULEJOIN 
		'SEL' -- @OP
		-- @IDRuleJOIN 
		-- @IDRule
		-- @LeftTABObjectID
		-- @RightTABObjectID
		-- @JoinType 
		,@ALIAS = 'TEST' -- (MOSTRA TUTTE LE RIGHE NEL CUI ALIAS SIA CONTENUTO IL VALORE SPECIFICATO DAL PARAMETRO @ALIAS - UTILIZZA LA LIKE)
		-- @ExtendedDescription

EXEC	spSelInsUpdDelCpyRULEJOIN 
		'SEL' -- @OP
		-- @IDRuleJOIN 
		-- @LeftTABObjectID
		-- @RightTABObjectID 
		-- @JoinType 
		-- @ALIAS
		,@ExtendedDescription = 'PROVA' -- (MOSTRA TUTTE LE RIGHE NELLA CUI DESCRIZIONE ESTESA SIA CONTENUTO IL VALORE SPECIFICATO DAL PARAMETRO @ExtendedDescription - UTILIZZA LA LIKE)
--------------------------------------------------------


--------------------------------------------------------
-- INSERIMENTO
--------------------------------------------------------
DECLARE @LASTID int, @LTID int, @RTID int
SET @LTID = dbo.fnGetObjectID('dbo.TAB_CONTR_031CM') -- METODO DI ESTRAZIONE ALTERNATIVO DELL'ID DI TABELLA
SET @RTID = dbo.fnGetObjectID('dbo.TAB_LAV_031CM') -- METODO DI ESTRAZIONE ALTERNATIVO DELL'ID DI TABELLA

EXEC	@LASTID = spSelInsUpdDelCpyRULEJOIN 
		'INS' -- @OP
		,NULL -- @IDRuleJOIN (LA COLONNA CORRISPONDENTE A QUESTO PARAMETRO E' UNA PRIMARY KEY IDENTITY(1,1) QUINDI NON VA VALORIZZATA IN CASO DI INSERIMENTO - IL PARAMETRO SARA' COMUNQUE IGNORATO IN CASO DI VALORIZZAZIONE ACCIDENTALE)
		,1 -- @IDRule (REGOLA MASTER A CUI APPARTIENE LA JOIN)
		,@LTID -- @LeftTABObjectID (NOTARE CHE IL NOME DELLA TABELLA FISICA E' COMPRENSIVO DELLO SCHEMA "dbo.": LO SCHEMA NON VA OBBLIGATORIAMENTE SPECIFICATO - SARA' AGGIUNTO AUTOMATICAMENTE IL PREFISSO "dbo." - SE NON IN QUEI CASI NEI QUALI ESISTONO TABELLE AVENTI LO STESSO NOME MA UN DIVERSO SCHEMA)
		,@RTID -- @RightTABObjectID (VEDI NOTA PRECEDENTE) 
		,@JoinType = 'INNER'
		,@ALIAS = 'JOINTEST' -- @ALIAS
		,@ExtendedDescription = 'Join di prova tra i contributi e i lavoratori' -- @ExtendedDescription
PRINT (@LASTID)
--------------------------------------------------------


--------------------------------------------------------
-- VARIAZIONE
--------------------------------------------------------
-- PRIMO ESEMPIO

DECLARE @LTID int, @RTID int
SET @LTID = dbo.fnGetObjectID('dbo.TAB_CONTR_031CM') -- METODO DI ESTRAZIONE ALTERNATIVO DELL'ID DI TABELLA
SET @RTID = dbo.fnGetObjectID('dbo.TAB_LAV_031CM') -- METODO DI ESTRAZIONE ALTERNATIVO DELL'ID DI TABELLA

EXEC	spSelInsUpdDelCpyRULEJOIN 
		'UPD' -- @OP
		,2 -- @IDRuleJOIN (CRITERIO DI SELEZIONE DELLA RIGA DA AGGIORNARE, DA SPECIFICARE OBBLIGATORIAMENTE)
		-- @IDRule
		,@LTID -- @LeftTABObjectID (NOTARE CHE IL NOME DELLA TABELLA FISICA E' COMPRENSIVO DELLO SCHEMA "dbo.": LO SCHEMA NON VA OBBLIGATORIAMENTE SPECIFICATO - SARA' AGGIUNTO AUTOMATICAMENTE IL PREFISSO "dbo." - SE NON IN QUEI CASI NEI QUALI ESISTONO TABELLE AVENTI LO STESSO NOME MA UN DIVERSO SCHEMA)
		,@RTID -- @RightTABObjectID (VEDI NOTA PRECEDENTE) 
		-- @JoinType (PARAMETRO NON VALORIZZATO IN QUANTO UTILIZZATO SOLO CON L'OPZIONE 'SEL' A TITOLO DI FILTRO)
		-- @ALIAS -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		-- @ExtendedDescription -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)


-- SECONDO ESEMPIO: NOTARE CHE IL NOME DEL PARAMETRO @ALIAS E' STATO ESPRESSAMENTE SPECIFICATO 
-- IN QUANTO I PARAMETRI @LeftTABObjectID E @RightTABObjectID SONO STATI OMESSI. QUESTI ULTIMI, PERTANTO, MANTERRANNO I LORO VALORI ORIGINARI)

EXEC	spSelInsUpdDelCpyRULEJOIN 
		'UPD' -- @OP
		,2 -- @IDRuleJOIN (CRITERIO DI SELEZIONE DELLA RIGA DA AGGIORNARE, DA SPECIFICARE OBBLIGATORIAMENTE)
		-- @IDRule
		-- @LeftTABObjectID (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		-- @RightTABObjectID -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		-- @JoinType (PARAMETRO NON VALORIZZATO IN QUANTO UTILIZZATO SOLO CON L'OPZIONE 'SEL' A TITOLO DI FILTRO)
		,@ALIAS = 'JOINTEST' -- (VARIARE L'ALIAS DI UNA COLONNA PUO' COMPORTARE LA PERDITA DEL RIFERIMENTO DA PARTE DI ALCUNE FUNZIONI CHE UTILIZZANO L'ALIAS PER RISALIRE ALL'OGGETTO)
		-- @ExtendedDescription -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)

EXEC	spSelInsUpdDelCpyRULEJOIN 
		'UPD' -- @OP
		,1 -- @IDRuleJOIN (CRITERIO DI SELEZIONE DELLA RIGA DA AGGIORNARE, DA SPECIFICARE OBBLIGATORIAMENTE)
		-- @IDRule
		-- @LeftTABObjectID (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		-- @RightTABObjectID -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		,@JoinType = 'INNER JOIN' -- (PARAMETRO NON VALORIZZATO IN QUANTO UTILIZZATO SOLO CON L'OPZIONE 'SEL' A TITOLO DI FILTRO)
		-- @ALIAS (VARIARE L'ALIAS DI UNA COLONNA PUO' COMPORTARE LA PERDITA DEL RIFERIMENTO DA PARTE DI ALCUNE FUNZIONI CHE UTILIZZANO L'ALIAS PER RISALIRE ALL'OGGETTO)
		-- @ExtendedDescription -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)

-- QUARTO ESEMPIO: NOTARE CHE IL NOME DEL PARAMETRO @ExtendedDescription E' STATO ESPRESSAMENTE SPECIFICATO 
-- IN QUANTO I PARAMETRI @LeftTABObjectID, @RightTABObjectID E @ALIAS SONO STATI OMESSI. QUESTI ULTIMI, PERTANTO, MANTERRANNO I LORO VALORI ORIGINARI)

EXEC	spSelInsUpdDelCpyRULEJOIN 
		'UPD' -- @OP
		,2 -- @IDRuleJOIN (CRITERIO DI SELEZIONE DELLA RIGA DA AGGIORNARE, DA SPECIFICARE OBBLIGATORIAMENTE)
		-- @IDRule
		-- @LeftTABObjectID (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		-- @RightTABObjectID -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		-- @JoinType (PARAMETRO NON VALORIZZATO IN QUANTO UTILIZZATO SOLO CON L'OPZIONE 'SEL' A TITOLO DI FILTRO)
		-- @ALIAS -- (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		,@ExtendedDescription = 'Nuova descrizione estesa' -- (VARIANDO LA DESCRIZIONE ESTESA NON SARANNO OSSERVABILI IMPATTI DI ALCUN TIPO)
--------------------------------------------------------


--------------------------------------------------------
-- ELIMINAZIONE 
--------------------------------------------------------
-- PRIMO ESEMPIO

EXEC	spSelInsUpdDelCpyRULEJOIN 
		'DEL' -- @OP
		,2 -- @IDRuleJOIN (ELIMINAZIONE PER CHIAVE PRIMARIA, ELIMINA UNA SOLA RIGA, SE TROVA LA CORRISPONDENZA)
		-- @IDRule
		-- @LeftTABObjectID -- (PARAMETRO INUTILIZZATO)
		-- @RightTABObjectID -- (PARAMETRO INUTILIZZATO)
		-- @JoinType (PARAMETRO NON VALORIZZATO IN QUANTO UTILIZZATO SOLO CON L'OPZIONE 'SEL' A TITOLO DI FILTRO)
		-- @ALIAS -- (PARAMETRO INUTILIZZATO)
		-- @ExtendedDescription (PARAMETRO INUTILIZZATO)


-- SECONDO ESEMPIO: NOTARE CHE IL NOME DEL PARAMETRO @LeftTABObjectID E' STATO ESPRESSAMENTE SPECIFICATO 
-- IN QUANTO IL PARAMETRO @IDRuleJOIN E' STATO OMESSO

DECLARE @oID int, @cID int
SET @oID = dbo.fnGetObjectID('dbo.TAB_CONTR_031CM') -- ESTRAZIONE DELL'ID DI TABELLA

EXEC	spSelInsUpdDelCpyRULEJOIN 
		'DEL' -- @OP
		-- @IDRuleJOIN (PARAMETRO INUTILIZZATO)
		-- @IDRule
		,@LeftTABObjectID = @oID -- (VALORIZZANDO QUESTO PARAMETRO SENZA SPECIFICARE UN VALORE PER IL PARAMETRO SUCCESSIVO - @RightTABObjectID - IN FASE DI ELIMINAZIONE, PRODURRA' L'ELIMINAZIONE DI TUTTE LE COLONNE RELATIVE ALLA TABELLA SPECIFICATA. OVVIAMENTE NON DALLA TABELLA FISICA MA DA QUELLA DELLE REGOLE "RULES_JOINS")
		-- @RightTABObjectID -- (PARAMETRO INUTILIZZATO)
		-- @JoinType (PARAMETRO NON VALORIZZATO IN QUANTO UTILIZZATO SOLO CON L'OPZIONE 'SEL' A TITOLO DI FILTRO)
		-- @ALIAS -- (PARAMETRO INUTILIZZATO)
		-- @ExtendedDescription (PARAMETRO INUTILIZZATO)


-- TERZO ESEMPIO: NOTARE CHE I NOMI DEL PARAMETRO @LeftTABObjectID E @RightTABObjectID SONO STATI ESPRESSAMENTE SPECIFICATI
-- IN QUANTO IL PARAMETRO @IDRuleJOIN E' STATO OMESSO

DECLARE @oID int, @cID int
-- SET @oID = dbo.fnGetObjectID('dbo.TAB_CONTR_031CM') -- METODO DI ESTRAZIONE ALTERNATIVO DELL'ID DI TABELLA
-- SET @cID = dbo.fnGetFieldColumnID('COD_AGEV','dbo.TAB_CONTR_031CM') -- METODO DI ESTRAZIONE ALTERNATIVO DELL'ID DELLA COLONNA
SELECT @oID = IDRuleTAB, @cID = ColumnID FROM dbo.fnGetFieldID('COD_AGEV','TAB_CONTR_031CM') -- METODO DI ESTRAZIONE PRINCIPALE DEGLI ID DI TABELLA E DI COLONNA

EXEC	spSelInsUpdDelCpyRULEJOIN 
		'DEL' -- @OP
		-- @IDRuleJOIN (PARAMETRO INUTILIZZATO)
		-- @IDRule
		,@LeftTABObjectID = @oID -- (ELIMINA UNA SOLA RIGA IN QUANTO COMBINATO CON IL PARAMETRO SUCCESSIVO)
		,@RightTABObjectID = @cID -- (ELIMINA UNA SOLA RIGA IN QUANTO COMBINATO CON IL PARAMETRO PRECEDENTE)
		-- @JoinType (PARAMETRO NON VALORIZZATO IN QUANTO UTILIZZATO SOLO CON L'OPZIONE 'SEL' A TITOLO DI FILTRO)
		-- @ALIAS -- (PARAMETRO INUTILIZZATO)
		-- @ExtendedDescription (PARAMETRO INUTILIZZATO)


-- QUARTO ESEMPIO: NOTARE CHE IL NOME DEL PARAMETRO @ALIAS E' STATO ESPRESSAMENTE SPECIFICATO 
-- IN QUANTO I PARAMETRI  @IDRuleJOIN, @LeftTABObjectID E @RightTABObjectID SONO STATI OMESSI
EXEC	spSelInsUpdDelCpyRULEJOIN 
		'DEL' -- @OP
		-- @IDRuleJOIN (PARAMETRO INUTILIZZATO)
		-- @IDRule
		-- @LeftTABObjectID -- (PARAMETRO INUTILIZZATO)
		-- @RightTABObjectID -- (PARAMETRO INUTILIZZATO)
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

EXEC	spSelInsUpdDelCpyRULEJOIN 
		'CPY' -- @OP
		,1 -- @IDRuleJOIN (CREA UNA RIGA CLONE DEL CAMPO CORRISPONDENTE ALLA COLONNA CHIAVE, DIVERSIFICANDOLA DALLA RIGA ORIGINE VARIANDO LA COLONNA ALIAS - SARA' AGGIUNTO, IN CODA AL PREESISTENTE VALORE DELLA COLONNA ALIAS, UN NUMERO PROGRESSIVO CONSECUTIVO AUTOMATICO DEL TIPO "AliasColonna(1)")
		-- @IDRuleJOIN (PARAMETRO INUTILIZZATO)
		-- @IDRule
		-- @LeftTABObjectID -- (PARAMETRO INUTILIZZATO)
		-- @RightTABObjectID -- (PARAMETRO INUTILIZZATO)
		-- @JoinType (PARAMETRO NON VALORIZZATO IN QUANTO UTILIZZATO SOLO CON L'OPZIONE 'SEL' A TITOLO DI FILTRO)
		-- @ALIAS -- (PARAMETRO INUTILIZZATO)
		-- @ExtendedDescription (PARAMETRO INUTILIZZATO)
		-- @UseFlag (PARAMETRO INUTILIZZATO)


-- SECONDO ESEMPIO: NOTARE CHE IL NOME DEL PARAMETRO @ALIAS E' STATO ESPRESSAMENTE SPECIFICATO 
-- IN QUANTO I PARAMETRI @IDRuleJOIN, @LeftTABObjectID, @IDRule, @RightTABObjectID E @JoinType SONO STATI OMESSI

EXEC	spSelInsUpdDelCpyRULEJOIN 
		'CPY' -- @OP
		-- @IDRuleJOIN (PARAMETRO INUTILIZZATO)
		-- @IDRule
		-- @LeftTABObjectID -- (PARAMETRO INUTILIZZATO)
		-- @RightTABObjectID -- (PARAMETRO INUTILIZZATO)
		-- @JoinType (PARAMETRO NON VALORIZZATO IN QUANTO UTILIZZATO SOLO CON L'OPZIONE 'SEL' A TITOLO DI FILTRO)
		,@ALIAS = 'AliasColonna' (CREA UNA RIGA CLONE DELLA REGOLA LA CUI COLONNA ALIAS CORRISPONDE A QUANTO SPECIFICATO NEL PARAMETRO, DIVERSIFICANDOLA DALLA RIGA ORIGINE IN QUANTO, NELLA NUOVA RIGA, ALLA COLONNA ALIAS SARA' AGGIUNTO, IN CODA AL PREESISTENTE VALORE, UN NUMERO PROGRESSIVO CONSECUTIVO AUTOMATICO DEL TIPO "AliasColonna(1)")
		-- @ExtendedDescription (PARAMETRO INUTILIZZATO)
		-- @UseFlag (PARAMETRO INUTILIZZATO)
*/
ALTER PROC	[dbo].[spSelInsUpdDelCpyRULEJOIN]
			@OP varchar(3) -- 'SEL', 'INS', 'UPD', 'DEL', 'CPY'
			,@IDRuleJOIN int = NULL
			,@IDRule int = NULL
			,@LeftTABObjectID int = NULL
			,@RightTABObjectID int = NULL
			,@JoinType varchar(128) = NULL 
			,@ALIAS varchar(128) = NULL
			,@ExtendedDescription varchar(MAX) = NULL
AS

IF ISNULL(@OP,'') != ''
	BEGIN
		DECLARE @rulesJOINCount int

		-----------------------------------------------------------------------------
		-- SELEZIONE DI UNA O PIU' REGOLE IN BASE ALLA VALORIZZAZIONE DEI PARAMETRI
		-----------------------------------------------------------------------------
		IF @OP = 'SEL'
			BEGIN
				SELECT	
						IDRuleJOIN
						,IDRule
						,V.FullObjectName AS LeftTableName
						,V2.FullObjectName AS RightTableName
						,LeftTABObjectID
						,RightTABObjectID
						,JoinType
						,ALIAS
						,ExtendedDescription
				FROM	RULES_JOINS WITH(NOLOCK)
						INNER JOIN
						VTablesAndSchemas V
						ON LeftTABObjectID = V.ObjectID
						INNER JOIN
						VTablesAndSchemas V2
						ON RightTABObjectID = V2.ObjectID
				WHERE	(IDRuleJOIN = @IDRuleJOIN OR @IDRuleJOIN IS NULL)
				AND		(IDRule = @IDRule OR @IDRule IS NULL)
				AND		(LeftTABObjectID = @LeftTABObjectID OR @LeftTABObjectID IS NULL)
				AND		(RightTABObjectID = @RightTABObjectID OR @RightTABObjectID IS NULL)
				AND		(JoinType LIKE '%' + @JoinType + '%'  OR @JoinType IS NULL)
				AND		(ALIAS LIKE '%' + @ALIAS + '%' OR @ALIAS IS NULL)
				AND		(ExtendedDescription LIKE '%' + @ExtendedDescription + '%' OR @ExtendedDescription IS NULL)
			END

		-----------------------------------------------------------------------------
		-- INSERIMENTO DI UNA NUOVO CAMPO: E' OBBLIGATORIO VALORIZZARE TUTTI I
		-- PARAMETRI RELATIVI ALLE COLONNE DELLA TABELLA DEFINITE COME "NOT NULL"
		-----------------------------------------------------------------------------
		IF @OP = 'INS'
		AND ISNULL(@LeftTABObjectID,0) != 0
		AND ISNULL(@RightTABObjectID,0) != 0
		AND ISNULL(@ALIAS,'') != ''
			BEGIN
				BEGIN TRY
					IF	EXISTS 
						(
							SELECT	IDruleTAB 
							FROM	RULES_TABLES WITH(NOLOCK) 
							WHERE	ObjectID = @LeftTABObjectID
						)
					AND	EXISTS 
						(
							SELECT	IDruleTAB 
							FROM	RULES_TABLES WITH(NOLOCK) 
							WHERE	ObjectID = @RightTABObjectID
						)
						BEGIN
							DECLARE @RULES_JOINS RULES_JOINS_TYPE

							INSERT	@RULES_JOINS
									(
										IDRule
										,LeftTABObjectID
										,RightTABObjectID
										,JoinType
										,ALIAS
										,ExtendedDescription
									)
							VALUES	
									(
										@IDRule
										,@LeftTABObjectID
										,@RightTABObjectID
										,@JoinType
										,@ALIAS
										,@ExtendedDescription
									)

							INSERT	RULES_JOINS
									(
										IDRule
										,LeftTABObjectID
										,RightTABObjectID
										,JoinType
										,ALIAS
										,ExtendedDescription
									)
							SELECT	
									T.IDRule
									,T.LeftTABObjectID
									,T.RightTABObjectID
									,T.JoinType
									,T.ALIAS
									,T.ExtendedDescription
							FROM	@RULES_JOINS T
									LEFT JOIN
									RULES_JOINS RF WITH(NOLOCK)
									ON T.LeftTABObjectID = RF.LeftTABObjectID
									AND T.RightTABObjectID = RF.RightTABObjectID
									AND T.JoinType = RF.JoinType
							WHERE	RF.IDRule IS NULL -- EVITA I DUPLICATI

							RETURN ISNULL(SCOPE_IDENTITY(),0)
						END
				END TRY
				BEGIN CATCH
					DECLARE @ErrorMessage NVARCHAR(4000);
					DECLARE @ErrorSeverity INT;
					DECLARE @ErrorState INT;

					SELECT @ErrorMessage = ERROR_MESSAGE(),
						   @ErrorSeverity = ERROR_SEVERITY(),
						   @ErrorState = ERROR_STATE();

					RAISERROR (@ErrorMessage,
							   @ErrorSeverity,
							   @ErrorState
							   )
				END CATCH
			END
		-----------------------------------------------------------------------------


		-----------------------------------------------------------------------------
		-- AGGIORNAMENTO DEI CONTENUTI DEI CAMPI (AD ESCLUSIONE DELL'IDRuleTAB)
		-- IN BASE AI PARAMETRI VALORIZZATI: I VALORI DELLE COLONNE NON SPECIFICATE 
		-- NEI PARAMETRI SARANNO MANTENUTI INALTERATI PERTANTO, PER ALTERARLI O
		-- SVUOTARLI (NULL, QUANDO CONSENTITO) INVOCARE LA STORED PROCEDURE
		-- VALORIZZANDO TUTTI I PARAMETRI DESIDERATI
		-----------------------------------------------------------------------------
		IF @OP = 'UPD'
		AND ISNULL(@IDRuleJOIN,0) != 0 -- PARAMETRO OBBLIGATORIO PER EFFETTUARE L'AGGIORNAMENTO
			BEGIN	
				DECLARE 
						@oldIDRule int
						,@oldLeftTABObjectID int
						,@oldRightTABObjectID int
						,@oldJoinType varchar(15)
						,@oldALIAS varchar(128)
						,@oldExtendedDescription varchar(MAX)
				
				-- MEMORIZZAZIONE DEI DATI PREESISTENTI (SE PRESENTI)
				-- PER LA LORO RIASSEGNAZIONE NEL CASO IN CUI QUESTI
				-- DEBBANO ESSERE MANTENUTI (OVVERO NON NE E' STATO
				-- SPECIFICATO UN NUOVO VALORE)
				SELECT
						@oldIDRule = IDRule
						,@oldLeftTABObjectID = LeftTABObjectID
						,@oldRightTABObjectID = RightTABObjectID
						,@oldJoinType = JoinType
						,@oldALIAS = ALIAS
						,@oldExtendedDescription = ExtendedDescription
				FROM	RULES_JOINS WITH(NOLOCK)
				WHERE	IDRuleJOIN = @IDRuleJOIN

				-- SE ESISTE UNA COLONNA DA AGGIORNARE, RITORNATA DALLA 
				-- RICERCA PER IL PARAMETRO @IDRule, ALLORA PROCEDE CON
				-- L'AGGIORNAMENTO DELLE SOLE COLONNE PER LE QUALI E'
				-- STATO VALORIZZATO IL CORRISPONDENTE PARAMETRO
				IF ISNULL(@oldIDRule,0) != 0
					BEGIN
						UPDATE	RULES_JOINS
						SET		
								IDRule =
								CASE
									WHEN @IDRule IS NULL
									THEN @oldIDRule
									ELSE @IDRule
								END
								,LeftTABObjectID =
								CASE
									WHEN @LeftTABObjectID IS NULL
									THEN @oldLeftTABObjectID
									ELSE @LeftTABObjectID
								END
								,RightTABObjectID =
								CASE
									WHEN @RightTABObjectID IS NULL
									THEN @oldRightTABObjectID
									ELSE @RightTABObjectID
								END
								,JoinType =
								CASE
									WHEN @JoinType IS NULL
									THEN @oldJoinType
									ELSE @JoinType
								END
								,ALIAS =
								CASE
									WHEN @ALIAS IS NULL
									THEN @oldALIAS
									ELSE @ALIAS
								END
								,ExtendedDescription =
								CASE
									WHEN @ExtendedDescription IS NULL
									THEN @oldExtendedDescription
									ELSE @ExtendedDescription
								END
						WHERE	IDRuleJOIN = @IDRuleJOIN
					END
			END
		-----------------------------------------------------------------------------


		-----------------------------------------------------------------------------
		-- ELIMINAZIONE DI UNA REGOLA IN BASE ALL'IDRule, 
		-- AL LeftTABObjectID+RightTABObjectID+JoinType, ALL'ALIAS OPPURE 
		-- ALL'ExtendedDescription (UNO SOLTANTO TRA QUESTI)
		-----------------------------------------------------------------------------
		IF @OP = 'DEL'
			BEGIN
				IF ISNULL(@IDRuleJOIN,0) != 0
					BEGIN
						DELETE 
						FROM	RULES_JOINS
						WHERE	IDRuleJOIN = @IDRuleJOIN
					END
				IF ISNULL(@LeftTABObjectID,0) != 0
				AND ISNULL(@RightTABObjectID,0) != 0
				AND ISNULL(@JoinType,'') != ''
					BEGIN
						DELETE 
						FROM	RULES_JOINS
						WHERE	LeftTABObjectID = @LeftTABObjectID
						AND		RightTABObjectID = @RightTABObjectID
						AND		JoinType = @JoinType
					END
				IF ISNULL(@ALIAS,'') != ''
					BEGIN
						DELETE 
						FROM	RULES_JOINS
						WHERE	ALIAS = @ALIAS
					END
				IF ISNULL(@ExtendedDescription,'') != ''
					BEGIN
						DELETE 
						FROM	RULES_JOINS
						WHERE	ExtendedDescription = @ExtendedDescription
					END
			END
		-----------------------------------------------------------------------------


		-----------------------------------------------------------------------------
		-- CREAZIONE DI UNA COPIA CLONE DI UNA REGOLA, AGGIUNGENDO ALL'ALIAS DI QUESTA 
		-- UN SUFFISSO NUMERICO PROGRESSIVO "(1)", "(2)", "(3)", ETC.
		-- LA COPIA PUO' ESSERE EFFETTUATA PARTENDO DA UN IDRuleFIELD ESISTENTE O DA
		-- UN "ALIAS" ESISTENTE
		-----------------------------------------------------------------------------
		IF @OP = 'CPY'
			BEGIN
				IF ISNULL(@IDRuleJOIN,0) != 0
					BEGIN
						SELECT	@rulesJOINCount = COUNT(*)
						FROM	RULES_JOINS WITH(NOLOCK)
						WHERE	ALIAS LIKE (SELECT ALIAS FROM RULES_JOINS WITH(NOLOCK) WHERE IDRuleJOIN = @IDRuleJOIN) + '%'

						INSERT	RULES_JOINS
								(
									IDRule
									,LeftTABObjectID
									,RightTABObjectID
									,JoinType
									,ALIAS
									,ExtendedDescription
								) 
						SELECT	
								IDRule
								,LeftTABObjectID
								,RightTABObjectID
								,JoinType
								,LEFT(ALIAS,120)  + ' (' + CAST(@rulesJOINCount AS varchar(6)) + ')' AS ALIAS -- RIDUCE A 120 CARATTERI IL VALORE DELLA COLONNA PER POTERVI INSERIRE IL PROGRESSIVO (LUNGO AL MASSIMO 6 CARATTERI), PIU' LE PARENTESI TONDE
								,ExtendedDescription
						FROM	RULES_JOINS WITH(NOLOCK)
						WHERE	IDRuleJOIN = @IDRuleJOIN
					END

				IF ISNULL(@ALIAS,'') != ''
					BEGIN
						SELECT	@rulesJOINCount = COUNT(*)
						FROM	RULES_JOINS WITH(NOLOCK)
						WHERE	ALIAS LIKE @ALIAS + '%'

						INSERT	RULES_JOINS
								(
									IDRule
									,LeftTABObjectID
									,RightTABObjectID
									,JoinType
									,ALIAS
									,ExtendedDescription
								) 
						SELECT	TOP 1
								IDRule
								,LeftTABObjectID
								,RightTABObjectID
								,JoinType
								,LEFT(ALIAS,120)  + ' (' + CAST(@rulesJOINCount AS varchar(6)) + ')' AS ALIAS -- RIDUCE A 120 CARATTERI IL VALORE DELLA COLONNA PER POTERVI INSERIRE IL PROGRESSIVO (LUNGO AL MASSIMO 6 CARATTERI), PIU' LE PARENTESI TONDE
								,ExtendedDescription
						FROM	RULES_JOINS WITH(NOLOCK)
						WHERE	ALIAS = @ALIAS
						ORDER BY ALIAS
					END
			END
		-----------------------------------------------------------------------------

	END
