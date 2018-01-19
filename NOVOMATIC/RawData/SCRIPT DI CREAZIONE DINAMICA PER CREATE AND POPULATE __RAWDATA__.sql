DECLARE
		@SALA varchar(20) = '1000296'
		,@DBSTORICO varchar(128) = 'GMatica_AGS_RawData_01'
		,@DBCORRENTE varchar(128) = 'GMatica_AGS_RawData'
		,@STORICOFROM char(10) = '20120101'
		,@STORICOTO char(10) = '20151117'
		,@CORRENTEFROM char(10) = ''
		,@CORRENTETO char(10) = '20151117'
		,@CSVcolumns varchar(MAX)
		,@columns varchar(MAX)
		,@CREATEtable varchar(MAX)
		,@CREATEindex varchar(MAX)
		,@COPYdata varchar(MAX)
		,@COPYdata2 varchar(MAX) -- CON EXEC AT
SELECT	@columns = COALESCE(@columns, '') + 
		C.NAME + ' ' + 
		T.NAME + 
		CASE 
			WHEN T.name IN ('int', 'smallint') 
			AND C.name NOT IN ('RowID', 'GameID', 'TotalBet')
			THEN ' SPARSE'
			ELSE ''
		END +
		', '
		,@CSVcolumns = COALESCE(@CSVcolumns, '') + C.NAME + ', '
FROM	SYSOBJECTS O
		JOIN
		SYSCOLUMNS C
		ON O.ID = C.ID
		JOIN
		SYSTYPES T
		ON T.XTYPE = C.XTYPE
WHERE O.name = 'RawData_View'
ORDER BY C.COLID

SELECT @columns = LEFT(@columns, LEN(@columns)-1)
SELECT @CSVcolumns = LEFT(@CSVcolumns, LEN(@CSVcolumns)-1)

SELECT @CREATEtable = 'CREATE TABLE __RAWDATA__ (' + @columns + ')'
SELECT @CREATEindex =
'
CREATE INDEX	ix_TotalIN_TotalOUT_TotalTicketIN_TotalTicketOUT 
ON __RAWDATA__(TotalIN, TotalOUT, TotalTicketIN, TotalTicketOUT) 
INCLUDE (RowID, ServerTime, MachineID, LoginFlag)
WHERE	TotalHandpay IS NOT NULL
AND		TotalIN IS NOT NULL 
AND		TotalOUT IS NOT NULL 
AND		TotalTicketIN IS NOT NULL 
AND		TotalTicketOUT IS NOT NULL
' 

SELECT @COPYdata = 
'
INSERT __RAWDATA__(' + @CSVcolumns + ') ' + CHAR(13) +
'SELECT ' + @CSVcolumns + CHAR(13) + ' FROM [GMATICA_AGS_RawData_Elaborate_Stag_Agile].[TMP].[RawData_View]  WITH(NOLOCK) OPTION (MAXDOP 8)'


SELECT @COPYdata2 = 
'
INSERT __RAWDATA__(' + @CSVcolumns + ') ' + CHAR(13) +
'
EXEC
(
''
	SELECT RowID, ServerTime, MachineTime, MachineID, GameID, LoginFlag, TotalBet, Win, GamesPlayed, GamesWon, TotalHandpay, TotalHPCC, TotalJPCC, TotalRemote, TotalWon, TotalDrop, TotalIn, TotalOut, TotalBillIn, TotalBillChange, TotalCoinIn, TotalCoinInDrop, TotalCoinInHopper, TotalHopperOut, TotalHopperFill, TotalTicketIn, TotalTicketOut, TotalBillInNumber, BillIn1, BillIn2, BillIn3, BillIn4, BillIn5, BillIn6, BillIn7, BillIn8, TotalBillChangeNumber, BillChange1, BillChange2, BillChange3, BillChange4, BillChange5, BillChange6, BillChange7, TotalCoinInNumber, CoinIn3, CoinIn4, CoinIn5, CoinIn6, CoinIn7, CoinIn8, TotalCoinInDropNumber, CoinInDrop3, CoinInDrop4, CoinInDrop5, CoinInDrop6, CoinInDrop7, CoinInDrop8, TotalCoinInHopperNumber, CoinInHopper3, CoinInHopper4, TicketInA, TicketInB, TicketInC, TicketOutA, TicketOutB, TicketOutC, CurrentCreditA, CurrentCreditB, CurrentCreditC, TotalBetA, TotalBetB, TotalBetC, WinA, WinB, WinC, WinD, TotalHPCCA
	FROM [GMatica_AGS_RawData_01].[' + @SALA + '].[RawData] WITH(NOLOCK)
	WHERE ServerTime >= ''''' + @STORICOFROM + ''''' AND ServerTime < ''''' + @STORICOTO + '''''
	UNION ALL
	SELECT RowID, ServerTime, MachineTime, MachineID, GameID, LoginFlag, TotalBet, Win, GamesPlayed, GamesWon, TotalHandpay, TotalHPCC, TotalJPCC, TotalRemote, TotalWon, TotalDrop, TotalIn, TotalOut, TotalBillIn, TotalBillChange, TotalCoinIn, TotalCoinInDrop, TotalCoinInHopper, TotalHopperOut, TotalHopperFill, TotalTicketIn, TotalTicketOut, TotalBillInNumber, BillIn1, BillIn2, BillIn3, BillIn4, BillIn5, BillIn6, BillIn7, BillIn8, TotalBillChangeNumber, BillChange1, BillChange2, BillChange3, BillChange4, BillChange5, BillChange6, BillChange7, TotalCoinInNumber, CoinIn3, CoinIn4, CoinIn5, CoinIn6, CoinIn7, CoinIn8, TotalCoinInDropNumber, CoinInDrop3, CoinInDrop4, CoinInDrop5, CoinInDrop6, CoinInDrop7, CoinInDrop8, TotalCoinInHopperNumber, CoinInHopper3, CoinInHopper4, TicketInA, TicketInB, TicketInC, TicketOutA, TicketOutB, TicketOutC, CurrentCreditA, CurrentCreditB, CurrentCreditC, TotalBetA, TotalBetB, TotalBetC, WinA, WinB, WinC, WinD, TotalHPCCA
	FROM [GMatica_AGS_RawData].[' + @SALA + '].[RawData] WITH(NOLOCK)
	WHERE ServerTime >= ''''' + @CORRENTETO + '''''
''
) AT [POM-MON01]
'
PRINT (@CREATEtable + CHAR(13) + @CREATEindex + CHAR(13) + @COPYdata2)