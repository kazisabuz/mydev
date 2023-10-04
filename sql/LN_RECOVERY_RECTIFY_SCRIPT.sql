/* Formatted on 6/12/2023 6:28:21 PM (QP5 v5.388) */
ALTER TABLE AUTOPOST_TRAN_TEMP
    ADD (PRINCIPAL NUMBER (18, 2),
         INTEREST NUMBER (18, 2),
         CHARGE NUMBER (18, 2));

INSERT INTO AUTOPOST_TRAN_TEMP
    SELECT 1                      BATCH_SL,
           1                      LEG_SL,
           NULL                   TRAN_DATE,
           NULL                   VALUE_DATE,
           NULL                   SUPP_TRAN,
           TRAN_BRN_CODE          BRN_CODE,
           TRAN_ACING_BRN_CODE    ACING_BRN_CODE,
           'D'                    DR_CR,
           NULL                   GLACC_CODE,
           TRAN_INTERNAL_ACNUM    INT_AC_NO,
           NULL                   CONT_NO,
           TRAN_CURR_CODE         CURR_CODE,
           TRAN_AMOUNT            AC_AMOUNT,
           CASE
               WHEN TRANADV_PRIN_BC_AMT = 0 THEN NULL
               ELSE TRANADV_PRIN_BC_AMT
           END                    PRINCIPAL,
           CASE
               WHEN TRANADV_INTRD_BC_AMT = 0 THEN NULL
               ELSE TRANADV_INTRD_BC_AMT
           END                    INTEREST,
           CASE
               WHEN TRANADV_CHARGE_BC_AMT = 0 THEN NULL
               ELSE TRANADV_CHARGE_BC_AMT
           END                    CHARGE
      FROM LNINSTRECV,
           TRANADV2023,
           TRAN2023,
           ACNTS
     WHERE     LNINSTRECV_ENTITY_NUM = 1
           AND TRAN_DATE_OF_TRAN = '10-jun-2023'
           AND TRANADV_BRN_CODE = POST_TRAN_BRN
           AND TRAN_AMOUNT <> 0
           AND TRANADV_DATE_OF_TRAN = POST_TRAN_DATE
           AND TRANADV_BATCH_NUMBER = POST_TRAN_BATCH_NUM
           AND LNINSTRECV_INTERNAL_ACNUM = TRAN_INTERNAL_ACNUM
           AND TRAN_BRN_CODE = POST_TRAN_BRN
           AND TRAN_DATE_OF_TRAN = POST_TRAN_DATE
           AND TRAN_BATCH_NUMBER = POST_TRAN_BATCH_NUM
           AND LNINSTRECV_INTERNAL_ACNUM = TRAN_INTERNAL_ACNUM
           AND TRANADV_ENTITY_NUM = 1
           AND TRAN_ENTITY_NUM = 1
           -- and TRAN_BRN_CODE=26
           AND ACNTS_ENTITY_NUM = 1
           AND ACNTS_INTERNAL_ACNUM = TRAN_INTERNAL_ACNUM
           AND ACNTS_CLOSURE_DATE IS NULL
           AND TRAN_BRN_CODE = TRANADV_BRN_CODE
           AND TRAN_DATE_OF_TRAN = TRANADV_DATE_OF_TRAN
           AND TRAN_BATCH_NUMBER = TRANADV_BATCH_NUMBER
           AND TRAN_BATCH_SL_NUM = TRANADV_BATCH_SL_NUM;

INSERT INTO AUTOPOST_TRAN_TEMP
    SELECT 1                         BATCH_SL,
           1                         LEG_SL,
           NULL                      TRAN_DATE,
           NULL                      VALUE_DATE,
           NULL                      SUPP_TRAN,
           BRN_CODE,
           ACING_BRN_CODE,
           'C'                       DR_CR,
           NULL                      GLACC_CODE,
           LNACNT_RECOV_ACNT_NUM     INT_AC_NO,
           NULL                      CONT_NO,
           CURR_CODE,
           AC_AMOUNT,
           NULL                      PRINCIPAL,
           NULL                      INTEREST,
           NULL                      CHARGE
      FROM LOANACNTS, AUTOPOST_TRAN_TEMP
     WHERE LNACNT_ENTITY_NUM = 1 AND LNACNT_INTERNAL_ACNUM = INT_AC_NO;



INSERT INTO AUTOPOST_TRAN
    SELECT DENSE_RANK () OVER (ORDER BY TRAN_DATE, BRN_CODE)
               BATCH_SL,
           ROW_NUMBER ()
               OVER (PARTITION BY TRAN_DATE, BRN_CODE
                     ORDER BY TRAN_DATE, BRN_CODE)
               LEG_SL,
           TRAN_DATE
               TRAN_DATE,
           VALUE_DATE
               VALUE_DATE,
           NULL
               SUPP_TRAN,
           BRN_CODE,
           ACING_BRN_CODE,
           DR_CR,
           GLACC_CODE,
           INT_AC_NO,
           CONT_NO,
           CURR_CODE,
           AC_AMOUNT,
           AC_AMOUNT
               BC_AMOUNT,
           PRINCIPAL,
           INTEREST,
           CHARGE,
           NULL
               INST_PREFIX,
           NULL
               INST_NUM,
           NULL
               INST_DATE,
           NULL
               IBR_GL,
           NULL
               ORIG_RESP,
           NULL
               CONT_BRN_CODE,
           NULL
               ADV_NUM,
           NULL
               ADV_DATE,
           NULL
               IBR_CODE,
           NULL
               CAN_IBR_CODE,
           NULL
               NARRATION,
           NULL
               NARRATION,
           'INTELECT'
               USER_ID,
           NULL
               TERMINAL_ID,
           NULL
               PROCESSED,
           NULL
               BATCH_NO,
           NULL
               ERR_MSG,
           NULL
               DEPT_CODE
      FROM AUTOPOST_TRAN_TEMP TT;