USE [GMATICA_AGS_RawData_Elaborate]
GO
/****** Object:  StoredProcedure [RAW].[LoadingALLReceipt]    Script Date: 19/07/2017 17:21:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [RAW].[LoadingALLReceipt]
@AllCludID bit = 0
AS
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: Maesa
Creation Date.......: 2014-10-29 
Description.........: Popola le tabelle dei ticket e degli mhr di tutti i ClubID

Revision			 
2014-08-28(Maesa)...........:
2015-12-12(Jena) ...........: Inserita la funzione ListAllTable2
2016-01-08(Jena) ...........: Aggiunta tabella [ETL].[DailyLoadingHeader]
2016-04-21(Jena) ...........: Inserito parametro @AllCludID
2016-08-18(Jena) ...........: Inserita funzione DailySituation()
2016-08-23(Jena) ...........: Inserito ciclo sulla chiamata [RAW].[LoadingTicketMatching]
2017-03-10(GA) ...........:	  Adeguata ai nuovi calcoli
Note
- Use [Tab size] = 3 and [Indent size] 3

------------------
-- Parameters   --
------------------	

------------------
-- Call Example --
------------------ 
EXEC [RAW].[LoadingALLReceipt]
*/
BEGIN
SET NOCOUNT ON;
DECLARE @ListaClubID TABLE (Riga SMALLINT IDENTITY(1,1), ClubID INT);
DECLARE @Riga SMALLINT = 1, @Righe SMALLINT, @ClubID varchar(20), @SearchTicketOffSet smallint, @SearchMHROffSet int, @DailyLoadingHeaderID int, @IterationNumber tinyint, @ErrorNumber int,
        @Today DATE = SYSDATETIME();  

-- Parametri Concessionario
SELECT @SearchTicketOffSet= SearchTicketOffSet, @SearchMHROffSet = SearchMHROffSet FROM [Config].[Table];

-- Tutte le tabelle RawData
IF @AllCludID = 0 
BEGIN
   INSERT INTO @ListaClubID (ClubID) 
	SELECT T1.ClubID FROM [DBA].[DailySituation]('ReceiptOutDate') T1 INNER JOIN
	[ETL].[LoadingRawDataSummary] T2 ON T2.ClubID = T1.ClubID ORDER BY T2.LastRunningReceiptDate
   SET @Righe = @@ROWCOUNT;
END;

IF @AllCludID = 1 
BEGIN
   INSERT INTO @ListaClubID (ClubID) --VALUES (1000015)
   SELECT ClubID FROM ETL.LoadingRawDataSummary ORDER BY ClubID;
   SET @Righe = @@ROWCOUNT;
END;
--
INSERT INTO [ETL].[DailyLoadingHeader](DailyLoadingHeaderType, DailyLoadingHeaderStartDate, DailyLoadingHeaderNumberClubID)
VALUES(3, SYSDATETIME(),@Righe); 
SET @DailyLoadingHeaderID = SCOPE_IDENTITY();

--Per ogni ClubID, Eseguo la LoadingDelta
WHILE @Riga <= @Righe
BEGIN
   SET @IterationNumber = 1; 
	SET @ClubID = (SELECT ClubID FROM @ListaClubID WHERE Riga = @Riga);

	--Creo la tabella dei Receipt se non esiste
    EXEC [DBA].[CreateTable]  @Table = 'Receipt', @ClubID = @ClubID

	------------------------
	-- Matching Ticket    --
	------------------------
   --WHILE @IterationNumber <= 10
   --BEGIN
      --SET @ErrorNumber = (SELECT COUNT(*) 
      --                    FROM [ETL].[DailyLoading]
      --                    WHERE DailyLoadingDate >= @Today AND DailyLoadingType = 3 AND DailyLoadingClubID = @ClubID);

   	EXEC [RAW].[LoadingTicketMatching] @ClubID = @ClubID

      -- Se non ci sono stati errori, esce
      --IF @ErrorNumber = (SELECT COUNT(*) 
      --                   FROM [ETL].[DailyLoading]
      --                   WHERE DailyLoadingDate >= @Today AND DailyLoadingType = 3 AND DailyLoadingClubID = @ClubID)
      --   BREAK;

   --   SET @IterationNumber+=1;
   --END
	------------------------
	-- Matching MHR       --
	------------------------
	EXEC [RAW].[LoadingMHRMatching] @ClubID = @ClubID
	
	SET @Riga += 1;
END;

UPDATE [ETL].[DailyLoadingHeader]
SET DailyLoadingHeaderEndDate = SYSDATETIME()
WHERE DailyLoadingHeaderID = @DailyLoadingHeaderID;

END



