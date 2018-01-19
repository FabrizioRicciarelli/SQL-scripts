declare @placements table (Placement varchar(10))
insert into @placements values 
('720x60'),
('720x600'),
('720 x 60'),
('720_x_60'),
('1x1')

DECLARE
		@separator CHAR(1) = 'x'
		,@regexPattern varchar(255) = '%[0-9]%' 

SELECT 
		LEFT(LEFTOF, PATINDEX(REPLACE(@regexPattern,'[', '[^'),LEFTOF) - 1) + 'x' + 
		RIGHT(RIGHTOF, LEN(RIGHTOF) - PATINDEX(@regexPattern, RIGHTOF) + 1)
FROM 
(
	SELECT 
			RIGHT(LEFTOF, LEN(LEFTOF) - PATINDEX(@regexPattern, LEFTOF) + 1) AS LEFTOF
			,LEFT(RIGHTOF, LEN(RIGHTOF) - PATINDEX(@regexPattern, REVERSE(RIGHTOF)) + 1) AS RIGHTOF
	FROM 
	(
		SELECT 
				LEFT(A.Placement,x) AS LEFTOF
				,RIGHT(A.Placement,LEN(A.Placement) - x + 1) AS RIGHTOF
		FROM 
		(
			SELECT
					Placement
					,CHARINDEX(@separator, Placement) AS x
			FROM	@placements
		) A
	) B
) C