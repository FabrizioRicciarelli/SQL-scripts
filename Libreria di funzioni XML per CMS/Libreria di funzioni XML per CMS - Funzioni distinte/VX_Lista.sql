/*
SELECT * FROM VX_Lista
*/
ALTER VIEW [dbo].[VX_Lista] 
AS
WITH CTE (ListaObject, LinkInLista) AS
(
	SELECT ListaObject =
	(
		SELECT	* 
		FROM	ListaObject 
		FOR		XML PATH(''), TYPE
	)
	,LinkInLista = 
	(
		SELECT	LIL.id_Link
				,
				(
					SELECT	MAX(IdVsnLink) 
					FROM	VSN_Link L 
					WHERE	L.Id_Link = LIL.id_link 
				) AS IdVsn
				,ordine
				,homepageOgm
		FROM	LinkInLista LIL 
		--ORDER BY ordine
		FOR XML PATH('Link'), TYPE
	)	
)
SELECT	* 
FROM	CTE
WHERE	LinkInLista.id_lista = ListaObject.Id_Lista
FOR		XML PATH(''), ROOT('XmlLista')

--SELECT
--		LO.Id_Lista
--		,LO.ObjectNameMenu
--		,LO.Bullet
--		,LO.Titolo
--		,LO.ereditata
--		,LO.id_Area
--		,LO.IdAreaOgm

--		,LIL.id_linkinlista
--		,LIL.id_ObjectLista
--		,LIL.id_link
--		,LIL.ordine
--		--,LIL.id_lista
--		,LIL.target
--		,LIL.HomePageOgm

--FROM	[dbo].[ListaObject] LO WITH(NOLOCK)
--		INNER JOIN
--		[dbo].[linkinLista] LIL WITH(NOLOCK)
--ON		LO.Id_Lista = LIL.Id_Lista
--GO


