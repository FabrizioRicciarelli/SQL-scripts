/*
*/
ALTER FUNCTION [ETL].[BuildDynSQL_ConteggioInfo]()
RETURNS NVarchar(MAX)
AS
BEGIN
	DECLARE 
			@retVal Nvarchar(MAX)
	SET @retVal = 
	N'
		SELECT 
				*
		FROM	OPENQUERY -- Consente di superare questo errore: "Xml data type is not supported in distributed queries"
		(
			[CQI]
			,''
			SELECT
					 SUM(I.ConteggioVLTAttive) AS ConteggioVLTAttive
					,SUM(I.ConteggioElectronAttiviAncheConVLTNonCollegate) AS ConteggioElectronAttiviAncheConVLTNonCollegate
					,SUM(I.ConteggioElectronConVLTCollegate) AS ConteggioElectronConVLTCollegate
			FROM
			(
				SELECT  
						COUNT(*) AS ConteggioVLTAttive
						,0 AS ConteggioElectronAttiviAncheConVLTNonCollegate
						,0 AS ConteggioElectronConVLTCollegate
				FROM	[ConcessionarySystemDB].[AAMS].[VideoTerminalMachine] WITH(NOLOCK)
				WHERE	LOCATIONRECID!=0 AND CLUBID!=0 -- non sono in magazzino
				AND		VLTCESSATIONDATE IS NULL -- non cessate
			
				UNION ALL
			
				SELECT 
						0 AS ConteggioVLTAttive
						,COUNT(distinct UnivocalLocationCode) AS ConteggioElectronAttiviAncheConVLTNonCollegate
						,0 AS ConteggioElectronConVLTCollegate
				FROM	[ConcessionarySystemDB].[AAMS].[GamingRoomSystem] GRS WITH(NOLOCK)
						INNER JOIN 
						[ConcessionarySystemDB].[AAMS].[Location] T2 WITH(NOLOCK)
						ON GRS.LocationRecID = T2.RecID
				WHERE	GRS.cessationdate IS NULL
				AND		GRS.registrationdate IS NOT NULL -- non cessate e censite
				AND		T2.SiteType <> 9 -- non magazzino				
			
				UNION ALL
			
				SELECT 
						0 AS ConteggioVLTAttive
						,0 AS ConteggioElectronAttiviAncheConVLTNonCollegate
						,COUNT(DISTINCT UnivocalLocationCode) AS ConteggioElectronConVLTCollegate
				FROM	[ConcessionarySystemDB].[AAMS].[VideoTerminalMachine] GRS WITH(NOLOCK)
						INNER JOIN [ConcessionarySystemDB].[AAMS].[Location] t2 WITH(NOLOCK)
						ON GRS.LocationRecID = t2.RecID
				WHERE	GRS.Vltcessationdate is null -- non cessati
				AND		GRS.LastSftVerify > ''''20010101'''' -- vlt censite
				AND		t2.SiteType <> 9 -- non magazzino
			) I
			''
		)
	'
	RETURN @retVal
END