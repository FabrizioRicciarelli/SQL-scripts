/*
DECLARE
		@tkStart XML -- ex [TMP].[TicketStart]
		,@XCONFIG XML -- ex [Config].[Table]
		,@DataInfo XML = NULL
SET		@XCONFIG = ETL.WriteXCONFIG(@XCONFIG, 1, 'POM-MON01', 25, 45, 7200, 50, 'GMatica', 1, 1) -- CARICA UN ELEMENTO NEL CONTENITORE @XCONFIG (ex [Config].[Table])

EXEC	[ETL].[CheckRawDataDB] 
		@XCONFIG = @XCONFIG
		,@CurrentDataInfo = @DataInfo
		,@ClubID = '1000002'
		,@DataInfo = @DataInfo OUTPUT
--SELECT	@DataInfo AS '1000002' 

EXEC	[ETL].[CheckRawDataDB] 
		@XCONFIG = @XCONFIG
		,@CurrentDataInfo = @DataInfo
		,@ClubID = '1000004' -- TABELLA INESISTENTE
		,@DataInfo = @DataInfo OUTPUT
--SELECT	@DataInfo AS '1000004' 

EXEC	[ETL].[CheckRawDataDB] 
		@XCONFIG = @XCONFIG
		,@CurrentDataInfo = @DataInfo
		,@ClubID = '1000009'
		,@DataInfo = @DataInfo OUTPUT
--SELECT	@DataInfo AS '1000114' 

EXEC	[ETL].[CheckRawDataDB] 
		@XCONFIG = @XCONFIG
		,@CurrentDataInfo = @DataInfo
		,@ClubID = '1000294'
		,@DataInfo = @DataInfo OUTPUT
--SELECT	@DataInfo AS '1000294' 

EXEC	[ETL].[CheckRawDataDB] 
		@XCONFIG = @XCONFIG
		,@CurrentDataInfo = @DataInfo
		,@ClubID = '1000296'
		,@DataInfo = @DataInfo OUTPUT
SELECT	@DataInfo AS '1000002_1000296' 
*/
ALTER PROC	[ETL].[CheckRawDataDB]
			@XCONFIG XML = NULL
			,@CurrentDataInfo XML = NULL
			,@ClubID varchar(10) = NULL
			,@DataInfo XML OUTPUT
AS

SET NOCOUNT ON;

DECLARE
		-- Params 
		@ConcessionaryName sysname

		-- Dynamic SQL containers
		,@OUTERMOSTSQL Nvarchar(MAX) -- DA ESEGUIRE SU QUESTA MACCHINA
		,@OUTERSQLDbExists Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA POM-MON01
		,@OUTERSQLDataExists Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA POM-MON01
		,@OUTERSQLDataInfo Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA POM-MON01

		,@ServerName sysname 
		,@CurrentDBName sysname 
		
		-- Table info
		,@DB01InfoOnPIN varchar(MAX) = NULL 
		,@DBSTDInfoOnPIN varchar(MAX) = NULL 
		,@DB01InfoOnPOMMON varchar(MAX) = NULL 
		,@DBstdTableInfoOnPOMMON varchar(MAX) = NULL 

		-- Flags
		,@DB01ExistsOnPIN bit = 0
		,@DBstdExistsOnPIN bit = 0
		,@DB01ExistsOnPOMMON bit = 0
		,@DBstdExistsOnPOMMON bit = 0

		,@TableExists bit = 0
		,@ViewExists bit = 0

		,@stringTableInfo varchar(MAX) = ''
		,@stringViewInfo  varchar(MAX) = ''

		,@xmlViewInfo XML


