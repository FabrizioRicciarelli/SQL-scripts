Create procedure [dbo].[ReadViewsOrTablesFromAttachedCSVDatabase]
   @NameOfLinkedServer NVarchar(255),
   @TablesOrViews NVarchar(255)
/*
 */
as
Declare @Command NVarchar(255),
        @Return int

--firstly chack that the linked server is there
--this table is produced by the sp_Tables_ex procesure
Create Table #LinkedTables
   (TABLE_CAT sysname null, 
    TABLE_SCHEM sysname null, 
    TABLE_NAME sysname,
    TABLE_TYPE Varchar(10), 
    REMARKS Varchar(100) null)

Select @NameOfLinkedServer= Replace (@NameOfLinkedServer,'''','') --defeat injection
Select @Command= N'insert into #linkedTables
    (TABLE_CAT, TABLE_SCHEM, TABLE_NAME,TABLE_TYPE, REMARKS)
  execute @Return=sp_tables_ex @TheLinkedServer', @Return=1
EXEC sp_executesql @Command,
      N'@Return int output, @TheLinkedServer NVarchar(255)',
      @Return=@Return output, @TheLinkedServer=@NameOfLinkedServer
if @return<>0 return @Return  
if not exists (Select Table_Name from #linkedTables)
  begin
  Raiserror ('Sorry, but I couldn''t find any tables in %s',16,1,@NameOfLinkedServer)    
  return 1
  end   

Declare @CopyEverything Varchar(Max)
Select @CopyEverything=
  (Select '
INSERT INTO ['+TheTable.TABLE_CATALOG+'].['+TheTable.TABLE_SCHEMA+'].['+TheTable.Table_Name+']
    ('+ stuff((Select 
   ',['+column_Name+']'
  from information_schema.columns C 
    where C.Table_Name=TheTable.Table_Name 
      and C.TABLE_SCHEMA=TheTable.TABLE_SCHEMA
  order by ORDINAL_POSITION
  FOR XML PATH(''), TYPE).value('.', 'varchar(max)'),1,1,'')+')
  Select ' + stuff((Select 
    ', ['+COLUMN_NAME+']'-- end
     from information_schema.columns C 
       where C.Table_Name=TheTable.Table_Name 
         and C.TABLE_SCHEMA=TheTable.TABLE_SCHEMA
  order by ORDINAL_POSITION
  FOR XML PATH(''), TYPE).value('.', 'varchar(max)'),1,1,'') + '
  FROM ['+@NameOfLinkedServer+']...['+TheTable.TABLE_SCHEMA+'_'+TheTable.TABLE_NAME+'#csv]'
  as columnlist
from information_schema.Tables TheTable
inner join #LinkedTables 
on +TheTable.TABLE_SCHEMA+'_'+TheTable.TABLE_NAME+'#csv' = #LinkedTables.TABLE_NAME
where TheTable.TABLE_NAME like @TablesOrViews
FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
Select @CopyEverything
Execute  (@CopyEverything)


