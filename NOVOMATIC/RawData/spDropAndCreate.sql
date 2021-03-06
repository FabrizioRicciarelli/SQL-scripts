USE [GMATICA_AGS_RawData_Elaborate_Stag_Agile]
GO
/****** Object:  StoredProcedure [dbo].[spDropAndCreate]    Script Date: 06/07/2017 17:39:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
EXEC spDropAndCreate '[dbo].[Machine]','SYNONYM','FOR [_AGS_RawData].[dbo].[Machine]'
*/
ALTER PROC	[dbo].[spDropAndCreate]
			@ObjectName sysname = NULL
			,@ObjectType varchar(30) = NULL
			,@CreateDefinition varchar(MAX) = NULL
AS
IF ISNULL(@ObjectName,'') != ''
AND ISNULL(@ObjectType,'') != ''
AND ISNULL(@CreateDefinition,'') != ''
	BEGIN
		DECLARE @SQL Nvarchar(MAX)
		EXEC	spDropIfExists
				@ObjectName
				,@ObjectType
				 
		SELECT	@SQL = N'CREATE ' + @ObjectType + ' ' + @ObjectName + CHAR(13) + @CreateDefinition 
		--PRINT(@SQL)
		EXEC(@SQL)
	END
