/*
-- ESTRAZIONE DEI NOMI DELLE TABELLE REFERENZIATE
-- ALL'INTERNO DI UNA VISTA E, PER CIASCUNA DI QUESTE 
-- ESTRAZIONE DEL NUMERO DI RIGHE DI CUI SONO COMPOSTE
-- TRAMITE METODO FASTCOUNT, OLTRE ALLA DATA MINIMA E
-- MASSIMA DI CIASCUNA

-- SENZA DETTAGLIO DELLE TABELLE COMPONENTI LA VISTA - SU MACCHINA PIN
DECLARE	
		@ViewInfo XML
		,@DebugInfo	varchar(MAX)

EXEC	[ETL].[CountRawDataViewRows]
		@RawDataDBname = 'AGS_RawData'
		,@ConcessionaryName = 'GMATICA'
		,@RawDataViewName = NULL -- IL DEFAULT, SE IL PARAMETRO E' PASSATO COME NULL, E' "RawData_View"
		,@ClubID = '1000296'
		,@ViewInfo = @ViewInfo OUTPUT

SELECT	@ViewInfo AS ViewInfo

-- SENZA DETTAGLIO DELLE TABELLE COMPONENTI LA VISTA - SU POM-MON01
DECLARE	
		@ViewInfo XML
		,@DebugInfo	varchar(MAX)

EXEC	[ETL].[CountRawDataViewRows]
		@RawDataDBname = 'GMATICA_AGS_RawData'
		,@RawDataViewName = NULL -- IL DEFAULT, SE IL PARAMETRO E' PASSATO COME NULL, E' "RawData_View"
		,@ClubID = '1000296'
		,@ViewInfo = @ViewInfo OUTPUT

SELECT	@ViewInfo AS ViewInfo

-- CON DETTAGLIO DELLE TABELLE COMPONENTI LA VISTA
DECLARE	
		@ViewInfo XML
		,@DebugInfo	varchar(MAX)

EXEC	[ETL].[CountRawDataViewRows]
		@RawDataDBname = 'GMATICA_AGS_RawData'
		,@RawDataViewName = NULL -- IL DEFAULT, SE IL PARAMETRO E' PASSATO COME NULL, E' "RawData_View"
		,@ClubID = '1000296'
		,@ShowDependentTablesInfo = 1
		,@ViewInfo = @ViewInfo OUTPUT

SELECT	@ViewInfo AS ViewInfo
*/
ALTER PROC	[ETL].[CountRawDataViewRows]
			@RawDataDBname sysname = NULL
			,@RawDataViewName sysname = NULL
			,@ConcessionaryName sysname = NULL
			,@ClubID varchar(10) = NULL
			,@ShowDependentTablesInfo bit = NULL
			,@ViewInfo XML OUTPUT
AS
SET NOCOUNT ON;

DECLARE 
		@INNERSQL Nvarchar(MAX)
		,@OUTERSQL Nvarchar(MAX)
		,@OUTERMOSTSQL  Nvarchar(MAX)
		,@OUTERSQLDataExists Nvarchar(MAX) -- DA ESEGUIRE SULLA MACCHINA POM-MON01
		,@varcharTABLES varchar(MAX)
		,@xmlTABLES XML
		,@currentDataBaseName varchar(MAX) = NULL
		,@currentSchemaName varchar(MAX) = NULL
		,@currentTableName varchar(MAX) = NULL
		,@currentMinDate datetime = NULL
		,@currentMaxDate datetime = NULL
		,@ROWSCOUNT bigint
		,@nodeCount int
		,@i int
		,@stringtTableInfo varchar(MAX)
		,@xmlTableInfo XML
		,@currentRowsCount bigint
		,@ServerName sysname

SET @ServerName = IIF(@ConcessionaryName IS NOT NULL, @ConcessionaryName + N'_PIN01\DW', 'POM-MON01')
SET @RawDataViewName = ISNULL(@RawDataViewName,'RawData_View')
SET @ShowDependentTablesInfo = ISNULL(@ShowDependentTablesInfo, 0)

