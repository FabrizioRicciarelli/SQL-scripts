USE [Intranetinps_Richieste]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetValueFromXmlLink]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnGetValueFromXmlLink]
						(
							@XmlPath varchar(MAX) = NULL
							,@IdVsnLink int = NULL
							,@Data datetime = NULL,@Id_Link int = NULL
							,@separator char(1) = NULL
						)
		RETURNS varchar(MAX)
		AS
		BEGIN
			DECLARE @RETVAL varchar(MAX) = NULL

			IF ISNULL(@XmlPath,'') != ''
			AND ISNULL(@IdVsnLink,0) != 0
				BEGIN
					SELECT	@RETVAL =
							C.value('(//*[local-name()=sql:variable("@Xmlpath")])[1]','varchar(max)')
					FROM	VSN_Link AS T WITH(NOLOCK)
							CROSS APPLY T.XmlLink.nodes('XmlLink') AS X(C)
					WHERE	(IdVsnLink = @IdVsnLink)
					AND (Data = @Data OR @Data IS NULL)AND (Id_Link = @Id_Link OR @Id_Link IS NULL)
				END
	
			IF ISNULL(@XmlPath,'') != ''
			AND ISNULL(@IdVsnLink,0) = 0
				BEGIN
					SET @separator = ISNULL(@separator,',')
					SELECT	@RETVAL = 
							dbo.fnTrimSeparator
							(
								CAST
								(
									(
										SELECT	DISTINCT
												REPLACE
												(
													REPLACE
													(
														CAST(C.query('(//.[local-name()=sql:variable("@Xmlpath")])') AS varchar(MAX))
														,'<' + @Xmlpath + '>'
														,@separator
													)
													,'</' + @Xmlpath + '>'
													, ''
												)
										FROM	VSN_Link AS T WITH(NOLOCK)
												CROSS APPLY T.XmlLink.nodes('XmlLink') AS X(C)
										WHERE   1 = 1
										AND (Data = @Data OR @Data IS NULL)AND (Id_Link = @Id_Link OR @Id_Link IS NULL)
										FOR XML PATH(''), TYPE, ELEMENTS
									)
									AS varchar(MAX)
								)
								,@separator
							)
				END
	
			IF ISNULL(@XmlPath,'') = ''
			AND ISNULL(@IdVsnLink,0) != 0
				BEGIN
					SELECT	@RETVAL =
							CAST(T.XmlLink AS varchar(MAX))
					FROM	VSN_Link AS T WITH(NOLOCK)
					WHERE	(IdVsnLink = @IdVsnLink)
					AND (Data = @Data OR @Data IS NULL)AND (Id_Link = @Id_Link OR @Id_Link IS NULL)
				END
			RETURN @RETVAL
		END
		
GO
