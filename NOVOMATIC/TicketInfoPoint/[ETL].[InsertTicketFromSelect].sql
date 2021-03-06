/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: Fabrizio Ricciarelli
Creation Date.......: 2017-12-06
Description.........: SP per inserimento in tabella di dettaglio richiesta da prelievo CQI

------------------
-- Parameters   --
------------------	
@requestId int nullable
@ClaimantID tinyint nullable
@ConcessionaryID tinyint nullable
@ClubID varchar(10) nullable
@FromDate datetime nulable
@ToDate datetime nullable
@ISpaid tinyint default 1
@Threshold int default 100000 (which is interpreted as 1000,00)
@LoadTicketToCalc tinyint default 1
@COUNTONLY bit default 0
@ReturnMessage varchar(1000) OUTPUT 

------------------
-- Call Example --
------------------
DECLARE	@ReturnMessage varchar(1000)  
EXEC	ETL.InsertTicketFromSelect
		@requestId = 76  -- se specificato, aggiunge solo le righe di dettaglio (se non duplicate), altrimenti, se NULL o ZERO, inserisce una nuova richiesta master e vi appende le righe di dettaglio
		,@ClaimantID = 10
		,@ConcessionaryID = 4
		,@COUNTONLY = 1
		,@ReturnMessage = @ReturnMessage OUTPUT
SELECT	@ReturnMessage AS OperationResults
*/
ALTER PROC	[ETL].[InsertTicketFromSelect]
			@requestId int = null
			,@ClaimantID tinyint = NULL
			,@ConcessionaryID tinyint = NULL
			,@ClubID varchar(10) = NULL
			,@FromDate datetime = NULL
			,@ToDate datetime = NULL
			,@ISpaid tinyint= 1
			,@Threshold int = 100000
			,@LoadTicketToCalc tinyint = 1
			,@COUNTONLY bit = 0
			,@ReturnMessage varchar(1000) = NULL OUTPUT 
AS
SET NOCOUNT ON;

