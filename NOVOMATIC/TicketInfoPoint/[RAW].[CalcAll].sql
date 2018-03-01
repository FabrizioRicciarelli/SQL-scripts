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
DECLARE @ReturnCode int
EXEC [RAW].[CalcAll] @ConcessionaryID = 7, @Direction = 0,@TicketCode = '164504952927074578' ,@BatchID = 1,@ReturnCode = @ReturnCode Output
Select @ReturnCode

DECLARE @ReturnCode int
EXEC [RAW].[CalcAllLevel] @ConcessionaryID = 7, @Direction = 0,@TicketCode = '1000294MHR201502110001' ,@BatchID = 1,@MaxLevel = 50,@ReturnCode = @ReturnCode Output
Select @ReturnCode

EXEC [RAW].[CalcAllLevel] @ConcessionaryID = 1, @Direction = 0,@TicketCode = '116136268470765059' ,@BatchID = 1,@MaxLevel = 10

DECLARE @ReturnCode int
EXEC [RAW].[CalcAllLevel] @ConcessionaryID = 7, @Direction = 1,@TicketCode = 'dddds' ,@BatchID = 1,@MaxLevel = 50,@ReturnCode = @ReturnCode Output
Select @ReturnCode

*/
ALTER PROC	[RAW].[CalcAll]
			@ConcessionaryID tinyint,
			@Direction Bit,
			@TicketCode Varchar(50),
			@Level INT = null,
			@SessionParentID INT = NULL,
			@BatchID Int,
			@ClubID Varchar(10) = NULL,
			@ReturnCode Int = NULL Output 
AS
BEGIN
SET NOCOUNT ON;

DECLARE @ConcessionaryDB varchar(50),@DataStart Datetime2(3),@Message Varchar(1000),@Msg vARCHAR(1000), @ReturnCodeInternal Int, @ReturnCodeGlobal Int,
        @CalcEnd BIT,@VltEndCredit Int,@CashDesk  TinyInt = 0,@PayoutData DateTime2(3),@ProcedureName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) +'.'+QUOTENAME(OBJECT_NAME(@@PROCID)),
		@ServerTime_FIRST datetime = '1900-01-01 00:00:00.000',@PrintingData DateTime2(3), @ServerTimeStart DateTime2(3),@ParentID INT;

BEGIN TRY

-- Log operazione
SET @Msg  = 'Calcolo globale iniziato'
INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationTicketCode],[OperationRequestDetailID])
Select @ProcedureName,@Msg,@TicketCode,@BatchID


--SET @ServerTimeStart  = @ServerTime_FIRST 
--SET @CalcEnd = 0
IF  @ClubID = NULL (Select @ClubID = ClubID From [TMP].[TicketStart])
SET @VltEndCredit = (SELECT [MinVltEndCredit] FROM [Config].[Table])
-- Livello
--SET @Level = 0
SET @ReturnCode = 0;
SET @ReturnCodeInternal = 0;

	--inizializzo
	SET @ReturnCodeInternal = 0;
    SET @DataStart = SYSDATETIME(); 
	
	-- Trova il tappo
	EXEC	@ReturnCodeInternal =  
			[RAW].[FindCountersCork] 
			@TicketCode = @TicketCode
			,@Direction = @Direction
			,@BatchID = @BatchID
   
   -- non errore e non pagato/stampato da cashdesk
	--IF @ReturnCodeInternal <> -1 AND @ReturnCodeInternal <> 1
	PRINT(@ReturnCodeInternal)

	IF @ReturnCodeInternal = 0
	BEGIN
		-- Calcola i delta
		EXEC	@ReturnCodeInternal =  
				[RAW].[CalculateDeltaFromTicketOut]

		IF @ReturnCodeInternal <> -1

		-- Matching dei ticket
			EXEC	@ReturnCodeInternal =  
					[RAW].[TicketMatching] 
					@Direction = @Direction
		
		IF @ReturnCodeInternal <> -1
		
		-- Calcola le sessioni
			EXEC	@ReturnCodeInternal =  
					[RAW].[CalcSession] 
					@Level = @Level
					,@SessionParentID = @SessionParentID
	END
  -- pagato da cashdesk
 ELSE IF  @ReturnCodeInternal = 1 AND @Direction = 1
		BEGIN
			SELECT	@PayoutData = [PayoutData]  
			FROM	[TMP].[TicketStart] 
			WHERE	TicketCode = @TicketCode
			INSERT	[RAW].[Session](MachineID,StartServerTime,StartTicketCode,[Level],SessionParentID)
			Select	@CashDesk,ISNULL(@PayoutData,@ServerTime_FIRST),@TicketCode,@Level,@SessionParentID
		END

-- stampato da cashdesk
 ELSE IF  @ReturnCodeInternal = 1 AND @Direction = 0
 		BEGIN
			SELECT @PrintingData = [PrintingData]  FROM [TMP].[TicketStart] WHERE TicketCode = @TicketCode
			INSERT INTO [RAW].[Session](MachineID,StartServerTime,StartTicketCode,[Level],SessionParentID)
			Select @CashDesk,ISNULL(@PrintingData,@ServerTime_FIRST),@TicketCode,@Level,@SessionParentID
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
		-- ClubID non trovato
	IF @ReturnCodeInternal = 2
		BEGIN
			SET @ReturnCode = 2
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
