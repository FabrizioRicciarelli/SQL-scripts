CREATE TYPE [ETL].[TICKET_TYPE] AS TABLE(
			Clubid              int 
			,Ticketcode         varchar(40) 
			,Ticketvalue        int 
			,Printingmachine    varchar(20) 
			,Printingmachineid  smallint 
			,Printingdate       datetime 
			,Payoutmachine      varchar(20) 
			,Payoutmachineid    smallint 
			,Payoutdate         datetime 
			,Ispaidcashdesk     bit 
			,Isprintingcashdesk bit 
			,Expiredate         datetime 
			,Eventdate          datetime 
			,Mhmachine          varchar(30) 
			,Mhmachineid        smallint 
			,Creationchangedate datetime 
)
GO


