CREATE TYPE [dbo].[TICKETLIST_TYPE] AS TABLE(
	[TicketCode] [varchar](max) NULL
)
GO

CREATE TYPE [dbo].[TICKET_TYPE] AS TABLE(
	[ClubID] [int] NULL,
	[TicketCode] [varchar](40) NULL,
	[Ticketvalue] [int] NULL,
	[PrintingMachine] [varchar](20) NULL,
	[PrintingMachineID] [smallint] NULL,
	[PrintingDate] [datetime] NULL,
	[PayOutMachine] [varchar](20) NULL,
	[PayOutMachineID] [smallint] NULL,
	[PayOutDate] [datetime] NULL,
	[IsPaidCashDesk] [bit] NULL,
	[IsPrintingCashDesk] [bit] NULL,
	[ExpireDate] [datetime] NULL,
	[EventDate] [datetime] NULL,
	[MhMachine] [varchar](30) NULL,
	[MhMachineID] [smallint] NULL,
	[CreationChangeDate] [datetime] NULL
)
GO



