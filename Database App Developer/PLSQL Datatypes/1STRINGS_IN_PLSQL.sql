--Working with Strings in PL/SQL
DECLARE
    l_var   varchar2(50) := 'Hola';
    l_char  char(50)     := 'Hola';
BEGIN
    DBMS_OUTPUT.put_line ('*'||l_var||'*');
    DBMS_OUTPUT.put_line ('*'||l_char||'*');
END;

/

DECLARE
  l_var VARCHAR2 (10) := 'Logic';
  l_char    CHAR (10) := 'Logic';
BEGIN
  IF l_var = l_char
  THEN
   DBMS_OUTPUT.put_line ('Equal');
  ELSE
   DBMS_OUTPUT.put_line ('Not Equal');
  END IF;
END;

/
/*
No Igual se mostrara, porque el valor de l_fixed se rellena con 10 espacios
-------------------------------------------------
“Not Equal” is displayed, because the value of l_fixed has been padded to a length of 10 with spaces.
*/

--Concatenar multiples string / Concatenate multiple strings
DECLARE
  l_first  VARCHAR2 (10) := 'Brenzon';
  l_middle VARCHAR2 (5) := 'Elri';
  l_last   VARCHAR2 (20)
              := 'Alphons';
BEGIN
  /* Usar la funcion CONCAT / Use the CONCAT function */
  DBMS_OUTPUT.put_line (
     CONCAT ('Brenzon', 'Alphons'));
  /* Uso del operador || / Use the || operator */
  DBMS_OUTPUT.put_line (
      l_first
      || ' '
      || l_middle
      || ' '
      || l_last);
END;
/

--Cambiar mayusculas-minusculas de un string / Change the case of a string
DECLARE
    l_var VARCHAR2(25)  := 'CompaÑIA brenZON';
BEGIN
    DBMS_OUTPUT.put_line (UPPER(l_var));
    DBMS_OUTPUT.put_line (LOWER(l_var));
    DBMS_OUTPUT.put_line (INITCAP (l_var));
END;
/

--Encontrar string en otro string / Find a string within another string
DECLARE
    l_var varchar2(50)  := 'BrenzonEl PLSQL el codigo';
BEGIN
    --Encontrar la primer cohincidencia
    DBMS_OUTPUT.put_line ( 'Index: '||INSTR(l_var, 'e'));
--    
    --Encontrar la cohincidencia empezando en una poscicion fija
    DBMS_OUTPUT.put_line ( 'Index: '||INSTR(l_var, 'e', 4));
    
    --Encontrar la cohincidencia empezando en una poscicion fija recorriendo desde el final
    DBMS_OUTPUT.put_line ( 'Index: '||INSTR(l_var, 'e', -4));
    
    --Encontrar la cohincidencia N empezando desde una posicion fija recorriendo desde el final
    DBMS_OUTPUT.put_line ( 'Index: '||INSTR(l_var, 'e', -4, 2));
END;
/

--Funcion booleana para identificar si un string esta dentro de otro / Boolean function to identify if a string is within another
CREATE OR REPLACE FUNCTION in_string (string_in IN VARCHAR2, substring IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
    RETURN INSTR (string_in, substring) > 0;
END in_string;
/

DECLARE
    l_bol BOOLEAN;
    l_var varchar2(50)  := 'BrenzonEl PLSQL el codigo';
BEGIN
    l_bol := in_string ( l_var, 'Ñ');
    IF l_bol = TRUE THEN 
        DBMS_OUTPUT.put_line ('SI');
    ELSE
        DBMS_OUTPUT.put_line ('NO');
    END IF;
END;
/

--Rellenar strings / Fill out string
DECLARE
    l_name  VARCHAR2(50)    := 'Brandon';
    l_ape   VARCHAR2(50)    := 'Luna';
    l_fono  VARCHAR2(50)    := '55555555555';
BEGIN
    --Rellenar a la izquierda
    DBMS_OUTPUT.put_line ('Cabecera');
    DBMS_OUTPUT.put_line (LPAD('Subtitulo', 13, '.'));
    
    --Agregar "123" al final hasta completar 20 caracteres
    DBMS_OUTPUT.put_line (RPAD('ABD', 20, '1234'));
    
    --Mostrar cabecera y resultados
    DBMS_OUTPUT.put_line (
    /*1234567890x12345678901234567890x*/
     'First Name Last Name            Phone');
     DBMS_OUTPUT.put_line (
     RPAD(l_name,10)
     || ' '
     ||RPAD(l_ape,'20')
     ||' '
     ||l_fono);
END;
/

--Funcion de replace y translate / replace and translate function
DECLARE
    l_string    VARCHAR2(50) := 'Brenzon Spiricueta ei';
    l_var       VARCHAR2(20) := 'ABC-a-b-c-abc';
BEGIN
    DBMS_OUTPUT.put_line (REPLACE(l_string, 'ei', '37'));
    DBMS_OUTPUT.put_line (TRANSLATE(l_string, 'ei','37'));
    
    DBMS_OUTPUT.put_line (REPLACE(l_var, 'abc', '123'));
    DBMS_OUTPUT.put_line (TRANSLATE(l_var, 'abc','123'));
    
END;
/

--Funcion ltrim y rtrim / ltrim and rtrim function
DECLARE
    a VARCHAR2(50) := 'Esta sentencia tiene varios .......';
    b VARCHAR2(50) := 'El numero 1';
BEGIN
    DBMS_OUTPUT.put_line(RTRIM(a, '.'));
    DBMS_OUTPUT.put_line(LTRIM(b, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ '
                                    || 'abcdefghijklmnopqrstuvwxyz'));
    
END;
/

--TRIM
DECLARE
    l_var   VARCHAR2(40) := '...Que hay de nuevo viejo...';
BEGIN
    DBMS_OUTPUT.put_line ( TRIM (LEADING '.' FROM l_var));
    DBMS_OUTPUT.put_line ( TRIM (TRAILING '.' FROM l_var));
    DBMS_OUTPUT.put_line ( TRIM (BOTH '.' FROM l_var));
    --default
    DBMS_OUTPUT.put_line ( TRIM (l_var));
END;
/

--exceptions
CREATE TABLE small_varchar (
    str_value   VARCHAR2(2)
    );
    /
BEGIN
    INSERT INTO small_varchar VALUES ('airport');
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.put_line (SQLERRM || ' Value error');
    WHEN OTHERS THEN
        DBMS_OUTPUT.put_line ('Error: '|| SQLERRM);
END;