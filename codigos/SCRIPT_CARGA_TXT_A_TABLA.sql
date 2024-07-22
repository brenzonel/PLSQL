set serveroutput on --habilita el output para que se puedan mostrar mensajes con dbs_output.put_putline se ejecuta solo 1 vez

DECLARE
    f2 utl_file.file_type; --se declara la variable f2 como tipo fila
    v1 VARCHAR(256); --aqui se almacenara lo que se va a leer del archivo
BEGIN 
--delete from factura_vta; -- elimino los datos de la tabla en caso de que se requiera
    f2 := utl_file.fopen('URL_DIR', 'factura_ventas.txt', 'r'); --se abre el archivo f2
    LOOP --se usa un ciclo para leer los renglones del archivo
        utl_file.get_line(f2, v1); --se lee 1 renglon del archivo
        dbms_output.put_line(v1); --imprimo el renglon para verificar que se leyo
        INSERT INTO factura_vta VALUES (
            nvl(TO_NUMBER(substr(v1, 1, 4)),
                0),
            nvl(TO_NUMBER(substr(v1, 6, 3)),
                0),
            nvl(TO_NUMBER(substr(v1, 10, 5)),
                0),
            TO_DATE(substr(v1, 16, 8))
        ); --se agregan los valores segun el orden definido del archivo para ingresarlo a la tabla en el orden: values(id_clte, id_fact, valor, fecha )
        dbms_output.put_line('se inserto un registro'); --imprimo el aviso para mostrar que se ingreso un archivo
    END LOOP; --se termina el ciclo, si ya no se encontraron datos, se va directo a la excepcion de no_data_found por que ya no tendra datos el archivo

EXCEPTION
    WHEN no_data_found THEN --entra con la excepcion de que no encontro datos
        utl_file.fclose(f2); --se cierra el archivo
        dbms_output.put_line('se termino de recorrer el archivo'); --imprimo el aviso de que se termino de recorrer el archivo
END;