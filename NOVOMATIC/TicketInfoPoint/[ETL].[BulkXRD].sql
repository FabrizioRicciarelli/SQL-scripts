/*
SET NOCOUNT ON;

DECLARE 
		@XRD XML -- VUOTO
		,@INPUTxrd ETL.RAWDELTA_TYPE

-- RIEMPIMENTO OGGETTO DI TIPO "ETL.RAWDELTA_TYPE"
INSERT @INPUTxrd -- (RowID, UnivocalLocationCode, ServerTime, MachineID, GD, AamsMachineCode, GameID, GameName, VLTCredit, TotalBet, TotalWon, TotalBillIn, TotalCoinIn, TotalTicketIn, TotalHandPay, TotalTicketOut, Tax, TotalIn, TotalOut, WrongFlag, TicketCode, FlagMinVltCredit, SessionID)  -- * ELENCO PARAMETRI OPZIONALE *
VALUES
		 (-2043978769, 'EA110086040A', '2017-10-21 15:03:24.043', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 1150, 100, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641)
		,(-2043978766, 'EA110086040A', '2017-10-21 15:03:26.150', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 1050, 100, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641)
		,(-2043978761, 'EA110086040A', '2017-10-21 15:03:29.447', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 1000, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641)
		,(-2043978755, 'EA110086040A', '2017-10-21 15:03:31.707', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 950, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641)

-- BULK LOAD IN UNA VARIABILE XML (CONTENITORE) DA OGGETTO DI TIPO "ETL.RAWDELTA_TYPE"
SET	@XRD = ETL.BulkXRD(@XRD, @INPUTxrd) -- RIEMPIE IL CONTENITORE XML CON I DATI PRESENTI NELL'OGGETTO DI TIPO "ETL.RAWDELTA_TYPE", RITORNA UNA VARIABILE XML CONTENENTE TUTTE LE COLONNE PRESENTI NELL'OGGETTO IN INGRESSO (@INPUTxrd = ETL.RAWDELTA_TYPE)

SELECT * FROM ETL.GetXRD(@XRD, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- RITORNA L'ELENCO COMPLETO IN FORMA TABELLARE
PRINT(CONVERT(varchar(MAX),@XRD))
*/
ALTER FUNCTION [ETL].[BulkXRD]
				(
					@XMLrawdelta XML
					,@INPUTxrd ETL.RAWDELTA_TYPE READONLY
				)
RETURNS XML
AS
BEGIN
	DECLARE 
			@returnXRD XML = NULL
			,@outputXRD ETL.RAWDELTA_TYPE
			,@lastID int


	IF EXISTS (SELECT TOP 1 * FROM @INPUTxrd)
		BEGIN
			INSERT	@outputXRD
			SELECT
					RowID
					,UnivocalLocationCode
					,ServerTime
					,MachineID
					,GD
					,AamsMachineCode
					,GameID
					,GameName
					,VLTCredit
					,TotalBet
					,TotalWon
					,TotalBillIn
					,TotalCoinIn
					,TotalTicketIn
					,TotalHandPay
					,TotalTicketOut
					,Tax
					,TotalIn
					,TotalOut
					,WrongFlag
					,TicketCode
					,FlagMinVltCredit
					,SessionID
			FROM	ETL.GetXRD(@XMLrawdelta, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
			UNION ALL
			SELECT	
					RowID
					,UnivocalLocationCode
					,ServerTime
					,MachineID
					,GD
					,AamsMachineCode
					,GameID
					,GameName
					,VLTCredit
					,TotalBet
					,TotalWon
					,TotalBillIn
					,TotalCoinIn
					,TotalTicketIn
					,TotalHandPay
					,TotalTicketOut
					,Tax
					,TotalIn
					,TotalOut
					,WrongFlag
					,TicketCode
					,FlagMinVltCredit
					,SessionID
			FROM	@inputXRD
	END

	SET @returnXRD =
		(
			SELECT 	
					RowID
					,UnivocalLocationCode
					,ServerTime
					,MachineID
					,GD
					,AamsMachineCode
					,GameID
					,GameName
					,VLTCredit
					,TotalBet
					,TotalWon
					,TotalBillIn
					,TotalCoinIn
					,TotalTicketIn
					,TotalHandPay
					,TotalTicketOut
					,Tax
					,TotalIn
					,TotalOut
					,WrongFlag
					,TicketCode
					,FlagMinVltCredit
					,SessionID
			FROM	@outputXRD 
			FOR XML RAW('XRD'), TYPE
		)
	RETURN  @returnXRD
END