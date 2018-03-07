/*
This is a known problem: how to invoke a long running procedure on SQL Server without constraining the client to wait for the procedure execution to terminate. 

Most times happens in the context of web applications when waiting for a result means delaying the response to the client browser. 
On Web apps the time constraint is even more drastic, the developer often desires to launch the procedure and immediately return the page even when the execution lasts only few seconds. 
The application will retrieve the execution result later, usually via an Ajax call driven by the returned page script.
Often, the responses gravitated either around the SqlClient asynchronous methods (BeginExecute…) or around having a dedicated process with the sole pupose of maintaining the client connection alive for the duration of the long running procedure.
This problem is perfectly addressed by Service Broker Activation. 
*/

/*
We're going to use a table to store the result of the procedure execution. 
*/
CREATE TABLE AsyncExecResults (
			token			uniqueidentifier PRIMARY KEY,
			submit_time		datetime         NOT NULL,
			start_time		datetime         NULL,
			finish_time		datetime         NULL,
			[error_number]  int              NULL,
			[error_message] nvarchar(2048)   NULL,
			[error_line]	int              NULL
)
GO

/*
Creation of the service and the queue: only one single service will be used for both roles (initiator and target) 
and none of explicit contract will be created, relying instead on the predefined DEFAULT contract:
*/
CREATE QUEUE AsyncExecQueue
GO

CREATE SERVICE AsyncExecService 
ON QUEUE AsyncExecQueue ([DEFAULT]);
GO

/*
Next is the core of our asynchronous execution: the activated procedure. 
The procedure has to dequeue the message that specifies the user procedure, run the procedure and write the result in the results table
*/
CREATE PROC AsyncExecActivated
AS
SET NOCOUNT ON;
DECLARE @h                uniqueidentifier,
		@messageTypeName  sysname,
		@messageBody      varbinary(max),
		@xmlBody          xml,
		@procedureName    sysname,
		@startTime        datetime,
		@finishTime       datetime,
		@execErrorNumber  int,
		@execErrorMessage nvarchar(2048),
		@execErrorLine	  int,
		@xactState        smallint,
		@token            uniqueidentifier;

