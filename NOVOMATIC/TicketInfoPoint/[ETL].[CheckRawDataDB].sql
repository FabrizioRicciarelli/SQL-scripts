/*
DECLARE
		@tkStart XML -- ex [TMP].[TicketStart]
		,@XCONFIG XML -- ex [Config].[Table]
		,@TableInfo XML
SET		@XCONFIG = ETL.WriteXCONFIG(@XCONFIG, 1, 'POM-MON01', 25, 45, 7200, 50, 'GMatica', 1, 1) -- CARICA UN ELEMENTO NEL CONTENITORE @XCONFIG (ex [Config].[Table])

EXEC	[ETL].[CheckRawDataDB] 
		@XCONFIG
		,'1000002'
		,@TableInfo = @TableInfo OUTPUT
SELECT	@TableInfo AS '1000002' 

EXEC	[ETL].[CheckRawDataDB] 
		@XCONFIG
		,'1000004' -- TABELLA INESISTENTE
		,@TableInfo = @TableInfo OUTPUT
SELECT	@TableInfo AS '1000004' 

EXEC	[ETL].[CheckRawDataDB] 
		@XCONFIG
		,'1000009'
		,@TableInfo = @TableInfo OUTPUT
SELECT	@TableInfo AS '1000114' 

EXEC	[ETL].[CheckRawDataDB] 
		@XCONFIG
		,'1000294'
		,@TableInfo = @TableInfo OUTPUT
SELECT	@TableInfo AS '1000294' 

EXEC	[ETL].[CheckRawDataDB] 
		@XCONFIG
		,'1000296'
		,@TableInfo = @TableInfo OUTPUT
SELECT	@TableInfo AS '1000296' 
*/
ALTER PROC	[ETL].[CheckRawDataDB]
			@XCONFIG XML = NULL
			,@ClubID varchar(10) = NULL
			,@TableInfo XML OUTPUT
AS

SET NOCOUNT ON;

DECLARE
		-- Params 
		@ConcessionaryName sysname

		-- Dynamic SQL containers
		,@OUTERMOSTSQL Nvarchar(MAX) -- DA ESEGUIRE SU QUESTA MACCHINA
		,@OUTERSQLdbExists Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA POM-MON01
		,@OUTERSQLtableExists Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA POM-MON01
		,@OUTERSQLtableInfo Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA POM-MON01

		--,@ByteForm char(8) = NULL 
		
		-- Table info
		,@DB01TableInfoOnPIN varchar(MAX) = NULL 
		,@DBstdTableInfoOnPIN varchar(MAX) = NULL 
		,@DB01TableInfoOnPOMMON varchar(MAX) = NULL 
		,@DBstdTableInfoOnPOMMON varchar(MAX) = NULL 

		-- Flags
		,@DB01ExistsOnPIN bit = 0
		,@DBstdExistsOnPIN bit = 0
		,@DB01ExistsOnPOMMON bit = 0
		,@DBstdExistsOnPOMMON bit = 0

		,@TableExists bit = 0

SELECT	@ConcessionaryName = ConcessionaryName
FROM	ETL.GetXCONFIG(@XCONFIG,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI


----------------------------------------------------------------------------------------
-- 1. RICERCA DEL DB AGS_RawData_01 NELLE MACCHINE PIN
-- (Valorizzazione del flag @DB01ExistsOnPIN)
-- su DB01 il nome di tabella NON è "RawData_View" bensì "RawData"
----------------------------------------------------------------------------------------
SET @OUTERSQLdbExists = N'SELECT bitValue FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + [ETL].[BuildDynSQL_DBExists] ('AGS_RawData_01') + ''')'
SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLdbExists)
EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DB01ExistsOnPIN OUT

