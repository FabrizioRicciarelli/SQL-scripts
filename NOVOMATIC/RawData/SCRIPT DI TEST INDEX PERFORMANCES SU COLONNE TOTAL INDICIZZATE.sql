/*
DECLARE	@MAXTotalOut int
SELECT	@MAXTotalOut = MAX(TotalOut) 
FROM	[GMatica_AGS_RawData].[1000296].[RawData] WITH(NOLOCK)
WHERE	TotalOut IS NOT NULL

SELECT	*
		,@MAXTotalOut AS MAXTotalOut
FROM	[GMatica_AGS_RawData].[1000296].[RawData] WITH(NOLOCK)
WHERE	TotalOut = @MAXTotalOut
AND		TotalOut IS NOT NULL
*/

/*
SELECT
		 RowID
		,ServerTime
		,MachineTime
		,MachineID
		,GameID
		,LoginFlag
		,TotalBet
		,TotalBillIn
		,TotalCoinIn
		,TotalHandpay
		,TotalIn
		,TotalOut
		,TotalTicketIn
		,TotalTicketOut
		,TotalWon

FROM	[GMatica_AGS_RawData].[1000296].[RawData] WITH(NOLOCK)

WHERE	TotalOut > 0 
--AND		MachineID = 60
AND		LoginFlag = 0 
AND		ServerTime < '2016-01-01'

SELECT	
		MachineID
		,MAX(TotalBet) AS MaxTotalBet
		,MAX(TotalBillIn) AS MaxTotalBillIn
		,MAX(TotalHandpay) AS MaxTotalHandpay
		,MAX(TotalIn) AS MaxTotalIn
		,MAX(TotalOut) AS MaxTotalOut
		,MAX(TotalTicketIn) AS MaxTotalTicketIn
		,MAX(TotalTicketOut) AS MaxTotalTicketOut
		,MAX(TotalWon) AS MaxTotalWon
FROM	[GMatica_AGS_RawData].[1000296].[RawData] WITH(NOLOCK)
WHERE	TotalBet IS NOT NULL
AND		TotalBillIn IS NOT NULL
AND		TotalHandpay IS NOT NULL
AND		TotalIn IS NOT NULL
AND		TotalOut IS NOT NULL
AND		TotalTicketIn IS NOT NULL
AND		TotalTicketOut IS NOT NULL
AND		TotalWon IS NOT NULL
GROUP BY MachineID
ORDER BY MaxTotalWon DESC

SELECT	
		MachineID
		,MAX(TotalOut) AS MAXTotalOut
FROM	[GMatica_AGS_RawData].[1000296].[RawData] WITH(NOLOCK)
WHERE	TotalOut IS NOT NULL
GROUP BY MachineID
HAVING MAX(TotalOut) = (SELECT MAX(TotalOut) FROM [GMatica_AGS_RawData].[1000296].[RawData] WITH(NOLOCK))


DECLARE	@MAXTotalBet int
SELECT	@MAXTotalBet = MAX(TotalBet) 
FROM	[GMatica_AGS_RawData].[1000296].[RawData] WITH(NOLOCK)
WHERE	TotalBet IS NOT NULL

SELECT	*
		,@MAXTotalBet AS MAXTotalBet
FROM	[GMatica_AGS_RawData].[1000296].[RawData] WITH(NOLOCK)
WHERE	TotalBet = @MAXTotalBet



SELECT	
		MachineID
		,TotalBet
		,COUNT(*) AS OCCURRENCES
FROM	[GMatica_AGS_RawData].[1000296].[RawData] WITH(NOLOCK)
WHERE	TotalBet IS NOT NULL
GROUP BY MachineID, TotalBet
ORDER BY OCCURRENCES DESC
*/

DECLARE	
		@MAXTotalHandPay int
		,@MAXTotalOut int
		,@MAXTotalTicketIn int
		,@MAXTotalTicketOut int

SELECT	@MAXTotalHandPay = MAX(TotalHandPay) 
FROM	[GMatica_AGS_RawData].[1000296].[RawData] WITH(NOLOCK)
WHERE	TotalHandPay IS NOT NULL
AND		LoginFlag = 1
SELECT	@MAXTotalOut = MAX(TotalOut) 
FROM	[GMatica_AGS_RawData].[1000296].[RawData] WITH(NOLOCK)
WHERE	TotalOut IS NOT NULL
AND		LoginFlag = 1
SELECT	@MAXTotalTicketIn = MAX(TotalTicketIn) 
FROM	[GMatica_AGS_RawData].[1000296].[RawData] WITH(NOLOCK)
WHERE	TotalTicketIn IS NOT NULL
AND		LoginFlag = 1
SELECT	@MAXTotalTicketOut = MAX(TotalTicketOut) 
FROM	[GMatica_AGS_RawData].[1000296].[RawData] WITH(NOLOCK)
WHERE	TotalTicketOut IS NOT NULL
AND		LoginFlag = 1

