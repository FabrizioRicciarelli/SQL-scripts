CREATE TYPE [ETL].[TTICKETIN_TYPE] AS TABLE(
	[ID] [smallint] IDENTITY(1,1) NOT NULL,
	[TicketID] [nvarchar](255) NOT NULL,
	[UnivocalLocationCode] [varchar](20) NULL,
	[ClubID] [varchar](10) NULL
)
GO


