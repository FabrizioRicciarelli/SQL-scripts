USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetColumnDataType]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
-----------------------------------------
SELECT	
		fieldName
		,fieldType
		,fieldLenght
		,fieldPrecision
		,fieldScale
		,xmlPattern
		,fieldWithLength
		,OrdinalPosition
		,ColumnDefault
		,IsNullable
		,IsIdentity
		,IsPK
		,PK
FROM	fnGetColumnDataType('VSN_Pagina',NULL) 
WHERE	fieldName = 'idVsnPagina' -- TABELLA SU DATABASE CORRENTE
-----------------------------------------
DECLARE 
		@fieldList varchar(MAX)
		,@fieldListWithDataType varchar(MAX)
SELECT 
		@fieldList = COALESCE(@fieldList, '') + fieldName + ', '
		,@fieldListWithDataType = COALESCE(@fieldListWithDataType, '') + ' ' + fieldWithLength
FROM	fnGetColumnDataType('Pagine',NULL) 
PRINT(dbo.fnTrimCommas(@fieldList) + CHAR(13) + dbo.fnTrimCommas(@fieldListWithDataType))
-----------------------------------------
SELECT * FROM fnGetColumnDataType('VSN_Pagina',NULL) -- TABELLA SU DATABASE CORRENTE
SELECT * FROM fnGetColumnDataType('[Intranetinps_Richieste].[dbo].[VSN_TestoConImmagine]',NULL) -- TABELLA SU DATABASE CORRENTE (SPECIFICATO NELLA FORMA A TRE PARTI)
SELECT * FROM fnGetColumnDataType('[Intranetinps_Lavoro].[dbo].[TestoConImmagine]',NULL) -- TABELLA SU DATABASE ESTERNO
SELECT * FROM fnGetColumnDataType('vx_gruppi','T.') -- VISTA SU DATABASE CORRENTE; ALIAS SU CIASCUN NOME DI COLONNA
SELECT * FROM fnGetColumnDataType('[Intranetinps_Lavoro].[dbo].[vwDocumentiPagine]','T.') -- VISTA SU DATABASE REMOTO
SELECT * FROM fnGetColumnDataType('[Intranetinps].[dbo].[KeyWord_Link]','T.') -- VISTA SU DATABASE REMOTO
*/
CREATE FUNCTION [dbo].[fnGetColumnDataType](@objectName varchar(MAX)=NULL, @AliasPrefix varchar(20) = NULL)
RETURNS @FIELDINFO TABLE
		(
			fieldName varchar(128)
			,castedFieldName varchar(128)
			,fieldType varchar(128)
			,fieldLenght int
			,fieldPrecision int
			,fieldScale int
			,xmlPattern varchar(MAX)
			,fieldWithLength varchar(MAX)
			,OrdinalPosition int --NOT NULL
			,ColumnDefault varchar(MAX) --NULL
			,IsNullable BIT --NOT NULL
			,IsIdentity BIT --NOT NULL
			,IsPK BIT --NOT NULL
			,PK varchar(MAX) --NULL
		)
