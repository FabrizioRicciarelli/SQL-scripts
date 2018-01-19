--ALTER PROCEDURE [RAW].[LoadingMHRMatching]
--@ClubID varchar(10),
--@IterationNumMax Tinyint = 3,
--@MaxCalcDays SmallInt = NULL,
--@MachineID varchar(5) = NULL
--AS
DECLARE
	@ClubID varchar(10),
	@IterationNumMax Tinyint = 3,
	@MaxCalcDays SmallInt = NULL,
	@MachineID varchar(5) = NULL

DECLARE @StringaDeclare NVARCHAR(MAX) = SPACE(0), @StringaCalcoli NVARCHAR(MAX) = SPACE(0),@StringaCalcoli1 NVARCHAR(MAX) = SPACE(0), @StringaFinale NVARCHAR(MAX) = SPACE(0),
		@SpidNum AS Varchar(5),@MhxTable Varchar(1000);
		-- Creazione tabella di appoggio
		SET @SpidNum = (SELECT @@spid)
		SET @MhxTable =  '##MhxTable' + @SpidNum

BEGIN TRY

DECLARE
		@MaxServerTime DATETIME
		,@MinServerTime DATETIME
		,@MaxDWHMHRDate DATETIME
		,@ReceiptID int
		,@ReceiptMatchTypeID tinyint = 2
		,@ReceiptTypeID tinyint = 2
		,@MAX_Eventdate datetime2(0)
		,@TicketWayID tinyint = 2
		,@MaxSmallInt SmallInt = 32767
		,@SerververTime_MHx datetime2(3)
		,@GD Varchar(20) = NULL
		,@OffSet Int
		,@Stringa Varchar(100)
		,@MhxNumChek Int
		,@DataInizioImportazione datetime2(3)
		,@DataVltCalc Varchar(24)
		,@IterationNum Tinyint
		,@MatchedTickNum Int
		,@ExpiringDays SmallInt

DECLARE @TableMachine TABLE
		(
			Indice smallint identity(1,1)
			,MachineID tinyint
			, Machine varchar(30)
		)

SELECT  @DataInizioImportazione = sysdatetime();

-- log
SELECT @DataVltCalc = CONVERT(VARCHAR(24),GETDATE(),21)
SET @Stringa = @ClubID +  @DataVltCalc + ' : Inizio Calcolo MHX '
PRINT(@Stringa)

SET @IterationNum  = 1
SET @MhxNumChek = 0

-- Valori di offset
SELECT	@OffSet = 
		SearchMHROffSet 
FROM	[Config].[Table] 

-- Calcolo di default
SELECT	@ExpiringDays = 
		[ExpiringDays] 
FROM	[Config].[Table]

IF @MaxCalcDays IS NULL
	BEGIN
		SELECT	@MaxCalcDays = 
				[ExpiringDays] 
		FROM	[Config].[Table] 
	END

-- SolO le VLT per l' incrementale
IF(@MaxCalcDays > 0 OR @MaxCalcDays IS NULL)
	INSERT INTO @TableMachine(MachineID, Machine)	 
	Select	T1.MachineID, Machine 
	FROM	[RAW].[CountersCork] T1  
			INNER JOIN 
			[RAW].Machine T2
			ON T1.ClubID = T2.ClubID 
			AND T1.MachineID = T2.MachineID 
	WHERE	Calcdays <= @ExpiringDays 
	AND		T1.ClubID   = @ClubID  
	AND		t1.MachineID = ISNULL(@MachineID, t1.MachineID)

-- Le VLT per i totali
ELSE IF (@MaxCalcDays = 0) 
	INSERT INTO @TableMachine(MachineID, Machine)
	Select	T1.MachineID,Machine 
	FROM	[RAW].[CountersCork] T1  
			INNER JOIN 
			[RAW].Machine T2
			ON T1.ClubID = T2.ClubID 
			AND T1.MachineID = T2.MachineID 
	WHERE	Calcdays > @ExpiringDays 
	AND		T1.ClubID = @ClubID 
	AND		t1.MachineID = ISNULL(@MachineID, t1.MachineID)

--tutte le VLT	
ELSE IF(@MaxCalcDays = -1) 
	INSERT INTO @TableMachine(MachineID, Machine)
	Select	MachineID,Machine 
	FROM	[RAW].Machine 
	WHERE	ClubID = @ClubID 
	AND		MachineID = ISNULL(@MachineID, MachineID)

-- Tablella receipt
IF OBJECT_ID(N'tempdb..#Receipt_LK_Delta') IS NOT NULL 
	DROP TABLE #Receipt_LK_Delta;
CREATE TABLE #Receipt_LK_Delta ([ReceiptID] [int],[RowID] [int],[SessionID] [int] ,[TicketWayID] [tinyint], [ReceiptMatchTypeID] [tinyint],[DifferenceMatchType] SmallInt)	
	
IF OBJECT_ID(N'tempdb..#MhxTable') IS NOT NULL 
	DROP TABLE #MhxTable;	
