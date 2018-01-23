DECLARE 
		@CurrentXTTC XML
		,@CSVFieldValuesPairs varchar(MAX) = NULL
		,@CSVWhereConditionPairs varchar(MAX) = NULL
		
		,@NEWsessionID int = 1111
		,@NEWsessionParentID int = 2222
		,@NEWflagCalc bit = 1
		,@NEWlevel int = 99
		
		,@ticketcode varchar(50) = '391378593917118857'

		,@returnXTTC XML = NULL
		,@nodeCount int
		,@fieldName sysname
		,@fieldValue varchar(MAX)
		,@wherefield sysname
		,@wherevalue varchar(MAX)
		,@FIELDS_CUR CURSOR

DECLARE @FieldValues TABLE(fieldName sysname, fieldValue varchar(max))
DECLARE @WhereConditions TABLE(fieldName sysname, fieldValue varchar(max))

SET	@CurrentXTTC = ETL.WriteXTTC(@CurrentXTTC, '391378593917118854', 0, 1234, 1233, 1) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@CurrentXTTC = ETL.WriteXTTC(@CurrentXTTC, '391378593917118855', 1, 12345, 12344, 2) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@CurrentXTTC = ETL.WriteXTTC(@CurrentXTTC, '391378593917118856', 0, 123456, 123455, 3) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@CurrentXTTC = ETL.WriteXTTC(@CurrentXTTC, '391378593917118857', 0, 1234567, 1234566, 4) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE


SET @CSVFieldValuesPairs = 'sessionid=' + CAST(@NEWsessionid as varchar(10)) + ',flagcalc=' + CAST(@NEWflagCalc AS varchar(2)) + ',level=' +  CAST(@NEWlevel AS varchar(2)) + ',sessionparentid=' + CAST(@NEWsessionparentid as varchar(10))
SET @CSVWhereConditionPairs = 'ticketcode=' + @ticketcode

IF @CSVFieldValuesPairs LIKE '%,%'
	BEGIN
		INSERT	@FieldValues
		SELECT	
				dbo.fnLeftPart(Value,'=') AS fieldName
				,dbo.fnRightPart(Value,'=') AS fieldValue
		FROM	STRING_SPLIT(@CSVFieldValuesPairs,',')
	END
ELSE
	BEGIN
		INSERT	@FieldValues(fieldName, fieldValue)
		VALUES (dbo.fnLeftPart(@CSVFieldValuesPairs,'='), dbo.fnRightPart(@CSVFieldValuesPairs,'='))
	END

IF @CSVWhereConditionPairs LIKE '%,%'
	BEGIN
		INSERT	@WhereConditions
		SELECT	
				dbo.fnLeftPart(Value,'=') AS fieldName
				,dbo.fnRightPart(Value,'=') AS fieldValue
		FROM	STRING_SPLIT(@CSVWhereConditionPairs,',')
	END
ELSE
	BEGIN
		INSERT	@WhereConditions(fieldName, fieldValue)
		VALUES (dbo.fnLeftPart(@CSVWhereConditionPairs,'='), dbo.fnRightPart(@CSVWhereConditionPairs,'='))
	END

--SELECT	*
--FROM	@FieldValues

--SELECT	*
--FROM	@WhereConditions

SET @FIELDS_CUR = CURSOR FAST_FORWARD FOR 
SELECT	
		fieldName
		,fieldValue
		,(SELECT TOP 1 fieldName FROM @WhereConditions) AS whereField
		,(SELECT TOP 1 fieldValue FROM @WhereConditions) AS whereValue
FROM	@FieldValues

SET @returnXTTC = @CurrentXTTC

OPEN @FIELDS_CUR;
FETCH NEXT FROM @FIELDS_CUR 
INTO 
		@fieldName
		,@fieldValue
		,@wherefield
		,@wherevalue

WHILE @@FETCH_STATUS = 0
	BEGIN
		--SELECT @nodeCount = @returnXTTC.value('count(//@*[local-name()=sql:variable("@fieldName")])[1]','int')
		--SELECT @fieldName AS fieldName, @fieldvalue as NEWfieldvalue, @nodeCount AS nodecount, @wherefield as wherefield, @wherevalue as wherevalue

		-- SQL UPDATE STATEMENT EQUIVALENT: UPDATE RETURNXTTC SET FIELDNAME = FIELDVALUE WHERE WHEREFIELD = WHEREVALUE
		SET @returnXTTC.modify('replace value of (//@*[local-name()=sql:variable("@fieldname")])[../@*[local-name()=sql:variable("@wherefield")]=sql:variable("@wherevalue")][1] with sql:variable("@fieldvalue")')
		
		FETCH NEXT FROM @FIELDS_CUR 
		INTO 
				@fieldName
				,@fieldValue
				,@wherefield
				,@wherevalue
	END

CLOSE @FIELDS_CUR;
DEALLOCATE @FIELDS_CUR;

--SELECT @returnXTTC -- SHOWS THE XML CONTAINER IN XML SHAPE
SELECT * FROM ETL.GetXTTC(@returnXTTC, NULL, NULL, NULL, NULL, NULL, NULL) -- SHOWS THE XML CONTAINER IN TABULAR SHAPE
