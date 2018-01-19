--Create Student Table  
DECLARE @Student TABLE(id int identity(1,1) ,Name varchar(20), Marks int)   

--Declare Xml Data Type and Assign Some Xml Data.  
Declare @Data xml  
  
set @Data=  
'
<Root>  
	<Student>  
		<Name>Rakesh</Name>  
		<Marks>80</Marks>  
	</Student>  
	<Student>  
		<Name>Mahesh</Name>  
		<Marks>90</Marks>  
	</Student>  
	<Student>  
		<Name>Gowtham</Name>  
		<Marks>60</Marks>  
	</Student>  
</Root>
'  
SELECT @Data  AS  StudentData

SELECT * FROM @Student --no record in Student Table 
  
  
--Merge Statement usign Xml Data.  
MERGE INTO @Student AS Trg  
USING 
(
	SELECT 
			d.x.value('Name[1]','varchar(20)') AS Name
			,d.x.value('Marks[1]','int') AS Marks 
	FROM	@data.nodes('/Root/Student') AS d(x)
) AS Src  
ON Trg.Name = Src.Name  
WHEN	MATCHED 
THEN	UPDATE 
		SET Trg.Marks=Src.Marks  
WHEN	NOT MATCHED BY TARGET 
THEN	INSERT(Name,Marks) 
		VALUES(Src.Name,Src.Marks);  

SELECT * FROM @Student -- Here all the rows are inserted because no matching records existed in the Student table with the Name Key 

-- This time the XML Data Marks Column was changed with the same data, so we need to UPDATE the Student table data.
set @Data=  
'
<Root>  
	<Student>  
		<Name>Rakesh</Name>  
		<Marks>60</Marks>  
	</Student>  
	<Student>  
		<Name>Mahesh</Name>  
		<Marks>90</Marks>  
	</Student>  
	<Student>  
		<Name>Gowtham</Name>  
		<Marks>80</Marks>  
	</Student>  
	<Student>  
		<Name>Kadal</Name>  
		<Marks>10</Marks>  
	</Student>  
</Root>
'  
MERGE INTO @Student AS Trg  
USING 
(
	SELECT 
			d.x.value('Name[1]','varchar(20)') AS Name   
			,d.x.value('Marks[1]','int') AS Marks 
	FROM	@data.nodes('/Root/Student') AS d(x)
) AS Src  
ON Trg.Name = Src.Name  
WHEN	MATCHED 
THEN	UPDATE 
		SET Trg.Marks=Src.Marks  
WHEN	NOT MATCHED BY TARGET 
THEN	INSERT(Name,Marks) 
		VALUES(Src.Name,Src.Marks);  
  
SELECT * FROM @Student -- The Rakesh's Marsk changed FROM 80 to 60, the Gowtham's Marks changed FROM 60 to 80, the Kadal's new student is created

-- Remove some data FROM XML, while updating other data
set @Data=  
'
<Root>  
	<Student>  
		<Name>Rakesh</Name>  
		<Marks>60</Marks>  
	</Student>  
	<Student>  
		<Name>Mahesh</Name>  
		<Marks>90</Marks>  
	</Student>  
	<Student>  
		<Name>Kadal</Name>  
		<Marks>99</Marks>  
	</Student>  
</Root>
'  
  
MERGE INTO @Student AS Trg  
USING 
(
	SELECT 
			d.x.value('Name[1]','varchar(20)') AS Name   
			,d.x.value('Marks[1]','int') AS Marks 
	FROM	@data.nodes('/Root/Student') AS d(x)
) AS Src  
ON Trg.Name = Src.Name  
WHEN	MATCHED 
THEN	UPDATE 
		SET Trg.Marks=Src.Marks  
WHEN	NOT MATCHED BY TARGET 
THEN	INSERT(Name,Marks) 
		VALUES(Src.Name,Src.Marks)  
WHEN	NOT MATCHED BY SOURCE 
THEN	Delete;  
  
SELECT * FROM @Student -- Student Gowtamh removed, Kadal's Marks changed FROM 10 to 99
