USE [GMATICA_AGS_RawData_Elaborate_Stag_Agile]
GO
/****** Object:  StoredProcedure [dbo].[spDropIfExists]    Script Date: 06/07/2017 17:39:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC spDropIfExists '[TRQ][PippoPluto]','VIEW'
EXEC spDropIfExists 'PippoPluto','SYNONYM'
*/
ALTER PROC	[dbo].[spDropIfExists]
			@ObjectName sysname = NULL
			,@ObjectType varchar(30) = NULL
AS
IF ISNULL(@ObjectName,'') != ''
AND ISNULL(@ObjectType,'') != ''
	BEGIN
		DECLARE @SQL Nvarchar(MAX)

		SELECT	@SQL = N'' + 
				CASE @ObjectType
					WHEN	'SYNONYM'
					THEN	'IF EXISTS (SELECT  * FROM  sys.synonyms WHERE NAME = ''' + @ObjectName + ''') '
					ELSE	'IF (SELECT OBJECT_DEFINITION (OBJECT_ID(N''' + @ObjectName + '''))) IS NOT NULL '
				END + 
				'DROP ' + @ObjectType + ' ' + @ObjectName 
		--PRINT(@SQL)
		EXEC(@SQL)
	END
