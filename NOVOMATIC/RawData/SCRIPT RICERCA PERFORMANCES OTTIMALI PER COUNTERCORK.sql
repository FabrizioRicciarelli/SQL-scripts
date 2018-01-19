	DECLARE 
			@RestartTime datetime
			,@FromOut datetime = '2016-01-01'
			,@criteria varchar(MAX)
			,@TMP sql_variant
			--,@MachineID int = 54 -- 1.657.833 righe (TotalHandPay = 0)
			--,@MachineID int = 58 -- 1.671.736 righe (TotalHandPay = 0)
			--,@MachineID int = 9 -- 1.742.765 righe 
			--,@MachineID int = 29 -- 1.916.964 righe (TotalHandPay = 0)
			--,@MachineID int = 62 -- 1.950.185 righe (TotalHandPay = 0)
			--,@MachineID int = 13 -- 1.981.526 righe (TotalHandPay = 0)
			--,@MachineID int = 38 -- 2.001.013 righe (TotalHandPay = 0)
			--,@MachineID int = 55 -- 2.060.018 righe (TotalHandPay = 0)
			--,@MachineID int = 77 -- 2.080.616 righe (TotalHandPay = 0)
			,@MachineID int = 46 -- 2.172.812 righe
			--,@MachineID int = 34 -- 2.172.812 righe (TotalHandPay = 0)
			--,@MachineID int = 56 -- 2.289.324 righe (TotalHandPay = 0)
			--,@MachineID int = 53 -- 2.618.832 righe (WinD = 0, TotalHandPay = 0)

	DECLARE @ServerTime_FIRST datetime = '1900-01-01 00:00:00.000', @ServerTime_Last datetime = '2050-12-31 00:00:00.000';	

	DECLARE @TableMaxCounters TABLE (TotalBet bigint, TotalWon bigint, WinD bigint, TotalBillIn bigint, TotalCoinIn bigint, TotalTicketIn bigint, TotalTicketOut bigint, TotalHandPay bigint, TotalOut bigint, TotalIn bigint)
	DECLARE	@PreTotali TABLE(ServerTime datetime PRIMARY KEY NOT NULL,TotalBet int,TotalWon int ,WinD int,TotalBillIn int,TotalCoinIn int,TotalTicketIn int,TotalTicketOut int,TotalHandPay int,TotalOut int,TotalIn int)
	DECLARE	@Totali TABLE(RN int IDENTITY(1,1) PRIMARY KEY NOT NULL, TotalBet int,TotalWon int ,WinD int,TotalBillIn int,TotalCoinIn int,TotalTicketIn int,TotalTicketOut int,TotalHandPay int,TotalOut int,TotalIn int)

	--SET @criteria = 
	--'
	--AND		MachineID = ' + CAST(@MachineID AS varchar(4)) + '
	--AND		LoginFlag = 0 
	--AND		ServerTime < ' + QUOTENAME(@FromOut,CHAR(39)) + ' 
	--AND		LoginFlag = 1 
	--AND		TotalBet IS NOT NULL 
	--AND		TotalWon IS NOT NULL 
	--AND		WinD IS NOT NULL 
	--AND		TotalBillIn IS NOT NULL 
	--AND		TotalCoinIn IS NOT NULL 
	--AND		TotalTicketIn IS NOT NULL 
	--AND		TotalTicketOut IS NOT NULL 
	--AND		TotalHandPay IS NOT NULL 
	--AND		TotalOut IS NOT NULL 
	--AND		TotalIn IS NOT NULL
	--'
	--EXEC	dbo.GetRawDataScalar
	--		'GMATICA'
	--		,'1000296'
	--		,'MAX(ServerTime) AS ServerTime' -- Set di colonne specifico
	--		,@criteria
	--		,@TMP OUTPUT
	--SELECT	@RestartTime = ISNULL(CAST(@TMP AS datetime), @ServerTime_FIRST)

	SELECT	@RestartTime = 
			MAX(ISNULL(ServerTime, @ServerTime_First))
	FROM	[TMP].[RawData_View]
	WHERE	MachineID  = @MachineID 
	AND		ServerTime <= @FromOut
	AND		LoginFlag = 1 
	AND		TotalBet IS NOT NULL 
	AND		TotalWon IS NOT NULL 
	AND		WinD IS NOT NULL 
	AND		TotalBillIn IS NOT NULL 
	AND		TotalCoinIn IS NOT NULL 
	AND		TotalTicketIn IS NOT NULL 
	AND		TotalTicketOut IS NOT NULL 
	AND		TotalHandPay IS NOT NULL 
	AND		TotalOut IS NOT NULL 
	AND		TotalIn IS NOT NULL

	--SET @criteria = 
	--'
	--AND		MachineID = ' + CAST(@MachineID AS varchar(4)) + '
	--AND		(ServerTime Between ' + QUOTENAME(@RestartTime,CHAR(39)) + ' AND ' + QUOTENAME(@FromOut,CHAR(39)) + ') ' 
	----DELETE	FROM @PreTotali
	--INSERT	@PreTotali(ServerTime,TotalBet,TotalWon,WinD,TotalBillIn,TotalCoinIn,TotalTicketIn,TotalTicketOut,TotalHandPay,TotalOut,TotalIn)
	--EXEC	GetRemoteSpecificRawData
	--		'GMATICA'
	--		,'1000296'
	--		,'ServerTime,TotalBet,TotalWon,WinD,TotalBillIn,TotalCoinIn,TotalTicketIn,TotalTicketOut,TotalHandPay,TotalOut,TotalIn' -- Set di colonne specifico
	--		,@criteria

	INSERT	@PreTotali(ServerTime,TotalBet,TotalWon,WinD,TotalBillIn,TotalCoinIn,TotalTicketIn,TotalTicketOut,TotalHandPay,TotalOut,TotalIn)
	SELECT	ServerTime,TotalBet,TotalWon,WinD,TotalBillIn,TotalCoinIn,TotalTicketIn,TotalTicketOut,TotalHandPay,TotalOut,TotalIn
	FROM	[TMP].[RawData_View]
	WHERE	(ServerTime Between @RestartTime AND @FromOut) 
	AND		MachineID = @MachineID

	--DELETE	FROM @Totali
	INSERT	@Totali(TotalBet,TotalWon,WinD,TotalBillIn,TotalCoinIn,TotalTicketIn,TotalTicketOut,TotalHandPay,TotalOut,TotalIn)
	SELECT	TotalBet,TotalWon,WinD,TotalBillIn,TotalCoinIn,TotalTicketIn,TotalTicketOut,TotalHandPay,TotalOut,TotalIn
	FROM	@PreTotali
	ORDER BY ServerTime
												
	-- Creazione tappo 
	;With NumberedNext 
	AS (
		SELECT	
				Col
				,Value
				,RN
		FROM	@Totali 
		UNPIVOT
		(
			[Value] FOR Col IN 
			(
				TotalBet,TotalWon,WinD,TotalBillIn,TotalCoinIn,TotalTicketIn,TotalTicketOut,TotalHandPay,TotalOut,TotalIn
			)
		) p							
	)
	INSERT	@TableMaxCounters(TotalBet, TotalWon,  WinD, TotalBillIn , TotalCoinIn , TotalTicketIn , TotalTicketOut , TotalHandPay, TotalOut, TotalIn)
 	SELECT
			MAX(CASE WHEN Col = 'TotalBet'			THEN [Value] END) AS TotalBet
			,MAX(CASE WHEN Col = 'TotalWon'			THEN [Value] END) AS TotalWon
			,MAX(CASE WHEN Col = 'WinD'				THEN [Value] END) AS WinD
			,MAX(CASE WHEN Col = 'TotalBillIn'		THEN [Value] END) AS TotalBillIn
			,MAX(CASE WHEN Col = 'TotalCoinIn'		THEN [Value] END) AS TotalCoinIn
			,MAX(CASE WHEN Col = 'TotalTicketIn'	THEN [Value] END) AS TotalTicketIn
			,MAX(CASE WHEN Col = 'TotalTicketOut'	THEN [Value] END) AS TotalTicketOut
			,MAX(CASE WHEN Col = 'TotalHandPay'		THEN [Value] END) AS TotalHandPay
			,MAX(CASE WHEN Col = 'TotalOut'			THEN [Value] END) AS TotalOut
			,MAX(CASE WHEN Col = 'TotalIn'			THEN [Value] END) AS TotalIn
	FROM	NumberedNext 
	WHERE	RN = 1 
	--Fine creazione tappo 

	SELECT * FROM @TableMaxCounters
