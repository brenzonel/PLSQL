--Controlando el flujo de ejecucion / Controlling the flow of execution
/*Condicionales en el codigo / Conditional branching in code*/
--IF-THEN
DECLARE 
    l_sal pr_employees.salary%TYPE;
BEGIN
    SELECT salary
        INTO l_sal
        FROM pr_employees
        WHERE emp_id = 31;
    IF l_sal > 2000 
    THEN
        DBMS_OUTPUT.put_line ('Salary: '||l_sal);
    END IF;
END;
/
--IF-THEN-ELSE
DECLARE 
    l_sal pr_employees.salary%TYPE;
BEGIN
    SELECT salary
        INTO l_sal
        FROM pr_employees
        WHERE emp_id = 31;
        --WHERE emp_id = 61;
    IF l_sal > 2000 
    THEN
        DBMS_OUTPUT.put_line ('Salary is more than 2000');
    ELSE
        DBMS_OUTPUT.put_line ('Salary is less than 2000');
    END IF;
END;
/
--IF-ELIF
DECLARE 
    l_sal pr_employees.salary%TYPE;
BEGIN
    SELECT salary
        INTO l_sal
        FROM pr_employees
        WHERE emp_id = 61;
        --WHERE emp_id = 24;
    IF l_sal BETWEEN 1000 AND 2000
    THEN
        DBMS_OUTPUT.put_line ('Salary is BETWENN 1000 AND 2000');
    ELSIF l_sal > 2000 THEN
        DBMS_OUTPUT.put_line ('Salary is more than 2000');
    ELSE
        DBMS_OUTPUT.put_line ('Salary is less than 1000');
    END IF;
END;
/
--Case simple / simple case
DECLARE 
    l_jobid pr_employees.JOB_ID%TYPE;
BEGIN
    SELECT job_id
        INTO l_jobid
        FROM pr_employees
        WHERE emp_id = 61;
        --WHERE emp_id = 24;
    CASE l_jobid
     WHEN 1 THEN
        DBMS_OUTPUT.put_line ('The job is VENTAS');
     WHEN 2 THEN 
        DBMS_OUTPUT.put_line ('The job is INGENIERO DE SOFTWARE');
    ELSE
        DBMS_OUTPUT.put_line ('The job is not valid');
    END CASE;
END;
/
--Case busqueda / Searched CASE statements
DECLARE 
    l_sal pr_employees.salary%TYPE;
BEGIN
    SELECT salary
        INTO l_sal
        FROM pr_employees
        WHERE emp_id = 61;
        --WHERE emp_id = 24;
    CASE 
    WHEN l_sal BETWEEN 1000 AND 2000 THEN
        DBMS_OUTPUT.put_line ('Salary is BETWENN 1000 AND 2000');
     WHEN l_sal > 2000 THEN 
        DBMS_OUTPUT.put_line ('Salary is more than 2000');
    ELSE
        DBMS_OUTPUT.put_line ('Salary is less than 1000');
    END CASE;
END;
/

/******************************************/

/*Iteraciones con ciclos / Iterative processing with loops*/
--Ciclo For / For Loop
CREATE OR REPLACE PROCEDURE num_for (start_n IN NUMBER, end_n IN NUMBER) IS
BEGIN
    FOR l_current_n IN start_n .. end_n
    LOOP
        DBMS_OUTPUT.put_line('Number in for: '||l_current_n);
    END LOOP;
END num_for;
/
BEGIN
    num_for (10, 15);
END;
/
--Otra manera / other way
CREATE OR REPLACE PROCEDURE id_emp_for (start_n IN PLS_INTEGER, end_n IN PLS_INTEGER) IS
BEGIN
    FOR l_current_n IN (
            SELECT emp_id FROM pr_employees
            WHERE emp_id BETWEEN start_n AND end_n)
    LOOP
        DBMS_OUTPUT.put_line(l_current_n.emp_id);
    END LOOP;
END id_emp_for;
/
BEGIN
    id_emp_for (1, 5);
END;
/
--Loop simple / The simple Loop
CREATE OR REPLACE PROCEDURE num_loop (start_n IN NUMBER, end_n IN NUMBER) IS
    l_current_n NUMBER := start_n;
BEGIN
    LOOP
        EXIT WHEN l_current_n > end_n;
        DBMS_OUTPUT.put_line('Number in loop: '||l_current_n);
        l_current_n := l_current_n + 1;
    END LOOP;
END num_loop;
/
BEGIN
    num_loop (10, 15);
END;
/
--Otra manera / other way
CREATE OR REPLACE PROCEDURE id_emp_loop (start_n IN PLS_INTEGER, end_n IN PLS_INTEGER) IS
    CURSOR id_emp IS
        SELECT * FROM pr_employees
            WHERE emp_id BETWEEN start_n AND end_n;
    l_idemp pr_employees%ROWTYPE;
BEGIN
    OPEN id_emp;
    
    LOOP
        FETCH id_emp INTO l_idemp;
        
        EXIT WHEN id_emp%NOTFOUND;
        
        DBMS_OUTPUT.put_line('Emp: '||l_idemp.emp_id);
    END LOOP;
    CLOSE id_emp;
END id_emp_loop; 
/
BEGIN
    id_emp_loop (1, 5);
END;
/
--While Loop
CREATE OR REPLACE PROCEDURE num_while (start_n IN NUMBER, end_n IN NUMBER) IS
    l_current_n NUMBER := start_n;
BEGIN
    WHILE (l_current_n <= end_n)
    LOOP
        DBMS_OUTPUT.put_line('Number in while: '||l_current_n);
        l_current_n := l_current_n + 1;
    END LOOP;
END num_while;
/
BEGIN
    num_while (10, 15);
END;
/