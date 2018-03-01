/*
RICHIEDE LA PRESENZA DELLA SEGUENTE TABELLA:

CREATE TABLE ETL.LogConteggi (
	ConcessionaryID int
	,ConcessionaryName sysname
	,SystemDate datetime
	,ConteggioVLTAttive int
	,ConteggioElectronAttiviAncheConVLTNonCollegate int
	,ConteggioElectronConVLTCollegate int
)

L'INSERIMENTO PUO' AVVENIRE SOLO UNA VOLTA AL GIORNO. ELIMINARE LE RIGHE DI CIASCUNA 
GIORNATA - PER TUTTI I CONCESSIONARI - PER EFFETTUARE UN INSERIMENTO AGGIORNATO, 
COSI':

DELETE 
FROM	ETL.LogConteggi 
WHERE	YEAR(SystemDate) = YEAR(GETDATE()) 
AND		MONTH(SystemDate) = MONTH(GETDATE()) 
AND		DAY(SystemDate) = DAY(GETDATE())



-- ESEMPIO DI INVOCAZIONE:
--------------------------
EXEC ETL.GetConteggiCQI
SELECT	* FROM ETL.LogConteggi

*/
ALTER PROC [ETL].[GetConteggiCQI]
AS
SET XACT_ABORT ON; -- ATTIVARE (ON) PER ABILITARE LE TRANSAZIONI DISTRIBUITE
SET NOCOUNT ON;

DECLARE
		@ConcessionaryID tinyint = 7 -- (7 = GMATICA)

		,@OUTERMOSTSQL Nvarchar(MAX) -- DA ESEGUIRE SU QUESTA MACCHINA
		,@OUTERSQL Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA POM-MON01
		,@INNERSQL Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA PIN/CQI/FINANCE
		,@ConcessionaryName Nvarchar(20)

		,@STRINGcont Nvarchar(MAX) = NULL -- RISULTATI IN FORMA STRINGXML RITORNATI DALLE MACCHINE PIN/CQI/FINANCE
		,@XMLcont XML -- RISULTATI IN FORMA XML CONTENENTI TUTTI I CONTEGGI
		,@CONCESSIONARY_CUR CURSOR

DECLARE	@LogTable TABLE(
			ConcessionaryID int
			,ConcessionaryName sysname
			,SystemDate datetime
			,ConteggioVLTAttive int
			,ConteggioElectronAttiviAncheConVLTNonCollegate int
			,ConteggioElectronConVLTCollegate int
		)

SET @CONCESSIONARY_CUR = CURSOR FAST_FORWARD FOR 
SELECT	
		ConcessionarySK
		,ConcessionaryName 
FROM	[POM-MON01,1500].[AGS].[Type].[Concessionary]
WHERE	ConcessionaryName != 'Bplus' -- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<    *** COMMENTATO PERCHE' LA MACCHINA NON E' AL MOMENTO RAGGIUNGIBILE ***

OPEN @CONCESSIONARY_CUR;
FETCH NEXT FROM @CONCESSIONARY_CUR 
INTO 
		@ConcessionaryID
		,@ConcessionaryName
WHILE @@FETCH_STATUS = 0
	BEGIN
		-- DEFINIZIONE QUERY DA INVOCARE SU MACCHINE REMOTE
		SET @INNERSQL = ETL.BuildDynSQL_ConteggioInfo()

		SET		@INNERSQL = REPLACE(@INNERSQL, CHAR(39), CHAR(39)+CHAR(39))	-- rimpiazzo apici singoli con apici doppi per innesto query SQL dinamico
		SET		@OUTERSQL = N'SELECT * FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + @INNERSQL + ''')'
		SET		@OUTERMOSTSQL = N'SELECT @returnValue = CAST((SELECT * FROM OPENQUERY([POM-MON01,1500],'''+ REPLACE(@OUTERSQL,'''','''''') +''') FOR XML RAW(''CONTEGGI''),TYPE) AS Nvarchar(MAX))' -- QUERY PER ESECUZIONE IN AMBIENTE DI SVILUPPO  
		EXEC	sp_executesqL @OUTERMOSTSQL, N'@returnValue Nvarchar(MAX) OUT', @returnValue=@STRINGcont OUT
		SELECT	@XMLcont = CAST(@STRINGcont AS XML)

		INSERT	@LogTable
		SELECT
				@ConcessionaryID AS ConcessionaryID
				,@ConcessionaryName AS ConcessionaryName 
				,GETDATE() AS SystemDate
				,T.c.value('@ConteggioVLTAttive', 'int') AS ConteggioVLTAttive
				,T.c.value('@ConteggioElectronAttiviAncheConVLTNonCollegate', 'int') AS ConteggioElectronAttiviAncheConVLTNonCollegate
				,T.c.value('@ConteggioElectronConVLTCollegate', 'int') AS ConteggioElectronConVLTCollegate
		FROM	@XMLcont.nodes('CONTEGGI') AS T(c) 
		
		FETCH NEXT FROM @CONCESSIONARY_CUR 
		INTO 
			@ConcessionaryID
			,@ConcessionaryName
	END

CLOSE @CONCESSIONARY_CUR;
DEALLOCATE @CONCESSIONARY_CUR;

-- L'INSERIMENTO PUO' AVVENIRE SOLO UNA VOLTA AL GIORNO: 
-- LA JOIN TRA LE DUE TABELLE GARANTISCE QUESTO CRITERIO
INSERT	ETL.LogConteggi(
			ConcessionaryID
			,ConcessionaryName
			,SystemDate
			,ConteggioVLTAttive
			,ConteggioElectronAttiviAncheConVLTNonCollegate
			,ConteggioElectronConVLTCollegate
		)
SELECT	
		 T.ConcessionaryID
		,T.ConcessionaryName
		,T.SystemDate
		,T.ConteggioVLTAttive
		,T.ConteggioElectronAttiviAncheConVLTNonCollegate
		,T.ConteggioElectronConVLTCollegate
FROM	@LogTable T
		LEFT JOIN
		ETL.LogConteggi	L WITH(NOLOCK)
		ON T.ConcessionaryID = L.ConcessionaryID
		AND YEAR(T.SystemDate) = YEAR(L.SystemDate)
		AND MONTH(T.SystemDate) = MONTH(L.SystemDate)
		AND DAY(T.SystemDate) = DAY(L.SystemDate)
WHERE	L.ConcessionaryID IS NULL
