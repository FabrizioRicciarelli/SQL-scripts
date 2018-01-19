/*
---------------------------------------------------------------------------------------------
Vista preposta alla rappresentazione del contenitore del codice sorgente "SourcesRepository"

---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------
Esempi di invocazione:

SELECT * FROM V_SourcesRepository
*/
ALTER  VIEW [dbo].[V_SourcesRepository]
AS
SELECT 
		SR.IDrepository
		,SR.IDrepositoryType
		,SR.SourceName
		,SR.Abstract
		,SR.Contents
		,RT.RepositoryDescription
FROM	dbo.SourcesRepository SR WITH(NOLOCK)
		INNER JOIN
		RepositoryTypes RT WITH(NOLOCK)
		ON SR.IDRepositoryType = RT.IDRepositoryType
