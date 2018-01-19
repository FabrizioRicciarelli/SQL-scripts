CREATE TYPE [ETL].[TTC_TYPE] AS TABLE(
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ticketcode] [varchar](50) NOT NULL,
	[flagcalc] [bit] NULL,
	[sessionid] [int] NULL,
	[sessionparentid] [int] NULL,
	[level] [int] NULL
)
