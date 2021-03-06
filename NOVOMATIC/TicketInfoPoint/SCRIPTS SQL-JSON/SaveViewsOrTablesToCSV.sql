Create procedure [dbo].[SaveViewsOrTablesToCSV]
   @ServerDirectory NVarchar(255), 
   @NameOfLinkedServer NVarchar(255),
   @TablesOrViews NVarchar(255),
   @Database sysname

 /*
*/
as
Declare @CommandLineString Varchar(256)
Declare @Command NVARCHAR(max)
Create table #Tables (TABLE_NAME sysname, [TABLE_SCHEMA] sysname, TABLE_CATALOG sysname)
Create table #Columns (TABLE_NAME sysname, [TABLE_SCHEMA] sysname null, 
                       ORDINAL_POSITION int null, COLUMN_NAME sysname, 
                       DATA_TYPE NVARCHAR(128) ,CHARACTER_MAXIMUM_LENGTH int null )

Select @Command = '
insert into #Tables (TABLE_NAME, [TABLE_SCHEMA],TABLE_CATALOG)
  Select TABLE_NAME, [TABLE_SCHEMA],TABLE_CATALOG
    from ['+@Database+'].information_schema.Tables
    where TABLE_NAME like @whateverYouWant'
EXEC sp_executesql @Command,
      N'@whateverYouWant Nvarchar',
      @whateverYouWant = @TablesOrViews


Select @Command = '
insert into #Columns (TABLE_NAME, [TABLE_SCHEMA],
     ORDINAL_POSITION, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH )
  Select c.TABLE_NAME, c.[TABLE_SCHEMA],
     ORDINAL_POSITION, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
    from ['+@Database+'].information_schema.columns C 
    inner join #tables TheTable
       on C.Table_Name=TheTable.Table_Name 
         and C.TABLE_SCHEMA=TheTable.TABLE_SCHEMA'
EXEC sp_executesql @Command

--  In Windows, create a new directory for the linked server.
Select @CommandLineString = 'md '+@ServerDirectory --make an MD command
EXEC xp_cmdshell @CommandLineString, no_output --create the directory if it does not exist

--    Add that directory as a linked server with sp_addlinkedserver:
EXEC sp_addlinkedserver
@server= @NameOfLinkedServer,-- the name of the linked server to create. server is sysname, with no default.
@srvproduct= N'Jet 4.0',--product name of the OLE DB data source to add as a linked server. 
@provider=  N'Microsoft.Jet.OLEDB.4.0', --Is the unique programmatic identifier (PROGID) of the OLE DB provider that corresponds to this data source. 
@datasrc=  @ServerDirectory,--Is the name of the data source as interpreted by the OLE DB provider. 
@location=  null, --Is the location of the database as interpreted by the OLE DB provider.
@provstr=  N'Text'-- Is the OLE DB provider-specific connection string that identifies a unique data source. 

EXEC sp_addlinkedsrvlogin @NameOfLinkedServer, 'true'
--to drop the link, just do this!
--EXEC sp_dropserver @NameOfLinkedServer, 'droplogins'

--Now we must create the files in this directory, each of which will represent a table or view from the database

Select @Command=(Select 'execute xp_cmdshell ''copy /y NUL '+@ServerDirectory+'\'
    +TABLE_SCHEMA+'_'+TABLE_NAME+'.csv >NUL'', no_output
'
from #tables
FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
Execute (@Command)

Declare @IniFileContents Varchar(Max)
Select @IniFileContents=
  (Select '
['+TABLE_SCHEMA+'_'+TABLE_NAME+'.csv]
   ColNameHeader = False
   Format = CSVDelimited
   CharacterSet = ANSI',
  (Select '
   Col'+convert(varchar(4),ORDINAL_POSITION)+case when charindex(' ',column_Name)>0 then '="'+replace(column_Name,'.','_')+'" ' else '='+replace(column_Name,'.','_')+' ' end+ 
    Case  when DATA_TYPE in ('char', 'varchar', 'nchar','ntext', 'text', 'nvarchar') then  case when CHARACTER_MAXIMUM_LENGTH between 1 and 255 then 'Char  width '+ convert(varchar(3),CHARACTER_MAXIMUM_LENGTH) else 'Longchar' end
    --Case  when DATA_TYPE in ('char', 'varchar', 'nchar','ntext', 'text', 'nvarchar') then  case when CHARACTER_MAXIMUM_LENGTH <= 255 then 'Char' else 'Longchar' end
    when DATA_TYPE in ('uniqueidentifier') then 'char width 40'
    when DATA_TYPE in ('bit') then 'Byte'
    when DATA_TYPE in ('tinyint', 'smallint') then 'Short'
    when DATA_TYPE in ('int','bigint') then 'Integer'
    when DATA_TYPE in ('smallmoney','money') then 'Currency'
    when DATA_TYPE in ('decimal','numeric') then  'Currency'--'Decimal'
    when DATA_TYPE in ('float','real') then 'Double'
    when DATA_TYPE in ('varbinary') then 'Longchar'
    when DATA_TYPE in ('XML') then 'LongChar'
    when DATA_TYPE in ('date','datetimeoffset','datetime2','smalldatetime', 
                           'datetime','time' ) then 'DateTime'
  else DATA_TYPE end
     from #Columns C 
       where C.Table_Name=TheTable.Table_Name 
         and C.TABLE_SCHEMA=TheTable.TABLE_SCHEMA
  order by ORDINAL_POSITION
  FOR XML PATH(''), TYPE).value('.', 'varchar(max)') as tableDef
from #tables TheTable
FOR XML PATH(''), TYPE).value('.', 'varchar(max)') 
             

Select @CommandLineString=@ServerDirectory+'\schema.ini'
execute spSaveTextToFile @IniFileContents, @CommandLineString, 0 
              
Declare @CopyEverything Varchar(Max)
Select @CopyEverything=
  (Select '
INSERT INTO '+@NameOfLinkedServer+'...'+TABLE_SCHEMA+'_'+TABLE_NAME+'#csv('+
  stuff((Select 
   ',['+replace(column_Name,'.','_')+']'
     from #Columns C 
       where C.Table_Name=TheTable.Table_Name 
         and C.TABLE_SCHEMA=TheTable.TABLE_SCHEMA
     order by ORDINAL_POSITION
  FOR XML PATH(''), TYPE).value('.', 'varchar(max)'),1,1,'')+')
  Select ' + stuff((Select 
   case when DATA_TYPE in ('xml','varbinary') then ', convert(NVARCHAR(MAX),['+column_Name+'])'
   else ', ['+COLUMN_NAME+']' end
     from #Columns C 
       where C.Table_Name=TheTable.Table_Name 
         and C.TABLE_SCHEMA=TheTable.TABLE_SCHEMA
  order by ORDINAL_POSITION
  FOR XML PATH(''), TYPE).value('.', 'varchar(max)'),1,1,'') + '
  FROM '+TABLE_CATALOG+'.'+TABLE_SCHEMA+'.'+Table_Name+'
  '
   as columnlist
from #tables TheTable
FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
Select @CommandLineString= @ServerDirectory + '\lastQuery.sql'
execute spSaveTextToFile
  @CopyEverything,@CommandLineString ,0 
Execute  (@CopyEverything)

--EXEC sp_tables_ex @NameOfLinkedServer
