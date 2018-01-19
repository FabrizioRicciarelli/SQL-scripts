/*
SELECT	* 
FROM	[ETL].[vSessionDeltaJSON]	
WHERE	requestDetailId = 9
ORDER BY Level
*/
ALTER VIEW [ETL].[vSessionDeltaJSON]
AS
SELECT
 		S.RecID
		,S.requestDetailId
		,S.SessionID
		,S.SessionParentID
		,S.[Level]
		,S.UnivocalLocationCode
		,S.MachineID
		,S.GD
		,S.AamsMachineCode
		,S.StartServerTime
		,S.EndServerTime
		,S.TotalRows
		,S.TotalBillIn
		,S.TotalCoinIN
		,S.TotalTicketIn
		,S.TotalBetValue
		,S.TotalBetNum
		,S.TotalWinValue
		,S.TotalWinNum
		,S.Tax
		,S.TotalIn
		,S.TotalOut
		,S.FlagMinVltCredit
		,S.StartTicketCode
		,Delta =
		(
			SELECT
					L.RecID
					,L.requestDetailId
					,L.RowID
					,L.UnivocalLocationCode
					,L.ServerTime
					,L.MachineID
					,L.GD
					,L.AamsMachineCode
					,L.GameID
					,L.GameName
					,L.VLTCredit
					,L.TotalBet
					,L.TotalWon
					,L.TotalBillIn
					,L.TotalCoinIn
					,L.TotalTicketIn
					,L.TotalHandPay
					,L.TotalTicketOut
					,L.Tax
					,L.TotalIn
					,L.TotalOut
					,L.WrongFlag
					,L.TicketCode
					,L.SessionID
			FROM	ETL.Delta L WITH(NOLOCK)
			WHERE	L.SessionID = S.SessionID
			AND		L.requestDetailId = S.requestDetailId
			FOR JSON PATH 
		)
FROM	[ETL].[Session] S WITH(NOLOCK)
