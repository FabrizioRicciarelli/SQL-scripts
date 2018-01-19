/*
----------------------------------------
dbo.fnLeftPart
----------------------------------------

FUNZIONE CHE RITORNA LA PORZIONE DI STRINGA CHE SI TROVA ALLA SINISTRA DEL DELIMITATORE SPECIFICATO

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnLeftPart('added nvarchar(max)',' ') AS LEFTPART
SELECT dbo.fnLeftPart('dbo.VSN_TestoConImmagine','.dbo') AS LEFTPART
SELECT dbo.fnLeftPart('Intranetinps_Richieste.dbo.VSN_Link','.dbo') AS LEFTPART
SELECT dbo.fnLeftPart('Intranetinps_Lavoro.IntranetInps.dirforupload_appo','.IntranetInps') AS LEFTPART
*/
CREATE FUNCTION [dbo].[fnLeftPart](@str varchar(MAX) = NULL, @what varchar(MAX))
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @RETVAL varchar(MAX) = NULL

	SELECT	@RETVAL =
			CASE
				WHEN @str IS NOT NULL
				AND @what IS NOT NULL
				AND dbo.fnCountStringOccurrences(@str,@what) > 0
				THEN SUBSTRING(@str, 1, CHARINDEX(@what,@str) - 1)
				ELSE @str
			END

	RETURN @RETVAL
END
