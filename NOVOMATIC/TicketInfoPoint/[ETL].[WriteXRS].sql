/*
DECLARE @XRS XML -- VUOTO
SET @XRS ='<XRS RowID="-2043978766" UnivocalLocationCode="EA110086040A" ServerTime="2017-10-21T15:03:26.150" MachineID="11" GD="GD014017380" AamsMachineCode="D0000004379" GameID="-146039307" GameName="Book Of Ra" VLTCredit="1050" TotalBet="100" TicketCode="0" SessionID="-2147483641"/>'
SELECT * FROM ETL.GetXRS(@XRS, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
PRINT(CONVERT(varchar(MAX),@XRS))

DECLARE @XRS XML -- VUOTO
SET	@XRS = ETL.WriteXRS(@XRS, -2043978769, 'EA110086040A', '2017-10-21 15:03:24.043', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 1150, 100, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SET	@XRS = ETL.WriteXRS(@XRS, -2043978766, 'EA110086040A', '2017-10-21 15:03:26.150', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 1050, 100, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XRS = ETL.WriteXRS(@XRS, -2043978761, 'EA110086040A', '2017-10-21 15:03:29.447', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 1000, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SET	@XRS = ETL.WriteXRS(@XRS, -2043978755, 'EA110086040A', '2017-10-21 15:03:31.707', 11, 'GD014017380', 'D0000004379', -146039307, 'Book Of Ra', 950, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, -2147483641) -- AGGIUNGE UN ELEMENTO AL CONTENITORE PREESISTENTE
SELECT * FROM ETL.GetXRS(@XRS, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
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