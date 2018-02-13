/*
DECLARE @XTTKIN XML -- VUOTO
SET	@XTTKIN = ETL.WriteXTTKIN(@XTTKIN, NULL, '391378593917118854', 'GD55677656T34', 1000296)
SET	@XTTKIN = ETL.WriteXTTKIN(@XTTKIN, NULL, '391378593917118857', 'TJI72719992431', 1000296)
SET	@XTTKIN = ETL.WriteXTTKIN(@XTTKIN, NULL, '391378593917118859', 'OL288859277384', 1000296)

SELECT * FROM ETL.GetAllXTTKIN(@XTTKIN)
PRINT(CONVERT(varchar(MAX),@XTTKIN))
*/
ALTER FUNCTION [ETL].[WriteXTTKIN]
				(
					@XMLTTKIN XML = NULL
					,@ID smallint = NULL -- NOT NULL smallint IDENTITY(1,1)
					,@TicketID nvarchar(255) = NULL -- NOT NULL
					,@UnivocalLocationCode varchar(20) = NULL
					,@ClubID int = NULL
				)
RETURNS XML
AS
BEGIN
	DECLARE 
			@returnXTTKIN XML = NULL
			,@inputTTKIN ETL.TTICKETIN_TYPE
			,@outputTTKIN ETL.TTICKETIN_TYPE
			,@lastID int


	IF ISNULL(@TicketID,'') != ''
		BEGIN
			IF @XMLTTKIN IS NOT NULL
				BEGIN
					INSERT @inputTTKIN
					SELECT
							TicketID
							,UnivocalLocationCode
							,ClubID
					FROM	ETL.GetAllXTTKIN(@XMLTTKIN)
					
					SELECT	@lastID = MAX(id)
					FROM	@inputTTKIN
				END

			IF NOT EXISTS (SELECT * FROM @inputTTKIN)
				BEGIN
					INSERT 	@outputTTKIN
							(
								TicketID
								,UnivocalLocationCode
								,ClubID
							) 
							VALUES 
							(
								@TicketID
								,@UnivocalLocationCode
								,@ClubID
							)
				END
			ELSE
				BEGIN
					INSERT	@outputTTKIN
					SELECT	
							TicketID
							,UnivocalLocationCode
							,ClubID
					FROM	@inputTTKIN
					UNION ALL
					SELECT	
							TicketID
							,UnivocalLocationCode
							,ClubID
					FROM
					(
						SELECT 
								@TicketID AS TicketID
								,@UnivocalLocationCode AS UnivocalLocationCode
								,@ClubID AS ClubID 
					) I 
				END 
		END

	SET @returnXTTKIN =
		(
				SELECT 	
						ID							
						,TicketID
						,UnivocalLocationCode
						,ClubID
				FROM	@outputTTKIN 
				FOR XML RAW('TTKIN'), TYPE
		)
	RETURN  @returnXTTKIN
END