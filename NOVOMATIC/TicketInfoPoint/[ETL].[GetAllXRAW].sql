/*
DECLARE @XRAW XML -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)
SELECT * FROM ETL.GetXRAW(@XRAW)
--SELECT * FROM ETL.GetXRAW(@XRAW, @RowID,@ServerTime,@MachineTime,@MachineID,@GameID,@LoginFlag,@TotalBet,@Win,@GamesPlayed,@GamesWon,@TotalHandpay,@TotalHPCC,@TotalJPCC,@TotalRemote,@TotalWon,@TotalDrop,@TotalIn,@TotalOut,@TotalBillIn,@TotalBillChange,@TotalCoinIn,@TotalCoinInDrop,@TotalCoinInHopper,@TotalHopperOut,@TotalHopperFill,@TotalTicketIn,@TotalTicketOut,@TotalBillInNumber,@BillIn1,@BillIn2,@BillIn3,@BillIn4,@BillIn5,@BillIn6,@BillIn7,@BillIn8,@TotalBillChangeNumber,@BillChange1,@BillChange2,@BillChange3,@BillChange4,@BillChange5,@BillChange6,@BillChange7,@TotalCoinInNumber,@CoinIn3,@CoinIn4,@CoinIn5,@CoinIn6,@CoinIn7,@CoinIn8,@TotalCoinInDropNumber,@CoinInDrop3,@CoinInDrop4,@CoinInDrop5,@CoinInDrop6,@CoinInDrop7,@CoinInDrop8,@TotalCoinInHopperNumber,@CoinInHopper3,@CoinInHopper4,@TicketInA,@TicketInB,@TicketInC,@TicketOutA,@TicketOutB,@TicketOutC,@CurrentCreditA,@CurrentCreditB,@CurrentCreditC,@TotalBetA,@TotalBetB,@TotalBetC,@WinA,@WinB,@WinC,@WinD,@TotalHPCCA) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
*/
ALTER	FUNCTION [ETL].[GetAllXRAW](
		@XMLraw XML = NULL
)
RETURNS TABLE
AS
RETURN (
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
) 