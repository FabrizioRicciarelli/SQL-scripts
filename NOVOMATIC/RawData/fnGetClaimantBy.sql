/*
 Funzione che ritorna il contenuto di una qualsiasi 
 delle colonne specificate (id, name, email, folder)
 utilizzando come criterio il contenuto di una delle
 altre colonne. 
 Il primo parametro "@what" specifica la colonna per
 la quale ritornare il valore mentre il secondo
 parametro "@criteria" stabilisce il criterio di filtro
 da utilizzare per selezionare quale valore ritornare.
 Per il primo parametro "@what" è possibile specificare
 il wildcard "*" che consentirà di ottenere i valori
 di tutte le colonne corrispondenti al criterio
 specificato dal secondo parametro "@criteria".

-----------------------
 Esempi di invocazione
-----------------------

-- è noto il valore della colonna "ID" (o "requestClaimantID", possono essere utilizzati alternativamente)
SELECT dbo.fnGetClaimantBy('*','id = 1') AS ALLFIELDS
SELECT dbo.fnGetClaimantBy('*','requestClaimantID = 1') AS ALLFIELDS
SELECT dbo.fnGetClaimantBy('name','id = 1') AS email
SELECT dbo.fnGetClaimantBy('email','id = 1') AS email
SELECT dbo.fnGetClaimantBy('FOLDER','id = 1') AS Folder

-- è noto il valore della colonna "name" (o "requestClaimantName", possono essere utilizzati alternativamente)
SELECT dbo.fnGetClaimantBy('*','name = Fabio De Stefani') AS ALLFIELDS
SELECT dbo.fnGetClaimantBy('*','requestClaimantName = Fabio De Stefani') AS ALLFIELDS
SELECT dbo.fnGetClaimantBy('id','name = Fabio De Stefani') AS id
SELECT dbo.fnGetClaimantBy('email','name = Fabio De Stefani') AS email
SELECT dbo.fnGetClaimantBy('folder','name = Fabio De Stefani') AS folder

-- è noto il valore della colonna "folder" (o "requestClaimantFolder", possono essere utilizzati alternativamente)
SELECT dbo.fnGetClaimantBy('*','folder = Gianpiero') AS ALLFIELDS
SELECT dbo.fnGetClaimantBy('*','requestClaimantFolder = Gianpiero') AS ALLFIELDS
SELECT dbo.fnGetClaimantBy('id','folder = Gianpiero') AS id
SELECT dbo.fnGetClaimantBy('name','folder = Gianpiero') AS name
SELECT dbo.fnGetClaimantBy('email','folder = Gianpiero') AS email

-- è noto il valore della colonna "email" (o "requestClaimantEmail", possono essere utilizzati alternativamente)
SELECT dbo.fnGetClaimantBy('*','email = a.borrelli@novomatic.it') AS ALLFIELDS
SELECT dbo.fnGetClaimantBy('*','requestClaimantEmail = a.borrelli@novomatic.it') AS ALLFIELDS
SELECT dbo.fnGetClaimantBy('id','email = a.borrelli@novomatic.it') AS id
SELECT dbo.fnGetClaimantBy('name','email = a.borrelli@novomatic.it') AS name
SELECT dbo.fnGetClaimantBy('folder','email = a.borrelli@novomatic.it') AS email

-- tabella completa per tests e verifiche
SELECT	*
FROM	[ETL].[requestClaimant]

-- prove
SELECT dbo.fnGetClaimantBy('*','id = 5') AS ALLFIELDS
SELECT dbo.fnGetClaimantBy('name','folder = Camera') AS name

*/
ALTER FUNCTION dbo.fnGetClaimantBy
				(
					@what varchar(20)
					,@criteria varchar(MAX)
				)
RETURNS varchar(1000)
AS
BEGIN
	DECLARE 
			@retVal varchar(1000)
			,@purgedCriteria varchar(1000) = LTRIM(RTRIM(SUBSTRING(@criteria, CHARINDEX('=',@criteria) + 1,LEN(@criteria))))

	SELECT	@retVal =
			CASE @what
				WHEN	'*'
				THEN	'requestClaimantId = ' + CAST(requestClaimantID AS varchar(100)) + 
						', requestClaimantName = ' + ISNULL(requestClaimantName,'') + 
						', requestClaimantEmail = ' + ISNULL(requestClaimantEmail,'') + 
						', requestClaimantFolder = ' + ISNULL(requestClaimantFolder,'')
				WHEN	'id'
				THEN	CAST(requestClaimantID AS varchar(1000))
				WHEN	'name'
				THEN	requestClaimantName
				WHEN	'email'
				THEN	requestClaimantEmail
				WHEN	'folder'
				THEN	requestClaimantFolder
			END
	FROM	[ETL].[requestClaimant]
	WHERE
			requestClaimantID =
			CASE
				WHEN @criteria LIKE 'requestClaimantID%' OR @criteria LIKE 'ID%'
				THEN CAST(@purgedCriteria AS smallint)
				ELSE requestClaimantID
			END
	AND
			requestClaimantName = 
			CASE
				WHEN @criteria LIKE 'requestClaimantName%' OR @criteria LIKE 'Name%'
				THEN @purgedCriteria
				ELSE requestClaimantName
			END
	AND
			requestClaimantEmail = 
			CASE
				WHEN @criteria LIKE 'requestClaimantEmail%' OR @criteria LIKE 'Email%'
				THEN @purgedCriteria
				ELSE requestClaimantEmail
			END
	AND
			requestClaimantFolder = 
			CASE
				WHEN @criteria LIKE 'requestClaimantFolder%' OR @criteria LIKE 'Folder%'
				THEN @purgedCriteria
				ELSE requestClaimantFolder
			END
	RETURN @retVal
END