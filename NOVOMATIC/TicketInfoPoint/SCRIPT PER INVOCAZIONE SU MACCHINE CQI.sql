SET XACT_ABORT ON; -- ATTIVARE (ON) PER ABILITARE LE TRANSAZIONI DISTRIBUITE

DECLARE
		@ConcessionaryID tinyint = 7 -- (7 = GMATICA)

		,@OUTERMOSTSQL Nvarchar(MAX) -- DA ESEGUIRE SU QUESTA MACCHINA
		,@OUTERSQL Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA POM-MON01
		,@INNERSQL Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA PIN/CQI/FINANCE
		,@ConcessionaryName Nvarchar(20)

		,@STRINGcont Nvarchar(MAX) = NULL -- RISULTATI IN FORMA STRINGXML RITORNATI DALLE MACCHINE PIN/CQI/FINANCE
		,@XMLcont XML -- RISULTATI IN FORMA XML CONTENENTI TUTTI I CONTEGGI

-- IDENTIFICAZIONE DEL CONCESSIONARIO
SELECT @ConcessionaryName = ETL.getConcessionaryName(@ConcessionaryID)

-- DEFINIZIONE QUERY DA INVOCARE SU MACCHINE REMOTE
SET @INNERSQL = 
N'
	SELECT 
			*
	FROM	OPENQUERY -- Consente di superare questo errore: "Xml data type is not supported in distributed queries"
	(
		[CQI]
		,''
		SELECT
				 SUM(I.ConteggioVLTAttive) AS ConteggioVLTAttive
				,SUM(I.ConteggioElectronAttiviAncheConVLTNonCollegate) AS ConteggioElectronAttiviAncheConVLTNonCollegate
				,SUM(I.ConteggioElectronConVLTCollegate) AS ConteggioElectronConVLTCollegate
		FROM
		(
			SELECT  
					COUNT(*) AS ConteggioVLTAttive
					,0 AS ConteggioElectronAttiviAncheConVLTNonCollegate
					,0 AS ConteggioElectronConVLTCollegate
			FROM	[ConcessionarySystemDB].[AAMS].[VideoTerminalMachine] WITH(NOLOCK)
			WHERE	LOCATIONRECID!=0 AND CLUBID!=0 -- non sono in magazzino
			AND		VLTCESSATIONDATE IS NULL -- non cessate
			
			UNION ALL
			
			SELECT 
					0 AS ConteggioVLTAttive
					,COUNT(distinct UnivocalLocationCode) AS ConteggioElectronAttiviAncheConVLTNonCollegate
					,0 AS ConteggioElectronConVLTCollegate
			FROM	[ConcessionarySystemDB].[AAMS].[GamingRoomSystem] GRS WITH(NOLOCK)
					INNER JOIN 
					[ConcessionarySystemDB].[AAMS].[Location] T2 WITH(NOLOCK)
					ON GRS.LocationRecID = T2.RecID
			WHERE	GRS.cessationdate IS NULL
			AND		GRS.registrationdate IS NOT NULL -- non cessate e censite
			AND		T2.SiteType <> 9 -- non magazzino				
			
			UNION ALL
			
			SELECT 
					0 AS ConteggioVLTAttive
					,0 AS ConteggioElectronAttiviAncheConVLTNonCollegate
					,COUNT(DISTINCT UnivocalLocationCode) AS ConteggioElectronConVLTCollegate
			FROM	[ConcessionarySystemDB].[AAMS].[VideoTerminalMachine] GRS WITH(NOLOCK)
					INNER JOIN [ConcessionarySystemDB].[AAMS].[Location] t2 WITH(NOLOCK)
					ON GRS.LocationRecID = t2.RecID
			WHERE	GRS.Vltcessationdate is null -- non cessati
			AND		GRS.LastSftVerify > ''''20010101'''' -- vlt censite
			AND		t2.SiteType <> 9 -- non magazzino
		) I
		''
	)
'

SET @INNERSQL = REPLACE(@INNERSQL, CHAR(39), CHAR(39)+CHAR(39))	-- rimpiazzo apici singoli con apici doppi per innesto query SQL dinamico

SET @OUTERSQL = N'SELECT * FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + @INNERSQL + ''')'
SELECT	@OUTERMOSTSQL = 
		CASE	
			WHEN	@@SERVERNAME LIKE '%DEV%' -- DETERMINA L'AMBIENTE SUL QUALE E' IN ESECUZIONE LA CORRENTE STORED PROCEDURE
			THEN	N'SELECT @returnValue = CAST((SELECT * FROM OPENQUERY([POM-MON01],'''+ REPLACE(@OUTERSQL,'''','''''') +''') FOR XML RAW(''CONTEGGI''),TYPE) AS Nvarchar(MAX))' -- QUERY PER ESECUZIONE IN AMBIENTE DI SVILUPPO  
			ELSE	N'SELECT @returnValue = CAST((SELECT * FROM (' + @OUTERSQL + ') FOR XML RAW(''CONTEGGI''),TYPE) AS Nvarchar(MAX))' -- QUERY PER ESECUZIONE IN AMBIENTE DI PRODUZIONE
		END

EXEC	sp_executesqL @OUTERMOSTSQL, N'@returnValue Nvarchar(MAX) OUT', @returnValue=@STRINGcont OUT
SELECT	@XMLcont = CAST(@STRINGcont AS XML)

SELECT	@XMLCONT AS ConteggiXML
SELECT 
		T.c.value('@ConteggioVLTAttive', 'int') AS ConteggioVLTAttive
		,T.c.value('@ConteggioElectronAttiviAncheConVLTNonCollegate', 'int') AS ConteggioElectronAttiviAncheConVLTNonCollegate
		,T.c.value('@ConteggioElectronConVLTCollegate', 'int') AS ConteggioElectronConVLTCollegate
FROM	@XMLcont.nodes('CONTEGGI') AS T(c) 

