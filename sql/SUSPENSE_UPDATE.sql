/* Formatted on 8/12/2020 2:00:09 PM (QP5 v5.227.12220.39754) */
INSERT INTO LNSUSPLED
   SELECT 1 LNSUSP_ENTITY_NUM,
          IACLINK_INTERNAL_ACNUM LNSUSP_ACNT_NUM,
          '31-dec-2021' LNSUSP_TRAN_DATE,
          rownum LNSUSP_SL_NUM,
          '31-dec-2021' LNSUSP_VALUE_DATE,
          2 LNSUSP_ENTRY_TYPE,
          'D' LNSUSP_DB_CR_FLG,
          'BDT' LNSUSP_CURR_CODE,
          REPAY_AMT LNSUSP_AMOUNT,
          REPAY_AMT LNSUSP_INT_AMT,
          0 LNSUSP_CHGS_AMT,
          '1-JUL-2021' LNSUSP_INT_FROM_DATE,
          '31-DEC-2021' LNSUSP_INT_UPTO_DATE,
          'By Interest Accrual' LNSUSP_REMARKS1,
          'MAIL|Sat 1/22/2022 3:52 PM' LNSUSP_REMARKS2,
          null LNSUSP_REMARKS3,
          'A' LNSUSP_AUTO_MANUAL,
          null LNSUSP_RECOV_THRU,
          null LNSUSP_SRC_REF_KEY,
          'INTELECT' LNSUSP_ENTD_BY,
          SYSDATE LNSUSP_ENTD_ON,
          'INTELECT' LNSUSP_LAST_MOD_BY,
          SYSDATE LNSUSP_LAST_MOD_ON,
          'INTELECT' LNSUSP_AUTH_BY,
          SYSDATE LNSUSP_AUTH_ON,
          NULL TBA_MAIN_KEY
     FROM acc4, iaclink
    WHERE acc_no = IACLINK_ACTUAL_ACNUM AND IACLINK_ENTITY_NUM = 1 ;


 ------------------------

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
                           AND LNSUSP_ACNT_NUM IN (10002600043730,
10002600043731,
10002600050608,
10002600050613,
10002600050614,
10002600050615))
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