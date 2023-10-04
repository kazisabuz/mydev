/* Formatted on 10/4/2021 4:44:04 PM (QP5 v5.149.1003.31008) */
INSERT INTO AUTOPOST_TRAN
   SELECT 1 BATCH_SL,
          ROWNUM LEG_SL,
          '30-sep-2021' TRAN_DATE,
          '30-sep-2021' VALUE_DATE,
          1 SUPP_TRAN,
          ACNTS_BRN_CODE BRN_CODE,
          ACNTS_BRN_CODE ACING_BRN_CODE,
          'D' DR_CR,
          LNPRDAC_INT_SUSP_GL GLACC_CODE,
          NULL INT_AC_NO,
          NULL CONT_NO,
          'BDT' CURR_CODE,
          ABS (LOANIA_INT_AMT_RND) AC_AMOUNT,
          ABS (LOANIA_INT_AMT_RND) BC_AMOUNT,
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
          'Accrual reversal for sep,2021' LEG_NARRATION,
          'Accrual reversal for sep,2021' BATCH_NARRATION,
          'INTELECT' USER_ID,
          NULL TERMINAL_ID,
          NULL PROCESSED,
          NULL BATCH_NO,
          NULL ERR_MSG,
          NULL DEPT_CODE
     FROM (  SELECT ACNTS_BRN_CODE,
                    LNPRDAC_INT_SUSP_GL,
                    SUM (LOANIA_INT_AMT_RND) LOANIA_INT_AMT_RND
               FROM ACC_TF,
                    loania,
                    acnts,
                    lnprodacpm
              WHERE     LOANIA_ACNT_NUM = INTERNAL_NUMBER
                    AND LOANIA_ENTITY_NUM = 1
                    AND LOANIA_BRN_CODE = 1024
                    AND ACNTS_INTERNAL_ACNUM = INTERNAL_NUMBER
                    AND LOANIA_VALUE_DATE >= '01-jul-2021'
                    AND ACNTS_ENTITY_NUM = 1
                    AND ACNTS_BRN_CODE = 1024
                    AND ACNTS_PROD_CODE = LNPRDAC_PROD_CODE
           GROUP BY ACNTS_BRN_CODE,
                    LNPRDAC_INT_SUSP_GL )
   UNION ALL
   SELECT 1 BATCH_SL,
          ROWNUM + 4 LEG_SL,
          '30-sep-2021' TRAN_DATE,
          '30-sep-2021' VALUE_DATE,
          1 SUPP_TRAN,
          ACNTS_BRN_CODE BRN_CODE,
          ACNTS_BRN_CODE ACING_BRN_CODE,
          'C' DR_CR,
          LNPRDAC_INT_ACCR_GL GLACC_CODE,
          NULL INT_AC_NO,
          NULL CONT_NO,
          'BDT' CURR_CODE,
          ABS (LOANIA_INT_AMT_RND) AC_AMOUNT,
          ABS (LOANIA_INT_AMT_RND) BC_AMOUNT,
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
          'Accrual reversal for sep,2021' LEG_NARRATION,
          'Accrual reversal for sep,2021' BATCH_NARRATION,
          'INTELECT' USER_ID,
          NULL TERMINAL_ID,
          NULL PROCESSED,
          NULL BATCH_NO,
          NULL ERR_MSG,
          NULL DEPT_CODE
     FROM (  SELECT ACNTS_BRN_CODE,
                    LNPRDAC_INT_INCOME_GL,
                    LNPRDAC_INT_ACCR_GL,
                    SUM (LOANIA_INT_AMT_RND) LOANIA_INT_AMT_RND
               FROM ACC_TF,
                    loania,
                    acnts,
                    lnprodacpm
              WHERE     LOANIA_ACNT_NUM = INTERNAL_NUMBER
                    AND LOANIA_ENTITY_NUM = 1
                    AND LOANIA_BRN_CODE = 1024
                    AND ACNTS_INTERNAL_ACNUM = INTERNAL_NUMBER
                    AND LOANIA_VALUE_DATE >= '01-jul-2021'
                    AND ACNTS_ENTITY_NUM = 1
                    AND ACNTS_BRN_CODE = 1024
                    AND ACNTS_PROD_CODE = LNPRDAC_PROD_CODE
           GROUP BY ACNTS_BRN_CODE,
                    LNPRDAC_INT_INCOME_GL,
                    LNPRDAC_INT_ACCR_Gl
                    HAVING SUM (LOANIA_INT_AMT_RND) <> 0);

