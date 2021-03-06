USE [Intranetinps_Richieste]
GO
/****** Object:  StoredProcedure [dbo].[spGetCrossDbColumns]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC spGetCrossDbColumns 'Intranetinps_Lavoro', 'vwDocumentiPagine' 
*/
CREATE PROC [dbo].[spGetCrossDbColumns]
			@dbname sysname
			,@tablename sysname
AS

DECLARE @Tables table 
		(
			DbName sysname
			,SchemaName sysname
			,TableName sysname
			,columnobjectid int
			,columnName sysname
			,columnid int
			,maxlen int
			,prec int
			,scal int
			,nullable bit
			,isidentity bit
			,TypeName sysname
		)

DECLARE @SQL nvarchar(4000)

SET @SQL='
select	''?'' as 
		DbName
		,s.name as SchemaName
		,t.name as TableName
		,c.object_id as columnobjectid
		,c.name as columnName
		,c.column_id as columnid
		,c.max_length as maxlen
		,c.precision as prec
		,c.scale as scal
		,c.is_nullable as nullable
		,c.is_identity as isidentity
		,tp.name as TypeName
from	[?].sys.tables t 
		inner join 
		[?].sys.schemas s 
		on t.schema_id=s.schema_id 
		Inner join 
		[?].sys.columns c 
		on t.object_id = c.object_id
		Inner Join 
		[?].sys.types Tp 
		on tp.system_type_id = c.system_type_id
where	tp.name IN
		(
			''char'', ''nchar'',
			''varchar'', ''nvarchar'',
			''text'', ''ntext''
		)'

INSERT	@Tables 
		(
			DbName
			,SchemaName
			,TableName
			,columnobjectid
			,columnName
			,columnid
			,maxlen
			,prec
			,scal
			,nullable
			,isidentity
			,TypeName
		)
EXEC	sp_msforeachdb @SQL
SET NOCOUNT OFF

SELECT	* 
FROM	@Tables 
WHERE	DbName = @dbname
AND		TableName = @tableName
ORDER BY 
		DbName
		,SchemaName
		,TableName
		,columnid

GO
