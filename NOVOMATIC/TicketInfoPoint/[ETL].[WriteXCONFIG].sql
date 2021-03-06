/*
-- @XCONFIG ex Table.Config

SET NOCOUNT ON;

DECLARE @XCONFIG XML -- VUOTO
SET	@XCONFIG = ETL.WriteXCONFIG(@XCONFIG, 7, 'POM-MON01', 25, 45, 7200, 50, 'GMatica', 1, 1) -- CARICA UN ELEMENTO AL CONTENITORE (PRIMO CARICAMENTO)

SELECT * FROM ETL.GetXCONFIG(@XCONFIG, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
SELECT * FROM ETL.GetXCONFIG(@XCONFIG, 7, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
SELECT * FROM ETL.GetXCONFIG(@XCONFIG, NULL, 'POM-MON01', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
SELECT * FROM ETL.GetXCONFIG(@XCONFIG, NULL, NULL, 25, NULL, NULL, NULL, NULL, NULL, NULL)
SELECT * FROM ETL.GetXCONFIG(@XCONFIG, NULL, NULL, NULL, 45, NULL, NULL, NULL, NULL, NULL)
SELECT * FROM ETL.GetXCONFIG(@XCONFIG, NULL, NULL, NULL, NULL, 7200, NULL, NULL, NULL, NULL)
SELECT * FROM ETL.GetXCONFIG(@XCONFIG, NULL, NULL, NULL, NULL, NULL, 50, NULL, NULL, NULL)
SELECT * FROM ETL.GetXCONFIG(@XCONFIG, NULL, NULL, NULL, NULL, NULL, NULL, 'GMatica', NULL, NULL)
SELECT * FROM ETL.GetXCONFIG(@XCONFIG, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)

SELECT * FROM ETL.GetAllXCONFIG(@XCONFIG)
SELECT * FROM ETL.GetAllXCONFIG(@XCONFIG) FOR XML PATH('CONFIG'), ROOT('ROWS'), TYPE, ELEMENTS

PRINT(CONVERT(varchar(MAX),@XCONFIG))
*/
ALTER FUNCTION [ETL].[WriteXCONFIG]
				(
					@XMLCONFIG XML
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
RETURNS XML
AS
BEGIN
	RETURN (
		SELECT *
		FROM (
			SELECT
					ConcessionaryID
					,Position 
					,OffSetIN 
					,OffSetOut 
					,OffSetMh 
					,MinVltEndCredit
					,ConcessionaryName
					,FlagDbArchive
					,OffsetRawData
			FROM	ETL.GetAllXCONFIG(@XMLCONFIG)
			UNION ALL
			SELECT 
					@ConcessionaryID AS ConcessionaryID
					,@Position AS Position
					,@OffSetIN AS OffSetIN
					,@OffSetOut AS OffSetOut
					,@OffSetMh AS OffSetMh
					,@MinVltEndCredit AS MinVltEndCredit
					,@ConcessionaryName	AS ConcessionaryName
					,@FlagDbArchive	AS FlagDbArchive
					,@OffsetRawData	AS OffsetRawData
		) I
		FOR XML RAW('CONFIG'), TYPE
	)
END