EXEC    SP_AUTO_SCRIPT_TRAN;


DELETE FROM loaniadtl
      WHERE (LOANIADTL_ENTITY_NUM,
             LOANIADTL_BRN_CODE,
             LOANIADTL_ACNT_NUM,
             LOANIADTL_VALUE_DATE) IN
               (SELECT LOANIA_ENTITY_NUM,
                       LOANIA_BRN_CODE,
                       LOANIA_ACNT_NUM,
                       LOANIA_VALUE_DATE
                  FROM ACC_TF, loania
                 WHERE     LOANIA_ACNT_NUM = INTERNAL_NUMBER
                       AND LOANIA_ENTITY_NUM = 1
                       AND LOANIA_BRN_CODE = 1024
                       AND LOANIA_VALUE_DATE >= '01-jul-2021');



DELETE FROM loania
      WHERE (LOANIA_ENTITY_NUM,
             LOANIA_BRN_CODE,
             LOANIA_ACNT_NUM,
             LOANIA_VALUE_DATE) IN
               (SELECT LOANIA_ENTITY_NUM,
                       LOANIA_BRN_CODE,
                       LOANIA_ACNT_NUM,
                       LOANIA_VALUE_DATE
                  FROM ACC_TF, loania
                 WHERE     LOANIA_ACNT_NUM = INTERNAL_NUMBER
                       AND LOANIA_ENTITY_NUM = 1
                       AND LOANIA_BRN_CODE = 1024
                       AND LOANIA_VALUE_DATE >= '01-jul-2021');

UPDATE loanacnts
   SET LNACNT_INT_APPLIED_UPTO_DATE = '30-jun-2021',
       LNACNT_INT_ACCR_UPTO = '30-jun-2021',
       LNACNT_PA_ACCR_POSTED_UPTO = '30-jun-2021',
       LNACNT_RTMP_ACCURED_UPTO = NULL,
       LNACNT_RTMP_PROCESS_DATE = NULL
 WHERE LNACNT_INTERNAL_ACNUM IN (SELECT INTERNAL_NUMBER FROM acc_tf)
       AND LNACNT_ENTITY_NUM = 1;



DELETE FROM loaniadly
      WHERE RTMPLNIA_ACNT_NUM IN (SELECT INTERNAL_NUMBER FROM acc_tf);

DELETE FROM LNINTAPPL
      WHERE LNINTAPPL_ACNT_NUM IN (SELECT INTERNAL_NUMBER FROM acc_tf)
            AND LNINTAPPL_ENTITY_NUM = 1
            AND LNINTAPPL_APPL_DATE =
                   TO_DATE ('09/30/2021 00:00:00', 'MM/DD/YYYY HH24:MI:SS');

UPDATE tran2021
   SET TRAN_AMOUNT = 0, TRAN_BASE_CURR_EQ_AMT = 0
 WHERE TRAN_ENTITY_NUM = 1
       AND TRAN_DATE_OF_TRAN =
              TO_DATE ('09/30/2021 00:00:00', 'MM/DD/YYYY HH24:MI:SS')
       AND TRAN_BRN_CODE = 1024
       AND TRAN_BATCH_NUMBER = 182
       AND TRAN_INTERNAL_ACNUM IN (SELECT INTERNAL_NUMBER FROM acc_tf);

  SELECT TRAN_DB_CR_FLG, SUM (TRAN_AMOUNT)
    FROM tran2021
   WHERE TRAN_ENTITY_NUM = 1
         AND TRAN_DATE_OF_TRAN =
                TO_DATE ('09/30/2021 00:00:00', 'MM/DD/YYYY HH24:MI:SS')
         AND TRAN_BRN_CODE = 1024
         AND TRAN_BATCH_NUMBER = 182
