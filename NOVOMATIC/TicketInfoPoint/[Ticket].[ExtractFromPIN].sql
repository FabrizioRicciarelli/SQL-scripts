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
@TicketCode			-- FACOLTATIVO, ELENCO DI TICKETS (MIXATI, SIA MHx CHE NON), SEPARATI DA VIRGOLE, OPPURE TICKET SINGOLO (SIA MHx CHE NON) 
@TicketValu			-- FACOLTATIVO, VALORE ESATTO DEL TICKET
@Threshold			-- FACOLTATIVO, VALORE MINIMO DEL TICKET
@FromDate			-- FACOLTATIVO, DATA INIZIALE MINIMA DALLA QUALE INIZIARE LA RICERCA
@ToDate				-- FACOLTATIVO, SE NON VALORIZZATO, QUANDO AL PARAMETRO @FromDate VIENE ASSEGNATO UN VALORE, IL PARAMETRO @ToDate CONTERRA' UNA DATA IL CUI GIORNO CORRISPONDE A QUELLO SUCCESSIVO SPECIFICATO IN @FromDate
@IsMhx				-- FACOLTATIVO, SE VALORIZZATO A 0 (FORZATURA) NON EFFETTUA LA RICERCA PER TICKETS NON-MHx (SCARTO APRIORISTICO)
@ISpaid				-- FACOLTATIVO, SE VALORIZZATO, RICERCHERA' SOLO QUEI TICKETS IL CUI CAMPO PayoutUserID SIA STATO VALORIZZATO (NON NULLO) - VALE SOLO PER I TICKETS NON-MHx
@LoadTicketToCalc	-- FACOLTATIVO
@XMLtickets 		-- OUTPUT

------------------
-- Call Example --
------------------

-- RICERCA DI SOLI TICKET NON-MHx
------------------------------------------------------------------------------------		
DECLARE	@XTICKETS XML -- VUOTO
EXEC	Ticket.ExtractFromPIN
		@ConcessionaryID = 7 -- OBBLIGATORIO, DETERMINA IL CONCESSIONARIO
		,@ClubID = NULL	-- FACOLTATIVO, DETERMINA LA SALA
		,@TicketCode = '128301058212579623,317623697657321163,87357650376813781,574469064150040316,83373844871275342,272366424668744552,309551976638606413,184120789653679575,' -- FACOLTATIVO, ELENCO DI TICKETS (MIXATI, SIA MHx CHE NON), SEPARATI DA VIRGOLE, OPPURE TICKET SINGOLO (SIA MHx CHE NON) 
		,@TicketValue = NULL -- FACOLTATIVO, VALORE ESATTO DEL TICKET
		,@Threshold = NULL -- FACOLTATIVO, VALORE MINIMO DEL TICKET
		,@FromDate = NULL -- DATA INIZIALE MINIMA DALLA QUALE INIZIARE LA RICERCA
		,@ToDate = NULL	-- FACOLTATIVO, SE NON VALORIZZATO, QUANDO AL PARAMETRO @FromDate VIENE ASSEGNATO UN VALORE, IL PARAMETRO @ToDate CONTERRA' UNA DATA IL CUI GIORNO CORRISPONDE A QUELLO SUCCESSIVO SPECIFICATO IN @FromDate
		,@IsMhx = NULL -- FACOLTATIVO, SE VALORIZZATO A 0 (FORZATURA) NON EFFETTUA LA RICERCA PER TICKETS NON-MHx (SCARTO APRIORISTICO)
		,@ISpaid = NULL -- FACOLTATIVO, SE VALORIZZATO, RICERCHERA' SOLO QUEI TICKETS IL CUI CAMPO PayoutUserID SIA STATO VALORIZZATO (NON NULLO) - VALE SOLO PER I TICKETS NON-MHx
		,@LoadTicketToCalc = NULL
		,@XMLTICKETS = @XTICKETS OUTPUT
