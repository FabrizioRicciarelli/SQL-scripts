USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnMiddlePart]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnMiddlePart
----------------------------------------

FUNZIONE CHE RITORNA LA PORZIONE DI STRINGA CHE SI TROVA IN MEZZO A DUE OCCORRENZE DEL DELIMITATORE SPECIFICATO

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnMiddlePart('Intranetinps_Richieste.dbo.VSN_Link','.') AS MIDDLEPART
SELECT dbo.fnMiddlePart('Intranetinps_Lavoro.IntranetInps.dirforupload_appo','.') AS MIDDLEPART
*/
CREATE FUNCTION [dbo].[fnMiddlePart](@str varchar(MAX) = NULL, @what varchar(MAX))
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE 
			@RETVAL varchar(MAX) = NULL
			,@FIRSTPOS int
			,@LASTPOS int
			,@WIDTH int

	IF ISNULL(@str,'') != ''
	AND ISNULL(@what,'') != ''
	AND dbo.fnCountStringOccurrences(@str,@what) = 2
		BEGIN
			SET @FIRSTPOS = CHARINDEX(@what, @str)
			SET @LASTPOS = CHARINDEX(@what, @str, @FIRSTPOS +1 )
			SET @WIDTH = @LASTPOS - @FIRSTPOS - 1

			SELECT	@RETVAL = 
					CASE
						WHEN @FIRSTPOS > 0
						AND @LASTPOS >= @FIRSTPOS
						AND @WIDTH > 0
						THEN SUBSTRING(@str, @FIRSTPOS + 1, @WIDTH)
						ELSE @str
					END
		END
	RETURN @RETVAL
END

GO
