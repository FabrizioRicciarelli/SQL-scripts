/*
EXEC SP_BATCH_CheckRegoleAutomaticheContributi 2
*/
ALTER PROC	dbo.SP_BATCH_CheckRegoleAutomaticheContributi
			@IdContributo bigint
AS 
DECLARE 
		@From varchar(1000)
		,@Where varchar(1000)
		,@SQL varchar(MAX)

DECLARE rules_cursor CURSOR 
FAST_FORWARD 
READ_ONLY 
FOR  
	SELECT	
			[From]
			,Condition 
	FROM	dbo.RegoleAutomatiche
	WHERE	Entity = 'TAB_CONTR_031CM'

OPEN rules_cursor   
	FETCH	NEXT 
	FROM	rules_cursor 
	INTO	@From,@Where
	
	WHILE @@FETCH_STATUS = 0   
		BEGIN
			SET	@SQL = 'SELECT 0 FROM '+ @From + 'WHERE ' + @Where +' AND VARIAZIONE.ID_CONTR = ' + CAST(@IdContributo AS VARCHAR)
			PRINT @SQL
			EXEC(@SQL)
			
			FETCH	NEXT 
			FROM	rules_cursor 
			INTO	@From,@Where
		END   
CLOSE rules_cursor   
DEALLOCATE rules_cursor
