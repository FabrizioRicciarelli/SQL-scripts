/*
DECLARE @SQL Nvarchar(MAX)
SET @SQL = REPLACE([ETL].[BuildDynSQL_VLTInfo] (7), CHAR(39)+CHAR(39), CHAR(39))
PRINT(@SQL)
EXEC(@SQL) AT [POM-MON01] 
*/
ALTER FUNCTION [ETL].[BuildDynSQL_VLTInfo] (@ConcessionaryID int)
RETURNS Nvarchar(MAX)
AS
BEGIN
	DECLARE 
			@retVal Nvarchar(MAX)
			,@ConcessionaryName varchar(128) 
	SET @ConcessionaryName = ETL.getConcessionaryName(@ConcessionaryID)

	SET @retVal = REPLACE(
	N'
		SELECT	
				T1.ClubID AS ClubID
				,MachineID
				,T1.Machine AS Machine
				,AamsMachineCode
				,T3.UnivocalLocationCode AS UnivocalLocationCode
		FROM	[$_AGS_RawData].[dbo].[Machine] T1 WITH(NOLOCK) 
				INNER JOIN 
				[$_AGS_DW_COPIA].[Dim].[VLT] T2 WITH(NOLOCK)
				ON  T1.Machine COLLATE SQL_Latin1_General_CP1_CI_AS = T2.Machine COLLATE SQL_Latin1_General_CP1_CI_AS
				INNER JOIN
				[$_AGS_RawData].[Finance].[GamingRoom] T3 WITH(NOLOCK)
				ON T1.ClubID = T3.ClubID
	'
	,'$',@ConcessionaryName)
	RETURN @retVal
END