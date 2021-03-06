/*
DECLARE	
		@MachineID tinyint = 4
		,@wherecondition varchar(MAX)
		,@FromServerTime datetime = '2016-08-07 18:57:50.350'
		,@ToServerTime datetime = '2016-08-07 19:04:51.443'

DECLARE	@RawData TABLE
		(
			RowID int
			,ServerTime datetime
			,GameID int
			,LoginFlag bit
		)			

SET @wherecondition =
'
AND		MachineID = ' + CAST(@MachineID AS varchar(10)) + '
AND		(ServerTime BETWEEN ''' +  CAST(@FromServerTime AS varchar(30)) + ''' AND ''' +  CAST(@ToServerTime AS varchar(30)) + ''')
'

INSERT	@RawData
EXEC	GetRemoteSpecificRawData
		'GMATICA'
		,'1000296'
		,'RowID,ServerTime,GameID,LoginFlag' -- Set di colonne specifico
		,@wherecondition

SELECT	*
FROM	@RawData

*/
ALTER PROC [dbo].[GetRemoteSpecificRawData]
			@ConcessionaryName sysname
			,@ClubID varchar(10) = NULL	
			,@CSVfields varchar(MAX) = NULL
			,@criteria varchar(MAX) = NULL
			,@grouping varchar(MAX) = NULL
AS

EXEC	[POM-MON01].[Staging].[dbo].[GetSpecificRawData]
		@ConcessionaryName
		,@ClubID
		,@CSVfields
		,@criteria
		,@grouping

