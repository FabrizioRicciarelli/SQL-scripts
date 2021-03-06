USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetExplicitXmlTableFields]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.fnGetExplicitXmlTableFields
----------------------------------------

****************
* DA TERMINARE *
****************

FUNZIONE PREPOSTA ALLA RAPPRESENTAZIONE IN FORMATO XML EXPLICIT DI UNA QUALSIASI TABELLA SECONDO SPECIFICI LIVELLI 
DI ANNIDAMENTO

-- ESEMPI DI INVOCAZIONE

SELECT dbo.fnGetExplicitXmlTableFields('Link_RichiesteCancellazione',1) AS fieldsList
*/
CREATE FUNCTION	[dbo].[fnGetExplicitXmlTableFields](@tableName varchar(128) = NULL, @level int = NULL)
RETURNS Nvarchar(MAX)
AS
BEGIN
	DECLARE	
			@RETVAL nvarchar(MAX) = NULL
			,@purgedTableName nvarchar(MAX)
			,@orderby nvarchar(MAX)
			,@strLevel nvarchar(5)
			,@masterTag nvarchar(MAX)

	IF ISNULL(@tableName,'') != ''
	AND ISNULL(@level,0) > 0
		BEGIN
			SET @purgedTableName = CAST(dbo.fnpurge(@tableName) AS Nvarchar(MAX))
			SET @masterTag = CAST('Xml' + @purgedTableName AS Nvarchar(MAX))
			SET @strLevel = CAST('!' + CAST(ISNULL(@level,1) AS varchar(5)) + '!' AS Nvarchar(5))
			
			SELECT	TOP 1 @orderby =
					CAST
					(
						'ORDER BY [' + @masterTag + @strLevel + c.Name + '!element]' + CHAR(13) 
						AS nvarchar(MAX)
					)
			FROM	SYS.OBJECTS O
					INNER JOIN
					SYS.COLUMNS C
					ON O.object_id = C.object_id
			WHERE	O.name = @purgedTableName
			ORDER BY C.column_id

			SELECT	@RETVAL = 
					CAST
					(
						COALESCE(@RETVAL, '') + ',' + c.Name + ' AS [' + @masterTag + @strLevel + c.Name + '!element]' + CHAR(13)
						AS Nvarchar(MAX)
					)
			FROM	SYS.OBJECTS O
					INNER JOIN
					SYS.COLUMNS C
					ON O.object_id = C.object_id
			WHERE	O.name = @purgedTableName
			ORDER BY C.column_id

			SELECT	@RETVAL = 
					CAST
					(
						'SELECT 1 AS TAG, NULL AS parent' + CHAR(13) +
						@RETVAL +
						'FROM ' + @tableName + ' WITH(NOLOCK)' + CHAR(13) +
						@orderby +
						'FOR XML EXPLICIT, ROOT(''Xml' + @purgedTableName + '''), TYPE' + CHAR(13)
						AS Nvarchar(MAX)
					)
		END
	RETURN @RETVAL
END
GO
