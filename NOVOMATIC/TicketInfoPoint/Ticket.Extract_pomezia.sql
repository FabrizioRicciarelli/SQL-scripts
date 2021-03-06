/* 
Template NIS (1.1 - 2015-04-01)  

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗ 
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝ 
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║      
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║      
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗ 
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ 
                                                                             
Author..............: Jena 
Creation Date.......: 2017-02-01  
Description.........:  

Revision        
2017-05-25: GA - Adattata per i nuovi requisiti del progetto 
2018-01-12: FR - Compattata in struttura dinamica 

------------------ 
-- Parameters   -- 
------------------   
@ConcessionaryID tinyint 
@ClubID varchar(10) = NULL 
@TicketCode varchar(20) = NULL 
@FromDate datetime = NULL 
@ToDate datetime = NULL 
@IsMhx Bit = NULL 

@ReturnMessage varchar(1000) = NULL OUTPUT 

------------------ 
-- Call Example -- 
------------------ 
EXEC Ticket.Extract_Pomezia -- NON SUFFICIENTE
EXEC Ticket.Extract_Pomezia  @ConcessionaryID = 7 -- NON SUFFICIENTE
 
EXEC Ticket.Extract_Pomezia  @ConcessionaryID = 7, @ClubID = '1000294'
EXEC Ticket.Extract_Pomezia  @ConcessionaryID = 7, @ClubID = '1000294', @Fromdate = '20150211'
EXEC Ticket.Extract_Pomezia  @ConcessionaryID = 7,  @TicketCode = '1000332HPV201709220001'
EXEC Ticket.Extract_Pomezia  @ConcessionaryID = 4,  @TicketCode = '241284330180829418'
*/ 
ALTER PROC	Ticket.Extract_pomezia 
			@ConcessionaryID tinyint = NULL, 
			@ClubID          varchar(10) = NULL, 
			@TicketCode      varchar(20) = NULL, 
			@FromDate        datetime = NULL, 
			@ToDate          datetime = NULL, 
			@IsMhx           bit = NULL, 
			@ReturnMessage   varchar(1000) = NULL OUTPUT
AS 
SET NOCOUNT ON; 

DECLARE
		@StringSQL			varchar(MAX)
		,@insertStatement	varchar(MAX)
		,@targetTable		sysname
		,@firstField		varchar(10)
		,@ConcessionaryName varchar(100) 

-- I PARAMETRI MINIMI RICHIESTI DA VALORIZZARE SONO:
-- @ConcessionaryID +
-- @ClubID e/oppure @TicketCode
IF ISNULL(@ConcessionaryID,0) > 0
AND 
(
	ISNULL(@ClubID,'') != '' OR
	ISNULL(@TicketCode,'') != ''
)
	BEGIN
		SELECT	@ConcessionaryName = concessionaryname 
		FROM	ConcessionaryType 
		WHERE	concessionarySK = @ConcessionaryID

		-- ASSEGNAZIONE DINAMICA DEI VALORI IN BASE AI PARAMETRI FORNITI ALLA PRESENTE SP
		SET		@ToDate = ISNULL(@ToDate, Dateadd(DAY, 1, @fromDate)); 
		SELECT	@StringSQL =
				'EXEC [POM-MON01].[AGS_ETL].[Ticket].[Extract_PIN01]' + 
				ISNULL(COALESCE(NULL, ' @ClubID = ' + @ClubID + ','),'') +
				ISNULL(COALESCE(NULL, ' @TicketCode = ' + QUOTENAME(@TicketCode, CHAR(39)) + ','),'') +
				ISNULL(COALESCE(NULL, ' @FromDate = ' + QUOTENAME(CONVERT(CHAR(8), @FromDate, 112), CHAR(39)) + ','),'') +
				ISNULL(COALESCE(NULL, ' @ToDate = ' + QUOTENAME(CONVERT(CHAR(8), @ToDate, 112), CHAR(39)) + ','),'') +
				ISNULL(COALESCE(NULL, ' @ISMhx = ' + QUOTENAME(CONVERT(CHAR(1), @ISMhx, 112), CHAR(39)) + ','),'')
		SET		@StringSQL = LEFT(@StringSQL, LEN(@StringSQL)-1)

		-- SELEZIONE DINAMICA DELLA TABELLA DI DESTINAZIONE IN BASE AI PARAMETRI FORNITI ALLA PRESENTE SP
		SELECT	@targetTable =
				CASE
					WHEN 	@TicketCode IS NULL
					THEN	'[TMP].[Ticket]'
					ELSE	'[TMP].[Ticketstart]'
				END

		-- LA TABELLA DI DESTINAZIONE [TMP].[Ticket] NON HA LA COLONNA "clubid" 
		SELECT	@firstField =
				CASE
					WHEN 	@TicketCode IS NULL
					THEN	''
					ELSE	'clubid, '
				END

		SET	@insertStatement = 
		'
		DECLARE @SQL varchar(MAX) = ' + QUOTENAME(@StringSQL, CHAR(39)) + CHAR(13) + '
		TRUNCATE TABLE ' + @targetTable + CHAR(13) + ' 
		INSERT ' + @targetTable + '(' + @firstField + 'ticketcode, ticketvalue, printingdata, printingmachine, printingmachineid, payoutdata, payoutmachine, payoutmachineid, ispaidcashdesk, isprintingcashdesk, expiredate, eventdate, mhmachine, mhmachineid, creationchangedate)' + CHAR(13) + ' 
		EXEC(@SQL) AT [' + @ConcessionaryName + '_Pin01\DW]
		' 

		EXEC(@insertStatement)
	END