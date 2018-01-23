--------------------
-- CLEAN UP OBJECTS
--------------------
IF OBJECT_ID (N'dbo.XMLEscaped') IS NOT NULL     
DROP FUNCTION dbo.XMLEscaped
GO
IF OBJECT_ID (N'dbo.JSONEscaped') IS NOT NULL     
DROP FUNCTION dbo.JSONEscaped
GO
IF OBJECT_ID (N'dbo.ParseJSON') IS NOT NULL     
DROP FUNCTION dbo.ParseJSON
GO
IF OBJECT_ID (N'dbo.FlattenedJSON') IS NOT NULL
   DROP FUNCTION dbo.FlattenedJSON
GO
IF OBJECT_ID (N'dbo.ParseXML') IS NOT NULL
   DROP FUNCTION dbo.ParseXML
GO
IF OBJECT_ID (N'dbo.ToJSON') IS NOT NULL
DROP FUNCTION dbo.ToJSON
GO
IF OBJECT_ID (N'dbo.ToXML') IS NOT NULL
DROP FUNCTION dbo.ToXML
GO
IF EXISTS 
(
	SELECT	* 
	FROM	sys.types 
	WHERE	name LIKE 'Hierarchy'
)
DROP TYPE dbo.Hierarchy
GO
/*
------------------------------------
-- CREATE THE UTILITY TABLE Numbers
------------------------------------
IF OBJECT_ID (N'dbo.Numbers') IS NOT NULL     
DROP TABLE dbo.Numbers
GO

SELECT	TOP 100000000 IDENTITY(int,1,1) AS number -- One hundred million ROWS (it takes 2 mins and 45 seconds to be created)
INTO	dbo.Numbers
FROM	sys.columns s1
		CROSS JOIN sys.columns s2
		CROSS JOIN sys.columns s3

ALTER TABLE Numbers ADD CONSTRAINT PK_Numbers PRIMARY KEY CLUSTERED (number)

SELECT	COUNT(number)
FROM	numbers
*/

/*
---------------------------
dbo.Hierarchy
--------------------------

Hierarchy User Defined Table Type to store different source structures: used by many of the functions contained herein
*/
CREATE TYPE dbo.Hierarchy AS TABLE
(
	element_id int NOT NULL -- internal surrogate primary key gives the order of parsing and the list order
	,sequenceNo int NULL -- the place in the sequence for the element
	,parent_ID int -- if the element has a parent then it is in this column. The document is the ultimate parent, so you can get the structure from recursing from the document
	,[Object_ID] int -- each list or object has an object id. This ties all elements to a parent. Lists are treated as objects here
	,NAME nvarchar(2000) -- the name of the object, null if it hasn't got one
	,StringValue nvarchar(MAX) NULL -- the string representation of the value of the element
	,ValueType varchar(10) NOT null -- the declared type of the value represented as a string in StringValue
	
	PRIMARY KEY (element_id)
)
GO

