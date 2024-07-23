create or replace PACKAGE BODY "CE_BANK_STA_PKG" AS

---==============================================================================
---
--- Object Description : Insertion in the interface tables of Account Statements (EC - Declaration)
---
---------------------------------------------------------------------------------
---
--- Development And Modification History:
---
--- TASK # Ver# DATE     Developer       DESCRIPTION
--- ------ ---- -------- --------------- ---------------------------------------------
--- XXXXX  1.0  01/02/19 BADLA           Insertion in the interface tables of Account Statements (EC - Declaration)
---
---==============================================================================

    g_debug   VARCHAR2(2) := nvl(fnd_profile.value_specific('DEBUG_MODE',fnd_global.user_id),'N');

---==============================================================================

    PROCEDURE output_message (
        i_message IN VARCHAR2
    )
        IS
    BEGIN
        apps.fnd_file.put(apps.fnd_file.output,i_message);
        apps.fnd_file.new_line(apps.fnd_file.output,1);
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20001,'Error in ce_bank_sta.output_message - ' || sqlerrm);
    END output_message;
--****************************************************************************
-- FUNCTION READ_LINE: Reads the input string and extract the selected field
--****************************************************************************

    FUNCTION read_line (
        p_str   IN VARCHAR2,
        p_pos   IN NUMBER
    ) RETURN VARCHAR2 IS

        lv_str_line            VARCHAR2(2000) := p_str;
        lv_str_field           VARCHAR2(2000) := '';
        lv_position            NUMBER := p_pos;
        lv_position_pipe       NUMBER;
        lv_position_pipe_nxt   NUMBER;
        lv_send_email          BOOLEAN;
    BEGIN
        output_message('*******************************************************************************************************');
        output_message('Start read_line');
        output_message(' p_str:         ' || p_str);
        output_message(' p_pos:         ' || p_pos);
        IF
            lv_position = 1
        THEN
            lv_position_pipe := instr(lv_str_line,'|',1,lv_position) + 1;
        ELSE
            lv_position_pipe := instr(lv_str_line,'|',1,lv_position - 1) + 1;
        END IF;

        lv_position_pipe_nxt := instr(lv_str_line,'|',1,lv_position);
        IF
            lv_position = 12
        THEN
            IF
                substr(lv_str_line,instr(lv_str_line,'|',1,lv_position - 1) + 1,120) IS NULL
            THEN
                lv_str_field := '';
            ELSE
                lv_str_field := substr(lv_str_line,instr(lv_str_line,'|',1,lv_position - 1) + 1,120);
            END IF;
        ELSE
            IF
                lv_position = 1
            THEN
                lv_str_field := substr(lv_str_line,1, (lv_position_pipe) - 2);
            ELSE
                IF
                    lv_position = 9 OR lv_position = 8
                THEN
                    lv_str_field := trim(translate(substr(lv_str_line,lv_position_pipe, (lv_position_pipe_nxt - lv_position_pipe) ),'$,',' ') );

                ELSE
                    lv_str_field := trim(translate(substr(lv_str_line,lv_position_pipe, (lv_position_pipe_nxt - lv_position_pipe) ),'$,',' ') );
                END IF;
            END IF;
        END IF;

        return(lv_str_field);
    EXCEPTION
        WHEN OTHERS THEN
            return('Error in the line: ' || p_str);
            output_message('Error in the line: ' || p_str);
    END read_line;

