/*
DECLARE	@XGAME XML -- VUOTO
EXEC ETL.ExtractGAME 7, @XGAME = @XGAME OUTPUT
SELECT * FROM ETL.GetAllXGAME(@XGAME) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
*/
ALTER	FUNCTION [ETL].[GetAllXGAME](
		@XMLGAME XML = NULL
)
RETURNS  TABLE
AS
RETURN(
	SELECT 
			T.c.value('@ConcessionaryID', 'int') AS ConcessionaryID
			,T.c.value('@GameID', 'int') AS GameID
			,T.c.value('@GameNameSK', 'smallint') AS GameNameSK
			,T.c.value('@GameName', 'varchar(50)') AS GameName
			,T.c.value('@AAMSGameCode', 'varchar(12)') AS AAMSGameCode
	FROM	@XMLGAME.nodes('GAME') AS T(c) 
) 