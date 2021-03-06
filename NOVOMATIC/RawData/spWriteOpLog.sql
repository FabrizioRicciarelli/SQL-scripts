USE [GMATICA_AGS_RawData_Elaborate_Stag_Agile]
GO
/****** Object:  StoredProcedure [dbo].[spWriteOpLog]    Script Date: 06/07/2017 17:39:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
*/
ALTER PROC	[dbo].[spWriteOpLog] 
			@ProcedureName sysname = NULL
			,@OperationMsg varchar(1000) = NULL
			,@OperationTicketCode varchar(50) = NULL
			,@OperationRequestDetailID int = NULL
AS
IF ISNULL(@ProcedureName, '') != ''
AND ISNULL(@OperationMsg, '') != ''
	BEGIN
		INSERT	[ETL].[OperationLog]  
				(
					ProcedureName
					,OperationMsg
					,OperationTicketCode
					,OperationRequestDetailID
					)
		VALUES	(
					@ProcedureName
					,@OperationMsg
					,@OperationTicketCode
					,@OperationRequestDetailID
				)
	END
