/*
DECLARE @XTICKETS XML -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)

SET	@XTICKETS = ETL.GetXTICKETS(@XTICKETS, @Batchid, @Clubid, @Ticketcode, @Ticketvalue, @Printingmachine, @Printingmachineid, @Printingdate, @Payoutmachine, @Payoutmachineid, @Payoutdate, @Ispaidcashdesk, @Isprintingcashdesk, @Expiredate, @Eventdate, @Mhmachine, @Mhmachineid, @Creationchangedate) -- ELENCA GLI ELEMENTI DEL CONTENITORE
*/
ALTER FUNCTION	[ETL].[GetXTICKETS](
				@XMLtickets XML = NULL
				,@Batchid            int 
				,@Clubid             int 
				,@Ticketcode         varchar(40) 
				,@Ticketvalue        int 
				,@Printingmachine    varchar(20) 
				,@Printingmachineid  smallint 
				,@Printingdate       datetime 
				,@Payoutmachine      varchar(20) 
				,@Payoutmachineid    smallint 
				,@Payoutdate         datetime 
				,@Ispaidcashdesk     bit 
				,@Isprintingcashdesk bit 
				,@Expiredate         datetime 
				,@Eventdate          datetime 
				,@Mhmachine          varchar(30) 
				,@Mhmachineid        smallint 
				,@Creationchangedate datetime 
)
RETURNS @returnTICKETS TABLE(
		batchid             int 
		,clubid             int 
		,ticketcode         varchar(40) 
		,ticketvalue        int 
		,printingmachine    varchar(20) 
		,printingmachineid  smallint 
		,printingdate       datetime 
		,payoutmachine      varchar(20) 
		,payoutmachineid    smallint 
		,payoutdate         datetime 
		,ispaidcashdesk     bit 
		,isprintingcashdesk bit 
		,expiredate         datetime 
		,eventdate          datetime 
		,mhmachine          varchar(30) 
		,mhmachineid        smallint 
		,creationchangedate datetime 
)
AS
BEGIN
	INSERT	@returnTICKETS
	SELECT
			 I.batchid             
			,I.clubid             
			,I.ticketcode        
			,I.ticketvalue       
			,I.printingmachine   
			,I.printingmachineid 
			,I.printingdate      
			,I.payoutmachine     
			,I.payoutmachineid   
			,I.payoutdate        
			,I.ispaidcashdesk    
			,I.isprintingcashdesk
			,I.expiredate        
			,I.eventdate         
			,I.mhmachine         
			,I.mhmachineid       
			,I.creationchangedate
	FROM
	(
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
	) I
	WHERE	(batchid = @Batchid OR @Batchid IS NULL)
	AND		(clubid = @Clubid OR @Clubid IS NULL)
	AND		(ticketcode = @Ticketcode OR @Ticketcode IS NULL)
	AND		(ticketvalue = @Ticketvalue OR @Ticketvalue IS NULL)
	AND		(printingmachine = @Printingmachine OR @Printingmachine IS NULL)
	AND		(printingmachineid = @Printingmachineid OR @Printingmachineid IS NULL)
	AND		(printingdate = @Printingdate OR @Printingdate IS NULL)
	AND		(payoutmachine = @Payoutmachine OR @Payoutmachine IS NULL)
	AND		(payoutmachineid = @Payoutmachineid OR @Payoutmachineid IS NULL)
	AND		(payoutdate = @Payoutdate OR @Payoutdate IS NULL)
	AND		(ispaidcashdesk = @Ispaidcashdesk OR @Ispaidcashdesk IS NULL)
	AND		(isprintingcashdesk = @Isprintingcashdesk OR @Isprintingcashdesk IS NULL)
	AND		(expiredate = @Expiredate OR @Expiredate IS NULL)
	AND		(eventdate = @Eventdate OR @Eventdate IS NULL)
	AND		(mhmachine = @Mhmachine OR @Mhmachine IS NULL)
	AND		(mhmachineid = @Mhmachineid OR @Mhmachineid IS NULL)
	AND		(creationchangedate = @Creationchangedate OR @Creationchangedate IS NULL)

	RETURN
END
