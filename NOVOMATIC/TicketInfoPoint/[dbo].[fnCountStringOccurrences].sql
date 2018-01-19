/*
----------------------------------------
dbo.fnCountStringOccurrences
----------------------------------------
FUNZIONE CHE EFFETTUA IL CONTEGGIO, ALL'INTERNO DELLA STRINGA PASSATA NEL PARAMETRO "@string" DELLE OCCORRENZE CORRISPONDENTI AL VALORE
SPECIFICATO NEL PARAMETRO "@charToCount"

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnCountStringOccurrences('added nvarchar(max)',' ') AS Occorrenze
SELECT dbo.fnCountStringOccurrences('Intranetinps_Lavoro.IntranetInps.dirforupload_appo','dbo.') AS Occorrenze
*/
CREATE FUNCTION [dbo].[fnCountStringOccurrences](@string varchar(MAX), @charToCount varchar(128))
RETURNS int 
AS
BEGIN
	DECLARE @RETVAL int
		IF @string IS NOT NULL
		AND @charToCount IS NOT NULL
			BEGIN
				SELECT @RETVAL = LEN(@string) - LEN(REPLACE(@string, @charToCount, ''))
			END
	RETURN @RETVAL
END
