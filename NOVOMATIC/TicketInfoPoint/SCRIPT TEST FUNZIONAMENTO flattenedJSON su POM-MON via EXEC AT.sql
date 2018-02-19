DECLARE @SQL nvarchar(MAX) =
N'
DECLARE @cars xml;
SET @cars =
''<?xml version="1.0" encoding="UTF-8"?>
<root>
  <row>
    <Make>Volkswagen</Make>
    <Model>Eurovan</Model>
    <Year>2003</Year>
    <Color>White</Color>
  </row>
  <row>
    <Make>Honda</Make>
    <Model>CRV</Model>
    <Year>2009</Year>
    <Color>Black</Color>
    <Mileage>35,600</Mileage>
  </row>
</root>'';

SELECT [GMATICA_AGS_RawData_Elaborate_GdF].[dbo].[FlattenedJSON] (@cars) AS JSON_cars
'
EXEC(@SQL) AT [POM-MON01]