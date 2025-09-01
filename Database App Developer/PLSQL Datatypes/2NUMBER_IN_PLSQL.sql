/*Numbers in PLSQL*/
--Round, Floor, Ceil
BEGIN
    --ROUND
    DBMS_OUTPUT.put_line (ROUND(10.25));
    DBMS_OUTPUT.put_line (ROUND(10.25, 1));
    DBMS_OUTPUT.put_line (ROUND(10.23, 1));
    DBMS_OUTPUT.put_line (ROUND(10.25, 2));
    DBMS_OUTPUT.put_line (ROUND(10.25, -2));
    DBMS_OUTPUT.put_line (ROUND(125, -2));
    --TRUNC
    DBMS_OUTPUT.put_line (TRUNC (10.25, 1));
    DBMS_OUTPUT.put_line (TRUNC (10.27, 1));
    DBMS_OUTPUT.put_line (TRUNC (123.456, -1));
    --FLOOR
    DBMS_OUTPUT.put_line (FLOOR(10.25));
    --CEIL
    DBMS_OUTPUT.put_line (CEIL(10.25));
END;
/

BEGIN
   DBMS_OUTPUT.put_line (MOD (15, 4));
   DBMS_OUTPUT.put_line (REMAINDER (15, 4));
   DBMS_OUTPUT.put_line (MOD (15, 6));
   DBMS_OUTPUT.put_line (REMAINDER (15, 6));
END;
/

--Format numbers
BEGIN
   DBMS_OUTPUT.put_line ('Amount= ' || TO_CHAR (10000, '0G000G999'));
   DBMS_OUTPUT.put_line ('Amount= ' || TO_CHAR (10000, 'FM9G999G999'));
   DBMS_OUTPUT.put_line ('Amount= ' || TO_CHAR (10000, 'FML999G999D99'));
END;
/