/*
SELECT [ETL].[BuildDynSQL_TicketsMHx] (NULL) AS DynSQL
SELECT [ETL].[BuildDynSQL_TicketsMHx] ('TOP 1000') AS DynSQL

DECLARE @SQL Nvarchar(MAX) = 'SELECT * FROM OPENQUERY([GMATICA_PIN01\DW],'''
SET @SQL += REPLACE(
				REPLACE(
					REPLACE(
						[ETL].[BuildDynSQL_TicketsMHx] (NULL)
						,'$'
						,' AND ST.ClubID = 1000252 '
					)
					,'#'
					,'-- AND (ST.CreationChangeDate BETWEEN ''20170701'' AND ''20170706'')'
				)
				,CHAR(39)
				,CHAR(39)+CHAR(39)
			) + ''')'
SELECT @SQL
EXEC(@SQL) AT [POM-MON01] 
*/
ALTER FUNCTION [ETL].[BuildDynSQL_TicketsMHx] (@TopRows varchar(20) = NULL)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE 
			@firstPart varchar(MAX)
			,@secondPart varchar(MAX)
			--,@retVal varchar(MAX)
	
	SELECT @firstPart = 
N'
SET NOCOUNT ON;
SET FMTONLY OFF;
DECLARE	@TicketsMHx TABLE(
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
INSERT	@TicketsMHx
SELECT	' + ISNULL(@TopRows,'') + ' 
		ST.ClubID AS ClubID
		,ST.Receipt AS TicketCode
		,ST.Value AS TicketValue
		,NULL AS PrintingMachine
		,NULL AS PrintingMachineID
		,NULL AS PrintingDate
		,NULL AS PayoutMachine
		,NULL AS PayoutMachineID
		,NULL AS PayoutDate
		,0 AS IsPaidCashDesk
		,0 AS IsPrintingCashDesk
		,NULL AS ExpireDate
		,ST.EventDate AS EventDate
		,ST.Machine AS MhMachine
		,ST.MachineID AS MhMachineID
		,ST.RegDateTime AS CreationChangeDate 
FROM	 
(
	SELECT 
			ClubID
			,Receipt 
			,Value
			,EventDate
			,Machine
			,MachineID
			,RegDateTime
	FROM	OPENQUERY(
		[SQL-FINANCE\SQL_FINANCE]
		,''
		SELECT
				ST.ClubID AS ClubID
				,ST.Receipt	AS Receipt
				,CAST ((CAST(ST.AddInfo.value(''''(/CHandpayVoucherInfo//EventValue/node())[1]'''', ''''nvarchar(30)'''') AS  DECIMAL(13,2)) * 100) AS INT) AS Value
				,CASE 
					WHEN	ST.Type = 36 
					THEN	ST.AddInfo.value(''''(/CHandpayVoucherInfo//EventDateTime/node())[1]'''', ''''datetime'''')
					WHEN	ST.Type IN (21, 22, 26, 27) 
					THEN	ST.AddInfo.value(''''(/CMachineEventInfo//EventDateTime/node())[1]'''', ''''datetime'''') 
					ELSE	NULL
				END AS EventDate
				,CASE
					WHEN	LEN(LEFT(RTRIM(LTRIM(M.LabelID)), 11)) < 11 
					THEN	UPPER(LEFT(RTRIM(LTRIM(M.CertificateName)), 11))
					WHEN	LEFT(RTRIM(LTRIM(M.LabelID)), 11) NOT LIKE ''''GD%'''' THEN UPPER(LEFT(RTRIM(LTRIM(M.CertificateName)), 11))
					ELSE	UPPER(LEFT(RTRIM(LTRIM(M.LabelID)), 11))
				END AS Machine
				,ST.AddInfo.value(''''(/CHandpayVoucherInfo//MachID/node())[1]'''', ''''int'''') AS MachineID
				,RegDateTime
		FROM	NucleusDB.Cashdesk.ShiftTransaction ST (NOLOCK)
				INNER JOIN 
				NucleusDB.Cashdesk.ShiftTranCurrency STC (NOLOCK) 
				ON STC.ClubId = ST.ClubId 
				AND STC.TransactionId = ST.RecId
				LEFT OUTER JOIN 
				NucleusDB.Config.Machine M (NOLOCK) 
				ON M.ClubId = ST.ClubId 
				AND M.RecId = ST.ObjectId
		WHERE	ST.Type IN (21, 22, 26, 27,36) 
		$ -- SOSTITUIRE CON LA WHERECONDITION DI PIU BASSO LIVELLO
		''
	)
)		ST 
# -- SOSTITUIRE CON LA WHERECONDITION DI PIU ALTO LIVELLO
'
	
	SELECT @secondPart = 
'
IF @@ROWCOUNT < 1
	BEGIN
		INSERT	@TicketsMHx
		SELECT	' + ISNULL(@TopRows,'') + ' 
				ST.ClubID AS ClubID
				,ST.Receipt AS TicketCode
				,ST.Value AS TicketValue
				,NULL AS PrintingMachine
				,NULL AS PrintingMachineID
				,NULL AS PrintingDate
				,NULL AS PayoutMachine
				,NULL AS PayoutMachineID
				,NULL AS PayoutDate
				,0 AS IsPaidCashDesk
				,0 AS IsPrintingCashDesk
				,NULL AS ExpireDate
				,ST.EventDate AS EventDate
				,ST.Machine AS MhMachine
				,ST.MachineID AS MhMachineID
				,ST.RegDateTime AS CreationChangeDate 
		FROM	 
		(
			SELECT 
					ClubID
					,Receipt 
					,Value
					,EventDate
					,Machine
					,MachineID
					,RegDateTime
			FROM	OPENQUERY(
				[SQL-FINANCE\SQL_FINANCE]
				,''
				SELECT 
						ST.ClubID AS ClubID
						,ST.Receipt AS Receipt
						,Value = CASE 
							WHEN ST.Type = 36 THEN CAST ((CAST(ST.AddInfo.value(''''(/CHandpayVoucherInfo//HandpayInfo/EventValue/node())[1]'''', ''''nvarchar(30)'''') AS  DECIMAL(13,2)) * 100) AS INT)
							WHEN ST.Type IN (21, 22, 26, 27) THEN CAST ((CAST (ST.AddInfo.value(''''(/CMachineEventInfo//EventValue/node())[1]'''', ''''nvarchar(30)'''') AS  DECIMAL(13,2)) * 100) AS INT)
							ELSE NULL
						END
						,EventDate = CASE 
							WHEN ST.Type = 36 THEN ST.AddInfo.value(''''(CHandpayVoucherInfo//HandpayInfo/EventDateTime/node())[1]'''', ''''datetime'''')
							WHEN ST.Type IN (21, 22, 26, 27) THEN ST.AddInfo.value(''''(/CMachineEventInfo//EventDateTime/node())[1]'''', ''''datetime'''') 
							ELSE NULL
						END
						,Machine = CASE
							 WHEN LEN(LEFT(RTRIM(LTRIM(M.LabelID)), 11)) < 11 THEN UPPER(LEFT(RTRIM(LTRIM(M.CertificateName)), 11))
							 WHEN LEFT(RTRIM(LTRIM(M.LabelID)), 11) NOT LIKE ''''GD%'''' THEN UPPER(LEFT(RTRIM(LTRIM(M.CertificateName)), 11))
							 ELSE UPPER(LEFT(RTRIM(LTRIM(M.LabelID)), 11))
						END 
						,MachineID = CASE 
							WHEN ST.Type = 36 THEN ST.AddInfo.value(''''(/CHandpayVoucherInfo//HandpayInfo/MachID/node())[1]'''', ''''int'''') 
							WHEN ST.Type IN (21, 22, 26, 27) THEN ST.AddInfo.value(''''(/CMachineEventInfo//MachID/node())[1]'''', ''''int'''')
							ELSE NULL
						END 
						,RegDateTime
				FROM	NucleusDB.Cashdesk.ShiftTranClosed ST (NOLOCK)
						INNER JOIN 
						NucleusDB.Cashdesk.ShiftTranCurrency STC (NOLOCK) 
						ON STC.ClubId = ST.ClubId 
						AND STC.TransactionId = ST.RecId
						LEFT OUTER JOIN 
						NucleusDB.Config.Machine M (NOLOCK) 
						ON M.ClubId = ST.ClubId 
						AND M.RecId = ST.ObjectId
				WHERE	ST.Type IN (21, 22, 26, 27,36) 
				$ -- SOSTITUIRE CON LA WHERECONDITION DI PIU BASSO LIVELLO
				''
			)
		)		ST 
	# -- SOSTITUIRE CON LA WHERECONDITION DI PIU ALTO LIVELLO
	END

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
FROM	@TicketsMHx
'
		 
	RETURN CAST(@firstPart AS varchar(MAX)) + CAST(@secondPart AS varchar(MAX))
END