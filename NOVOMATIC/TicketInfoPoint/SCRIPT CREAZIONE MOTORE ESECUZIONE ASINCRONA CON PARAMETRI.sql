CREATE TABLE [AsyncExecResults] (
  [token]         uniqueidentifier PRIMARY KEY,
  [submit_time]   datetime         NOT NULL,
  [start_time]    datetime         NULL,
  [finish_time]   datetime         NULL,
  [error_number]  int              NULL,
  [error_message] nvarchar(2048)   NULL
);
GO

CREATE QUEUE [AsyncExecQueue];
GO

CREATE SERVICE [AsyncExecService] ON QUEUE [AsyncExecQueue] ([DEFAULT]);
GO

-- Dynamic SQL helper procedure
-- Extracts the parameters from the message body
-- Creates the invocation Transact-SQL batch
-- Invokes the dynmic SQL batch
CREATE PROCEDURE [usp_procedureInvokeHelper] (@x xml)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @stmt             nvarchar(max),
          @stmtDeclarations nvarchar(max),
          @stmtValues       nvarchar(max),
          @i                int,
          @countParams      int,
          @namedParams      nvarchar(max),
          @paramName        sysname,
          @paramType        sysname,
          @paramPrecision   int,
          @paramScale       int,
          @paramLength      int,
          @paramTypeFull    nvarchar(300),
          @comma            nchar(1)

  SELECT @i = 0,
         @stmtDeclarations = N'',
         @stmtValues = N'',
         @namedParams = N'',
         @comma = N''

  DECLARE crsParam CURSOR FORWARD_ONLY STATIC READ_ONLY FOR
  SELECT
    x.value(N'@Name',N'sysname'),
    x.value(N'@BaseType',N'sysname'),
    x.value(N'@Precision',N'int'),
    x.value(N'@Scale',N'int'),
    x.value(N'@MaxLength',N'int')
  FROM @x.nodes(N'//procedure/parameters/parameter') t (x);
  OPEN crsParam;

  FETCH NEXT FROM crsParam INTO @paramName
  ,@paramType
  ,@paramPrecision
  ,@paramScale
  ,@paramLength;
  WHILE (@@fetch_status = 0)
  BEGIN
    SELECT @i = @i + 1;

    SELECT @paramTypeFull = @paramType +
      CASE
        WHEN @paramType IN (N'varchar'
          ,N'nvarchar'
          ,N'varbinary'
          ,N'char'
          ,N'nchar'
          ,N'binary') THEN N'(' + CAST(@paramLength AS nvarchar(5)) + N')'
        WHEN @paramType IN (N'numeric') THEN N'(' + CAST(@paramPrecision AS nvarchar(10)) + N',' +
          CAST(@paramScale AS nvarchar(10)) + N')'
        ELSE N''
      END;

    -- Some basic sanity check on the input XML
    IF (@paramName IS NULL
      OR @paramType IS NULL
      OR @paramTypeFull IS NULL
      OR CHARINDEX(N'''',@paramName) > 0
      OR CHARINDEX(N'''',@paramTypeFull) > 0)
      RAISERROR (N'Incorrect parameter attributes %i: %s:%s %i:%i:%i'
      ,16,10,@i,@paramName,@paramType
      ,@paramPrecision,@paramScale,@paramLength);

    SELECT @stmtDeclarations = @stmtDeclarations + N'
declare @pt' + CAST(@i AS varchar(3)) + N' ' + @paramTypeFull,
           @stmtValues = @stmtValues + N'
select @pt' + CAST(@i AS varchar(3)) + N'=@x.value(
    N''(//procedure/parameters/parameter)[' + CAST(@i AS varchar(3))
           + N']'', N''' + @paramTypeFull + ''');',
           @namedParams = @namedParams + @comma + @paramName
           + N'=@pt' + CAST(@i AS varchar(3));

    SELECT @comma = N',';

    FETCH NEXT FROM crsParam INTO @paramName
    ,@paramType
    ,@paramPrecision
    ,@paramScale
    ,@paramLength;
  END

  CLOSE crsParam;
  DEALLOCATE crsParam;

  SELECT @stmt = @stmtDeclarations + @stmtValues + N'
exec ' + QUOTENAME(@x.value(N'(//procedure/name)[1]',N'sysname'));

  IF (@namedParams != N'')
    SELECT @stmt = @stmt + N' ' + @namedParams;

  EXEC sp_executesql @stmt,
                     N'@x xml',
                     @x;
END
GO

CREATE PROCEDURE usp_AsyncExecActivated
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @h                uniqueidentifier,
          @messageTypeName  sysname,
          @messageBody      varbinary(max),
          @xmlBody          xml,
          @startTime        datetime,
          @finishTime       datetime,
          @execErrorNumber  int,
          @execErrorMessage nvarchar(2048),
          @xactState        smallint,
          @token            uniqueidentifier;

  BEGIN TRANSACTION;
    BEGIN TRY;
      RECEIVE TOP (1)
      @h = [conversation_handle]
      ,@messageTypeName = [message_type_name]
      ,@messageBody = [message_body]
      FROM [AsyncExecQueue];
      IF (@h IS NOT NULL)
      BEGIN
        IF (@messageTypeName = N'DEFAULT')
        BEGIN
          -- The DEFAULT message type is a procedure invocation.
          --
          SELECT @xmlBody = CAST(@messageBody AS xml);

          SAVE TRANSACTION usp_AsyncExec_procedure;
          SELECT @startTime = GETUTCDATE();
        BEGIN TRY
          EXEC [usp_procedureInvokeHelper] @xmlBody;
        END TRY
        BEGIN CATCH
          -- This catch block tries to deal with failures of the procedure execution
          -- If possible it rolls back to the savepoint created earlier, allowing
          -- the activated procedure to continue. If the executed procedure
          -- raises an error with severity 16 or higher, it will doom the transaction
          -- and thus rollback the RECEIVE. Such case will be a poison message,
          -- resulting in the queue disabling.
          --
          SELECT @execErrorNumber = ERROR_NUMBER(),
                 @execErrorMessage = ERROR_MESSAGE(),
                 @xactState = XACT_STATE();
          IF (@xactState = -1)
          BEGIN
            ROLLBACK;
            RAISERROR (N'Unrecoverable error in procedure: %i: %s',16,10,
            @execErrorNumber,@execErrorMessage);
          END
          ELSE
          IF (@xactState = 1)
          BEGIN
            ROLLBACK TRANSACTION usp_AsyncExec_procedure;
          END
        END CATCH

          SELECT @finishTime = GETUTCDATE();
          SELECT @token = [conversation_id]
          FROM sys.conversation_endpoints
          WHERE [conversation_handle] = @h;
          IF (@token IS NULL)
          BEGIN
            RAISERROR (N'Internal consistency error: conversation not found',16,20);
          END
          UPDATE [AsyncExecResults]
          SET [start_time] = @starttime,
              [finish_time] = @finishTime,
              [error_number] = @execErrorNumber,
              [error_message] = @execErrorMessage
          WHERE [token] = @token;
          IF (0 = @@ROWCOUNT)
          BEGIN
            RAISERROR (N'Internal consistency error: token not found',16,30);
          END
          END CONVERSATION @h;
        END
        ELSE
        IF (@messageTypeName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog')
        BEGIN
          END CONVERSATION @h;
        END
        ELSE
        IF (@messageTypeName = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error')
        BEGIN
          DECLARE @errorNumber  int,
                  @errorMessage nvarchar(4000);
          SELECT @xmlBody = CAST(@messageBody AS xml);
          WITH XMLNAMESPACES (DEFAULT N'http://schemas.microsoft.com/SQL/ServiceBroker/Error')
          SELECT @errorNumber = @xmlBody.value('(/Error/Code)[1]','INT'),
                 @errorMessage = @xmlBody.value('(/Error/Description)[1]','NVARCHAR(4000)');
          -- Update the request with the received error
          SELECT @token = [conversation_id]
          FROM sys.conversation_endpoints
          WHERE [conversation_handle] = @h;
          UPDATE [AsyncExecResults]
          SET [error_number] = @errorNumber,
              [error_message] = @errorMessage
          WHERE [token] = @token;
          END CONVERSATION @h;
        END
        ELSE
        BEGIN
          RAISERROR (N'Received unexpected message type: %s',16,50,@messageTypeName);
        END
      END
    COMMIT;
  END TRY
  BEGIN CATCH
    DECLARE @error   int,
            @message nvarchar(2048);
    SELECT @error = ERROR_NUMBER(),
           @message = ERROR_MESSAGE(),
           @xactState = XACT_STATE();
    IF (@xactState <> 0)
    BEGIN
      ROLLBACK;
    END;
    RAISERROR (N'Error: %i, %s',1,60,@error,@message) --WITH LOG;
  END CATCH
END
GO

ALTER QUEUE [AsyncExecQueue]
WITH ACTIVATION (
PROCEDURE_NAME = [usp_AsyncExecActivated]
,MAX_QUEUE_READERS = 1
,EXECUTE AS OWNER
,STATUS = ON);
GO

-- Helper function to create the XML element
-- for a passed in parameter
CREATE FUNCTION [dbo].[fn_DescribeSqlVariant] (@p sql_variant
,@n sysname)
RETURNS xml WITH SCHEMABINDING
AS
BEGIN
  RETURN (SELECT
    @n AS [@Name],
    SQL_VARIANT_PROPERTY(@p,'BaseType') AS [@BaseType],
    SQL_VARIANT_PROPERTY(@p,'Precision') AS [@Precision],
    SQL_VARIANT_PROPERTY(@p,'Scale') AS [@Scale],
    SQL_VARIANT_PROPERTY(@p,'MaxLength') AS [@MaxLength],
    @p
  FOR xml PATH ('parameter'),TYPE)
END
GO

-- Invocation wrapper. Accepts arbitrary
-- named parameetrs to be passed to the
-- background procedure
CREATE PROCEDURE [usp_AsyncExecInvoke] @procedureName sysname
,@p1 sql_variant = NULL,@n1 sysname = NULL
,@p2 sql_variant = NULL,@n2 sysname = NULL
,@p3 sql_variant = NULL,@n3 sysname = NULL
,@p4 sql_variant = NULL,@n4 sysname = NULL
,@p5 sql_variant = NULL,@n5 sysname = NULL
,@token uniqueidentifier OUTPUT
AS
BEGIN
  DECLARE @h         uniqueidentifier,
          @xmlBody   xml,
          @trancount int;
  SET NOCOUNT ON;

  SET @trancount = @@trancount;
  IF @trancount = 0
    BEGIN TRANSACTION
    ELSE
      SAVE TRANSACTION usp_AsyncExecInvoke;
    BEGIN TRY
      BEGIN DIALOG CONVERSATION @h
      FROM SERVICE [AsyncExecService]
      TO SERVICE N'AsyncExecService','current database'
      WITH ENCRYPTION = OFF;
      SELECT @token = [conversation_id]
      FROM sys.conversation_endpoints
      WHERE [conversation_handle] = @h;

      SELECT @xmlBody = (SELECT
          @procedureName AS [name],
          (SELECT
            *
          FROM (SELECT
            [dbo].[fn_DescribeSqlVariant](@p1,@n1) AS [*]
          WHERE @p1 IS NOT NULL
          UNION ALL
          SELECT
            [dbo].[fn_DescribeSqlVariant](@p2,@n2) AS [*]
          WHERE @p2 IS NOT NULL
          UNION ALL
          SELECT
            [dbo].[fn_DescribeSqlVariant](@p3,@n3) AS [*]
          WHERE @p3 IS NOT NULL
          UNION ALL
          SELECT
            [dbo].[fn_DescribeSqlVariant](@p4,@n4) AS [*]
          WHERE @p4 IS NOT NULL
          UNION ALL
          SELECT
            [dbo].[fn_DescribeSqlVariant](@p5,@n5) AS [*]
          WHERE @p5 IS NOT NULL) AS p
          FOR xml PATH (''),TYPE)
          AS [parameters]
        FOR xml PATH ('procedure'),TYPE);
      SEND ON CONVERSATION @h (@xmlBody);
      INSERT INTO [AsyncExecResults] ([token],[submit_time])
        VALUES (@token,GETUTCDATE());
      IF @trancount = 0
      COMMIT;
  END TRY
  BEGIN CATCH
    DECLARE @error     int,
            @message   nvarchar(2048),
            @xactState smallint;
    SELECT @error = ERROR_NUMBER(),
           @message = ERROR_MESSAGE(),
           @xactState = XACT_STATE();
    IF @xactState = -1
      ROLLBACK;
    IF @xactState = 1
      AND @trancount = 0
      ROLLBACK
    IF @xactState = 1
      AND @trancount > 0
      ROLLBACK TRANSACTION usp_my_procedure_name;

    RAISERROR (N'Error: %i, %s',16,1,@error,@message);
  END CATCH
END
GO