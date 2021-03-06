/*
DECLARE @XCONFIG XML -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)
SET	@XCONFIG = ETL.WriteXCONFIG(@XCONFIG, 7, 'POM-MON01', 25, 45, 7200, 50, 'GMatica', 1, 1) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)
SELECT * FROM ETL.GetAllXCONFIG(@XCONFIG)
*/
ALTER	FUNCTION [ETL].[GetAllXCONFIG](
		@XMLconfig XML = NULL
)
RETURNS TABLE
AS
RETURN
(
	SELECT 
			T.c.value('@ConcessionaryID', 'tinyint') AS ConcessionaryID
			,T.c.value('@Position', 'varchar(50)') AS Position
			,T.c.value('@OffSetIN', 'smallint') AS OffSetIN
			,T.c.value('@OffSetOut', 'smallint') AS OffSetOut
			,T.c.value('@OffSetMh', 'int') AS OffSetMh
			,T.c.value('@MinVltEndCredit', 'int') AS MinVltEndCredit
			,T.c.value('@ConcessionaryName', 'varchar(50)') AS ConcessionaryName
			,T.c.value('@FlagDbArchive', 'bit') AS FlagDbArchive
			,T.c.value('@OffsetRawData', 'int') AS OffsetRawData
	FROM	@XMLconfig.nodes('CONFIG') AS T(c) 
)