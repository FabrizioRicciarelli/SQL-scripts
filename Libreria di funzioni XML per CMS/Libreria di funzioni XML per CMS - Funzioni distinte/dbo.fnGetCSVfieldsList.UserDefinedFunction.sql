USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetCSVfieldsList]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetCSVfieldsList
----------------------------------------

FUNZIONE CHE RITORNA UNA STRINGA, COMPOSTA DINAMICAMENTE, CONTENENTE L'ELENCO DEI CAMPI - E IL LORO TIPO DI DATO - PRESENTI NELLA TABELLA SPECIFICATA.
L'ELENCO, SE NON DIVERSAMENTE SPECIFICATO (QUINDI CON IL PARAMETRO "@separator" VALORIZZATO A NULL) VEDRA' I CAMPI SEPARATI TRA LORO DA UN PUNTO E VIRGOLA.

L'ELENCO RITORNATO NON VEDRA' PRESENTI:
- LA COLONNA IL CUI NOME CORRISPONDE AL NOME SPECIFICATO NEL PARAMETRO "@primaryIdFieldName" 
- I NOMI DI COLONNA CORRISPONDENTI A CAMPI DI TIPO XML 

QUESTO PERCHE' LA PRESENTE FUNZIONE E' STATA APPOSITAMENTE DISEGNATA PER POTER ESSERE IMPIEGATA NELLA STORED PROCEDURE DI GENERAZIONE DI CODICE AUTOMATICO
DENOMINATA "spGenSQLCodeForXmlGet"

PER AVERE L'ELENCO *COMPLETO* DEI CAMPI, SEPARATO DA VIRGOLE, PRESENTI IN UNA TABELLA SI VEDA LA FUNZIONE "dbo.fnGetTableFields"

-- ESEMPI DI INVOCAZIONE

SELECT	dbo.fnGetCSVfieldsList('dbo.VSN_Link', 'IdVsnLink', NULL) AS CSVFieldList
*/
CREATE FUNCTION	[dbo].[fnGetCSVfieldsList]
				(
					@tableName varchar(MAX) = NULL
					,@primaryIdFieldName varchar(128) = NULL
					,@separator CHAR(1) = NULL
				)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @RETVAL varchar(MAX) = NULL

	IF ISNULL(@tableName,'') != ''
	AND ISNULL(@primaryIdFieldName,'') != ''
		BEGIN

			DECLARE 
					@FieldList varchar(MAX)

			SET		@separator = ISNULL(@separator,';')

			SELECT	@FieldList = COALESCE(@FieldList,'') + ColumnName + ' ' + DataType + ';'
			FROM	dbo.fnGetColInfo(@tableName)
			WHERE	DataType != 'xml'
			AND		ColumnName != @primaryIdFieldName
			
			SET		@FieldList = dbo.fnTrimSeparator(@FieldList,';')
			SET		@RETVAL = @FieldList
		END

	RETURN @RETVAL

END
GO
