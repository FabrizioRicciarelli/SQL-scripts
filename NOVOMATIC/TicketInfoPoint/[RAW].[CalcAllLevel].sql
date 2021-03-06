USE [GMATICA_AGS_RawData_Elaborate_Tip]
GO
/****** Object:  StoredProcedure [RAW].[CalcAllLevel]    Script Date: 06/03/2018 12:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [RAW].[CalcAllLevel]
@ConcessionaryID tinyint,
@Direction Bit,
@TicketCode Varchar(50),
@BatchID Int,
@MaxLevel SmallInt,
@ClubID Varchar(10) = NULL,
@ReturnCode Int = NULL Output 
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
Creation Date.......: 2017-05-23 
Description.........: Calcola tutti i livelli delta,sessioni,ticket

Revision			 

Note
- Use [Tab size] = 3 and [Indent size] 3

------------------
-- Parameters   --
------------------	

------------------
-- Call Example --
------------------
truncate table err.errorlog
truncate table [ETL].[OperationLog] 
DECLARE @ReturnCode int
EXEC [RAW].[CalcAllLevel] @ConcessionaryID = 7, @Direction = 0,@TicketCode = '375559646310240944' ,@BatchID = 1,@MaxLevel = 10,@ReturnCode = @ReturnCode Output
Select @ReturnCode

*/
BEGIN
SET NOCOUNT ON;

DECLARE @ConcessionaryDB varchar(50),@DataStart Datetime2(3),@Message Varchar(1000), @Level Int,@Msg vARCHAR(1000), @ReturnCodeInternal Int, @ReturnCodeGlobal Int,@NumTicket SmallInt,@RecID SMALLINT,
        @MachineID TINYINT,@CalcEnd BIT,@VltEndCredit Int,@CashDesk  TinyInt = 0,@PayoutData DateTime2(3),@ProcedureName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) +'.'+QUOTENAME(OBJECT_NAME(@@PROCID)),
		  @ServerTime_FIRST datetime = '1900-01-01 00:00:00.000',@PrintingData DateTime2(3), @ServerTimeStart DateTime2(3),@SessionParentID INT,@SessionID INT ;
DECLARE @TabellaLavoro TABLE(RecID int identity(1,1) PRIMARY KEY, SessionID int, ReceiptID int, TicketWayID tinyint, Level smallint, SessionParentID int);

CREATE TABLE #TicketToCalcSucc ([Id] [INT] IDENTITY(1,1) NOT NULL,[TicketCode] [VARCHAR](50) NOT NULL,
	[SessionID] [INT] NULL,[SessionParentID] [INT] NULL,[Level] [INT] NULL)

BEGIN TRY
SET @CalcEnd = 0
-- Log operazione
SET @Msg  = 'Calcolo globale iniziato'
INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
Select @ProcedureName,@Msg,@TicketCode,@BatchID

----Inizializzo
TRUNCATE table [RAW].[Delta]
TRUNCATE table [RAW].[Session]
TRUNCATE table [RAW].[TicketToCalc]

