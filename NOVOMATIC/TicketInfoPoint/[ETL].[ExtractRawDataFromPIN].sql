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
@XRAW				-- OUTPUT

-------------------
-- Call Examples --
-------------------
DECLARE @XRAW XML -- VUOTO
EXEC [ETL].[ExtractRawDataFromPIN] 7, 1000114, '2,20,26,27', '2015-11-17 06:19:27.000', '2015-11-18 07:19:27.000', @XRAW = @XRAW OUTPUT
SELECT * FROM ETL.GetAllXRAW(@XRAW)

DECLARE @XRAW XML -- VUOTO
EXEC [ETL].[ExtractRawDataFromPIN] 7, 1000002, '27', '2015-11-17 17:48:34.913', '2015-11-17 18:49:36.597', @XRAW = @XRAW OUTPUT
SELECT @XRAW
SELECT * FROM ETL.GetAllXRAW(@XRAW)

DECLARE @XRAW XML -- VUOTO
EXEC [ETL].[ExtractRawDataFromPIN] 7, 1000002, '27', '2015-11-17 06:19:27.000', NULL, @XRAW = @XRAW OUTPUT
SELECT @XRAW
SELECT * FROM ETL.GetAllXRAW(@XRAW)

DECLARE @XRAW XML -- VUOTO
EXEC [ETL].[ExtractRawDataFromPIN] 7, 1000002, NULL, '20151117', '20151118', @XRAW = @XRAW OUTPUT
SELECT * FROM ETL.GetAllXRAW(@XRAW)

DECLARE @XRAW XML -- VUOTO
EXEC [ETL].[ExtractRawDataFromPIN] 7, 1000002, NULL, '20131117', '20131118', @XRAW = @XRAW OUTPUT
SELECT * FROM ETL.GetAllXRAW(@XRAW)
*/
ALTER PROC	[ETL].[ExtractRawDataFromPIN]
			@ConcessionaryID tinyint
			,@ClubID int
			,@CSVmachineID varchar(100)
			,@FromDate datetime
			,@ToDate datetime = NULL
			,@XRAW XML OUTPUT
AS

DECLARE 
		@OUTERMOSTSQL Nvarchar(MAX) -- DA ESEGUIRE SU QUESTA MACCHINA
		,@OUTERSQL Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA POM-MON01
		,@INNERSQL Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA PIN
		,@ConcessionaryName varchar(20)
		--,@RawData_01 bit = 0
		,@TopRows varchar(20) = 'TOP 10000'
		,@STRINGrawdata Nvarchar(MAX)

BEGIN TRY
	-- IDENTIFICAZIONE DEL CONCESSIONARIO
	SET @ConcessionaryName = ETL.getConcessionaryName(@ConcessionaryID)


	SET @ToDate = ISNULL(@ToDate,DATEADD(DD,1,@FromDate))

	-- ********************************************************************
	-- *** LOGICA DI INDIVIDUAZIONE DEI RAWDATA_01 ANCORA DA INTRODURRE ***
	-- ********************************************************************
	--IF @RawData_01 = 1 -- su DB01 il nome di tabella NON è "RawData_View" bensì "RawData"
	--	BEGIN
	--		SET @INNERSQL = REPLACE(
	--			N'
	--			SELECT	' + ISNULL(@TopRows,'') + ' 
	--					*
	--			FROM	[AGS_RawData_01].[' + CAST(@ClubID AS varchar(10)) + '].[RawData] WITH(NOLOCK)
	--			WHERE	(ServerTime BETWEEN ' + QUOTENAME(CONVERT(CHAR(26), @FromDate, 120), CHAR(39)) + ' AND ' + QUOTENAME(CONVERT(CHAR(26), @ToDate, 120), CHAR(39)) + ')' + 
	--			IIF(ISNULL(@CSVmachineID,'') = '', '', ' AND MachineID IN (' + @CSVmachineID + ')') + '
	--			'
	--			,CHAR(39)
	--			,CHAR(39)+CHAR(39)
	--		)
	--	END

	SET @INNERSQL = REPLACE(
		N'
		SELECT	' + ISNULL(@TopRows,'') + ' 
				*
		FROM	[AGS_RawData].[' + CAST(@ClubID AS Nvarchar(10)) + '].[RawData_View] WITH(NOLOCK)
		WHERE	(ServerTime BETWEEN ' + QUOTENAME(CONVERT(Nvarchar(26), @FromDate, 120), CHAR(39)) + ' AND ' + QUOTENAME(CONVERT(Nvarchar(26), @ToDate, 120), CHAR(39)) + ')' + 
				IIF(ISNULL(@CSVmachineID,'') = '', '', ' AND MachineID IN (' + @CSVmachineID + ')') + '
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
				THEN	N'SELECT @returnValue = CAST((SELECT * FROM OPENQUERY([POM-MON01],'''+ REPLACE(@OUTERSQL,'''','''''') +''') FOR XML RAW(''RAWDATA''),TYPE) AS Nvarchar(MAX))' -- QUERY PER ESECUZIONE IN AMBIENTE DI SVILUPPO  
				ELSE	N'SELECT @returnValue = CAST((' + @OUTERSQL + ' FOR XML RAW(''RAWDATA''),TYPE) AS Nvarchar(MAX))' -- QUERY PER ESECUZIONE IN AMBIENTE DI PRODUZIONE
			END

	EXEC	sp_executesqL @OUTERMOSTSQL, N'@returnValue Nvarchar(MAX) OUT', @returnValue=@STRINGrawdata OUT
	SELECT @XRAW = CAST(ISNULL(@STRINGrawdata,'<RAWDATA/>') AS XML)
	--PRINT(@OUTERMOSTSQL)
END TRY

BEGIN CATCH 
    SELECT
			ERROR_NUMBER() AS ErrorNumber
			,ERROR_SEVERITY() AS Severity
			,ERROR_STATE() AS ErrorState
			,ISNULL(ERROR_PROCEDURE(), ISNULL(dbo.GetProcName(@@PROCID),'*Unknown*')) AS ErrorProcedure  
			,ERROR_LINE() AS ProcedureLine
			,ERROR_MESSAGE() As ErrorMessage
END CATCH 
