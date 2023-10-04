/* Formatted on 31/01/2021 6:37:16 PM (QP5 v5.227.12220.39754) */
BEGIN
   FOR IDX IN (SELECT * FROM MIG_DETAIL)
   LOOP
      INSERT INTO BACKUPTABLE.COVID_RECOVERY
         SELECT ACNTS_BRN_CODE,
                ACNTS_PROD_CODE,
                ACNTS_INTERNAL_ACNUM,
                ACNTS_AC_TYPE,
                ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
                ACNTS_CLOSURE_DATE,
                TRAN_DATE_OF_TRAN,
                TRAN_BATCH_NUMBER,
                TRAN_DB_CR_FLG,
                TRAN_GLACC_CODE TRAN_AMOUNT
           FROM TRAN2020, ACNTS
          WHERE     (TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER) IN
                       (SELECT TRAN_BRN_CODE,
                               TRAN_DATE_OF_TRAN,
                               TRAN_BATCH_NUMBER
                          FROM TRAN2020
                         WHERE     TRAN_ENTITY_NUM = 1
                               AND TRAN_GLACC_CODE IN
                                      ('225116225', '225116230')
                               AND TRAN_DB_CR_FLG = 'D'
                               AND TRAN_DATE_OF_TRAN >= '30-jun-2020'
                               AND TRAN_BRN_CODE = IDX.BRANCH_CODE
                               AND TRAN_AUTH_BY IS NOT NULL)
                AND TRAN_ENTITY_NUM = 1
                AND TRAN_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                AND ACNTS_ENTITY_NUM = 1
                AND ACNTS_CLOSURE_DATE IS NOT NULL
                AND TRAN_INTERNAL_ACNUM <> 0
                AND TRAN_DB_CR_FLG = 'C'
                AND TRAN_BRN_CODE = IDX.BRANCH_CODE;

      COMMIT;
   END LOOP;
END;