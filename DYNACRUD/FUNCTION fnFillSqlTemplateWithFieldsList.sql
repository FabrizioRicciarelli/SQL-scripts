/*
---------------------------------------------------------------------------------------------
FUNZIONE PREPOSTA AL RIEMPIMENTO DI UN TEMPLATE SOSTITUENDO LE WILDCARDS ($N,$T,$F, ETC.)
CON I RISPETTIVI RIMPIAZZI PROVENIENTI DALLA FUNZIONE dbo.fnGetTableDef(@tableName)
---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------
Esempi di invocazione:

------------------------------
-- Esempio di creazione di 
-- elenchi per C#
------------------------------
-- 1. Classi C# (vedere anche la funzione ad-hoc "fnBuildCsharpClass")
------------------------------
DECLARE 
		@CR char(1) = CHAR(13)
		,@TAB char(1) = CHAR(9)
		,@TAB2 char(2) = CHAR(9) + CHAR(9)
		,@TAB3 char(3) = CHAR(9) + CHAR(9) + CHAR(9)
		,@regionPrivate varchar(50)
		,@regionPublic varchar(50)
		,@endregion varchar(20)
		,@summary varchar(100)

SET @regionPrivate = @TAB2 + '#region Variabili private' + @CR
SET @regionPublic = @TAB2 + '#region Proprietà pubbliche' + @CR
SET @endRegion = @TAB2 + '#endregion' + @CR
SET @summary = @CR + @TAB2 + '/// <summary>' + @CR + @TAB2 + '///' + @CR + @TAB2 + '/// </summary>' + @CR

PRINT (@regionPrivate + dbo.fnFillSqlTemplateWithFieldsList(@TAB2 + 'private $# $^;' + CHAR(13),'ENTITA_DETT') + @endregion) -- classe C# (Variabili private)
PRINT (@regionPublic + dbo.fnFillSqlTemplateWithFieldsList(@summary + @TAB2 + 'public $# $@' + @CR + @TAB2 + '{' + @CR + @TAB3 + 'get { return $^; }' + @CR + @TAB3 + 'set { $^ = ($#)value; }' + @CR + @TAB2 +' }' + CHAR(13),'ENTITA_DETT') + @endregion) -- classe C# (Proprietà pubbliche)

------------------------------
-- 2. Parametri DataAccessLayer C#
------------------------------
PRINT (dbo.fnFillSqlTemplateWithFieldsList('SqlParameter p$@ = new SqlParameter("$V",$Q);' + CHAR(13) + 'p$@.Size = $S;' + CHAR(13) + 'p$@.Precision = $P;' + CHAR(13) + 'p$@.Scale = $C;' + CHAR(13) + 'p$@.Value = $^;' + CHAR(13),'ENTITA_DETT')) 

------------------------------
-- Esempi di creazione di 
-- elenchi per T-SQL
------------------------------
PRINT (dbo.fnFillSqlTemplateWithFieldsList('$N,' + CHAR(13),'ENTITA_DETT'))
PRINT (dbo.fnFillSqlTemplateWithFieldsList('AND ($N = $V OR $V IS NULL) -- [$T] $F {$L} -$S- .$I. *$P* #$C#' + CHAR(13),'ENTITA_DETT'))
PRINT (dbo.fnFillSqlTemplateWithFieldsList('$N IS NOT NULL OR' + CHAR(13),'ENTITA_DETT'))
PRINT (dbo.fnFillSqlTemplateWithFieldsList('SET @SQL = dbo.fnAddSetParam(@SQL,''$N'', @$N, ''$T'') ' + CHAR(13),'ENTITA_DETT'))
-- 
*/
ALTER FUNCTION [dbo].[fnFillSqlTemplateWithFieldsList](@SQLbase nvarchar(MAX), @tableName SYSNAME)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @retVal varchar(MAX)
	SET @retVal = dbo.fnFillSqlTemplateWithFieldsListOrdered(@SQLbase, @tableName, NULL)
	RETURN @retVal
END