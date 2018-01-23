DECLARE @xml nvarchar(max) = '<root xmlns:p1="http://org.test">
   <p1:Telephone>
     <p1:Type code="Home">Home</p1:Type>
     <p1:TelephoneNumber>01234 987654</p1:TelephoneNumber>
   </p1:Telephone>
   <p1:Telephone>
     <p1:Type code="Business">Business</p1:Type>
     <p1:TelephoneNumber>01324 123456</p1:TelephoneNumber>
   </p1:Telephone></root>'

    DECLARE @xml_handle int  
    EXEC sp_XML_preparedocument @xml_handle OUTPUT, @xml, '<root xmlns:p1="http://org.test" />'

    SELECT * FROM 
    OPENXML( @xml_handle, '//p1:Telephone') 
    WITH (
        [Type]              varchar(10) './p1:Type',
        [Code]              varchar(10) './p1:Type/@code',
        [TelephoneNumber]   varchar(10) './p1:TelephoneNumber'
    )

  EXEC sp_xml_removedocument @xml_handle    