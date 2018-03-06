CREATE TYPE [ETL].[TTFORWARDIN_TYPE] AS TABLE(
	[Riga] [int] IDENTITY(1,1) NOT NULL,
	[ClubID] [varchar](20) NULL,
	[TicketID] [nvarchar](255) NULL
)
GO


