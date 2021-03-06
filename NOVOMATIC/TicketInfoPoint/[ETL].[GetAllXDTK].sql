/*
DECLARE	@XDTK XML -- VUOTO
SELECT * FROM ETL.GetXDTK(@XDTK, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetAllXDTK(@XDTK) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetAllXDTK(@XDTK) FOR XML PATH('DTK'), ROOT('ROWS'), TYPE -- RITORNA L'ELENCO COMPLETO IN FORMA XML
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