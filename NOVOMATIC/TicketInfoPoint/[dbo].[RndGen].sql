/*
SELECT dbo.RndGen(1,13) AS NUM
*/
ALTER FUNCTION [dbo].[RndGen](@lower int=1, @upper int=13)
RETURNS int
AS
BEGIN
	DECLARE @RND int
	SELECT	@RND = ROUND(((@upper - @lower) * RNDVALUE + @lower), 0)
	FROM	[dbo].[V_RAND_NEWID]
	RETURN	@RND
END