/*
DECLARE @XTTC XML -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)

SET	@XTTC = ETL.WriteXTTC(@XTTC, '391378593917118854', 0, 1234, 1233, 1) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XTTC = ETL.WriteXTTC(@XTTC, '391378593917118855', 1, 12345, 12344, 2) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XTTC = ETL.WriteXTTC(@XTTC, '391378593917118856', 0, 123456, 123455, 2) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XTTC = ETL.WriteXTTC(@XTTC, '391378593917118857', 0, 1234567, 1234566, 3) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE

SELECT * FROM ETL.GetAllXTTC(@XTTC) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
*/
ALTER	FUNCTION [ETL].[GetAllXTTC](
		@XMLttc XML = NULL
)
RETURNS TABLE
AS
RETURN (
	SELECT 
			T.c.value('@id', 'int') AS id
			,T.c.value('@ticketcode', 'varchar(50)') AS ticketcode
			,T.c.value('@flagcalc', 'bit') AS flagcalc
			,T.c.value('@sessionid', 'int') AS sessionid
			,T.c.value('@sessionparentid', 'int') AS sessionparentid
			,T.c.value('@level', 'int') AS level
	FROM	@XMLttc.nodes('TTC') AS T(c) 
) 