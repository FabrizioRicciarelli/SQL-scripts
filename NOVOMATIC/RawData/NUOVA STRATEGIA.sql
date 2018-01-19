DECLARE	
		@Message varchar(1000)
		,@Stringa varchar(100)
		,@ServerTime_Delta datetime
		,@FromServerTime datetime2(3)
		,@ToServerTime datetime2(3)
		,@CalcDurationSS int
		,@ClubID varchar(10)
		,@MachineID smallint
		,@Msg varchar(1000)
		,@TicketCode varchar(50)
		,@UnivocalLocationCode varchar(30)
		,@GD varchar(30)
		,@AamsMachineCode varchar(30)
		,@GameName varchar(100)
		,@ProcedureName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) +'.'+QUOTENAME(OBJECT_NAME(@@PROCID))
		,@BatchID int
		,@ServerTime_FIRST datetime = '1900-01-01 00:00:00.000'
		,@ServerTime_Last datetime = '2050-12-31 00:00:00.000'
		,@DailyLoadingType_Delta tinyint = 1

		,@SQL varchar(MAX)
SELECT	TOP 1
		@MachineID = MachineID
		,@ClubID  = ClubID  
		,@FromServerTime = FromOut
		,@ToServerTime = ToOut 
FROM	[TMP].[CountersCork] WITH(NOLOCK) 

SET @SQL =
'
SELECT 
		RowID
		,ServerTime
		,MachineID
		,GameID
		,IIF
		(
			LoginFlag = 0 
			OR 
			(
				LoginFlag= 1 
				AND 
				(
					ISNULL(TotalBet,0) + 
					ISNULL(TotalWon,0) + 
					ISNULL(TotalBillIn,0) + 
					ISNULL(TotalCoinIn,0) +
					ISNULL(TotalTicketIn,0) + 
					ISNULL(TotalTicketOut,0) + 
					ISNULL(TotalHandPay,0) + 
					ISNULL(WinD,0) + 
					ISNULL(TotalOut,0) + 
					ISNULL(TotalIn,0)  > 0
				)
			)
			,NULL
			,LoginFlag
		) AS LoginFlag2
		,TotalBet
		,TotalWon 
		,TotalBillIn 
		,TotalCoinIn 
		,TotalTicketIn
		,TotalTicketOut 
		,TotalHandPay 
		,WinD 
		,TotalOut 
		,TotalIn
FROM	
(
	SELECT RowID, ServerTime, MachineTime, MachineID, GameID, LoginFlag, TotalBet, Win, GamesPlayed, GamesWon, TotalHandpay, TotalHPCC, TotalJPCC, TotalRemote, TotalWon, TotalDrop, TotalIn, TotalOut, TotalBillIn, TotalBillChange, TotalCoinIn, TotalCoinInDrop, TotalCoinInHopper, TotalHopperOut, TotalHopperFill, TotalTicketIn, TotalTicketOut, TotalBillInNumber, BillIn1, BillIn2, BillIn3, BillIn4, BillIn5, BillIn6, BillIn7, BillIn8, TotalBillChangeNumber, BillChange1, BillChange2, BillChange3, BillChange4, BillChange5, BillChange6, BillChange7, TotalCoinInNumber, CoinIn3, CoinIn4, CoinIn5, CoinIn6, CoinIn7, CoinIn8, TotalCoinInDropNumber, CoinInDrop3, CoinInDrop4, CoinInDrop5, CoinInDrop6, CoinInDrop7, CoinInDrop8, TotalCoinInHopperNumber, CoinInHopper3, CoinInHopper4, TicketInA, TicketInB, TicketInC, TicketOutA, TicketOutB, TicketOutC, CurrentCreditA, CurrentCreditB, CurrentCreditC, TotalBetA, TotalBetB, TotalBetC, WinA, WinB, WinC, WinD, TotalHPCCA
	FROM [GMatica_AGS_RawData_01].[1000296].[RawData] -- WITH (INDEX(0)) -- DISABILITA TEMPORANEAMENTE L''USO DEGLI INDICI PER ANALISI SULLE PERFORMANCES
	WHERE MachineID = ' + CAST(@MachineID AS varchar(10)) + '
	AND ServerTime > ''' + CAST(@FromServerTime AS varchar(30)) + '''
	AND ServerTime <= ''' + CAST(@ToServerTime AS varchar(30)) + '''
	
	UNION ALL
	
	SELECT (RowID + 2147483649) AS RowID, ServerTime, MachineTime, MachineID, GameID, LoginFlag, TotalBet, Win, GamesPlayed, GamesWon, TotalHandpay, TotalHPCC, TotalJPCC, TotalRemote, TotalWon, TotalDrop, TotalIn, TotalOut, TotalBillIn, TotalBillChange, TotalCoinIn, TotalCoinInDrop, TotalCoinInHopper, TotalHopperOut, TotalHopperFill, TotalTicketIn, TotalTicketOut, TotalBillInNumber, BillIn1, BillIn2, BillIn3, BillIn4, BillIn5, BillIn6, BillIn7, BillIn8, TotalBillChangeNumber, BillChange1, BillChange2, BillChange3, BillChange4, BillChange5, BillChange6, BillChange7, TotalCoinInNumber, CoinIn3, CoinIn4, CoinIn5, CoinIn6, CoinIn7, CoinIn8, TotalCoinInDropNumber, CoinInDrop3, CoinInDrop4, CoinInDrop5, CoinInDrop6, CoinInDrop7, CoinInDrop8, TotalCoinInHopperNumber, CoinInHopper3, CoinInHopper4, TicketInA, TicketInB, TicketInC, TicketOutA, TicketOutB, TicketOutC, CurrentCreditA, CurrentCreditB, CurrentCreditC, TotalBetA, TotalBetB, TotalBetC, WinA, WinB, WinC, WinD, TotalHPCCA
	FROM [GMatica_AGS_RawData].[1000296].[RawData] -- WITH (INDEX(0)) -- DISABILITA TEMPORANEAMENTE L''USO DEGLI INDICI PER ANALISI SULLE PERFORMANCES
	WHERE MachineID = ' + CAST(@MachineID AS varchar(10)) + '
	AND ServerTime > ''' + CAST(@FromServerTime AS varchar(30)) + '''
	AND ServerTime <= ''' + CAST(@ToServerTime AS varchar(30)) + '''
) V
'
PRINT(@SQL)
EXEC(@SQL) AT [POM-MON01]

