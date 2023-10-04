/* Formatted on 9/8/2022 4:43:43 PM (QP5 v5.388) */
SELECT facno (1, LNINSTRECV_INTERNAL_ACNUM)
           loan_account,
       facno (1, LNINSTRECV_RECOV_FROM_ACNT)
           CASA_ACCOUNT,
       (SELECT LNOD_OD_AMT
          FROM LNOD
         WHERE     LNOD_ENTITY_NUM = 1
               AND LNOD_INTERNAL_ACNUM = LNINSTRECV_INTERNAL_ACNUM)
           od_amount,
       LNINSTRECV_INSTALLMENT_AMT,
       LNINSTRECV_REPAY_AMT
           RECOVERY_AMOUNT,
       FN_GET_ASON_ACBAL (1,
                          LNINSTRECV_RECOV_FROM_ACNT,
                          'BDT',
                          '30-OCT-2022',
                          '31-OCT-2022')
           BALANCE_ON_PROCESS_TIME,POST_TRAN_BRN, POST_TRAN_DATE, POST_TRAN_BATCH_NUM
  FROM LNINSTRECV
 WHERE LNINSTRECV_REPAY_DATE = '24-JUL-2023' and LNINSTRECV_ACNT_BRN_CODE=48124;

------------------------------------------------------------------
/* Formatted on 4/2/2023 4:01:41 PM (QP5 v5.388) */
SELECT facno (1, LNINSTRECV_INTERNAL_ACNUM)
           loan_account,
       facno (1, LNINSTRECV_RECOV_FROM_ACNT),
       FN_GET_OD_AMT (1,
                      LNINSTRECV_INTERNAL_ACNUM,
                      '01-apr-2023',
                      '02-apr-2023')
           od_amount,
       (SELECT LNOD_OD_AMT
          FROM LNOD
         WHERE     LNOD_ENTITY_NUM = 1
               AND LNOD_INTERNAL_ACNUM = LNINSTRECV_INTERNAL_ACNUM)
           od_amount_tabl,
       LNINSTRECV_INSTALLMENT_AMT,
       LNINSTRECV_REPAY_AMT
           RECOVERY_AMOUNT,
       LNINSTRECV_PRIN_RECOV_AMT,
       LNINSTRECV_INT_RECOV_AMT,
       LNINSTRECV_CHG_RECOV_AMT,
       FN_GET_ASON_ACBAL (1,
                          LNINSTRECV_RECOV_FROM_ACNT,
                          'BDT',
                          '31-MAR-2023',
                          '31-MAR-2023')
           BALANCE_ON_PROCESS_TIME,
       POST_TRAN_BRN,
       POST_TRAN_DATE,
       POST_TRAN_BATCH_NUM
  FROM LNINSTRECV
 WHERE     LNINSTRECV_REPAY_DATE = '02-apr-2023'
       AND LNINSTRECV_ACNT_BRN_CODE = 56010;
-- and LNINSTRECV_INTERNAL_ACNUM=15601000002182;

-------------------------------------------------
/* Formatted on 9/20/2023 11:59:14 AM (QP5 v5.388) */
SELECT *
  FROM tran2023
 WHERE     (TRAN_INTERNAL_ACNUM,
            TRAN_BRN_CODE,
            TRAN_DATE_OF_TRAN,
            TRAN_BATCH_NUMBER,
            TRAN_AMOUNT) IN
               (SELECT LNINSTRECV_INTERNAL_ACNUM,
                       POST_TRAN_BRN,
                       POST_TRAN_DATE,
                       POST_TRAN_BATCH_NUM,
                       LNINSTRECV_REPAY_AMT
                 FROM LNINSTRECV, iaclink, acc4
                WHERE     IACLINK_ENTITY_NUM = 1
                      AND IACLINK_INTERNAL_ACNUM = LNINSTRECV_INTERNAL_ACNUM
                      AND LNINSTRECV_ENTITY_NUM = 1
                      AND IACLINK_ACTUAL_ACNUM = acc_no
                      AND POST_TRAN_DATE = '02-apr-2023')
       AND TRAN_ENTITY_NUM = 1;
       
       
/* Formatted on 9/20/2023 11:59:14 AM (QP5 v5.388) */
SELECT *
  FROM tran2023
 WHERE     (TRAN_INTERNAL_ACNUM,
            TRAN_AMOUNT) IN
               (SELECT LNINSTRECV_INTERNAL_ACNUM,
                        LNINSTRECV_REPAY_AMT
                 FROM LNINSTRECV, iaclink, acc4,acnts
                WHERE     IACLINK_ENTITY_NUM = 1
                      AND IACLINK_INTERNAL_ACNUM = LNINSTRECV_INTERNAL_ACNUM
                      AND LNINSTRECV_ENTITY_NUM = 1
                      and ACNTS_ENTITY_NUM=1
                      and ACNTS_INTERNAL_ACNUM=IACLINK_INTERNAL_ACNUM
                      and ACNTS_CLOSURE_DATE is null
                      AND IACLINK_ACTUAL_ACNUM = acc_no
                      AND POST_TRAN_DATE = '02-apr-2023')
       AND TRAN_ENTITY_NUM = 1
       and TRAN_DATE_OF_TRAN>='02-apr-2023'
       and TRAN_DB_CR_FLG='D';
       
--------------------------------------------------------------






/* Formatted on 12/12/2022 1:56:48 PM (QP5 v5.388) */
SELECT facno (1, PBDCONT_DEP_AC_NUM)                                      RD_ACCOUNT,
       FACNO (1, PBDCONT_INST_REC_FROM_AC)                                CASA_ACCOUNT,
       CASE
           WHEN PBDCONT_AC_DEP_AMT = 0 THEN PBDCONT_BC_DEP_AMT
           WHEN PBDCONT_BC_DEP_AMT = 0 THEN PBDCONT_AC_DEP_AMT
           ELSE PBDCONT_BC_DEP_AMT
       END                                                                istallment_amount,
       0                                                                  RECOVERY_AMOUNT,
       FN_GET_ASON_ACBAL (1,
                          PBDCONT_INST_REC_FROM_AC,
                          'BDT',
                          '12-DEC-2022',
                          '12-DEC-2022')                                  BALANCE_ON_PROCESS_TIME,
       (SELECT S.ACNTS_CLOSURE_DATE
         FROM ACNTS S
        WHERE     S.ACNTS_ENTITY_NUM = V_ENTITY_NUM
              AND S.ACNTS_INTERNAL_ACNUM = P.PBDCONT_INST_REC_FROM_AC)    REC_ACNT_CLOSE_DATE
  FROM PBDCONTRACT P, DEPPROD D
 WHERE     ACNTS_ENTITY_NUM = 1
       AND ACNTS_INTERNAL_ACNUM = PBDCONT_INST_REC_FROM_AC
       --AND PBDCONT_CLOSURE_DATE IS NULL
       AND PBDCONT_CLOSURE_DATE IS NOT NULL
       AND NVL (TRIM (D.DEPPR_TYPE_OF_DEP), '0') = '3'
       AND D.DEPPR_PROD_CODE = P.PBDCONT_PROD_CODE
       AND PBDCONT_ENTITY_NUM = 1;