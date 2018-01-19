/*
Funzione preposta alla trasformazione di un elenco di valori separati da un delimitatore
(una virgola di default) in una tabella.

*** Attenzione!!! Un elenco di valori le cui dimensioni della stringa siano al di sopra degli 8000 caratteri
potrebbe creare qualche anomalia.

Esempi di invocazione:

SELECT * FROM dbo.SplitStrings8000(N'Patriots,Red Sox,Bruins', DEFAULT)
*/
ALTER FUNCTION dbo.SplitStrings8000
				(
				   @List NVARCHAR(MAX) = NULL,
				   @Delimiter NVARCHAR(255) = N','
				)
RETURNS TABLE
WITH SCHEMABINDING 
AS
RETURN
	WITH E1(N) AS 
	( 
		SELECT 1 
		UNION ALL 
		SELECT 1 
		UNION ALL 
		SELECT 1 
		UNION ALL 
		SELECT 1 
		UNION ALL 
		SELECT 1 
		UNION ALL 
		SELECT 1 
		UNION ALL 
		SELECT 1 
		UNION ALL 
		SELECT 1 
		UNION ALL 
		SELECT 1 
		UNION ALL 
		SELECT 1
	)
	,E2(N) AS 
	(
		SELECT	1 
		FROM	E1 a
				,E1 b
	)
	,E4(N) AS 
	(
		SELECT	1 
		FROM	E2 a
				,E2 b
	)
	,E42(N) AS 
	(
		SELECT	1 
		FROM	E4 a
				,E2 b
	)
	,cteTally(N) AS 
	(
		SELECT	0 
		UNION ALL 
		SELECT	TOP(DATALENGTH(ISNULL(@List,1))) 
				ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) 
		FROM E42
	)
	,cteStart(N1) AS 
	(
		SELECT	t.N + 1 
		FROM	cteTally t
		WHERE	(SUBSTRING(@List,t.N,1) = @Delimiter OR t.N = 0)
	)

	SELECT	Item = 
			SUBSTRING
			(
				@List
				,s.N1
				,ISNULL
				(
					NULLIF
					(
						CHARINDEX
						(
							@Delimiter
							,@List
							,s.N1
						)
						,0
					) - s.N1
					,8000
				)
			)
	FROM	cteStart s;
