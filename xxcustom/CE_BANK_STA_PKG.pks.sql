create or replace PACKAGE         "CE_BANK_STA_PKG" AS

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

--****************************************************************************
--PROCEDURE outlog_c: Procedure that puts line in the file log of the concurrent program.          
--****************************************************************************
PROCEDURE outlog_c (v_message IN VARCHAR2);

--****************************************************************************
--PROCEDURE output_c: procedure that has put line in the output file of the concurrent program.
--****************************************************************************
PROCEDURE output_c (v_message IN VARCHAR2);


--****************************************************************************
-- PROCEDURE read_bank_st: This procedure insert the corresponding fields separated by a pipe from an archive .txt
--****************************************************************************
PROCEDURE read_bank_st ( ERRBUF OUT VARCHAR2, RETCODE OUT NUMBER, lv_nom_file IN VARCHAR2, p_bank_name IN VARCHAR2 );

END CE_BANK_STA_PKG;


read_bank_st