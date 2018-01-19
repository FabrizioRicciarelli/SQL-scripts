USE GMATICA_AGS_RawData;
/*
Restituisce, in forma tabellare, l'elenco dei campi - con relativi datatypes e dimensioni - 
che compongono le tabelle utente

-- Esempi di invocazione/richiamo
----------------------------------
SELECT * FROM dbo.GetColumns() -- Restituisce le colonne delle tabelle 'RawData' di default
SELECT * FROM dbo.GetColumns('RawData')
SELECT * FROM dbo.GetColumns('RawData_01')
SELECT * FROM dbo.GetColumns('RawData_02')
SELECT * FROM dbo.GetColumns('RawData_03')
SELECT * FROM dbo.GetColumns('RawData_16')
SELECT * FROM dbo.GetColumns('TicketData')
SELECT * FROM dbo.GetColumns('Concessionary')
SELECT * FROM dbo.GetColumns('Config')
SELECT * FROM dbo.GetColumns('Machine')
SELECT * FROM dbo.GetColumns('ElectronDB')

-- Elenco di tutte le tabelle utente presenti
-- nel DB corrente
----------------------------------------------
SELECT	DISTINCT [name]
FROM	SYSOBJECTS 
WHERE	xtype = 'U'

*/
CREATE FUNCTION dbo.GetColumns(@tableName sysname = NULL)
RETURNS @Columns TABLE
		(
			ColName sysname
			,ColDatatype varchar(30)
			,ColLength int
			,ColPrecision smallint
			,ColScale smallint
		)
AS
BEGIN
	SELECT @tableName = ISNULL(@tableName, 'RawData')

	INSERT	@Columns
			(
				ColName
				,ColDatatype
				,ColLength
				,ColPrecision
				,ColScale
			)
	SELECT	
			C.[name] AS ColName
			,S.[name] AS ColDatatype
			,C.[length] AS ColLength
			,C.xprec AS ColPrecision
			,C.xscale AS ColScale
	FROM	
	(
			SELECT	*
			FROM	SYSOBJECTS
			WHERE	id = 
					(
						SELECT	MAX(id) 
						FROM	SYSOBJECTS 
						WHERE	[name] = @tableName 
						AND		xtype = 'U'
					)
	)	O
		JOIN
		SYSCOLUMNS C
		ON O.id = C.id
		JOIN
		SYSTYPES S
		ON S.xtype = C.xtype
	ORDER BY C.colid

	RETURN
END

