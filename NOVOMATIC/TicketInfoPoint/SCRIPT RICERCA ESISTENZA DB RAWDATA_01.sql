DECLARE
		@tkStart XML -- ex [TMP].[TicketStart]
		,@XCONFIG XML -- ex [Config].[Table]

SET	@XCONFIG = ETL.WriteXCONFIG(@XCONFIG, 1, 'POM-MON01', 25, 45, 7200, 50, 'GMatica', 1, 1) -- CARICA UN ELEMENTO NEL CONTENITORE @XCONFIG (ex [Config].[Table])


DECLARE
		-- Params 
		@ClubID varchar(10) = '1000002'
		,@ConcessionaryName sysname

		-- Dynamic SQL containers
		,@OUTERMOSTSQL Nvarchar(MAX) -- DA ESEGUIRE SU QUESTA MACCHINA
		,@OUTERSQLdbexists Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA POM-MON01
		,@OUTERSQLexistsDBstd Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA POM-MON01
		,@OUTERSQLexistsTable Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA POM-MON01
		,@INNERSQLdbexists Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA PIN
		,@INNERSQLexistsDBstd Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA PIN
		,@INNERSQLexistsTable Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA PIN

		,@CreateViewStr NVARCHAR(MAX)

		-- DB & Table names
		,@Position sysname
		,@RawDataDBname sysname
		,@RawDataTable sysname
		,@RawDataTableDBstd sysname

		-- Flags
		,@DB01ExistsOnPIN bit = 0
		,@DB01TableExistsOnPIN bit = 0
		,@DBstdExistsOnPIN bit = 0
		,@DBstdTableExistsOnPIN bit = 0
		,@DB01ExistsOnPOMMON bit = 0
		,@DB01TableExistsOnPOMMON bit = 0
		,@DBstdExistsOnPOMMON bit = 0
		,@DBstdTableExistsOnPOMMON bit = 0
		,@IsPIN bit = 0


SELECT	
		@Position = Position
		,@ConcessionaryName = ConcessionaryName  
FROM	ETL.GetXCONFIG(@XCONFIG,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI



----------------------------------------------------------------------------------------
-- 1. RICERCA DEL DB AGS_RawData_01 NELLE MACCHINE PIN
-- (Valorizzazione del flag @DB01ExistsOnPIN)
----------------------------------------------------------------------------------------
SET @RawDataDBname = 'AGS_RawData_01'
SET @INNERSQLdbexists = [ETL].[BuildDynSQL_DBExists] (@RawDataDBname)
--N'
--SELECT	bitValue =
--		CASE
--			WHEN	EXISTS(
--						SELECT	TOP 1
--								name
--						FROM	sys.databases
--						WHERE	name = ''''' + @RawDataDBname + '''''
--					)
--			THEN	1
--			ELSE	0
--		END
--'
SET @OUTERSQLdbexists = N'SELECT bitValue FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + @INNERSQLdbexists + ''')'
SELECT	@OUTERMOSTSQL = 
		CASE	
			WHEN	@@SERVERNAME LIKE '%DEV%' -- DETERMINA L'AMBIENTE SUL QUALE E' IN ESECUZIONE LA CORRENTE STORED PROCEDURE
			THEN	N'SELECT @returnValue = (SELECT bitValue FROM OPENQUERY([POM-MON01],'''+ REPLACE(@OUTERSQLdbexists,'''','''''') +'''))' -- QUERY PER ESECUZIONE IN AMBIENTE DI SVILUPPO  
			ELSE	N'SELECT @returnValue = (' + @OUTERSQLdbexists + ')' -- QUERY PER ESECUZIONE IN AMBIENTE DI PRODUZIONE
		END

EXEC	sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DB01ExistsOnPIN OUT

