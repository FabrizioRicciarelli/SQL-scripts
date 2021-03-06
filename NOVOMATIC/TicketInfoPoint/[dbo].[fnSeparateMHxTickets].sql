/*
SELECT * FROM dbo.fnSeparateMHxTickets('479194386004564610,369456253604773261,525764475876923475,181340809208629093,1000002MHR201103140009,1000252HPV201703170001')
*/	  
ALTER FUNCTION [dbo].[fnSeparateMHxTickets](@CSVtickets varchar(MAX))
RETURNS @RETVAL TABLE (NOMHxTickets varchar(MAX), MHxTickets varchar(MAX))
AS
BEGIN
	IF LEN(ISNULL(@CSVtickets,'')) > 10
	AND ISNULL(@CSVtickets,'') LIKE '%,%'
		BEGIN
			DECLARE 
					@NOMHxTickets varchar(MAX) = NULL
					,@MHxTickets varchar(MAX) = NULL

			DECLARE	@TICKETS TABLE
					(
						TicketCode varchar(50)
						,IsMHx bit
					)
			
			INSERT	@TICKETS(TicketCode, IsMHx)
			SELECT	Value AS TicketCode, IsMHx = IIF(value LIKE '%[a-zA-Z]%', 1, 0) 
			FROM	dbo.STRING_SPLIT(@CSVtickets,',')

			SELECT	@NOMHxTickets = COALESCE(@NOMHxTickets + ',', '') + TicketCode 
			FROM	@TICKETS
			WHERE	IsMHx = 0

			SELECT	@MHxTickets = COALESCE(@MHxTickets + ',', '') + TicketCode
			FROM	@TICKETS
			WHERE	IsMHx = 1

			INSERT	@RETVAL(NOMHxTickets, MHxTickets)
			SELECT	@NOMHxTickets, @MHxTickets
		END

	RETURN
END