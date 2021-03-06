/*
DECLARE @XVLT XML -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)

SET	@XVLT = ETL.WriteXVLT(@XVLT, '391378593917118854', 0, 1234, 1233, 1) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XVLT = ETL.WriteXVLT(@XVLT, '391378593917118855', 1, 12345, 12344, 2) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XVLT = ETL.WriteXVLT(@XVLT, '391378593917118856', 0, 123456, 123455, 2) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XVLT = ETL.WriteXVLT(@XVLT, '391378593917118857', 0, 1234567, 1234566, 3) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE

SELECT * FROM ETL.GetXVLT(@XVLT, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
*/
ALTER	FUNCTION [ETL].[GetXVLT](
		@XMLvlt XML = NULL
		,@ClubID int NULL
		,@MachineID smallint NULL
		,@Machine varchar(30) NULL
		,@AamsMachineCode varchar(30) NULL
		,@UnivocalLocationCode varchar(30) NULL
)
RETURNS  @returnVLT TABLE(
		ClubID int NULL
		,MachineID smallint NULL
		,Machine varchar(30) NULL
		,AamsMachineCode varchar(30) NULL
		,UnivocalLocationCode varchar(30) NULL
)
AS
BEGIN
	INSERT	 @returnVLT
	SELECT
			 I.ClubID
			,I.MachineID
			,I.Machine
			,I.AamsMachineCode
			,I.UnivocalLocationCode
	FROM
	(
		SELECT 
				T.c.value('@ClubID', 'int') AS ClubID
				,T.c.value('@MachineID', 'smallint') AS MachineID
				,T.c.value('@Machine', 'varchar(30)') AS Machine
				,T.c.value('@AamsMachineCode', 'varchar(30)') AS AamsMachineCode
				,T.c.value('@UnivocalLocationCode', 'varchar(30)') AS UnivocalLocationCode
		FROM	@XMLvlt.nodes('VLT') AS T(c) 
	) I
	WHERE	(ClubID = @ClubID OR @ClubID IS NULL)
	AND		(MachineID = @MachineID OR @MachineID IS NULL)
	AND		(Machine = @Machine OR @Machine IS NULL)
	AND		(AamsMachineCode = @AamsMachineCode OR @AamsMachineCode IS NULL)
	AND		(UnivocalLocationCode = @UnivocalLocationCode OR @UnivocalLocationCode IS NULL)

	RETURN
END
