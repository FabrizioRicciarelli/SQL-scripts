USE [TicketInfoPoint]
GO
/****** Object:  UserDefinedFunction [ETL].[BuildDynSQL_TableExists]    Script Date: 30/01/2018 17:26:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT [ETL].[BuildDynSQL_MinMaxServerDate] ('AGS_RawData_01','RawData','1000002') AS DynSQL
*/
DROP FUNCTION [ETL].[BuildDynSQL_MinMaxServerDate] (
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
		SELECT	
				MIN(ServerTime) AS MinDate
				,MAX(ServerTime) AS MaxDate
		FROM	$.[' + @ClubID + '].[' + @RawDataTable + ']',
		'$',
		'[' + @RawDataDBname +']'
	)
	
	RETURN @retVal
END