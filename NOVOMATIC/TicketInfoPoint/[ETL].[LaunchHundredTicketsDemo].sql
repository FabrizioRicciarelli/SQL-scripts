/*
-------------------------------------------------------
-- 1. Eseguire il troncamento delle tabelle di lavoro
-------------------------------------------------------
TRUNCATE TABLE [GMATICA_AGS_RawData_Elaborate_Tip].[ETL].[SESSIONS]
TRUNCATE TABLE [GMATICA_AGS_RawData_Elaborate_Tip].[ETL].[DELTAS]

TRUNCATE TABLE ERR.ErrorLog
TRUNCATE TABLE ETL.OperationLog


-------------------------------------------------------
-- 2. COPIARE E INCOLLARE CIASCUNA RIGA IN UNA NUOVA FINESTRA DI MANAGEMENT 
-- STUDIO ED ESEGUIRE CADAUNA IMMEDIATAMENTE ALLO SCOPO DI AVERE UN'ESECUZIONE
-- PARALLELA (IN TOTALE SONO 1085 TICKETS)
-------------------------------------------------------
EXEC	ETL.LaunchHundredTicketsDemo @ClubID = 1000065 -- 102 TICKETS
EXEC	ETL.LaunchHundredTicketsDemo @ClubID = 1000221 -- 101 TICKETS
EXEC	ETL.LaunchHundredTicketsDemo @ClubID = 1000349 -- 101 TICKETS
EXEC	ETL.LaunchHundredTicketsDemo @ClubID = 1000315 -- 108 TICKETS
EXEC	ETL.LaunchHundredTicketsDemo @ClubID = 1000199 -- 109 TICKETS
EXEC	ETL.LaunchHundredTicketsDemo @ClubID = 1000172 -- 109 TICKETS
EXEC	ETL.LaunchHundredTicketsDemo @ClubID = 1000167 -- 111 TICKETS
EXEC	ETL.LaunchHundredTicketsDemo @ClubID = 1000377 -- 114 TICKETS
EXEC	ETL.LaunchHundredTicketsDemo @ClubID = 1000172 -- 115 TICKETS
EXEC	ETL.LaunchHundredTicketsDemo @ClubID = 1000408 -- 115 TICKETS

EXEC	ETL.LaunchHundredTicketsDemo @ClubID = 1000369 -- 115 TICKETS *** CRITICO! MOLTEPLICI OCCORRENZE DELL'ERRORE "An XML operation resulted an XML data type exceeding 2GB in size. Operation aborted."

-------------------------------------------------------
-- RISULTATI DI ELABORAZIONI SU SALE SPECIFICHE
-------------------------------------------------------
-- [1000221 = 101 Tickets, 20:18 min elab = 12 SEC/TICKET AVG]
-- [1000329 = 207 Tickets, 41:22 min elab = 12 SEC/TICKET AVG]
-- [1000241 = 490 Tickets, xx min elab]
-- [1000220	= 590 Tickets, xx min elab]
-- [1000114	= 899 Tickets, xx min elab]

-------------------------------------------------------
-- INDAGINI DI VARIO TIPO
-------------------------------------------------------
SELECT	
		ClubID
		,COUNT(*) AS NUMTICKETS
FROM	GMATICA_AGS_RawData_Elaborate_Tip.GDF.agn_input_ticket_2017_1
GROUP BY ClubID
ORDER BY NUMTICKETS DESC

SELECT	*
FROM 	##PICKUP
ORDER BY ClubID, ID
SELECT	* 
FROM	AsyncExecResults
SELECT	* 
FROM	ETL.OperationLog
SELECT	* 
FROM	ERR.ErrorLog

SELECT	*
FROM	[GMATICA_AGS_RawData_Elaborate_Tip].[ETL].[SESSIONS]
ORDER BY ClubID, ElabID, Level
SELECT	*
FROM	[GMATICA_AGS_RawData_Elaborate_Tip].[ETL].[DELTAS]
ORDER BY ClubID, ElabID, SessionID

-------------------------------------------------------
RICHIEDE LA PRESENZA DELLE SEGUENTI TABELLE DI OUTPUT:
(selezionare ed eseguire prima di lanciare la SP)
-------------------------------------------------------
CREATE TABLE [ETL].[SESSIONS](
	[ElabID] int NULL,
	[ClubID] int NULL,
	[SessionID] [bigint] NULL,
	[SessionParentID] [int] NULL,
	[Level] [int] NULL,
	[UnivocalLocationCode] [varchar](30) NULL,
	[MachineID] [smallint] NULL,
	[GD] [varchar](30) NULL,
	[AamsMachineCode] [varchar](30) NULL,
	[StartServerTime] [datetime2](3) NULL,
	[EndServerTime] [datetime2](3) NULL,
	[TotalRows] [int] NULL,
	[TotalBillIn] [smallint] NULL,
	[TotalCoinIN] [smallint] NULL,
	[TotalTicketIn] [smallint] NULL,
	[TotalBetValue] [bigint] NULL,
	[TotalBetNum] [int] NULL,
	[TotalWinValue] [bigint] NULL,
	[TotalWinNum] [int] NULL,
	[Tax] [bigint] NULL,
	[TotalIn] [bigint] NULL,
	[TotalOut] [bigint] NULL,
	[FlagMinVltCredit] [bit] NULL,
	[StartTicketCode] [varchar](50) NULL
)
GO

CREATE TABLE [ETL].[DELTAS](
	[ElabID] int NULL,
	[ClubID] int NULL,
	[RowID] [int] NULL,
	[UnivocalLocationCode] [varchar](30) NULL,
	[ServerTime] [datetime2](3) NULL,
	[MachineID] [tinyint] NULL,
	[GD] [varchar](30) NULL,
	[AamsMachineCode] [varchar](30) NULL,
	[GameID] [int] NULL,
	[GameName] [varchar](100) NULL,
	[LoginFlag] [bit] NULL,
	[VLTCredit] [int] NULL,
	[TotalBet] [int] NULL,
	[TotalWon] [int] NULL,
	[TotalBillIn] [int] NULL,
	[TotalCoinIn] [int] NULL,
	[TotalTicketIn] [int] NULL,
	[TotalHandPay] [int] NULL,
	[TotalTicketOut] [int] NULL,
	[Tax] [int] NULL,
	[TotalIn] [int] NULL,
	[TotalOut] [int] NULL,
	[WrongFlag] [bit] NULL,
	[TicketCode] [varchar](50) NULL,
	[FlagMinVltCredit] [bit] NULL,
	[SessionID] [int] NULL
)
GO

*/
ALTER PROC	[ETL].[LaunchHundredTicketsDemo]
			@ClubID int = NULL
