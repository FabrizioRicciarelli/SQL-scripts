USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnTrimSeparator]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnTrimSeparator
----------------------------------------

FUNZIONE CHE RIMUOVE OGNI OCCORRENZA DEL CARATTERE SPECIFICATO NEL PARAMETRO "@separator" CHE SI TROVI ALL'INIZIO E/O ALLA FINE DELLA STRINGA PASSATA. 
TRA I CARATTERI CHE SARANNO RIMOSSI *NON* E' COMPRESO IL RITORNO-CARRELLO

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnTrimSeparator('Stringa terminante per virgola,', NULL)
SELECT dbo.fnTrimSeparator('Stringa terminante per virgola,', ',')
SELECT dbo.fnTrimSeparator(',,,,,Stringa iniziante per cinque virgole,',',')

SELECT dbo.fnTrimSeparator('.Stringa iniziante per punto', '.')
SELECT dbo.fnTrimSeparator('Stringa terminante per tre punti...', '.')
SELECT dbo.fnTrimSeparator('#Stringa tra #HashTags#','#')
*/
CREATE FUNCTION	[dbo].[fnTrimSeparator](@stringToTrim varchar(MAX)=NULL,@separator char(1)=NULL)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE 
			@RETVAL varchar(MAX)
	
	SET @RETVAL = @stringToTrim
	SET @separator = ISNULL(@separator,',')

	IF ISNULL(@stringToTrim,'') != ''
		BEGIN
			SET @RETVAL = LTRIM(RTRIM(@stringToTrim))
			WHILE (RIGHT(@RETVAL,1) = @separator OR LEFT(@RETVAL,1) = @separator)
				BEGIN
					SET @RETVAL =
						CASE
							WHEN RIGHT(@RETVAL,1) = @separator
							THEN LEFT(@RETVAL,LEN(@RETVAL)-1)
							WHEN LEFT(@RETVAL,1) = @separator
							THEN RIGHT(@RETVAL,LEN(@RETVAL)-1)
						END
				END
		END
	
	RETURN @RETVAL
END
GO