--SE ESISTE IL DB AGS_RawData_01 NELLE MACCHINE PIN, CERCA ANCHE LA TABELLA
IF @DB01ExistsOnPIN = 1
	BEGIN
		SET @OUTERSQLtableExists = N'SELECT TableExists FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + [ETL].[BuildDynSQL_TableOrViewExists] ('AGS_RawData_01', 'RawData', @ClubID) + ''')'
		SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLtableExists)
		EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@TableExists OUT
		
		-- SE ESISTE ANCHE LA TABELLA NE ESTRAE IL NUMERO DI RIGHE E LE DATE MINIMA E MASSIMA
		IF @tableExists = 1
			BEGIN
				SET @OUTERSQLtableInfo = N'SELECT TableInfo FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + [ETL].[BuildDynSQL_TableInfo] ('AGS_RawData_01', 'RawData', @ClubID) + ''')'
				SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLtableInfo)
				EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue varchar(MAX) OUT', @returnValue=@DB01TableInfoOnPIN OUT

				-- SE NON VENGONO RITORNATE INFORMAZIONI SULLA TABELLA, TENTA CON UN OGGETTO "VIEW" AVENTE LO STESSO NOME DI PARTENZA
				IF @DB01TableInfoOnPIN IS NULL
					BEGIN
						SET @OUTERSQLtableInfo = N'SELECT ViewInfo FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + [ETL].[BuildDynSQL_ViewInfo] ('AGS_RawData_01', 'RawData', @ClubID) + ''')'
						SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLtableInfo)
						EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue varchar(MAX) OUT', @returnValue=@DB01TableInfoOnPIN OUT
					END
			END
	END
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 2. RICERCA DEL DB AGS_RawData NELLE MACCHINE PIN
-- (Valorizzazione del flga @DBstdExistsOnPIN)
----------------------------------------------------------------------------------------
SET @OUTERSQLdbExists = N'SELECT bitValue FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + [ETL].[BuildDynSQL_DBExists] ('AGS_RawData') + ''')'
SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLdbExists)
EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DBstdExistsOnPIN OUT

