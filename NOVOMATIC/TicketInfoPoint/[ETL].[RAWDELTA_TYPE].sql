CREATE TYPE [ETL].[RAWDELTA_TYPE] AS TABLE(
	RowID int NULL -- NOT NULL
	,UnivocalLocationCode varchar(30) NULL
	,ServerTime datetime2(3) NULL -- NOT NULL
	,MachineID tinyint NULL -- NOT NULL
	,GD varchar(30) NULL
	,AamsMachineCode varchar(30) NULL
	,GameID int NULL
	,GameName varchar(100) NULL
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
	,TicketCode varchar(50) NULL
	,FlagMinVltCredit bit NULL
	,SessionID int NOT NULL
)
GO


