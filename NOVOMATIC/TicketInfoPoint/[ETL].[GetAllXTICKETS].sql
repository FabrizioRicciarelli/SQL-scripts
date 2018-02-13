/*
-- NOTA: AD ECCEZIONE DELLE COLONNE batchid E clubid, LA TABELLA TMP.TICKET HA GLI STESSI IDENTICI CAMPI (RICORDARSI DELLA DIFFORMITA' TRA PrintingDatA/E e PayoutDatA/E)

DECLARE @XTICKETS XML -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)

SET	@XTICKETS = ETL.GetAllXTICKETS(@XTICKETS)
*/
ALTER FUNCTION	[ETL].[GetAllXTICKETS](
				@XMLtickets XML = NULL
)
RETURNS TABLE
AS
RETURN(
	SELECT 
			T.c.value('@BatchID', 'int') AS batchid
			,T.c.value('@ClubID', 'int') AS clubid
			,T.c.value('@TicketCode', 'varchar(50)') AS ticketcode
			,T.c.value('@TicketValue', 'int') AS ticketvalue
			,T.c.value('@PrintingMachine', 'varchar(20)') AS printingmachine
			,T.c.value('@PrintingMachineID', 'smallint') AS printingmachineid
			,T.c.value('@PrintingDate', 'datetime') AS printingdate
			,T.c.value('@PayoutMachine', 'varchar(20)') AS payoutmachine
			,T.c.value('@PayoutMachineID', 'smallint') AS payoutmachineid
			,T.c.value('@PayoutDate', 'datetime') AS payoutdate
			,T.c.value('@IsPaidCashDesk', 'bit') AS ispaidcashdesk
			,T.c.value('@IsPrintingCashDesk', 'bit') AS isprintingcashdesk
			,T.c.value('@ExpireDate', 'datetime') AS expiredate
			,T.c.value('@EventDate', 'datetime') AS eventdate
			,T.c.value('@MhMachine', 'varchar(30)') AS mhmachine
			,T.c.value('@MhMachineID', 'smallint') AS mhmachineid
			,T.c.value('@CreationChangeDate', 'datetime') AS creationchangedate
	FROM	@XMLtickets.nodes('TICKETS') AS T(c) 
) 
