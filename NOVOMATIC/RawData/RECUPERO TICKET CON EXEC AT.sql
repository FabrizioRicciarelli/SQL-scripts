EXEC(
'
SELECT	
		ClubID
		,TicketCode
		,Ticketvalue
		,PrintingDate
		,PrintingMachine
		,PrintingMachineID
		,PayOutDate
		,PayOutMachine
		,PayOutMachineID 
		,IsPrintingCashDesk
		,IsPaidCashDesk
		,ExpireDate
		,EventDate
		,MhMachine
		,MhMachineID
		,CreationChangeDate
FROM	AGS_ETL.Ticket.Extract
'
)
AT [GMatica_Pin01\DW]