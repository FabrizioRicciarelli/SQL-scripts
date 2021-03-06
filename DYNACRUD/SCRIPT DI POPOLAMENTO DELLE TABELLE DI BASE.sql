/*
Run this script on:

SQLINPS13,2989.IrpefWeb    -  This database will be modified

to synchronize it with:

SQLINPSSVIL06,2059.IRPEFWEB

You are recommended to back up your database before running this script

Script created by SQL Data Compare version 10.2.3 from Red Gate Software Ltd at 04/12/2015 17:15:08

*/
		
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS, NOCOUNT ON
GO
SET DATEFORMAT YMD
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO
BEGIN TRANSACTION
-- Pointer used for text / image updates. This might not be needed, but is declared here just in case
DECLARE @pv binary(16)

-- Add 17 rows to [dbo].[FILLER_DEC]
INSERT INTO [dbo].[FILLER_DEC] ([WildCard], [FieldName], [AssociatedFunction]) VALUES ('$#', 'cSharpType', 'dbo.fnGetTableDef')
INSERT INTO [dbo].[FILLER_DEC] ([WildCard], [FieldName], [AssociatedFunction]) VALUES ('$?', 'randomData', 'dbo.fnGetTableDef')
INSERT INTO [dbo].[FILLER_DEC] ([WildCard], [FieldName], [AssociatedFunction]) VALUES ('$@', 'cSharpPublicPropertyName', 'dbo.fnGetTableDef')
INSERT INTO [dbo].[FILLER_DEC] ([WildCard], [FieldName], [AssociatedFunction]) VALUES ('$^', 'cSharpPrivateVariableName', 'dbo.fnGetTableDef')
INSERT INTO [dbo].[FILLER_DEC] ([WildCard], [FieldName], [AssociatedFunction]) VALUES ('$C', 'fieldScale', 'dbo.fnGetTableDef')
INSERT INTO [dbo].[FILLER_DEC] ([WildCard], [FieldName], [AssociatedFunction]) VALUES ('$F', 'fullFieldType', 'dbo.fnGetTableDef')
INSERT INTO [dbo].[FILLER_DEC] ([WildCard], [FieldName], [AssociatedFunction]) VALUES ('$I', 'fieldIsIdentity', 'dbo.fnGetTableDef')
INSERT INTO [dbo].[FILLER_DEC] ([WildCard], [FieldName], [AssociatedFunction]) VALUES ('$K', 'castedFieldName', 'dbo.fnGetTableDef')
INSERT INTO [dbo].[FILLER_DEC] ([WildCard], [FieldName], [AssociatedFunction]) VALUES ('$L', 'fieldLength', 'dbo.fnGetTableDef')
INSERT INTO [dbo].[FILLER_DEC] ([WildCard], [FieldName], [AssociatedFunction]) VALUES ('$M', 'castedDenulledFieldName', 'dbo.fnGetTableDef')
INSERT INTO [dbo].[FILLER_DEC] ([WildCard], [FieldName], [AssociatedFunction]) VALUES ('$N', 'fieldName', 'dbo.fnGetTableDef')
INSERT INTO [dbo].[FILLER_DEC] ([WildCard], [FieldName], [AssociatedFunction]) VALUES ('$P', 'fieldPrecision', 'dbo.fnGetTableDef')
INSERT INTO [dbo].[FILLER_DEC] ([WildCard], [FieldName], [AssociatedFunction]) VALUES ('$Q', 'SqlDbType', 'dbo.fnGetTableDef')
INSERT INTO [dbo].[FILLER_DEC] ([WildCard], [FieldName], [AssociatedFunction]) VALUES ('$S', 'stringFieldLength', 'dbo.fnGetTableDef')
INSERT INTO [dbo].[FILLER_DEC] ([WildCard], [FieldName], [AssociatedFunction]) VALUES ('$T', 'fieldType', 'dbo.fnGetTableDef')
INSERT INTO [dbo].[FILLER_DEC] ([WildCard], [FieldName], [AssociatedFunction]) VALUES ('$V', 'variableName', 'dbo.fnGetTableDef')
INSERT INTO [dbo].[FILLER_DEC] ([WildCard], [FieldName], [AssociatedFunction]) VALUES ('$X', 'fieldIsKey', 'dbo.fnGetTableDef')

-- Add 5 rows to [dbo].[RepositoryTypes]
SET IDENTITY_INSERT [dbo].[RepositoryTypes] ON
INSERT INTO [dbo].[RepositoryTypes] ([IDRepositoryType], [RepositoryDescription]) VALUES (1, 'Funzione C#')
INSERT INTO [dbo].[RepositoryTypes] ([IDRepositoryType], [RepositoryDescription]) VALUES (2, 'Script SQL')
INSERT INTO [dbo].[RepositoryTypes] ([IDRepositoryType], [RepositoryDescription]) VALUES (3, 'Definizione COBOL')
INSERT INTO [dbo].[RepositoryTypes] ([IDRepositoryType], [RepositoryDescription]) VALUES (4, 'Classe o codice esempio C#')
INSERT INTO [dbo].[RepositoryTypes] ([IDRepositoryType], [RepositoryDescription]) VALUES (5, 'CSS')
SET IDENTITY_INSERT [dbo].[RepositoryTypes] OFF

