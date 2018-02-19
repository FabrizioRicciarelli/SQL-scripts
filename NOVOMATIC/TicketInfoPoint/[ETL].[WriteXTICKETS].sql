/*
DECLARE @XTICKETS XML -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)
SET	@XTICKETS = ETL.WriteXTICKETS(@XTICKETS,1, 1000002, '309551976638606413',4000,'GD014017411',27, '2015-11-17 18:49:27.000','GD014017652',26,'2015-11-17 18:49:46.000',0,0, '2016-02-15 18:49:27.000','2016-03-01 00:00:0.000','GD014017652',26,'2016-01-01 00:00:00.000') -- CARICA UN ELEMENTO AL CONTENITORE (ex [TMP].[TicketStart])
SET	@XTICKETS = ETL.WriteXTICKETS(@XTICKETS,2, 1000002, '309551976638606413',4000,'GD014017411',27, '2015-11-17 18:49:27.000','GD014017652',26,'2015-11-17 18:49:46.000',0,0, '2016-02-15 18:49:27.000','2016-03-01 00:00:0.000','GD014017652',26,'2016-01-01 00:00:00.000') -- CARICA UN ELEMENTO AL CONTENITORE (ex [TMP].[TicketStart])
SELECT * FROM ETL.GetAllXTICKETS(@XTICKETS)
*/
ALTER FUNCTION [ETL].[WriteXTICKETS](
				@XMLtickets			 XML
				,@BatchID            int 
				,@ClubID             int 
				,@TicketCode         varchar(40) 
				,@TicketValue        int 
				,@PrintingMachine    varchar(20) 
				,@PrintingMachineID  smallint 
				,@PrintingDate       datetime 
				,@PayoutMachine      varchar(20) 
				,@PayoutMachineID    smallint 
				,@PayoutDate         datetime 
				,@IsPaidCashDesk     bit 
				,@IsPrintingCashDesk bit 
				,@ExpireDate         datetime 
				,@EventDate          datetime 
				,@MHMachine          varchar(30) 
				,@MHMachineID        smallint 
				,@CreationChangeDate datetime 
)
RETURNS XML
AS
BEGIN
	RETURN (
		SELECT *
		FROM (
			SELECT
					BatchID            
					,ClubID             
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
					,MHMachine          
					,MHMachineID        
					,CreationChangeDate 
			FROM	ETL.GetAllXTICKETS(@XMLtickets)
			UNION ALL
			SELECT	
					@BatchID AS BatchID
					,@ClubID AS ClubID
					,@TicketCode AS TicketCode
					,@TicketValue AS TicketValue
					,@PrintingMachine AS PrintingMachine
					,@PrintingMachineID AS PrintingMachineID
					,@PrintingDate AS PrintingDate
					,@PayoutMachine AS PayoutMachine
					,@PayoutMachineID AS PayoutMachineID
					,@PayoutDate AS PayoutDate
					,@IsPaidCashDesk AS IsPaidCashDesk
					,@IsPrintingCashDesk AS IsPrintingCashDesk
					,@ExpireDate AS ExpireDate
					,@EventDate AS EventDate
					,@MHMachine AS MHMachine
					,@MHMachineID AS MHMachineID
					,@CreationChangeDate AS CreationChangeDate
		) I
		FOR XML RAW('TICKETS'), TYPE
	)
END