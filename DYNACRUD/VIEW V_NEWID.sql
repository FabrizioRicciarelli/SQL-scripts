/*
---------------------------------------------------------------------------------------------
Vista preposta al ritorno di un GUID casuale
---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------
Esempi di invocazione:

SELECT * FROM V_NEWID
*/
ALTER VIEW [dbo].[V_NEWID]
AS
SELECT NEWID() AS NEWIDVALUE
