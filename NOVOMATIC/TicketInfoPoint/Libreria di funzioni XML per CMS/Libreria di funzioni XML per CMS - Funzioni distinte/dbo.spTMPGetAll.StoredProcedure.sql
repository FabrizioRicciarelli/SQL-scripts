USE [Intranetinps_Richieste]
GO
/****** Object:  StoredProcedure [dbo].[spTMPGetAll]    Script Date: 23/06/2017 11:04:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----------------------------------------
dbo.spTMPGetAll - SISTEMA TMP
----------------------------------------

NELL'AMBITO DEL MICROSISTEMA DI GESTIONE DI DATI TABELLARI TEMPORANEI (SISTEMA "TMP"), QUESTA STORED PROCEDURE E' PREPOSTA ALLA RESTITUZIONE DI TUTTI I
DATI PRESENTI ALL'INTERNO DELLA TABELLA TEMPORANEA PRECEDENTEMENTE CREATA DALLA SP "spTMPcreate", QUINDI ARRICCHITA DELLE COLONNE NECESSARIE TRAMITE LA
SP "spTMPaddColumns" E POPOLATA CON I VALORI VOLUTI ATTRAVERSO GLI STATEMENTS INSERT/UPDATE

-- ESEMPI DI INVOCAZIONE

EXEC spTMPcreate
EXEC spTMPgetAll -- oppure SELECT * FROM ##__tmpTable
EXEC spTMPaddColumns 'added nvarchar(max), added2 varchar(20), added3 datetime'

INSERT ##__tmpTable(added, added2, added3)
VALUES
		('NEW','PIPPO', GETDATE())
		,('OLD', 'PLUTO', NULL)

EXEC spTMPgetAll -- oppure SELECT * FROM ##__tmpTable
*/
CREATE PROC [dbo].[spTMPGetAll]
AS
IF	EXISTS
	(
		SELECT	* 
		FROM	tempdb..sysobjects 
		where	name LIKE '%##__tmpTable%' 
		AND		[type] in (N'U')
	)
	BEGIN
		SELECT * FROM ##__tmpTable
	END
ELSE
	BEGIN
		PRINT('TABELLA TEMPORANEA INESISTENTE, CREARNE UNA TRAMITE LA SP "spTMPcreate" E AGGIUNGERVI COLONNE TRAMITE LA SP "spTMPaddColumns @CSVColNamesAndTypes", QUINDI POPOLARLA CON I DATI DESIDERATI E RIESEGUIRE LA PRESENTE SP.')
	END
GO
