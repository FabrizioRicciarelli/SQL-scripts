/*
CRUD COMPLETA PER LA SELEZIONE, L'INSERIMENTO, LA MODIFICA, LA CANCELLAZIONE E LA COPIA (DUPLICATO)
DI UNA REGOLA ALL'INTERNO DELLA TABELLA "RULES"

SELECT * FROM RULES

ESEMPI DI INVOCAZIONE:
--------------------------------------------------------
-- SELEZIONE (SELECT)
--------------------------------------------------------
EXEC	spSelInsUpdDelCpyRULE
		'SEL' -- @OP -- (MOSTRA TUTTE LE RIGHE)
		-- @IDRule
		-- @IDGroup 
		-- @RuleName
		-- @ExtendedDescription

EXEC	spSelInsUpdDelCpyRULE
		'SEL' -- @OP
		,1 -- @IDRule -- (MOSTRA SOLO LA REGOLA CORRISPONDENTE AL VALORE SPECIFICATO NEL PARAMETRO, CHE IN QUESTO CASO E' CHIAVE NUMERICA PRIMARIA)
		-- @IDGroup 
		-- @RuleName
		-- @ExtendedDescription

EXEC	spSelInsUpdDelCpyRULE
		'SEL' -- @OP
		-- @IDRule
		-- @IDGroup 
		,@RuleName = 'Tolleranza' -- (MOSTRA TUTTE LE RIGHE NEL CUI NOME REGOLA SIA CONTENUTO IL VALORE SPECIFICATO DAL PARAMETRO @RuleName - UTILIZZA LA LIKE)
		-- @ExtendedDescription

EXEC	spSelInsUpdDelCpyRULE 
		'SEL' -- @OP
		-- @IDRule
		-- @IDGroup 
		-- @RuleName
		,@ExtendedDescription = 'PERCENTUALE' -- (MOSTRA TUTTE LE RIGHE NELLA CUI DESCRIZIONE ESTESA SIA CONTENUTO IL VALORE SPECIFICATO DAL PARAMETRO @ExtendedDescription - UTILIZZA LA LIKE)

--------------------------------------------------------
-- INSERIMENTO
--------------------------------------------------------
EXEC	spSelInsUpdDelCpyRULE 
		'INS' -- @OP
		,NULL -- @IDRule (LA COLONNA CORRISPONDENTE A QUESTO PARAMETRO E' UNA PRIMARY KEY IDENTITY(1,1) QUINDI NON VA VALORIZZATA IN CASO DI INSERIMENTO - IL PARAMETRO SARA' COMUNQUE IGNORATO IN CASO DI VALORIZZAZIONE ACCIDENTALE)
		,2 -- @IDgroup
		,'TEST' -- @RuleName
		,'REGOLA DI PROVA' -- @ExtendedDescription
--------------------------------------------------------


--------------------------------------------------------
-- VARIAZIONE
--------------------------------------------------------
-- PRIMO ESEMPIO

EXEC	spSelInsUpdDelCpyRULE 
		'UPD' -- @OP
		,2 -- @IDRule (CRITERIO DI SELEZIONE DELLA RIGA DA AGGIORNARE, DA SPECIFICARE OBBLIGATORIAMENTE)
		,2 -- @IDgroup (QUESTA COLONNA VIENE AGGIORNATA)
		-- @RuleName (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		-- @ExtendedDescription (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)


-- SECONDO ESEMPIO: NOTARE CHE IL NOME DEL PARAMETRO @RuleName E' STATO ESPRESSAMENTE SPECIFICATO 
-- IN QUANTO IL PARAMETRO @IDgroup E' STATO OMESSO. QUEST'ULTIMO, PERTANTO, MANTERRA' IL SUO VALORE ORIGINARIO

EXEC	spSelInsUpdDelCpyRULE 
		'UPD' -- @OP
		,2 -- @IDRule (CRITERIO DI SELEZIONE DELLA RIGA DA AGGIORNARE, DA SPECIFICARE OBBLIGATORIAMENTE)
		-- @IDgroup (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		,@RuleName = 'BaseInTolleranzaRispettoAllaVariazione' -- (QUESTA COLONNA VIENE AGGIORNATA)
		-- @ExtendedDescription (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)


-- TERZO ESEMPIO: NOTARE CHE IL NOME DEL PARAMETRO @ExtendedDescription E' STATO ESPRESSAMENTE SPECIFICATO 
-- IN QUANTO I PARAMETRI @IDgroup E @RuleName SONO STATI OMESSI. QUESTI ULTIMI, PERTANTO, MANTERRANNO I LORO VALORI ORIGINARI)

EXEC	spSelInsUpdDelCpyRULE 
		'UPD' -- @OP
		,2 -- @IDRule (CRITERIO DI SELEZIONE DELLA RIGA DA AGGIORNARE, DA SPECIFICARE OBBLIGATORIAMENTE)
		-- @IDgroup (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		-- @RuleName = (QUESTA COLONNA, NON ESSENDO STATO VALORIZZATO IL PARAMETRO, SARA' MANTENUTA INVARIATA)
		,@ExtendedDescription = 'Nuova descrizione estesa che rimpiazzerà quella preesistente' -- (QUESTA COLONNA VIENE AGGIORNATA)


-- QUARTO ESEMPIO: 

EXEC	spSelInsUpdDelCpyRULE 
		'UPD' -- @OP
		,2 -- @IDRule (CRITERIO DI SELEZIONE DELLA RIGA DA AGGIORNARE, DA SPECIFICARE OBBLIGATORIAMENTE)
		,NULL -- @IDGroup (QUESTA COLONNA VIENE AZZERATA)
		,'TEST' -- @RuleName (QUESTA COLONNA VIENE AGGIORNATA)
		,'REGOLA DI PROVA' -- (QUESTA COLONNA VIENE AGGIORNATA)
--------------------------------------------------------


--------------------------------------------------------
-- ELIMINAZIONE 
--------------------------------------------------------
-- PRIMO ESEMPIO

EXEC	spSelInsUpdDelCpyRULE 
		'DEL' -- @OP
		,2 -- @IDRule (ELIMINAZIONE PER CHIAVE PRIMARIA, ELIMINA UNA SOLA RIGA, SE TROVA LA CORRISPONDENZA)


-- SECONDO ESEMPIO: NOTARE CHE IL NOME DEL PARAMETRO @IDGroup E' STATO ESPRESSAMENTE SPECIFICATO 
-- IN QUANTO IL PARAMETRO @IDRule E' STATO OMESSO

EXEC	spSelInsUpdDelCpyRULE 
		'DEL' -- @OP
		,@IDGroup = 2 -- (ELIMINA UNA O PIU' RIGHE, A SECONDA DELLA CORRISPONDENZA)


-- TERZO ESEMPIO: NOTARE CHE IL NOME DEL PARAMETRO @RuleName E' STATO ESPRESSAMENTE SPECIFICATO 
-- IN QUANTO I PARAMETRI @IDRule E @IDGroup SONO STATI OMESSI

EXEC	spSelInsUpdDelCpyRULE 
		'DEL' -- @OP
		,@RuleName = 'TEST' -- (ELIMINA UNA SOLA RIGA - IL VALORE DELLA COLONNA RuleName HA UN INDICE UNIQUE -, SE TROVA LA CORRISPONDENZA)


-- QUARTO ESEMPIO: NOTARE CHE IL NOME DEL PARAMETRO @RuleName E' STATO ESPRESSAMENTE SPECIFICATO 
-- IN QUANTO I PARAMETRI @IDRule, @IDGroup E @RuleName SONO STATI OMESSI
EXEC	spSelInsUpdDelCpyRULE 
		'DEL' -- @OP
		,@ExtendedDescription = 'REGOLA DI PROVA' -- (ELIMINA UNA O PIU' RIGHE, A SECONDA DELLA CORRISPONDENZA)
--------------------------------------------------------


--------------------------------------------------------
-- COPIA (O DUPLICAZIONE)
-- LA COPIA PUO' ESSERE EFFETTUATA ESCLUSIVAMENTE
-- PARTENDO DA UN IDRule ESISTENTE O DA UN RuleName 
-- ESISTENTE
--------------------------------------------------------
-- PRIMO ESEMPIO

EXEC	spSelInsUpdDelCpyRULE 
		'CPY' -- @OP
		,1 -- @IDRule (CREA UNA RIGA CLONE DELLA REGOLA CORRISPONDENTE ALLA COLONNA CHIAVE, DIVERSIFICANDOLA DALLA RIGA ORIGINE VARIANDO LA COLONNA RuleName - SARA' AGGIUNTO, IN CODA AL PREESISTENTE VALORE DELLA COLONNA RuleName, UN NUMERO PROGRESSIVO CONSECUTIVO AUTOMATICO DEL TIPO "Nome regola (1)")


-- SECONDO ESEMPIO: NOTARE CHE IL NOME DEL PARAMETRO @RuleName E' STATO ESPRESSAMENTE SPECIFICATO 
-- IN QUANTO I PARAMETRI @IDRule, @IDGroup E @RuleName SONO STATI OMESSI

EXEC	spSelInsUpdDelCpyRULE 
		'CPY' -- @OP
		,@RuleName = 'VariazioneInTolleranzaRispettoAllaBase' (CREA UNA RIGA CLONE DELLA REGOLA LA CUI COLONNA RuleName CORRISPONDE A QUANTO SPECIFICATO NEL PARAMETRO, DIVERSIFICANDOLA DALLA RIGA ORIGINE IN QUANTO, NELLA NUOVA RIGA, ALLA COLONNA RuleName SARA' AGGIUNTO, IN CODA AL PREESISTENTE VALORE, UN NUMERO PROGRESSIVO CONSECUTIVO AUTOMATICO DEL TIPO "VariazioneInTolleranzaRispettoAllaBase (1)")
*/
ALTER PROC	dbo.spSelInsUpdDelCpyRULE
			@OP varchar(3) -- 'SEL', 'INS', 'UPD', 'DEL', 'CPY'
			,@IDRule int = NULL
			,@IDgroup int = NULL 
			,@RuleName varchar(128) = NULL
			,@ExtendedDescription varchar(MAX) = NULL
