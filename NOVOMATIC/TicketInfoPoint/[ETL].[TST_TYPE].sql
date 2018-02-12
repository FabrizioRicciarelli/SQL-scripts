/*
TST - ex TicketServerTime
*/
CREATE TYPE [ETL].[TST_TYPE] AS TABLE (
	ServerTime datetime2(3) NULL
	,IterationNum tinyint NULL
	,Rn smallint NULL
	,DifferenceSS int NULL
	,Direction bit NULL
	,MachineID smallint NULL
)
GO


