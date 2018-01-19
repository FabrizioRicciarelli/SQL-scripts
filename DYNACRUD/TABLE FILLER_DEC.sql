/*
---------------------------------------------------------------------------------------------
Tabella preposta a contenere le wildcard per la sostituzione di elementi salvaposto con
nomi provenienti dalla definizione di una tabella (Templating)
---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------
Esempi di invocazione:

SELECT * FROM FILLER_DEC WITH(NOLOCK)
*/
CREATE TABLE [dbo].[FILLER_DEC](
	[WildCard] [varchar](3) NOT NULL,
	[FieldName] [varchar](100) NOT NULL,
	[AssociatedFunction] [varchar](100) NOT NULL,
 CONSTRAINT [PK_FILLER_DEC] PRIMARY KEY CLUSTERED 
(
	[WildCard] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


