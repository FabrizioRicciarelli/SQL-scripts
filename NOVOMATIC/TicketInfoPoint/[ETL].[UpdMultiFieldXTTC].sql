/*
DECLARE 
		@XTTC XML -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)
		,@NEWsessionID int = 1111
		,@NEWsessionParentID int = 2222
		,@NEWflagCalc bit = 1
		,@NEWlevel int = 99
		
		,@ticketcode varchar(50) = '391378593917118857'

SET	@XTTC = ETL.WriteXTTC(@XTTC, '391378593917118854', 0, 1234, 1233, 1) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XTTC = ETL.WriteXTTC(@XTTC, '391378593917118855', 1, 12345, 12344, 2) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XTTC = ETL.WriteXTTC(@XTTC, '391378593917118856', 0, 123456, 123455, 3) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XTTC = ETL.WriteXTTC(@XTTC, '391378593917118857', 0, 1234567, 1234566, 4) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE

SELECT * FROM ETL.GetXTTC(@XTTC, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI

SET	@XTTC = ETL.UpdMultiFieldXTTC(@XTTC,  'sessionid=' + CAST(@NEWsessionid as varchar(10)) + ',flagcalc=' + CAST(@NEWflagCalc AS varchar(2)) + ',level=' +  CAST(@NEWlevel AS varchar(2)) + ',sessionparentid=' + CAST(@NEWsessionparentid as varchar(10)), 'ticketcode=' + @ticketcode) -- MODIFICA A TUTTI I FLAGCALC ? >>> 1, SESSIONID ? >>> 
--PRINT(CAST(@XTTC AS varchar(MAX)))
SELECT * FROM ETL.GetXTTC(@XTTC, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI (MODIFICATI)

*/
ALTER FUNCTION	[ETL].[UpdMultiFieldXTTC] (
				@CurrentXTTC XML
				,@CSVFieldValuesPairs varchar(MAX) = NULL
				,@CSVWhereConditionPairs varchar(MAX) = NULL
				)
RETURNS XML
AS
BEGIN
	DECLARE 
			@returnXTTC XML = NULL
			,@i int
			,@nodeCount int
			,@fieldName sysname
			,@fieldValue varchar(MAX)
			,@wherefield sysname
			,@wherevalue varchar(MAX)
			,@FIELDS_CUR CURSOR

	DECLARE @FieldValues TABLE(fieldName sysname, fieldValue varchar(max))
	DECLARE @WhereConditions TABLE(fieldName sysname, fieldValue varchar(max))
	
	IF @CurrentXTTC IS NOT NULL
		BEGIN
			SET @returnXTTC = @CurrentXTTC

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

		END
	
	RETURN  @returnXTTC

END