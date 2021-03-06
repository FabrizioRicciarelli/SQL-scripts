/*
DECLARE @XRD XML -- VUOTO
SET @XRD ='<XRD RowID="-2043978766" UnivocalLocationCode="EA110086040A" ServerTime="2017-10-21T15:03:26.150" MachineID="11" GD="GD014017380" AamsMachineCode="D0000004379" GameID="-146039307" GameName="Book Of Ra" VLTCredit="1050" TotalBet="100" TicketCode="0" SessionID="-2147483641"/>'
SELECT * FROM ETL.GetXRD(@XRD, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
PRINT(CONVERT(varchar(MAX),@XRD))

DECLARE @XRD XML -- VUOTO
SET	@XRD = ETL.WriteXRD(@XRD, -2043978769, 'EA110086040A', '2017-10-21 15:03:24.043', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 0, 1150, 100, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XRD = ETL.WriteXRD(@XRD, -2043978766, 'EA110086040A', '2017-10-21 15:03:26.150', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 0, 1050, 100, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XRD = ETL.WriteXRD(@XRD, -2043978761, 'EA110086040A', '2017-10-21 15:03:29.447', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 0, 1000, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XRD = ETL.WriteXRD(@XRD, -2043978755, 'EA110086040A', '2017-10-21 15:03:31.707', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 0, 950, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SELECT * FROM ETL.GetXRD(@XRD, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
PRINT(CONVERT(varchar(MAX),@XRD))
*/
ALTER FUNCTION [ETL].[WriteXRD]
				(
					@XRD XML
					,@RowID int = NULL -- NOT NULL
					,@UnivocalLocationCode varchar(30) = NULL
					,@ServerTime datetime2(3) = NULL -- NOT NULL
					,@MachineID tinyint = NULL -- NOT NULL
					,@GD varchar(30) = NULL
					,@AamsMachineCode varchar(30) = NULL
					,@GameID int = NULL
					,@GameName varchar(100) = NULL
					,@LoginFlag bit = NULL
					,@VLTCredit int = NULL
					,@TotalBet int = NULL
					,@TotalWon int = NULL
					,@TotalBillIn int = NULL
					,@TotalCoinIn int = NULL
					,@TotalTicketIn int = NULL
					,@TotalHandPay int = NULL
					,@TotalTicketOut int = NULL
					,@Tax int = NULL
					,@TotalIn int = NULL
					,@TotalOut int = NULL
					,@WrongFlag bit = NULL -- AS (CONVERT(bitcase when VLTCredit<(0) OR TotalBet<(0) OR TotalWon<(0) OR TotalBillIn<(0) OR TotalCoinIn<(0) OR TotalTicketIn<(0) OR TotalHandPay<(0) OR TotalTicketOut<(0) OR Tax<(0) OR VLTCredit>(10000000) OR TotalBet>(1000) OR TotalWon>(500000) OR TotalBillIn>(50000) OR TotalCoinIn>(200) OR TotalTicketIn>(1000000) OR TotalHandPay>(6000000) OR TotalTicketOut>(1000000) OR Tax>(50000) then (1) else (0) end))
					,@TicketCode varchar(50) = NULL
					,@FlagMinVltCredit bit = NULL
					,@SessionID int = NULL -- NOT NULL
				)
RETURNS XML
AS
BEGIN
	RETURN (
		SELECT *
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
			FROM	ETL.GetAllXRD(@XRD)
			UNION ALL
			SELECT 
					@RowID AS RowID
					,@UnivocalLocationCode AS UnivocalLocationCode
					,@ServerTime AS ServerTime
					,@MachineID AS MachineID
					,@GD AS GD
					,@AamsMachineCode AS AamsMachineCode
					,@GameID AS GameID
					,@GameName AS GameName
					,@LoginFlag AS LoginFlag
					,@VLTCredit AS VLTCredit
					,@TotalBet AS TotalBet
					,@TotalWon AS TotalWon
					,@TotalBillIn AS TotalBillIn
					,@TotalCoinIn AS TotalCoinIn
					,@TotalTicketIn AS TotalTicketIn
					,@TotalHandPay AS TotalHandPay
					,@TotalTicketOut AS TotalTicketOut
					,@Tax AS Tax
					,@TotalIn AS TotalIn
					,@TotalOut AS TotalOut
					,@WrongFlag AS WrongFlag
					,@TicketCode AS TicketCode
					,@FlagMinVltCredit AS FlagMinVltCredit
					,@SessionID AS SessionID
		) I
		FOR XML RAW('XRD'), TYPE
	)
END