ALTER PROCEDURE [RAW].[CalculateDeltaFromTicketOut]
@ReturnCode Int = 0 Output
AS
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: GA
Creation Date.......: 2017-05-22
Description.........: Calcola i Delta in runtime da Out a Out

Note
- Use [Tab size] = 3 and [Indent size] 3 (Insert spaces)

------------------
-- Parameters   --
------------------	

------------------
-- Call Example --
------------------ 
DECLARE @ReturnCode int
EXEC @ReturnCode =  [RAW].[CalculateDeltaFromTicketOut]
SELECT @ReturnCode ReturnCode 
*/
BEGIN
SET NOCOUNT ON;
		             
BEGIN TRY  
	-- Tabelle
	DECLARE	@TableMaxCounters TABLE (TotalBet bigint, TotalWon bigint, WinD bigint, TotalBillIn bigint, TotalCoinIn bigint, TotalTicketIn bigint, TotalTicketOut bigint,TotalHandPay bigint, TotalOut bigint, TotalIn bigint);

	-- Variabili
	DECLARE	@Message VARCHAR(1000),@Stringa varchar(100), @ServerTime_Delta datetime, @FromServerTime Datetime,@ToServerTime Datetime,
			@CalcDurationSS Int,@ClubID varchar(10),@MachineID SmallInt,@Msg VARCHAR(1000),@TicketCode Varchar(50),@UnivocalLocationCode [VARCHAR](30),@GD [VARCHAR](30),
			@AamsMachineCode [VARCHAR](30),@GameName Varchar(100),@Direction Bit = NULL,@ServertimePost Datetime;
	DECLARE @ProcedureName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) +'.'+QUOTENAME(OBJECT_NAME(@@PROCID)),@BatchID Int;
	DECLARE @ServerTimeTicketStart Datetime,@ServertimePre  DATETIME,@VltMinSession SMALLINT
	-- Costanti
	DECLARE @ServerTime_FIRST datetime = '1900-01-01 00:00:00.000', @ServerTime_Last datetime = '2050-12-31 00:00:00.000', @DailyLoadingType_Delta tinyint = 1;

   -----------------			                   
	-- Inizializzo
	-----------------
	-- MachineID
	SELECT @MachineID = MachineID,@ClubID  = ClubID  FROM  [TMP].[CountersCork]
	SELECT @GD = [Machine],@AamsMachineCode = AamsMachineCode FROM [dbo].[VLT] WHERE MachineID = @MachineID AND ClubID = @ClubID
	SELECT @UnivocalLocationCode = UnivocalLocationCode FROM dbo.GamingRoom	WHERE ClubID  = @ClubID		
	Select @TicketCode= TicketCode ,@BatchID = BatchID From [TMP].[TicketStart]
	SELECT @VltMinSession = MinVltEndCredit FROM Config.[Table]
	SET @ServertimePre = NULL
	
	-- Log operazione
	SET @Msg  = 'Calcolo delta iniziato'
	INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
	Select @ProcedureName,@Msg,@TicketCode,@BatchID
	
	-- pulisco
	DELETE FROM @TableMaxCounters;
	DELETE FROM [TMP].[Delta]


	-- Calcolo dall' ultimo totalout presente nel tappo 
	SELECT @FromServerTime = FromOut FROM [TMP].[CountersCork] WHERE ClubID = @ClubID AND MachineID = @MachineID
	SELECT @ToServerTime  = ToOut FROM [TMP].[CountersCork] WHERE ClubID = @ClubID AND MachineID = @MachineID				
	
	-------------------------------------------------------
	-- Valori dei contatori di partenza
	-------------------------------------------------------
	INSERT INTO @TableMaxCounters(TotalBet, TotalWon,  WinD, TotalBillIn , TotalCoinIn , TotalTicketIn , TotalTicketOut , TotalHandPay, TotalOut, TotalIn)
	SELECT TotalBet, TotalWon,  WinD, TotalBillIn , TotalCoinIn , TotalTicketIn , TotalTicketOut , TotalHandPay, TotalOut, TotalIn
					FROM [TMP].[CountersCork] WHERE ClubID = @ClubID AND MachineID = @MachineID
		
	-- Controllo se l'intervallo dei ricalcoli 	-- Se ho le date di confine inizio i calcoli	(Il resto dei controlli lo effettuo nella FindCork)
	IF (@ToServerTime IS NOT NULL AND @FromServerTime IS NOT NULL)
		BEGIN	

		;WITH TableRawDataCTE AS (
			
			-- tappo iniziale
			SELECT	NULL AS RowID,@FromServerTime  AS ServerTime,@MachineID AS MachineID,NULL AS GameID,0 AS LoginFlag,TotalBet,TotalWon,TotalBillIn,TotalCoinIn,TotalTicketIn,TotalTicketOut,TotalHandPay,WinD,TotalOut,TotalIn 
			FROM	@TableMaxCounters
			
			UNION ALL
			
			-- dati				
			SELECT	RowID, ServerTime,@MachineID AS MachineID,GameID,LoginFlag,TotalBet,TotalWon,TotalBillIn,TotalCoinIn,TotalTicketIn,TotalTicketOut,TotalHandPay,WinD,TotalOut,TotalIn
			FROM	[TMP].[RawData_View]  (nolock) 
			WHERE	MachineID = @MachineID 
			AND		(ServerTime > @FromServerTime AND ServerTime <= @ToServerTime)
		)
		,Tabella01 AS (
			SELECT	RowID, ServerTime, MachineID, GameID, LoginFlag,
                    TotalBet =   TotalBet - ISNULL(MAX(TotalBet) OVER(ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0),
                    TotalWon =   TotalWon - ISNULL(MAX(TotalWon) OVER(ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0),
                    WinD =        WinD - ISNULL(MAX(WinD) OVER(ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0),
                    TotalBillIn = TotalBillIn - ISNULL(MAX(TotalBillIn) OVER(ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0),
                    TotalCoinIn = TotalCoinIn - ISNULL(MAX(TotalCoinIn) OVER(ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0),
                    TotalTicketIn = TotalTicketIn - ISNULL(MAX(TotalTicketIn) OVER(ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0),
                    TotalTicketOut = TotalTicketOut - ISNULL(MAX(TotalTicketOut) OVER(ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0),
                    TotalHandPay = TotalHandPay - ISNULL(MAX(TotalHandPay) OVER(ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0),
                    TotalOut = TotalOut - ISNULL(MAX(TotalOut) OVER(ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0),
                    TotalIn = TotalIn - ISNULL(MAX(TotalIn) OVER(ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0) 
            FROM	TableRawDataCTE
        )
		,Tabella02 AS (
			SELECT	RowID, ServerTime, MachineID, GameID, LoginFlag,
					TotalBet, TotalWon, WinD AS Tax, TotalBillIn, TotalCoinIn, TotalTicketIn, TotalTicketOut,TotalHandPay,TotalIn,TotalOut,
					VLTCredit = SUM(cast((IsNull(TotalIn, 0) + IsNULL(TotalWon,0))  as bigint) - cast((IsNULL(TotalBet,0) + IsNULL(TotalOut,0) + IsNULL(WinD,0)) as bigint)) 
					OVER(ORDER BY ServerTime ROWS BETWEEN UNBOUNDED PRECEDING AND Current ROW)  
            FROM Tabella01 t1
		)
			-- Tabella finale  
		INSERT	[TMP].Delta (RowID,[UnivocalLocationCode],ServerTime, MachineID,[GD],AamsMachineCode, GameID,GameName,LoginFlag,VLTCredit,TotalBet,TotalWon,TotalBillIn,TotalCoinIn,TotalTicketIn,TotalTicketOut, TotalHandPay,Tax,TotalIn,TotalOut)
		SELECT	RowID,@UnivocalLocationCode,ServerTime, MachineID,@GD,@AamsMachineCode, T1.GameID,replace([GameNameType], char(13) + char(10), ''),LoginFlag,VltCredit,TotalBet,TotalWon,TotalBillIn,TotalCoinIn,TotalTicketIn,TotalTicketOut, TotalHandPay,Tax,TotalIn,TotalOut -- sono campi calcolati
		FROM	Tabella02 T1
				INNER JOIN 
				[dbo].[GameNameID] T2 
				ON T1.GameID = T2.GameID
			
		-- Cancello per avere le sessioni con limite a 50 C
		SELECT @ServerTimeTicketStart = [ServerTime],@Direction = Direction  
		FROM [TMP].[TicketServerTime]
			
		SET @ServertimePre = (
			SELECT	Max([ServerTime]) 
			FROM	[TMP].[Delta] 
			WHERE	VLTCredit < @VltMinSession 
			AND		ServerTime < @ServerTimeTicketStart
			AND		ISNULL(TotalIn,0) = 0
		)	

		IF @ServertimePre IS NOT NULL	
		BEGIN
			DELETE FROM [TMP].[Delta] 
			WHERE ServerTime < @ServertimePre
				
			-- credito residuo da sessione precedente
			UPDATE	[TMP].Delta 
			SET		TotalBet = NULL
					,TotalWon = NULL 
			WHERE	ServerTime = @ServertimePre
		END

		-- se è in avanti la sessione finisce se il credito diventa inferiore a mincredit
		IF @Direction = 1
		BEGIN
			SET @ServertimePost = (
				SELECT	MIN([ServerTime]) 
				FROM	[TMP].[Delta] 
				WHERE	VLTCredit < @VltMinSession 
				AND		ServerTime > @ServerTimeTicketStart 
				AND		ISNULL(TotalOut,0) = 0)
				
			IF  @ServertimePost IS NOT NULL
					DELETE		
					FROM	[TMP].[Delta] 
					WHERE	ServerTime > @ServertimePost
		END

		---- DEBUG
		--SELECT	'CalculateDeltaFromTicketOut - TMP.DELTA' AS TABELLA
		--		,*
		--FROM	[TMP].[Delta]

		-- Log operazione
		SET @Msg  = 'Calcolo delta terminato'
		INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
		Select @ProcedureName,@Msg,@TicketCode,@BatchID
	END ELSE 
		 -- Errore specifico
		 BEGIN
		 	SET @Msg = '@FromServerTime OR @ToServerTime is Null'
			RAISERROR (@Msg,16,1);
		 END	
		-- Errore specifico
	   IF NOT EXISTS (Select TOP 1 * FROM [TMP].[Delta])
		BEGIN
			SET @Msg = 'Empty table [TMP].[Delta]'
			RAISERROR (@Msg,16,1);
		END

END TRY
	-- Gestione Errore
		   BEGIN CATCH
				EXECUTE [ERR].[UspLogError]  @ErrorTicket = @TicketCode,@ErrorRequestDetailID  = @BatchID
            SET @ReturnCode = -1;
       END CATCH
      
RETURN @ReturnCode

END
	
