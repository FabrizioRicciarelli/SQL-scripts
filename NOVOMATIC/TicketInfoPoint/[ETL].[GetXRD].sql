/*
DECLARE @XRD XML -- VUOTO
SET @XRD ='<XRD RowID="-2043978766" UnivocalLocationCode="EA110086040A" ServerTime="2017-10-21T15:03:26.150" MachineID="11" GD="GD014017380" AamsMachineCode="D0000004379" GameID="-146039307" GameName="Book Of Ra" LoginFlag="0" VLTCredit="1050" TotalBet="100" TicketCode="0" SessionID="-2147483641"/>'
SELECT * FROM ETL.GetXRD(@XRD, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI

DECLARE @XRD XML -- VUOTO
SET	@XRD = ETL.WriteXRD(@XRD, -2043978769, 'EA110086040A', '2017-10-21 15:03:24.043', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 0, 1150, 100, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XRD = ETL.WriteXRD(@XRD, -2043978766, 'EA110086040A', '2017-10-21 15:03:26.150', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 0, 1050, 100, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XRD = ETL.WriteXRD(@XRD, -2043978761, 'EA110086040A', '2017-10-21 15:03:29.447', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 0, 1000, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XRD = ETL.WriteXRD(@XRD, -2043978755, 'EA110086040A', '2017-10-21 15:03:31.707', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 0, 950, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE

SELECT * FROM ETL.GetXRD(@XRD, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetXRD(@XRD, -2043978755, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetXRD(@XRD, NULL, 'EA110086040A', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetXRD(@XRD, NULL, NULL, '2017-10-21 15:03:31.707', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
PRINT(CONVERT(varchar(MAX),@XRD))
*/
ALTER	FUNCTION [ETL].[GetXRD](
		@XMLRD XML = NULL
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
RETURNS @returnRD TABLE(
		RowID int
		,UnivocalLocationCode varchar(30)
		,ServerTime datetime2(3)
		,MachineID tinyint
		,GD varchar(30)
		,AamsMachineCode varchar(30)
		,GameID int
		,GameName varchar(100)
		,LoginFlag bit
		,VLTCredit int
		,TotalBet int
		,TotalWon int
		,TotalBillIn int
		,TotalCoinIn int
		,TotalTicketIn int
		,TotalHandPay int
		,TotalTicketOut int
		,Tax int
		,TotalIn int
		,TotalOut int
		,WrongFlag bit
		,TicketCode varchar(50)
		,FlagMinVltCredit bit
		,SessionID int
)
AS
BEGIN
	INSERT	@returnRD
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
	WHERE	(RowID = @RowID OR @RowID IS NULL)
	AND		(UnivocalLocationCode = @UnivocalLocationCode OR @UnivocalLocationCode IS NULL)
	AND		(ServerTime = @ServerTime OR @ServerTime IS NULL)
	AND		(MachineID = @MachineID OR @MachineID IS NULL)
	AND		(GD = @GD OR @GD IS NULL)
	AND		(AamsMachineCode = @AamsMachineCode OR @AamsMachineCode IS NULL)
	AND		(GameID = @GameID OR @GameID IS NULL)
	AND		(GameName = @GameName OR @GameName IS NULL)
	AND		(LoginFlag = @LoginFlag OR @LoginFlag IS NULL)
	AND		(VLTCredit = @VLTCredit OR @VLTCredit IS NULL)
	AND		(TotalBet = @TotalBet OR @TotalBet IS NULL)
	AND		(TotalWon = @TotalWon OR @TotalWon IS NULL)
	AND		(TotalBillIn = @TotalBillIn OR @TotalBillIn IS NULL)
	AND		(TotalCoinIn = @TotalCoinIn OR @TotalCoinIn IS NULL)
	AND		(TotalTicketIn = @TotalTicketIn OR @TotalTicketIn IS NULL)
	AND		(TotalHandPay = @TotalHandPay OR @TotalHandPay IS NULL)
	AND		(TotalTicketOut = @TotalTicketOut OR @TotalTicketOut IS NULL)
	AND		(Tax = @Tax OR @Tax IS NULL)
	AND		(TotalIn = @TotalIn OR @TotalIn IS NULL)
	AND		(TotalOut = @TotalOut OR @TotalOut IS NULL)
	AND		(WrongFlag = @WrongFlag OR @WrongFlag IS NULL)
	AND		(TicketCode = @TicketCode OR @TicketCode IS NULL)
	AND		(FlagMinVltCredit = @FlagMinVltCredit OR @FlagMinVltCredit IS NULL)
	AND		(SessionID = @SessionID OR @SessionID IS NULL)

	RETURN
END
