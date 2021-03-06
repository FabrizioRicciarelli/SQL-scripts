USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnCompareXML]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT dbo.fnCompareXML('<PIPPO></PIPPO>', '<PIPPO></PIPPO>')
SELECT dbo.fnCompareXML('<PIPPO></PIPPO>', '<PLUTO></PLUTO>')
*/
CREATE FUNCTION	[dbo].[fnCompareXML](@firstXML XML = NULL, @secondXML XML = NULL)
RETURNS BIT
AS
BEGIN
	DECLARE @RETVAL BIT = 0
		IF @firstXML IS NOT NULL
		AND @secondXML IS NOT NULL
			BEGIN
				SELECT @RETVAL = 
					CASE
						WHEN CONVERT(varchar(max),@firstXML) = CONVERT(varchar(max), @secondXML)
						THEN 1
						ELSE 0
					END
			END
	RETURN @RETVAL
END
GO
