/*
Ritorna l'anno corrente in forma di stringa a 4 caratteri

Esempio:

SELECT  dbo.CurrentYear() AS CY
*/
ALTER FUNCTION dbo.CurrentYear()
RETURNS varchar(4)
AS
BEGIN
	RETURN CAST(YEAR(GETDATE()) AS varchar(4))
END
GO

/*
Ritorna il mese corrente in forma di stringa a 2 caratteri riempita con zero quando il mese è inferiore a 10

Esempio:

SELECT  dbo.CurrentMonth() AS CM
*/
ALTER FUNCTION dbo.CurrentMonth()
RETURNS varchar(2)
AS
BEGIN
	RETURN dbo.PadLeft(CAST(MONTH(GETDATE()) AS varchar(2)),NULL,NULL)
END
GO

/*
Ritorna il giorno corrente in forma di stringa a 2 caratteri riempita con zero quando il giorno è inferiore a 10

Esempio:

SELECT  dbo.CurrentDay() AS CD
*/
ALTER FUNCTION dbo.CurrentDay()
RETURNS varchar(2)
AS
BEGIN
	RETURN dbo.PadLeft(CAST(DAY(GETDATE()) AS varchar(2)),NULL,NULL)
END
GO

/*
Ritorna l'ora corrente in forma di stringa a 2 caratteri riempita con zero quando l'ora è inferiore a 10

Esempio:

SELECT  dbo.CurrentHour() AS CH
*/
ALTER FUNCTION dbo.CurrentHour()
RETURNS varchar(2)
AS
BEGIN
	RETURN dbo.PadLeft(CAST(DATEPART(HOUR, GETDATE()) AS varchar(2)),NULL,NULL)
END
GO

/*
Ritorna il minuto corrente in forma di stringa a 2 caratteri riempita con zero quando l'ora è inferiore a 10

Esempio:

SELECT  dbo.CurrentMinute() AS CMN
*/
ALTER FUNCTION dbo.CurrentMinute()
RETURNS varchar(2)
AS
BEGIN
	RETURN dbo.PadLeft(CAST(DATEPART(MINUTE, GETDATE()) AS varchar(2)),NULL,NULL)
END
GO

/*
Ritorna il secondo corrente in forma di stringa a 2 caratteri riempita con zero quando l'ora è inferiore a 10

Esempio:

SELECT  dbo.CurrentSecond() AS CS
*/
ALTER FUNCTION dbo.CurrentSecond()
RETURNS varchar(2)
AS
BEGIN
	RETURN dbo.PadLeft(CAST(DATEPART(SECOND, GETDATE()) AS varchar(2)),NULL,NULL)
END
GO

/*
Ritorna l'anno, il mese e il giorno correnti in forma di stringa a 10 caratteri dove il mese e il giorno sono riempiti con uno zero quando questi siano inferiori a 10
Se viene specificato un carattere per il parametro @sep, questo verrà utilizzato come separatore tra l'anno, il mese e il giorno

Esempio:

SELECT  dbo.CurrentYMD(NULL) AS CYMD
SELECT  dbo.CurrentYMD('/') AS CYMD
SELECT  dbo.CurrentYMD('-') AS CYMD
SELECT  dbo.CurrentYMD('_') AS CYMD
SELECT  dbo.CurrentYMD(',') AS CYMD
SELECT  dbo.CurrentYMD('.') AS CYMD
*/
ALTER FUNCTION dbo.CurrentYMD(@sep varchar(1) = NULL)
RETURNS varchar(10)
AS
BEGIN
	RETURN dbo.CurrentYear() + ISNULL(@sep,'') + dbo.CurrentMonth()	+ ISNULL(@sep,'') + dbo.CurrentDay()
END
GO

/*
Ritorna il giorno, il mese e l'anno  correnti in forma di stringa a 10 caratteri dove il mese e il giorno sono riempiti con uno zero quando questi siano inferiori a 10
Se viene specificato un carattere per il parametro @sep, questo verrà utilizzato come separatore tra il giorno, il mese e l'anno

Esempio:

SELECT  dbo.CurrentDMY(NULL) AS CDMY
SELECT  dbo.CurrentDMY('/') AS CDMY
SELECT  dbo.CurrentDMY('-') AS CDMY
SELECT  dbo.CurrentDMY('_') AS CDMY
SELECT  dbo.CurrentDMY(',') AS CDMY
SELECT  dbo.CurrentDMY('.') AS CDMY
*/
CREATE FUNCTION dbo.CurrentDMY(@sep varchar(1) = NULL)
RETURNS varchar(10)
AS
BEGIN
	RETURN dbo.CurrentDay() + ISNULL(@sep,'') + dbo.CurrentMonth()	+ ISNULL(@sep,'') + dbo.CurrentYear() 
END
GO

