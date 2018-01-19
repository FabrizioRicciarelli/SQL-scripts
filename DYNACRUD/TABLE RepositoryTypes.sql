/*
---------------------------------------------------------------------------------------------
Tabella preposta a contenere le tipologie di codice sorgente per la creazione degli elenchi 
di definizione degli oggetti per la crud dinamica
---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------
Esempi di invocazione:

SELECT * FROM RepositoryTypes WITH(NOLOCK)
*/
CREATE TABLE [dbo].[RepositoryTypes](
	[IDRepositoryType] [int] IDENTITY(1,1) NOT NULL,
	[RepositoryDescription] [varchar](512) NOT NULL,
 CONSTRAINT [PK_RepositoryTypes] PRIMARY KEY CLUSTERED 
(
	[IDRepositoryType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


