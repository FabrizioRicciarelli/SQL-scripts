IF EXISTS 
(
	SELECT	* 
	FROM	sys.types 
	WHERE	name LIKE 'Hierarchy'
)
DROP TYPE dbo.Hierarchy
GO
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
