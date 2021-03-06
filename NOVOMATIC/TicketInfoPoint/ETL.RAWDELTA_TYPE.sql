CREATE TYPE ETL.RAWDELTA_TYPE  AS TABLE(
	[RowID] [int] NOT NULL,
	[UnivocalLocationCode] [varchar](30) NULL,
	[ServerTime] [datetime2](3) NOT NULL,
	[MachineID] [tinyint] NOT NULL,
	[GD] [varchar](30) NULL,
	[AamsMachineCode] [varchar](30) NULL,
	[GameID] [int] NULL,
	[GameName] [varchar](100) NULL,
	[VLTCredit] [int] NULL,
	[TotalBet] [int] NULL,
	[TotalWon] [int] NULL,
	[TotalBillIn] [int] NULL,
	[TotalCoinIn] [int] NULL,
	[TotalTicketIn] [int] NULL,
	[TotalHandPay] [int] NULL,
	[TotalTicketOut] [int] NULL,
	[Tax] [int] NULL,
	[TotalIn] [int] NULL,
	[TotalOut] [int] NULL,
	[WrongFlag] [bit] NULL, -- AS (CONVERT([bit],case when [VLTCredit]<(0) OR [TotalBet]<(0) OR [TotalWon]<(0) OR [TotalBillIn]<(0) OR [TotalCoinIn]<(0) OR [TotalTicketIn]<(0) OR [TotalHandPay]<(0) OR [TotalTicketOut]<(0) OR [Tax]<(0) OR [VLTCredit]>(10000000) OR [TotalBet]>(1000) OR [TotalWon]>(500000) OR [TotalBillIn]>(50000) OR [TotalCoinIn]>(200) OR [TotalTicketIn]>(1000000) OR [TotalHandPay]>(6000000) OR [TotalTicketOut]>(1000000) OR [Tax]>(50000) then (1) else (0) end)),
	[TicketCode] [varchar](50) NULL,
	[FlagMinVltCredit] [bit] NULL,
	[SessionID] [int] NOT NULL
)

