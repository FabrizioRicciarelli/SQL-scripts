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

SELECT	TOP 1
		@MachineID = MachineID
		,@ClubID  = ClubID  
		,@FromServerTime = FromOut
		,@ToServerTime = ToOut 
FROM	[TMP].[CountersCork] WITH(NOLOCK) 

SELECT 
		RowID
		,ServerTime
		,@MachineID AS MachineID
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
FROM	[TMP].[RawData_View] 
WHERE	MachineID = @MachineID 
AND		ServerTime > @FromServerTime 
AND		ServerTime <= @ToServerTime
