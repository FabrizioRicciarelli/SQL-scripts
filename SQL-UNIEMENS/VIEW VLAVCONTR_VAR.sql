/*
SELECT	* FROM VLAVCONTR_VAR
*/
CREATE VIEW	dbo.VLAVCONTR_VAR
AS
SELECT	
		C.ID_CONTR
		--,C.DT_MESE_CONTR
		--,C.ID_DEN031CM
		--,C.NUM_MTR_LAV
		--,C.CF_LAVORATORE
		,C.TIPO_OPE
		,C.COD_AGEV
		,C.IMP_AGEV
		,C.COD_RETR
		,C.MESE_MAX
		,C.NUM_GIORNI
		,C.IMP_RETR_COMPL
		,C.IMP_CONTR_VERS
		,C.IMP_TRATT_PENS
		,C.DATA_INI_PRDO
		,C.IND_EMISS_031R
		,C.DATA_FINE_PRDO
		,C.IMP_CONTR_CALC
		--,C.COD_ALIQ
		--,C.COD_CAT_LAV
		--,C.TIPO_RAPP_LAV
		,C.CONTR_BASE_CALC
		,C.CONTR_AGG_CALC
		,C.CONTR_SOLID_CALC
		,C.CONTR_BASE_MOD
		,C.CONTR_AGG_MOD
		,C.CONTR_SOLID_MOD
		--,C.GG_FASCIA
		--,C.IMP_RETRIB_PREC
		,C.COD_BRANO
		--,C.DATA_CRE
		--,C.DATA_AGG
		--,C.UTE_CRE
		--,C.UTE_AGG

		,L.ID_DEN031CM
		,L.COD_ALIQ
		,L.NUM_MTR_LAV
		,L.TIPO_RAPP_LAV
		,L.COD_CAT_LAV
		,L.DT_MESE_CONTR
		,L.TIPO_OPE_LAV
		,L.IMP_RETRIB_PREC
		,L.GG_FASCIA
		,L.DATA_CRE
		,L.DATA_AGG
		,L.UTE_CRE
		,L.UTE_AGG
		,L.ID_TRASMISSIONE
		,L.CF_LAVORATORE
		,L.COGNOME
		,L.NOME
		--,L.STATODENUNCIAINDIVIDUALE
FROM	var.TAB_CONTR_031CM C WITH(NOLOCK)
		INNER JOIN
		var.TAB_LAV_031CM L WITH(NOLOCK)
		ON C.ID_DEN031CM = L.ID_DEN031CM
		AND C.NUM_MTR_LAV = L.NUM_MTR_LAV

