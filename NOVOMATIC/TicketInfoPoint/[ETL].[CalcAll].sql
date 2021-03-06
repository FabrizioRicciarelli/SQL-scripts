﻿/* 
Template NIS (1.1 - 2015-04-01)  

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗ 
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝ 
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║      
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║      
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗ 
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ 
                                                                             
Author..............: Fabrizio Ricciarelli
Creation Date.......: 2018-01-17  
Description.........: Calcola tutti i livelli delta, sessioni, ticket - Versione in memoria (nessuna tabella fisica coinvolta)  

Note 
- Use Tab size = 3 and Indent size 3 

------------------ 
-- Parameters   -- 
------------------   

------------------ 
-- Call Example -- 
------------------  

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE 
		@XCONFIG XML -- ex [Config].[Table]
		,@XTMPTicketStart XML -- ex [TMP].[TicketStart]
		,@XRawDelta XML
		,@XRawSession XML

SET	@XCONFIG =	ETL.WriteXCONFIG(
					@XCONFIG
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

EXEC	ETL.CalcAll 
		@Direction = 0
		,@BatchID = 1
		,@Xconfig = @XCONFIG
		,@XTMPTicketStart = @XTMPTicketStart
		,@XRawDelta = @XRawDelta OUTPUT
		,@XRawSession = @XRawSession OUTPUT
SELECT * FROM ETL.GetAllXRD(@XRawDelta) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetAllXRS(@XRawSession) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE 
		@XCONFIG XML -- ex [Config].[Table]
		,@XTMPTicketStart XML -- ex [TMP].[TicketStart]
		,@XRawDelta XML
		,@XRawSession XML

SET	@XCONFIG = ETL.WriteXCONFIG(@XCONFIG, 7, 'POM-MON01', 25, 45, 7200, 50, 'GMatica', 1, 1) -- CARICA UN ELEMENTO AL CONTENITORE @XCONFIG (ex [Config].[Table])
SET	@XTMPTicketStart =  ETL.WriteXTICKETS(     @XTMPTicketStart,        1, 1000114, '205211897507353489',       150001,    'GD010024135',                 33, '2017-07-09 01:25:04',           NULL,             NULL,        NULL,            NULL,                NULL, '2017-10-07',  '2017-07-09 01:50:39.000',       NULL,         NULL,                NULL) -- CARICA UN ELEMENTO AL CONTENITORE (ex [TMP].[TicketStart])

EXEC	ETL.CalcAll 
		@Direction = 0
		,@BatchID = 1
		,@Xconfig = @XCONFIG
		,@XTMPTicketStart = @XTMPTicketStart
		,@XRawDelta = @XRawDelta OUTPUT
		,@XRawSession = @XRawSession OUTPUT
SELECT * FROM ETL.GetAllXRD(@XRawDelta) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetAllXRS(@XRawSession) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE 
		@XCONFIG XML -- ex [Config].[Table]
		,@XTMPTicketStart XML -- ex [TMP].[TicketStart]
		,@XRawDelta XML
		,@XRawSession XML

SET	@XCONFIG = ETL.WriteXCONFIG(@XCONFIG, 7, 'POM-MON01', 25, 45, 7200, 50, 'GMatica', 1, 1) -- CARICA UN ELEMENTO AL CONTENITORE @XCONFIG (ex [Config].[Table])
SET	@XTMPTicketStart =  ETL.WriteXTICKETS(     @XTMPTicketStart,        1, 1000114, '205211897507353489',       150001,    'GD010024135',                 33, '2017-07-09 01:25:04',           NULL,             NULL,        NULL,            NULL,                NULL, '2017-10-07',  '2017-07-09 01:50:39.000',       NULL,         NULL,                NULL) -- CARICA UN ELEMENTO AL CONTENITORE (ex [TMP].[TicketStart])

EXEC	ETL.CalcAll 
		@Direction = 0
		,@BatchID = 1
		,@Xconfig = @XCONFIG
		,@XTMPTicketStart = @XTMPTicketStart
		,@XRawDelta = @XRawDelta OUTPUT
		,@XRawSession = @XRawSession OUTPUT
SELECT * FROM ETL.GetAllXRD(@XRawDelta) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetAllXRS(@XRawSession) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE 
		@XCONFIG XML -- ex [Config].[Table]
		,@XTMPTicketStart XML -- ex [TMP].[TicketStart]
		,@XRawDelta XML
		,@XRawSession XML

SET	@XCONFIG = ETL.WriteXCONFIG(@XCONFIG, 1, 'POM-MON01', 25, 45, 7200, 50, 'GMatica', 1, 1) -- CARICA UN ELEMENTO AL CONTENITORE @XCONFIG (ex [Config].[Table])
SET	@XTMPTicketStart =  ETL.WriteXTICKETS(     @XTMPTicketStart,        1, 1000114, '205211897507353489',       150001,    'GD010024135',                 33, '2017-07-09 01:25:04',           NULL,             NULL,        NULL,            NULL,                NULL, '2017-10-07',  '2017-07-09 01:50:39.000',       NULL,         NULL,                NULL) -- CARICA UN ELEMENTO AL CONTENITORE (ex [TMP].[TicketStart])

EXEC	ETL.CalcAll 
		@Direction = 0
		,@BatchID = 1
		,@Xconfig = @XCONFIG
		,@XTMPTicketStart = @XTMPTicketStart
		,@XRawDelta = @XRawDelta OUTPUT
		,@XRawSession = @XRawSession OUTPUT
SELECT * FROM ETL.GetAllXRD(@XRawDelta) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetAllXRS(@XRawSession) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/ 
ALTER PROC	[ETL].[CalcAll] 
			@Direction					bit
			,@TicketCode				varchar(50) = NULL
			,@Level						int = NULL 
			,@SessionParentID			int = NULL 
			,@BatchID					int
			,@Xconfig					XML			-- ex Config.Table
			,@XTMPTicketStart			XML			-- ex TMP.TicketStart
			,@XRawSession				XML OUTPUT	-- ex RAW.Session
			,@XRawDelta					XML OUTPUT	-- ex RAW.Delta
			,@XTMPTicketServerTime		XML OUTPUT	-- ex TMP.TicketServerTime
			,@XTMPCountersCork			XML OUTPUT	-- ex TMP.CountersCork
			,@XRawTicketMatched			XML OUTPUT	-- ex RAW.TicketMatched
			,@XTMPDeltaTicketIN			XML OUTPUT	-- ex TMP.DeltaTicketIN
			,@XTMPDeltaTicketOUT		XML OUTPUT	-- ex TMP.DeltaTicketOUT
			,@ReturnCode				int = NULL Output 
AS
 
SET NOCOUNT ON; 

DECLARE 
		@ConcessionaryID		smallint
		,@ClubID				int 
		,@ConcessionaryDB		varchar(50) 
        ,@Message				varchar(1000) 
        ,@Msg					varchar(1000) 
        ,@ReturnCodeInternal	int 
        ,@ReturnCodeGlobal		int 
        ,@CalcEnd				bit 
        ,@VltEndCredit			int 
        ,@CashDesk				tinyint = 0 
        ,@PayoutDate			datetime2(3) 
        ,@ServerTime_FIRST		datetime = '1900-01-01 00:00:00.000' 
        ,@PrintingDate			datetime2(3) 
        ,@ServerTimeStart		datetime2(3) 
        ,@ParentID				int
		,@XTMPTicket			XML
		,@XTMPDelta				XML -- ex TMP.Delta

BEGIN TRY 
	EXEC ETL.WriteLog @@PROCID, 'Sub-calcolo iniziato', @TicketCode, @BatchID -- Log operazione  

    SELECT	
			@ConcessionaryID = concessionaryid
			,@VltEndCredit = MinVltEndCredit
			,@ReturnCodeInternal = 0 
	FROM	ETL.GetAllXCONFIG(@XCONFIG) 

	SET @ReturnCode = 0;
	SET @ReturnCodeInternal = 0;

	SELECT	
			@ClubID = ISNULL(@ClubID, ClubID) 
	FROM	ETL.GetAllXTICKETS(@XTMPTicketStart)

	EXEC	@ReturnCodeInternal = 
			ETL.FindCountersCork 
			@XconfigTable = @XCONFIG								-- ex Config.Table
			,@Direction	= @Direction 
			,@TicketCode = @TicketCode 
			,@ClubID = @ClubID 
			,@BatchID = @BatchID
			,@XTMPTicketStart = @XTMPTicketStart OUTPUT				-- ex TMP.TicketStart
			,@XTMPTicketServerTime = @XTMPTicketServerTime OUTPUT	-- ex TMP.TicketServerTime
			,@XTMPCountersCork = @XTMPCountersCork OUTPUT			-- ex TMP.CountersCork

	IF @ReturnCodeInternal = 0
		BEGIN
			EXEC	@ReturnCodeInternal =
					ETL.CalculateDeltaFromTicketOut 
					@XCONFIG = @XCONFIG
					,@XTMPTicketStart = @XTMPTicketStart
					,@XTMPCountersCork = @XTMPCountersCork
					,@XTMPTicketServerTime = @XTMPTicketServerTime
					,@XTMPDelta	= @XTMPDelta OUTPUT

			IF @ReturnCodeInternal <> -1
				BEGIN
					EXEC	@ReturnCodeInternal =
							ETL.Ticketmatching 
							@XCONFIG = @XCONFIG
							,@TicketCode = @TicketCode
							,@Direction = @Direction
							,@XTMPCountersCork = @XTMPCountersCork
							,@XTMPTicketStart = @XTMPTicketStart
							,@XTMPDelta	= @XTMPDelta OUTPUT

					IF @ReturnCodeInternal <> -1
						BEGIN
							EXEC	@ReturnCodeInternal =
									ETL.CalcSession 
									@XCONFIG = @XCONFIG						-- ex Config.Table
									,@SessionParentID = @SessionParentID
									,@Level	= @Level 
									,@XTMPCountersCork = @XTMPCountersCork	-- ex TMP.CountersCork 
									,@XTMPDelta	= @XTMPDelta				-- ex TMP.Delta
									,@XTMPTicketStart = @XTMPTicketStart	-- ex TMP.TicketStart
									,@XRawSession = @XRawSession OUTPUT		-- ex RAW.Session
									,@XRawDelta = @XRawDelta OUTPUT			-- ex RAW.Delta
						END
				END
		END
	
	 ELSE IF  @ReturnCodeInternal = 1 AND @Direction = 1
			BEGIN
				SELECT	@PayoutDate = PayoutDate
				FROM	ETL.GetAllXTICKETS(@XTMPTicketStart) 
				WHERE	TicketCode = @TicketCode

				SELECT	@XRawSession = ETL.WriteXRS(@XRawSession, NULL, @SessionParentID, @Level,NULL, @CashDesk, NULL, NULL, ISNULL(@PayoutDate, @ServerTime_FIRST), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @TicketCode)
			END

	 ELSE IF  @ReturnCodeInternal = 1 AND @Direction = 0
 			BEGIN
				SELECT	@PrintingDate = printingdate
				FROM	ETL.GetAllXTICKETS(@XTMPTicketStart)
 				WHERE	ticketcode = @TicketCode

				SELECT	@XRawSession = ETL.WriteXRS(@XRawSession, NULL, @SessionParentID, @Level,NULL, @CashDesk, NULL, NULL, ISNULL(@PrintingDate, @ServerTime_FIRST), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @TicketCode)
			END
    
	EXEC ETL.WriteLog @@PROCID, 'Sub-calcolo terminato', @TicketCode, @BatchID -- Log operazione  

    --IF @ReturnCodeInternal = -1 
    --BEGIN 
    --    RAISERROR('Internal procedure Error',16,1); 
    --END 

END TRY 

BEGIN CATCH
	INSERT	ERR.ErrorLog(ErrorTime, ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, ErrorTicketCode, ErrorRequestDetailID) 
    SELECT
			GETDATE() AS ErrorTime
			,ERROR_NUMBER() AS ErrorNumber
			,ERROR_SEVERITY() AS ErrorSeverity
			,ERROR_STATE() AS ErrorState
			,ISNULL(ERROR_PROCEDURE(), ISNULL(dbo.GetProcName(@@PROCID),'*Unknown*')) AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine
			,ERROR_MESSAGE() AS	ErrorMessage
			,@TicketCode AS ErrorTicketCode
			,@BatchID AS ErrorRequestDetailID
            SET @ReturnCode = -1;
END CATCH 

RETURN @ReturnCode
