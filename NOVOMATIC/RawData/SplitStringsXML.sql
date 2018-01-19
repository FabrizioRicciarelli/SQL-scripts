/*
Funzione preposta alla trasformazione di un elenco di valori separati da un delimitatore
(una virgola di default) in una tabella.

*** Attenzione!!! Un elenco di valori i cui contenuti prevedano la presenza di caratteri tipici del linguaggio XML
potrebbe creare qualche anomalia.

Esempi di invocazione:

SELECT * FROM dbo.SplitStringsXML(N'Patriots,Red Sox,Bruins', DEFAULT)
*/
ALTER FUNCTION	dbo.SplitStringsXML
				(
				   @List       NVARCHAR(MAX) = NULL,
				   @Delimiter  NVARCHAR(255) = N','
				)
RETURNS TABLE
WITH SCHEMABINDING
AS
	RETURN 
	(  
		SELECT	Item = 
				y.i.value('(./text())[1]', 'nvarchar(4000)')
		FROM 
		( 
			SELECT	x = 
					CONVERT
					(
						XML
						,'<i>' + 
						REPLACE
						(
							@List
							,@Delimiter
							,'</i><i>'
						) + 
						'</i>'
					).query('.')
		)	A
			CROSS APPLY 
			x.nodes('i') AS y(i)
	);
GO
