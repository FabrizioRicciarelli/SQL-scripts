/*
SELECT * FROM VRULES_TABLES ORDER BY FullObjectName
SELECT * FROM VRULES_TABLES WHERE FullObjectName LIKE 'dbo.%' ORDER BY FullObjectName
SELECT * FROM VRULES_TABLES WHERE FullObjectName LIKE 'var.%' ORDER BY FullObjectName
*/
ALTER VIEW	[dbo].[VRULES_TABLES]
AS
SELECT
		IDruleTAB
		,R.RuleName AS ParentRule
		,V.ObjectName
		,V.FullObjectName
		,ALIAS
		,T.ExtendedDescription
		,R.IDRule AS ParentID
FROM	RULES_TABLES T WITH(NOLOCK)
		INNER JOIN
		RULES R WITH(NOLOCK)
		ON T.IDRule = R.IDRule
		INNER JOIN
		VTablesAndSchemas V
		ON T.ObjectID = V.ObjectID

GO


