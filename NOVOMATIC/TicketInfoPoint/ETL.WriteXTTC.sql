/*
DECLARE @XTTC XML -- VUOTO
SET	@XTTC = ETL.WriteXTTC(@XTTC, '391378593917118854', 0, 1234, 1233, 1)
SET	@XTTC = ETL.WriteXTTC(@XTTC, '391378593917118855', 1, 12345, 12344, 2)
SET	@XTTC = ETL.WriteXTTC(@XTTC, '391378593917118856', 0, 123456, 123455, 3)
SET	@XTTC = ETL.WriteXTTC(@XTTC, '391378593917118857', 1, 1234567, 1234566, 4)

SELECT * FROM ETL.GetXTTC(@XTTC, NULL, NULL, NULL, NULL, NULL, NULL)
SELECT * FROM ETL.GetXTTC(@XTTC, NULL, '391378593917118856', NULL, NULL, NULL, NULL)
SELECT * FROM ETL.GetXTTC(@XTTC, NULL, NULL, 1, NULL, NULL, NULL)
SELECT * FROM ETL.GetXTTC(@XTTC, NULL, NULL, NULL, 1234567, NULL, NULL)
SELECT * FROM ETL.GetXTTC(@XTTC, NULL, NULL, NULL, NULL, 1233, NULL)
SELECT * FROM ETL.GetXTTC(@XTTC, NULL, NULL, NULL, NULL, NULL, 3)
SELECT * FROM ETL.GetXTTC(@XTTC, NULL, NULL, 0, NULL, NULL, 3)

PRINT(CONVERT(varchar(MAX),@XTTC))
*/
ALTER FUNCTION ETL.WriteXTTC
				(
					@CurrentXTTC XML
					,@TicketCode varchar(50) = NULL
					,@FlagCalc bit = NULL
					,@SessionID int = NULL
					,@SessionParentID int = NULL
					,@Level int = NULL
				)
RETURNS XML
AS
BEGIN
	DECLARE 
			@returnXTTC XML = NULL
			,@inputTTC ETL.TTC_TYPE
			,@outputTTC ETL.TTC_TYPE
			,@lastID int


	IF ISNULL(@TicketCode,'') != ''
	AND ISNULL(@FlagCalc,-1) != -1
		BEGIN
			IF @CurrentXTTC IS NOT NULL
				BEGIN
					INSERT @inputTTC
					SELECT
							ticketcode 
							,flagcalc 
							,sessionid 
							,sessionparentid 
							,level
					FROM	ETL.GetXTTC(@CurrentXTTC, NULL, NULL, NULL, NULL, NULL, NULL)
					
					SELECT	@lastID = MAX(id)
					FROM	@inputTTC
				END

			IF NOT EXISTS (SELECT * FROM @inputTTC)
				BEGIN
					SET @FlagCalc = 0 
					INSERT 	@outputTTC
							(
								ticketcode 
								,flagcalc 
								,sessionid 
								,sessionparentid 
								,level
							) 
							VALUES 
							(
								@TicketCode 
								,@FlagCalc
								,@SessionID 
								,@SessionParentID
								,@Level 
							)
				END
			ELSE
				BEGIN
					INSERT	@outputTTC
					SELECT	
							ticketcode 
							,flagcalc 
							,sessionid 
							,sessionparentid 
							,level
					FROM	@inputTTC
					UNION ALL
					SELECT	
							ticketcode 
							,flagcalc 
							,sessionid 
							,sessionparentid 
							,level
					FROM
					(
						SELECT 
								@TicketCode AS TicketCode
								,@FlagCalc AS FlagCalc
								,@SessionID AS SessionID 
								,@SessionParentID AS SessionParentID
								,@Level AS Level  
					) I 
				END 
		END

	SET @returnXTTC =
		(
				SELECT 	
						id							
						,ticketcode 
						,flagcalc 
						,sessionid 
						,sessionparentid 
						,level
				FROM	@outputTTC 
				FOR XML RAW('TTC'), TYPE
		)
	RETURN  @returnXTTC
END