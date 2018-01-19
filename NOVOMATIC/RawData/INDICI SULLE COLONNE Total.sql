USE [GMATICA_AGS_RawData];

CREATE NONCLUSTERED INDEX [IX_TotalOut_INCL_AllOthers]
ON [1000296].[RawData] ([TotalOut] DESC)
INCLUDE ([RowID],[ServerTime],[MachineTime],[MachineID],[GameID],[LoginFlag],[TotalBet],[Win],[GamesPlayed],[GamesWon],[TotalHandpay],[TotalHPCC],[TotalJPCC],[TotalRemote],[TotalWon],[TotalDrop],[TotalIn],[TotalBillIn],[TotalBillChange],[TotalCoinIn],[TotalCoinInDrop],[TotalCoinInHopper],[TotalHopperOut],[TotalHopperFill],[TotalTicketIn],[TotalTicketOut],[TotalBillInNumber],[BillIn1],[BillIn2],[BillIn3],[BillIn4],[BillIn5],[BillIn6],[BillIn7],[BillIn8],[TotalBillChangeNumber],[BillChange1],[BillChange2],[BillChange3],[BillChange4],[BillChange5],[BillChange6],[BillChange7],[TotalCoinInNumber],[CoinIn3],[CoinIn4],[CoinIn5],[CoinIn6],[CoinIn7],[CoinIn8],[TotalCoinInDropNumber],[CoinInDrop3],[CoinInDrop4],[CoinInDrop5],[CoinInDrop6],[CoinInDrop7],[CoinInDrop8],[TotalCoinInHopperNumber],[CoinInHopper3],[CoinInHopper4],[TicketInA],[TicketInB],[TicketInC],[TicketOutA],[TicketOutB],[TicketOutC],[CurrentCreditA],[CurrentCreditB],[CurrentCreditC],[TotalBetA],[TotalBetB],[TotalBetC],[WinA],[WinB],[WinC],[WinD],[TotalHPCCA])
WHERE TotalOut IS NOT NULL
WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [DatiRawData];
GO

CREATE NONCLUSTERED INDEX [IX_TotalHandpay_INCL_AllOthers]
ON [1000296].[RawData] ([TotalHandpay] DESC)
INCLUDE ([RowID],[ServerTime],[MachineTime],[MachineID],[GameID],[LoginFlag],[TotalBet],[Win],[GamesPlayed],[GamesWon],[TotalOut],[TotalHPCC],[TotalJPCC],[TotalRemote],[TotalWon],[TotalDrop],[TotalIn],[TotalBillIn],[TotalBillChange],[TotalCoinIn],[TotalCoinInDrop],[TotalCoinInHopper],[TotalHopperOut],[TotalHopperFill],[TotalTicketIn],[TotalTicketOut],[TotalBillInNumber],[BillIn1],[BillIn2],[BillIn3],[BillIn4],[BillIn5],[BillIn6],[BillIn7],[BillIn8],[TotalBillChangeNumber],[BillChange1],[BillChange2],[BillChange3],[BillChange4],[BillChange5],[BillChange6],[BillChange7],[TotalCoinInNumber],[CoinIn3],[CoinIn4],[CoinIn5],[CoinIn6],[CoinIn7],[CoinIn8],[TotalCoinInDropNumber],[CoinInDrop3],[CoinInDrop4],[CoinInDrop5],[CoinInDrop6],[CoinInDrop7],[CoinInDrop8],[TotalCoinInHopperNumber],[CoinInHopper3],[CoinInHopper4],[TicketInA],[TicketInB],[TicketInC],[TicketOutA],[TicketOutB],[TicketOutC],[CurrentCreditA],[CurrentCreditB],[CurrentCreditC],[TotalBetA],[TotalBetB],[TotalBetC],[WinA],[WinB],[WinC],[WinD],[TotalHPCCA])
WHERE TotalHandpay IS NOT NULL
WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [DatiRawData];
GO

CREATE NONCLUSTERED INDEX [IX_TotalTicketIn_INCL_AllOthers]
ON [1000296].[RawData] ([TotalTicketIn] DESC)
INCLUDE ([RowID],[ServerTime],[MachineTime],[MachineID],[GameID],[LoginFlag],[TotalBet],[Win],[GamesPlayed],[GamesWon],[TotalOut],[TotalHPCC],[TotalJPCC],[TotalRemote],[TotalWon],[TotalDrop],[TotalIn],[TotalBillIn],[TotalBillChange],[TotalCoinIn],[TotalCoinInDrop],[TotalCoinInHopper],[TotalHopperOut],[TotalHopperFill],[TotalHandPay],[TotalTicketOut],[TotalBillInNumber],[BillIn1],[BillIn2],[BillIn3],[BillIn4],[BillIn5],[BillIn6],[BillIn7],[BillIn8],[TotalBillChangeNumber],[BillChange1],[BillChange2],[BillChange3],[BillChange4],[BillChange5],[BillChange6],[BillChange7],[TotalCoinInNumber],[CoinIn3],[CoinIn4],[CoinIn5],[CoinIn6],[CoinIn7],[CoinIn8],[TotalCoinInDropNumber],[CoinInDrop3],[CoinInDrop4],[CoinInDrop5],[CoinInDrop6],[CoinInDrop7],[CoinInDrop8],[TotalCoinInHopperNumber],[CoinInHopper3],[CoinInHopper4],[TicketInA],[TicketInB],[TicketInC],[TicketOutA],[TicketOutB],[TicketOutC],[CurrentCreditA],[CurrentCreditB],[CurrentCreditC],[TotalBetA],[TotalBetB],[TotalBetC],[WinA],[WinB],[WinC],[WinD],[TotalHPCCA])
WHERE TotalTicketIn IS NOT NULL
WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [DatiRawData];
GO

CREATE NONCLUSTERED INDEX [IX_TotalTicketOut_INCL_AllOthers]
ON [1000296].[RawData] ([TotalTicketOut] DESC)
INCLUDE ([RowID],[ServerTime],[MachineTime],[MachineID],[GameID],[LoginFlag],[TotalBet],[Win],[GamesPlayed],[GamesWon],[TotalOut],[TotalHPCC],[TotalJPCC],[TotalRemote],[TotalWon],[TotalDrop],[TotalIn],[TotalBillIn],[TotalBillChange],[TotalCoinIn],[TotalCoinInDrop],[TotalCoinInHopper],[TotalHopperOut],[TotalHopperFill],[TotalHandPay],[TotalTicketIn],[TotalBillInNumber],[BillIn1],[BillIn2],[BillIn3],[BillIn4],[BillIn5],[BillIn6],[BillIn7],[BillIn8],[TotalBillChangeNumber],[BillChange1],[BillChange2],[BillChange3],[BillChange4],[BillChange5],[BillChange6],[BillChange7],[TotalCoinInNumber],[CoinIn3],[CoinIn4],[CoinIn5],[CoinIn6],[CoinIn7],[CoinIn8],[TotalCoinInDropNumber],[CoinInDrop3],[CoinInDrop4],[CoinInDrop5],[CoinInDrop6],[CoinInDrop7],[CoinInDrop8],[TotalCoinInHopperNumber],[CoinInHopper3],[CoinInHopper4],[TicketInA],[TicketInB],[TicketInC],[TicketOutA],[TicketOutB],[TicketOutC],[CurrentCreditA],[CurrentCreditB],[CurrentCreditC],[TotalBetA],[TotalBetB],[TotalBetC],[WinA],[WinB],[WinC],[WinD],[TotalHPCCA])
WHERE TotalTicketOut IS NOT NULL
WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [DatiRawData];
GO

