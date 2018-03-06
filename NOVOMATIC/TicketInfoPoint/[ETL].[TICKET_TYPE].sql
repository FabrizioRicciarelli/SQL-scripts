CREATE TYPE [ETL].[TICKET_TYPE] AS TABLE(
	[BatchID] [int] IDENTITY(1,1) NOT NULL,
	[Clubid] [int] NULL,
	[Ticketcode] [varchar](40) NULL,
	[Ticketvalue] [int] NULL,
	[Printingmachine] [varchar](20) NULL,
	[Printingmachineid] [smallint] NULL,
	[Printingdate] [datetime] NULL,
	[Payoutmachine] [varchar](20) NULL,
	[Payoutmachineid] [smallint] NULL,
	[Payoutdate] [datetime] NULL,
	[Ispaidcashdesk] [bit] NULL,
	[Isprintingcashdesk] [bit] NULL,
	[Expiredate] [datetime] NULL,
	[Eventdate] [datetime] NULL,
	[Mhmachine] [varchar](30) NULL,
	[Mhmachineid] [smallint] NULL,
	[Creationchangedate] [datetime] NULL
)
GO


