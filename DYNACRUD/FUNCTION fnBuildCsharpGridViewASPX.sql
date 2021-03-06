USE [IRPEFWEB]
GO
/****** Object:  UserDefinedFunction [dbo].[fnBuildCsharpGridView]    Script Date: 04/12/2015 15:54:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
---------------------------------------------------------------------------------------------
Funzione preposta alla creazione della definizione degli elementi ASPX per un GridView 
partendo dalla struttura di una tabella SQL

N.B.:
Usare sempre la SELECT per invocare la presente funzione; una volta eseguita, copiare 
il contenuto della colonna 'GridViewAspxDef' e incollarla all'interno di una 
finestra di Visual Studio preposta al recepimento di una definizione ASPX.

Per creare la classe principale in C# della Crud dinamica (DYNACRUD), invocare la funzione
"dbo.fnBuildCsharpClass"

Per creare la definizione degli elementi ASPX per un GridView, invocare la funzione 
"dbo.fnBuildCsharpGridViewASPX".

Per creare la definizione degli elementi CSS per un GridView, invocare la funzione 
invocare la funzione "dbo.fnBuildCsharpGridViewCSS".
		
Per creare il codice C# del CodeBehind di gestione degli eventi di un GridView, invocare la 
funzione "dbo.fnBuildCsharpGridViewCS".

---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------
Esempi di invocazione: 

SELECT dbo.fnBuildCsharpGridViewASPX('ENTITA_DETT') AS GridViewAspxDef
---------------------------------------------------------------------------------------------
*/
ALTER FUNCTION [dbo].[fnBuildCsharpGridViewASPX](@tableName SYSNAME)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE 
			@TAB char(1) = CHAR(9)
			,@TAB2 char(2) = CHAR(9) + CHAR(9)
			,@TAB3 char(3) = CHAR(9) + CHAR(9) + CHAR(9)
			,@TAB4 char(4) = CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9)
			,@CR char(1) = CHAR(13)
			,@CR2 char(2) = CHAR(13) + CHAR(13)
			,@DataKeyNames varchar(MAX)
			,@GridViewDef varchar(MAX)
			,@GridViewName varchar(128)

	IF ISNULL(@tableName,'') != ''
		BEGIN
			SET	@GridViewName = REPLACE(UPPER(LEFT(@TableName,1)) + LOWER(SUBSTRING(@TableName, 2, LEN(@TableName)-1)),'_','')

			SELECT  @DataKeyNames = COALESCE(@DataKeyNames, '') + REPLACE(CsharpPublicPropertyName,'_PK','') + ',' 
			FROM	dbo.fnGetTableDef(@tableName)
			WHERE	fieldIsKey = 1

			SELECT	@DataKeyNames = LTRIM(RTRIM(LEFT(@DataKeyNames, LEN(@DataKeyNames) -1)))

			SELECT	@GridViewDef =
					(
						SELECT	REPLACE(Contents,'$TableName', @GridViewName)
						FROM	V_SourcesRepository
						WHERE	RepositoryDescription = 'Funzione C#'
						AND		SourceName = 'GridViewAspxElementsTop'
					) +  @CR2 + 
					(
						REPLACE
						(
							REPLACE
							(
								dbo.fnFillSqlTemplateWithFieldsListOrdered
								(
									@TAB2 + '<asp:TemplateField HeaderText="$@" HeaderStyle-HorizontalAlign="Left">' + CHAR(13) +
									@TAB3 + '<ItemTemplate><asp:Label ID="lbl$@" Text=''<%# Bind("$@") %>'' DataFormatString="{0:F$S}" ApplyFormatInEditMode="true" HtmlEncode="false" runat="server"></asp:Label></ItemTemplate>' + CHAR(13) +
									@TAB3 + '<EditItemTemplate><asp:TextBox ID="txt$@" MaxLength="$S" Text=''<%# Bind("$@") %>'' DataFormatString="{0:F$S}" ApplyFormatInEditMode="true" HtmlEncode="false" runat="server"></asp:TextBox></EditItemTemplate>' + CHAR(13) +
									@TAB3+ '<FooterTemplate><asp:TextBox ID="txt$@" runat="server"></asp:TextBox></FooterTemplate>' + CHAR(13) +
									@TAB2 + '</asp:TemplateField>' + CHAR(13)

									,@tableName,NULL)
								,'_x'
								,''
							)
							,'_PK'
							,''
						)
					) +
					(
						SELECT	REPLACE(Contents,'$TableName', @GridViewName)
						FROM	V_SourcesRepository
						WHERE	RepositoryDescription = 'Funzione C#'
						AND		SourceName = 'GridViewAspxElementsBottom'
					)
		END
	RETURN @GridViewDef
END
