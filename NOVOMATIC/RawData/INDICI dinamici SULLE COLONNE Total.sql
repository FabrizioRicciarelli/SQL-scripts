/*
EXEC CreateTotalIndexes '1000296', 'TotalOut, TotalHandpay, TotalTicketIn, TotalTicketOut'
*/
ALTER PROC	dbo.CreateTotalIndexes 
			@ClubId varchar(10) = NULL
			,@CSVindexedColumns varchar(MAX) = NULL
AS
IF ISNULL(@ClubId,'') != ''
AND ISNULL(@CSVindexedColumns,'') != ''
BEGIN
	DECLARE 
			@SQL varchar(MAX) = ''
			,@CurrentTableName sysname
			,@IncludedColumns varchar(MAX)

	DECLARE @IndexedColumns TABLE (CurrentTotalColumn sysname)

	SET @CurrentTableName = '[' + @ClubId + '].[RawData]'
	INSERT @IndexedColumns(CurrentTotalColumn)
	SELECT Item AS CurrentTotalColumn FROM dbo.SplitStringsXML(@CSVindexedColumns, N',')

	SELECT 
			@IncludedColumns =	REPLACE
								(
									'INCLUDE ([RowID],[ServerTime],[MachineTime],[MachineID],[GameID],[LoginFlag],[TotalBet],[Win],[TotalHandpay],[TotalIn],[TotalBillIn],[TotalTicketIn],[TotalTicketOut],[WinD])'
									,CurrentTotalColumn
									,''
								)
			,@SQL +=
	'
	IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = ' + QUOTENAME('[IX_' + CurrentTotalColumn + '_INCL_SomeOthers]',CHAR(39)) + ' AND object_id = OBJECT_ID(' + QUOTENAME(@CurrentTableName,CHAR(39)) + ')
		BEGIN
			CREATE NONCLUSTERED INDEX [IX_TotalOut_INCL_AllOthers]	
			ON ' + @CurrentTableName + ' ([' + CurrentTotalColumn + '] DESC)' + CHAR(13) +@IncludedColumns + '
			WHERE ' + CurrentTotalColumn + '  IS NOT NULL
			WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 60) ON [DatiRawData];
		END
	GO
	'
	FROM @IndexedColumns

	PRINT(@SQL)
END
--CREATE NONCLUSTERED INDEX [IX_TotalHandpay_INCL_AllOthers]
--ON [1000296].[RawData] ([TotalHandpay] DESC)
--INCLUDE ([RowID],[ServerTime],[MachineTime],[MachineID],[GameID],[LoginFlag],[TotalBet],[Win],[TotalHandpay],[TotalIn],[TotalBillIn],[TotalTicketIn],[TotalTicketOut],[WinD])
----INCLUDE ([GamesPlayed],[GamesWon],[TotalHPCC],[TotalJPCC],[TotalRemote],[TotalIn],[TotalBillChange],[TotalCoinIn],[TotalCoinInDrop],[TotalCoinInHopper],[TotalHopperOut],[TotalHopperFill],[TotalBillInNumber],[BillIn1],[BillIn2],[BillIn3],[BillIn4],[BillIn5],[BillIn6],[BillIn7],[BillIn8],[TotalBillChangeNumber],[BillChange1],[BillChange2],[BillChange3],[BillChange4],[BillChange5],[BillChange6],[BillChange7],[TotalCoinInNumber],[CoinIn3],[CoinIn4],[CoinIn5],[CoinIn6],[CoinIn7],[CoinIn8],[TotalCoinInDropNumber],[CoinInDrop3],[CoinInDrop4],[CoinInDrop5],[CoinInDrop6],[CoinInDrop7],[CoinInDrop8],[TotalCoinInHopperNumber],[CoinInHopper3],[CoinInHopper4],[TicketInA],[TicketInB],[TicketInC],[TicketOutA],[TicketOutB],[TicketOutC],[CurrentCreditA],[CurrentCreditB],[CurrentCreditC],[TotalBetA],[TotalBetB],[TotalBetC],[WinA],[WinB],[WinC],[TotalHPCCA])
--WHERE TotalHandpay IS NOT NULL
--WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 60) ON [DatiRawData];
--GO