CREATE TABLE #MhxTable (ReceiptID Int Not Null, ReceiptValue Bigint Null, EventDate Datetime2(0), Machine Varchar(30) null)

-- Solo le VLT nei cork e ultimo linkato
IF  @MaxCalcDays >= 0 		
	SET	@MAX_Eventdate = IsNULL
		(
			(
				SELECT MAX(Eventdate) 
				FROM [RAW].[MHx] T1 
				INNER JOIN 
				@TableMachine T4 
				ON T1.Machine = T4.Machine 
				AND T1.ClubID = @ClubID 
				WHERE LinkedData IS NOT NULL
			)
			, '1900-01-01'
		)

ELSE
-- Tutte le VLT e parto dall'inizio dei tempi				
	SET @MAX_Eventdate = IsNULL
		(
			(
				SELECT MIN(Eventdate) 
				FROM [RAW].[MHx] T1 
				INNER JOIN 
				@TableMachine T4 
				ON T1.Machine = T4.Machine 
				AND T1.ClubID = @ClubID  
				WHERE LinkedData IS NULL
			)
			, '1900-01-01'
		)

SET @MatchedTickNum = 0;

-----------------------------------
-- Matching MHx                  --
-----------------------------------	
WHILE @IterationNum <= @IterationNumMax
	BEGIN
		IF @IterationNum = 1 
			BEGIN  
				INSERT INTO #MhxTable(ReceiptID, ReceiptValue, EventDate, Machine)
				SELECT	ReceiptID, ReceiptValue, EventDate, T1.Machine 
				FROM	[RAW].[MHx] T1 
						INNER JOIN
						@TableMachine T4 
						ON T1.Machine = T4.Machine 
						AND T1.ClubID = @ClubID 
				WHERE LinkedData IS NULL 
				AND EventDate >= @MAX_Eventdate		
			
				SET @MhxNumChek = @@RowCount
			
				IF @MhxNumChek = 0 
					BEGIN
						SET @IterationNum = 250
						BREAK
					END
				ELSE		
					CONTINUE		 
			END	
		ELSE 
			BEGIN
				SET @MAX_Eventdate = IsNULL((SELECT MIN(Eventdate) FROM #MhxTable), '1900-01-01');
				Truncate table #Receipt_LK_Delta
				
				-- Iterazioni
				IF @IterationNum = 2
				SET @OFFSET = @OFFSET * 8	
				IF @IterationNum = 3
				SET @OFFSET = @OFFSET * 3	
			END
		-- Matching
		;WITH Delta AS 
		(
			SELECT	T1.RowID, ServerTime, MachineTime, T1.MachineID, TotalHandPay ReceiptValue,T2.ClubID, T2.Machine
					,DATEADD(SECOND,  @OffSET, T1.ServerTime) TimePlusOffset 
					,DATEADD(SECOND, -@OffSET, T1.ServerTime) TimeLessOffset
			FROM	[' + @ClubID + '].Delta t1
					INNER JOIN 
					[RAW].Machine t2 
					ON t1.MachineID = t2.MachineID 
					AND t2.ClubID = @ClubID 
					AND T2.MachineID = ISNULL(@MachineID, T2.MachineID)
			WHERE	(
						ServerTime > DATEADD(SECOND, -@OffSET, @MAX_Eventdate) 
					) 
			AND TotalHandPay > 0 
		)
		,Delta_LK_MHx AS  
		(
			SELECT	t2.ReceiptID, t1.RowID, MachineID, ServerTime,ABS(DATEDIFF(SECOND, t1.ServerTime, t2.EventDate)) AS ABSSecondDiff
					,ROW_NUMBER() OVER (PARTITION BY t2.ReceiptID ORDER BY ABS(DATEDIFF(SECOND, t1.ServerTime, t2.EventDate))) AS Row_Number
			FROM	Delta t1 
					INNER JOIN 
					#MhxTable t2 
					ON  
					(
						TimeLessOffset < EventDate 
						AND TimePlusOffset > EventDate
					) 
					AND t1.ReceiptValue = t2.ReceiptValue 
					AND t1.Machine = t2.Machine	
		)
		,CTEReceipt_LK_Delta AS 
		(
			SELECT	ReceiptID, RowID, @TicketWayID AS TicketWayID, @ReceiptTypeID AS ReceiptTypeID
					,IIF(ABSSecondDiff < @MaxSmallInt,ABSSecondDiff,@MaxSmallInt) AS ABSSecondDiff, t2.SessionID 
			FROM	Delta_LK_MHx t1 
					INNER JOIN 
					[' + @ClubID + '].Session t2  
					ON t1.ServerTime BETWEEN t2.StartServerTime AND ISNULL(t2.EndServerTimeExtended, t2.EndServerTime) 
					AND t1.MachineID = t2.MachineID 
			WHERE	Row_Number = 1 
		)
		,CTEReceipt_LK_Delta2 AS 
		(
				-- Per evitare il link doppio su un'unico delta, su delta molto vicini con lo stesso valore di ticket
			SELECT	[ReceiptID],[RowID],[SessionID] ,[TicketWayID] , ReceiptTypeID ,ABSSecondDiff
					,RANK() OVER  (PARTITION BY ROWID ORDER BY ABSSecondDiff  ASC) AS RowRank 
			FROM 	CTEReceipt_LK_Delta
		)
		-- Aggiorno tabelle in produzione	
		MERGE INTO [' + @ClubID + '].Receipt_LK_Delta AS Target
		USING 
		(
			SELECT	[ReceiptID],[RowID],[SessionID],[TicketWayID],ReceiptTypeID,ABSSecondDiff 
			FROM	CTEReceipt_LK_Delta2 
			WHERE	RowRank = 1
		) AS Source 

		-- Evito di linkare i delta già linkati
		ON Target.RowID =  Source.RowID

		WHEN NOT MATCHED THEN
		INSERT  (ReceiptID, RowID, TicketWayID, ReceiptMatchTypeID, DifferenceMatchType, SessionID)
		Values  (Source.ReceiptID, Source.RowID, Source.TicketWayID, Source.ReceiptTypeID, Source.ABSSecondDiff, Source.SessionID)
		
		OUTPUT inserted.ReceiptID,inserted.[RowID],inserted.SessionID,inserted.[TicketWayID] ,inserted.[ReceiptMatchTypeID] , inserted.DifferenceMatchType
		-- Tabella finale
		INTO #Receipt_LK_Delta ([ReceiptID],[RowID],[SessionID],[TicketWayID] , [ReceiptMatchTypeID] ,[DifferenceMatchType] );

		UPDATE	[RAW].[Mhx]
		SET		[LinkedData] = GETDATE()
		WHERE	[LinkedData] IS NULL
		AND		ReceiptID IN 
				(
					SELECT	ReceiptID 
					FROM	#Receipt_LK_Delta
				)
			
		SET @MatchedTickNum += (Select Count(*) FROM #Receipt_LK_Delta)

		-- Cancello i matchati nell'iterazione
		DELETE 
		FROM	#MhxTable 
		WHERE	ReceiptID IN 
				(
					SELECT	ReceiptID 
					FROM	#Receipt_LK_Delta
				)
		
		IF (Select Count(*) FROM #MhxTable) = 0  
			SET  @IterationNum = 253

		SET @IterationNum += 1
	END
	-- operazioni finali
	IF @IterationNum >= @IterationNumMax
	BEGIN
		-- log
		SELECT @DataVltCalc = CONVERT(VARCHAR(24),GETDATE(),21)
		SET @Stringa = '' + @ClubID + ' '  +  @DataVltCalc + ' : Fine Calcolo MHX ' + ' iterazione  '  + Cast(@IterationNum  AS Varchar(3)) + ' matchati  ' + Cast(@MatchedTickNum AS Varchar(20))
		PRINT(@Stringa)

		IF @MachineID IS NULL
			BEGIN
				SET	@SerververTime_MHx = 
					(
						SELECT	Max(EventDate) 
						FROM	[RAW].[MHx] 
						WHERE	ClubID = @ClubID 
						AND		LinkedData IS NOT NULL
					) 		
				----------------------------------------------
				-- Aggiornamento ETL.LoadingRawDataSummary  --
				----------------------------------------------
				UPDATE	[ETL].[LoadingRawDataSummary]
				SET		ServerTime_MHx = @SerververTime_MHx 
				WHERE	ClubID = @ClubID
			END
		
		IF @IterationNum = @IterationNumMax
		BEGIN
			----------------------------------------------
			-- Memorizzo gli MH che non riesco a matchare  --
			----------------------------------------------		
			MERGE INTO [RAW].[MhxNeverMatched] AS Target
			USING 
			(
				SELECT	ReceiptID 
				FROM	#MhxTable
			) AS Source 
			ON Target.ReceiptID = Source.ReceiptID
			WHEN NOT MATCHED THEN
			INSERT (ReceiptID) VALUES (Source.ReceiptID);
		END

		----------------------------------------------	
		-- Pulizia
		----------------------------------------------	
		IF OBJECT_ID(N'tempdb..#MhxTable') IS NOT NULL 
			DROP TABLE #MhxTable;	
		IF OBJECT_ID(N'tempdb..#Receipt_LK_Delta') IS NOT NULL 
			DROP TABLE #Receipt_LK_Delta;		
	END
END TRY

BEGIN CATCH	
	DECLARE @DailyLoadingType_MHMatching tinyint = 4, @Message VARCHAR(1000) = ERROR_MESSAGE();
	INSERT INTO ETL.DailyLoading(DailyLoadingType, DailyLoadingDate, DailyLoadingClubID, DailyLoadingMachineID, DailyLoadingMessage)
	VALUES(@DailyLoadingType_MHMatching, @DataInizioImportazione, @ClubID, NULL, @Message)
END CATCH;
