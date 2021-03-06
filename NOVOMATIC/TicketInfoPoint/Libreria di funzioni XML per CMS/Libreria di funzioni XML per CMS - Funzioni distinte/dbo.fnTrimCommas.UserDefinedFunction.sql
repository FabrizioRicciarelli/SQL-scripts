USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnTrimCommas]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnTrimCommas
----------------------------------------

FUNZIONE CHE RIMUOVE QUALUNQUE PUNTEGGIATURA CHE SI TROVI ALL'INIZIO E/O ALLA FINE DELLA STRINGA PASSATA. TRA I CARATTERI CHE SARANNO RIMOSSI 
E' COMPRESO IL RITORNO-CARRELLO

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnTrimCommas('Stringa terminante per virgola spazio, ')
SELECT dbo.fnTrimCommas(' .Stringa iniziante per spazio punto')
SELECT dbo.fnTrimCommas('Stringa terminante per tre punti...')
SELECT dbo.fnTrimCommas(',,,,,Stringa iniziante per cinque virgole, '+CHAR(13)+CHAR(13))
*/
CREATE FUNCTION	[dbo].[fnTrimCommas](@stringToTrim varchar(MAX))
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE 
			@RETVAL varchar(MAX)
	
	SET @RETVAL = @stringToTrim

	IF ISNULL(@stringToTrim,'') != ''
		BEGIN
			SET @RETVAL = LTRIM(RTRIM(@stringToTrim))
			WHILE (RIGHT(@RETVAL,1) IN (',','.',';',':',' ',CHAR(13)) OR LEFT(@RETVAL,1) IN (',','.',';',':',' ',CHAR(13)))
				BEGIN
					SET @RETVAL =
						CASE
							WHEN RIGHT(@RETVAL,1) IN (',','.',';',':',' ',CHAR(13))
							THEN LEFT(@RETVAL,LEN(@RETVAL)-1)
							WHEN LEFT(@RETVAL,1) IN (',','.',';',':',' ',CHAR(13))
							THEN RIGHT(@RETVAL,LEN(@RETVAL)-1)
						END
				END
		END
	
	RETURN @RETVAL
END
GO
