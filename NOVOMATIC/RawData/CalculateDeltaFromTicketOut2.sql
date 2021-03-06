/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: GA, FR
Creation Date.......: 2017-05-22
Last revision Date..: 2017-07-05
Description.........: Calcola i Delta in runtime da Out a Out

Note
- Use [Tab size] = 3 and [Indent size] 3 (Insert spaces)

------------------
-- Parameters   --
------------------	
@ReturnCode Int = 0 Output

------------------
-- Call Example --
------------------ 
DECLARE @ReturnCode int
EXEC	[RAW].[CalculateDeltaFromTicketOut2]
			@TicketCode = '4412211590049855'
			,@ReturnCode = @ReturnCode OUTPUT
SELECT @ReturnCode AS ReturnCode 

SELECT * FROM [TMP].[Delta]

-- Svuotamento tabelle di log: errori ed operazioni
-- (solo i dati relativi alla giornata odierna)
EXEC DeleteTodayErrorLog
EXEC DeleteTodayOperationLog

-- Letture tabelle di log: errori ed operazioni
-- (solo i dati relativi alla giornata odierna)
SELECT * FROM dbo.VTodayErrorLog ORDER BY ErrorTime DESC
SELECT * FROM dbo.VTodayOperationLog ORDER BY OperationTime DESC

*/
ALTER PROC	[RAW].[CalculateDeltaFromTicketOut2]
			@TicketCode varchar(50)
			,@ReturnCode int = 0 OUTPUT
AS
SET NOCOUNT ON;

DECLARE	
		@Message varchar(1000)
		,@Stringa varchar(100)
		,@ServerTime_Delta datetime
		,@FromServerTime datetime2(3)
		,@ToServerTime datetime2(3)
		,@CalcDurationSS int
		,@ClubID varchar(10)
		,@ConcessionaryID tinyint
		,@ConcessionaryName sysname
		,@BatchID int
		,@MachineID smallint
		,@Msg varchar(1000)
		,@UnivocalLocationCode varchar(30)
		,@GD varchar(30)
		,@AamsMachineCode varchar(30)
		,@GameName varchar(100)
		,@criteria varchar(4000)
		,@ProcedureName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + '.' + QUOTENAME(OBJECT_NAME(@@PROCID))
		,@ServerTime_FIRST datetime = '1900-01-01 00:00:00.000'
		,@ServerTime_Last datetime = '2050-12-31 00:00:00.000'
		,@DailyLoadingType_Delta tinyint = 1

DECLARE @RawData TABLE
		(
			RowID int
			,ServerTime datetime
			,GameID int
			,LoginFlag bit
			,TotalBet int NULL
			,TotalWon int NULL
			,TotalBillIn int NULL
			,TotalCoinIn int NULL
			,TotalTicketIn int NULL
			,TotalTicketOut int NULL
			,TotalHandPay int NULL
			,WinD int NULL
			,TotalOut int NULL
			,TotalIn int NULL
		)
		             
DECLARE	@TableMaxCounters TABLE 
		(
			TotalBet bigint
			,TotalWon bigint
			,WinD bigint
			,TotalBillIn bigint
			,TotalCoinIn bigint
			,TotalTicketIn bigint
			,TotalTicketOut bigint
			,TotalHandPay bigint
			,TotalOut bigint
			,TotalIn bigint
		)