--PRINT(@OUTERMOSTSQL)
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 1.b SE ESISTE IL DB AGS_RawData_01 NELLE MACCHINE PIN, CERCA ANCHE LA TABELLA
-- (Valorizzazione del flga @DB01TableExistsOnPIN)
----------------------------------------------------------------------------------------
IF @DB01ExistsOnPIN = 1
	BEGIN
		SET @RawDataDBname = 'AGS_RawData_01'
		SET @RawDataTable = 'RawData' -- su DB01 il nome di tabella NON è "RawData_View" bensì "RawData"
		SELECT @INNERSQLexistsTable = [ETL].[BuildDynSQL_TableExists] (@RawDataDBname, @RawDataTable, @ClubID)

		--SET @INNERSQLexistsTable = REPLACE
		--(
		--	N'
		--	SELECT	bitValue =
		--			CASE
		--				WHEN	EXISTS(
		--							SELECT	TOP 1 
		--									* 
		--							FROM	$.[sys].[tables] TBL WITH(NOLOCK)
		--									INNER JOIN 
		--									$.[sys].[partitions] PART WITH(NOLOCK) 
		--									ON TBL.object_id = PART.object_id
		--									INNER JOIN 
		--									$.[sys].[indexes] IDX WITH(NOLOCK) 
		--									ON PART.object_id = IDX.object_id
		--									INNER JOIN 
		--									$.[sys].[schemas] SCH WITH(NOLOCK) 
		--									ON TBL.schema_id = SCH.schema_id
		--							WHERE	TBL.name = ''''' + @RawDataTable + ''''' 
		--							AND		SCH.Name = ''''' + @ClubID + '''''
		--						)
		--				THEN	1
		--				ELSE	0
		--			END 			  
		--	'
		--	,'$','[' + @RawDataDBname +']'
		--)

		SET @OUTERSQLexistsTable = N'SELECT bitValue FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + @INNERSQLexistsTable + ''')'
		SELECT	@OUTERMOSTSQL = 
				CASE	
					WHEN	@@SERVERNAME LIKE '%DEV%' -- DETERMINA L'AMBIENTE SUL QUALE E' IN ESECUZIONE LA CORRENTE STORED PROCEDURE
					THEN	N'SELECT @returnValue = (SELECT bitValue FROM OPENQUERY([POM-MON01],'''+ REPLACE(@OUTERSQLexistsTable,'''','''''') +'''))' -- QUERY PER ESECUZIONE IN AMBIENTE DI SVILUPPO  
					ELSE	N'SELECT @returnValue = (' + @OUTERSQLexistsTable + ')' -- QUERY PER ESECUZIONE IN AMBIENTE DI PRODUZIONE
				END

		EXEC	sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DB01TableExistsOnPIN OUT

		--PRINT(@OUTERMOSTSQL)
	END
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 2. RICERCA DEL DB AGS_RawData NELLE MACCHINE PIN
-- (Valorizzazione del flga @DBstdExistsOnPIN)
----------------------------------------------------------------------------------------
SET @RawDataDBname = 'AGS_RawData'
SET @INNERSQLdbexists = [ETL].[BuildDynSQL_DBExists] (@RawDataDBname)
--SET @INNERSQLexistsDBstd = 
--N'
--SELECT	bitValue =
--		CASE
--			WHEN	EXISTS(
--						SELECT	TOP 1
--								name
--						FROM	sys.databases
--						WHERE	name = ''''' + @RawDataDBname + '''''
--					)
--			THEN	1
--			ELSE	0
--		END
--'
SET @OUTERSQLexistsDBstd = N'SELECT bitValue FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + @INNERSQLdbexists + ''')'
SELECT	@OUTERMOSTSQL = 
		CASE	
			WHEN	@@SERVERNAME LIKE '%DEV%' -- DETERMINA L'AMBIENTE SUL QUALE E' IN ESECUZIONE LA CORRENTE STORED PROCEDURE
			THEN	N'SELECT @returnValue = (SELECT bitValue FROM OPENQUERY([POM-MON01],'''+ REPLACE(@OUTERSQLexistsDBstd,'''','''''') +'''))' -- QUERY PER ESECUZIONE IN AMBIENTE DI SVILUPPO  
			ELSE	N'SELECT @returnValue = (' + @OUTERSQLexistsDBstd + ')' -- QUERY PER ESECUZIONE IN AMBIENTE DI PRODUZIONE
		END

EXEC	sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DBstdExistsOnPIN OUT

