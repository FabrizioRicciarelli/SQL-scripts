/*
DECLARE @XCCK XML -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)

SET	@XCCK = ETL.WriteXCCK(@XCCK, 1000296, 24, '20151117', '20151118', 1000, 500, 500, 800, 800, 500, 500, 550, 450, 380) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XCCK = ETL.WriteXCCK(@XCCK, 1000296, 25, '20151117', '20151118', 1200, 900, 700, 300, 400, 700, 90, 850, 720, 190) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XCCK = ETL.WriteXCCK(@XCCK, 1000296, 26, '20151221', '20151231', 1400, 800, 600, 200, 300, 600, 900, 850, 250, 180) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)

SELECT * FROM ETL.GetXCCK(@XCCK, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
-- OPPURE SELECT * FROM ETL.GetAllXCCK(@XCCK) -- SE NON CI SONO VALORI DA FILTRARE

PRINT(CONVERT(varchar(MAX),@XCCK))
*/
ALTER FUNCTION [ETL].[WriteXCCK]
				(
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
	DECLARE 
			@returnXCCK XML = NULL
			,@inputCCK ETL.CCK_TYPE
			,@outputCCK ETL.CCK_TYPE
			,@lastID int


	IF ISNULL(@ClubID,0) != 0
		BEGIN
			IF @XMLCCK IS NOT NULL
				BEGIN
					INSERT @inputCCK
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
					FROM	ETL.GetXCCK(@XMLCCK, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
					
					SELECT	@lastID = MAX(ClubID)
					FROM	@inputCCK
				END

			IF NOT EXISTS (SELECT * FROM @inputCCK)
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
							VALUES 
							(
								 @ClubID
								,@MachineID
								,@FromOut
								,@ToOut
								,@TotalBet
								,@TotalWon
								,@WinD
								,@TotalBillIn
								,@TotalCoinIn
								,@TotalTicketIn
								,@TotalTicketOut
								,@TotalHandPay
								,@TotalOut
								,@TotalIn
							)
				END
			ELSE
				BEGIN
					INSERT	@outputCCK
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
					FROM	@inputCCK
					UNION ALL
					SELECT	
							 I.ClubID AS ClubID 
							,I.MachineID AS MachineID
							,I.FromOut AS FromOut
							,I.ToOut AS ToOut 
							,I.TotalBet	AS TotalBet
							,I.TotalWon	AS TotalWon
							,I.WinD	AS WinD 
							,I.TotalBillIn AS TotalBillIn 
							,I.TotalCoinIn AS TotalCoinIn
							,I.TotalTicketIn AS TotalTicketIn
							,I.TotalTicketOut AS TotalTicketOut 
							,I.TotalHandPay	AS TotalHandPay 
							,I.TotalOut	AS TotalOut
							,I.TotalIn AS TotalIn 
					FROM
					(
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
				END 
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