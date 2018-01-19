select * from [dbo].[ConcessionaryType] -- (13 items):  BPlus, Gamenet, Cirsa, HBG, Gtech, Cogetech, GMatica, Codere, Snai, Intralot, Netwin, Sisal, NTS
select * from [dbo].[DWMachine]
select * from [dbo].[Game]
select * from [dbo].[GameName]
select * from [dbo].[GameNameType]
select * from [dbo].[GamingRoom]
select * from [dbo].[Machine]

--DECLARE @Concessionari varchar(MAX)
--SELECT @Concessionari = COALESCE(@Concessionari, ' ') + ConcessionaryName + ', '
--FROM [dbo].[ConcessionaryType]
--SELECT LEFT(@Concessionari, LEN(@Concessionari)-1)

DECLARE @Macchine varchar(MAX)
SELECT @Macchine = COALESCE(@Macchine, ' ') + Machine + '|' + AAMSMachineCode + '|' + CIV ', '
FROM [dbo].[DWMachine]
SELECT LEFT(@Macchine, LEN(@Macchine)-1)

select distinct AamsModelCode from [dbo].[DWMachine]
select * from [dbo].[DWMachine]
SELECT	*
FROM	[dbo].[DWMachine]
FOR		XML PATH(''), ROOT('VLTs'), TYPE, ELEMENTS