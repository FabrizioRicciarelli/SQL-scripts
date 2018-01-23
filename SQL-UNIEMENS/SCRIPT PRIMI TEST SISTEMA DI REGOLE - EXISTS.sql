DECLARE	
		@CFAzienda varchar(16) = '00937610152'
		,@CFLavoratore varchar(16) = 'BBTCLR54C68Z114Q'
		,@PeriodoCompetenza varchar(10) = '2013-12-01'
		,@PATTERN nvarchar(MAX)

DECLARE	@RULES TABLE
		(
			NodoDaConfrontare varchar(128)
			,ValoreDaConfrontare varchar(50)
			,XMLdata XML
		)

INSERT	@RULES
		(
					NodoDaConfrontare
					,ValoreDaConfrontare
					,XMLdata
		)
SELECT	
		'../../CodiceRetribuzione' AS NodoDaConfrontare
		,'RN' AS ValoreDaConfrontare
		,dbo.fnGetXMLcontr(@CFAzienda, @CFLavoratore, @PeriodoCompetenza) AS XMLdata

SELECT	@PATTERN = N'[' + NodoDaConfrontare + ' = sql:column("ValoreDaConfrontare")]'
FROM	@RULES

PRINT @PATTERN
/*
SELECT	
		NodoDaConfrontare
		,ValoreDaConfrontare
		,XMLdata
FROM	@RULES
WHERE	XMLdata.exist(@PATTERN) = 1 
*/