AS

IF ISNULL(@OP,'') != ''
	BEGIN
		DECLARE @rulesCount int

		-----------------------------------------------------------------------------
		-- SELEZIONE DI UNA O PIU' REGOLE IN BASE ALLA VALORIZZAZIONE DEI PARAMETRI
		-----------------------------------------------------------------------------
		IF @OP = 'SEL'
			BEGIN
				SELECT	*
				FROM	RULES WITH(NOLOCK)
				WHERE	(IDRule = @IDRule OR @IDRule IS NULL)
				AND		(IDgroup = @IDgroup OR @IDgroup IS NULL)
				AND		(RuleName LIKE '%' + @RuleName + '%' OR @RuleName IS NULL)
				AND		(ExtendedDescription LIKE '%' + @ExtendedDescription + '%' OR @ExtendedDescription IS NULL)
			END


		-----------------------------------------------------------------------------
		-- INSERIMENTO DI UNA NUOVA REGOLA: E' OBBLIGATORIO VALORIZZARE TUTTI I
		-- PARAMETRI RELATIVI ALLE COLONNE DELLA TABELLA DEFINITE COME "NOT NULL"
		-----------------------------------------------------------------------------
		IF @OP = 'INS'
		AND ISNULL(@RuleName,'') != ''
		AND ISNULL(@ExtendedDescription,'') != ''
			BEGIN
				INSERT	RULES
						(
							IDGroup
							,RuleName
							,ExtendedDescription
						) 
				SELECT	
						@IDGroup AS IDGroup
						,@RuleName AS RuleName
						,@ExtendedDescription AS ExtendedDescription
			END
		-----------------------------------------------------------------------------


		-----------------------------------------------------------------------------
		-- AGGIORNAMENTO DEI CONTENUTI DEI CAMPI (AD ESCLUSIONE DELL'IDRule)
		-- IN BASE AI PARAMETRI VALORIZZATI: I VALORI DELLE COLONNE NON SPECIFICATE 
		-- NEI PARAMETRI SARANNO MANTENUTI INALTERATI PERTANTO, PER ALTERARLI O
		-- SVUOTARLI (NULL, QUANDO CONSENTITO) INVOCARE LA STORED PROCEDURE
		-- VALORIZZANDO TUTTI I PARAMETRI DESIDERATI
		-----------------------------------------------------------------------------
		IF @OP = 'UPD'
		AND ISNULL(@IDRule,0) != 0 -- PARAMETRO OBBLIGATORIO PER EFFETTUARE L'AGGIORNAMENTO
			BEGIN	
				DECLARE 
						@oldIDgroup int = NULL 
						,@oldRuleName varchar(128) = NULL
						,@oldExtendedDescription varchar(MAX) = NULL
				
				-- MEMORIZZAZIONE DEI DATI PREESISTENTI (SE PRESENTI)
				-- PER LA LORO RIASSEGNAZIONE NEL CASO IN CUI QUESTI
				-- DEBBANO ESSERE MANTENUTI (OVVERO NON NE E' STATO
				-- SPECIFICATO UN NUOVO VALORE)
				SELECT
						@oldIDgroup = IDGroup
						,@oldRuleName = RuleName
						,@oldExtendedDescription = ExtendedDescription
				FROM	RULES WITH(NOLOCK)
				WHERE	IDRule = @IDRule

				-- SE ESISTE UNA COLONNA DA AGGIORNARE, RITORNATA DALLA 
				-- RICERCA PER IL PARAMETRO @IDRule, ALLORA PROCEDE CON
				-- L'AGGIORNAMENTO DELLE SOLE COLONNE PER LE QUALI E'
				-- STATO VALORIZZATO IL CORRISPONDENTE PARAMETRO
				IF ISNULL(@oldRuleName,'') != '' 
					BEGIN
						UPDATE	RULES
						SET		
								IDGroup =
								CASE
									WHEN @IDGroup IS NULL
									THEN @oldIDgroup
									ELSE @IDGroup
								END
								,RuleName =
								CASE
									WHEN @RuleName IS NULL
									THEN @oldRuleName
									ELSE @RuleName
								END
								,ExtendedDescription =
								CASE
									WHEN @ExtendedDescription IS NULL
									THEN @oldExtendedDescription
									ELSE @ExtendedDescription
								END
						WHERE	IDRule = @IDRule
					END
			END
		-----------------------------------------------------------------------------


		-----------------------------------------------------------------------------
		-- ELIMINAZIONE DI UNA REGOLA IN BASE ALL'IDRule, ALL'IDGroup, AL RuleName
		-- OPPURE ALL'ExtendedDescription (UNO SOLTANTO TRA QUESTI)
		-----------------------------------------------------------------------------
		IF @OP = 'DEL'
			BEGIN
				IF ISNULL(@IDRule,0) != 0
					BEGIN
						DELETE 
						FROM	RULES
						WHERE	IDRule = @IDRule
					END
				IF ISNULL(@IDGroup,0) != 0
					BEGIN
						DELETE 
						FROM	RULES
						WHERE	IDGroup = @IDGroup
					END
				IF ISNULL(@RuleName,'') != ''
					BEGIN
						DELETE 
						FROM	RULES
						WHERE	RuleName = @RuleName
					END
				IF ISNULL(@ExtendedDescription,'') != ''
					BEGIN
						DELETE 
						FROM	RULES
						WHERE	ExtendedDescription = @ExtendedDescription
					END
			END
		-----------------------------------------------------------------------------


		-----------------------------------------------------------------------------
		-- CREAZIONE DI UNA COPIA CLONE DI UNA REGOLA, AGGIUNGENDO AL NOME DI QUESTA 
		-- UN SUFFISSO NUMERICO PROGRESSIVO "(1)", "(2)", "(3)", ETC.
		-- LA COPIA PUO' ESSERE EFFETTUATA PARTENDO DA UN IDRule ESISTENTE O DA
		-- UN RuleName ESISTENTE
		-----------------------------------------------------------------------------
		IF @OP = 'CPY'
			BEGIN
				IF ISNULL(@IDRule,0) != 0
					BEGIN
						SELECT	@rulesCount = COUNT(*)
						FROM	RULES WITH(NOLOCK)
						WHERE	RuleName = (SELECT RuleName FROM RULES WITH(NOLOCK) WHERE IDRule = @IDRule)

						INSERT	RULES
								(
									RuleName
									,IDGroup
									,ExtendedDescription
								) 
						SELECT	
								LEFT(RuleName,120) + ' (' + CAST(@rulesCount AS varchar(6)) + ')' AS RuleName -- RIDUCE A 120 CARATTERI IL VALORE DELLA COLONNA PER POTERVI INSERIRE IL PROGRESSIVO (LUNGO AL MASSIMO 6 CARATTERI), PIU' LE PARENTESI TONDE
								,IDGroup
								,ExtendedDescription
						FROM	RULES WITH(NOLOCK)
						WHERE	IDRule = @IDRule
					END

				IF ISNULL(@RuleName,'') != ''
					BEGIN
						SELECT	@rulesCount = COUNT(*)
						FROM	RULES WITH(NOLOCK)
						WHERE	RuleName = @RuleName

						INSERT	RULES
								(
									RuleName
									,IDGroup
									,ExtendedDescription
								) 
						SELECT	TOP 1
								LEFT(RuleName,120) + ' (' + CAST(@rulesCount AS varchar(6)) + ')' AS RuleName -- RIDUCE A 120 CARATTERI IL VALORE DELLA COLONNA PER POTERVI INSERIRE IL PROGRESSIVO (LUNGO AL MASSIMO 6 CARATTERI), PIU' LE PARENTESI TONDE
								,IDGroup
								,ExtendedDescription
						FROM	RULES WITH(NOLOCK)
						WHERE	RuleName = @RuleName
						ORDER BY RuleName
					END
			END
		-----------------------------------------------------------------------------

	END
