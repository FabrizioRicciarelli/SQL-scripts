USE [GMATICA_AGS_RawData_Elaborate_Stag_Agile]
GO
/****** Object:  StoredProcedure [RAW].[FindCountersCork]    Script Date: 18/07/2017 11:15:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: GA
Creation Date.......: 2017-01-30
Description.........: Calcola i valori di tutti i contatori non nulli precedenti all'ultimo calcolo dei delta effettuato

Revision			 
GA 2017-01-30..: Aggiunto creazione tappo caso senza riavvi, controlli (VltDismesse, Aggiornamento contatori,IsReadyForCork)

Note
- Use [Tab size] = 2 and [Indent size]

------------------
-- Parameters   --
------------------	

------------------
-- Call Example --
------------------
DECLARE @ReturnCode int
EXEC @ReturnCode =   [RAW].[FindCountersCork] @Direction = 1
SELECT @ReturnCode ReturnCode 
*/
ALTER PROC	[RAW].[FindCountersCork]
			@Direction BIT,
			@ReturnCode Int = 0 Output
AS
BEGIN
SET NOCOUNT ON;

BEGIN TRY
	DECLARE @TableMaxCounters TABLE (TotalBet bigint, TotalWon bigint, WinD bigint, TotalBillIn bigint, TotalCoinIn bigint, TotalTicketIn bigint, TotalTicketOut bigint, TotalHandPay bigint, TotalOut bigint, TotalIn bigint);
	DECLARE @TableNumbered TABLE(Col Varchar(50),Value Bigint, ServerTime Datetime2(3) , Rn int)
	-- Variabili
	DECLARE @Message VARCHAR(1000);
	DECLARE @ServerTimeMaxCounters datetime2(3),@Stringa Varchar(500), @FromServerTime Datetime2(3),@ToServerTime Datetime2(3),
	@RestartTime Datetime2(3),@CalcDurationSS Int,@CtnNumbered Int
	DECLARE @UpdateCalc bit,@GD Varchar(30),@Msg VARCHAR(1000),@TicketCode Varchar(50),@BatchID Int;
	DECLARE @FromOut DateTime2(3) = NULL,@ToOut DateTime2(3) = NULL, @OFFSETOUT SmallInt = 3600,@ClubID varchar(10), @MachineID SmallInt;
	-- Costanti
	DECLARE @ServerTime_FIRST datetime = '1900-01-01 00:00:00.000', @ServerTime_Last datetime = '2050-12-31 00:00:00.000';	
	DECLARE	@Totali TABLE(TotalBet int,TotalWon int ,WinD int,TotalBillIn int,TotalCoinIn int,TotalTicketIn int,TotalTicketOut int,TotalHandPay int,TotalOut int,TotalIn int)
	DECLARE @ProcedureName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + '.'+QUOTENAME(OBJECT_NAME(@@PROCID));

	------------------------------------------------------
	-- Calcolo VLT       --
	------------------------------------------------------
	-- Inizializzo
	TRUNCATE TABLE [TMP].[CountersCork]
	-- Log operazione			
	Select @TicketCode= TicketCode ,@BatchID = BatchID From [TMP].[TicketStart]
	SET @Msg  = 'Calcolo  tappo Ticket Code iniziato'
	INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
	Select @ProcedureName,@Msg,@TicketCode,@BatchID

	-- Tracking indietro 
	IF @Direction = 0
	BEGIN
	-- date di inizio e fine
		SELECT @MachineID = ISNULL(PrintingMachineID,MhMachineID),@ClubID  = ClubID  FROM [TMP].[TicketStart]
		SELECT @ToOut =  ISNULL((Select ServerTime FROM [TMP].[TicketServerTime]),@ServerTime_FIRST)
		SET @FromOut = ISNULL((Select MAX(Servertime) FROM  [TMP].RawData_View where TotalOut > 0 AND MachineID = @MachineID AND LoginFlag = 0 AND ServerTime < @ToOut),@ServerTime_FIRST)
	END ELSE IF @Direction = 1
	-- Tracking in avanti -- va preso il serverTime di IN di questo ticket
	BEGIN
	-- date di inizio e fine
		SELECT @MachineID = PayOutMachineID,@ClubID  = ClubID  FROM [TMP].[TicketStart]
		SELECT @FromOut = ISNULL((Select ServerTime FROM [TMP].[TicketServerTime]),@ServerTime_Last)
		SET @ToOut= ISNULL((Select MIN(Servertime) FROM  [TMP].RawData_View where TotalOut > 0 AND MachineID = @MachineID AND LoginFlag = 0 AND ServerTime > @FromOut),@ServerTime_Last)
	END
