/*
----------------------------------------------------
-- FUNZIONE CHE RITORNA UNA STRINGA CASUALE
-- DI LUNGHEZZA SPECIFICA IN BASE AL TIPO DI
-- DATO SPECIFICATO.
-- SE INDICATO, PUO' RACCHIUDERE IL DATO 
-- CASUALE TRA DELIMITATORI
----------------------------------------------------
--
-- Fabrizio Ricciarelli per Eustema Spa
-- 27/11/2015
--
-- Esempi di invocazione:
--
PRINT(dbo.fnGetRandomDataByDatatype('bit',10,NULL))
PRINT(dbo.fnGetRandomDataByDatatype('int',10,NULL))
PRINT(dbo.fnGetRandomDataByDatatype('decimal',20,NULL))
PRINT(dbo.fnGetRandomDataByDatatype('varchar',100,'"'))
PRINT(dbo.fnGetRandomDataByDatatype('datetime',26,NULL))
PRINT(dbo.fnGetRandomDataByDatatype('datetime',26,''''))
*/
ALTER FUNCTION [dbo].[fnGetRandomDataByDatatype](@sqlDatatype varchar(20) = NULL, @maxLength int = NULL, @encloseStringsWithQuoteChar char(1) = NULL)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @retVal varchar(MAX) = NULL
	
	IF ISNULL(@sqlDatatype,'') != ''
	AND ISNULL(@maxLength,'') != ''
		BEGIN
			SELECT @retVal =
					CASE 
						WHEN @sqlDatatype in ('bit') 
						THEN CAST(BITVALUE AS char(1))
						WHEN @sqlDatatype in ('bigint','int','smallint','tinyint') 
						THEN LEFT(CAST(CAST(RNDVALUE * 1000000 AS int) AS varchar(MAX)),@maxLength)
						WHEN @sqlDatatype in ('float','decimal','numeric','money','smallmoney','real') 
						THEN LEFT(CAST(CAST(RNDVALUE * 1000000.999 AS decimal(18,2)) AS varchar(MAX)),@maxLength)
						WHEN @sqlDatatype in ('binary','varbinary') 
						THEN ISNULL(@encloseStringsWithQuoteChar,'') + LEFT('0x546869732069732044756D6D792044617461',@maxLength) + ISNULL(@encloseStringsWithQuoteChar,'')
						WHEN @sqlDatatype In ('varchar','char','text') 
						THEN ISNULL(@encloseStringsWithQuoteChar,'') + dbo.fnRandomString(1,@maxLength) + ISNULL(@encloseStringsWithQuoteChar,'')
						WHEN @sqlDatatype In ('nchar','nvarchar','ntext') 
						THEN ISNULL(@encloseStringsWithQuoteChar,'') + dbo.fnRandomString(1,@maxLength / 2) + ISNULL(@encloseStringsWithQuoteChar,'')
						WHEN @sqlDatatype in('date','time','datetime','datetime2','smalldatetime','datetimeoffset')
						THEN ISNULL(@encloseStringsWithQuoteChar,'') + CONVERT(varchar(50),dateadd(D,ROUND(RNDVALUE * 1000,1),GETDATE()),121) + ISNULL(@encloseStringsWithQuoteChar,'')
						WHEN @sqlDatatype in ('uniqueidentifier') 
						THEN ISNULL(@encloseStringsWithQuoteChar,'') + CAST(NEWIDVALUE AS varchar(33)) + ISNULL(@encloseStringsWithQuoteChar,'')
						ELSE ''
					END
			FROM	V_RAND_NEWID
		END

	RETURN @retVal
END