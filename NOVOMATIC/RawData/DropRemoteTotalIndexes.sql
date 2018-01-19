/*
EXEC	DropRemoteTotalIndexes 
		@DBname = 'GMATICA_AGS_RawData'
		,@ClubId = '1000296'
		,@CSVindexedColumns = 'TotalOut,TotalHandpay,TotalTicketIn,TotalTicketOut'

*/
ALTER PROC	dbo.DropRemoteTotalIndexes 
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
	DECLARE 
			@SQL Nvarchar(MAX) 

	SELECT @SQL = 
	N'
	EXEC	DropTotalIndexes
			@DBname = ' + QUOTENAME(@DBname, CHAR(39)) + '
			,@ClubId = ' + QUOTENAME(@ClubId, CHAR(39)) + '
			,@CSVindexedColumns = ' + QUOTENAME(@CSVindexedColumns, CHAR(39)) + '
	'

	--PRINT(@SQL)
	EXEC [POM-MON01].[Staging].[dbo].[sp_executesql] @SQL
END
