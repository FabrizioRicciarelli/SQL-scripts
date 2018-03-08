/*
DECLARE	
		@ConcessionaryID			tinyint = 7
		,@ConcessionaryName			varchar(30)
		,@XCONFIG XML -- ex Config.Table

SET @ConcessionaryName = ETL.GetConcessionaryName(@ConcessionaryID)
SET	@XCONFIG =	ETL.WriteXCONFIG(@XCONFIG, @ConcessionaryID, 'POM-MON01', 25, 45, 7200, 50, @ConcessionaryName, 1, 1) 

SELECT [ETL].[BuildDynSQL_CalcAllLevel] (7, '14214358217068117', 1, 1000221, @XCONFIG) AS DynSQL
SELECT [ETL].[BuildDynSQL_CalcAllLevel] (7, '2851042900715907', 1, 1000349, @XCONFIG) AS DynSQL

*/
ALTER FUNCTION [ETL].[BuildDynSQL_CalcAllLevel] (
				@ConcessionaryID tinyint
				,@TicketCode varchar(50)
				,@ID int
				,@ClubID int
				,@XCONFIG XML
)
RETURNS Nvarchar(MAX)
AS
BEGIN
	RETURN(
		SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
		N'
		DECLARE
				--@ReturnCode		int
				@XRAWDelta		XML
				,@XRAWSession	XML

		EXEC	@ReturnCode =
				ETL.CalcAllLevel
				@ConcessionaryID = $
				,@Direction = 0
				,@TicketCode = ''#'' 
				,@BatchID = °
				,@MaxLevel = 10
				,@XCONFIG = ''§''
				,@XRAWDelta = @XRAWDelta OUTPUT
				,@XRAWSession = @XRAWSession OUTPUT

		IF @ReturnCode = 0
			BEGIN
				INSERT	[ETL].[SESSIONS](ElabID, ClubID, SessionID, SessionParentID, Level, UnivocalLocationCode, MachineID, GD, AamsMachineCode, StartServerTime, EndServerTime, TotalRows, TotalBillIn, TotalCoinIN, TotalTicketIn, TotalBetValue, TotalBetNum, TotalWinValue, TotalWinNum, Tax, TotalIn, TotalOut, FlagMinVltCredit, StartTicketCode)
				SELECT	° AS ElabID, ç AS ClubID, SessionID, SessionParentID, Level, UnivocalLocationCode, MachineID, GD, AamsMachineCode, StartServerTime, EndServerTime, TotalRows, TotalBillIn, TotalCoinIN, TotalTicketIn, TotalBetValue, TotalBetNum, TotalWinValue, TotalWinNum, Tax, TotalIn, TotalOut, FlagMinVltCredit, StartTicketCode
				FROM	ETL.GetAllXRS(@XRAWSession)
				INSERT	[ETL].[DELTAS](ElabID, ClubID, RowID, UnivocalLocationCode, ServerTime, MachineID, GD, AamsMachineCode, GameID, GameName, LoginFlag, VLTCredit, TotalBet, TotalWon, TotalBillIn, TotalCoinIn, TotalTicketIn, TotalHandPay, TotalTicketOut, Tax, TotalIn, TotalOut, WrongFlag, TicketCode, FlagMinVltCredit, SessionID)
				SELECT	° AS ElabID, ç AS ClubID, RowID, UnivocalLocationCode, ServerTime, MachineID, GD, AamsMachineCode, GameID, GameName, LoginFlag, VLTCredit, TotalBet, TotalWon, TotalBillIn, TotalCoinIn, TotalTicketIn, TotalHandPay, TotalTicketOut, Tax, TotalIn, TotalOut, WrongFlag, TicketCode, FlagMinVltCredit, SessionID
				FROM	ETL.GetAllXRD(@XRAWDelta)
			END
		'
		,'$',CAST(@ConcessionaryID AS varchar(5))),'#',@TicketCode),'°',CAST(@ID AS varchar(10))),'§',CAST(@XCONFIG AS Nvarchar(MAX))),'ç',CAST(@ClubID AS varchar(10)))
	)	
END