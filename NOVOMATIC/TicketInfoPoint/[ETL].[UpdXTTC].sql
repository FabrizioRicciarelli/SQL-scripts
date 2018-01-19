/*
DECLARE @XTTC XML -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)

SET	@XTTC = ETL.WriteXTTC(@XTTC, '391378593917118854', 0, 1234, 1233, 1) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XTTC = ETL.WriteXTTC(@XTTC, '391378593917118855', 1, 12345, 12344, 2) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XTTC = ETL.WriteXTTC(@XTTC, '391378593917118856', 0, 123456, 123455, 2) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XTTC = ETL.WriteXTTC(@XTTC, '391378593917118857', 0, 1234567, 1234566, 3) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE

SELECT * FROM ETL.GetXTTC(@XTTC, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI

SET	@XTTC = ETL.UpdXTTC(@XTTC, '391378593917118857', '391378593917118859', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MODIFICA AL SOLO TICKETCODE '391378593917118857' >> '391378593917118859' (SOLO 1 PEZZO MODIFICATO)
SET	@XTTC = ETL.UpdXTTC(@XTTC, NULL, NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL)  -- MODIFICA A TUTTI I FLAGCALC = 0 >> 1 (3 PEZZI MODIFICATI)
SET	@XTTC = ETL.UpdXTTC(@XTTC, NULL, NULL, NULL, NULL, 12345, 12344, NULL, NULL, NULL, NULL) -- MODIFICA A TUTTI I SESSIONID = 12345 >> 12344 (SOLO 1 PEZZO MODIFICATO)
SET	@XTTC = ETL.UpdXTTC(@XTTC, NULL, NULL, NULL, NULL, NULL, NULL, 1234566, 1234560, NULL, NULL) -- MODIFICA A TUTTI I SESSIONPARENTID = 1234566 >> 1234560 (SOLO 1 PEZZO MODIFICATO)
SET	@XTTC = ETL.UpdXTTC(@XTTC, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, 4)  -- MODIFICA A TUTTI I LEVEL = 2 >> 4 (2 PEZZI MODIFICATI)

SELECT * FROM ETL.GetXTTC(@XTTC, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI (MODIFICATI)

*/
ALTER FUNCTION	[ETL].[UpdXTTC] (
				@CurrentXTTC XML
				,@TicketCode varchar(50) = NULL
				,@NEWTicketCode varchar(50) = NULL
				,@FlagCalc bit = NULL
				,@NEWFlagCalc bit = NULL
				,@SessionID int = NULL
				,@NEWSessionID int = NULL
				,@SessionParentID int = NULL
				,@NEWSessionParentID int = NULL
				,@Level int = NULL
				,@NEWLevel int = NULL
				)
RETURNS XML
AS
BEGIN
	DECLARE 
			@returnXTTC XML = NULL
			,@i int
			,@nodeCount int
	
	IF @CurrentXTTC IS NOT NULL
		BEGIN
			SET @returnXTTC = @CurrentXTTC

			IF @TicketCode IS NOT NULL
			AND @NEWTicketCode IS NOT NULL
				BEGIN
					SELECT @nodeCount = @returnXTTC.value('count(/TTC/@ticketcode)','int')
					SELECT @i = 1
					WHILE (@i <= @nodeCount)
						BEGIN
							SET @returnXTTC.modify('replace value of (/TTC/@ticketcode)[.=sql:variable("@TicketCode")][1] with sql:variable("@NEWTicketCode")')
							SET @i = @i + 1
						END		
			   END

			IF @FlagCalc IS NOT NULL
			AND @NEWFlagCalc IS NOT NULL
				BEGIN
					SELECT @nodeCount = @returnXTTC.value('count(/TTC/@flagcalc)','int')
					SELECT @i = 1
					WHILE (@i <= @nodeCount)
						BEGIN
							SET @returnXTTC.modify('replace value of (/TTC/@flagcalc)[.=sql:variable("@FlagCalc")][1] with sql:variable("@NEWFlagCalc")')
							SET @i = @i + 1
						END		
			   END

			IF @SessionID IS NOT NULL
			AND @NEWSessionID IS NOT NULL
				BEGIN
					SELECT @nodeCount = @returnXTTC.value('count(/TTC/@sessionid)','int')
					SELECT @i = 1
					WHILE (@i <= @nodeCount)
						BEGIN
							SET @returnXTTC.modify('replace value of (/TTC/@sessionid)[.=sql:variable("@SessionID")][1] with sql:variable("@NEWSessionID")')
							SET @i = @i + 1
						END		
			   END

			IF @SessionParentID IS NOT NULL
			AND @NEWSessionParentID IS NOT NULL
				BEGIN
					SELECT @nodeCount = @returnXTTC.value('count(/TTC/@sessionparentid)','int')
					SELECT @i = 1
					WHILE (@i <= @nodeCount)
						BEGIN
							SET @returnXTTC.modify('replace value of (/TTC/@sessionparentid)[.=sql:variable("@SessionParentID")][1] with sql:variable("@NEWSessionParentID")')
							SET @i = @i + 1
						END		
			   END

			IF @Level IS NOT NULL
			AND @NEWLevel IS NOT NULL
				BEGIN
					SELECT @nodeCount = @returnXTTC.value('count(/TTC/@level)','int')
					SELECT @i = 1
					WHILE (@i <= @nodeCount)
						BEGIN
							SET @returnXTTC.modify('replace value of (/TTC/@level)[.=sql:variable("@Level")][1] with sql:variable("@NEWLevel")')
							SET @i = @i + 1
						END		
			   END


		END
	
	RETURN  @returnXTTC

END