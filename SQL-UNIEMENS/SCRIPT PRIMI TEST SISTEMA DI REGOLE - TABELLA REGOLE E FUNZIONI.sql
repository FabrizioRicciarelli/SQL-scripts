--CREATE TABLE	dbo.XQUERY_RULES
--				(
--					IDXQuery int IDENTITY(1,1) PRIMARY KEY CLUSTERED NOT NULL
--					,IDGroup int NULL
--					,Descrizione varchar(50) NOT NULL
--					,XQueryPattern varchar(MAX) NOT NULL
--					,XQueryResultDataType varchar(MAX) NOT NULL
--				)
--INSERT XQUERY_RULES(Descrizione, XQueryPattern, XQueryResultDataType) 
--VALUES
--('ImportoRetribuzionePerCodiceRetribuzioneRN','(//ImportoRetribuzione[../CodiceRetribuzione = ''RN''])[1]', 'decimal(18,2)'), 
--('ContributoNormalePerCodiceRetribuzioneRN','(//Normale[../../CodiceRetribuzione = ''RN''])[1]','decimal(18,2)')
--GO

/*
SELECT dbo.fnGetXQueryPattern(1, NULL) AS XQueryPattern
SELECT dbo.fnGetXQueryPattern(NULL, 'ImportoRetribuzionePerCodiceRetribuzioneRN') AS XQueryPattern
SELECT dbo.fnGetXQueryPattern(2, NULL) AS XQueryPattern
SELECT dbo.fnGetXQueryPattern(NULL, 'ContributoNormalePerCodiceRetribuzioneRN') AS XQueryPattern
*/
ALTER FUNCTION dbo.fnGetXQueryPattern(@IDXQuery int=NULL, @Descrizione varchar(50)=NULL)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @RETVAL varchar(MAX) = NULL

	IF ISNULL(@IDXQuery,0) != 0
	OR ISNULL(@Descrizione,'') != ''
		BEGIN
			SELECT	@RETVAL = XQueryPattern
			FROM	XQUERY_RULES WITH(NOLOCK)
			WHERE	(IDXQuery = @IDXQuery OR @IDXQuery IS NULL)
			AND		(Descrizione = @Descrizione OR @Descrizione IS NULL)
		END

	RETURN @RETVAL
END
GO

/*
SELECT * FROM dbo.fnGetXQueryPatterns(1)
*/
CREATE FUNCTION dbo.fnGetXQueryPatterns(@IDGroup int=NULL)
RETURNS	@PATTERNS TABLE
		(
			IDXQuery int
			,Descrizione varchar(50)
			,XQueryPattern varchar(MAX)
		)
AS
BEGIN
	IF ISNULL(@IDGroup,0) != 0
		BEGIN
			INSERT	@PATTERNS
					(
						IDXQuery
						,Descrizione
						,XQueryPattern
					)
			SELECT	
					IDXQuery
					,Descrizione
					,XQueryPattern
			FROM	XQUERY_RULES WITH(NOLOCK)
			WHERE	IDGroup = @IDGroup
		END

	RETURN
END
GO

/*
SELECT dbo.fnGetXQueryResultDataType(1, NULL) AS XQueryResultDataType
SELECT dbo.fnGetXQueryResultDataType(NULL, 'ImportoRetribuzionePerCodiceRetribuzioneRN') AS XQueryResultDataType
SELECT dbo.fnGetXQueryResultDataType(2, NULL) AS XQueryResultDataType
SELECT dbo.fnGetXQueryResultDataType(NULL, 'ContributoNormalePerCodiceRetribuzioneRN') AS XQueryResultDataType
*/
ALTER FUNCTION dbo.fnGetXQueryResultDataType(@IDXQuery int=NULL, @Descrizione varchar(50)=NULL)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @RETVAL varchar(MAX) = NULL

	IF ISNULL(@IDXQuery,0) != 0
	OR ISNULL(@Descrizione,'') != ''
		BEGIN
			SELECT	@RETVAL = XQueryResultDataType
			FROM	XQUERY_RULES WITH(NOLOCK)
			WHERE	(IDXQuery = @IDXQuery OR @IDXQuery IS NULL)
			AND		(Descrizione = @Descrizione OR @Descrizione IS NULL)
		END

	RETURN @RETVAL
END
GO

/*
SELECT * FROM dbo.fnGetXQueryResultDataTypes(1)
*/
CREATE FUNCTION dbo.fnGetXQueryResultDataTypes(@IDGroup int=NULL)
RETURNS	@PATTERNS TABLE
		(
			IDXQuery int
			,Descrizione varchar(50)
			,XQueryResultDataType varchar(MAX)
		)
AS
BEGIN
	IF ISNULL(@IDGroup,0) != 0
		BEGIN
			INSERT	@PATTERNS
					(
						IDXQuery
						,Descrizione
						,XQueryResultDataType
					)
			SELECT	
					IDXQuery
					,Descrizione
					,XQueryResultDataType
			FROM	XQUERY_RULES WITH(NOLOCK)
			WHERE	IDGroup = @IDGroup
		END

	RETURN
END
GO

/*
SELECT * FROM dbo.fnGetXQueryResults(NULL, 1, NULL)
SELECT * FROM dbo.fnGetXQueryResults(NULL, NULL, 'ImportoRetribuzionePerCodiceRetribuzioneRN')
SELECT * FROM dbo.fnGetXQueryResults(NULL, 2, NULL)
SELECT * FROM dbo.fnGetXQueryResults(NULL, NULL, 'ContributoNormalePerCodiceRetribuzioneRN')
SELECT * FROM dbo.fnGetXQueryResults(1, NULL, NULL)
*/
ALTER FUNCTION dbo.fnGetXQueryResults(@IDGroup int=NULL, @IDXQuery int=NULL, @Descrizione varchar(50)=NULL)
RETURNS @XQueryResults TABLE
		(
			IDXQuery int
			,IDGroup int
			,Descrizione varchar(50)
			,XQueryPattern varchar(MAX)
			,XQueryResultDataType varchar(MAX)
		)
AS
BEGIN
	DECLARE @RETVAL varchar(MAX) = NULL

	IF ISNULL(@IDGroup,0) != 0
	OR ISNULL(@IDXQuery,0) != 0
	OR ISNULL(@Descrizione,'') != ''
		BEGIN
			IF ISNULL(@IDGroup,0) != 0
				BEGIN
					INSERT	@XQueryResults
							(
								IDXQuery
								,IDGroup
								,Descrizione
								,XQueryPattern
								,XQueryResultDataType
							)
					SELECT	
							IDXQuery
							,IDGroup
							,Descrizione
							,XQueryPattern
							,XQueryResultDataType
					FROM	XQUERY_RULES WITH(NOLOCK)
					WHERE	(IDGroup = @IDGroup)
				END
			ELSE
				BEGIN
					INSERT	@XQueryResults
							(
								IDXQuery
								,IDGroup
								,Descrizione
								,XQueryPattern
								,XQueryResultDataType
							)
					SELECT	
							IDXQuery
							,IDGroup
							,Descrizione
							,XQueryPattern
							,XQueryResultDataType
					FROM	XQUERY_RULES WITH(NOLOCK)
					WHERE	(IDXQuery = @IDXQuery OR @IDXQuery IS NULL)
					AND		(Descrizione = @Descrizione OR @Descrizione IS NULL)
				END
		END

	RETURN
END
GO

