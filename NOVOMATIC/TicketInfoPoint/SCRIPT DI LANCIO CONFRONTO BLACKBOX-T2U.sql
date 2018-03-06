-----------------------------------------------------------------------------------------------------------------
--
-- BLACKBOX
--
-- A. E' possibile una sola istanza in esecuzione alla volta per ciascun database della SP [RAW].[CalcAllLevel]
-- B. Presuppone la presenza e il pre-popolamento della tabella di configurazione Config.Table
-- C. Legge e scrive su 13 tabelle fisiche per appoggiare i dati durante i calcoli
-----------------------------------------------------------------------------------------------------------------

-- 1. Svuotamento tabella di LOG
TRUNCATE TABLE [ETL].[OperationLog]

-- 2. Definizione variabili di lavoro
DECLARE @ReturnCode int

-- 3. Esecuzione calcoli (presuppone la presenza e il pre-popolamento della tabella di configurazione Config.Table)
EXEC	[RAW].[CalcAllLevel] 
		@ConcessionaryID = 7
		,@Direction = 0
		,@TicketCode = '427102895993931934' -- 427102895993931934, 375559646310240944, 553637305458476249, 148239190679638755, 96415771688841631 
		,@BatchID = 1
		,@MaxLevel = 10
		,@ReturnCode = @ReturnCode Output

-- 4. Risultati dei calcoli (dati su disco, tabelle fisiche [RAW].[Session] e [RAW].[Delta])
--SELECT '[ETL].[OperationLog]' AS TABELLA, * FROM [ETL].[OperationLog] WHERE OperationRequestDetailID = 1
SELECT '[RAW].[Session]' AS TABELLA, * FROM [RAW].[Session]
SELECT '[RAW].[Delta]' AS TABELLA, * FROM [RAW].[Delta]



-----------------------------------------------------------------------------------------------------------------
--
-- T2U - Tickets To User
--
-- A. E' possibile eseguire un numero illimitato di istanze di esecuzione della SP ETL.CalcAllLevel: si deve
--    solo avere l'accortezza di valorizzare correttamente il parametro BatchID che identifica l'istanza
-- B. Non necessita della tabella di configurazione Config.Table
-- C. Non scrive e non legge in nessua tabella fisica per appoggiare i dati durante i calcoli
-- D. I tempi di esecuzione si abbassano progressivamente se i tickets richiesti in diverse
--    istanze di calcolo corrispondono alla stessa sala di un'altra istanza in esecuzione
--    (con tempi di esecuzione attorno ai 2 secondi per ciascuna istanza di calcolo)
-----------------------------------------------------------------------------------------------------------------

-- 1. Svuotamento tabella di LOG
--TRUNCATE TABLE [ETL].[OperationLog]

-- 2. Definizione variabili di lavoro
DECLARE
		@ConcessionaryID			tinyint = 7
		,@ConcessionaryName			varchar(30)
		,@XCONFIG					XML -- ex Config.Table
		,@XRAWDelta					XML -- ex RAW.Delta
		,@XRAWSession				XML -- ex RAW.Session

-- 3. Estrazione nominativo del concessionario per successivo popolamento tabella virtuale di configurazione
SET @ConcessionaryName = ETL.getConcessionaryName(@ConcessionaryID)

-- 4. Popolamento tabella virtuale di configurazione (ex Config.Table)
--											ConcessionaryID	, Position		, OffSetIN, OffSetOut, OffSetMh, MinVltEndCredit, ConcessionaryName , FlagDbArchive, OffsetRawData
SET	@XCONFIG =	ETL.WriteXCONFIG(@XCONFIG,	@ConcessionaryID, 'POM-MON01'	,       25,        45,     7200,              50, @ConcessionaryName,             1,             1) 

