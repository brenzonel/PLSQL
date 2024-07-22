set  serveroutput on --PARA ACTIVAR LOS MENSAJES EN CONSOLA SOLO SE EJCUTA 1 VEZ

CREATE OR REPLACE PROCEDURE SP_CARGAR (
    opcion NUMBER
) IS
--declare
    f2                utl_file.file_type;
    f1                utl_file.file_type;
    v1                VARCHAR(256);
    posicion_pipe_sig NUMBER;
    posicion_pipe     NUMBER;
    tabla             VARCHAR(2);
    c_id_clte         NUMBER;
    id_clte           NUMBER;
/*variables de la tabla factura*/
    f_fecha           DATE;
    f_folio           NUMBER;
    f_valor           NUMBER;
    f_estatus         VARCHAR(20);
/*variables de la tabla factura*/
/*variables de la tabla producto*/
    p_folio           NUMBER;
    p_prod            NUMBER;
    p_valor           NUMBER;
    p_cantidad        NUMBER;   
/*variables de la tabla producto*/
    s                 NUMBER;
BEGIN /******** PARA ELIMINAR LOS DATOS DE LAS TABLAS FACT_VTA Y PROD_VENTA Y PROBAR CON OPCION 1 Y OPCION 0 COMO PARAMETROS*******/
    DELETE FROM ba_fact_vta;

    DELETE FROM ba_prod_venta;
