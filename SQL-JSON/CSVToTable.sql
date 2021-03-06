IF OBJECT_ID (N'dbo.CSVToTable') IS NOT NULL
DROP PROCEDURE dbo.CSVToTable
GO
/*
---------------------------
CSVToTable
---------------------------

Stored procedure which takes a CSV definition (and its data) and converts it to a tabular format

-- SAMPLE USAGE:

EXEC CSVToTable 
'"REVIEW_DATE","AUTHOR","ISBN","DISCOUNTED_PRICE"
"1985/01/21","Douglas Adams",0345391802,5.95
"1990/01/12","Douglas Hofstadter",0465026567,9.95
"1998/07/15","Timothy ""The Parser"" Campbell",0968411304,18.99
"1999/12/03","Richard Friedman",0060630353,5.95
"2001/09/19","Karen Armstrong",0345384563,9.95
"2002/06/23","David Jones",0198504691,9.95
"2002/06/23","Julian Jaynes",0618057072,12.50
"2003/09/30","Scott Adams",0740721909,4.95
"2004/10/04","Benjamin Radcliff",0804818088,4.95
"2004/10/04","Randel Helms",0879755725,4.50'
,DEFAULT
,DEFAULT
,DEFAULT
,DEFAULT

*/
CREATE PROC	dbo.CSVToTable
			@CSV NVARCHAR(MAX) 
			,@firstRowHeadings int = 1 
			,@Delimiter char(1) = ',' 
			,@LineTerminator char(1) = NULL
			,@DoRowOrderColumn int = 0
AS
DECLARE	
		@MyHierarchy Hierarchy
		,@Command nvarchar(2000)

INSERT	@MyHierarchy 
SELECT	* 
FROM	dbo.ParseCSV(@CSV, @firstRowHeadings, @Delimiter, @LineTerminator)

IF @DoRowOrderColumn = 0
	SELECT @command = 
	'
		SELECT ' +	STUFF
					(
						(
							SELECT line 
							FROM
							(
								SELECT	DISTINCT 
										',MAX( 
											CASE
												WHEN sequenceNo = ' + CONVERT(varchar(10), sequenceNo) + ' 
												THEN StringValue 
												ELSE '''' 
												END) AS [' + [name] + ']' 
								FROM	@MyHierarchy  
								WHERE	[Object_ID] IS NULL 
								
								UNION ALL
								
								SELECT	'
										FROM	@TheHierarchy 
										WHERE	[Object_ID] IS NULL
										GROUP BY parent_ID 
										ORDER BY parent_ID' 
							) AS f(line)
							FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)')
						,1
						,1
						,''
					)
ELSE
	SELECT @command = 
	(
		SELECT	line + '
		' 
		FROM
		(
			SELECT 'SELECT Parent_ID AS [Row]' 
			
			UNION ALL
  
			SELECT	DISTINCT
					',MAX( 
						CASE
							WHEN sequenceNo = ' + CONVERT(varchar(10), sequenceNo) + ' 
							THEN StringValue 
							ELSE '''' 
						END) AS [' + [name] + ']' 
			FROM	@MyHierarchy 
			WHERE	[Object_ID] IS NULL 
			
			UNION ALL

			SELECT	'
			FROM	@TheHierarchy 
			WHERE	[Object_ID] IS NULL
			GROUP BY Parent_ID 
			ORDER BY Parent_ID' 
		) AS f(line)
		FOR XML PATH(''), TYPE
	).value('.', 'varchar(max)')

EXEC	sp_executesql 
		@Command
		,N'@TheHierarchy hierarchy READONLY'
		,@TheHierarchy = @MyHierarchy
