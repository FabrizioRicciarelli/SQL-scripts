USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetColInfo]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT * FROM dbo.fnGetColInfo('VSN_TestoConImmagine')
SELECT * FROM dbo.fnGetColInfo('[Intranetinps_Lavoro].[dbo].[vwDocumentiPagine]')
SELECT * FROM dbo.fnGetColInfo('IntranetInps.dbo.KeyWord_Link')
SELECT * FROM dbo.fnGetColInfo('ImmagineGalleria')
*/
CREATE FUNCTION [dbo].[fnGetColInfo](@tableName varchar(MAX))
RETURNS @COLINFO TABLE
		(
			TableCatalog varchar(128) --NOT NULL
			,TableSchema varchar(128) --NOT NULL
			,TableName varchar(128) --NOT NULL
			,ColumnName varchar(128) --NOT NULL
			,OrdinalPosition int --NOT NULL
			,ColumnDefault varchar(MAX) --NULL
			,IsNullable BIT --NOT NULL
			,DataType varchar(128) --NOT NULL
			,MaxLength int --NULL
			,Precision int --NULL
			,Scale int --NULL
			,IsIdentity BIT --NOT NULL
			,IsPK BIT --NOT NULL
			,PK varchar(MAX) --NULL
		)
AS
BEGIN
	IF ISNULL(@tableName,'') != ''
		BEGIN
			DECLARE 
					@Catalog varchar(128)
					,@Schema varchar(128)
					,@Table varchar(128)
					,@DEBUG bit = 0

			SET @tableName = REPLACE(REPLACE(@tableName, '[',''),']','')
			
			SET @Schema = 
				CASE
					WHEN dbo.fnMiddlePart(@tableName,'.') IS NULL
					THEN 'dbo'
					ELSE dbo.fnMiddlePart(@tableName,'.')

				END

			SET @Catalog = 
				CASE
					WHEN dbo.fnLeftPart(@tableName,'.dbo') IS NULL 
					OR dbo.fnLeftPart(@tableName,'.dbo') = @tableName
					THEN DB_NAME()
					ELSE dbo.fnLeftPart(@tableName,'.dbo')
				END
			
			SET @Table = ISNULL(dbo.fnRightPart(@tableName, @Schema + '.'),@tableName)

			IF @DEBUG = 1
				BEGIN
					INSERT	@COLINFO
							(
								TableCatalog
								,TableSchema
								,TableName
							)
					SELECT
							@Catalog AS TableCatalog, @Schema AS TableSchema, @Table AS Tablet
				END
			ELSE
				BEGIN
					INSERT	@COLINFO
							(
								TableCatalog
								,TableSchema
								,TableName
								,ColumnName
								,OrdinalPosition
								,ColumnDefault
								,IsNullable
								,DataType
								,MaxLength
								,Precision
								,Scale
								,IsIdentity
								,IsPK
								,PK
							)
					SELECT	
							TC.TABLE_CATALOG AS TableCatalog
							,TC.TABLE_SCHEMA AS TableSchema
							,TC.TABLE_NAME AS TableName
							,TC.COLUMN_NAME AS Columname
							,TC.ORDINAL_POSITION AS OrdinalPosition
							,TC.COLUMN_DEFAULT AS ColumnDefault
							,IsNullable = CASE TC.IS_NULLABLE WHEN 'YES' THEN 1 ELSE 0 END
							,TC.DATA_TYPE AS DataType
							,TC.CHARACTER_MAXIMUM_LENGTH AS MaxLength
							,TC.NUMERIC_PRECISION AS Precision
							,TC.NUMERIC_SCALE AS Scale
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
					FROM	INFORMATION_SCHEMA.COLUMNS TC
							LEFT JOIN
							INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TCN
							ON TCN.TABLE_CATALOG = TC.TABLE_CATALOG
							AND TCN.TABLE_NAME = TC.TABLE_NAME
							AND TCN.TABLE_SCHEMA = TC.TABLE_SCHEMA
							LEFT JOIN 
							INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
							ON TCN.CONSTRAINT_NAME = CCU.CONSTRAINT_NAME
					WHERE	TCN.TABLE_CATALOG = @Catalog
							AND TCN.TABLE_SCHEMA = @schema
							AND TCN.TABLE_NAME = @table
							AND TCN.CONSTRAINT_TYPE = 'PRIMARY KEY'
			END
		END

		RETURN
END
GO
