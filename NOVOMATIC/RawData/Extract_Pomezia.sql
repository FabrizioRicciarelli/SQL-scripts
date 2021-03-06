USE [Staging]
GO
/****** Object:  StoredProcedure [Ticket].[Extract_Pomezia]    Script Date: 07/07/2017 14:03:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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

Note
- Use [Tab size] = 3 and [Indent size] = 3 (Insert spaces)

------------------
-- Parameters   --
------------------	
@ConcessionaryID tinyint
@ClubID varchar(10) = NULL
@TicketCode varchar(max) = NULL
@FromDate datetime = NULL
@ToDate datetime = NULL
@IsMhx Bit = NULL

@ReturnMessage varchar(1000) = NULL OUTPUT

------------------
-- Call Example --
------------------  
DECLARE @ReturnCode int, @ReturnMessage varchar(1000) 
EXEC @ReturnCode = [Ticket].[Extract_Pomezia]  @ConcessionaryID = 7, @ClubID = 1000294, @Fromdate = '20150211',@IsMhx = 1, @ReturnMessage = @ReturnMessage OUTPUT
SELECT @ReturnCode ReturnCode, @ReturnMessage ReturnMessage 

DECLARE @ReturnCode int, @ReturnMessage varchar(1000) 
EXEC @ReturnCode = [Ticket].[Extract_Pomezia]  @ConcessionaryID = 7,  @TicketCode = '525764475876923475', @ReturnMessage = @ReturnMessage OUTPUT
SELECT @ReturnCode ReturnCode, @ReturnMessage ReturnMessage 

DECLARE @ReturnCode int, @ReturnMessage varchar(1000) 
EXEC @ReturnCode = [Ticket].[Extract_Pomezia]  @ConcessionaryID = 7,  @TicketCode = '1000294MHR201502110001', @ReturnMessage = @ReturnMessage OUTPUT
SELECT @ReturnCode ReturnCode, @ReturnMessage ReturnMessage 

*/
ALTER PROC	[Ticket].[Extract_Pomezia] 
			@ConcessionaryID tinyint,
			@ClubID varchar(10) = NULL,
			@TicketCode varchar(max) = NULL,
			@FromDate datetime = NULL,
			@ToDate datetime = NULL,
			@IsMhx Bit = NULL,
			@ReturnMessage varchar(1000) = NULL OUTPUT
AS
BEGIN
SET NOCOUNT ON;
DECLARE @ReturnCode int = 0;

DECLARE @TableResult TABLE(ReturnCode int, ReturnMessage varchar(1000));
DECLARE @StringSQL varchar(max), @ConcessionaryName varchar(100), @LinkedServer varchar(100), @CQIDB varchar(100);

SELECT @ConcessionaryName = ConcessionaryName, @LinkedServer = LinkedServer
FROM  AGS.Type.Concessionary
WHERE ConcessionarySK = @ConcessionaryID;


SET @ToDate = ISNULL(@ToDate, DATEADD(DAY, 1, @fromDate));

SET @StringSQL = 'DECLARE @ReturnCode int, @ReturnMessage varchar(1000) 
					   EXEC [AGS_ETL].[Ticket].[Extract_PIN01] ' + char(10);

IF NOT @ClubID IS NULL
   SET @StringSQL+= '@ClubID = ' + @ClubID + ',';                 
 
