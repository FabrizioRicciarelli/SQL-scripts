USE [Intranetinps_Richieste]
GO
/****** Object:  StoredProcedure [dbo].[spGetVSNXml]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC spGetVSNXml 'VSN_LINK','XmlLink','ID_Link = 15122'
EXEC spGetVSNXml 'VSN_Pagina','XmlPagina','IdPagina = 8754 AND Versione = 3'
*/
CREATE PROC	[dbo].[spGetVSNXml]
			@VSNTableName varchar(MAX)=NULL
			,@VSNXmlColumnName varchar(128) = NULL
			,@VSNCriteria varchar(MAX) = NULL
AS
IF ISNULL(@VSNTableName,'') != ''
AND ISNULL(@VSNXmlColumnName,'') != ''
	BEGIN
		IF ISNULL(@VSNCriteria,'') != ''
			BEGIN
				SET @VSNCriteria =
					CASE
					WHEN LTRIM(REPLACE(@VSNCriteria,CHAR(13),'')) LIKE 'WHERE%'
					THEN ''
					ELSE ' WHERE ' + @VSNCriteria
				END
			END
			DECLARE 
					@SQL Nvarchar(MAX)
			
			SET @SQL = 'SELECT ' + 	@VSNXmlColumnName + ' FROM ' + @VSNTableName + ' ' + @VSNCriteria
			EXEC(@SQL)
	END	

GO
