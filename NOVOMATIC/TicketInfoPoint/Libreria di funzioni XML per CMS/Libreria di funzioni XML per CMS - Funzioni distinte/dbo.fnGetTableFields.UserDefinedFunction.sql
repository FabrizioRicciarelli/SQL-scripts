USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetTableFields]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetTableFields
----------------------------------------

FUNZIONE CHE RITORNA UNA STRINGA, COMPOSTA DINAMICAMENTE, CONTENENTE L'ELENCO DEI CAMPI - SENZA TIPO DI DATO - PRESENTI NELLA TABELLA SPECIFICATA.
L'ELENCO VEDRA' I CAMPI SEPARATI TRA LORO DA UNA VIRGOLA. LA PRESENTE FUNZIONE E' IN GRADO DI RESTITUIRE TUTTE LE COLONNE PRESENTI NEI TRE DATABASES
INERENTI LA INTRANET INPS, PERTANTO:

- IntranetInps
- IntranetInps_Lavoro
- IntranetInps_Richieste

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnGetTableFields('Link_RichiesteCancellazione') AS fieldsList
SELECT dbo.fnGetTableFields('[IntranetInps].[dbo].[KeyWord_Link]') AS fieldsList
SELECT dbo.fnGetTableFields('[IntranetInps_Lavoro].[dbo].[AreeArchiviate]') AS fieldsList
SELECT dbo.fnGetTableFields('[IntranetInps_Richieste].[dbo].[VSN_NewsInPage]') AS fieldsList
*/
CREATE FUNCTION	[dbo].[fnGetTableFields](@tableName varchar(128) = NULL)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE	@RETVAL varchar(MAX) = NULL

	IF ISNULL(@tableName,'') != ''
		BEGIN
			IF dbo.fnCountStringOccurrences(@tableName, '.') > 1
			AND (@tableName LIKE '%IntranetInps.%' OR @tableName LIKE '%IntranetInps].%')
				BEGIN
					SELECT	@RETVAL = COALESCE(@RETVAL, '') + ',' + LTRIM(RTRIM(column_name)) + CHAR(13)  
					FROM	IntranetInps.INFORMATION_SCHEMA.COLUMNS
					WHERE	table_name = dbo.fnpurge(@tableName) 
					AND		table_schema = 'dbo'
				END 
			ELSE
				BEGIN
					IF dbo.fnCountStringOccurrences(@tableName, '.') > 1
					AND (@tableName LIKE '%IntranetInps_Lavoro.%' OR @tableName LIKE '%IntranetInps_Lavoro].%')
						BEGIN
							SELECT	@RETVAL = COALESCE(@RETVAL, '') + ',' + column_name + CHAR(13)  
							FROM	IntranetInps_Lavoro.INFORMATION_SCHEMA.COLUMNS
							WHERE	table_name = dbo.fnpurge(@tableName) 
							AND		table_schema = 'dbo'
						END 
					ELSE
						BEGIN
							IF dbo.fnCountStringOccurrences(@tableName, '.') > 1
							AND (@tableName LIKE '%IntranetInps_Richieste.%' OR @tableName LIKE '%IntranetInps_Richieste].%')
								BEGIN
									SELECT	@RETVAL = COALESCE(@RETVAL, '') + ',' + column_name + CHAR(13)  
									FROM	IntranetInps_Richieste.INFORMATION_SCHEMA.COLUMNS
									WHERE	table_name = dbo.fnpurge(@tableName) 
									AND		table_schema = 'dbo'
								END
							ELSE 
								BEGIN
									SELECT	@RETVAL = COALESCE(@RETVAL, '') + ',' + c.Name + CHAR(13)
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