BEGIN TRY  
	-- Ultimo totalout presente nel tappo, ID macchina, ID club
	SELECT	TOP 1
			@ConcessionaryID = ConcessionaryID 
			,@ConcessionaryName = ConcessionaryName
	FROM	[Config].[Table] WITH(NOLOCK)

	-- SELECT * FROM [TMP].[CountersCork] WITH(NOLOCK) 

	SELECT	TOP 1
			@MachineID = MachineID
			,@ClubID  = ClubID  
			,@FromServerTime = FromOut
			,@ToServerTime = ToOut 
	FROM	[TMP].[CountersCork] WITH(NOLOCK) 
	
	SELECT	TOP 1
			@GD = [Machine]
			,@AamsMachineCode = AamsMachineCode 
	FROM	[dbo].[VLT] WITH(NOLOCK)
	
	SELECT	TOP 1
			@UnivocalLocationCode = UnivocalLocationCode 
	FROM	dbo.GamingRoom WITH(NOLOCK) -- dbo.GamingRoom = SYNONYM
	
	IF ISNULL(@MachineID,0) != 0
	AND ISNULL(@ConcessionaryName,'') != ''
	AND ISNULL(@ClubID,'') != ''
	AND ISNULL(@FromServerTime,'') != ''
	AND ISNULL(@ToServerTime,'') != ''
	AND ISNULL(@GD,'') != ''
	AND ISNULL(@AamsMachineCode,'') != ''
	AND ISNULL(@UnivocalLocationCode,'') != ''
		BEGIN

			-- Inizializzazione
			SET @ReturnCode = 0
			DELETE FROM [TMP].[Delta]

			-- Log operazione
			EXEC spWriteOpLog @ProcedureName, 'Calcolo delta iniziato', @TicketCode, @BatchID
	
			-- Valori dei contatori di partenza
			INSERT	@TableMaxCounters
					(
						TotalBet
						,TotalWon
						,WinD
						,TotalBillIn 
						,TotalCoinIn 
						,TotalTicketIn 
						,TotalTicketOut 
						,TotalHandPay
						,TotalOut
						,TotalIn
					)
			SELECT	TOP 1
					TotalBet
					,TotalWon
					,WinD
					,TotalBillIn 
					,TotalCoinIn 
					,TotalTicketIn 
					,TotalTicketOut 
					,TotalHandPay
					,TotalOut
					,TotalIn
			FROM	[TMP].[CountersCork] WITH(NOLOCK) 
		
			-- Controllo dell'intervallo dei ricalcoli 	
			-- Se esistono le date di confine si procede con i calcoli	
			-- (Gli altri controlli vengono effettuati nella FindCork)
			IF @FromServerTime IS NOT NULL 
			AND @ToServerTime IS NOT NULL
				BEGIN	
					-- Calcoli 	
					
					SET @criteria = 
					'
					AND		MachineID = ' + CAST(@MachineID AS varchar(4)) + '
					AND		ServerTime > ''' +  CAST(@FromServerTime AS varchar(30)) + ''' 
					AND		ServerTime <= ''' + CAST(@ToServerTime AS varchar(30)) + '''
					'
					DELETE	FROM @RawData
					INSERT	@RawData
					EXEC	GetRemoteSpecificRawData
							@ConcessionaryName
							,@ClubID
							,
							'
								RowID
								,ServerTime
								,GameID
								,LoginFlag
								,ISNULL(TotalBet,0) AS TotalBet
								,ISNULL(TotalWon,0) AS TotalWon
								,ISNULL(TotalBillIn,0) AS TotalBillIn
								,ISNULL(TotalCoinIn,0) AS TotalCoinIn
								,ISNULL(TotalTicketIn,0) AS TotalTicketIn
								,ISNULL(TotalTicketOut,0) AS TotalTicketOut
								,ISNULL(TotalHandPay,0) AS TotalHandPay
								,ISNULL(WinD,0) AS WinD
								,ISNULL(TotalOut,0) AS TotalOut
								,ISNULL(TotalIn,0) AS TotalIn' -- Set di colonne specifico
							,@criteria

					;WITH TableRawDataCTE AS 
					(
						-- tappo iniziale
						SELECT 
								NULL AS RowID
								,@FromServerTime AS ServerTime
								,@MachineID AS MachineID
								,NULL AS GameID
								,1 AS LoginFlag2
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
						FROM	@TableMaxCounters
					
						UNION ALL

						-- dati				
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
										AND (TotalBet + TotalWon + TotalBillIn + TotalCoinIn + TotalTicketIn + TotalTicketOut + TotalHandPay + WinD + TotalOut + TotalIn) > 0
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
						FROM	@RawData 
					)
					,TabellaDelta01 AS 
					(
						SELECT 
								RowID
								,ServerTime
								,MachineID
								,GameID
								,LoginFlag2
								,COUNT(LoginFlag2) OVER (ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS C1
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
						FROM	TableRawDataCTE										   
					)
					,TabellaDelta02 AS 
					(
						SELECT 
								RowID
								,ServerTime
								,MachineID
								,GameID
								,LoginFlag2
								,C1
								,TotalBet		= TotalBet			- MAX(TotalBet)			OVER (PARTITION BY C1 ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)
								,TotalWon		= TotalWon			- MAX(TotalWon)			OVER (PARTITION BY C1 ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)
								,WinD			= WinD				- MAX(WinD)				OVER (PARTITION BY C1 ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)
								,TotalBillIn	= TotalBillIn		- MAX(TotalBillIn)		OVER (PARTITION BY C1 ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)
								,TotalCoinIn	= TotalCoinIn		- MAX(TotalCoinIn)		OVER (PARTITION BY C1 ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)
								,TotalTicketIn	= TotalTicketIn		- MAX(TotalTicketIn)	OVER (PARTITION BY C1 ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)
								,TotalTicketOut	= TotalTicketOut	- MAX(TotalTicketOut)	OVER (PARTITION BY C1 ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)
								,TotalHandPay	= TotalHandPay		- MAX(TotalHandPay)		OVER (PARTITION BY C1 ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)
								,TotalOut		= TotalOut			- MAX(TotalOut)			OVER (PARTITION BY C1 ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)
								,TotalIn		= TotalIn			- MAX(TotalIn)			OVER (PARTITION BY C1 ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) 
						FROM	TabellaDelta01
					)
					,TabellaDelta03 AS 
					(
						SELECT  
								RowID
								,ServerTime
								,MachineID
								,GameID
								,LoginFlag2
								,TotalBet
								,TotalWon
								,WinD
								,TotalBillIn
								,TotalCoinIn
								,TotalTicketIn
								,TotalTicketOut
								,TotalHandPay
								,TotalOut
								,TotalIn
								,VltCredit = 
								CASE 
									WHEN	TotalOut > 0 
									AND		(TotalBet + TotalWon + TotalBillIn + TotalCoinIn + TotalTicketIn + WinD + TotalIn)  > 0
									THEN	0 
									ELSE	CAST(TotalIn + TotalWon AS bigint) - CAST(TotalBet + TotalOut + WinD AS bigint) 
								END
						FROM	TabellaDelta02 
						WHERE	LoginFlag2 IS NULL 
						AND		(TotalBet + TotalOut + totalIN) != 0
						---AND NOT	(TotalBet = 0 AND TotalOut = 0 AND totalIN = 0)
					) 	
					,TabellaDelta04 AS 
					(
						SELECT 
								RowID
								,ServerTime
								,MachineID
								,GameID
								,0 AS LoginFlag
								,SumVltCredit = 
								CASE 
									WHEN	TotalOut IS NOT NULL
									AND		(TotalBet + TotalWon + TotalBillIn + TotalCoinIn + TotalTicketIn + WinD + TotalIn) = 0
									THEN	0 
									ELSE	SUM(VLTCredit) OVER (PARTITION BY MachineID ORDER BY ServerTime ROWS UNBOUNDED PRECEDING) 
								END
								,TotalBet
								,TotalWon
								,TotalBillIn
								,TotalCoinIn
								,TotalTicketIn
								,TotalTicketOut
								,TotalHandPay
								,WinD AS Tax
								,TotalIn
								,TotalOut 
						FROM	TabellaDelta03 
					)
					INSERT	[TMP].Delta 
							(
								RowID
								,UnivocalLocationCode
								,ServerTime
								,MachineID
								,GD
								,AamsMachineCode
								,GameID
								,GameName
								,LoginFlag
								,VLTCredit
								,TotalBet
								,TotalWon
								,TotalBillIn
								,TotalCoinIn
								,TotalTicketIn
								,TotalTicketOut
								,TotalHandPay
								,Tax
								,TotalIn
								,TotalOut
							)
					SELECT 
							RowID
							,@UnivocalLocationCode AS UnivocalLocationCode
							,ServerTime
							,MachineID
							,@GD AS GD
							,@AamsMachineCode AS AamsMachineCode
							,TD4.GameID AS GameID
							,REPLACE([GameNameType], CHAR(13) + CHAR(10), '') AS GameName
							,LoginFlag
							,SumVltCredit AS VLTCredit
							,TotalBet
							,TotalWon
							,TotalBillIn
							,TotalCoinIn
							,TotalTicketIn
							,TotalTicketOut
							,TotalHandPay
							,Tax
							,TotalIn
							,TotalOut -- sono campi calcolati
					FROM	TabellaDelta04 TD4
							JOIN 
							[dbo].[GameNameID] GNI WITH(NOLOCK) 
							ON TD4.GameID = GNI.GameID

					-- Log operazione
					EXEC spWriteOpLog @ProcedureName, 'Calcolo delta terminato', @TicketCode, @BatchID

				IF	NOT EXISTS 
					(
						SELECT	TOP 1 
								RowID 
						FROM	[TMP].[Delta] WITH(NOLOCK)
					)
					BEGIN
						SET @Msg = 'Empty table [TMP].[Delta]'
						RAISERROR (@Msg,16,1);
					END

				END --  IF @ToServerTime IS NOT NULL AND @FromServerTime IS NOT NULL
		 
			ELSE 
				BEGIN
					SET @Msg = '@FromServerTime OR @ToServerTime is Null'
					RAISERROR (@Msg,16,1);
				END	
				
		END -- 	IF ISNULL(@MachineID,0) != 0 AND ISNULL(@ClubID,'') != '' AND ISNULL(@FromServerTime,'') != '' AND ISNULL(@ToServerTime,'') != ''...
	ELSE
		BEGIN
			SET	@Msg = 
				'Una o più variabili non impostate. Verificare:' + CHAR(13) +
				'@MachineID = ' + CAST(@MachineID AS varchar(10)) + CHAR(13) +
				'@ConcessionaryName = ' + @ConcessionaryName + CHAR(13) +
				'@ClubID = ' + @ClubID + CHAR(13) +
				'@FromServerTime = ' + CAST(@FromServerTime AS varchar(30)) + CHAR(13) +
				'@ToServerTime = ' + CAST(@ToServerTime AS varchar(30)) + CHAR(13) +
				'@criteria = ' + @criteria + CHAR(13) 
			RAISERROR (@Msg,16,1);
		END
END TRY

-- Gestione Errore
BEGIN CATCH
	EXECUTE [ERR].[UspLogError]  @ErrorTicket = @TicketCode,@ErrorRequestDetailID  = @BatchID
	SET @ReturnCode = -1;
END CATCH
	      
RETURN @ReturnCode
