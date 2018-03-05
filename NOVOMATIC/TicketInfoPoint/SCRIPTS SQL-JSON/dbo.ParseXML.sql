IF OBJECT_ID (N'dbo.ParseXML') IS NOT NULL
   DROP FUNCTION dbo.ParseXML
GO
/*
---------------------------
dbo.ParseXML
--------------------------

Function which returns a hierarchy table given an XML document

-- SAMPLE USAGE:

-- SAMPLE #1
-------------
DECLARE	
		@XMLSample XML

SELECT	@XMLSample =
'
<root>
	<CSV>
		<item Year="1997" Make="Ford" Model="E350" Description="ac, abs, moon" Price="3000.00" />
		<item Year="1999" Make="Chevy" Model="Venture &quot;Extended Edition&quot;" Description="" Price="4900.00" />
		<item Year="1999" Make="Chevy" Model="Venture &quot;Extended Edition, Very Large&quot;" Description="" Price="5000.00" />
		<item Year="1996" Make="Jeep" Model="Grand Cherokee" Description="MUST SELL! air, moon roof, loaded" Price="4799.00" />
	</CSV>
</root>
'

SELECT	* 
FROM	dbo.ParseXML(@XMLSample)


-- SAMPLE #2
-------------
DECLARE	@MyHierarchy Hierarchy
INSERT	@myHierarchy
SELECT	* 
FROM	dbo.ParseXML
		(
			(
				SELECT	* 
				FROM	adventureworks.person.contact 
				WHERE	contactID in (123,124,125) 
				FOR		XML path('contact'), root('contacts')
			)
		)
SELECT	dbo.ToJSON(@MyHierarchy)

-- SAMPLE #3
------------- 
DECLARE	
		@MyHierarchy Hierarchy
		,@XMLSample XML

SELECT	@XMLSample =
'
<root>
	<CSV>
		<item Year="1997" Make="Ford" Model="E350" Description="ac, abs, moon" Price="3000.00" />
		<item Year="1999" Make="Chevy" Model="Venture &quot;Extended Edition&quot;" Description="" Price="4900.00" />
		<item Year="1999" Make="Chevy" Model="Venture &quot;Extended Edition, Very Large&quot;" Description="" Price="5000.00" />
		<item Year="1996" Make="Jeep" Model="Grand Cherokee" Description="MUST SELL! air, moon roof, loaded" Price="4799.00" />
	</CSV>
</root>
'

INSERT	@myHierarchy
SELECT	* 
FROM	dbo.ParseXML(@XMLSample)

SELECT	* 
FROM	@myHierarchy

SELECT	dbo.ToJSON(@MyHierarchy)
*/
CREATE FUNCTION dbo.ParseXML( @XML_Result XML)
RETURNS @Hierarchy TABLE
 (
	element_id int PRIMARY KEY NOT NULL -- internal surrogate primary key gives the order of parsing and the list order
	,sequenceNo int NULL -- the place in the sequence for the element
	,parent_ID int -- if the element has a parent then it is in this column. The document is the ultimate parent, so you can get the structure from recursing from the document
	,[Object_ID] int -- each list or object has an object id. This ties all elements to a parent. Lists are treated as objects here
	,NAME nvarchar(2000) -- the name of the object, null if it hasn't got one
	,StringValue nvarchar(MAX) NOT NULL -- the string representation of the value of the element
	,ValueType varchar(10) NOT null -- the declared type of the value represented as a string in StringValue
 )
