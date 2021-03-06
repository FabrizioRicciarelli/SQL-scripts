/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: Fabrizio Ricciarelli 
Creation Date.......: 2018-01-15
Description.........: Estrazione tickets per RawData direttamente da macchine PIN

Revision			 

Note
- Use [Tab size] = 3 and [Indent size] = 3 (Instert spaces)

------------------
-- Parameters   --
------------------	
@ConcessionaryID	-- OBBLIGATORIO, DETERMINA IL CONCESSIONARIO
@ClubID				-- FACOLTATIVO, DETERMINA LA SALA
@TicketCode			-- FACOLTATIVO, ELENCO DI TICKETS (MIXATI, SIA MHx CHE NON), SEPARATI DA VIRGOLE, OPPURE TICKET SINGOLO (SIA MHx CHE NON) *** SE NON SPECIFICATO, VALORIZZARE IL PARAMETRO @Threshold ***
@TicketValue		-- FACOLTATIVO, VALORE ESATTO DEL TICKET
@Threshold			-- FACOLTATIVO, VALORE MINIMO DEL TICKET *** SE NON SPECIFICATO, VALORIZZARE IL PARAMETRO @TicketCode ***
@FromDate			-- FACOLTATIVO, DATA INIZIALE MINIMA DALLA QUALE INIZIARE LA RICERCA
@ToDate				-- FACOLTATIVO, SE NON VALORIZZATO, QUANDO AL PARAMETRO @FromDate VIENE ASSEGNATO UN VALORE, IL PARAMETRO @ToDate CONTERRA' UNA DATA IL CUI GIORNO CORRISPONDE A QUELLO SUCCESSIVO SPECIFICATO IN @FromDate
@IsMhx				-- FACOLTATIVO, SE VALORIZZATO A 0 (FORZATURA) NON EFFETTUA LA RICERCA PER TICKETS NON-MHx (SCARTO APRIORISTICO)
@ISpaid				-- FACOLTATIVO, SE VALORIZZATO, RICERCHERA' SOLO QUEI TICKETS IL CUI CAMPO PayoutUserID SIA STATO VALORIZZATO (NON NULLO) - VALE SOLO PER I TICKETS NON-MHx
@LoadTicketToCalc	-- FACOLTATIVO
@XMLtickets 		-- OUTPUT

------------------
-- Call Example --
------------------

