CREATE TYPE RawDataMinimal_TYPE AS TABLE
(
	[RowID] [int] NOT NULL,
	[ServerTime] [datetime] NULL,
	[MachineTime] [datetime] NULL,
	[MachineID] [tinyint] NULL,
	[GameID] [int] NULL,
	[LoginFlag] [bit] NULL,

	[TotalBet] [int] NULL,
	[TotalBillChange] [int] NULL,
	[TotalBillIn] [int] NULL,
	[TotalBillInNumber] [int] NULL,
	[TotalCoinIn] [int] NULL,
	[TotalCoinInDrop] [int] NULL,
	[TotalCoinInHopper] [int] NULL,
	[TotalDrop] [int] NULL,
	[TotalHandpay] [int] NULL,
	[TotalHopperOut] [int] NULL,
	[TotalHopperFill] [int] NULL,
	[TotalHPCC] [int] NULL,
	[TotalJPCC] [int] NULL,
	[TotalIn] [int] NULL,
	[TotalOut] [int] NULL,
	[TotalRemote] [int] NULL,
	[TotalTicketIn] [int] NULL,
	[TotalTicketOut] [int] NULL,
	[TotalWon] [int] NULL,

	[Win] [int] NULL,
	[WinA] [int] NULL,
	[WinB] [int] NULL,
	[WinC] [int] NULL,
	[WinD] [int] NULL,
)


