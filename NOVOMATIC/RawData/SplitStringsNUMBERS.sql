/*
Funzione preposta alla trasformazione di un elenco di valori separati da un delimitatore
(una virgola di default) in una tabella.

*** Attenzione!!! Questa funzione presuppone l'esistenza di una tabella dbo.Numbers che potrà essere creata
delle dimensioni idonee alle proprie esigenze attraverso il codice seguente:

-------------------------------
DECLARE @UpperLimit INT = 1000000; -- <<< Modificare questo valore (attualmente pari ad un milione) per adattarlo a specifiche esigenze
 
WITH n AS
(
    SELECT	x = 
			ROW_NUMBER() OVER (ORDER BY s1.[object_id])
    FROM    sys.all_objects AS s1
			CROSS JOIN 
			sys.all_objects AS s2
			CROSS JOIN 
			sys.all_objects AS s3
)
SELECT	Number = x
INTO	dbo.Numbers
FROM	n
WHERE	(x BETWEEN 1 AND @UpperLimit);
 
GO
CREATE UNIQUE CLUSTERED INDEX n ON dbo.Numbers(Number) 
WITH (DATA_COMPRESSION = PAGE);
GO
-------------------------------

Esempi di invocazione:

SELECT * FROM dbo.SplitStringsNUMBERS(N'Patriots,Red Sox,Bruins', DEFAULT)
*/
ALTER FUNCTION dbo.SplitStringsNUMBERS
				(
				   @List       NVARCHAR(MAX) = NULL,
				   @Delimiter  NVARCHAR(255) = N','
				)
RETURNS TABLE
WITH SCHEMABINDING
AS
	RETURN
	(
		SELECT	Item = 
				SUBSTRING
					(
						@List
						,Number
						,CHARINDEX
						(
							@Delimiter
							,@List + @Delimiter
							,Number
						) - Number
					)
		FROM	dbo.Numbers
		WHERE	Number <= CONVERT(INT, LEN(@List))
		AND		SUBSTRING(@Delimiter + @List, Number, LEN(@Delimiter)) = @Delimiter
   );
GO