IF NOT @TicketCode IS NULL
   SET @StringSQL+= ' @TicketCode = ''' + @TicketCode + ''',';  

IF NOT @FromDate IS NULL
   SET @StringSQL+= '@FromDate = ' + QUOTENAME(CONVERT(char(8), @FromDate, 112), char(39));                 
 
IF NOT @ToDate IS NULL
   SET @StringSQL+= ',@ToDate = ' + QUOTENAME(CONVERT(char(8), @ToDate, 112), char(39));    

IF NOT @ISMhx IS NULL
   SET @StringSQL+= ',@ISMhx = ' + QUOTENAME(CONVERT(char(1), @ISMhx, 112), char(39));  

IF LEFT(REVERSE(@StringSQL), 1) = ','
   SET @StringSQL = LEFT(@StringSQL, LEN(@StringSQL) - 1);

--SET @StringSQL+= ',@ReturnCode = @ReturnCode OUTPUT, @ReturnMessage = @ReturnMessage OUTPUT' + CHAR(13); 
SET @StringSQL+= ',@ReturnMessage = @ReturnMessage OUTPUT' + CHAR(13); 
SET @StringSQL+= 'SELECT @ReturnCode ReturnCode, @ReturnMessage ReturnMessage'; 


IF @ConcessionaryName = 'GMATICA'  INSERT INTO @TableResult(ReturnCode, ReturnMessage) EXEC (@StringSQL) AT[GMatica_Pin01\DW];
IF @ConcessionaryName = 'NETWIN'   INSERT INTO @TableResult(ReturnCode, ReturnMessage) EXEC (@StringSQL) AT[Netwin_Pin01\DW];
IF @ConcessionaryName = 'NTS'      INSERT INTO @TableResult(ReturnCode, ReturnMessage) EXEC (@StringSQL) AT[NTS_Pin01\DW];
IF @ConcessionaryName = 'INTRALOT' INSERT INTO @TableResult(ReturnCode, ReturnMessage) EXEC (@StringSQL) AT[INTRALOT_Pin01\DW];
IF @ConcessionaryName = 'HBG'      INSERT INTO @TableResult(ReturnCode, ReturnMessage) EXEC (@StringSQL) AT[HBG_Pin01\DW];
IF @ConcessionaryName = 'SISAL'    INSERT INTO @TableResult(ReturnCode, ReturnMessage) EXEC (@StringSQL) AT[SISAL_Pin01\DW];
IF @ConcessionaryName = 'SNAI'     INSERT INTO @TableResult(ReturnCode, ReturnMessage) EXEC (@StringSQL) AT[SNAI_Pin01\DW];
IF @ConcessionaryName = 'CODERE'   INSERT INTO @TableResult(ReturnCode, ReturnMessage) EXEC (@StringSQL) AT[CODERE_Pin01\DW];
IF @ConcessionaryName = 'BPLUS'    INSERT INTO @TableResult(ReturnCode, ReturnMessage) EXEC (@StringSQL) AT[BPLUS_Pin01\DW];
IF @ConcessionaryName = 'CIRSA'    INSERT INTO @TableResult(ReturnCode, ReturnMessage) EXEC (@StringSQL) AT[CIRSA_Pin01\DW];
IF @ConcessionaryName = 'GAMENET'  INSERT INTO @TableResult(ReturnCode, ReturnMessage) EXEC (@StringSQL) AT[GAMENET_Pin01\DW];
IF @ConcessionaryName = 'GTECH'    INSERT INTO @TableResult(ReturnCode, ReturnMessage) EXEC (@StringSQL) AT[GTECH_Pin01\DW];
IF @ConcessionaryName = 'COGETECH' INSERT INTO @TableResult(ReturnCode, ReturnMessage) EXEC (@StringSQL) AT[COGETECH_Pin01\DW];

TRUNCATE TABLE Ticket.Extract;

SET  @StringSQL = 'SELECT	ClubID, TicketCode, Ticketvalue, PrintingDate, PrintingMachine, PrintingMachineID , PayOutDate, PayOutMachine, PayOutMachineID , IsPrintingCashDesk , IsPaidCashDesk, ExpireDate,	EventDate, MhMachine, MhMachineID, CreationChangeDate
				   FROM [' + @LinkedServer + '].AGS_ETL.[Ticket].Extract;'
INSERT INTO Ticket.[Extract](ClubID, TicketCode, Ticketvalue, PrintingDate, PrintingMachine, PrintingMachineID , PayOutDate, PayOutMachine, PayOutMachineID , IsPrintingCashDesk , IsPaidCashDesk , ExpireDate, 	EventDate, MhMachine, MhMachineID, CreationChangeDate)
EXEC(@StringSQL);

IF NOT @TicketCode IS NULL
   INSERT INTO [POM-DBA-DATA].[GMATICA_AGS_RawData_Elaborate_Stag_Agile].[TMP].[TicketStart](ClubID, TicketCode, TicketValue, PrintingData, PrintingMachine,PrintingMachineID,PayoutData,PayOutMachine, PayOutMachineID, IsPrintingCashDesk,[IsPaidCashDesk], EventDate, [MhMachine],[MhMachineID],CreationChangeDate, ExpireDate)
   SELECT  ClubID, TicketCode, TicketValue, PrintingDate, PrintingMachine,PrintingMachineID,PayOutDate, PayOutMachine, PayOutMachineID , IsPrintingCashDesk, [IsPaidCashDesk],EventDate, [MhMachine],[MhMachineID],CreationChangeDate, ExpireDate
   FROM Ticket.Extract
ELSE
   INSERT INTO [POM-DBA-DATA].[GMATICA_AGS_RawData_Elaborate_Stag_Agile].[TMP].[Ticket](TicketCode, TicketValue, PrintingData, PrintingMachine,PrintingMachineID, PayoutData,PayOutMachine, PayOutMachineID , IsPrintingCashDesk,[IsPaidCashDesk], EventDate,[MhMachine],[MhMachineID], CreationChangeDate, ExpireDate)
   SELECT  TicketCode, TicketValue, PrintingDate, PrintingMachine,PrintingMachineID,PayOutDate, PayOutMachine, PayOutMachineID , IsPrintingCashDesk,[IsPaidCashDesk], EventDate,[MhMachine],[MhMachineID], CreationChangeDate, ExpireDate
   FROM Ticket.Extract;

---------------------------------
-- Recordset di Uscita         --
---------------------------------
--SELECT @ReturnCode = ReturnCode, @ReturnMessage = ReturnMessage
--FROM @TableResult;

END