--CREATE NONCLUSTERED INDEX [IX_TotalTicketIn_INCL_AllOthers]
--ON [1000296].[RawData] ([TotalTicketIn] DESC)
--INCLUDE ([RowID],[ServerTime],[MachineTime],[MachineID],[GameID],[LoginFlag],[TotalBet],[Win],[TotalHandpay],[TotalIn],[TotalBillIn],[TotalTicketIn],[TotalTicketOut],[WinD])
----INCLUDE ([GamesPlayed],[GamesWon],[TotalHPCC],[TotalJPCC],[TotalRemote],[TotalIn],[TotalBillChange],[TotalCoinIn],[TotalCoinInDrop],[TotalCoinInHopper],[TotalHopperOut],[TotalHopperFill],[TotalBillInNumber],[BillIn1],[BillIn2],[BillIn3],[BillIn4],[BillIn5],[BillIn6],[BillIn7],[BillIn8],[TotalBillChangeNumber],[BillChange1],[BillChange2],[BillChange3],[BillChange4],[BillChange5],[BillChange6],[BillChange7],[TotalCoinInNumber],[CoinIn3],[CoinIn4],[CoinIn5],[CoinIn6],[CoinIn7],[CoinIn8],[TotalCoinInDropNumber],[CoinInDrop3],[CoinInDrop4],[CoinInDrop5],[CoinInDrop6],[CoinInDrop7],[CoinInDrop8],[TotalCoinInHopperNumber],[CoinInHopper3],[CoinInHopper4],[TicketInA],[TicketInB],[TicketInC],[TicketOutA],[TicketOutB],[TicketOutC],[CurrentCreditA],[CurrentCreditB],[CurrentCreditC],[TotalBetA],[TotalBetB],[TotalBetC],[WinA],[WinB],[WinC],[TotalHPCCA])
--WHERE TotalTicketIn IS NOT NULL
--WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 60) ON [DatiRawData];
--GO

--CREATE NONCLUSTERED INDEX [IX_TotalTicketOut_INCL_AllOthers]
--ON [1000296].[RawData] ([TotalTicketOut] DESC)
--INCLUDE ([RowID],[ServerTime],[MachineTime],[MachineID],[GameID],[LoginFlag],[TotalBet],[Win],[TotalHandpay],[TotalIn],[TotalBillIn],[TotalTicketIn],[TotalTicketOut],[WinD])
----INCLUDE ([GamesPlayed],[GamesWon],[TotalHPCC],[TotalJPCC],[TotalRemote],[TotalIn],[TotalBillChange],[TotalCoinIn],[TotalCoinInDrop],[TotalCoinInHopper],[TotalHopperOut],[TotalHopperFill],[TotalBillInNumber],[BillIn1],[BillIn2],[BillIn3],[BillIn4],[BillIn5],[BillIn6],[BillIn7],[BillIn8],[TotalBillChangeNumber],[BillChange1],[BillChange2],[BillChange3],[BillChange4],[BillChange5],[BillChange6],[BillChange7],[TotalCoinInNumber],[CoinIn3],[CoinIn4],[CoinIn5],[CoinIn6],[CoinIn7],[CoinIn8],[TotalCoinInDropNumber],[CoinInDrop3],[CoinInDrop4],[CoinInDrop5],[CoinInDrop6],[CoinInDrop7],[CoinInDrop8],[TotalCoinInHopperNumber],[CoinInHopper3],[CoinInHopper4],[TicketInA],[TicketInB],[TicketInC],[TicketOutA],[TicketOutB],[TicketOutC],[CurrentCreditA],[CurrentCreditB],[CurrentCreditC],[TotalBetA],[TotalBetB],[TotalBetC],[WinA],[WinB],[WinC],[TotalHPCCA])
--WHERE TotalTicketOut IS NOT NULL
--WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 60) ON [DatiRawData];
--GO

