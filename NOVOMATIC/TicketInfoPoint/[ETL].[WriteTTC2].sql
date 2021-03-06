/*
DECLARE 
		@TTC ETL.TTC_TYPE -- VUOTO
		,@xmlTTC XML

--EXEC	ETL.WriteTTC2
--		@inputTTC = @TTC
--		,@TicketCode = '391378593917118855'
--		,@FlagCalc = 0
--		,@SessionID = 12345
--		,@SessionParentID = 12344
--		,@Level = 0
--		,@xmldata = @XMLttc OUTPUT

EXEC	ETL.WriteTTC2 @TTC, '391378593917118854', 0, 1234, 1233, 1, @xmlTTC OUTPUT
EXEC	ETL.WriteTTC2 @TTC, '391378593917118855', 0, 12345, 12344, 2, @xmlTTC OUTPUT
EXEC	ETL.WriteTTC2 @TTC, '391378593917118856', 0, 123456, 123455, 3, @xmlTTC OUTPUT
EXEC	ETL.WriteTTC2 @TTC, '391378593917118857', 0, 1234567, 1234566, 4, @xmlTTC OUTPUT

SELECT * FROM ETL.GetXTTC(@XMLttc, NULL, NULL, NULL, NULL, NULL, NULL)
*/
ALTER PROC [ETL].[WriteTTC2]
			@inputTTC ETL.TTC_TYPE READONLY
			,@TicketCode varchar(50) = NULL
			,@FlagCalc bit = NULL
			,@SessionID int = NULL
			,@SessionParentID int = NULL
			,@Level int = NULL
			,@xmldata XML OUTPUT
AS
BEGIN TRY
	IF ISNULL(@TicketCode,'') != ''
	AND ISNULL(@FlagCalc,-1) != -1
		BEGIN
			DECLARE @outputTTC ETL.TTC_TYPE

			IF NOT EXISTS (SELECT * FROM @inputTTC)
				BEGIN
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
					MERGE @outputTTC AS T 
					USING @inputTTC AS S
					ON ISNULL(T.ticketcode,'') = ISNULL(S.ticketcode,'')
					WHEN	NOT MATCHED 
					THEN	INSERT 
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
							) ;
				END
		
			SET @xmldata = 
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
			--PRINT(CONVERT(varchar(MAX),@xmldata))
		END
END TRY

BEGIN CATCH 
    SELECT
			ERROR_NUMBER() AS ErrorNumber
			,ERROR_SEVERITY() AS Severity
			,ERROR_STATE() AS ErrorState
			,ISNULL(ERROR_PROCEDURE(), ISNULL(dbo.GetProcName(@@PROCID),'*Unknown*')) AS ErrorProcedure  
			,ERROR_LINE() AS ProcedureLine
			,ERROR_MESSAGE() As ErrorMessage
END CATCH 

