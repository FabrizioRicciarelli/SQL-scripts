CREATE TYPE [ETL].[TicketTbl] AS TABLE(
	[requestDetailId] [int] NULL,
	[requestId] [int] NULL,
	[ticket] [varchar](50) NULL,
	[clubId] [varchar](10) NULL,
	[ticketDirection] [bit] NULL,
	[univocalLocationCode] [varchar](20) NULL,
	[elabStart] [datetime] NULL,
	[elabEnd] [datetime] NULL,
	[detailStatusId] [tinyint] NULL,
	[requestStatusDesc] [varchar](25) NULL,
	[fileNameSession] [varchar](70) NULL,
	[fileNameDelta] [varchar](70) NULL,
	[fileNameOperationLog] [varchar](70) NULL,
	[fileNameErrorLog] [varchar](70) NULL,
	[system_date] [datetime2](3) NULL
)


