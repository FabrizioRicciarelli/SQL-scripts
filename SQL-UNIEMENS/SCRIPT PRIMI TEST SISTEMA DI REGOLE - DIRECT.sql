/*
FUNZIONE PREPOSTA ALL'ESTRAZIONE DEI CONTRIBUTI DETERMINANDO, SULLA BASE DEI DATI CONTENUTI NELLA COLONNA XML, 
L'INTERVALLO DEI VALORI RIENTRANTI NEL RANGE DI TOLLERANZA STABILITO DAL VALORE PERCENTUALE PASSATO NEL 
PARAMETRO @percentualeTolleranza
LA PRESENTE FUNZIONE SI AVVALE DI UNA TABELLA DELLE REGOLE, XQUERY_RULES, CONTENENTE I CRITERI DA 
UTILIZZARE PER FILTRARE IL SET DEI RISULTATI; TALI CRITERI POSSONO PREVEDERE, AD ESEMPIO, IL CONFRONTO TRA
UNO O PIU' NODI XML, ANCHE ANNIDATI, E/O CONFRONTI TRA NODI XML E VALORI DI COLONNE DI ALTRE TABELLE

ESEMPI DI INVOCAZIONE:

-- TUTTE LE AZIENDE, TUTTI I LORO DIPENDENTI, QUALUNQUE PERIODO, 
-- IL CUI CONTRIBUTO SIA INFERIORE O UGUALE AL 10% RISPETTO A QUELLO BASE
SELECT * FROM dbo.fnGetContributiInTolerance(NULL, NULL, NULL, 10) WHERE IsInTolerance = 1 ORDER BY CFAZIENDA, CFLAVORATORE, PERIODOCOMPETENZA
SELECT * FROM dbo.fnGetContributiInTolerance(NULL, NULL, NULL, 10) WHERE IsInTolerance = 0

-- TUTTE LE AZIENDE, TUTTI I LORO DIPENDENTI, QUALUNQUE PERIODO, 
-- IL CUI CONTRIBUTO SIA INFERIORE O UGUALE AL 10% RISPETTO A QUELLO BASE MA NON SIA IDENTICO
SELECT * FROM dbo.fnGetContributiInTolerance(NULL, NULL, NULL, 10) WHERE IsInTolerance = 1 AND isIdentical = 0 ORDER BY CFAZIENDA, CFLAVORATORE, PERIODOCOMPETENZA
SELECT * FROM dbo.fnGetContributiInTolerance(NULL, NULL, NULL, 10) WHERE IsInTolerance = 0

-- SOLO L'AZIENDA IL CUI CF E' UGUALE A 00937610152, TUTTI I SUOI DIPENDENTI, QUALUNQUE PERIODO, 
-- IL CUI CONTRIBUTO SIA INFERIORE O UGUALE AL 10% RISPETTO A QUELLO BASE
SELECT * FROM dbo.fnGetContributiInTolerance('00937610152', NULL, NULL, 10) WHERE IsInTolerance = 1 ORDER BY CFLAVORATORE, PERIODOCOMPETENZA
SELECT * FROM dbo.fnGetContributiInTolerance('00937610152', NULL, NULL, 10) WHERE IsInTolerance = 0

-- SOLO L'AZIENDA IL CUI CF E' UGUALE A 00937610152, PER IL SOLO DIPENDENTE IL CUI CF E' UGUALE A BCCGRG69M09L219Y, QUALUNQUE PERIODO, 
-- IL CUI CONTRIBUTO SIA INFERIORE O UGUALE AL 10% RISPETTO A QUELLO BASE
SELECT * FROM dbo.fnGetContributiInTolerance('00937610152', 'BCCGRG69M09L219Y', NULL, 10) WHERE IsInTolerance = 1 ORDER BY PERIODOCOMPETENZA
SELECT * FROM dbo.fnGetContributiInTolerance('00937610152', 'BCCGRG69M09L219Y', NULL, 10) WHERE IsInTolerance = 0

-- TUTTE LE AZIENDE, TUTTI I LORO DIPENDENTI, NEL PERIODO UGUALE A 1/GEN/2014, 
-- IL CUI CONTRIBUTO SIA INFERIORE O UGUALE AL 10% RISPETTO A QUELLO BASE
SELECT * FROM dbo.fnGetContributiInTolerance(NULL, NULL, '2014-01-01', 10) WHERE IsInTolerance = 1 ORDER BY CFAZIENDA, CFLAVORATORE
SELECT * FROM dbo.fnGetContributiInTolerance(NULL, NULL, '2014-01-01', 10) WHERE IsInTolerance = 0

-- SOLO L'AZIENDA IL CUI CF E' UGUALE A 01504490994, TUTTI I SUOI DIPENDENTI, NEL PERIODO UGUALE A 1/GEN/2014, 
-- IL CUI CONTRIBUTO SIA INFERIORE O UGUALE AL 10% RISPETTO A QUELLO BASE
SELECT * FROM dbo.fnGetContributiInTolerance('01504490994', NULL, '2014-01-01', 10) WHERE IsInTolerance = 1 ORDER BY CFLAVORATORE
SELECT * FROM dbo.fnGetContributiInTolerance('01504490994', NULL, '2014-01-01', 10) WHERE IsInTolerance = 0

*/
ALTER FUNCTION dbo.fnGetContributiInTolerance
				(
					@CFAzienda varchar(16) = NULL
					,@CFLavoratore varchar(16) = NULL
					,@PeriodoCompetenza varchar(10) = NULL
					,@percentualeTolleranza smallint = NULL
				)
