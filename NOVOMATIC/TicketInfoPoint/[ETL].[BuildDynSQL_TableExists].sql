/*
SELECT [ETL].[BuildDynSQL_TableExists] ('AGS_RawData_01','RawData','1000002') AS DynSQL
*/
CREATE FUNCTION [ETL].[BuildDynSQL_TableExists] (
				@RawDataDBname sysname
				,@RawDataTable sysname
				,@ClubID varchar(10)
)
RETURNS Nvarchar(MAX)
AS
BEGIN
	DECLARE @retVal Nvarchar(MAX)
	SET @retVal = REPLACE(
		N'
		SELECT	bitValue =
				CASE
					WHEN	EXISTS(
								SELECT	TOP 1 
										* 
								FROM	$.[sys].[tables] TBL WITH(NOLOCK)
										INNER JOIN 
										$.[sys].[partitions] PART WITH(NOLOCK) 
										ON TBL.object_id = PART.object_id
										INNER JOIN 
										$.[sys].[indexes] IDX WITH(NOLOCK) 
										ON PART.object_id = IDX.object_id
										INNER JOIN 
										$.[sys].[schemas] SCH WITH(NOLOCK) 
										ON TBL.schema_id = SCH.schema_id
								WHERE	TBL.name = ''''' + @RawDataTable + ''''' 
								AND		SCH.Name = ''''' + @ClubID + '''''
							)
					THEN	1
					ELSE	0
				END 			  
		',
		'$',
		'[' + @RawDataDBname +']'
	)
	
	RETURN @retVal
END