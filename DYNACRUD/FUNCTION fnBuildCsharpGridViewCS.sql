/*
---------------------------------------------------------------------------------------------
Funzione preposta alla creazione del codice C# del CodeBehind di gestione degli eventi di un 
GridView partendo dalla struttura di una tabella SQL

N.B.:
Usare sempre la SELECT per invocare la presente funzione; una volta eseguita, copiare 
il contenuto della colonna 'GridViewCodeBehindEvents' e incollarla all'interno di una 
finestra di Visual Studio preposta al recepimento di una classe CS.

Per creare la classe principale in C# della Crud dinamica (DYNACRUD), invocare la funzione
"dbo.fnBuildCsharpClass"

Per creare la definizione degli elementi ASPX per un GridView, invocare la funzione 
"dbo.fnBuildCsharpGridViewASPX".

Per creare la definizione degli elementi CSS per un GridView, invocare la funzione 
invocare la funzione "dbo.fnBuildCsharpGridViewCSS".
		
Per creare il codice C# del CodeBehind di gestione degli eventi di un GridView, invocare la 
funzione "dbo.fnBuildCsharpGridViewCS".

---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------
Esempi di invocazione: 

SELECT dbo.fnBuildCsharpGridViewCS('ENTITA_DETT') AS GridViewCodeBehindEvents
---------------------------------------------------------------------------------------------
*/
ALTER FUNCTION [dbo].[fnBuildCsharpGridViewCS](@tableName SYSNAME)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE 
			@TAB char(1) = CHAR(9)
			,@TAB2 char(2) = CHAR(9) + CHAR(9)
			,@TAB3 char(3) = CHAR(9) + CHAR(9) + CHAR(9)
			,@TAB4 char(4) = CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9)
			,@CR char(1) = CHAR(13)
			,@CR2 char(2) = CHAR(13) + CHAR(13)
			,@DataKeyNames varchar(MAX)
			,@GridViewName varchar(128)
			,@GridViewCodeBehindEvents varchar(MAX) = NULL

	IF ISNULL(@tableName,'') != ''
		BEGIN
			SET	@GridViewName = REPLACE(UPPER(LEFT(@TableName,1)) + LOWER(SUBSTRING(@TableName, 2, LEN(@TableName)-1)),'_','')

			SELECT	@GridViewCodeBehindEvents =
					REPLACE(Contents,'$TableName', @GridViewName)
					FROM	V_SourcesRepository
					WHERE	RepositoryDescription = 'Funzione C#'
					AND		SourceName = 'GridViewEventsCodeBehind'
		END
	RETURN @GridViewCodeBehindEvents
END
