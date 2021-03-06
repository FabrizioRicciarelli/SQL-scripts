/*
DECLARE @XOI XML = NULL -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)

DECLARE
		@XCONFIG XML -- ex [Config].[Table]
SET		@XCONFIG = ETL.WriteXCONFIG(@XCONFIG, 1, 'POM-MON01', 25, 45, 7200, 50, 'GMatica', 1, 1) -- CARICA UN ELEMENTO NEL CONTENITORE @XCONFIG (ex [Config].[Table])

EXEC	[ETL].[CheckRawDataDB] 
		@XCONFIG = @XCONFIG
		,@CurrentDataInfo = @XOI -- PASSA IL CONTENITORE NULLO PER CARICARE I PRIMI RISULTATI DELL'ESECUZIONE
		,@ClubID = '1000002'
		,@DataInfo = @XOI OUTPUT

EXEC	[ETL].[CheckRawDataDB] 
		@XCONFIG = @XCONFIG
		,@CurrentDataInfo = @XOI -- PASSA IL CONTENITORE GIA' VALORIZZATO PER AGGIUNGERVI I RISULTATI DELL'ESECUZIONE
		,@ClubID = '1000296'
		,@DataInfo = @XOI OUTPUT

SELECT * FROM ETL.GetXOI(@XOI, '1000296', NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI, FILTRATI (TRAMITE LIKE SUL NOME DELL'OGGETTO)
ORDER BY Name

SELECT * FROM ETL.GetXOI(@XOI, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
ORDER BY Name
*/
ALTER	FUNCTION [ETL].[GetXOI](
		 @XMLoi XML = NULL
		,@Name sysname = NULL
		,@RowsCount bigint = NULL
		,@MinDate datetime = NULL
		,@MaxDate datetime = NULL
)
RETURNS @returnTV TABLE(
		Name sysname
		,RowsCount bigint
		,MinDate datetime
		,MaxDate datetime
)
AS
BEGIN
	INSERT	@returnTV
	SELECT
			I.Name
			,I.RowsCount
			,I.MinDate
			,I.MaxDate
	FROM
	(
		SELECT 
				T.c.value('@Name', 'sysname') AS Name
				,T.c.value('@RowsCount', 'bigint') AS RowsCount
				,T.c.value('@MinDate', 'datetime') AS MinDate
				,T.c.value('@MaxDate', 'datetime') AS MaxDate
		FROM	@XMLoi.nodes('ObjectInfo') AS T(c) 
	) I
	WHERE	(Name LIKE '%' + @Name + '%' OR @Name IS NULL)
	AND		(RowsCount = @RowsCount OR @RowsCount IS NULL)
	AND		(MinDate = @MinDate OR @MinDate IS NULL)
	AND		(MaxDate = @MaxDate OR @MaxDate IS NULL)

	RETURN
END
