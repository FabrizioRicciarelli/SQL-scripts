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
Description.........: SP per inserimento nelle tabelle master e di dettaglio richiesta da input manuale e/o importazione da CSV

------------------
-- Parameters   --
------------------	
@requestDesc varchar(150) * mandatory
@requestClaimantId smallint * mandatory
@ConcessionaryID tinyint * mandatory
@ticketList ETL.TicketTbl READONLY
@ReturnMessage varchar(1000) OUTPUT 

------------------
-- Call Example --
------------------
DECLARE	@mylist ETL.TicketTbl, @ReturnMessage varchar(1000), @LASTMASTERID INT
INSERT @mylist (ticket, ticketDirection, clubId)
VALUES 
		('58422214835338610',0,'0'),
		('58707400519556830',0,'0'),
		('64492000056259545',1,'0'), 
		('67967006555949464',1,'0'),
		('68795144968901671',1,'0'), 
		('90086637885313270',1,'0'), 
		('94076559426442391',0,'0'), 
		('94890953944170659',0,'0')
EXEC	@LASTMASTERID = ETL.InsertTicketFromImportOrManual @requestDesc='20171206_1544', @requestClaimantId=10, @ConcessionaryID=7, @ticketList=@mylist, @ReturnMessage = @ReturnMessage OUTPUT
SELECT	@ReturnMessage AS OperationResults
IF @LASTMASTERID > 0
	BEGIN 
		SELECT * FROM ETL.request WHERE requestID = @LASTMASTERID
		SELECT * FROM ETL.requestDetail WHERE requestID = @LASTMASTERID
	END
*/
CREATE PROC	[ETL].[InsertTicketFromImportOrManual]
			@requestDesc varchar(150) = NULL
			,@requestClaimantId smallint = NULL
			,@ConcessionaryID tinyint = NULL
			,@ticketList ETL.TicketTbl READONLY												
			,@ReturnMessage varchar(1000) = NULL OUTPUT 							  
AS
SET NOCOUNT ON;

