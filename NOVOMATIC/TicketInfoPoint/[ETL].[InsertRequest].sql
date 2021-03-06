/*
*/
ALTER PROCEDURE [ETL].[InsertRequest]
    @requestClaimantId int,
    @requestDesc VARCHAR(150),
    @requestDetails ETL.TicketTbl READONLY,
	@ConcessionaryID TINYINT
    
AS
BEGIN
DECLARE	@requestId int

INSERT INTO [ETL].[request]
           ([requestDesc]
           ,[requestClaimantId]
           ,[requestStatusId]
		   ,[ConcessionaryID])
     VALUES
           (@requestDesc
           ,@requestClaimantId
           ,1
		   ,@ConcessionaryID
		   )

SET @requestId = SCOPE_IDENTITY()



INSERT INTO [ETL].[requestDetail]
           ([requestId]
           ,[ticket]
           ,[clubId]
           ,[ticketDirection]
           ,[detailStatusId]
			)

SELECT @requestId, [ticket], [clubId], [ticketDirection], 1 FROM @requestDetails

END
