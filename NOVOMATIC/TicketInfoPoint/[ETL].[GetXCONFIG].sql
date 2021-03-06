/*
DECLARE @XCONFIG XML -- DICHIARAZIONE DI UN CONTENITORE (INIZIALMENTE E' VUOTO)

SET	@XCONFIG = ETL.WriteXCONFIG(@XCONFIG, 7, 'POM-MON01', 25, 45, 7200, 50, 'GMatica', 1, 1) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)

			--ETL.GetXCONFIG(@XCONFIG XML, @ConcessionaryID tinyint = NULL, @Position varchar(50) = NULL, @OffSetIN smallint = NULL, @OffSetOut smallint = NULL, @OffSetMh int = NULL, @MinVltEndCredit int = NULL, @ConcessionaryName varchar(50) = NULL, @FlagDbArchive bit = NULL, @OffsetRawData int = NULL
SELECT * FROM ETL.GetXCONFIG(@XCONFIG,     NULL,                           NULL,                         NULL,                      NULL,                        NULL,                 NULL,                        NULL,                                  NULL,                      NULL) -- MOSTRA L'ELENCO DEI VALORI CONTENUTI
*/
ALTER	FUNCTION [ETL].[GetXCONFIG](
		@XMLconfig XML = NULL
		,@ConcessionaryID tinyint = NULL
		,@Position varchar(50) = NULL
		,@OffSetIN smallint = NULL
		,@OffSetOut smallint = NULL
		,@OffSetMh int = NULL
		,@MinVltEndCredit int = NULL
		,@ConcessionaryName varchar(50) = NULL
		,@FlagDbArchive bit = NULL
		,@OffsetRawData int = NULL
)
RETURNS @returnCONFIG TABLE(
		ConcessionaryID tinyint NOT NULL
		,Position varchar(50) NULL
		,OffSetIN smallint NULL
		,OffSetOut smallint NULL
		,OffSetMh int NULL
		,MinVltEndCredit int NULL
		,ConcessionaryName varchar(50) NULL
		,FlagDbArchive bit NULL
		,OffsetRawData int NULL
)
AS
BEGIN
	INSERT	@returnCONFIG
	SELECT
			I.ConcessionaryID
			,I.Position 
			,I.OffSetIN 
			,I.OffSetOut 
			,I.OffSetMh 
			,I.MinVltEndCredit
			,I.ConcessionaryName
			,I.FlagDbArchive
			,I.OffsetRawData
	FROM
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
	) I
	WHERE	(ConcessionaryID = @ConcessionaryID OR @ConcessionaryID IS NULL)
	AND		(Position = @Position OR @Position IS NULL)
	AND		(OffSetIN = @OffSetIN OR @OffSetIN IS NULL)
	AND		(OffSetOut = @OffSetOut OR @OffSetOut IS NULL)
	AND		(OffSetMh = @OffSetMh OR @OffSetMh IS NULL)
	AND		(MinVltEndCredit = @MinVltEndCredit OR @MinVltEndCredit IS NULL)
	AND		(ConcessionaryName = @ConcessionaryName OR @ConcessionaryName IS NULL)
	AND		(FlagDbArchive = @FlagDbArchive OR @FlagDbArchive IS NULL)
	AND		(OffsetRawData = @OffsetRawData OR @OffsetRawData IS NULL)

	RETURN
END
