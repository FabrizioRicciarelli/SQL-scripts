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