IF @Direction = 0
BEGIN
	-- livello 0
	SET @SessionParentID = NULL
	SET @LEVEL = 0
	EXEC	[RAW].[CalcAll]
			@ConcessionaryID = @ConcessionaryID
			,@Direction = @Direction
			,@TicketCode = @TicketCode
			,@SessionParentID = @SessionParentID
			,@Level = @Level
			,@BatchID = @BatchID
			,@ReturnCode = @ReturnCode Output

	-- sessione
	SELECT	@SessionID = SessionID 
	FROM	[RAW].[Session] 
	WHERE	StartTicketCode = @TicketCode

	-- ticket da calcolare a livello 0
	INSERT	[RAW].[TicketToCalc] ([TicketCode],[FlagCalc],SessionID,[SessionParentID] ,[Level])
	SELECT @TicketCode,1,@SessionID,@SessionParentID,@Level 
	
	-- sessione padre successviva
	SELECT @SessionParentID = @SessionID

	SET @Level += 1

    -- ticket da calcolare nei livelli successivi
	INSERT	INTO [RAW].[TicketToCalc] ([TicketCode],[FlagCalc],SessionID,[SessionParentID] ,[Level])
	SELECT	ticketCode,0,@SessionID,@SessionParentID,@Level 
	FROM	Raw.Delta 
	WHERE	SessionID = @SessionID 
	AND		TotalIn <> 0 
	AND		TicketCode IS NOT NULL
	
	SET @NumTicket = @@ROWCOUNT

	-- DEBUG
	SELECT @NumTicket AS NumTicket_ROWCOUNT, @Level AS Level
				
	INSERT	INTO #TicketToCalcSucc ([TicketCode],SessionID,[SessionParentID] ,[Level])
	SELECT	[TicketCode],SessionID,[SessionParentID] ,[Level] 
	FROM	[RAW].[TicketToCalc] 
	WHERE Level = @Level

	---- DEBUG
	--SELECT	'CALCALLLEVEL - POST-INSERT' AS PHASE
	--		,@TicketCode AS TicketCode
	--		,1 AS Flagcalc
	--		,@SessionID AS SessionID
	--		,@SessionParentID AS SessionParentID
	--		,@Level AS Level
	--		,@NumTicket AS NumTicket
	--SELECT	'CALCALLLEVEL - POST-INSERT - [RAW].[TicketToCalc]' AS TABELLA, *
	--FROM	[RAW].[TicketToCalc] 
	--SELECT	'CALCALLLEVEL - POST-INSERT - #TicketToCalcSucc' AS TABELLA, *
	--FROM	#TicketToCalcSucc 


	-- ciclo su tutto il livello
	SET @RecID = 1

	WHILE (@RecID <= @NumTicket) AND (@Level < @MaxLevel)
		BEGIN

			SELECT	@TicketCode = TicketCode, @Level = Level 
			FROM	#TicketToCalcSucc 
			WHERE	ID = @RecID

			-- DEBUG
			SELECT	'***' AS CURRENT_TICKET, @TicketCode AS TicketCode, @Level AS Level

			SELECT	@SessionParentID = SessionParentID  
			FROM	[RAW].[TicketToCalc] 
			WHERE	TicketCode = @TicketCode

			EXEC	[RAW].[CalcAll] 
					@ConcessionaryID = @ConcessionaryID
					,@Direction = @Direction
					,@TicketCode = @TicketCode
					,@SessionParentID = @SessionParentID
					,@Level = @Level
					,@BatchID =@BatchID
					,@ReturnCode = @ReturnCode OUTPUT
		
			-- scrivo che ho calcolato il ticket
			SELECT	@SessionID = SessionID 
			FROM	[Raw].Session 
			WHERE	StartTicketCode = @TicketCode
  
			UPDATE	[RAW].[TicketToCalc] 
			SET		FlagCalc = 1
					,SessionID = @SessionID 
			WHERE	TicketCode = @TicketCode
   
			MERGE	[RAW].[TicketToCalc] AS target  
			USING	(	
						SELECT 
								ticketCode
								,0 AS FlagCalc 
						FROM	Raw.Delta 
						WHERE	SessionID = @SessionID 
						AND		TotalIn <> 0 
						AND		TicketCode IS NOT NULL
					) AS source
			ON		(target.TicketCode = source.TicketCode) 
			WHEN	NOT MATCHED 
			THEN	INSERT (TicketCode, FlagCalc, SessionParentID, Level)  
			VALUES	(source.TicketCode, 0, @SessionID, @Level+1);

			SET @RecID += 1
		
			IF @RecID > @NumTicket 
				BEGIN
					SET  @Level += 1 
					TRUNCATE TABLE	#TicketToCalcSucc
					INSERT	#TicketToCalcSucc ([TicketCode],SessionID,[SessionParentID] ,[Level])
					SELECT	[TicketCode],SessionID,[SessionParentID] ,[Level] 
					FROM	[RAW].[TicketToCalc] 
					WHERE	Level = @Level
					
					SELECT @NumTicket = @@ROWCOUNT
					
					SET @RecID = 1

					-- DEBUG
					SELECT	'CURRENT PARAMETERS' AS PHASE
							,@NumTicket AS NumTicket
							,@RecID AS RecID
							,@Level AS Level
					SELECT	'#TicketToCalcSucc' AS TABELLA, *
					FROM	#TicketToCalcSucc
				END
		END