BEGIN TRANSACTION;
	BEGIN TRY;
		RECEIVE	TOP (1)
				@h = conversation_handle
				,@messageTypeName = message_type_name
				,@messageBody = message_body
		FROM	AsyncExecQueue;
      
		IF (@h IS NOT NULL)
			BEGIN
				IF (@messageTypeName = N'DEFAULT')
					BEGIN
						DECLARE @SQL Nvarchar(MAX)

						-- The DEFAULT message type is a procedure invocation.
						-- Extract the name of the procedure from the message body.
						-- *** WARNING!!! DO NOT TRY TO join the following two "SELECT" in a single line: 
						-- it will result in "Error 2812 cannot find stored procedure" ***
						SELECT @xmlBody = CAST(@messageBody as xml);
						SELECT @procedureName = @xmlBody.value('(//procedure/name)[1]', 'sysname');
						
						SAVE TRANSACTION usp_AsyncExec_procedure;
						SELECT @startTime = GETUTCDATE();

						BEGIN TRY
							EXEC @procedureName
						END TRY

						-- This catch block tries to deal with failures of the procedure execution
						-- If possible it rolls back to the savepoint created earlier, allowing
						-- the activated procedure to continue. If the executed procedure 
						-- raises an error with severity 16 or higher, it will doom the transaction
						-- and thus rollback the RECEIVE. Such case will be a poison message,
						-- resulting in the queue disabling.
						BEGIN CATCH
							SELECT 
									@execErrorNumber = ERROR_NUMBER()
									,@execErrorMessage = ERROR_MESSAGE()
									,@execErrorLine = ERROR_LINE() 
									,@xactState = XACT_STATE()
          
							IF (@xactState = -1)
								BEGIN
									ROLLBACK;
									RAISERROR (N'Unrecoverable error in procedure %s: %i: %s',16,10,@procedureName,@execErrorNumber,@execErrorMessage);
								END
							ELSE IF (@xactState = 1)
								BEGIN
									ROLLBACK TRANSACTION usp_AsyncExec_procedure;
								END
						END CATCH

						SELECT 
								@finishTime = GETUTCDATE()
								,@token = conversation_id
						FROM	sys.conversation_endpoints
						WHERE	conversation_handle = @h;
          
						IF (@token IS NULL)
							BEGIN
								RAISERROR (N'Internal consistency error: conversation not found',16,20);
							END
          
						UPDATE	AsyncExecResults
						SET		start_time = @starttime,
								finish_time = @finishTime,
								[error_number] = @execErrorNumber,
								[error_message] = @execErrorMessage,
								[error_line] = @execErrorLine
						WHERE	token = @token;
          
						IF (0 = @@ROWCOUNT)
							BEGIN
								RAISERROR (N'Internal consistency error: token not found',16,30);
							END

						END CONVERSATION @h;
					END
			ELSE
				BEGIN
					IF (@messageTypeName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog')
						BEGIN
							END CONVERSATION @h;
						END
					ELSE
						IF (@messageTypeName = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error')
							BEGIN
								DECLARE	@errorNumber  int,
										@errorMessage nvarchar(4000),
										@errorLine  int
						
								SELECT	@xmlBody = CAST(@messageBody AS xml);
								WITH	XMLNAMESPACES (DEFAULT N'http://schemas.microsoft.com/SQL/ServiceBroker/Error')
										SELECT 
												@errorNumber = @xmlBody.value('(/Error/Code)[1]','int'),
												@errorMessage = @xmlBody.value('(/Error/Description)[1]','Nvarchar(4000)'),
												@errorLine = @xmlBody.value('(/Error/Line)[1]','Nvarchar(4000)');

								-- Update the request with the received error
								SELECT	@token = conversation_id
								FROM	sys.conversation_endpoints
								WHERE	conversation_handle = @h;

								UPDATE	AsyncExecResults
								SET		[error_number] = @errorNumber,
										[error_message] = @errorMessage,
										[error_line] = @errorLine
								WHERE	token = @token;

								END CONVERSATION @h;
							END
						ELSE
							BEGIN
								RAISERROR (N'Received unexpected message type: %s',16,50,@messageTypeName);
							END
				END 
		END

		COMMIT;
	END TRY
	BEGIN CATCH
		DECLARE	@error   int,
				@message nvarchar(2048);
				SELECT @error = ERROR_NUMBER(),
				@message = ERROR_MESSAGE(),
				@xactState = XACT_STATE();
		IF (@xactState <> 0)
			BEGIN
				ROLLBACK;
			END;
		RAISERROR (N'Error: %i, %s',1,60,@error,@message)-- WITH LOG;
	END CATCH
GO

/*
To make the procedure activated we need to attach it to our service queue. 
This will ensure this procedure is run whenever a message arrives to our [AsyncExecService]:
*/
ALTER QUEUE AsyncExecQueue
	WITH ACTIVATION (
		PROCEDURE_NAME = AsyncExecActivated
		,MAX_QUEUE_READERS = 1000
		,EXECUTE AS OWNER
		,STATUS = ON
	);
GO

/*
The procedure that submits the message to invoke the desired asyncronous executed procedure. 
This procedure returns an output parameter ‘token’ than can be used to lookup the asynchronous execution result
*/
CREATE PROC	AsyncExecInvoke 
			@procedureName sysname
			,@token uniqueidentifier OUTPUT
AS
SET NOCOUNT ON;

DECLARE	@h         uniqueidentifier,
		@xmlBody   xml,
		@trancount int;

SET	@trancount = @@trancount;

IF @trancount = 0
	BEGIN TRANSACTION
ELSE
	SAVE TRANSACTION AsyncExecInvoke;

BEGIN TRY
	BEGIN DIALOG CONVERSATION @h
	FROM SERVICE AsyncExecService
	TO SERVICE N'AsyncExecService','current database'
	WITH ENCRYPTION = OFF;

	SELECT	@token = conversation_id
	FROM	sys.conversation_endpoints
	WHERE	conversation_handle = @h;

	SELECT @xmlBody = (
		SELECT	@procedureName AS name
		FOR		xml PATH ('procedure'),TYPE
	);

	SEND ON CONVERSATION @h (@xmlBody);

	INSERT	AsyncExecResults (token,submit_time)
	VALUES	(@token,GETUTCDATE());

	IF	@trancount = 0
		COMMIT;
END TRY

BEGIN CATCH
	DECLARE	@error     int,
			@message   nvarchar(2048),
			@xactState smallint;
	
	SELECT	@error = ERROR_NUMBER(),
			@message = ERROR_MESSAGE(),
			@xactState = XACT_STATE();
	
	IF @xactState = -1
		ROLLBACK;
	IF @xactState = 1
	AND @trancount = 0
		ROLLBACK
	IF @xactState = 1
	AND @trancount > 0
		ROLLBACK TRANSACTION my_procedure_name;

	RAISERROR (N'Error: %i, %s',16,1,@error,@message);
END CATCH
GO

/*
To test our asynchronous execution infrastructure we'll create two test procedures and invoke them asynchronously. 
One of them simply waits for 5 seconds to simulate a ‘long’ running procedure...
*/
CREATE PROC MyLongRunningProcedure
AS
	WAITFOR DELAY '00:00:05';
	PRINT('FINISHED')
GO

/*
...and the other one produces intentionally a primary key violation, just to simulate a fault in the asynchronously executed procedure
*/
CREATE PROC MyFaultyProcedure
AS
	SET NOCOUNT ON;

	DECLARE @t TABLE (id int PRIMARY KEY);
	INSERT	@t(id)
	VALUES	(1)
	INSERT	@t (id)
	VALUES	(1)
GO

/*
Activation Context
If you check the start time of the second asynchronosuly executed procedure you will notice that it started right after the first one finished. 
This is because we declare a max_queue_readers value of 1 when we set up activation on the queue. 
This restricts that at most one activated procedure to run at any time, effectively serializing all the asynchronously executed procedures. 
Whether this is desired or not depends a lot on the actual usage scenario. 
The limit can be increased as necessary.

If you start playing around with this method of invoking procedures asynchronously you will notice that sometimes the asynchronously executed procedure is misteriously denied access to other databases or to server scoped objects. 
When the same procedure is run manually from a query window in SSMS, it executes fine. 
This is caused by the EXECUTE AS context under which activation occurs: the details are explained in MSDN’s Extending Database Impersonation by Using EXECUTE AS. 
The best solution is to simply turn the trustworthy bit on on the database where the activated procedure runs. 
When this is not desired, or not allowed by your hosting environment, the solution is to code sign the activated procedure: Signing an activated procedure.
Using Service Broker Activation to invoke procedures asynchronously may look daunting at beginning. 
It sure is significantly more complex than just calling BeginExecuteNonQuery. 
But what needs to be understood is that this is a reliable way to invoke the procedure. 
The client is free to disconnect as soon as it commited the call to usp_AsyncExecInvoke. 
The procedure invoked will run, even if the server is stopped and restarted, even if a mirroring or clustering failover occurs. 
The server may even crash and be completely rebuilt: as soon as the database is back online, that queue will activate and invoke the asynchronous execution. 
Such level of reliability is difficult, if not impossible, to guarantee by using a client process.

If the async call doesn't work as expected, try to execute the following statements then try again:
ALTER DATABASE [GMATICA_AGS_RawData_Elaborate_Tip] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
ALTER DATABASE [GMATICA_AGS_RawData_Elaborate_Tip] SET ENABLE_BROKER
ALTER DATABASE [GMATICA_AGS_RawData_Elaborate_Tip] SET MULTI_USER
														  
Where "databasename" is the name of the database where the service will run.

TRUNCATE TABLE AsyncExecResults 
DECLARE @token uniqueidentifier;

EXEC	AsyncExecInvoke 
		N'MyFaultyProcedure'
        ,@token OUTPUT

SELECT	*
FROM	AsyncExecResults
WHERE	token = @token;

EXEC	AsyncExecInvoke 
		N'MyLongRunningProcedure'
        ,@token OUTPUT

--SELECT	*
--FROM	AsyncExecResults
--WHERE	token = @token;

--WAITFOR	DELAY '00:00:10';
SELECT	*
FROM	AsyncExecResults;

select * from sysobjects where type = 'p'
ORDER BY NAME
*/

