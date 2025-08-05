--PLSQL en paquetes / PLSQL in a package
/*Pr_employees
Name      Null?    Type         
--------- -------- ------------ 
EMP_ID    NOT NULL NUMBER       
EMP_NAME           VARCHAR2(50) 
EMAIL              VARCHAR2(50) 
*/
--Package
CREATE OR REPLACE PACKAGE employee_pkg AS
    SUBTYPE g_fullname IS VARCHAR (100);

    FUNCTION name_email (
                name_id pr_employees.emp_id%TYPE,
                name_n pr_employees.emp_name%TYPE)
                RETURN g_fullname;
    FUNCTION name_email (
                employee_id IN pr_employees.emp_id%TYPE)
                RETURN g_fullname;
END employee_pkg;
/
--BODY
CREATE OR REPLACE PACKAGE BODY employee_pkg AS

    FUNCTION name_email (
                name_id pr_employees.emp_id%TYPE,
                name_n pr_employees.emp_name%TYPE)
                RETURN g_fullname IS
        BEGIN
            RETURN name_id || ' - ' || name_n;
    END;

    FUNCTION name_email (
                employee_id IN pr_employees.emp_id%TYPE)
                RETURN g_fullname IS
        l_name_email g_fullname;
        BEGIN
            SELECT name_email (emp_id, emp_name) 
                INTO l_name_email
                FROM pr_employees
                WHERE emp_id = employee_id;
        RETURN l_name_email;
    END;

END employee_pkg;
/
--Uso del paquete employee_pkg / use package employee_pkg
CREATE OR REPLACE PROCEDURE emp_display ( emp_id_in IN pr_employees.emp_id%TYPE) IS
    l_name employee_pkg.g_fullname;
BEGIN
    l_name := employee_pkg.name_email(emp_id_in);
    DBMS_OUTPUT.put_line(l_name);
END;
/
BEGIN 
    emp_display(31);
END;
/