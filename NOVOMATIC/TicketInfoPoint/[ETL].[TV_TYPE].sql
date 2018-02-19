CREATE TYPE [ETL].[TV_TYPE] AS TABLE 
(
	ObjectName sysname NULL
	,RowsCount bigint 
	,MinDate datetime
	,MaxDate datetime
)
GO
