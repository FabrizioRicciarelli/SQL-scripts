USE [UniemensPosSportSpet]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetXMLcontr]    Script Date: 08/02/2017 16:23:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
FUNZIONE PREPOSTA ALL'ESTRAZIONE DELLA SOLA COLONNA XML
DALLA TABELLA DEI CONTRIBUTI tb_keyd_keydenindivss_rc
FORNENDO, COME PARAMETRI IN INGRESSO, IL CF DELL'AZIENDA,
IL CF DEL LAVORATORE E IL PERIODO DI COMPETENZA

ESEMPIO DI INVOCAZIONE:

SELECT dbo.fnGetXMLcontr('00937610152', 'BBTCLR54C68Z114Q', '2013-12-01') AS XMLcol
*/
ALTER FUNCTION [dbo].[fnGetXMLcontr](@CFAzienda varchar(16), @CFLavoratore varchar(16), @PeriodoCompetenza varchar(10))
RETURNS XML
AS
BEGIN
	DECLARE @RETVAL XML = NULL

	IF LTRIM(RTRIM(ISNULL(@CFAzienda,''))) != ''
	AND LTRIM(RTRIM(ISNULL(@CFLavoratore,''))) != ''
	AND LTRIM(RTRIM(ISNULL(@PeriodoCompetenza,''))) != ''
		BEGIN
			SELECT	@RETVAL = ap_keyd_sqlcommand_enpals
			FROM	tb_keyd_keydenindivss_rc
			WHERE	ap_keyd_cfazienda = @CFAzienda
			AND		ap_keyd_cflavoratoreiscritto = @CFLavoratore
			AND		ap_keyd_competenza = @PeriodoCompetenza
		END
	RETURN @RETVAL
END
