DECLARE @XRS XML

SET @XRS =
(
SELECT TOP 5 
		[SessionID]
		,[SessionParentID]
		,[Level]
		,[UnivocalLocationCode]
		,[MachineID]
		,[GD]
		,[AamsMachineCode]
		,[StartServerTime]
		,[EndServerTime]
		,[TotalRows]
		,[TotalBillIn]
		,[TotalCoinIN]
		,[TotalTicketIn]
		,([TotalBetValue] *-1) AS TotalBetValue
		,[TotalBetNum]
		,([TotalWinValue] *-1) AS TotalWinValue
		,[TotalWinNum]
		,([Tax]  *-1) AS Tax
		,[TotalIn]
		,[TotalOut]
		,[FlagMinVltCredit]
		,[StartTicketCode]
FROM	[ETL].[Session]
FOR XML RAW('XRS'), TYPE
)
SELECT @XRS
SELECT * FROM ETL.GetXRS(@XRS, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)