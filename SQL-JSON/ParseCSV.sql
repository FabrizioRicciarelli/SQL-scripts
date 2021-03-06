IF OBJECT_ID (N'dbo.ParseCSV') IS NOT NULL     
DROP FUNCTION dbo.ParseCSV
GO
/*
---------------------------
dbo.ParseCSV
---------------------------

Function which parses a CSV file and transforms it in a hierarchical structure

-- SAMPLE #1
-------------
DECLARE 
		@Hierarchy Hierarchy
		,@CSV nvarchar(MAX)

SET @CSV =
'Year,Make,Model,Description,Price
1997,Ford,E350,"ac, abs, moon",3000.00
1999,Chevy,"Venture ""Extended Edition""","",4900.00
1999,Chevy,"Venture ""Extended Edition, Very Large""","",5000.00
1996,Jeep,Grand Cherokee,"MUST SELL! air, moon roof, loaded",4799.00'

INSERT	@Hierarchy
SELECT	* 
FROM	dbo.ParseCSV(@CSV, Default, Default, Default)

SELECT	*
FROM	@Hierarchy
WHERE	ValueType NOT IN('object','array')

SELECT	DISTINCT
		[NAME]
		,ValueType
		,MaxLenght =
		CASE ValueType
			WHEN 'String'
			THEN MAX(LEN(StringValue)) OVER()
			ELSE 0
		END
FROM	@Hierarchy
WHERE	ValueType NOT IN('object','array')
GO

-- SAMPLE #2
-------------
DECLARE
		@MyHierarchy Hierarchy
		,@XML XML
		,@CSV nvarchar(MAX)

SET @CSV =
'Year,Make,Model,Description,Price
1997,Ford,E350,"ac, abs, moon",3000.00
1999,Chevy,"Venture ""Extended Edition""","",4900.00
1999,Chevy,"Venture ""Extended Edition, Very Large""","",5000.00
1996,Jeep,Grand Cherokee,"MUST SELL! air, moon roof, loaded",4799.00'
SELECT	* 
FROM	dbo.ParseCSV(@CSV, Default, Default, Default)

INSERT	@myHierarchy
SELECT	* 
FROM	dbo.parseCSV(@CSV, Default, Default, Default)
--SELECT	ISJSON(dbo.ToJSON(@MyHierarchy)) -- ONLY SQLSERVER 2016+
SELECT	CAST(dbo.ToXML(@MyHierarchy) AS XML)

-- SAMPLE #3
-------------
DECLARE
		@MyHierarchy Hierarchy
		,@CSV nvarchar(MAX)

SET @CSV = '"REVIEW_DATE","AUTHOR","ISBN","DISCOUNTED_PRICE"
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

INSERT	@MyHierarchy
SELECT	* 
FROM	dbo.ParseCSV(@CSV, Default,Default,Default)

SELECT	*
FROM	@myHierarchy
SELECT	*
FROM	dbo.GetStructure(@MyHierarchy)

-- SELECT ISJSON(dbo.ToJSON(@MyHierarchy)) AS ValidJSON -- ONLY ON SQLSERVER 2016+
SELECT dbo.ToJSON(@MyHierarchy) AS JSONformat
SELECT CAST(dbo.ToXML(@MyHierarchy) AS XML) AS XMLformat

-- SAMPLE #4
-------------
DECLARE	
		@MyHierarchy Hierarchy
		,@Command NVarchar(2000)

INSERT	@MyHierarchy 
SELECT	* FROM dbo.ParseCSV('"Nom D''Employee";"Addresse";"Numero D''Employee"
"Jean Bonnehomme";"1234 rue Veritable";00001
"Marie Antoinette";"4321 rue Gateau";00002', Default, ';', Default)

SELECT	@command = 
		(
			SELECT line + '
			'FROM 
			(
					SELECT 'SELECT Parent_ID AS [Row]' 
					UNION ALL
					SELECT DISTINCT ',	MAX
										( 
										CASE 
											WHEN sequenceNo = ' + CONVERT(varchar(10), sequenceNo) + ' 
											THEN StringValue 
											ELSE '''' 
										END
										) AS [' + name + ']' 
					FROM	@MyHierarchy 
					WHERE	[Object_ID] IS NULL 
					UNION ALL
					SELECT 'FROM	@TheHierarchy WHERE [Object_ID] IS NULL
					GROUP BY Parent_ID 
					ORDER BY parent_ID' 
			) f(line)
			FOR XML PATH(''), TYPE
		).value('.', 'varchar(max)')

EXEC	sp_executesql @Command
		,N'@TheHierarchy hierarchy READONLY'
		,@TheHierarchy = @MyHierarchy

 */
