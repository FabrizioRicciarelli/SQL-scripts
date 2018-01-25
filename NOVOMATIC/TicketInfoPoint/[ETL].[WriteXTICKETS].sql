/*
DECLARE @XTICKETS XML -- VUOTO

SET	@XTICKETS = ETL.WriteXTICKETS(@XTICKETS, @Clubid, @Ticketcode, @Ticketvalue, @Printingmachine, @Printingmachineid, @Printingdate, @Payoutmachine, @Payoutmachineid, @Payoutdate, @Ispaidcashdesk, @Isprintingcashdesk, @Expiredate, @Eventdate, @Mhmachine, @Mhmachineid, @Creationchangedate) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)

*/
ALTER FUNCTION [ETL].[WriteXTICKETS](
				@XMLtickets XML
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
RETURNS XML
AS
BEGIN
	DECLARE 
			@returnXTICKETS XML = NULL
			,@inputTICKETS ETL.TICKET_TYPE
			,@outputTICKETS ETL.TICKET_TYPE

	IF ISNULL(@Clubid,0) != 0
	AND ISNULL(@Ticketcode,'') != ''
		BEGIN
			IF @XMLtickets IS NOT NULL
				BEGIN
					INSERT @inputTICKETS
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
				END

			IF NOT EXISTS (SELECT * FROM @inputTICKETS)
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
							VALUES 
							(
								 @clubid             
								,@ticketcode        
								,@ticketvalue       
								,@printingmachine   
								,@printingmachineid 
								,@printingdate      
								,@payoutmachine     
								,@payoutmachineid   
								,@payoutdate        
								,@ispaidcashdesk    
								,@isprintingcashdesk
								,@expiredate        
								,@eventdate         
								,@mhmachine         
								,@mhmachineid       
								,@creationchangedate
							)
				END
			ELSE
				BEGIN
					INSERT	@outputTICKETS
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
					FROM	@inputTICKETS
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
					FROM
					(
						SELECT 
								@clubid AS clubid
								,@ticketcode AS ticketcode
								,@ticketvalue AS ticketvalue
								,@printingmachine AS printingmachine
								,@printingmachineid AS printingmachineid
								,@printingdate AS printingdate
								,@payoutmachine AS payoutmachine
								,@payoutmachineid AS payoutmachineid
								,@payoutdate AS payoutdate
								,@ispaidcashdesk AS ispaidcashdesk
								,@isprintingcashdesk AS isprintingcashdesk
								,@expiredate AS expiredate
								,@eventdate AS eventdate
								,@mhmachine AS mhmachine
								,@mhmachineid AS mhmachineid
								,@creationchangedate AS creationchangedate
					) I 
				END 
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