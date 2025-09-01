/*DATE AND TIME STAMP IN PLSQL*/
--Declaring DATE, TIMESTAMP, and INTERVAL variables
DECLARE
   l_today_date        DATE := SYSDATE;
   l_today_timestamp   TIMESTAMP := SYSTIMESTAMP;
   l_today_timetzone   TIMESTAMP WITH TIME ZONE := SYSTIMESTAMP;
   l_interval1         INTERVAL YEAR (4) TO MONTH := '2011-11';
   l_interval2         INTERVAL DAY (2) TO SECOND := '15 00:30:44';
BEGIN
   DBMS_OUTPUT.put_line (l_today_date);
   DBMS_OUTPUT.put_line (l_today_timestamp);
   DBMS_OUTPUT.put_line (l_today_timetzone);
   DBMS_OUTPUT.put_line (l_interval1);
   DBMS_OUTPUT.put_line (l_interval2);
END;
/

--Calls to SYSDATE and SYSTIMESTAMP and the returned values
BEGIN
  DBMS_OUTPUT.put_line (SYSDATE);
  DBMS_OUTPUT.put_line (SYSTIMESTAMP);
  DBMS_OUTPUT.put_line (SYSDATE - SYSTIMESTAMP);
END;
/

--FORMAT DATE
BEGIN
    DBMS_OUTPUT.put_line(TO_CHAR(SYSDATE, 'Day, DDth Month YYYY'));
    DBMS_OUTPUT.put_line(TO_CHAR(SYSDATE, 'Day, DDth Month YYYY', 'NLS_DATE_LANGUAGE=Spanish'));
    DBMS_OUTPUT.put_line(TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
    ----
    DBMS_OUTPUT.put_line(EXTRACT(YEAR FROM SYSDATE));
    DBMS_OUTPUT.put_line(EXTRACT(DAY FROM SYSDATE));
    --
END;

--TRUNC DATE
BEGIN
    DBMS_OUTPUT.put_line(TRUNC (SYSDATE));
    DBMS_OUTPUT.put_line(TRUNC (SYSDATE, 'MM'));    --PRIMER DIA DEL MES / FIRST DAT OF THEW MONTH
    DBMS_OUTPUT.put_line(TRUNC (SYSDATE, 'Q'));     --PRIMER DIA DEL CUARTO DEL AÑO / FIRST DAY OF THE QUARTER
    DBMS_OUTPUT.put_line(TRUNC (SYSDATE, 'Y'));     --PRIMER DIA DEL AÑO / FIRST DAY OF THE YEAR
END;
/
--DATE ARITHMETIC
DECLARE
    l_date      DATE        := SYSDATE;
    l_date2     DATE        := SYSDATE + 11;
    l_datestamp TIMESTAMP   := SYSTIMESTAMP;
BEGIN
    --DIA DE MAÑANA / TOMORROW DAY
    DBMS_OUTPUT.put_line (l_date+1);
    --1 hora antes / move back 1 hour
    DBMS_OUTPUT.put_line(l_datestamp);
    DBMS_OUTPUT.put_line(TO_CHAR(l_datestamp-1/24,'DD-MM-YYYY HH:MI:SS AM'));
    --MOVER 10 SEGUNDOS / MOVE AHEAD 10 SECONDS
    DBMS_OUTPUT.put_line(l_datestamp);
    DBMS_OUTPUT.put_line(TO_CHAR(l_datestamp+10 /(60 * 60 *24),'DD-MM-YYYY HH:MI:SS AM'));
    --DIAS ENTRE DOS FECHAS / DAYS BETWEEN THE TOW DATE
    DBMS_OUTPUT.put_line(l_date - l_date2);
    DBMS_OUTPUT.put_line(l_date2 - l_date);
    
END;
/

--CONSEGUIR LA EDAD DE ALGUIEN / GET THE AGE OF ANYONE
CREATE OR REPLACE FUNCTION you_age (birthdate in DATE) RETURN NUMBER IS
    l_age   NUMBER;
BEGIN
    l_age := (SYSDATE-birthdate)/365;
    RETURN ROUND(l_age);
END;
/
DECLARE
    l_age NUMBER;
BEGIN
    l_age := you_age('18-MAY-1996');
    DBMS_OUTPUT.put_line('Años|Years Old: '||l_age);
END;
/

--ADD_MONTHS, NEXT_DAY, LAST_DAY
BEGIN
    --AGREGAR 1 MES / ADD 1 MONTH
    DBMS_OUTPUT.put_line(ADD_MONTHS(SYSDATE, 1));
    --RETROCEDER 1 MES / MOVE BACK 1 MONTH
    DBMS_OUTPUT.put_line(ADD_MONTHS(TO_DATE('27-FEB-2025', 'DD-MON-YYYY'), -1));
    --SIGUIENTE DIA SELECCIONANDO UNO EN ESPECIFICO / NEXT DAY SELECTING A SPECIFIC ONE
    DBMS_OUTPUT.put_line(NEXT_DAY (SYSDATE, 'SAT')); --PROXIMO SABADO / NEXT SATURDAY
    DBMS_OUTPUT.put_line(NEXT_DAY (SYSDATE, 'MON')); --PROXIMO LUNES / NEXT MONDAY
    --ULTIMO DIA DE LA FECHA / LAST DAY OF THE DATE
    DBMS_OUTPUT.put_line(LAST_DAY (TO_DATE('13-MAR-2025','DD-MON-YY')));
END;
/

SELECT EMP_ID, EMP_NAME, HIRE_DATE, TO_CHAR(HIRE_DATE, 'YYYY-MM-DD') HIRE_DATE_FORMAT
FROM PR_EMPLOYEES
WHERE HIRE_DATE BETWEEN '01-JAN-25' AND '30-MAR-25'
;
/