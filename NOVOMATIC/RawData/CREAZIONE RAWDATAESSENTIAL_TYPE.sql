CREATE TYPE RawDataEssential_TYPE AS TABLE
(
	[RowID] [int] NOT NULL,
	[ServerTime] [datetime] NULL,
	[MachineTime] [datetime] NULL,
	[MachineID] [tinyint] NULL,
	[GameID] [int] NULL,
	[LoginFlag] [bit] NULL,

	[TotalBet] [int] NULL,
	[TotalBillIn] [int] NULL,
	[TotalCoinIn] [int] NULL,
	[TotalHandpay] [int] NULL,
	[TotalIn] [int] NULL,
	[TotalOut] [int] NULL,
	[TotalTicketIn] [int] NULL,
	[TotalTicketOut] [int] NULL,
	[TotalWon] [int] NULL,

	[WinD] [int] NULL
)


