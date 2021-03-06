/*
SELECT [ETL].[BuildDynSQL_TicketsNoMHx] (NULL) AS DynSQL
SELECT [ETL].[BuildDynSQL_TicketsNoMHx] ('TOP 1000') AS DynSQL

DECLARE @SQL Nvarchar(MAX) = 'SELECT * FROM OPENQUERY([GMATICA_PIN01\DW],'''
		,@FromDate datetime = '2017-07-01'
		,@ToDate datetime = '2017-07-06'
SET @SQL += REPLACE(
				REPLACE(
					[ETL].[BuildDynSQL_TicketsNoMHx] (NULL)
					,'$'
					,
					'
					AND TD.MachineID = 17 
					AND TD.ClubID = 1000252 
					AND ((CreationTime BETWEEN '''+ QUOTENAME(CONVERT(varchar(26),@FromDate,126),CHAR(39)) + ''' AND ''' + QUOTENAME(CONVERT(varchar(26),@ToDate,126),CHAR(39)) + ''') OR (PayoutTime BETWEEN '''+ QUOTENAME(CONVERT(varchar(26),@FromDate,126),CHAR(39)) + ''' AND ''' + QUOTENAME(CONVERT(varchar(26),@ToDate,126),CHAR(39)) + '''))
					'
				)
				,CHAR(39)
				,CHAR(39)+CHAR(39)
			) + ''')'
SELECT @SQL
EXEC(@SQL) AT [POM-MON01]
*/
ALTER FUNCTION [ETL].[BuildDynSQL_TicketsNoMHx] (@TopRows Nvarchar(20) = NULL)
RETURNS Nvarchar(MAX)
AS
BEGIN
	DECLARE @retVal Nvarchar(MAX)
	SET @retVal = 
N'
SET NOCOUNT ON;
SET FMTONLY OFF;
DECLARE	@TicketsNoMHx TABLE(
		ClubID int
		,TicketCode varchar(50)
		,TicketValue int
		,PrintingMachine varchar(30)
		,PrintingMachineID int
		,PrintingDate datetime
		,PayoutMachine varchar(30)
		,PayoutMachineID int
		,PayoutDate datetime
		,IsPaidCashDesk bit
		,IsPrintingCashDesk bit
		,ExpireDate datetime
		,EventDate datetime
		,MhMachine varchar(30)
		,MhMachineID int
		,CreationChangeDate datetime
)
INSERT	@TicketsNoMHx
SELECT	' + ISNULL(@TopRows,'') + ' 
		ST.ClubID AS ClubID
		,ST.TicketCode AS TicketCode
		,ST.TicketValue AS TicketValue
		,ST.PrintingMachine	AS PrintingMachine
		,ST.PrintingMachineID AS PrintingMachineID
		,ST.PrintingDate AS PrintingDate
		,ST.PayoutMachine AS PayoutMachine
		,ST.PayoutMachineID	AS PayoutMachineID
		,ST.PayoutDate AS PayoutDate
		,ST.IsPaidCashDesk AS IsPaidCashDesk
		,ST.IsPrintingCashDesk AS IsPrintingCashDesk
		,ST.ExpireDate AS ExpireDate
		,NULL AS EventDate
		,NULL AS MhMachine
		,NULL AS MhMachineID
		,NULL AS CreationChangeDate 
FROM	 
(
	SELECT 
			ClubID
			,TicketCode 
			,TicketValue
			,PrintingMachine
			,PrintingMachineID
			,PrintingDate
			,PayoutMachine
			,PayoutMachineID
			,PayoutDate
			,IsPaidCashDesk
			,IsPrintingCashDesk
			,ExpireDate
	FROM	OPENQUERY(
		[SQL-FINANCE\SQL_FINANCE]
		,''
		SELECT	
				TD.ClubID AS ClubID 
				,TD.TicketID AS TicketCode 
				,CAST(((CashA+CashB+CashC) * 100) AS BIGINT) AS TicketValue
				,LEFT(LTRIM(CM.CertificateName), 11) AS PrintingMachine 
				,TD.MachineID AS PrintingMachineID
				,CreationTime AS PrintingDate
				,LEFT(LTRIM(PM.CertificateName), 11) AS PayoutMachine 
				,TD.PayoutMachineID AS PayoutMachineID
				,PayoutTime as PayoutDate
				,IsPaidCashDesk = IIF(PayoutUserID IS NOT NULL, 1, 0)
				,IsPrintingCashDesk = IIF(UserID IS NOT NULL, 1, 0)
				,ExpireTime AS ExpireDate
		FROM	NucleusDB.Tito.TicketData TD (NOLOCK)   
				LEFT OUTER JOIN 
				NucleusDB.Config.Machine CM (NOLOCK) 
				ON TD.ClubId = CM.ClubId 
				AND TD.MachineId = CM.RecId 
				LEFT OUTER JOIN 
				NucleusDB.Config.Machine PM (NOLOCK) 
				ON TD.ClubId = PM.ClubId 
				AND TD.PayoutMachineId = PM.RecId 
				LEFT OUTER JOIN 
				NucleusDB.Users.UsersSite US (NOLOCK) 
				ON TD.ClubId = US.ClubId 
				AND TD.UserId = US.RecId
				LEFT OUTER JOIN 
				NucleusDB.Users.UsersSite PS (NOLOCK) 
				ON TD.ClubId = PS.ClubId 
				AND TD.PayoutUserId = PS.RecId
		WHERE	1 = 1 
		$ -- SOSTITUIRE CON LA WHERECONDITION DI PIU BASSO LIVELLO
		''
	)
) ST 

SELECT			
		ClubID
		,TicketCode
		,TicketValue
		,PrintingMachine
		,PrintingMachineID
		,PrintingDate
		,PayoutMachine
		,PayoutMachineID
		,PayoutDate
		,IsPaidCashDesk
		,IsPrintingCashDesk
		,ExpireDate
		,EventDate
		,MhMachine
		,MhMachineID
		,CreationChangeDate
FROM	@TicketsNoMHx
' 
	RETURN @retVal
END