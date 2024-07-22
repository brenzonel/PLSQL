--create or replace procedure fact_venta
--is
declare 
cursor f_vta is
select id_clte, valor, fecha_fact
from Factura_vta;
v_anio number;
v_mes varchar(5);
f_id_clt number;

begin
delete from venta_anual; 
FOR venta IN f_vta LOOP
    v_anio := TO_NUMBER ( to_char(venta.fecha_fact, 'yyyy') );
    v_mes := TO_NUMBER ( to_char(venta.fecha_fact, 'mm') );
    BEGIN
        SELECT
            id_cliente
        INTO f_id_clt
        FROM
            venta_anual
        WHERE
                id_cliente = venta.id_clte
            AND anio = v_anio;

    EXCEPTION
        WHEN no_data_found THEN
            f_id_clt := NULL;
    END;
	--if f_vta%notfound THEN -----este found no se puede porque el sql es solo para insert, update y delete
      if f_id_clt is null THEN
            if v_mes = 01 THEN
                insert into venta_anual (id_cliente, anio, ene) values (venta.id_clte, v_anio, venta.valor);
            ELSIF v_mes = 02 THEN 
                insert into venta_anual (id_cliente, anio, feb) values (venta.id_clte, v_anio, venta.valor);
            ELSIF v_mes = 03 THEN 
                insert into venta_anual (id_cliente, anio, mar) values (venta.id_clte, v_anio, venta.valor);
            ELSIF v_mes = 04 THEN 
                insert into venta_anual (id_cliente, anio, abr) values (venta.id_clte, v_anio, venta.valor);
            ELSIF v_mes = 05 THEN 
                insert into venta_anual (id_cliente, anio, may) values (venta.id_clte, v_anio, venta.valor);
            ELSIF v_mes = 06 THEN 
                insert into venta_anual (id_cliente, anio, jun) values (venta.id_clte, v_anio, venta.valor);
            ELSIF v_mes = 07 THEN 
                insert into venta_anual (id_cliente, anio, jul) values (venta.id_clte, v_anio, venta.valor);
            ELSIF v_mes = 08 THEN 
                insert into venta_anual (id_cliente, anio, ago) values (venta.id_clte, v_anio, venta.valor);
            ELSIF v_mes = 09 THEN 
                insert into venta_anual (id_cliente, anio, sep) values (venta.id_clte, v_anio, venta.valor);
            ELSIF v_mes = 10 THEN 
                insert into venta_anual (id_cliente, anio, oct) values (venta.id_clte, v_anio, venta.valor);
            ELSIF v_mes = 11 THEN 
                insert into venta_anual (id_cliente, anio, nov) values (venta.id_clte, v_anio, venta.valor);
            ELSIF v_mes = 12 THEN 
                insert into venta_anual (id_cliente, anio, dic) values (venta.id_clte, v_anio, venta.valor);
            END IF;
    
        else 
            
            if v_mes = 01 THEN
                update venta_anual set ene = nvl(ene,0) + venta.valor where ID_CLIENTE = venta.id_clte and anio = v_anio;
            ELSIF v_mes = 02 THEN 
                update venta_anual set feb = nvl(feb,0) + venta.valor where ID_CLIENTE = venta.id_clte and anio = v_anio;
            ELSIF v_mes = 03 THEN 
                update venta_anual set mar = nvl(mar,0) + venta.valor where ID_CLIENTE = venta.id_clte and anio = v_anio;
            ELSIF v_mes = 04 THEN 
                update venta_anual set abr = nvl(abr,0) + venta.valor where ID_CLIENTE = venta.id_clte and anio = v_anio;
            ELSIF v_mes = 05 THEN 
                update venta_anual set may = nvl(may,0) + venta.valor where ID_CLIENTE = venta.id_clte and anio = v_anio;
            ELSIF v_mes = 06 THEN 
                update venta_anual set jun = nvl(jun,0) + venta.valor where ID_CLIENTE = venta.id_clte and anio = v_anio;
            ELSIF v_mes = 07 THEN 
                update venta_anual set jul = nvl(jul,0) + venta.valor where ID_CLIENTE = venta.id_clte and anio = v_anio;
            ELSIF v_mes = 08 THEN 
                update venta_anual set ago = nvl(ago,0) + venta.valor where ID_CLIENTE = venta.id_clte and anio = v_anio;
            ELSIF v_mes = 09 THEN 
                update venta_anual set sep = nvl(sep,0) + venta.valor where ID_CLIENTE = venta.id_clte and anio = v_anio;
            ELSIF v_mes = 10 THEN 
                update venta_anual set oct = nvl(oct,0) + venta.valor where ID_CLIENTE = venta.id_clte and anio = v_anio;
            ELSIF v_mes = 11 THEN 
                update venta_anual set nov = nvl(nov,0) + venta.valor where ID_CLIENTE = venta.id_clte and anio = v_anio;
            ELSIF v_mes = 12 THEN 
                update venta_anual set dic = nvl(dic,0) + venta.valor where ID_CLIENTE = venta.id_clte and anio = v_anio;
            END IF;
        END IF;
END LOOP;

END;