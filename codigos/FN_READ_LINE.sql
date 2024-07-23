FUNCTION read_line (
        p_str IN VARCHAR2,
        p_pos IN NUMBER
    ) RETURN VARCHAR2 IS

        lv_str_line          VARCHAR2(2000) := p_str; --var1
        lv_str_field         VARCHAR2(2000) := ''; --var2
        lv_position          NUMBER := p_pos; --var3
        lv_position_pipe     NUMBER;
        lv_position_pipe_nxt NUMBER;
    BEGIN
        IF lv_position = 1 THEN
            lv_position_pipe := instr(lv_str_line, '|', 1, lv_position) + 1;
        ELSE
            lv_position_pipe := instr(lv_str_line, '|', 1, lv_position - 1) + 1;
        END IF;

        lv_position_pipe_nxt := instr(lv_str_line, '|', 1, lv_position);
        IF lv_position = 12 THEN
            IF substr(lv_str_line,
                      instr(lv_str_line, '|', 1, lv_position - 1) + 1,
                      120) IS NULL THEN
                lv_str_field := '';
            ELSE
                lv_str_field := substr(lv_str_line, instr(lv_str_line, '|', 1, lv_position - 1) + 1, 120);
            END IF;
        ELSE
            IF lv_position = 1 THEN
                lv_str_field := substr(lv_str_line, 1,(lv_position_pipe) - 2);
            ELSE
                IF lv_position = 9 OR lv_position = 8 THEN
                    lv_str_field := trim(translate(substr(lv_str_line, lv_position_pipe,(lv_position_pipe_nxt - lv_position_pipe)), '$,'
                    , ' '));

                ELSE
                    lv_str_field := trim(translate(substr(lv_str_line, lv_position_pipe,(lv_position_pipe_nxt - lv_position_pipe)), '$,'
                    , ' '));
                END IF;
            END IF;
        END IF;

        RETURN ( lv_str_field );
END read_line;