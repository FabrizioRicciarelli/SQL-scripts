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

DECLARE @replacements varchar(max) = ''
SELECT	@replacements = COALESCE(@replacements,'') + FieldName + ' = ' + WildCard + CHAR(13)
FROM	FILLER_DEC
PRINT(@replacements)

PRINT 
(
	dbo.fnFillSqlTemplateWithFieldsListOrdered
	(
		@replacements
		,'ENTITA_DETT'
		,NULL
	)
)


PRINT (dbo.fnFillSqlTemplateWithFieldsListOrdered('$N, -- (ad es.: $?)' + CHAR(13),'ENTITA_DETT',NULL))
PRINT (dbo.fnFillSqlTemplateWithFieldsListOrdered('AND ($N = $V OR $V IS NULL) -- [$T] $F {$L} -$S- .$I. *$P* #$C#' + CHAR(13),'ENTITA_DETT',NULL))
PRINT (dbo.fnFillSqlTemplateWithFieldsListOrdered('$N IS NOT NULL OR' + CHAR(13),'ENTITA_DETT',NULL))
PRINT (dbo.fnFillSqlTemplateWithFieldsListOrdered('SET @SQL = dbo.fnAddSetParam(@SQL,''$N'', @$N, ''$T'') ' + CHAR(13),'ENTITA_DETT',NULL))
PRINT (dbo.fnFillSqlTemplateWithFieldsListOrdered('_ed.$@ = $?;' + CHAR(13),'ENTITA_DETT',NULL))

DECLARE @TAB2 char(2) = CHAR(9) + CHAR(9), @TAB3 char(3) = CHAR(9) + CHAR(9) + CHAR(9)
SELECT 
(
	REPLACE
	(
		REPLACE
		(
			dbo.fnFillSqlTemplateWithFieldsListOrdered
			(
				@TAB2 + '<asp:TemplateField HeaderText="$@" HeaderStyle-HorizontalAlign="Left">' + CHAR(13) +
				@TAB3 + '<ItemTemplate><asp:Label ID="lbl$@" Text=''<%# Bind("$@") %>'' DataFormatString="{0:F$S}" ApplyFormatInEditMode="true" HtmlEncode="false" runat="server"></asp:Label></ItemTemplate>' + CHAR(13) +
				@TAB3 + '<EditItemTemplate><asp:TextBox ID="txt$@" MaxLength="$S" Text=''<%# Bind("$@") %>'' DataFormatString="{0:F$S}" ApplyFormatInEditMode="true" HtmlEncode="false" runat="server"></asp:TextBox></EditItemTemplate>' + CHAR(13) +
				@TAB3+ '<FooterTemplate><asp:TextBox ID="txt$@" runat="server"></asp:TextBox></FooterTemplate>' + CHAR(13) +
				@TAB2 + '</asp:TemplateField>' + CHAR(13)

				,'ENTITA_DETT',NULL)
			,'_x'
			,''
		)
		,'_PK'
		,''
	)
)
-- 
*/
ALTER FUNCTION [dbo].[fnFillSqlTemplateWithFieldsListOrdered](@SQLbase nvarchar(MAX), @tableName SYSNAME, @orderByDefFieldName SYSNAME=NULL)
RETURNS nvarchar(MAX) AS
BEGIN

