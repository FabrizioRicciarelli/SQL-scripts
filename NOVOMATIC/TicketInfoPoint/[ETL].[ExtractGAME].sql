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
Description.........: Estrazione GAMES

Revision			 

Note
- Use [Tab size] = 3 and [Indent size] = 3 (Instert spaces)

------------------
-- Parameters   --
------------------	
@ConcessionaryID	-- OBBLIGATORIO, DETERMINA IL CONCESSIONARIO
@ClubID				-- FACOLTATIVO, DETERMINA LA SALA
@XGAME				-- OUTPUT

-------------------
-- Call Examples --
-------------------
SET NOCOUNT ON;
DECLARE	@XGAME XML -- VUOTO
EXEC ETL.ExtractGAME 7, @XGAME = @XGAME OUTPUT
SELECT * FROM ETL.GetAllXGAME(@XGAME) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
*/
ALTER PROC	[ETL].[ExtractGAME] 
			@ConcessionaryID int = NULL
			,@GameID int = NULL
			,@GameNameSK int = NULL
			,@XGAME XML OUTPUT
AS
DECLARE 
		@INNERSQL Nvarchar(MAX)
		,@OUTERSQL Nvarchar(MAX)
		,@stringGAME Nvarchar(MAX)
		,@IsDevelopment bit

BEGIN TRY
	SET @IsDevelopment = IIF(@@SERVERNAME LIKE '%DEV%', 1, 0)

	SET		@INNERSQL =	[ETL].[BuildDynSQL_GAMEInfo](@ConcessionaryID)
	SET		@INNERSQL += IIF(@GameID IS NOT NULL,N' AND T1.GameID = ' + CAST(@GameID AS Nvarchar(20)),'')
	SET		@INNERSQL += IIF(@GameNameSK IS NOT NULL,N' AND T1.GameNameSK = ' + CAST(@GameNameSK AS Nvarchar(20)),'')
	SET		@OUTERSQL = ETL.BuildDynSQL_XmlWrapper(@INNERSQL,'GAME')
	EXEC	sp_executesqL @OUTERSQL, N'@returnValue Nvarchar(MAX) OUT', @returnValue=@stringGAME OUT

	SELECT @XGAME = CAST(ISNULL(@stringGAME,'<GAME/>') AS XML)
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
