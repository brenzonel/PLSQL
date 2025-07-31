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
