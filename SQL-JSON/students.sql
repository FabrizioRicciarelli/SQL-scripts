declare @json nvarchar(4000);
SET @json=
N'
{
	"wclass": 
	{
		"sections":
		[
			{
				"section":"A",
				"students": 
				[
					{ "name":"Linda Jones", "legacySkill":"Access, VB 5.0" },
					{ "name":"Adam Davidson", "legacySkill":"Cobol,MainFrame" },
					{ "name":"Charles Boyer", "legacySkill":"HTML, XML" }
				]
			},
			{
				"section":"B",
				"students": 
				[
					{ "name":"John Doe", "legacySkill":"C#, C++" },
					{ "name":"Emily Thorne", "legacySkill":"VBA, Word, Excel" },
					{ "name":"Susan Stepbride", "legacySkill":"Complete Office package" }
				]
			}
		]
	}
}
'
SELECT	*
FROM	OPENJSON
		(
			@json,
			'$.wclass.sections'
		)


SELECT	*
FROM	OPENJSON
		(
			@json,
			'$.wclass.sections[0].students'
		)
WITH	([name] nvarchar(50), legacySkill nvarchar(255))
WHERE	[name] LIKE '%Boyer%'
OR		[name] LIKE '%Davidson%'