/*
---------------------------------------------------------------------------------
-- SE SOLO FOSSE POSSIBILE ESEGUIRE LA sp_executesql ALL'INTERNO DI UNA FUNZIONE
-- IL CODICE COMMENTATO CHE SEGUE SOSTITUIREBBE INTEGRALMENTE QUELLO ATTUALMENTE
-- IN USO
---------------------------------------------------------------------------------
DECLARE 
		@r varchar(max)
		,@t varchar(max)
		,@function Nvarchar(MAX)
		,@AP varchar(1) = CHAR(39)
		,@TAB2 char(2) = CHAR(9) + CHAR(9)
		,@SQL Nvarchar(MAX) = NULL
		,@parmDef Nvarchar(max) = N'@tableName SYSNAME, @SQLbase Nvarchar(MAX), @SQL Nvarchar(MAX) OUTPUT'

		----------------------------------------------------------------
		-- Da commentare se si può utilizzare una EXEC in una FUNCTION
		-- (decommentando di conseguenza tutto il resto del codice)
		----------------------------------------------------------------
		,@orderByDefFieldName varchar(100) = 'variableName'
		,@tableName SYSNAME = 'ENTITA_DETT'
		,@SQLbase Nvarchar(MAX) = '$V $F,' + CHAR(13)
		----------------------------------------------------------------
SELECT	
		@r = COALESCE(@r,'') + @TAB2 + 'REPLACE(' + CHAR(13)
		,@t = COALESCE(@t,'') + @TAB2 + @AP + LTRIM(RTRIM(WildCard)) + @AP + ',' + LTRIM(RTRIM(FieldName)) + '),' + CHAR(13)
FROM	FILLER_DEC
ORDER BY FieldName

SET @t = LEFT(@t,LEN(@t)-2)
SET @function =	N'SELECT @SQL = COALESCE(@SQL,'''') + ' + CHAR(13) + 
				@r + @TAB2 + '''' + @SQLbase + ''',' + CHAR(13) + 
				@t + CHAR(13) + 
				'FROM dbo.fnGetTableDef('''' + @tableName + '''')' + CHAR(13) + 
				CASE ISNULL(@orderByDefFieldName,'') WHEN '' THEN '' ELSE 'ORDER BY ' + @orderByDefFieldName END
EXEC sp_executesql @function, @parmDef, @tableName, @SQLbase, @SQL=@SQL OUTPUT
SET @SQL = CASE WHEN RIGHT(@SQL,1) = ',' THEN LEFT(@SQL,LEN(@SQL)-1) WHEN RIGHT(@SQL,2) = ',' + CHAR(13) THEN LEFT(@SQL,LEN(@SQL)-2) END
--PRINT(@function)
PRINT(@SQL)
-- RETURN @SQL
*/
	DECLARE
			@retVal nvarchar(MAX)
			,@SQL Nvarchar(MAX)

	IF ISNULL(@SQLbase,'') != ''
	AND ISNULL(@tableName,'') != ''
		BEGIN

			IF ISNULL(@orderByDefFieldName,'') = ''
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
				END

			IF ISNULL(@orderByDefFieldName,'') = 'fieldName'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY fieldName
				END

			IF ISNULL(@orderByDefFieldName,'') = 'variableName'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY variableName
				END

			IF ISNULL(@orderByDefFieldName,'') = 'castedFieldName'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY castedFieldName
				END

			IF ISNULL(@orderByDefFieldName,'') = 'castedDenulledFieldName'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY castedDenulledFieldName
				END

			IF ISNULL(@orderByDefFieldName,'') = 'fieldType'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY fieldType
				END

			IF ISNULL(@orderByDefFieldName,'') = 'fullFieldType'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY fullFieldType
				END

			IF ISNULL(@orderByDefFieldName,'') = 'SqlDbType'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY SqlDbType
				END

			IF ISNULL(@orderByDefFieldName,'') = 'cSharpType'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY cSharpType
				END

			IF ISNULL(@orderByDefFieldName,'') = 'cSharpPrivateVariableName'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY cSharpPrivateVariableName
				END

			IF ISNULL(@orderByDefFieldName,'') = 'cSharpPublicPropertyName'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY cSharpPublicPropertyName
				END

			IF ISNULL(@orderByDefFieldName,'') = 'fieldLength'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY fieldLength
				END

			IF ISNULL(@orderByDefFieldName,'') = 'stringFieldLength'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY stringFieldLength
				END

			IF ISNULL(@orderByDefFieldName,'') = 'fieldIsIdentity'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY fieldIsIdentity
				END

			IF ISNULL(@orderByDefFieldName,'') = 'fieldIsKey'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY fieldIsKey
				END

			IF ISNULL(@orderByDefFieldName,'') = 'fieldPrecision'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY fieldPrecision
				END

			IF ISNULL(@orderByDefFieldName,'') = 'randomData'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY randomData
				END

			IF ISNULL(@orderByDefFieldName,'') = 'fieldScale'
				BEGIN
					SELECT	@retVal = COALESCE(@retVal,'') + 
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
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(
							@SQLbase,
							'$N',fieldName),
							'$V',variableName),
							'$K',castedFieldName),
							'$M',castedDenulledFieldName),
							'$T',fieldType),
							'$F',fullFieldType),
							'$Q',SqlDbType),
							'$#',cSharpType),
							'$^',cSharpPrivateVariableName),
							'$@',cSharpPublicPropertyName),
							'$L',fieldLength),
							'$S',stringFieldLength),
							'$I',fieldIsIdentity),
							'$X',fieldIsKey),
							'$P',fieldPrecision),
							'$?',randomData),
							'$C',fieldScale)
					FROM	dbo.fnGetTableDef(@tableName)
					ORDER BY fieldScale
				END

		END
	RETURN @retVal
END