RETURNS @CONTRIBUTI TABLE
		(
			CFAzienda varchar(16)
			,CFLavoratore varchar(16)
			,PeriodoCompetenza varchar(10)
			,ContributoNormaleBASE decimal(18,2)
			,ContributoNormaleRN decimal(18,2)
			,ImportoRetribuzioneBASE decimal(18,2)
			,ImportoRetribuzioneRN decimal(18,2)
			,isInTolerance bit
			,isIdentical bit
		)
AS
BEGIN
	IF ISNULL(@percentualeTolleranza,0) > 0
		BEGIN
			INSERT	@CONTRIBUTI
					(
						CFAzienda
						,CFLavoratore
						,PeriodoCompetenza
						,ImportoRetribuzioneBASE
						,ContributoNormaleBASE
						,ContributoNormaleRN
						,ImportoRetribuzioneRN
						,isInTolerance
						,isIdentical
					)
			SELECT	DISTINCT
					M.AP_KEYD_CFAZIENDA AS CFAzienda
					,M.AP_KEYD_CFLAVORATOREISCRITTO AS CFLavoratore
					,M.AP_KEYD_COMPETENZA AS PeriodoCompetenza
					,C.CONTR_BASE_MOD AS ContributoNormaleBASE
					,C.IMP_RETR_COMPL AS ImportoRetribuzioneBASE
					,CAST(M.AP_KEYD_SQLCOMMAND_ENPALS.value('(//*[local-name()=sql:column("X.NodeNameA")][//*[local-name()=sql:column("X.NodeNameB")] = sql:column("X.MatchValueAB")])[1]','varchar(max)') AS decimal(18,2))/100 AS ImportoRetribuzioneRN -- Valore dell'ImportoRetribuzione (laddove il CodiceRetribuzione = 'RN')
					,CAST(M.AP_KEYD_SQLCOMMAND_ENPALS.value('(//*[local-name()=sql:column("X.NodeNameC")][//*[local-name()=sql:column("X.NodeNameD")] = sql:column("X.MatchValueCD")])[1]','varchar(max)') AS decimal(18,2))/100 AS ContributoNormaleRN -- Valore del Contributo/Normale (laddove il CodiceRetribuzione = 'RN')
					--,CAST(M.AP_KEYD_SQLCOMMAND_ENPALS.value('(//ImportoRetribuzione[../CodiceRetribuzione = ''RN''])[1]','varchar(max)') AS decimal(18,2)) AS ImportoRetribuzioneRN
					--,CAST(M.AP_KEYD_SQLCOMMAND_ENPALS.value('(//Normale[../../CodiceRetribuzione = ''RN''])[1]','varchar(max)') AS decimal(18,2)) AS ContributoNormaleRN
					,isInTolerance = 
					CASE
						WHEN 
						(
							CAST(M.AP_KEYD_SQLCOMMAND_ENPALS.value('(//*[local-name()=sql:column("X.NodeNameC")][//*[local-name()=sql:column("X.NodeNameD")] = sql:column("X.MatchValueCD")])[1]','varchar(max)') AS decimal(18,2))/100 
							BETWEEN 
								C.CONTR_BASE_MOD - (C.CONTR_BASE_MOD * @percentualeTolleranza / 100)
								AND 
								C.CONTR_BASE_MOD
						)
						THEN 1
						ELSE 0
					END
					,isIdentical = 
					CASE
						WHEN 
						(
							CAST(M.AP_KEYD_SQLCOMMAND_ENPALS.value('(//*[local-name()=sql:column("X.NodeNameC")][//*[local-name()=sql:column("X.NodeNameD")] = sql:column("X.MatchValueCD")])[1]','varchar(max)') AS decimal(18,2))/100 = C.CONTR_BASE_MOD -- valore del Contributo/Normale (laddove il CodiceRetribuzione = 'RN') nel nodo XML = ContributoNormale nella BASE
						)
						THEN 1
						ELSE 0
					END
			FROM	TB_KEYD_KEYDENINDIVSS_RC M WITH(NOLOCK)
					INNER JOIN
					dbo.TAB_CONTR_031CM C WITH(NOLOCK) -- BASE *** ATTENZIONE! SOSTITURE IL PREFISSO "var." CON "dbo." APPENA I DATI SARANNO DISPONIBILI ***
					ON M.AP_KEYD_CFLAVORATOREISCRITTO = C.CF_LAVORATORE
					AND M.AP_KEYD_COMPETENZA = C.DT_MESE_CONTR
					INNER JOIN
					XQUERY_RULES X WITH(NOLOCK)
					ON X.IDXQUERY = 1 -- TROVARE UNA CHIAVE DI JOIN TRA LE REGOLE E LE ALTRE DUE TABELLE
			WHERE	(M.AP_KEYD_CFAZIENDA = @CFAzienda OR @CFAzienda IS NULL)
			AND		(M.AP_KEYD_CFLAVORATOREISCRITTO = @CFLavoratore OR @CFLavoratore IS NULL)
			AND		(M.AP_KEYD_COMPETENZA = @PeriodoCompetenza OR @PeriodoCompetenza IS NULL)
			AND		C.COD_RETR = X.MatchValueAB -- 'RN'
			AND		CAST(M.AP_KEYD_SQLCOMMAND_ENPALS.value('(//*[local-name()=sql:column("X.NodeNameA")][//*[local-name()=sql:column("X.NodeNameB")] = sql:column("X.MatchValueAB")])[1]','varchar(max)') AS decimal(18,2))/100 = CAST(C.IMP_RETR_COMPL AS decimal(18,2)) -- ImportoRetribuzione nel nodo XML = ImportoRetribuzione nella BASE 
			AND		ISNULL(CAST(M.AP_KEYD_SQLCOMMAND_ENPALS.value('(//*[local-name()=sql:column("X.NodeNameA")][//*[local-name()=sql:column("X.NodeNameB")] = sql:column("X.MatchValueAB")])[1]','varchar(max)') AS decimal(18,2)),0.00) != 0.00 -- Valore dell'ImportoRetribuzione (laddove il CodiceRetribuzione = 'RN') nel nodo XML DIVERSO da ZERO
			AND		ISNULL(CAST(M.AP_KEYD_SQLCOMMAND_ENPALS.value('(//*[local-name()=sql:column("X.NodeNameC")][//*[local-name()=sql:column("X.NodeNameD")] = sql:column("X.MatchValueCD")])[1]','varchar(max)') AS decimal(18,2)),0.00) != 0.00 -- Valore del Contributo/Normale (laddove il CodiceRetribuzione = 'RN') nel nodo XML DIVERSO da ZERO
		END	

	RETURN
END