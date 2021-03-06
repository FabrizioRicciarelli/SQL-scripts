USE [GMATICA_AGS_RawData_Elaborate_Stag_Agile]
GO
/****** Object:  StoredProcedure [RAW].[TicketOutServerTime2]    Script Date: 13/07/2017 14:04:53 ******/
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
                                                                            
Author..............: GA, FR
Creation Date.......: 2017-05-19
Last Revision Date..: 2017-07-13
Description.........: Parte da un ticketOut o MH remoto e trova il corrispondente Servertime sui delta

Revision			 

Note
- Use [Tab size] = 2 and [Indent size]

------------------
-- Parameters   --
------------------	

------------------
-- Call Example --
-----------------
DECLARE	@ReturnCode int
TRUNCATE TABLE [TMP].[TicketServerTime]
EXEC	@ReturnCode =   
		[RAW].[TicketOutServerTime2] 
			@TicketCode = '4412211590049855'
			,@Direction = 0 -- 0 = Tracciamento a ritroso, 1 = Tracciamento in avanti
			,@ClubID = '1000296'
			,@BatchID = 1
			,@ReturnCode = @ReturnCode OUTPUT
SELECT	@ReturnCode AS ReturnCode 

SELECT * FROM [TMP].[TicketServerTime] 

DECLARE	@ReturnCode int
EXEC	@ReturnCode =   
		[RAW].[TicketOutServerTime2] 
			@TicketCode = '1000294MHR201502110001'
			,@Direction = 0
			,@ClubID = '1000296'
			,@BatchID = 1
SELECT	@ReturnCode ReturnCode 

SELECT * FROM [TMP].[TicketServerTime] 


EXEC	[RAW].[TicketOutServerTime2] 
		@TicketCode = '355536370074870687'
		,@Direction = 1
		,@ClubID = '1000296'
		,@BatchID = 1

SELECT * FROM [TMP].[TicketServerTime] 


SELECT * FROM dbo.VTodayErrorLog ORDER BY ErrorTime DESC

*/
ALTER PROC	[RAW].[TicketOutServerTime2] 
			@TicketCode varchar(50)
			,@Direction bit
			,@ClubID varchar(10) = NULL
			,@BatchID int
			,@ReturnCode int = 0 OUTPUT
AS
SET NOCOUNT ON;

DECLARE 
		@OFFSET int
		,@Rank smallint
		,@IterationNum tinyint
		,@Rn smallint
		,@ServerTime datetime2(3)
		,@DifferenceSS int
		,@TicketValue int
		,@TotalOutDiff int
		,@NumRecord int
		,@DataStart datetime2(3)
		,@PrintingData datetime2(0) = NULL
		,@PrintingDataIsNULL bit = 0
		,@MachineID smallint
		,@TotalOut int
		,@ViewString varchar(5000)
		,@FromServerTimeOut datetime2(3)
		,@ToServerTimeOut datetime2(3)
		,@FromServerTimeOutTMP datetime2(3)
		,@PayOutData datetime2(3)
		,@Msg varchar(1000)
		,@ConcessionaryID tinyint
		,@ConcessionaryName sysname
		,@ReturnMessage varchar(1000)
		,@Message varchar(1000)
		,@ReturnCode2 int
		,@ReturnMessage2 varchar(1000)
		,@ServerTime_FIRST datetime = '1900-01-01 00:00:00.000'
		,@ServerTime_LAST datetime = '2050-12-31 00:00:00.000'
		,@criteria varchar(4000)
		,@ProcedureName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + '.' + QUOTENAME(OBJECT_NAME(@@PROCID))
		,@TMP sql_variant

		,@TicketList TICKETLIST_TYPE
		,@Tickets TICKET_TYPE

DECLARE @RawData TABLE(ServerTime datetime, TotalOut int)


DECLARE	@ServerTimeTable TABLE
		(
			[ServerTime] datetime2(3)
			,[Rn] smallint
			,DifferenceSS int
		)

DECLARE @TotalOutTable TABLE
		(
			[ServerTime] datetime2(3)
			,TotalOut int
		)	

