/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: Fabrizio Ricciarelli 
Creation Date.......: 2018-01-15
Description.........: Estrazione GAMES

Revision			 

Note
- Use [Tab size] = 3 and [Indent size] = 3 (Instert spaces)

------------------
-- Parameters   --
------------------	
@ConcessionaryID	-- OBBLIGATORIO, DETERMINA IL CONCESSIONARIO
@ClubID				-- FACOLTATIVO, DETERMINA LA SALA
@XGAME				-- OUTPUT

-------------------
-- Call Examples --
-------------------
SET NOCOUNT ON;
DECLARE	@XGAME XML -- VUOTO
EXEC ETL.ExtractGAME 7, @XGAME = @XGAME OUTPUT
SELECT * FROM ETL.GetAllXGAME(@XGAME) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
*/
ALTER PROC	[ETL].[ExtractGAME] 
			@ConcessionaryID int = NULL
			,@GameID int = NULL
			,@GameNameSK int = NULL
			,@XGAME XML OUTPUT
AS
DECLARE 
		@INNERSQL Nvarchar(MAX)
		,@OUTERSQL Nvarchar(MAX)
		,@stringGAME Nvarchar(MAX)
		,@IsDevelopment bit
		,@ConcessionaryName varchar(128) 

SET @IsDevelopment = IIF(@@SERVERNAME LIKE '%DEV%', 1, 0)
SET @ConcessionaryName = ETL.getConcessionaryName(@ConcessionaryID)

SET @INNERSQL =
N'
	SELECT
			# AS ConcessionaryID	
			,T1.GameID AS GameID
			,T1.GameNameSK AS GameNameSK
			,REPLACE(T2.GameName, Char(13) + Char(10), '''') AS GameName
			,T3.GameNameTypeSK AS GameNameTypeSK
			,T1.AAMSGameCode AS AAMSGameCode
	FROM	[$_AGS_DW].[Dim].[Game] T1 WITH(NOLOCK)
			INNER JOIN 
			[$_AGS_DW].[Dim].[GameName] T2 WITH(NOLOCK)
			ON T1.GameNameSK = T2.GameNameSk 
			INNER JOIN 
			[$_AGS_DW].[Dim].[GameNameType] T3 WITH(NOLOCK)
			ON T2.GameNameTypeSK = T3.GameNameTypeSK
	WHERE	1 = 1
'

SET @INNERSQL += IIF(@GameID IS NOT NULL,N' AND T1.GameID = ' + CAST(@GameID AS Nvarchar(20)),'')
SET @INNERSQL += IIF(@GameNameSK IS NOT NULL,N' AND T1.GameNameSK = ' + CAST(@GameNameSK AS Nvarchar(20)),'')
SET @INNERSQL = REPLACE(@INNERSQL,'#',@ConcessionaryID)
SET @INNERSQL = REPLACE(@INNERSQL,'$',@ConcessionaryName)

SELECT	@OUTERSQL = 
		CASE	
			WHEN	@@SERVERNAME LIKE '%DEV%' -- DETERMINA L'AMBIENTE SUL QUALE E' IN ESECUZIONE LA CORRENTE STORED PROCEDURE
			THEN	N'SELECT @returnValue = CAST((SELECT * FROM OPENQUERY([POM-MON01],'''+ REPLACE(@INNERSQL,'''','''''') +''') FOR XML RAW(''GAME''),TYPE) AS Nvarchar(MAX))' -- QUERY PER ESECUZIONE IN AMBIENTE DI SVILUPPO  
			ELSE	N'SELECT @returnValue = CAST((SELECT * FROM (' + @INNERSQL + ') FOR XML RAW(''GAME''),TYPE) AS Nvarchar(MAX))' -- QUERY PER ESECUZIONE IN AMBIENTE DI PRODUZIONE
		END

EXEC	sp_executesqL @OUTERSQL, N'@returnValue Nvarchar(MAX) OUT', @returnValue=@stringGAME OUT

SELECT @XGAME = CAST(ISNULL(@stringGAME,'<GAME/>') AS XML)
