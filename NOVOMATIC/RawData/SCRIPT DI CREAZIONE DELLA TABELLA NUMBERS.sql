SET NOCOUNT ON;
 
DECLARE @UpperLimit INT = 1000000;
 
WITH n AS
(
    SELECT	x = 
			ROW_NUMBER() OVER (ORDER BY s1.[object_id])
    FROM    sys.all_objects AS s1
			CROSS JOIN 
			sys.all_objects AS s2
			CROSS JOIN 
			sys.all_objects AS s3
)
SELECT	Number = x
INTO	dbo.Numbers
FROM	n
WHERE	(x BETWEEN 1 AND @UpperLimit);
 
GO
CREATE UNIQUE CLUSTERED INDEX n ON dbo.Numbers(Number) 
WITH (DATA_COMPRESSION = PAGE);
GO

SELECT *
FROM Numbers
