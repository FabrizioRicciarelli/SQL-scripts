/*
RECUPERO DELLA LISTA COMPLETA (O DI UNA QUOTA PARTE DI ESSI) DEI CONCESSIONARI DA 600DWH

ESEMPI DI INVOCAZIONE:

EXEC [ETL].[GetRemoteConcessionary] -- RITORNA LA LISTA COMPLETA
EXEC [ETL].[GetRemoteConcessionary] @ExcludedID=7 -- RITORNA LA LISTA COMPLETA, AD ESCLUSIONE DI "GMatica"
EXEC [ETL].[GetRemoteConcessionary] @ID=7-- RITORNA SOLO IL SECONDO ELEMENTO (AD OGGI "GMatica")
EXEC [ETL].[GetRemoteConcessionary] @Name='Gmatic' -- RITORNA IL SETTIMO ELEMENTO (AD OGGI "GMatica"); NOTARE CHE NEL PARAMETRO MANCA LA "A" FINALE... LA RICERCA AVVIENE PER LIKE
EXEC [ETL].[GetRemoteConcessionary] @SystemCode='1411000' -- RITORNA IL SETTIMO ELEMENTO (AD OGGI "GMatica"); NOTARE CHE NEL PARAMETRO MANCANO LE TRE CIFRE FINALI... LA RICERCA AVVIENE PER LIKE
EXEC [ETL].[GetRemoteConcessionary] @Letter='D' -- RITORNA IL SETTIMO ELEMENTO (AD OGGI "GMatica");
EXEC [ETL].[GetRemoteConcessionary] @Number=1 -- RITORNA IL SETTIMO ELEMENTO (AD OGGI "GMatica");

*/
ALTER PROC	[ETL].[GetRemoteConcessionary]
			@ID int = NULL
			,@ExcludedID int = NULL
			,@Name varchar(50) = NULL
			,@SystemCode varchar(1000) = NULL
			,@Letter char(1) = NULL
			,@Number tinyint = NULL
AS
BEGIN TRY
	SELECT	
			ConcessionarySK
			,ConcessionaryName 
			,ConcessionarySystemCode
			,ConcessionaryLetter
			,ConcessionaryNumber
	FROM	[600DWH].[dim].[Concessionary] WITH(NOLOCK)
	WHERE	(ConcessionarySK = @ID OR @ID IS NULL)
	AND		(ConcessionarySK != @ExcludedID OR @ExcludedID IS NULL)
	AND		(ConcessionaryName LIKE '%' + @Name + '%' OR @Name IS NULL)
	AND		(ConcessionarySystemCode LIKE '%' + @SystemCode + '%' OR @SystemCode IS NULL)
	AND		(ConcessionaryLetter = @Letter OR @Letter IS NULL)
	AND		(ConcessionaryNumber = @Number OR @Number IS NULL)
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
