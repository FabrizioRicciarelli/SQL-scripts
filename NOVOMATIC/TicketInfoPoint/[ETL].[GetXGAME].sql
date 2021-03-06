/*
DECLARE	@XGAME XML -- VUOTO
EXEC ETL.ExtractGAME 7, @XGAME = @XGAME OUTPUT
SELECT * FROM ETL.GetXGAME(@XGAME, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
*/
ALTER	FUNCTION [ETL].[GetXGAME](
		@XMLGAME XML = NULL
		,@ConcessionaryID int = NULL
		,@GameID int = NULL
		,@GameNameSK smallint = NULL
		,@GameName varchar(50) = NULL
		,@AAMSGameCode varchar(12) = NULL
)
RETURNS  @returnGAME TABLE(
		 ConcessionaryID int
		,GameID int
		,GameNameSK smallint
		,GameName varchar(50)
		,AAMSGameCode varchar(12)
)
AS
BEGIN
	INSERT	 @returnGAME
	SELECT
			 I.ConcessionaryID
			,I.GameID
			,I.GameNameSK
			,I.GameName
			,I.AAMSGameCode
	FROM
	(
		SELECT 
				T.c.value('@ConcessionaryID', 'int') AS ConcessionaryID
				,T.c.value('@GameID', 'int') AS GameID
				,T.c.value('@GameNameSK', 'smallint') AS GameNameSK
				,T.c.value('@GameName', 'varchar(50)') AS GameName
				,T.c.value('@AAMSGameCode', 'varchar(12)') AS AAMSGameCode
		FROM	@XMLGAME.nodes('GAME') AS T(c) 
	) I
	WHERE	(ConcessionaryID = @ConcessionaryID OR @ConcessionaryID IS NULL)
	AND		(GameID = @GameID OR @GameID IS NULL)
	AND		(GameNameSK = @GameNameSK OR @GameNameSK IS NULL)
	AND		(GameName = @GameName OR @GameName IS NULL)
	AND		(AAMSGameCode = @AAMSGameCode OR @AAMSGameCode IS NULL)

	RETURN
END
