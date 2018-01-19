/*
EXEC	DropTotalIndexes 
		@DBname = 'GMATICA_AGS_RawData'
		,@ClubId = '1000296'
		,@CSVindexedColumns = 'TotalOut,TotalHandpay,TotalTicketIn,TotalTicketOut'
*/
ALTER PROC	dbo.DropTotalIndexes 
			@DBname sysname
			,@ClubId varchar(10) = NULL
			,@CSVindexedColumns varchar(MAX) = NULL
AS
SET NOCOUNT ON;
IF ISNULL(@DBname,'') != ''
AND ISNULL(@ClubId,'') != ''
BEGIN
	DECLARE 
			@SQL varchar(MAX) = 'USE ' + @DBname + ';' + CHAR(13)
			,@CurrentTableName sysname

	DECLARE @IndexedColumns TABLE (CurrentTotalColumn sysname)

	SET @CurrentTableName = '[' + @ClubId + '].[RawData]'
	
	INSERT	@IndexedColumns(CurrentTotalColumn)
	SELECT	LTRIM(RTRIM(Item)) AS CurrentTotalColumn 
	FROM	dbo.SplitStringsXML(@CSVindexedColumns, N',')

	SELECT 
			@SQL +=
'
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = ' + QUOTENAME('[IX_' + CurrentTotalColumn + '_INCL_SomeOthers]',CHAR(39)) + ' AND object_id = OBJECT_ID(' + QUOTENAME(@CurrentTableName,CHAR(39)) + ')
	BEGIN
		DROP INDEX [IX_' + CurrentTotalColumn + '_INCL_AllOthers]	
		ON ' + @CurrentTableName + '
	END
GO
'
	FROM @IndexedColumns

	--PRINT(@SQL)
	EXEC(@SQL)
END
