-- I NODI NULLI NON VENGONO UPDATATI: TRASFORMARE IN TABELLA L'XML, AGGIORNARE A VALORI NON NULLI E RICOSTRUIRE L'XML E QUINDI EFFETTUARE L'UPDATE TRAMITE LA PRESENTE FUNZIONE
DECLARE	
		@XTMPTicketStart	XML
		,@ClubID			int = 1000002
		,@BatchID			int = 1

SET	@XTMPTicketStart = ETL.WriteXTICKETS(@XTMPTicketStart, NULL, 1000002, '309551976638606413',4000,'GD014017411',27, '2015-11-17 18:49:27.000','GD014017652',26,'2015-11-17 18:49:46.000',NULL,NULL, '2016-02-15 18:49:27.000',NULL,NULL,NULL,'2016-01-01 00:00:00.000')

SET	@XTMPTicketStart = (SELECT * FROM	ETL.GetAllXTICKETS(@XTMPTicketStart) FOR XML RAW('TICKETS'), ELEMENTS XSINIL)
SELECT 
		T.c.value(' (BatchID)[1]', 'int') AS BatchID
		,T.c.value('(ClubID)[1]', 'int') AS ClubID									
		,T.c.value('(TicketCode)[1]', 'varchar(50)') AS TicketCode					
		,T.c.value('(TicketValue)[1]', 'int') AS TicketValue						
		,T.c.value('(PrintingMachine)[1]', 'varchar(20)') AS PrintingMachine		
		,T.c.value('(PrintingMachineID)[1]', 'smallint') AS PrintingMachineID		
		,T.c.value('(PrintingDate)[1]', 'datetime') AS PrintingDate					
		,T.c.value('(PayoutMachine)[1]', 'varchar(20)') AS PayoutMachine			
		,T.c.value('(PayoutMachineID)[1]', 'smallint') AS PayoutMachineID			
		,T.c.value('(PayoutDate)[1]', 'datetime') AS PayoutDate						
		,T.c.value('(IsPaidCashDesk)[1]', 'bit') AS IsPaidCashDesk					
		,T.c.value('(IsPrintingCashDesk)[1]', 'bit') AS IsPrintingCashDesk			
		,T.c.value('(ExpireDate)[1]', 'datetime') AS ExpireDate						
		,T.c.value('(EventDate)[1]', 'datetime') AS EventDate						
		,T.c.value('(MhMachine)[1]', 'varchar(30)') AS MhMachine					
		,T.c.value('(MhMachineID)[1]', 'smallint') AS MhMachineID					
		,T.c.value('(CreationChangeDate)[1]', 'datetime') AS CreationChangeDate		
FROM	@XTMPTicketStart.nodes('//TICKETS') AS T(c)
FOR XML RAW('TICKETS'), TYPE 
