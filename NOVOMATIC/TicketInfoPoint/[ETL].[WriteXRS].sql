/*
DECLARE @XRS XML -- VUOTO
SET @XRS ='<XRS SessionID="-2147483648" SessionParentID="-2147483255" Level="0" RowID="-2043978766" UnivocalLocationCode="EA110086040A" StartServerTime="2017-10-21T15:03:26.150" EndServerTime="2017-01-02T12:43:59.865" TotalRows="900" MachineID="11" GD="GD014017380" AamsMachineCode="D0000004379" GameID="-146039307" GameName="Book Of Ra" VLTCredit="1050" TotalBet="100" TicketCode="0"/>'
--SET @XRS ='<XRS SessionParentID="-2147483255" Level="0" RowID="-2043978766" UnivocalLocationCode="EA110086040A" StartServerTime="2017-10-21T15:03:26.150" EndServerTime="2017-01-02T12:43:59.865" TotalRows="900" MachineID="11" GD="GD014017380" AamsMachineCode="D0000004379" GameID="-146039307" GameName="Book Of Ra" VLTCredit="1050" TotalBet="100" TicketCode="0"/>'
SELECT * FROM ETL.GetAllXRS(@XRS)
PRINT(CONVERT(varchar(MAX),@XRS))

--DECLARE @XRS XML -- VUOTO
SET	@XRS = ETL.WriteXRS(@XRS, NULL, -2043978256, 0, 'EA110086040A', 27, 'GD014017380', 'D0000004379', '2017-01-01T12:43:59.865', '2017-01-02T12:43:59.865', 1150, 100, NULL, NULL, NULL, NULL,  NULL, NULL, NULL, NULL, NULL, 0, NULL) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XRS = ETL.WriteXRS(@XRS, NULL, -2043978257, 0, 'EA110086040A', 27, 'GD014017380', 'D0000004379', '2017-01-01T12:43:59.865', '2017-01-02T12:43:59.865', 1050, 100, NULL, NULL, NULL, NULL,  NULL, NULL, NULL, NULL, NULL, 0, NULL) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XRS = ETL.WriteXRS(@XRS, NULL, -2043978258, 0, 'EA110086040A', 27, 'GD014017380', 'D0000004379', '2017-01-01T12:43:59.865', '2017-01-02T12:43:59.865', 1000, 50, NULL, NULL, NULL, NULL,  NULL, NULL, NULL, NULL, NULL, 0, NULL) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XRS = ETL.WriteXRS(@XRS, NULL, -2043978259, 0, 'EA110086040A', 27, 'GD014017380', 'D0000004379', '2017-01-01T12:43:59.865', '2017-01-02T12:43:59.865', 950, 50, NULL, NULL, NULL, NULL,  NULL, NULL, NULL, NULL, NULL, 0, NULL) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SELECT * FROM ETL.GetAllXRS(@XRS)
--PRINT(CONVERT(varchar(MAX),@XRS))
*/
ALTER FUNCTION [ETL].[WriteXRS]
				(
					@XMLSESSION XML
					,@SessionID bigint --IDENTITY(-2147483648,1) NOT NULL
					,@SessionParentID bigint
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
RETURNS XML
AS
BEGIN
	DECLARE	@outputXRS ETL.RAWSESSION_TYPE 

	INSERT	@outputXRS(SessionParentID, Level, UnivocalLocationCode, MachineID, GD, AamsMachineCode, StartServerTime, EndServerTime, TotalRows, TotalBillIn, TotalCoinIN, TotalTicketIn, TotalBetValue, TotalBetNum, TotalWinValue, TotalWinNum, Tax, TotalIn, TotalOut, FlagMinVltCredit, StartTicketCode)					
	SELECT	SessionParentID, Level, UnivocalLocationCode, MachineID, GD, AamsMachineCode, StartServerTime, EndServerTime, TotalRows, TotalBillIn, TotalCoinIN, TotalTicketIn, TotalBetValue, TotalBetNum, TotalWinValue, TotalWinNum, Tax, TotalIn, TotalOut, FlagMinVltCredit, StartTicketCode
	FROM	ETL.GetAllXRS(@XMLSESSION)
	UNION ALL
	SELECT	
			@SessionParentID AS SessionParentID
			,@Level AS Level
			,@UnivocalLocationCode AS UnivocalLocationCode
			,@MachineID AS MachineID
			,@GD AS GD
			,@AamsMachineCode AS AamsMachineCode
			,@StartServerTime AS StartServerTime
			,@EndServerTime AS EndServerTime
			,@TotalRows AS TotalRows
			,@TotalBillIn AS TotalBillIn
			,@TotalCoinIN AS TotalCoinIN
			,@TotalTicketIn AS TotalTicketIn
			,@TotalBetValue AS TotalBetValue
			,@TotalBetNum AS TotalBetNum
			,@TotalWinValue AS TotalWinValue
			,@TotalWinNum AS TotalWinNum
			,@Tax AS Tax
			,@TotalIn AS TotalIn
			,@TotalOut AS TotalOut
			,@FlagMinVltCredit AS FlagMinVltCredit
			,@StartTicketCode AS StartTicketCode

	RETURN(
		SELECT	I.*
		FROM(
			SELECT	SessionID, SessionParentID, Level, UnivocalLocationCode, MachineID, GD, AamsMachineCode, StartServerTime, EndServerTime, TotalRows, TotalBillIn, TotalCoinIN, TotalTicketIn, TotalBetValue, TotalBetNum, TotalWinValue, TotalWinNum, Tax, TotalIn, TotalOut, FlagMinVltCredit, StartTicketCode
			FROM	@outputXRS
		) I
		FOR XML RAW('XRS'), TYPE
	)
END