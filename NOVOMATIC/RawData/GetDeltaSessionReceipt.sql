/*
DECLARE @delta DELTA_TYPE
INSERT	@delta
EXEC	dbo.GetDeltaSessionReceipt
		@ClubID = '1000296'
		,@Nature = 'Delta'
		,@Criteria = NULL

DECLARE @session SESSION_TYPE
INSERT	@session
EXEC	dbo.GetDeltaSessionReceipt
		@ClubID = '1000296'
		,@Nature = 'Session'
		,@Criteria = NULL

DECLARE @receipt RECEIPTLKDELTA_TYPE
INSERT	@receipt
EXEC	dbo.GetDeltaSessionReceipt
		@ClubID = '1000296'
		,@Nature = 'Receipt_LK_Delta'
		,@Criteria = NULL


-- RICHIEDE LA CREAZIONE DEI SEGUENTI TIPI:
CREATE TYPE DELTA_TYPE AS TABLE(
	RowID int PRIMARY KEY NOT NULL
	,ServerTime datetime2(3) NULL
	,MachineTime datetime2(0) NULL
	,MachineID tinyint NULL
	,GameID int NULL
	,LoginFlag bit NULL
	,VLTCredit int NULL
	,TotalBet int NULL
	,TotalWon int NULL
	,TotalBillIn int NULL
	,TotalCoinIn int NULL
	,TotalTicketIn int NULL
	,TotalHandPay int NULL
	,TotalTicketOut int NULL
	,Tax int NULL
	,TotalIn int NULL
	,TotalOut int NULL
	,WrongFlag bit NULL
)
GO

CREATE TYPE SESSION_TYPE AS TABLE(
	SessionID int PRIMARY KEY NOT NULL
	,VLTStartCredit int NULL
	,VLTEndCredit int NULL
	,StartServerTime datetime2(3) NULL
	,EndServerTime datetime2(3) NULL
	,EndServerTimeExtended datetime2(3) NULL
	,StartMachineTime datetime2(0) NULL
	,EndMachineTime datetime2(0) NULL
	,EndMachineTimeExtended datetime2(0) NULL
	,MachineID tinyint NULL
	,ResetFromTicketOut bit NULL
	,TotalRows int NULL
	,TotalBillIn smallint NULL
	,TotalCoinIN smallint NULL
	,TotalTicketIn smallint NULL
	,TotalBetValue bigint NULL
	,TotalBetNum int NULL
	,TotalWinValue bigint NULL
	,TotalWinNum int NULL
	,Tax bigint NULL
	,TotalIn bigint NULL
	,TotalOut bigint NULL
)
GO

CREATE TYPE RECEIPTLKDELTA_TYPE AS TABLE(
	ReceiptID int PRIMARY KEY NOT NULL
	,RowID int NOT NULL
	,SessionID int NULL
	,TicketWayID tinyint NULL
	,ReceiptMatchTypeID tinyint NULL
	,DifferenceMatchType smallint NULL
	,Congruity tinyint NULL
)
GO


*/
CREATE PROC dbo.GetDeltaSessionReceipt
			@ClubID varchar(10) = NULL
			,@Nature varchar(20) = NULL
			,@Criteria varchar(MAX) = NULL
AS
IF ISNULL(@ClubID,'') != ''
AND ISNULL(@Nature,'') != ''
	BEGIN
		DECLARE @SQL Nvarchar(MAX)

		SET @SQL =
		N'
		SELECT	*
		FROM	[' + QUOTENAME(@ClubID, CHAR(39)) + '].[' + QUOTENAME(@Nature, CHAR(39)) + ']
		' + ISNULL(@Criteria,'')

		PRINT(@SQL)
		--EXEC sp_executesql @SQL
	END