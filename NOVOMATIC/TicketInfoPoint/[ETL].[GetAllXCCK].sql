/*
DECLARE @XCCK XML -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)

SET	@XCCK = ETL.WriteXCCK(@XCCK, 1000296, 22, '2017-01-01', '2017-12-31', 1000, 70, 95, 1080, 80, 25, 800, 860, 240, 1900) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XCCK = ETL.WriteXCCK(@XCCK, 1000296, 23, '2017-01-01', '2017-12-31', 1200, 50, 75, 1090, 90, 55, 600, 960, 640, 1700) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XCCK = ETL.WriteXCCK(@XCCK, 1000296, 24, '2017-01-01', '2017-12-31', 1400, 90, 85, 1030, 70, 45, 700, 260, 540, 1300) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XCCK = ETL.WriteXCCK(@XCCK, 1000296, 25, '2017-01-01', '2017-12-31', 1600, 40, 45, 1010, 60, 35, 300, 560, 840, 1100) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)

SELECT * FROM ETL.GetAllXCCK(@XCCK)
SELECT * FROM ETL.GetAllXCCK(@XCCK) FOR XML PATH('CCK'), ROOT('ROWS'), TYPE -- RITORNA L'ELENCO COMPLETO IN FORMA XML
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