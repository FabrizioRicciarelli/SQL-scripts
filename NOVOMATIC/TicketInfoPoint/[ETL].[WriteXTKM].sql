/*
-- TKM - ex TMP.Ticketmatched

DECLARE @XTKM XML -- VUOTO

SET	@XTKM = ETL.WriteXTKM(@XTKM, '22283774729991283', 1, NULL)
SET	@XTKM = ETL.WriteXTKM(@XTKM, '89934758992193844', 2, NULL)
SET	@XTKM = ETL.WriteXTKM(@XTKM, '99378577298377855', NULL, 1)
SELECT * FROM ETL.GetXTKM(@XTKM, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetAllXTKM(@XTKM) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetAllXTKM(@XTKM) FOR XML PATH('TKM'), ROOT('ROWS'), TYPE -- RITORNA L'ELENCO COMPLETO IN FORMA XML

PRINT(CONVERT(varchar(MAX),@XTKM))
*/
ALTER FUNCTION [ETL].[WriteXTKM]
				(
					@XMLTKM XML = NULL
					,@TicketCode varchar(50) = NULL
					,@RowID int = NULL -- NOT NULL
					,@OUT bit = NULL
				)
RETURNS XML
AS
BEGIN
	DECLARE 
			@returnXTKM XML = NULL
			,@inputTKM ETL.TICKETMATCHED_TYPE
			,@outputTKM ETL.TICKETMATCHED_TYPE

	IF ISNULL(@RowID,0) != 0
	OR ISNULL(@OUT,-1) != -1
		BEGIN
			IF @XMLTKM IS NOT NULL
				BEGIN
					INSERT @inputTKM
					SELECT
							 TicketCode
							,RowID
							,[OUT] 
					FROM	ETL.GetAllXTKM(@XMLTKM) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
				END

			IF NOT EXISTS (SELECT * FROM @inputTKM)
				BEGIN
					INSERT 	@outputTKM
							(
								 TicketCode
								,RowID
								,[OUT] 
							) 
							VALUES 
							(
								 @TicketCode
								,@RowID
								,@OUT 
							)
				END
			ELSE
				BEGIN
					INSERT	@outputTKM
					SELECT	
							 TicketCode
							,RowID
							,[OUT] 
					FROM	@inputTKM
					UNION ALL
					SELECT	
							 I.TicketCode
							,I.RowID
							,I.[OUT] 
					FROM
					(
						SELECT 
								 @TicketCode AS TicketCode
								,@RowID AS RowID 
								,@OUT AS [OUT] 
					) I 
				END 
		END

	SET @returnXTKM =
		(
				SELECT 	
						TicketCode
						,RowID
						,[OUT] 
				FROM	@outputTKM 
				FOR XML RAW('TKM'), TYPE
		)
	RETURN  @returnXTKM
END