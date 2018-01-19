/*
SELECT dbo.fnGetRawDataView(NULL, NULL)
SELECT dbo.fnGetRawDataView(NULL, 'MachineID = 78 AND ServerTime > ''@FromServerTime'' <= ''@FromServerTime''')
*/
ALTER FUNCTION	dbo.fnGetRawDataView(@CSVfieldsToReturn varchar(MAX) = NULL, @criteria varchar(MAX) = NULL)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE 
			@RETVAL varchar(MAX)
			,@DEF varchar(MAX)
			,@CSVvalues varchar(MAX)
			,@fieldList varchar(MAX)
			,@fieldListAndTypes varchar(MAX)
			--,@POS int

	DECLARE @instances TABLE(pos int)

	SELECT	
			@DEF = VIEW_DEFINITION
			,@fieldList =	COALESCE(@fieldList,'') + 
							COLUMN_NAME + 
							',' 
			,@fieldListAndTypes =	COALESCE(@fieldListAndTypes,'') + 
									COLUMN_NAME + ' ' +
									DATA_TYPE +
									CASE 
										WHEN DATA_TYPE IN ('char','varchar', 'nchar', 'nvarchar')
										THEN
											' (' +  
											CASE CHARACTER_MAXIMUM_LENGTH
												WHEN -1
												THEN 'MAX'
												ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS varchar(10))
											END +
											'),'
										ELSE ',' 
									END
	FROM	INFORMATION_SCHEMA.VIEWS V
			JOIN
			INFORMATION_SCHEMA.COLUMNS C 
			ON V.TABLE_SCHEMA = C.TABLE_SCHEMA
	AND		V.TABLE_NAME = V.TABLE_NAME 
	WHERE	V.TABLE_SCHEMA = 'TMP'
	AND		V.TABLE_NAME = 'RawData_View'
	ORDER BY ORDINAL_POSITION

	IF ISNULL(@fieldList,'') != ''
		BEGIN
			IF RIGHT(@fieldList,1) = ','
				BEGIN
					SET @fieldList = LEFT(@fieldList, LEN(@fieldList) -1)
					SET @fieldListAndTypes = LEFT(@fieldListAndTypes, LEN(@fieldListAndTypes) -1)
				END
		END

	--SELECT @CSVvalues = dbo.fnGetInstancesPositions(@DEF, '%POM-MON01%')
	SELECT @CSVvalues = dbo.fnGetInstancesPositions(@DEF, '%WHERE%')

	SET @RETVAL = @CSVvalues
	--SET @RETVAL = @DEF
	--SET @RETVAL = @fieldList
	--SET @RETVAL = @fieldListAndTypes
	RETURN @RETVAL
END
