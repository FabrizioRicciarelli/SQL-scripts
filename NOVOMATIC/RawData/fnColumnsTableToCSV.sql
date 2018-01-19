/*
Funzione che trasforma un UDTT (User Defined Table Type) di tipo COLUMNS_TYPE in una lista
di nomi di colonna separati da virgole (con o senza il tipo di dato annesso)

-- Esempi di invocazione

DECLARE @Columns COLUMNS_TYPE
INSERT	@Columns
EXEC	dbo.GetRemoteColumns
		'GMATICA_AGS_RawData'
		,'RawData'
		,NULL

SELECT dbo.fnColumnsTableToCSV(@columns, NULL) AS fieldsList
SELECT dbo.fnColumnsTableToCSV(@columns, 1) AS fieldsList
*/
ALTER FUNCTION dbo.fnColumnsTableToCSV(@columns COLUMNS_TYPE READONLY, @withDataType bit = NULL)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @RETVAL varchar(MAX) = NULL

	IF EXISTS(SELECT TOP 1 ColName FROM @columns)
		BEGIN
			SELECT	@RETVAL = COALESCE(@RETVAL,'') +
					CASE ISNULL(@withDataType,0)
						WHEN	0 
						THEN	ColName
						ELSE	ColName + 
								' ' + 
								ColDatatype +
								CASE 
									WHEN	ColDatatype IN('char','varchar','nchar','nvarchar')
									THEN	'(' +
											CASE 
												WHEN	ColLength = -1
												THEN	'MAX'
												ELSE	CAST(ColLength AS varchar(10))
											END +
											')'
									WHEN	ColDatatype IN('decimal','numeric')
									THEN	'(' + 
											CAST(ColScale AS varchar(2)) + 
											',' + 
											CAST(ColPrecision AS varchar(2)) + 
											')'
									WHEN	ColDatatype IN('datetime2')
									AND		ColScale != 0 
									THEN	'(' +
											CAST(ColScale AS varchar(2)) +
											')'
									ELSE	''
								END
						END +
						','
			FROM	@Columns

			SELECT	@RETVAL =
					CASE
						WHEN RIGHT(@RETVAL,1) = ',' 
						THEN LEFT(@RETVAL, LEN(@RETVAL) - 1)
						ELSE @RETVAL
					END
		END
	RETURN @RETVAL
END