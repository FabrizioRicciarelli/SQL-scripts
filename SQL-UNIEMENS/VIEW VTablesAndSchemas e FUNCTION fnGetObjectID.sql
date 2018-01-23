/*
SELECT	* FROM VTablesAndSchemas WHERE ObjectName = 'TAB_CONTR_031CM'
SELECT	* FROM VTablesAndSchemas WHERE FullObjectName = 'dbo.TAB_CONTR_031CM'
SELECT	* FROM VTablesAndSchemas WHERE FullObjectName = 'var.TAB_CONTR_031CM'
*/
ALTER VIEW dbo.VTablesAndSchemas
AS
SELECT	
		so.object_id AS ObjectID
		,so.name AS ObjectName
		,ss.name + '.' + so.name AS FullObjectName
		,so.type AS ObjectType
		,so.type_desc AS ObjectTypeDesc
		,so.create_date AS ObjectDateCreation
		,so.modify_date AS ObjectDateLastModified
		,ss.schema_id AS SchemaID
		,ss.name AS SchemaName
		,ss.principal_id AS SchemaPrincipalID
FROM	sys.objects so
		INNER JOIN
		sys.schemas ss
		ON so.schema_id = ss.schema_id

GO

/*
SELECT	dbo.fnGetObjectID('TAB_CONTR_031CM') AS ObjectID
SELECT	dbo.fnGetObjectID('dbo.TAB_CONTR_031CM') AS ObjectID
SELECT	dbo.fnGetObjectID('var.TAB_CONTR_031CM') AS ObjectID

SELECT	* 
FROM	VTablesAndSchemas 
WHERE	Objectid = dbo.fnGetObjectID('TAB_CONTR_031CM') -- di default, se non specificato nel nome, estrae l'oggetto il cui schema è "dbo"

SELECT	* 
FROM	VTablesAndSchemas 
WHERE	Objectid = dbo.fnGetObjectID('TAB_CONTR_031CM') -- risultato equivalente al precedente

SELECT	* 
FROM	VTablesAndSchemas 
WHERE	Objectid = dbo.fnGetObjectID('VAR.TAB_CONTR_031CM') -- stesso nome di tabella ma owner differente, quindi l'ID restituito differisce dai precedenti
*/
ALTER FUNCTION	dbo.fnGetObjectID(@ObjectName varchar(128)=NULL)
RETURNS	bigint
AS
BEGIN
	DECLARE 
			@RETVAL bigint = NULL
			,@schema varchar(128) = 'dbo'

	IF ISNULL(@ObjectName,'') != ''
		BEGIN
			IF @ObjectName LIKE '%.%'
				BEGIN
					SET @schema = LOWER(LEFT(@ObjectName, CHARINDEX('.', @ObjectName) - 1))
					SET @ObjectName = RIGHT(@ObjectName, LEN(@ObjectName) - CHARINDEX('.',@ObjectName))
				END

			SELECT	@RETVAL = ObjectID 
			FROM	VTablesAndSchemas 
			WHERE	ObjectName = @ObjectName
			AND		SchemaName = @schema
		END
	RETURN @RETVAL
END

