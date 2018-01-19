DECLARE 
		@OUTERSQL varchar(MAX)
		,@INNERSQL varchar(MAX)
		,@ConcessionaryName varchar(20)
		,@ClubID varchar(10)
		,@FromDate varchar(8)
		,@ToDate varchar(8)
		,@TopRows varchar(20)
		,@machineID int
		,@CSVmachineID varchar(100)

SET @ConcessionaryName = 'GMATICA'
SET @ClubID = '1000114'--'1000296'

--SET @FromDate = '20151118' -- '20100101'
--SET @ToDate = '20171231' --'20101231'

SET @FromDate = '20151117'
SET @ToDate = '20151118'

SET @TopRows = 'TOP 10000'
SET @machineID = 2
--SET @CSVmachineID = '2,20,26,27'
SET @CSVmachineID = '20'

--SET @INNERSQL = 
--'
--SELECT	' + ISNULL(@TopRows,'') + ' 
--		*
--FROM	[AGS_RawData_01].[' + @ClubID + '].[RawData_View] WITH(NOLOCK)
--WHERE	(ServerTime BETWEEN ' + QUOTENAME(CONVERT(CHAR(8), @FromDate, 112), CHAR(39)) + ' AND ' + QUOTENAME(CONVERT(CHAR(8), @ToDate, 112), CHAR(39)) + ')' +  -- AGS_RawData_01 Contiene solo i dati nell'intervallo 01/01/2012 - 17/11/2015
--'
--AND		MachineID = ' + CAST(@MachineID AS varchar(3)) + '
--'
--SET @INNERSQL = REPLACE(@INNERSQL, CHAR(39), CHAR(39)+CHAR(39))

--SET @OUTERSQL =
--'
--DECLARE @SQL varchar(MAX)	  
--SET @SQL = ''' + @INNERSQL + '''
--EXEC(@SQL) AT [' + ISNULL(@ConcessionaryName,'') + '_PIN01\DW]
--'
----PRINT(@INNERSQL)
----PRINT(@OUTERSQL)
--EXEC(@OUTERSQL) AT [POM-MON01]

SET @INNERSQL = 
'
SELECT	' + ISNULL(@TopRows,'') + ' 
		*
FROM	[AGS_RawData].[' + @ClubID + '].[RawData_View] WITH(NOLOCK)
WHERE	(ServerTime BETWEEN ' + QUOTENAME(CONVERT(CHAR(8), @FromDate, 112), CHAR(39)) + ' AND ' + QUOTENAME(CONVERT(CHAR(8), @ToDate, 112), CHAR(39)) + ')
--AND		MachineID = ' + CAST(@MachineID AS varchar(5)) + '
AND		MachineID IN (' + @CSVmachineID + ')
'
SET @INNERSQL = REPLACE(@INNERSQL, CHAR(39), CHAR(39)+CHAR(39))

SET @OUTERSQL =
'
DECLARE @SQL varchar(MAX)	  
SET @SQL = ''' + @INNERSQL + '''
EXEC(@SQL) AT [' + ISNULL(@ConcessionaryName,'') + '_PIN01\DW]
'
--PRINT(@INNERSQL)
--PRINT(@OUTERSQL)
EXEC(@OUTERSQL) AT [POM-MON01]