END
IF @Direction = 1
BEGIN
	-- In avanti
	IF  @ClubID = NULL 
			(Select @ClubID = ClubID From [TMP].[TicketStart])
	SET @VltEndCredit = (SELECT [MinVltEndCredit] FROM [Config].[Table])
	-- Livello
	SET @Level = 0
	SET @ReturnCode = 0;
	SET @SessionParentID = NULL

-- Inserisco il ticket tra quelli da calcolare 
INSERT INTO [RAW].[TicketToCalc] ([TicketCode],[FlagCalc],SessionID,[SessionParentID] ,[Level])
Select @TicketCode,0,@SessionID,@SessionParentID,@Level
-- ciclo finché esistono ticketout
WHILE EXISTS (Select TicketCode FROM  [RAW].[TicketToCalc] WHERE  FlagCalc = 0 AND Level = @Level) AND (@Level <= @MaxLevel)
		AND (@CalcEnd = 0)
BEGIN
	-- Prendo il ticket da calcolare
	SELECT @TicketCode = Ticketcode,@SessionParentID = SessionParentID  FROM RAW.TicketToCalc WHERE Level = @level
	--Calcolo
	EXEC [RAW].[CalcAll] @ConcessionaryID = @ConcessionaryID, @Direction = @Direction,@TicketCode = @TicketCode,
								@SessionParentID = @SessionParentID,@Level = @Level, @BatchID = @BatchID,@ReturnCode = @ReturnCode OUTPUT
	-- 
	SELECT @SessionID = SessionID FROM Raw.Session WHERE StartTicketCode = @TicketCode 
	SELECT @MachineID = MachineID FROM  [Raw].Session WHERE SessionID = @SessionID
	UPDATE [RAW].[TicketToCalc] SET FlagCalc = 1,SessionID = @SessionID WHERE TicketCode = @TicketCode
-- controllo se è stampato da cashdesk
IF ISNULL(@MachineID,0) <> 0
		BEGIN
		-- scrivo quelli da calcolare             
				MERGE [RAW].[TicketToCalc] AS target  
				USING (	SELECT ticketCode,0 AS FlagCalc FROM   Raw.Delta WHERE SessionID = @SessionID AND TotalOut <> 0 AND TicketCode IS NOT NULL) AS source
				ON (target.TicketCode = source.TicketCode) WHEN NOT MATCHED THEN 
				INSERT (TicketCode, FlagCalc,SessionParentID,Level)  
				VALUES (source.TicketCode, 0,@SessionID,@Level+1);
				SET  @Level += 1 
		END ELSE SET @CalcEnd = 1
	END
END
-- Log operazione
SET @Msg  = 'Calcolo globale terminato'
INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
Select @ProcedureName,@Msg,@TicketCode,@BatchID

	-- Errore specifico
	IF @ReturnCodeInternal = -1
		BEGIN
			SET @Msg = 'Internal procedure Error'
			RAISERROR (@Msg,16,1);
		END

END TRY
--	-- Gestione Errore
	BEGIN CATCH
		EXECUTE [ERR].[UspLogError]  @ErrorTicket = @TicketCode,@ErrorRequestDetailID  = @BatchID
		SET @ReturnCode = -1;
    END CATCH
      
RETURN 
--@ReturnCode Output
	-- fine calcoli
END
