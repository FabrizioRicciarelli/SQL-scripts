IF OBJECT_ID (N'dbo.ToXML') IS NOT NULL
DROP FUNCTION dbo.ToXML
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
