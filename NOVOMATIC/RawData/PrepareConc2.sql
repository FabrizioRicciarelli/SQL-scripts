USE [GMATICA_AGS_RawData_Elaborate_Stag_Agile]
GO
/****** Object:  StoredProcedure [RAW].[PrepareConc2]    Script Date: 06/07/2017 17:38:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: GA, FR
Creation Date.......: 2017-05-19
Last revision Date..: 2017-07-06
Description.........: Prepara un concessionario per il calcolo
Revision			 

Note
- Use [Tab size] = 2 and [Indent size]

------------------
-- Parameters   --
------------------	
@ConcessionaryID tinyint
@BatchID int
@ReturnCode int = 0 OUTPUT

------------------
-- Call Example --
------------------
DECLARE	@ReturnCode int
EXEC	@ReturnCode =  
		[RAW].[PrepareConc2]  
			@BatchID = 1
			,@ConcessionaryID  = 7

SELECT	@ReturnCode AS ReturnCode 

DECLARE	@ReturnCode int
EXEC	@ReturnCode =   
		[RAW].[TicketOutServerTime2] 
		@BatchID = 1

SELECT	@ReturnCode AS ReturnCode 

*/
ALTER PROC	[RAW].[PrepareConc2] 
			@ConcessionaryID tinyint
			,@BatchID int
			,@ReturnCode int = 0 OUTPUT
AS
---------------------
-- CODICE RIVISITATO
---------------------
SET NOCOUNT ON;

-- Variabili
DECLARE 
		@SYNONYMname sysname
		,@SYNONYMDefinition varchar(500)
		,@SYNONYMCreate varchar(500)
		,@Position varchar(50)
		,@Msg varchar(1000)
		,@ConcessionaryName varchar(50)
		,@ViewString varchar(1000)
		,@ServerTime_FIRST datetime = '1900-01-01 00:00:00.000'
		,@ServerTime_Last datetime = '2050-12-31 00:00:00.000'
		,@ProcedureName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + '.' + QUOTENAME(OBJECT_NAME(@@PROCID))
 
BEGIN TRY
	EXEC	spWriteOpLog 
			@ProcedureName
			,'Preparazione concessionario iniziata'
			,''
			,@BatchID

	SELECT	@ConcessionaryName = ConcessionaryName 
	FROM	dbo.ConcessionaryType WITH(NOLOCK)
	WHERE	[ConcessionarySK] = @ConcessionaryID

	SELECT	TOP 1
			@Position = Position 
	FROM	[Config].[Table] WITH(NOLOCK)

	UPDATE	Config.[Table] 
	SET		
			ConcessionaryName = @ConcessionaryName
			,ConcessionaryID = @ConcessionaryID

	SELECT	@SYNONYMname = '[dbo].[Machine]'
			,@SYNONYMDefinition = 'FOR [' + @Position + '].[' + @ConcessionaryName + '_AGS_RawData].' + @SYNONYMname
	EXEC	spDropAndCreate @SYNONYMname,'SYNONYM', @SYNONYMDefinition

	SELECT	@SYNONYMname = '[dbo].[DWMachine]'
			,@SYNONYMDefinition = 'FOR [' + @Position + '].[' + @ConcessionaryName + '_AGS_DW].[Dim].[VLT]'
	EXEC	spDropAndCreate @SYNONYMname,'SYNONYM', @SYNONYMDefinition

	SELECT	@SYNONYMname = '[dbo].[Game]'
			,@SYNONYMDefinition = 'FOR [' + @Position + '].[' + @ConcessionaryName + '_AGS_DW].[Dim].[Game]'
	EXEC	spDropAndCreate @SYNONYMname,'SYNONYM', @SYNONYMDefinition

	SELECT	@SYNONYMname = '[dbo].[GameName]'
			,@SYNONYMDefinition = 'FOR [' + @Position + '].[' + @ConcessionaryName + '_AGS_DW].[Dim].[GameName]'
	EXEC	spDropAndCreate @SYNONYMname,'SYNONYM', @SYNONYMDefinition

	SELECT	@SYNONYMname = '[dbo].[GameNameType]'
			,@SYNONYMDefinition = 'FOR [' + @Position + '].[' + @ConcessionaryName + '_AGS_DW].[Dim].[GameNameType]'
	EXEC	spDropAndCreate @SYNONYMname,'SYNONYM', @SYNONYMDefinition

	SELECT	@SYNONYMname = '[dbo].[GamingRoom]'
			,@SYNONYMDefinition = 'FOR [' + @Position + '].[' + @ConcessionaryName + '_AGS_RawData].[Finance].[GamingRoom]'
	EXEC	spDropAndCreate @SYNONYMname,'SYNONYM', @SYNONYMDefinition

	SET @ViewString = 
	'
	AS
	SELECT	GameID, GameNameType 
	FROM	[dbo].[Game] T1 
			JOIN 
			[dbo].[GameName] T2 
			ON T1.GameNameSK = T2.GameNameSk
			JOIN 
			[dbo].[GameNameType] T3 
			ON T2.GameNameTypeSK = T3.GameNameTypeSK
	'
	EXEC spDropAndCreate '[dbo].[GameNameID]','VIEW', @ViewString

	SET @ViewString = 
	'
	AS
	SELECT	ClubID, MachineID, T1.Machine, AamsMAchineCode 
	FROM	[dbo].[Machine] T1 
			JOIN 
			[dbo].[DWMachine] T2
			ON T1.Machine COLLATE SQL_Latin1_General_CP1_CI_AS = T2.Machine COLLATE SQL_Latin1_General_CP1_CI_AS
	'
	EXEC spDropAndCreate '[dbo].[VLT]','VIEW', @ViewString

	EXEC	spWriteOpLog 
			@ProcedureName
			,'Preparazione concessionario terminata'
			,''
			,@BatchID