--****************************************************************************
-- PROCEDURE read_bank_st: This procedure insert the corresponding fields separated by a pipe from an archive .txt
--****************************************************************************

    PROCEDURE read_bank_st (
        errbuf        OUT VARCHAR2,
        retcode       OUT NUMBER,
        lv_nom_file   IN VARCHAR2,
        p_bank_name   IN VARCHAR2
    ) IS

        lv_filename            VARCHAR2(100) := lv_nom_file || '.txt';
        lv_filename_re         VARCHAR2(100) := lv_nom_file || '.bck';
        lv_dir                 VARCHAR2(240) := fnd_utils_pkg.get_unix_alias('$DATA_TOP')
                                   || '/inbox';
        lv_dir_dest            VARCHAR2(240) := fnd_utils_pkg.get_unix_alias('$DATA_TOP')
                                        || '/archive';
        TYPE lv_tablines IS
            TABLE OF ce_statement_lines_interface%rowtype INDEX BY BINARY_INTEGER;
        TYPE lv_tabheader IS
            TABLE OF ce_statement_headers_int%rowtype INDEX BY BINARY_INTEGER;
        lv_llines              lv_tablines;
        lv_lheader             lv_tabheader;
        lv_sfile               utl_file.file_type;
        lv_newline             VARCHAR2(1000);
        lv_num                 NUMBER := 0;
        lv_num2                NUMBER := 0;
        lv_gorgid              hr.hr_all_organization_units.organization_id%TYPE;
        lv_gacctname           apps.ce_bank_accounts_v.bank_account_name%TYPE;
        lv_gcurcode            apps.ce_bank_accounts_v.currency_code%TYPE;
        lv_gbankbranchid       apps.ce_bank_accounts_v.bank_branch_id%TYPE;
        lv_gbankacctid         apps.ce_bank_accounts_v.bank_account_id%TYPE;
        lv_gbankname           apps.ce_bank_branches_v.bank_name%TYPE;
        lv_gbankbranchname     apps.ce_bank_branches_v.bank_branch_name%TYPE;
        lv_gbankbranchparid    apps.ce_bank_branches_v.branch_party_id%TYPE;
        lv_msg                 VARCHAR(4000);
        lv_num_error           NUMBER := 0;
        lv_send_email          BOOLEAN;
        lv_error               NUMBER := 0;
        lv_numval              NUMBER := 0;
        lv_req_id              NUMBER;
        lv_msg_conc            VARCHAR2(4000);
        lv_date_param          varchar(20);
        lv_c_phase             VARCHAR2(50);
        lv_c_status            VARCHAR2(50);
        lv_c_dev_phase         VARCHAR2(50);
        lv_c_dev_status        VARCHAR2(50);
        lv_c_message           VARCHAR2(50);
        lv_req_return_status   BOOLEAN;
        lv_dup_bank_sta        NUMBER;
        lv_dup_bank_sta_intf   NUMBER;
    BEGIN
        output_message('*******************************************************************************************************');
        output_message('Start read_bank_st');
        output_message(' lv_nom_file:             ' || lv_nom_file);
        output_message(' p_bank_name:         ' || p_bank_name);
        BEGIN
            lv_sfile := utl_file.fopen(lv_dir,lv_filename,'R');
        EXCEPTION
            WHEN OTHERS THEN
                --The file must be closed here since at the moment that it does not find lines it jumps directly to the execption and it would not close it.
                utl_file.fclose(lv_sfile);
                lv_msg := 'The file was not found: ' || lv_filename;
                output_message('The file was not found: ' || lv_filename);
                --lv_send_email := fnd_utils_pkg.send_email();

        END;--execption 

        IF
            p_bank_name = 'NOMBRE BANCO'
        THEN
            IF
                utl_file.is_open(lv_sfile)
            THEN
                output_message(' Oracle load headers');
                lv_num := 1;
                utl_file.get_line(lv_sfile,lv_newline);
                output_message('Start storage of the lines  ');
                LOOP
                    BEGIN
                        utl_file.get_line(lv_sfile,lv_newline);

                -- BANK_ACCOUNT_NUM 
                        output_message('----------------Number of line  ' || lv_num);
                        output_message('----------------');
                        lv_llines(lv_num).line_number := trim(read_line(lv_newline,11) );
                        lv_llines(lv_num).bank_account_num := trim(read_line(lv_newline,1) );

                    --STATEMENT_NUMBER 
                        lv_llines(lv_num).statement_number := TO_DATE(read_line(lv_newline,2),'dd-MM-yy');
                    --TRX_DATE 

                        lv_llines(lv_num).trx_date := TO_DATE(read_line(lv_newline,2),'dd-MM-yy');

                    -- TRX_CODE 

                        lv_llines(lv_num).trx_code := trim(read_line(lv_newline,6) );

                    --TRX_TEXT
                        lv_llines(lv_num).trx_text := trim(read_line(lv_newline,5)
                                                                || read_line(lv_newline,12) );
                    -- AMOUNT 

                        IF
                            to_number(read_line(lv_newline,8) ) = 0
                        THEN
                            lv_llines(lv_num).amount := to_number(read_line(lv_newline,9) );
                        ELSE
                            lv_llines(lv_num).amount := to_number(read_line(lv_newline,8) );
                        END IF;

                    --BANK_TRX_NUMBER  

                        lv_llines(lv_num).bank_trx_number := trim(read_line(lv_newline,4) );
                        output_message(lv_llines(lv_num).bank_trx_number);

                    -- BANK_ACCT_CURRENCY_CODE 
                        lv_llines(lv_num).bank_acct_currency_code := trim('MXN');
                        lv_num := lv_num + 1;
                    EXCEPTION
                        WHEN no_data_found THEN
                            EXIT;
                        WHEN OTHERS THEN
                            output_message('Error when loading lines'|| lv_newline);
                            utl_file.fclose(lv_sfile);
                    END;

                    output_message('End of loop','read_bank_st','LOG');
                END LOOP;

                ---HEADERS
                -- STATEMENT_NUMBER  

                output_message('Headers');
                lv_lheader(1).statement_number := TO_DATE(lv_llines(lv_num - 1).statement_number,'dd-MM-yy');

                output_message(lv_lheader(1).statement_number);
                        --BANK_ACCOUNT_NUM
                lv_lheader(1).bank_account_num := lv_llines(lv_num - 1).bank_account_num;
                output_message(lv_lheader(1).bank_account_num);
                        --STATEMENT_DATE 
                lv_lheader(1).statement_date := TO_DATE(lv_llines(lv_num - 1).statement_number,'dd-MM-yy');

                output_message(lv_lheader(1).statement_date);

                        --Bank name
                BEGIN
                    SELECT  --+ CE_BANK_STA_PKG.read_bank_st
                        cbaua.org_id,
                        cba.bank_account_name,
                        cba.currency_code,
                        cba.bank_branch_id,
                        cba.bank_account_id,
                        cbr.bank_name,
                        cbr.bank_branch_name,
                        cbr.branch_party_id
                    INTO
                        lv_gorgid,
                        lv_gacctname,
                        lv_gcurcode,
                        lv_gbankbranchid,
                        lv_gbankacctid,
                        lv_gbankname,
                        lv_gbankbranchname,
                        lv_gbankbranchparid
                    FROM
                        ce_bank_accounts cba,
                        ce_bank_branches_v cbr,
                        ce_bank_acct_uses_all cbaua
                    WHERE
                        1 = 1
                        AND cba.bank_branch_id = cbr.branch_party_id
                        AND cba.bank_account_id = cbaua.bank_account_id
                        AND cba.bank_account_num = lv_lheader(1).bank_account_num;

                EXCEPTION
                    WHEN OTHERS THEN
                        output_message('Check the query of bank information');
                        output_message('Error:::: ' || lv_lheader(1).bank_account_num);
                        lv_msg := 'Check the query of bank information Error:::: ' || lv_lheader(1).bank_account_num;
                        lv_error := lv_error + 1;
                        utl_file.fclose(lv_sfile);
                END;

                IF
                    lv_error = 0
                THEN
                        --BANK_NAME 
                    lv_lheader(1).bank_name := lv_gbankname;
                    output_message(lv_lheader(1).bank_name);
                        --BANK_BRANCH_NAME 
                    lv_lheader(1).bank_branch_name := lv_gbankbranchname;
                        --Close file
                    utl_file.fclose(lv_sfile);
                    output_message(' Close txt ');
                END IF;

            ELSE
                lv_error := lv_error + 1;
                utl_file.fclose(lv_sfile);
            END IF;

            BEGIN
                SELECT
                    COUNT(*)
                INTO lv_dup_bank_sta
                FROM
                    ce_statement_headers a,
                    ce_bank_accounts b
                WHERE
                    a.bank_account_id = b.bank_account_id
                    AND b.bank_account_num = lv_lheader(1).bank_account_num
                    AND a.statement_number = lv_lheader(1).statement_number;

            END;

            BEGIN
                SELECT
                    COUNT(*)
                INTO lv_dup_bank_sta_intf
                FROM
                    ce_statement_headers_int a
                WHERE
                    1 = 1
                    AND a.bank_account_num = lv_lheader(1).bank_account_num
                    AND a.statement_number = lv_lheader(1).statement_number;

            END;

            IF
                lv_dup_bank_sta > 0 OR lv_dup_bank_sta_intf > 0
            THEN
                lv_error := lv_error + 1;
                lv_num_error := lv_num_error + 1;
                IF
                    lv_dup_bank_sta_intf > 0
                THEN
                    lv_msg := ' Error: Duplicate Bank statement number: '
                              || lv_lheader(1).statement_number
                              || ' Bank account: '
                              || lv_lheader(1).bank_account_num
                              || ' in table of interface CE_STATEMENT_HEADERS_INT';

                    output_message(' Error: Duplicate Bank statement number: '
                                     || lv_lheader(1).statement_number
                                     || ' Bank account: '
                                     || lv_lheader(1).bank_account_num
                                     || ' in table of interface CE_STATEMENT_HEADERS_INT');

                ELSE
                    lv_msg := ' Error: Duplicate Bank statement number: '
                              || lv_lheader(1).statement_number
                              || ' Bank account: '
                              || lv_lheader(1).bank_account_num
                              || ' in table of bank statement CE_STATEMENT_HEADERS';

                    output_message(' Error: Duplicate Bank statement number: '
                                     || lv_lheader(1).statement_number
                                     || ' Bank account: '
                                     || lv_lheader(1).bank_account_num
                                     || ' in table of bank statement CE_STATEMENT_HEADERS');

                END IF;

            ELSE
                IF
                    lv_error = 0
                THEN
                    lv_date_param := to_char(to_date(lv_lheader(1).statement_date,'DD-MON-YY'),'YYYY/MM/DD HH24:MI:SS');

                    output_message(' Insert in headers ' || lv_filename);
                    BEGIN

                        output_message('Header Stored: '
                                         || lv_lheader(1).statement_number
                                         || ' '
                                         || lv_lheader(1).bank_account_num
                                         || ' '
                                         || lv_lheader(1).statement_date
                                         || ' '
                                         || lv_lheader(1).bank_name
                                         || ' '
                                         || lv_lheader(1).bank_branch_name
                                         || ' '
                                         || 'N'
                                         || ' '
                                         || lv_gcurcode);

                        INSERT INTO ce_statement_headers_int ( --+ CE_BANK_STA_PKG.read_bank_st
                            statement_number,
                            bank_account_num,
                            statement_date,
                            bank_name,
                            bank_branch_name,
                            record_status_flag,
                            currency_code,
                            created_by,
                            creation_date,
                            last_updated_by,
                            last_update_date
                        ) VALUES (
                            lv_lheader(1).statement_number,
                            lv_lheader(1).bank_account_num,
                            lv_lheader(1).statement_date,
                            lv_lheader(1).bank_name,
                            lv_lheader(1).bank_branch_name,
                            'N',
                            lv_gcurcode,
                            11,
                            SYSDATE,
                            11,
                            SYSDATE
                        );

                        COMMIT;
                    EXCEPTION
                        WHEN OTHERS THEN
                            output_message('Error when inserting at CE_STATEMENT_HEADERS_INT ');
                            lv_msg := ' '
                                      || 'Error Header: '
                                      || lv_lheader(1).statement_number
                                      || ' '
                                      || lv_lheader(1).bank_account_num;

                            lv_num_error := lv_num_error + 1;
                            lv_error := 1;
                            utl_file.fclose(lv_sfile);
                    END;

                    IF
                        lv_error = 0
                    THEN
                        lv_num2 := 1;
                        lv_numval := 1;
                        FOR i IN 1..lv_num - 1 LOOP
                            output_message(' Insert in lines ');
                            IF
                                lv_llines(i).trx_code IS NOT NULL
                            THEN
                                BEGIN
                                    INSERT INTO ce_statement_lines_interface  --+ CE_BANK_STA_PKG.read_bank_st
                                     (
                                        bank_account_num,
                                        statement_number,
                                        trx_date,
                                        trx_code,
                                        trx_text,
                                        amount,
                                        bank_trx_number,
                                        bank_acct_currency_code,
                                        line_number
                                    ) VALUES (
                                        lv_llines(i).bank_account_num,
                                        lv_lheader(1).statement_number,
                                        lv_llines(i).trx_date,
                                        lv_llines(i).trx_code,
                                        lv_llines(i).trx_text,
                                        lv_llines(i).amount,
                                        lv_llines(i).bank_trx_number,
                                        lv_gcurcode,
                                        lv_llines(i).line_number
                                    );

                                    output_message('Line: '
                                                     || lv_llines(i).bank_account_num
                                                     || ' '
                                                     || lv_lheader(1).statement_number
                                                     || ' '
                                                     || lv_llines(i).line_number);

                                    lv_numval := lv_numval + 1;
                                    lv_num2 := lv_num2 + 1;
                                    COMMIT;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        output_message('Error when inserting at ce_statement_lines_interface'|| sqlerrm);
                                        lv_msg := ' '
                                                  || 'Error line: '
                                                  || lv_lheader(1).statement_number
                                                  || lv_llines(i).line_number
                                                  || lv_num2;

                                        lv_num_error := lv_num_error + 1;
                                        utl_file.fclose(lv_sfile);
                                END;
                            ELSE
                                lv_num_error := lv_num_error + 1;

                                output_message('Line not valid: '
                                                 || lv_llines(i).bank_account_num
                                                 || ' '
                                                 || lv_lheader(1).statement_number
                                                 || ' '
                                                 || lv_num2);

                                lv_msg := ' Line not valid '
                                          || lv_lheader(1).statement_number
                                          || ' '
                                          || lv_llines(i).line_number
                                          || ' '
                                          || lv_num2;

                                EXIT;
                                lv_num2 := lv_num2 + 1;
                            END IF;

                        END LOOP;

                    END IF;

                END IF;
            END IF;

        END IF;

        IF
            lv_num_error > 0
        THEN
            --lv_send_email := fnd_utils_pkg.send_email();

            retcode := 2;
        ELSE
            output_message('Start call of concurrent Bank Statement Import');
            BEGIN
                output_message('*******************************************************************************************************');
                output_message('Start concurrent Bank Statement Import');
                output_message(' Option                   CE');
                output_message(' Bank Branch Name         ARPLABIM');
                output_message(' Bank Account Number      ');
                output_message(' Statement Number From    ');
                output_message(' Statement Number To      ');
                output_message(' Statement Date From      ');
                output_message(' Statement Date TO        ');
                output_message(' GL Date                  ' || lv_date_param);
                output_message(' Organization             ');
                output_message(' Legal Entity Id          ');
                output_message(' Receivables Activity     ');
                output_message(' Payment Method           ');
                output_message(' NSF Handling             ');
                output_message(' Display Debug            ');
                output_message(' Debug Path               ');
                output_message(' Debug File               ');
                apps.fnd_global.apps_initialize(user_id => fnd_profile.value('USER_ID'),resp_id => fnd_profile.value('RESP_ID'),resp_appl_id => fnd_profile
.value('RESP_APPL_ID'),security_group_id => 0);

                lv_req_id := fnd_request.submit_request(application => 'CE',program => 'ARPLABIM',description => 'Program - AutoReconciliation Import',start_time
=> SYSDATE,sub_request => false,argument1 => 'IMPORT',argument2 => lv_gbankbranchparid,argument3 => '',argument4 => '',argument5 => '',argument6
=> '',argument7 => '',argument8 => lv_date_param,argument9 => '',argument10 => '',argument11 => '',argument12 => '',argument13 => '',argument14 => 'N',argument15 => '',argument16 => '');

                COMMIT;
                IF
                    lv_req_id = 0
                THEN
                    output_message('Concurrent request failed to submit ');
                    lv_msg := 'Concurrent request failed to submit ';
                    utl_file.fclose(lv_sfile);
                ELSE
                    output_message('Successfully Submitted the Concurrent Request. Request id :' || lv_req_id);
                END IF;

                IF
                    lv_req_id > 0
                THEN
                    LOOP
 --
      --To make process execution to wait for 1st program to complete
      --
                        lv_req_return_status := fnd_concurrent.wait_for_request(request_id => lv_req_id,INTERVAL => 5 --interval Number of seconds to wait between checks
                       ,max_wait => 60 --Maximum number of seconds to wait for the request completion
                                             -- out arguments
                       ,phase => lv_c_phase,status => lv_c_status,dev_phase => lv_c_dev_phase,dev_status => lv_c_dev_status,message => lv_c_message);

                        EXIT WHEN upper(lv_c_phase) = 'COMPLETED' OR upper(lv_c_status) IN (
                            'CANCELLED',
                            'ERROR',
                            'TERMINATED'
                        );

                    END LOOP;
    --
    --

                    IF
                        upper(lv_c_phase) = 'COMPLETED' AND upper(lv_c_status) = 'ERROR'
                    THEN
                        output_message('The Bank Statement Import completed in error. Oracle request id: '
                                         || lv_req_id
                                         || ' '
                                         || sqlerrm);
                    ELSIF upper(lv_c_phase) = 'COMPLETED' AND upper(lv_c_status) = 'NORMAL' THEN
                        dbms_output.put_line('The XX_PROGRAM_1 request successful for request id: ' || lv_req_id);
                        output_message('The Bank Statement Import request successful for request id: ' || lv_req_id);
                    END IF;

                END IF;

            EXCEPTION
                WHEN OTHERS THEN

                    output_message('Error While Submitting Concurrent Request '
                                     || TO_CHAR(sqlcode)
                                     || '-'
                                     || sqlerrm);
                    utl_file.fclose(lv_sfile);
            END;

        END IF;

        output_message('End of the concurrent');
        utl_file.fclose(lv_sfile);
    END read_bank_st;

END ce_bank_sta_pkg;