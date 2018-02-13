/*
-- DTK - ex TMP.DeltaTicketIN/TMP.DeltaTicketOut

DECLARE @XDTK XML -- VUOTO
--SET	@XDTK = ETL.WriteXDTK(@XDTK,@RowID,@TotalTicketIN,@TotalOut,@ServerTime,@MachineID)

SET	@XDTK = ETL.WriteXDTK(@XDTK XML, 1, 1000, NULL, '2017-01-01', 22)
SET	@XDTK = ETL.WriteXDTK(@XDTK XML, 2, 1600, NULL, '2017-01-01', 23)
SET	@XDTK = ETL.WriteXDTK(@XDTK XML, 3, NULL, 1200, '2018-01-01', 29)
SELECT * FROM ETL.GetXDTK(@XDTK, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetAllXDTK(@XDTK) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI

PRINT(CONVERT(varchar(MAX),@XDTK))
*/
ALTER FUNCTION [ETL].[WriteXDTK]
				(
					@XMLDTK XML = NULL
					,@RowID int = NULL
					,@TotalTicketIN int = NULL
					,@TotalOut int = NULL
					,@ServerTime datetime2(3) = NULL
					,@MachineID smallint = NULL
				)
RETURNS XML
AS
BEGIN
	DECLARE 
			@returnXDTK XML = NULL
			,@inputDTK ETL.DELTATICKET_TYPE
			,@outputDTK ETL.DELTATICKET_TYPE

	IF ISNULL(@ServerTime,'') != ''
		BEGIN
			IF @XMLDTK IS NOT NULL
				BEGIN
					INSERT @inputDTK
					SELECT
							RowID
							,TotalTicketIN
							,TotalOut
							,ServerTime
							,MachineID
					FROM	ETL.GetAllXDTK(@XMLDTK) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
				END

			IF NOT EXISTS (SELECT * FROM @inputDTK)
				BEGIN
					INSERT 	@outputDTK
							(
								RowID
								,TotalTicketIN
								,TotalOut
								,ServerTime
								,MachineID
							) 
							VALUES 
							(
								 @RowID
								,@TotalTicketIN
								,@TotalOut
								,@ServerTime
								,@MachineID
							)
				END
			ELSE
				BEGIN
					INSERT	@outputDTK
					SELECT	
							RowID
							,TotalTicketIN
							,TotalOut
							,ServerTime
							,MachineID
					FROM	@inputDTK
					UNION ALL
					SELECT	
							 I.RowID
							,I.TotalTicketIN
							,I.TotalOut
							,I.ServerTime
							,I.MachineID
					FROM
					(
						SELECT 
								 @RowID AS RowID
								,@TotalTicketIN AS TotalTicketIN
								,@TotalOut AS TotalOut
								,@ServerTime AS	ServerTime
								,@MachineID AS MachineID
					) I 
				END 
		END

	SET @returnXDTK =
		(
				SELECT 	
						RowID
						,TotalTicketIN
						,TotalOut
						,ServerTime
						,MachineID
				FROM	@outputDTK 
				FOR XML RAW('DTK'), TYPE
		)
	RETURN  @returnXDTK
END