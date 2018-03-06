CREATE TYPE [ETL].[CONFIG_TYPE] AS TABLE(
	[ConcessionaryID] [tinyint] NOT NULL,
	[Position] [varchar](50) NULL,
	[OffSetIN] [smallint] NULL,
	[OffSetOut] [smallint] NULL,
	[OffSetMh] [int] NULL,
	[MinVltEndCredit] [int] NULL,
	[ConcessionaryName] [varchar](50) NULL,
	[FlagDbArchive] [bit] NULL,
	[OffsetRawData] [int] NULL
)
GO


