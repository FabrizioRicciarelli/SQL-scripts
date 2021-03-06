USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnSplit]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnSplit
----------------------------------------

FUNZIONE PREPOSTA ALLA TRASFORMAZIONE DI UN ELENCO CSV (COMMA SEPARATED VALUES) IN UNA TABELLA 
DOVE CIASCUNA RIGA CONTIENE CIASCUN ELEMENTO DELL’ELENCO

-- ESEMPI DI INVOCAZIONE

SELECT * FROM dbo.fnSplit('Pippo, Pluto, Paperino', ',')
SELECT * FROM dbo.fnSplit('Pippo, Pluto, Paperino', NULL)
*/
CREATE FUNCTION [dbo].[fnSplit]
(
   @List       NVARCHAR(MAX),
   @Delimiter  NVARCHAR(255) = NULL
)
RETURNS TABLE
WITH SCHEMABINDING
AS
   RETURN 
   (  
      SELECT Item = LTRIM(RTRIM(y.i.value('(./text())[1]', 'nvarchar(4000)')))
      FROM 
      ( 
        SELECT x = CONVERT(XML, '<i>' 
          + REPLACE(@List, ISNULL(@Delimiter,','), '</i><i>') 
          + '</i>').query('.')
      ) AS a CROSS APPLY x.nodes('i') AS y(i)
   );

GO
