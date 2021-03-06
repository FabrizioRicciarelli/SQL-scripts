/*
SELECT * FROM dbo.fnGetXQueryResults(NULL, 1, NULL)
SELECT * FROM dbo.fnGetXQueryResults(NULL, NULL, 'ImportoRetribuzionePerCodiceRetribuzioneRN')
SELECT * FROM dbo.fnGetXQueryResults(NULL, 2, NULL)
SELECT * FROM dbo.fnGetXQueryResults(NULL, NULL, 'ContributoNormalePerCodiceRetribuzioneRN')
SELECT * FROM dbo.fnGetXQueryResults(1, NULL, NULL)
*/
ALTER FUNCTION [dbo].[fnGetXQueryResults](@IDGroup int=NULL, @IDXQuery int=NULL, @Descrizione varchar(50)=NULL)
RETURNS @XQueryResults TABLE
		(
			IDXQuery int NOT NULL,
			IDGroup int NULL,
			Descrizione varchar(255) NOT NULL,
			XQueryPattern varchar(max) NOT NULL,
			XQueryResultDataType varchar(max) NOT NULL,
			TableName varchar(128) NULL,
			XmlColumnName varchar(128) NULL,
			NodeNameA varchar(128) NULL,
			NodeNameB varchar(128) NULL,
			MatchValueAB varchar(128) NULL,
			NodeNameC varchar(128) NULL,
			NodeNameD varchar(128) NULL,
			MatchValueCD varchar(128) NULL,
			InternalNodeNameToMatch varchar(128) NULL,
			ExternalColumnNameToMatch varchar(128) NULL
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
								--IDXQuery
								--,IDGroup
								--,Descrizione
								--,XQueryPattern
								--,XQueryResultDataType
								IDXQuery
								,IDGroup
								,Descrizione
								,XQueryPattern
								,XQueryResultDataType
								,TableName
								,XmlColumnName
								,NodeNameA
								,NodeNameB
								,MatchValueAB
								,NodeNameC
								,NodeNameD
								,MatchValueCD
								,InternalNodeNameToMatch
								,ExternalColumnNameToMatch
							)
					SELECT	
							--IDXQuery
							--,IDGroup
							--,Descrizione
							--,XQueryPattern
							--,XQueryResultDataType
							IDXQuery
							,IDGroup
							,Descrizione
							,XQueryPattern
							,XQueryResultDataType
							,TableName
							,XmlColumnName
							,NodeNameA
							,NodeNameB
							,MatchValueAB
							,NodeNameC
							,NodeNameD
							,MatchValueCD
							,InternalNodeNameToMatch
							,ExternalColumnNameToMatch
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
								,TableName
								,XmlColumnName
								,NodeNameA
								,NodeNameB
								,MatchValueAB
								,NodeNameC
								,NodeNameD
								,MatchValueCD
								,InternalNodeNameToMatch
								,ExternalColumnNameToMatch
							)
					SELECT	
							IDXQuery
							,IDGroup
							,Descrizione
							,XQueryPattern
							,XQueryResultDataType
							,TableName
							,XmlColumnName
							,NodeNameA
							,NodeNameB
							,MatchValueAB
							,NodeNameC
							,NodeNameD
							,MatchValueCD
							,InternalNodeNameToMatch
							,ExternalColumnNameToMatch
					FROM	XQUERY_RULES WITH(NOLOCK)
					WHERE	(IDXQuery = @IDXQuery OR @IDXQuery IS NULL)
					AND		(Descrizione = @Descrizione OR @Descrizione IS NULL)
				END
		END

	RETURN
END
