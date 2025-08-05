--PL/SQL data dictionary
--The USER view: Database objects owned by the schema to which you are connected.
SELECT * FROM user_objects;
--The ALL view: Database objects to which the currently connected schema has access.
SELECT * FROM all_objects;
--The DBA view: non-DBA schemas usually have no authority to query DBA views.
SELECT * FROM dba_objects;
/

--Mostrar informacion sobre objetos / Display information about stored objects

--OBJECT_NAME: Nombre del objeto / Name of the object
SELECT object_name
  FROM user_objects
 WHERE object_type = 'TABLE'
 ORDER BY object_name;
--OBJECT_TYPE: Tipo del objeto / Type of the object, such as PACKAGE, FUNCTION, or TRIGGER
SELECT object_type, object_name
  FROM user_objects
 WHERE 1=1
 --AND status = 'INVALID'
 ORDER BY object_type, object_name;
--STATUS: Estatus del objeto VALID or INVALID / Status of the object—VALID or INVALID
--LAST_DDL_TIME: Indica el tiempo de la ultima actualizacion del objeto / Time stamp indicating the last time this object was changed
SELECT object_type, object_name, 
       last_ddl_time
  FROM user_objects
 WHERE last_ddl_time <= TRUNC (SYSDATE)
 ORDER BY object_type, object_name;
/

-----------------------------

--Mostrar y buscar fuente de codigo / Display and search source code
--NAME: Nombre del objeto / Name of the object
--TYPE: Tipo del objeto / Type of the object (ranging from PL/SQL program units to Java source and trigger source)
--LINE: Numero de la linea del codigo completo / Number of the line of the source code
--TEXT: Texto o cadena del codigo / Text of the source code
SELECT name, line, text
  FROM user_source
 WHERE UPPER (text) 
  LIKE '%ERROR_LOG%'
 ORDER BY name, line;
 /*
 NAME           LINE    TEXT
 RECORD_ERROR	6	"    INSERT INTO error_log (error_code,"
*/
--Busqueda del objeto y todo su codigo, en base al resultado del query anterior / Search for the object and all its code, based on the result of the previous query
SELECT name, line, text
  FROM user_source
 WHERE UPPER (name) 
  LIKE 'RECORD_ERROR'
 ORDER BY name, line;
 /
 
--Configuración del compilador del código almacenado / Compiler settings of stored code
/*
PLSQL_OPTIMIZE_LEVEL: Optimization level that was used to compile the object
PLSQL_CODE_TYPE: Compilation mode for the object
PLSQL_DEBUG: Whether or not the object was compiled for debugging
PLSQL_WARNINGS: Compiler warning settings that were used to compile the object
NLS_LENGTH_SEMANTICS: NLS length semantics that were used to compile the object
An optimization level of 0 means no optimization at all. An optimization level of 1 means a minimal amount of optimization. Neither of these levels should be seen in a production environment.
*/
SELECT *
  FROM user_plsql_object_settings
 WHERE 1=1;
 --AND plsql_optimize_level < 2;
--
SELECT name, plsql_warnings
  FROM user_plsql_object_settings
 WHERE plsql_warnings LIKE '%DISABLE%';
 /

--Detalle de procedimiento y funciones / Detailed information about procedures and functions
/*
AUTHID: Shows whether a procedure or a function is defined as an invoker rights (CURRENT_USER) or definer rights (DEFINER) program unit
DETERMINISTIC: Set to YES if the function is defined to be deterministic, which theoretically means that the value returned by the function is determined completely by the function’s argument values
PIPELINED: Set to YES if the function is defined as a pipelined function, which means that it can be executed in parallel as part of a parallel query
OVERLOAD: Set to a positive number if this subprogram is overloaded, which means that there are at least two subprograms with this name in the same package
*/
SELECT   object_name
       , procedure_name 
       , overload
       , object_type
       , authid
       , deterministic
       , parallel
    FROM user_procedures
   WHERE 1=1 --authid = 'CURRENT_USER'
ORDER BY object_name, procedure_name;
/

--Analizar y modificar triggers / Analyze and modify the trigger state
/*
TRIGGER_NAME: The name of the trigger
TRIGGER_TYPE: A string that shows if this is a BEFORE or AFTER trigger and whether it is a row- or statement-level trigger (in a trigger that is fired before an INSERT statement, for example, the value of this column is BEFORE STATEMENT)
TRIGGERING_EVENT: The type of SQL operation—such as INSERT, INSERT OR UPDATE, DELETE OR UPDATE—that will cause the trigger to fire
TABLE_NAME: The name of the table on which the trigger is defined
STATUS: The status of the trigger—ENABLED or DISABLED
WHEN_CLAUSE: An optional clause you can use to avoid unnecessary execution of the trigger body
TRIGGER_BODY: The code executed when the trigger fires
/
CREATE OR REPLACE TRIGGER status_emp
AFTER INSERT ON pr_employees
FOR EACH ROW
BEGIN
    UPDATE pr_employees
    SET status = 'A'
    WHERE emp_id = :NEW.emp_id;
END status_emp;
/
*/
--Encontrar todos los triggers deshabilitados / Find all disabled triggers:
SELECT *
  FROM user_triggers 
 WHERE status = 'DISABLED';
 