/*******ELIMINAR CUANDO SEA NECESARIO********/
    dbms_output.put_line(opcion);
    f2 := utl_file.fopen('URL_DIR', 'factura_producto.txt', 'r');
    LOOP
        utl_file.get_line(f2, v1);
        dbms_output.put_line('se lee la linea de:');
        dbms_output.put_line(v1);
        tabla := substr(v1, 1, 2);
        IF tabla = 'FP' THEN --pregunto si es factura
            s := 3;
            posicion_pipe := instr(v1, '|');
            f_folio := TO_NUMBER ( substr(v1, 3, posicion_pipe - 3) ); --consigo el folio
            dbms_output.put_line('FOLIO:');
            dbms_output.put_line(f_folio);
            posicion_pipe_sig := instr(v1, '|', s - 1, 2);
            s := posicion_pipe_sig;
            id_clte := TO_NUMBER ( substr(v1, posicion_pipe + 1, s - posicion_pipe - 1) ); --consigo el cliente
            dbms_output.put_line('CLIENTE:');
            dbms_output.put_line(id_clte);
      /***sub bloque para validar que exista el cliente***/
            BEGIN
                SELECT
                    id_cliente
                INTO c_id_clte
                FROM
                    ba_cliente
                WHERE
                    id_cliente = id_clte;

            EXCEPTION
                WHEN no_data_found THEN --si no existe le asigno null 
                    c_id_clte := NULL;
            END;
      /***sub bloque****/
            posicion_pipe := instr(v1, '|', s);
            posicion_pipe_sig := instr(v1, '|', s - 1, 2);
            s := posicion_pipe_sig;
            f_fecha := TO_DATE ( substr(v1, posicion_pipe + 1, s - posicion_pipe - 1) ); --consigo la fecha
            dbms_output.put_line('FECHA:');
            dbms_output.put_line(f_fecha);
            posicion_pipe := instr(v1, '|', s);
            posicion_pipe_sig := instr(v1, '|', s - 1, 2);
            s := posicion_pipe_sig;
            f_valor := TO_NUMBER ( substr(v1, posicion_pipe + 1, s - posicion_pipe - 1) ); --consigo el valor
            dbms_output.put_line('VALOR:');
            dbms_output.put_line(f_valor);
            posicion_pipe := instr(v1, '|', s);
            posicion_pipe_sig := instr(v1, '|', s - 1, 2);
            s := posicion_pipe_sig;
            f_estatus := to_char(substr(v1, posicion_pipe + 1, s - posicion_pipe - 1)); --consigo el estatus
            dbms_output.put_line('ESTATUS:');
            dbms_output.put_line(f_estatus);
            IF
                c_id_clte IS NULL
                AND opcion = 1
            THEN -- se pregunta si se encontro el cliente y si la opcion es 1 donde 1 es un SI para que se cree el cliente
      /******CREAR EL CLIENTE EN LA TABLA CLIENTE*****/
                INSERT INTO ba_cliente VALUES (
                    id_clte,
                    'SIN NOMBRE'
                );

                IF SQL%found THEN
                    dbms_output.put_line('se inserto en la cliente');
                ELSE
                    dbms_output.put_line('no se inserto en la tabla cliente');
                END IF;

            END IF; --end if de la opcion 1 y c_id_clte = NULL
            IF
                c_id_clte = id_clte
                AND opcion = 1
            THEN --verificar que el cliente existe y  que entre cuando la opcion no sea cero y se inserte en la tabla
                INSERT INTO ba_fact_vta VALUES (
                    f_folio,
                    id_clte,
                    f_fecha,
                    f_valor,
                    f_estatus
                );

                IF SQL%found THEN --valida que el insert en fact:vta se realizo
                    dbms_output.put_line('se inserto en la tabla factura venta');
                ELSE
                    dbms_output.put_line('no se inserto en la tabla factura venta');
                END IF; --fin de la validacion del insert
            END IF;-- fin del fin cuando el cliente existe y opcion =1
            IF
                c_id_clte IS NULL
                AND opcion = 0
            THEN --se pregunta si se encontro el cliente y si la opcion es 0 para crear un archivo con los datos del cliente 
                f1 := utl_file.fopen('URL_DIR', 'clientes_no_dados_de_alta.txt', 'a');
                dbms_output.put_line('SE INSERTO EN EL ARCHIVO LA CADENA:');
                dbms_output.put_line(v1);
                utl_file.put_line(f1, v1);
                dbms_output.put_line('al archivo');
            END IF; --end if de c_id_clte = NULL and opcion = 0
        END IF; --end if de la tabla = FP
        IF tabla = 'PF' THEN --pregunto si es producto
            s := 3;
            posicion_pipe := instr(v1, '|');
            p_folio := TO_NUMBER ( substr(v1, 3, posicion_pipe - 3) ); --consigo el folio
            dbms_output.put_line('FOLIO:');
            dbms_output.put_line(p_folio);
            posicion_pipe_sig := instr(v1, '|', s - 1, 2);
            s := posicion_pipe_sig;
            p_prod := TO_NUMBER ( substr(v1, posicion_pipe + 1, s - posicion_pipe - 1) ); --consigo el numero de producto
            dbms_output.put_line('PRODUCTO:');
            dbms_output.put_line(p_prod);
            posicion_pipe := instr(v1, '|', s);
            posicion_pipe_sig := instr(v1, '|', s - 1, 2);
            s := posicion_pipe_sig;
            p_valor := TO_NUMBER ( substr(v1, posicion_pipe + 1, s - posicion_pipe - 1) );--consigo el valor
            dbms_output.put_line('VALOR:');
            dbms_output.put_line(p_valor);
            posicion_pipe := instr(v1, '|', s);
            posicion_pipe_sig := instr(v1, '|', s - 1, 2);
            s := posicion_pipe_sig;
            p_cantidad := TO_NUMBER ( substr(v1, posicion_pipe + 1, s - posicion_pipe - 1) ); --consigo la cantidad
            dbms_output.put_line('CANTIDAD:');
            dbms_output.put_line(p_cantidad);
            IF
                c_id_clte = id_clte
                AND opcion = 1
            THEN --verificar que el cliente existe y  que entre cuando la opcion no sea cero y se inserte en la tabla
                INSERT INTO ba_prod_venta VALUES (
                    p_folio,
                    p_prod,
                    p_valor,
                    p_cantidad
                ); --folio, prod,valor,cant
                IF SQL%found THEN --se valida si se realizo el insert en prod_venta
                    dbms_output.put_line('se inserto en la tabla producto venta');
                ELSE
                    dbms_output.put_line('no se inserto en la tabla producto venta');
                END IF; --fin del if si se realizo el insert en la tabla prod_venta
            END IF;-- fin del if de la validacion del cliente si existe y opcion =1
            IF
                c_id_clte IS NULL
                AND opcion = 0
            THEN
                dbms_output.put_line('SE INSERTO EN EL ARCHIVO LA CADENA:');
                dbms_output.put_line(v1);
                utl_file.put_line(f1, v1);
            END IF; --FIN DEL if cuando se agrega al archivo
        END IF; --fin del if = PF
--end if;
    END LOOP;

EXCEPTION
    WHEN no_data_found THEN
        utl_file.fclose(f2);
        utl_file.fclose(f1);
        dbms_output.put_line('se termino de recorrer el archivo');
END;
/*****SE EJECUTA EL PROCEDURE*******/
BEGIN
    SP_CARGAR(0);
END;