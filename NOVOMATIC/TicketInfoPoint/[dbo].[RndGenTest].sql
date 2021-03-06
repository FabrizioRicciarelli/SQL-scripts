/*
SELECT * FROM dbo.RndGenTest(100000,1,6)
*/
ALTER FUNCTION [dbo].[RndGenTest](@iterations int = 1000, @lower int=1, @upper int=13)
RETURNS @RNDNUM TABLE (NUM int, Occurrences int)
AS
BEGIN
	DECLARE	@RND TABLE (NUM int)
	DECLARE @I INT = 1
	
	WHILE @I < @iterations
		BEGIN
			INSERT	@RND(NUM)
			SELECT	dbo.RndGen(@lower,@upper) AS NUM
			-- oppure
			--SELECT	ROUND(((@upper - @lower) * RNDVALUE + @lower), 0) AS NUM
			--FROM	[dbo].[V_RAND_NEWID]
			SET @I += 1
		END
	
	INSERT  @RNDNUM (NUM, Occurrences)
	SELECT	NUM, COUNT(*) AS Occurrences
	FROM	@RND
	GROUP BY NUM
	ORDER BY NUM

	RETURN
END
