/*
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
	DECLARE 
			@returnXCONFIG XML = NULL
			,@inputCONFIG ETL.CONFIG_TYPE
			,@outputCONFIG ETL.CONFIG_TYPE
			,@lastID int


	IF ISNULL(@ConcessionaryID,0) != 0
		BEGIN
			IF @XMLCONFIG IS NOT NULL
				BEGIN
					INSERT @inputCONFIG
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
					FROM	ETL.GetXCONFIG(@XMLCONFIG, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
					
					SELECT	@lastID = MAX(ConcessionaryID)
					FROM	@inputCONFIG
				END

			IF NOT EXISTS (SELECT * FROM @inputCONFIG)
				BEGIN
					INSERT 	@outputCONFIG
							(
								 ConcessionaryID
								,Position 
								,OffSetIN 
								,OffSetOut 
								,OffSetMh 
								,MinVltEndCredit
								,ConcessionaryName
								,FlagDbArchive
								,OffsetRawData
							) 
							VALUES 
							(
								 @ConcessionaryID
								,@Position 
								,@OffSetIN 
								,@OffSetOut 
								,@OffSetMh 
								,@MinVltEndCredit
								,@ConcessionaryName
								,@FlagDbArchive
								,@OffsetRawData
							)
				END
			ELSE
				BEGIN
					INSERT	@outputCONFIG
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
					FROM	@inputCONFIG
					UNION ALL
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
				END 
		END

	SET @returnXCONFIG =
		(
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
				FROM	@outputCONFIG 
				FOR XML RAW('CONFIG'), TYPE
		)
	RETURN  @returnXCONFIG
END