IF OBJECT_ID (N'dbo.ParseJSON') IS NOT NULL     
DROP FUNCTION dbo.ParseJSON
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