SELECT	*
FROM	ETL.GetXTICKETS(@XTICKETS, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
------------------------------------------------------------------------------------


-- RICERCA MISTA, TICKET NORMALI E MHx
------------------------------------------------------------------------------------
DECLARE	@XTICKETS XML -- VUOTO
EXEC	Ticket.ExtractFromPIN
		@ConcessionaryID = 7 -- OBBLIGATORIO, DETERMINA IL CONCESSIONARIO
		,@ClubID = NULL	-- FACOLTATIVO, DETERMINA LA SALA
		,@TicketCode = '479194386004564610,369456253604773261,525764475876923475,181340809208629093,1000294MHR201502110001' -- FACOLTATIVO, ELENCO DI TICKETS (MIXATI, SIA MHx CHE NON), SEPARATI DA VIRGOLE, OPPURE TICKET SINGOLO (SIA MHx CHE NON) 
		,@TicketValue = NULL -- FACOLTATIVO, VALORE ESATTO DEL TICKET
		,@Threshold = NULL -- FACOLTATIVO, VALORE MINIMO DEL TICKET
		,@FromDate = NULL -- DATA INIZIALE MINIMA DALLA QUALE INIZIARE LA RICERCA
		,@ToDate = NULL	-- FACOLTATIVO, SE NON VALORIZZATO, QUANDO AL PARAMETRO @FromDate VIENE ASSEGNATO UN VALORE, IL PARAMETRO @ToDate CONTERRA' UNA DATA IL CUI GIORNO CORRISPONDE A QUELLO SUCCESSIVO SPECIFICATO IN @FromDate
		,@IsMhx = NULL -- FACOLTATIVO, SE VALORIZZATO A 0 (FORZATURA) NON EFFETTUA LA RICERCA PER TICKETS NON-MHx (SCARTO APRIORISTICO)
		,@ISpaid = NULL -- FACOLTATIVO, SE VALORIZZATO, RICERCHERA' SOLO QUEI TICKETS IL CUI CAMPO PayoutUserID SIA STATO VALORIZZATO (NON NULLO) - VALE SOLO PER I TICKETS NON-MHx
		,@LoadTicketToCalc = NULL
		,@XMLTICKETS = @XTICKETS OUTPUT
SELECT	*
FROM	ETL.GetXTICKETS(@XTICKETS, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
------------------------------------------------------------------------------------


-- RICERCA PER VALORI DI TICKET SUPERIORI A 500€		
------------------------------------------------------------------------------------
DECLARE	@XTICKETS XML -- VUOTO
EXEC	Ticket.ExtractFromPIN
		@ConcessionaryID = 7 -- OBBLIGATORIO, DETERMINA IL CONCESSIONARIO
		,@ClubID = NULL	-- FACOLTATIVO, DETERMINA LA SALA
		,@TicketCode = NULL -- FACOLTATIVO, ELENCO DI TICKETS (MIXATI, SIA MHx CHE NON), SEPARATI DA VIRGOLE, OPPURE TICKET SINGOLO (SIA MHx CHE NON) 
		,@TicketValue = NULL -- FACOLTATIVO, VALORE ESATTO DEL TICKET
		,@Threshold = 500 -- FACOLTATIVO, VALORE MINIMO DEL TICKET
		,@FromDate = NULL -- DATA INIZIALE MINIMA DALLA QUALE INIZIARE LA RICERCA
		,@ToDate = NULL	-- FACOLTATIVO, SE NON VALORIZZATO, QUANDO AL PARAMETRO @FromDate VIENE ASSEGNATO UN VALORE, IL PARAMETRO @ToDate CONTERRA' UNA DATA IL CUI GIORNO CORRISPONDE A QUELLO SUCCESSIVO SPECIFICATO IN @FromDate
		,@IsMhx = NULL -- FACOLTATIVO, SE VALORIZZATO A 0 (FORZATURA) NON EFFETTUA LA RICERCA PER TICKETS NON-MHx (SCARTO APRIORISTICO)
		,@ISpaid = NULL -- FACOLTATIVO, SE VALORIZZATO, RICERCHERA' SOLO QUEI TICKETS IL CUI CAMPO PayoutUserID SIA STATO VALORIZZATO (NON NULLO) - VALE SOLO PER I TICKETS NON-MHx
		,@LoadTicketToCalc = NULL
		,@XMLTICKETS = @XTICKETS OUTPUT
SELECT	*
FROM	ETL.GetXTICKETS(@XTICKETS, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
------------------------------------------------------------------------------------
*/
CREATE PROC	[ETL].[ExtractTicketsFromPIN]
			@ConcessionaryID tinyint
			,@ClubID varchar(10) = NULL
			,@TicketCode varchar(max) = NULL
			,@TicketValue int
			,@FromDate datetime = NULL
			,@ToDate datetime = NULL
			,@IsMhx Bit = NULL
			,@ISpaid BIT = NULL
			,@Threshold int = NULL
			,@LoadTicketToCalc BIT = NULL
			,@XMLtickets XML = NULL OUTPUT
AS


------------------------------------------------------------------------
-- AFFINCHE' SIA POSSIBILE MEMORIZZARE I RISULTATI DELLE QUERY
-- INVOCATE SULLE MACHINE REMOTE ALL'INTERNO DI UNA TABELLA
-- IN MEMORIA (@TABLEOUTPUT) E' INDISPENSABILE CHE IL 
-- "Distributed Transaction Coordinator (DTC or MSDTC)" SIA
-- STATO CORRETTAMENTE ATTIVATO E CONFIGURATO SU TUTTI I 
-- SERVER/LINKED SERVER COINVOLTI NELLE OPERAZIONI DI TRASFERIMENTO.
-- UNA VOLTA ACCERTATISI CHE CIO' SIA STATO FATTO, VALORIZZARE
-- LA VARIABILE CHE SEGUE (@MSDTC_ENABLED) AD 1: IN TAL MODO
-- I RISULTATI DELLE QUERY VERRANNO CORRETTAMENTE INSTRADATI
-- ALL'INTERNO DELLA TABELLA IN MEMORIA E RESI QUINDI DISPONIBILI
-- PER GLI USI SUCCESSIVI

DECLARE @MSDTC_ENABLED bit = 0
------------------------------------------------------------------------

SET XACT_ABORT ON; -- ATTIVARE (ON) PER ABILITARE LE TRANSAZIONI DISTRIBUITE

DECLARE
		@DEBUG bit = 0 -- VALORIZZARE AD 1 PER MOSTRARE IL COSTRUTTO DELLE QUERY DINAMICHE PIUTTOSTO CHE ESEGUIRLE 
		,@IsDevelopment bit = 0
		,@OUTERMOSTSQL Nvarchar(MAX) -- DA ESEGUIRE SU QUESTA MACCHINA
		,@OUTERSQL Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA POM-MON01
		,@INNERSQL Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA PIN
		,@ConcessionaryName Nvarchar(20)

		,@NOMHxTickets Nvarchar(MAX) = NULL -- CONTENITORE PER TICKETS NON-MHx
		,@MHxTickets Nvarchar(MAX) = NULL -- CONTENITORE PER TICKETS MHx
		,@STRINGTickets Nvarchar(MAX) = NULL -- TICKETS IN FORMA STRINGXML RITORNATI DALLE MACCHINE PIN
		,@MIXEDTickets Nvarchar(MAX) = '' -- TICKETS IN FORMA STRINGXML CONTENENTI TUTTI I TICKET OGGETTO DI RICERCA (LA SOMMA DI TUTTI I PEZZI RICERCATI, MHx E NON-MHx)

		,@QuotedFromDate Nvarchar(10)
		,@QuotedToDate Nvarchar(10)

		,@whereCondition Nvarchar(MAX)
		,@TopRows Nvarchar(20) = N'TOP 10000' -- MAX DIECIMILA RIGHE 
		,@NumRecord tinyint

		,@INPUTtickets ETL.TICKET_TYPE

IF @MSDTC_ENABLED = 1
	BEGIN
		DECLARE	@TABLEOUTPUT	TABLE 
				( 
					clubid             int 
					,ticketcode         varchar(40) 
					,ticketvalue        int 
					,printingmachine    varchar(20) 
					,printingmachineid  smallint 
					,printingdate       datetime 
					,payoutmachine      varchar(20) 
					,payoutmachineid    smallint 
					,payoutdate         datetime 
					,ispaidcashdesk     bit 
					,isprintingcashdesk bit 
					,expiredate         datetime 
					,eventdate          datetime 
					,mhmachine          varchar(30) 
					,MhMachineID        smallint 
					,creationchangedate datetime 
				)
	END


-- DETERMINAZIONE AMBIENTE DEL SERVER SQL
SET @IsDevelopment = IIF(@@SERVERNAME LIKE '%DEV%', 1, 0)

-- IDENTIFICAZIONE DEL CONCESSIONARIO
--SELECT	
--		@ConcessionaryName = ConcessionaryName
--		--,@LinkedServer = LinkedServer
--FROM	dbo.ConcessionaryType
--WHERE	ConcessionarySK = @ConcessionaryID
SELECT @ConcessionaryName = ETL.getConcessionaryName(@ConcessionaryID)

-- FORMATTAZIONE DATE
SET @ToDate = ISNULL(@ToDate,Dateadd(day, 1, CAST(@FromDate AS DateTime))) -- se non è stata passata la data di arrivo come parametro, viene assunta come data il giorno successivo a quello della data di partenza 
SET @QuotedFromDate = QUOTENAME(CONVERT(char(8), ISNULL(@FromDate, Space(0)), 112), Char(39))
SET @QuotedToDate = QUOTENAME(CONVERT(char(8), ISNULL(@ToDate, Space(0)), 112), Char(39))

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
		ISNULL(@Threshold,'') != ''
	)
	AND ISNULL(@TicketValue,'') NOT LIKE '%[a-zA-Z]%'
	AND ISNULL(@IsMHx,0) = 0 -- SE QUESTO PARAMETRO E' VALORIZZATO A 1, SALTA LA RICERCA DEI TICKET NON MHx
)
	BEGIN 

		-- DEFINIZIONE QUERY DA INVOCARE SU MACCHINE REMOTE
		SET @INNERSQL = 
		N'
		SELECT	' + ISNULL(@TopRows,'') + ' 
				TD.ClubID
				,TD.TicketID as TicketCode
				,CAST(((CashA+CashB+CashC) * 100) AS BIGINT) AS TicketValue
				,LEFT(LTRIM(CM.CertificateName), 11) AS PrintingMachine
				,TD.MachineID as PrintingMachineID
				,CreationTime as PrintingDate
				,LEFT(LTRIM(PM.CertificateName), 11) as PayoutMachine
				,TD.PayoutMachineID as PayoutMachineID
				,PayoutTime as PayoutDate
				,IsPaidCashDesk = IIF(ISNULL(PayoutUserID,0) = 0, 0, 1)
				,IsPrintingCashDesk = IIF(ISNULL(UserID,0) = 0, 0, 1)  
				,ExpireTime AS ExpireDate 
				,NULL AS EventDate
				,NULL AS MhMachine
				,NULL AS MhMachineID
				,NULL AS CreationChangeDate 
		FROM	[SQL-FINANCE\SQL_FINANCE].[NucleusDB].[Tito].[TicketData] TD WITH(NOLOCK)
				LEFT OUTER JOIN 
				[SQL-FINANCE\SQL_FINANCE].[NucleusDB].[Config].[Machine] CM WITH(NOLOCK) 
				ON TD.ClubId = CM.ClubId 
				AND TD.MachineId = CM.RecId
				LEFT OUTER JOIN 
				[SQL-FINANCE\SQL_FINANCE].[NucleusDB].[Config].[Machine] PM WITH(NOLOCK) 
				ON TD.ClubId = PM.ClubId 
				AND TD.PayoutMachineId = PM.RecId 
				LEFT OUTER JOIN 
				(SELECT ClubId, RecId FROM OPENQUERY([SQL-FINANCE\SQL_FINANCE], ''SELECT ClubId, RecId FROM [NucleusDB].[Users].[UsersSite] WITH(NOLOCK)'')) US -- Consente di superare questo errore: "Xml data type is not supported in distributed queries"
				ON TD.ClubId = US.ClubId 
				AND TD.UserId = US.RecId 
				LEFT OUTER JOIN 
				(SELECT ClubId, RecId FROM OPENQUERY([SQL-FINANCE\SQL_FINANCE], ''SELECT ClubId, RecId FROM [NucleusDB].[Users].[UsersSite] WITH(NOLOCK)'')) PS -- Consente di superare questo errore: "Xml data type is not supported in distributed queries" 
				ON TD.ClubId = PS.ClubId 
				AND TD.PayoutUserId = PS.RecId
		' 

		-- APPOSIZIONE APICI IN PROSSIMITA' DI CIASCUN TICKET
		SET @NOMHxTickets = Char(39) + REPLACE(@NOMHxTickets, ',', CHAR(39) + ',' + CHAR(39)) + CHAR(39)

		-- COMPOSIZIONE/FORMATTAZIONE WHERECONDITION
		SET	@whereCondition = N'WHERE ' +
			ISNULL(COALESCE(NULL, N'AND TD.ClubID = ' + @ClubID + N' '),'') +	 
			ISNULL(COALESCE(NULL, N'AND TD.TicketID IN (' + @NOMHxTickets + N') '),'')  + -- CRITERIO DI RICERCA DINAMICO SU TICKETS NON-MHx MULTIPLI
			ISNULL(COALESCE(NULL, N'AND CAST(((CashA+CashB+CashC) * 100) AS BIGINT) = ' + CAST(@TicketValue AS varchar(10)) + N' '),'') + -- CRITERIO DI RICERCA DINAMICO SU TICKET SINGOLO
			CASE WHEN ISNULL(@FromDate,'') != '' THEN N'AND ((CreationTime BETWEEN ' + @QuotedFromDate + N' AND ' + @QuotedToDate + N') OR (PayoutTime BETWEEN ' + @QuotedFromDate + N' AND ' + @QuotedToDate + N'))' ELSE N'' END + N' ' + -- CRITERIO DI RICERCA DINAMICO SU INTERVALLI DI DATE
			CASE WHEN ISNULL(@ISpaid,0) = 1 THEN N'AND PayoutUserID IS NOT NULL' ELSE N'' END	+ ' ' +	-- CRITERIO DI RICERCA DINAMICO SU FLAG PayoutUserID
			ISNULL(COALESCE(NULL, 'AND CAST(((CashA+CashB+CashC) * 100) AS BIGINT) > ' + CAST(@Threshold AS varchar(10))),'') -- CRITERIO DI RICERCA DINAMICO SU SOGLIA

		SET	@whereCondition = REPLACE(@whereCondition,'  ', ' ') -- rimpiazzo doppi spazi con spazio singolo
		SET	@whereCondition = REPLACE(@whereCondition,'  ', ' ') -- rimpiazzo doppi spazi con spazio singolo
		SET	@whereCondition = REPLACE(@whereCondition,'WHERE AND', 'WHERE') -- rimpiazzo AND fuori posto

		SET @INNERSQL += @whereCondition -- concatenazione QUERY e sua wherecondition
		SET @INNERSQL = REPLACE(@INNERSQL, CHAR(39), CHAR(39)+CHAR(39))	-- rimpiazzo apici singoli con apici doppi per innesto query SQL dinamico

		IF @MSDTC_ENABLED = 1
			BEGIN
				SET @OUTERSQL =
				N'
				DECLARE @SQL Nvarchar(MAX)	  
				SET @SQL = N''' + @INNERSQL + '''
				EXEC(@SQL) AT [' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW]
				'
			END
		ELSE
			BEGIN
				SET @OUTERSQL =
				N'
				SELECT * FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + @INNERSQL + ''')
				'
			END

		IF @DEBUG = 1
			BEGIN
				PRINT(@INNERSQL)
				PRINT(@OUTERSQL)
			END
		ELSE
			BEGIN
				IF @MSDTC_ENABLED = 1
					BEGIN -- MEMORIZZA IL RISULTATO ALL'INTERNO DELLA TABELLA IN MEMORIA
						PRINT 'UNCOMMENT THE LINES BELOW'
						--INSERT	@TableOutput 
						--		( 
						--			clubid
						--			,ticketcode
						--			,ticketvalue
						--			,printingmachine
						--			,printingmachineid
						--			,printingdate
						--			,payoutmachine
						--			,payoutmachineid
						--			,payoutdate
						--			,ispaidcashdesk
						--			,isprintingcashdesk
						--			,expiredate
						--			,eventdate
						--			,mhmachine
						--			,MhMachineID
						--			,creationchangedate
						--		) 
						--IF @IsDevelopment = 1
						--	EXEC(@OUTERSQL) AT [POM-MON01]
						--ELSE
						--	EXEC(@OUTERSQL) 
					END
				ELSE -- MEMORIZZA IL RISULTATO NEL PARAMETRO DI OUTPUT @XMLtickets
					BEGIN
						IF @IsDevelopment = 1
							BEGIN
								SET		@OUTERMOSTSQL = N'SELECT @POMMONreturnValue = CAST((SELECT * FROM OPENQUERY([POM-MON01],'''+ REPLACE(@OUTERSQL,'''','''''') +''') FOR XML RAW(''TICKETS''),TYPE) AS Nvarchar(MAX))'   
								EXEC	sp_executesqL @OUTERMOSTSQL, N'@POMMONreturnValue Nvarchar(MAX) OUT', @POMMONreturnValue=@STRINGTickets OUT
								SET		@MIXEDTickets += ISNULL(@STRINGTickets,'')
								--PRINT	@STRINGTickets
							END
						ELSE
							EXEC(@OUTERSQL) 
					END
			END
	END

