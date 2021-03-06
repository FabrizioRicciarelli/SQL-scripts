/*
DECLARE @XRAW XML -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)
SELECT * FROM ETL.GetXRAW(@XRAW, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI

SELECT * FROM ETL.GetXRAW(@XRAW, @RowID,@ServerTime,@MachineTime,@MachineID,@GameID,@LoginFlag,@TotalBet,@Win,@GamesPlayed,@GamesWon,@TotalHandpay,@TotalHPCC,@TotalJPCC,@TotalRemote,@TotalWon,@TotalDrop,@TotalIn,@TotalOut,@TotalBillIn,@TotalBillChange,@TotalCoinIn,@TotalCoinInDrop,@TotalCoinInHopper,@TotalHopperOut,@TotalHopperFill,@TotalTicketIn,@TotalTicketOut,@TotalBillInNumber,@BillIn1,@BillIn2,@BillIn3,@BillIn4,@BillIn5,@BillIn6,@BillIn7,@BillIn8,@TotalBillChangeNumber,@BillChange1,@BillChange2,@BillChange3,@BillChange4,@BillChange5,@BillChange6,@BillChange7,@TotalCoinInNumber,@CoinIn3,@CoinIn4,@CoinIn5,@CoinIn6,@CoinIn7,@CoinIn8,@TotalCoinInDropNumber,@CoinInDrop3,@CoinInDrop4,@CoinInDrop5,@CoinInDrop6,@CoinInDrop7,@CoinInDrop8,@TotalCoinInHopperNumber,@CoinInHopper3,@CoinInHopper4,@TicketInA,@TicketInB,@TicketInC,@TicketOutA,@TicketOutB,@TicketOutC,@CurrentCreditA,@CurrentCreditB,@CurrentCreditC,@TotalBetA,@TotalBetB,@TotalBetC,@WinA,@WinB,@WinC,@WinD,@TotalHPCCA) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
*/
ALTER	FUNCTION [ETL].[GetXRAW](
		@XMLraw XML = NULL
		,@RowID int = NULL -- NOT = NULL
		,@ServerTime datetime = NULL -- NULLABLE
		,@MachineTime datetime = NULL -- NULLABLE
		,@MachineID tinyint = NULL -- NULLABLE
		,@GameID int = NULL -- NULLABLE
		,@LoginFlag bit = NULL -- NULLABLE
		,@TotalBet int = NULL -- NULLABLE
		,@Win int = NULL -- NULLABLE
		,@GamesPlayed int = NULL -- NULLABLE
		,@GamesWon int = NULL -- NULLABLE
		,@TotalHandpay int = NULL -- NULLABLE
		,@TotalHPCC int = NULL -- NULLABLE
		,@TotalJPCC int = NULL -- NULLABLE
		,@TotalRemote int = NULL -- NULLABLE
		,@TotalWon int = NULL -- NULLABLE
		,@TotalDrop int = NULL -- NULLABLE
		,@TotalIn int = NULL -- NULLABLE
		,@TotalOut int = NULL -- NULLABLE
		,@TotalBillIn int = NULL -- NULLABLE
		,@TotalBillChange int = NULL -- NULLABLE
		,@TotalCoinIn int = NULL -- NULLABLE
		,@TotalCoinInDrop int = NULL -- NULLABLE
		,@TotalCoinInHopper int = NULL -- NULLABLE
		,@TotalHopperOut int = NULL -- NULLABLE
		,@TotalHopperFill int = NULL -- NULLABLE
		,@TotalTicketIn int = NULL -- NULLABLE
		,@TotalTicketOut int = NULL -- NULLABLE
		,@TotalBillInNumber int = NULL -- NULLABLE
		,@BillIn1 smallint = NULL -- NULLABLE
		,@BillIn2 smallint = NULL -- NULLABLE
		,@BillIn3 smallint = NULL -- NULLABLE
		,@BillIn4 smallint = NULL -- NULLABLE
		,@BillIn5 smallint = NULL -- NULLABLE
		,@BillIn6 smallint = NULL -- NULLABLE
		,@BillIn7 smallint = NULL -- NULLABLE
		,@BillIn8 smallint = NULL -- NULLABLE
		,@TotalBillChangeNumber smallint = NULL -- NULLABLE
		,@BillChange1 smallint = NULL -- NULLABLE
		,@BillChange2 smallint = NULL -- NULLABLE
		,@BillChange3 smallint = NULL -- NULLABLE
		,@BillChange4 smallint = NULL -- NULLABLE
		,@BillChange5 smallint = NULL -- NULLABLE
		,@BillChange6 smallint = NULL -- NULLABLE
		,@BillChange7 smallint = NULL -- NULLABLE
		,@TotalCoinInNumber smallint = NULL -- NULLABLE
		,@CoinIn3 smallint = NULL -- NULLABLE
		,@CoinIn4 smallint = NULL -- NULLABLE
		,@CoinIn5 smallint = NULL -- NULLABLE
		,@CoinIn6 smallint = NULL -- NULLABLE
		,@CoinIn7 smallint = NULL -- NULLABLE
		,@CoinIn8 smallint = NULL -- NULLABLE
		,@TotalCoinInDropNumber smallint = NULL -- NULLABLE
		,@CoinInDrop3 smallint = NULL -- NULLABLE
		,@CoinInDrop4 smallint = NULL -- NULLABLE
		,@CoinInDrop5 smallint = NULL -- NULLABLE
		,@CoinInDrop6 smallint = NULL -- NULLABLE
		,@CoinInDrop7 smallint = NULL -- NULLABLE
		,@CoinInDrop8 smallint = NULL -- NULLABLE
		,@TotalCoinInHopperNumber int = NULL -- NULLABLE
		,@CoinInHopper3 int = NULL -- NULLABLE
		,@CoinInHopper4 int = NULL -- NULLABLE
		,@TicketInA int = NULL -- NULLABLE
		,@TicketInB int = NULL -- NULLABLE
		,@TicketInC int = NULL -- NULLABLE
		,@TicketOutA int = NULL -- NULLABLE
		,@TicketOutB int = NULL -- NULLABLE
		,@TicketOutC int = NULL -- NULLABLE
		,@CurrentCreditA int = NULL -- NULLABLE
		,@CurrentCreditB int = NULL -- NULLABLE
		,@CurrentCreditC int = NULL -- NULLABLE
		,@TotalBetA int = NULL -- NULLABLE
		,@TotalBetB int = NULL -- NULLABLE
		,@TotalBetC int = NULL -- NULLABLE
		,@WinA int = NULL -- NULLABLE
		,@WinB int = NULL -- NULLABLE
		,@WinC int = NULL -- NULLABLE
		,@WinD int = NULL -- NULLABLE
		,@TotalHPCCA int = NULL -- NULLABLE
)
RETURNS @returnRAW TABLE(
		RowID int NULL
		,ServerTime datetime NULL
		,MachineTime datetime NULL
		,MachineID tinyint NULL
		,GameID int NULL
		,LoginFlag bit NULL
		,TotalBet int NULL
		,Win int NULL
		,GamesPlayed int NULL
		,GamesWon int NULL
		,TotalHandpay int NULL
		,TotalHPCC int NULL
		,TotalJPCC int NULL
		,TotalRemote int NULL
		,TotalWon int NULL
		,TotalDrop int NULL
		,TotalIn int NULL
		,TotalOut int NULL
		,TotalBillIn int NULL
		,TotalBillChange int NULL
		,TotalCoinIn int NULL
		,TotalCoinInDrop int NULL
		,TotalCoinInHopper int NULL
		,TotalHopperOut int NULL
		,TotalHopperFill int NULL
		,TotalTicketIn int NULL
		,TotalTicketOut int NULL
		,TotalBillInNumber int NULL
		,BillIn1 smallint NULL
		,BillIn2 smallint NULL
		,BillIn3 smallint NULL
		,BillIn4 smallint NULL
		,BillIn5 smallint NULL
		,BillIn6 smallint NULL
		,BillIn7 smallint NULL
		,BillIn8 smallint NULL
		,TotalBillChangeNumber smallint NULL
		,BillChange1 smallint NULL
		,BillChange2 smallint NULL
		,BillChange3 smallint NULL
		,BillChange4 smallint NULL
		,BillChange5 smallint NULL
		,BillChange6 smallint NULL
		,BillChange7 smallint NULL
		,TotalCoinInNumber smallint NULL
		,CoinIn3 smallint NULL
		,CoinIn4 smallint NULL
		,CoinIn5 smallint NULL
		,CoinIn6 smallint NULL
		,CoinIn7 smallint NULL
		,CoinIn8 smallint NULL
		,TotalCoinInDropNumber smallint NULL
		,CoinInDrop3 smallint NULL
		,CoinInDrop4 smallint NULL
		,CoinInDrop5 smallint NULL
		,CoinInDrop6 smallint NULL
		,CoinInDrop7 smallint NULL
		,CoinInDrop8 smallint NULL
		,TotalCoinInHopperNumber int NULL
		,CoinInHopper3 int NULL
		,CoinInHopper4 int NULL
		,TicketInA int NULL
		,TicketInB int NULL
		,TicketInC int NULL
		,TicketOutA int NULL
		,TicketOutB int NULL
		,TicketOutC int NULL
		,CurrentCreditA int NULL
		,CurrentCreditB int NULL
		,CurrentCreditC int NULL
		,TotalBetA int NULL
		,TotalBetB int NULL
		,TotalBetC int NULL
		,WinA int NULL
		,WinB int NULL
		,WinC int NULL
		,WinD int NULL
		,TotalHPCCA int NULL
)
AS
BEGIN
	INSERT	@returnRAW
	SELECT
			 I.RowID 
			,I.ServerTime 
			,I.MachineTime 
			,I.MachineID 
			,I.GameID 
			,I.LoginFlag 
			,I.TotalBet 
			,I.Win 
			,I.GamesPlayed 
			,I.GamesWon 
			,I.TotalHandpay 
			,I.TotalHPCC 
			,I.TotalJPCC 
			,I.TotalRemote 
			,I.TotalWon 
			,I.TotalDrop 
			,I.TotalIn 
			,I.TotalOut 
			,I.TotalBillIn 
			,I.TotalBillChange 
			,I.TotalCoinIn 
			,I.TotalCoinInDrop 
			,I.TotalCoinInHopper 
			,I.TotalHopperOut 
			,I.TotalHopperFill 
			,I.TotalTicketIn 
			,I.TotalTicketOut 
			,I.TotalBillInNumber 
			,I.BillIn1 
			,I.BillIn2 
			,I.BillIn3 
			,I.BillIn4 
			,I.BillIn5 
			,I.BillIn6 
			,I.BillIn7 
			,I.BillIn8 
			,I.TotalBillChangeNumber 
			,I.BillChange1 
			,I.BillChange2 
			,I.BillChange3 
			,I.BillChange4 
			,I.BillChange5 
			,I.BillChange6 
			,I.BillChange7 
			,I.TotalCoinInNumber 
			,I.CoinIn3 
			,I.CoinIn4 
			,I.CoinIn5 
			,I.CoinIn6 
			,I.CoinIn7 
			,I.CoinIn8 
			,I.TotalCoinInDropNumber 
			,I.CoinInDrop3 
			,I.CoinInDrop4 
			,I.CoinInDrop5 
			,I.CoinInDrop6 
			,I.CoinInDrop7 
			,I.CoinInDrop8 
			,I.TotalCoinInHopperNumber 
			,I.CoinInHopper3 
			,I.CoinInHopper4 
			,I.TicketInA 
			,I.TicketInB 
			,I.TicketInC 
			,I.TicketOutA 
			,I.TicketOutB 
			,I.TicketOutC 
			,I.CurrentCreditA 
			,I.CurrentCreditB 
			,I.CurrentCreditC 
			,I.TotalBetA 
			,I.TotalBetB 
			,I.TotalBetC 
			,I.WinA 
			,I.WinB 
			,I.WinC 
			,I.WinD 
			,I.TotalHPCCA 
	FROM
	(
		SELECT 
				T.c.value('@RowID', 'int') AS RowID
				,T.c.value('@ServerTime', 'datetime') AS ServerTime
				,T.c.value('@MachineTime', 'datetime') AS MachineTime
				,T.c.value('@MachineID', 'tinyint') AS MachineID
				,T.c.value('@GameID', 'int') AS GameID
				,T.c.value('@LoginFlag', 'bit') AS LoginFlag
				,T.c.value('@TotalBet', 'int') AS TotalBet
				,T.c.value('@Win', 'int') AS Win
				,T.c.value('@GamesPlayed', 'int') AS GamesPlayed
				,T.c.value('@GamesWon', 'int') AS GamesWon
				,T.c.value('@TotalHandpay', 'int') AS TotalHandpay
				,T.c.value('@TotalHPCC', 'int') AS TotalHPCC
				,T.c.value('@TotalJPCC', 'int') AS TotalJPCC
				,T.c.value('@TotalRemote', 'int') AS TotalRemote
				,T.c.value('@TotalWon', 'int') AS TotalWon
				,T.c.value('@TotalDrop', 'int') AS TotalDrop
				,T.c.value('@TotalIn', 'int') AS TotalIn
				,T.c.value('@TotalOut', 'int') AS TotalOut
				,T.c.value('@TotalBillIn', 'int') AS TotalBillIn
				,T.c.value('@TotalBillChange', 'int') AS TotalBillChange
				,T.c.value('@TotalCoinIn', 'int') AS TotalCoinIn
				,T.c.value('@TotalCoinInDrop', 'int') AS TotalCoinInDrop
				,T.c.value('@TotalCoinInHopper', 'int') AS TotalCoinInHopper
				,T.c.value('@TotalHopperOut', 'int') AS TotalHopperOut
				,T.c.value('@TotalHopperFill', 'int') AS TotalHopperFill
				,T.c.value('@TotalTicketIn', 'int') AS TotalTicketIn
				,T.c.value('@TotalTicketOut', 'int') AS TotalTicketOut
				,T.c.value('@TotalBillInNumber', 'int') AS TotalBillInNumber
				,T.c.value('@BillIn1', 'smallint') AS BillIn1
				,T.c.value('@BillIn2', 'smallint') AS BillIn2
				,T.c.value('@BillIn3', 'smallint') AS BillIn3
				,T.c.value('@BillIn4', 'smallint') AS BillIn4
				,T.c.value('@BillIn5', 'smallint') AS BillIn5
				,T.c.value('@BillIn6', 'smallint') AS BillIn6
				,T.c.value('@BillIn7', 'smallint') AS BillIn7
				,T.c.value('@BillIn8', 'smallint') AS BillIn8
				,T.c.value('@TotalBillChangeNumber', 'smallint') AS TotalBillChangeNumber
				,T.c.value('@BillChange1', 'smallint') AS BillChange1
				,T.c.value('@BillChange2', 'smallint') AS BillChange2
				,T.c.value('@BillChange3', 'smallint') AS BillChange3
				,T.c.value('@BillChange4', 'smallint') AS BillChange4
				,T.c.value('@BillChange5', 'smallint') AS BillChange5
				,T.c.value('@BillChange6', 'smallint') AS BillChange6
				,T.c.value('@BillChange7', 'smallint') AS BillChange7
				,T.c.value('@TotalCoinInNumber', 'smallint') AS TotalCoinInNumber 
				,T.c.value('@CoinIn3', 'smallint') AS CoinIn3
				,T.c.value('@CoinIn4', 'smallint') AS CoinIn4
				,T.c.value('@CoinIn5', 'smallint') AS CoinIn5
				,T.c.value('@CoinIn6', 'smallint') AS CoinIn6
				,T.c.value('@CoinIn7', 'smallint') AS CoinIn7
				,T.c.value('@CoinIn8', 'smallint') AS CoinIn8
				,T.c.value('@TotalCoinInDropNumber', 'smallint') AS TotalCoinInDropNumber
				,T.c.value('@CoinInDrop3', 'smallint') AS CoinInDrop3
				,T.c.value('@CoinInDrop4', 'smallint') AS CoinInDrop4
				,T.c.value('@CoinInDrop5', 'smallint') AS CoinInDrop5
				,T.c.value('@CoinInDrop6', 'smallint') AS CoinInDrop6
				,T.c.value('@CoinInDrop7', 'smallint') AS CoinInDrop7
				,T.c.value('@CoinInDrop8', 'smallint') AS CoinInDrop8
				,T.c.value('@TotalCoinInHopperNumber', 'int') AS TotalCoinInHopperNumber
				,T.c.value('@CoinInHopper3', 'int') AS CoinInHopper3
				,T.c.value('@CoinInHopper4', 'int') AS CoinInHopper4
				,T.c.value('@TicketInA', 'int') AS TicketInA
				,T.c.value('@TicketInB', 'int') AS TicketInB
				,T.c.value('@TicketInC', 'int') AS TicketInC
				,T.c.value('@TicketOutA', 'int') AS TicketOutA
				,T.c.value('@TicketOutB', 'int') AS TicketOutB
				,T.c.value('@TicketOutC', 'int') AS TicketOutC
				,T.c.value('@CurrentCreditA', 'int') AS CurrentCreditA
				,T.c.value('@CurrentCreditB', 'int') AS CurrentCreditB
				,T.c.value('@CurrentCreditC', 'int') AS CurrentCreditC
				,T.c.value('@TotalBetA', 'int') AS TotalBetA
				,T.c.value('@TotalBetB', 'int') AS TotalBetB
				,T.c.value('@TotalBetC', 'int') AS TotalBetC
				,T.c.value('@WinA', 'int') AS WinA
				,T.c.value('@WinB', 'int') AS WinB
				,T.c.value('@WinC', 'int') AS WinC
				,T.c.value('@WinD', 'int') AS WinD
				,T.c.value('@TotalHPCCA', 'int') AS TotalHPCCA
		FROM	@XMLraw.nodes('RAWDATA') AS T(c) 
	) I
	WHERE	(RowID = @RowID OR @RowID IS NULL)
	AND		(ServerTime = @ServerTime OR @ServerTime IS NULL)
	AND		(MachineTime = @MachineTime OR @MachineTime IS NULL)
	AND		(MachineID = @MachineID OR @MachineID IS NULL)
	AND		(GameID = @GameID OR @GameID IS NULL)
	AND		(LoginFlag = @LoginFlag OR @LoginFlag IS NULL)
	AND		(TotalBet = @TotalBet OR @TotalBet IS NULL)
	AND		(Win = @Win OR @Win IS NULL)
	AND		(GamesPlayed = @GamesPlayed OR @GamesPlayed IS NULL)
	AND		(GamesWon = @GamesWon OR @GamesWon IS NULL)
	AND		(TotalHandpay = @TotalHandpay OR @TotalHandpay IS NULL)
	AND		(TotalHPCC = @TotalHPCC OR @TotalHPCC IS NULL)
	AND		(TotalJPCC = @TotalJPCC OR @TotalJPCC IS NULL)
	AND		(TotalRemote = @TotalRemote OR @TotalRemote IS NULL)
	AND		(TotalWon = @TotalWon OR @TotalWon IS NULL)
	AND		(TotalDrop = @TotalDrop OR @TotalDrop IS NULL)
	AND		(TotalIn = @TotalIn OR @TotalIn IS NULL)
	AND		(TotalOut = @TotalOut OR @TotalOut IS NULL)
	AND		(TotalBillIn = @TotalBillIn OR @TotalBillIn IS NULL)
	AND		(TotalBillChange = @TotalBillChange OR @TotalBillChange IS NULL)
	AND		(TotalCoinIn = @TotalCoinIn OR @TotalCoinIn IS NULL)
	AND		(TotalCoinInDrop = @TotalCoinInDrop OR @TotalCoinInDrop IS NULL)
	AND		(TotalCoinInHopper = @TotalCoinInHopper OR @TotalCoinInHopper IS NULL)
	AND		(TotalHopperOut = @TotalHopperOut OR @TotalHopperOut IS NULL)
	AND		(TotalHopperFill = @TotalHopperFill OR @TotalHopperFill IS NULL)
	AND		(TotalTicketIn = @TotalTicketIn OR @TotalTicketIn IS NULL)
	AND		(TotalTicketOut = @TotalTicketOut OR @TotalTicketOut IS NULL)
	AND		(TotalBillInNumber = @TotalBillInNumber OR @TotalBillInNumber IS NULL)
	AND		(BillIn1 = @BillIn1 OR @BillIn1 IS NULL)
	AND		(BillIn2 = @BillIn2 OR @BillIn2 IS NULL)
	AND		(BillIn3 = @BillIn3 OR @BillIn3 IS NULL)
	AND		(BillIn4 = @BillIn4 OR @BillIn4 IS NULL)
	AND		(BillIn5 = @BillIn5 OR @BillIn5 IS NULL)
	AND		(BillIn6 = @BillIn6 OR @BillIn6 IS NULL)
	AND		(BillIn7 = @BillIn7 OR @BillIn7 IS NULL)
	AND		(BillIn8 = @BillIn8 OR @BillIn8 IS NULL)
	AND		(TotalBillChangeNumber = @TotalBillChangeNumber OR @TotalBillChangeNumber IS NULL)
	AND		(BillChange1 = @BillChange1 OR @BillChange1 IS NULL)
	AND		(BillChange2 = @BillChange2 OR @BillChange2 IS NULL)
	AND		(BillChange3 = @BillChange3 OR @BillChange3 IS NULL)
	AND		(BillChange4 = @BillChange4 OR @BillChange4 IS NULL)
	AND		(BillChange5 = @BillChange5 OR @BillChange5 IS NULL)
	AND		(BillChange6 = @BillChange6 OR @BillChange6 IS NULL)
	AND		(BillChange7 = @BillChange7 OR @BillChange7 IS NULL)
	AND		(TotalCoinInNumber = @TotalCoinInNumber OR @TotalCoinInNumber IS NULL)
	AND		(CoinIn3 = @CoinIn3 OR @CoinIn3 IS NULL)
	AND		(CoinIn4 = @CoinIn4 OR @CoinIn4 IS NULL)
	AND		(CoinIn5 = @CoinIn5 OR @CoinIn5 IS NULL)
	AND		(CoinIn6 = @CoinIn6 OR @CoinIn6 IS NULL)
	AND		(CoinIn7 = @CoinIn7 OR @CoinIn7 IS NULL)
	AND		(CoinIn8 = @CoinIn8 OR @CoinIn8 IS NULL)
	AND		(TotalCoinInDropNumber = @TotalCoinInDropNumber OR @TotalCoinInDropNumber IS NULL)
	AND		(CoinInDrop3 = @CoinInDrop3 OR @CoinInDrop3 IS NULL)
	AND		(CoinInDrop4 = @CoinInDrop4 OR @CoinInDrop4 IS NULL)
	AND		(CoinInDrop5 = @CoinInDrop5 OR @CoinInDrop5 IS NULL)
	AND		(CoinInDrop6 = @CoinInDrop6 OR @CoinInDrop6 IS NULL)
	AND		(CoinInDrop7 = @CoinInDrop7 OR @CoinInDrop7 IS NULL)
	AND		(CoinInDrop8 = @CoinInDrop8 OR @CoinInDrop8 IS NULL)
	AND		(TotalCoinInHopperNumber = @TotalCoinInHopperNumber OR @TotalCoinInHopperNumber IS NULL)
	AND		(CoinInHopper3 = @CoinInHopper3 OR @CoinInHopper3 IS NULL)
	AND		(CoinInHopper4 = @CoinInHopper4 OR @CoinInHopper4 IS NULL)
	AND		(TicketInA = @TicketInA OR @TicketInA IS NULL)
	AND		(TicketInB = @TicketInB OR @TicketInB IS NULL)
	AND		(TicketInC = @TicketInC OR @TicketInC IS NULL)
	AND		(TicketOutA = @TicketOutA OR @TicketOutA IS NULL)
	AND		(TicketOutB = @TicketOutB OR @TicketOutB IS NULL)
	AND		(TicketOutC = @TicketOutC OR @TicketOutC IS NULL)
	AND		(CurrentCreditA = @CurrentCreditA OR @CurrentCreditA IS NULL)
	AND		(CurrentCreditB = @CurrentCreditB OR @CurrentCreditB IS NULL)
	AND		(CurrentCreditC = @CurrentCreditC OR @CurrentCreditC IS NULL)
	AND		(TotalBetA = @TotalBetA OR @TotalBetA IS NULL)
	AND		(TotalBetB = @TotalBetB OR @TotalBetB IS NULL)
	AND		(TotalBetC = @TotalBetC OR @TotalBetC IS NULL)
	AND		(WinA = @WinA OR @WinA IS NULL)
	AND		(WinB = @WinB OR @WinB IS NULL)
	AND		(WinC = @WinC OR @WinC IS NULL)
	AND		(WinD = @WinD OR @WinD IS NULL)
	AND		(TotalHPCCA = @TotalHPCCA OR @TotalHPCCA IS NULL)

	RETURN
END
