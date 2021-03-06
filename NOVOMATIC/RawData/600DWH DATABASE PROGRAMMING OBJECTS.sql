USE [600DWH]
GO
/****** Object:  User [f.ricciarelli]    Script Date: 22/12/2017 22:56:01 ******/
CREATE USER [f.ricciarelli] FOR LOGIN [f.ricciarelli] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [f.ricciarelli]
GO
/****** Object:  Schema [Dim]    Script Date: 22/12/2017 22:56:01 ******/
CREATE SCHEMA [Dim]
GO
/****** Object:  Synonym [Dim].[Concessionary]    Script Date: 22/12/2017 22:56:01 ******/
CREATE SYNONYM [Dim].[Concessionary] FOR [POM-MON01].[AGS].[Type].[Concessionary]
GO
/****** Object:  Synonym [Dim].[Date]    Script Date: 22/12/2017 22:56:01 ******/
CREATE SYNONYM [Dim].[Date] FOR [UnifiedDWH].[dim].[Date]
GO
/****** Object:  Synonym [Dim].[Venue]    Script Date: 22/12/2017 22:56:01 ******/
CREATE SYNONYM [Dim].[Venue] FOR [UnifiedRegistry].[Dim].[vVenue]
GO
/****** Object:  Table [Dim].[ConcessionaryTable]    Script Date: 22/12/2017 22:56:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[ConcessionaryTable](
	[ConcessionarySK] [tinyint] NOT NULL,
	[ConcessionaryName] [varchar](100) NULL,
	[ConcessionarySystemCode] [varchar](1000) NULL,
	[ConcessionaryLetter] [char](1) NULL,
	[ConcessionaryNumber] [tinyint] NULL,
 CONSTRAINT [PK_Concessionario] PRIMARY KEY CLUSTERED 
(
	[ConcessionarySK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Dim].[Game]    Script Date: 22/12/2017 22:56:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[Game](
	[GameSK] [int] IDENTITY(1,1) NOT NULL,
	[GameSystemSK] [tinyint] NOT NULL,
	[ConcessionaryNumber] [tinyint] NOT NULL,
	[UGN] [bigint] NULL,
	[GameID] [varchar](15) NOT NULL,
	[CommercialName] [varchar](100) NOT NULL,
	[RTP] [varchar](2) NULL,
	[CommercialNameCleaned] [varchar](50) NOT NULL,
	[AAMSGameCode] [varchar](20) NOT NULL,
	[RtpSogei] [decimal](5, 3) NULL,
 CONSTRAINT [PK_Game] PRIMARY KEY CLUSTERED 
(
	[GameSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Dim].[GameSystem]    Script Date: 22/12/2017 22:56:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[GameSystem](
	[GameSystemSK] [tinyint] IDENTITY(1,1) NOT NULL,
	[AAMSGameSystemCode] [varchar](10) NOT NULL,
	[ConcessionaryGameSystemCode] [varchar](11) NOT NULL,
	[Description] [varchar](50) NOT NULL,
	[Version] [varchar](10) NOT NULL,
 CONSTRAINT [PK_GameSystem] PRIMARY KEY CLUSTERED 
(
	[GameSystemSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Dim].[Vlt]    Script Date: 22/12/2017 22:56:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[Vlt](
	[VltSK] [int] IDENTITY(1,1) NOT NULL,
	[GameSystemSK] [tinyint] NOT NULL,
	[ConcessionaryNumber] [tinyint] NOT NULL,
	[AAMSMachineCode] [varchar](11) NOT NULL,
	[CertificateName] [varchar](30) NULL,
	[VLTmodel] [varchar](50) NULL,
	[DateFirstBet] [date] NULL,
	[CIV] [nvarchar](11) NULL,
 CONSTRAINT [PK_Vlt] PRIMARY KEY CLUSTERED 
(
	[VltSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Dim].[VltState]    Script Date: 22/12/2017 22:56:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[VltState](
	[VltStateSk] [tinyint] NOT NULL,
	[State] [varchar](50) NOT NULL,
 CONSTRAINT [PK_VltState] PRIMARY KEY CLUSTERED 
(
	[VltStateSk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
