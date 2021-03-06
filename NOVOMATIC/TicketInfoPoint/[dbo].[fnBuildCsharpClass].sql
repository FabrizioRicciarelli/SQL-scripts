/*
---------------------------------------------------------------------------------------------
Funzione preposta alla creazione di una classe C# partendo dalla struttura di una tabella SQL

Si avvale delle seguenti funzioni subordinate:
- dbo.fnGetTableDef
- dbo.fnFillSqlTemplateWithFieldsList
- dbo.fnCleanVariableName

N.B.:
Usare sempre la SELECT per invocare la presente funzione; una volta eseguita, copiare 
il contenuto della colonna 'EntityClass' e incollarla all'interno di una finestra di 
Visual Studio preposta al recepimento di una classe CS.

Per creare la classe principale in C# della Crud dinamica (DYNACRUD), invocare la funzione
"dbo.fnBuildCsharpClass"

Per creare la definizione degli elementi ASPX per un GridView, invocare la funzione 
"dbo.fnBuildCsharpGridViewASPX".

Per creare la definizione degli elementi CSS per un GridView, invocare la funzione 
invocare la funzione "dbo.fnBuildCsharpGridViewCSS".
		
Per creare il codice C# del CodeBehind di gestione degli eventi di un GridView, invocare la 
funzione "dbo.fnBuildCsharpGridViewCS".

---------------------------------------------------------------------------------------------
* DYNACRUD v.1.0 *

Fabrizio Ricciarelli per Eustema SpA
04/12/2015
---------------------------------------------------------------------------------------------
Esempi di invocazione:

SELECT dbo.fnBuildCsharpClass('ENTITA_DETT') AS EntityClass
SELECT dbo.fnBuildCsharpClass('MEMO78') AS EntityClass
SELECT dbo.fnBuildCsharpClass('COMUNICAZIONE_PSR') AS EntityClass
---------------------------------------------------------------------------------------------
*/
CREATE FUNCTION	[dbo].[fnBuildCsharpClass](@TableName SYSNAME)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE 
			@CR char(1) = CHAR(13)
			,@CR2 char(2) = CHAR(13) + CHAR(13)
			,@TAB char(1) = CHAR(9)
			,@TAB2 char(2) = CHAR(9) + CHAR(9)
			,@TAB3 char(3) = CHAR(9) + CHAR(9) + CHAR(9)
			,@TAB4 char(4) = REPLICATE(CHAR(9),4)
			,@TAB5 char(5) = REPLICATE(CHAR(9),5)
			,@TAB6 char(6) = REPLICATE(CHAR(9),6)
			,@TAB7 char(7) = REPLICATE(CHAR(9),7)
			,@TAB8 char(8) = REPLICATE(CHAR(9),8)
			,@class varchar(MAX)
			,@className SYSNAME
			,@regionPrivate varchar(50)
			,@regionPublic varchar(50)
			,@regionConstructors varchar(50)
			,@connectionString varchar(2048)
			,@dynamicCRUDspName varchar(100) 
			,@regionPublicMethods varchar(50)
			,@endregion varchar(20)
			,@summary varchar(100)
			,@functionsAccessories varchar(MAX)

	--------------------------------------------------------------------------
	-- Valorizzazione delle costanti
	--------------------------------------------------------------------------
	SET @regionPrivate = @TAB2 + '#region Variabili private' + @CR
	SET @regionPublic = @CR + @TAB2 + '#region Proprietà pubbliche' + @CR
	SET @regionConstructors = @CR + @TAB2 + '#region Costruttori' + @CR
	SET @regionPublicMethods = @CR + @TAB2 + '#region Metodi pubblici' + @CR
	SET @endRegion = @TAB2 + '#endregion' + @CR
	SET @summary = @TAB2 + '/// <summary>' + @CR + @TAB2 + '///' + @CR + @TAB2 + '/// </summary>' + @CR
	
	SET @connectionString = '"Initial Catalog=Irpefweb;Data Source=SQLINPSSVIL06,2059;user id=IRPEFWEB;password=ops36mm89"; // commentare o rimpiazzare con eventuale stringa di connessione già presente'
	SET @dynamicCRUDspName = '"spSelInsUpdDel' + REPLACE(@tableName,'_','') + '"'
	SET @className = LOWER(@TableName)
	SET @class = ''
	--------------------------------------------------------------------------


	--------------------------------------------------------------------------
	-- PRELIEVO DELLE FUNZIONI (METODI) ACCESSORI DAL REPOSITORY DEI SORGENTI
	--------------------------------------------------------------------------
	SELECT	@functionsAccessories = COALESCE(@functionsAccessories,'') + @CR2 + Contents
	FROM	V_SourcesRepository
	WHERE	RepositoryDescription = 'Funzione C#'


	--------------------------------------------------------------------------
	-- Rimpiazzo di tutti i placeholders dei nomi di tabella (nome della classe) 
	-- con il nome della tabella corrente, in minuscolo
	--------------------------------------------------------------------------
	SELECT	@functionsAccessories = REPLACE(@functionsAccessories, '$className', @className)
	--------------------------------------------------------------------------


	--------------------------------------------------------------------------
	-- INTESTAZIONE DELLA CLASSE
	--------------------------------------------------------------------------
	SET @class +=	'using System;' + @CR + 
					'using System.Data; ' + @CR + 
					'using System.Data.SqlClient;' + @CR +
					'using System.Reflection;' + @CR + 
					'using System.Text.RegularExpressions;' + @CR2 + 

					'namespace ' + UPPER(@TableName) + '.Base' + @CR + 
					'{' + @CR + 
					REPLACE(@summary,@TAB2,@TAB) +
					@TAB + 'public class ' + @className + @CR + 
					@TAB + '{' + @CR

	--------------------------------------------------------------------------
	-- VARIABILI PRIVATE DELLA CLASSE
	--------------------------------------------------------------------------
	SET @class +=	@regionPrivate +
					@TAB2 + '// Le variabili private di classe terminanti col suffisso "_x" sono quelle corrispondenti alle colonne "nullabili" della tabella fisica.' + @CR + 
					dbo.fnFillSqlTemplateWithFieldsListOrdered(@TAB2 + 'private $# $^;' + @CR,@TableName,'cSharpPublicPropertyName') + @CR +
					@TAB2 + '// Variabili private "speciali" che non sono collegate in nessun modo ai campi fisici della tabella' + @CR + 
					@TAB2 + 'private String _connectionString__;' + @CR + 
					@TAB2 + 'private String _spName__;' + @CR +
					@endregion -- classe c# (Variabili private)

	--------------------------------------------------------------------------
	-- PROPRIETA' PUBBLICHE DELLA CLASSE
	--------------------------------------------------------------------------
	SET @class +=	@regionPublic + 
					dbo.fnFillSqlTemplateWithFieldsListOrdered(@summary + @TAB2 + 'public $# $@' + @CR + @TAB2 + '{' + @CR + @TAB3 + 'get { return $^; }' + @CR + @TAB3 + 'set { $^ = ($#)value; }' + @CR + @TAB2 +' }' + @CR2, @TableName, 'cSharpPublicPropertyName') + @CR +
					@TAB2 + '// Proprietà pubbliche "speciali" che non sono collegate in nessun modo ai campi fisici della tabella' + @CR + 
					@summary + @TAB2 + 'public String ConnectionString__' + @CR + @TAB2 + '{' + @CR + @TAB3 + 'get { return _connectionString__; }' + @CR + @TAB3 + 'set { _connectionString__ = (String)value; }' + @CR + @TAB2 +' }' + @CR2 +
					@summary + @TAB2 + 'public String SpName__' + @CR + @TAB2 + '{' + @CR + @TAB3 + 'get { return _spName__; }' + @CR + @TAB3 + 'set { _spName__ = (String)value; }' + @CR + @TAB2 +' }' + @CR +
					@endregion -- classe c# (Proprietà pubbliche)

	--------------------------------------------------------------------------
	-- COSTRUTTORI
	--------------------------------------------------------------------------
	SET @class +=	@regionConstructors + 
					@summary +
					@TAB2 + 'public entita_dett()' + @CR + 
					@TAB2 + '{' + @CR + 
					@TAB3 + 'PropertyInfo[]' + @CR + 
					@TAB4 + '_properties = null;' + @CR2 + 

					@TAB3 + '_properties = typeof(entita_dett).GetProperties();' + @CR2 + 

					@TAB3 + 'foreach (PropertyInfo property in _properties)' + @CR + 
					@TAB3 + '{' + @CR + 
					@TAB4 + 'property.SetValue(this, null, null);' + @CR + 
					@TAB3 + '}' + @CR + 
					@TAB2 + '}' + @CR2 +
					@summary +
					@TAB2 + 'public entita_dett(Boolean pForceDefaultValue)' + @CR + 
					@TAB2 + '{' + @CR + 
					@TAB2 + 'if(pForceDefaultValue)' + @CR + 
					@TAB2 + '{' + @CR + 
					dbo.fnFillSqlTemplateWithFieldsListOrdered
					(
						@TAB3 + '$^ = ($#)NullOrValue("$@",true);' + @CR
						,@TableName,'cSharpPublicPropertyName'
					) +
					@TAB2 + '}' + @CR + 
					@TAB2 + '}' + @CR + 
					@endregion -- classe c# (Proprietà pubbliche)

	--------------------------------------------------------------------------
	-- METODI PUBBLICI
	--------------------------------------------------------------------------
	SET @class +=	@regionPublicMethods + 
					@TAB2 + '/// <summary>' + @CR +
					@TAB2 + '/// Funzione principale per le operazioni di SELECT, INSERT, UPDATE e DELETE sulla tabella fisica' + @CR +
					@TAB2 + '/// alla quale la presente classe fa riferimento' + @CR +
					@TAB2 + '/// </summary>' + @CR +
					@TAB2 + '/// <param name="pOperazione">Operazione da effettuare: S = SELECT, I = INSERT, U = UPDATE, D = DELETE</param>' + @CR +
					@TAB2 + '/// <param name="pUpdateWhereCondition">Stringa contenente il criterio da utilizzare *ESCLUSIVAMENTE* per l''operazione di UPDATE</param>' + @CR +
					@TAB2 + '/// <param name="pForceDefaultValue">Booleano che specifica se forzare/specificare (TRUE) i valori di default per le proprietà non valorizzate, oppure (FALSE) se ignorarli</param>' + @CR +
					@TAB2 + '/// <param name="pReturnValue">Int, il numero delle righe che sono state interessate dall''operazione (0 se nulla è cambiato sul DB)</param>' + @CR +
					@TAB2 + '/// <returns>DataTable, riempito *ESCLUSIVAMENTE* per l''operazione di SELECT, NULL altrimenti</returns>' + @CR +
					@TAB2 + 'public DataTable SelInsUpdDel(String pOperazione, String pUpdateWhereCondition, Boolean pForceDefaultValue, out int pReturnValue)' + @CR + 
					@TAB2 + '{' + @CR + 
					@TAB3 + 'DataTable retVal = new DataTable();' + @CR +
					@TAB3 + 'SqlConnection conn = new SqlConnection(); // commentare o rimpiazzare con eventuale oggetto connessione già presente' + @CR + 
					@TAB3 + 'SqlDataAdapter da = new SqlDataAdapter();' + @CR2 + 
					@TAB3 + 'String command = String.Empty;' + @CR +

					@TAB3 + 'command = (!String.IsNullOrEmpty(_spName__)) ? _spName__ : ' + @dynamicCRUDspName + ';' + @CR + 
					@TAB3 + 'conn.ConnectionString = (!String.IsNullOrEmpty(_connectionString__)) ? _connectionString__ : ' + @connectionString + @CR2 + 
					@TAB3 + 'SqlCommand cmd = new SqlCommand(command); // rimpiazzare eventualmente con altro nome di stored procedure di CRUD DINAMICA' + @CR + 
					@TAB3 + 'cmd.Connection = conn;' + @CR + 
					@TAB3 + 'cmd.CommandType = CommandType.StoredProcedure;' + @CR2 + 

					dbo.fnFillSqlTemplateWithFieldsListOrdered
					(
						@TAB3 + 'SqlParameter psql$@ = new SqlParameter("$V", $Q);' + @CR
						,@TableName,'cSharpPublicPropertyName'
					) + @CR +
					dbo.fnFillSqlTemplateWithFieldsListOrdered
					(
						@TAB4 + 'psql$@.Size = $S;' + @CR + 
						@TAB4 + 'psql$@.Precision = $P;' + @CR + 
						@TAB4 + 'psql$@.Scale = $C;' + @CR +
						@TAB4 + 'psql$@.Value = NullOrValue("$@", pForceDefaultValue);' + @CR
						,@TableName,'cSharpPublicPropertyName'
					) + @CR +
					dbo.fnFillSqlTemplateWithFieldsListOrdered
					(
						@TAB3 + 'cmd.Parameters.Add(psql$@);' + @CR
						,@TableName,'cSharpPublicPropertyName'
					) + @CR +
					@TAB3 + 'SqlParameter psqlOP = new SqlParameter("@OP", SqlDbType.Char);' + @CR + 
					@TAB3 + 'psqlOP.Size = 1;' + @CR + 
					@TAB3 + 'psqlOP.Precision = 0;' + @CR + 
					@TAB3 + 'psqlOP.Scale = 0;' + @CR + 
					@TAB3 + 'psqlOP.Value = pOperazione;' + @CR + 
					@TAB3 + 'cmd.Parameters.Add(psqlOP);' + @CR + 
					@TAB3 + 'SqlParameter psqlUpdateWhereCondition = new SqlParameter("@UpdateWhereCondition", SqlDbType.VarChar);' + @CR + 
					@TAB3 + 'psqlUpdateWhereCondition.Size = 8000;' + @CR + 
					@TAB3 + 'psqlUpdateWhereCondition.Precision = 0;' + @CR + 
					@TAB3 + 'psqlUpdateWhereCondition.Scale = 0;' + @CR + 
					@TAB3 + 'psqlUpdateWhereCondition.Value = pUpdateWhereCondition;' + @CR + 
					@TAB3 + 'cmd.Parameters.Add(psqlUpdateWhereCondition);' + @CR + 
					@TAB3 + 'SqlParameter psqlReturnValue = new SqlParameter("@ReturnValue", SqlDbType.Int);' + @CR + 
					@TAB3 + 'psqlReturnValue.Size = 10;' + @CR + 
					@TAB3 + 'psqlReturnValue.Precision = 0;' + @CR + 
					@TAB3 + 'psqlReturnValue.Scale = 0;' + @CR + 
					@TAB3 + 'psqlReturnValue.Direction = ParameterDirection.Output;' + @CR + 
					@TAB3 + 'cmd.Parameters.Add(psqlReturnValue);' + @CR2 +

					@TAB3 + '// Per debug' + @CR + 
					@TAB3 + '//foreach (SqlParameter par in cmd.Parameters)' + @CR + 
					@TAB3 + '//{' + @CR + 
					@TAB3 + '//    parValue = (par.Value == null) ? "null" : par.Value.ToString();' + @CR + 
					@TAB3 + '//    Console.WriteLine(String.Format("{0} = {1}", par.ParameterName, parValue));' + @CR + 
					@TAB3 + '//}' + @CR2 +

					@TAB3 + 'conn.Open();' + @CR2 + 

					@TAB3 + 'if(pOperazione.ToUpper() != "S")' + @CR +
					@TAB3 + '{' + @CR +
					@TAB4 + 'cmd.ExecuteNonQuery();' + @CR + 
					@TAB3 + '}' + @CR +
					@TAB3 + 'else' + @CR +
					@TAB3 + '{' + @CR +
					@TAB4 + 'retVal.Load(cmd.ExecuteReader());' + @CR +
					@TAB3 + '}' + @CR +
					@TAB3 + 'conn.Close();' + @CR2 + 

					@TAB3 + 'pReturnValue = (int)psqlReturnValue.Value;' + @CR2 + 

					@TAB3 + 'return retVal;' + @CR +
					@TAB2 + '}'

	--------------------------------------------------------------------------
	-- AGGIUNTA DELLE FUNZIONI (METODI) ACCESSORI 
	-- PRELEVATI DAL REPOSITORY DEI SORGENTI
	--------------------------------------------------------------------------
	SET @class +=	@functionsAccessories + @CR + 
					@endregion -- classe c# (Metodi pubblici)

	SET @class +=	@TAB + '}' + @CR + '}'


	RETURN @class
END