--SELECT
--		@MAXTotalHandPay = MAXTotalHandPay
--		,@MAXTotalOut = MAXTotalOut
--		,@MAXTotalTicketIn = MAXTotalTicketIn
--		,@MAXTotalTicketOut = MAXTotalTicketOut
--FROM
--(
--SELECT	MAX(TotalHandPay) AS MAXTotalHandPay
--		,NULL AS MAXTotalOut
--		,NULL AS MAXTotalTicketIn
--		,NULL AS MAXTotalTicketOut
--FROM	[GMatica_AGS_RawData].[1000296].[RawData] WITH(NOLOCK)
--WHERE	TotalHandPay IS NOT NULL
--AND		LoginFlag = 1
--UNION ALL
--SELECT	NULL AS MAXTotalHandPay
--		,MAX(TotalOut) AS MAXTotalOut
--		,NULL AS MAXTotalTicketIn
--		,NULL AS MAXTotalTicketOut
--FROM	[GMatica_AGS_RawData].[1000296].[RawData] WITH(NOLOCK)
--WHERE	TotalOut IS NOT NULL
--AND		LoginFlag = 1
--UNION ALL
--SELECT	NULL AS MAXTotalHandPay
--		,NULL AS MAXTotalOut
--		,MAX(TotalTicketIn) AS MAXTotalTicketIn
--		,NULL AS MAXTotalTicketOut
--FROM	[GMatica_AGS_RawData].[1000296].[RawData] WITH(NOLOCK)
--WHERE	TotalTicketIn IS NOT NULL
--AND		LoginFlag = 1
--UNION ALL
--SELECT	NULL AS MAXTotalHandPay
--		,NULL AS MAXTotalOut
--		,NULL AS MAXTotalTicketIn
--		,MAX(TotalTicketOut) AS MAXTotalTicketOut
--FROM	[GMatica_AGS_RawData].[1000296].[RawData] WITH(NOLOCK)
--WHERE	TotalTicketOut IS NOT NULL
--AND		LoginFlag = 1
--) U


SELECT	DISTINCT
		MachineID
		,MAXTotalHandPay
		,MAXTotalOut
		,MAXTotalTicketIn
		,MAXTotalTicketOut
FROM
(
--SELECT	RowID, MachineID, TotalBet, Win, TotalWon, TotalDrop, TotalCoinIn -- *
SELECT	MachineID
		,@MAXTotalHandPay AS MAXTotalHandPay
		,NULL AS MAXTotalOut
		,NULL AS MAXTotalTicketIn
		,NULL AS MAXTotalTicketOut
FROM	[GMatica_AGS_RawData].[1000296].[RawData] WITH(NOLOCK)
WHERE	TotalHandPay = @MAXTotalHandPay
AND		TotalHandPay IS NOT NULL
AND		LoginFlag = 1
UNION ALL
--SELECT	RowID, MachineID, TotalBet, Win, TotalWon, TotalDrop, TotalCoinIn -- *
SELECT	MachineID
		,NULL AS MAXTotalHandPay
		,@MAXTotalOut AS MAXTotalOut
		,NULL AS MAXTotalTicketIn
		,NULL AS MAXTotalTicketOut
FROM	[GMatica_AGS_RawData].[1000296].[RawData] WITH(NOLOCK)
WHERE	TotalOut = @MAXTotalOut
AND		TotalOut IS NOT NULL
AND		LoginFlag = 1
UNION ALL
--SELECT	RowID, MachineID, TotalBet, Win, TotalWon, TotalDrop, TotalCoinIn -- *
SELECT	MachineID
		,NULL AS MAXTotalHandPay
		,NULL AS MAXTotalOut
		,@MAXTotalTicketIn AS MAXTotalTicketIn
		,NULL AS MAXTotalTicketOut
FROM	[GMatica_AGS_RawData].[1000296].[RawData] WITH(NOLOCK)
WHERE	TotalTicketIn = @MAXTotalTicketIn
AND		TotalTicketIn IS NOT NULL
AND		LoginFlag = 1
UNION ALL
--SELECT	RowID, MachineID, TotalBet, Win, TotalWon, TotalDrop, TotalCoinIn -- *
SELECT	MachineID
		,NULL AS MAXTotalHandPay
		,NULL AS MAXTotalOut
		,NULL AS MAXTotalTicketIn
		,@MAXTotalTicketOut AS MAXTotalTicketOut
FROM	[GMatica_AGS_RawData].[1000296].[RawData] WITH(NOLOCK)
WHERE	TotalTicketOut = @MAXTotalTicketOut
AND		LoginFlag = 1
AND		TotalTicketOut IS NOT NULL
) U