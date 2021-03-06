/*
DECLARE	@XDTK XML -- VUOTO
SELECT * FROM ETL.GetXDTK(@XDTK, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetAllXDTK(@XDTK) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetAllXDTK(@XDTK) FOR XML PATH('DTK'), ROOT('ROWS'), TYPE -- RITORNA L'ELENCO COMPLETO IN FORMA XML
*/
ALTER	FUNCTION [ETL].[GetXDTK](
		@XMLDTK XML = NULL
		,@RowID int = NULL
		,@TotalTicketIN int = NULL
		,@TotalOut int = NULL
		,@ServerTime datetime2(3) = NULL
		,@MachineID smallint = NULL
)
RETURNS  @returnDTK TABLE(
		RowID int NULL
		,TotalTicketIN int NULL
		,TotalOut int NULL
		,ServerTime datetime2(3) NULL
		,MachineID smallint NULL
)
AS
BEGIN
	INSERT	 @returnDTK
	SELECT
			 I.RowID
			,I.TotalTicketIN
			,I.TotalOut
			,I.ServerTime
			,I.MachineID
	FROM
	(
		SELECT 
				T.c.value('@RowID', 'int') AS RowID
				,T.c.value('@TotalTicketIN', 'int') AS TotalTicketIN
				,T.c.value('@TotalOut', 'int') AS TotalOut
				,T.c.value('@ServerTime', 'datetime2(3)') AS ServerTime
				,T.c.value('@MachineID', 'smallint') AS MachineID
		FROM	@XMLDTK.nodes('DTK') AS T(c) 
	) I
	WHERE	(RowID = @RowID OR @RowID IS NULL)
	AND		(TotalTicketIN = @TotalTicketIN OR @TotalTicketIN IS NULL)
	AND		(TotalOut = @TotalOut OR @TotalOut IS NULL)
	AND		(ServerTime = @ServerTime OR @ServerTime IS NULL)
	AND		(MachineID = @MachineID OR @MachineID IS NULL)

	RETURN
END