--PRINT(@OUTERMOSTSQL)
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 2.b SE ESISTE IL DB AGS_RawData NELLE MACCHINE PIN, CERCA ANCHE LA TABELLA
-- (Valorizzazione del flga @DBstdTableExistsOnPIN)
----------------------------------------------------------------------------------------
IF @DBstdExistsOnPIN = 1
	BEGIN
		SET @RawDataDBname = 'AGS_RawData'
		SET @RawDataTable = 'RawData'
		SELECT @INNERSQLexistsTable = [ETL].[BuildDynSQL_TableExists] (@RawDataDBname, @RawDataTable, @ClubID)

		--SET @INNERSQLexistsTable = REPLACE
		--(
		--N'
		--SELECT	bitValue =
		--		CASE
		--			WHEN	EXISTS(
		--						SELECT	TOP 1 
		--								* 
		--						FROM	$.[sys].[tables] TBL WITH(NOLOCK)
		--								INNER JOIN 
		--								$.[sys].[partitions] PART WITH(NOLOCK) 
		--								ON TBL.object_id = PART.object_id
		--								INNER JOIN 
		--								$.[sys].[indexes] IDX WITH(NOLOCK) 
		--								ON PART.object_id = IDX.object_id
		--								INNER JOIN 
		--								$.[sys].[schemas] SCH WITH(NOLOCK) 
		--								ON TBL.schema_id = SCH.schema_id
		--						WHERE	TBL.name = ''''' + @RawDataTable + ''''' 
		--						AND		SCH.Name = ''''' + @ClubID + '''''
		--					)
		--			THEN	1
		--			ELSE	0
		--		END 			  
		--','$','[' + @RawDataDBname +']')

		SET @OUTERSQLexistsTable = N'SELECT bitValue FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + @INNERSQLexistsTable + ''')'
		SELECT	@OUTERMOSTSQL = 
				CASE	
					WHEN	@@SERVERNAME LIKE '%DEV%' -- DETERMINA L'AMBIENTE SUL QUALE E' IN ESECUZIONE LA CORRENTE STORED PROCEDURE
					THEN	N'SELECT @returnValue = (SELECT bitValue FROM OPENQUERY([POM-MON01],'''+ REPLACE(@OUTERSQLexistsTable,'''','''''') +'''))' -- QUERY PER ESECUZIONE IN AMBIENTE DI SVILUPPO  
					ELSE	N'SELECT @returnValue = (' + @OUTERSQLexistsTable + ')' -- QUERY PER ESECUZIONE IN AMBIENTE DI PRODUZIONE
				END
		
		EXEC	sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DBstdTableExistsOnPIN OUT
		
		--PRINT(@OUTERMOSTSQL)
	END
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 3. RICERCA DEL DB Concessionary_AGS_RawData_01 NEL SERVER POM-MON01
-- (Valorizzazione del flga @DB01ExistsOnPOMMON)
----------------------------------------------------------------------------------------
SET @RawDataDBname = @ConcessionaryName + '_AGS_RawData'
SET @INNERSQLdbexists = [ETL].[BuildDynSQL_DBExists] (@RawDataDBname)
--SET @INNERSQLdbexists = N'
--SELECT	bitValue =
--		CASE
--			WHEN	EXISTS(
--						SELECT	TOP 1
--								name
--						FROM	sys.databases
--						WHERE	name = ''''' + @RawDataDBname + '''''
--					)
--			THEN	1
--			ELSE	0
--		END
--'
SET @OUTERSQLdbexists = REPLACE(@INNERSQLdbexists,'''''','''')
SELECT	@OUTERMOSTSQL = 
		CASE	
			WHEN	@@SERVERNAME LIKE '%DEV%' -- DETERMINA L'AMBIENTE SUL QUALE E' IN ESECUZIONE LA CORRENTE STORED PROCEDURE
			THEN	N'SELECT @returnValue = (SELECT bitValue FROM OPENQUERY([POM-MON01],'''+ REPLACE(@OUTERSQLdbexists,'''','''''') +'''))' -- QUERY PER ESECUZIONE IN AMBIENTE DI SVILUPPO  
			ELSE	N'SELECT @returnValue = (' + @OUTERSQLdbexists + ')' -- QUERY PER ESECUZIONE IN AMBIENTE DI PRODUZIONE
		END

EXEC	sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DB01ExistsOnPOMMON OUT

