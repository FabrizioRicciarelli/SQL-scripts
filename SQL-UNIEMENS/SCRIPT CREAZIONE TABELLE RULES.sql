/*
CREATE TABLE	dbo.RULES
				(
					IDRule int IDENTITY(1,1) PRIMARY KEY CLUSTERED NOT NULL
					,IDgroup int NULL -- per raggruppamenti
					,RuleName varchar(128) NOT NULL -- nome mnemonico
					,ExtendedDescription varchar(MAX) NOT NULL -- descrizione esaustiva dei contenuti dell'oggetto REGOLE
				)

CREATE TABLE	dbo.RULES_TABLES
				(
					IDRuleTAB int IDENTITY(1,1) PRIMARY KEY CLUSTERED NOT NULL
					,IDRule int NOT NULL -- relativo alla tabella RULES
					,ObjectID int NOT NULL -- releativo all'ID della tabella di sistema sysobjects
					,ALIAS varchar(128) NOT NULL -- nome rappresentativo di immediata comprensione (autoparlante)
					,ExtendedDescription varchar(MAX) -- descrizione esaustiva dei contenuti dell'oggetto tabella
				)

CREATE TABLE	dbo.RULES_FIELDS
				(
					IDruleFIELD int IDENTITY(1,1) PRIMARY KEY CLUSTERED NOT NULL
					,IDruleTAB int NOT NULL -- relativo alla tabella RULES_TABLES (funge anche da ParentObjectID in quanto relativo all'ID della tabella di sistema sysobjects)
					,ColumnID int NOT NULL -- releativo all'ID della tabella di sistema syscolumns (da utilizzare in congiunzione con IDruleTAB)
					,ALIAS varchar(128) NULL -- nome rappresentativo di immediata comprensione (autoparlante)
					,ExtendedDescription varchar(MAX) NOT NULL -- descrizione esaustiva dei contenuti dell'oggetto campo/colonna
					,UseFlag smallint NULL -- flag indicante il tipo di utilizzo del campo: NULL o 0 = visualizza e usa in JOIN/WHERE, 1 = visualizza soltanto, 2 = utilizza solo in JOIN/WHERE senza mostrare
				)

CREATE TABLE	dbo.RULES_JOINS
				(
					IDruleJOIN int IDENTITY(1,1) PRIMARY KEY CLUSTERED NOT NULL
					,LeftTABobjectID int NOT NULL -- relativo alla tabella RULES_TABLES
					,RightTABobjectID int NOT NULL -- relativo alla tabella RULES_TABLES
					,JOINtype varchar(15) NOT NULL -- INNER, LEFT, LEFT OUTER, RIGHT, RIGHT OUTER, CROSS, etc.
				)

CREATE TABLE	dbo.RULES_JOINCONDITIONS
				(
					IDruleJOINCOND int IDENTITY(1,1) PRIMARY KEY CLUSTERED NOT NULL
					,IDruleJOIN int NOT NULL -- relativo alla tabella RULES_JOINS
					,LeftFIELDobjectID int NOT NULL -- relativo alla tabella RULES_FIELDS
					,RightFIELDobjectID int NULL -- relativo alla tabella RULES_FIELDS
					,RightValue varchar(128) NULL -- in ALTERNATIVA al RightFIELDobjectID (invece che il costrutto ON FIELD1=FIELD2 si utilizzerà ON FIELD1=VALUE)
				)

CREATE TABLE	dbo.RULES_WHERECONDITIONS
				(
					IDruleWHERECOND int IDENTITY(1,1) PRIMARY KEY CLUSTERED NOT NULL
					,IDrule int NOT NULL -- relativo alla tabella RULES
					,LeftFIELDobjectID int NOT NULL -- relativo alla tabella RULES_FIELDS
					,RightFIELDobjectID int NULL -- relativo alla tabella RULES_FIELDS
					,RightValue varchar(128) NULL -- in ALTERNATIVA al RightFIELDobjectID (invece che il costrutto ON FIELD1=FIELD2 si utilizzerà ON FIELD1=VALUE)
				)

SELECT * FROM RULES_TABLES
SELECT dbo.fnGetFieldColumnID('ID_CONTR','dbo.TAB_CONTR_031CM') AS ColumnID

-- INSERIMENTO REGOLA
INSERT RULES	(RuleName, IDGroup, ExtendedDescription) 
VALUES			('VariazioneInTolleranzaRispettoAllaBase',1,'TOLLERANZA DEL 10% A SCENDERE, OVVERO, ESCLUDENDO O INCLUDENDO I VALORI CHE RIENTRANO NELLA PERCENTUALE STABILITA DI UNA DETERMINATA SOGLIA. DATA UNA SOGLIA CONTR_BASE_CALC_BASE = 80 ED UN VALORE PERCENTUALE PARI A 10, SARA'' VERIFICATO SE IL CAMPO DA CONFRONTARE, CONTR_BASE_MOD, SI TROVI NELL''INTERVALLO TRA LA SOGLIA-10% E LA SOGLIA STESSA; SE IL CAMPO VALE 80 LA FORMULA APPLICATA SARA'' 80-(80*10/100)=72 QUINDI IL CAMPO DA CONFRONTARE DOVRA'' TROVARSI TRA 72 E 80 AFFINCHE'' IL RISULTATO DELLA FUNZIONE SIA 1. SE L''ULTIMO PARAMETRO DELLA FUNZIONE dbo.fnIsInRange (@allowOverRange) VIENE VALORIZZATO AD 1, IL RISULTATO DELLA FUNZIONE SARA'' 1 ANCHE QUALORA IL CAMPO DA CONFRONTARE SUPERI LA SOGLIA (QUINDI UN VALORE > 80)')

-- INSERIMENTO TABELLA CONTRIBUTI BASE
INSERT	RULES_TABLES(IDRule, ObjectID, ALIAS, ExtendedDescription) 
SELECT	dbo.fnGetRuleID('VariazioneInTolleranzaRispettoAllaBase') AS IDRule
		,dbo.fnGetObjectID('dbo.TAB_CONTR_031CM') AS ObjectID
		,'TabellaContributiBASE' AS ALIAS
		,'Tabella dei contributi di base' AS ExtendedDescription

-- INSERIMENTO TABELLA CONTRIBUTI VARIAZIONI
INSERT	RULES_TABLES(IDRule, ObjectID, ALIAS, ExtendedDescription) 
SELECT	dbo.fnGetRuleID('VariazioneInTolleranzaRispettoAllaBase') AS IDRule
		,dbo.fnGetObjectID('var.TAB_CONTR_031CM') AS ObjectID
		,'TabellaContributiVARIAZIONE' AS ALIAS
		,'Tabella dei contributi in variazione' AS ExtendedDescription

-- INSERIMENTO TABELLA DENUNCE BASE
INSERT	RULES_TABLES(IDRule, ObjectID, ALIAS, ExtendedDescription) 
SELECT	dbo.fnGetRuleID('VariazioneInTolleranzaRispettoAllaBase') AS IDRule
		,dbo.fnGetObjectID('dbo.TAB_DEN_031CM') AS ObjectID
		,'TabellaDenunceBASE' AS ALIAS
		,'Tabella delle denunce BASE dei contributi' AS ExtendedDescription

-- INSERIMENTO TABELLA DENUNCE VARIAZIONI
INSERT	RULES_TABLES(IDRule, ObjectID, ALIAS, ExtendedDescription) 
SELECT	dbo.fnGetRuleID('VariazioneInTolleranzaRispettoAllaBase') AS IDRule
		,dbo.fnGetObjectID('var.TAB_DEN_031CM') AS ObjectID
		,'TabellaDenunceVARIAZIONE' AS ALIAS
		,'Tabella delle denunce in VARIAZIONE dei contributi' AS ExtendedDescription

----------------------------------------------------------------------------
-- INSERIMENTO DEI CAMPI CHE DOVRANNO ESSERE MOSTRATI 
-- E/O UTILIZZATI PER LE JOIN/WHERECONDITIONS DELLA TABELLA CONTRIBUTI BASE
----------------------------------------------------------------------------

-- CAMPI DELLA TABELLA "dbo.TAB_CONTR_031CM" (TABELLA CONTRIBUTI BASE)
----------------------------------------------------------------------
INSERT	RULES_FIELDS(IDruleTAB, ColumnID, ALIAS, ExtendedDescription, UseFlag)
SELECT	dbo.fnGetRuleTabObjectID('dbo.TAB_CONTR_031CM',NULL) AS IDruleTAB -- oppure, cercando l'oggetto per ALIAS: dbo.fnGetRuleTabObjectID(NULL,'TabellaContributiBASE')
		,dbo.fnGetFieldColumnID('ID_CONTR','dbo.TAB_CONTR_031CM') AS ColumnID
		,'IdentificativoContributoBASE' AS ALIAS
		,'Identificativo numerico (univoco) del contributo' AS ExtendedDescription
		,2 AS UseFlag -- utilizza questo campo solo per JOIN/WHERE

INSERT	RULES_FIELDS(IDruleTAB, ColumnID, ALIAS, ExtendedDescription)
SELECT	dbo.fnGetRuleTabObjectID('dbo.TAB_CONTR_031CM',NULL) AS IDruleTAB -- oppure, cercando l'oggetto per ALIAS: dbo.fnGetRuleTabObjectID(NULL,'TabellaContributiBASE')
		,dbo.fnGetFieldColumnID('DT_MESE_CONTR','dbo.TAB_CONTR_031CM') AS ColumnID
		,'DataMeseContributoBASE' AS ALIAS
		,'Periodo nel quale è stato effettuato il versamento del contributo' AS ExtendedDescription

INSERT	RULES_FIELDS(IDruleTAB, ColumnID, ALIAS, ExtendedDescription, UseFlag)
SELECT	dbo.fnGetRuleTabObjectID('dbo.TAB_CONTR_031CM',NULL) AS IDruleTAB -- oppure, cercando l'oggetto per ALIAS: dbo.fnGetRuleTabObjectID(NULL,'TabellaContributiBASE')
		,dbo.fnGetFieldColumnID('ID_DEN031CM','dbo.TAB_CONTR_031CM') AS ColumnID
		,'IdentificativoDenunciaContributoBASE' AS ALIAS
		,'Identificativo numerico (univoco) della denuncia di versamento dei contributi' AS ExtendedDescription
		,2 AS UseFlag -- utilizza questo campo solo per JOIN/WHERE

INSERT	RULES_FIELDS(IDruleTAB, ColumnID, ALIAS, ExtendedDescription, UseFlag)
SELECT	dbo.fnGetRuleTabObjectID('dbo.TAB_CONTR_031CM',NULL) AS IDruleTAB -- oppure, cercando l'oggetto per ALIAS: dbo.fnGetRuleTabObjectID(NULL,'TabellaContributiBASE')
		,dbo.fnGetFieldColumnID('COD_RETR','dbo.TAB_CONTR_031CM') AS ColumnID
		,'CodiceTipoRetribuzioneBASE' AS ALIAS
		,'Codice alfanumerico identificativo del tipo di retribuzione (TR, RN, etc.)' AS ExtendedDescription
		,2 AS UseFlag -- utilizza questo campo solo per JOIN/WHERE

INSERT	RULES_FIELDS(IDruleTAB, ColumnID, ALIAS, ExtendedDescription)
SELECT	dbo.fnGetRuleTabObjectID('dbo.TAB_CONTR_031CM',NULL) AS IDruleTAB -- oppure, cercando l'oggetto per ALIAS: dbo.fnGetRuleTabObjectID(NULL,'TabellaContributiBASE')
		,dbo.fnGetFieldColumnID('IMP_RETR_COMPL','dbo.TAB_CONTR_031CM') AS ColumnID
		,'ImportoRetribuzioneComplessivoBASE' AS ALIAS
		,'Importo complessivo della retribuzione' AS ExtendedDescription

INSERT	RULES_FIELDS(IDruleTAB, ColumnID, ALIAS, ExtendedDescription)
SELECT	dbo.fnGetRuleTabObjectID('dbo.TAB_CONTR_031CM',NULL) AS IDruleTAB -- oppure, cercando l'oggetto per ALIAS: dbo.fnGetRuleTabObjectID(NULL,'TabellaContributiBASE')
		,dbo.fnGetFieldColumnID('CF_LAVORATORE','dbo.TAB_CONTR_031CM') AS ColumnID
		,'CodiceFiscaleLavoratoreBASE' AS ALIAS
		,'Codice Fiscale del lavoratore (a 16 caratteri)' AS ExtendedDescription

INSERT	RULES_FIELDS(IDruleTAB, ColumnID, ALIAS, ExtendedDescription)
SELECT	dbo.fnGetRuleTabObjectID('dbo.TAB_CONTR_031CM',NULL) AS IDruleTAB -- oppure, cercando l'oggetto per ALIAS: dbo.fnGetRuleTabObjectID(NULL,'TabellaContributiBASE')
		,dbo.fnGetFieldColumnID('NUM_MTR_LAV','dbo.TAB_CONTR_031CM') AS ColumnID
		,'NumeroMatricolaLavoratoreBASE' AS ALIAS
		,'Numero univoco di matricola del lavoratore' AS ExtendedDescription

-- CAMPI DELLA TABELLA "var.TAB_CONTR_031CM" (TABELLA CONTRIBUTI VARIAZIONI)
----------------------------------------------------------------------
INSERT	RULES_FIELDS(IDruleTAB, ColumnID, ALIAS, ExtendedDescription, UseFlag)
SELECT	dbo.fnGetRuleTabObjectID('var.TAB_CONTR_031CM',NULL) AS IDruleTAB -- oppure, cercando l'oggetto per ALIAS: dbo.fnGetRuleTabObjectID(NULL,'TabellaContributiVARIAZIONE')
		,dbo.fnGetFieldColumnID('ID_CONTR','var.TAB_CONTR_031CM') AS ColumnID
		,'IdentificativoContributoVAR' AS ALIAS
		,'Identificativo numerico (univoco) del contributo' AS ExtendedDescription
		,2 AS UseFlag -- utilizza questo campo solo per JOIN/WHERE

INSERT	RULES_FIELDS(IDruleTAB, ColumnID, ALIAS, ExtendedDescription)
SELECT	dbo.fnGetRuleTabObjectID('var.TAB_CONTR_031CM',NULL) AS IDruleTAB -- oppure, cercando l'oggetto per ALIAS: dbo.fnGetRuleTabObjectID(NULL,'TabellaContributiVARIAZIONE')
		,dbo.fnGetFieldColumnID('DT_MESE_CONTR','var.TAB_CONTR_031CM') AS ColumnID
		,'DataMeseContributoVAR' AS ALIAS
		,'Periodo nel quale è stato effettuato il versamento del contributo' AS ExtendedDescription

INSERT	RULES_FIELDS(IDruleTAB, ColumnID, ALIAS, ExtendedDescription, UseFlag)
SELECT	dbo.fnGetRuleTabObjectID('var.TAB_CONTR_031CM',NULL) AS IDruleTAB -- oppure, cercando l'oggetto per ALIAS: dbo.fnGetRuleTabObjectID(NULL,'TabellaContributiVARIAZIONE')
		,dbo.fnGetFieldColumnID('ID_DEN031CM','var.TAB_CONTR_031CM') AS ColumnID
		,'IdentificativoDenunciaContributoVAR' AS ALIAS
		,'Identificativo numerico (univoco) della denuncia di versamento dei contributi' AS ExtendedDescription
		,2 -- utilizza questo campo solo per JOIN/WHERE

INSERT	RULES_FIELDS(IDruleTAB, ColumnID, ALIAS, ExtendedDescription, UseFlag)
SELECT	dbo.fnGetRuleTabObjectID('var.TAB_CONTR_031CM',NULL) AS IDruleTAB -- oppure, cercando l'oggetto per ALIAS: dbo.fnGetRuleTabObjectID(NULL,'TabellaContributiVARIAZIONE')
		,dbo.fnGetFieldColumnID('COD_RETR','var.TAB_CONTR_031CM') AS ColumnID
		,'CodiceTipoRetribuzioneVAR' AS ALIAS
		,'Codice alfanumerico identificativo del tipo di retribuzione (TR, RN, etc.)' AS ExtendedDescription
		,2 AS UseFlag -- utilizza questo campo solo per JOIN/WHERE

INSERT	RULES_FIELDS(IDruleTAB, ColumnID, ALIAS, ExtendedDescription)
SELECT	dbo.fnGetRuleTabObjectID('var.TAB_CONTR_031CM',NULL) AS IDruleTAB -- oppure, cercando l'oggetto per ALIAS: dbo.fnGetRuleTabObjectID(NULL,'TabellaContributiVARIAZIONE')
		,dbo.fnGetFieldColumnID('IMP_RETR_COMPL','var.TAB_CONTR_031CM') AS ColumnID
		,'ImportoRetribuzioneComplessivoVAR' AS ALIAS
		,'Importo complessivo della retribuzione' AS ExtendedDescription

INSERT	RULES_FIELDS(IDruleTAB, ColumnID, ALIAS, ExtendedDescription)
SELECT	dbo.fnGetRuleTabObjectID('var.TAB_CONTR_031CM',NULL) AS IDruleTAB -- oppure, cercando l'oggetto per ALIAS: dbo.fnGetRuleTabObjectID(NULL,'TabellaContributiVARIAZIONE')
		,dbo.fnGetFieldColumnID('CF_LAVORATORE','var.TAB_CONTR_031CM') AS ColumnID
		,'CodiceFiscaleLavoratoreVAR' AS ALIAS
		,'Codice Fiscale del lavoratore (a 16 caratteri)' AS ExtendedDescription

INSERT	RULES_FIELDS(IDruleTAB, ColumnID, ALIAS, ExtendedDescription)
SELECT	dbo.fnGetRuleTabObjectID('var.TAB_CONTR_031CM',NULL) AS IDruleTAB -- oppure, cercando l'oggetto per ALIAS: dbo.fnGetRuleTabObjectID(NULL,'TabellaContributiVARIAZIONE')
		,dbo.fnGetFieldColumnID('NUM_MTR_LAV','var.TAB_CONTR_031CM') AS ColumnID
		,'NumeroMatricolaLavoratoreVAR' AS ALIAS
		,'Numero univoco di matricola del lavoratore' AS ExtendedDescription

-- CAMPI DELLA TABELLA "dbo.TAB_DEN_031CM" (TABELLA DENUNCE BASE)
----------------------------------------------------------------------
INSERT	RULES_FIELDS(IDruleTAB, ColumnID, ALIAS, ExtendedDescription)
SELECT	dbo.fnGetRuleTabObjectID('dbo.TAB_DEN_031CM',NULL) AS IDruleTAB -- oppure, cercando l'oggetto per ALIAS: dbo.fnGetRuleTabObjectID(NULL,'TabellaContributiBASE')
		,dbo.fnGetFieldColumnID('CF_AZIENDA','dbo.TAB_DEN_031CM') AS ColumnID
		,'CodiceFiscaleLavoratoreBASE' AS ALIAS
		,'Codice Fiscale del lavoratore (a 16 caratteri)' AS ExtendedDescription

INSERT	RULES_FIELDS(IDruleTAB, ColumnID, ALIAS, ExtendedDescription, UseFlag)
SELECT	dbo.fnGetRuleTabObjectID('dbo.TAB_DEN_031CM',NULL) AS IDruleTAB -- oppure, cercando l'oggetto per ALIAS: dbo.fnGetRuleTabObjectID(NULL,'TabellaDenunceBASE')
		,dbo.fnGetFieldColumnID('ID_DEN031CM','dbo.TAB_DEN_031CM') AS ColumnID
		,'IdentificativoDenunciaContributoBASEPK' AS ALIAS
		,'Identificativo numerico (univoco) della denuncia di versamento dei contributi (chiave primaria)' AS ExtendedDescription
		,2 -- utilizza questo campo solo per JOIN/WHERE

-- CAMPI DELLA TABELLA "var.TAB_DEN_031CM" (TABELLA DENUNCE VARIAZIONI)
----------------------------------------------------------------------
INSERT	RULES_FIELDS(IDruleTAB, ColumnID, ALIAS, ExtendedDescription, UseFlag)
SELECT	dbo.fnGetRuleTabObjectID('var.TAB_DEN_031CM',NULL) AS IDruleTAB -- oppure, cercando l'oggetto per ALIAS: dbo.fnGetRuleTabObjectID(NULL,'TabellaContributiBASE')
		,dbo.fnGetFieldColumnID('ID_DEN031CM','var.TAB_DEN_031CM') AS ColumnID
		,'IdentificativoDenunciaContributoVARPK' AS ALIAS
		,'Identificativo numerico (univoco) della denuncia di versamento dei contributi (chiave primaria)' AS ExtendedDescription
		,2 -- utilizza questo campo solo per JOIN/WHERE

INSERT	RULES_FIELDS(IDruleTAB, ColumnID, ALIAS, ExtendedDescription)
SELECT	dbo.fnGetRuleTabObjectID('var.TAB_DEN_031CM',NULL) AS IDruleTAB -- oppure, cercando l'oggetto per ALIAS: dbo.fnGetRuleTabObjectID(NULL,'TabellaContributiBASE')
		,dbo.fnGetFieldColumnID('CF_AZIENDA','var.TAB_DEN_031CM') AS ColumnID
		,'CodiceFiscaleAziendaVAR' AS ALIAS
		,'Codice Fiscale dell''Azienda che effettua la denuncia di versamento dei contributi' AS ExtendedDescription

*/