BEGIN TRY
	------------------------------------------------------------------
	-- 0. DEFINIZIONE VARIABILI DI SERVIZIO
	------------------------------------------------------------------
	DECLARE
			@USESTUB bit = 1 -- *** ATTENZIONE !!! IMPOSTARE A 0 UNA VOLTA ALLINEATI I DB, OVVERO, QUANDO LA SP [Ticket].[Extract_Pomezia] SARA' RAGGIUNGIBILE DA QUESTO SERVER
			
			,@MASTER_RECORD_OK bit = 0 -- Identifica la corretta creazione del record di riferimento nella tabella master (ETL.Request)
			,@FOUND int = 0 -- Numero di records trovati in CQI corrispondenti ai criteri di ricerca
			,@INSERTED int = 0 -- Numero di records inseriti nella tabella di destinazione
			,@DUPLICATED int = 0 -- Numero di records NON inseriti nella tabella di destinazione in quanto rilevati come duplicati
			,@MAXID int = 0 -- Massimo valore contenuto nella colonna ID della tabella di prelievo (dove verranno riversati i dati da CQI)
			,@LASTID int = 0 -- Massimo valore contenuto nella colonna ID della tabella di prelievo dopo lo scarico (dove sono stati riversati i dati da CQI)
			,@ReturnCode int = 0 -- Codice ritornato dalle SP/Funzioni invocate

	------------------------------------------------------------------
	-- 1. TABELLA DI TRANSITO PER BYPASS DUPLICATI
	------------------------------------------------------------------
	DECLARE	@PRE TABLE
			(
				requestId int NOT NULL
				,ticket varchar(50) NULL
				,clubId varchar(10) NULL
				,ticketDirection bit NULL
			)

	----------------------------------------------------------------
	-- 1.a IDENTIFICAZIONE CORRETTO REQUESTID	PER INSERIMENTO 
	-- FITTIZIO NELLE TABELLE PRE
	----------------------------------------------------------------
	IF @COUNTONLY = 1
		BEGIN
			SELECT	@RequestId =
					CASE
						WHEN	ISNULL(@requestId,0) <= 0 -- SE IL VALORE SPECIFICATO E' NULL/INFERIORE/UGUALE A ZERO
						THEN	(SELECT ISNULL(MAX(requestId),0)+1 FROM ETL.request) -- ALLORA PRELEVA L'ID PIU' ALTO E VI AGGIUNGE 1 (SE LA TABELLA E' COMPLETAMENTE VUOTA GENERERA' L'ID NUMERO 1)
						ELSE	@RequestId -- ALTRIMENTI UTILIZZA IL VALORE SPECIFICATO
					END
		END		
	-----------------------------------------------------------------------------------
	-- 1.b PREPARAZIONE RECORD RICHIESTA MASTER	(se requestID non è stato specificato)
	-----------------------------------------------------------------------------------
	IF ISNULL(@requestId,0) <= 0 -- SE IL VALORE SPECIFICATO E' NULL/INFERIORE/UGUALE A ZERO
	AND @COUNTONLY = 0 -- E NON E' STATO RICHIESTO IL SOLO CONTEGGIO
		BEGIN
			INSERT ETL.request([requestDesc], [requestClaimantId], [ConcessionaryID], [ClubID], [requestStatusId], [TipoRichiesta], [system_date])
			SELECT
					dbo.Nowsmall('_',NULL,NULL) AS requestDesc -- ritorna una stringa del tipo "20171212_1055"
					,@ClaimantID AS requestClaimantId 
					,@ConcessionaryID AS ConcessionaryID
					,@ClubID AS ClubID
					,(SELECT ISNULL(requestStatusId,1) FROM ETL.requestStatus WITH(NOLOCK) WHERE requestStatusDesc LIKE '%pending%') AS requestStatusId
					,(SELECT ISNULL(RequestTypeId,2) FROM ETL.requestType WITH(NOLOCK) WHERE requestTypeDesc LIKE '%selezione%') AS TipoRichiesta
					,GETDATE() AS system_date

			SET @requestId = SCOPE_IDENTITY()
		END

	IF @USESTUB = 0
		BEGIN
			----------------------------------------------------------------
			-- 2.a FUNZIONE REALE
			----------------------------------------------------------------
			BEGIN TRAN -- Operazione svolta in transazione a garanzia di isolamento degli estremi superiore ed inferiore del set di record inserito

				-- PRELIEVO MASSIMO ID DALLA TABELLA DI PRELIEVO (DATI CQI) PRIMA DEL SUO POPOLAMENTO (PER ESCLUDERE QUANTO PRESENTE IN PRECEDENZA)
				SELECT	@MAXID = MAX(ID)
				FROM	RAW.TTicketIN
	
				-- INVOCAZIONE SP REMOTA SU CQI CON POPOLAMENTO TABELLA LOCALE DI PRELIEVO (RAW.TTicketIN)
				EXEC	@ReturnCode = 
						[POM-MON01].[GMATICA_AGS_RawData_Elaborate_Agile].[Ticket].[Extract_Pomezia] -- ESTRAZIONE, DA CQI, DEI TICKETS CORRISPONDENTI AI CRITERI IMPOSTATI 
							@ConcessionaryID = @ConcessionaryID
							,@FromDate = @FromDate
							,@ToDate = @ToDate
							,@ISpaid = @ISpaid										
							,@Threshold = @Threshold
							,@LoadTicketToCalc = @LoadTicketToCalc
							,@ReturnMessage = @ReturnMessage OUTPUT
	
				-- PRELIEVO MASSIMO ID DALLA TABELLA DI PRELIEVO (DATI CQI) DOPO IL SUO POPOLAMENTO (PER ESCLUDERE QUANTO PRESENTE IN PRECEDENZA)
				SELECT	@LASTID = MAX(ID)
				FROM	RAW.TTicketIN

			COMMIT TRAN


			IF LTRIM(RTRIM(@ReturnMessage)) = '' -- Se la SP non ha ritornato errori, procede
				BEGIN
					-- POPOLAMENTO TABELLA DI TRANSITO CON TUTTI I RECORDS RITORNATI DALL'ESTRAZIONE DA CQI
					INSERT @PRE (requestId, ticket, ticketDirection, clubId)
					SELECT	
							@requestId AS requestId
							,LTRIM(RTRIM(ISNULL(TicketID,''))) AS Ticket
							,0 AS ticketDirection
							,ISNULL(clubId,'0') AS ClubID
					FROM	RAW.TTicketIN WITH(NOLOCK)
					WHERE	(ID BETWEEN @MAXID AND @LASTID)	-- Soltanto i records inseriti dalla precedente chiamata: quanto presente in precedenza o successivamente sarà ignorato
			
					SET @FOUND = @@ROWCOUNT -- Valorizzato soltanto nel caso in cui la precedente SP ha ritornato, senza errori, almeno un record

					-- PULIZIA DELLA TABELLA DI PRELIEVO
					-- (Non resterà traccia dei dati appoggiati)
					DELETE
					FROM	RAW.TTicketIN
					WHERE	(ID BETWEEN @MAXID AND @LASTID)
				END
			ELSE
				BEGIN
					SET @ReturnMessage = @ReturnMessage
				END
			----------------------------------------------------------------
		END	
	ELSE
		BEGIN
			------------------------------------------------------------------
			-- 2.b STUB
			------------------------------------------------------------------
			INSERT @PRE (requestId, ticket, ticketDirection, clubId)
			VALUES 
					(@RequestId,'11111111111111111',0,'0'),
					(@RequestId,'22222222222222222',0,'0'),
					(@RequestId,'33333333333333333',1,'0'), 
					(@RequestId,'44444444444444444',1,'0'),
					(@RequestId,'55555555555555555',1,'0'), 
					(@RequestId,'66666666666666666',1,'0'), 
					(@RequestId,'77777777777777777',0,'0'), 
					(@RequestId,'88888888888888888',0,'0'),
					(@RequestId,'99999999999999999',0,'0')

			SET @FOUND = 8 -- NUMERO DI RECORD INSERITI MANUALMENTE (VALUES)
			------------------------------------------------------------------
		END

	IF @FOUND > 0
		BEGIN
			------------------------------------------------------------------
			-- 3. POPOLAMENTO TABELLA DI DESTINAZIONE CON ESCLUSIONE DUPLICATI
			------------------------------------------------------------------
			
			-- CONTEGGIO DUPLICATI (SE PRESENTI)
			SELECT	@DUPLICATED = COUNT(*)
			FROM	@PRE P
					LEFT JOIN
					ETL.requestDetail RD WITH(NOLOCK)
					ON P.requestId = RD.requestId
					AND P.clubId = ISNULL(RD.clubId,'0') -- SUL LATO "PRE" IL CLUBID E' GIA' SICURAMENTE DIVERSO DA NULL
					AND P.ticket = LTRIM(RTRIM(ISNULL(RD.ticket,''))) -- SUL LATO "PRE" IL TICKET E' GIA' TRIMMATO E SICURAMENTE DIVERSO DA NULL
			WHERE	RD.requestId IS NOT NULL -- DUPLICATI

			IF @COUNTONLY = 0
				BEGIN
					-- INSERIMENTO NELLA TABELLA FINALE DI DETTAGLIO RICHIESTE, SENZA DUPLICATI
					INSERT	ETL.requestDetail (requestId, ticket, ticketDirection, clubId, detailStatusId)
					SELECT	P.requestId, P.ticket, P.ticketDirection, P.clubId, 1 AS detailStatusId -- detailStatusId: 1=PENDING 
					FROM	@PRE P
							LEFT JOIN
							ETL.requestDetail RD WITH(NOLOCK)
							ON P.requestId = RD.requestId
							AND P.clubId = ISNULL(RD.clubId,'0') -- SUL LATO "PRE" IL CLUBID E' GIA' SICURAMENTE DIVERSO DA NULL
							AND P.ticket = LTRIM(RTRIM(ISNULL(RD.ticket,''))) -- SUL LATO "PRE" IL TICKET E' GIA' TRIMMATO E SICURAMENTE DIVERSO DA NULL
					WHERE	RD.requestId IS NULL -- IMPEDISCE I DUPLICATI

					SET @INSERTED = @@ROWCOUNT
				END

			SET @ReturnMessage = 
				CASE 
					WHEN @USESTUB = 1
					THEN '*** STUB IN USE *** ' 
					ELSE ''
				END +
				CASE
					WHEN @COUNTONLY = 0
					THEN 'FOUND ON CQI: ' + CAST(@FOUND AS varchar(20)) + ' RECORDS, INSERTED: ' + CAST(@INSERTED AS varchar(20)) + ' RECORDS, DUPLICATES EXCLUDED: ' + CAST(@DUPLICATED AS varchar(20)) + ' RECORDS'
					ELSE 'RECORDS WHICH WILL BE INSERTED INTO THE NEW REQUEST: ' + CAST(@FOUND AS varchar(20))
				END
			------------------------------------------------------------------
		END
	ELSE
		BEGIN
			SET @ReturnMessage = 'NO DATA TO BE PROCESSED.'	
		END
			
END TRY

BEGIN CATCH 
    SELECT
			ERROR_NUMBER() AS ErrorNumber
			,ERROR_SEVERITY() AS Severity
			,ERROR_STATE() AS ErrorState
			,ISNULL(ERROR_PROCEDURE(), ISNULL(dbo.GetProcName(@@PROCID),'*Unknown*')) AS ErrorProcedure  
			,ERROR_LINE() AS ProcedureLine
			,ERROR_MESSAGE() As ErrorMessage
	SET @ReturnMessage = ERROR_MESSAGE();
END CATCH