CREATE FUNCTION	dbo.ParseCSV 
				( 
					@CSV NVARCHAR(MAX) 
					,@firstRowHeadings int = 1 
					,@Delimiter char(1) = ',' 
					,@LineTerminator char(1) = null
				 )
RETURNS @hierarchy TABLE
		(
			element_id int IDENTITY(1, 1) NOT NULL -- internal surrogate primary key gives the order of parsing and the list order
			,sequenceNo int NULL -- the place in the sequence for the element
			,parent_ID int -- if the element has a parent then it is in this column. The document is the ultimate parent, so you can get the structure from recursing from the document
			,[Object_ID] int -- each list or object has an object id. This ties all elements to a parent. Lists are treated as objects here
			,NAME nvarchar(2000) -- the name of the object, null if it hasn't got one
			,StringValue nvarchar(MAX) NULL -- the string representation of the value of the element
			,ValueType varchar(10) NOT null -- the declared type of the value represented as a string in StringValue
		)
  
AS
BEGIN
	IF @LineTerminator IS NULL 
		SELECT @LineTerminator = char(13)

	SET @CSV = REPLACE(@CSV, '""', '§§')

	DECLARE @UnwrappedString TABLE  
			(
				Position int primary key
				,[Character] char(1)
				,[STATE] varchar(8)
				,[COLUMN] int
				,[row] int
				,TheValue varchar(2000) DEFAULT ''
			)
	
	DECLARE @Values TABLE  
			(
				Value_ID int IDENTITY(1,1) PRIMARY KEY 
				,[COLUMN] int
				,[row] int
				,TheValue varchar(2000) DEFAULT ''
				,ValueType varchar(20)
			)

	DECLARE 
			@LastRow int
			,@FirstRow int
			,@State varchar(8)
			,@PreviousCharacter char(1)
			,@Column int
			,@Row int
			,@TheValue varchar(2000)

	SELECT
			@State = 'Col-end'
			,@PreviousCharacter = ' '
			,@COLUMN = 1
			,@Row = 1
			,@TheValue = ''

	INSERT	@UnwrappedString 
			(
				Position
				,[Character]
				,[state]
			)
	SELECT
			number AS Position
			,SUBSTRING(@CSV, number, 1) AS [Character]
			,'' AS [state]
	FROM	numbers 
	WHERE	number <= len(@CSV)
	
	UNION ALL
	
	SELECT 
			LEN(@CSV) + 1 AS Position
			,@LineTerminator AS [Character]
			,'Col-end' AS [state]

	UPDATE  @UnwrappedString /*Temp tables are always maxdop 1 and will be updated accordint to the primary key */
	SET		@State =
			[State] = /* adopt a state machine that changes as it examines each character */
			CASE  
				WHEN [Character] = @LineTerminator 
				AND @State <> 'in' 
				THEN 'Row-end'
				WHEN @State = 'Row-end' 
				THEN 'Col-end' 
				WHEN @State = 'in?' 
				THEN
					CASE 
						WHEN [Character] = '"' 
						THEN 'Escape?' 
						ELSE 'in' 
					END 
				WHEN @State = 'Escape?' 
				THEN
					CASE 
						WHEN [Character] = '"' 
						THEN 'in' 
						WHEN [Character] = @Delimiter 
						THEN 'Col-end' 
						ELSE 'out' 
					END 
				WHEN @State = 'Col-end' 
				THEN
					CASE 
						WHEN [Character] = '"' 
						THEN 'in?' 
						ELSE 'out' 
					END
				WHEN [Character] = '"' 
				THEN 
					CASE  
					WHEN @State = 'out?' 
					THEN 'in' 
					WHEN @State = 'out' 
					THEN 'in' 
					ELSE 'out?' 
				END
				WHEN [Character] = @Delimiter 
				AND @state='out' 
				THEN 'Col-end'
				WHEN @state = 'out?' 
				THEN 'Col-end'   
				ELSE @State 
			END
			,@Column = 
			[column]=
			CASE 
				WHEN @State = 'Col-end' 
				THEN @Column + 1 
				WHEN @state = 'Row-end' 
				THEN 0 
				ELSE @Column 
			END
			,@Row =
			[Row] = 
			CASE 
				WHEN @State = 'Row-end' 
				THEN @Row + 1 
				ELSE @Row 
			END
			,@TheValue =
			TheValue = 
			CASE 
				WHEN @State IN ('Col-end', 'Row-end') 
				THEN ''
				WHEN @State IN ('in', 'out') 
				THEN @TheValue + [Character]
				WHEN @State IN ('out?')  
				THEN @TheValue
				ELSE '' 
			END 
     
	INSERT	@Values
			(
				[COLUMN]
				,[row]
				,TheValue
				,ValueType
			)
	SELECT	
			PreviousOne.[column]
			,PreviousOne.[row]
			,PreviousOne.TheValue
			,CASE 
				WHEN PreviousOne.TheValue IN ('true', 'false') 
				THEN 'boolean'
				WHEN PreviousOne.TheValue = 'null' 
				THEN 'null'
				WHEN LEN(PreviousOne.TheValue) = 0 
				OR PATINDEX('%[^0-9,.]%', PreviousOne.TheValue COLLATE SQL_Latin1_General_CP850_Bin) > 0
				OR LEFT(PreviousOne.TheValue,1) = '0' 
				THEN 'String'
				WHEN PATINDEX('%[^0-9]%', PreviousOne.TheValue COLLATE SQL_Latin1_General_CP850_Bin) > 0 
				THEN 'real'
				ELSE 'int' 
			END
	FROM	@UnwrappedString firstOne
			LEFT OUTER JOIN 
			@UnwrappedString previousOne
			ON firstOne.position = PreviousOne.position + 1 
	WHERE	firstOne.[state] = 'Row-end' 
	OR		firstOne.state = 'Col-end'  
	AND		PreviousOne.[column] > 0 
	OPTION (RECOMPILE)

	IF @firstRowHeadings <> 0
		INSERT	@hierarchy 
				(
					Parent_ID
					,SequenceNo
					,[Object_ID]
					,[Name]
					,StringValue
					,ValueType
				)
		SELECT
				[Values].[Row] - 1 AS Parent_ID
				,[Values].[column] AS SequenceNo
				,NULL AS [Object_ID]
				,Attributes.TheValue AS [Name]
				,[Values].[TheValue] AS StringValue
				,[Values].[ValueType] AS ValueType
		FROM	@Values AS [Values]
				INNER JOIN 
				@Values AS attributes 
				ON [Values].[column] = [attributes].[column]
		WHERE   attributes.[row] = 1 
		AND		[Values].[ROW] > 1 
		OPTION (RECOMPILE)
	ELSE 
		INSERT	@hierarchy 
				(
					Parent_ID
					,SequenceNo
					,[Object_ID]
					,[Name]
					,StringValue
					,ValueType
				)
		SELECT   
				[Row] AS Parent_ID
				,[column] AS SequenceNo
				,NULL AS [Object_ID]
				,'Column' + CONVERT(varchar(5),[column]) AS [Name]
				,[TheValue] AS StringValue
				,[ValueType] AS ValueType
		FROM    @Values AS [Values]
		
		SELECT	
				@LastRow = MAX(parent_ID)
				,@FirstRow = MIN(Parent_ID)
		FROM	@hierarchy

		INSERT	@hierarchy 
				(
					Parent_ID
					,[Object_ID]
					,[Name]
					,StringValue
					,ValueType
				)
		SELECT	
				@LastRow + 1 AS Parent_ID
				,[Values].[Row] AS [Object_ID]
				,NULL AS [Name]
				,[Values].[Row] AS StringValue
				,'object' AS ValueType
		FROM	@Values AS [Values] 
		WHERE	[column] = 1 
		AND		([row] BETWEEN @FirstRow AND @LastRow)

		INSERT	@hierarchy 
				(
					Parent_ID
					,[Object_ID]
					,[Name]
					,StringValue
					,ValueType
				)
		SELECT	
				@LastRow + 2 AS Parent_ID
				,@LastRow + 1 AS [Object_ID]
				,'CSV' AS [Name]
				,@LastRow + 1 AS StringValue
				,'array' AS ValueType

		INSERT	@hierarchy 
				(
					Parent_ID
					,[Object_ID]
					,[Name]
					,StringValue
					,ValueType
				)
		SELECT	
				null AS Parent_ID
				,@LastRow + 2 AS [Object_ID]
				,'-' AS [Name]
				,'' AS StringValue
				,'object' AS ValueType    
	
	UPDATE	@hierarchy
	SET		StringValue = REPLACE(StringValue, '§§','""')
	UPDATE	@hierarchy
	SET		StringValue = 
			REPLACE(StringValue, '""""','')
			
	UPDATE	@hierarchy
	SET		StringValue = 
			CASE
				WHEN LEN(StringValue) = 2
				AND StringValue = '""'
				THEN 'null'
				ELSE StringValue
			END
		
	RETURN
END
