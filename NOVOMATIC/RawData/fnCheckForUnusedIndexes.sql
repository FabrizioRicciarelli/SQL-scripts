/*
Funzione preposta all'analisi della struttura degli indici di uno o più
database e alla creazione di uno script on-the-fly per la *eliminazione* degli
indici rilevati come inutilizzati/superflui.

Richiede privilegi amministrativi

-- Esempi di richiamo:
SELECT * FROM dbo.fnCheckForUnusedIndexes()
*/
ALTER FUNCTION dbo.fnCheckForUnusedIndexes()
RETURNS @INDEXDATA TABLE
		(
			ObjectName sysname
			,IndexName sysname
			,IndexID int
			,UserSeek bigint
			,UserScans bigint
			,UserLookups bigint
			,UserUpdates bigint
			,TableRows int
			,Drop_Statement varchar(MAX)
		)
AS
BEGIN
	INSERT	@INDEXDATA
	SELECT	TOP 25
			o.name AS ObjectName
			,i.name AS IndexName
			,i.index_id AS IndexID
			,dm_ius.user_seeks AS UserSeek
			,dm_ius.user_scans AS UserScans
			,dm_ius.user_lookups AS UserLookups
			,dm_ius.user_updates AS UserUpdates
			,p.TableRows
			,Drop_Statement =
				'DROP INDEX ' + 
				QUOTENAME(i.name) + 
				' ON ' + 
				QUOTENAME(s.name) +
				'.' + 
				QUOTENAME(OBJECT_NAME(dm_ius.OBJECT_ID))
	FROM	sys.dm_db_index_usage_stats AS dm_ius
			JOIN 
			sys.indexes i 
			ON i.index_id = dm_ius.index_id 
			AND dm_ius.OBJECT_ID = i.OBJECT_ID
			JOIN 
			sys.objects o 
			ON dm_ius.OBJECT_ID = o.OBJECT_ID
			JOIN 
			sys.schemas s 
			ON o.schema_id = s.schema_id
			JOIN 
			(
				SELECT	SUM(p.rows) AS TableRows
						,p.index_id
						,p.OBJECT_ID
				FROM	sys.partitions p 
				GROUP BY 
						p.index_id
						,p.OBJECT_ID
			) p
			ON p.index_id = dm_ius.index_id 
			AND dm_ius.OBJECT_ID = p.OBJECT_ID
	WHERE	OBJECTPROPERTY(dm_ius.OBJECT_ID,'IsUserTable') = 1
	AND		dm_ius.database_id = DB_ID()
	AND		i.type_desc = 'nonclustered'
	AND		i.is_primary_key = 0
	AND		i.is_unique_constraint = 0
	ORDER BY 
	(
		dm_ius.user_seeks + dm_ius.user_scans + dm_ius.user_lookups
	) ASC
	
	RETURN
END
