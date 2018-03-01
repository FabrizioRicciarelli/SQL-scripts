/*
*/
ALTER FUNCTION ETL.BuildDynSQL_XmlWrapper(@INNERSQL Nvarchar(MAX), @XmlRawName sysname)
RETURNS NVarchar(MAX)
AS
BEGIN
	DECLARE 
			@retVal Nvarchar(MAX)
	SET @retVal = 
			CASE	
				WHEN	@@SERVERNAME LIKE '%DEV%' -- DETERMINA L'AMBIENTE SUL QUALE E' IN ESECUZIONE LA CORRENTE STORED PROCEDURE
				THEN	N'SELECT @returnValue = CAST((SELECT * FROM OPENQUERY([POM-MON01],'''+ REPLACE(@INNERSQL,'''','''''') +''') FOR XML RAW(''' + @XmlRawName + '''),TYPE) AS Nvarchar(MAX))' -- QUERY PER ESECUZIONE IN AMBIENTE DI SVILUPPO  
				ELSE	N'SELECT @returnValue = CAST((' + @INNERSQL + ' FOR XML RAW(''' + @XmlRawName + '''),TYPE) AS Nvarchar(MAX))' -- QUERY PER ESECUZIONE IN AMBIENTE DI PRODUZIONE
			END
	RETURN @retVal
END