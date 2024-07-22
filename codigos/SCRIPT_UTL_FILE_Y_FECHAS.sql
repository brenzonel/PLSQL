set serveroutput on

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
BEGIN
    DELETE FROM ventas_acumulada;

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

END;
/****************************************/

CREATE OR REPLACE DIRECTORY url_dir AS 'C:\Users\asu\Desktop\Oracle';

GRANT READ ON DIRECTORY url_dir TO PUBLIC;

GRANT WRITE ON DIRECTORY url_dir TO PUBLIC;

GRANT EXECUTE ON utl_file TO PUBLIC;

DECLARE
    cadena VARCHAR(256);
    file   utl_file.file_type;
BEGIN
    cadena := 'si se pudo LEL';
    file := utl_file.fopen('url_dir', 'prueba.txt', 'a');
    utl_file.put(file, cadena);
    utl_file.fclose(file);
    dbms_output.put_line('si se escribio');
END;