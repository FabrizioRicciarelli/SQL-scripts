SELECT * FROM OPENQUERY([POM-MON01],
'SELECT * FROM OPENQUERY([GMatica_PIN01\DW],''
	SELECT	TOP 10000 
			*
	FROM	[AGS_RawData].[1000114].[RawData_View] WITH(NOLOCK)
	WHERE	(ServerTime BETWEEN ''''20151117'''' AND ''''20151118'''')
	AND		MachineID IN (2,20,26,27)
			'')
'
)

SELECT * FROM OPENQUERY([POM-MON01],
'SELECT * FROM OPENQUERY([GMatica_PIN01\DW],''
	SELECT	TOP 10000 
			*
	FROM	[AGS_RawData].[1000114].[RawData] WITH(NOLOCK)
	WHERE	(ServerTime BETWEEN ''''20151117'''' AND ''''20151118'''')
	AND		MachineID IN (2,20,26,27)
			'')
'
)