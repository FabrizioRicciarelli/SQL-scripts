/*
SELECT [ETL].[BuildDynSQL_TicketsMHx_1] (NULL) AS DynSQL
SELECT [ETL].[BuildDynSQL_TicketsMHx_1] ('TOP 1000') AS DynSQL

DECLARE @SQL Nvarchar(MAX) = 'SELECT * FROM OPENQUERY([GMATICA_PIN01\DW],'''
SET @SQL += REPLACE([ETL].[BuildDynSQL_TicketsMHx_1] ('TOP 1000'), CHAR(39), CHAR(39)+CHAR(39)) + ''')'
PRINT(@SQL)
EXEC(@SQL) AT [POM-MON01] 
*/
ALTER FUNCTION [ETL].[BuildDynSQL_TicketsMHx_1] (@TopRows Nvarchar(20) = NULL)
RETURNS Nvarchar(MAX)
AS
BEGIN
	DECLARE @retVal Nvarchar(MAX)
	SET @retVal = 
			N'
			SELECT	' + ISNULL(@TopRows,'') + ' 
					ST.ClubID
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
					,ST.EventDate 
					,MhMachine = 
						CASE  
							WHEN	LEN(LEFT(RTRIM(LTRIM(M.LabelID)), 11)) < 11 
							AND		LEFT(RTRIM(LTRIM(M.LabelID)), 11) NOT LIKE ''GD%'' 
							THEN	UPPER(LEFT(RTRIM(LTRIM(M.CertificateName)), 11))  
							ELSE	UPPER(LEFT(RTRIM(LTRIM(M.LabelID)), 11))   
						END
					,ST.MachineID AS MhMachineID
					,RegDateTime AS CreationChangeDate 
			FROM	 
			(
				SELECT 
						ClubId
						,Receipt 
						,Value
						,EventDate
						,MachineID
						,Type
						,ObjectId
						,RecId
						,RegDateTime
				FROM	OPENQUERY -- Consente di superare questo errore: "Xml data type is not supported in distributed queries"
				(
					[SQL-FINANCE\SQL_FINANCE]
					,''
					SELECT 
							ClubId
							,Receipt
							,CAST((CAST(ST.AddInfo.value(''''(/CHandpayVoucherInfo//EventValue/node())[1]'''', ''''nvarchar(30)'''') AS  DECIMAL(13,2)) * 100) AS INT) AS Value
							,EventDate = 
								CASE 
									WHEN ST.Type = 36 
									THEN ST.AddInfo.value(''''(/CHandpayVoucherInfo//EventDateTime/node())[1]'''', ''''datetime'''') 
									WHEN ST.Type IN (21, 22, 26, 27) 
									THEN ST.AddInfo.value(''''(/CMachineEventInfo//EventDateTime/node())[1]'''', ''''datetime'''') 
									ELSE NULL
								END  
							,ST.AddInfo.value(''''(/CHandpayVoucherInfo//MachID/node())[1]'''', ''''int'''') AS MachineID
							,Type
							,ObjectId
							,RecId
							,RegDateTime
					FROM	[NucleusDB].[Cashdesk].[ShiftTransaction] ST WITH(NOLOCK)
					''
				)
			)		ST 
					INNER JOIN 
					[SQL-FINANCE\SQL_FINANCE].[NucleusDB].[Cashdesk].[ShiftTranCurrency] STC WITH(NOLOCK) 
					ON STC.ClubId = ST.ClubId 
					AND STC.TransactionId = ST.RecId 
					LEFT OUTER JOIN 
					[SQL-FINANCE\SQL_FINANCE].[NucleusDB].[Config].[Machine] M WITH(NOLOCK) 
					ON M.ClubId = ST.ClubId 
					AND M.RecId = ST.ObjectId 
			WHERE	ST.[Type] IN (21, 22, 26, 27, 36)
			'
	RETURN @retVal
END