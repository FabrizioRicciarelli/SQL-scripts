CREATE TYPE [ETL].[DELTATICKET_TYPE] AS TABLE(
	[RowID] [int] NULL,
	[TotalTicketIN] [int] NULL,
	[TotalOut] [int] NULL,
	[ServerTime] [datetime2](3) NULL,
	[MachineID] [smallint] NULL
)
GO


