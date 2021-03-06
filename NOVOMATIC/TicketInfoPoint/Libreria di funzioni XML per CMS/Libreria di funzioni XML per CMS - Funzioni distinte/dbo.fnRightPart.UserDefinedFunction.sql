USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnRightPart]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnRightPart
----------------------------------------

FUNZIONE CHE RITORNA LA PORZIONE DI STRINGA CHE SI TROVA ALLA DESTRA DEL DELIMITATORE SPECIFICATO

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnRightPart('Intranetinps_Richieste.dbo.VSN_Link','dbo.') AS RIGHTPART
SELECT dbo.fnRightPart('Intranetinps_Lavoro.IntranetInps.dirforupload_appo','IntranetInps.') AS RIGHTPART
*/
CREATE FUNCTION [dbo].[fnRightPart](@str varchar(MAX) = NULL, @what varchar(MAX))
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @RETVAL varchar(MAX) = NULL

	SELECT	@RETVAL =
			CASE
				WHEN @str IS NOT NULL
				AND @what IS NOT NULL
				AND dbo.fnCountStringOccurrences(@str,@what) > 0
				THEN SUBSTRING(@str, CHARINDEX(@what,@str) + LEN(@what), LEN(@str)-LEN(CHARINDEX(@what,@str)- 1))
				ELSE @str
			END

	RETURN @RETVAL
END

GO
