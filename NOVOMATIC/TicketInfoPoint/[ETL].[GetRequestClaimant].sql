/*
RECUPERO DELLA LISTA COMPLETA (O DI UNA QUOTA PARTE DI ESSI) DEI CLAIMANTS

ESEMPI DI INVOCAZIONE:

EXEC [ETL].[GetRequestClaimant] -- RITORNA LA LISTA COMPLETA
EXEC [ETL].[GetRequestClaimant] @ID=10 -- RITORNA SOLO IL SECONDO ELEMENTO (AD OGGI "Administrator")
EXEC [ETL].[GetRequestClaimant] @Name='ANDREN' -- RITORNA IL SETTIMO ELEMENTO (AD OGGI "Gianpiero Andrenacci"); NOTARE CHE NEL PARAMETRO MANCA LA PARTE FINALE... LA RICERCA AVVIENE PER LIKE
EXEC [ETL].[GetRequestClaimant] @Email='MICUCCI' -- RITORNA IL SETTIMO ELEMENTO (AD OGGI "o.micucci@novomatic.it"); NOTARE CHE NEL PARAMETRO MANCANO LA PARTE FINALE ED INIZIALE... LA RICERCA AVVIENE PER LIKE
EXEC [ETL].[GetRequestClaimant] @Email='ALIF' -- RITORNA IL SETTIMO ELEMENTO (AD OGGI "Califfa"); NOTARE CHE NEL PARAMETRO MANCANO LA PARTE FINALE ED INIZIALE... LA RICERCA AVVIENE PER LIKE

*/
ALTER PROC	[ETL].[GetRequestClaimant]
			@ID smallint = NULL
			,@Name nvarchar(150) = NULL
			,@Email nvarchar(150) = NULL
			,@Folder nvarchar(150) = NULL
AS
BEGIN TRY
	SELECT	
			 requestClaimantId 
			,requestClaimantName 
			,requestClaimantEmail
			,requestClaimantFolder

	FROM	[ETL].[requestClaimant] WITH(NOLOCK)
	WHERE	(requestClaimantId = @ID OR @ID IS NULL)
	AND		(requestClaimantName LIKE '%' + @Name + '%' OR @Name IS NULL)
	AND		(requestClaimantEmail LIKE '%' + @Email + '%' OR @Email IS NULL)
	AND		(requestClaimantFolder LIKE '%' + @Folder + '%' OR @Folder IS NULL)
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
