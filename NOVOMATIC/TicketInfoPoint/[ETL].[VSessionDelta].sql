ALTER VIEW [ETL].[VSessionDelta]
AS
SELECT	
		S.requestDetailId
		, S.StartTicketCode
		,D.RecID, D.RowID, D.UnivocalLocationCode, D.ServerTime, D.MachineID, D.GD, D.AamsMachineCode, D.GameID, D.GameName, D.VLTCredit, D.TotalBet, D.TotalWon, D.TotalBillIn, D.TotalCoinIn, D.TotalTicketIn, D.TotalHandPay, D.TotalTicketOut, D.Tax, D.TotalIn, D.TotalOut, D.WrongFlag, D.TicketCode, D.SessionID
FROM	ETL.Delta D WITH(NOLOCK)
		INNER JOIN
		ETL.Session S WITH(NOLOCK)
		ON D.SessionID = S.SessionID
		AND D.requestDetailId = S.requestDetailId
