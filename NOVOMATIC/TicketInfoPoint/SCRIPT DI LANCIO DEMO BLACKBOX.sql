-----------------------------------------------------------------------------------------------------------------
--
-- BLACKBOX
--
-- A. E' possibile una sola istanza in esecuzione alla volta per ciascun database della SP [RAW].[CalcAllLevel]
-- B. Presuppone la presenza e il pre-popolamento della tabella di configurazione Config.Table
-- C. Legge e scrive su 13 tabelle fisiche per appoggiare i dati durante i calcoli
-----------------------------------------------------------------------------------------------------------------

-- 1. Svuotamento tabella di LOG
TRUNCATE TABLE [ETL].[OperationLog]
TRUNCATE TABLE ERR.ERRORLOG
--SELECT * FROM ERR.ErrorLog

-- 2. Definizione variabili di lavoro
DECLARE @ReturnCode int

-- 3. Esecuzione calcoli (presuppone la presenza e il pre-popolamento della tabella di configurazione Config.Table)
EXEC	[RAW].[CalcAllLevel] 
		@ConcessionaryID = 7
		,@Direction = 0
		,@TicketCode = '375559646310240944' -- 427102895993931934, 375559646310240944, 553637305458476249, 148239190679638755, 96415771688841631 
		,@BatchID = 1
		,@MaxLevel = 10
		,@ReturnCode = @ReturnCode Output

-- 4. Risultati dei calcoli (dati su disco, tabelle fisiche [RAW].[Session] e [RAW].[Delta])
--SELECT '[ETL].[OperationLog]' AS TABELLA, * FROM [ETL].[OperationLog] WHERE OperationRequestDetailID = 1
SELECT '[RAW].[Session]' AS TABELLA, * FROM [RAW].[Session]
SELECT '[RAW].[Delta]' AS TABELLA, * FROM [RAW].[Delta]
