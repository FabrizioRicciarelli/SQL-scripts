/*
DECLARE @XRS XML -- VUOTO
SET @XRS ='<XRS SessionID="-2147483648" Level="0" UnivocalLocationCode="EA230118757A" MachineID="13" GD="GD011017233" AamsMachineCode="D0000002423" StartServerTime="2017-10-29T02:20:09.847" EndServerTime="2017-10-29T02:42:10.927" TotalRows="551" TotalBillIn="2" TotalCoinIN="0" TotalTicketIn="0" TotalBetValue="15704250" TotalBetNum="548" TotalWinValue="11476625" TotalWinNum="166" Tax="1020" TotalIn="7000" TotalOut="70013" StartTicketCode="522490202754716924" />'
SELECT * FROM ETL.GetXRS(@XRS, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI

DECLARE @XRS XML -- VUOTO
SET	@XRS = ETL.WriteXRS(@XRS, -2147483648, NULL, 0, 'EA230118757A', 3, 'GD011017233', 'D0000002423', '2017-10-29 02:20:09.847', '2017-10-29 02:42:10.927', 551, 2, NULL, 0, 15704250, 548, 11476625, 166, 1020, 7000, 70013, NULL, '522490202754716924') -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XRS = ETL.WriteXRS(@XRS, -2147483648, NULL, 0, 'EA110086040A', 9, 'GD012028334', 'D0000002290', '2017-10-29 02:02:10.467', '2017-10-29 02:40:29.070', 1090, 8, NULL, 0, 111807250, 1080, 29199565, 277, 286596, 40000, 110017, NULL, '50149147153424875') -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XRS = ETL.WriteXRS(@XRS, -2147483648, NULL, 0, 'EA910140227Y', 13, 'GD009003460', 'D0000001431', '2017-10-29 02:00:04.770', '2017-10-29 02:23:49.347' ,337, 2,NULL, 0, 6111850, 334, 2580075, 86,18810, 10000, 100046, NULL, '556604200274145003') -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XRS = ETL.WriteXRS(@XRS, -2147483648, NULL, 0, 'EA110086040A', 9, 'GD012028334', 'D0000002290', '2017-10-29 02:02:10.467', '2017-10-29 02:40:29.070', 1090, 8,NULL, 0, 111645400, 1080,29013990, 276, 285342, 40000, 110017, NULL, '50149147153424875') -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XRS = ETL.WriteXRS(@XRS, -2147483648, NULL, 0, 'EA230118757A', 13, 'GD011017233', 'D0000002423', '2017-10-29 02:20:09.847', '2017-10-29 02:42:10.927' ,551, 2,NULL, 0, 15704250, 548,11476625, 166, 1020, 7000, 70013, NULL, '522490202754716924') -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE

SELECT * FROM ETL.GetXRS(@XRS, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetXRS(@XRS, -2147483648, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetXRS(@XRS, NULL, NULL, NULL, 'EA230118757A', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
SELECT * FROM ETL.GetXRS(@XRS, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2017-10-29 02:20:09.847', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
PRINT(CONVERT(varchar(MAX),@XRS))
*/
ALTER	FUNCTION [ETL].[GetXRS](
		@XMLRS XML = NULL
		,@SessionID int --IDENTITY(-2147483648,1) NOT NULL
		,@SessionParentID int
		,@Level int
		,@UnivocalLocationCode varchar(30)
		,@MachineID smallint -- NOT NULL
		,@GD varchar(30)
		,@AamsMachineCode varchar(30)
		,@StartServerTime datetime2(3) -- NOT NULL
		,@EndServerTime datetime2(3)
		,@TotalRows int
		,@TotalBillIn smallint
		,@TotalCoinIN smallint
		,@TotalTicketIn smallint
		,@TotalBetValue bigint
		,@TotalBetNum int
		,@TotalWinValue bigint
		,@TotalWinNum int
		,@Tax bigint
		,@TotalIn bigint
		,@TotalOut bigint
		,@FlagMinVltCredit bit
		,@StartTicketCode varchar(50) NULL
)
RETURNS @returnRS TABLE(
		SessionID int --IDENTITY(-2147483648,1) -- NOT NULL
		,SessionParentID int
		,Level int
		,UnivocalLocationCode varchar(30)
		,MachineID smallint -- NOT NULL
		,GD varchar(30)
		,AamsMachineCode varchar(30)
		,StartServerTime datetime2(3) -- NOT NULL
		,EndServerTime datetime2(3)
		,TotalRows int
		,TotalBillIn smallint
		,TotalCoinIN smallint
		,TotalTicketIn smallint
		,TotalBetValue bigint
		,TotalBetNum int
		,TotalWinValue bigint
		,TotalWinNum int
		,Tax bigint
		,TotalIn bigint
		,TotalOut bigint
		,FlagMinVltCredit bit
		,StartTicketCode varchar(50) NULL
)
AS
BEGIN
	INSERT	@returnRS
	SELECT
			 I.SessionID
			,I.SessionParentID
			,I.Level
			,I.UnivocalLocationCode
			,I.MachineID
			,I.GD
			,I.AamsMachineCode
			,I.StartServerTime
			,I.EndServerTime
			,I.TotalRows
			,I.TotalBillIn
			,I.TotalCoinIN
			,I.TotalTicketIn
			,I.TotalBetValue
			,I.TotalBetNum
			,I.TotalWinValue
			,I.TotalWinNum
			,I.Tax
			,I.TotalIn
			,I.TotalOut
			,I.FlagMinVltCredit
			,I.StartTicketCode
	FROM
	(
		SELECT 
				 T.c.value('@SessionID', 'int') AS SessionID
				,T.c.value('@SessionParentID', 'int') AS SessionParentID
				,T.c.value('@Level', 'int') AS Level
				,T.c.value('@UnivocalLocationCode', 'varchar(30)') AS UnivocalLocationCode
				,T.c.value('@MachineID', 'tinyint') AS MachineID
				,T.c.value('@GD', 'varchar(30)') AS GD
				,T.c.value('@AamsMachineCode', 'varchar(30)') AS AamsMachineCode
				,T.c.value('@StartServerTime', 'datetime2(3)') AS StartServerTime
				,T.c.value('@EndServerTime', 'datetime2(3)') AS EndServerTime
				,T.c.value('@TotalRows', 'int') AS TotalRows
				,T.c.value('@TotalBillIn', 'int') AS TotalBillIn
				,T.c.value('@TotalCoinIn', 'int') AS TotalCoinIn
				,T.c.value('@TotalTicketIn', 'int') AS TotalTicketIn
				,T.c.value('@TotalBetValue', 'bigint') AS TotalBetValue
				,T.c.value('@TotalBetNum', 'int') AS TotalBetNum
				,T.c.value('@TotalWinValue', 'bigint') AS TotalWinValue
				,T.c.value('@TotalWinNum', 'int') AS TotalWinNum
				,T.c.value('@Tax', 'bigint') AS Tax
				,T.c.value('@TotalIn', 'bigint') AS TotalIn
				,T.c.value('@TotalOut', 'bigint') AS TotalOut
				,T.c.value('@FlagMinVltCredit', 'bit') AS FlagMinVltCredit
				,T.c.value('@StartTicketCode', 'varchar(50)') AS StartTicketCode
		FROM	@XMLRS.nodes('XRS') AS T(c) 
	) I
	WHERE	(SessionID = @SessionID OR @SessionID IS NULL)
	AND		(SessionParentID = @SessionParentID OR @SessionParentID IS NULL)
	AND		(Level = @Level OR @Level IS NULL)
	AND		(UnivocalLocationCode = @UnivocalLocationCode OR @UnivocalLocationCode IS NULL)
	AND		(MachineID = @MachineID OR @MachineID IS NULL)
	AND		(GD = @GD OR @GD IS NULL)
	AND		(AamsMachineCode = @AamsMachineCode OR @AamsMachineCode IS NULL)
	AND		(StartServerTime = @StartServerTime OR @StartServerTime IS NULL)
	AND		(EndServerTime = @EndServerTime OR @EndServerTime IS NULL)
	AND		(TotalRows = @TotalRows OR @TotalRows IS NULL)
	AND		(TotalBillIn = @TotalBillIn OR @TotalBillIn IS NULL)
	AND		(TotalCoinIn = @TotalCoinIn OR @TotalCoinIn IS NULL)
	AND		(TotalTicketIn = @TotalTicketIn OR @TotalTicketIn IS NULL)
	AND		(TotalBetValue = @TotalBetValue OR @TotalBetValue IS NULL)
	AND		(TotalBetNum = @TotalBetNum OR @TotalBetNum IS NULL)
	AND		(TotalWinValue = @TotalWinValue OR @TotalWinValue IS NULL)
	AND		(TotalWinNum = @TotalWinNum OR @TotalWinNum IS NULL)
	AND		(Tax = @Tax OR @Tax IS NULL)
	AND		(TotalIn = @TotalIn OR @TotalIn IS NULL)
	AND		(TotalOut = @TotalOut OR @TotalOut IS NULL)
	AND		(FlagMinVltCredit = @FlagMinVltCredit OR @FlagMinVltCredit IS NULL)
	AND		(StartTicketCode = @StartTicketCode OR @StartTicketCode IS NULL)
	

	RETURN
END
