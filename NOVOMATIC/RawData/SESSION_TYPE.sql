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

