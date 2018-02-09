/*
SELECT [ETL].[CheckDBStatus]() AS DbStatus
*/
ALTER FUNCTION	[ETL].[CheckDBStatus]()
RETURNS varchar(256)
AS
BEGIN
	DECLARE	
			@retVal varchar(256)
			,@status int 
	SELECT	@status = status 
	FROM	sys.sysdatabases 
	WHERE	name = DB_NAME() 

	--PRINT DB_NAME() + ' - ' + CONVERT(VARCHAR(20),@status) 

	IF ( (1 & @status) = 1 ) SET @retVal = 'autoclose' 
	IF ( (2 & @status) = 2 ) SET @retVal = '2 not sure' 
	IF ( (4 & @status) = 4 ) SET @retVal = 'select into/bulkcopy' 
	IF ( (8 & @status) = 8 ) SET @retVal = 'trunc. log on chkpt' 
	IF ( (16 & @status) = 16 ) SET @retVal = 'torn page detection' 
	IF ( (32 & @status) = 32 ) SET @retVal = 'loading' 
	IF ( (64 & @status) = 64 ) SET @retVal = 'pre recovery' 
	IF ( (128 & @status) = 128 ) SET @retVal = 'recovering' 
	IF ( (256 & @status) = 256 ) SET @retVal = 'not recovered' 
	IF ( (512 & @status) = 512 ) SET @retVal = 'offline' 
	IF ( (1024 & @status) = 1024 ) SET @retVal = 'read only' 
	IF ( (2048 & @status) = 2048 ) SET @retVal = 'dbo use only' 
	IF ( (4096 & @status) = 4096 ) SET @retVal = 'single user' 
	IF ( (8192 & @status) = 8192 ) SET @retVal = '8192 not sure' 
	IF ( (16384 & @status) = 16384 ) SET @retVal = '16384 not sure' 
	IF ( (32768 & @status) = 32768 ) SET @retVal = 'emergency mode' 
	IF ( (65536 & @status) = 65536 ) SET @retVal = 'online' 
	IF ( (131072 & @status) = 131072 ) SET @retVal = '131072 not sure' 
	IF ( (262144 & @status) = 262144 ) SET @retVal = '262144 not sure' 
	IF ( (524288 & @status) = 524288 ) SET @retVal = '524288 not sure' 
	IF ( (1048576 & @status) = 1048576 ) SET @retVal = '1048576 not sure' 
	IF ( (2097152 & @status) = 2097152 ) SET @retVal = '2097152 not sure' 
	IF ( (4194304 & @status) = 4194304 ) SET @retVal = 'autoshrink' 
	IF ( (1073741824 & @status) = 1073741824 ) SET @retVal = 'cleanly shutdown'  

	-- ALTERNATIVA
	--SELECT	@retVal = DATABASEPROPERTYEX('master', 'Status')

	RETURN @retVal

END