-- AND TRAN_INTERNAL_ACNUM IN (SELECT INTERNAL_NUMBER FROM acc_tf)
GROUP BY TRAN_DB_CR_FLG;



  SELECT ACNTS_BRN_CODE,
         LNPRDAC_INT_INCOME_GL,
         LNPRDAC_INT_ACCR_GL,
         SUM (DEPOSIT_AMOUNT) DEPOSIT_AMOUNT
    FROM acc5, acnts, lnprodacpm
   WHERE     ACNTS_INTERNAL_ACNUM = acc_no
         AND ACNTS_ENTITY_NUM = 1
         AND ACNTS_BRN_CODE = 1024
         AND ACNTS_PROD_CODE = LNPRDAC_PROD_CODE
GROUP BY ACNTS_BRN_CODE, LNPRDAC_INT_INCOME_GL, LNPRDAC_INT_ACCR_Gl;

UPDATE tranadv2021
   SET TRANADV_INTRD_AC_AMT = 0, TRANADV_INTRD_BC_AMT = 0
 WHERE (TRANADV_ENTITY_NUM,
        TRANADV_BRN_CODE,
        TRANADV_DATE_OF_TRAN,
        TRANADV_BATCH_NUMBER,
        TRANADV_BATCH_SL_NUM) IN
          (SELECT TRAN_ENTITY_NUM,
                  TRAN_BRN_CODE,
                  TRAN_DATE_OF_TRAN,
                  TRAN_BATCH_NUMBER,
                  TRAN_BATCH_SL_NUM
             FROM tran2021
            WHERE TRAN_ENTITY_NUM = 1
                  AND TRAN_DATE_OF_TRAN =
                         TO_DATE ('09/30/2021 00:00:00',
                                  'MM/DD/YYYY HH24:MI:SS')
                  AND TRAN_BRN_CODE = 1024
                  AND TRAN_BATCH_NUMBER = 182
                  AND TRAN_AMOUNT = 0);


INSERT INTO ACTUAL_ACCOUNT_UPDATE (IACLINK_INTERNAL_ACNUM, ACTUAL_ACNUM)
   SELECT INTERNAL_NUMBER, '' FROM ACC_TF;
 
---IF INTEREST GOES IN SUSPENSE
   
DELETE FROM  LNSUSPLED
   WHERE LNSUSP_ENTITY_NUM=1
   AND  LNSUSP_ACNT_NUM IN ( SELECT INTERNAL_NUMBER FROM ACC_TF)
   AND LNSUSP_TRAN_DATE='30-SEP-2021';
  -- AND LNSUSP_DB_CR_FLG='C'
   --AND LNSUSP_AMOUNT<1
   
 
BEGIN
   FOR IDX
      IN (  SELECT LNSUSP_ACNT_NUM,
                   SUM (CREDIT_BAL) - SUM (DEBIT_BAL) SUSP_BAL,
                   SUM (CREDIT_BAL) CREDIT_SUM,
                   SUM (DEBIT_BAL) DEBIT_SUM
              FROM (SELECT LNSUSP_ACNT_NUM,
                           CASE
                              WHEN LNSUSP_DB_CR_FLG = 'C' THEN LNSUSP_AMOUNT
                              ELSE 0
                           END
                              CREDIT_BAL,
                           CASE
                              WHEN LNSUSP_DB_CR_FLG = 'D' THEN LNSUSP_AMOUNT
                              ELSE 0
                           END
                              DEBIT_BAL
                      FROM LNSUSPLED
                     WHERE     LNSUSP_ENTITY_NUM = 1
                           AND LNSUSP_ACNT_NUM IN
                                  (SELECT IACLINK_INTERNAL_ACNUM
                                     FROM acc_TF, iaclink
                                    WHERE     ACCNUMBER = IACLINK_ACTUAL_ACNUM
                                          AND IACLINK_ENTITY_NUM = 1))
          GROUP BY LNSUSP_ACNT_NUM
          ORDER BY LNSUSP_ACNT_NUM)
   LOOP
      UPDATE LNSUSPBAL
         SET LNSUSPBAL_SUSP_BAL = IDX.SUSP_BAL,
             LNSUSPBAL_SUSP_DB_SUM = IDX.DEBIT_SUM,
             LNSUSPBAL_SUSP_CR_SUM = IDX.CREDIT_SUM,
             LNSUSPBAL_INT_BAL = IDX.SUSP_BAL
       WHERE     LNSUSPBAL_ENTITY_NUM = 1
             AND LNSUSPBAL_ACNT_NUM = IDX.LNSUSP_ACNT_NUM;
   END LOOP;
END;  