---------------------------------------------------------
-- RICERCA DEI TICKETS MULTIPLI MHx 
-- OPPURE DEL SINGOLO TICKET MHx
---------------------------------------------------------
IF ISNULL(@MHxTickets,'') != ''
OR ISNULL(@TicketValue,'') LIKE '%[a-zA-Z]%'
	BEGIN 

		-- DEFINIZIONE QUERY DA INVOCARE SU MACCHINE REMOTE
		SET @INNERSQL = 
		N'
		SELECT	' + ISNULL(@TopRows,'') + ' 
				ST.ClubID
				,ST.Receipt AS TicketCode
				,ST.Value AS TicketValue
				,NULL AS PrintingMachine
				,NULL AS PrintingMachineID
				,NULL AS PrintingDate
				,NULL AS PayoutMachine
				,NULL AS PayoutMachineID
				,NULL AS PayoutDate
				,0 AS IsPaidCashDesk
				,0 AS IsPrintingCashDesk
				,NULL AS ExpireDate
				,ST.EventDate 
				,MhMachine = 
					CASE  
						WHEN	LEN(LEFT(RTRIM(LTRIM(M.LabelID)), 11)) < 11 
						AND		LEFT(RTRIM(LTRIM(M.LabelID)), 11) NOT LIKE ''GD%'' 
						THEN	UPPER(LEFT(RTRIM(LTRIM(M.CertificateName)), 11))  
						ELSE	UPPER(LEFT(RTRIM(LTRIM(M.LabelID)), 11))   
					END
				,ST.MachineID AS MhMachineID
				,RegDateTime AS CreationChangeDate 
		FROM	 
		(
			SELECT 
					ClubId
					,Receipt 
					,Value
					,EventDate
					,MachineID
					,Type
					,ObjectId
					,RecId
					,RegDateTime
			FROM	OPENQUERY -- Consente di superare questo errore: "Xml data type is not supported in distributed queries"
			(
				[SQL-FINANCE\SQL_FINANCE]
				,''
				SELECT 
						ClubId
						,Receipt
						,CAST((CAST(ST.AddInfo.value(''''(/CHandpayVoucherInfo//EventValue/node())[1]'''', ''''nvarchar(30)'''') AS  DECIMAL(13,2)) * 100) AS INT) AS Value
						,EventDate = 
							CASE 
								WHEN ST.Type = 36 
								THEN ST.AddInfo.value(''''(/CHandpayVoucherInfo//EventDateTime/node())[1]'''', ''''datetime'''') 
								WHEN ST.Type IN (21, 22, 26, 27) 
								THEN ST.AddInfo.value(''''(/CMachineEventInfo//EventDateTime/node())[1]'''', ''''datetime'''') 
								ELSE NULL
							END  
						,ST.AddInfo.value(''''(/CHandpayVoucherInfo//MachID/node())[1]'''', ''''int'''') AS MachineID
						,Type
						,ObjectId
						,RecId
						,RegDateTime
				FROM	[NucleusDB].[Cashdesk].[ShiftTransaction] ST WITH(NOLOCK)
				''
			)
		)		ST 
				INNER JOIN 
				[SQL-FINANCE\SQL_FINANCE].[NucleusDB].[Cashdesk].[ShiftTranCurrency] STC WITH(NOLOCK) 
				ON STC.ClubId = ST.ClubId 
				AND STC.TransactionId = ST.RecId 
				LEFT OUTER JOIN 
				[SQL-FINANCE\SQL_FINANCE].[NucleusDB].[Config].[Machine] M WITH(NOLOCK) 
				ON M.ClubId = ST.ClubId 
				AND M.RecId = ST.ObjectId 
		WHERE	ST.[Type] IN (21, 22, 26, 27, 36)
		'

		-- APPOSIZIONE APICI IN PROSSIMITA' DI CIASCUN TICKET
		SET @MHxTickets = Char(39) + REPLACE(@MHxTickets, ',', CHAR(39) + ',' + CHAR(39)) + CHAR(39)

		-- COMPOSIZIONE/FORMATTAZIONE WHERECONDITION
		-- *** ATTENZIONE *** GESTIRE I TICKET NON NUMERICI (COME QUELLI CONTENENTI "MHR")
		SET	@whereCondition = ISNULL(COALESCE(NULL, N'AND ST.ClubID = ' + @ClubID + N''),'') +
		ISNULL(COALESCE(NULL, N' AND ST.Receipt IN (' + @MHxTickets + ') '),'') -- CRITERIO DI RICERCA DINAMICO SU TICKETS MHx MULTIPLI

		SET @INNERSQL += @whereCondition -- concatenazione QUERY e sua wherecondition 
		SET @INNERSQL = REPLACE(@INNERSQL, CHAR(39), CHAR(39)+CHAR(39))	-- rimpiazzo apici singoli con apici doppi per innesto query SQL dinamico

		IF @MSDTC_ENABLED = 1
			BEGIN
				SET @OUTERSQL =
				N'
				DECLARE @SQL varchar(MAX)	  
				SET @SQL = ''' + @INNERSQL + '''
				EXEC(@SQL) AT [' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW]
				'
			END
		ELSE
			BEGIN
				SET @OUTERSQL =
				N'
				SELECT * FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + @INNERSQL + ''')
				'
			END

		IF @DEBUG = 1
			BEGIN
				PRINT(@INNERSQL)
				PRINT(@OUTERSQL)
			END
		ELSE
			BEGIN
				IF @MSDTC_ENABLED = 1
					BEGIN -- MEMORIZZA IL RISULTATO ALL'INTERNO DELLA TABELLA IN MEMORIA
						PRINT 'UNCOMMENT THE LINES BELOW'
						--INSERT	@TableOutput 
						--		( 
						--			clubid
						--			,ticketcode
						--			,ticketvalue
						--			,printingmachine
						--			,printingmachineid
						--			,printingdate
						--			,payoutmachine
						--			,payoutmachineid
						--			,payoutdate
						--			,ispaidcashdesk
						--			,isprintingcashdesk
						--			,expiredate
						--			,eventdate
						--			,mhmachine
						--			,MhMachineID
						--			,creationchangedate
						--		) 
						--IF @IsDevelopment = 1
						--	EXEC(@OUTERSQL) AT [POM-MON01]
						--ELSE
						--	EXEC(@OUTERSQL) 
					END
				ELSE -- MEMORIZZA IL RISULTATO NEL PARAMETRO DI OUTPUT @XMLtickets
					BEGIN
						IF @IsDevelopment = 1
							BEGIN
								SET		@OUTERMOSTSQL = N'SELECT @POMMONreturnValue = CAST((SELECT * FROM OPENQUERY([POM-MON01],'''+ REPLACE(@OUTERSQL,'''','''''') +''') FOR XML RAW(''TICKETS''),TYPE) AS Nvarchar(MAX))'   
								EXEC	sp_executesqL @OUTERMOSTSQL, N'@POMMONreturnValue Nvarchar(MAX) OUT', @POMMONreturnValue=@STRINGTickets OUT
								SET		@MIXEDTickets += ISNULL(@STRINGTickets,'')
								--PRINT	@STRINGTickets
							END
						ELSE
							EXEC(@OUTERSQL) 
					END
			END

		SET @NumRecord = @@ROWCOUNT

		IF @NumRecord = 0
			BEGIN

				-- DEFINIZIONE QUERY DA INVOCARE SU MACCHINE REMOTE
				SET @INNERSQL = 
				N'
				SELECT 
						ST.ClubID
						,ST.Receipt AS TicketCode
						,ST.Value AS TicketValue
						,NULL AS PrintingMachine
						,NULL AS PrintingMachineID
						,NULL AS PrintingDate
						,NULL AS PayoutMachine
						,NULL AS PayoutMachineID
						,NULL AS PayoutDate
						,0 AS IsPaidCashDesk
						,0 AS IsPrintingCashDesk
						,NULL AS ExpireDate
						,ST.EventDate 
						,MhMachine =
							CASE
								 WHEN	LEN(LEFT(RTRIM(LTRIM(M.LabelID)), 11)) < 11 
								 AND	LEFT(RTRIM(LTRIM(M.LabelID)), 11) NOT LIKE ''GD%'' 
								 THEN	UPPER(LEFT(RTRIM(LTRIM(M.CertificateName)), 11))
								 ELSE	UPPER(LEFT(RTRIM(LTRIM(M.LabelID)), 11))
							 END
						,ST.MachineID AS MhMachineID
						,RegDateTime AS CreationChangeDate 
				FROM	 
				(
					SELECT 
							ClubId
							,Receipt 
							,Value
							,EventDate
							,MachineID
							,Type
							,ObjectId
							,RecId
							,RegDateTime
					FROM	OPENQUERY -- Consente di superare questo errore: "Xml data type is not supported in distributed queries"
					(
						[SQL-FINANCE\SQL_FINANCE]
						,''
						SELECT 
								ClubId
								,Receipt
								,Value = 
									CASE 
										WHEN ST.Type = 36 THEN CAST ((CAST (ST.[AddInfo].value(''(/CHandpayVoucherInfo//HandpayInfo/EventValue/node())[1]'', ''nvarchar(30)'') AS  DECIMAL(13,2)) * 100) AS INT)
										WHEN ST.Type IN (21, 22, 26, 27) THEN CAST ((CAST (ST.[AddInfo].value(''(/CMachineEventInfo//EventValue/node())[1]'', ''nvarchar(30)'') AS  DECIMAL(13,2)) * 100) AS INT)
										ELSE NULL
									END
								,EventDate =
									CASE 
										WHEN ST.Type = 36 THEN ST.[AddInfo].value(''(CHandpayVoucherInfo//HandpayInfo/EventDateTime/node())[1]'', ''datetime'')
										WHEN ST.Type IN (21, 22, 26, 27) THEN ST.[AddInfo].value(''(/CMachineEventInfo//EventDateTime/node())[1]'', ''datetime'') 
										ELSE NULL
									END 
								,MachineID = 
									CASE 
										WHEN ST.Type = 36 THEN ST.[AddInfo].value(''(/CHandpayVoucherInfo//HandpayInfo/MachID/node())[1]'', ''int'') 
										WHEN ST.Type IN (21, 22, 26, 27) THEN ST.[AddInfo].value(''(/CMachineEventInfo//MachID/node())[1]'', ''int'')
										ELSE NULL
									END
								,Type
								,ObjectId
								,RecId
								,RegDateTime
						FROM	[NucleusDB].[Cashdesk].[ShiftTransaction] ST WITH(NOLOCK)
						''
					)
				)		ST 
						
						INNER JOIN 
						[NucleusDB].[Cashdesk].[ShiftTranCurrency] STC WITH(NOLOCK) 
						ON STC.ClubId = ST.ClubId 
						AND STC.TransactionId = ST.RecId
						LEFT OUTER JOIN 
						[NucleusDB].]Config].]Machine] M WITH(NOLOCK) 
						ON M.ClubId = ST.ClubId 
						AND M.RecId = ST.ObjectId
				WHERE	ST.[Type] IN (21, 22, 26, 27,36) 
				AND '
				 
				-- APPOSIZIONE APICI IN PROSSIMITA' DI CIASCUN TICKET
				SET @MHxTickets = Char(39) + REPLACE(@MHxTickets, ',', CHAR(39) + ',' + CHAR(39)) + CHAR(39)

				-- COMPOSIZIONE/FORMATTAZIONE WHERECONDITION
				SET	@whereCondition = ISNULL(COALESCE(NULL, N'AND ST.ClubID = ' + @ClubID + ''),'') +
				ISNULL(COALESCE(NULL, N' AND ST.Receipt IN (' + @MHxTickets + ') '),'') -- CRITERIO DI RICERCA DINAMICO SU TICKETS MHx MULTIPLI

				SET @INNERSQL += @whereCondition -- concatenazione QUERY e sua wherecondition 
				SET @INNERSQL = REPLACE(@INNERSQL, CHAR(39), CHAR(39)+CHAR(39))	-- rimpiazzo apici singoli con apici doppi per innesto query SQL dinamico

				IF @MSDTC_ENABLED = 1
					BEGIN
						SET @OUTERSQL =
						N'
						DECLARE @SQL Nvarchar(MAX)	  
						SET @SQL = N''' + @INNERSQL + '''
						EXEC(@SQL) AT [' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW]
						'
					END
				ELSE
					BEGIN
						SET @OUTERSQL =
						N'
						SELECT * FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + @INNERSQL + ''')
						'
					END


				IF @DEBUG = 1
					BEGIN
						PRINT(@INNERSQL)
						PRINT(@OUTERSQL)
					END
				ELSE
					BEGIN
						IF @MSDTC_ENABLED = 1
							BEGIN -- MEMORIZZA IL RISULTATO ALL'INTERNO DELLA TABELLA IN MEMORIA
								PRINT 'UNCOMMENT THE LINES BELOW'
								--INSERT	@TableOutput 
								--		( 
								--			clubid
								--			,ticketcode
								--			,ticketvalue
								--			,printingmachine
								--			,printingmachineid
								--			,printingdate
								--			,payoutmachine
								--			,payoutmachineid
								--			,payoutdate
								--			,ispaidcashdesk
								--			,isprintingcashdesk
								--			,expiredate
								--			,eventdate
								--			,mhmachine
								--			,MhMachineID
								--			,creationchangedate
								--		) 
								--IF @IsDevelopment = 1
								--	EXEC(@OUTERSQL) AT [POM-MON01]
								--ELSE
								--	EXEC(@OUTERSQL) 
							END
						ELSE -- MEMORIZZA IL RISULTATO NEL PARAMETRO DI OUTPUT @XMLtickets
							BEGIN
								IF @IsDevelopment = 1
									BEGIN
										SET		@OUTERMOSTSQL = N'SELECT @POMMONreturnValue = CAST((SELECT * FROM OPENQUERY([POM-MON01],'''+ REPLACE(@OUTERSQL,'''','''''') +''') FOR XML RAW(''TICKETS''),TYPE) AS Nvarchar(MAX))'   
										EXEC	sp_executesqL @OUTERMOSTSQL, N'@POMMONreturnValue Nvarchar(MAX) OUT', @POMMONreturnValue=@STRINGTickets OUT
										SET		@MIXEDTickets += ISNULL(@STRINGTickets,'')
										--PRINT	@STRINGTickets
									END
								ELSE
									EXEC(@OUTERSQL) 
							END
					END

			END
	END

---------------------------------------------------------
-- IMPOSTA IL PARAMETRO DI OUTPUT @XMLtickets
-- CON TUTTI I RISULTATI TROVATI
---------------------------------------------------------
SET	@XMLtickets = CAST(ISNULL(@MIXEDTickets,'<TICKETS/>') AS XML)

---------------------------------------------------------------
-- PROVIENIENTE DA Ticket.Extract_Pomezia: VERIFICARE SE SERVE
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
--				INSERT INTO 	[RAW].[TTForwardIN](
--								ClubID, TicketID, TicketValue, TicketCreationTime, TicketPayoutTime, UnivocalLocationCode, AamsMachineCode
--								)
--				SELECT			T1.ClubID, TicketCode, Ticketvalue, PrintingDate, PayOutDate, T3.UnivocalLocationCode, T2.AamsMachineCode 
--				FROM			@TableOutput T1
--								INNER JOIN [dbo].[VLT] T2 ON T1.PrintingMachine = T2.Machine
--								INNER JOIN [dbo].[GamingRoom] T3 ON T1.ClubID = T3.ClubID
--			END
--	END
