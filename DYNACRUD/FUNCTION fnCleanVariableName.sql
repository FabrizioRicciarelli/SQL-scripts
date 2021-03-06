/*
----------------------------------------------------
-- FUNZIONE PREPOSTA AL RIMPIAZZO DI STRINGHE
-- UTILIZZATE COME NOMI DI VARIABLI
----------------------------------------------------
--
-- Fabrizio Ricciarelli per Eustema Spa
-- 16/11/2015
--
-- Esempi di invocazione:
--
PRINT (dbo.fnCleanVariableName('@giachiocciolata'))
PRINT (dbo.fnCleanVariableName('Segno_d’archivio'))
PRINT (dbo.fnCleanVariableName('Dati per DC Finanza'))
PRINT (dbo.fnCleanVariableName('Da inserire nella comunica-zione'))
-- 
*/
ALTER FUNCTION [dbo].[fnCleanVariableName](@string varchar(128))
RETURNS varchar(128)
AS
BEGIN
	DECLARE @retVal varchar(128)
	SET		@retVal =
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			@string,
			' ','_'),
			CHAR(160),'_'),
			'-','_' + CAST(ASCII('-') AS varchar(5)) + '_'),
			'+','_' + CAST(ASCII('+') AS varchar(5)) + '_'),
			'*','_' + CAST(ASCII('*') AS varchar(5)) + '_'),
			'/','_' + CAST(ASCII('/') AS varchar(5)) + '_'),
			'’','_' + CAST(ASCII('’') AS varchar(5)) + '_'),
			'@','_' + CAST(ASCII('@') AS varchar(5)) + '_'),
			'#','_' + CAST(ASCII('#') AS varchar(5)) + '_'),
			'§','_' + CAST(ASCII('§') AS varchar(5)) + '_'),
			'\','_' + CAST(ASCII('\') AS varchar(5)) + '_'),
			'$','_' + CAST(ASCII('$') AS varchar(5)) + '_')

	RETURN @retVal
END
