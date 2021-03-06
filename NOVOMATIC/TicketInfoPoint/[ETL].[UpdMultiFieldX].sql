/*

-- *** ATTENZIONE !!! ***
-- SE TRA LE COLONNE DA MODIFICARE VI SONO ANCHE QUELLE UTILIZZATE NEL CRITERIO DI FILTRO (COME, AD ESEMPIO, UNA COSA DEL TIPO "SET FlagCalc = 1, SessionID = 345 WHERE FlagCalc = 0") ACCERTARSI DI PORRE TALI COLONNE
-- ALLA *FINE* DELL'ELENCO DELLE COLONNE DA MODIFICARE, IN QUESTO MODO: "SET SessionID = 345, FlagCalc = 1  WHERE FlagCalc = 0", DOVE FlagCalc = 1 HA LA PRECEDENZA PIU' BASSA IN QUANTO UTILIZZATO COME CRITERIO DI FILTRO
-- SI RISCHIA, ALTRIMENTI, CHE IN SEDE DI AGGIORNAMENTO, LA COLONNA CAMBI STATO E ALLA CICLO DI AGGIORNAMENTO SUCCESSIVO, IL CRITERIO NON SIA PIU' APPLICABILE PROPRIO IN VIRTU' DEL VALORE APPENA CAMBIATO.
-- QUESTO ACCADE PERCHE', IN XML-DML, GLI AGGIORNAMENTI AVVENGONO SUL SINGOLO NODO E NEL CASO DELLA PRESENZA DI PIU' NODI E' NECESSARIO EFFETTUARE UN CICLO TRA TUTTI I NODI MEDESIMI

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

---- PRIMO TEST:  -- MODIFICA A TUTTI I FLAGCALC ? >>> 1, SESSIONID ? >>> 1111, LEVEL >>> 99, SESSIONPARENTID >>>> 2222 DOVE IL TicketCode sia uguale a '391378593917118857' 
SET	@XTTC = ETL.UpdMultiFieldX(@XTTC,  'sessionid=' + CAST(@NEWsessionid as varchar(10)) + ',level=' +  CAST(@NEWlevel AS varchar(2)) + ',sessionparentid=' + CAST(@NEWsessionparentid as varchar(10)) + ',flagcalc=' + CAST(@NEWflagCalc AS varchar(2)), 'ticketcode=' + @ticketcode) 
SELECT * FROM ETL.GetXTTC(@XTTC, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI (MODIFICATI)

-- SECONDO TEST:  -- MODIFICA A TUTTI I FLAGCALC ? >>> 1, SESSIONID ? >>>	1111 DOVE IL flagCalc sia diverso da 1 
SET	@XTTC = ETL.UpdMultiFieldX(@XTTC,  'sessionid=' + CAST(@NEWsessionid as varchar(10))+ ',level=' +  CAST(@NEWlevel AS varchar(2)) + ',sessionparentid=' + CAST(@NEWsessionparentid as varchar(10)) + ',flagcalc=' + CAST(@NEWflagCalc AS varchar(2)) , 'flagcalc=0') 
SELECT * FROM ETL.GetXTTC(@XTTC, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI (MODIFICATI)


-------------------------------------------------------------


-- I NODI NULLI NON VENGONO UPDATATI: TRASFORMARE IN TABELLA L'XML, AGGIORNARE A VALORI NON NULLI E RICOSTRUIRE L'XML E QUINDI EFFETTUARE L'UPDATE TRAMITE LA PRESENTE FUNZIONE
DECLARE	
		@XTMPTicketStart	XML
		,@ClubID			int = 1000002
		,@BatchID			int = 1

SET	@XTMPTicketStart = ETL.WriteXTICKETS(@XTMPTicketStart, NULL, 1000002, '309551976638606413',4000,'GD014017411',27, '2015-11-17 18:49:27.000','GD014017652',26,'2015-11-17 18:49:46.000',NULL,NULL, '2016-02-15 18:49:27.000',NULL,NULL,NULL,'2016-01-01 00:00:00.000')
SET	@XTMPTicketStart = ETL.DenullXTICKETS(@XTMPTicketStart)
SET	@XTMPTicketStart = ETL.UpdMultiFieldX(@XTMPTicketStart,  'BatchID=' + CAST(@BatchID AS varchar(10)), 'ClubID=' + CAST(@ClubID AS varchar(10))) 
SELECT * FROM ETL.GetAllXTICKETS(@XTMPTicketStart)

*/
ALTER FUNCTION	[ETL].[UpdMultiFieldX] (
				@CurrentX XML
				,@CSVFieldValuesPairs varchar(MAX) = NULL
				,@CSVWhereConditionPairs varchar(MAX) = NULL
				)
