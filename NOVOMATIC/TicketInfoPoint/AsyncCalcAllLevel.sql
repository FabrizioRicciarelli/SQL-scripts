/*
VIENE RICHIAMATA RICORSIVAMENTE IN MODO ASINCRONO
DALLA STORED PROCEDURE "ETL.LaunchHundredTicketsDemo"
*/
ALTER PROC AsyncCalcAllLevel
AS
DECLARE
			@ConcessionaryID			tinyint 
			,@Direction					bit 
			,@TicketCode				varchar(50) 
			,@BatchID					int 
			,@MaxLevel					smallint 
			,@ClubID					varchar(10) = NULL 
			,@XCONFIG					XML

			,@ID int
			,@Position varchar(50)
			,@OffSetIN smallint
			,@OffSetOut smallint
			,@OffSetMh int
			,@MinVltEndCredit int
			,@ConcessionaryName varchar(50)
			,@FlagDbArchive bit
			,@OffsetRawData int
			,@picked bit

			,@XRAWDelta					XML
			,@XRAWSession				XML
			,@ReturnCode				int 

SELECT	TOP 1
		@ID = ID
		,@ConcessionaryID = ConcessionaryID 
		,@Position = Position
		,@OffSetIN = OffSetIN
		,@OffSetOut = OffSetOut
		,@OffSetMh = OffSetMh
		,@MinVltEndCredit =	MinVltEndCredit
		,@ConcessionaryName = ConcessionaryName
		,@FlagDbArchive = FlagDbArchive
		,@OffsetRawData = OffsetRawData
		,@TicketCode = TicketCode
FROM	##CONFIG_PICKUP
WHERE	picked = 0
ORDER BY ID

SET @XCONFIG = ETL.WriteXCONFIG(@XCONFIG, @ConcessionaryID, @Position, @OffSetIN, @OffSetOut, @OffSetMh, @MinVltEndCredit, @ConcessionaryName, @FlagDbArchive, @OffsetRawData)

UPDATE	##CONFIG_PICKUP
SET		picked = 1 
WHERE	ID = @ID	
EXEC	@ReturnCode =
		ETL.CalcAllLevel
		@ConcessionaryID = @ConcessionaryID
		,@Direction = 0
		,@TicketCode = @TicketCode 
		,@BatchID = @ID
		,@MaxLevel = 10
		,@XCONFIG = @XCONFIG
		,@XRAWDelta = @XRAWDelta OUTPUT
		,@XRAWSession = @XRAWSession OUTPUT

IF @ReturnCode = 0
	BEGIN
		INSERT	[ETL].[SESSIONS](ElabID, SessionID, SessionParentID, Level, UnivocalLocationCode, MachineID, GD, AamsMachineCode, StartServerTime, EndServerTime, TotalRows, TotalBillIn, TotalCoinIN, TotalTicketIn, TotalBetValue, TotalBetNum, TotalWinValue, TotalWinNum, Tax, TotalIn, TotalOut, FlagMinVltCredit, StartTicketCode)
		SELECT	@ID AS ElabID, SessionID, SessionParentID, Level, UnivocalLocationCode, MachineID, GD, AamsMachineCode, StartServerTime, EndServerTime, TotalRows, TotalBillIn, TotalCoinIN, TotalTicketIn, TotalBetValue, TotalBetNum, TotalWinValue, TotalWinNum, Tax, TotalIn, TotalOut, FlagMinVltCredit, StartTicketCode
		FROM	ETL.GetAllXRS(@XRAWSession)
		INSERT	[ETL].[DELTAS](ElabID, RowID, UnivocalLocationCode, ServerTime, MachineID, GD, AamsMachineCode, GameID, GameName, LoginFlag, VLTCredit, TotalBet, TotalWon, TotalBillIn, TotalCoinIn, TotalTicketIn, TotalHandPay, TotalTicketOut, Tax, TotalIn, TotalOut, WrongFlag, TicketCode, FlagMinVltCredit, SessionID)
		SELECT	@ID AS ElabID, RowID, UnivocalLocationCode, ServerTime, MachineID, GD, AamsMachineCode, GameID, GameName, LoginFlag, VLTCredit, TotalBet, TotalWon, TotalBillIn, TotalCoinIn, TotalTicketIn, TotalHandPay, TotalTicketOut, Tax, TotalIn, TotalOut, WrongFlag, TicketCode, FlagMinVltCredit, SessionID
		FROM	ETL.GetAllXRD(@XRAWDelta)
	END
