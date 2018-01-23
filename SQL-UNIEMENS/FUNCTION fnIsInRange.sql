/*
SELECT dbo.fnIsInRange(73.00, 80.00, 10, NULL) AS IsInRange -- RITORNA 1 POICHE' 73 SI TROVA NELL'INTERVALLO DEL 10% AL DI SOTTO DELLA SOGLIA (80-10%=8, 80-8=72, 73>72 & <80)
SELECT dbo.fnIsInRange(71.00, 80.00, 10, NULL) AS IsInRange -- RITORNA 0 POICHE' 71 NON SI TROVA NELL'INTERVALLO DEL 10% AL DI SOTTO DELLA SOGLIA (80-10%=8, 80-8=72, 71<72 & <80)
SELECT dbo.fnIsInRange(81.00, 80.00, 10, NULL) AS IsInRange -- RITORNA 0 POICHE' 81 NON SI TROVA NELL'INTERVALLO DEL 10% AL DI SOTTO DELLA SOGLIA, BENSI' è MAGGIORE (80-10%=8, 80-8=72, 81>72 & >80) E IL PARAMETRO @allowOverRange è nullo o zero
SELECT dbo.fnIsInRange(81.00, 80.00, 10, 1) AS IsInRange -- RITORNA 1 POICHE' 81, BENCHE' NON SI TROVI NELL'INTERVALLO DEL 10% AL DI SOTTO DELLA SOGLIA (80-10%=8, 80-8=72, 81>72 & >80) IL PARAMETRO @allowOverRange E' STATO IMPOSTATO A 1 QUINDI CONSENTE IL SUPERAMENTO DELLA SOGLIA IN SALITA
-----------------------------------------------------------
-- ESEMPIO DI FILTRO CON TOLLERANZA DEL 10% A SCENDERE
-- OVVERO, ESCLUDENDO O INCLUDENDO I VALORI CHE RIENTRANO
-- NELLA PERCENTUALE STABILITA DI UNA DETERMINATA SOGLIA.
-- DATA UNA SOGLIA CONTR_BASE_CALC_BASE = 80 ED UN VALORE
-- PERCENTUALE PARI A 10, SARA' VERIFICATO SE IL CAMPO
-- DA CONFRONTARE, CONTR_BASE_MOD, SI TROVI NELL'INTERVALLO
-- TRA LA SOGLIA-10% E LA SOGLIA STESSA; SE IL CAMPO VALE 80
-- LA FORMULA APPLICATA SARA' 80-(80*10/100)=72
-- QUINDI IL CAMPO DA CONFRONTARE DOVRA' TROVARSI TRA
-- 72 E 80 AFFINCHE' IL RISULTATO DELLA FUNZIONE SIA 1
-- SE L'ULTIMO PARAMETRO DELLA FUNZIONE dbo.fnIsInRange 
-- (@allowOverRange) VIENE VALORIZZATO AD 1, IL RISULTATO
-- DELLA FUNZIONE SARA' 1 ANCHE QUALORA IL CAMPO DA
-- CONFRONTARE SUPERI LA SOGLIA (QUINDI UN VALORE > 80)
-----------------------------------------------------------
DECLARE	@perc smallint = 10

-- in tolleranza (esclusi i valori che superano la soglia)
SELECT
		'In tolleranza (esclusi i valori che superano la soglia)' AS Analisi
		,CONTR_BASE_CALC_BASE
		,CONTR_BASE_MOD AS CONTR_BASE_MOD_VAR
		,* 
FROM	VTAB_CONTR_031CM_BASEVAR
WHERE	COD_RETR_BASE = 'RN'
AND		dbo.fnIsInRange(CONTR_BASE_MOD, CONTR_BASE_CALC_BASE, @perc, 0) = 1

-- in tolleranza (compresi i valori che superano la soglia)
SELECT	
		'In tolleranza (compresi i valori che superano la soglia)' AS Analisi
		,CONTR_BASE_CALC_BASE
		,CONTR_BASE_MOD AS CONTR_BASE_MOD_VAR
		,* 
FROM	VTAB_CONTR_031CM_BASEVAR
WHERE	COD_RETR_BASE = 'RN'
AND		dbo.fnIsInRange(CONTR_BASE_MOD, CONTR_BASE_CALC_BASE, @perc, 1) = 1

-- fuori tolleranza (esclusi i valori che superano la soglia)
SELECT	
		'Fuori tolleranza (esclusi i valori che superano la soglia)' AS Analisi
		,CONTR_BASE_CALC_BASE
		,CONTR_BASE_MOD AS CONTR_BASE_MOD_VAR
		,CAST(CONTR_BASE_CALC_BASE * @perc / 100 AS decimal(13,2)) AS MASSIMA_VARIAZIONE_AMMESSA
		,CONTR_BASE_CALC_BASE - CONTR_BASE_MOD AS VARIAZIONE_RILEVATA
		,((CONTR_BASE_CALC_BASE - CONTR_BASE_MOD) - CAST(CONTR_BASE_CALC_BASE * @perc / 100 AS decimal(13,2))) AS SFORAMENTO
		,* 
FROM	VTAB_CONTR_031CM_BASEVAR
WHERE	COD_RETR_BASE = 'RN'
AND		dbo.fnIsInRange(CONTR_BASE_MOD, CONTR_BASE_CALC_BASE, @perc, 0) = 0

-- fuori tolleranza (compresi i valori che superano la soglia)
SELECT	
		'Fuori tolleranza (compresi i valori che superano la soglia)' AS Analisi
		,CONTR_BASE_CALC_BASE
		,CONTR_BASE_MOD AS CONTR_BASE_MOD_VAR
		,CAST(CONTR_BASE_CALC_BASE * @perc / 100 AS decimal(13,2)) AS MASSIMA_VARIAZIONE_AMMESSA
		,CONTR_BASE_CALC_BASE - CONTR_BASE_MOD AS VARIAZIONE_RILEVATA
		,((CONTR_BASE_CALC_BASE - CONTR_BASE_MOD) - CAST(CONTR_BASE_CALC_BASE * @perc / 100 AS decimal(13,2))) AS SFORAMENTO
		,* 
FROM	VTAB_CONTR_031CM_BASEVAR
WHERE	COD_RETR_BASE = 'RN'
AND		dbo.fnIsInRange(CONTR_BASE_MOD, CONTR_BASE_CALC_BASE, @perc, 1) = 0
-----------------------------------------------------------
*/
ALTER FUNCTION	dbo.fnIsInRange(@valueToCheck decimal(18,2)=NULL, @threshold decimal(18,2)=NULL, @perc smallint=NULL, @allowOverRange bit=NULL)
RETURNS BIT
AS
BEGIN
	DECLARE @RETVAL BIT = 0

	IF ISNULL(@valueToCheck,0.00) != 0.00
	AND ISNULL(@threshold,0.00) != 0.00
	AND ISNULL(@perc,0) != 0
		BEGIN
			IF ISNULL(@allowOverRange,0) != 0
				BEGIN
					SELECT	@RETVAL =
							CASE
								WHEN
								(
									@valueToCheck 
									BETWEEN 
										@threshold - (@threshold * @perc / 100)
									AND 
										@threshold
								)
								OR @valueToCheck >= @threshold
								THEN 1
								ELSE 0
							END
				END
			ELSE
				BEGIN
					SELECT	@RETVAL =
							CASE
								WHEN
								(
									@valueToCheck 
									BETWEEN 
										@threshold - (@threshold * @perc / 100)
									AND 
										@threshold
								)
								THEN 1
								ELSE 0
							END
				END
		END
	RETURN @RETVAL
END