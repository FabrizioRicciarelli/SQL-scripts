/*
RECUPERO DELLA LISTA COMPLETA (O DI UNA QUOTA PARTE DI ESSI) DEI CLAIMANTS

ESEMPI DI INVOCAZIONE:

EXEC [ETL].[GetRequestStatus] -- RITORNA LA LISTA COMPLETA
EXEC [ETL].[GetRequestStatus] @ID=1 -- RITORNA SOLO IL PRIMO ELEMENTO (AD OGGI "pending")
EXEC [ETL].[GetRequestStatus] @Desc='pend' -- RITORNA IL PRIMO ELEMENTO (AD OGGI "pending"); NOTARE CHE NEL PARAMETRO MANCA LA PARTE FINALE... LA RICERCA AVVIENE PER LIKE
EXEC [ETL].[GetRequestStatus] @Date='2017-05-25 11:55' -- RITORNA IL SETTIMO ELEMENTO (AD OGGI "o.micucci@novomatic.it"); NOTARE CHE NEL PARAMETRO MANCANO LA PARTE FINALE ED INIZIALE... LA RICERCA AVVIENE PER LIKE

*/
ALTER PROC	[ETL].[GetRequestStatus]
			@ID tinyint = NULL
			,@Desc varchar(25) = NULL
			,@Date datetime2(3) = NULL
AS
BEGIN TRY
	DECLARE	@strDATE varchar(26)
	IF ISNULL(@Date,'') != ''
		SET	@strDATE = REPLACE(REPLACE(REPLACE(CAST(@DATE AS varchar(26)),'.000',''),':00',''),' 00','') 

	SELECT	
			 requestStatusId 
			,requestStatusDesc 
			,system_date

	FROM	[ETL].[requestStatus] WITH(NOLOCK)
	WHERE	(requestStatusId = @ID OR @ID IS NULL)
	AND		(requestStatusDesc LIKE '%' + @Desc + '%' OR @Desc IS NULL)
	AND		(CONVERT(DATETIME,SUBSTRING(CAST(system_date AS varchar(26)),1,LEN(@strDATE)),120) = CONVERT(DATETIME, @strDate, 120) OR @Date IS NULL)
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