--SE ESISTE IL DB AGS_RawData NELLE MACCHINE PIN, CERCA ANCHE LA TABELLA
IF @DBstdExistsOnPIN = 1
	BEGIN
		SET @OUTERSQLtableExists = N'SELECT TableExists FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + [ETL].[BuildDynSQL_TableOrViewExists] ('AGS_RawData', 'RawData_View', @ClubID) + ''')'
		SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLtableExists)
		EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@TableExists OUT
		
		-- SE ESISTE ANCHE LA TABELLA NE ESTRAE IL NUMERO DI RIGHE E LE DATE MINIMA E MASSIMA
		IF @tableExists = 1
			BEGIN
				SET @OUTERSQLtableInfo = N'SELECT TableInfo FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + [ETL].[BuildDynSQL_TableInfo] ('AGS_RawData', 'RawData_View', @ClubID) + ''')'
				SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLtableInfo)
				EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue varchar(MAX) OUT', @returnValue=@DBstdTableInfoOnPIN OUT

				-- SE NON VENGONO RITORNATE INFORMAZIONI SULLA TABELLA, TENTA CON UN OGGETTO "VIEW" AVENTE LO STESSO NOME DI PARTENZA
				IF @DBstdTableInfoOnPIN IS NULL
					BEGIN
						SET @OUTERSQLtableInfo = N'SELECT ViewInfo FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + [ETL].[BuildDynSQL_ViewInfo] ('AGS_RawData_01', 'RawData', @ClubID) + ''')'
						SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLtableInfo)
						EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue varchar(MAX) OUT', @returnValue=@DBstdTableInfoOnPIN OUT
					END
			END
	END
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 3. RICERCA DEL DB Concessionary_AGS_RawData_01 NEL SERVER POM-MON01
-- (Valorizzazione del flga @DB01ExistsOnPOMMON)
-- su DB01 il nome di tabella NON è "RawData_View" bensì "RawData"
----------------------------------------------------------------------------------------
SET @OUTERSQLdbExists = REPLACE([ETL].[BuildDynSQL_DBExists] (@ConcessionaryName + '_AGS_RawData_01'),'''''','''')
SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLdbExists)
EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DB01ExistsOnPOMMON OUT

-- SE ESISTE IL DB Concessionary_AGS_RawData_01	NELLA MACCHINE POMMON, CERCA ANCHE LA TABELLA
IF @DB01ExistsOnPOMMON = 1
	BEGIN
		SET @OUTERSQLtableExists = REPLACE([ETL].[BuildDynSQL_TableOrViewExists] ( @ConcessionaryName + '_AGS_RawData_01', 'RawData', @ClubID),'''''','''')
		SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLtableExists)
		EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@TableExists OUT
		
		-- SE ESISTE ANCHE LA TABELLA NE ESTRAE IL NUMERO DI RIGHE E LE DATE MINIMA E MASSIMA
		IF @tableExists = 1
			BEGIN
				SET @OUTERSQLtableInfo = REPLACE([ETL].[BuildDynSQL_TableInfo] ( @ConcessionaryName + '_AGS_RawData_01', 'RawData', @ClubID),'''''','''')
				SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLtableInfo)
				EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue varchar(MAX) OUT', @returnValue=@DB01TableInfoOnPOMMON OUT

				-- SE NON VENGONO RITORNATE INFORMAZIONI SULLA TABELLA, TENTA CON UN OGGETTO "VIEW" AVENTE LO STESSO NOME DI PARTENZA
				IF @DB01TableInfoOnPOMMON IS NULL
					BEGIN
						SET @OUTERSQLtableInfo = REPLACE([ETL].[BuildDynSQL_ViewInfo] ( @ConcessionaryName + '_AGS_RawData_01', 'RawData', @ClubID),'''''','''')
						SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLtableInfo)
						EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue varchar(MAX) OUT', @returnValue=@DB01TableInfoOnPOMMON OUT
					END
			END
	END
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 4. RICERCA DEL DB Concessionary_AGS_RawData NEL SERVER POM-MON01
-- (Valorizzazione del flga @DBstdExistsOnPOMMON)
----------------------------------------------------------------------------------------
SET @OUTERSQLdbExists = REPLACE([ETL].[BuildDynSQL_DBExists] (@ConcessionaryName + '_AGS_RawData'),'''''','''')
SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLdbExists)
EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DBstdExistsOnPOMMON OUT

-- SE ESISTE IL DB Concessionary_AGS_RawData	NELLA MACCHINE POMMON, CERCA ANCHE LA TABELLA
IF @DBstdExistsOnPOMMON = 1
	BEGIN
		SET @OUTERSQLtableExists = REPLACE([ETL].[BuildDynSQL_TableOrViewExists] (@ConcessionaryName + '_AGS_RawData', 'RawData_View', @ClubID),'''''','''')
		SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLtableExists)
		EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue varchar(MAX) OUT', @returnValue=@TableExists OUT

		-- SE ESISTE ANCHE LA TABELLA NE ESTRAE IL NUMERO DI RIGHE E LE DATE MINIMA E MASSIMA
		IF @tableExists = 1
			BEGIN
				SET @OUTERSQLtableInfo = REPLACE([ETL].[BuildDynSQL_TableInfo] ( @ConcessionaryName + '_AGS_RawData', 'RawData_View', @ClubID),'''''','''')
				SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLtableInfo)
				EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue varchar(MAX) OUT', @returnValue=@DBStdTableInfoOnPOMMON OUT

				-- SE NON VENGONO RITORNATE INFORMAZIONI SULLA TABELLA, TENTA CON UN OGGETTO "VIEW" AVENTE LO STESSO NOME DI PARTENZA
				IF @DBStdTableInfoOnPOMMON IS NULL
					BEGIN
						SET @OUTERSQLtableInfo = REPLACE([ETL].[BuildDynSQL_ViewInfo] ( @ConcessionaryName + '_AGS_RawData_01', 'RawData', @ClubID),'''''','''')
						SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLtableInfo)
						EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue varchar(MAX) OUT', @returnValue=@DBStdTableInfoOnPOMMON OUT
					END
			END
	END
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 5. COMPOSIZIONE DELL'XML RAPPRESENTANTE I RISULTATI DELLE RICERCHE
----------------------------------------------------------------------------------------
SET @TableInfo = 
(
	SELECT	
			I.Server
			,I.Db
			,Info = CASE WHEN I.IDX = 1 THEN 'MinDate' WHEN I.IDX = 2 THEN 'MaxDate' WHEN I.IDX = 3 THEN 'RowsCount' END
			,I.Value
	FROM
	(
		SELECT 'PIN' AS Server, 'RawData_01' AS Db, VALUE, ROW_NUMBER() OVER(ORDER BY VALUE) AS IDX FROM STRING_SPLIT(@DB01TableInfoOnPIN, CHAR(44)) UNION ALL
		SELECT 'PIN' AS Server, 'RawData' AS Db, VALUE, ROW_NUMBER() OVER(ORDER BY VALUE) FROM STRING_SPLIT(@DBstdTableInfoOnPIN, CHAR(44)) UNION ALL
		SELECT 'POM-MON01' AS Server, 'RawData_01' AS Db, VALUE, ROW_NUMBER() OVER(ORDER BY VALUE) FROM STRING_SPLIT(@DB01TableInfoOnPOMMON, CHAR(44)) UNION ALL
		SELECT 'POM-MON01' AS Server, 'RawData' AS Db, VALUE, ROW_NUMBER() OVER(ORDER BY VALUE) FROM STRING_SPLIT(@DBstdTableInfoOnPOMMON, CHAR(44)) 
	) I
	FOR XML RAW('TableInfo'), TYPE
)
----------------------------------------------------------------------------------------
