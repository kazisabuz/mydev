INSERT INTO AUTOPOST_TRAN
SELECT
      1 BATCH_SL,
      5096+rownum LEG_SL,
    null   TRAN_DATE,
     null  VALUE_DATE,
       null SUPP_TRAN,
     BRANCH_CODE  BRN_CODE,
      26 ACING_BRN_CODE,
     'C'  DR_CR,
     BPO_GL  GLACC_CODE,
     null  INT_AC_NO,
      null CONT_NO,
     'BDT'  CURR_CODE,
      1 AC_AMOUNT,
    1 BC_AMOUNT,
     null  PRINCIPAL,
      null INTEREST,
     null  CHARGE,
      null INST_PREFIX,
     null  INST_NUM,
      null INST_DATE,
     null  IBR_GL,
      null ORIG_RESP,
      null CONT_BRN_CODE,
      null ADV_NUM,
    null   ADV_DATE,
     null  IBR_CODE,
     null  CAN_IBR_CODE,
      'Regarding Off us transaction are not posted in our CBS|mail|Sunday,December 08,2019'    LEG_NARRATION,
      'Regarding Off us transaction are not posted in our CBS|mail|Sunday,December 08,2019'    BATCH_NARRATION,
       'INTELECT'USER_ID,
      NULL TERMINAL_ID,
     NULL  PROCESSED,
     NULL  BATCH_NO,
     NULL  ERR_MSG,
     null DEPT_CODE
  FROM backuptable.ACC2 
  where TRAN_TYPE is not null
  
  
       
UNION ALL 
SELECT
      1 BATCH_SL,
     10+ rownum LEG_SL,
    null   TRAN_DATE,
     null  VALUE_DATE,
       null SUPP_TRAN,
     IACLINK_BRN_CODE  BRN_CODE,
      IACLINK_BRN_CODE ACING_BRN_CODE,
     'C'  DR_CR,
     0  GLACC_CODE,
     IACLINK_INTERNAL_ACNUM  INT_AC_NO,
      null CONT_NO,
     'BDT'  CURR_CODE,
      INST_AMOUNT AC_AMOUNT,
     INST_AMOUNT  BC_AMOUNT,
     NULL  PRINCIPAL,
      null INTEREST,
     INST_AMOUNT  CHARGE,
      null INST_PREFIX,
     null  INST_NUM,
      null INST_DATE,
     null  IBR_GL,
      null ORIG_RESP,
      null CONT_BRN_CODE,
      null ADV_NUM,
    null   ADV_DATE,
     null  IBR_CODE,
     null  CAN_IBR_CODE,
      'Loan Account reversal voucher posting|Issue|24242'    LEG_NARRATION,
      'Loan Account reversal voucher posting|Issue|24242'    BATCH_NARRATION,
       'INTELECT'USER_ID,
      NULL TERMINAL_ID,
     NULL  PROCESSED,
     NULL  BATCH_NO,
     NULL  ERR_MSG
  FROM acc4, IACLINK
 WHERE     IACLINK_ACTUAL_ACNUM = ACC_NO
       AND IACLINK_ENTITY_NUM = 1
       
       