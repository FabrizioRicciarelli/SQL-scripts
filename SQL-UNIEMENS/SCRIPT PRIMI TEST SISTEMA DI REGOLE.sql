DECLARE	
		@CFAzienda varchar(16) = '00937610152'
		,@CFLavoratore varchar(16) = 'BBTCLR54C68Z114Q'
		,@PeriodoCompetenza varchar(10) = '2013-12-01'
		,@ContributoNormaleRN int
		,@ImportoRetribuzioneRN int
		,@isInTolerance bit
		,@importoRetribuzioneBase int 
		,@ContributoNormaleBase int = 150000 -- Range contributo normale variazione = da 135000 a 150000 (150000 - 10% = 150000 - 15000 = 135000)
		,@percentualeTolleranza smallint = 10

DECLARE	@XML XML
DECLARE	@RESULTS TABLE
		(
			CFAzienda varchar(16)
			,CFLavoratore varchar(16)
			,PeriodoCompetenza varchar(10)
			,ContributoNormaleRN int
			,ImportoRetribuzioneRN int
			,isInTolerance bit
		)

SELECT	@XML = dbo.fnGetXMLcontr(@CFAzienda, @CFLavoratore, @PeriodoCompetenza)

DECLARE	@CONTRIBUTI TABLE
		(
			CFAzienda varchar(16)
			,CFLavoratore varchar(16)
			,PeriodoCompetenza varchar(10)
			,ContributoNormaleBASE decimal(18,2)
			,ContributoNormaleRN int
			,ImportoRetribuzioneRN int
			,isInTolerance bit
		)

INSERT @CONTRIBUTI
		(
			CFAzienda
			,CFLavoratore
			,PeriodoCompetenza
			,ContributoNormaleBASE
			,ContributoNormaleRN
			,ImportoRetribuzioneRN
			,isInTolerance
		)
SELECT	
		M.AP_KEYD_CFAZIENDA AS CFAzienda
		,M.AP_KEYD_CFLAVORATOREISCRITTO AS CFLavoratore
		,M.AP_KEYD_COMPETENZA AS PeriodoCompetenza
		--,AP_KEYD_SQLCOMMAND_ENPALS -- dbo.fnGetXMLcontr(AP_KEYD_CFAZIENDA, AP_KEYD_CFLAVORATOREISCRITTO, AP_KEYD_COMPETENZA)
		,C.CONTR_BASE_MOD AS ContributoNormaleBASE
		,M.AP_KEYD_SQLCOMMAND_ENPALS.value('(//Normale[../../CodiceRetribuzione = ''RN''])[1]','varchar(max)') AS ContributoNormaleRN
		,M.AP_KEYD_SQLCOMMAND_ENPALS.value('(//ImportoRetribuzione[../CodiceRetribuzione = ''RN''])[1]','varchar(max)') AS ImportoRetribuzioneRN
		,NULL AS isInTolerance
FROM	TB_KEYD_KEYDENINDIVSS_RC M WITH(NOLOCK)
		INNER JOIN
		var.TAB_CONTR_031CM C WITH(NOLOCK)
		ON M.AP_KEYD_CFLAVORATOREISCRITTO = C.CF_LAVORATORE
ORDER BY AP_KEYD_COMPETENZA DESC

SELECT
		CFAzienda
		,CFLavoratore
		,PeriodoCompetenza
		,ContributoNormaleRN
		,ImportoRetribuzioneRN
		,isInTolerance = 
					CASE
						WHEN ContributoNormaleRN <= @ContributoNormaleBase
						AND	ContributoNormaleRN >= (@ContributoNormaleBase - (@ContributoNormaleBase * @percentualeTolleranza / 100))
						THEN 1
						ELSE 0
					END
FROM	@CONTRIBUTI

--SELECT	@ContributoNormaleRN = xmlData.Col.value('.','varchar(max)')
--FROM	@XML.nodes('//Normale[../../CodiceRetribuzione = ''RN'']') xmlData(Col);
SELECT	@ContributoNormaleRN = @XML.value('(//Normale[../../CodiceRetribuzione = ''RN''])[1]','varchar(max)') -- EQUIVALENTE AL PRECEDENTE COMMENTATO

--SELECT	@ImportoRetribuzioneRN = xmlData.Col.value('.','varchar(max)')
--FROM	@XML.nodes('//ImportoRetribuzione[../CodiceRetribuzione = ''RN'']') xmlData(Col);
SELECT	@ImportoRetribuzioneRN = @XML.value('(//ImportoRetribuzione[../CodiceRetribuzione = ''RN''])[1]','varchar(max)') -- EQUIVALENTE AL PRECEDENTE COMMENTATO


SELECT	@isInTolerance = 
			CASE
				WHEN @ContributoNormaleRN <= @ContributoNormaleBase
				AND	@ContributoNormaleRN >= (@ContributoNormaleBase - (@ContributoNormaleBase * @percentualeTolleranza / 100))
				THEN 1
				ELSE 0
			END

INSERT	@RESULTS
		(
			CFAzienda
			,CFLavoratore
			,PeriodoCompetenza
			,ContributoNormaleRN
			,ImportoRetribuzioneRN
			,isInTolerance
		)
VALUES
		(
			@CFAzienda
			,@CFLavoratore
			,@PeriodoCompetenza
			,@ContributoNormaleRN
			,@ImportoRetribuzioneRN
			,@isInTolerance
		)

SELECT	*
FROM	@RESULTS