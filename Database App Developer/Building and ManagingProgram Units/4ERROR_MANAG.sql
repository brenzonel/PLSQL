--Error Management
/*
3 Categorias: internally defined, predefined, and user defined
internally defined  - Tiene codigo de error, pero no nombre, a menos que PLSQL le ponga uno. Genera internamente un proceso en la bd.(ORA-00060 (bloqueo detectado al esperar un recurso)).
predefined          - Tiene codigo de error, tiene nombre, estan en un paquete STANDARD. (ORA-00001, a la que se le asigna el nombre DUP_VAL_ON_INDEX).
user defined        - Se declara y define por el usuario, se asocian a un error especifico en la aplicacion.
-------------------------------------------------------
3 Categories: internally defined, predefined, and user defined
internally defined  - It has an error code, but no name, unless PLSQL assigns one. It internally spawns a process in the database (ORA-00060 (block detected while waiting for a resource)).
predefined          - It has an error code, a name, and is in a STANDARD package. (ORA-00001, which is assigned the name DUP_VAL_ON_INDEX).
user defined        - Declared and defined by the user, they are associated with a specific error in the application.
*/
--Generacion de excepciones / Raising exceptions
--Declaracion Raise / RAISE STATEMENT
CREATE OR REPLACE PROCEDURE emp_hiredate (emp_date IN INTEGER) IS
BEGIN
    IF emp_date IS NULL THEN
        RAISE VALUE_ERROR;
    END IF;
END emp_hiredate;
/
DECLARE
    v_num INTEGER;
BEGIN
    SELECT
        dep_parent_id
    INTO v_num
    FROM
        pr_departments
    WHERE
        dep_id = 1;

    emp_hiredate(v_num);
END;
/

-- RAISE APP ERROR (value must be between -20,999 and -20,000 and message)
CREATE OR REPLACE PROCEDURE val_emp (v_date IN DATE) IS
    v_fiveyears date := (sysdate - (365*5));
BEGIN
    IF ((v_fiveyears - v_date) / 365) <= 0  THEN --'SYSDATE - 5 YEARS'
        RAISE_APPLICATION_ERROR(-20501,
                                'The employee must have at least 5 years to have this benefit.');
    END IF;
END val_emp;
/
DECLARE
    v_date date;
BEGIN
    SELECT hire_date INTO v_date
    FROM PR_EMPLOYEES
    --WHERE emp_id = 29; --hire_date 09-MAY-24
    WHERE emp_id = 61; --hire_date 30-NOV-19
    
    val_emp(v_date);
END;
/

--Definir excepciones propias / Define own exceptions -> name EXCEPTION;
CREATE OR REPLACE PROCEDURE proc_salary (salary IN NUMBER) IS
    e_salary_low EXCEPTION;
    PRAGMA EXCEPTION_INIT ( e_salary_low, -20900);
BEGIN
    IF salary <= 2500 THEN
        RAISE_APPLICATION_ERROR (-20900, 'Salary to low');
    END IF;
END proc_salary;
/
DECLARE
    v_salary NUMBER;
BEGIN
    SELECT salary INTO v_salary
    FROM pr_employees
    WHERE emp_id = 24;
    proc_salary(v_salary);
END;
/
--Captura de errores / recording error
CREATE TABLE error_log (
    ERROR_CODE      INTEGER,
    error_msg       VARCHAR2(4000),
    backtrace       CLOB,
    callstack       CLOB,
    created_on      DATE,
    created_by      VARCHAR2(30)
    );
/
--se puede usar en las exceptiones / It can be used in exceptions
/*
EXCEPTION
   WHEN OTHERS
   THEN
      DECLARE
         l_code   INTEGER := SQLCODE;
      BEGIN
         INSERT INTO error_log
              VALUES (l_code
                    ,  sys.DBMS_UTILITY.format_error_stack
                    ,  sys.DBMS_UTILITY.format_error_backtrace
                    ,  sys.DBMS_UTILITY.format_call_stack
                    ,  SYSDATE
                    ,  USER);
         RAISE;
      END;
**Pero es demasiado codigo, y si se cambia la tabla error_log, se debera cambiar cada objeto que tiene este codigo
--------------------------------------------------------
**But it is too much code, and if the error_log table is changed, each object that this code has to be changed must be changed
*/
--Se usara un procedimiento almacenado / A stored procedure will be used
CREATE OR REPLACE PROCEDURE record_error IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_code  PLS_INTEGER := SQLCODE;
    l_mssg  VARCHAR2(32767) := SQLERRM;
BEGIN
    INSERT INTO error_log (error_code,
                            error_msg,
                            backtrace,
                            callstack,
                            created_on,
                            created_by)
                VALUES (l_code,
                        l_mssg,
                        sys.DBMS_UTILITY.format_error_backtrace,
                        sys.DBMS_UTILITY.format_call_stack,
                        SYSDATE,
                        USER);
    COMMIT;

END record_error;
/
--Ahora lo podemos usar en la seccion de excepciones / Now we can use it in the exception section
/*
EXCEPTION
   WHEN OTHERS
   THEN
      record_error();
      RAISE;
*/
DECLARE
    f2 UTL_FILE.file_type; --se declara la variable f2 como tipo fila
    v1 VARCHAR(256);
BEGIN
    f2 := UTL_FILE.fopen('DIR_DENTI', 'factura_ventas.txt', 'r');
    UTL_FILE.get_line(f2, v1);
    dbms_output.put_line(v1);
EXCEPTION
   WHEN OTHERS THEN
      record_error();
      RAISE;
END;
/
--Exceptions and rollbacks
BEGIN
    DELETE FROM pr_employees
        WHERE job_id = 3;
    UPDATE pr_employees
        SET salary = salary * 20;
EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
        record_error();
        DECLARE
            l_count integer;
        BEGIN
            SELECT COUNT(1) INTO l_count
                FROM pr_employees
                WHERE job_id = 3;
            DBMS_OUTPUT.put_line (l_count);
            RAISE;
        END;
END;
/*
The DELETE is completed successfully, but then Oracle Database raises the ORA-01438 error when trying to execute the UPDATE statement. 
I catch the error and display the number of rows in the Employees table WHERE job_id = 3. 
“0” is displayed, because the failure of the UPDATE statement did not cause a rollback in the session.
After I display the count, however, I reraise the same exception. 
Because there is no enclosing block and this outermost block terminates with an unhandled exception, any changes made in this block are rolled back by the database.
So after this block is run, the employees in JOB 3 will still be in the table.
*/