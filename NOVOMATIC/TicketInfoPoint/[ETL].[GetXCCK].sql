/*
DECLARE @XCCK XML -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)

SET	@XCCK = ETL.WriteXCCK(@XCCK, '391378593917118854', 0, 1234, 1233, 1) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XCCK = ETL.WriteXCCK(@XCCK, '391378593917118855', 1, 12345, 12344, 2) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XCCK = ETL.WriteXCCK(@XCCK, '391378593917118856', 0, 123456, 123455, 2) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XCCK = ETL.WriteXCCK(@XCCK, '391378593917118857', 0, 1234567, 1234566, 3) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE

--SELECT * FROM ETL.GetXCCK(@XCCK, @ClubID,@MachineID,@FromOut,@ToOut,@TotalBet,@TotalWon,@WinD,@TotalBillIn,@TotalCoinIn,@TotalTicketIn,@TotalTicketOut,@TotalHandPay,@TotalOut,@TotalIn) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetXCCK(@XCCK, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
*/
ALTER	FUNCTION [ETL].[GetXCCK](
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
RETURNS @returnCCK TABLE(
		ClubID int NOT NULL
		,MachineID tinyint NULL
		,FromOut datetime NULL
		,ToOut datetime2(3) NULL
		,TotalBet bigint NULL
		,TotalWon bigint NULL
		,WinD bigint NULL
		,TotalBillIn bigint NULL
		,TotalCoinIn bigint NULL
		,TotalTicketIn bigint NULL
		,TotalTicketOut bigint NULL
		,TotalHandPay bigint NULL
		,TotalOut bigint NULL
		,TotalIn bigint NULL
)		
AS
BEGIN
	INSERT	@returnCCK
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
	FROM
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
	) I
	WHERE	(ClubID = @ClubID OR @ClubID IS NULL)
	AND		(MachineID = @MachineID OR @MachineID IS NULL)
	AND		(FromOut = @FromOut OR @FromOut IS NULL)
	AND		(ToOut = @ToOut OR @ToOut IS NULL)
	AND		(TotalBet = @TotalBet OR @TotalBet IS NULL)
	AND		(TotalWon = @TotalWon OR @TotalWon IS NULL)
	AND		(WinD = @WinD OR @WinD IS NULL)
	AND		(TotalBillIn = @TotalBillIn OR @TotalBillIn IS NULL)
	AND		(TotalCoinIn = @TotalCoinIn OR @TotalCoinIn IS NULL)
	AND		(TotalTicketIn = @TotalTicketIn OR @TotalTicketIn IS NULL)
	AND		(TotalTicketOut = @TotalTicketOut OR @TotalTicketOut IS NULL)
	AND		(TotalHandPay = @TotalHandPay OR @TotalHandPay IS NULL)
	AND		(TotalOut = @TotalOut OR @TotalOut IS NULL)
	AND		(TotalIn = @TotalIn OR @TotalIn IS NULL)

	RETURN
END
