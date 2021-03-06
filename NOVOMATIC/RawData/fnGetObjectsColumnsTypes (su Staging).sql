/*
Restituisce, in forma tabellare, l'elenco dei campi - con relativi datatypes e dimensioni - 
che compongono le tabelle contenute in uno dei 13 database dei concessionari

-- Esempi di invocazione/richiamo
----------------------------------

SELECT * FROM dbo.fnGetObjectsColumnsTypes('GMATICA_AGS_RawData', 'RawData') -- Restituisce le colonne delle tabelle 'RawData' di default
SELECT * FROM dbo.fnGetObjectsColumnsTypes('Staging', 'it_toponimi')
SELECT * FROM dbo.fnGetObjectsColumnsTypes('Staging', 'address')

*/
ALTER FUNCTION	[dbo].[fnGetObjectsColumnsTypes]
				(
					@DBname sysname = NULL
					,@tableName sysname = NULL
				)
RETURNS @Columns TABLE
(
	ColName sysname
	,ColDatatype varchar(30)
	,ColLength int
	,ColPrecision smallint
	,ColScale smallint
	,ColIsSparse bit
)
WITH SCHEMABINDING
AS
BEGIN
	IF @DBname = 'GMATICA_AGS_RawData'
		BEGIN
			INSERT @Columns
			(
				ColName
				,ColDatatype
				,ColLength
				,ColPrecision
				,ColScale
				,ColIsSparse
			)
			SELECT 
				C.[name] AS ColName
				,S.[name] AS ColDatatype
				,C.[max_length] AS ColLength
				,C.[precision] AS ColPrecision
				,C.[scale] AS ColScale
				,C.[is_sparse] AS ColIsSparse
			FROM 
			(
				SELECT	object_id
				FROM	GMATICA_AGS_RawData.sys.objects WITH(NOLOCK)
				WHERE	object_id = 
				(
					SELECT	MAX(object_id) 
					FROM	GMATICA_AGS_RawData.sys.objects WITH(NOLOCK) 
					WHERE	[name] = @tableName 
					AND		type = 'U'
				)
			)	O
				JOIN 
				GMATICA_AGS_RawData.sys.columns C WITH(NOLOCK)
				ON O.object_id = C.object_id
				JOIN 
				GMATICA_AGS_RawData.sys.types S WITH(NOLOCK)
				ON S.system_type_id = C.system_type_id
			ORDER BY C.column_id
		END

	IF @DBname = 'BPLUS_AGS_RawData'
		BEGIN
			INSERT @Columns
			(
				ColName
				,ColDatatype
				,ColLength
				,ColPrecision
				,ColScale
				,ColIsSparse
			)
			SELECT 
				C.[name] AS ColName
				,S.[name] AS ColDatatype
				,C.[max_length] AS ColLength
				,C.[precision] AS ColPrecision
				,C.[scale] AS ColScale
				,C.[is_sparse] AS ColIsSparse
			FROM 
			(
				SELECT	object_id
				FROM	BPLUS_AGS_RawData.sys.objects WITH(NOLOCK)
				WHERE	object_id = 
				(
					SELECT	MAX(object_id) 
					FROM	BPLUS_AGS_RawData.sys.objects WITH(NOLOCK) 
					WHERE	[name] = @tableName 
					AND		type = 'U'
				)
			)	O
				JOIN 
				BPLUS_AGS_RawData.sys.columns C WITH(NOLOCK)
				ON O.object_id = C.object_id
				JOIN 
				BPLUS_AGS_RawData.sys.types S WITH(NOLOCK)
				ON S.system_type_id = C.system_type_id
			ORDER BY C.column_id
		END

	IF @DBname = 'CIRSA_AGS_RawData'
		BEGIN
			INSERT @Columns
			(
				ColName
				,ColDatatype
				,ColLength
				,ColPrecision
				,ColScale
				,ColIsSparse
			)
			SELECT 
				C.[name] AS ColName
				,S.[name] AS ColDatatype
				,C.[max_length] AS ColLength
				,C.[precision] AS ColPrecision
				,C.[scale] AS ColScale
				,C.[is_sparse] AS ColIsSparse
			FROM 
			(
				SELECT	object_id
				FROM	CIRSA_AGS_RawData.sys.objects WITH(NOLOCK)
				WHERE	object_id = 
				(
					SELECT	MAX(object_id) 
					FROM	CIRSA_AGS_RawData.sys.objects WITH(NOLOCK) 
					WHERE	[name] = @tableName 
					AND		type = 'U'
				)
			)	O
				JOIN 
				CIRSA_AGS_RawData.sys.columns C WITH(NOLOCK)
				ON O.object_id = C.object_id
				JOIN 
				CIRSA_AGS_RawData.sys.types S WITH(NOLOCK)
				ON S.system_type_id = C.system_type_id
			ORDER BY C.column_id
		END


	IF @DBname = 'CODERE_AGS_RawData'
		BEGIN
			INSERT @Columns
			(
				ColName
				,ColDatatype
				,ColLength
				,ColPrecision
				,ColScale
				,ColIsSparse
			)
			SELECT 
				C.[name] AS ColName
				,S.[name] AS ColDatatype
				,C.[max_length] AS ColLength
				,C.[precision] AS ColPrecision
				,C.[scale] AS ColScale
				,C.[is_sparse] AS ColIsSparse
			FROM 
			(
				SELECT	object_id
				FROM	CODERE_AGS_RawData.sys.objects WITH(NOLOCK)
				WHERE	object_id = 
				(
					SELECT	MAX(object_id) 
					FROM	CODERE_AGS_RawData.sys.objects WITH(NOLOCK) 
					WHERE	[name] = @tableName 
					AND		type = 'U'
				)
			)	O
				JOIN 
				CODERE_AGS_RawData.sys.columns C WITH(NOLOCK)
				ON O.object_id = C.object_id
				JOIN 
				CODERE_AGS_RawData.sys.types S WITH(NOLOCK)
				ON S.system_type_id = C.system_type_id
			ORDER BY C.column_id
		END

	IF @DBname = 'COGETECH_AGS_RawData'
		BEGIN
			INSERT @Columns
			(
				ColName
				,ColDatatype
				,ColLength
				,ColPrecision
				,ColScale
				,ColIsSparse
			)
			SELECT 
				C.[name] AS ColName
				,S.[name] AS ColDatatype
				,C.[max_length] AS ColLength
				,C.[precision] AS ColPrecision
				,C.[scale] AS ColScale
				,C.[is_sparse] AS ColIsSparse
			FROM 
			(
				SELECT	object_id
				FROM	COGETECH_AGS_RawData.sys.objects WITH(NOLOCK)
				WHERE	object_id = 
				(
					SELECT	MAX(object_id) 
					FROM	COGETECH_AGS_RawData.sys.objects WITH(NOLOCK) 
					WHERE	[name] = @tableName 
					AND		type = 'U'
				)
			)	O
				JOIN 
				COGETECH_AGS_RawData.sys.columns C WITH(NOLOCK)
				ON O.object_id = C.object_id
				JOIN 
				COGETECH_AGS_RawData.sys.types S WITH(NOLOCK)
				ON S.system_type_id = C.system_type_id
			ORDER BY C.column_id
		END
	
	IF @DBname = 'GAMENET_AGS_RawData'
		BEGIN
			INSERT @Columns
			(
				ColName
				,ColDatatype
				,ColLength
				,ColPrecision
				,ColScale
				,ColIsSparse
			)
			SELECT 
				C.[name] AS ColName
				,S.[name] AS ColDatatype
				,C.[max_length] AS ColLength
				,C.[precision] AS ColPrecision
				,C.[scale] AS ColScale
				,C.[is_sparse] AS ColIsSparse
			FROM 
			(
				SELECT	object_id
				FROM	GAMENET_AGS_RawData.sys.objects WITH(NOLOCK)
				WHERE	object_id = 
				(
					SELECT	MAX(object_id) 
					FROM	GAMENET_AGS_RawData.sys.objects WITH(NOLOCK) 
					WHERE	[name] = @tableName 
					AND		type = 'U'
				)
			)	O
				JOIN 
				GAMENET_AGS_RawData.sys.columns C WITH(NOLOCK)
				ON O.object_id = C.object_id
				JOIN 
				GAMENET_AGS_RawData.sys.types S WITH(NOLOCK)
				ON S.system_type_id = C.system_type_id
			ORDER BY C.column_id
		END
	
	IF @DBname = 'GTECH_AGS_RawData'
		BEGIN
			INSERT @Columns
			(
				ColName
				,ColDatatype
				,ColLength
				,ColPrecision
				,ColScale
				,ColIsSparse
			)
			SELECT 
				C.[name] AS ColName
				,S.[name] AS ColDatatype
				,C.[max_length] AS ColLength
				,C.[precision] AS ColPrecision
				,C.[scale] AS ColScale
				,C.[is_sparse] AS ColIsSparse
			FROM 
			(
				SELECT	object_id
				FROM	GTECH_AGS_RawData.sys.objects WITH(NOLOCK)
				WHERE	object_id = 
				(
					SELECT	MAX(object_id) 
					FROM	GAMENET_AGS_RawData.sys.objects WITH(NOLOCK) 
					WHERE	[name] = @tableName 
					AND		type = 'U'
				)
			)	O
				JOIN 
				GTECH_AGS_RawData.sys.columns C WITH(NOLOCK)
				ON O.object_id = C.object_id
				JOIN 
				GTECH_AGS_RawData.sys.types S WITH(NOLOCK)
				ON S.system_type_id = C.system_type_id
			ORDER BY C.column_id
		END
	
	IF @DBname = 'HBG_AGS_RawData'
		BEGIN
			INSERT @Columns
			(
				ColName
				,ColDatatype
				,ColLength
				,ColPrecision
				,ColScale
				,ColIsSparse
			)
			SELECT 
				C.[name] AS ColName
				,S.[name] AS ColDatatype
				,C.[max_length] AS ColLength
				,C.[precision] AS ColPrecision
				,C.[scale] AS ColScale
				,C.[is_sparse] AS ColIsSparse
			FROM 
			(
				SELECT	object_id
				FROM	HBG_AGS_RawData.sys.objects WITH(NOLOCK)
				WHERE	object_id = 
				(
					SELECT	MAX(object_id) 
					FROM	HBG_AGS_RawData.sys.objects WITH(NOLOCK) 
					WHERE	[name] = @tableName 
					AND		type = 'U'
				)
			)	O
				JOIN 
				HBG_AGS_RawData.sys.columns C WITH(NOLOCK)
				ON O.object_id = C.object_id
				JOIN 
				HBG_AGS_RawData.sys.types S WITH(NOLOCK)
				ON S.system_type_id = C.system_type_id
			ORDER BY C.column_id
		END
	
	IF @DBname = 'INTRALOT_AGS_RawData'
		BEGIN
			INSERT @Columns
			(
				ColName
				,ColDatatype
				,ColLength
				,ColPrecision
				,ColScale
				,ColIsSparse
			)
			SELECT 
				C.[name] AS ColName
				,S.[name] AS ColDatatype
				,C.[max_length] AS ColLength
				,C.[precision] AS ColPrecision
				,C.[scale] AS ColScale
				,C.[is_sparse] AS ColIsSparse
			FROM 
			(
				SELECT	object_id
				FROM	INTRALOT_AGS_RawData.sys.objects WITH(NOLOCK)
				WHERE	object_id = 
				(
					SELECT	MAX(object_id) 
					FROM	INTRALOT_AGS_RawData.sys.objects WITH(NOLOCK) 
					WHERE	[name] = @tableName 
					AND		type = 'U'
				)
			)	O
				JOIN 
				INTRALOT_AGS_RawData.sys.columns C WITH(NOLOCK)
				ON O.object_id = C.object_id
				JOIN 
				INTRALOT_AGS_RawData.sys.types S WITH(NOLOCK)
				ON S.system_type_id = C.system_type_id
			ORDER BY C.column_id
		END
	
	IF @DBname = 'NETWIN_AGS_RawData'
		BEGIN
			INSERT @Columns
			(
				ColName
				,ColDatatype
				,ColLength
				,ColPrecision
				,ColScale
				,ColIsSparse
			)
			SELECT 
				C.[name] AS ColName
				,S.[name] AS ColDatatype
				,C.[max_length] AS ColLength
				,C.[precision] AS ColPrecision
				,C.[scale] AS ColScale
				,C.[is_sparse] AS ColIsSparse
			FROM 
			(
				SELECT	object_id
				FROM	NETWIN_AGS_RawData.sys.objects WITH(NOLOCK)
				WHERE	object_id = 
				(
					SELECT	MAX(object_id) 
					FROM	NETWIN_AGS_RawData.sys.objects WITH(NOLOCK) 
					WHERE	[name] = @tableName 
					AND		type = 'U'
				)
			)	O
				JOIN 
				NETWIN_AGS_RawData.sys.columns C WITH(NOLOCK)
				ON O.object_id = C.object_id
				JOIN 
				NETWIN_AGS_RawData.sys.types S WITH(NOLOCK)
				ON S.system_type_id = C.system_type_id
			ORDER BY C.column_id
		END
	
	IF @DBname = 'NTS_AGS_RawData'
		BEGIN
			INSERT @Columns
			(
				ColName
				,ColDatatype
				,ColLength
				,ColPrecision
				,ColScale
				,ColIsSparse
			)
			SELECT 
				C.[name] AS ColName
				,S.[name] AS ColDatatype
				,C.[max_length] AS ColLength
				,C.[precision] AS ColPrecision
				,C.[scale] AS ColScale
				,C.[is_sparse] AS ColIsSparse
			FROM 
			(
				SELECT	object_id
				FROM	NTS_AGS_RawData.sys.objects WITH(NOLOCK)
				WHERE	object_id = 
				(
					SELECT	MAX(object_id) 
					FROM	NTS_AGS_RawData.sys.objects WITH(NOLOCK) 
					WHERE	[name] = @tableName 
					AND		type = 'U'
				)
			)	O
				JOIN 
				NTS_AGS_RawData.sys.columns C WITH(NOLOCK)
				ON O.object_id = C.object_id
				JOIN 
				NTS_AGS_RawData.sys.types S WITH(NOLOCK)
				ON S.system_type_id = C.system_type_id
			ORDER BY C.column_id
		END
	
	IF @DBname = 'SISAL_AGS_RawData'
		BEGIN
			INSERT @Columns
			(
				ColName
				,ColDatatype
				,ColLength
				,ColPrecision
				,ColScale
				,ColIsSparse
			)
			SELECT 
				C.[name] AS ColName
				,S.[name] AS ColDatatype
				,C.[max_length] AS ColLength
				,C.[precision] AS ColPrecision
				,C.[scale] AS ColScale
				,C.[is_sparse] AS ColIsSparse
			FROM 
			(
				SELECT	object_id
				FROM	SISAL_AGS_RawData.sys.objects WITH(NOLOCK)
				WHERE	object_id = 
				(
					SELECT	MAX(object_id) 
					FROM	SISAL_AGS_RawData.sys.objects WITH(NOLOCK) 
					WHERE	[name] = @tableName 
					AND		type = 'U'
				)
			)	O
				JOIN 
				SISAL_AGS_RawData.sys.columns C WITH(NOLOCK)
				ON O.object_id = C.object_id
				JOIN 
				SISAL_AGS_RawData.sys.types S WITH(NOLOCK)
				ON S.system_type_id = C.system_type_id
			ORDER BY C.column_id
		END
	
	IF @DBname = 'SNAI_AGS_RawData'
		BEGIN
			INSERT @Columns
			(
				ColName
				,ColDatatype
				,ColLength
				,ColPrecision
				,ColScale
				,ColIsSparse
			)
			SELECT 
				C.[name] AS ColName
				,S.[name] AS ColDatatype
				,C.[max_length] AS ColLength
				,C.[precision] AS ColPrecision
				,C.[scale] AS ColScale
				,C.[is_sparse] AS ColIsSparse
			FROM 
			(
				SELECT	object_id
				FROM	SNAI_AGS_RawData.sys.objects WITH(NOLOCK)
				WHERE	object_id = 
				(
					SELECT	MAX(object_id) 
					FROM	SNAI_AGS_RawData.sys.objects WITH(NOLOCK) 
					WHERE	[name] = @tableName 
					AND		type = 'U'
				)
			)	O
				JOIN 
				SNAI_AGS_RawData.sys.columns C WITH(NOLOCK)
				ON O.object_id = C.object_id
				JOIN 
				SNAI_AGS_RawData.sys.types S WITH(NOLOCK)
				ON S.system_type_id = C.system_type_id
			ORDER BY C.column_id
		END

	IF @DBname = 'Staging'
		BEGIN
			INSERT @Columns
			(
				ColName
				,ColDatatype
				,ColLength
				,ColPrecision
				,ColScale
				,ColIsSparse
			)
			SELECT 
				C.[name] AS ColName
				,S.[name] AS ColDatatype
				,C.[max_length] AS ColLength
				,C.[precision] AS ColPrecision
				,C.[scale] AS ColScale
				,C.[is_sparse] AS ColIsSparse
			FROM 
			(
				SELECT	object_id
				FROM	sys.objects WITH(NOLOCK)
				WHERE	object_id = 
				(
					SELECT	MAX(object_id) 
					FROM	sys.objects WITH(NOLOCK) 
					WHERE	[name] = @tableName 
					AND		type = 'U'
				)
			)	O
				JOIN 
				sys.columns C WITH(NOLOCK)
				ON O.object_id = C.object_id
				JOIN 
				sys.types S WITH(NOLOCK)
				ON S.system_type_id = C.system_type_id
			ORDER BY C.column_id
		END

	RETURN
END