-- RICERCA DI UN SINGOLO TICKET NON-MHx
------------------------------------------------------------------------------------		
DECLARE
-------------------------------------------------------------------------------------------
-- 1. DEFINIZIONE DEL VALORE DEL TICKET DA LAVORARE
-------------------------------------------------------------------------------------------
		@TicketCode				varchar(50) = '427102895993931934'	-- IL PARAMETRO IN INGRESSO DELLA SP ETL.ExtractTicketsFromPIN "TicketCode" E' IN REALTA' UN varchar(MAX) POICHE' ACCETTA IN INGRESSO UN CSV DI TICKETS
		
		,@ConcessionaryID		tinyint	-- SARA' RECUPERATO DA @XConfigTable
		,@ClubID				int 	-- SARA' RECUPERATO DA @XTMPTicketStart
	
		,@XConfigTable			XML -- ex Config.Table (DA RIEMPIRE IN CIASCUNA SESSIONE DI CALCOLO, PRIMA DEL RECUPERO DEL TICKET E DEI RELATIVI RAWDATA)
		,@XTMPTicketStart		XML -- VUOTO (SARA' POPOLATO DALLA SP ETL.ExtractTicketsFromPIN)
		,@XTMPTicketDateRange	XML -- VUOTO (Conterrà tutti i tickets nell'intervallo di date specificato)
		,@XTFWIN				XML -- VUOTO (SARA' POPOLATO DALLA SP ETL.ExtractTicketsFromPIN)
		,@XTMPRawData_View		XML -- VUOTO (SARA' POPOLATO DALLA SP ETL.ExtractRawDataFromPOMMON)

		,@OFFSETOUT				int 
		,@PrintingDate			datetime2(0)
		,@PayoutDate			datetime2(0)
		,@StrPrintingMachineID	varchar(20)
		,@TimeStart				datetime
		,@TimeEnd				datetime
		,@SmallTimeStart		varchar(10)
		,@SmallTimeEnd			varchar(10)


-------------------------------------------------------------------------------------------
-- 2. POPOLAMENTO DEL CONTENITORE DEI PARAMETRI DI CONFIGURAZIONE DELLA SESSIONE DI CALCOLO
-------------------------------------------------------------------------------------------
SET		@XConfigTable =	ETL.WriteXCONFIG(
			@XConfigTable
			,7				-- ConcessionaryID
			,'POM-MON01'	-- Position
			,25				-- OffSetIN
			,45				-- OffSetOut
			,7200			-- OffSetMh
			,50				-- MinVltEndCredit
			,'GMatica'		-- ConcessionaryName
			,1				-- FlagDbArchive
			,1				-- OffsetRawData
		) 

-------------------------------------------------------------------------------------------
-- 3. POPOLAMENTO DEI PARAMETRI ESSENZIALI PER L'ESTRAZIONE DEI DATI RELATIVI AL TICKET
-------------------------------------------------------------------------------------------
SELECT
		-- PER ESTRAZIONE TICKETS
		@ConcessionaryID = ConcessionaryID
		
		-- PER ESTRAZIONE RAWDATA
		,@OFFSETOUT = offsetout * 1000
FROM	ETL.GetAllXConfig(@XConfigTable)
		

-------------------------------------------------------------------------------------------
-- 4. ESTRAZIONE DI TUTTI I PARAMETRI RELATIVI AL TICKET SELEZIONATO
-------------------------------------------------------------------------------------------
EXEC	ETL.ExtractTicketsFromPIN
		@ConcessionaryID = @ConcessionaryID -- OBBLIGATORIO, DETERMINA IL CONCESSIONARIO
		,@ClubID = NULL	-- FACOLTATIVO, DETERMINA LA SALA
		,@TicketCode = @TicketCode -- FACOLTATIVO, ELENCO DI TICKETS (MIXATI, SIA MHx CHE NON), SEPARATI DA VIRGOLE, OPPURE TICKET SINGOLO (SIA MHx CHE NON) *** SE NON SPECIFICATO, VALORIZZARE IL PARAMETRO @Threshold *** 
		,@TicketValue = NULL -- FACOLTATIVO, VALORE ESATTO DEL TICKET
		,@Threshold = NULL -- FACOLTATIVO, VALORE MINIMO DEL TICKET *** SE NON SPECIFICATO, VALORIZZARE IL PARAMETRO @TicketCode ***
		,@FromDate = NULL -- DATA INIZIALE MINIMA DALLA QUALE INIZIARE LA RICERCA
		,@ToDate = NULL	-- FACOLTATIVO, SE NON VALORIZZATO, QUANDO AL PARAMETRO @FromDate VIENE ASSEGNATO UN VALORE, IL PARAMETRO @ToDate CONTERRA' UNA DATA IL CUI GIORNO CORRISPONDE A QUELLO SUCCESSIVO SPECIFICATO IN @FromDate
		,@IsMhx = NULL -- FACOLTATIVO, SE VALORIZZATO A 0 (FORZATURA) NON EFFETTUA LA RICERCA PER TICKETS NON-MHx (SCARTO APRIORISTICO)
		,@ISpaid = NULL -- FACOLTATIVO, SE VALORIZZATO, RICERCHERA' SOLO QUEI TICKETS IL CUI CAMPO PayoutUserID SIA STATO VALORIZZATO (NON NULLO) - VALE SOLO PER I TICKETS NON-MHx
		,@LoadTicketToCalc = NULL
		,@XMLTICKETS = @XTMPTicketStart OUTPUT

-------------------------------------------------------------------------------------------
-- 5. ESTRAZIONE DI TUTTI I PARAMETRI RELATIVI AL TICKET SELEZIONATO PER CREAZIONE FILTRO
--    PER SUCCESSIVA ESTRAZIONE DEI RAWDATA
-------------------------------------------------------------------------------------------
SELECT	
		@ClubID = ClubID
		,@StrPrintingmachineID = CAST(ISNULL(PrintingmachineID,0) AS varchar(20))
		,@PrintingDate = PrintingDate	-- TicketCreationTime
		,@PayoutDate = PayoutDate		-- TicketPayoutTime
FROM	ETL.GetAllXTICKETS(@XTMPTicketStart)


-------------------------------------------------------------------------------------------
-- 6. DETERMINAZIONE INTERVALLI DATE: APPLICAZIONE DEGLI OFFSET ALLE DATE
-------------------------------------------------------------------------------------------
SELECT	
		@TimeStart = DATEADD(SECOND, -@OFFSETOUT, @PrintingDate)
		,@TimeEnd = DATEADD(SECOND, @OFFSETOUT, @PrintingDate)

-------------------------------------------------------------------------------------------
-- 7. ESTRAZIONE DEI RAWDATA IN BASE AL FILTRO
-------------------------------------------------------------------------------------------
SELECT	'TICKETSTART DATA' AS TABELLA, *
FROM	ETL.GetAllXTICKETS(@XTMPTicketStart)

--SELECT @TimeStart AS TimeStart, @TimeEnd AS TimeEnd

SELECT	
		@SmallTimeStart = CONVERT(char(10),@TimeStart,112)
		,@SmallTimeEnd = CONVERT(char(10),@TimeEnd,112)

--SELECT @SmallTimeStart AS SmallTimeStart, @SmallTimeEnd AS SmallTimeEnd

SELECT 
		@TimeStart =  DATEADD(DD, -5, CONVERT(Datetime, @SmallTimeStart, 120))
		,@TimeEnd = DATEADD(DD, 5, CONVERT(Datetime, @SmallTimeEnd, 120))

SELECT @TimeStart AS TimeStart, @TimeEnd AS TimeEnd

-------------------------------------------------------------------------------------------
-- 8. ESTRAZIONE DI TUTTI I TICKETS MHx NELL'INTERVALLO DI DATE SPECIFICATO DAL TICKETSTART
-------------------------------------------------------------------------------------------
EXEC	ETL.ExtractTicketsFromPIN
		@ConcessionaryID = @ConcessionaryID -- OBBLIGATORIO, DETERMINA IL CONCESSIONARIO
		,@ClubID = @ClubID	-- FACOLTATIVO, DETERMINA LA SALA
		,@TicketCode = NULL -- FACOLTATIVO, ELENCO DI TICKETS (MIXATI, SIA MHx CHE NON), SEPARATI DA VIRGOLE, OPPURE TICKET SINGOLO (SIA MHx CHE NON) *** SE NON SPECIFICATO, VALORIZZARE IL PARAMETRO @Threshold *** 
		,@TicketValue = NULL -- FACOLTATIVO, VALORE ESATTO DEL TICKET
		,@Threshold = NULL -- FACOLTATIVO, VALORE MINIMO DEL TICKET *** SE NON SPECIFICATO, VALORIZZARE IL PARAMETRO @TicketCode ***
		,@FromDate = @TimeStart -- DATA INIZIALE MINIMA DALLA QUALE INIZIARE LA RICERCA
		,@ToDate = @TimeEnd	-- FACOLTATIVO, SE NON VALORIZZATO, QUANDO AL PARAMETRO @FromDate VIENE ASSEGNATO UN VALORE, IL PARAMETRO @ToDate CONTERRA' UNA DATA IL CUI GIORNO CORRISPONDE A QUELLO SUCCESSIVO SPECIFICATO IN @FromDate
		,@IsMhx = 1 -- FACOLTATIVO, SE VALORIZZATO A 0 (FORZATURA) NON EFFETTUA LA RICERCA PER TICKETS NON-MHx (SCARTO APRIORISTICO)
		,@ISpaid = NULL -- FACOLTATIVO, SE VALORIZZATO, RICERCHERA' SOLO QUEI TICKETS IL CUI CAMPO PayoutUserID SIA STATO VALORIZZATO (NON NULLO) - VALE SOLO PER I TICKETS NON-MHx
		,@LoadTicketToCalc = NULL
		,@XMLTICKETS = @XTMPTicketDateRange OUTPUT

SELECT	'TICKETdateRange MHx' AS TABELLA, *
FROM	ETL.GetAllXTICKETS(@XTMPTicketDateRange)

-------------------------------------------------------------------------------------------
-- 9. ESTRAZIONE DI TUTTI I TICKETS NON-MHx NELL'INTERVALLO DI DATE SPECIFICATO DAL TICKETSTART
-------------------------------------------------------------------------------------------
EXEC	ETL.ExtractTicketsFromPIN
		@ConcessionaryID = @ConcessionaryID -- OBBLIGATORIO, DETERMINA IL CONCESSIONARIO
		,@ClubID = @ClubID	-- FACOLTATIVO, DETERMINA LA SALA
		,@TicketCode = NULL -- FACOLTATIVO, ELENCO DI TICKETS (MIXATI, SIA MHx CHE NON), SEPARATI DA VIRGOLE, OPPURE TICKET SINGOLO (SIA MHx CHE NON) *** SE NON SPECIFICATO, VALORIZZARE IL PARAMETRO @Threshold *** 
		,@TicketValue = NULL -- FACOLTATIVO, VALORE ESATTO DEL TICKET
		,@Threshold = NULL -- FACOLTATIVO, VALORE MINIMO DEL TICKET *** SE NON SPECIFICATO, VALORIZZARE IL PARAMETRO @TicketCode ***
		,@FromDate = @TimeStart -- DATA INIZIALE MINIMA DALLA QUALE INIZIARE LA RICERCA
		,@ToDate = @TimeEnd	-- FACOLTATIVO, SE NON VALORIZZATO, QUANDO AL PARAMETRO @FromDate VIENE ASSEGNATO UN VALORE, IL PARAMETRO @ToDate CONTERRA' UNA DATA IL CUI GIORNO CORRISPONDE A QUELLO SUCCESSIVO SPECIFICATO IN @FromDate
		,@IsMhx = 0 -- FACOLTATIVO, SE VALORIZZATO A 0 (FORZATURA) NON EFFETTUA LA RICERCA PER TICKETS NON-MHx (SCARTO APRIORISTICO)
		,@ISpaid = NULL -- FACOLTATIVO, SE VALORIZZATO, RICERCHERA' SOLO QUEI TICKETS IL CUI CAMPO PayoutUserID SIA STATO VALORIZZATO (NON NULLO) - VALE SOLO PER I TICKETS NON-MHx
		,@LoadTicketToCalc = NULL
		,@XMLTICKETS = @XTMPTicketDateRange OUTPUT

SELECT	'TICKETdateRange NON-MHx' AS TABELLA, *
FROM	ETL.GetAllXTICKETS(@XTMPTicketDateRange)


EXEC [ETL].[ExtractRawDataFromPOMMON] @ConcessionaryID, @ClubID, @StrPrintingmachineID, @TimeStart, @TimeEnd, NULL, @XTMPRawData_View = @XTMPRawData_View OUTPUT
SELECT 'FIRST RAWDATA FOUND' AS TABELLA, * FROM ETL.GetAllXRAW(@XTMPRawData_View)
WHERE MachineTime = @PrintingDate

--EXEC [ETL].[ExtractRawDataFromPOMMON] @ConcessionaryID, @ClubID, @StrPrintingmachineID, @TimeStart, @TimeEnd, 'TOTALOUT > 0', @XTMPRawData_View = @XTMPRawData_View OUTPUT
--SELECT * FROM ETL.GetAllXRAW(@XTMPRawData_View)

------------------------------------------------------------------------------------



-- RICERCA DI UN SINGOLO TICKET NON-MHx, SENZA CONOSCERE LA SALA
------------------------------------------------------------------------------------		
DECLARE	
		@XTICKETS XML -- VUOTO
		,@XTFWIN XML -- VUOTO
EXEC	ETL.ExtractTicketsFromPIN
		@ConcessionaryID = 7 -- OBBLIGATORIO, DETERMINA IL CONCESSIONARIO
		,@ClubID = NULL -- FACOLTATIVO, DETERMINA LA SALA
		,@TicketCode = '427102895993931934' -- FACOLTATIVO, ELENCO DI TICKETS (MIXATI, SIA MHx CHE NON), SEPARATI DA VIRGOLE, OPPURE TICKET SINGOLO (SIA MHx CHE NON) *** SE NON SPECIFICATO, VALORIZZARE IL PARAMETRO @Threshold *** 
		,@TicketValue = NULL -- FACOLTATIVO, VALORE ESATTO DEL TICKET
		,@Threshold = NULL -- FACOLTATIVO, VALORE MINIMO DEL TICKET *** SE NON SPECIFICATO, VALORIZZARE IL PARAMETRO @TicketCode ***
		,@FromDate = NULL -- DATA INIZIALE MINIMA DALLA QUALE INIZIARE LA RICERCA
		,@ToDate = NULL	-- FACOLTATIVO, SE NON VALORIZZATO, QUANDO AL PARAMETRO @FromDate VIENE ASSEGNATO UN VALORE, IL PARAMETRO @ToDate CONTERRA' UNA DATA IL CUI GIORNO CORRISPONDE A QUELLO SUCCESSIVO SPECIFICATO IN @FromDate
		,@IsMhx = NULL -- FACOLTATIVO, SE VALORIZZATO A 0 (FORZATURA) NON EFFETTUA LA RICERCA PER TICKETS NON-MHx (SCARTO APRIORISTICO)
		,@ISpaid = NULL -- FACOLTATIVO, SE VALORIZZATO, RICERCHERA' SOLO QUEI TICKETS IL CUI CAMPO PayoutUserID SIA STATO VALORIZZATO (NON NULLO) - VALE SOLO PER I TICKETS NON-MHx
		,@LoadTicketToCalc = NULL
		,@XMLTICKETS = @XTICKETS OUTPUT
SELECT	*
FROM	ETL.GetAllXTICKETS(@XTICKETS)
------------------------------------------------------------------------------------


-- RICERCA DI TUTTI I TICKETS (NON-MHx E MHx), PER SALA, IN UN INTERVALLO DI DATE
------------------------------------------------------------------------------------		
DECLARE	
		@XTICKETS XML -- VUOTO
		,@XTFWIN XML -- VUOTO
EXEC	ETL.ExtractTicketsFromPIN
		@ConcessionaryID = 7 -- OBBLIGATORIO, DETERMINA IL CONCESSIONARIO
		,@ClubID = 1000252 -- FACOLTATIVO, DETERMINA LA SALA
		,@TicketCode = NULL -- FACOLTATIVO, ELENCO DI TICKETS (MIXATI, SIA MHx CHE NON), SEPARATI DA VIRGOLE, OPPURE TICKET SINGOLO (SIA MHx CHE NON) *** SE NON SPECIFICATO, VALORIZZARE IL PARAMETRO @Threshold *** 
		,@TicketValue = NULL -- FACOLTATIVO, VALORE ESATTO DEL TICKET
		,@Threshold = NULL -- FACOLTATIVO, VALORE MINIMO DEL TICKET *** SE NON SPECIFICATO, VALORIZZARE IL PARAMETRO @TicketCode ***
		,@FromDate = '20170701' -- DATA INIZIALE MINIMA DALLA QUALE INIZIARE LA RICERCA
		,@ToDate = '20170705'	-- FACOLTATIVO, SE NON VALORIZZATO, QUANDO AL PARAMETRO @FromDate VIENE ASSEGNATO UN VALORE, IL PARAMETRO @ToDate CONTERRA' UNA DATA IL CUI GIORNO CORRISPONDE A QUELLO SUCCESSIVO SPECIFICATO IN @FromDate
		,@IsMhx = 1 -- FACOLTATIVO, SE VALORIZZATO A 0 (FORZATURA) NON EFFETTUA LA RICERCA PER TICKETS NON-MHx (SCARTO APRIORISTICO)
		,@ISpaid = NULL -- FACOLTATIVO, SE VALORIZZATO, RICERCHERA' SOLO QUEI TICKETS IL CUI CAMPO PayoutUserID SIA STATO VALORIZZATO (NON NULLO) - VALE SOLO PER I TICKETS NON-MHx
		,@LoadTicketToCalc = NULL
		,@XMLTICKETS = @XTICKETS OUTPUT
SELECT	*
FROM	ETL.GetAllXTICKETS(@XTICKETS)
------------------------------------------------------------------------------------







-- RICERCA DI SOLI TICKET NON-MHx
------------------------------------------------------------------------------------		
DECLARE	
		@XTICKETS XML -- VUOTO
		,@XTFWIN XML -- VUOTO
EXEC	ETL.ExtractTicketsFromPIN
		@ConcessionaryID = 7 -- OBBLIGATORIO, DETERMINA IL CONCESSIONARIO
		,@ClubID = NULL	-- FACOLTATIVO, DETERMINA LA SALA
		,@TicketCode = '427102895993931934,375559646310240944,553637305458476249,148239190679638755,96415771688841631' -- FACOLTATIVO, ELENCO DI TICKETS (MIXATI, SIA MHx CHE NON), SEPARATI DA VIRGOLE, OPPURE TICKET SINGOLO (SIA MHx CHE NON) *** SE NON SPECIFICATO, VALORIZZARE IL PARAMETRO @Threshold *** 
		,@TicketValue = NULL -- FACOLTATIVO, VALORE ESATTO DEL TICKET
		,@Threshold = NULL -- FACOLTATIVO, VALORE MINIMO DEL TICKET *** SE NON SPECIFICATO, VALORIZZARE IL PARAMETRO @TicketCode ***
		,@FromDate = NULL -- DATA INIZIALE MINIMA DALLA QUALE INIZIARE LA RICERCA
		,@ToDate = NULL	-- FACOLTATIVO, SE NON VALORIZZATO, QUANDO AL PARAMETRO @FromDate VIENE ASSEGNATO UN VALORE, IL PARAMETRO @ToDate CONTERRA' UNA DATA IL CUI GIORNO CORRISPONDE A QUELLO SUCCESSIVO SPECIFICATO IN @FromDate
		,@IsMhx = NULL -- FACOLTATIVO, SE VALORIZZATO A 0 (FORZATURA) NON EFFETTUA LA RICERCA PER TICKETS NON-MHx (SCARTO APRIORISTICO)
		,@ISpaid = NULL -- FACOLTATIVO, SE VALORIZZATO, RICERCHERA' SOLO QUEI TICKETS IL CUI CAMPO PayoutUserID SIA STATO VALORIZZATO (NON NULLO) - VALE SOLO PER I TICKETS NON-MHx
		,@LoadTicketToCalc = NULL
		,@XMLTICKETS = @XTICKETS OUTPUT
SELECT	*
FROM	ETL.GetAllXTICKETS(@XTICKETS)
------------------------------------------------------------------------------------


-- RICERCA MISTA, TICKET NORMALI E MHx, MULTISALA
------------------------------------------------------------------------------------
DECLARE	
		@XTICKETS XML -- VUOTO
		,@XTFWIN XML -- VUOTO
EXEC	ETL.ExtractTicketsFromPIN
		@ConcessionaryID = 7 -- OBBLIGATORIO, DETERMINA IL CONCESSIONARIO
		,@ClubID = NULL	-- FACOLTATIVO, DETERMINA LA SALA
		,@TicketCode = '479194386004564610,369456253604773261,525764475876923475,181340809208629093,1000002MHR201103140009' -- FACOLTATIVO, ELENCO DI TICKETS (MIXATI, SIA MHx CHE NON), SEPARATI DA VIRGOLE, OPPURE TICKET SINGOLO (SIA MHx CHE NON) *** SE NON SPECIFICATO, VALORIZZARE IL PARAMETRO @Threshold ***  
		,@TicketValue = NULL -- FACOLTATIVO, VALORE ESATTO DEL TICKET
		,@Threshold = NULL -- FACOLTATIVO, VALORE MINIMO DEL TICKET *** SE NON SPECIFICATO, VALORIZZARE IL PARAMETRO @TicketCode ***
		,@FromDate = NULL -- DATA INIZIALE MINIMA DALLA QUALE INIZIARE LA RICERCA
		,@ToDate = NULL	-- FACOLTATIVO, SE NON VALORIZZATO, QUANDO AL PARAMETRO @FromDate VIENE ASSEGNATO UN VALORE, IL PARAMETRO @ToDate CONTERRA' UNA DATA IL CUI GIORNO CORRISPONDE A QUELLO SUCCESSIVO SPECIFICATO IN @FromDate
		,@IsMhx = NULL -- FACOLTATIVO, SE VALORIZZATO A 0 (FORZATURA) NON EFFETTUA LA RICERCA PER TICKETS NON-MHx (SCARTO APRIORISTICO)
		,@ISpaid = NULL -- FACOLTATIVO, SE VALORIZZATO, RICERCHERA' SOLO QUEI TICKETS IL CUI CAMPO PayoutUserID SIA STATO VALORIZZATO (NON NULLO) - VALE SOLO PER I TICKETS NON-MHx
		,@LoadTicketToCalc = NULL
		,@XMLTICKETS = @XTICKETS OUTPUT
SELECT	*
FROM	ETL.GetAllXTICKETS(@XTICKETS)
------------------------------------------------------------------------------------


-- RICERCA PER VALORI DI TICKET SUPERIORI A 500€, SALA 1000002		
------------------------------------------------------------------------------------
DECLARE	
		@XTICKETS XML -- VUOTO
		,@XTFWIN XML -- VUOTO
EXEC	ETL.ExtractTicketsFromPIN
		@ConcessionaryID = 7 -- OBBLIGATORIO, DETERMINA IL CONCESSIONARIO
		,@ClubID = 1000002	-- FACOLTATIVO, DETERMINA LA SALA
		,@TicketCode = NULL -- FACOLTATIVO, ELENCO DI TICKETS (MIXATI, SIA MHx CHE NON), SEPARATI DA VIRGOLE, OPPURE TICKET SINGOLO (SIA MHx CHE NON) *** SE NON SPECIFICATO, VALORIZZARE IL PARAMETRO @Threshold ***  
		,@TicketValue = NULL -- FACOLTATIVO, VALORE ESATTO DEL TICKET
		,@Threshold = 50001 -- FACOLTATIVO, VALORE MINIMO DEL TICKET (50001 = 500,01) *** SE NON SPECIFICATO, VALORIZZARE IL PARAMETRO @TicketCode ***
		,@FromDate = NULL -- DATA INIZIALE MINIMA DALLA QUALE INIZIARE LA RICERCA
		,@ToDate = NULL	-- FACOLTATIVO, SE NON VALORIZZATO, QUANDO AL PARAMETRO @FromDate VIENE ASSEGNATO UN VALORE, IL PARAMETRO @ToDate CONTERRA' UNA DATA IL CUI GIORNO CORRISPONDE A QUELLO SUCCESSIVO SPECIFICATO IN @FromDate
		,@IsMhx = NULL -- FACOLTATIVO, SE VALORIZZATO A 0 (FORZATURA) NON EFFETTUA LA RICERCA PER TICKETS NON-MHx (SCARTO APRIORISTICO)
		,@ISpaid = NULL -- FACOLTATIVO, SE VALORIZZATO, RICERCHERA' SOLO QUEI TICKETS IL CUI CAMPO PayoutUserID SIA STATO VALORIZZATO (NON NULLO) - VALE SOLO PER I TICKETS NON-MHx
		,@LoadTicketToCalc = NULL
		,@XMLTICKETS = @XTICKETS OUTPUT
SELECT	*
FROM	ETL.GetAllXTICKETS(@XTICKETS)
------------------------------------------------------------------------------------


-- RICERCA PER VALORI DI TICKET SUPERIORI A 500€, SALA 1000002, A PARTIRE DAL 17/11/2017
-- *** RIEMPIE ANCHE L'OGGETTO @XMLTTFORWARDIN ***		
------------------------------------------------------------------------------------
DECLARE	
		@XTICKETS XML -- VUOTO
		,@XTFWIN XML -- VUOTO
EXEC	ETL.ExtractTicketsFromPIN
		@ConcessionaryID = 7 -- OBBLIGATORIO, DETERMINA IL CONCESSIONARIO
		,@ClubID = 1000002	-- FACOLTATIVO, DETERMINA LA SALA
		,@TicketCode = NULL -- FACOLTATIVO, ELENCO DI TICKETS (MIXATI, SIA MHx CHE NON), SEPARATI DA VIRGOLE, OPPURE TICKET SINGOLO (SIA MHx CHE NON) *** SE NON SPECIFICATO, VALORIZZARE IL PARAMETRO @Threshold ***  
		,@TicketValue = NULL -- FACOLTATIVO, VALORE ESATTO DEL TICKET
		,@Threshold = 50001 -- FACOLTATIVO, VALORE MINIMO DEL TICKET (50001 = 500,01) *** SE NON SPECIFICATO, VALORIZZARE IL PARAMETRO @TicketCode ***
		,@FromDate = '20171117' -- DATA INIZIALE MINIMA DALLA QUALE INIZIARE LA RICERCA
		,@ToDate = '20181231'	-- FACOLTATIVO, SE NON VALORIZZATO, QUANDO AL PARAMETRO @FromDate VIENE ASSEGNATO UN VALORE, IL PARAMETRO @ToDate CONTERRA' UNA DATA IL CUI GIORNO CORRISPONDE A QUELLO SUCCESSIVO SPECIFICATO IN @FromDate
		,@IsMhx = NULL -- FACOLTATIVO, SE VALORIZZATO A 0 (FORZATURA) NON EFFETTUA LA RICERCA PER TICKETS NON-MHx (SCARTO APRIORISTICO)
		,@ISpaid = NULL -- FACOLTATIVO, SE VALORIZZATO, RICERCHERA' SOLO QUEI TICKETS IL CUI CAMPO PayoutUserID SIA STATO VALORIZZATO (NON NULLO) - VALE SOLO PER I TICKETS NON-MHx
		,@LoadTicketToCalc = 1 -- *** RIEMPIE ANCHE L'OGGETTO @XMLTTFORWARDIN ***
		,@XMLTICKETS = @XTICKETS OUTPUT
SELECT	*
FROM	ETL.GetAllXTICKETS(@XTICKETS)
--WHERE	payoutmachine IS NOT NULL


-- RICERCA PER VALORI DI TICKET SUPERIORI A 500€, SALA 1000002, A PARTIRE DAL 17/11/2017 DI TIPO MHX
------------------------------------------------------------------------------------
DECLARE	
		@XTICKETS XML -- VUOTO
		,@XTFWIN XML -- VUOTO
EXEC	ETL.ExtractTicketsFromPIN
		@ConcessionaryID = 7 -- OBBLIGATORIO, DETERMINA IL CONCESSIONARIO
		,@ClubID = 1000002	-- FACOLTATIVO, DETERMINA LA SALA
		,@TicketCode = NULL -- FACOLTATIVO, ELENCO DI TICKETS (MIXATI, SIA MHx CHE NON), SEPARATI DA VIRGOLE, OPPURE TICKET SINGOLO (SIA MHx CHE NON) *** SE NON SPECIFICATO, VALORIZZARE IL PARAMETRO @Threshold ***  
		,@TicketValue = NULL -- FACOLTATIVO, VALORE ESATTO DEL TICKET
		,@Threshold = 50001 -- FACOLTATIVO, VALORE MINIMO DEL TICKET (50001 = 500,01) *** SE NON SPECIFICATO, VALORIZZARE IL PARAMETRO @TicketCode ***
		,@FromDate = '20171117' -- DATA INIZIALE MINIMA DALLA QUALE INIZIARE LA RICERCA
		,@ToDate = '20181231'	-- FACOLTATIVO, SE NON VALORIZZATO, QUANDO AL PARAMETRO @FromDate VIENE ASSEGNATO UN VALORE, IL PARAMETRO @ToDate CONTERRA' UNA DATA IL CUI GIORNO CORRISPONDE A QUELLO SUCCESSIVO SPECIFICATO IN @FromDate
		,@IsMhx = 1 -- FACOLTATIVO, SE VALORIZZATO A 0 (FORZATURA) NON EFFETTUA LA RICERCA PER TICKETS NON-MHx (SCARTO APRIORISTICO)
		,@ISpaid = NULL -- FACOLTATIVO, SE VALORIZZATO, RICERCHERA' SOLO QUEI TICKETS IL CUI CAMPO PayoutUserID SIA STATO VALORIZZATO (NON NULLO) - VALE SOLO PER I TICKETS NON-MHx
		,@LoadTicketToCalc = 1 -- *** RIEMPIE ANCHE L'OGGETTO @XMLTTFORWARDIN ***
		,@XMLTICKETS = @XTICKETS OUTPUT
SELECT	*
FROM	ETL.GetAllXTICKETS(@XTICKETS)
--WHERE	payoutmachine IS NOT NULL

------------------------------------------------------------------------------------
*/
ALTER PROC	[ETL].[ExtractTicketsFromPIN]
			@ConcessionaryID tinyint
			,@ClubID varchar(10) = NULL
			,@TicketCode varchar(max) = NULL
			,@TicketValue int = NULL
			,@FromDate datetime = NULL
			,@ToDate datetime = NULL
			,@IsMhx Bit = NULL
			,@ISpaid BIT = NULL
			,@Threshold int = NULL
			,@LoadTicketToCalc BIT = NULL
			,@XMLtickets XML = NULL OUTPUT
AS

SET XACT_ABORT ON; -- ATTIVARE (ON) PER ABILITARE LE TRANSAZIONI DISTRIBUITE

DECLARE
		@DEBUG bit = 0 -- VALORIZZARE AD 1 PER MOSTRARE IL COSTRUTTO DELLE QUERY DINAMICHE PIUTTOSTO CHE ESEGUIRLE 
		,@OUTERMOSTSQL Nvarchar(MAX) -- DA ESEGUIRE SU QUESTA MACCHINA
		,@OUTERSQL Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA POM-MON01
		,@INNERSQL Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA PIN
		,@ConcessionaryName Nvarchar(20)

		,@NOMHxTickets Nvarchar(MAX) = NULL -- CONTENITORE PER TICKETS NON-MHx
		,@MHxTickets Nvarchar(MAX) = NULL -- CONTENITORE PER TICKETS MHx
		,@STRINGTickets Nvarchar(MAX) = NULL -- TICKETS IN FORMA STRINGXML RITORNATI DALLE MACCHINE PIN
		,@MIXEDTickets Nvarchar(MAX) = '' -- TICKETS IN FORMA STRINGXML CONTENENTI TUTTI I TICKET OGGETTO DI RICERCA (LA SOMMA DI TUTTI I PEZZI RICERCATI, MHx E NON-MHx)

		,@QuotedFromDate Nvarchar(20)
		,@QuotedToDate Nvarchar(20)
		,@QuadQuotedFromDate Nvarchar(20)
		,@QuadQuotedToDate Nvarchar(20)

		,@innermostWhereCondition Nvarchar(MAX)
		,@outermostWhereCondition Nvarchar(MAX)
		,@TopRows Nvarchar(20) = NULL -- N'TOP 100000' -- MAX CENTOMILA RIGHE 
		,@NumRecord tinyint

		,@INPUTtickets ETL.TICKET_TYPE

BEGIN TRY
	-- IDENTIFICAZIONE DEL CONCESSIONARIO
	SELECT @ConcessionaryName = ETL.getConcessionaryName(@ConcessionaryID)

	-- FORMATTAZIONE DATE
	SELECT 
			@ToDate = ISNULL(@ToDate,Dateadd(day, 1, CAST(@FromDate AS DateTime))) -- se non è stata passata la data di arrivo come parametro, viene assunta come data il giorno successivo a quello della data di partenza 
			--,@QuotedFromDate = QUOTENAME(CONVERT(char(26), ISNULL(@FromDate, Space(0)), 126), NCHAR(39))
			--,@QuotedToDate = QUOTENAME(CONVERT(char(26), ISNULL(@ToDate, Space(0)), 126), NCHAR(39))
			,@QuotedFromDate = QUOTENAME(CONVERT(char(8), ISNULL(@FromDate, Space(0)), 112), NCHAR(39))
			,@QuotedToDate = QUOTENAME(CONVERT(char(8), ISNULL(@ToDate, Space(0)), 112), NCHAR(39))
	SELECT	
			@QuadQuotedFromDate = REPLACE(@QuotedFromDate,NCHAR(39),NCHAR(39)+NCHAR(39))
			,@QuadQuotedtODate = REPLACE(@QuotedToDate,NCHAR(39),NCHAR(39)+NCHAR(39))

	-- SPACCHETTAMENTO TICKETS MULTIPLI (DA VALORI SEPARATI DA VIRGOLE NEL PARAMETRO @TicketCode), CHE POTREBBERO ESSERE SIA MHx CHE NON
	-- OPPURE ASSEGNAZIONE DEL VALORE ALLA VARIABILE @TicketValue PER TICKET SINGOLO
	IF @TicketCode IS NOT NULL 
		BEGIN
			IF @TicketCode LIKE '%,%' -- TICKETS MULTIPLI
				BEGIN
					SELECT	
							@MHxTickets = MHxTickets
							,@NOMHxTickets = NOMHxTickets
					FROM	dbo.fnSeparateMHxTickets(@TicketCode) 
				END
			ELSE -- TICKET SINGOLO
				BEGIN
					SELECT
							@MHxTickets = CASE WHEN @TicketCode LIKE '%[a-zA-Z]%' THEN @TicketCode ELSE NULL END 	
							,@NOMHxTickets = CASE WHEN @TicketCode NOT LIKE '%[a-zA-Z]%' THEN @TicketCode ELSE NULL END
				END
		END

	---------------------------------------------------------
	-- RICERCA DEI TICKETS MULTIPLI NON-MHx 
	-- OPPURE DEL SINGOLO TICKET NON-MHx
	---------------------------------------------------------
	IF 
	(
		(
			ISNULL(@NOMHxTickets,'') != '' OR 
			ISNULL(@TicketValue,'') != '' OR
			ISNULL(@Threshold,'') != '' OR
			ISNULL(@FromDate,'') != ''
		)
		AND ISNULL(@TicketValue,'') NOT LIKE '%[a-zA-Z]%'
		--AND (@IsMHx IS NOT NULL AND @IsMHx != 0) -- SE QUESTO PARAMETRO E' VALORIZZATO A 0, SALTA LA RICERCA DEI TICKET NON MHx
	)
		BEGIN 

			-- DEFINIZIONE QUERY DA INVOCARE SU MACCHINE REMOTE
			SET @INNERSQL = [ETL].[BuildDynSQL_TicketsNoMHx] (@TopRows)
			SET @INNERSQL = REPLACE(@INNERSQL, NCHAR(39), NCHAR(39)+NCHAR(39))	-- rimpiazzo apici singoli con apici doppi per innesto query SQL dinamico

			-- APPOSIZIONE APICI IN PROSSIMITA' DI CIASCUN TICKET
			SET @NOMHxTickets = NCHAR(39)+NCHAR(39) + REPLACE(@NOMHxTickets, ',', NCHAR(39)+NCHAR(39) + ',' + NCHAR(39)+NCHAR(39)) + NCHAR(39)+NCHAR(39) 

			-- COMPOSIZIONE/FORMATTAZIONE WHERECONDITION
			SET	@innermostWhereCondition = 
				IIF(@ClubID IS NOT NULL, N' AND TD.ClubID = ' + @ClubID, N'') +
				IIF(@NOMHxTickets IS NOT NULL, N' AND TD.TicketID IN (' + @NOMHxTickets + N') ', N'') +
				IIF(@FromDate IS NOT NULL, N' AND ((CreationTime BETWEEN ' + @QuadQuotedFromDate + N' AND ' + @QuadQuotedToDate + N') OR (PayoutTime BETWEEN ' + @QuadQuotedFromDate + N' AND ' + @QuadQuotedToDate + N'))', N'') +
				IIF(@TicketValue IS NOT NULL,  N' AND CAST(((CashA+CashB+CashC) * 100) AS BIGINT) = ' + CAST(@TicketValue AS varchar(10)) + N' ', N'') +
				IIF(ISNULL(@ISpaid,0) = 1, N' AND PayoutUserID IS NOT NULL', N'') +
				IIF(@Threshold IS NOT NULL, 'AND CAST(((CashA+CashB+CashC) * 100) AS BIGINT) > ' + CAST(@Threshold AS varchar(10)), N'')

			SET	@innermostWhereCondition = REPLACE(@innermostWhereCondition,'  ', ' ') -- rimpiazzo doppi spazi con spazio singolo
			SET @innermostWhereCondition = REPLACE(@innermostWhereCondition, NCHAR(39), NCHAR(39)+NCHAR(39))	-- rimpiazzo apici singoli con apici doppi per innesto query SQL dinamico

			SET @INNERSQL = REPLACE(@INNERSQL, '$', @innermostWhereCondition) -- concatenazione QUERY e sua wherecondition 

			IF @DEBUG = 1
				BEGIN
					PRINT(@INNERSQL)
					PRINT(@OUTERSQL)
				END
			ELSE
				BEGIN
					SET		@OUTERSQL =	N'SELECT * FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + @INNERSQL + ''')'
					SET		@OUTERMOSTSQL = ETL.BuildDynSQL_XmlWrapper(@OUTERSQL,'TICKETS')
					--PRINT(@OUTERMOSTSQL)
					EXEC	sp_executesqL @OUTERMOSTSQL, N'@returnValue Nvarchar(MAX) OUT', @returnValue=@STRINGTickets OUT
					SET		@MIXEDTickets += ISNULL(@STRINGTickets,'')
				END
		END

	---------------------------------------------------------
	-- RICERCA DEI TICKETS MULTIPLI MHx 
	-- OPPURE DEL SINGOLO TICKET MHx
	---------------------------------------------------------
	IF ISNULL(@MHxTickets,'') != ''
	OR ISNULL(@IsMhx,0) = 1
	OR ISNULL(@TicketValue,'') LIKE '%[a-zA-Z]%'
		BEGIN 

			-- DEFINIZIONE QUERY DA INVOCARE SU MACCHINE REMOTE
			SET @INNERSQL = [ETL].[BuildDynSQL_TicketsMHx] (@TopRows)
			SET @INNERSQL = REPLACE(@INNERSQL, NCHAR(39), NCHAR(39)+NCHAR(39))	-- rimpiazzo apici singoli con apici doppi per innesto query SQL dinamico

			-- APPOSIZIONE APICI IN PROSSIMITA' DI CIASCUN TICKET
			SET @MHxTickets = NCHAR(39)+NCHAR(39) + REPLACE(@MHxTickets, ',', NCHAR(39)+NCHAR(39) + ',' + NCHAR(39)+NCHAR(39)) + NCHAR(39)+NCHAR(39) 

			-- COMPOSIZIONE/FORMATTAZIONE WHERECONDITION
			SET	@innermostWhereCondition = 
				IIF(@ClubID IS NOT NULL, N' AND ST.ClubID = ' + @ClubID, N'') +
				IIF(@MHxTickets IS NOT NULL, N' AND ST.Receipt IN (' + @MHxTickets + ') ', N'') -- CRITERIO DI RICERCA DINAMICO SU TICKETS MHx MULTIPLI
			SET	@innermostWhereCondition = REPLACE(@innermostWhereCondition,'  ', ' ') -- rimpiazzo doppi spazi con spazio singolo
			SET @innermostWhereCondition = REPLACE(@innermostWhereCondition, NCHAR(39), NCHAR(39)+NCHAR(39))	-- rimpiazzo apici singoli con apici doppi per innesto query SQL dinamico
				
			SET	@outermostWhereCondition = ''

			SET @INNERSQL = REPLACE(@INNERSQL, '$', @innermostWhereCondition) -- concatenazione QUERY e sua wherecondition 
			SET @INNERSQL = REPLACE(@INNERSQL, '#', @outermostWhereCondition) -- concatenazione QUERY e sua wherecondition 

			IF @DEBUG = 1
				BEGIN
					PRINT(@INNERSQL)
					PRINT(@OUTERSQL)
				END
			ELSE
				BEGIN
					SET		@OUTERSQL = N'SELECT * FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + CAST(@INNERSQL AS varchar(MAX)) + ''')'
					SET		@OUTERMOSTSQL = ETL.BuildDynSQL_XmlWrapper(@OUTERSQL,'TICKETS')
					EXEC	sp_executesqL @OUTERMOSTSQL, N'@returnValue Nvarchar(MAX) OUT', @returnValue=@STRINGTickets OUT
					SET		@MIXEDTickets += ISNULL(@STRINGTickets,'')

				END
		END

	---------------------------------------------------------
	-- IMPOSTA IL PARAMETRO DI OUTPUT @XMLtickets
	-- CON TUTTI I RISULTATI TROVATI
	---------------------------------------------------------
	SET	@XMLtickets = CAST(ISNULL(@MIXEDTickets,'<TICKETS/>') AS XML)

	---------------------------------------------------------------
	-- PROVIENIENTE DA Ticket.Extract_Pomezia: VERIFICARE SE SERVE.
	-- PER IL MOMENTO RESTA COMMENTATA
	---------------------------------------------------------------
	--IF @TicketCode IS NOT NULL
	--	BEGIN
	--			TRUNCATE TABLE	[TMP].[TicketStart]
	--			INSERT INTO 	[TMP].[TicketStart](
	--							ClubID, TicketCode, TicketValue, PrintingData, PrintingMachine, PrintingMachineID, PayoutData, PayOutMachine, PayOutMachineID, IsPaidCashDesk, IsPrintingCashDesk, ExpireDate, EventDate, MhMachine, MhMachineID, CreationChangeDate
	--							)
	--			SELECT			ClubID, TicketCode, TicketValue, PrintingDate, PrintingMachine, PrintingMachineID, PayoutDate, PayOutMachine, PayOutMachineID, IsPaidCashDesk, IsPrintingCashDesk, ExpireDate, EventDate, MhMachine, MhMachineID, CreationChangeDate
	--			FROM			@TableOutput
	--	END
	--ELSE
	--	BEGIN
	--		IF @LoadTicketToCalc <> 1 OR @LoadTicketToCalc IS NULL
	--			BEGIN
	--				TRUNCATE TABLE	[TMP].[Ticket]
	--				INSERT INTO		[TMP].[Ticket](
	--								TicketCode, TicketValue, PrintingData, PrintingMachine, PrintingMachineID, PayOutData, PayOutMachine, PayOutMachineID, IsPaidCashDesk, IsPrintingCashDesk, ExpireDate, EventDate, MhMachine, MhMachineID, CreationChangeDate
	--								)
	--				SELECT			TicketCode, TicketValue, PrintingDate, PrintingMachine, PrintingMachineID, PayOutDate, PayOutMachine, PayOutMachineID, IsPaidCashDesk, IsPrintingCashDesk, ExpireDate, EventDate, MhMachine, MhMachineID, CreationChangeDate
	--				FROM			@TableOutput
	--			END
	--		ELSE
	--			BEGIN
	--				TRUNCATE TABLE	[RAW].[TTForwardIN]
	--				INSERT INTO 	[RAW].[TTForwardIN](ClubID, TicketID, TicketValue, TicketCreationTime, TicketPayoutTime, UnivocalLocationCode, AamsMachineCode)
	--				SELECT			T1.ClubID, TicketCode, Ticketvalue, PrintingDate, PayOutDate, T3.UnivocalLocationCode, T2.AamsMachineCode 
	--				FROM			@TableOutput T1
	--								INNER JOIN [dbo].[VLT] T2 ON T1.PrintingMachine = T2.Machine
	--								INNER JOIN [dbo].[GamingRoom] T3 ON T1.ClubID = T3.ClubID
	--			END
	--	END
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
