/*

*/
ALTER PROC ETL.WriteTTC
			@CurrentTTC ETL.TTC_TYPE READONLY
			,@TicketCode varchar(50) = NULL
			,@FlagCalc bit = NULL
			,@SessionID int = NULL
			,@SessionParentID int = NULL
			,@Level int = NULL
AS

IF ISNULL(@TicketCode,'') != ''
AND ISNULL(@FlagCalc,0) != 0
	BEGIN
		DECLARE @returnTTC ETL.TTC_TYPE

		-- COPIA TUTTO IL CONTENUTO DELLA TABELLA
		-- CORRENTEMENTE IN MEMORIA NEL NUOVO
		-- CONTENITORE
		INSERT	@returnTTC
				(
					ticketcode 
					,flagcalc 
					,sessionid 
					,sessionparentid 
					,level
				) 
		SELECT 
					ticketcode 
					,flagcalc 
					,sessionid 
					,sessionparentid 
					,level
		FROM	@CurrentTTC
		
		-- AGGIUNGE AL NUOVO CONTENITORE 
		-- L'ELEMENTO SPECIFICATO DAI
		-- PARAMETRI IN INGRESSO	
		INSERT	@returnTTC
				(
					ticketcode 
					,flagcalc 
					,sessionid 
					,sessionparentid 
					,level
				) 
		SELECT 
				@TicketCode 
				,@FlagCalc
				,@SessionID AS sessionid 
				,@SessionParentID AS sessionparentid
				,@Level AS level 
	END

-- RITORNA IL CONTENITORE AGGIORNATO
SELECT	*
FROM  @returnTTC