BEGIN TRY
	------------------------------------------------------------------
	-- 0. DEFINIZIONE VARIABILI DI SERVIZIO
	------------------------------------------------------------------
	DECLARE
			@requestId int = 0 -- Identificativo chiave della tabella master, ritornato dalla SCOPE_IDENTITY in fase di inserimento
			,@requestTypeId int = 0 -- Identificativo del tipo di richiesta (manuale/importazione = 1, da CQI/selezione = 2)
			,@requestStatusId int = 0 -- Identificativo dello stato della richiesta (pending = 1, elaboration = 2, failed = 3, partially completed = 4, fully completed = 5)
			,@FOUND int = 0 -- Numero di records passati nella lista dei ticket
			,@INSERTED int = 0 -- Numero di records inseriti nella tabella di destinazione
			,@DUPLICATEDONMASTER int = 0 -- Numero di records NON inseriti nella tabella MASTER di destinazione in quanto rilevati come duplicati
			,@DUPLICATEDONDETAIL int = 0 -- Numero di records NON inseriti nella tabella DETTAGLIO di destinazione in quanto rilevati come duplicati
			,@ReturnCode int = 0 -- Codice ritornato dalle SP/Funzioni invocate
	------------------------------------------------------------------

	IF ISNULL(@requestDesc,'') != ''
	AND ISNULL(@requestClaimantId,0) > 0
	AND ISNULL(@ConcessionaryID,0) > 0
		BEGIN

			------------------------------------------------------------------
			-- 1. TABELLA DI TRANSITO PER BYPASS DUPLICATI
			------------------------------------------------------------------
			DECLARE @PRE TABLE (
					requestDesc varchar(150)
					,requestClaimantId smallint
					,requestStatusId tinyint
					,ConcessionaryID tinyint
				)

			-- CONTEGGIO RECORDS VOCI DI DETTAGLIO PASSATE IN INGRESSO COME PARAMETRO
			SELECT	@FOUND = COUNT(*)
			FROM	@ticketList

			IF @FOUND > 0
				BEGIN
					---------------------------------------------------------------------------
					-- 1a. POPOLAMENTO TABELLA DI TRANSITO PER SUCCESSIVA ESCLUSIONE DUPLICATI
					---------------------------------------------------------------------------
					INSERT @PRE(requestDesc, requestClaimantId, ConcessionaryID, requestStatusId)
					SELECT 
							@requestDesc AS requestDesc															 
							,@requestClaimantId AS requestClaimantId
							,@ConcessionaryID AS ConcessionaryID
							,(SELECT requestStatusId FROM ETL.requestStatus WITH(NOLOCK) WHERE requestStatusDesc LIKE '%pending%') AS requestStatusId


					------------------------------------------------------------------
					-- 2. POPOLAMENTO TABELLA MASTER CON ESCLUSIONE DUPLICATI
					------------------------------------------------------------------
					-- CONTEGGIO DUPLICATI (SE PRESENTI)
					SELECT	@DUPLICATEDONMASTER = COUNT(*)
					FROM	@PRE P
							INNER JOIN
							ETL.request R WITH(NOLOCK)
							ON P.requestClaimantId = R.requestClaimantId
							AND P.ConcessionaryID = R.ConcessionaryID
							AND P.requestStatusId = R.requestStatusId
							AND P.requestDesc = R.requestDesc
					--WHERE	R.requestDesc IS NOT NULL -- DUPLICATI

					IF ISNULL(@DUPLICATEDONMASTER,0) < 1
						BEGIN 
							INSERT ETL.request(requestDesc, requestClaimantId, ConcessionaryID, requestStatusId, TipoRichiesta, system_date)
							SELECT 
									P.requestDesc															 
									,P.requestClaimantId
									,P.ConcessionaryID
									,P.requestStatusId
									,(SELECT requestTypeId FROM ETL.requestType WITH(NOLOCK) WHERE requestTypeDesc LIKE '%manuale%') AS TipoRichiesta
									,GETDATE() AS system_date
							FROM	@PRE P
									LEFT JOIN
									ETL.request R WITH(NOLOCK)
									ON P.requestClaimantId = R.requestClaimantId
									AND P.ConcessionaryID = R.ConcessionaryID
									AND P.requestStatusId = R.requestStatusId
									AND P.requestDesc = R.requestDesc
							WHERE	R.requestDesc IS NULL -- IMPEDISCE I DUPLICATI

							SET @requestId = SCOPE_IDENTITY()

							IF ISNULL(@requestId,0) > 0
								BEGIN
									------------------------------------------------------------------
									-- 3. POPOLAMENTO TABELLA DI DETTAGLIO CON ESCLUSIONE DUPLICATI
									------------------------------------------------------------------
			
									-- CONTEGGIO DUPLICATI (SE PRESENTI)
									SELECT	@DUPLICATEDONDETAIL = COUNT(*)
									FROM	@ticketList P
											LEFT JOIN
											ETL.requestDetail RD WITH(NOLOCK)
											ON RD.requestId = @requestId 
											AND P.clubId = ISNULL(RD.clubId,'0') -- SUL LATO "PRE" IL CLUBID E' GIA' SICURAMENTE DIVERSO DA NULL
											AND P.ticket = LTRIM(RTRIM(ISNULL(RD.ticket,''))) -- SUL LATO "PRE" IL TICKET E' GIA' TRIMMATO E SICURAMENTE DIVERSO DA NULL
									WHERE	RD.requestId IS NOT NULL -- DUPLICATI

									-- INSERIMENTO NELLA TABELLA FINALE DI DETTAGLIO RICHIESTE, SENZA DUPLICATI
									INSERT	ETL.requestDetail 
											(
												requestId
												,ticket
												,clubId
												,ticketDirection
												,univocalLocationCode
												,elabStart
												,elabEnd
												,detailStatusId
												,fileNameSession
												,fileNameDelta
												,fileNameOperationLog
												,fileNameErrorLog
												,system_date
											)
									SELECT	@requestId
											,P.ticket
											,P.clubId
											,P.ticketDirection
											,P.univocalLocationCode
											,P.elabStart
											,P.elabEnd
											,P.detailStatusId
											,P.fileNameSession
											,P.fileNameDelta
											,P.fileNameOperationLog
											,P.fileNameErrorLog
											,ISNULL(P.system_date,GETDATE()) AS system_date 
									FROM	@ticketList P
											LEFT JOIN
											ETL.requestDetail RD WITH(NOLOCK)
											ON RD.requestId = @requestId
											AND ISNULL(P.clubId,'0') = ISNULL(RD.clubId,'0')
											AND LTRIM(RTRIM(ISNULL(P.ticket,''))) = LTRIM(RTRIM(ISNULL(RD.ticket,'')))
									WHERE	RD.requestId IS NULL -- IMPEDISCE I DUPLICATI

									SET @INSERTED = @@ROWCOUNT

									SET @ReturnMessage = 
										'FOUND ON INPUT: ' + CAST(@FOUND AS varchar(20)) + ' RECORDS, INSERTED: ' + CAST(@INSERTED AS varchar(20)) + ' RECORDS, DUPLICATES EXCLUDED: ' + CAST(@DUPLICATEDONDETAIL AS varchar(20)) + ' RECORDS'
									------------------------------------------------------------------
								END
							ELSE
								BEGIN
									SET @ReturnMessage = 'CAN''T CREATE THE MASTER RECORD - NO DATA INSERTED.'	
								END
						END
					ELSE
						BEGIN
							SET @ReturnMessage = 'MASTER RECORD DUPLICATED - NO DATA INSERTED.'	
						END
				END
			ELSE
				BEGIN
					SET @ReturnMessage = 'NO DATA TO BE PROCESSED.'	
				END
		END	
		
		RETURN @requestId	
END TRY

BEGIN CATCH	
	SET @ReturnMessage = ERROR_MESSAGE();
	RETURN -1
END CATCH