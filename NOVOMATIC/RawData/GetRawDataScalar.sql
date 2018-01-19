/*
DECLARE	
		@FromServerTimeOut datetime
		,@TMP sql_variant
		,@criteria varchar(MAX)
		,@PayoutData datetime = '2016-08-07 19:06:17.000'
		,@MachineID int = 4

SET NOCOUNT ON;
SET @criteria = 
'
AND		TotalOut > 0 
AND		ServerTime < ''' + CAST(@PayOutData AS varchar(30)) + ''' 
AND		MachineID = ' + CAST(@MachineID AS varchar(4)) + '
'

EXEC	dbo.GetRawDataScalar
		'GMATICA'
		,'1000296'
		,'MAX(ServerTime) AS ServerTime'
		,@criteria
		,@TMP OUTPUT
SELECT  @FromServerTimeOut = CAST(@TMP AS datetime)
SELECT @FromServerTimeOut AS MaxServerTime

*/
ALTER PROC	dbo.GetRawDataScalar
			@pConcessionaryName sysname = NULL
			,@pClubID varchar(10) = NULL
			,@pScalarColumnName varchar(MAX) = NULL
			,@pCriteria varchar(MAX) = NULL
			,@pRetval sql_variant OUTPUT
AS

SET NOCOUNT ON;

IF ISNULL(@pConcessionaryName,'') != ''
AND ISNULL(@pClubID,'') != ''
AND ISNULL(@pScalarColumnName,'') != ''
AND ISNULL(@pCriteria,'') != ''
	BEGIN
		DECLARE 
				@SQL Nvarchar(MAX)
				,@ParmDefinition nvarchar(500)

		SET @ParmDefinition = 
		N'
			@ConcessionaryName sysname
			,@ClubID varchar(10)
			,@CSVfields varchar(MAX)
			,@Criteria varchar(MAX) = NULL
			,@ReturnValueOUT sql_variant OUTPUT
		';
		
		SET @SQL =
		N'
		DECLARE @RawDataScalar TABLE(ScalarValue sql_variant)
		DELETE  FROM @RawDataScalar
		INSERT	@RawDataScalar
		EXEC	GetRemoteSpecificRawData
				@ConcessionaryName
				,@ClubID
				,@CSVfields -- Nome di colonna o funzione di aggregazione
				,@Criteria

		SELECT	@ReturnValueOUT = 
				ScalarValue
		FROM	@RawDataScalar
		';

		EXEC	sp_executesql 
				@SQL
				,@ParmDefinition
				,@ConcessionaryName = @pConcessionaryName
				,@ClubID = @pClubID
				,@CSVfields = @pScalarColumnName -- Nome di colonna o funzione di aggregazione
				,@Criteria = @pCriteria
				,@ReturnValueOUT = @pRetval OUTPUT;
	END