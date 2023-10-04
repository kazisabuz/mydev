insert into  tab_acnt_bal
WITH ACCOUNT_WISE_TOTAL_BALANCE
     AS ( ------------------- FORMONTHS WISE TRANSACTION SUMMATION --------------------
         SELECT   TRAN_GLACC_CODE,
                  SUM (CREDIT_AMOUNT) ACCOUNT_WISE_CREDIT_SUM,
                  SUM (DEBIT_AMOUNT) ACCOUNT_WISE_DEBIT_SUM,
                  SUM (CREDIT_TRANSACTION) ACCOUNT_WISE_CREDIT_TRAN,
                  SUM (DEBIT_TRANSACTION) ACCOUNT_WISE_DEBIT_TRAN
             FROM ( (SELECT /*+ FULL(TA) PARALLEL(TA, DEFAULT,DEFAULT)  PARALLEL(TR, DEFAULT,DEFAULT) */
                           TR.TRAN_GLACC_CODE,
                            TR.TRAN_DATE_OF_TRAN,
                            TRAN_BATCH_NUMBER,
                            TRAN_BATCH_SL_NUM,
                            TRAN_DB_CR_FLG,
                            TRAN_AMOUNT,
                            (CASE
                                WHEN TRAN_DB_CR_FLG = 'D'
                                THEN
                                   NVL (TRAN_AMOUNT, 0)
                                ELSE
                                   0
                             END)
                               DEBIT_AMOUNT,
                            (CASE
                                WHEN TRAN_DB_CR_FLG = 'C'
                                THEN
                                   NVL (TRAN_AMOUNT, 0)
                                ELSE
                                   0
                             END)
                               CREDIT_AMOUNT,
                            (CASE WHEN TRAN_DB_CR_FLG = 'C' THEN 1 ELSE 0 END)
                               CREDIT_TRANSACTION,
                            (CASE WHEN TRAN_DB_CR_FLG = 'D' THEN 1 ELSE 0 END)
                               DEBIT_TRANSACTION
                       FROM TRAN2014 TR
                      WHERE     TR.TRAN_AUTH_ON IS NOT NULL
                     and  TRAN_ENTITY_NUM=1
                     and  TRAN_GLACC_CODE <>0
                            and TRAN_ACING_BRN_CODE =8110
                           --- AND TR.TRAN_INTERNAL_ACNUM <> 0
                            AND TR.TRAN_AMOUNT <> 0
                     UNION ALL
                     SELECT /*+ FULL(TA) PARALLEL(TA, DEFAULT,DEFAULT)  PARALLEL(TR, DEFAULT,DEFAULT) */
                           TR.TRAN_GLACC_CODE,
                            TR.TRAN_DATE_OF_TRAN,
                            TRAN_BATCH_NUMBER,
                            TRAN_BATCH_SL_NUM,
                            TRAN_DB_CR_FLG,
                            TRAN_AMOUNT,
                            (CASE
                                WHEN TRAN_DB_CR_FLG = 'D'
                                THEN
                                   NVL (TRAN_AMOUNT, 0)
                                ELSE
                                   0
                             END)
                               DEBIT_AMOUNT,
                            (CASE
                                WHEN TRAN_DB_CR_FLG = 'C'
                                THEN
                                   NVL (TRAN_AMOUNT, 0)
                                ELSE
                                   0
                             END)
                               CREDIT_AMOUNT,
                            (CASE WHEN TRAN_DB_CR_FLG = 'C' THEN 1 ELSE 0 END)
                               CREDIT_TRANSACTION,
                            (CASE WHEN TRAN_DB_CR_FLG = 'D' THEN 1 ELSE 0 END)
                               DEBIT_TRANSACTION
                       FROM TRAN2015 TR
                      WHERE     TR.TRAN_AUTH_ON IS NOT NULL
                             and TRAN_ACING_BRN_CODE =8110
                           and  TRAN_ENTITY_NUM=1
                     and  TRAN_GLACC_CODE <>0
                            AND TR.TRAN_AMOUNT <> 0
                     UNION ALL
                     SELECT /*+ FULL(TA) PARALLEL(TA, DEFAULT,DEFAULT)  PARALLEL(TR, DEFAULT,DEFAULT) */
                           TR.TRAN_GLACC_CODE,
                            TR.TRAN_DATE_OF_TRAN,
                            TRAN_BATCH_NUMBER,
                            TRAN_BATCH_SL_NUM,
                            TRAN_DB_CR_FLG,
                            TRAN_AMOUNT,
                            (CASE
                                WHEN TRAN_DB_CR_FLG = 'D'
                                THEN
                                   NVL (TRAN_AMOUNT, 0)
                                ELSE
                                   0
                             END)
                               DEBIT_AMOUNT,
                            (CASE
                                WHEN TRAN_DB_CR_FLG = 'C'
                                THEN
                                   NVL (TRAN_AMOUNT, 0)
                                ELSE
                                   0
                             END)
                               CREDIT_AMOUNT,
                            (CASE WHEN TRAN_DB_CR_FLG = 'C' THEN 1 ELSE 0 END)
                               CREDIT_TRANSACTION,
                            (CASE WHEN TRAN_DB_CR_FLG = 'D' THEN 1 ELSE 0 END)
                               DEBIT_TRANSACTION
                       FROM TRAN2016 TR
                      WHERE     TR.TRAN_AUTH_ON IS NOT NULL
                             and TRAN_ACING_BRN_CODE =8110
                           and  TRAN_ENTITY_NUM=1
                     and  TRAN_GLACC_CODE <>0
                            AND TR.TRAN_AMOUNT <> 0
                     UNION ALL
                     SELECT /*+ FULL(TA) PARALLEL(TA, DEFAULT,DEFAULT)  PARALLEL(TR, DEFAULT,DEFAULT) */
                           TR.TRAN_GLACC_CODE,
                            TR.TRAN_DATE_OF_TRAN,
                            TRAN_BATCH_NUMBER,
                            TRAN_BATCH_SL_NUM,
                            TRAN_DB_CR_FLG,
                            TRAN_AMOUNT,
                            (CASE
                                WHEN TRAN_DB_CR_FLG = 'D'
                                THEN
                                   NVL (TRAN_AMOUNT, 0)
                                ELSE
                                   0
                             END)
                               DEBIT_AMOUNT,
                            (CASE
                                WHEN TRAN_DB_CR_FLG = 'C'
                                THEN
                                   NVL (TRAN_AMOUNT, 0)
                                ELSE
                                   0
                             END)
                               CREDIT_AMOUNT,
                            (CASE WHEN TRAN_DB_CR_FLG = 'C' THEN 1 ELSE 0 END)
                               CREDIT_TRANSACTION,
                            (CASE WHEN TRAN_DB_CR_FLG = 'D' THEN 1 ELSE 0 END)
                               DEBIT_TRANSACTION
                       FROM TRAN2017 TR
                      WHERE     TR.TRAN_AUTH_ON IS NOT NULL
                            and TRAN_ACING_BRN_CODE =8110
                           and  TRAN_ENTITY_NUM=1
                     and  TRAN_GLACC_CODE <>0
                            AND TR.TRAN_AMOUNT <> 0))
         GROUP BY TRAN_GLACC_CODE)
