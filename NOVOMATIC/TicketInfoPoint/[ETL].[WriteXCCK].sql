/*
-- @XCCK ex TMP.CountersCork

SET NOCOUNT ON;

DECLARE @XCCK XML -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)
DECLARE @XCCK_EL XML 

SET	@XCCK = ETL.WriteXCCK(@XCCK, 1000296, 24, '20151117', '20151118', 1000, 500, 500, 800, 800, 500, 500, 550, 450, 380) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XCCK = ETL.WriteXCCK(@XCCK, 1000296, 25, '20151117', '20151118', 1200, 900, 700, 300, 400, 700, 90, 850, 720, 190) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XCCK = ETL.WriteXCCK(@XCCK, 1000296, 26, '20151221', '20151231', 1400, 800, 600, 200, 300, 600, 900, 850, 250, 180) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)

SELECT * FROM ETL.GetAllXCCK(@XCCK)	-- MOSTRA L'ELENCO COMPLETO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetXCCK(@XCCK, NULL, NULL, '20151221', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI, FILTRATO PER "FromOut"
SELECT * FROM ETL.GetAllXCCK(@XCCK) FOR XML PATH('CountersCork'), ROOT('ROOT'), TYPE, ELEMENTS -- MOSTRA L'ELENCO IN FORMATO XML ELEMENTS

SELECT @XCCK_EL = (SELECT * FROM ETL.GetAllXCCK(@XCCK) FOR XML PATH('CountersCork'), ROOT('root'), TYPE, ELEMENTS) -- PREPARAZIONE XML_ELEMENTS PER JSON

SELECT dbo.XML2JSON(@XCCK_EL) AS JSONdata -- MOSTRA L'ELENCO IN FORMATO JSON

PRINT(CONVERT(varchar(MAX), @XCCK)) -- MOSTRA LA STRUTTURA XML RAW
*/
ALTER FUNCTION [ETL].[WriteXCCK] (
					@XMLCCK XML = NULL
					,@ClubID int = NULL -- NOT NULL
					,@MachineID tinyint = NULL
					,@FromOut datetime = NULL
					,@ToOut datetime2(3) = NULL
					,@TotalBet bigint = NULL
					,@TotalWon bigint = NULL
					,@WinD bigint = NULL
					,@TotalBillIn bigint = NULL
					,@TotalCoinIn bigint = NULL
					,@TotalTicketIn bigint = NULL
					,@TotalTicketOut bigint = NULL
					,@TotalHandPay bigint = NULL
					,@TotalOut bigint = NULL
					,@TotalIn bigint = NULL
				)
RETURNS XML
AS
BEGIN
	RETURN (
		SELECT *
		FROM (
			SELECT
					ClubID
					,MachineID
					,FromOut
					,ToOut
					,TotalBet
					,TotalWon
					,WinD
					,TotalBillIn
					,TotalCoinIn
					,TotalTicketIn
					,TotalTicketOut
					,TotalHandPay
					,TotalOut
					,TotalIn
			FROM	ETL.GetAllXCCK(@XMLCCK)
			UNION ALL
			SELECT
					@ClubID AS ClubID 
					,@MachineID AS MachineID
					,@FromOut AS FromOut
					,@ToOut AS ToOut 
					,@TotalBet	AS TotalBet
					,@TotalWon	AS TotalWon
					,@WinD	AS WinD 
					,@TotalBillIn AS TotalBillIn 
					,@TotalCoinIn AS TotalCoinIn
					,@TotalTicketIn AS TotalTicketIn
					,@TotalTicketOut AS TotalTicketOut 
					,@TotalHandPay	AS TotalHandPay 
					,@TotalOut	AS TotalOut
					,@TotalIn AS TotalIn 
		) I
		FOR XML RAW('CCK'), TYPE
	)
END