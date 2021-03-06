/*
-- TST - ex TicketServerTime

DECLARE @XTST XML = NULL -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)
SET	@XTST = ETL.WriteXTST(@XTST,'2017-01-01',1,1,25,0,22)
SET	@XTST = ETL.WriteXTST(@XTST,'2017-01-01',1,1,32,0,22)

SELECT * FROM ETL.GetAllXTST(@XTST)
*/
ALTER	FUNCTION [ETL].[GetAllXTST](
		@XMLtst XML = NULL
)
RETURNS TABLE
AS
RETURN(
	SELECT 
			T.c.value('@ServerTime', 'datetime2(3)') AS ServerTime
			,T.c.value('@IterationNum', 'tinyint') AS IterationNum
			,T.c.value('@Rn', 'smallint') AS Rn
			,T.c.value('@DifferenceSS', 'int') AS DifferenceSS
			,T.c.value('@Direction', 'bit') AS Direction
			,T.c.value('@MachineID', 'smallint') AS MachineID
	FROM	@XMLtst.nodes('TST') AS T(c) 
) 