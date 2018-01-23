/*
SELECT * FROM VRULES_FIELDS ORDER BY FullFieldName
SELECT * FROM VRULES_FIELDS WHERE FullFieldName LIKE 'dbo.%' ORDER BY FullFieldName
SELECT * FROM VRULES_FIELDS WHERE FullFieldName LIKE 'var.%' ORDER BY FullFieldName

SELECT * FROM VRULES_FIELDS WHERE FullFieldName LIKE 'dbo.%' AND ParentTable LIKE '%_CONTR_%' ORDER BY FullFieldName
SELECT * FROM VRULES_FIELDS WHERE FullFieldName LIKE 'var.%' AND ParentTable LIKE '%_CONTR_%' ORDER BY FullFieldName

SELECT * FROM VRULES_FIELDS WHERE FullFieldName LIKE 'dbo.%' AND ParentTable LIKE '%_DEN_%' ORDER BY FullFieldName
SELECT * FROM VRULES_FIELDS WHERE FullFieldName LIKE 'var.%' AND ParentTable LIKE '%_DEN_%' ORDER BY FullFieldName
*/
ALTER VIEW	[dbo].[VRULES_FIELDS]
AS
SELECT
		IDruleFIELD
		,V.ObjectName AS ParentTable
		,V.FieldName
		,V.FullFieldName
		,ALIAS
		,ExtendedDescription
		,UseFlag
		,IDruleTAB AS ParentID
		,R.ColumnID
FROM	RULES_FIELDS R WITH(NOLOCK)
		INNER JOIN
		VTablesSchemasColumns V
		ON R.IDRuleTAB = V.ObjectID
		AND R.ColumnID = V.ColumnID