/*
Ritorna l'ora e il minuto correnti in forma di stringa a 5 caratteri dove l'ora e il minuto sono riempiti con uno zero quando questi siano inferiori a 10
Se viene specificato un carattere per il parametro @sep, questo verrà utilizzato come separatore tra l'ora e il minuto

Esempio:

SELECT  dbo.CurrentHM(NULL) AS CHM
SELECT  dbo.CurrentHM('_') AS CHM
SELECT  dbo.CurrentHM(':') AS CHM
SELECT  dbo.CurrentHM('.') AS CHM
*/
ALTER FUNCTION dbo.CurrentHM(@sep varchar(1) = NULL)
RETURNS varchar(5)
AS
BEGIN
	RETURN dbo.CurrentHour() + ISNULL(@sep,'') + dbo.CurrentMinute()
END
GO

/*
Ritorna l'ora, il minuto e il secondo correnti in forma di stringa a 8 caratteri dove l'ora, il minuto e il secondo sono riempiti con uno zero quando questi siano inferiori a 10
Se viene specificato un carattere per il parametro @sep, questo verrà utilizzato come separatore tra l'ora, il minuto e il secondo

Esempio:

SELECT  dbo.CurrentHMS(NULL) AS CHMS
SELECT  dbo.CurrentHMS('_') AS CHMS
SELECT  dbo.CurrentHMS(':') AS CHMS
SELECT  dbo.CurrentHMS('.') AS CHMS
*/
ALTER FUNCTION dbo.CurrentHMS(@sep varchar(1) = NULL)
RETURNS varchar(8)
AS
BEGIN
	RETURN dbo.CurrentHour() + ISNULL(@sep,'') + dbo.CurrentMinute() + ISNULL(@sep,'') + dbo.CurrentSecond()
END
GO

/*
Ritorna l'anno e il mese correnti in forma di stringa a 7 caratteri dove il mese è riempito con uno zero quando questo è inferiore a 10
Se viene specificato un carattere per il parametro @sep, questo verrà utilizzato come separatore tra l'anno e il mese

Esempio:

SELECT  dbo.CurrentYM(NULL) AS CYM
SELECT  dbo.CurrentYM('-') AS CYM
SELECT  dbo.CurrentYM('/') AS CYM
SELECT  dbo.CurrentYM('_') AS CYM
SELECT  dbo.CurrentYM(',') AS CYM
SELECT  dbo.CurrentYM('.') AS CYM
*/
ALTER FUNCTION dbo.CurrentYM(@sep varchar(1) = NULL)
RETURNS varchar(7)
AS
BEGIN
	RETURN dbo.CurrentYear() + ISNULL(@sep,'') + dbo.CurrentMonth()
END
GO

/*
Ritorna il mese e il giorno correnti in forma di stringa a 7 caratteri dove sia il mese che il giorno è riempito con uno zero quando questo è inferiore a 10
Se viene specificato un carattere per il parametro @sep, questo verrà utilizzato come separatore tra il mese e il giorno

Esempio:

SELECT  dbo.CurrentMD(NULL) AS CYM
SELECT  dbo.CurrentMD('-') AS CYM
SELECT  dbo.CurrentMD('/') AS CYM
SELECT  dbo.CurrentMD('_') AS CYM
SELECT  dbo.CurrentMD(',') AS CYM
*/
ALTER FUNCTION dbo.CurrentMD(@sep varchar(1) = NULL)
RETURNS varchar(7)
AS
BEGIN
	RETURN dbo.CurrentMonth() + ISNULL(@sep,'') + dbo.CurrentDay()
END
GO

/*
Ritorna data ed ora correnti, in forma YMD riempiendo con uno zero il mese, il giorno, l'ora, il minuto e il secondo qualora uno di questi sia inferiore a 10
Se viene specificato un carattere per il parametro @sep, questo verrà utilizzato come separatore tra la data (Anno, Mese, Giorno) e l'orario (Ore, Minuti, Secondi)
Se viene specificato un carattere per il parametro @sepYMD, questo verrà utilizzato come separatore tra gli elementi della data (Anno, Mese, Giorno)
Se viene specificato un carattere per il parametro @sepHMS, questo verrà utilizzato come separatore tra gli elementi dell'orario (Ore, Minuti, Secondi)

Esempio:

SELECT  dbo.Now(NULL,NULL,NULL) AS NOW -- ritorna una stringa del tipo "20171212105607"
SELECT  dbo.Now('_',NULL,NULL) AS NOW -- ritorna una stringa del tipo "20171212_105537"
SELECT  dbo.Now('T','-',':') AS NOW	-- ritorna una stringa del tipo "2017-12-12T10:53:24"
*/
ALTER FUNCTION dbo.Now(@sep varchar(1) = NULL, @sepYMD varchar(1) = NULL, @sepHMS varchar(1) = NULL)
RETURNS varchar(19)
AS
BEGIN
	RETURN dbo.CurrentYMD(@sepYMD) + ISNULL(@sep,'') + dbo.CurrentHMS(@sepHMS)
