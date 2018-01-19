/*
---------------------------------------------------------------------------------------------
Vista preposta al ritorno di un valore reale (float, double) casuale
---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------
Esempi di invocazione:

SELECT * FROM V_RAND
*/
ALTER VIEW [dbo].[V_RAND]
AS
SELECT RAND() AS RNDVALUE



