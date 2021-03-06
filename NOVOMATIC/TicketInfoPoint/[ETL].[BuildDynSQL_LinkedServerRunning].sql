/*
SELECT [ETL].[BuildDynSQL_LinkedServerRunning] ('[GMATICA_PIN01\DW]') AS DynSQL
*/
ALTER FUNCTION [ETL].[BuildDynSQL_LinkedServerRunning] (
				@LInkedServerName sysname
)
RETURNS Nvarchar(MAX)
AS
BEGIN
	DECLARE @retVal Nvarchar(MAX)
	SET @retVal = 
	N'
	SET FMTONLY OFF; 
	BEGIN TRY
		DECLARE	@tmp TABLE(CATALOG_NAME sysname, DESCRIPTION nvarchar(25))
		INSERT	@tmp
		EXEC	sp_catalogs ' + @LInkedServerName + '

		SELECT ServerAndDbInfo = CAST(
		( 
			SELECT 
					1 AS ServerStatus
					,''ONLINE'' AS DBStatus
			FOR		XML RAW(''ServerAndDbInfo''), TYPE
		) AS varchar(MAX))
	END TRY
	BEGIN CATCH
		SELECT ServerAndDbInfo = CAST(
		( 
			SELECT 
					0 AS ServerStatus
					,CAST(ERROR_MESSAGE() AS varchar(MAX)) AS DBStatus
			FOR		XML RAW(''ServerAndDbInfo''), TYPE
		) AS varchar(MAX))
	END CATCH
	'
	
	RETURN @retVal
END