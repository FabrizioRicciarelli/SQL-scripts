/*
SET NOCOUNT ON;

DECLARE 
		@XTICKETS XML -- VUOTO
		,@INPUTtickets ETL.TICKET_TYPE

-- RIEMPIMENTO OGGETTO DI TIPO "ETL.TICKET_TYPE"
INSERT	@INPUTtickets -- * ELENCO PARAMETRI OPZIONALE *
VALUES	
		 (@Clubid, @Ticketcode, @Ticketvalue, @Printingmachine, @Printingmachineid, @Printingdate, @Payoutmachine, @Payoutmachineid, @Payoutdate, @Ispaidcashdesk, @Isprintingcashdesk, @Expiredate, @Eventdate, @Mhmachine, @Mhmachineid, @Creationchangedate)	
		,(@Clubid, @Ticketcode, @Ticketvalue, @Printingmachine, @Printingmachineid, @Printingdate, @Payoutmachine, @Payoutmachineid, @Payoutdate, @Ispaidcashdesk, @Isprintingcashdesk, @Expiredate, @Eventdate, @Mhmachine, @Mhmachineid, @Creationchangedate)
		,(@Clubid, @Ticketcode, @Ticketvalue, @Printingmachine, @Printingmachineid, @Printingdate, @Payoutmachine, @Payoutmachineid, @Payoutdate, @Ispaidcashdesk, @Isprintingcashdesk, @Expiredate, @Eventdate, @Mhmachine, @Mhmachineid, @Creationchangedate)
		,(@Clubid, @Ticketcode, @Ticketvalue, @Printingmachine, @Printingmachineid, @Printingdate, @Payoutmachine, @Payoutmachineid, @Payoutdate, @Ispaidcashdesk, @Isprintingcashdesk, @Expiredate, @Eventdate, @Mhmachine, @Mhmachineid, @Creationchangedate)

-- BULK LOAD IN UNA VARIABILE XML (CONTENITORE) DA OGGETTO DI TIPO "ETL.TICKET_TYPE"
SET	@XTICKETS = ETL.BulkXTTC(@XTICKETS, @INPUTtickets) -- RIEMPIE IL CONTENITORE XML CON I DATI PRESENTI NELL'OGGETTO DI TIPO "ETL.TICKET_TYPE", RITORNA UNA VARIABILE XML CONTENENTE TUTTE LE COLONNE PRESENTI NELL'OGGETTO IN INGRESSO (@INPUTtickets = ETL.TICKET_TYPE)

SELECT * FROM ETL.GetXTICKETS(@XMLtickets, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) FOR XML PATH('TICKET'), ROOT('ROWS'), TYPE -- RITORNA L'ELENCO COMPLETO IN FORMA XML

*/
ALTER FUNCTION [ETL].[BulkXTICKETS]
				(
					@XMLtickets XML
					,@INPUTtickets ETL.TICKET_TYPE READONLY
				)
RETURNS XML
AS
BEGIN
	DECLARE 
			@returnXTICKETS XML = NULL
			,@outputTICKETS ETL.TICKET_TYPE
			,@lastID int

	IF EXISTS (SELECT TOP 1 * FROM @INPUTtickets)
		BEGIN
			INSERT 	@outputTICKETS
					(
						clubid             
						,ticketcode        
						,ticketvalue       
						,printingmachine   
						,printingmachineid 
						,printingdate      
						,payoutmachine     
						,payoutmachineid   
						,payoutdate        
						,ispaidcashdesk    
						,isprintingcashdesk
						,expiredate        
						,eventdate         
						,mhmachine         
						,mhmachineid       
						,creationchangedate
					) 
			SELECT
					clubid             
					,ticketcode        
					,ticketvalue       
					,printingmachine   
					,printingmachineid 
					,printingdate      
					,payoutmachine     
					,payoutmachineid   
					,payoutdate        
					,ispaidcashdesk    
					,isprintingcashdesk
					,expiredate        
					,eventdate         
					,mhmachine         
					,mhmachineid       
					,creationchangedate
			FROM	ETL.GetXTICKETS(@XMLtickets, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
			UNION ALL
			SELECT	
					clubid             
					,ticketcode        
					,ticketvalue       
					,printingmachine   
					,printingmachineid 
					,printingdate      
					,payoutmachine     
					,payoutmachineid   
					,payoutdate        
					,ispaidcashdesk    
					,isprintingcashdesk
					,expiredate        
					,eventdate         
					,mhmachine         
					,mhmachineid       
					,creationchangedate
			FROM	@INPUTtickets
		END

	SET @returnXTICKETS =
		(
				SELECT 	
						clubid             
						,ticketcode        
						,ticketvalue       
						,printingmachine   
						,printingmachineid 
						,printingdate      
						,payoutmachine     
						,payoutmachineid   
						,payoutdate        
						,ispaidcashdesk    
						,isprintingcashdesk
						,expiredate        
						,eventdate         
						,mhmachine         
						,mhmachineid       
						,creationchangedate
				FROM	@outputTICKETS 
				FOR XML RAW('TICKETS'), TYPE
		)
	RETURN  @returnXTICKETS
END