/*
---------------------------
dbo.XMLEscaped
--------------------------

-- SAMPLE USAGE:

Function that takes a SQL String with all its clobber and outputs it as a sting with all the XML escape sequences in it

SELECT dbo.XMLEscaped('"""')

*/ 
CREATE FUNCTION dbo.XMLEscaped (@Unescaped NVARCHAR(MAX)) -- a string with maybe characters that will break json
RETURNS nvarchar(MAX)
AS
BEGIN
    DECLARE @return nvarchar(MAX)
    SELECT @return = 
    REPLACE(
        REPLACE(
            REPLACE(
	            REPLACE(
		            REPLACE(
			            REPLACE(@Unescaped,'&', '&amp;')
	                ,'<', '&lt;')
	          ,'>', '&gt;')
		   ,'\"', '&quot;')
        ,'"', '&quot;')
    ,'''', '&#39;')

	RETURN @return
END
GO


/*
---------------------------
dbo.JSONEscaped
--------------------------

Function that takes a SQL String with all its clobber and outputs it as a sting with all the JSON escape sequences in it

-- SAMPLE USAGE:

SELECT dbo.JSONEscaped('"""')

*/ 
CREATE FUNCTION dbo.JSONEscaped (@Unescaped NVARCHAR(MAX)) -- a string with maybe characters that will break json
RETURNS NVARCHAR(MAX)
AS 
BEGIN
	SELECT	@Unescaped = 
			REPLACE(@Unescaped, FROMString, TOString)
	FROM
	(
		SELECT
				'""' AS FROMString, '\"' AS TOString
				UNION ALL SELECT '"""', '\""'
				UNION ALL SELECT '\', '\\'
				UNION ALL SELECT '\\"', '\"'
				UNION ALL SELECT '/', '\/'
				UNION ALL SELECT  CHAR(08),'\b'
				UNION ALL SELECT  CHAR(12),'\f'
				UNION ALL SELECT  CHAR(10),'\n'
				UNION ALL SELECT  CHAR(13),'\r'
				UNION ALL SELECT  CHAR(09),'\t'
	) AS substitutions
	
	RETURN @Unescaped
END
GO

/*
---------------------------
dbo.ParseJSON
--------------------------

Function which parses a JSON structure and returns a hierarchical table structure

-- SAMPLE USAGE:

DECLARE @json varchar(MAX)
SET @json =
'
{    
	"Person": 
	{
		"firstName": "John",
		"lastName": "Smith",
		"age": 25,
		"Address": 
		{
			"streetAddress":"21 2nd Street",
			"city":"New York",
			"state":"NY",
			"postalCode":"10021"
		},
		"PhoneNumbers": 
		{
			"home":"212 555-1234",
			"fax":"646 555-4567"
		}
	}
}
'
SELECT	* 
FROM	dbo.ParseJSON(@json)
*/
CREATE FUNCTION dbo.ParseJSON(@JSON nvarchar(MAX))
RETURNS @hierarchy TABLE
		(
			element_id int IDENTITY(1, 1) NOT NULL -- internal surrogate primary key gives the order of parsing and the list order
			,sequenceNo int NULL -- the place in the sequence for the element
			,parent_ID int -- if the element has a parent then it is in this column. The document is the ultimate parent, so you can get the structure from recursing from the document
			,[Object_ID] int -- each list or object has an object id. This ties all elements to a parent. Lists are treated as objects here
			,NAME nvarchar(2000) -- the name of the object, null if it hasn't got one
			,StringValue nvarchar(MAX) NOT NULL -- the string representation of the value of the element
			,ValueType varchar(10) NOT null -- the declared type of the value represented as a string in StringValue
		)
AS
BEGIN
	/* 
	In this temporary table we keep all strings, even the names of the elements, since they are 'escaped' in a different way and may contain, unescaped, 
	brackets denoting objects or lists. 
	These are replaced in the JSON string by tokens representing the string 
	*/
	DECLARE @Strings TABLE
	(
		String_ID INT IDENTITY(1, 1),
		StringValue NVARCHAR(MAX)
	)

	DECLARE
			@FirstObject int -- the index of the first open bracket found in the JSON string
			,@OpenDelimiter int -- the index of the next open bracket found in the JSON string
			,@NextOpenDelimiter int -- the index of subsequent open bracket found in the JSON string
			,@NextCloseDelimiter int -- the index of subsequent close bracket found in the JSON string
			,@Type nvarchar(10) -- whether it denotes an object or an array
			,@NextCloseDelimiterChar char(1) -- either a '}' or a ']'
			,@Contents nvarchar(MAX) -- the unparsed contents of the bracketed expression
			,@Start int -- index of the start of the token that you are parsing
			,@end int -- index of the end of the token that you are parsing
			,@param int -- the parameter at the end of the next Object/Array token
			,@EndOfName int -- the index of the start of the parameter at end of Object/Array token
			,@token nvarchar(200) -- either a string or object
			,@value nvarchar(MAX) --  the value as a string
			,@SequenceNo int -- the sequence number within a list
			,@name nvarchar(200) -- the name as a string
			,@parent_ID int -- the next parent ID to allocate
			,@lenJSON int -- the current length of the JSON String
			,@characters NCHAR(36) -- used to convert hex to decimal
			,@result bigint -- the value of the hex symbol being parsed
			,@index smallint -- used for parsing the hex value
			,@Escape int -- the index of the next escape character
	    
	SELECT	
			@characters = '0123456789abcdefghijklmnopqrstuvwxyz' -- initialise the characters to convert hex to ascii
			,@SequenceNo = 0 -- set the sequence no. to something sensible
			,@parent_ID=0; -- firstly we process all strings. This is done because [{} and ] aren't escaped in strings, which complicates an iterative parse

	WHILE 1 = 1 --forever until there is nothing more to do
	BEGIN
		SELECT @start = PATINDEX('%[^a-zA-Z]["]%', @json COLLATE SQL_Latin1_General_CP850_Bin); --next delimited string
	    IF @start = 0 BREAK -- no more so drop through the WHILE loop
		
		IF SUBSTRING(@json, @start + 1, 1) = '"' 
		BEGIN -- Delimited Name
			SET @start=@Start+1;
			SET @end=PATINDEX('%[^\]["]%', RIGHT(@json, LEN(@json+'|')-@start) collate SQL_Latin1_General_CP850_Bin);
		END
	     
		IF @end = 0 BREAK --no end delimiter to last string

	    SELECT @token = SUBSTRING(@json, @start + 1, @end - 1)
	    
		-- put in the escaped control characters
		SELECT @token = dbo.JSONEscaped(@token)
		
		SELECT 
				@result = 0
				,@escape = 1

		--Begin to take out any hex escape codes
		WHILE @escape > 0
			BEGIN
				SELECT 
						@index = 0
						,@escape = PATINDEX('%\x[0-9a-f][0-9a-f][0-9a-f][0-9a-f]%', @token COLLATE SQL_Latin1_General_CP850_Bin) -- find the next hex escape sequence
				IF @escape > 0 --if there is one
	            BEGIN
					WHILE @index<4 --there are always four digits to a \x sequence   
						BEGIN
							SELECT @result = @result + POWER(16, @index) * (CHARINDEX(SUBSTRING(@token, @escape + 2 + 3 - @index, 1), @characters)-1), @index=@index+1 ;
						END
						-- and replace the hex sequence by its unicode value
						SELECT @token = STUFF(@token, @escape, 6, nchar(@result))
	            END
	        END
			-- store the string away 
			INSERT @Strings(StringValue) 
			SELECT @token
	      
			-- and replace the string with a token
			SELECT @JSON = STUFF(@json, @start, @end + 1,'@string' + CONVERT(nvarchar(5), @@identity))
	END

	-- all strings are now removed. Now we find the first leaf.  
	WHILE 1=1  --forever until there is nothing more to do
		BEGIN
			SELECT @parent_ID = @parent_ID + 1
			
			--find the first object or list by looking for the open bracket
			SELECT @FirstObject = PATINDEX('%[{[[]%', @json COLLATE SQL_Latin1_General_CP850_Bin) -- object or array
			IF @FirstObject = 0 BREAK
			
			IF (SUBSTRING(@json, @FirstObject, 1) = '{') 
				SELECT @NextCloseDelimiterChar = '}', @type='object'
			ELSE 
				SELECT @NextCloseDelimiterChar = ']', @type='array'
			
			SELECT @OpenDelimiter = @firstObject
	  
			WHILE 1=1 --find the innermost object or list...
				BEGIN
					SELECT @lenJSON = LEN(@JSON + '|') - 1
					
					--find the matching close-delimiter proceeding after the open-delimiter
					SELECT @NextCloseDelimiter = CHARINDEX(@NextCloseDelimiterChar, @json, @OpenDelimiter + 1)
					
					-- is there an intervening open-delimiter of either type
					SELECT @NextOpenDelimiter = PATINDEX('%[{[[]%', RIGHT(@json, @lenJSON - @OpenDelimiter) COLLATE SQL_Latin1_General_CP850_Bin) -- object
					IF @NextOpenDelimiter = 0 BREAK
	      
					SELECT @NextOpenDelimiter = @NextOpenDelimiter + @OpenDelimiter
					IF @NextCloseDelimiter < @NextOpenDelimiter BREAK
	      
					IF SUBSTRING(@json, @NextOpenDelimiter, 1) = '{' 
						SELECT @NextCloseDelimiterChar = '}', @type = 'object'
					ELSE 
						SELECT @NextCloseDelimiterChar = ']', @type='array'
	      
					SELECT @OpenDelimiter=@NextOpenDelimiter
				END

				-- parse out the list or name/value pairs
				SELECT @contents = SUBSTRING(@json, @OpenDelimiter + 1, @NextCloseDelimiter - @OpenDelimiter - 1)
				SELECT @JSON = STUFF(@json, @OpenDelimiter, @NextCloseDelimiter  -@OpenDelimiter + 1, '@' + @type + CONVERT(nvarchar(5), @parent_ID))

				WHILE (PATINDEX('%[A-Za-z0-9@+.e]%', @contents COLLATE SQL_Latin1_General_CP850_Bin)) <> 0 
					BEGIN
						IF @Type='Object' --it will be a 0-n list containing a string followed by a string, number,boolean, or null
							BEGIN
								SELECT 
										@SequenceNo = 0
										,@end = CHARINDEX(':', ' ' + @contents) --if there is anything, it will be a string-based name.
								SELECT  @start = PATINDEX('%[^A-Za-z@][@]%', ' ' + @contents COLLATE SQL_Latin1_General_CP850_Bin)
								SELECT	
										@token = SUBSTRING(' ' + @contents, @start + 1, @End - @Start -1 )
										,@endofname = PATINDEX('%[0-9]%', @token COLLATE SQL_Latin1_General_CP850_Bin)
										,@param = RIGHT(@token, LEN(@token) - @endofname + 1)
								SELECT
										@token = LEFT(@token, @endofname  -1)
										,@Contents = RIGHT(' ' + @contents, LEN(' ' + @contents + '|') - @end - 1)
								
								SELECT  @name = stringvalue 
								FROM	@strings
								WHERE	string_id  =@param --fetch the name
							END
						ELSE 
							SELECT 
									@Name = null
									,@SequenceNo = @SequenceNo + 1 
							SELECT	@end = CHARINDEX(',', @contents) -- a string-token, object-token, list-token, number,boolean, or null
							
							IF @end = 0 
								SELECT  @end = PATINDEX('%[A-Za-z0-9@+.e][^A-Za-z0-9@+.e]%', @Contents + ' ' COLLATE SQL_Latin1_General_CP850_Bin) + 1
							
							SELECT	@start = PATINDEX('%[^A-Za-z0-9@+.e][A-Za-z0-9@+.e]%', ' ' + @contents COLLATE SQL_Latin1_General_CP850_Bin)
							SELECT
									@Value = RTRIM(SUBSTRING(@contents, @start, @End - @Start))
									,@Contents = RIGHT(@contents + ' ', LEN(@contents + '|') - @end)

							IF SUBSTRING(@value, 1, 7) = '@object' 
								INSERT	@hierarchy(NAME, SequenceNo, parent_ID, StringValue, Object_ID, ValueType)
								SELECT	@name, @SequenceNo, @parent_ID, SUBSTRING(@value, 8, 5), SUBSTRING(@value, 8, 5), 'object' 
							ELSE 
								IF SUBSTRING(@value, 1, 6) = '@array' 
									INSERT	@hierarchy(NAME, SequenceNo, parent_ID, StringValue, Object_ID, ValueType)
									SELECT	@name, @SequenceNo, @parent_ID, SUBSTRING(@value, 7, 5), SUBSTRING(@value, 7, 5), 'array' 
								ELSE 
									IF SUBSTRING(@value, 1, 7)='@string' 
										INSERT	@hierarchy(NAME, SequenceNo, parent_ID, StringValue, ValueType)
										SELECT	@name, @SequenceNo, @parent_ID, stringvalue, 'string'
										FROM	@strings
										WHERE	string_id=SUBSTRING(@value, 8, 5)
									ELSE 
										IF @value IN ('true', 'false') 
											INSERT	@hierarchy(NAME, SequenceNo, parent_ID, StringValue, ValueType)
											SELECT	@name, @SequenceNo, @parent_ID, @value, 'boolean'
										ELSE
											IF @value='null' 
												INSERT	@hierarchy(NAME, SequenceNo, parent_ID, StringValue, ValueType)
												SELECT	@name, @SequenceNo, @parent_ID, @value, 'null'
											ELSE
												IF PATINDEX('%[^0-9]%', @value COLLATE SQL_Latin1_General_CP850_Bin) > 0 
													INSERT	@hierarchy(NAME, SequenceNo, parent_ID, StringValue, ValueType)
													SELECT	@name, @SequenceNo, @parent_ID, @value, 'real'
												ELSE
													INSERT	@hierarchy(NAME, SequenceNo, parent_ID, StringValue, ValueType)
													SELECT @name, @SequenceNo, @parent_ID, @value, 'int'
													
													IF @Contents = ' ' 
														SELECT @SequenceNo=0
					END
		END
	
	INSERT @hierarchy (NAME, SequenceNo, parent_ID, StringValue, Object_ID, ValueType)
	SELECT '-',1, NULL, '', @parent_id-1, @type
	--
	
	RETURN
END
GO

/*
---------------------------
dbo.ToJSON
--------------------------

Function that takes a JSON hierarchy and converts it to a JSON string

-- SAMPLE USAGE:

DECLARE 
		@MyHierarchy Hierarchy -- to pass the hierarchy table around
		,@XMLSample XML

SELECT	@XMLSample =
'
<glossary>
	<title>example glossary</title>
	<GlossDiv>
		<title>S</title>
		<GlossList>
			<GlossEntry id="SGML" SortAs="SGML">
				<GlossTerm>Standard ""Generalized"" Markup Language</GlossTerm>
				<Acronym>SGML</Acronym>
				<Abbrev>ISO 8879:1986</Abbrev>
				<GlossDef>
					<para>A meta-markup language, used to create markup languages such as DocBook.</para>
					<GlossSeeAlso OtherTerm="GML" />
					<GlossSeeAlso OtherTerm="XML" />
				</GlossDef>
				<GlossSee OtherTerm="markup" />
			</GlossEntry>
		</GlossList>
	</GlossDiv>
</glossary>'
	 
INSERT	@MyHierarchy 
SELECT	*
FROM	dbo.ParseXML(@XMLSample)

SELECT	dbo.ToJSON(@MyHierarchy)
*/
CREATE FUNCTION dbo.ToJSON(@Hierarchy Hierarchy READONLY)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE
			@JSON NVARCHAR(MAX),
			@NewJSON NVARCHAR(MAX),
			@Where INT,
			@ANumber INT,
			@notNumber INT,
			@indent INT,
			@ii int,
			@CrLf CHAR(2)
	      
	-- Get the root token into place 
	SELECT
			@CrLf = CHAR(13) + CHAR(10) --just CHAR(10) in UNIX
			,@JSON = 
				CASE ValueType 
					WHEN 'array' 
					THEN + COALESCE('{'+@CrLf+'  "' + NAME + '" : ','') + '[' 
					ELSE '{' 
				END
			+ @CrLf
			+ CASE 
				WHEN ValueType = 'array' 
				AND NAME IS NOT NULL 
				THEN '  ' 
				ELSE '' 
			END
			+ '@Object' + CONVERT(varchar(5), OBJECT_ID)
			+ @CrLf 
			+ CASE ValueType 
				WHEN 'array' 
				THEN
					CASE 
						WHEN NAME IS NULL 
						THEN ']' 
						ELSE '  ]' + @CrLf + '}' + @CrLf 
					END
				ELSE '}' 
			END
	FROM	@Hierarchy 
	WHERE	parent_id IS NULL 
	AND		valueType IN ('object','document','array') -- get the root element
	
	/*
	Iterate from the root token growing each branch and leaf in each iteration. 
	All values, or name/value pairs with a structure can be created in one SQL Statement
	*/
	SELECT	@ii = 1000
	
	WHILE @ii > 0
		BEGIN
			SELECT @where= PATINDEX('%[^[a-zA-Z0-9]@Object%', @json) -- find NEXT token
			IF @where = 0 BREAK
			
			/* Get the indent of the object found by looking backwards up the string */ 
			SET @indent = CHARINDEX(CHAR(10) + CHAR(13), REVERSE(LEFT(@json, @where)) + CHAR(10) + CHAR(13)) - 1
			SET @NotNumber = PATINDEX('%[^0-9]%', RIGHT(@json, LEN(@JSON+'|') - @Where - 8) + ' ') -- find NEXT token
			SET @NewJSON = NULL -- The structure in its JSON form
			SELECT  
					@NewJSON = COALESCE(@NewJSON + ',' + @CrLf + SPACE(@indent), '')
					+ CASE 
						WHEN parent.ValueType = 'array' 
						THEN '' 
						ELSE COALESCE('"' + TheRow.[NAME] + '" : ', '') 
					END
					+ CASE TheRow.valuetype
							WHEN 'array' 
							THEN '  [' + @CrLf + SPACE(@indent+2) + '@Object' + CONVERT(varchar(5), TheRow.[OBJECT_ID]) + @CrLf + SPACE(@indent + 2) + ']' 
							WHEN 'object' 
							THEN '  {' + @CrLf + SPACE(@indent +2) + '@Object' + CONVERT(varchar(5), TheRow.[OBJECT_ID]) + @CrLf + SPACE(@indent + 2) + '}'
							WHEN 'string' 
							--THEN '"' + dbo.JSONEscaped(TheRow.StringValue) + '"'
							THEN dbo.JSONEscaped('"' + TheRow.StringValue + '"')
							ELSE TheRow.StringValue
					END 
			FROM	@Hierarchy TheRow 
					INNER JOIN 
					@hierarchy Parent
					ON parent.element_ID = TheRow.parent_ID
			WHERE	TheRow.parent_id = SUBSTRING(@JSON, @where + 8, @Notnumber-1)
			/* 
			Basically, we just lookup the structure based on the ID that is appended to the @Object token. 
			Now we replace the token with the structure, maybe with more tokens in it.
			*/
			SELECT @JSON =STUFF(@JSON, @where + 1, 8 + @NotNumber - 1, @NewJSON), @ii = @ii-1
		END

	RETURN @JSON
END
GO

/*
---------------------------
dbo.ToXML
--------------------------

Converts a Hierarchy table in an XML document. 
This uses the same technique as the dbo.toJSON function, and uses the 'entities' form of XML syntax to give a compact rendering of the structure

-- SAMPLE USAGE:

DECLARE
		@MyHierarchy Hierarchy
		,@xml XML
		,@json nvarchar(MAX)

SET @json =
'
{
	"menu": 
	{
		"id": "file",
		"value": "File",
		"popup": 
		{
			"menuitem": 
			[
				{"value": "New", "onclick": "CreateNewDoc(\"astra\")"},
				{"value": "Open", "onclick": "OpenDoc()"},
				{"value": "Close", "onclick": "CloseDoc()"}
			]
		}
	}
}
'
SELECT	* 
FROM	dbo.ParseJSON(@json)

INSERT	@myHierarchy 
SELECT	* 
FROM	dbo.ParseJSON(@json)

SELECT dbo.ToXML(@MyHierarchy)
SELECT @XML = dbo.ToXML(@MyHierarchy)

SELECT @XML
*/
CREATE FUNCTION dbo.ToXML( @Hierarchy Hierarchy READONLY)
RETURNS nvarchar(MAX)
AS
BEGIN
	DECLARE
			@XMLAsString NVARCHAR(MAX)
			,@NewXML NVARCHAR(MAX)
			,@Entities NVARCHAR(MAX)
			,@Objects NVARCHAR(MAX)
			,@Name NVARCHAR(200)
			,@Where INT
			,@ANumber INT
			,@notNumber INT
			,@indent INT
			,@CrLf CHAR(2)
      
	-- get the root token into place 
	SELECT	
			@CrLf = CHAR(13) + CHAR(10)--just CHAR(10) in UNIX
			,@XMLasString ='<?xml version="1.0" ?>@Object' + CONVERT(varchar(5), [Object_ID]) + ''
	FROM	@hierarchy 
	WHERE	parent_id IS NULL 
	AND		valueType IN ('object','array') -- get the root element

	/* 
	Iterate from the root token growing each branch and leaf in each iteration. 
	All values, or name/value pairs within a structure can be created in one SQL Statement
	*/
	WHILE 1=1
		BEGIN
			SELECT @where = PATINDEX('%[^a-zA-Z0-9]@Object%', @XMLAsString) -- find NEXT token
			IF @where = 0 BREAK
			
			/* Get the indent of the object we've found by looking backwards up the string */ 
			SET @indent = CHARINDEX(char(10) + char(13), REVERSE(LEFT(@XMLasString ,@where)) + char(10) + char(13)) -1
			SET @NotNumber = PATINDEX('%[^0-9]%', RIGHT(@XMLasString, LEN(@XMLAsString + '|') - @Where - 8) + ' ') -- find NEXT token
			SET @Entities  =NULL -- this contains the structure in its XML form
			
			SELECT	@Entities = 
					COALESCE(@Entities + ' ',' ') + NAME 
					+ '="'
					--+ REPLACE(REPLACE(REPLACE(dbo.JSONEscaped(StringValue), '<', '&lt;'), '&', '&amp;'), '>', '&gt;')
					+ dbo.XMLEscaped(StringValue)
					+ '"'  
			FROM	@hierarchy 
			WHERE	parent_id = SUBSTRING(@XMLasString, @where + 8, @Notnumber - 1) 
			AND		ValueType NOT IN ('array', 'object')
			
			SELECT	@Entities =
					COALESCE(@entities,'')
					,@Objects = '',
					@name = 
					CASE 
						WHEN Name='-' 
						THEN 'root' 
						ELSE NAME 
					END
			FROM	@hierarchy 
			WHERE	[Object_id] = SUBSTRING(@XMLasString, @where + 8, @Notnumber - 1) 
    
			SELECT	@Objects = @Objects + @CrLf + SPACE(@indent+2) + '@Object' + CONVERT(varchar(5), [Object_ID])
			FROM	@hierarchy 
			WHERE	parent_id = SUBSTRING(@XMLasString, @where + 8, @Notnumber - 1) 
			AND		ValueType IN ('array', 'object')
			
			IF @Objects = '' --if it is a lef, we can do a more compact rendering
				SELECT @NewXML = '<' + COALESCE(@name, 'item') + @entities + ' />'
			ELSE
				SELECT @NewXML = '<' + COALESCE(@name, 'item') + @entities + '>' + @Objects + @CrLf + SPACE(@indent) + '</'+COALESCE(@name, 'item') + '>'
			
			-- lookup the structure based on the ID that is appended to the @Object token
			-- replace the token with the structure, maybe with more tokens in it
			SELECT @XMLasString = STUFF(@XMLasString, @where + 1, 8 + @NotNumber - 1, @NewXML)
		END
		
		RETURN @XMLasString
END
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

/*
---------------------------
dbo.FlattenedJSON
--------------------------

Function which compacts a JSON structure in a flattened fashion

-- SAMPLE USAGE:
DECLARE 
		@XMLSample XML

SELECT	@XMLSample =
'
<root>
	<item>
		<Year>1997</Year> 
		<Make>Ford</Make>
		<Model>E350</Model>
		<Description>ac, abs, moon</Description>
		<Price>3000.00</Price> 
	</item>
	<item>
		<Year>1999</Year> 
		<Make>Chevy</Make>
		<Model>Venture Extended Edition</Model>
		<Description/>
		<Price>4900.00</Price>  
	</item>
	<item>
		<Year>1999</Year> 
		<Make>Chevy</Make>
		<Model>Venture Extended Edition, Very Large</Model>
		<Description/>
		<Price>5000.00</Price>  
	</item>
	<item>
		<Year>1996</Year> 
		<Make>Jeep</Make>
		<Model>Grand Cherokee</Model>
		<Description>MUST SELL! air, moon roof, loaded</Description>
		<Price>4799.00</Price> 
	</item>
</root>
'
SELECT dbo.FlattenedJSON(@XMLSample)

*/
CREATE FUNCTION dbo.FlattenedJSON (@XMLResult XML)
RETURNS nvarchar(MAX)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE  
			@JSONVersion nvarchar(MAX)
			,@Rowcount int

	SELECT	
			@JSONVersion = ''
			,@rowcount = COUNT(*) 
	FROM	@XMLResult.nodes('/root/*') x(a)

	SELECT	@JSONVersion = 
			@JSONVersion+
			STUFF
			(
				(
					SELECT	TheLine 
					FROM 
					(
						SELECT	
								',
								{' +
								STUFF
								(
									(
										SELECT	
												',"' + 
												COALESCE(b.c.value('local-name(.)', 'nvarchar(255)'), '') + '":"' +
												REPLACE
												( --escape tab properly within a value
													REPLACE
													( --escape return properly
														REPLACE
														( --linefeed must be escaped
															REPLACE
															( --backslash too
																REPLACE
																(
																	COALESCE(b.c.value('text()[1]','nvarchar(MAX)'), '')
																	, '\', '\\'
																) -- forwardslash  
																,'/'
																,'\/'
															)   
															,CHAR(10)
															,'\n'
														)   
														,CHAR(13)
														,'\r'
													)   
													,CHAR(09)
													,'\t'
												) +  
												'"'   
										FROM	x.a.nodes('*') b(c) 
										FOR		XML PATH(''),TYPE
									).value('(./text())[1]','NVARCHAR(MAX)')
									,1
									,1
									,''
								) +
								'}'
						FROM	@XMLResult.nodes('/root/*') x(a)
					) JSON(theLine)
			FOR XML PATH(''),TYPE).value('.','NVARCHAR(MAX)' 
			)
			,1
			,1
			,''
		)

	IF @Rowcount>1 
		RETURN '[' + @JSONVersion + '
		]'
	RETURN @JSONVersion
END