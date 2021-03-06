USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetTableFieldsWithAliasPrefix]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetTableFieldsWithAliasPrefix
----------------------------------------

QUASI IDENTICA ALLA FUNZIONE GEMELLA  "fnGetTableFields" ANCHE QUESTA FUNZIONE RITORNA UNA STRINGA, COMPOSTA DINAMICAMENTE, CONTENENTE L'ELENCO DEI CAMPI 
- SEMPRE SENZA TIPO DI DATO - PRESENTI NELLA TABELLA SPECIFICATA; A DIFFERENZA DELL'ALTRA, CON QUESTA FUNZIONE E' POSSIBILE SPECIFICARE UN ALIAS DA ANTEPORRE
AI NOMI DELLE COLONNE RITORNATE NELL'ELENCO.
L'ELENCO VEDRA' I CAMPI SEPARATI TRA LORO DA UNA VIRGOLA. LA PRESENTE FUNZIONE E' IN GRADO DI RESTITUIRE TUTTE LE COLONNE PRESENTI NEI TRE DATABASES
INERENTI LA INTRANET INPS, PERTANTO:

- IntranetInps
- IntranetInps_Lavoro
- IntranetInps_Richieste

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnGetTableFieldsWithAliasPrefix('Link_RichiesteCancellazione',NULL) AS fieldsList
SELECT dbo.fnGetTableFieldsWithAliasPrefix('[IntranetInps].[dbo].[KeyWord_Link]','A') AS fieldsList
SELECT dbo.fnGetTableFieldsWithAliasPrefix('[IntranetInps_Lavoro].[dbo].[AreeArchiviate]','AREEAR') AS fieldsList
SELECT dbo.fnGetTableFieldsWithAliasPrefix('[IntranetInps_Richieste].[dbo].[VSN_NewsInPage]','NIP') AS fieldsList
*/
CREATE FUNCTION	[dbo].[fnGetTableFieldsWithAliasPrefix](@tableName varchar(128) = NULL, @AliasPrefix varchar(20))
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE	@RETVAL varchar(MAX) = NULL

	IF ISNULL(@tableName,'') != ''
		BEGIN
			SET @AliasPrefix = ISNULL(@AliasPrefix,'T.')
			SET @AliasPrefix = 
				CASE 
					WHEN dbo.fnCountStringOccurrences(@AliasPrefix, '.') < 1
					THEN @AliasPrefix + '.'
					ELSE @AliasPrefix
				END

			IF dbo.fnCountStringOccurrences(@tableName, '.') > 1
			AND (@tableName LIKE '%IntranetInps.%' OR @tableName LIKE '%IntranetInps].%')
				BEGIN
					SELECT	@RETVAL = COALESCE(@RETVAL, '') + ',' + @AliasPrefix + column_name + CHAR(13)  
					FROM	IntranetInps.INFORMATION_SCHEMA.COLUMNS
					WHERE	table_name = dbo.fnpurge(@tableName) 
					AND		table_schema = 'dbo'
				END 
			ELSE
				BEGIN
					IF dbo.fnCountStringOccurrences(@tableName, '.') > 1
					AND (@tableName LIKE '%IntranetInps_Lavoro.%' OR @tableName LIKE '%IntranetInps_Lavoro].%')
						BEGIN
							SELECT	@RETVAL = COALESCE(@RETVAL, '') + ',' + @AliasPrefix + column_name + CHAR(13)  
							FROM	IntranetInps_Lavoro.INFORMATION_SCHEMA.COLUMNS
							WHERE	table_name = dbo.fnpurge(@tableName) 
							AND		table_schema = 'dbo'
						END 
					ELSE
						BEGIN
							IF dbo.fnCountStringOccurrences(@tableName, '.') > 1
							AND (@tableName LIKE '%IntranetInps_Richieste.%' OR @tableName LIKE '%IntranetInps_Richieste].%')
								BEGIN
									SELECT	@RETVAL = COALESCE(@RETVAL, '') + ',' + @AliasPrefix + column_name + CHAR(13)  
									FROM	IntranetInps_Richieste.INFORMATION_SCHEMA.COLUMNS
									WHERE	table_name = dbo.fnpurge(@tableName) 
									AND		table_schema = 'dbo'
								END
							ELSE 
								BEGIN
									SELECT	@RETVAL = COALESCE(@RETVAL, '') + ',' + @AliasPrefix + c.Name + CHAR(13)
									FROM	SYS.OBJECTS O
											INNER JOIN
											SYS.COLUMNS C
											ON O.object_id = C.object_id
									WHERE	O.name = @tableName
									ORDER BY C.column_id
								END
							END
				END
			IF @@ROWCOUNT > 0
				BEGIN
					SET @RETVAL = RIGHT(@RETVAL,LEN(@RETVAL)-1)
				END
		END
	RETURN @RETVAL
END
GO
