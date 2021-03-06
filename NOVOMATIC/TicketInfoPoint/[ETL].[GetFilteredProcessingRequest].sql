/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: Valerio, Fabrizio
Creation Date.......: 2017-09-25
Last modified date..: 2017-10-25
Description.........: Recupera le richieste filtrate

Revision			 
Fabrizio: aggiunto intervallo condizionale sulla system date (se impostati entrambi gli estremi)

Note
- Use [Tab size] = 2 and [Indent size]

------------------
-- Parameters   --
------------------	
- ConcessionaryID: ID del concessionario;
- DeteFrom: Dalla data;
- DateTo: Alla data;
- RequestDescription: Descrizione della richiesta;
- RequestStatusID: ID dello stato della richiesta;
- TicketID: ID del ticket;
- RequestClaimantID: ID dell'utente

------------------
-- Call Example --
------------------
DECLARE 
		@testFrom DATETIME = '2017-12-01'--T00:00:00.000Z' 
		,@testTo DATETIME = '2017-12-27'--T00:00:00.000Z'
--EXEC ETL.GetFilteredProcessingRequest @dateFrom = '2017-12-27', @dateTo = '2017-12-27'
EXEC ETL.GetFilteredProcessingRequest @dateFrom = @testFrom, @dateTo = @testTo
*/

ALTER PROC	[ETL].[GetFilteredProcessingRequest]
			@ConcessionaryID tinyint = NULL
			,@DateFrom datetime = NULL
			,@DateTo datetime = NULL
			,@RequestDescription nvarchar(150) = NULL
			,@RequestStatusID tinyint = NULL
			,@TicketID varchar(50) = NULL
			,@RequestClaimantID smallint = NULL
AS

BEGIN
	
	DECLARE 
			@FROM varchar(10) = NULL
			,@TO varchar(10) = NULL

	IF ISNULL(@DateFrom,'') != ''
	AND ISNULL(@DateTo,'') != ''
		BEGIN
			SET @FROM = dbo.ToISOdate(@DateFrom)
			SET @TO = dbo.ToISOdate(@DateTo)
		END
	
	SELECT	DISTINCT 
			requestId
			,requestDesc
			,requestClaimantId
			,requestClaimantName
			,elabStart
			,elabEnd
			,requestStatusId
			,requestStatusDesc
			,ConcessionaryID AS concessionaryId
			,ConcessionaryName AS concessionaryName
			,system_date
	FROM	ETL.vRequest
	WHERE	(ConcessionaryID = @ConcessionaryID OR @ConcessionaryID IS NULL)
	AND		1 = 
			CASE	
				WHEN @FROM IS NOT NULL
				THEN 
					CASE
						WHEN (dbo.ToISOdate(system_date) BETWEEN @FROM AND @TO)
						THEN 1
						ELSE 0
					END
				ELSE 1
			END
	AND		(requestDesc = @RequestDescription OR @RequestDescription IS NULL)
	AND		(requestStatusId = @RequestStatusID OR @RequestStatusID IS NULL)
	AND		(requestClaimantId = @RequestClaimantID OR @RequestClaimantID IS NULL)
	AND		(TicketID = @TicketID OR @TicketID IS NULL)

END
