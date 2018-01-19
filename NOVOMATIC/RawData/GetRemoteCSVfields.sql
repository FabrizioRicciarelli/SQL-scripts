USE [GMATICA_AGS_RawData_Elaborate_Stag_Agile]
GO
/****** Object:  StoredProcedure [dbo].[GetRemoteCSVfields]    Script Date: 12/07/2017 16:58:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
-- Tutte le colonne della tabella remota specificata senza il datatype
DECLARE	@CSVfields varchar(MAX)
EXEC	GetRemoteCSVfields 
		'GMATICA_AGS_RawData' -- Nome del DB remoto
		,'RawData' -- Nome della tabella remota
		,0 -- Specifica se annettere il datatype al nome della colonna o meno (1 = annette il datatype, 0 = senza il datatype)
		,NULL -- Criterio di filtro sulle colonne ritornate
		,@CSVfields OUTPUT -- Variabile che sarà popolata con i nomi di colonna separati da virgole
PRINT(@CSVfields)

-- Tutte le colonne della tabella remota specificata con annesso il datatype
DECLARE	@CSVfields varchar(MAX)
EXEC	GetRemoteCSVfields 
		'GMATICA_AGS_RawData' -- Nome del DB remoto
		,'RawData' -- Nome della tabella remota
		,1 -- Specifica se annettere il datatype al nome della colonna o meno (1 = annette il datatype, 0 = senza il datatype)
		,NULL -- Criterio di filtro sulle colonne ritornate
		,@CSVfields OUTPUT -- Variabile che sarà popolata con i nomi di colonna separati da virgole
PRINT(@CSVfields)

-- Solo le colonne della tabella remota specificata il cui nome contenga la parola "Total"
DECLARE	@CSVfields varchar(MAX)
EXEC	GetRemoteCSVfields 
		'GMATICA_AGS_RawData' -- Nome del DB remoto
		,'RawData' -- Nome della tabella remota
		,0 -- Specifica se annettere il datatype al nome della colonna o meno (1 = annette il datatype, 0 = senza il datatype)
		,'ColName LIKE ''%Total%'''
		,@CSVfields OUTPUT
PRINT(@CSVfields+CHAR(13));

-- Solo le colonne della tabella remota specificata il cui nome contenga la parola "Total" con annesso il datatype
DECLARE	@CSVfields varchar(MAX)
EXEC	GetRemoteCSVfields 
		'GMATICA_AGS_RawData' -- Nome del DB remoto
		,'RawData' -- Nome della tabella remota
		,1 -- Specifica se annettere il datatype al nome della colonna o meno (1 = annette il datatype, 0 = senza il datatype)
		,'ColName LIKE ''%Total%'''
		,@CSVfields OUTPUT
PRINT(@CSVfields+CHAR(13));

-- Solo le colonne della tabella remota specificata il cui nome contenga la parola "Total" e che siano di tipo INT, con annesso il datatype
DECLARE	@CSVfields varchar(MAX)
EXEC	GetRemoteCSVfields 
		'GMATICA_AGS_RawData' -- Nome del DB remoto
		,'RawData' -- Nome della tabella remota
		,1 -- Specifica se annettere il datatype al nome della colonna o meno (1 = annette il datatype, 0 = senza il datatype)
		,'ColName LIKE ''%Total%'' AND ColDatatype = ''int'''
		,@CSVfields OUTPUT
PRINT(@CSVfields)

-- Solo le colonne della tabella remota specificata che siano di tipo SPARSE
DECLARE	@CSVfields varchar(MAX)
EXEC	GetRemoteCSVfields 
		'GMATICA_AGS_RawData' -- Nome del DB remoto
		,'RawData' -- Nome della tabella remota
		,1 -- Specifica se annettere il datatype al nome della colonna o meno (1 = annette il datatype, 0 = senza il datatype)
		,'ColIsSparse = 1'
		,@CSVfields OUTPUT
PRINT(@CSVfields)

DECLARE @CSVfields varchar(MAX)
EXEC GetRemoteCSVfields 'Staging', 'VenueGeocoding', 0, NULL, @CSVfields OUTPUT
PRINT(@CSVfields+CHAR(13));

DECLARE @CSVfields varchar(MAX)
EXEC GetRemoteCSVfields 'Staging', 'VenueGeocoding', 1, NULL, @CSVfields OUTPUT
PRINT(@CSVfields)

DECLARE @CSVfields varchar(MAX)
EXEC GetRemoteCSVfields 'Staging', 'Game', 0, NULL, @CSVfields OUTPUT
PRINT(@CSVfields+CHAR(13));

DECLARE @CSVfields varchar(MAX)
EXEC GetRemoteCSVfields 'Staging', 'Game', 1, NULL, @CSVfields OUTPUT
PRINT(@CSVfields)

*/
ALTER PROC	[dbo].[GetRemoteCSVfields]
			@remoteDBname sysname = NULL
			,@remoteTableName sysname = NULL
			,@withDataType bit = NULL
			,@criteria varchar(MAX) = NULL
			,@fieldsList varchar(MAX) OUTPUT
AS
SET NOCOUNT ON;

DECLARE @Columns COLUMNS_TYPE

SELECT 
		@remoteDBname = ISNULL(@remoteDBname, 'GMATICA_AGS_RawData')
		,@remoteTableName = ISNULL(@remoteTableName, 'RawData')

INSERT	@Columns
EXEC	GetRemoteColumns
		@remoteDBname
		,@remoteTableName
		,@criteria

SELECT	@fieldsList = dbo.fnColumnsTableToCSV(@columns, @withDataType)
