/*
Run this script on:

SQLINPS13,2989.IrpefWeb    -  This database will be modified

to synchronize it with:

SQLINPSSVIL06,2059.IRPEFWEB

You are recommended to back up your database before running this script

Script created by SQL Data Compare version 10.2.3 from Red Gate Software Ltd at 04/12/2015 17:21:52

*/
		
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS, NOCOUNT ON
GO
SET DATEFORMAT YMD
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO
BEGIN TRANSACTION
-- Pointer used for text / image updates. This might not be needed, but is declared here just in case
DECLARE @pv binary(16)

-- Add 5 rows to [dbo].[ENTITA_DETT]
INSERT INTO [dbo].[ENTITA_DETT] ([CodiceEntita], [CFCreditore], [CodiceSede], [CodiceProcedura], [Progressivo], [Anno], [Mese], [IdStruttura], [CFDebitore], [CodicePrestazione], [AnnoRif], [MeseRif], [ImportoCredito], [ImportoDebito], [ImportoSospeso], [ImportoSospesoInAtto], [DataInserimento], [DataUltimaModifica], [CodiceRegione], [ChiaveARCAAnagraficaCodice], [ChiaveARCAAnagraficaProgressivo], [ChiaveARCAPrestazione]) VALUES ('AFI', 'PSQMRA48L16E693P', '000000', '018', 1, 2015, '12', 1, '', '1422', 2015, '12', 0.00, 13.00, 0.00, 0.00, '2015-12-04 10:50:00.000', '2015-12-04 10:50:00.000', '99', 'PSQ', 601355, 'PSQMRA48L16E693P')
INSERT INTO [dbo].[ENTITA_DETT] ([CodiceEntita], [CFCreditore], [CodiceSede], [CodiceProcedura], [Progressivo], [Anno], [Mese], [IdStruttura], [CFDebitore], [CodicePrestazione], [AnnoRif], [MeseRif], [ImportoCredito], [ImportoDebito], [ImportoSospeso], [ImportoSospesoInAtto], [DataInserimento], [DataUltimaModifica], [CodiceRegione], [ChiaveARCAAnagraficaCodice], [ChiaveARCAAnagraficaProgressivo], [ChiaveARCAPrestazione]) VALUES ('AFI', 'PSQMRA48L16E693P', '000000', '020', 1, 2015, '12', 1, '', '007', 2015, '12', 0.00, 133.00, 0.00, 0.00, '2015-12-04 10:50:00.000', '2015-12-04 10:50:00.000', '99', 'PSQ', 601355, 'PSQMRA48L16E693P')
INSERT INTO [dbo].[ENTITA_DETT] ([CodiceEntita], [CFCreditore], [CodiceSede], [CodiceProcedura], [Progressivo], [Anno], [Mese], [IdStruttura], [CFDebitore], [CodicePrestazione], [AnnoRif], [MeseRif], [ImportoCredito], [ImportoDebito], [ImportoSospeso], [ImportoSospesoInAtto], [DataInserimento], [DataUltimaModifica], [CodiceRegione], [ChiaveARCAAnagraficaCodice], [ChiaveARCAAnagraficaProgressivo], [ChiaveARCAPrestazione]) VALUES ('CGRIT', 'PSQMRA48L16E693P', '000000', '04B', 1, 2015, '12', 1, '', '007', 2015, '12', 3.00, 0.00, 0.00, 0.00, '2015-12-04 11:23:00.000', '2015-12-04 11:23:00.000', '99', 'PSQ', 601355, 'PSQMRA48L16E693P')
INSERT INTO [dbo].[ENTITA_DETT] ([CodiceEntita], [CFCreditore], [CodiceSede], [CodiceProcedura], [Progressivo], [Anno], [Mese], [IdStruttura], [CFDebitore], [CodicePrestazione], [AnnoRif], [MeseRif], [ImportoCredito], [ImportoDebito], [ImportoSospeso], [ImportoSospesoInAtto], [DataInserimento], [DataUltimaModifica], [CodiceRegione], [ChiaveARCAAnagraficaCodice], [ChiaveARCAAnagraficaProgressivo], [ChiaveARCAPrestazione]) VALUES ('RIT', 'GGGHHH45H28S290W', '000000', '39B', 1, 2015, '11', 1, NULL, '99999', NULL, NULL, 2000.00, 1800.31, 543.86, NULL, '2015-12-03 18:17:00.000', '2015-12-03 20:38:43.000', '00', NULL, NULL, '6C1C799AFC6648649B068116E4D90A686C1C799AFC6648649B068116E4D90A686C1C799AFC6648649B068116E4D90A686C1C799AFC6648649B068116E4D90A68')
INSERT INTO [dbo].[ENTITA_DETT] ([CodiceEntita], [CFCreditore], [CodiceSede], [CodiceProcedura], [Progressivo], [Anno], [Mese], [IdStruttura], [CFDebitore], [CodicePrestazione], [AnnoRif], [MeseRif], [ImportoCredito], [ImportoDebito], [ImportoSospeso], [ImportoSospesoInAtto], [DataInserimento], [DataUltimaModifica], [CodiceRegione], [ChiaveARCAAnagraficaCodice], [ChiaveARCAAnagraficaProgressivo], [ChiaveARCAPrestazione]) VALUES ('RIT', 'PSQMRA48L16E693P', '000000', '09', 2, 2015, '12', 1, '', '007', 2015, '12', 0.00, 22.00, 0.00, 0.00, '2015-12-04 09:25:00.000', '2015-12-04 09:25:00.000', '99', 'PSQ', 601355, 'PSQMRA48L16E693P')
COMMIT TRANSACTION
GO
