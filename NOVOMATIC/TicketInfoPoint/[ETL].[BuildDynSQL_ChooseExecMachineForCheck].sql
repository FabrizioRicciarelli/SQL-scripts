/*
DECLARE 
		@OUTERSQL Nvarchar(MAX)
		,@ConcessionaryName varchar(20) = 'GMatica'
		,@ClubID varchar(10) = '1000002'

SET @OUTERSQL = N'SELECT TableExists FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + [ETL].[BuildDynSQL_TableExists] ('AGS_RawData', 'RawData', @ClubID) + ''')'
SELECT [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQL) AS DynSQL

SET @OUTERSQL = N'SELECT ViewExists FROM OPENQUERY([' + ISNULL(@ConcessionaryName,'') + N'_PIN01\DW],''' + [ETL].[BuildDynSQL_ViewExists] ('AGS_RawData', 'RawData_View', @ClubID) + ''')'
SELECT [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQL) AS DynSQL

SET @OUTERSQL = REPLACE([ETL].[BuildDynSQL_TableInfo] ( @ConcessionaryName + '_AGS_RawData', 'RawData_View', @ClubID),'''''','''')
SELECT [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQL) AS DynSQL

SET @OUTERSQL = REPLACE([ETL].[BuildDynSQL_ViewInfo] ( @ConcessionaryName + '_AGS_RawData', 'RawData_View', @ClubID, 0),'''''','''')
SELECT [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQL) AS DynSQL

SET @OUTERSQL = REPLACE([ETL].[BuildDynSQL_ViewExists] (@ConcessionaryName + '_AGS_RawData', 'RawData_View', @ClubID),'''''','''')
SELECT [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (@OUTERSQL) AS DynSQL

*/
ALTER FUNCTION [ETL].[BuildDynSQL_ChooseExecMachineForCheck] (
				@OUTERSQL Nvarchar(MAX)
)
RETURNS Nvarchar(MAX)
AS
BEGIN
	DECLARE @retVal Nvarchar(MAX)
	SELECT	@retVal = 
			CASE	
				WHEN	@@SERVERNAME LIKE '%DEV%' -- DETERMINA L'AMBIENTE SUL QUALE E' IN ESECUZIONE LA CORRENTE STORED PROCEDURE
				THEN	N'SELECT @returnValue = (SELECT * FROM OPENQUERY([POM-MON01],''' + REPLACE(@OUTERSQL,'''','''''') + '''))' -- QUERY PER ESECUZIONE IN AMBIENTE DI SVILUPPO  
				ELSE	N'SELECT @returnValue = (' + @OUTERSQL + ')' -- QUERY PER ESECUZIONE IN AMBIENTE DI PRODUZIONE
			END
	
	--RETURN REPLACE(@retVal,CHAR(39), CHAR(39) + CHAR(39))
	RETURN @retVal
END