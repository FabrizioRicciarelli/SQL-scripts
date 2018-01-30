/*
DECLARE
		@tkStart XML -- ex [TMP].[TicketStart]
		,@XCONFIG XML -- ex [Config].[Table]
		,@ByteForm char(8)
		,@ServerPINMinDate datetime
		,@ServerPINMaxDate datetime 
		,@ServerPOMMONMinDate datetime
		,@ServerPOMMONMaxDate datetime 

SET		@XCONFIG = ETL.WriteXCONFIG(@XCONFIG, 1, 'POM-MON01', 25, 45, 7200, 50, 'GMatica', 1, 1) -- CARICA UN ELEMENTO NEL CONTENITORE @XCONFIG (ex [Config].[Table])

EXEC	[ETL].[CheckRawDataDB] 
		@XCONFIG
		,'1000002'
		,@ByteForm = @ByteForm OUTPUT
		,@ServerPINMinDate = @ServerPINMinDate OUTPUT
		,@ServerPINMaxDate = @ServerPINMaxDate OUTPUT 
		,@ServerPOMMONMinDate = @ServerPOMMONMinDate OUTPUT 
		,@ServerPOMMONMaxDate = @ServerPOMMONMaxDate OUTPUT 
SELECT	@ByteForm AS ByteForm

EXEC	[ETL].[CheckRawDataDB] 
		@XCONFIG
		,'1000296'
		,@ByteForm = @ByteForm OUTPUT
		,@ServerPINMinDate = @ServerPINMinDate OUTPUT
		,@ServerPINMaxDate = @ServerPINMaxDate OUTPUT 
		,@ServerPOMMONMinDate = @ServerPOMMONMinDate OUTPUT 
		,@ServerPOMMONMaxDate = @ServerPOMMONMaxDate OUTPUT 
SELECT	@ByteForm AS ByteForm
*/
ALTER PROC		[ETL].[CheckRawDataDB]
				@XCONFIG XML = NULL
				,@ClubID varchar(10) = NULL
				,@ByteForm char(8) = NULL OUTPUT
				,@ServerPINMinDate datetime = NULL OUTPUT
				,@ServerPINMaxDate datetime = NULL OUTPUT 
				,@ServerPOMMONMinDate datetime = NULL OUTPUT
				,@ServerPOMMONMaxDate datetime = NULL OUTPUT 
AS

SET NOCOUNT ON;

DECLARE
		-- Params 
		@ConcessionaryName sysname

		-- Dynamic SQL containers
		,@OUTERMOSTSQL Nvarchar(MAX) -- DA ESEGUIRE SU QUESTA MACCHINA
		,@OUTERSQLdbExists Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA POM-MON01
		,@OUTERSQLtableExists Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA POM-MON01

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


