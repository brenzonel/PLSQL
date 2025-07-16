--Bloques Aninados / Nest block
DECLARE
    l_msg   VARCHAR2 (100) := 'Hello';
BEGIN
    DECLARE
        l_msg2  VARCHAR2 (100) := l_msg || ' World';
    BEGIN
        DBMS_OUTPUT.put_line (l_msg2);
    END;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_stack);
END;    
/

/******************************************/

--Bloques con nombre (procedimiento almacenado) / Nest Block with name (store Procedure)
CREATE OR REPLACE PROCEDURE hello_world is
    l_msg VARCHAR2 (100) := 'Hello World';
BEGIN
    DBMS_OUTPUT.put_line (l_msg);
END;
/
--Llamada a procedimiento hello_world / call store procedure hello_world
BEGIN
   hello_world;
END;
/

/******************************************/

--Procedimiento almacenado con parametro / Store procedure with single parameter
CREATE OR REPLACE PROCEDURE hello_place (place_in IN VARCHAR2) is
    l_msg VARCHAR2 (100) ;
BEGIN
    l_msg := 'Hello ' || place_in;
    DBMS_OUTPUT.put_line (l_msg);
END;
/
--Llamada a procedimiento hello_world / call store procedure hello_world
BEGIN
   hello_place ('Wold');
   hello_place ('Universe');
   hello_place ('Home');
END;
/

/******************************************/

--Bloque de funcion con parametro / Block of function with parameter
CREATE OR REPLACE FUNCTION hello_msg (place_in VARCHAR2) RETURN VARCHAR2 IS
BEGIN
    RETURN 'Hello ' || place_in;
END hello_msg;
/
--Llamar a la funcion en un bloque / call the function in block
DECLARE
    l_msg VARCHAR2 (100);
BEGIN
    l_msg := hello_msg('Home');
    DBMS_OUTPUT.put_line (l_msg);
END;
/
--Llamar la funcion en un procedimiento almacenado / call the function in store procedure
CREATE OR REPLACE PROCEDURE hello_place_all (place_in VARCHAR2) IS
BEGIN
    DBMS_OUTPUT.put_line (hello_msg(place_in));
END hello_place_all;
/
--Llamar al procedimiento que llama a la funcion y mostrar el mensaje / call the store procedure thats call the function and display the message
BEGIN
    hello_place_all ('Home');
    HELLO_PLACE_ALL ('HOME MAYUS');
    HELLO_place_ALL ('HOME MAYUS and Minus');
    "HELLO_PLACE_ALL" ('Home double quotation');
    --"hello_place_all" ('home') --error
END;
/
/*
En la BD de Oracle el nombre de este objeto (procedimiento) se guarda como HELLO_PLACE_ALL
por lo tanto al llamar al procedimiento se busca como HELLO_PLACE_ALL, sin importa si se escribe con mayusculas o minusculas
/
In the Oracle DB the name of this object (store procedure) is saved as HELLO_PLACE_ALL
therefore when calling the store procedure its searched for as HELLO_PLACE_ALL, regardless of whether it is written in upper or lower case
*/
/*
El usar dobles comillas ("Nombre") en BD Oracle se guardara con el nombre como esta escrito entre esas comillas dobles
si se quiere llamar un objeto con ese "Nombre" se debera usar las dobles comillas
/
Using double quotes ("Name") in Oracle DB is saved with the name as it is written between those double quotes
if you want to call an object with that "Name" you should use the double quotes
*/
--Procedimiento con nombre en dobles comillas / Procedure with name in double quotes
CREATE OR REPLACE PROCEDURE "hello_place_all" (place_in VARCHAR2) IS
BEGIN
    DBMS_OUTPUT.put_line (hello_msg(place_in || ' with doble quotes'));
END "hello_place_all";
/
BEGIN
    hello_place_all ('Home');
    "HELLO_PLACE_ALL" ('Home MAYUS and double quotation');
    "hello_place_all" ('Home');
END;
/

/******************************************/

--SQL en bloques de PLSQL / SQL inside PLSQL Blocks
--DML Select con tabla pr_employees / DML Select with table pr_employees
DECLARE 
    l_name pr_employees.emp_name%TYPE;
BEGIN
    SELECT emp_name
        INTO l_name
        FROM pr_employees
        WHERE emp_id = 31;
    
    DBMS_OUTPUT.put_line (l_name);
END;
/
--DML Delete con tabla pr_employees / DML Delete with table pr_employees
DECLARE 
    l_empid pr_employees.emp_id%TYPE := 41;
BEGIN
    DELETE FROM pr_employees
        WHERE emp_id = l_empid;
    DBMS_OUTPUT.put_line (SQL%ROWCOUNT);
    COMMIT;
END;
/
--DML Update con tabal pr_employees (valor*1.2) / DML Update with table pr_employees (value*1.2)
DECLARE 
    l_jobid pr_employees.job_id%TYPE := 1;
BEGIN
    UPDATE pr_employees
        SET salary = salary * 1.2
        WHERE job_id = l_jobid;
    DBMS_OUTPUT.put_line (SQL%ROWCOUNT);
    COMMIT;
END;
/
--DML Insert con tabla pr_employees / DML Insert into pr_employees
BEGIN
    INSERT INTO pr_employees (EMP_NAME
                            , EMAIL
                            , JOB_ID   
                            , SALARY 
                            , HIRE_DATE)
        VALUES('PLSQL Block'
            , 'plsql@gmail.com'
            , 1
            , 1200
            , SYSDATE);
    DBMS_OUTPUT.put_line (SQL%ROWCOUNT);
    COMMIT;
END;
/
/******************************************/

--Controlando bloques (condicionales) / controlling blocks (conditionals)
DECLARE
    l_msg   VARCHAR2 (100) := 'Hello';
    l_msg2  VARCHAR2 (100) := ' World';
BEGIN
    IF SYSDATE >= TO_DATE ('01-JUL-2025')
    --IF SYSDATE >= TO_DATE ('01-AUG-2025')
    THEN
        l_msg2 := l_msg || l_msg2;
        DBMS_OUTPUT.put_line (l_msg2);
    ELSE
        DBMS_OUTPUT.put_line (l_msg);
    END IF;
END;
/

/******************************************/

--Reestructura con bloques (lmsg2 se asignará solo después de 2020) 
DECLARE
    l_msg   VARCHAR2 (100) := 'Hello';
BEGIN
    IF SYSDATE >= TO_DATE ('01-JUL-2025')
    --IF SYSDATE >= TO_DATE ('01-AUG-2025')
    THEN
        DECLARE
            l_msg2   VARCHAR2 (100) := ' World';
        BEGIN
            l_msg2 := l_msg || l_msg2;
            DBMS_OUTPUT.put_line (l_msg2);
        END;
    ELSE
        DBMS_OUTPUT.put_line (l_msg);
    END IF;
END;
/
/******************************************/
--Reestructura con bloques y captura de errores 
--(lmsg2 se asignará solo después de 2020) 
DECLARE
    l_msg   VARCHAR2 (100) := 'Hello';
BEGIN
    DECLARE
        l_msg2   VARCHAR2 (5);
    BEGIN
        l_msg2 := ' World!';
        DBMS_OUTPUT.put_line (l_msg2);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_stack);
    END;
    
    DBMS_OUTPUT.put_line (l_msg);
    
END;