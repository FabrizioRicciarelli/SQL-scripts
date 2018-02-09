/*
DECLARE
			@ServerStatus bit
			,@DBStatus sysname

EXEC [ETL].[CheckLinkedAndDBStatus] '[GMATICA_PIN01\DW]', 'AGS_RawData', @ServerStatus = @ServerStatus OUTPUT, @DBStatus = @DBStatus OUTPUT
SELECT @ServerStatus AS ServerStatus, @DBStatus AS DBStatus 
*/
ALTER PROC	[ETL].[CheckLinkedAndDBStatus]
			@LInkedServerName sysname
			,@DataBaseName sysname
			,@ServerStatus bit OUTPUT
			,@DBStatus varchar(MAX) OUTPUT
AS
DECLARE 
		@INNERSQL Nvarchar(MAX)
		,@OUTERSQL Nvarchar(MAX)
		,@OUTERMOSTSQL Nvarchar(MAX)
		,@returnValue Nvarchar(MAX)
		,@XMLreturn XML

SET		@INNERSQL = [ETL].[BuildDynSQL_LinkedServerRunning] (@LInkedServerName)
SET		@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@INNERSQL)
EXEC	sp_executesqL @OUTERMOSTSQL, N'@returnValue varchar(MAX) OUT', @returnValue=@returnValue OUT

PRINT @OUTERMOSTSQL

SET @XMLreturn = CAST(@returnValue AS XML)
SELECT	
		@ServerStatus = T.c.value('@ServerStatus', 'bit')
		,@DBStatus = T.c.value('@DBStatus', 'varchar(MAX)')
FROM	@XMLreturn.nodes('ServerAndDbInfo') AS T(c) 

