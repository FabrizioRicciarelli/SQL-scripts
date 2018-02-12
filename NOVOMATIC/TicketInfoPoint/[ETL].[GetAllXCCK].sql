/*
DECLARE @XCCK XML -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)

SET	@XCCK = ETL.WriteXCCK(@XCCK, 1000296, 24, '20151117', '20151118', 1000, 500, 500, 800, 800, 500, 500, 550, 450, 380) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XCCK = ETL.WriteXCCK(@XCCK, 1000296, 25, '20151117', '20151118', 1200, 900, 700, 300, 400, 700, 90, 850, 720, 190) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XCCK = ETL.WriteXCCK(@XCCK, 1000296, 26, '20151221', '20151231', 1400, 800, 600, 200, 300, 600, 900, 850, 250, 180) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)

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