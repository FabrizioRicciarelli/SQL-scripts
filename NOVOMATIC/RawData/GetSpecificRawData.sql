USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[GetSpecificRawData]    Script Date: 18/07/2017 16:40:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Template NIS (1.1 - 2015-04-01) 

███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
████╗  ██║██╔═══██╗██║   ██║██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
██║╚██╗██║██║   ██║╚██╗ ██╔╝██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
██║ ╚████║╚██████╔╝ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚═╝  ╚═══╝ ╚═════╝   ╚═══╝   ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
                                                                            
Author..............: FR
Creation Date.......: 2017-07-13
Description.........: Estrazione mirata dei RawData

Revision 1			 

Note
- Use [Tab size] = 2 and [Indent size]

------------------
-- Parameters   --
------------------	
@ConcessionaryName sysname
@ClubID varchar(10)	
@CSVfields varchar(MAX) -- ad eccezione delle colonne "RowID, ServerTime, MachineID" che sono già incluse
@criteria varchar(MAX)

------------------
-- Call Example --
------------------  
DECLARE	
		@MachineID tinyint = 53
		,@wherecondition varchar(MAX)
		,@ToOut varchar(20) = '2016-01-01'
		,@ServerTime_FIRST datetime = '1900-01-01 00:00:00.000'
		,@ServerTime_Last datetime = '2050-12-31 00:00:00.000'

		-- Set di colonne
		,@CSVcolumns varchar(MAX) = 'MAX(ServerTime) AS ServerTime'

		-- Set completo di colonne
		--,@CSVcolumns varchar(MAX) = ', MachineTime, GameID, LoginFlag, TotalBet, Win, GamesPlayed, GamesWon, TotalHandpay, TotalHPCC, TotalJPCC, TotalRemote, TotalWon, TotalDrop, TotalIn, TotalOut, TotalBillIn, TotalBillChange, TotalCoinIn, TotalCoinInDrop, TotalCoinInHopper, TotalHopperOut, TotalHopperFill, TotalTicketIn, TotalTicketOut, TotalBillInNumber, BillIn1, BillIn2, BillIn3, BillIn4, BillIn5, BillIn6, BillIn7, BillIn8, TotalBillChangeNumber, BillChange1, BillChange2, BillChange3, BillChange4, BillChange5, BillChange6, BillChange7, TotalCoinInNumber, CoinIn3, CoinIn4, CoinIn5, CoinIn6, CoinIn7, CoinIn8, TotalCoinInDropNumber, CoinInDrop3, CoinInDrop4, CoinInDrop5, CoinInDrop6, CoinInDrop7, CoinInDrop8, TotalCoinInHopperNumber, CoinInHopper3, CoinInHopper4, TicketInA, TicketInB, TicketInC, TicketOutA, TicketOutB, TicketOutC, CurrentCreditA, CurrentCreditB, CurrentCreditC, TotalBetA, TotalBetB, TotalBetC, WinA, WinB, WinC, WinD, TotalHPCCA'


SET @wherecondition =
'
AND		TotalOut > 0 
AND		MachineID = ' + CAST(@MachineID AS varchar(10)) + '
AND		LoginFlag = 0 
AND		ServerTime < ''' + @ToOut + '''
'

EXEC	GetSpecificRawData
		@ConcessionaryName = 'GMATICA'
		,@ClubID = '1000296'
		,@CSVfields = @CSVcolumns
		,@criteria = @wherecondition

*/
ALTER PROC [dbo].[GetSpecificRawData]
			@ConcessionaryName sysname = NULL	
			,@ClubID varchar(10) = NULL	
			,@CSVfields varchar(MAX) = NULL	
			,@criteria varchar(MAX) = NULL
			,@grouping varchar(MAX) = NULL
AS
SET NOCOUNT ON;

IF ISNULL(@ConcessionaryName,'') != ''
AND  ISNULL(@ClubID,'') != ''
AND  ISNULL(@CSVfields,'') != ''
	BEGIN
		DECLARE 
				@SQL Nvarchar(MAX)
				,@Position sysname
				,@RawDataDB sysname
				,@RawDataDB_01 sysname
				,@subcriteriaDB nvarchar(MAX)
				,@subcriteriaDB_01 nvarchar(MAX)

		SELECT	TOP 1
				@RawDataDB = @ConcessionaryName + '_AGS_RawData' 
				,@RawDataDB_01 = @ConcessionaryName + '_AGS_RawData_01' 

		SELECT	
				@subcriteriaDB =
				CASE
					WHEN ISNULL(@criteria,'') LIKE '%ServerTime%'
					THEN @criteria
					ELSE 'AND ServerTime >= ''20151117'''
				END
				,@subcriteriaDB_01 =
				CASE
					WHEN ISNULL(@criteria,'') LIKE '%ServerTime%'
					THEN @criteria
					ELSE 'AND (ServerTime BETWEEN ''20120101'' AND  ''20151117'')'
				END

		SET @SQL =
		N'
		IF	EXISTS 
			(
				SELECT	name 
				FROM	master.sys.databases 
				WHERE	name = N''' + @RawDataDB_01 + '''
			)
		AND	EXISTS
			(
				SELECT	TOP 1 
						TBL.name 
				FROM	[' + @RawDataDB_01 +'].sys.tables TBL
						JOIN 
						[' + @RawDataDB_01 +'].sys.partitions PART 
						ON TBL.object_id = PART.object_id
						JOIN 
						[' + @RawDataDB_01 +'].sys.indexes IDX 
						ON PART.object_id = IDX.object_id
						JOIN 
						[' + @RawDataDB_01 +'].sys.schemas SCH 
						ON TBL.schema_id = SCH.schema_id
				WHERE	TBL.name = ''RawData'' 
				AND		SCH.Name = ''' + @ClubID + '''
			)			  
			BEGIN
				SELECT
						*--' + @CSVfields + '
				FROM
				(
					SELECT	
							' + @CSVfields + '
					FROM	[' + @RawDataDB_01 +'].[' + @ClubID + '].[RawData] WITH(NOLOCK)
					WHERE	1 = 1
					' + @subcriteriaDB_01 + ' ' + ISNULL(@grouping,'') + 
					'
					UNION ALL
					SELECT	
							' + @CSVfields + '
					FROM	[' + @RawDataDB +'].[' + @ClubID + '].[RawData] WITH(NOLOCK)
					WHERE	1 = 1
					' + @subcriteriaDB + ' ' + ISNULL(@grouping,'') +
					'
				) U
			END
		ELSE
			BEGIN
				SELECT
						' + @CSVfields + '
				FROM	[' + @RawDataDB +'].[' + @ClubID + '].[RawData] WITH(NOLOCK)
				WHERE	1 = 1
				' + ISNULL(@criteria,'') + ' ' + ISNULL(@grouping,'') + '
			END
		'
		PRINT(@SQL)
		EXEC sp_executesql @SQL
	END