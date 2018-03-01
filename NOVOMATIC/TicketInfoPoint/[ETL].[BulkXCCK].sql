/*
SET NOCOUNT ON;

DECLARE 
		@XCCK XML -- VUOTO
		,@INPUTCCK ETL.CCK_TYPE

-- RIEMPIMENTO OGGETTO DI TIPO "ETL.CCK_TYPE"
INSERT	@INPUTCCK -- (ClubID,MachineID,FromOut,ToOut,TotalBet,TotalWon,WinD,TotalBillIn,TotalCoinIn,TotalTicketIn,TotalTicketOut,TotalHandPay,TotalOut,TotalIn) -- * ELENCO PARAMETRI OPZIONALE *
VALUES	
		 (1000296, 17, '2017-11-30T18:34:16.005','2017-12-01T09:11:31.104', 1000, NULL, 100, 150, 400, 100, 200, NULL, 150, 250)	
		,(1000296, 17, '2017-10-11T19:18:29.216','2017-10-21T11:17:41.121', 1100, NULL, 120, 110, 600, 200, 250,  100, 250, 200)	
		,(1000296, 17, '2017-12-23T05:28:44.144','2017-12-25T17:45:35.653', 1200,   50, 150, 130, 400, 600, 280, NULL, 350, 150)	
		,(1000296, 17, '2017-09-06T07:52:21.876','2017-09-07T21:03:26.877', 1300,   25, 180, 250, 500,  50, 210,   75, 450, 300)	

-- BULK LOAD IN UNA VARIABILE XML (CONTENITORE) DA OGGETTO DI TIPO "ETL.CCK_TYPE"
SET	@XCCK = ETL.BulkXCCK(@XCCK, @INPUTCCK) -- RIEMPIE IL CONTENITORE XML CON I DATI PRESENTI NELL'OGGETTO DI TIPO "ETL.CCK_TYPE", RITORNA UNA VARIABILE XML CONTENENTE TUTTE LE COLONNE PRESENTI NELL'OGGETTO IN INGRESSO (@INPUTCCK = ETL.CCK_TYPE)

SELECT * FROM ETL.GetAllXCCK(@XCCK) -- RITORNA L'ELENCO COMPLETO IN FORMA TABELLARE
SELECT * FROM ETL.GetAllXCCK(@XCCK) FOR XML PATH('CCK'), ROOT('ROWS'), TYPE -- RITORNA L'ELENCO COMPLETO IN FORMA XML

*/
ALTER FUNCTION [ETL].[BulkXCCK]
				(
					@XMLCCK XML
					,@INPUTCCK ETL.CCK_TYPE READONLY
				)
RETURNS XML
AS
BEGIN
	DECLARE 
			@returnXCCK XML = NULL
			,@outputCCK ETL.CCK_TYPE
			,@lastID int

	IF EXISTS (SELECT TOP 1 * FROM @INPUTCCK)
		BEGIN
			INSERT 	@outputCCK
					(
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
					) 
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
			FROM	@INPUTCCK
		END

	SET @returnXCCK =
		(
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
				FROM	@outputCCK 
				FOR XML RAW('CCK'), TYPE
		)
	RETURN  @returnXCCK
END