AS
DECLARE
		@ConcessionaryID	tinyint = 7
		,@ConcessionaryName	varchar(30)
		,@XCONFIG			XML -- ex Config.Table
		,@XRAWDelta			XML -- ex RAW.Delta
		,@XRAWSession		XML -- ex RAW.Session
		,@ID				int
		,@ReturnCode		int
		,@TicketCode		varchar(50)
		,@token				uniqueidentifier
		,@INNERSQL			Nvarchar(MAX)

DECLARE	@Running TABLE(ID int IDENTITY(1,1), TicketCode varchar(50))

IF OBJECT_ID('tempdb..##PICKUP') IS  NULL 
	--DROP TABLE ##PICKUP
	CREATE TABLE  ##PICKUP(
		ID int NOT NULL
		,ClubID int NOT NULL
		,INNERSQL nvarchar(MAX) NULL
		,picked bit NULL DEFAULT(0)
		,Token uniqueidentifier NULL
		,ReturnValue int NULL
		,CONSTRAINT PK_PICK_UP PRIMARY KEY CLUSTERED(
			ID ASC
			,ClubID ASC
		)
	)	


SET @ClubID = ISNULL(@ClubID,1000456)  -- [1000456 = 1 solo ticket]

INSERT	@Running
--VALUES ('14214358217068117'),('17697061134408396'),('20606643902271817')
SELECT	TicketID AS TicketCode
FROM	GMATICA_AGS_RawData_Elaborate_Tip.GDF.agn_input_ticket_2017_1
WHERE	ClubID = @ClubID

SET @ConcessionaryName = ETL.getConcessionaryName(@ConcessionaryID)
SET	@XCONFIG =	ETL.WriteXCONFIG(@XCONFIG, @ConcessionaryID, 'POM-MON01', 25, 45, 7200, 50, @ConcessionaryName, 1, 1) 

TRUNCATE TABLE ##PICKUP
TRUNCATE TABLE AsyncExecResults 

DECLARE TICKETS_CUR CURSOR FORWARD_ONLY STATIC READ_ONLY -- FAST_FORWARD
FOR 
	SELECT	ID, TicketCode
	FROM	@Running
	ORDER BY TicketCode

OPEN TICKETS_CUR;
FETCH NEXT FROM TICKETS_CUR INTO @ID, @TicketCode

WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @INNERSQL = ETL.BuildDynSQL_CalcAllLevel (@ConcessionaryID, @TicketCode, @ID, @ClubID, @XCONFIG)
		
		INSERT	##PICKUP(ID, ClubID, INNERSQL,picked,Token,ReturnValue)
		SELECT	@ID, @ClubID, @INNERSQL, 0, NULL, NULL
		FROM	@Running
		WHERE	ID = @ID
	
		--EXEC AsyncExecInvoke N'AsyncSQL', @token OUTPUT
		EXEC	sp_executesqL @INNERSQL, N'@ReturnCode int OUTPUT', @ReturnCode=@ReturnCode

		UPDATE	##PICKUP
		SET		token = @token
				,Returnvalue = @ReturnCode 
		WHERE	ID = @ID	
		AND		ClubID = @ClubID

		FETCH NEXT FROM TICKETS_CUR INTO @ID, @TicketCode
	END

CLOSE TICKETS_CUR;
DEALLOCATE TICKETS_CUR;
GO