-- 5. Esecuzione calcoli
EXEC	ETL.CalcAllLevel
		@ConcessionaryID = @ConcessionaryID
		,@Direction = 0
		,@TicketCode = '427102895993931934' -- 427102895993931934, 375559646310240944, 553637305458476249, 148239190679638755, 96415771688841631 
		,@BatchID = 100
		,@MaxLevel = 10
		,@XCONFIG = @XCONFIG
		,@XRAWDelta = @XRAWDelta OUTPUT
		,@XRAWSession = @XRAWSession OUTPUT

-- 6. Risultati dei calcoli (dati in memoria, nessuna scrittura su disco)
--SELECT 'OperationLog' AS TABELLA, * FROM [ETL].[OperationLog] WHERE OperationRequestDetailID = 100
--SELECT 'SESSION' AS Tabella, * FROM ETL.GetAllXRS(@XRAWSession)
--SELECT 'DELTA' AS Tabella, * FROM ETL.GetAllXRD(@XRAWDelta)

-- ANALISI COMPARATIVA 1:1 TRA I DATI ELABORATI DALLA BLACKBOX E QUELLI ELABORATI DA T2U (RICHIEDE, OVVIAMENTE, CHE ENTRAMBE LE SP SIANO STATE LANCIATE CON LO STESSO NUMERO DI TICKET)
SELECT	X.SessionID, X.SessionParentID, X.Level, X.UnivocalLocationCode, X.MachineID, X.GD, X.AamsMachineCode, X.StartServerTime, X.EndServerTime, X.TotalRows, X.TotalBillIn, X.TotalCoinIN, X.TotalTicketIn, X.TotalBetValue, X.TotalBetNum, X.TotalWinValue, X.TotalWinNum, X.Tax, X.TotalIn, X.TotalOut, X.FlagMinVltCredit, X.StartTicketCode
FROM	[RAW].[Session] S
		INNER JOIN
		ETL.GetAllXRS(@XRAWSession) X
		ON  S.SessionID = X.SessionID
		AND S.Level = X.Level
		AND S.UnivocalLocationCode = X.UnivocalLocationCode
		AND S.MachineID = X.MachineID
		AND S.GD = X.GD
		AND S.AamsMachineCode = X.AamsMachineCode
		AND S.StartServerTime = X.StartServerTime
		AND S.EndServerTime = X.EndServerTime
		AND S.TotalRows = X.TotalRows
		AND S.TotalBillIn = X.TotalBillIn
		AND S.TotalTicketIn = X.TotalTicketIn
		AND S.TotalBetValue = X.TotalBetValue
		AND S.TotalBetNum = X.TotalBetNum
		AND S.TotalWinValue = X.TotalWinValue
		AND S.TotalWinNum = X.TotalWinNum
		AND S.Tax = X.Tax
		AND S.TotalIn = X.TotalIn
		AND S.TotalOut = X.TotalOut
		AND S.StartTicketCode = X.StartTicketCode

SELECT	X.RowID, X.UnivocalLocationCode, X.ServerTime, X.MachineID, X.GD, X.AamsMachineCode, X.GameID, X.GameName, X.VLTCredit, X.TotalBet, X.TotalWon, X.TotalBillIn, X.TotalCoinIn, X.TotalTicketIn, X.TotalHandPay, X.TotalTicketOut, X.Tax, X.TotalIn, X.TotalOut, X.WrongFlag, X.TicketCode, X.FlagMinVltCredit, X.SessionID
FROM	[RAW].[Delta] D
		INNER JOIN
		ETL.GetAllXRD(@XRAWDelta) X
		ON D.RowID = X.RowID
		AND D.UnivocalLocationCode = X.UnivocalLocationCode
		AND D.ServerTime = X.ServerTime
		AND D.MachineID = X.MachineID
		AND D.GD = X.GD
		AND D.AamsMachineCode = X.AamsMachineCode
		AND D.GameID = X.GameID
		AND D.GameName = X.GameName
		AND D.VLTCredit = X.VLTCredit
		AND D.WrongFlag = X.WrongFlag
		AND D.SessionID = X.SessionID