END
GO

/*
Ritorna data ed ora correnti, in forma DMY, riempiendo con uno zero il mese, il giorno, l'ora, il minuto e il secondo qualora uno di questi sia inferiore a 10
Se viene specificato un carattere per il parametro @sep, questo verrà utilizzato come separatore tra la data (Giorno, Mese, Anno) e l'orario (Ore, Minuti, Secondi)
Se viene specificato un carattere per il parametro @sepYMD, questo verrà utilizzato come separatore tra gli elementi della data (Giorno, Mese, Anno)
Se viene specificato un carattere per il parametro @sepHMS, questo verrà utilizzato come separatore tra gli elementi dell'orario (Ore, Minuti, Secondi)

Esempio:

SELECT  dbo.NowIT(NULL,NULL,NULL) AS NOW -- ritorna una stringa del tipo "12122017110954"
SELECT  dbo.NowIT('_',NULL,NULL) AS NOW -- ritorna una stringa del tipo "12122017_110948"
SELECT  dbo.NowIT('T','-',':') AS NOW -- ritorna una stringa del tipo "12-12-2017T11:09:33"
SELECT  dbo.NowIT(' ','/',':') AS NOW -- ritorna una stringa del tipo "12/12/2017 11:09:20"
*/
ALTER FUNCTION dbo.NowIT(@sep varchar(1) = NULL, @sepYMD varchar(1) = NULL, @sepHMS varchar(1) = NULL)
RETURNS varchar(19)
AS
BEGIN
	RETURN dbo.CurrentDMY(@sepYMD) + ISNULL(@sep,'') + dbo.CurrentHMS(@sepHMS)
END
GO

/*
Ritorna data ed ora correnti, in forma YMD, riempiendo con uno zero il mese, il giorno, l'ora e il minuto qualora uno di questi sia inferiore a 10
Se viene specificato un carattere per il parametro @sep, questo verrà utilizzato come separatore tra la data (Anno, Mese, Giorno) e l'orario (Ore, Minuti)
Se viene specificato un carattere per il parametro @sepYMD, questo verrà utilizzato come separatore tra gli elementi della data (Anno, Mese, Giorno)
Se viene specificato un carattere per il parametro @sepHM, questo verrà utilizzato come separatore tra gli elementi dell'orario (Ore, Minuti)

Esempio:

SELECT  dbo.Nowsmall(NULL,NULL,NULL) AS NOW -- ritorna una stringa del tipo "201712121056"
SELECT  dbo.Nowsmall('_',NULL,NULL) AS NOW -- ritorna una stringa del tipo "20171212_1055"
SELECT  dbo.Nowsmall('T','-',':') AS NOW	-- ritorna una stringa del tipo "2017-12-12T10:53"
*/
CREATE FUNCTION dbo.Nowsmall(@sep varchar(1) = NULL, @sepYMD varchar(1) = NULL, @sepHM varchar(1) = NULL)
RETURNS varchar(19)
AS
BEGIN
	RETURN dbo.CurrentYMD(@sepYMD) + ISNULL(@sep,'') + dbo.CurrentHM(@sepHM)
END
GO

/*
Ritorna data ed ora correnti, in forma DMY, riempiendo con uno zero il mese, il giorno, l'ora e il minuto qualora uno di questi sia inferiore a 10
Se viene specificato un carattere per il parametro @sep, questo verrà utilizzato come separatore tra la data (Giorno, Mese, Anno) e l'orario (Ore, Minuti)
Se viene specificato un carattere per il parametro @sepYMD, questo verrà utilizzato come separatore tra gli elementi della data (Giorno, Mese, Anno)
Se viene specificato un carattere per il parametro @sepHM, questo verrà utilizzato come separatore tra gli elementi dell'orario (Ore, Minuti)

Esempio:

SELECT  dbo.NowITsmall(NULL,NULL,NULL) AS NOW -- ritorna una stringa del tipo ""
SELECT  dbo.NowITsmall('_',NULL,NULL) AS NOW -- ritorna una stringa del tipo ""
SELECT  dbo.Nowitsmall(' ','/',':') AS NOW	-- ritorna una stringa del tipo ""
*/
ALTER FUNCTION dbo.NowITsmall(@sep varchar(1) = NULL, @sepYMD varchar(1) = NULL, @sepHM varchar(1) = NULL)
RETURNS varchar(19)
AS
BEGIN
	RETURN dbo.CurrentDMY(@sepYMD) + ISNULL(@sep,'') + dbo.CurrentHM(@sepHM)
END
GO
