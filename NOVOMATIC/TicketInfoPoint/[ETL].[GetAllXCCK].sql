/*
DECLARE @XCCK XML -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)

SET	@XCCK = ETL.WriteXCCK(@XCCK, '391378593917118854', 0, 1234, 1233, 1) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XCCK = ETL.WriteXCCK(@XCCK, '391378593917118855', 1, 12345, 12344, 2) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XCCK = ETL.WriteXCCK(@XCCK, '391378593917118856', 0, 123456, 123455, 2) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XCCK = ETL.WriteXCCK(@XCCK, '391378593917118857', 0, 1234567, 1234566, 3) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE

SELECT * FROM ETL.GetAllXCCK(@XCCK)
*/
ALTER FUNCTION [ETL].[GetAllXCCK](@XMLCCK XML = NULL)
RETURNS TABLE		
AS
RETURN
(
	SELECT 
			T.c.value('@ClubID', 'int') AS ClubID
			,T.c.value('@MachineID', 'tinyint') AS MachineID
			,T.c.value('@FromOut', 'datetime') AS FromOut
			,T.c.value('@ToOut', 'datetime') AS ToOut
			,T.c.value('@TotalBet', 'bigint') AS TotalBet
			,T.c.value('@TotalWon', 'bigint') AS TotalWon
			,T.c.value('@WinD', 'bigint') AS WinD
			,T.c.value('@TotalBillIn', 'bigint') AS TotalBillIn
			,T.c.value('@TotalCoinIn', 'bigint') AS TotalCoinIn
			,T.c.value('@TotalTicketIn', 'bigint') AS TotalTicketIn
			,T.c.value('@TotalTicketOut', 'bigint') AS TotalTicketOut
			,T.c.value('@TotalHandPay', 'bigint') AS TotalHandPay
			,T.c.value('@TotalOut', 'bigint') AS TotalOut
			,T.c.value('@TotalIn', 'bigint') AS TotalIn
	FROM	@XMLCCK.nodes('CCK') AS T(c) 
) 