END TRY

-- Gestione Errore
BEGIN CATCH
	EXECUTE [ERR].[UspLogError]  @ErrorRequestDetailID  = @BatchID;
	SET @ReturnCode = -1;
END CATCH
      
RETURN @ReturnCode


---------------------
-- CODICE ORIGINALE
---------------------
----BEGIN
----SET NOCOUNT ON;
------ Variabili
----DECLARE @SYNONYMDefinition VARCHAR(500), @SYNONYMCreate VARCHAR(500),@Position VARCHAR(50),@Msg VARCHAR(1000),@ConcessionaryName VARCHAR(50),@ViewString VARCHAR(1000);
----DECLARE @ServerTime_FIRST datetime = '1900-01-01 00:00:00.000', @ServerTime_Last datetime = '2050-12-31 00:00:00.000';
----DECLARE @ProcedureName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) +'.'+QUOTENAME(OBJECT_NAME(@@PROCID));
 
----BEGIN TRY
------ Inizializzo
----SELECT @ConcessionaryName = ConcessionaryName FROM dbo.ConcessionaryType WHERE [ConcessionarySK] = @ConcessionaryID
----SELECT @Position = Position FROM  Config.[Table]

----IF (Select OBJECT_DEFINITION (OBJECT_ID(N'[dbo].GameNameID'))) IS NOT NULL
----	DROP VIEW [dbo].GameNameID

----IF (Select OBJECT_DEFINITION (OBJECT_ID(N'[dbo].VLT'))) IS NOT NULL
----	DROP VIEW [dbo].VLT

