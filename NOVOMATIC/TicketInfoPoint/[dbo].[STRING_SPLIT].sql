/*
----------------------------------------
dbo.STRING_SPLIT
Equivalente della funzione SPLIT_STRING 
disponibile nei server SQL 2016+
----------------------------------------

FUNZIONE PREPOSTA ALLA TRASFORMAZIONE DI UN ELENCO CSV (COMMA SEPARATED VALUES) IN UNA TABELLA 
DOVE CIASCUNA RIGA CONTIENE CIASCUN ELEMENTO DELL’ELENCO

-- ESEMPI DI INVOCAZIONE

SELECT * FROM dbo.STRING_SPLIT('Pippo, Pluto, Paperino', ',')
SELECT * FROM dbo.STRING_SPLIT('Pippo, Pluto, Paperino', NULL)
*/
ALTER FUNCTION [dbo].[STRING_SPLIT]
(
   @List       NVARCHAR(MAX),
   @Delimiter  NVARCHAR(255) = NULL
)
RETURNS TABLE
WITH SCHEMABINDING
AS
   RETURN 
   (  
      SELECT Value = LTRIM(RTRIM(y.i.value('(./text())[1]', 'nvarchar(MAX)')))
      FROM 
      ( 
        SELECT x = CONVERT(XML, '<i>' 
          + REPLACE(@List, ISNULL(@Delimiter,','), '</i><i>') 
          + '</i>').query('.')
      ) AS a CROSS APPLY x.nodes('i') AS y(i)
   );

