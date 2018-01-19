DECLARE @counts TABLE(MachineID int, Occurrences int)
INSERT @counts
EXEC	GetRemoteSpecificRawData
		@ConcessionaryName = 'GMATICA'
		,@ClubID = '1000296'
		,@CSVfields = 'DISTINCT MachineID, COUNT(*) AS Occurrences'
		,@criteria = 'AND ServerTime IS NOT NULL'
		,@grouping = 'GROUP BY MachineID'
SELECT	*
FROM	@counts
ORDER BY Occurrences DESC