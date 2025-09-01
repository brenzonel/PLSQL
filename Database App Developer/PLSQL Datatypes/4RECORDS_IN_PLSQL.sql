--RECORD AND PSEUDORECORDS IN PLSQL

--Definir un registro con %ROWTYPE/ Declare a record with %ROWTYPE
--%ROWTYPE para de las tablas / %ROWTYPE is for tables
--%TYPE es para las columnas de las tablas / %TYPE is for the columns of the tables
DECLARE
    l_emp_name   pr_employees.emp_name%TYPE;
BEGIN
    SELECT emp_name INTO l_emp_name 
    FROM pr_employees where emp_id = 1;
    
    DBMS_OUTPUT.put_line ('Empleado: ' || l_emp_name);
END;
/

DECLARE
    l_employees pr_employees%ROWTYPE;
BEGIN
    SELECT * INTO l_employees
    FROM pr_employees WHERE emp_id = 1;
    DBMS_OUTPUT.put_line ('Nombre: '||l_employees.emp_name||' Email: '||l_employees.email || ' Salary: '||l_employees.salary);
END;
/

--Declarar un tipo de registro / Create your own record type
DECLARE
    TYPE emp_rec IS RECORD (
        name    VARCHAR2(50),
        email   VARCHAR2(50),
        salary  NUMBER
    );
    employee emp_rec;
BEGIN
    SELECT emp_name, email, salary
        INTO employee.name, employee.email, employee.salary
    FROM pr_employees WHERE emp_id = 1;
    DBMS_OUTPUT.put_line ('Nombre: '|| employee.name);
    DBMS_OUTPUT.put_line ('Email: '|| employee.email);
    DBMS_OUTPUT.put_line ('Salary: '|| employee.salary);
END;
/

--EXECUTE IMMEDIATE
DECLARE
    l_emp pr_employees%ROWTYPE;
BEGIN
    EXECUTE IMMEDIATE 'SELECT * FROM PR_EMPLOYEES WHERE emp_id = 1'
        INTO l_emp;
    DBMS_OUTPUT.put_line ('Nombre: '||l_emp.emp_name||'Salary: '|| l_emp.salary);
END;
/

--specification of the package
CREATE OR REPLACE PACKAGE pk_employee_increase AS

    PROCEDURE sp_emp_val_increase ( c_empid in pr_employees.emp_id%TYPE );

    PROCEDURE sp_emp_val_increase;

    FUNCTION fun_emp_update_salary ( c_empid IN pr_employees.emp_id%TYPE, c_level IN NUMBER) RETURN VARCHAR2;
    
END pk_employee_increase;
/

CREATE OR REPLACE PACKAGE BODY pk_employee_increase AS
    PROCEDURE sp_emp_val_increase ( c_empid in pr_employees.emp_id%TYPE ) IS   
        l_salary    pr_employees.salary%TYPE;
        l_hiredate  pr_employees.hire_date%TYPE;
        l_empname   pr_employees.emp_name%TYPE;
        l_level     NUMBER;
        l_request   VARCHAR(50);
    BEGIN
        SELECT emp_name, salary, hire_date INTO l_empname, l_salary, l_hiredate
        FROM pr_employees WHERE emp_id = c_empid and status like 'A';
        l_level := (round(l_hiredate - SYSDATE)*-1)/365;
        IF l_level >= 1 AND l_salary < 1000000 THEN
            DBMS_OUTPUT.put_line ('Employee: '|| l_empname || ' is a candidate for an increase. Level: '  || l_level);
            l_request := fun_emp_update_salary(c_empid, l_level);
            DBMS_OUTPUT.put_line (l_request);
        ELSE 
            DBMS_OUTPUT.put_line ('Employee: '|| l_empname || ' is not a candidate for an increase.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.put_line ('ERROR SPEMPID: '|| sqlerrm);     
    END sp_emp_val_increase;

    PROCEDURE sp_emp_val_increase IS
        CURSOR cur_emps IS
            SELECT emp_name, email, salary, hire_date, status
            FROM pr_employees;
        l_level     NUMBER;
    BEGIN
        FOR employee IN cur_emps LOOP
            l_level := (round(employee.hire_date - SYSDATE)*-1)/365;
            IF NOT (employee.status = 'A') THEN
                DBMS_OUTPUT.put_line ('The employee is inactive');
            ELSE
                IF l_level >= 1 AND employee.salary < 1000000 THEN
                    DBMS_OUTPUT.put_line ('Employee: '|| employee.emp_name ||' ' || employee.email || ' is a candidate for an increase. Level: '  || l_level);
                ELSE
                    DBMS_OUTPUT.put_line ('Employee: '|| employee.emp_name || ' is not a candidate for an increase.');
                END IF;
            END IF;
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.put_line ('ERROR SPGLOBAL: '|| sqlerrm);
    END sp_emp_val_increase; 

    FUNCTION fun_emp_update_salary ( c_empid IN pr_employees.emp_id%TYPE,  c_level IN NUMBER) RETURN VARCHAR2 IS
        l_level NUMBER;
    BEGIN
        l_level := round(c_level)*1.05;
        UPDATE pr_employees
        SET salary = salary * l_level
        WHERE emp_id = c_empid;
        COMMIT;

        RETURN 'Employee: ' || c_empid || ' has salary update';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.put_line ('ERROR FUNCTION: '|| sqlerrm);
    END fun_emp_update_salary;
END pk_employee_increase;
/

BEGIN
    SYSTEM.PK_EMPLOYEE_INCREASE.sp_emp_val_increase();
    SYSTEM.PK_EMPLOYEE_INCREASE.sp_emp_val_increase(1);
END;
/

--Otra manera
BEGIN
    FOR emp_rec IN 
        (SELECT emp_name, email FROM pr_employees) LOOP
            DBMS_OUTPUT.put_line ('Nombre: '|| emp_rec.emp_name||' Email: '||emp_rec.email);
    END LOOP;
END;
/
