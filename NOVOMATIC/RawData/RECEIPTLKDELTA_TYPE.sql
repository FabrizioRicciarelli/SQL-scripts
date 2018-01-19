CREATE TYPE RECEIPTLKDELTA_TYPE AS TABLE(
	ReceiptID int PRIMARY KEY NOT NULL
	,RowID int NOT NULL
	,SessionID int NULL
	,TicketWayID tinyint NULL
	,ReceiptMatchTypeID tinyint NULL
	,DifferenceMatchType smallint NULL
	,Congruity tinyint NULL
)