-- Controllo se posso effettuare il calcolo
 IF  (@FromOut <> @ServerTime_Last ) AND (@ToOut <> @ServerTime_FIRST)
	--Calcoli
	BEGIN
	-- Ultimo riavvio prima dei calcoli
		SET @RestartTime = 
						ISNULL((SELECT max(serverTime) AS serverTime FROM  [TMP].[RawData_View] t1 (nolock)						
								WHERE MachineID  = @MachineID AND ServerTime <= @FromOut
								AND LoginFlag = 1 
								AND TotalBet IS NOT NULL AND TotalWon IS NOT NULL AND WinD IS NOT NULL AND TotalBillIn IS NOT NULL 
								AND TotalCoinIn IS NOT NULL AND TotalTicketIn IS NOT NULL AND TotalTicketOut IS NOT NULL AND TotalHandPay IS NOT NULL 
								AND TotalOut IS NOT NULL AND TotalIn IS NOT NULL
							),@ServerTime_First)
	--Select @MachineID,@LastRawDataOut,@LastDeltaTotalOut,@RestartTime,'Incremental'
	--select @RestartTime
	IF @RestartTime  <> @ServerTime_FIRST 
	BEGIN
			DELETE	FROM @Totali
			INSERT	@Totali(TotalBet,TotalWon,WinD,TotalBillIn,TotalCoinIn,TotalTicketIn,TotalTicketOut,TotalHandPay,TotalOut,TotalIn)
			SELECT	TotalBet,TotalWon,WinD,TotalBillIn,TotalCoinIn,TotalTicketIn,TotalTicketOut,TotalHandPay,TotalOut,TotalIn
			FROM	[TMP].[RawData_View]
			WHERE	(ServerTime Between @RestartTime AND @FromOut) 
			AND		MachineID = @MachineID

												
			-- Creazione tappo 
			;With NumberedNext 
			AS (
				SELECT	Col, Value, ROW_NUMBER() OVER (PARTITION BY Col ORDER BY ServerTime desc) AS rn
				--FROM [TMP].RawData_View (nolock)
				FROM @Totali
				UNPIVOT
				(
					[Value] FOR Col IN 
					(
						TotalBet,TotalWon,WinD,TotalBillIn,TotalCoinIn,TotalTicketIn,TotalTicketOut,TotalHandPay,TotalOut,TotalIn
					)
				) p							
				--WHERE ServerTime Between @RestartTime AND @FromOut AND MachineID = @MachineID
			)
			-- popolo tabella [TMP].[CountersCork] per i calcoli successivi										 						
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
			WHERE	rn = 1 
			--Fine creazione tappo 
		END
	END
	--Aggiorno i contatori
			INSERT [TMP].[CountersCork]  (ClubID, MachineID, FromOut,ToOut,TotalBet, TotalWon, WinD, TotalBillIn, TotalCoinIn, TotalTicketIn, TotalTicketOut, TotalHandPay, TotalOut, TotalIn)
			SELECT @ClubID, @MachineID,@FromOut,@ToOut, TMCN.TotalBet, TMCN.TotalWon,  TMCN.WinD, TMCN.TotalBillIn , TMCN.TotalCoinIn , TMCN.TotalTicketIn , TMCN.TotalTicketOut , TMCN.TotalHandPay, TMCN.TotalOut, TMCN.TotalIn
					 FROM @TableMaxCounters AS  TMCN					
	-- Verifiche finali
	SET @Msg  = 'Calcolo tappo terminato'
	INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
	Select @ProcedureName,@Msg,@TicketCode,@BatchID
	-- Errore specifico
	IF NOT EXISTS (Select * From [TMP].[CountersCork])
		BEGIN
		SET @Msg = 'Empty table [TMP].[CountersCork]'
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