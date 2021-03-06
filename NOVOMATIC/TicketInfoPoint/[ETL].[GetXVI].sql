/*
DECLARE @XVI XML = NULL -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)

EXEC	[ETL].[CountRawDataViewRows]
		@RawDataDBname = 'GMATICA_AGS_RawData'
		,@RawDataViewName = NULL -- IL DEFAULT, SE IL PARAMETRO E' PASSATO COME NULL, E' "RawData_View"
		,@ClubID = '1000296'
		,@ShowDependentTablesInfo = 1
		,@ViewInfo = @XVI OUTPUT

SELECT * FROM ETL.GetXVI(@XVI, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
*/
ALTER	FUNCTION [ETL].[GetXVI](
		@XMLvi XML = NULL
		,@ViewName sysname NULL
		,@ViewRowsCount bigint NULL
		,@ViewMinDate datetime NULL
		,@ViewMaxDate datetime NULL
		,@TableName sysname NULL
		,@TableRowsCount bigint NULL
		,@TableMinDate datetime NULL
		,@TableMaxDate datetime NULL
)
RETURNS @returnTVI TABLE(
		ViewName sysname NULL
		,ViewRowsCount bigint NULL
		,ViewMinDate datetime NULL
		,ViewMaxDate datetime NULL
		,TableName sysname NULL
		,TableRowsCount bigint NULL
		,TableMinDate datetime NULL
		,TableMaxDate datetime NULL
)
AS
BEGIN
	INSERT	@returnTVI
	SELECT
			 I.ViewName
			,I.ViewRowsCount
			,I.ViewMinDate
			,I.ViewMaxDate
			,I.TableName
			,I.TableRowsCount
			,I.TableMinDate
			,I.TableMaxDate
	FROM
	(
		SELECT 
				T.c.value('@ViewName', 'sysname') AS ViewName
				,T.c.value('@ViewRowsCount', 'bigint') AS ViewRowsCount
				,T.c.value('@ViewMinDate', 'datetime') AS ViewMinDate
				,T.c.value('@ViewMaxDate', 'datetime') AS ViewMaxDate
				,T.c.value('@TableName', 'sysname') AS TableName
				,T.c.value('@TableRowsCount', 'bigint') AS TableRowsCount
				,T.c.value('@TableMinDate', 'datetime') AS TableMinDate
				,T.c.value('@TableMaxDate', 'datetime') AS TableMaxDate
		FROM	@XMLvi.nodes('ViewInfo') AS T(c) 
	) I
	WHERE	(ViewName LIKE '%' + @ViewName + '%' OR @ViewName IS NULL)
	AND		(ViewRowsCount = @ViewRowsCount OR @ViewRowsCount IS NULL)
	AND		(ViewMinDate = @ViewMinDate OR @ViewMinDate IS NULL)
	AND		(ViewMaxDate = @ViewMaxDate OR @ViewMaxDate IS NULL)
	AND		(TableName LIKE '%' + @TableName + '%' OR @TableName IS NULL)
	AND		(TableRowsCount = @TableRowsCount OR @TableRowsCount IS NULL)
	AND		(TableMinDate = @TableMinDate OR @TableMinDate IS NULL)
	AND		(TableMaxDate = @TableMaxDate OR @TableMaxDate IS NULL)

	RETURN
END