----------------------------------------------------------------------------------------
-- 1. INIZIALIZZAZIONE
----------------------------------------------------------------------------------------
SELECT	@ConcessionaryName = ISNULL(ConcessionaryName,'')
FROM	ETL.GetXCONFIG(@XCONFIG,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI


----------------------------------------------------------------------------------------
-- 2. RICERCA DEL DB AGS_RawData NELLE MACCHINE PIN
-- (Valorizzazione del flga @DBstdExistsOnPIN)
----------------------------------------------------------------------------------------
SET @stringViewInfo = ''
SET @ServerName = @ConcessionaryName + N'_PIN01\DW'
SET @CurrentDBName = 'AGS_RawData'
SET @OUTERSQLDbExists = N'SELECT DbExists FROM OPENQUERY([' + @ServerName + '],''' + [ETL].[BuildDynSQL_DBExists] ('AGS_RawData') + ''')'
SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLDbExists)
EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DBstdExistsOnPIN OUT
PRINT('@DBstdExistsOnPIN: ' + CAST(@DBstdExistsOnPIN AS VARCHAR(1)))

IF @DBstdExistsOnPIN = 1
	--SE ESISTE IL DB AGS_RawData NELLE MACCHINE PIN, CERCA ANCHE LA TABELLA
	BEGIN
		SET @OUTERSQLDataExists = N'SELECT TableExists FROM OPENQUERY([' + @ServerName + '],''' + [ETL].[BuildDynSQL_TableExists] ('AGS_RawData', 'RawData', @ClubID) + ''')'
		SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLDataExists)
		
		EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@TableExists OUT
		
		IF @tableExists = 1
			-- SE ESISTE ANCHE LA TABELLA NE ESTRAE IL NUMERO DI RIGHE E LE DATE MINIMA E MASSIMA
			BEGIN
				SET @OUTERSQLDataInfo = N'SELECT ObjectInfo FROM OPENQUERY([' + @ServerName + '],''' + [ETL].[BuildDynSQL_TableInfo] ('AGS_RawData', 'RawData', @ClubID) + ''')'
				SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLDataInfo)
				
				EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue varchar(MAX) OUT', @returnValue=@DBSTDInfoOnPIN OUT
				
				SET @DBSTDInfoOnPIN = REPLACE(@DBSTDInfoOnPIN, 'Name="', 'Name="[' + @ServerName + '].')
				SET @stringTableInfo += @DBSTDInfoOnPIN
			END

		-- VERIFICA ALTRESI' SE C'E' ANCHE LA VISTA SUL SERVER PIN01...
		SET @OUTERSQLDataExists = N'SELECT ViewExists FROM OPENQUERY([' + @ServerName + '],''' + [ETL].[BuildDynSQL_ViewExists] ('AGS_RawData', 'RawData_View', @ClubID) + ''')'
		SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLDataExists)
		EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@ViewExists OUT
		
		IF @ViewExists = 1
			-- ...SE ESISTE, NE ESTRAE IL NUMERO DI RIGHE E LE DATE MINIMA E MASSIMA
			BEGIN
				EXEC	[ETL].[CountRawDataViewRows]
						@RawDataDBname = @CurrentDBName
						,@ConcessionaryName = @ConcessionaryName -- VALORIZZANDO QUESTO PARAMETRO SI INDICA ALLA SP CHE L'ESTRAZIONE VA EFFETTUATA SULLA MACCHINA PIN
						,@ClubID = @ClubID
						,@ViewInfo = @xmlViewInfo OUTPUT

				SET @stringViewInfo += CAST(@xmlViewInfo AS varchar(MAX))
			END
	END
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 3. RICERCA DEL DB Concessionary_AGS_RawData_01 NEL SERVER POM-MON01
-- (Valorizzazione del flga @DB01ExistsOnPOMMON)
-- su DB01 il nome di tabella NON è "RawData_View" bensì "RawData"
----------------------------------------------------------------------------------------
SET @ServerName = N'POM-MON01'
SET @CurrentDBName = @ConcessionaryName + '_AGS_RawData'
SET @OUTERSQLDbExists = REPLACE([ETL].[BuildDynSQL_DBExists] (@ConcessionaryName + '_AGS_RawData_01'),'''''','''')
SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLDbExists)
EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DB01ExistsOnPOMMON OUT

