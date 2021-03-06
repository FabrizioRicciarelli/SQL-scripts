/*
-- TTKIN - ex TTicketIN

DECLARE @XTTKIN XML -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)

SET	@XTTKIN = ETL.WriteXTTKIN(@XTTKIN, NULL, '391378593917118855', 'GD64HH7748859', 1000296) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XTTKIN = ETL.WriteXTTKIN(@XTTKIN, NULL, '391378593917118859', 'TJ64HH7747341', 1000296) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)

SELECT * FROM ETL.GetXTTKIN(@XTTKIN, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetAllXTTKIN(@XTTKIN) FOR XML PATH('TTKIN'), ROOT('ROWS'), TYPE -- RITORNA L'ELENCO COMPLETO IN FORMA XML
*/
ALTER	FUNCTION [ETL].[GetXTTKIN](
		@XMLTTKIN XML = NULL
		,@ID smallint = NULL -- NOT NULL smallint IDENTITY(1,1)
		,@TicketID nvarchar(255) = NULL -- NOT NULL
		,@UnivocalLocationCode varchar(20) = NULL
		,@ClubID int = NULL
)
RETURNS @returnTTKIN TABLE(
	ID smallint
	,TicketID nvarchar(255)
	,UnivocalLocationCode varchar(20)
	,ClubID int
)
AS
BEGIN
	INSERT	@returnTTKIN
	SELECT
			 I.ID
			,I.TicketID
			,I.UnivocalLocationCode
			,I.ClubID
	FROM
	(
		SELECT 
				T.c.value('@ID', 'smallint') AS ID
				,T.c.value('@TicketID', 'nvarchar(255)') AS TicketID
				,T.c.value('@UnivocalLocationCode', 'varchar(20)') AS UnivocalLocationCode
				,T.c.value('@ClubID', 'int') AS ClubID
		FROM	@XMLTTKIN.nodes('TTKIN') AS T(c) 
	) I
	WHERE	(ID = @ID OR @ID IS NULL)
	AND		(TicketID = @TicketID OR @TicketID IS NULL)
	AND		(UnivocalLocationCode = @UnivocalLocationCode OR @UnivocalLocationCode IS NULL)
	AND		(ClubID = @ClubID OR @ClubID IS NULL)

	RETURN
END
