-------------------- Supplementary transaction     ---------------                  
DELETE FROM AUTOPOST_TRAN ;

COMMIT ;

INSERT INTO AUTOPOST_TRAN
SELECT DENSE_RANK() OVER ( ORDER BY TRAN_BRN_CODE) BATCH_SL,
       ROW_NUMBER() OVER ( PARTITION BY TRAN_BRN_CODE ORDER BY TRAN_BRN_CODE) LEG_SL,
       TRAN_DATE_OF_TRAN TRAN_DATE,
       TRAN_DATE_OF_TRAN VALUE_DATE,
       '1' SUPP_TRAN,
       TRAN_BRN_CODE BRN_CODE,
       TRAN_BRN_CODE ACING_BRN_CODE,
       DECODE(TRAN_DB_CR_FLG, 'D', 'C', 'D') DR_CR,
       TRAN_GLACC_CODE GLACC_CODE,
       0 INT_AC_NO,
       0 CONT_NO,
       TRAN_CURR_CODE CURR_CODE,
       SUM (TRAN_AMOUNT) AC_AMOUNT,
       SUM (TRAN_AMOUNT) BC_AMOUNT,
       NULL PRINCIPAL,
       NULL INTEREST,
       NULL CHARGE,
       NULL INST_PREFIX,
       NULL INST_NUM,
       NULL INST_DATE,
       NULL IBR_GL,
       NULL ORIG_RESP,
       NULL CONT_BRN_CODE,
       NULL ADV_NUM,
       NULL ADV_DATE,
       NULL IBR_CODE,
       NULL CAN_IBR_CODE,
       'TDS recovery correction' LEG_NARRATION,
       'TDS recovery correction' BATCH_NARRATION,
       'INTELECT' USER_ID,
       NULL TERMINAL_ID,
       NULL PROCESSED,
       NULL BATCH_NO,
       NULL ERR_MSG
  FROM TRAN2018
   WHERE     TRAN_ENTITY_NUM = 1
         AND TRAN_DATE_OF_TRAN = '31-may-2018'
         AND TRAN_NARR_DTL1 = 'TDS Recovered on 31-MAY-18 for '
         AND TRAN_ENTD_BY = '37413'
GROUP BY TRAN_BRN_CODE, TRAN_GLACC_CODE, TRAN_DB_CR_FLG, TRAN_DATE_OF_TRAN, TRAN_CURR_CODE
ORDER BY TRAN_BRN_CODE, TRAN_GLACC_CODE;

COMMIT ;

EXEC SP_AUTO_SCRIPT_TRAN ;


Delete FROM DEPIA p
 WHERE p.rowid in (select d.rowid
                     from depia d, pbdcontract p
                    where d.depia_entity_num = 1
                      and p.pbdcont_entity_num = 1
                      and d.depia_brn_code = p.pbdcont_brn_code
                      and d.depia_internal_acnum = p.pbdcont_dep_ac_num
                      and d.depia_contract_num = p.pbdcont_cont_num
                      and p.pbdcont_closure_date is null
                      and d.depia_contract_num <> 0
                      and d.depia_date_of_entry = '31-may-2018'
                      and d.depia_entry_type = 'TD'
                      and p.pbdcont_prod_code in (1075, 1078)) ;
                      
COMMIT ;