RETURNS XML
AS
BEGIN
	DECLARE 
			@returnX XML = NULL
			,@i int
			,@nodeCount int
			,@fieldName sysname
			,@fieldValue varchar(MAX)
			,@wherefield sysname
			,@wherevalue varchar(MAX)
			,@FIELDS_CUR CURSOR

	DECLARE @FieldValues TABLE(fieldName sysname, fieldValue varchar(max))
	DECLARE @WhereConditions TABLE(fieldName sysname, fieldValue varchar(max))
	
	IF @CurrentX IS NOT NULL
		BEGIN
			SET @returnX = @CurrentX

			IF @CSVFieldValuesPairs LIKE '%,%'
				BEGIN
					INSERT	@FieldValues
					SELECT	
							dbo.fnLeftPart(Value,'=') AS fieldName
							,dbo.fnRightPart(Value,'=') AS fieldValue
					FROM	dbo.STRING_SPLIT(@CSVFieldValuesPairs,',')
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
					FROM	dbo.STRING_SPLIT(@CSVWhereConditionPairs,',')
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

			SET @returnX = @CurrentX

			OPEN @FIELDS_CUR;
			FETCH NEXT FROM @FIELDS_CUR 
			INTO 
					@fieldName
					,@fieldValue
					,@whereField
					,@whereValue

			WHILE @@FETCH_STATUS = 0
				BEGIN
					SELECT @nodeCount = @returnX.value('count(//@*[local-name()=sql:variable("@fieldName")])','int')	-- INDIVIDUA E QUANTIFICA IL NUMERO DELLE OCCORRENZE DI CIASCUN NODO/ATTRIBUTO CORRISPONDENTE AL CONTENUTO DELLA VARIABILE @fieldName (NELL'ESEMPIO, IN SEQUENZA: "sessionid", "level", "sessionparentid", "flagcalc")
					SELECT @i = 1
					WHILE (@i <= @nodeCount)
						BEGIN
							SET @returnX.modify(
							'
							replace value of 
							(//@*[local-name()=sql:variable("@fieldName")])
							[
								../@*[local-name()=sql:variable("@whereField")] = sql:variable("@whereValue") 
								and position() = sql:variable("@i")
							][1] 
							with sql:variable("@fieldValue")
							'
							)
							-- IL PRECEDENTE COMANDO XML-DML SI INTERPRETA IN QUESTO MODO:
							-- Sostituisci il valore corrispondente al nodo
							-- (//@*[nomedellattributocorrente()=valorevariabilesql@fieldName]) OVVERO, il nome del nodo/attributo corrispondente al valore contenuto in quel momento dalla variabile @fieldname (ad esempio: @fieldName = 'sessionID')
							-- [ LADDOVE
							--		../@*[nomedellattributocorrente()=valorevariabilesql@whereField] = valorevariabilesql@whereValue OVVERO, dove il nome del nodo/attributo sia uguale al contenuto della variabile @whereField e il suo valore corrisponda a quello contenuto nella variabile @whereValue
							--      and position() = valorevariabilesql@i OVVERO, e l'indice del nodo corrente corrisponda al contenuto della variabile @i
							-- ][1] OVVERO un singleton, cioè il puntamento ad un nodo/attributo unico
							-- rimpiazzandolo con valorevariabile@fieldValue OVVERO utilizzando come valore di rimpiazzo quello contenuto nella variabile @fieldValue
							--
							-- LO STATEMENT SQL EQUIVALENTE E' QUESTO: UPDATE RETURNX SET FIELDNAME = FIELDVALUE WHERE WHEREFIELD = WHEREVALUE

							SET @i += 1 -- INCREMENTO PER SPOSTAMENTO TRAMITE INDICE ATTRAVERSO LE VARIE OCCORRENZE DI CIASCUN NODO/ATTRIBUTO, TRA QUELLE INDIVIDUATE E MEMORIZZATE NELLA VARIABILE @nodeCount
						END		
		
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
	
	RETURN  @returnX

END