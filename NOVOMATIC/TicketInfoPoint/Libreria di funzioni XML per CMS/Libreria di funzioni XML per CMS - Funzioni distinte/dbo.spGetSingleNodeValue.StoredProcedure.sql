USE [Intranetinps_Richieste]
GO
/****** Object:  StoredProcedure [dbo].[spGetSingleNodeValue]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
spGetSingleNodeValue
----------------------------------------

STORED PROCEDURE ATTA ALL’ESTRAZIONE DEL VALORE POPOLATO IN PROSSIMITÀ DEL NODO XML SPECIFICATO

-- ESEMPI DI INVOCAZIONE

EXEC	dbo.spGetSingleNodeValue
		@tableName = '[Intranetinps_Richieste].[dbo].[VSN_Galleria]' -- E' POSSIBILE UTILIZZARE LA FORMA A TRE PARTI PER PUNTARE AD UN DB DIVERSO DA QUELLO CORRENTE
		,@xmlFieldName = 'XmlGalleria'
		,@nodeName = 'FileAssociato'
		,@nodeID = NULL -- QUANDO "NULL", ESTRAE IL VALORE CORRISPONDENTE AL PRIMO NODO ('(//NodeName)[1]' NEL CASO IN CUI CE NE SIA PIU' DI UNO)
		,@criteria = 'id_VsnGalleria = 13'

EXEC	dbo.spGetSingleNodeValue
		@tableName = '[Intranetinps_Richieste].[dbo].[VSN_Galleria]' -- E' POSSIBILE UTILIZZARE LA FORMA A TRE PARTI PER PUNTARE AD UN DB DIVERSO DA QUELLO CORRENTE
		,@xmlFieldName = 'XmlGalleria'
		,@nodeName = 'FileAssociato'
		,@nodeID = 2
		,@criteria = 'id_VsnGalleria = 13'
*/
CREATE PROC	[dbo].[spGetSingleNodeValue]
			@tableName varchar(128) = NULL
			,@xmlFieldName varchar(128) = NULL
			,@nodeName varchar(128) = NULL
			,@nodeID int = NULL
			,@criteria varchar(MAX) = NULL
AS

IF ISNULL(@tableName,'') != ''
AND ISNULL(@xmlFieldName,'') != ''
AND ISNULL(@nodeName,'') != ''
AND ISNULL(@criteria,'') != ''
	BEGIN
		DECLARE @SQL varchar(MAX)

		SELECT	@nodeID =
				CASE
					WHEN @nodeID IS NULL
					THEN '1'
					ELSE @nodeID
				END

		SELECT	@criteria =
				CASE
					WHEN @criteria LIKE 'WHERE%'
					THEN @criteria
					ELSE 'WHERE ' + @criteria
				END

		SET	@SQL = 
		'SELECT ' +
		@nodeName + ' = C.value(''(//' + @nodeName + ')[' + CAST(@nodeID AS varchar(20)) + ']'',''varchar(MAX)'')'  + CHAR(13) + 
		'FROM '  + @tableName + ' AS T WITH(NOLOCK) ' + CHAR(13) +
		'CROSS APPLY T.' + @xmlFieldName + '.nodes(''/'') AS X(C)' + CHAR(13) +
		@criteria

		PRINT(@SQL)
		EXEC(@SQL)
	END


GO