SELECT TT.TRAN_GLACC_CODE,
       TT.ACCOUNT_WISE_CREDIT_SUM,
       TT.ACCOUNT_WISE_DEBIT_SUM,
       ACCOUNT_WISE_CREDIT_SUM - ACCOUNT_WISE_DEBIT_SUM CURRENT_BALANCE
  FROM ACCOUNT_WISE_TOTAL_BALANCE TT;
  
  
  
  
SELECT TRAN_INTERNAL_ACNUM,
 ACCOUNT_WISE_CREDIT_SUM - GLBBAL_AC_CUR_CR_SUM ACNTBAL_AC_CUR_CR_SUM,
       ACCOUNT_WISE_DEBIT_SUM - GLBBAL_AC_CUR_DB_SUM ACNTBAL_AC_CUR_DB_SUM,
       CURRENT_BALANCE - GLBBAL_BC_BAL CURRENT_BALANCE
  FROM tab_acnt_bal, glbbal
 WHERE     TRAN_INTERNAL_ACNUM = GLBBAL_BC_BAL 
and GLBBAL_ENTITY_NUM = 1
and (ACCOUNT_WISE_CREDIT_SUM - GLBBAL_AC_CUR_CR_SUM <> 0 
or ACCOUNT_WISE_DEBIT_SUM - GLBBAL_AC_CUR_DB_SUM <> 0 or
 CURRENT_BALANCE - GLBBAL_AC_BAL <> 0)
