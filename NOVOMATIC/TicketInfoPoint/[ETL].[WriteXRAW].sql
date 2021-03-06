/*
DECLARE @XRAW XML -- VUOTO
SET	@XRAW = ETL.WriteXRAW(@XRAW, @RowID,@ServerTime,@MachineTime,@MachineID,@GameID,@LoginFlag,@TotalBet,@Win,@GamesPlayed,@GamesWon,@TotalHandpay,@TotalHPCC,@TotalJPCC,@TotalRemote,@TotalWon,@TotalDrop,@TotalIn,@TotalOut,@TotalBillIn,@TotalBillChange,@TotalCoinIn,@TotalCoinInDrop,@TotalCoinInHopper,@TotalHopperOut,@TotalHopperFill,@TotalTicketIn,@TotalTicketOut,@TotalBillInNumber,@BillIn1,@BillIn2,@BillIn3,@BillIn4,@BillIn5,@BillIn6,@BillIn7,@BillIn8,@TotalBillChangeNumber,@BillChange1,@BillChange2,@BillChange3,@BillChange4,@BillChange5,@BillChange6,@BillChange7,@TotalCoinInNumber,@CoinIn3,@CoinIn4,@CoinIn5,@CoinIn6,@CoinIn7,@CoinIn8,@TotalCoinInDropNumber,@CoinInDrop3,@CoinInDrop4,@CoinInDrop5,@CoinInDrop6,@CoinInDrop7,@CoinInDrop8,@TotalCoinInHopperNumber,@CoinInHopper3,@CoinInHopper4,@TicketInA,@TicketInB,@TicketInC,@TicketOutA,@TicketOutB,@TicketOutC,@CurrentCreditA,@CurrentCreditB,@CurrentCreditC,@TotalBetA,@TotalBetB,@TotalBetC,@WinA,@WinB,@WinC,@WinD,@TotalHPCCA)

SELECT * FROM ETL.GetXRAW(@XRAW, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI

PRINT(CONVERT(varchar(MAX),@XRAW))
*/
ALTER FUNCTION [ETL].[WriteXRAW]
				(
					@XMLRAWDATA XML = NULL
					,@RowID int = NULL -- NOT = NULL
					,@ServerTime datetime = NULL -- NULLABLE
					,@MachineTime datetime = NULL -- NULLABLE
					,@MachineID tinyint = NULL -- NULLABLE
					,@GameID int = NULL -- NULLABLE
					,@LoginFlag bit = NULL -- NULLABLE
					,@TotalBet int = NULL -- NULLABLE
					,@Win int = NULL -- NULLABLE
					,@GamesPlayed int = NULL -- NULLABLE
					,@GamesWon int = NULL -- NULLABLE
					,@TotalHandpay int = NULL -- NULLABLE
					,@TotalHPCC int = NULL -- NULLABLE
					,@TotalJPCC int = NULL -- NULLABLE
					,@TotalRemote int = NULL -- NULLABLE
					,@TotalWon int = NULL -- NULLABLE
					,@TotalDrop int = NULL -- NULLABLE
					,@TotalIn int = NULL -- NULLABLE
					,@TotalOut int = NULL -- NULLABLE
					,@TotalBillIn int = NULL -- NULLABLE
					,@TotalBillChange int = NULL -- NULLABLE
					,@TotalCoinIn int = NULL -- NULLABLE
					,@TotalCoinInDrop int = NULL -- NULLABLE
					,@TotalCoinInHopper int = NULL -- NULLABLE
					,@TotalHopperOut int = NULL -- NULLABLE
					,@TotalHopperFill int = NULL -- NULLABLE
					,@TotalTicketIn int = NULL -- NULLABLE
					,@TotalTicketOut int = NULL -- NULLABLE
					,@TotalBillInNumber int = NULL -- NULLABLE
					,@BillIn1 smallint = NULL -- NULLABLE
					,@BillIn2 smallint = NULL -- NULLABLE
					,@BillIn3 smallint = NULL -- NULLABLE
					,@BillIn4 smallint = NULL -- NULLABLE
					,@BillIn5 smallint = NULL -- NULLABLE
					,@BillIn6 smallint = NULL -- NULLABLE
					,@BillIn7 smallint = NULL -- NULLABLE
					,@BillIn8 smallint = NULL -- NULLABLE
					,@TotalBillChangeNumber smallint = NULL -- NULLABLE
					,@BillChange1 smallint = NULL -- NULLABLE
					,@BillChange2 smallint = NULL -- NULLABLE
					,@BillChange3 smallint = NULL -- NULLABLE
					,@BillChange4 smallint = NULL -- NULLABLE
					,@BillChange5 smallint = NULL -- NULLABLE
					,@BillChange6 smallint = NULL -- NULLABLE
					,@BillChange7 smallint = NULL -- NULLABLE
					,@TotalCoinInNumber smallint = NULL -- NULLABLE
					,@CoinIn3 smallint = NULL -- NULLABLE
					,@CoinIn4 smallint = NULL -- NULLABLE
					,@CoinIn5 smallint = NULL -- NULLABLE
					,@CoinIn6 smallint = NULL -- NULLABLE
					,@CoinIn7 smallint = NULL -- NULLABLE
					,@CoinIn8 smallint = NULL -- NULLABLE
					,@TotalCoinInDropNumber smallint = NULL -- NULLABLE
					,@CoinInDrop3 smallint = NULL -- NULLABLE
					,@CoinInDrop4 smallint = NULL -- NULLABLE
					,@CoinInDrop5 smallint = NULL -- NULLABLE
					,@CoinInDrop6 smallint = NULL -- NULLABLE
					,@CoinInDrop7 smallint = NULL -- NULLABLE
					,@CoinInDrop8 smallint = NULL -- NULLABLE
					,@TotalCoinInHopperNumber int = NULL -- NULLABLE
					,@CoinInHopper3 int = NULL -- NULLABLE
					,@CoinInHopper4 int = NULL -- NULLABLE
					,@TicketInA int = NULL -- NULLABLE
					,@TicketInB int = NULL -- NULLABLE
					,@TicketInC int = NULL -- NULLABLE
					,@TicketOutA int = NULL -- NULLABLE
					,@TicketOutB int = NULL -- NULLABLE
					,@TicketOutC int = NULL -- NULLABLE
					,@CurrentCreditA int = NULL -- NULLABLE
					,@CurrentCreditB int = NULL -- NULLABLE
					,@CurrentCreditC int = NULL -- NULLABLE
					,@TotalBetA int = NULL -- NULLABLE
					,@TotalBetB int = NULL -- NULLABLE
					,@TotalBetC int = NULL -- NULLABLE
					,@WinA int = NULL -- NULLABLE
					,@WinB int = NULL -- NULLABLE
					,@WinC int = NULL -- NULLABLE
					,@WinD int = NULL -- NULLABLE
					,@TotalHPCCA int = NULL -- NULLABLE
				)
