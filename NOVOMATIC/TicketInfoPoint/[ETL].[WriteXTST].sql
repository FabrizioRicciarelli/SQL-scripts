/*
-- TST - ex TicketServerTime

DECLARE @XTST XML -- VUOTO
--SET	@XTST = ETL.WriteXTST(@XTST,@ServerTime,@IterationNum,@Rn,@DifferenceSS,@Direction,@MachineID)

SET	@XTST = ETL.WriteXTST(@XTST,'2017-01-01',1,1,25,0,22)
SET	@XTST = ETL.WriteXTST(@XTST,'2017-01-01',1,1,32,0,22)
SELECT * FROM ETL.GetAllXTST(@XTST) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI

PRINT(CONVERT(varchar(MAX),@XTST))
*/
ALTER FUNCTION [ETL].[WriteXTST]
				(
					@XMLtst XML = NULL
					,@ServerTime datetime2(3) NULL
					,@IterationNum tinyint NULL
					,@Rn smallint NULL
					,@DifferenceSS int NULL
					,@Direction bit NULL
					,@MachineID smallint NULL
				)
RETURNS XML
AS
BEGIN
	DECLARE 
			@returnXTST XML = NULL
			,@inputTST ETL.TST_TYPE
			,@outputTST ETL.TST_TYPE
			,@lastID int


	IF ISNULL(@ServerTime,'') != ''
		BEGIN
			IF @XMLTST IS NOT NULL
				BEGIN
					INSERT @inputTST
					SELECT
							ServerTime
							,IterationNum
							,Rn
							,DifferenceSS
							,Direction
							,MachineID
					FROM	ETL.GetXTST(@XMLTST, NULL, NULL, NULL, NULL, NULL, NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
				END

			IF NOT EXISTS (SELECT * FROM @inputTST)
				BEGIN
					INSERT 	@outputTST
							(
								ServerTime
								,IterationNum
								,Rn
								,DifferenceSS
								,Direction
								,MachineID
							) 
							VALUES 
							(
								 @ServerTime
								,@IterationNum
								,@Rn
								,@DifferenceSS
								,@Direction
								,@MachineID
							)
				END
			ELSE
				BEGIN
					INSERT	@outputTST
					SELECT	
							ServerTime
							,IterationNum
							,Rn
							,DifferenceSS
							,Direction
							,MachineID
					FROM	@inputTST
					UNION ALL
					SELECT	
							 I.ServerTime AS ServerTime
							,I.IterationNum AS IterationNum
							,I.Rn AS Rn
							,I.DifferenceSS	AS DifferenceSS
							,I.Direction AS Direction
							,I.MachineID AS MachineID
					FROM
					(
						SELECT 
								@ServerTime AS ServerTime
								,@IterationNum AS IterationNum
								,@Rn AS Rn
								,@DifferenceSS AS DifferenceSS
								,@Direction AS Direction
								,@MachineID AS MachineID
					) I 
				END 
		END

	SET @returnXTST =
		(
				SELECT 	
						ServerTime
						,IterationNum
						,Rn
						,DifferenceSS
						,Direction
						,MachineID
				FROM	@outputTST 
				FOR XML RAW('TST'), TYPE
		)
	RETURN  @returnXTST
END