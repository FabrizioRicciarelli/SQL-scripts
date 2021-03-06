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
Description.........: Estrazione VLT

Revision			 

Note
- Use [Tab size] = 3 and [Indent size] = 3 (Instert spaces)

------------------
-- Parameters   --
------------------	
@ConcessionaryID	-- OBBLIGATORIO, DETERMINA IL CONCESSIONARIO
@ClubID				-- FACOLTATIVO, DETERMINA LA SALA
@XVLT				-- OUTPUT

-------------------
-- Call Examples --
-------------------
DECLARE	@XVLT XML -- VUOTO
EXEC ETL.ExtractVLT 7, @XVLT = @XVLT OUTPUT
SELECT * FROM ETL.GetAllXVLT(@XVLT)

DECLARE	@XVLT XML -- VUOTO
EXEC ETL.ExtractVLT 7, 1000025, @XVLT = @XVLT OUTPUT
SELECT * FROM ETL.GetAllXVLT(@XVLT)

DECLARE	@XVLT XML -- VUOTO
EXEC ETL.ExtractVLT 7, 1000252, 17, @XVLT = @XVLT OUTPUT
SELECT * FROM ETL.GetAllXVLT(@XVLT)
*/
ALTER PROC	[ETL].[ExtractVLT] 
			@ConcessionaryID int = NULL
			,@ClubID int = NULL
			,@MachineID int = NULL
			,@XVLT XML OUTPUT
AS
DECLARE 
		@INNERSQL Nvarchar(MAX)
		,@OUTERSQL Nvarchar(MAX)
		,@VLT ETL.VLT_TYPE
		,@stringVLT Nvarchar(MAX)
		,@IsDevelopment bit 

BEGIN TRY
	SET @IsDevelopment = IIF(@@SERVERNAME LIKE '%DEV%', 1, 0)

	SET		@INNERSQL =	[ETL].[BuildDynSQL_VLTInfo](@ConcessionaryID)
	SET		@INNERSQL += 
				IIF(@ClubID IS NOT NULL,N' WHERE T1.ClubID = ' + CAST(@ClubID AS Nvarchar(20)),'') +
				IIF(@MachineID IS NOT NULL,N' AND MachineID = ' + CAST(@MachineID AS Nvarchar(20)),'')

	SET		@OUTERSQL = ETL.BuildDynSQL_XmlWrapper(@INNERSQL,'VLT')
	EXEC	sp_executesqL @OUTERSQL, N'@returnValue Nvarchar(MAX) OUT', @returnValue=@STRINGvlt OUT

	SELECT @XVLT = CAST(ISNULL(@STRINGvlt,'<VLT/>') AS XML)
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
