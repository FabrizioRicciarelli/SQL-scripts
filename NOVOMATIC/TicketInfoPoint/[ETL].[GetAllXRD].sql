/*
DECLARE @XRD XML -- VUOTO
SET @XRD ='<XRD RowID="-2043978766" UnivocalLocationCode="EA110086040A" ServerTime="2017-10-21T15:03:26.150" MachineID="11" GD="GD014017380" AamsMachineCode="D0000004379" GameID="-146039307" GameName="Book Of Ra" LoginFlag="0" VLTCredit="1050" TotalBet="100" TicketCode="0" SessionID="-2147483641"/>'
SELECT * FROM ETL.GetAllXRD(@XRD)

-------------------------------

DECLARE @XRD XML -- VUOTO
SET	@XRD = ETL.WriteXRD(@XRD, -2043978769, 'EA110086040A', '2017-10-21 15:03:24.043', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 0, 115000000, 100, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XRD = ETL.WriteXRD(@XRD, -2043978766, 'EA110086040A', '2017-10-21 15:03:26.150', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 0, 1050, 100, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XRD = ETL.WriteXRD(@XRD, -2043978761, 'EA110086040A', '2017-10-21 15:03:29.447', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 0, 1000, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XRD = ETL.WriteXRD(@XRD, -2043978755, 'EA110086040A', '2017-10-21 15:03:31.707', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 0, 950, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE

SELECT * FROM ETL.GetAllXRD(@XRD)
*/
ALTER	FUNCTION [ETL].[GetAllXRD](
		@XMLRD XML = NULL
)
RETURNS TABLE
AS
RETURN(
	SELECT
			 I.RowID
			,I.UnivocalLocationCode
			,I.ServerTime
			,I.MachineID
			,I.GD
			,I.AamsMachineCode
			,I.GameID
			,I.GameName
			,I.LoginFlag
			,I.VLTCredit
			,I.TotalBet
			,I.TotalWon
			,I.TotalBillIn
			,I.TotalCoinIn
			,I.TotalTicketIn
			,I.TotalHandPay
			,I.TotalTicketOut
			,I.Tax
			,I.TotalIn
			,I.TotalOut
			,WrongFlag =	
				CASE 
					WHEN	I.VLTCredit < 0 
					OR		I.TotalBet < 0 
					OR		I.TotalWon < 0 
					OR		I.TotalBillIn < 0 
					OR		I.TotalCoinIn < 0 
					OR		I.TotalTicketIn < 0 
					OR		I.TotalHandPay < 0 
					OR		I.TotalTicketOut < 0 
					OR		I.Tax < 0 
					OR		I.VLTCredit > 10000000 
					OR		I.TotalBet > 1000 
					OR		I.TotalWon > 500000 
					OR		I.TotalBillIn > 50000 
					OR		I.TotalCoinIn > 200 
					OR		I.TotalTicketIn > 1000000 
					OR		I.TotalHandPay > 6000000 
					OR		I.TotalTicketOut > 1000000 
					OR		I.Tax > 50000 
					THEN	1 
					ELSE	0 
				END
			,I.TicketCode
			,I.FlagMinVltCredit
			,I.SessionID
	FROM
	(
		SELECT 
				T.c.value('@RowID', 'int') AS RowID
				,T.c.value('@UnivocalLocationCode', 'varchar(30)') AS UnivocalLocationCode
				,T.c.value('@ServerTime', 'datetime2(3)') AS ServerTime
				,T.c.value('@MachineID', 'tinyint') AS MachineID
				,T.c.value('@GD', 'varchar(30)') AS GD
				,T.c.value('@AamsMachineCode', 'varchar(30)') AS AamsMachineCode
				,T.c.value('@GameID', 'int') AS GameID
				,T.c.value('@GameName', 'varchar(100)') AS GameName
				,T.c.value('@LoginFlag', 'bit') AS LoginFlag
				,T.c.value('@VLTCredit', 'int') AS VLTCredit
				,T.c.value('@TotalBet', 'int') AS TotalBet
				,T.c.value('@TotalWon', 'int') AS TotalWon
				,T.c.value('@TotalBillIn', 'int') AS TotalBillIn
				,T.c.value('@TotalCoinIn', 'int') AS TotalCoinIn
				,T.c.value('@TotalTicketIn', 'int') AS TotalTicketIn
				,T.c.value('@TotalHandPay', 'int') AS TotalHandPay
				,T.c.value('@TotalTicketOut', 'int') AS TotalTicketOut
				,T.c.value('@Tax', 'int') AS Tax
				,T.c.value('@TotalIn', 'int') AS TotalIn
				,T.c.value('@TotalOut', 'int') AS TotalOut
				,T.c.value('@WrongFlag', 'bit') AS WrongFlag
				,T.c.value('@TicketCode', 'varchar(50)') AS TicketCode
				,T.c.value('@FlagMinVltCredit', 'bit') AS FlagMinVltCredit
				,T.c.value('@SessionID', 'int') AS SessionID
		FROM	@XMLRD.nodes('XRD') AS T(c)
	) I 
) 
