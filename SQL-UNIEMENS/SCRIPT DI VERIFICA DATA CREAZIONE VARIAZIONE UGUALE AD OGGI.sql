SELECT	*
FROM	var.TAB_CONTR_031CM
WHERE	YEAR(DATA_CRE) = YEAR(GETDATE())
AND		MONTH(DATA_CRE) = MONTH(GETDATE())
AND		DAY(DATA_CRE) = DAY(GETDATE())
ORDER BY DATA_CRE DESC