--Encuentre todos los activadores de nivel de fila definidos en la tabla PR_EMPLOYEES: / Find all row-level triggers defined on the PR_EMPLOYEES table:
 SELECT *
  FROM user_triggers 
 WHERE table_name = 'PR_EMPLOYEES'
   AND trigger_type LIKE '%EACH ROW';
   
--Encontrar triggers con alguna operacion / Find all triggers that fire when an UPDATE operation is performed
SELECT *
  FROM user_triggers 
 WHERE triggering_event LIKE '%UPDATE%';
 /
--Encontrar el contenido del cuerpo de un trigger con una cohincidencia / search the contents of trigger bodies
BEGIN
  FOR rec IN (SELECT * 
              FROM user_triggers)
  LOOP
    IF rec.trigger_body LIKE '%emp%'
    THEN
      DBMS_OUTPUT.put_line (
        'Trigger Name: ' || rec.trigger_name);
    END IF;
  END LOOP;
END;
/

--Dependencia de objetos / Object dependency analysis
/*
NAME: Name of the object
TYPE: Type of the object
REFERENCED_OWNER: Owner of the referenced object
REFERENCED_NAME: Name of the referenced object
REFERENCED_TYPE: Type of the referenced object
*/
--Encontrar objetos que dependen de otro / Find all the objects that depend on (reference)
SELECT type, name, referenced_owner, referenced_name, referenced_type
   FROM user_dependencies
  WHERE  1=1
  AND referenced_name = 'PR_EMPLOYEES'
  --AND name NOT LIKE '%\_API' ESCAPE '\'
ORDER BY type, name;
/

--Analizar argumentos / Analyze argument information
/*
OBJECT_NAME: The name of the procedure or function
PACKAGE_NAME: The name of the package in which the procedure or function is defined
ARGUMENT_NAME: The name of the argument
POSITION: The position of the argument in the parameter list (if 0, this is the RETURN clause of a function)
IN_OUT: The mode of the argument—IN, OUT, or IN OUT
DATA_TYPE: The data type of the argument
DATA_LEVEL: The nesting depth of the argument for composite types (for example, if one of your arguments’ data types is a record, USER_ARGUMENTS will have a row for this argument with a DATA_LEVEL of 0 and then a row for each field in the record with a DATA_LEVEL of 1)
*/
SELECT object_name
     , package_name
     , argument_name
     , position
     , in_out
     , data_type
     , pls_type
     , data_level
  FROM user_arguments
 WHERE data_type = 'NUMBER';
 /
 
 --
/*
PL/Scope es una herramienta invocada por el compilador de PL/SQL para recopilar información sobre todos los identificadores (variables, procedimientos, funciones, tipos, etc.) de su unidad de programa PL/SQL y ponerla a disposición a través de la vista USER_IDENTIFIERS. Esta herramienta facilita la obtención de respuestas a preguntas que, de otro modo, requerirían analizar una unidad de programa PL/SQL y, posteriormente, el árbol de análisis.

Por ejemplo: Mi jefe me ha pedido que elimine de nuestros programas cualquier variable, constante, excepción, etc., que se declare pero nunca se utilice. Encontrar todos los candidatos para su eliminación simplemente buscando en el código sería una tarea laboriosa y propensa a errores.
--------------------------------------------------
PL/Scope is a tool invoked by the PL/SQL compiler to collect information about all the identifiers (variables, procedures, functions, types, and so on) in your PL/SQL program unit and make it available through the USER_IDENTIFIERS view. This tool makes it relatively easy to get answers to questions that would otherwise require you to parse a PL/SQL program unit and then analyze the parse tree.

Here’s one example: My manager has asked me to remove from our programs any variables, constants, exceptions, and the like that are declared but never used. Finding all candidates for removal by simply searching code would be both time-consuming and error-prone.
*/
 WITH subprograms_with_exception
        AS (SELECT DISTINCT owner
                          , object_name
                          , object_type
                          , name
              FROM all_identifiers has_exc
             WHERE     has_exc.owner = USER
                   AND has_exc.usage = 'DECLARATION'
                   AND has_exc.TYPE = 'EXCEPTION'),
     subprograms_with_raise_handle
        AS (SELECT DISTINCT owner
                          , object_name
                          , object_type
                          , name
              FROM all_identifiers with_rh
             WHERE     with_rh.owner = USER
                   AND with_rh.usage = 'REFERENCE'
                   AND with_rh.TYPE = 'EXCEPTION')
SELECT *
  FROM subprograms_with_exception
MINUS
SELECT *
FROM subprograms_with_raise_handle;