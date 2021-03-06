/*
SELECT * FROM dbo.fnCercaNelCodice('IMP_RETR_COMPL')
SELECT * FROM dbo.fnCercaNelCodice('IMP_RETR_COMPL') WHERE ObjectType = 'TF'
SELECT * FROM dbo.fnCercaNelCodice('IMP_RETR_COMPL') WHERE ObjectType = 'P'

SELECT * FROM dbo.fnCercaNelCodice('COD_RETR')
SELECT * FROM dbo.fnCercaNelCodice('COD_RETR') WHERE ObjectType = 'TF'
SELECT * FROM dbo.fnCercaNelCodice('COD_RETR') WHERE ObjectType = 'P'

SELECT * FROM dbo.fnCercaNelCodice('CONTR_BASE_MOD')
SELECT * FROM dbo.fnCercaNelCodice('CONTR_BASE_MOD') WHERE ObjectType = 'TF'
SELECT * FROM dbo.fnCercaNelCodice('CONTR_BASE_MOD') WHERE ObjectType = 'P'
*/
ALTER FUNCTION [dbo].[fnCercaNelCodice] (@textToSearch varchar(MAX) = NULL)
RETURNS @RESULTS TABLE
		(
			ObjectName varchar(128)
			,ObjectType varchar(10)
		)
AS
BEGIN
	IF ISNULL(@textToSearch,'') != ''
		BEGIN
			IF LEN(@textToSearch) > 2
				BEGIN
					DECLARE @Numbers TABLE (Num INT NOT NULL PRIMARY KEY CLUSTERED)
					DECLARE @i int

					SET @i = 1

					WHILE @i <= 10000
						BEGIN
							INSERT @Numbers(Num) VALUES (@i)
							SELECT @i = @i + 1
						END

					INSERT	@RESULTS
							(
								ObjectName
								,ObjectType
							)
					SELECT	DISTINCT	
							O.Name AS ObjectName
							,O.Type AS ObjectType
					FROM
					(
						SELECT 
								Id
								,CAST(COALESCE(MIN(CASE WHEN sc.colId = Num-1 THEN sc.text END), '') AS VARCHAR(MAX)) +
								CAST(COALESCE(MIN(CASE WHEN sc.colId = Num THEN sc.text END), '') AS VARCHAR(MAX)) AS [text]
						FROM	SysComments SC
								INNER JOIN 
								@Numbers N
								ON N.Num = SC.colid
								OR N.num-1 = SC.colid
						WHERE	N.Num < 30
						GROUP BY 
								Id
								,Num
					)	C
						INNER JOIN sysobjects O
						ON C.id = O.Id
					WHERE C.text LIKE '%' + @textToSearch + '%'
					ORDER BY 
							ObjectName
							,ObjectType
				END
			ELSE
				BEGIN
					INSERT	@RESULTS
							(
								ObjectName
								,ObjectType
							)
					VALUES	('CERCARE CON UNA STRINGA LUNGA ALMENO 3 CARATTERI', 'ERR')
				END
		END
	ELSE
		BEGIN
			INSERT	@RESULTS
					(
						ObjectName
						,ObjectType
					)
			VALUES	('SPECIFICARE UN TESTO DA RICERCARE', 'ERR')
		END
	RETURN
END