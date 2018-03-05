IF OBJECT_ID (N'dbo.FlattenedJSON') IS NOT NULL
   DROP FUNCTION dbo.FlattenedJSON
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