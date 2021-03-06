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
Description.........: Estrazione RawData direttamente da macchina POM-MON01

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
@XTMPRawData_View	-- OUTPUT

-------------------
-- Call Examples --
-------------------
DECLARE @XTMPRawData_View XML -- VUOTO
EXEC [ETL].[ExtractRawDataFromPOMMON] 7, 1000114, '2,20,26,27', '2015-11-17 06:19:27.000', '2015-11-18 07:19:27.000', @XTMPRawData_View = @XTMPRawData_View OUTPUT
SELECT * FROM ETL.GetAllXRAW(@XTMPRawData_View)

DECLARE @XTMPRawData_View XML -- VUOTO
EXEC [ETL].[ExtractRawDataFromPOMMON] 7, 1000002, '27', '2015-11-17 17:48:34.913', '2015-11-17 18:49:36.597', @XTMPRawData_View = @XTMPRawData_View OUTPUT
SELECT @XTMPRawData_View
SELECT * FROM ETL.GetAllXRAW(@XTMPRawData_View)

DECLARE @XTMPRawData_View XML -- VUOTO
EXEC [ETL].[ExtractRawDataFromPOMMON] 7, 1000002, '27', '2015-11-17 06:19:27.000', NULL, @XTMPRawData_View = @XTMPRawData_View OUTPUT
SELECT @XTMPRawData_View
SELECT * FROM ETL.GetAllXRAW(@XTMPRawData_View)

DECLARE @XTMPRawData_View XML -- VUOTO
EXEC [ETL].[ExtractRawDataFromPOMMON] 7, 1000002, NULL, '20151117', '20151118', @XTMPRawData_View = @XTMPRawData_View OUTPUT
SELECT * FROM ETL.GetAllXRAW(@XTMPRawData_View)

DECLARE @XTMPRawData_View XML -- VUOTO
EXEC [ETL].[ExtractRawDataFromPOMMON] 7, 1000002, NULL, '20131117', '20131118', @XTMPRawData_View = @XTMPRawData_View OUTPUT
SELECT * FROM ETL.GetAllXRAW(@XTMPRawData_View)

DECLARE @XTMPRawData_View XML -- VUOTO
EXEC [ETL].[ExtractRawDataFromPOMMON] 7, 1000002, NULL, '20131117', '20131118', @XTMPRawData_View = @XTMPRawData_View OUTPUT
SELECT * FROM ETL.GetAllXRAW(@XTMPRawData_View)

DECLARE @XTMPRawData_View XML -- VUOTO
EXEC [ETL].[ExtractRawDataFromPOMMON] 7, 1000002, NULL, NULL, NULL, 'TOTALOUT > 0', @XTMPRawData_View = @XTMPRawData_View OUTPUT
SELECT * FROM ETL.GetAllXRAW(@XTMPRawData_View)


DECLARE @XTMPRawData_View XML -- VUOTO
EXEC [ETL].[ExtractRawDataFromPOMMON] 7, 1000002, '27', NULL, NULL, 'TOTALOUT > 0', @XTMPRawData_View = @XTMPRawData_View OUTPUT
SELECT * FROM ETL.GetAllXRAW(@XTMPRawData_View)


DECLARE @XTMPRawData_View XML -- VUOTO
EXEC [ETL].[ExtractRawDataFromPOMMON] 7, 1000252, NULL, '20170701', '20170706', NULL, @XTMPRawData_View = @XTMPRawData_View OUTPUT
SELECT * FROM ETL.GetAllXRAW(@XTMPRawData_View)

*/
ALTER PROC	[ETL].[ExtractRawDataFromPOMMON]
			@ConcessionaryID tinyint
			,@ClubID int
			,@CSVmachineID varchar(100) = NULL
			,@FromDate datetime = NULL
			,@ToDate datetime = NULL
			,@INNERSQL Nvarchar(MAX) = NULL
			,@MoreCriteria Nvarchar(MAX) = NULL
			,@TopRows varchar(20) = NULL -- 'TOP 10000'
			,@XTMPRawData_View XML OUTPUT
AS

DECLARE 
		@OUTERSQL Nvarchar(MAX) -- DA ESEGUIRE SU QUESTA MACCHINA
		,@ConcessionaryName varchar(20)
		,@STRINGrawdata Nvarchar(MAX)
		,@QFromDate Nvarchar(26)
		,@QToDate Nvarchar(26)
		,@HasCSVMachineIDs Nvarchar(255)
		,@HasMoreCriteria Nvarchar(MAX)

BEGIN TRY
	SET @FromDate = ISNULL(@FromDate,'1900-01-01T00:00:00.000')

	SELECT 
			@ConcessionaryName = ETL.getConcessionaryName(@ConcessionaryID)	-- IDENTIFICAZIONE DEL CONCESSIONARIO
			,@ToDate = IIF(@FromDate = '1900-01-01T00:00:00.000','2049-12-31T23:59:59.999',ISNULL(@ToDate,DATEADD(DD,1,@FromDate))) -- AGGIUNTA DI UN GIORNO QUALORA LA DATA DI ARRIVO NON SIA STATA SPECIFICATA
			,@QFromDate = QUOTENAME(CONVERT(Nvarchar(26), @FromDate, 126), CHAR(39)) -- APICI ATTORNO ALLA DATA DI PARTENZA
			,@QToDate = QUOTENAME(CONVERT(Nvarchar(26), @ToDate, 126), CHAR(39)) -- APICI ATTORNO ALLA DATA DI ARRIVO
			,@HasCSVMachineIDs = IIF(ISNULL(@CSVmachineID,'') = '', '', ' AND MachineID IN (' + @CSVmachineID + ')') -- AGGIUNTA DI WHERECONDITION SU MACHINE IDs SE SPECIFICATO
			,@HasMoreCriteria = IIF(ISNULL(@MoreCriteria,'') = '', '', ' AND ' + @MoreCriteria) -- AGGIUNTA DI ULTERIORI WHERECONDITION SE SPECIFICATE

	IF @INNERSQL IS NULL
		BEGIN
			SET @INNERSQL = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
				N'
				SELECT	° *
				FROM	[$_AGS_RawData].[#].[RawData_View]
				WHERE	(ServerTime BETWEEN ^ AND §)
				|
				ç'
				,'°',ISNULL(@TopRows,'')),'$',@ConcessionaryName),'#',CAST(@ClubID AS Nvarchar(10))),'^',@QFromDate),'§',@QToDate),'|',@HasCSVMachineIDs),'ç',@HasMoreCriteria)

			SET		@OUTERSQL =	ETL.BuildDynSQL_XmlWrapper(@INNERSQL,'RAWDATA')
		END
	ELSE
		BEGIN
			SET @INNERSQL = REPLACE(
								REPLACE(
									REPLACE(
										@INNERSQL
										,'°'
										,ISNULL(@TopRows,'')
									)
									,'$'
									,@ConcessionaryName
								)
								,'#'
								,CAST(@ClubID AS Nvarchar(10))
							)
			SET	@OUTERSQL = ETL.BuildDynSQL_XmlWrapper(@INNERSQL,'RAWDATA')
		END
	PRINT(@OUTERSQL)
	EXEC	sp_executesqL @OUTERSQL, N'@returnValue Nvarchar(MAX) OUT', @returnValue=@STRINGrawdata OUT
	SELECT	@XTMPRawData_View = CAST(ISNULL(@STRINGrawdata,'<RAWDATA/>') AS XML)
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
