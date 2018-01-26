/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: Fabrizio Ricciarelli 
Creation Date.......: 2018-01-15
Description.........: Estrazione RawData direttamente da macchine PIN

Revision			 

Note
- Use [Tab size] = 3 and [Indent size] = 3 (Instert spaces)

------------------
-- Parameters   --
------------------	
@ConcessionaryID	-- OBBLIGATORIO, DETERMINA IL CONCESSIONARIO
@ClubID				-- OBBLIGATORIO, DETERMINA LA SALA
@CSVmachineID		-- FACOLTATIVO, ELENCO DI VALORI NUMERICI SEPARATI DA VIRGOLE, RIGUARDANTI GLI ID DELLE MACCHINE (FUNGE DA FILTRO)
@FromDate			-- FACOLTATIVO, DATA INIZIALE MINIMA DALLA QUALE INIZIARE LA RICERCA
@ToDate				-- FACOLTATIVO, DATA FINALE MASSIMA ENTRO LA QUALE TERMINARE LA RICERCA
@XRD				-- OUTPUT

-------------------
-- Call Examples --
-------------------
DECLARE @XRD XML -- VUOTO
EXEC [ETL].[ExtractRawDataFromPIN] 7, 1000114, '2,20,26,27', '20151117', '20151118', @XRD = @XRD OUTPUT
SELECT * FROM ETL.GetXRD(@XRD, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI

DECLARE @XRD XML -- VUOTO
EXEC [ETL].[ExtractRawDataFromPIN] 7, 1000002, '2,20,26,27', '20151117', '20151118', @XRD = @XRD OUTPUT
SELECT * FROM ETL.GetXRD(@XRD, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
*/
ALTER PROC	[ETL].[ExtractRawDataFromPIN]
			@ConcessionaryID tinyint
			,@ClubID int
			,@CSVmachineID varchar(100)
			,@FromDate varchar(8)
			,@ToDate varchar(8)
			,@XRD XML OUTPUT
AS

DECLARE 
		@OUTERMOSTSQL Nvarchar(MAX) -- DA ESEGUIRE SU QUESTA MACCHINA
		,@OUTERSQL Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA POM-MON01
		,@INNERSQL Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA PIN
		,@ConcessionaryName varchar(20)
		,@RawData_01 bit = 0
		,@TopRows varchar(20) = 'TOP 10000'
		,@STRINGrawdata Nvarchar(MAX)

-- IDENTIFICAZIONE DEL CONCESSIONARIO
SET @ConcessionaryName = ETL.getConcessionaryName(@ConcessionaryID)


-- ********************************************************************
-- *** LOGICA DI INDIVIDUAZIONE DEI RAWDATA_01 ANCORA DA INTRODURRE ***
-- ********************************************************************
IF @RawData_01 = 1 
	BEGIN
		SET @INNERSQL = REPLACE(
			N'
			SELECT	' + ISNULL(@TopRows,'') + ' 
					*
			FROM	[AGS_RawData_01].[' + CAST(@ClubID AS varchar(10)) + '].[RawData_View] WITH(NOLOCK)
			WHERE	(ServerTime BETWEEN ' + QUOTENAME(CONVERT(CHAR(8), @FromDate, 112), CHAR(39)) + ' AND ' + QUOTENAME(CONVERT(CHAR(8), @ToDate, 112), CHAR(39)) + ')
			AND		MachineID IN (' + @CSVmachineID + ')
			'
			,CHAR(39)
			,CHAR(39)+CHAR(39)
		)
	END

SET @INNERSQL = REPLACE(
	N'
	SELECT	' + ISNULL(@TopRows,'') + ' 
			*
	FROM	[AGS_RawData].[' + CAST(@ClubID AS Nvarchar(10)) + '].[RawData_View] WITH(NOLOCK)
	WHERE	(ServerTime BETWEEN ' + QUOTENAME(CONVERT(Nvarchar(8), @FromDate, 112), CHAR(39)) + ' AND ' + QUOTENAME(CONVERT(Nvarchar(8), @ToDate, 112), CHAR(39)) + ')
	AND		MachineID IN (' + @CSVmachineID + ')
	'
	,CHAR(39)
	,CHAR(39)+CHAR(39)
)

SET @OUTERSQL =
N'
SELECT * FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + @INNERSQL + ''')
'

SELECT	@OUTERMOSTSQL = 
		CASE	
			WHEN	@@SERVERNAME LIKE '%DEV%' -- DETERMINA L'AMBIENTE SUL QUALE E' IN ESECUZIONE LA CORRENTE STORED PROCEDURE
			THEN	N'SELECT @returnValue = CAST((SELECT * FROM OPENQUERY([POM-MON01],'''+ REPLACE(@OUTERSQL,'''','''''') +''') FOR XML RAW(''XRD''),TYPE) AS Nvarchar(MAX))' -- QUERY PER ESECUZIONE IN AMBIENTE DI SVILUPPO  
			ELSE	N'SELECT @returnValue = CAST((SELECT * FROM (' + @OUTERSQL + ') FOR XML RAW(''XRD''),TYPE) AS Nvarchar(MAX))' -- QUERY PER ESECUZIONE IN AMBIENTE DI PRODUZIONE
		END

EXEC	sp_executesqL @OUTERMOSTSQL, N'@returnValue Nvarchar(MAX) OUT', @returnValue=@STRINGrawdata OUT
SELECT @XRD = CAST(ISNULL(@STRINGrawdata,'<XRD/>') AS XML)