IF @DB01ExistsOnPOMMON = 1
	-- SE ESISTE IL DB Concessionary_AGS_RawData_01	NELLA MACCHINE POMMON, CERCA ANCHE LA TABELLA
	BEGIN
		SET @OUTERSQLDataExists = REPLACE([ETL].[BuildDynSQL_TableExists] ( @ConcessionaryName + '_AGS_RawData_01', 'RawData', @ClubID),'''''','''')
		SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLDataExists)
		
		EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@TableExists OUT
		
		IF @tableExists = 1
			-- SE ESISTE ANCHE LA TABELLA NE ESTRAE IL NUMERO DI RIGHE E LE DATE MINIMA E MASSIMA
			BEGIN
				SET @OUTERSQLDataInfo = REPLACE([ETL].[BuildDynSQL_TableInfo] ( @ConcessionaryName + '_AGS_RawData_01', 'RawData', @ClubID),'''''','''')
				SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLDataInfo)
				
				EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue varchar(MAX) OUT', @returnValue=@DB01InfoOnPOMMON OUT
				
				SET @DB01InfoOnPOMMON = REPLACE(@DB01InfoOnPOMMON, 'Name="', 'Name="[' + @ServerName + '].')
				SET @stringTableInfo += @DB01InfoOnPOMMON
			END

		-- VERIFICA ALTRESI' SE C'E' ANCHE LA VISTA SUL SERVER POM-MON01...
		SET @OUTERSQLDataExists = REPLACE([ETL].[BuildDynSQL_ViewExists] ( @ConcessionaryName + '_AGS_RawData', 'RawData_View', @ClubID),'''''','''')
		SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLDataExists)
		EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@ViewExists OUT
		
		IF @ViewExists = 1
			-- ...SE ESISTE, NE ESTRAE IL NUMERO DI RIGHE E LE DATE MINIMA E MASSIMA
			BEGIN
				EXEC	[ETL].[CountRawDataViewRows]
						@RawDataDBname = @CurrentDBName
						,@ConcessionaryName = NULL -- VALORIZZANDO QUESTO PARAMETRO SI INDICA ALLA SP CHE L'ESTRAZIONE VA EFFETTUATA SULLA MACCHINA PIN
						,@ClubID = @ClubID
						,@ViewInfo = @xmlViewInfo OUTPUT

				SET @stringViewInfo += CAST(@xmlViewInfo AS varchar(MAX))
			END
	END
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 4. RICERCA DEL DB Concessionary_AGS_RawData NEL SERVER POM-MON01
-- (Valorizzazione del flga @DBstdExistsOnPOMMON)
----------------------------------------------------------------------------------------
SET @ServerName = N'POM-MON01'
SET @CurrentDBName = @ConcessionaryName + '_AGS_RawData'
SET @OUTERSQLDbExists = REPLACE([ETL].[BuildDynSQL_DBExists] (@ConcessionaryName + '_AGS_RawData'),'''''','''')
SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLDbExists)
EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue bit OUT', @returnValue=@DBstdExistsOnPOMMON OUT

IF @DBstdExistsOnPOMMON = 1
	-- SE ESISTE IL DB Concessionary_AGS_RawData	NELLA MACCHINE POMMON, CERCA ANCHE LA TABELLA
	BEGIN
		SET @OUTERSQLDataExists = REPLACE([ETL].[BuildDynSQL_TableExists] (@ConcessionaryName + '_AGS_RawData', 'RawData', @ClubID),'''''','''')
		SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLDataExists)
		
		EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue varchar(MAX) OUT', @returnValue=@TableExists OUT

		-- SE ESISTE ANCHE LA TABELLA NE ESTRAE IL NUMERO DI RIGHE E LE DATE MINIMA E MASSIMA
		IF @tableExists = 1
			BEGIN
				SET @OUTERSQLDataInfo = REPLACE([ETL].[BuildDynSQL_TableInfo] ( @ConcessionaryName + '_AGS_RawData', 'RawData', @ClubID),'''''','''')
				SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQLDataInfo)
				
				EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue varchar(MAX) OUT', @returnValue=@DBStdTableInfoOnPOMMON OUT

				SET @DBStdTableInfoOnPOMMON = REPLACE(@DBStdTableInfoOnPOMMON, 'Name="', 'Name="[' + @ServerName + '].')
				SET @stringTableInfo += @DBStdTableInfoOnPOMMON
			END
	END
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
-- 5. COMPOSIZIONE DELL'XML RAPPRESENTANTE I RISULTATI DELLE RICERCHE
----------------------------------------------------------------------------------------
SET @DataInfo = CAST(
					IIF(
						CAST(ISNULL(@CurrentDataInfo,'') AS varchar(MAX)) != ''
						,CAST(@CurrentDataInfo AS varchar(MAX))
						,''
					) + @stringTableInfo + @stringViewInfo 
					AS XML
				)
----------------------------------------------------------------------------------------
