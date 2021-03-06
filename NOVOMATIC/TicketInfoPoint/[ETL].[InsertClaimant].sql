/**/
ALTER PROCEDURE [ETL].[InsertClaimant]
      @requestClaimantName nvarchar(150)
      ,@requestClaimantEmail nvarchar(255)
      ,@requestClaimantFolder nvarchar(255)
      ,@requestClaimantID int OUTPUT
    
AS
BEGIN

SELECT @requestClaimantID=[requestClaimantId] from [ETL].[requestClaimant] where requestClaimantEmail=@requestClaimantEmail 

IF @requestClaimantID IS NULL
    BEGIN
    INSERT INTO [ETL].[requestClaimant]
			(requestClaimantName, requestClaimantEmail, requestClaimantFolder)
	    VALUES
			(@requestClaimantName
			,@requestClaimantEmail
			,@requestClaimantFolder)

         SET @requestClaimantID = SCOPE_IDENTITY()
    END

END