-- Add 16 rows to [dbo].[SourcesRepository]
SET IDENTITY_INSERT [dbo].[SourcesRepository] ON
INSERT INTO [dbo].[SourcesRepository] ([IDrepository], [IDrepositoryType], [SourceName], [Abstract], [Contents]) VALUES (1, 1, 'ListMandatoryProperties', 'Funzione che ritorna l''elenco delle proprietà non nullabili', N'        /// <summary>
        /// Funzione che ritorna l''elenco delle proprietà non nullabili
        /// </summary>
        /// <param name="pSeparator">Carattere separatore (; , | etc.)</param>
        /// <returns>String</returns>
        public String ListMandatoryProperties(String pSeparator)
        {
            #region Variabili
            String
                retVal = String.Empty;

            PropertyInfo[]
                _properties = null;
            #endregion

            pSeparator = (String.IsNullOrEmpty(pSeparator)) ? ";" : pSeparator;
            _properties = this.GetType().GetProperties();

            foreach (PropertyInfo property in _properties)
            {
                if (!property.Name.EndsWith("_x"))
                {
                    retVal += property.Name + pSeparator;
                }
            }

            return retVal.Substring(0, retVal.LastIndexOf(pSeparator));
        }
')
INSERT INTO [dbo].[SourcesRepository] ([IDrepository], [IDrepositoryType], [SourceName], [Abstract], [Contents]) VALUES (2, 1, 'PropertyIsMandatory', 'Funzione che ritorna un valore booleano sull''obbligatorietà di una proprietà (NOT NULLABLE)', N'        /// <summary>
        /// Funzione che ritorna un valore booleano sull''obbligatorietà di una proprietà (NOT NULLABLE)
        /// </summary>
        /// <param name="pPropertyName">Nome della proprietà da valutare</param>
        /// <returns>true se la proprietà specificata corrisponde ad un campo NON nullabile, false se il campo è nullabile, null se la proprietà non esiste</returns>
        public Boolean? PropertyIsMandatory(String pPropertyName)
        {
            #region Variabili
            Boolean?
                retVal = null;
            Boolean
                _propertyExists = false;

            PropertyInfo[]
                _properties = null;
            #endregion

            _properties = this.GetType().GetProperties();

            if (!String.IsNullOrEmpty(pPropertyName))
            {
                foreach (PropertyInfo property in _properties)
                {
                    if (property.Name.StartsWith(pPropertyName) && !_propertyExists)
                    {
                        _propertyExists = true;
                        if (!property.Name.EndsWith("_x"))
                        {
                            retVal = true;
                            break;
                        }
                        else
                        {
                            retVal = false;
                        }
                    }
                }
            }
            return retVal;
        }
')
INSERT INTO [dbo].[SourcesRepository] ([IDrepository], [IDrepositoryType], [SourceName], [Abstract], [Contents]) VALUES (3, 1, 'GetDefaultValue', 'Funzione che ritorna il valore di defaultdi un determinato tipo di dato (per i tipi didati nullabili, tipo int?, il valore ritornatoè null)', N'        /// <summary>
        /// Funzione che ritorna il valore di default
        /// di un determinato tipo di dato (per i tipi di
        /// dati nullabili, tipo int?, il valore ritornato
        /// è null)
        /// </summary>
        /// <param name="pT"></param>
        /// <returns></returns>
        public object GetDefaultValue(Type pT)
        {
            return (!pT.IsValueType || Nullable.GetUnderlyingType(pT) != null) ? null : (pT == typeof(DateTime)) ? new DateTime(1753, 1, 1, 12, 0, 0) : Activator.CreateInstance(pT);
        }
')
INSERT INTO [dbo].[SourcesRepository] ([IDrepository], [IDrepositoryType], [SourceName], [Abstract], [Contents]) VALUES (4, 1, 'NullOrValue', 'Funzione che ritorna il valore di una determinata proprietà della classe solo se il suo valore è stato popolato o, comunque, è diverso dal valore di default del tipo di dato. Nel caso in cui, invece, venga impostato il parametro "pForceDefaultValue" a true, se la proprietà scelta non è stata impostata, sarà ritornato il valore di default piuttosto che null.', N'        /// <summary>
        /// Funzione che ritorna il valore di una determinata
        /// proprietà della classe solo se il suo valore è
        /// stato popolato o, comunque, è diverso dal valore
        /// di default del tipo di dato.
        /// Nel caso in cui, invece, venga impostato il parametro
        /// "pForceDefaultValue" a true, se la proprietà scelta non è
        /// stata impostata, sarà ritornato il valore di default
        /// piuttosto che null.
        /// </summary>
        /// <param name="pPropertyName">Nome della proprietà sulla quale operare le valutazioni</param>
        /// <param name="pForceDefaultValue">Flag che determina se ritornare null (false) o il default (true)</param>
        /// <returns>Object</returns>
        public object NullOrValue(String pPropertyName, Boolean pForceDefaultValue)
        {
            #region Variabili
            PropertyInfo[]
                _properties = null;
            DateTime
            _dateProperty;
            String
                _currentValue = String.Empty;
            Object
                retVal = null; // Di default, se il valore della proprietà è uguale al valore di default, viene ritornato null
            #endregion

            _properties = this.GetType().GetProperties();

            foreach (PropertyInfo property in _properties)
            {
                if (!property.Name.EndsWith("__")) // esclude le proprietà non pertinenti la tabella
                {
                    if (property.Name == pPropertyName)
                    {
                        if (pForceDefaultValue)
                        {
                            retVal = GetDefaultValue(property.PropertyType); // Predispone il valore di ritorno a quello di default nel caso in cui la condizione successiva risulti falsa
                        }
                        else if (!Equals(property.GetValue(this, null), GetDefaultValue(property.PropertyType))) // Confronto tra oggetti
                        {
                            if (property.PropertyType == typeof(DateTime))
                            {
                                _dateProperty = Convert.ToDateTime(property.GetValue(this, null));
                                if (_dateProperty.Year == 1)
                                {
                                    retVal = null;
                                }
                            }
                            else
                            {
                                retVal = property.GetValue(this, null);
                            }
                        }
                        break;
                    }
                }
            }
            return retVal;
        }
')
EXEC(N'INSERT INTO [dbo].[SourcesRepository] ([IDrepository], [IDrepositoryType], [SourceName], [Abstract], [Contents]) VALUES (5, 4, ''ProgrammaPilotaEsempio'', ''Main program (Program.cs) che rappresenta un esempio di come utilizzare il meccanismo di CRUD dinamica'', N''using System;
using System.Collections.Generic;
using System.Data;
using System.Reflection;
using ENTITA_DETT.Base;

namespace EntitaDett
{
    class Program
    {
        /// <summary>
        /// Funzione MAIN
        /// </summary>
        /// <param name="args"></param>
        static void Main(string[] args)
        {
            #region Variabili
            // La variabile "pReturnValue" recepirà il numero di 
            // operazioni effettuate sul DataTable 
            // (righe inserite, cancellate, modificate e/o ritornate)
            int
                pReturnValue = 0;

            String
                _tableName = "ENTITA_DETT",
                _connStringSVIL = "Initial Catalog=Irpefweb;Data Source=SQLINPSSVIL06,2059;user id=IRPEFWEB;password=ops36mm89",
                _spName = "spSelInsUpdDel" + _tableName.Replace("_", ""),
                _whereCondition = String.Empty;
            DataTable
                _dt = null;
            entita_dett
                _ed = null;
            List<entita_dett>
                _edArray = new List<entita_dett>();
            #endregion

            // DEBUG
            // Elenco separato da punti e virgola 
            // delle proprietà obbligatorie
            //ListMandatoryProperties(); 

            // DEBUG
            // Elenco dettagliato delle proprietà 
            // e loro relativa obbligatorietà
            //ShowMandatoryProperties(); 

            // ===============================================================================
            // 1. Caricamento di tutte le righe dal DB (SELECT *) e rappresentazione dei 
            // dati senza nessun filtro applicato (equivalente a "WHERE 1=1")
            // ===============================================================================
            _ed = new entita_dett(); // Istanziamento della classe per lettura da DB
            _ed.ConnectionString__ = _connStringSVIL;
            _ed.SpName__ = _spName;

            _dt = new DataTable(_tableName); // Attribuzione del nome della tabella al DataTable

            // ---------------------------------------------------------------------
            // Caricamento di tutte le righe dal DB, 
            // la variabile pReturnValue conterrà il numero dei records interessati 
            // (0 nel caso in cui non vi siano records nella tabella)
            // ---------------------------------------------------------------------
            _dt = _ed.SelInsUpdDel("S", String.Empty, false, out pReturnValue);
            // ---------------------------------------------------------------------

            if (pReturnValue > 0)
            {
                // Popolamento dell''''array di classi 
                // con i valori provenienti dal DB
                _edArray = PopolaEDArray(_dt);

                // Rappresentazione a schermo dell''''array popolato
                DisplayEDArray("SELECT *", _edArray);
            }
            // ===============================================================================


            // ===============================================================================
            // 2. Inserimento di un record con dati casuali
            // ===============================================================================
            _ed = new entita_dett(); // Istanziamento della classe per predisposizione alla scrittura
            _ed.ConnectionString__ = _connStringSVIL;
            _ed.SpName__ = _spName;

            _ed.CodiceEntita = "RIT";
            _ed.CFCreditore = "RHPMTUMYXDOSAVTP";
            _ed.CFDebitore_x = "DMRPCQJJEHYPHZHB";
            _ed.CodicePrestazione_x = "HKPDZ";
            _ed.CodiceSede = "YTZQ5W";
            _ed.CodiceProcedura = "30B";
            _ed.Progressivo = 7313;
            _ed.Anno = 2015;
            _ed.Mese = "11";
            _ed.AnnoRif_x = null;
            _ed.MeseRif_x '')')
EXEC(N'UPDATE [dbo].[SourcesRepository] SET [Contents].WRITE(N''= null;
            _ed.ImportoCredito_x = 447433.31M;
            _ed.ImportoDebito = 268.23M;
            _ed.ImportoSospeso_x = 730744.83M;
            _ed.ImportoSospesoInAtto_x = 110073.89M;
            _ed.DataInserimento = DateTime.Now; // Convert.ToDateTime("2017-12-22 15:40:01.240");
            _ed.DataUltimaModifica = DateTime.Now; // Convert.ToDateTime("2016-06-25 15:40:01.240");
            _ed.CodiceRegione = "00";
            _ed.IdStruttura = 1;
            _ed.ChiaveARCAAnagraficaCodice_x = "NQH";
            _ed.ChiaveARCAAnagraficaProgressivo_x = 1012;
            _ed.ChiaveARCAPrestazione_x = "CTKXG78NRNPWMLUDC7FQZ6D7F2A7C8W6E4PJWJH6S4WEWJUNUG5EV8DAEFANG7P4BJSQMX6VGTGTKDMISZLQSMNEUFDF2R4XKBXGSGISADKSCGUEPMWKI2FWZTFZSC";

            // ---------------------------------------------------------------------
            // Inserimento nel DB, 
            // la variabile pReturnValue conterrà il numero dei records interessati 
            // (nel caso di una Insert questo valore è 1 
            // se il record è stato creato, 0 altrimenti)
            // ---------------------------------------------------------------------
            _dt = _ed.SelInsUpdDel("I", String.Empty, false, out pReturnValue);
            // ---------------------------------------------------------------------

            // ===============================================================================


            // ===============================================================================
            // 3. Modifica ai valori di alcuni campi sul DB (UPDATE), a titolo di esempio, 
            // tramite impostazione delle corrispondenti proprietà della classe 
            // e successiva rappresentazione dei dati
            //
            // N.B.: I valori di default (0 per gli interi, stringhe vuote per
            // le stringhe e così via) saranno ignorati nelle update a meno che
            // il parametro "pForceDefaultValue" della funzione SelInsUpdDel non 
            // venga impostato a TRUE: in questo caso, invece del valore null,
            // verrà utilizzato il valore di default per il tipo di dato 
            // corrispondente alla proprietà non valorizzata.
            // ===============================================================================
            _ed = new entita_dett();
            _ed.ConnectionString__ = _connStringSVIL;
            _ed.SpName__ = _spName;

            // Criterio di WHERE sull''''UPDATE
            _whereCondition = "CFCreditore = ''''RHPMTUMYXDOSAVTP'''' AND Anno = 2015 AND Mese = ''''11''''";

            // ------------------------------------
            // Campi che verranno modificati 
            // (si popolano solo le proprietà i cui 
            // corrispondenti campi si intendono 
            // alterare sul DB)
            // ------------------------------------
            _ed.CodicePrestazione_x = "5679B";
            _ed.ImportoDebito = 9110.31M;
            _ed.ImportoSospeso_x = 6549.74M;
            _ed.DataUltimaModifica = DateTime.Now;
            _ed.IdStruttura = 3;
            // ------------------------------------

            // ---------------------------------------------------------------------
            // Aggiornamento del DB, 
            // la variabile pReturnValue conterrà il numero dei records interessati 
            // (0 nel caso in cui nessun record abbia subìto modifiche)
            // ---------------------------------------------------------------------
            _ed.SelInsUpdDel("U", _whereCondition, false, out pReturnValue);
            // ---------------------------------------------------------------------

            // ===============================================================================


            // ===============================================================================
            // 4. Caricamento di una riga specifica dal DB (SELECT ... WHE'',NULL,NULL) WHERE [IDrepository]=5
UPDATE [dbo].[SourcesRepository] SET [Contents].WRITE(N''RE ...) 
            // e rappresentazione dei dati 
            // ===============================================================================
            _ed = new entita_dett(); // Istanziamento della classe per lettura da DB
            _ed.ConnectionString__ = _connStringSVIL;
            _ed.SpName__ = _spName;

            _dt = new DataTable(_tableName); // Attribuzione del nome della tabella al DataTable

            // ------------------------------------
            // Criterio di filtro sulla SELECT 
            // (si popolano solo le proprietà i cui 
            // valori saranno adottati come criterio 
            // di selezione dei records)
            // ------------------------------------
            _ed.CFCreditore = "RHPMTUMYXDOSAVTP";
            _ed.Anno = 2015;
            _ed.Mese = "11";
            // ------------------------------------

            // ---------------------------------------------------------------------
            // Caricamento di tutte le righe dal DB 
            // corrispondenti ai criteri impostati (proprietà valorizzate), 
            // la variabile pReturnValue conterrà il numero dei records interessati 
            // (0 nel caso in cui alcun record corrisponda ai criteri impostati)
            // ---------------------------------------------------------------------
            _dt = _ed.SelInsUpdDel("S", String.Empty, false, out pReturnValue);
            // ---------------------------------------------------------------------

            if (pReturnValue > 0)
            {
                // Popolamento dell''''array di classi 
                // con i valori provenienti dal DB
                _edArray = PopolaEDArray(_dt);

                // Rappresentazione a schermo dell''''array popolato
                DisplayEDArray
                (
                    String.Format
                    (
                        "SELECT * WHERE CFCreditore = ''''{0}'''' AND Anno = {1} AND Mese = ''''{2}''''",
                        _ed.CFCreditore,
                        _ed.Anno,
                        _ed.Mese
                    ),
                    _edArray
                );
            }
            // ===============================================================================


            // ===============================================================================
            // 5. Eliminazione di una riga specifica dal DB (DELETE FROM ... WHERE ...) 
            // e rappresentazione dei dati 
            // ===============================================================================
            _ed = new entita_dett(); // Istanziamento della classe per lettura da DB
            _ed.ConnectionString__ = _connStringSVIL;
            _ed.SpName__ = _spName;

            _dt = new DataTable(_tableName); // Attribuzione del nome della tabella al DataTable

            // ------------------------------------
            // Criterio di filtro sulla DELETE 
            // (si popolano solo le proprietà i cui 
            // valori saranno adottati come criterio 
            // per l''''eliminazione dei records)
            // ------------------------------------
            _ed.CFCreditore = "RHPMTUMYXDOSAVTP";
            _ed.Anno = 2015;
            _ed.Mese = "11";
            // ------------------------------------

            // ---------------------------------------------------------------------
            // Esecuzione dello statement di eliminazione, 
            // la variabile pReturnValue conterrà il numero dei records interessati 
            // (0 nel caso in cui alcun record sia stato eliminato)
            // ---------------------------------------------------------------------
            _dt = _ed.SelInsUpdDel("D", String.Empty, false, out pReturnValue);
            // ---------------------------------------------------------------------

            // ======================'',NULL,NULL) WHERE [IDrepository]=5
UPDATE [dbo].[SourcesRepository] SET [Contents].WRITE(N''=========================================================


            // ===============================================================================
            // 6. Modifica ai valori di alcuni campi sul DB, a titolo di esempio, 
            // tramite impostazione delle corrispondenti proprietà della classe 
            // e successiva rappresentazione dei dati
            //
            // N.B.: in questo esempio viene impostato a TRUE il parametro 
            // "pForceDefaultValue" che forzerà ai valori di default tutte le 
            // proprietà per le quali non viene impostato un valore
            // ===============================================================================

            // Istanziamento della classe CON FORZATURA ai valori default
            _ed = new entita_dett(true);
            _ed.ConnectionString__ = _connStringSVIL;
            _ed.SpName__ = _spName;

            // Criterio di WHERE sull''''UPDATE
            _whereCondition = "CFCreditore = ''''RCCWTR70E15H501Y'''' AND Anno = 2015 AND Mese = ''''11''''";

            // ------------------------------------
            // Campi che verranno modificati
            // ------------------------------------
            _ed.DataUltimaModifica = DateTime.Now;
            _ed.IdStruttura = 2;
            _ed.ImportoDebito = 777.31M;
            _ed.ImportoSospeso_x = 1258.74M;
            // ------------------------------------

            // ---------------------------------------------------------------------
            // Aggiornamento del DB, 
            // la variabile pReturnValue conterrà il numero dei records interessati 
            // (0 nel caso in cui nessun record abbia subìto modifiche)
            // ---------------------------------------------------------------------
            _ed.SelInsUpdDel("U", _whereCondition, true, out pReturnValue);
            // ---------------------------------------------------------------------

            // Rappresentazione a schermo dell''''array popolato
            DisplayEDArray(String.Format("UPDATE {0}", _whereCondition), _edArray);
            // ===============================================================================


            // ===============================================================================
            // 6b. Modifica ai valori di alcuni campi sul DB (UPDATE), a titolo di esempio, 
            // tramite impostazione delle corrispondenti proprietà della classe 
            // e successiva rappresentazione dei dati
            //
            // N.B.: in questo esempio viene impostato a TRUE il parametro 
            // "pForceDefaultValue" che forzerà ai valori di default tutte le 
            // proprietà per le quali non viene impostato un valore
            // ================================================================================
            _ed = new entita_dett();
            _ed.ConnectionString__ = _connStringSVIL;
            _ed.SpName__ = _spName;

            // Criterio di WHERE sull''''UPDATE
            _whereCondition = "CFCreditore = ''''RCCWTR70E15H501Y'''' AND Anno = 2015 AND Mese = ''''11''''";

            // ------------------------------------
            // Campi che verranno modificati
            // ------------------------------------
            _ed.DataUltimaModifica = DateTime.Now;
            _ed.IdStruttura = 2;
            _ed.ImportoDebito = 777.31M;
            _ed.ImportoSospeso_x = 1258.74M;
            // ------------------------------------

            // ---------------------------------------------------------------------
            // Aggiornamento del DB, 
            // la variabile pReturnValue conterrà il numero dei records interessati 
            // (0 nel caso in cui nessun record abbia subìto modifiche)
            // ---------------------------------------------------------------------
            _ed.SelInsUpdDel("U", _whereCondition, false, out '',NULL,NULL) WHERE [IDrepository]=5
UPDATE [dbo].[SourcesRepository] SET [Contents].WRITE(N''pReturnValue);
            // ---------------------------------------------------------------------

            // Rappresentazione a schermo dell''''array popolato
            DisplayEDArray(String.Format("UPDATE {0}", _whereCondition), _edArray);
            // ===============================================================================


            // ===============================================================================
            // 7. Caricamento di una riga specifica dal DB (SELECT ... WHERE ...) 
            // e rappresentazione dei dati 
            // ===============================================================================
            _ed = new entita_dett();
            _ed.ConnectionString__ = _connStringSVIL;
            _ed.SpName__ = _spName;

            _dt = new DataTable(_tableName); // Attribuzione del nome della tabella al DataTable

            // ------------------------------------
            // Criterio di filtro sulla SELECT
            // L''''impostazione delle proprietà, in 
            // caso di operazione "S" (select), 
            // fungerà da filtro
            // ------------------------------------
            _ed.CFCreditore = "RCCWTR70E15H501Y";
            _ed.Anno = 2015;
            _ed.Mese = "11";
            // ------------------------------------

            // ---------------------------------------------------------------------
            // Caricamento di tutte le righe dal DB corrispondenti ai criteri impostati (proprietà valorizzate), 
            // la variabile pReturnValue conterrà il numero dei records interessati 
            // (0 nel caso in cui alcun record corrisponda ai criteri impostati)
            // ---------------------------------------------------------------------
            _dt = _ed.SelInsUpdDel("S", String.Empty, false, out pReturnValue);
            // ---------------------------------------------------------------------

            if (pReturnValue > 0)
            {
                // Popolamento dell''''array di classi 
                // con i valori provenienti dal DB
                _edArray = PopolaEDArray(_dt);

                // Rappresentazione a schermo dell''''array popolato
                DisplayEDArray
                (
                    String.Format
                    (
                        "SELECT * WHERE CFCreditore = ''''{0}'''' AND Anno = {1} AND Mese = ''''{2}''''",
                        _ed.CFCreditore,
                        _ed.Anno,
                        _ed.Mese
                    )
                    , _edArray
                );
            }
            // ===============================================================================


            Console.WriteLine("Fine elaborazione: premere un tasto per terminare l''''applicazione.");
            Console.ReadLine();
        }

        /// <summary>
        /// Funzione per il popolamento di un array di classi "entita_dett"
        /// </summary>
        /// <param name="pDt"></param>
        /// <returns>List<entita_dett></returns>
        static List<entita_dett> PopolaEDArray(DataTable pDt)
        {
            #region Variabili
            List<entita_dett>
                retVal = null;
            entita_dett
                _ed = null;
            PropertyInfo[]
                _properties = typeof(entita_dett).GetProperties();
            String
                _propertyName = String.Empty;
            object
                _rowValue = null;
            #endregion

            if (pDt != null && pDt.Rows.Count > 0)
            {
                retVal = new List<entita_dett>();

                // Ciclo attraverso tutte le righe del DataTable
                foreach (DataRow currentRow in pDt.Rows)
                {
                    // Istanziamento di una nuova classe "entita_dett" ad ogni riga del DataTable
                    _ed = new entita_dett();

'',NULL,NULL) WHER'
+N'E [IDrepository]=5
UPDATE [dbo].[SourcesRepository] SET [Contents].WRITE(N''                    // Popolamento delle proprietà della classe istanziata
                    foreach (PropertyInfo property in _properties)
                    {
                        _propertyName = property.Name.Replace("_x", String.Empty);
                        if (!_propertyName.EndsWith("__")) // esclude le proprietà non pertinenti la tabella
                        {
                            _rowValue = (object)currentRow[_propertyName];

                            if (property.PropertyType.Name == "String")
                            {
                                property.SetValue(_ed, ConvertFromDBVal<String>(_rowValue), null);
                            }
                            else
                            {
                                _rowValue = (_rowValue == System.DBNull.Value)
                                    ? null
                                    : _rowValue;

                                property.SetValue(_ed, _rowValue, null);
                            }
                        }
                    }

                    // Aggiunta della classe appena popolata 
                    // all''''array/lista delle classi "entita_dett"
                    retVal.Add(_ed);
                }
            }
            return retVal;
        }

        /// <summary>
        /// Funzione per la rappresentazione a console 
        /// dei contenuti dell''''array di classi "entita_dett"
        /// </summary>
        /// <param name="pEDarray"></param>
        static void DisplayEDArray(String pIntestazione, List<entita_dett> pEDarray)
        {
            #region Variabili
            String
                _currentValue = String.Empty;
            PropertyInfo[]
                _properties = typeof(entita_dett).GetProperties();
            #endregion

            if (!String.IsNullOrEmpty(pIntestazione))
            {
                Console.WriteLine(pIntestazione);
                Console.WriteLine("-------------------------------------------");
            }

            if (pEDarray != null)
            {
                foreach (entita_dett currentEd in pEDarray)
                {
                    // Lettura proprietà della classe
                    foreach (PropertyInfo property in _properties)
                    {
                        if (!property.Name.EndsWith("__")) // esclude le proprietà non pertinenti la tabella
                        {
                            _currentValue = (property.GetValue(currentEd, null) == null)
                                 ? string.Empty
                                 : property.GetValue(currentEd, null).ToString();

                            Console.WriteLine(String.Format("{0} = {1}", property.Name, _currentValue));
                        }
                    }
                    Console.WriteLine("-------------------------------------------");
                }
            }
            else
            {
                Console.WriteLine("L''''array/lista di classi non contiene elementi.");
            }
        }

        /// <summary>
        /// Funzione per la conversione dei System.DBNull
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="obj"></param>
        /// <returns>T</returns>
        static T ConvertFromDBVal<T>(object obj)
        {
            return (obj == null || obj == DBNull.Value)
                ? default(T)
                : (T)obj;
        }

        /// <summary>
        /// Funzione che ritorna l''''elenco separato 
        /// da punti e virgola, delle proprietà obbligatorie
        /// </summary>
        static void ListMandatoryProperties()
        {
            #region Variabili
            entita_dett
                _ed = new entita_dett();
            #endregion

            Console.WriteLine(_ed.ListMandatoryProperties(";"));
        }

        ///'',NULL,NULL) WHERE [IDrepository]=5
UPDATE [dbo].[SourcesRepository] SET [Contents].WRITE(N'' <summary>
        /// Funzione che ritorna l''''elenco dettagliato 
        /// delle proprietà e loro relativa obbligatorietà
        /// </summary>
        static void ShowMandatoryProperties()
        {
            #region Variabili
            entita_dett
                _ed = new entita_dett();
            PropertyInfo[]
                _properties = typeof(entita_dett).GetProperties();
            #endregion

            foreach (PropertyInfo property in _properties)
            {
                if (!property.Name.EndsWith("__")) // esclude le proprietà non pertinenti la tabella
                {
                    Console.WriteLine
                    (
                        String.Format
                        (
                            "{0} (mandatory = {1})",
                            property.Name,
                            _ed.PropertyIsMandatory(property.Name).ToString()
                        )
                    );
                }
            }
        }
    }
}
'',NULL,NULL) WHERE [IDrepository]=5
')
INSERT INTO [dbo].[SourcesRepository] ([IDrepository], [IDrepositoryType], [SourceName], [Abstract], [Contents]) VALUES (6, 1, 'PropertiesToDT', 'Trasferisce i valori delle proprietà della classe ad un DataTable di riferimento avente una struttura adeguata al recepimento dei valori della classe passata ', N'        /// <summary>
        /// Trasferisce i valori delle proprietà della
        /// classe ad un DataTable di riferimento avente
        /// una struttura adeguata al recepimento dei
        /// valori della classe passata
        /// </summary>
        /// <param name="pDt">DataTable di riferimento</param>
        public void PropertiesToDT(ref DataTable pDt)
        {
            #region Variabili
            DataTable
                retVal = null;
            PropertyInfo[]
                    _properties = this.GetType().GetProperties();
            String
                _propertyName;
            #endregion

            if (this != null && pDt != null && pDt.Rows.Count > 0)
            {
                retVal = new DataTable();

                // Ciclo attraverso tutte le righe del DataTable
                foreach (DataRow currentRow in pDt.Rows)
                {
                    // Recupero dei valori delle proprietà della classe passata
                    foreach (PropertyInfo property in _properties)
                    {
                        _propertyName = property.Name.Replace("_x", String.Empty).Replace("_PK", String.Empty);
                        if (!_propertyName.EndsWith("__")) // esclude le proprietà non pertinenti la tabella
                        {
                            currentRow[_propertyName] = (property.GetValue(this, null) == null)
                                ? System.DBNull.Value
                                : property.GetValue(this, null);
                        }
                    }
                }
            }
        }
')
INSERT INTO [dbo].[SourcesRepository] ([IDrepository], [IDrepositoryType], [SourceName], [Abstract], [Contents]) VALUES (7, 1, 'BuildWhereCondition', 'Funzione preposta alla costruzione di una stringa (da impiegare come "Where condition" per un''UPDATE SQL) sulla base dei campi chiave (PK) ', N'        /// <summary>
        /// Funzione preposta alla costruzione di una stringa 
        /// (da impiegare come "Where condition" per un''UPDATE SQL)
        /// sulla base dei campi chiave (PK)
        /// </summary>
        /// <param name="pEd">Classe contenitrice</param>
        /// <returns>Stringa WhereCondition costruita</returns>
        public String BuildWhereCondition()
        {
            #region Variabili
            String
                retVal = null,
                _propertyName = String.Empty,
                _whereCondition = "1=1",
                _andCondition = String.Empty,
                _propertyType;
            Object
                _cellValue = null;
            PropertyInfo[]
                _properties = this.GetType().GetProperties();
            #endregion

            if (this != null)
            {
                foreach (PropertyInfo property in _properties)
                {
                    _propertyName = property.Name;
                    _propertyType = property.PropertyType.Name;

                    if (!_propertyName.EndsWith("__")) // esclude le proprietà non pertinenti i campi della tabella origine
                    {
                        _cellValue = (property.GetValue(this, null) == null)
                                ? System.DBNull.Value
                                : property.GetValue(this, null);

                        if (_propertyName.EndsWith("_PK"))
                        {
                            _andCondition = " AND {0}";
                            _andCondition +=
                                (
                                    _propertyType == "String" ||
                                    _propertyType == "Char" ||
                                    _propertyType == "Byte" ||
                                    _propertyType == "Byte[]" ||
                                    _propertyType == "DateTime" ||
                                    _propertyType == "DateTimeOffset"
                                )
                                ? " = ''{1}''"
                                : " = {1}";
                            _whereCondition += String.Format(_andCondition, _propertyName.Replace("_x", String.Empty).Replace("_PK", String.Empty), _cellValue);
                        }
                    }
                }
                retVal = (_whereCondition == "1=1")
                    ? null
                    : _whereCondition;
            }
            return retVal;
        }
')
INSERT INTO [dbo].[SourcesRepository] ([IDrepository], [IDrepositoryType], [SourceName], [Abstract], [Contents]) VALUES (8, 1, 'PropertyIsPrimaryKey', 'Funzione che ritorna un valore booleano in base al fatto se una proprietà corrisponde ad una primary key o meno', N'        /// <summary>
        /// Funzione che ritorna un valore booleano in base al fatto
        /// se una proprietà corrisponde ad una primary key o meno
        /// </summary>
        /// <param name="pPropertyName">Nome della proprietà da valutare</param>
        /// <returns>Ritorna TRUE se la proprietà specificata corrisponde ad un campo NON nullabile, TRUE se il campo è nullabile, null se la proprietà non esiste</returns>
        public Boolean? PropertyIsPrimaryKey(String pPropertyName)
        {
            Boolean?
                retVal = null;
            Boolean
                _propertyExists = false;

            PropertyInfo[]
                _properties = null;

            _properties = this.GetType().GetProperties();

            if (!String.IsNullOrEmpty(pPropertyName))
            {
                foreach (PropertyInfo property in _properties)
                {
                    if (property.Name.StartsWith(pPropertyName) && !_propertyExists)
                    {
                        _propertyExists = true;
                        if (!property.Name.EndsWith("_PK"))
                        {
                            retVal = true;
                            break;
                        }
                        else
                        {
                            retVal = false;
                        }
                    }
                }
            }
            return retVal;
        }
')
INSERT INTO [dbo].[SourcesRepository] ([IDrepository], [IDrepositoryType], [SourceName], [Abstract], [Contents]) VALUES (9, 1, 'ListPrimaryKeyProperties', 'Funzione che ritorna l''elenco delle proprietà di tipo PrimaryKey', N'        /// <summary>
        /// Funzione che ritorna l''elenco delle proprietà di tipo PrimaryKey
        /// </summary>
        /// <param name="pSeparator">Carattere separatore (; , | etc.)</param>
        /// <returns>String</returns>
        public String ListPrimaryKeyProperties(String pSeparator)
        {
            String
                retVal = String.Empty;

            PropertyInfo[]
                _properties = null;

            pSeparator = (String.IsNullOrEmpty(pSeparator)) ? ";" : pSeparator;

            _properties = this.GetType().GetProperties();

            foreach (PropertyInfo property in _properties)
            {
                if (!property.Name.EndsWith("_PK"))
                {
                    retVal += property.Name + pSeparator;
                }
            }

            return retVal.Substring(0, retVal.LastIndexOf(pSeparator));
        }
')
INSERT INTO [dbo].[SourcesRepository] ([IDrepository], [IDrepositoryType], [SourceName], [Abstract], [Contents]) VALUES (10, 1, 'IsGuid', 'Funzione che ritorna true se la stringa passata è di tipo GUID', N'        /// <summary>
        /// Funzione che ritorna true se la stringa passata
        /// è di tipo GUID
        /// </summary>
        /// <param name="pStringValue">Stringa da verificare</param>
        /// <returns>Boolean (TRUE se la stringa è un GUID valido, FALSE altrimenti)</returns>
        public Boolean IsGuid(String pStringValue)
        {
            string guidPattern = @"[a-fA-F0-9]{8}(\-[a-fA-F0-9]{4}){3}\-[a-fA-F0-9]{12}";
            if (string.IsNullOrEmpty(pStringValue))
                return false;
            Regex reguidPattern = new Regex(guidPattern);
            return reguidPattern.IsMatch(pStringValue);
        }
')
INSERT INTO [dbo].[SourcesRepository] ([IDrepository], [IDrepositoryType], [SourceName], [Abstract], [Contents]) VALUES (11, 1, 'ConvertFromDBVal', 'Funzione per la conversione dei System.DBNull', N'        /// <summary>
        /// Funzione per la conversione dei System.DBNull
        /// </summary>
        /// <typeparam name="T">Tipo di dato sul quale effettuare il cast o del quale ritornare il valore di default</typeparam>
        /// <param name="pObj">Oggetto da verificare</param>
        /// <returns>Se il valore dell''oggetto in ingresso è null, ritorna il valore di default per il tipo "T" specificato oppure il valore già castato dell''oggetto in ingresso</returns>
        public T ConvertFromDBVal<T>(object pObj)
        {
            return (pObj == null || pObj == DBNull.Value) ? default(T) : (T)pObj;
        }
')
EXEC(N'INSERT INTO [dbo].[SourcesRepository] ([IDrepository], [IDrepositoryType], [SourceName], [Abstract], [Contents]) VALUES (12, 1, ''SetPropertyValue'', ''Funzione che converte un valore stringa al tipo corretto della proprietà in corso di valorizzazione '', N''        /// <summary>
        /// Funzione che converte un valore stringa al tipo corretto
        /// della proprietà in corso di valorizzazione
        /// </summary>
        /// <param name="pProperty">La proprietà alla quale si intende attribuire il valore</param>
        /// <param name="pCellValue">Il valore stringa da convertire al tipo corretto da assegnare</param>
        public void SetPropertyValue(PropertyInfo pProperty, String pCellValue)
        {
            #region Variabili
            Type
                _propertyType;
            String
                _propertyName = String.Empty;
            PropertyInfo[]
                _properties = this.GetType().GetProperties();
            int
                _returnIntValue;
            short
                _returnShortValue;
            long
                _returnLongValue;
            DateTime
                _returnDateTimeValue;
            DateTimeOffset
                _returnDateOffsetTimeValue;
            TimeSpan
                _returnTimeSpanValue;
            Boolean
                _tryOp = false,
                _returnBooleanValue;
            Decimal
                _returnDecimalValue;
            Double
                _returnDoubleValue;
            float
                _returnFloatValue;
            Byte
                _returnByteResult;
            Byte[]
                _returnByteArrayResult;
            #endregion

            if (this != null && !String.IsNullOrEmpty(pCellValue))
            {
                _propertyName = pProperty.Name.Replace("_x", String.Empty);
                if (!_propertyName.EndsWith("__")) // esclude le proprietà non pertinenti la tabella
                {
                    // Estrazione del tipo di variabile in caso di variabile nullabile
                    _propertyType = pProperty.PropertyType;

                    if (_propertyType.IsGenericType && _propertyType.GetGenericTypeDefinition() == typeof(Nullable<>))
                    {
                        _propertyType = _propertyType.GetGenericArguments()[0];
                    }

                    switch (_propertyType.Name)
                    {
                        case "String":
                            pProperty.SetValue(this, ConvertFromDBVal<String>(pCellValue), null);
                            break;
                        case "Char":
                            pProperty.SetValue(this, ConvertFromDBVal<Char>(pCellValue), null);
                            break;
                        case "int":
                            _tryOp = int.TryParse(pCellValue, out _returnIntValue);
                            pProperty.SetValue(this, ((_tryOp) ? _returnIntValue : this.GetDefaultValue(typeof(int))), null);
                            break;
                        case "Int16":
                        case "short":
                            _tryOp = Int16.TryParse(pCellValue, out  _returnShortValue);
                            pProperty.SetValue(this, ((_tryOp) ? _returnShortValue : this.GetDefaultValue(typeof(short))), null);
                            break;
                        case "Int32":
                            _tryOp = Int32.TryParse(pCellValue, out  _returnIntValue);
                            pProperty.SetValue(this, ((_tryOp) ? _returnIntValue : this.GetDefaultValue(typeof(Int32))), null);
                            break;
                        case "long":
                            _tryOp = long.TryParse(pCellValue, out  _returnLongValue);
                            pProperty.SetValue(this, ((_tryOp) ? _returnLongValue : this.GetDefaultValue(typeof(long))), null);
                            break;
                        case "DateTime":
                            _returnDateTimeValue = DateTime.Parse(pCellValue, System.Globalization.CultureInfo.InvariantCulture);
                            pProperty.SetValue(this, _'')')
UPDATE [dbo].[SourcesRepository] SET [Contents].WRITE(N'returnDateTimeValue, null);
                            break;
                        case "DateTimeOffset":
                            _returnDateTimeValue = DateTime.ParseExact(pCellValue, "yyyy-MM-ddTHH:mm:ss.fffzzz:00", System.Globalization.CultureInfo.InvariantCulture);
                            _returnDateOffsetTimeValue = DateTime.SpecifyKind(_returnDateTimeValue, DateTimeKind.Local);
                            pProperty.SetValue(this, _returnDateOffsetTimeValue, null);
                            break;
                        case "TimeSpan":
                            _returnTimeSpanValue = TimeSpan.ParseExact(pCellValue, @"h\:m", System.Globalization.CultureInfo.InvariantCulture);
                            pProperty.SetValue(this, _returnTimeSpanValue, null);
                            break;
                        case "Guid":
                            _tryOp = IsGuid(pCellValue);
                            pProperty.SetValue(this, ((_tryOp) ? pCellValue : this.GetDefaultValue(typeof(Guid))), null);
                            break;
                        case "Decimal":
                            _tryOp = Decimal.TryParse(pCellValue, out _returnDecimalValue);
                            pProperty.SetValue(this, ((_tryOp) ? _returnDecimalValue : this.GetDefaultValue(typeof(Decimal))), null);
                            break;
                        case "Double":
                            _tryOp = Double.TryParse(pCellValue, out _returnDoubleValue);
                            pProperty.SetValue(this, ((_tryOp) ? _returnDoubleValue : this.GetDefaultValue(typeof(Double))), null);
                            break;
                        case "float":
                            _tryOp = float.TryParse(pCellValue, out _returnFloatValue);
                            pProperty.SetValue(this, ((_tryOp) ? _returnFloatValue : this.GetDefaultValue(typeof(float))), null);
                            break;
                        case "Boolean":
                            _tryOp = Boolean.TryParse(pCellValue, out _returnBooleanValue);
                            pProperty.SetValue(this, ((_tryOp) ? _returnBooleanValue : this.GetDefaultValue(typeof(Boolean))), null);
                            break;
                        case "Byte":
                            _tryOp = Byte.TryParse(pCellValue, out _returnByteResult);
                            pProperty.SetValue(this, ((_tryOp) ? _returnByteResult : this.GetDefaultValue(typeof(Byte))), null);
                            break;
                        case "Byte[]":
                            _returnByteArrayResult = new byte[pCellValue.Length * sizeof(char)];
                            System.Buffer.BlockCopy(pCellValue.ToCharArray(), 0, _returnByteArrayResult, 0, _returnByteArrayResult.Length);
                            pProperty.SetValue(this, _returnByteArrayResult, null);
                            break;
                        default:
                            pProperty.SetValue(this, pCellValue, null);
                            break;
                    }
                }
            }
        }
',NULL,NULL) WHERE [IDrepository]=12
INSERT INTO [dbo].[SourcesRepository] ([IDrepository], [IDrepositoryType], [SourceName], [Abstract], [Contents]) VALUES (13, 5, 'GridViewStyle', 'Classi principali di un GridView (come definito dalla funzione fnBuildCsharpGridView)', N'/* GridView elements */
.gvStyle
{
    background-color: transparent;
    border: 0px solid none;
    text-align: center;
    width: 100%;
    font-size: 0.8em;
}

.gvEmptyDataRowStyle
{
    border: 0px solid none;
    background-color: DarkSlateGray;
    color: Red;
    font-size: 1.1em;
    text-align: center;
}

.gvOdd
{
    font-family: Calibri, Cambria, Verdana, Sans-Serif;
    background: DarkGrey;
    color: White;
    font-weight: bold;
}

.gvEven
{
    font-family: Calibri, Cambria, Verdana, Sans-Serif;
    background: Grey; 
    color: White;
    font-weight: bold;
}

.gvSelectedRowStyle
{
    border: 1px solid white;
    background-color: ForestGreen;
    color: White;
    font-weight: bold;
}

.gvHeaderStyle
{
    height: 30px;
    text-align: center;
    padding: 8px;
    text-transform: uppercase;
    font-family: Calibri, Cambria, Verdana, Sans-Serif;
    font-size: 1em;
    color: White;
    background: SlateGrey; 
}

.gvPagerStyle
{
    font-family: Calibri, Cambria, Verdana, Sans-Serif;
    margin: 1px;
    padding: 1px;
    color: White;
}

.gvPagerStyle span
{
    font-family: Calibri, Cambria, Verdana, Sans-Serif;
    font-size: 1.5em;
    border: 1px solid none;
    margin: 1px;
    padding: 1px;
    color: Orange;
}

.gvPagerStyle a
{
    font-family: Calibri, Cambria, Verdana, Sans-Serif;
    font-size: 1.1em;
    border: 1px solid none;
    margin: 1px;
    padding: 1px;
    color: White;
}

.gvPagerStyle a:hover
{
    font-family: Calibri, Cambria, Verdana, Sans-Serif;
    font-size: 1.1em;
    border: 1px solid Orange;
    margin: 0px;
    padding: 1px;
    text-decoration: none;
    color: Orange;
}

.gvFooterStyle
{
    background: SlateGray;
    font-weight: bold; 
    font-size: 1.1em;
    color: White;
}
/* END GridView elements */
')
EXEC(N'INSERT INTO [dbo].[SourcesRepository] ([IDrepository], [IDrepositoryType], [SourceName], [Abstract], [Contents]) VALUES (14, 1, ''GridViewEventsCodeBehind'', ''Template dei metodi pubblici per la gestione degli eventi di un GridView'', N''        #region Eventi GridView
        /// <summary>
        /// 
        /// </summary>
        /// <param name="pDt"></param>
        protected void gvbind()
        {
        		// "$TableName" è un DataTable contenente la stessa identica
        		// definizione dei campi della tabella origine
            if ($TableName != null && $TableName.Rows.Count > 0)
            {
                gv$TableName.DataSource = $TableName;
            }
            else if ($TableName != null)
            {
                $TableName.Rows.Add($TableName.NewRow());
                gv$TableName.DataSource = $TableName;
                gv$TableName.DataBind();
                int columncount = gv$TableName.Rows[0].Cells.Count;
                gv$TableName.Rows[0].Cells.Clear();
                gv$TableName.Rows[0].Cells.Add(new TableCell());
                gv$TableName.Rows[0].Cells[0].ColumnSpan = columncount;
                gv$TableName.Rows[0].Cells[0].Text = "No Records Found";
            }
            gv$TableName.DataBind();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void gv$TableName_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {

							// Aggiungere il codice di gestione
							// della fase di caricamento dati da DB (sulla griglia)

            }
            if (e.Row.RowType == DataControlRowType.Footer)
            {

							// Aggiungere il codice di gestione
							// della fase di caricamento dati da DB (sul footer)

            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void gv$TableName_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            GridViewRow row = (GridViewRow)gv$TableName.Rows[e.RowIndex];

						// Aggiungere il codice di gestione
						// della fase di cancellazione su DB

            gvbind();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void gv$TableName_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gv$TableName.EditIndex = e.NewEditIndex;

						// Aggiungere il codice di gestione
						// della fase di pre-scrittura su DB

            gvbind();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void gv$TableName_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gv$TableName.PageIndex = e.NewPageIndex;
            gvbind();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void gv$TableName_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gv$TableName.EditIndex = -1;
            gvbind();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void gv$TableName_RowUpdated(object sender, GridViewUpdatedEventArgs e)
        {
 
						// Aggiungere il codice di gestione
						// della fase successiva alla scrittura su DB

           gvbind();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void gv$TableName_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            #region Variabili
            GridViewRow
                row = ((GridView)sender).Rows[e.Row'')')
UPDATE [dbo].[SourcesRepository] SET [Contents].WRITE(N'Index];
            int
                _returnIntValue;
            #endregion

						// Aggiungere il codice di gestione
						// della fase di scrittura su DB

            // Conclude la sessione di editing
            gv$TableName.EditIndex = -1;
            
            // Rieffettua il binding
            gvbind();
        }
        #endregion
',NULL,NULL) WHERE [IDrepository]=14
INSERT INTO [dbo].[SourcesRepository] ([IDrepository], [IDrepositoryType], [SourceName], [Abstract], [Contents]) VALUES (15, 1, 'GridViewAspxElementsTop', 'Template (utilizzato esclusivamente dalla funzione "dbo.fnBuildCsharpGridViewCodeBehind") della definizione degli elementi ASPX (parte iniziale) di un GridView dinamico', N'	<asp:GridView 
		ID="gv$TableName" 
		runat="server" 
		Visible="true" 

		ShowHeader="true"
		ShowFooter="true"

		EnableViewState="true"

		AutoGenerateColumns="false" 
		AutoGenerateDeleteButton="false" 
		AutoGenerateEditButton="false" 
		AutoGenerateSelectButton="false" 

		CssClass="gvStyle" 
		CellPadding="2" 
		CellSpacing="2" 
		GridLines="Horizontal" 

		AllowPaging="true" 
		PageSize="10" 
		AllowSorting="true" 
		EnableSortingAndPagingCallbacks="false" 

		OnPageIndexChanging="gv$TableName_PageIndexChanging" 
		OnRowCancelingEdit="gv$TableName_RowCancelingEdit" 
		OnRowDeleting="gv$TableName_RowDeleting" 
		OnRowEditing="gv$TableName_RowEditing" 
		OnRowUpdated="gv$TableName_RowUpdated" 
		OnRowUpdating="gv$TableName_RowUpdating" 

		EmptyDataText="Nessun record trovato." 

		DataKeyNames=" CodiceEntita,CFCreditore,CodiceSede,CodiceProcedura,Progressivo,Anno,Mese,IdStruttura " 
		>

		<Columns>
			<asp:CommandField 
				ShowInsertButton="true" 
				ShowEditButton="true" 
				ShowDeleteButton="true" 
				ShowSelectButton="true" 

				CancelText="X" 
				DeleteText="D" 
				EditText="E" 
				InsertText="I" 
				NewText="N" 
				SelectText="S" 
				UpdateText="U" 

				InsertVisible="true" />
')
INSERT INTO [dbo].[SourcesRepository] ([IDrepository], [IDrepositoryType], [SourceName], [Abstract], [Contents]) VALUES (16, 1, 'GridViewAspxElementsBottom', 'Template (utilizzato esclusivamente dalla funzione "dbo.fnBuildCsharpGridViewCodeBehind") della definizione degli elementi ASPX (parte finale) di un GridView dinamico', N'		</Columns>		<HeaderStyle CssClass="gvHeaderStyle" />		<RowStyle CssClass="gvOdd" />		<AlternatingRowStyle CssClass="gvEven" />		<SelectedRowStyle CssClass="gvSelectedRowStyle" />		<PagerSettings 			FirstPageText="«" 			LastPageText="»" 			Mode="NumericFirstLast" 			Position="TopAndBottom" 			PageButtonCount="10" />		<PagerStyle CssClass="gvPagerStyle" HorizontalAlign="Center" />		<FooterStyle CssClass="gvFooterStyle" />	</asp:GridView>')
SET IDENTITY_INSERT [dbo].[SourcesRepository] OFF
COMMIT TRANSACTION
GO
