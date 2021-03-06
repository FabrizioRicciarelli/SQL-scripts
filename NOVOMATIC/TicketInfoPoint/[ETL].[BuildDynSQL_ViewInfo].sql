/*
SELECT [ETL].[BuildDynSQL_ViewInfo] ('AGS_RawData_01','RawData','1000004',NULL) AS DynSQL
SELECT [ETL].[BuildDynSQL_ViewInfo] ('GMATICA_AGS_RawData_01','RawData_View','1000002',NULL) AS DynSQL

DECLARE @SQL Nvarchar(MAX)
SET @SQL = REPLACE([ETL].[BuildDynSQL_ViewInfo] ('GMATICA_AGS_RawData','RawData_View','1000002',1), CHAR(39)+CHAR(39), CHAR(39))
PRINT(@SQL)
EXEC(@SQL) AT [POM-MON01] 

*/
ALTER FUNCTION [ETL].[BuildDynSQL_ViewInfo] (
				@RawDataDBname sysname
				,@RawDataTable sysname
				,@ClubID varchar(10)
				,@DoRowCount bit = null
)
RETURNS Nvarchar(MAX)
AS
BEGIN
	DECLARE @retVal Nvarchar(MAX)

	SET @retVal = REPLACE(
		N'
		SELECT	ViewInfo = CAST(
		( 
			SELECT
			--' + IIF(ISNULL(@DoRowCount,0) = 0, '0 AS RowsCount,', 'COUNT_BIG(*) AS RowsCount,') +
			'		0 AS RowsCount -- LOGICA DI CONTEGGIO TRASFERITA NELLA SP "[ETL].[CountRawDataViewRows]"
					MIN(ServerTime) AS MinDate,      
					MAX(ServerTime) AS MaxDate    
			FROM	$.[' + @ClubID + '].[' + @RawDataTable + ']
			FOR XML RAW(''ViewInfo''), TYPE
		) AS varchar(MAX))',
		'$',
		'[' + @RawDataDBname +']'
	)
	RETURN @retVal
END