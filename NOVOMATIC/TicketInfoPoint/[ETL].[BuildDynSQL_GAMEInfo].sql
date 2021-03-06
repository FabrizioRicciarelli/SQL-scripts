/*
DECLARE @SQL Nvarchar(MAX)
SET @SQL = REPLACE([ETL].[BuildDynSQL_GAMEInfo] (7), CHAR(39)+CHAR(39), CHAR(39))
PRINT(@SQL)
EXEC(@SQL) AT [POM-MON01] 
*/
ALTER FUNCTION [ETL].[BuildDynSQL_GAMEInfo] (@ConcessionaryID int)
RETURNS Nvarchar(MAX)
AS
BEGIN
	DECLARE 
			@retVal Nvarchar(MAX)
			,@ConcessionaryName varchar(128) 
	SET @ConcessionaryName = ETL.getConcessionaryName(@ConcessionaryID)

	SET @retVal = REPLACE(REPLACE(
	N'
		SELECT
				# AS ConcessionaryID	
				,T1.GameID AS GameID
				,T1.GameNameSK AS GameNameSK
				,REPLACE(T2.GameName, Char(13) + Char(10), '''') AS GameName
				,T3.GameNameTypeSK AS GameNameTypeSK
				,T1.AAMSGameCode AS AAMSGameCode
		FROM	[$_AGS_DW_COPIA].[Dim].[Game] T1 WITH(NOLOCK)
				INNER JOIN 
				[$_AGS_DW_COPIA].[Dim].[GameName] T2 WITH(NOLOCK)
				ON T1.GameNameSK = T2.GameNameSk 
				INNER JOIN 
				[$_AGS_DW_COPIA].[Dim].[GameNameType] T3 WITH(NOLOCK)
				ON T2.GameNameTypeSK = T3.GameNameTypeSK
		WHERE	1 = 1
	'
	,'$',@ConcessionaryName),'#',@ConcessionaryID)
	RETURN @retVal
END