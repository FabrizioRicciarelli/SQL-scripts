DECLARE @SQL Nvarchar(MAX)
--SET @SQL =
--N'
--SELECT COUNT(*)
--FROM
--(
--SELECT	RowID, ServerTime, MachineTime, MachineID, GameID, LoginFlag, TotalBet, Win, GamesPlayed, GamesWon, TotalHandpay, TotalHPCC, TotalJPCC, TotalRemote, TotalWon, TotalDrop, TotalIn, TotalOut, TotalBillIn, TotalBillChange, TotalCoinIn, TotalCoinInDrop, TotalCoinInHopper, TotalHopperOut, TotalHopperFill, TotalTicketIn, TotalTicketOut, TotalBillInNumber, BillIn1, BillIn2, BillIn3, BillIn4, BillIn5, BillIn6, BillIn7, BillIn8, TotalBillChangeNumber, BillChange1, BillChange2, BillChange3, BillChange4, BillChange5, BillChange6, BillChange7, TotalCoinInNumber, CoinIn3, CoinIn4, CoinIn5, CoinIn6, CoinIn7, CoinIn8, TotalCoinInDropNumber, CoinInDrop3, CoinInDrop4, CoinInDrop5, CoinInDrop6, CoinInDrop7, CoinInDrop8, TotalCoinInHopperNumber, CoinInHopper3, CoinInHopper4, TicketInA, TicketInB, TicketInC, TicketOutA, TicketOutB, TicketOutC, CurrentCreditA, CurrentCreditB, CurrentCreditC, TotalBetA, TotalBetB, TotalBetC, WinA, WinB, WinC, WinD, TotalHPCCA
--FROM	[GMatica_AGS_RawData_01].[1000252].[RawData] WITH (NOLOCK)
--WHERE	ServerTime >= ''20120101'' AND ServerTime < ''20151117''
--UNION ALL
--SELECT	(RowID + 2147483649), ServerTime, MachineTime, MachineID, GameID, LoginFlag, TotalBet, Win, GamesPlayed, GamesWon, TotalHandpay, TotalHPCC, TotalJPCC, TotalRemote, TotalWon, TotalDrop, TotalIn, TotalOut, TotalBillIn, TotalBillChange, TotalCoinIn, TotalCoinInDrop, TotalCoinInHopper, TotalHopperOut, TotalHopperFill, TotalTicketIn, TotalTicketOut, TotalBillInNumber, BillIn1, BillIn2, BillIn3, BillIn4, BillIn5, BillIn6, BillIn7, BillIn8, TotalBillChangeNumber, BillChange1, BillChange2, BillChange3, BillChange4, BillChange5, BillChange6, BillChange7, TotalCoinInNumber, CoinIn3, CoinIn4, CoinIn5, CoinIn6, CoinIn7, CoinIn8, TotalCoinInDropNumber, CoinInDrop3, CoinInDrop4, CoinInDrop5, CoinInDrop6, CoinInDrop7, CoinInDrop8, TotalCoinInHopperNumber, CoinInHopper3, CoinInHopper4, TicketInA, TicketInB, TicketInC, TicketOutA, TicketOutB, TicketOutC, CurrentCreditA, CurrentCreditB, CurrentCreditC, TotalBetA, TotalBetB, TotalBetC, WinA, WinB, WinC, WinD, TotalHPCCA
--FROM	[GMatica_AGS_RawData].[1000252].[RawData] WITH (NOLOCK)
--WHERE	ServerTime >= ''20151117''
--) I
--'
--EXEC(@SQL) AT [POM-MON01]

--SET @SQL =
--N'
--DECLARE @RAWMINIMAL TABLE(RowID int, ServerTime datetime, MachineID tinyint, LoginFlag bit, TotalOut int)
--INSERT 	@RAWMINIMAL
--SELECT	RowID, ServerTime, MachineID, LoginFlag, TotalOut
--FROM	[GMatica_AGS_RawData].[1000252].[RawData_VIEW]
--WHERE	ServerTime <= ''2017-07-04 00:14:26.453'' AND ServerTime > DATEADD(DD,-60,''2017-07-04 00:14:26.453'')

--SELECT COUNT(*)
--FROM   @RAWMINIMAL
--'
--EXEC(@SQL) AT [POM-MON01]


SET @SQL =
N'
DECLARE @RAWMINIMAL XML--TABLE(RowID int, ServerTime datetime, MachineID tinyint, LoginFlag bit, TotalOut int)
--INSERT 	@RAWMINIMAL
SELECT @RAWMINIMAL =
(
SELECT	RowID, ServerTime, MachineID, LoginFlag, TotalOut
FROM	[GMatica_AGS_RawData].[1000252].[RawData_VIEW]
WHERE	ServerTime <= ''2017-07-04 00:14:26.453'' AND ServerTime > DATEADD(DD,-60,''2017-07-04 00:14:26.453'')
FOR XML RAW(''RAWMIN'')
)
'
EXEC(@SQL) AT [POM-MON01]
