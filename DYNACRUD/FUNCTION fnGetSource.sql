/*
---------------------------------------------------------------------------------------------
Funzione preposta al recupero di un elemento dal repository dei sorgenti
---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------
Esempi di invocazione:

SELECT dbo.fnGetSource('Chunk C#', 'ClassUsings') AS ClassUsings
---------------------------------------------------------------------------------------------
*/
ALTER FUNCTION dbo.fnGetSource(@RepositoryDescription varchar(512)=NULL, @SourceName varchar(128)=NULL)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @retVal varchar(MAX) = NULL

	IF ISNULL(@RepositoryDescription,'') != ''
	AND ISNULL(@SourceName,'') != ''
		BEGIN
			SELECT	@retVal = Contents
			FROM	V_SourcesRepository
			WHERE	RepositoryDescription = @RepositoryDescription -- 'Chunk C#'
			AND		SourceName = @SourceName -- 'ClassUsings'
		END
	
	RETURN @retVal
END