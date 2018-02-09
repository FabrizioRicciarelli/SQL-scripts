EXEC ('sp_catalogs [GMATICA_PIN01\DW]') AT [POM-MON01]


SET XACT_ABORT OFF;
DECLARE @retVal Nvarchar(MAX), @LInkedServerName sysname = '[GMATICA_PIN01\DW]'
DECLARE @ServerAndDbInfo TABLE(info varchar(MAX))
SET @retVal = 
N'
	SET FMTONLY OFF; 
	DECLARE @srvr nvarchar(128),
			@retval int;
	SET @srvr = ''[GMATICA_PIN02\DW]'';
	BEGIN try
		EXEC @retval = sys.sp_testlinkedserver
	END try 
	BEGIN catch
		SET @retval = sign(@@error);
		--PRINT ''Unable to connect to server. This operation will be tried later!'';
	END catch;

	BEGIN try
		IF @retval=0 
		SELECT * FROM OPENQUERY([GMATICA_PIN01\DW],''SELECT 1'');
	END try 
	BEGIN catch
	--	PRINT ''Table or view does not exist'';
	END catch;
'
--INSERT @ServerAndDbInfo
EXEC (@retVal) AT [POM-MON01]

SELECT * FROM OPENQUERY(
	[POM-MON01]
	,
	N'
	SET FMTONLY ON; 
	DECLARE @srvr nvarchar(128),
			@retval int;
	SET @srvr = ''[GMATICA_PIN01\DW]'';
	BEGIN try
		EXEC @retval = sys.sp_testlinkedserver
	END try 
	BEGIN catch
		SET @retval = sign(@@error);
		PRINT ''Unable to connect to server. This operation will be tried later!'';
	END catch;

	BEGIN try
		IF @retval=0 
		SELECT * FROM OPENQUERY([GMATICA_PIN01\DW],''SELECT 1'');
	END try 
	BEGIN catch
		PRINT ''Table or view does not exist'';
	END catch;
	'
)

EXEC	sp_testlinkedserver @servername = [POM-MON01] WITH RESULT SETS
EXEC	sp_catalogs [POM-MON01] WITH RESULT SETS((CATALOG_NAME sysname, DESCRIPTION nvarchar(25)))
EXEC	sp_catalogs [GMATICA_PIN01\DW] WITH RESULT SETS((CATALOG_NAME sysname, DESCRIPTION nvarchar(25)))