/*
EXEC	CreateTotalIndexes 
		@DBname = 'GMATICA_AGS_RawData'
		,@ClubId = '1000296'
		,@CSVindexedColumns = 'TotalOut,TotalHandpay,TotalTicketIn,TotalTicketOut'
		,@CSVincludedColumns = NULL

EXEC	CreateTotalIndexes 
		@DBname = 'GMATICA_AGS_RawData'
		,@ClubId = '1000296'
		,@CSVindexedColumns = 'TotalOut,TotalHandpay,TotalTicketIn,TotalTicketOut'
		,@CSVincludedColumns = 'RowID,ServerTime,MachineTime,MachineID,GameID,LoginFlag,TotalBet,Win,TotalOut,TotalHandpay,TotalIn,TotalBillIn,TotalTicketIn,TotalTicketOut,WinD'
*/
ALTER PROC	[dbo].[CreateTotalIndexes] 
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
			@SQL varchar(MAX) = 'USE ' + @DBname + ';' + CHAR(13)
			,@CurrentTableName sysname
			,@IncludedColumns varchar(MAX)

	DECLARE @IndexedColumns TABLE (CurrentTotalColumn sysname)

	SET @CurrentTableName = '[' + @ClubId + '].[RawData]'
	
	INSERT	@IndexedColumns(CurrentTotalColumn)
	SELECT	LTRIM(RTRIM(Item)) AS CurrentTotalColumn 
	FROM	dbo.SplitStringsXML(@CSVindexedColumns, N',')

	SELECT 
			@IncludedColumns =	
				CASE
					WHEN @CSVincludedColumns IS NOT NULL
					THEN REPLACE(
									'			INCLUDE (' + @CSVincludedColumns + ')'
									,',' + CurrentTotalColumn
									,''
								)
					ELSE ''
				END
			,@SQL +=
'
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = ' + QUOTENAME('[IX_' + CurrentTotalColumn + '_INCL_SomeOthers]',CHAR(39)) + ' AND object_id = OBJECT_ID(' + QUOTENAME(@CurrentTableName,CHAR(39)) + '))
	BEGIN
		CREATE NONCLUSTERED INDEX [IX_' + CurrentTotalColumn + '_INCL_AllOthers]	
		ON ' + @CurrentTableName + ' ([' + CurrentTotalColumn + '] DESC)' + CHAR(13) + @IncludedColumns + '
		WHERE ' + CurrentTotalColumn + ' IS NOT NULL
		WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 60) ON [DatiRawData];
	END
'
	FROM @IndexedColumns

	--PRINT(@SQL)
	EXEC(@SQL)
END
