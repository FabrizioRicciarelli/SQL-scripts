USE [GMATICA_AGS_RawData];

CREATE UNIQUE NONCLUSTERED INDEX [IX_FilteredTotals_INCL_AllOthers]
ON [1000296].[RawData] (LoginFlag,TotalOut,TotalBet,TotalWon,WinD,TotalBillIn,TotalCoinIn,TotalTicketIn,TotalTicketOut,TotalHandPay,TotalIn)
INCLUDE ([ServerTime],[MachineID],[GameID],[LoginFlag],[Win])
WHERE	TotalOut IS NOT NULL
AND		TotalBet IS NOT NULL 
AND		TotalWon IS NOT NULL 
AND		WinD IS NOT NULL 
AND		TotalBillIn IS NOT NULL 
AND		TotalCoinIn IS NOT NULL 
AND		TotalTicketIn IS NOT NULL 
AND		TotalTicketOut IS NOT NULL 
AND		TotalHandPay IS NOT NULL 
AND		TotalIn IS NOT NULL
WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [DatiRawData];
GO

