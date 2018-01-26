/*
SELECT ETL.getConcessionaryName(7) AS Concessionary
*/
ALTER FUNCTION	ETL.getConcessionaryName(@ConcessionaryID int = NULL)
RETURNS varchar(100)
AS
BEGIN
	DECLARE 
			@SQL Nvarchar(MAX)
			,@retVal varchar(100) 
	
	SELECT	@retVal = ConcessionaryName
	FROM	[POM-MON01].[AGS].[Type].[Concessionary] WITH(NOLOCK)
	WHERE	ConcessionarySK = @ConcessionaryID 

	RETURN @retVal
END