/*
SET NOCOUNT ON;

DECLARE 
		@XRS XML -- VUOTO
		,@INPUTXRS ETL.RAWSESSION_TYPE

-- COMMENTARE/DECOMMENTARE LA PARTE SEGUENTE INDENTATA PER OSSERVARE COME SI COMPORTA LA BULK
---------------------------------------------------------------------------------------------

				---- RIEMPIMENTO OGGETTO DI TIPO "ETL.RAWSESSION_TYPE"
				--INSERT @INPUTXRS -- (RowID, UnivocalLocationCode, ServerTime, MachineID, GD, AamsMachineCode, GameID, GameName, VLTCredit, TotalBet, TotalWon, TotalBillIn, TotalCoinIn, TotalTicketIn, TotalHandPay, TotalTicketOut, Tax, TotalIn, TotalOut, WrongFlag, TicketCode, FlagMinVltCredit)  -- * ELENCO PARAMETRI OPZIONALE *
				--VALUES
				--			(-2147483641, NULL, 0, 'EA2301187AAA', 3, 'GD011017233', 'D0000001111', '2017-10-29 02:20:09.847', '2017-10-29 02:42:10.927', 551, 2, NULL, 0, 15704250, 548, 11476625, 166, 1020, 7000, 70013, NULL, '522490202754716924')
				--			,(-2147483640, NULL, 0, 'EA2301187AAA', 3, 'GD011017233', 'D00000011BB', '2017-10-29 02:20:09.847', '2017-10-29 02:42:10.927', 551, 2, NULL, 0, 15704250, 548, 11476625, 166, 1020, 7000, 70013, NULL, '522490202754716924')

				---- BULK LOAD IN UNA VARIABILE XML (CONTENITORE) DA OGGETTO DI TIPO "ETL.rawSession_TYPE"
				--SET	@XRS = ETL.BulkXRS(@XRS, @INPUTXRS) -- RIEMPIE IL CONTENITORE XML CON I DATI PRESENTI NELL'OGGETTO DI TIPO "ETL.RAWSESSION_TYPE", RITORNA UNA VARIABILE XML CONTENENTE TUTTE LE COLONNE PRESENTI NELL'OGGETTO IN INGRESSO (@INPUTXRS = ETL.RAWSESSION_TYPE)

---------------------------------------------------------------------------------------------
INSERT @INPUTXRS -- (RowID, UnivocalLocationCode, ServerTime, MachineID, GD, AamsMachineCode, GameID, GameName, VLTCredit, TotalBet, TotalWon, TotalBillIn, TotalCoinIn, TotalTicketIn, TotalHandPay, TotalTicketOut, Tax, TotalIn, TotalOut, WrongFlag, TicketCode, FlagMinVltCredit)  -- * ELENCO PARAMETRI OPZIONALE *
VALUES
		 (NULL, NULL, 0, 'EA2301187BBB', 3, 'GD011017233' , 'D0000002222', '2017-10-29 02:20:09.847', '2017-10-29 02:42:10.927', 551, 2, NULL, 0, 15704250, 548, 11476625, 166, 1020, 7000, 70013, NULL, '522490202754716924')
		,(NULL, NULL, 0, 'EA1100860CCC', 9, 'GD012028334' , 'D0000003333', '2017-10-29 02:02:10.467', '2017-10-29 02:40:29.070', 1090, 8, NULL, 0, 111807250, 1080, 29199565, 277, 286596, 40000, 110017, NULL, '50149147153424875')
		,(NULL, NULL, 0, 'EA9101402DDD', 13, 'GD009003460', 'D0000004444', '2017-10-29 02:00:04.770', '2017-10-29 02:23:49.347' ,337, 2,NULL, 0, 6111850, 334, 2580075, 86,18810, 10000, 100046, NULL, '556604200274145003')
		,(NULL, NULL, 0, 'EA1100860EEE', 9, 'GD012028334' , 'D0000005555', '2017-10-29 02:02:10.467', '2017-10-29 02:40:29.070', 1090, 8,NULL, 0, 111645400, 1080,29013990, 276, 285342, 40000, 110017, NULL, '50149147153424875')
		,(NULL, NULL, 0, 'EA2301187FFF', 13, 'GD011017233', 'D0000006666', '2017-10-29 02:20:09.847', '2017-10-29 02:42:10.927' ,551, 2,NULL, 0, 15704250, 548,11476625, 166, 1020, 7000, 70013, NULL, '522490202754716924')

-- BULK LOAD IN UNA VARIABILE XML (CONTENITORE) DA OGGETTO DI TIPO "ETL.rawSession_TYPE"
SET	@XRS = ETL.BulkXRS(@XRS, @INPUTXRS) -- RIEMPIE IL CONTENITORE XML CON I DATI PRESENTI NELL'OGGETTO DI TIPO "ETL.RAWSESSION_TYPE", RITORNA UNA VARIABILE XML CONTENENTE TUTTE LE COLONNE PRESENTI NELL'OGGETTO IN INGRESSO (@INPUTXRS = ETL.RAWSESSION_TYPE)

SELECT * FROM ETL.GetAllXRS(@XRS) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
PRINT(CONVERT(varchar(MAX),@XRS))
*/
ALTER FUNCTION [ETL].[BulkXRS]
				(
					@XMLrawSession XML
					,@INPUTXRS ETL.RAWSESSION_TYPE READONLY
				)
RETURNS XML
AS
BEGIN
	DECLARE 
			@returnXRS XML = NULL
			,@lastID bigint


	SELECT	@lastID = IIF(MAX(SessionID) IS NULL,-2147483649,MAX(SessionID)-2)
	FROM	@INPUTXRS

	SET @returnXRS =
		(
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
						@lastID+ROW_NUMBER() OVER(ORDER BY SessionID DESC) AS SessionID
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
			) I
			FOR XML RAW('XRS'), TYPE
		)
	RETURN  @returnXRS
END