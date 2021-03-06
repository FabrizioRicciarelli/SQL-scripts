/*
--------------------------------------------
-- MOSTRA LA COLONNA XML CHE SARA' GENERATA
--------------------------------------------
DECLARE	
		@xmlField XML -- VARIABILE PREPOSTA AL RECEPIMENTO DEL CONTENUTO DELLA COLONNA XML

EXEC	spGetDualLevelXml
		'ListaObject' -- @masterTableName
		,'LinkInLista/Link' -- @commaSep2ndLevelTableNames
		,'Id_Lista' -- @commonIDfieldName
		,13295 -- @commonIDfieldValue
		,0 -- @useElementTag
		,@xmlField OUTPUT


---------------------
-- VERSIONA LA LISTA
---------------------
EXEC spVSN_Lista 25
*/
ALTER PROC [dbo].[spVSN_Lista] 
			@IDlista int = NULL
AS
IF ISNULL(@IDlista,0) > 0
	BEGIN
		DECLARE	
				@xmlField XML -- VARIABILE PREPOSTA AL RECEPIMENTO DEL CONTENUTO DELLA COLONNA XML

		SET NOCOUNT ON; -- DISABILITA TEMPORANEAMENTE IL CONTEGGIO DELLE RIGHE 

		-- POPOLAMENTO DELLA TABELLA IN MEMORIA CON IL RISULTATO DELLA CHIAMATA ALLA SP DI GENERAZIONE DELL'XML
		EXEC	spGetDualLevelXml
				'ListaObject' -- @masterTableName
				,'LinkInLista/Link' -- @commaSep2ndLevelTableNames
				,'Id_Lista' -- @commonIDfieldName
				,@IDLista -- @commonIDfieldValue
				,0 -- @useElementTag
				,@xmlField OUTPUT

		SET NOCOUNT OFF; -- RIABILITA IL CONTEGGIO DELLE RIGHE 

		-- POPOLAMENTO DELLA TABELLA "VSN" DI DESTINAZIONE, CON ESCLUSIONE DEI DUPLICATI
		BEGIN TRAN
			INSERT	VSN_Lista
					(
						Id_Lista
						,XmlLista
						,Data
					)
			SELECT
					L.Id_Lista
					,@xmlField AS XmlLista
					,GETDATE() AS Data
			FROM	Lista L WITH(NOLOCK)
					LEFT JOIN
					VSN_Lista R WITH(NOLOCK)
					ON L.ID_Lista = R.Id_Lista
					AND dbo.fnCompareXML(@xmlField, R.XmlLista) = 1
			WHERE	L.ID_Lista = @IDLista
			AND		R.Id_Lista IS NULL -- IMPEDISCE I DUPLICATI
		COMMIT TRAN
	END