SELECT	@ConcessionaryName = ConcessionaryName
FROM	ETL.GetXCONFIG(@XCONFIG,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI


----------------------------------------------------------------------------------------
-- 1. RICERCA DEL DB AGS_RawData_01 NELLE MACCHINE PIN
-- (Valorizzazione del flag @DB01ExistsOnPIN)
----------------------------------------------------------------------------------------
SET @OUTERSQLdbExists = N'SELECT bitValue FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + [ETL].[BuildDynSQL_DBExists] ('AGS_RawData_01') + ''')'
SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLdbExists)
EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DB01ExistsOnPIN OUT
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 1.b SE ESISTE IL DB AGS_RawData_01 NELLE MACCHINE PIN, CERCA ANCHE LA TABELLA
-- (Valorizzazione del flga @DB01TableExistsOnPIN)
----------------------------------------------------------------------------------------
IF @DB01ExistsOnPIN = 1
	BEGIN
		SET @OUTERSQLtableExists = N'SELECT bitValue FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + [ETL].[BuildDynSQL_TableExists] ('AGS_RawData_01', 'RawData', @ClubID) + ''')'
		SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLtableExists)
		EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DB01TableExistsOnPIN OUT
	END
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 2. RICERCA DEL DB AGS_RawData NELLE MACCHINE PIN
-- (Valorizzazione del flga @DBstdExistsOnPIN)
----------------------------------------------------------------------------------------
SET @OUTERSQLdbExists = N'SELECT bitValue FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + [ETL].[BuildDynSQL_DBExists] ('AGS_RawData') + ''')'
SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLdbExists)
EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DBstdExistsOnPIN OUT
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 2.b SE ESISTE IL DB AGS_RawData NELLE MACCHINE PIN, CERCA ANCHE LA TABELLA
-- (Valorizzazione del flga @DBstdTableExistsOnPIN)
----------------------------------------------------------------------------------------
IF @DBstdExistsOnPIN = 1
	BEGIN
		SET @OUTERSQLtableExists = N'SELECT bitValue FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + [ETL].[BuildDynSQL_TableExists] ('AGS_RawData', 'RawData', @ClubID) + ''')'
		SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLtableExists)
		EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DBstdTableExistsOnPIN OUT
	END
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 3. RICERCA DEL DB Concessionary_AGS_RawData_01 NEL SERVER POM-MON01
-- (Valorizzazione del flga @DB01ExistsOnPOMMON)
----------------------------------------------------------------------------------------
SET @OUTERSQLdbExists = REPLACE([ETL].[BuildDynSQL_DBExists] (@ConcessionaryName + '_AGS_RawData'),'''''','''')
SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLdbExists)
EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DB01ExistsOnPOMMON OUT
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 3.b SE ESISTE IL DB Concessionary_AGS_RawData_01 NEL SERVER POM-MON01, CERCA ANCHE LA TABELLA
-- (Valorizzazione del flga @DB01ExistsOnPOMMON)
----------------------------------------------------------------------------------------
IF @DB01ExistsOnPOMMON = 1
	BEGIN
		SET @OUTERSQLtableExists = REPLACE([ETL].[BuildDynSQL_TableExists] ( @ConcessionaryName + '_AGS_RawData_01', 'RawData', @ClubID),'''''','''')
		SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLtableExists)
		EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DB01TableExistsOnPOMMON OUT
	END
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 4. RICERCA DEL DB Concessionary_AGS_RawData NEL SERVER POM-MON01
-- (Valorizzazione del flga @DBstdExistsOnPOMMON)
----------------------------------------------------------------------------------------
SET @OUTERSQLdbExists = REPLACE([ETL].[BuildDynSQL_DBExists] (@ConcessionaryName + '_AGS_RawData'),'''''','''')
SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLdbExists)
EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DBstdExistsOnPOMMON OUT
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 4.b SE ESISTE IL DB Concessionary_AGS_RawData NEL SERVER POM-MON01, CERCA ANCHE LA TABELLA
-- (Valorizzazione del flga @DBstdTableExistsOnPOMMON)
----------------------------------------------------------------------------------------
IF @DBstdExistsOnPOMMON = 1
	BEGIN
		SET @OUTERSQLtableExists = REPLACE([ETL].[BuildDynSQL_TableExists] (@ConcessionaryName + '_AGS_RawData', 'RawData', @ClubID),'''''','''')
		SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLtableExists)
		EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DBstdTableExistsOnPOMMON OUT
	END
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 5. COMPOSIZIONE DELLA SEQUENZA DI 8 BIT RAPPRESENTANTI I RISULTATI DELLE RICERCHE
----------------------------------------------------------------------------------------
SET	@ByteForm = 
	CAST(@DB01ExistsOnPIN AS varchar(1)) +
	CAST(@DB01TableExistsOnPIN AS varchar(1)) +
	CAST(@DBstdExistsOnPIN AS varchar(1)) +
	CAST(@DBstdTableExistsOnPIN AS varchar(1)) +
	CAST(@DB01ExistsOnPOMMON AS varchar(1)) +
	CAST(@DB01TableExistsOnPOMMON AS varchar(1)) + 
	CAST(@DBstdExistsOnPOMMON AS varchar(1)) + 
	CAST(@DBstdTableExistsOnPOMMON AS varchar(1))
----------------------------------------------------------------------------------------
