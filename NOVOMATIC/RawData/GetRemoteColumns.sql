USE [GMATICA_AGS_RawData_Elaborate_Stag_Agile]
GO
/****** Object:  StoredProcedure [dbo].[GetRemoteColumns]    Script Date: 12/07/2017 16:58:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Restituisce, in forma tabellare, l'elenco dei campi - con relativi datatypes e dimensioni - 
che compongono le tabelle utente

-- Esempi di invocazione/richiamo
----------------------------------
EXEC dbo.GetRemoteColumns  -- Restituisce le colonne delle tabelle 'RawData' di default
EXEC dbo.GetRemoteColumns 'GMATICA_AGS_RawData', 'RawData' -- Tutte le colonne della tabella specificata
EXEC dbo.GetRemoteColumns 'GMATICA_AGS_RawData', 'RawData', 'ColName LIKE ''%Total%''' -- Solo le colonne il cui nome contenga la parola "Total"
EXEC dbo.GetRemoteColumns 'GMATICA_AGS_RawData', 'RawData', 'ColDataType = ''smallint''' -- Solo le colonne di tipo smallint
EXEC dbo.GetRemoteColumns 'GMATICA_AGS_RawData', 'RawData', 'ColScale != 0' -- Solo le colonne la cui scala di precisione sia diversa da zero
EXEC dbo.GetRemoteColumns 'GMATICA_AGS_RawData', 'RawData', 'ColIsSparse = 1' -- Solo le colonne di tipo SPARSE
EXEC dbo.GetRemoteColumns 'GMATICA_AGS_RawData', 'RawData_01'
EXEC dbo.GetRemoteColumns 'GMATICA_AGS_RawData', 'RawData_02'
EXEC dbo.GetRemoteColumns 'GMATICA_AGS_RawData', 'RawData_03'
EXEC dbo.GetRemoteColumns 'GMATICA_AGS_RawData', 'RawData_16'
EXEC dbo.GetRemoteColumns 'GMATICA_AGS_RawData', 'TicketData'
EXEC dbo.GetRemoteColumns 'GMATICA_AGS_RawData', 'Concessionary'
EXEC dbo.GetRemoteColumns 'GMATICA_AGS_RawData', 'Config'
EXEC dbo.GetRemoteColumns 'GMATICA_AGS_RawData', 'Machine'
EXEC dbo.GetRemoteColumns 'GMATICA_AGS_RawData', 'ElectronDB'
EXEC dbo.GetRemoteColumns 'Staging', 'it_toponimi'
EXEC dbo.GetRemoteColumns 'Staging', 'VLTModel'
EXEC dbo.GetRemoteColumns 'Staging', 'VenueGeocoding'
EXEC dbo.GetRemoteColumns 'Staging', 'Game'

-- Elenco di tutte le tabelle utente presenti
-- nel DB specificato
----------------------------------------------
DECLARE 
		@SQL varchar(MAX)
		,@remoteDBname sysname = 'GMATICA_AGS_RawData' -- 'Staging' -- 
SET @SQL =
'
SELECT	DISTINCT [name]
FROM	' + @remoteDBname + '.sys.objects 
WHERE	[type] = ''U''
'
EXEC(@SQL) AT [POM-MON01]
*/
ALTER PROCEDURE [dbo].[GetRemoteColumns]
				@remoteDBname sysname = NULL
				,@remoteTableName sysname = NULL
				,@criteria varchar(MAX) = NULL
AS
DECLARE @SQL varchar(MAX)
	
SELECT 
		@remoteDBname = ISNULL(@remoteDBname, 'GMATICA_AGS_RawData')
		,@remoteTableName = ISNULL(@remoteTableName, 'RawData')
		,@criteria =
			CASE
				WHEN @criteria IS NOT NULL
				THEN
					CASE
						WHEN @criteria NOT LIKE '%WHERE%'
						THEN ' WHERE ' + @criteria
						ELSE @criteria
					END
				ELSE ''
			END

SET @SQL =
'
USE Staging;
SELECT 
		ColName
		,ColDatatype
		,ColLength
		,ColPrecision
		,ColScale
		,ColIsSparse
FROM	dbo.GetColumns(''' + @remoteDBname + ''',''' + @remoteTableName + ''')
' + @criteria
EXEC(@SQL) AT [POM-MON01]
