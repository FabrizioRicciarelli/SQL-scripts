-- VIEW DATABASE STATE permission denied in database 'GMATICA_AGS_RawData'. The user does not have permission to perform this action.
SELECT SUM(st.row_count)
FROM	sys.dm_db_partition_stats st
WHERE	OBJECT_ID = OBJECT_ID('[10000002].[RawData]')
AND		(index_id < 2)

-- The object '[10000002].[RawData]' does not exist in database 'GMATICA_AGS_RawData' or is invalid for this operation.
exec sp_spaceused '[10000002].[RawData]'

-- No results
SELECT	CONVERT(bigint, rows)
FROM	sysindexes
WHERE	id = OBJECT_ID('[10000002].[RawData]')
AND		indid < 2

SELECT TOP 10 *
FROM [POM-MON01].[NTS_AGS_RawData].[6500011].[RawData]