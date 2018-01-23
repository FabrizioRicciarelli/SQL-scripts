/*
------------------------------------
-- CREATE THE UTILITY TABLE Numbers
------------------------------------
IF OBJECT_ID (N'dbo.Numbers') IS NOT NULL     
DROP TABLE dbo.Numbers
GO

SELECT	TOP 100000000 IDENTITY(int,1,1) AS number -- One hundred million ROWS (it takes 2 mins and 45 seconds to be created)
INTO	dbo.Numbers
FROM	sys.columns s1
		CROSS JOIN sys.columns s2
		CROSS JOIN sys.columns s3

ALTER TABLE Numbers ADD CONSTRAINT PK_Numbers PRIMARY KEY CLUSTERED (number)

SELECT	COUNT(number)
FROM	numbers
*/
