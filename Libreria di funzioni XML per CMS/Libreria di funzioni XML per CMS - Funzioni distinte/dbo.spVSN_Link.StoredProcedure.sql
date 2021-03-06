USE [Intranetinps_Richieste]
GO
/****** Object:  StoredProcedure [dbo].[spVSN_Link]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC spVSN_Link 24577
*/
CREATE PROC [dbo].[spVSN_Link] 
			@IDlink int = NULL
AS
IF ISNULL(@IDlink,0) > 0
	BEGIN
		DECLARE	
				@xmlField XML -- VARIABILE PREPOSTA AL RECEPIMENTO DEL CONTENUTO DELLA COLONNA XML

		SET NOCOUNT ON; -- DISABILITA TEMPORANEAMENTE IL CONTEGGIO DELLE RIGHE 

		-- POPOLAMENTO DELLA TABELLA IN MEMORIA CON IL RISULTATO DELLA CHIAMATA ALLA SP DI GENERAZIONE DELL'XML
		EXEC	spGetDualLevelXml
				'Link' -- @masterTableName
				,'[IntranetInps].[dbo].[KeyWord_Link]/Link, VX_Gruppi/Gruppo' -- @commaSep2ndLevelTableNames
				,'Id_Link' -- @commonIDfieldName
				,@IDLink -- @commonIDfieldValue
				,0 -- @useElementTag
				,@xmlField OUTPUT

		SET NOCOUNT OFF; -- RIABILITA IL CONTEGGIO DELLE RIGHE 

		-- POPOLAMENTO DELLA TABELLA "VSN" DI DESTINAZIONE, CON ESCLUSIONE DEI DUPLICATI
		BEGIN TRAN
			INSERT	VSN_Link
					(
						Id_Link
						,XmlLink
						,Data
					)
			SELECT
					L.Id_Link
					,@xmlField AS XmlLink
					,GETDATE() AS Data
			FROM	Link L WITH(NOLOCK)
					LEFT JOIN
					VSN_Link R WITH(NOLOCK)
					ON L.ID_Link = R.Id_Link
					AND dbo.fnCompareXML(@xmlField, R.XmlLink) = 1
			WHERE	L.ID_Link = @IDLink
			AND		R.Id_Link IS NULL -- IMPEDISCE I DUPLICATI
		COMMIT TRAN
	END

GO
