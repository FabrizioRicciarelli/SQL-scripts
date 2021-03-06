/*
Run this script on:

        192.168.8.125,2989.IRPEFWEB    -  This database will be modified

to synchronize it with:

        192.168.234.245,2059.IRPEFWEB

You are recommended to back up your database before running this script

Script created by SQL Compare version 10.4.8 from Red Gate Software Ltd at 04/12/2015 17:20:51

*/
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id=OBJECT_ID('tempdb..#tmpErrors')) DROP TABLE #tmpErrors
GO
CREATE TABLE #tmpErrors (Error int)
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO
BEGIN TRANSACTION
GO
PRINT N'Creating [dbo].[ENTITA_DETT]'
GO
CREATE TABLE [dbo].[ENTITA_DETT]
(
[CodiceEntita] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CFCreditore] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CFDebitore] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CodicePrestazione] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CodiceSede] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodiceProcedura] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Progressivo] [int] NOT NULL,
[Anno] [int] NOT NULL,
[Mese] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AnnoRif] [int] NULL,
[MeseRif] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ImportoCredito] [decimal] (18, 2) NULL,
[ImportoDebito] [decimal] (18, 2) NULL,
[ImportoSospeso] [decimal] (18, 2) NULL,
[ImportoSospesoInAtto] [decimal] (18, 2) NULL,
[DataInserimento] [datetime] NOT NULL DEFAULT (getdate()),
[DataUltimaModifica] [datetime] NOT NULL DEFAULT (getdate()),
[CodiceRegione] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IdStruttura] [int] NOT NULL,
[ChiaveARCAAnagraficaCodice] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChiaveARCAAnagraficaProgressivo] [int] NULL,
[ChiaveARCAPrestazione] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK_ENTITA_DETT] on [dbo].[ENTITA_DETT]'
GO
ALTER TABLE [dbo].[ENTITA_DETT] ADD CONSTRAINT [PK_ENTITA_DETT] PRIMARY KEY CLUSTERED  ([CodiceEntita], [CFCreditore], [CodiceSede], [CodiceProcedura], [Progressivo], [Anno], [Mese], [IdStruttura])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
IF EXISTS (SELECT * FROM #tmpErrors) ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT>0 BEGIN
PRINT 'The database update succeeded'
COMMIT TRANSACTION
END
ELSE PRINT 'The database update failed'
GO
DROP TABLE #tmpErrors
GO
