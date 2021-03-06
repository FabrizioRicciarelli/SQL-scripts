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
	DECLARE	@outputTTKIN ETL.TTICKETIN_TYPE 

	INSERT 	@outputTTKIN(TicketID, UnivocalLocationCode, ClubID)
	SELECT	TicketID, UnivocalLocationCode, ClubID
	FROM	ETL.GetAllXTTKIN(@XMLTTKIN)
	UNION ALL
	SELECT	@TicketID AS TicketID, @UnivocalLocationCode AS UnivocalLocationCode, @ClubID as ClubID

	RETURN(
		SELECT	I.*
		FROM(
			SELECT	ID, TicketID, UnivocalLocationCode, ClubID
			FROM	@outputTTKIN 
		) I
		FOR XML RAW('TTKIN'), TYPE
	)
END