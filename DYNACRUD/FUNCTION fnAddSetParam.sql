/*
---------------------------------------------------------------------------------------------
FUNZIONE PREPOSTA ALLA ELENCAZIONE DI UN INSIEME DI "SET" DI NOMI DI CAMPO PER LA 
CREAZIONE DI UNO STATEMENT DI UPDATE
---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------
Esempi di invocazione:

PRINT(dbo.fnAddSetParam('UPDATE ADDIZIONALE_COMUNALE_DETT', 'CFCreditore', 'RCCFRZ67P13F611D','STR'))
PRINT(dbo.fnAddSetParam('UPDATE ADDIZIONALE_COMUNALE_DETT', 'CFCreditore', 'RCCFRZ67P13F611D','VARCHAR'))
PRINT(dbo.fnAddSetParam('UPDATE ADDIZIONALE_COMUNALE_DETT SET CFCreditore = ''RCCFRZ67P13F611D''', 'ImportoAcconto', '140.21', 'INT'))
PRINT(dbo.fnAddSetParam('UPDATE ADDIZIONALE_COMUNALE_DETT SET CFCreditore = ''RCCFRZ67P13F611D'', ImportoAcconto = 140.21', 'DataInserimento', '2015-10-11 17:35:44', 'DAT'))
*/
ALTER FUNCTION	[dbo].[fnAddSetParam](@SQLbase varchar(MAX), @fieldName varchar(128), @fieldValue varchar(128), @fieldType varchar(20))
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @retVal varchar(MAX)
	SET @retVal = ISNULL(@SQLbase,'')

	IF ISNULL(@SQLbase,'') != ''
	AND ISNULL(@fieldName,'') != ''
	AND ISNULL(@fieldValue,'') != ''
		BEGIN
			SET @fieldType = UPPER(@fieldType)

			IF @SQLbase NOT LIKE '%SET%'
				BEGIN
					SET @retVal = @SQLbase + CHAR(13) + 'SET '
				END
			ELSE
				BEGIN
					SET @retVal = @SQLbase + ', '
				END
			SET @retVal = @retVal + @fieldName + ' = '

			IF @fieldType = 'BIT'
				BEGIN
					SET @retVal = @retVal + CONVERT(varchar(1),@fieldValue)
				END
			IF @fieldType = 'INT'
				BEGIN
					SET @retVal = @retVal + CONVERT(varchar(9),@fieldValue)
				END
			IF @fieldType IN ('BIG','BIGINT') -- BigInt
				BEGIN
					SET @retVal = @retVal + CONVERT(varchar(16),@fieldValue)
				END
			IF @fieldType IN ('DEC','DECIMAL') -- Decimal(18,2)
				BEGIN
					SET @retVal = @retVal + CONVERT(varchar(21),@fieldValue)
				END
			IF @fieldType IN ('DAT','DATETIME') -- DateTime
				BEGIN
					SET @retVal = @retVal + '''' + CONVERT(varchar(26),@fieldValue) + ''''
				END
			IF @fieldType IN ('STR','CHAR','VARCHAR') -- Char, Varchar
				BEGIN
					SET @retVal = @retVal + '''' + @fieldValue + ''''
				END

		END

	RETURN @retVal
END