AS
BEGIN
	IF ISNULL(@objectName,'') != ''
		BEGIN
			SET @AliasPrefix = ISNULL(@AliasPrefix,'')

			IF dbo.fnCountStringOccurrences(@objectName, '.') > 1
			AND (@objectName LIKE '%IntranetInps.%' OR @objectName LIKE '%IntranetInps].%')
				BEGIN
					INSERT	@FIELDINFO
							(
								fieldName
								,castedFieldName
								,fieldType
								,fieldLenght
								,fieldPrecision
								,fieldScale
								,xmlPattern
								,fieldWithLength
								,OrdinalPosition
								,ColumnDefault
								,IsNullable
								,IsIdentity
								,IsPK
								,PK
							)
					SELECT 
							TC.COLUMN_NAME AS fieldName
							,castedFieldName =
								CASE
									WHEN DATA_TYPE IN('text', 'ntext', 'xml')
									THEN 'CAST(' + @AliasPrefix + TC.COLUMN_NAME + ' AS varchar(MAX)) AS ' + TC.COLUMN_NAME
									ELSE @AliasPrefix + TC.COLUMN_NAME
								END
							,TC.DATA_TYPE AS fieldType
							,TC.CHARACTER_MAXIMUM_LENGTH AS fieldLenght
							,TC.NUMERIC_PRECISION AS fieldPrecision
							,TC.NUMERIC_SCALE AS fieldScale
							,@AliasPrefix + TC.COLUMN_NAME + ' = XmlData.value(''(//' + TC.COLUMN_NAME + ')[1]'',''' + 
								CASE 
									WHEN TC.DATA_TYPE = 'text'
									THEN 'varchar(MAX)''' 
									WHEN TC.DATA_TYPE = 'ntext'
									THEN 'nvarchar(MAX)''' 
									WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
									AND TC.CHARACTER_MAXIMUM_LENGTH = -1
									THEN TC.DATA_TYPE + '(MAX)'''
									WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
									AND TC.CHARACTER_MAXIMUM_LENGTH > 0
									THEN TC.DATA_TYPE + '(' + CAST(TC.CHARACTER_MAXIMUM_LENGTH AS varchar(4)) + ')'''
									WHEN TC.DATA_TYPE IN ('decimal','numeric')
									THEN TC.DATA_TYPE + '(' + CAST(TC.NUMERIC_PRECISION AS varchar(4)) + ',' + CAST(TC.NUMERIC_SCALE AS varchar(4)) + ')'''
									ELSE TC.DATA_TYPE + ''''
								END +
								',' AS xmlPattern
							,@AliasPrefix + TC.COLUMN_NAME + ' ' +
								CASE 
									WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
									AND TC.CHARACTER_MAXIMUM_LENGTH = -1
									THEN TC.DATA_TYPE + '(MAX)'
									WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
									AND TC.CHARACTER_MAXIMUM_LENGTH > 0
									THEN TC.DATA_TYPE + '(' + CAST(TC.CHARACTER_MAXIMUM_LENGTH AS varchar(4)) + ')'
									WHEN TC.DATA_TYPE IN ('decimal','numeric')
									THEN TC.DATA_TYPE + '(' + CAST(TC.NUMERIC_PRECISION AS varchar(4)) + ',' + CAST(TC.NUMERIC_SCALE AS varchar(4)) + ')'
									ELSE TC.DATA_TYPE
								END +
								'),' AS fieldWithLength
							,TC.ORDINAL_POSITION AS OrdinalPosition
							,TC.COLUMN_DEFAULT AS ColumnDefault
							,IsNullable = CASE TC.IS_NULLABLE WHEN 'YES' THEN 1 ELSE 0 END
							,IsIdentity = COLUMNPROPERTY(object_id(TC.TABLE_SCHEMA + '.' + TC.TABLE_NAME), TC.COLUMN_NAME, 'IsIdentity')
							,IsPK = 
								CASE
									WHEN TC.COLUMN_NAME = CCU.COLUMN_NAME
									THEN 1
									ELSE 0
								END
							,PK =
								CASE
									WHEN TC.COLUMN_NAME = CCU.COLUMN_NAME
									THEN ccu.CONSTRAINT_NAME
									ELSE ''
								END
					FROM	IntranetInps.INFORMATION_SCHEMA.COLUMNS TC
							LEFT JOIN
							IntranetInps.INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TCN
							ON TCN.TABLE_CATALOG = TC.TABLE_CATALOG
							AND TCN.TABLE_NAME = TC.TABLE_NAME
							AND TCN.TABLE_SCHEMA = TC.TABLE_SCHEMA
							LEFT JOIN 
							IntranetInps.INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
							ON TCN.CONSTRAINT_NAME = CCU.CONSTRAINT_NAME
					WHERE	TC.table_name = dbo.fnpurge(@objectName) 
					AND		TC.table_schema = 'dbo'
				END 
			ELSE
				BEGIN
					IF dbo.fnCountStringOccurrences(@objectName, '.') > 1
					AND (@objectName LIKE '%IntranetInps_Lavoro.%' OR @objectName LIKE '%IntranetInps_Lavoro].%')
						BEGIN
							INSERT	@FIELDINFO
									(
										fieldName
										,castedFieldName
										,fieldType
										,fieldLenght
										,fieldPrecision
										,fieldScale
										,xmlPattern
										,fieldWithLength
										,OrdinalPosition
										,ColumnDefault
										,IsNullable
										,IsIdentity
										,IsPK
										,PK
									)
							SELECT 
									TC.COLUMN_NAME AS fieldName
									,castedFieldName =
										CASE
											WHEN TC.DATA_TYPE IN('text', 'ntext', 'xml')
											THEN 'CAST(' + @AliasPrefix + TC.COLUMN_NAME + ' AS varchar(MAX)) AS ' + TC.COLUMN_NAME
											ELSE @AliasPrefix + TC.COLUMN_NAME
										END
									,TC.DATA_TYPE AS fieldType
									,TC.CHARACTER_MAXIMUM_LENGTH AS fieldLenght
									,TC.NUMERIC_PRECISION AS fieldPrecision
									,TC.NUMERIC_SCALE AS fieldScale
									,@AliasPrefix + TC.COLUMN_NAME + ' = XmlData.value(''(//' + TC.COLUMN_NAME + ')[1]'',''' + 
										CASE 
											WHEN TC.DATA_TYPE = 'text'
											THEN 'varchar(MAX)''' 
											WHEN TC.DATA_TYPE = 'ntext'
											THEN 'nvarchar(MAX)''' 
											WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
											AND TC.CHARACTER_MAXIMUM_LENGTH = -1
											THEN TC.DATA_TYPE + '(MAX)'''
											WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
											AND TC.CHARACTER_MAXIMUM_LENGTH > 0
											THEN TC.DATA_TYPE + '(' + CAST(TC.CHARACTER_MAXIMUM_LENGTH AS varchar(4)) + ')'''
											WHEN TC.DATA_TYPE IN ('decimal','numeric')
											THEN TC.DATA_TYPE + '(' + CAST(TC.NUMERIC_PRECISION AS varchar(4)) + ',' + CAST(TC.NUMERIC_SCALE AS varchar(4)) + ')'''
											ELSE TC.DATA_TYPE + ''''
										END +
										'),' AS xmlPattern
									,@AliasPrefix + TC.COLUMN_NAME + ' ' +
										CASE 
											WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
											AND TC.CHARACTER_MAXIMUM_LENGTH = -1
											THEN TC.DATA_TYPE + '(MAX)'
											WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
											AND TC.CHARACTER_MAXIMUM_LENGTH > 0
											THEN TC.DATA_TYPE + '(' + CAST(TC.CHARACTER_MAXIMUM_LENGTH AS varchar(4)) + ')'
											WHEN TC.DATA_TYPE IN ('decimal','numeric')
											THEN TC.DATA_TYPE + '(' + CAST(TC.NUMERIC_PRECISION AS varchar(4)) + ',' + CAST(TC.NUMERIC_SCALE AS varchar(4)) + ')'
											ELSE TC.DATA_TYPE
										END +
										',' AS fieldWithLength
									,TC.ORDINAL_POSITION AS OrdinalPosition
									,TC.COLUMN_DEFAULT AS ColumnDefault
									,IsNullable = CASE TC.IS_NULLABLE WHEN 'YES' THEN 1 ELSE 0 END
									,IsIdentity = COLUMNPROPERTY(object_id(TC.TABLE_SCHEMA + '.' + TC.TABLE_NAME), TC.COLUMN_NAME, 'IsIdentity')
									,IsPK = 
										CASE
											WHEN TC.COLUMN_NAME = CCU.COLUMN_NAME
											THEN 1
											ELSE 0
										END
									,PK =
										CASE
											WHEN TC.COLUMN_NAME = CCU.COLUMN_NAME
											THEN ccu.CONSTRAINT_NAME
											ELSE ''
										END
							FROM	IntranetInps_Lavoro.INFORMATION_SCHEMA.COLUMNS TC
									LEFT JOIN
									IntranetInps_Lavoro.INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TCN
									ON TCN.TABLE_CATALOG = TC.TABLE_CATALOG
									AND TCN.TABLE_NAME = TC.TABLE_NAME
									AND TCN.TABLE_SCHEMA = TC.TABLE_SCHEMA
									LEFT JOIN 
									IntranetInps_Lavoro.INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
									ON TCN.CONSTRAINT_NAME = CCU.CONSTRAINT_NAME
							WHERE	TC.table_name = dbo.fnpurge(@objectName) 
							AND		TC.table_schema = 'dbo'
						END 
					ELSE
						BEGIN
							IF dbo.fnCountStringOccurrences(@objectName, '.') > 1
							AND (@objectName LIKE '%IntranetInps_Richieste.%' OR @objectName LIKE '%IntranetInps_Richieste].%')
								BEGIN
									INSERT	@FIELDINFO
											(
												fieldName
												,castedFieldName
												,fieldType
												,fieldLenght
												,fieldPrecision
												,fieldScale
												,xmlPattern
												,fieldWithlength
												,OrdinalPosition
												,ColumnDefault
												,IsNullable
												,IsIdentity
												,IsPK
												,PK
											)
									SELECT 
											TC.COLUMN_NAME AS fieldName
											,castedFieldName =
												CASE
													WHEN TC.DATA_TYPE IN('text', 'ntext', 'xml')
													THEN 'CAST(' + @AliasPrefix + TC.COLUMN_NAME + ' AS varchar(MAX)) AS ' + TC.COLUMN_NAME
													ELSE @AliasPrefix + TC.COLUMN_NAME
												END
											,TC.DATA_TYPE AS fieldType
											,TC.CHARACTER_MAXIMUM_LENGTH AS fieldLenght
											,TC.NUMERIC_PRECISION AS fieldPrecision
											,TC.NUMERIC_SCALE AS fieldScale
											,@AliasPrefix + TC.COLUMN_NAME + ' = XmlData.value(''(//' + TC.COLUMN_NAME + ')[1]'',''' + 
												CASE 
													WHEN TC.DATA_TYPE = 'text'
													THEN 'varchar(MAX)''' 
													WHEN TC.DATA_TYPE = 'ntext'
													THEN 'nvarchar(MAX)''' 
													WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
													AND TC.CHARACTER_MAXIMUM_LENGTH = -1
													THEN TC.DATA_TYPE + '(MAX)'''
													WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
													AND TC.CHARACTER_MAXIMUM_LENGTH > 0
													THEN TC.DATA_TYPE + '(' + CAST(TC.CHARACTER_MAXIMUM_LENGTH AS varchar(4)) + ')'''
													WHEN TC.DATA_TYPE IN ('decimal','numeric')
													THEN TC.DATA_TYPE + '(' + CAST(TC.NUMERIC_PRECISION AS varchar(4)) + ',' + CAST(TC.NUMERIC_SCALE AS varchar(4)) + ')'''
													ELSE TC.DATA_TYPE + ''''
												END +
												'),' AS xmlPattern
											,@AliasPrefix + TC.COLUMN_NAME + ' ' +
												CASE 
													WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
													AND TC.CHARACTER_MAXIMUM_LENGTH = -1
													THEN TC.DATA_TYPE + '(MAX)'
													WHEN TC.DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
													AND TC.CHARACTER_MAXIMUM_LENGTH > 0
													THEN TC.DATA_TYPE + '(' + CAST(TC.CHARACTER_MAXIMUM_LENGTH AS varchar(4)) + ')'
													WHEN TC.DATA_TYPE IN ('decimal','numeric')
													THEN TC.DATA_TYPE + '(' + CAST(TC.NUMERIC_PRECISION AS varchar(4)) + ',' + CAST(TC.NUMERIC_SCALE AS varchar(4)) + ')'
													ELSE TC.DATA_TYPE
												END +
												',' AS fieldWithLength
											,TC.ORDINAL_POSITION AS OrdinalPosition
											,TC.COLUMN_DEFAULT AS ColumnDefault
											,IsNullable = CASE TC.IS_NULLABLE WHEN 'YES' THEN 1 ELSE 0 END
											,IsIdentity = COLUMNPROPERTY(object_id(TC.TABLE_SCHEMA + '.' + TC.TABLE_NAME), TC.COLUMN_NAME, 'IsIdentity')
											,IsPK = 
												CASE
													WHEN TC.COLUMN_NAME = CCU.COLUMN_NAME
													THEN 1
													ELSE 0
												END
											,PK =
												CASE
													WHEN TC.COLUMN_NAME = CCU.COLUMN_NAME
													THEN ccu.CONSTRAINT_NAME
													ELSE ''
												END
									FROM	IntranetInps_Richieste.INFORMATION_SCHEMA.COLUMNS TC
											LEFT JOIN
											IntranetInps_Richieste.INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TCN
											ON TCN.TABLE_CATALOG = TC.TABLE_CATALOG
											AND TCN.TABLE_NAME = TC.TABLE_NAME
											AND TCN.TABLE_SCHEMA = TC.TABLE_SCHEMA
											LEFT JOIN 
											IntranetInps_Richieste.INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
											ON TCN.CONSTRAINT_NAME = CCU.CONSTRAINT_NAME
									WHERE	TC.table_name = dbo.fnpurge(@objectName) 
									AND		TC.table_schema = 'dbo'
								END
							ELSE 
								BEGIN
									INSERT	@FIELDINFO
											(
												fieldName
												,castedFieldName
												,fieldType
												,fieldLenght
												,fieldPrecision
												,fieldScale
												,xmlPattern
												,fieldWithLength
												,OrdinalPosition
												,ColumnDefault
												,IsNullable
												,IsIdentity
												,IsPK
												,PK
											)
									SELECT 
											c.name AS fieldName
											,castedFieldName =
												CASE
													WHEN t.name IN('text', 'ntext', 'xml')
													THEN 'CAST(' + @AliasPrefix + c.name  + ' AS varchar(MAX)) AS ' + c.name
													ELSE @AliasPrefix + c.name 
												END
											,t.name AS fieldType
											,c.max_length AS fieldLenght
											,c.precision AS fieldPrecision
											,c.scale AS fieldScale
											,@AliasPrefix + c.name + ' = XmlData.value(''(//' + c.name + ')[1]'',''' + 
												CASE
													WHEN t.name = 'text'
													THEN 'varchar(MAX)''' 
													WHEN t.name = 'ntext'
													THEN 'nvarchar(MAX)''' 
													WHEN t.name IN ('char','varchar', 'nchar', 'nvarchar')
													AND c.max_length = -1
													THEN t.name + '(MAX)'''
													WHEN t.name IN ('char','varchar', 'nchar', 'nvarchar')
													AND c.max_length > 0
													THEN t.name + '(' + CAST(c.max_length AS varchar(4)) + ')'''
													WHEN t.name IN ('decimal','numeric')
													THEN t.name + '(' + CAST(c.precision AS varchar(4)) + ',' + CAST(c.scale AS varchar(4)) + ')'''
													ELSE t.name + ''''
												END +
												'),' AS xmlPattern
											,@AliasPrefix + c.name + ' ' +
												CASE 
													WHEN t.name IN ('char','varchar', 'nchar', 'nvarchar')
													AND c.max_length = -1
													THEN t.name + '(MAX)'
													WHEN t.name IN ('char','varchar', 'nchar', 'nvarchar')
													AND c.max_length > 0
													THEN t.name + '(' + CAST(c.max_length AS varchar(4)) + ')'
													WHEN t.name IN ('decimal','numeric')
													THEN t.name + '(' + CAST(c.precision AS varchar(4)) + ',' + CAST(c.scale AS varchar(4)) + ')'
													ELSE t.name
												END +
												',' AS fieldWithLength
											,OrdinalPosition = c.column_id
											,ColumnDefault = NULL
											,IsNullable = c.is_nullable
											,IsIdentity = c.is_identity
											,IsPK = 0
											,PK = NULL
									FROM	sys.columns c
											JOIN 
											sys.types t
											ON t.user_type_id = c.user_type_id
											AND t.system_type_id = c.system_type_id
									WHERE	object_id = OBJECT_ID(@objectName)
								END
							END
						END
		END
	
	RETURN 
END
GO
