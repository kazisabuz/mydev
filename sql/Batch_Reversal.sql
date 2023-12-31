/* Formatted on 4/27/2022 11:11:51 AM (QP5 v5.252.13127.32867) */
INSERT INTO AUTOPOST_TRAN
   SELECT DENSE_RANK () OVER (ORDER BY TRAN_BRN_CODE) BATCH_SL,
          ROW_NUMBER () OVER (PARTITION BY TRAN_BRN_CODE ORDER BY TRAN_BRN_CODE) LEG_SL,
          NULL TRAN_DATE,
          NULL VALUE_DATE,
          NULL SUPP_TRAN,
       TRAN_BRN_CODE   BRN_CODE,
         TRAN_ACING_BRN_CODE ACING_BRN_CODE,
          CASE
             WHEN TRAN_DB_CR_FLG = 'D' THEN 'C'
             WHEN TRAN_DB_CR_FLG = 'C' THEN 'D'
             ELSE NULL
          END
             DR_CR,
         TRAN_GLACC_CODE GLACC_CODE,
      TRAN_INTERNAL_ACNUM    INT_AC_NO,
         NULL CONT_NO,
     TRAN_CURR_CODE    CURR_CODE,
        TRAN_AMOUNT  AC_AMOUNT,
          TRAN_AMOUNT BC_AMOUNT,
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
          TRAN_NARR_DTL1 ||' '||TRAN_NARR_DTL2 ||' '|| TRAN_NARR_DTL3 NARRATION,
           TRAN_NARR_DTL1 ||' '||TRAN_NARR_DTL2 ||' '|| TRAN_NARR_DTL3 NARRATION,
          'INTELECT' USER_ID,
          NULL TERMINAL_ID,
          NULL PROCESSED,
          NULL BATCH_NO,
          NULL ERR_MSG,
          NULL DEPT_CODE
     FROM tran2021
    WHERE     TRAN_ENTITY_NUM = 1
          AND TRAN_BRN_CODE = 10157
          AND TRAN_DATE_OF_TRAN = '28-DEC-2021'
          AND TRAN_BATCH_NUMBER IN (148, 149)