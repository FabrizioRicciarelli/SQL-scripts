/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: GA
Creation Date.......: 2017-05-22
Description.........: Calcola la sessione da Out a Out

Note
- Use [Tab size] = 3 and [Indent size] 3 (Insert spaces)

------------------
-- Parameters   --
------------------	

------------------
-- Call Example --
------------------  
EXEC [ETL].[RequestElaborate]
*/
ALTER PROC	[ETL].[GetTicketFromSelect]
			@requestId int,
			@ConcessionaryID tinyint = NULL,
			@ClubID varchar(10) = NULL,
			@FromDate datetime = NULL,
			@ToDate datetime = NULL,
			@ISpaid tinyint= 1 ,
			@Threshold int = 100000,
			@LoadTicketToCalc tinyint = 1,
			@ReturnMessage varchar(1000) = NULL OUTPUT 
AS
BEGIN TRY
	SET NOCOUNT ON;
	declare @tt table (Ticket varchar(20),direction bit,ClubId varchar(20))

	-- tutti i ticket del 2013
	--DECLARE @ReturnCode int, @ReturnMessage varchar(1000) 
	--EXEC @ReturnCode = [Ticket].[Extract_Pomezia]  @ConcessionaryID = 7,  @FromDate = '20130101',@ToDate = '20140101',@ISpaid = 1,@Threshold = 100000,@LoadTicketToCalc = 1,@ReturnMessage = @ReturnMessage OUTPUT
	--SELECT @ReturnCode ReturnCode, @ReturnMessage ReturnMessage 
	--INSERT INTO [ETL].[requestDetail] ()
	--select * from [RAW].[TTicketIN]

	INSERT INTO [ETL].[requestDetail] ([requestId],[ticket],[ticketDirection],[clubId])
	VALUES (@RequestId,'',0,NULL),
	(@RequestId,'',0,NULL),
	(@RequestId,'',0,NULL), 
	(@RequestId,'',0,NULL),
	(@RequestId,'',0,NULL), 
	(@RequestId,'',0,NULL), 
	(@RequestId,'',0,NULL), 
	(@RequestId,'',0,NULL)
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
