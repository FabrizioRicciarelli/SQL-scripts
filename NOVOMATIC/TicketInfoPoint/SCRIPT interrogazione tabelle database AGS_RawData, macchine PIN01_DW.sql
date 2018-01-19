SELECT	TOP 1000 *
FROM	[Gmatica_PIN01\DW].[AGS_RawData].[1000296].[RawData]

SELECT	TOP 1000 *
FROM	[Gmatica_PIN01\DW].[AGS_RawData].[Config].[Table]

SELECT	TOP 1000 *
FROM	[Gmatica_PIN01\DW].[AGS_RawData].[DBA].[ClubIDGiocati]

SELECT	TOP 1000 *
FROM	[Gmatica_PIN01\DW].[AGS_RawData].[DBA].[LastCheck]

SELECT	TOP 1000 *
FROM	[Gmatica_PIN01\DW].[AGS_RawData].[dbo].[ElectronDB]

SELECT	TOP 1000 *
FROM	[Gmatica_PIN01\DW].[AGS_RawData].[dbo].[Machine]

SELECT	TOP 1000 *
FROM	[Gmatica_PIN01\DW].[AGS_RawData].[Dim].[Concessionary]

SELECT	TOP 1000 *
FROM	[Gmatica_PIN01\DW].[AGS_RawData].[Finance].[GamingRoom]

SELECT	TOP 1000 *
FROM	[Gmatica_PIN01\DW].[AGS_RawData].[Finance].[GamingVLT]

--SELECT	TOP 1000 *
--FROM	[Gmatica_PIN01\DW].[AGS_RawData].[ROE].[AssociazioniManuali]

SELECT	TOP 1000 *
FROM	[Gmatica_PIN01\DW].[AGS_RawData].[ROE].[Config]

SELECT	TOP 1000 *
FROM	[Gmatica_PIN01\DW].[AGS_RawData].[ROE].[ResetCounters]

SELECT	TOP 1000 *
FROM	[Gmatica_PIN01\DW].[AGS_RawData].[ROE].[TipoMatch]

SELECT	TOP 1000 *
FROM	[Gmatica_PIN01\DW].[AGS_RawData].[ROE].[TipoTransazione]

SELECT	TOP 1000 *
FROM	[Gmatica_PIN01\DW].[AGS_RawData].[ROE].[Utenze]

SELECT	TOP 1000 *
FROM	[Gmatica_PIN01\DW].[AGS_RawData].[TMP].[RawData]

-- VISTE

SELECT	TOP 1000 *
FROM	[Gmatica_PIN01\DW].[AGS_RawData].[dbo].[vElectrondb]

SELECT	COUNT(*)
FROM	[Gmatica_PIN01\DW].[AGS_RawData].[1000296].[RawData_View]


DECLARE 
		@OUTERSQL varchar(MAX)
		,@INNERSQL varchar(MAX)
		,@ConcessionaryName varchar(20)
		,@ClubID varchar(10)

SET @ConcessionaryName = 'GMATICA'
SET @ClubID = '1000296'
SET @INNERSQL = 
'
SELECT	COUNT(*)
FROM	[AGS_RawData].[' + @ClubID + '].[RawData_View] WITH(NOLOCK)
'
SET @OUTERSQL =
'
DECLARE @SQL varchar(MAX)
SET @SQL = ' + QUOTENAME(@INNERSQL, CHAR(39)) + '
EXEC(@SQL) AT [' + @ConcessionaryName + '_PIN01\DW]
'