BEGIN TRY

	SELECT	TOP 1
			@ServerTime = NULL
			,@IterationNum = 1
			,@NumRecord = 0
			,@DataStart = SYSDATETIME()
			,@OffSet = OffSetOut
			,@ConcessionaryID = ConcessionaryID 
			,@ConcessionaryName = ConcessionaryName
	FROM	[Config].[Table] WITH(NOLOCK)

	TRUNCATE TABLE [TMP].[TicketServerTime]
	TRUNCATE TABLE [TMP].[TicketStart]

	-- Log operazione
	EXEC spWriteOpLog @ProcedureName, 'Calcolo TicketOutServerTime iniziato', @TicketCode, @BatchID

	-- Prelievo dei dati del ticket MH di partenza
	INSERT	@TicketList(TicketCode) 
	VALUES (@TicketCode)
	
	INSERT	@Tickets
	EXEC	dbo.GetRemoteTickets
			 @LOCALConcessionaryID = @ConcessionaryID
			,@LOCALClubID = @ClubID
			,@LOCALTicketList = @TicketList
			,@LOCALFromDate = @ServerTime_FIRST
			,@LOCALToDate = @ServerTime_LAST
			,@LOCALIsMhx = 0
			,@ReturnMessage = NULL
	
	-- Errore specifico
	IF	NOT EXISTS
		(
			SELECT	TOP 1
					ClubID 
			FROM	@Tickets
		)
		BEGIN
			SET @Msg = 'Numero ticket di partenza errato'
			RAISERROR (@Msg,16,1);
		END


	-- Tracciamento in avanti
	IF @Direction  = 1
		BEGIN
			-- PrintingData
			SELECT	
					@PayOutData = PayOutData
					,@MachineID = PayOutMachineID 
			FROM	@Tickets
			
			-- Prelievo del primo Out prima dell'IN
			SET @criteria = 
			'
			AND		TotalOut > 0 
			AND		ServerTime < ''' + CAST(@PayOutData AS varchar(30)) + ''' 
			AND		MachineID = ' + CAST(@MachineID AS varchar(4)) + '
			'
			EXEC	dbo.GetRawDataScalar
					@ConcessionaryName
					,@ClubID
					,'MAX(ServerTime) AS ServerTime' -- Set di colonne specifico
					,@criteria
					,@TMP OUTPUT
			SELECT	@FromServerTimeOut = ISNULL(CAST(@TMP AS datetime), @ServerTime_FIRST)

			-- Inserimento
			INSERT	[TMP].[TicketServerTime] 
					(
						ServerTime
						,Direction
						,MachineID
					)
			VALUES	(
						@FromServerTimeOut
						,@Direction
						,@MachineID 
					)
		END

	-- Tracciamento a ritroso
	IF @Direction  = 0
		BEGIN
			---- Controllo se MH o ticket----
			SELECT	TOP 1
					@PrintingData = 
						CASE
							WHEN PrintingData IS NULL
							THEN EventDate
							ELSE PrintingData
						END
					,@MachineID =
						CASE
							WHEN PrintingData IS NULL
							THEN MhMachineID
							ELSE PrintingMachineID
						END
					,@PrintingDataIsNULL =
						CASE
							WHEN PrintingData IS NULL
							THEN 1
							ELSE 0
						END
			FROM	@Tickets

			SELECT	TOP 1 
					@OffSet = 
						CASE 
							WHEN @PrintingDataIsNULL = 1
							THEN OffSetMH -- Preleva l'OffsetMH al posto dell'OffsetOUT
							ELSE OffsetOUT
						END
			FROM	Config.[Table]

			-- Intervallo per gli out nel range massimo di ricerca
			SET @criteria = 
			'
			AND		TotalOut > 0 
			AND		LoginFlag = 0 
			AND		ServerTime < DATEADD(SS,-' + CAST(@OffSet AS varchar(8)) + ' * 30, ''' + CAST(@PrintingData AS varchar(30)) + ''') 
			AND		MachineID = ' + CAST(@MachineID AS varchar(4)) + '
			'
			EXEC	dbo.GetRawDataScalar
					@ConcessionaryName
					,@ClubID
					,'MAX(ServerTime) AS ServerTime' -- Set di colonne specifico
					,@criteria
					,@TMP OUTPUT
			SELECT	@FromServerTimeOut = ISNULL(CAST(@TMP AS datetime), @ServerTime_FIRST)
			
			SET @criteria = 
			'
			AND		TotalOut > 0 
			AND		LoginFlag = 0 
			AND		ServerTime > DATEADD(SS,' + CAST(@OffSet AS varchar(8)) + ' * 30, ''' + CAST(@PrintingData AS varchar(30)) + ''') 
			AND		MachineID = ' + CAST(@MachineID AS varchar(4)) + '
			'
			EXEC	dbo.GetRawDataScalar
					@ConcessionaryName
					,@ClubID
					,'MIN(ServerTime) AS ServerTime' -- Set di colonne specifico
					,@criteria
					,@TMP OUTPUT
			SELECT	@ToServerTimeOut = ISNULL(CAST(@TMP AS datetime), @ServerTime_FIRST)

			SET @criteria = 
			'
			AND		TotalOut > 0 
			AND		LoginFlag = 0 
			AND		(ServerTime BETWEEN ''' +  CAST(@FromServerTimeOut AS varchar(30)) + ''' AND ''' + CAST(@ToServerTimeOut AS varchar(30)) + ''')
			AND		MachineID = ' + CAST(@MachineID AS varchar(4)) + '
			'
			DELETE	FROM @RawData
			INSERT	@RawData
			EXEC	GetRemoteSpecificRawData
					@ConcessionaryName
					,@ClubID
					,'ServerTime, TotalOut' -- Set di colonne specifico
					,@criteria

			-- Calcolo dei TotalOut
			;WITH CTE_TotalOut AS
			(
				SELECT   
						ServerTime
						,TotalOut = TotalOut -	
						ISNULL
						(
							MAX(TotalOut) 
							OVER 
							(
								ORDER BY ServerTime 
								ROWS	BETWEEN 
										UNBOUNDED PRECEDING 
										AND 
										1 PRECEDING
							)
							,0
						)  
				FROM	@RawData
			)
			INSERT	@TotalOutTable
					(
						ServerTime
						,TotalOut
					)
			SELECT	
					ServerTime
					,TotalOut 
			FROM	CTE_TotalOut 
			WHERE	ServerTime > @FromServerTimeOut

			-- Iterazioni
			WHILE  
			(
				@NumRecord = 0 
				AND 
				@IterationNum <= 3
			)
				BEGIN
					-- Matching ticket OUT
					;WITH CTE_TCK_OUT AS 
					(
						SELECT
								ServerTime
								,ABS
								(
									DATEDIFF
									(
										SECOND
										,ServerTime
										,ISNULL(PrintingData, EventDate)
									)
								) AS DifferenceSS
								,RANK()	OVER  
										(
											PARTITION BY TicketValue 
											ORDER BY	ABS
														(
															DATEDIFF
															(
																SECOND
																,ServerTime
																,ISNULL(PrintingData, EventDate)
															)
														) ASC
										) AS RowRank 
						FROM
						(
							SELECT 
									Servertime
									,TotalOut 
							FROM	@TotalOutTable
						)	T1 
							INNER JOIN  
							@Tickets T2 
							ON 
							(
								ISNULL(PrintingData,EventDate) 
								BETWEEN DATEADD(SECOND, -@OffSet, ServerTime) 
								AND DATEADD(SECOND, @OffSet, ServerTime)
							) 
							AND T1.TotalOut = T2.TicketValue
					)
					 -- Inserimento dei ticket corrispondenti
					INSERT	@ServerTimeTable
							(
								ServerTime
								,Rn
								,DifferenceSS
							)
					SELECT	
							ServerTime
							,RowRank
							,DifferenceSS 
					FROM	CTE_TCK_OUT 
					WHERE	RowRank = 1
					
					SET @NumRecord = @@RowCount

					-- Inserimento nei risultati finali
					IF @NumRecord > 0
						BEGIN
							INSERT	[TMP].[TicketServerTime] 
									(
										ServerTime
										,IterationNum
										,Rn
										,DifferenceSS
										,Direction
										,MachineID
									)
							SELECT
									ServerTime
									,@IterationNum AS IterationNum
									,Rn
									,DifferenceSS
									,@Direction AS Direction
									,@MachineID AS MachineID
							FROM	@ServerTimeTable
						END

					--Incremento ciclo
					SET @IterationNum += 1;

					SELECT 
							@OFFSET = 
							CASE @IterationNum
								WHEN 2
								THEN @OFFSET * 6
								WHEN 3
								THEN @OFFSET * 5
							END
				END
				-- Fine calcoli
		END -- IF @Direction  = 0

		-- Log operazione
		EXEC spWriteOpLog @ProcedureName, 'Calcolo TicketOutServerTime terminato', @TicketCode, @BatchID
END TRY

-- Gestione Errore
BEGIN CATCH
	EXEC	[ERR].[UspLogError]  
			@ErrorTicket = @TicketCode
			,@ErrorRequestDetailID = @BatchID
	
	SET @ReturnCode = -1
END CATCH
      
RETURN @ReturnCode
