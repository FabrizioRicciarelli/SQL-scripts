/*
-- DTK - ex TMP.DeltaTicketIN/TMP.DeltaTicketOut

DECLARE @XDTK XML -- VUOTO

SET	@XDTK = ETL.WriteXDTK(@XDTK, 1, 1000, NULL, '2017-01-01', 22)
SET	@XDTK = ETL.WriteXDTK(@XDTK, 2, 1600, NULL, '2017-01-01', 23)
SET	@XDTK = ETL.WriteXDTK(@XDTK, 3, NULL, 1200, '2018-01-01', 29)
SELECT * FROM ETL.GetXDTK(@XDTK, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetAllXDTK(@XDTK) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetAllXDTK(@XDTK) FOR XML PATH('DTK'), ROOT('ROWS'), TYPE -- RITORNA L'ELENCO COMPLETO IN FORMA XML

PRINT(CONVERT(varchar(MAX),@XDTK))
*/
ALTER	FUNCTION [ETL].[GetAllXDTK](
		@XMLDTK XML = NULL
)
RETURNS  TABLE
AS
RETURN (
	SELECT 
			T.c.value('@RowID', 'int') AS RowID
			,T.c.value('@TotalTicketIN', 'int') AS TotalTicketIN
			,T.c.value('@TotalOut', 'int') AS TotalOut
			,T.c.value('@ServerTime', 'datetime2(3)') AS ServerTime
			,T.c.value('@MachineID', 'smallint') AS MachineID
	FROM	@XMLDTK.nodes('DTK') AS T(c) 
)