RETURNS XML
AS
BEGIN
	DECLARE	@outputRAWDATA ETL.RAWDATA_TYPE 

	INSERT	@outputRAWDATA(ServerTime , MachineTime , MachineID , GameID , LoginFlag , TotalBet , Win , GamesPlayed , GamesWon , TotalHandpay , TotalHPCC , TotalJPCC , TotalRemote , TotalWon , TotalDrop , TotalIn , TotalOut , TotalBillIn , TotalBillChange , TotalCoinIn , TotalCoinInDrop , TotalCoinInHopper , TotalHopperOut , TotalHopperFill , TotalTicketIn , TotalTicketOut , TotalBillInNumber , BillIn1 , BillIn2 , BillIn3 , BillIn4 , BillIn5 , BillIn6 , BillIn7 , BillIn8 , TotalBillChangeNumber , BillChange1 , BillChange2 , BillChange3 , BillChange4 , BillChange5 , BillChange6 , BillChange7 , TotalCoinInNumber , CoinIn3 , CoinIn4 , CoinIn5 , CoinIn6 , CoinIn7 , CoinIn8 , TotalCoinInDropNumber , CoinInDrop3 , CoinInDrop4 , CoinInDrop5 , CoinInDrop6 , CoinInDrop7 , CoinInDrop8 , TotalCoinInHopperNumber , CoinInHopper3 , CoinInHopper4 , TicketInA , TicketInB , TicketInC , TicketOutA , TicketOutB , TicketOutC , CurrentCreditA , CurrentCreditB , CurrentCreditC , TotalBetA , TotalBetB , TotalBetC , WinA , WinB , WinC , WinD , TotalHPCCA)
	SELECT	ServerTime , MachineTime , MachineID , GameID , LoginFlag , TotalBet , Win , GamesPlayed , GamesWon , TotalHandpay , TotalHPCC , TotalJPCC , TotalRemote , TotalWon , TotalDrop , TotalIn , TotalOut , TotalBillIn , TotalBillChange , TotalCoinIn , TotalCoinInDrop , TotalCoinInHopper , TotalHopperOut , TotalHopperFill , TotalTicketIn , TotalTicketOut , TotalBillInNumber , BillIn1 , BillIn2 , BillIn3 , BillIn4 , BillIn5 , BillIn6 , BillIn7 , BillIn8 , TotalBillChangeNumber , BillChange1 , BillChange2 , BillChange3 , BillChange4 , BillChange5 , BillChange6 , BillChange7 , TotalCoinInNumber , CoinIn3 , CoinIn4 , CoinIn5 , CoinIn6 , CoinIn7 , CoinIn8 , TotalCoinInDropNumber , CoinInDrop3 , CoinInDrop4 , CoinInDrop5 , CoinInDrop6 , CoinInDrop7 , CoinInDrop8 , TotalCoinInHopperNumber , CoinInHopper3 , CoinInHopper4 , TicketInA , TicketInB , TicketInC , TicketOutA , TicketOutB , TicketOutC , CurrentCreditA , CurrentCreditB , CurrentCreditC , TotalBetA , TotalBetB , TotalBetC , WinA , WinB , WinC , WinD , TotalHPCCA 
	FROM	ETL.GetAllXRAW(@XMLRAWDATA)
	UNION ALL
	SELECT	
			@ServerTime AS ServerTime 
			,@MachineTime AS MachineTime 
			,@MachineID AS MachineID 
			,@GameID AS GameID 
			,@LoginFlag AS LoginFlag 
			,@TotalBet AS TotalBet 
			,@Win AS Win 
			,@GamesPlayed AS GamesPlayed 
			,@GamesWon AS GamesWon 
			,@TotalHandpay AS TotalHandpay 
			,@TotalHPCC AS TotalHPCC 
			,@TotalJPCC AS TotalJPCC 
			,@TotalRemote AS TotalRemote 
			,@TotalWon AS TotalWon 
			,@TotalDrop AS TotalDrop 
			,@TotalIn AS TotalIn 
			,@TotalOut AS TotalOut 
			,@TotalBillIn AS TotalBillIn 
			,@TotalBillChange AS TotalBillChange 
			,@TotalCoinIn AS TotalCoinIn 
			,@TotalCoinInDrop AS TotalCoinInDrop 
			,@TotalCoinInHopper AS TotalCoinInHopper 
			,@TotalHopperOut AS TotalHopperOut 
			,@TotalHopperFill AS TotalHopperFill 
			,@TotalTicketIn AS TotalTicketIn 
			,@TotalTicketOut AS TotalTicketOut 
			,@TotalBillInNumber AS TotalBillInNumber 
			,@BillIn1 AS BillIn1 
			,@BillIn2 AS BillIn2 
			,@BillIn3 AS BillIn3 
			,@BillIn4 AS BillIn4 
			,@BillIn5 AS BillIn5 
			,@BillIn6 AS BillIn6 
			,@BillIn7 AS BillIn7 
			,@BillIn8 AS BillIn8 
			,@TotalBillChangeNumber AS TotalBillChangeNumber 
			,@BillChange1 AS BillChange1 
			,@BillChange2 AS BillChange2 
			,@BillChange3 AS BillChange3 
			,@BillChange4 AS BillChange4 
			,@BillChange5 AS BillChange5 
			,@BillChange6 AS BillChange6 
			,@BillChange7 AS BillChange7 
			,@TotalCoinInNumber AS TotalCoinInNumber 
			,@CoinIn3 AS CoinIn3 
			,@CoinIn4 AS CoinIn4 
			,@CoinIn5 AS CoinIn5 
			,@CoinIn6 AS CoinIn6 
			,@CoinIn7 AS CoinIn7 
			,@CoinIn8 AS CoinIn8 
			,@TotalCoinInDropNumber AS TotalCoinInDropNumber 
			,@CoinInDrop3 AS CoinInDrop3 
			,@CoinInDrop4 AS CoinInDrop4 
			,@CoinInDrop5 AS CoinInDrop5 
			,@CoinInDrop6 AS CoinInDrop6 
			,@CoinInDrop7 AS CoinInDrop7 
			,@CoinInDrop8 AS CoinInDrop8 
			,@TotalCoinInHopperNumber AS TotalCoinInHopperNumber 
			,@CoinInHopper3 AS CoinInHopper3 
			,@CoinInHopper4 AS CoinInHopper4 
			,@TicketInA AS TicketInA 
			,@TicketInB AS TicketInB 
			,@TicketInC AS TicketInC 
			,@TicketOutA AS TicketOutA 
			,@TicketOutB AS TicketOutB 
			,@TicketOutC AS TicketOutC 
			,@CurrentCreditA AS CurrentCreditA 
			,@CurrentCreditB AS CurrentCreditB 
			,@CurrentCreditC AS CurrentCreditC 
			,@TotalBetA AS TotalBetA 
			,@TotalBetB AS TotalBetB 
			,@TotalBetC AS TotalBetC 
			,@WinA AS WinA 
			,@WinB AS WinB 
			,@WinC AS WinC 
			,@WinD AS WinD 
			,@TotalHPCCA AS TotalHPCCA 

	RETURN(
		SELECT	I.*
		FROM(
			SELECT	RowID, ServerTime , MachineTime , MachineID , GameID , LoginFlag , TotalBet , Win , GamesPlayed , GamesWon , TotalHandpay , TotalHPCC , TotalJPCC , TotalRemote , TotalWon , TotalDrop , TotalIn , TotalOut , TotalBillIn , TotalBillChange , TotalCoinIn , TotalCoinInDrop , TotalCoinInHopper , TotalHopperOut , TotalHopperFill , TotalTicketIn , TotalTicketOut , TotalBillInNumber , BillIn1 , BillIn2 , BillIn3 , BillIn4 , BillIn5 , BillIn6 , BillIn7 , BillIn8 , TotalBillChangeNumber , BillChange1 , BillChange2 , BillChange3 , BillChange4 , BillChange5 , BillChange6 , BillChange7 , TotalCoinInNumber , CoinIn3 , CoinIn4 , CoinIn5 , CoinIn6 , CoinIn7 , CoinIn8 , TotalCoinInDropNumber , CoinInDrop3 , CoinInDrop4 , CoinInDrop5 , CoinInDrop6 , CoinInDrop7 , CoinInDrop8 , TotalCoinInHopperNumber , CoinInHopper3 , CoinInHopper4 , TicketInA , TicketInB , TicketInC , TicketOutA , TicketOutB , TicketOutC , CurrentCreditA , CurrentCreditB , CurrentCreditC , TotalBetA , TotalBetB , TotalBetC , WinA , WinB , WinC , WinD , TotalHPCCA 
			FROM	@outputRAWDATA
		) I
		FOR XML RAW('RAW'), TYPE
	)

END