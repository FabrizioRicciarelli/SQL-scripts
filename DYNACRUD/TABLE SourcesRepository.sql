/*
---------------------------------------------------------------------------------------------
Tabella preposta a contenere il codice sorgente (completo o parziale), in vari linguaggi,
per la creazione degli elenchi di definizione degli oggetti per la crud dinamica
---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------
Esempi di invocazione:

SELECT * FROM SourcesRepository WITH(NOLOCK)
*/
CREATE TABLE [dbo].[SourcesRepository](
	[IDrepository] [int] IDENTITY(1,1) NOT NULL,
	[IDrepositoryType] [int] NOT NULL,
	[SourceName] [varchar](128) NOT NULL,
	[Abstract] [varchar](512) NULL,
	[Contents] [nvarchar](max) NULL,
 CONSTRAINT [PK_SourcesRepository] PRIMARY KEY CLUSTERED 
(
	[IDrepository] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


