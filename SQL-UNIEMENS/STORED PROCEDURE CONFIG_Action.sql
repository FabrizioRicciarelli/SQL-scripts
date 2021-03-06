/*
STORED PROCEDURE 'CRUD' PER LA TABELLA CONFIGURAZIONE
N.B.: IL SOLO PARAMETRO OBBLIGATORIO E' @action MA IN
DETERMINATI CASI GLI ALTRI DUE PARAMETRI SONO INDISPENSABILI
PER OTTENERE I RISULTATI DESIDERATI

ESEMPI DI INVOCAZIONE:

EXEC CONFIG_Action 'SEL' -- EQUIVALENTE ALLA SP "CONFIG_SelectConfigurazione"

EXEC CONFIG_Action 'SEK', 'MailTo' -- EQUIVALENTE ALLA SP "CONFIG_SelectConfigurazioneByKey"
EXEC CONFIG_Action 'SEK', 'ExENPALS_SFTPServer' -- EQUIVALENTE ALLA SP "CONFIG_SelectConfigurazioneByKey"

--------------------------------------------------------------------------------------
-- sequenza di test per verifica inserimento, estrazione, aggiornamento, eliminazione
-- (doppio inserimento per verifica impedimento duplicati)
--------------------------------------------------------------------------------------
EXEC CONFIG_Action 'INS', 'Chiave', 'Valore' -- EQUIVALENTE ALLA SP "CONFIG_Insert"
EXEC CONFIG_Action 'INS', 'Chiave', 'Valore' -- EQUIVALENTE ALLA SP "CONFIG_Insert"

EXEC CONFIG_Action 'SEK', 'Chiave' -- EQUIVALENTE ALLA SP "CONFIG_SelectConfigurazioneByKey"
EXEC CONFIG_Action 'UPD', 'Chiave', 'NuovoValore' -- EQUIVALENTE ALLA SP "CONFIG_Update"
EXEC CONFIG_Action 'SEK', 'Chiave' -- EQUIVALENTE ALLA SP "CONFIG_SelectConfigurazioneByKey"
EXEC CONFIG_Action 'DEL', 'Chiave' -- EQUIVALENTE ALLA SP "CONFIG_Delete"
--------------------------------------------------------------------------------------
*/
ALTER PROC dbo.CONFIG_Action
			@action varchar(3) = NULL -- 'SEL', 'SEK', 'INS', 'UPD', 'DEL'
			,@key varchar(150) = NULL
			,@value varchar(max) = NULL
AS

SET NOCOUNT ON;

IF ISNULL(@action,'') != ''
	BEGIN
		IF UPPER(@action) = 'SEL' -- EQUIVALENTE ALLA SP "CONFIG_SelectConfigurazione"
			BEGIN
				SELECT 
						Nome
						,Valore 
				FROM	dbo.CONFIGURAZIONE
			END
		IF UPPER(@action) = 'SEK' -- EQUIVALENTE ALLA SP "CONFIG_SelectConfigurazioneByKey"
		AND ISNULL(@key,'') != ''
			BEGIN
				SELECT 
						Nome
						,Valore 
				FROM	dbo.CONFIGURAZIONE
				WHERE	Nome = @Key
			END
		IF UPPER(@action) = 'INS' -- EQUIVALENTE ALLA SP "CONFIG_Insert"
		AND ISNULL(@key,'') != ''
		AND ISNULL(@value,'') != ''
			BEGIN
				DECLARE @CONFIGURAZIONE TABLE(NOME varchar(150) NOT NULL, VALORE varchar(3000) NULL)
				INSERT	@CONFIGURAZIONE(Nome, Valore)
				VALUES	(@Key, @Value)

				INSERT	dbo.CONFIGURAZIONE(Nome, Valore)
				SELECT	T.Nome, T.Valore
				FROM	@CONFIGURAZIONE T
						LEFT JOIN
						CONFIGURAZIONE C
						ON C.Nome = T.Nome
						AND C.Valore = T.Valore
				WHERE	C.Nome IS NULL -- evita i duplicati
			END
		IF UPPER(@action) = 'UPD' -- EQUIVALENTE ALLA SP "CONFIG_Update"
		AND ISNULL(@key,'') != ''
		AND ISNULL(@value,'') != ''
			BEGIN
				UPDATE  dbo.CONFIGURAZIONE
				SET		Valore = @Value
				WHERE	Nome = @Key
			END
		IF UPPER(@action) = 'DEL' -- EQUIVALENTE ALLA SP "CONFIG_Delete"
		AND ISNULL(@key,'') != ''
			BEGIN
				DELETE 
				FROM	dbo.CONFIGURAZIONE
				WHERE	Nome = @Key
			END
	END
