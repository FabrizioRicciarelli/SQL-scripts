USE [GMATICA_AGS_RawData_Elaborate_Stag_Agile]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetInstancesPositions]    Script Date: 06/07/2017 17:39:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
DECLARE 
		@sentence varchar(MAX) = 'The first WORD is at position 11 and the second WORD is at position 49 the third WORD is at position 82 and the last WORD position is 118'
		,@SearchPatterntern varchar(20) = '%WORD%'

SELECT dbo.fnGetInstancesPositions(@sentence, @SearchPatterntern) AS Positions
*/
ALTER FUNCTION	[dbo].[fnGetInstancesPositions] 
				(
					@String varchar(max)
					,@SearchPattern varchar(max)
				)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE 
			@RETVAL varchar(MAX) = NULL
			,@CSVvalues varchar(MAX)
			,@POS int
			,@OLDpos int = 0

	DECLARE @instances TABLE(pos int)

	IF ISNULL(@String,'') != ''
	AND ISNULL(@SearchPattern,'') != ''
		BEGIN
			SELECT	@POS = PATINDEX(@SearchPattern, @String) 
	
			WHILE	@POS > 0 
			AND		@OLDpos != @POS
				BEGIN
					INSERT	@instances VALUES(@POS)
					SELECT	
							@OLDpos = @POS
							,@POS = PATINDEX(@SearchPattern, SUBSTRING(@String, @POS + 1, LEN(@String))) + @POS
					END

			SELECT	@RETVAL = 
					COALESCE(@RETVAL,'') + CAST(pos AS varchar(10)) + ','
			FROM	@instances

			SELECT	@RETVAL = LEFT(@RETVAL, LEN(@RETVAL)-1)
		END
	
	RETURN @RETVAL
END