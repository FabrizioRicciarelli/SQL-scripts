CREATE TYPE [ETL].[RAWSESSION_TYPE] AS TABLE(
	[SessionID] [int] NULL,--IDENTITY(-2147483648,1) NOT NULL,
	[SessionParentID] [int] NULL,
	[Level] [int] NULL,
	[UnivocalLocationCode] [varchar](30) NULL,
	[MachineID] [smallint] NOT NULL,
	[GD] [varchar](30) NULL,
	[AamsMachineCode] [varchar](30) NULL,
	[StartServerTime] [datetime2](3) NOT NULL,
	[EndServerTime] [datetime2](3) NULL,
	[TotalRows] [int] NULL,
	[TotalBillIn] [smallint] NULL,
	[TotalCoinIN] [smallint] NULL,
	[TotalTicketIn] [smallint] NULL,
	[TotalBetValue] [bigint] NULL,
	[TotalBetNum] [int] NULL,
	[TotalWinValue] [bigint] NULL,
	[TotalWinNum] [int] NULL,
	[Tax] [bigint] NULL,
	[TotalIn] [bigint] NULL,
	[TotalOut] [bigint] NULL,
	[FlagMinVltCredit] [bit] NULL,
	[StartTicketCode] [varchar](50) NULL
)
GO


