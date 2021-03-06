/*
EXEC	CreateRemoteTotalIndexes 
		@DBname = 'GMATICA_AGS_RawData'
		,@ClubId = '1000296'
		,@CSVindexedColumns = 'TotalOut,TotalHandpay,TotalTicketIn,TotalTicketOut'
		,@CSVincludedColumns = NULL

EXEC	CreateRemoteTotalIndexes 
		@DBname = 'GMATICA_AGS_RawData'
		,@ClubId = '1000296'
		,@CSVindexedColumns = 'TotalOut,TotalHandpay,TotalTicketIn,TotalTicketOut'
		,@CSVincludedColumns = 'RowID,ServerTime,MachineTime,MachineID,GameID,LoginFlag,TotalBet,Win,TotalOut,TotalHandpay,TotalIn,TotalBillIn,TotalTicketIn,TotalTicketOut,WinD'
*/
ALTER PROC	[dbo].[CreateRemoteTotalIndexes] 
			@DBname sysname
			,@ClubId varchar(10) = NULL
			,@CSVindexedColumns varchar(MAX) = NULL
			,@CSVincludedColumns varchar(MAX) = NULL
AS
SET NOCOUNT ON;
IF ISNULL(@DBname,'') != ''
AND ISNULL(@ClubId,'') != ''
AND ISNULL(@CSVindexedColumns,'') != ''
BEGIN
	EXEC	[POM-MON01].[Staging].[dbo].[CreateTotalIndexes]
			@DBname
			,@ClubId
			,@CSVindexedColumns
			,@CSVincludedColumns

	--DECLARE 
	--		@SQL Nvarchar(MAX) 

	--SELECT @SQL = 
	--N'
	--EXEC	CreateTotalIndexes
	--		@DBname = ' + QUOTENAME(@DBname, CHAR(39)) + '
	--		,@ClubId = ' + QUOTENAME(@ClubId, CHAR(39)) + '
	--		,@CSVindexedColumns = ' + QUOTENAME(@CSVindexedColumns, CHAR(39)) + '
	--		,@CSVincludedColumns = ' + CASE WHEN @CSVindexedColumns IS NOT NULL THEN QUOTENAME(@CSVindexedColumns, CHAR(39)) ELSE 'NULL' END + '
	--'

	--PRINT(@SQL)
	--EXEC [POM-MON01].[Staging].[dbo].sp_executesql @SQL -- Equivalente della EXEC(@SQL) AT [POM-MON01], ma con un utilizzo migliore del piano di esecuzione
END
