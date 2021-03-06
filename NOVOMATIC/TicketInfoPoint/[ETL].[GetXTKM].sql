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
ALTER	FUNCTION [ETL].[GetXTKM](
		@XMLTKM XML = NULL
		,@TicketCode varchar(50) = NULL
		,@RowID int = NULL
		,@OUT bit = NULL
)
RETURNS  @returnTKM TABLE(
	TicketCode varchar(50) NULL
	,RowID int NULL
	,[OUT] bit NULL
)
AS
BEGIN
	INSERT	 @returnTKM
	SELECT
			 I.TicketCode
			,I.RowID
			,I.[OUT] 
	FROM
	(
		SELECT 
				T.c.value('@TicketCode', 'varchar(50)') AS TicketCode
				,T.c.value('@RowID', 'int') AS RowID
				,T.c.value('@OUT', 'bit') AS [OUT]
		FROM	@XMLTKM.nodes('TKM') AS T(c) 
	) I
	WHERE	(TicketCode = @TicketCode OR @TicketCode IS NULL)
	AND		(RowID = @RowID OR @RowID IS NULL)
	AND		([OUT] = @OUT OR @OUT IS NULL)

	RETURN
END