--PRINT(@OUTERMOSTSQL)
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 3.b SE ESISTE IL DB Concessionary_AGS_RawData_01 NEL SERVER POM-MON01, CERCA ANCHE LA TABELLA
-- (Valorizzazione del flga @DB01ExistsOnPOMMON)
----------------------------------------------------------------------------------------
IF @DB01ExistsOnPOMMON = 1
	BEGIN
		SET @RawDataDBname = @ConcessionaryName + '_AGS_RawData_01'
		SET @RawDataTable = 'RawData' -- su DB01 il nome di tabella NON è "RawData_View" bensì "RawData"
		SELECT @INNERSQLexistsTable = [ETL].[BuildDynSQL_TableExists] (@RawDataDBname, @RawDataTable, @ClubID)

		--SET @INNERSQLexistsTable = REPLACE
		--(
		--N'
		--SELECT	bitValue =
		--		CASE
		--			WHEN	EXISTS(
		--						SELECT	TOP 1 
		--								* 
		--						FROM	$.[sys].[tables] TBL WITH(NOLOCK)
		--								INNER JOIN 
		--								$.[sys].[partitions] PART WITH(NOLOCK) 
		--								ON TBL.object_id = PART.object_id
		--								INNER JOIN 
		--								$.[sys].[indexes] IDX WITH(NOLOCK) 
		--								ON PART.object_id = IDX.object_id
		--								INNER JOIN 
		--								$.[sys].[schemas] SCH WITH(NOLOCK) 
		--								ON TBL.schema_id = SCH.schema_id
		--						WHERE	TBL.name = ''''' + @RawDataTable + ''''' 
		--						AND		SCH.Name = ''''' + @ClubID + '''''
		--					)
		--			THEN	1
		--			ELSE	0
		--		END 			  
		--','$','[' + @RawDataDBname +']')

		SET @OUTERSQLexistsTable = REPLACE(@INNERSQLexistsTable,'''''','''')

		SELECT	@OUTERMOSTSQL = 
				CASE	
					WHEN	@@SERVERNAME LIKE '%DEV%' -- DETERMINA L'AMBIENTE SUL QUALE E' IN ESECUZIONE LA CORRENTE STORED PROCEDURE
					THEN	N'SELECT @returnValue = (SELECT bitValue FROM OPENQUERY([POM-MON01],'''+ REPLACE(@OUTERSQLexistsTable,'''','''''') +'''))' -- QUERY PER ESECUZIONE IN AMBIENTE DI SVILUPPO  
					ELSE	N'SELECT @returnValue = (' + @OUTERSQLexistsTable + ')' -- QUERY PER ESECUZIONE IN AMBIENTE DI PRODUZIONE
				END
		
		EXEC	sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DB01TableExistsOnPOMMON OUT
		
		--PRINT(@OUTERMOSTSQL)
	END
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 4. RICERCA DEL DB Concessionary_AGS_RawData NEL SERVER POM-MON01
-- (Valorizzazione del flga @DBstdExistsOnPOMMON)
----------------------------------------------------------------------------------------
SET @RawDataDBname = @ConcessionaryName + '_AGS_RawData'
SET @INNERSQLdbexists = [ETL].[BuildDynSQL_DBExists] (@RawDataDBname)
--SET @INNERSQLdbexists = N'
--SELECT	bitValue =
--		CASE
--			WHEN	EXISTS(
--						SELECT	TOP 1
--								name
--						FROM	sys.databases
--						WHERE	name = ''''' + @RawDataDBname + '''''
--					)
--			THEN	1
--			ELSE	0
--		END
--'
SET @OUTERSQLdbexists = REPLACE(@INNERSQLdbexists,'''''','''')
SELECT	@OUTERMOSTSQL = 
		CASE	
			WHEN	@@SERVERNAME LIKE '%DEV%' -- DETERMINA L'AMBIENTE SUL QUALE E' IN ESECUZIONE LA CORRENTE STORED PROCEDURE
			THEN	N'SELECT @returnValue = (SELECT bitValue FROM OPENQUERY([POM-MON01],'''+ REPLACE(@OUTERSQLdbexists,'''','''''') +'''))' -- QUERY PER ESECUZIONE IN AMBIENTE DI SVILUPPO  
			ELSE	N'SELECT @returnValue = (' + @OUTERSQLdbexists + ')' -- QUERY PER ESECUZIONE IN AMBIENTE DI PRODUZIONE
		END

EXEC	sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DBstdExistsOnPOMMON OUT

--PRINT(@OUTERMOSTSQL)
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 4.b SE ESISTE IL DB Concessionary_AGS_RawData NEL SERVER POM-MON01, CERCA ANCHE LA TABELLA
-- (Valorizzazione del flga @DBstdTableExistsOnPOMMON)
----------------------------------------------------------------------------------------
IF @DBstdExistsOnPOMMON = 1
	BEGIN
		SET @RawDataDBname = @ConcessionaryName + '_AGS_RawData'
		SET @RawDataTable = 'RawData'
		SELECT @INNERSQLexistsTable = [ETL].[BuildDynSQL_TableExists] (@RawDataDBname, @RawDataTable, @ClubID)

		--SET @INNERSQLexistsTable = REPLACE
		--(
		--N'
		--SELECT	bitValue =
		--		CASE
		--			WHEN	EXISTS(
		--						SELECT	TOP 1 
		--								* 
		--						FROM	$.[sys].[tables] TBL WITH(NOLOCK)
		--								INNER JOIN 
		--								$.[sys].[partitions] PART WITH(NOLOCK) 
		--								ON TBL.object_id = PART.object_id
		--								INNER JOIN 
		--								$.[sys].[indexes] IDX WITH(NOLOCK) 
		--								ON PART.object_id = IDX.object_id
		--								INNER JOIN 
		--								$.[sys].[schemas] SCH WITH(NOLOCK) 
		--								ON TBL.schema_id = SCH.schema_id
		--						WHERE	TBL.name = ''''' + @RawDataTable + ''''' 
		--						AND		SCH.Name = ''''' + @ClubID + '''''
		--					)
		--			THEN	1
		--			ELSE	0
		--		END 			  
		--','$','[' + @RawDataDBname +']')

		SET @OUTERSQLexistsTable = REPLACE(@INNERSQLexistsTable,'''''','''')

		SELECT	@OUTERMOSTSQL = 
				CASE	
					WHEN	@@SERVERNAME LIKE '%DEV%' -- DETERMINA L'AMBIENTE SUL QUALE E' IN ESECUZIONE LA CORRENTE STORED PROCEDURE
					THEN	N'SELECT @returnValue = (SELECT bitValue FROM OPENQUERY([POM-MON01],'''+ REPLACE(@OUTERSQLexistsTable,'''','''''') +'''))' -- QUERY PER ESECUZIONE IN AMBIENTE DI SVILUPPO  
					ELSE	N'SELECT @returnValue = (' + @OUTERSQLexistsTable + ')' -- QUERY PER ESECUZIONE IN AMBIENTE DI PRODUZIONE
				END

		EXEC	sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DBstdTableExistsOnPOMMON OUT

		--PRINT(@OUTERMOSTSQL)
	END


PRINT('@DB01ExistsOnPIN:' + CAST(@DB01ExistsOnPIN AS varchar(1)))
PRINT('@DB01TableExistsOnPIN:' + CAST(@DB01TableExistsOnPIN AS varchar(1)))
PRINT('@DBstdExistsOnPIN:' + CAST(@DBstdExistsOnPIN AS varchar(1)))
PRINT('@DBstdTableExistsOnPIN:' + CAST(@DBstdTableExistsOnPIN AS varchar(1)))
PRINT('@DB01ExistsOnPOMMON:' + CAST(@DB01ExistsOnPOMMON AS varchar(1)))
PRINT('@DB01TableExistsOnPOMMON:' + CAST(@DB01TableExistsOnPOMMON AS varchar(1)))
PRINT('@DBstdExistsOnPOMMON:' + CAST(@DBstdExistsOnPOMMON AS varchar(1)))
PRINT('@DBstdTableExistsOnPOMMON:' + CAST(@DBstdTableExistsOnPOMMON AS varchar(1)))
 
--------------------------------------------------------------------------------------------------------------
---- Creazione Vista                                                                                                 --
--------------------------------------------------------------------------------------------------------------
--IF @DB01ExistsOnPIN = 1

--	SET @CreateViewStr = '--Se ho anche o solo RawData_01
--			  CREATE view [TMP].[RawData_View]
--				AS
--				SELECT RowID, ServerTime, MachineTime, MachineID, GameID, LoginFlag, TotalBet, Win, GamesPlayed, GamesWon, TotalHandpay, TotalHPCC, TotalJPCC, TotalRemote, TotalWon, TotalDrop, TotalIn, TotalOut, TotalBillIn, TotalBillChange, TotalCoinIn, TotalCoinInDrop, TotalCoinInHopper, TotalHopperOut, TotalHopperFill, TotalTicketIn, TotalTicketOut, TotalBillInNumber, BillIn1, BillIn2, BillIn3, BillIn4, BillIn5, BillIn6, BillIn7, BillIn8, TotalBillChangeNumber, BillChange1, BillChange2, BillChange3, BillChange4, BillChange5, BillChange6, BillChange7, TotalCoinInNumber, CoinIn3, CoinIn4, CoinIn5, CoinIn6, CoinIn7, CoinIn8, TotalCoinInDropNumber, CoinInDrop3, CoinInDrop4, CoinInDrop5, CoinInDrop6, CoinInDrop7, CoinInDrop8, TotalCoinInHopperNumber, CoinInHopper3, CoinInHopper4, TicketInA, TicketInB, TicketInC, TicketOutA, TicketOutB, TicketOutC, CurrentCreditA, CurrentCreditB, CurrentCreditC, TotalBetA, TotalBetB, TotalBetC, WinA, WinB, WinC, WinD, TotalHPCCA
--					   FROM [' + @Position + '].[' + @RawDataDB_01 +'].[' + @ClubID + '].[RawData]
--					   WHERE ServerTime >= ''20120101'' AND ServerTime < ''20151117''
--				UNION ALL
--				SELECT (RowID + 2147483649), ServerTime, MachineTime, MachineID, GameID, LoginFlag, TotalBet, Win, GamesPlayed, GamesWon, TotalHandpay, TotalHPCC, TotalJPCC, TotalRemote, TotalWon, TotalDrop, TotalIn, TotalOut, TotalBillIn, TotalBillChange, TotalCoinIn, TotalCoinInDrop, TotalCoinInHopper, TotalHopperOut, TotalHopperFill, TotalTicketIn, TotalTicketOut, TotalBillInNumber, BillIn1, BillIn2, BillIn3, BillIn4, BillIn5, BillIn6, BillIn7, BillIn8, TotalBillChangeNumber, BillChange1, BillChange2, BillChange3, BillChange4, BillChange5, BillChange6, BillChange7, TotalCoinInNumber, CoinIn3, CoinIn4, CoinIn5, CoinIn6, CoinIn7, CoinIn8, TotalCoinInDropNumber, CoinInDrop3, CoinInDrop4, CoinInDrop5, CoinInDrop6, CoinInDrop7, CoinInDrop8, TotalCoinInHopperNumber, CoinInHopper3, CoinInHopper4, TicketInA, TicketInB, TicketInC, TicketOutA, TicketOutB, TicketOutC, CurrentCreditA, CurrentCreditB, CurrentCreditC, TotalBetA, TotalBetB, TotalBetC, WinA, WinB, WinC, WinD, TotalHPCCA
--						FROM [' + @Position + '].[' + @RawDataDB +'].[' + @ClubID + '].[RawData]
--						WHERE ServerTime >= ''20151117''
--						'
--ELSE			  
--	SET @CreateViewStr = '			
--			 -- Se ho solo RawData
--			  CREATE view [TMP].[RawData_View]
--					  AS
--					  SELECT RowID, ServerTime, MachineTime, MachineID, GameID, LoginFlag, TotalBet, Win, GamesPlayed, GamesWon, TotalHandpay, TotalHPCC, TotalJPCC, TotalRemote, TotalWon, TotalDrop, TotalIn, TotalOut, TotalBillIn, TotalBillChange, TotalCoinIn, TotalCoinInDrop, TotalCoinInHopper, TotalHopperOut, TotalHopperFill, TotalTicketIn, TotalTicketOut, TotalBillInNumber, BillIn1, BillIn2, BillIn3, BillIn4, BillIn5, BillIn6, BillIn7, BillIn8, TotalBillChangeNumber, BillChange1, BillChange2, BillChange3, BillChange4, BillChange5, BillChange6, BillChange7, TotalCoinInNumber, CoinIn3, CoinIn4, CoinIn5, CoinIn6, CoinIn7, CoinIn8, TotalCoinInDropNumber, CoinInDrop3, CoinInDrop4, CoinInDrop5, CoinInDrop6, CoinInDrop7, CoinInDrop8, TotalCoinInHopperNumber, CoinInHopper3, CoinInHopper4, TicketInA, TicketInB, TicketInC, TicketOutA, TicketOutB, TicketOutC, CurrentCreditA, CurrentCreditB, CurrentCreditC, TotalBetA, TotalBetB, TotalBetC, WinA, WinB, WinC, WinD, TotalHPCCA
--					  FROM [' + @Position + '].[' + @RawDataDB +'].[' + @ClubID + '].[RawData]
--					'
--EXEC sp_executesql @CreateViewStr
