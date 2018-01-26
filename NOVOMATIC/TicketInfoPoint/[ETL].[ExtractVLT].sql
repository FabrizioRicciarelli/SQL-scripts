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
Description.........: Estrazione VLT

Revision			 

Note
- Use [Tab size] = 3 and [Indent size] = 3 (Instert spaces)

------------------
-- Parameters   --
------------------	
@ConcessionaryID	-- OBBLIGATORIO, DETERMINA IL CONCESSIONARIO
@ClubID				-- FACOLTATIVO, DETERMINA LA SALA
@XVLT				-- OUTPUT

-------------------
-- Call Examples --
-------------------
DECLARE	@XVLT XML -- VUOTO
EXEC ETL.ExtractVLT 7, @XVLT = @XVLT OUTPUT
SELECT * FROM ETL.GetXVLT(@XVLT, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI

DECLARE	@XVLT XML -- VUOTO
EXEC ETL.ExtractVLT 7, 1000025, @XVLT = @XVLT OUTPUT
SELECT * FROM ETL.GetXVLT(@XVLT, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI

DECLARE	@XVLT XML -- VUOTO
EXEC ETL.ExtractVLT 7, 1000002, @XVLT = @XVLT OUTPUT
SELECT * FROM ETL.GetXVLT(@XVLT, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
*/
ALTER PROC	[ETL].[ExtractVLT] 
			@ConcessionaryID int = NULL
			,@ClubID int = NULL
			,@XVLT XML OUTPUT
AS
DECLARE 
		@INNERSQL Nvarchar(MAX)
		,@OUTERSQL Nvarchar(MAX)
		,@VLT ETL.VLT_TYPE
		,@stringVLT Nvarchar(MAX)
		,@IsDevelopment bit 

SET @IsDevelopment = IIF(@@SERVERNAME LIKE '%DEV%', 1, 0)

SET @INNERSQL =
N'
	SELECT	
			T1.ClubID AS ClubID
			,MachineID
			,T1.Machine AS Machine
			,AamsMachineCode
			,T3.UnivocalLocationCode AS UnivocalLocationCode
	FROM	[' + ETL.getConcessionaryName(@ConcessionaryID) + '_AGS_RawData].[dbo].[Machine] T1 WITH(NOLOCK) 
			INNER JOIN 
			[' + ETL.getConcessionaryName(@ConcessionaryID) + '_AGS_DW].[Dim].[VLT] T2 WITH(NOLOCK)
			ON  T1.Machine COLLATE SQL_Latin1_General_CP1_CI_AS = T2.Machine COLLATE SQL_Latin1_General_CP1_CI_AS
			INNER JOIN
			[' + ETL.getConcessionaryName(@ConcessionaryID) + '_AGS_RawData].[Finance].[GamingRoom] T3 WITH(NOLOCK)
			ON T1.ClubID = T3.ClubID
'

SET @INNERSQL += IIF(@ClubID IS NOT NULL,N' WHERE T1.ClubID = ' + CAST(@ClubID AS Nvarchar(20)),'')

SELECT	@OUTERSQL = 
		CASE	
			WHEN	@@SERVERNAME LIKE '%DEV%' -- DETERMINA L'AMBIENTE SUL QUALE E' IN ESECUZIONE LA CORRENTE STORED PROCEDURE
			THEN	N'SELECT @returnValue = CAST((SELECT * FROM OPENQUERY([POM-MON01],'''+ REPLACE(@INNERSQL,'''','''''') +''') FOR XML RAW(''VLT''),TYPE) AS Nvarchar(MAX))' -- QUERY PER ESECUZIONE IN AMBIENTE DI SVILUPPO  
			ELSE	N'SELECT @returnValue = CAST((SELECT * FROM (' + @INNERSQL + ') FOR XML RAW(''VLT''),TYPE) AS Nvarchar(MAX))' -- QUERY PER ESECUZIONE IN AMBIENTE DI PRODUZIONE
		END

EXEC	sp_executesqL @OUTERSQL, N'@returnValue Nvarchar(MAX) OUT', @returnValue=@STRINGvlt OUT

SELECT @XVLT = CAST(ISNULL(@STRINGvlt,'<VLT/>') AS XML)
