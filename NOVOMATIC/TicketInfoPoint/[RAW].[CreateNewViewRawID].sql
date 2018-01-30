/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██╔██╗ ██║██║   ██║██║   ██║██║   ██║██╔████╔██║███████║   ██║   ██║██║     
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: Jena
Creation Date.......: 2015-11-24 
Description.........: Crea schema, RawID e vista per un nuovo ClubID

Revision			 

Note
- Use [Tab size] = 2 and [Indent size]

------------------
-- Parameters   --
------------------	

------------------
-- Call Example --
------------------  
EXEC [RAW].[CreateNewViewRawID] @ClubID =  1000171
EXEC [RAW].[CreateNewViewRawID] @ClubID =  1000432

*/
ALTER PROCEDURE [RAW].[CreateNewViewRawID]
@ClubID varchar(10) = NULL
AS
BEGIN
DECLARE @VerifyStr NVARCHAR(MAX), @CreateViewStr NVARCHAR(MAX), @Position sysname,  @RawDataDB sysname,@RawDataDB_01 sysname,@ConcessionaryName sysname,
		@FlagDbArchive Bit
-- inizializzo
SELECT @Position = Position,@ConcessionaryName = ConcessionaryName  FROM Config.[Table]

SET @RawDataDB = @ConcessionaryName + '_AGS_RawData'
SET @RawDataDB_01 = @ConcessionaryName + '_AGS_RawData_01'


-- Elimino vista
-- Verifico se c'è Raw_Data_01
SET @VerifyStr = '
Declare @Db01 Bit = NULL
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N''[Tmp].RawData_View'') ) DROP VIEW [Tmp].RawData_View
IF EXISTS(SELECT * FROM [' + @Position + '].[' + @RawDataDB_01 +'].sys.tables TBL
			  INNER JOIN [' + @Position + '].[' + @RawDataDB_01 +'].sys.partitions PART ON TBL.object_id = PART.object_id
			  INNER JOIN [' + @Position + '].[' + @RawDataDB_01 +'].sys.indexes IDX ON PART.object_id = IDX.object_id
			  INNER JOIN [' + @Position + '].[' + @RawDataDB_01 +'].sys.schemas SCH ON TBL.schema_id = SCH.schema_id
			  WHERE TBL.name = ''RawData'' and SCH.Name = ''' + @ClubID + ''')			  
				   Select @Db01 = 1
			  Else Select @Db01 = 0
			  Update [Config].[Table] SET FlagDbArchive = @Db01'

EXEC sp_executesql @VerifyStr

Select @FlagDbArchive = FlagDbArchive From Config.[Table]
 
