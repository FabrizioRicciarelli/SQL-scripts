/*
-- TST - ex TicketServerTime

DECLARE @XTST XML = NULL -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)
SET	@XTST = ETL.WriteXTST(@XTST,'2017-01-01',1,1,25,0,22)
SET	@XTST = ETL.WriteXTST(@XTST,'2017-01-01',1,1,32,0,22)

SELECT * FROM ETL.GetXTST(@XTST, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
*/
ALTER	FUNCTION [ETL].[GetXTST](
		@XMLtst XML = NULL
		,@ServerTime datetime2(3) NULL
		,@IterationNum tinyint NULL
		,@Rn smallint NULL
		,@DifferenceSS int NULL
		,@Direction bit NULL
		,@MachineID smallint NULL
)
RETURNS @returnTST TABLE(
		ServerTime datetime2(3) NULL
		,IterationNum tinyint NULL
		,Rn smallint NULL
		,DifferenceSS int NULL
		,Direction bit NULL
		,MachineID smallint NULL
)
AS
BEGIN
	INSERT	@returnTST
	SELECT
			 I.ServerTime
			,I.IterationNum
			,I.Rn
			,I.DifferenceSS
			,I.Direction
			,I.MachineID
	FROM
	(
		SELECT 
				T.c.value('@ServerTime', 'datetime2(3)') AS ServerTime
				,T.c.value('@IterationNum', 'tinyint') AS IterationNum
				,T.c.value('@Rn', 'smallint') AS Rn
				,T.c.value('@DifferenceSS', 'int') AS DifferenceSS
				,T.c.value('@Direction', 'bit') AS Direction
				,T.c.value('@MachineID', 'smallint') AS MachineID
		FROM	@XMLtst.nodes('TST') AS T(c) 
	) I
	WHERE	(ServerTime = @ServerTime OR @ServerTime IS NULL)
	AND		(IterationNum = @IterationNum OR @IterationNum IS NULL)
	AND		(Rn = @Rn OR @Rn IS NULL)
	AND		(DifferenceSS = @DifferenceSS OR @DifferenceSS IS NULL)
	AND		(Direction = @Direction OR @Direction IS NULL)
	AND		(MachineID = @MachineID OR @MachineID IS NULL)

	RETURN
END