------ aggiorno tabella di configurazione
----UPDATE Config.[Table] SET ConcessionaryName = @ConcessionaryName,ConcessionaryID = @ConcessionaryID
----		 WHERE 1=1
------ Creo sinonimo  [dbo].[Machine]
----SET @SYNONYMCreate = '
----IF EXISTS (SELECT  * FROM  sys.synonyms WHERE NAME = ''MACHINE'') 
----	DROP SYNONYM [dbo].[Machine]
----CREATE SYNONYM [dbo].[Machine] FOR ' + '[' + @Position + '].[' +
---- + @ConcessionaryName + '_AGS_RawData].[dbo].[Machine]'
---- PRINT @SYNONYMCreate
---- EXEC(@SYNONYMCreate)


---- -- Creo sinonimo  [dbo].[DWMachine]
----SET @SYNONYMCreate = '
----IF EXISTS (SELECT  * FROM  sys.synonyms WHERE NAME = ''DWMachine'') 
----	DROP SYNONYM [dbo].[DWMachine]
----CREATE SYNONYM [dbo].[DWMachine] FOR ' + '[' + @Position + '].[' +
---- + @ConcessionaryName + '_AGS_DW].[Dim].[VLT]'
---- PRINT @SYNONYMCreate
---- EXEC(@SYNONYMCreate)


------ Creo sinonimo  [dbo].[Game]
----SET @SYNONYMCreate = '
----IF EXISTS (SELECT  * FROM  sys.synonyms WHERE NAME = ''Game'') 
----	DROP SYNONYM [dbo].[Game]
----CREATE SYNONYM [dbo].[Game] FOR ' + '[' + @Position + '].[' +
---- + @ConcessionaryName + '_AGS_DW].[Dim].[Game]'

---- PRINT @SYNONYMCreate
---- EXEC(@SYNONYMCreate)

---- -- Creo sinonimo  [dbo].[GameName]
---- SET @SYNONYMCreate = '
----IF EXISTS (SELECT  * FROM  sys.synonyms WHERE NAME = ''GameName'') 
----	DROP SYNONYM [dbo].[GameName]
----CREATE SYNONYM [dbo].[GameName] FOR ' + '[' + @Position + '].[' +
---- + @ConcessionaryName + '_AGS_DW].[Dim].[GameName]'

---- PRINT @SYNONYMCreate
---- EXEC(@SYNONYMCreate)

----  -- Creo sinonimo  [dbo].[GameNameType]
----  SET @SYNONYMCreate = '
----IF EXISTS (SELECT  * FROM  sys.synonyms WHERE NAME = ''GameNameType'') 
----	DROP SYNONYM [dbo].[GameNameType]
----CREATE SYNONYM [dbo].[GameNameType] FOR ' + '[' + @Position + '].[' +
---- + @ConcessionaryName + '_AGS_DW].[Dim].[GameNameType]'

---- PRINT @SYNONYMCreate
---- EXEC(@SYNONYMCreate)

----   -- Creo sinonimo  [dbo].[GameNameType]
----  SET @SYNONYMCreate = '
----IF EXISTS (SELECT  * FROM  sys.synonyms WHERE NAME = ''GamingRoom'') 
----	DROP SYNONYM [dbo].[GamingRoom]
----CREATE SYNONYM [dbo].[GamingRoom] FOR ' + '[' + @Position + '].[' +
---- + @ConcessionaryName + '_AGS_RawData].[Finance].[GamingRoom]'

---- PRINT @SYNONYMCreate
---- EXEC(@SYNONYMCreate)
 
----SET @ViewString = '

----CREATE VIEW [dbo].GameNameID
----AS
----Select GameID,GameNameType FROM [dbo].[Game] T1 INNER JOIN [dbo].[GameName] T2 ON T1.GameNameSK = T2.GameNameSk
----INNER JOIN [dbo].[GameNameType] T3 ON T2.GameNameTypeSK = T3.GameNameTypeSK'

----PRINT @ViewString
----EXEC(@ViewString)



 
----SET @ViewString = '

----CREATE VIEW [dbo].VLT
----AS
----SELECT ClubID,MachineID,T1.Machine,AamsMAchineCode FROM [dbo].[Machine] T1 INNER JOIN [dbo].[DWMachine] T2
----			ON  T1.Machine COLLATE SQL_Latin1_General_CP1_CI_AS = T2.Machine COLLATE SQL_Latin1_General_CP1_CI_AS'

----PRINT @ViewString
----EXEC(@ViewString)


------ Controlli Finali
----	-- Log operazione
----	SET @Msg  = 'Preparazione concessionario terminata'
----	INSERT INTO [ETL].[OperationLog]  ([ProcedureName],[OperationMsg],[OperationRequestDetailID])
----	Select @ProcedureName,@Msg,@BatchID

----END TRY
----	-- Gestione Errore
----		   BEGIN CATCH
----				EXECUTE [ERR].[UspLogError]  @ErrorRequestDetailID  = @BatchID;
----            SET @ReturnCode = -1;
----       END CATCH
      
----RETURN @ReturnCode

----END

------Select GameID,GameNameType FROM [dbo].[Game] T1 INNER JOIN [dbo].[GameName] T2 ON T1.GameNameSK = T2.GameNameSk
------INNER JOIN [dbo].[GameNameType] T3 ON T2.GameNameTypeSK = T3.GameNameTypeSK
------ORDER BY GameNameType

------SELECT @SYNONYMDefinition = (Select OBJECT_DEFINITION (OBJECT_ID(N'[DW].[VLT]')))

------IF NOT @SYNONYMDefinition Like   '%![' + @ConcessionaryName + '!]%' ESCAPE '!'
------	OR  @SYNONYMDefinition IS NULL