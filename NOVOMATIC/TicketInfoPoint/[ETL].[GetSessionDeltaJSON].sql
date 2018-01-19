/*
DECLARE @JSDATA nvarchar(MAX)
EXEC ETL.GetSessionDeltaJSON @requestDetailId=1, @SessionID=-2147483648,@JSONDATA=@JSDATA OUTPUT
SELECT @JSDATA AS JSONDATA
*/
ALTER PROC [ETL].[GetSessionDeltaJSON]
			@requestDetailId int = NULL
			,@SessionID int = NULL
			,@JSONdata nvarchar(MAX) OUTPUT
AS
IF ISNULL(@requestDetailId,0) > 0
AND @SessionID IS NOT NULL -- NON USARE QUI "ISNULL(@SessionID,0) > 0" PERCHE' ESISTONO SessionID NEGATIVI
	BEGIN
		SELECT @JSONDATA = 
		(
			SELECT	TOP 1
 					 RecID AS 'Session.RecID'
					,requestDetailId AS 'Session.requestDetailId'
					,SessionID AS 'Session.SessionID'
					,SessionParentID AS 'Session.SessionParentID'
					,[Level] AS 'Session.Level'
					,UnivocalLocationCode AS 'Session.UnivocalLocationCode'
					,MachineID AS 'Session.MachineID'
					,GD AS 'Session.GD'
					,AamsMachineCode AS 'Session.AamsMachineCode'
					,StartServerTime AS 'Session.StartServerTime'
					,EndServerTime AS 'Session.EndServerTime'
					,TotalRows AS 'Session.TotalRows'
					,TotalBillIn AS 'Session.TotalBillIn'
					,TotalCoinIN AS 'Session.TotalCoinIN'
					,TotalTicketIn AS 'Session.TotalTicketIn'
					,TotalBetValue AS 'Session.TotalBetValue'
					,TotalBetNum AS 'Session.TotalBetNum'
					,TotalWinValue AS 'Session.TotalWinValue'
					,TotalWinNum AS 'Session.TotalWinNum'
					,Tax AS 'Session.Tax'
					,TotalIn AS 'Session.TotalIn'
					,TotalOut AS 'Session.TotalOut'
					,FlagMinVltCredit AS 'Session.FlagMinVltCredit'
					,StartTicketCode AS 'Session.StartTicketCode'
					,Delta =
					(
						SELECT
								 RecID
								,requestDetailId
								,RowID
								,UnivocalLocationCode
								,ServerTime
								,MachineID
								,GD
								,AamsMachineCode
								,GameID
								,GameName
								,VLTCredit
								,TotalBet
								,TotalWon
								,TotalBillIn
								,TotalCoinIn
								,TotalTicketIn
								,TotalHandPay
								,TotalTicketOut
								,Tax
								,TotalIn
								,TotalOut
								,WrongFlag
								,TicketCode
								,SessionID
						FROM	ETL.Delta L WITH(NOLOCK)
						WHERE	L.SessionID = S.SessionID
						AND		L.requestDetailId = S.requestDetailId
						FOR JSON PATH 
					)
			FROM	[ETL].[Session] S WITH(NOLOCK)
			WHERE	requestDetailId = @requestDetailId
			AND		SessionID = @SessionID
			ORDER BY RecID DESC
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		)
	END