IF @ClubID IS NOT NULL
	BEGIN

		DECLARE @tmpViewInfo TABLE(
				ViewName sysname NULL
				,ViewRowsCount bigint NULL
				,ViewMinDate datetime NULL
				,ViewMaxDate datetime NULL
				,TableName sysname NULL
				,TableRowsCount bigint NULL
				,TableMinDate datetime NULL
				,TableMaxDate datetime NULL
		)
		
		SET @ROWSCOUNT = 0

		------------------------------------------------------------------------------
		-- 1. ESTRAZIONE DEI NOMI DELLE TABELLE REFERENZIATE ALL'INTERNO DI UNA VISTA
		------------------------------------------------------------------------------
		SET @INNERSQL = [ETL].[BuildDynSQL_ViewTables] (@RawDataDBname, @ClubID)
		--SET @OUTERSQL = IIF(@ConcessionaryName IS NOT NULL, N'SELECT * FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + @INNERSQL + ''')', REPLACE(@INNERSQL,'''''',''''))
		SET @OUTERSQL = IIF(@ConcessionaryName IS NOT NULL, N'SELECT * FROM OPENQUERY([' + @ServerName + '],''' + @INNERSQL + ''')', REPLACE(@INNERSQL,'''''',''''))
		SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQL)
		EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue varchar(MAX) OUT', @returnValue=@varcharTABLES OUT
		SET @xmlTABLES = CAST(ISNULL(@varcharTABLES,'<Tables />') AS XML)

		------------------------------------------------------------------------------
		-- 2. CICLO ATTRAVERSO TUTTE LE TABELLE REFERENZIATE ALL'INTERNO DI UNA VISTA 
		--    PER SOMMATORIA NUMERO DELLE RIGHE CONTENUTE IN CIASCUNA
		------------------------------------------------------------------------------
		SELECT @nodeCount = @xmlTABLES.value('count(//@FullTableName)','int')	-- INDIVIDUA E QUANTIFICA IL NUMERO DELLE OCCORRENZE DI CIASCUN NODO/ATTRIBUTO
		SET @i = 1
		WHILE (@i <= @nodeCount)
			BEGIN
				SELECT	
						@currentDataBaseName = T.c.value('(//@DatabaseName)[position() = sql:variable("@i")][1]', 'varchar(MAX)')
						,@currentSchemaName = T.c.value('(//@SchemaName)[position() = sql:variable("@i")][1]', 'varchar(MAX)')
						,@currentTableName = T.c.value('(//@TableName)[position() = sql:variable("@i")][1]', 'varchar(MAX)')
				FROM	@xmlTABLES.nodes('Tables') AS T(c) 
		
				SET @INNERSQL = [ETL].[BuildDynSQL_TableRowsMinMaxDates] (@currentDataBaseName, @currentTableName, @currentSchemaName)
				SET @OUTERSQL = IIF(@ConcessionaryName IS NOT NULL, N'SELECT * FROM OPENQUERY([' + @ServerName + '],''' + @INNERSQL + ''')', REPLACE(@INNERSQL,'''''',''''))
				SET	@OUTERMOSTSQL = [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQL)
				EXEC sp_executesqL @OUTERMOSTSQL, N'@returnValue varchar(MAX) OUT', @returnValue=@stringtTableInfo OUT
				SET @xmlTableInfo = CAST(@stringtTableInfo AS XML)
				
				-- ESTRAZIONE DEL NUMERO DELLE RIGHE NONCHE' DELLE DATE MINIMA E MASSIMA DA CIASCUNA TABELLA
				SELECT
						@currentRowsCount =  T.c.value('(//@RowsCount)[1]', 'bigint')
						,@currentMinDate = T.c.value('(//@MinDate)[1]', 'datetime')	
						,@currentMaxDate = T.c.value('(//@MaxDate)[1]', 'datetime')	
				FROM	@xmlTableInfo.nodes('TableInfo') AS T(c) 

				INSERT @tmpViewInfo(
						TableName 
						,TableRowsCount 
						,TableMinDate 
						,TableMaxDate 
				)
				VALUES (
						'[' + @ServerName + '].[' + @currentDataBaseName +'].[' + @currentSchemaName + '].[' + @currentTableName + ']'
						,@currentRowsCount
						,@currentMinDate
						,@currentMaxDate
				)

				SET @ROWSCOUNT += @currentRowsCount -- SOMMA DEL CONTEGGIO DELLE RIGHE EFFETTUATO PER CIASCUNA TABELLA
				SET @i += 1 -- INCREMENTO PER SPOSTAMENTO TRAMITE INDICE ATTRAVERSO LE VARIE OCCORRENZE DI CIASCUN NODO/ATTRIBUTO, TRA QUELLE INDIVIDUATE E MEMORIZZATE NELLA VARIABILE @nodeCount

			END	 -- WHILE (@i <= @nodeCount)

			UPDATE	@tmpViewInfo
			SET		
					ViewName = '[' + @ServerName + '].[' + @RawDataDBname +'].[' + @ClubID + '].[' + @RawDataViewName + ']'
					,ViewRowsCount = @ROWSCOUNT
					,ViewMinDate = (SELECT MIN(TableMinDate) FROM @tmpViewInfo)
					,ViewMaxDate = (SELECT MAX(TableMaxDate) FROM @tmpViewInfo)

			SET @ViewInfo = 
				CASE
					WHEN @ShowDependentTablesInfo = 1
					THEN (
						SELECT
								ViewName 
								,ViewRowsCount 
								,ViewMinDate 
								,ViewMaxDate 
								,TableName 
								,TableRowsCount 
								,TableMinDate 
								,TableMaxDate
						FROM	@tmpViewInfo
						ORDER BY TableMinDate
						FOR		XML RAW('ViewInfo'), TYPE 
					)
					ELSE (
						SELECT	DISTINCT
								ViewName AS Name
								,ViewRowsCount AS RowsCount
								,ViewMinDate AS MinDate
								,ViewMaxDate AS MaxDate 
						FROM	@tmpViewInfo
						FOR		XML RAW('ObjectInfo'), TYPE 
					)
					END
	END