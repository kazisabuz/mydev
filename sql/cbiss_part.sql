/*Patitioning the CBISS table based on the branch code*/
CREATE TABLE CBISS_PART
(
  CBISS_ENTITY_NUM       NUMBER(4)             ,
  CBISS_CLIENT_ACNUM     NUMBER(14)            ,
  CBISS_ISSUE_DATE       DATE              ,
  CBISS_ISSUE_DAY_SL     NUMBER(4)           ,
  CBISS_CBTYPE_CODE      VARCHAR2(3 BYTE),
  CBISS_CHQBK_SIZE       NUMBER(5)              DEFAULT 0,
  CBISS_CHQBK_PREFIX     VARCHAR2(6 BYTE),
  CBISS_FROM_LEAF_NUM    NUMBER(15)             DEFAULT 0,
  CBISS_UPTO_LEAF_NUM    NUMBER(15)             DEFAULT 0,
  CBISS_SELF_TPRTY       CHAR(1 BYTE),
  CBISS_ISSUE_CIF_NUM    NUMBER(12)             DEFAULT 0,
  CBISS_ISSUE_CIF_NAME   VARCHAR2(50 BYTE),
  CBISS_REM1             VARCHAR2(35 BYTE),
  CBISS_REM2             VARCHAR2(35 BYTE),
  CBISS_REM3             VARCHAR2(35 BYTE),
  CBISS_CHGS_AMT         NUMBER(12,3)           DEFAULT 0,
  CBISS_SERVICE_TAX_AMT  NUMBER(12,3)           DEFAULT 0,
  POST_TRAN_BRN          NUMBER(6)              DEFAULT 0,
  POST_TRAN_DATE         DATE,
  POST_TRAN_BATCH_NUM    NUMBER(7)              DEFAULT 0,
  CBISS_REQ_BRN          NUMBER(6)              DEFAULT 0,
  CBISS_REQ_DATE         DATE,
  CBISS_REQ_DAY_SL       NUMBER(5)              DEFAULT 0,
  CBISS_ENTD_BY          VARCHAR2(8 BYTE)   ,
  CBISS_ENTD_ON          DATE               ,
  CBISS_LAST_MOD_BY      VARCHAR2(8 BYTE),
  CBISS_LAST_MOD_ON      DATE,
  CBISS_AUTH_BY          VARCHAR2(8 BYTE),
  CBISS_AUTH_ON          DATE,
  CBISS_REJ_BY           VARCHAR2(8 BYTE),
  CBISS_REJ_ON           DATE,
  CBISS_SYS_CALC_CHG     NUMBER(12,3)           DEFAULT 0,
  CBISS_SYS_CALC_STAX    NUMBER(12,3)           DEFAULT 0,
  CBISS_ISSUE_BRN        NUMBER(6)       
)
     PARTITION BY range (CBISS_ISSUE_BRN)
     INTERVAL (1)
     (PARTITION EMPTY_PART VALUES LESS THAN (1) TABLESPACE TBS_ACNTS_PART1);
     
     
EXEC DBMS_STATS.gather_table_stats(USER, 'CBISS_PART');


BEGIN
  DBMS_REDEFINITION.start_redef_table(
    uname      => USER,        
    orig_table => 'CBISS',
    int_table  => 'CBISS_PART');
END;
/


EXEC DBMS_STATS.gather_table_stats(USER, 'CBISS_PART');


BEGIN
  dbms_redefinition.sync_interim_table(
    uname      => USER,        
    orig_table => 'CBISS',
    int_table  => 'CBISS_PART');
END;
/




/* Formatted on 05/05/2015 4:33:53 PM (QP5 v5.149.1003.31008) */
DECLARE
   l_errors   NUMBER;
BEGIN
   DBMS_REDEFINITION.
    copy_table_dependents (
      uname              => USER,
      orig_table         => 'CBISS',
      int_table          => 'CBISS_PART',
      copy_indexes       => DBMS_REDEFINITION.cons_orig_params,
      copy_triggers      => TRUE,
      copy_constraints   => FALSE,
      copy_privileges    => TRUE,
      ignore_errors      => FALSE,
      num_errors         => l_errors,
      copy_statistics    => FALSE,
      copy_mvlog         => FALSE);

   DBMS_OUTPUT.put_line ('Errors=' || l_errors);
END;
/



BEGIN
  dbms_redefinition.finish_redef_table(
    uname      => USER,        
    orig_table => 'CBISS',
    int_table  => 'CBISS_PART');
END;



EXEC DBMS_STATS.gather_table_stats(USER, 'CBISS');
