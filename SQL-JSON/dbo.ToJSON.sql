IF OBJECT_ID (N'dbo.ToJSON') IS NOT NULL
DROP FUNCTION dbo.ToJSON
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
			SET @NotNumber = PATINDEX('%[^0-9]%', RIGHT(@json, LEN(@JSON + '|') - @Where - 8) + ' ') -- find NEXT token
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