------------------------------------------------------------------------------------------------------------
-- Creazione Vista                                                                                                 --
------------------------------------------------------------------------------------------------------------
IF @FlagDbArchive = 1

	SET @CreateViewStr = '--Se ho anche o solo RawData_01
			  CREATE view [TMP].[RawData_View]
				AS
				SELECT RowID, ServerTime, MachineTime, MachineID, GameID, LoginFlag, TotalBet, Win, GamesPlayed, GamesWon, TotalHandpay, TotalHPCC, TotalJPCC, TotalRemote, TotalWon, TotalDrop, TotalIn, TotalOut, TotalBillIn, TotalBillChange, TotalCoinIn, TotalCoinInDrop, TotalCoinInHopper, TotalHopperOut, TotalHopperFill, TotalTicketIn, TotalTicketOut, TotalBillInNumber, BillIn1, BillIn2, BillIn3, BillIn4, BillIn5, BillIn6, BillIn7, BillIn8, TotalBillChangeNumber, BillChange1, BillChange2, BillChange3, BillChange4, BillChange5, BillChange6, BillChange7, TotalCoinInNumber, CoinIn3, CoinIn4, CoinIn5, CoinIn6, CoinIn7, CoinIn8, TotalCoinInDropNumber, CoinInDrop3, CoinInDrop4, CoinInDrop5, CoinInDrop6, CoinInDrop7, CoinInDrop8, TotalCoinInHopperNumber, CoinInHopper3, CoinInHopper4, TicketInA, TicketInB, TicketInC, TicketOutA, TicketOutB, TicketOutC, CurrentCreditA, CurrentCreditB, CurrentCreditC, TotalBetA, TotalBetB, TotalBetC, WinA, WinB, WinC, WinD, TotalHPCCA
					   FROM [' + @Position + '].[' + @RawDataDB_01 +'].[' + @ClubID + '].[RawData]
					   WHERE ServerTime >= ''20120101'' AND ServerTime < ''20151117''
				UNION ALL
				SELECT (RowID + 2147483649), ServerTime, MachineTime, MachineID, GameID, LoginFlag, TotalBet, Win, GamesPlayed, GamesWon, TotalHandpay, TotalHPCC, TotalJPCC, TotalRemote, TotalWon, TotalDrop, TotalIn, TotalOut, TotalBillIn, TotalBillChange, TotalCoinIn, TotalCoinInDrop, TotalCoinInHopper, TotalHopperOut, TotalHopperFill, TotalTicketIn, TotalTicketOut, TotalBillInNumber, BillIn1, BillIn2, BillIn3, BillIn4, BillIn5, BillIn6, BillIn7, BillIn8, TotalBillChangeNumber, BillChange1, BillChange2, BillChange3, BillChange4, BillChange5, BillChange6, BillChange7, TotalCoinInNumber, CoinIn3, CoinIn4, CoinIn5, CoinIn6, CoinIn7, CoinIn8, TotalCoinInDropNumber, CoinInDrop3, CoinInDrop4, CoinInDrop5, CoinInDrop6, CoinInDrop7, CoinInDrop8, TotalCoinInHopperNumber, CoinInHopper3, CoinInHopper4, TicketInA, TicketInB, TicketInC, TicketOutA, TicketOutB, TicketOutC, CurrentCreditA, CurrentCreditB, CurrentCreditC, TotalBetA, TotalBetB, TotalBetC, WinA, WinB, WinC, WinD, TotalHPCCA
						FROM [' + @Position + '].[' + @RawDataDB +'].[' + @ClubID + '].[RawData]
						WHERE ServerTime >= ''20151117''
						'
ELSE			  
	SET @CreateViewStr = '			
			 -- Se ho solo RawData
			  CREATE view [TMP].[RawData_View]
					  AS
					  SELECT RowID, ServerTime, MachineTime, MachineID, GameID, LoginFlag, TotalBet, Win, GamesPlayed, GamesWon, TotalHandpay, TotalHPCC, TotalJPCC, TotalRemote, TotalWon, TotalDrop, TotalIn, TotalOut, TotalBillIn, TotalBillChange, TotalCoinIn, TotalCoinInDrop, TotalCoinInHopper, TotalHopperOut, TotalHopperFill, TotalTicketIn, TotalTicketOut, TotalBillInNumber, BillIn1, BillIn2, BillIn3, BillIn4, BillIn5, BillIn6, BillIn7, BillIn8, TotalBillChangeNumber, BillChange1, BillChange2, BillChange3, BillChange4, BillChange5, BillChange6, BillChange7, TotalCoinInNumber, CoinIn3, CoinIn4, CoinIn5, CoinIn6, CoinIn7, CoinIn8, TotalCoinInDropNumber, CoinInDrop3, CoinInDrop4, CoinInDrop5, CoinInDrop6, CoinInDrop7, CoinInDrop8, TotalCoinInHopperNumber, CoinInHopper3, CoinInHopper4, TicketInA, TicketInB, TicketInC, TicketOutA, TicketOutB, TicketOutC, CurrentCreditA, CurrentCreditB, CurrentCreditC, TotalBetA, TotalBetB, TotalBetC, WinA, WinB, WinC, WinD, TotalHPCCA
					  FROM [' + @Position + '].[' + @RawDataDB +'].[' + @ClubID + '].[RawData]
					'
EXEC sp_executesql @CreateViewStr

END
