/*
---------------------------
dbo.GetStructure
---------------------------

Function which analises the passed hierarchical structure and returns the contained fields and their datatypes and maxlengths

-- SAMPLE USAGE
-----------------
DECLARE 
		@Hierarchy Hierarchy
		,@CSV nvarchar(MAX)
SET @CSV =
'Year,Make,Model,Description,Price
1997,Ford,E350,"ac, abs, moon",3000.00
1999,Chevy,"Venture ""Extended Edition""","",4900.00
1999,Chevy,"Venture ""Extended Edition, Very Large""","",5000.00
1996,Jeep,Grand Cherokee,"MUST SELL! air, moon roof, loaded",4799.00'

INSERT	@Hierarchy
SELECT	* 
FROM	dbo.ParseCSV(@CSV, Default, Default, Default)

SELECT	*
FROM	dbo.GetStructure(@Hierarchy)
*/
ALTER FUNCTION dbo.GetStructure(@Hierarchy Hierarchy READONLY)
RETURNS @structure TABLE
		(
			FieldName varchar(128)
			,FieldType varchar(128)
			,FieldTypeSQL varchar(128)
			,MaxLen int
			,FullField varchar(128)
		)
AS
BEGIN
	INSERT	@structure
			(
				FieldName
				,FieldType
				,FieldTypeSQL
				,MaxLen
				,FullField
			)
	SELECT
			FieldName
			,MAX(FieldType)
			,MAX(FieldTypeSQL)
			,MAX(MaxLen)
			,FieldName = MAX(FieldName) +
			CASE MAX(FieldType)
				WHEN 'String'
				THEN ' ' + MAX(FieldTypeSQL) + ' (' + CAST(MAX(MaxLen) AS VARCHAR(8)) + ')'
				ELSE ' ' + MAX(FieldTypeSQL)
			END
	FROM
	(
		SELECT	DISTINCT
				[NAME] AS FieldName
				,ValueType AS FieldType
				,FieldTypeSQL =
				CASE ValueType
					WHEN 'String'
					THEN 'nvarchar'
					ELSE ValueType
				END
				,MaxLen =
				CASE ValueType
					WHEN 'String'
					THEN MAX(LEN(StringValue)) OVER(PARTITION BY [NAME], ValueType, StringValue)
					WHEN 'int'
					THEN 4
					WHEN 'real'
					THEN 4
					ELSE 0
				END
				,FullField = [NAME] + ' ' +
				CASE ValueType
					WHEN 'String'
					THEN 'nvarchar(' + CAST(MAX(LEN(StringValue)) OVER(PARTITION BY [NAME], ValueType, StringValue) AS VARCHAR(8)) + ')'
					WHEN 'int'
					THEN 'int'
					WHEN 'real'
					THEN 'real'
					ELSE ''
				END
		FROM	@Hierarchy
		WHERE	ValueType NOT IN('object','array')
	) FIELDS
	GROUP BY FieldName

	RETURN
END