AS 
BEGIN
	DECLARE @Insertions TABLE
			(
				Element_ID int IDENTITY(1,1) PRIMARY KEY
				,SequenceNo int
				,TheLevel int
				,Parent_ID int
				,[Object_ID] int
				,[Name] varchar(50)
				,StringValue varchar(MAX)
				,ValueType varchar(10)
				,TheNextLevel XML
				,ThisLevel XML
			)
     
	 DECLARE
			@RowCount int
			,@ii int

	--get the base-level nodes into the table
	INSERT	@Insertions 
			(
				TheLevel
				, Parent_ID
				, [Object_ID]
				, [Name]
				, StringValue
				, SequenceNo
				, TheNextLevel
				, ThisLevel
			)
	SELECT   
			1 AS TheLevel
			,NULL AS Parent_ID
			,NULL AS [Object_ID]
			,FirstLevel.value('local-name(.)', 'varchar(255)') AS [Name] -- the name of the element
			,dbo.JSONEscaped(FirstLevel.value('text()[1]','varchar(max)')) AS StringValue -- its value as a string
			,ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS SequenceNo -- the 'child number' (simple number sequence here)
			,FirstLevel.query('*') -- the 'inner XML' of the current child  
			,FirstLevel.query('.')  -- the XML of the parent
	FROM	@XML_Result.nodes('/*') a(FirstLevel) -- get all nodes from the XML

	SELECT	@RowCount = @@RowCount -- we need this to work out if we are rendering an object or a list.
	
	SELECT @ii = 2
	
	WHILE @RowCount > 0 --while loop to avoid recursion.
		BEGIN
			INSERT	@Insertions 
					(
						TheLevel
						,Parent_ID
						,[Object_ID]
						,[Name]
						,StringValue
						,SequenceNo
						,TheNextLevel
						,ThisLevel
					)
			SELECT -- all the elements first
					@ii AS TheLevel -- (2 to the final level)
					,a.Element_ID AS Parent_ID -- the parent node
					,NULL AS [Object_ID] -- we'll do this later: the object ID is merely a surrogate key to distinguish each node
					,[then].value('local-name(.)', 'varchar(255)') AS [name] -- the name
					,dbo.JSONEscaped([then].value('text()[1]','varchar(max)')) AS StringValue -- the value
					,ROW_NUMBER() OVER(PARTITION BY a.Element_ID ORDER BY (SELECT 1)) AS SequenceNo -- the order in the sequence
					,[then].query('*') AS TheNextLevel -- the 'inner' XML for the node
					,[then].query('.') AS ThisLevel -- the XML from which this node was extracted
			FROM	@Insertions a
					CROSS apply 
					a.TheNextLevel.nodes('*') whatsNext([then])
			WHERE	a.TheLevel = @ii - 1 -- only look at the previous level
			
			UNION ALL -- to pick out the attributes of the preceding level
			
			SELECT
					@ii AS TheLevel
					,a.Element_ID AS Parent_ID -- the parent node
					,NULL AS [Object_ID] -- we'll do this later: the object ID is merely a surrogate key to distinguish each node
					,[then].value('local-name(.)', 'varchar(255)') AS [name] -- the name
					,dbo.JSONEscaped([then].value('.','varchar(max)')) AS StringValue -- the value
					,ROW_NUMBER() OVER(PARTITION BY a.Element_ID ORDER BY (SELECT 1)) AS SequenceNo -- the order in the sequence
					,'' AS TheNextLevel
					,'' AS ThisLevel -- no nodes 
			FROM   @Insertions a  
					CROSS apply 
					a.ThisLevel.nodes('/*/@*') whatsNext([then]) -- just find the attributes
			WHERE	a.TheLevel = @ii - 1 OPTION (RECOMPILE)

			SELECT	@RowCount = @@ROWCOUNT
			SELECT	@ii = @ii+1
		END;

	--roughly type the DataTypes (no XSD available here) 
	UPDATE	@Insertions 
	SET	
		[Object_ID] = 
		CASE 
			WHEN StringValue IS NULL 
			THEN Element_ID 
			ELSE NULL 
		END
		,ValueType = 
		CASE
			WHEN StringValue IS NULL 
			THEN 'object'
			WHEN LEN(StringValue) = 0 
			THEN 'string'
			WHEN StringValue LIKE '%[^0-9.-]%' 
			THEN 'string'
			WHEN StringValue LIKE '[0-9]' 
			THEN 'int'
			WHEN RIGHT(StringValue, LEN(StringValue)-1) LIKE'%[^0-9.]%' 
			THEN 'string'
			WHEN StringValue LIKE'%[0-9][.][0-9]%' 
			THEN 'real'
			WHEN StringValue LIKE '%[^0-9]%' 
			THEN 'string'
			ELSE 'int' 
		END

	-- and find the arrays
	UPDATE	@Insertions 
	SET		ValueType = 'array'
	WHERE	Element_ID IN
			(
				SELECT candidates.Parent_ID 
				FROM
				(
					SELECT
							Parent_ID
							,COUNT(*) AS SameName 
					FROM	@Insertions -- where they all have the same name (a sure sign)
					GROUP BY 
							[Name]
							,Parent_ID -- no lists in XML
					HAVING COUNT(*) > 1
				) AS candidates
				INNER JOIN  
				@Insertions insertions
				ON candidates.Parent_ID = insertions.Parent_ID
				GROUP BY candidates.Parent_ID 
				HAVING COUNT(*) = MIN(SameName)
			) 

	-- insert them into the hierarchy
	INSERT	@Hierarchy 
			(
				Element_ID
				,SequenceNo
				,Parent_ID
				,[Object_ID]
				,[Name]
				,StringValue
				,ValueType
			)
	SELECT 
			Element_ID
			,SequenceNo
			,Parent_ID
			,[Object_ID]
			,[Name]
			,COALESCE(StringValue, ''), ValueType
	FROM	@Insertions

	RETURN
END
GO
