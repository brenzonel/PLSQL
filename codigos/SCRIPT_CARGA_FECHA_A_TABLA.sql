set serveroutput on --habilita el output para que se puedan mostrar mensajes con dbs_output.put_putline

DECLARE
    CURSOR f_vta IS
    SELECT
        id_clte,
        valor,
        fecha_fact
    FROM
        factura_vta;

    v_anio   NUMBER;
    v_mes    VARCHAR(5);
    f_id_clt NUMBER;
    f1       utl_file.file_type;
    CURSOR v_ac IS
    SELECT
        id_clte,
        anio,
        mes,
        valor
    FROM
        ventas_acumulada;

BEGIN
    DELETE FROM ventas_acumulada;

    f1 := utl_file.fopen('URL_DIR', 'prueba.txt', 'w');
    utl_file.put_line(f1, 'ID'
                          || ' '
                          || 'AÑO'
                          || ' '
                          || 'MES'
                          || '  '
                          || 'VALOR');

    FOR venta IN f_vta LOOP
        v_anio := TO_NUMBER ( to_char(venta.fecha_fact, 'yyyy') );
        v_mes := TO_NUMBER ( to_char(venta.fecha_fact, 'mm') );
        BEGIN
            SELECT
                id_clte
            INTO f_id_clt
            FROM
                ventas_acumulada
            WHERE
                    id_clte = venta.id_clte
                AND anio = v_anio
                AND mes = v_mes;

        EXCEPTION
            WHEN no_data_found THEN
                f_id_clt := NULL;
        END;
	--if f_vta%notfound then -----este found no se puede porque el sql es solo para insert, update y delete
        IF f_id_clt IS NULL THEN
            INSERT INTO ventas_acumulada VALUES (
                venta.id_clte,
                v_anio,
                v_mes,
                venta.valor
            );

        ELSE
            UPDATE ventas_acumulada
            SET
                valor = nvl(valor, 0) + venta.valor
            WHERE
                    id_clte = venta.id_clte
                AND anio = v_anio
                AND mes = v_mes;

        END IF;

    END LOOP;

    FOR a_venta IN v_ac LOOP
        IF a_venta.mes < 10 THEN
            utl_file.put_line(f1, a_venta.id_clte
                                  || ' '
                                  || a_venta.anio
                                  || ' 0'
                                  || a_venta.mes
                                  || '   '
                                  || a_venta.valor);
        ELSE
            utl_file.put_line(f1, a_venta.id_clte
                                  || ' '
                                  || a_venta.anio
                                  || ' '
                                  || a_venta.mes
                                  || '   '
                                  || a_venta.valor);
        END IF;

        dbms_output.put_line('se escribio en el archivo');
    END LOOP;

    utl_file.fclose(f1);
END;