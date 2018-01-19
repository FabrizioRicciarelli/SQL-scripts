/*
---------------------------------------------------------------------------------------------
Vista preposta al ritorno di 
- un valore reale (float, double) casuale 
- un GUID casuale
- un BIT casuale
---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------
Esempi di invocazione:

SELECT * FROM V_RAND_NEWID
*/
ALTER VIEW [dbo].[V_RAND_NEWID]
AS
SELECT 
		RAND() AS RNDVALUE
		,NEWID() AS NEWIDVALUE
		,BITVALUE =
			CASE 
				WHEN RAND(CAST(NEWID() AS binary(8))) < 0.5 
				THEN 0 
				ELSE 1 
			END
