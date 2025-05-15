SELECT JOB_NAME, CURSOR(SELECT SALARY, EMP_NAME 
   FROM PR_EMPLOYEES e
   WHERE e.JOB_ID = d.JOB_ID) p
   FROM PR_JOBS d
   ORDER BY JOB_NAME;
/
CREATE OR REPLACE FUNCTION find_bef_date (cur SYS_REFCURSOR, date_tobval date)
    RETURN NUMBER IS
    /*FUNCION PARA VALIDAR FECHAS DE UN CURSOR (cur) ANTES DE LA FECHA A VALIDAR (date_tobval) MANDADA EN EL PARAMETRO*/
    date_obtained   date;
    before_n        number := 0;
    after_n         number := 0;
BEGIN
    LOOP
        FETCH cur INTO date_obtained;
        EXIT WHEN cur%NOTFOUND;
            IF date_obtained > date_tobval then
                after_n := after_n + 1;
            ELSE
                before_n := before_n + 1;
            END IF;
    END LOOP;
    CLOSE cur;
    
    IF before_n > after_n THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END;
/
--ENCONTRAR EMPLEADOS QUE CONTRATARON ANTES DE UNA FECHA DE ALGUN GERENTE O DEPARTAMENTO
SELECT E1.EMP_NAME, E1.EMAIL 
FROM PR_EMPLOYEES E1
WHERE 1=1
AND find_bef_date(CURSOR (SELECT E2.HIRE_DATE FROM PR_EMPLOYEES E2 WHERE E1.EMP_ID = E2.EMP_ID AND E1.JOB_ID = 2), E1.HIRE_DATE) = 1
;