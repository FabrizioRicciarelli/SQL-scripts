/*
DECLARE @XRS XML -- VUOTO
SET @XRS ='<XRS SessionID="-2147483648" Level="0" UnivocalLocationCode="EA230118757A" MachineID="13" GD="GD011017233" AamsMachineCode="D0000002423" StartServerTime="2017-10-29T02:20:09.847" EndServerTime="2017-10-29T02:42:10.927" TotalRows="551" TotalBillIn="2" TotalCoinIN="0" TotalTicketIn="0" TotalBetValue="15704250" TotalBetNum="548" TotalWinValue="11476625" TotalWinNum="166" Tax="1020" TotalIn="7000" TotalOut="70013" StartTicketCode="522490202754716924" />'
SELECT * FROM ETL.GetXRS(@XRS, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI

DECLARE @XRS XML -- VUOTO
-- ETL.WriteXRS(@CurrentXRS,@SessionID,@SessionParentID,@Level,@UnivocalLocationCode,@MachineID,@GD,@AamsMachineCode,@StartServerTime,@EndServerTime,@TotalRows,@TotalBillIn,@TotalCoinIN,@TotalTicketIn,@TotalBetValue,@TotalBetNum,@TotalWinValue,@TotalWinNum,@Tax,@TotalIn,@TotalOut,@FlagMinVltCredit,@StartTicketCode)

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
ALTER FUNCTION [ETL].[WriteXRS]
				(
					@CurrentXRS XML
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
RETURNS XML
AS
BEGIN
	DECLARE 
			@returnXRS XML = NULL
			,@inputXRS ETL.RAWSESSION_TYPE
			,@outputXRS ETL.RAWSESSION_TYPE
			,@lastID int


	IF ISNULL(@MachineID,0) != 0
	AND ISNULL(@StartServerTime,'') != '' 
		BEGIN
			IF @CurrentXRS IS NOT NULL
				BEGIN
					INSERT	@inputXRS
					SELECT
							SessionID
							,SessionParentID
							,Level
							,UnivocalLocationCode
							,MachineID
							,GD
							,AamsMachineCode
							,StartServerTime
							,EndServerTime
							,TotalRows
							,TotalBillIn
							,TotalCoinIN
							,TotalTicketIn
							,TotalBetValue
							,TotalBetNum
							,TotalWinValue
							,TotalWinNum
							,Tax
							,TotalIn
							,TotalOut
							,FlagMinVltCredit
							,StartTicketCode
					FROM	ETL.GetXRS(@CurrentXRS, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
					
					SELECT	@lastID = MAX(SessionID)
					FROM	@inputXRS
				END

			IF NOT EXISTS (SELECT * FROM @inputXRS)
				BEGIN
					INSERT 	@outputXRS
							(
								SessionID
								,SessionParentID
								,Level
								,UnivocalLocationCode
								,MachineID
								,GD
								,AamsMachineCode
								,StartServerTime
								,EndServerTime
								,TotalRows
								,TotalBillIn
								,TotalCoinIN
								,TotalTicketIn
								,TotalBetValue
								,TotalBetNum
								,TotalWinValue
								,TotalWinNum
								,Tax
								,TotalIn
								,TotalOut
								,FlagMinVltCredit
								,StartTicketCode
							) 
							VALUES 
							(
								 @SessionID
								,@SessionParentID
								,@Level
								,@UnivocalLocationCode
								,@MachineID
								,@GD
								,@AamsMachineCode
								,@StartServerTime
								,@EndServerTime
								,@TotalRows
								,@TotalBillIn
								,@TotalCoinIN
								,@TotalTicketIn
								,@TotalBetValue
								,@TotalBetNum
								,@TotalWinValue
								,@TotalWinNum
								,@Tax
								,@TotalIn
								,@TotalOut
								,@FlagMinVltCredit
								,@StartTicketCode
							)
				END
			ELSE
				BEGIN
					INSERT	@outputXRS
					SELECT	
							SessionID
							,SessionParentID
							,Level
							,UnivocalLocationCode
							,MachineID
							,GD
							,AamsMachineCode
							,StartServerTime
							,EndServerTime
							,TotalRows
							,TotalBillIn
							,TotalCoinIN
							,TotalTicketIn
							,TotalBetValue
							,TotalBetNum
							,TotalWinValue
							,TotalWinNum
							,Tax
							,TotalIn
							,TotalOut
							,FlagMinVltCredit
							,StartTicketCode
					FROM	@inputXRS
					UNION ALL
					SELECT	
							SessionID
							,SessionParentID
							,Level
							,UnivocalLocationCode
							,MachineID
							,GD
							,AamsMachineCode
							,StartServerTime
							,EndServerTime
							,TotalRows
							,TotalBillIn
							,TotalCoinIN
							,TotalTicketIn
							,TotalBetValue
							,TotalBetNum
							,TotalWinValue
							,TotalWinNum
							,Tax
							,TotalIn
							,TotalOut
							,FlagMinVltCredit
							,StartTicketCode
					FROM
					(
						SELECT 
								@SessionID AS SessionID
								,@SessionParentID AS SessionParentID
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
					) I 
				END 
		END

	SET @returnXRS =
		(
			SELECT 	
					SessionID
					,SessionParentID
					,Level
					,UnivocalLocationCode
					,MachineID
					,GD
					,AamsMachineCode
					,StartServerTime
					,EndServerTime
					,TotalRows
					,TotalBillIn
					,TotalCoinIN
					,TotalTicketIn
					,TotalBetValue
					,TotalBetNum
					,TotalWinValue
					,TotalWinNum
					,Tax
					,TotalIn
					,TotalOut
					,FlagMinVltCredit
					,StartTicketCode
			FROM	@outputXRS 
			FOR XML RAW('XRS'), TYPE
		)
	RETURN  @returnXRS
END