/*
SET NOCOUNT ON;

DECLARE 
		@XRD XML -- VUOTO
		,@DELTATYPE ETL.RAWDELTA_TYPE

-- RIEMPIMENTO OGGETTO DI TIPO "ETL.RAWDELTA_TYPE"
INSERT @DELTATYPE -- (RowID, UnivocalLocationCode, ServerTime, MachineID, GD, AamsMachineCode, GameID, GameName, VLTCredit, TotalBet, TotalWon, TotalBillIn, TotalCoinIn, TotalTicketIn, TotalHandPay, TotalTicketOut, Tax, TotalIn, TotalOut, WrongFlag, TicketCode, FlagMinVltCredit, SessionID)  -- * ELENCO PARAMETRI OPZIONALE *
VALUES
		 (-2043978769, 'EA110086040A', '2017-10-21 15:03:24.043', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 0, 1150, 100, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641)
		,(-2043978766, 'EA110086040A', '2017-10-21 15:03:26.150', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 0, 1050, 100, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641)
		,(-2043978761, 'EA110086040A', '2017-10-21 15:03:29.447', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 0, 1000, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641)
		,(-2043978755, 'EA110086040A', '2017-10-21 15:03:31.707', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 0, 950, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641)

-- BULK LOAD IN UNA VARIABILE XML (CONTENITORE) DA OGGETTO DI TIPO "ETL.RAWDELTA_TYPE"
SET	@XRD = ETL.BulkXRD(@XRD, @DELTATYPE) -- RIEMPIE IL CONTENITORE XML CON I DATI PRESENTI NELL'OGGETTO DI TIPO "ETL.RAWDELTA_TYPE", RITORNA UNA VARIABILE XML CONTENENTE TUTTE LE COLONNE PRESENTI NELL'OGGETTO IN INGRESSO (@DELTATYPE = ETL.RAWDELTA_TYPE)

SELECT * FROM ETL.GetXRD(@XRD, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- RITORNA L'ELENCO COMPLETO IN FORMA TABELLARE
-- OPPURE
SELECT * FROM ETL.GetAllXRD(@XRD)
PRINT(CONVERT(varchar(MAX),@XRD))
*/
ALTER FUNCTION [ETL].[BulkXRD]
				(
					@XMLDELTA XML
					,@DELTATYPE ETL.RAWDELTA_TYPE READONLY
				)
RETURNS XML
AS
BEGIN
RETURN(
	SELECT I.* 
	FROM (
		SELECT
				RowID
				,UnivocalLocationCode
				,ServerTime
				,MachineID
				,GD
				,AamsMachineCode
				,GameID
				,GameName
				,LoginFlag
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
		FROM	ETL.GetAllXRD(@XMLDELTA)
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
				,LoginFlag
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
		FROM	@DELTATYPE
	) I
	FOR XML RAW('XRD'), TYPE
)
END