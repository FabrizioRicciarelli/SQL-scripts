/*
----------------------------------------------------
-- FUNZIONE CHE RITORNA UNA STRINGA CASUALE
-- DI LUNGHEZZA SPECIFICA
----------------------------------------------------
--
-- Fabrizio Ricciarelli per Eustema Spa
-- 16/11/2015
--
-- Esempi di invocazione:
--
PRINT dbo.fnRandomString(1,5)
PRINT dbo.fnRandomString(128,128)
PRINT dbo.fnRandomString(255,255)
PRINT dbo.fnRandomString(1023,1023)
PRINT dbo.fnRandomString(8000,8000) -- IL MASSIMO RAPPRESENTABILE ALL'INTERNO DEL CLIENT Microsoft Sql Management Studio
*/
ALTER FUNCTION [dbo].[fnRandomString](@minLength int, @maxLength int)
RETURNS varchar(max)
AS
BEGIN

	DECLARE @length int, @charpool varchar(max), @LoopCount int, @PoolLength int, @RandomString varchar(max), @rand float
	SELECT @Length = RNDVALUE * @minLength + @maxLength FROM V_RAND
	SET @CharPool = 'abcdefghijkmnopqrstuvwxyzABCDEFGHIJKLMNPQRSTUVWXYZ23456789'-- - .,_!$@#%^&*'
	SET @PoolLength = Len(@CharPool)
	SET @LoopCount = 0
	SET @RandomString = ''

	WHILE (@LoopCount < @Length) 
	BEGIN
		SELECT @RAND =  RNDVALUE *  @PoolLength FROM V_RAND
		SELECT @RandomString = @RandomString + SUBSTRING(@Charpool, CONVERT(int, @rand), 1)
		SELECT @LoopCount = @LoopCount + 1
	END

	RETURN UPPER(LEFT(@RandomString,@maxLength))
END
/*
-- per ovviare al problema "Msg 443, Level 16, State 1, Procedure ufnGetRandomNumber, Line 5 Invalid use of a side-effecting operator ‘rand’ within a function."
ALTER VIEW V_RAND
AS
SELECT RAND() AS RNDVALUE
*/