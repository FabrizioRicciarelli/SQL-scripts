/*
EXEC	ETL.LaunchHundredTicketsDemo

SELECT	*
FROM 	##CONFIG_PICKUP
SELECT	* 
FROM	AsyncExecResults
SELECT	* 
FROM	ETL.OperationLog

-------------------------------------------------------
RICHIEDE LA PRESENZA DELLE SEGUENTI TABELLE DI OUTPUT:
(selezionare ed eseguire prima di lanciare la SP)
-------------------------------------------------------
CREATE TABLE [ETL].[SESSIONS](
	[ElabID] int NULL,
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
ALTER PROC [ETL].[LaunchHundredTicketsDemo]
AS
DECLARE
		@ConcessionaryID	tinyint = 7
		,@ConcessionaryName	varchar(30)
		,@XCONFIG			XML -- ex Config.Table
		,@XRAWDelta			XML -- ex RAW.Delta
		,@XRAWSession		XML -- ex RAW.Session
		,@ID				int
		,@TicketCode		varchar(50)
		,@token				uniqueidentifier
		,@TICKETS_CUR		cursor

DECLARE	@Running TABLE(ID int IDENTITY(1,1), TicketCode varchar(50))

--IF OBJECT_ID('tempdb..##CONFIG_PICKUP') IS NOT NULL 
--	DROP TABLE ##CONFIG_PICKUP

IF OBJECT_ID('tempdb..##CONFIG_PICKUP') IS  NULL 
	CREATE TABLE ##CONFIG_PICKUP(
					ID int NOT NULL PRIMARY KEY CLUSTERED
					,ConcessionaryID tinyint NULL
					,Position varchar(50) NULL
					,OffSetIN smallint NULL
					,OffSetOut smallint NULL
					,OffSetMh int NULL
					,MinVltEndCredit int NULL
					,ConcessionaryName varchar(50) NULL
					,FlagDbArchive bit NULL
					,OffsetRawData int NULL
					,TicketCode varchar(50) NULL
					,picked bit DEFAULT(0) NULL
					,Token uniqueidentifier
				)

-- 101 Tickets del ClubID 1000221
INSERT	@Running
VALUES ('14214358217068117'),('17697061134408396'),('20606643902271817')
--SELECT	TicketID AS TicketCode
--FROM	GMATICA_AGS_RawData_Elaborate_Tip.GDF.agn_input_ticket_2017_1
--WHERE	ClubID = 1000221 

SET @ConcessionaryName = ETL.getConcessionaryName(@ConcessionaryID)
SET	@XCONFIG =	ETL.WriteXCONFIG(@XCONFIG, @ConcessionaryID, 'POM-MON01', 25, 45, 7200, 50, @ConcessionaryName, 1, 1) 

TRUNCATE TABLE ##CONFIG_PICKUP
TRUNCATE TABLE ETL.OperationLog
TRUNCATE TABLE AsyncExecResults 

SET @TICKETS_CUR = CURSOR FAST_FORWARD 
FOR 
	SELECT	ID, TicketCode
	FROM	@Running
	ORDER BY TicketCode

OPEN @TICKETS_CUR;
FETCH NEXT FROM @TICKETS_CUR INTO @ID, @TicketCode

WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT	##CONFIG_PICKUP
		SELECT	@ID, 7, 'POM-MON01', 25, 45, 7200, 50, @ConcessionaryName, 1, 1, @TicketCode, 0, NULL
		FROM	@Running
		WHERE	ID = @ID
	
		EXEC AsyncExecInvoke N'AsyncCalcAllLevel', @token OUTPUT

		UPDATE	##CONFIG_PICKUP
		--SET		picked = 1, token = @token
		SET		token = @token 
		WHERE	ID = @ID	

		FETCH NEXT FROM @TICKETS_CUR INTO @ID, @TicketCode
	END

CLOSE @TICKETS_CUR;
DEALLOCATE @TICKETS_CUR;
GO
