CREATE TABLE __RAWDATA__ (RowID numeric, ServerTime datetime, MachineTime datetime, MachineID tinyint, GameID int, LoginFlag bit, TotalBet int, Win int SPARSE, GamesPlayed int SPARSE, GamesWon int SPARSE, TotalHandpay int SPARSE, TotalHPCC int SPARSE, TotalJPCC int SPARSE, TotalRemote int SPARSE, TotalWon int SPARSE, TotalDrop int SPARSE, TotalIn int SPARSE, TotalOut int SPARSE, TotalBillIn int SPARSE, TotalBillChange int SPARSE, TotalCoinIn int SPARSE, TotalCoinInDrop int SPARSE, TotalCoinInHopper int SPARSE, TotalHopperOut int SPARSE, TotalHopperFill int SPARSE, TotalTicketIn int SPARSE, TotalTicketOut int SPARSE, TotalBillInNumber int SPARSE, BillIn1 smallint SPARSE, BillIn2 smallint SPARSE, BillIn3 smallint SPARSE, BillIn4 smallint SPARSE, BillIn5 smallint SPARSE, BillIn6 smallint SPARSE, BillIn7 smallint SPARSE, BillIn8 smallint SPARSE, TotalBillChangeNumber smallint SPARSE, BillChange1 smallint SPARSE, BillChange2 smallint SPARSE, BillChange3 smallint SPARSE, BillChange4 smallint SPARSE, BillChange5 smallint SPARSE, BillChange6 smallint SPARSE, BillChange7 smallint SPARSE, TotalCoinInNumber smallint SPARSE, CoinIn3 smallint SPARSE, CoinIn4 smallint SPARSE, CoinIn5 smallint SPARSE, CoinIn6 smallint SPARSE, CoinIn7 smallint SPARSE, CoinIn8 smallint SPARSE, TotalCoinInDropNumber smallint SPARSE, CoinInDrop3 smallint SPARSE, CoinInDrop4 smallint SPARSE, CoinInDrop5 smallint SPARSE, CoinInDrop6 smallint SPARSE, CoinInDrop7 smallint SPARSE, CoinInDrop8 smallint SPARSE, TotalCoinInHopperNumber int SPARSE, CoinInHopper3 int SPARSE, CoinInHopper4 int SPARSE, TicketInA int SPARSE, TicketInB int SPARSE, TicketInC int SPARSE, TicketOutA int SPARSE, TicketOutB int SPARSE, TicketOutC int SPARSE, CurrentCreditA int SPARSE, CurrentCreditB int SPARSE, CurrentCreditC int SPARSE, TotalBetA int SPARSE, TotalBetB int SPARSE, TotalBetC int SPARSE, WinA int SPARSE, WinB int SPARSE, WinC int SPARSE, WinD int SPARSE, TotalHPCCA int SPARSE)

CREATE INDEX	ix_TotalIN_TotalOUT_TotalTicketIN_TotalTicketOUT 
ON __RAWDATA__(TotalIN, TotalOUT, TotalTicketIN, TotalTicketOUT) 
INCLUDE (RowID, ServerTime, MachineID, LoginFlag)
WHERE	TotalHandpay IS NOT NULL
AND		TotalIN IS NOT NULL 
AND		TotalOUT IS NOT NULL 
AND		TotalTicketIN IS NOT NULL 
AND		TotalTicketOUT IS NOT NULL

-- EXECUTION TIME: 07:05:31 (129.354.132 row(s) affected)
INSERT __RAWDATA__(RowID, ServerTime, MachineTime, MachineID, GameID, LoginFlag, TotalBet, Win, GamesPlayed, GamesWon, TotalHandpay, TotalHPCC, TotalJPCC, TotalRemote, TotalWon, TotalDrop, TotalIn, TotalOut, TotalBillIn, TotalBillChange, TotalCoinIn, TotalCoinInDrop, TotalCoinInHopper, TotalHopperOut, TotalHopperFill, TotalTicketIn, TotalTicketOut, TotalBillInNumber, BillIn1, BillIn2, BillIn3, BillIn4, BillIn5, BillIn6, BillIn7, BillIn8, TotalBillChangeNumber, BillChange1, BillChange2, BillChange3, BillChange4, BillChange5, BillChange6, BillChange7, TotalCoinInNumber, CoinIn3, CoinIn4, CoinIn5, CoinIn6, CoinIn7, CoinIn8, TotalCoinInDropNumber, CoinInDrop3, CoinInDrop4, CoinInDrop5, CoinInDrop6, CoinInDrop7, CoinInDrop8, TotalCoinInHopperNumber, CoinInHopper3, CoinInHopper4, TicketInA, TicketInB, TicketInC, TicketOutA, TicketOutB, TicketOutC, CurrentCreditA, CurrentCreditB, CurrentCreditC, TotalBetA, TotalBetB, TotalBetC, WinA, WinB, WinC, WinD, TotalHPCCA) 
SELECT RowID, ServerTime, MachineTime, MachineID, GameID, LoginFlag, TotalBet, Win, GamesPlayed, GamesWon, TotalHandpay, TotalHPCC, TotalJPCC, TotalRemote, TotalWon, TotalDrop, TotalIn, TotalOut, TotalBillIn, TotalBillChange, TotalCoinIn, TotalCoinInDrop, TotalCoinInHopper, TotalHopperOut, TotalHopperFill, TotalTicketIn, TotalTicketOut, TotalBillInNumber, BillIn1, BillIn2, BillIn3, BillIn4, BillIn5, BillIn6, BillIn7, BillIn8, TotalBillChangeNumber, BillChange1, BillChange2, BillChange3, BillChange4, BillChange5, BillChange6, BillChange7, TotalCoinInNumber, CoinIn3, CoinIn4, CoinIn5, CoinIn6, CoinIn7, CoinIn8, TotalCoinInDropNumber, CoinInDrop3, CoinInDrop4, CoinInDrop5, CoinInDrop6, CoinInDrop7, CoinInDrop8, TotalCoinInHopperNumber, CoinInHopper3, CoinInHopper4, TicketInA, TicketInB, TicketInC, TicketOutA, TicketOutB, TicketOutC, CurrentCreditA, CurrentCreditB, CurrentCreditC, TotalBetA, TotalBetB, TotalBetC, WinA, WinB, WinC, WinD, TotalHPCCA
 FROM [GMATICA_AGS_RawData_Elaborate_Stag_Agile].[TMP].[RawData_View]
