CREATE TYPE [ETL].[CCK_TYPE] AS TABLE(
	[ClubID] [int] NOT NULL,
	[MachineID] [tinyint] NULL,
	[FromOut] [datetime] NULL,
	[ToOut] [datetime2](3) NULL,
	[TotalBet] [bigint] NULL,
	[TotalWon] [bigint] NULL,
	[WinD] [bigint] NULL,
	[TotalBillIn] [bigint] NULL,
	[TotalCoinIn] [bigint] NULL,
	[TotalTicketIn] [bigint] NULL,
	[TotalTicketOut] [bigint] NULL,
	[TotalHandPay] [bigint] NULL,
	[TotalOut] [bigint] NULL,
	[TotalIn] [bigint] NULL
)
GO


