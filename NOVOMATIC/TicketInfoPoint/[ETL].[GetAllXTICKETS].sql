/*
DECLARE @XTICKETS XML -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)
SET	@XTICKETS = ETL.WriteXTICKETS(@XTICKETS,        1, 1000002, '309551976638606413',         4000,    'GD014017411',                 27, '2015-11-17 18:49:27.000',  'GD014017652',               26, '2015-11-17 18:49:46.000',               0,                   0, '2016-02-15 18:49:27.000',       NULL,       NULL,         NULL,                NULL) -- CARICA UN ELEMENTO AL CONTENITORE (ex [TMP].[TicketStart])
SELECT * FROM ETL.GetAllXTICKETS(@XTICKETS)
*/
ALTER FUNCTION	[ETL].[GetAllXTICKETS](
				@XMLtickets XML = NULL
)
RETURNS TABLE
AS
RETURN(
	SELECT 
			T.c.value('@BatchID', 'int') AS BatchID
			,T.c.value('@ClubID', 'int') AS ClubID									
			,T.c.value('@TicketCode', 'varchar(50)') AS TicketCode					
			,T.c.value('@TicketValue', 'int') AS TicketValue						
			,T.c.value('@PrintingMachine', 'varchar(20)') AS PrintingMachine		
			,T.c.value('@PrintingMachineID', 'smallint') AS PrintingMachineID		
			,T.c.value('@PrintingDate', 'datetime') AS PrintingDate					
			,T.c.value('@PayoutMachine', 'varchar(20)') AS PayoutMachine			
			,T.c.value('@PayoutMachineID', 'smallint') AS PayoutMachineID			
			,T.c.value('@PayoutDate', 'datetime') AS PayoutDate						
			,T.c.value('@IsPaidCashDesk', 'bit') AS IsPaidCashDesk					
			,T.c.value('@IsPrintingCashDesk', 'bit') AS IsPrintingCashDesk			
			,T.c.value('@ExpireDate', 'datetime') AS ExpireDate						
			,T.c.value('@EventDate', 'datetime') AS EventDate						
			,T.c.value('@MhMachine', 'varchar(30)') AS MhMachine					
			,T.c.value('@MhMachineID', 'smallint') AS MhMachineID					
			,T.c.value('@CreationChangeDate', 'datetime') AS CreationChangeDate		
	FROM	@XMLtickets.nodes('TICKETS') AS T(c) 
) 

/*
*/