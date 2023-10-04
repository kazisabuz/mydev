begin 
 --  W_SQL := 'TRUNCATE TABLE OPEN_ACCOUNT_DATA';

 --  EXECUTE IMMEDIATE W_SQL;

for idx in (select branch_code from mig_detail) loop
 
   INSERT INTO OPEN_ACCOUNT_DATA
        SELECT ACNTS_BRN_CODE,
               PO_BRANCH,
               GMO_BRANCH,
               PARENT_BRANCH,
               PROD_TYPE,
               TRANSACTION_TYPE,
               COUNT (*),
               SUM (TRANSACTION_AMOUNT),
               :P_ASON_DATE
          FROM (SELECT ACNTS_INTERNAL_ACNUM,
                       ACNTS_BRN_CODE,
                       PO_BRANCH,
                       GMO_BRANCH,
                       PARENT_BRANCH,
                       ACNTS_PROD_CODE,
                       ACNTS_AC_TYPE,
                       ACNTS_OPENING_DATE,
                       PROD_TYPE,
                       --DUMMY_TRAN_AMOUNT,
                       SUBSTR (DUMMY_TRAN_AMOUNT, 1, 1) TRANSACTION_TYPE,
                       TO_NUMBER (
                          SUBSTR (DUMMY_TRAN_AMOUNT,
                                  3,
                                  LENGTH (DUMMY_TRAN_AMOUNT) - 2))
                          TRANSACTION_AMOUNT
                  FROM (SELECT ACNTS_INTERNAL_ACNUM,
                               ACNTS_BRN_CODE,
                               PO_BRANCH,
                               GMO_BRANCH,
                               PARENT_BRANCH,
                               ACNTS_PROD_CODE,
                               ACNTS_AC_TYPE,
                               ACNTS_OPENING_DATE,
                               PROD_TYPE,
                               (SELECT TRAN_DB_CR_FLG || '@' || TRAN_AMOUNT
                                  FROM TRAN2023 T4
                                 WHERE     T4.TRAN_ENTITY_NUM = 1
                                       AND T4.TRAN_INTERNAL_ACNUM =
                                              ACNTS_INTERNAL_ACNUM
                                       AND T4.TRAN_AUTH_BY IS NOT NULL
                                       AND (T4.TRAN_DATE_OF_TRAN,
                                            T4.TRAN_BATCH_NUMBER,
                                            T4.TRAN_BATCH_SL_NUM,
                                            T4.TRAN_AUTH_ON) IN (SELECT MIN (
                                                                           T3.TRAN_DATE_OF_TRAN),
                                                                        MIN (
                                                                           T3.TRAN_BATCH_NUMBER),
                                                                        MIN (
                                                                           T3.TRAN_BATCH_SL_NUM),
                                                                        MIN (
                                                                           T3.TRAN_AUTH_ON)
                                                                   FROM TRAN2023 T3
                                                                  WHERE     T3.TRAN_ENTITY_NUM =
                                                                               1
                                                                        AND T3.TRAN_INTERNAL_ACNUM =
                                                                               ACNTS_INTERNAL_ACNUM
                                                                        AND T3.TRAN_AUTH_BY
                                                                               IS NOT NULL
                                                                        AND (T3.TRAN_DATE_OF_TRAN,
                                                                             T3.TRAN_BATCH_NUMBER,
                                                                             T3.TRAN_AUTH_ON) IN (SELECT MIN (
                                                                                                            T2.TRAN_DATE_OF_TRAN),
                                                                                                         MIN (
                                                                                                            T2.TRAN_BATCH_NUMBER),
                                                                                                         MIN (
                                                                                                            T2.TRAN_AUTH_ON)
                                                                                                    FROM TRAN2023 T2
                                                                                                   WHERE     T2.TRAN_ENTITY_NUM =
                                                                                                                1
                                                                                                         AND T2.TRAN_INTERNAL_ACNUM =
                                                                                                                ACNTS_INTERNAL_ACNUM
                                                                                                         AND T2.TRAN_AUTH_BY
                                                                                                                IS NOT NULL
                                                                                                         AND (T2.TRAN_DATE_OF_TRAN,
                                                                                                              T2.TRAN_AUTH_ON) IN (SELECT MIN (
                                                                                                                                             T1.TRAN_DATE_OF_TRAN),
                                                                                                                                          MIN (
                                                                                                                                             T1.TRAN_AUTH_ON)
                                                                                                                                     FROM TRAN2023 T1
                                                                                                                                    WHERE     T1.TRAN_ENTITY_NUM =
                                                                                                                                                 1
                                                                                                                                          AND T1.TRAN_INTERNAL_ACNUM =
                                                                                                                                                 ACNTS_INTERNAL_ACNUM
                                                                                                                                          AND T1.TRAN_AUTH_BY
                                                                                                                                                 IS NOT NULL))))
                                  DUMMY_TRAN_AMOUNT
                          FROM ACNTS,
                               MBRN_TREE1,
                               (SELECT CASE
                                          WHEN PRODUCT_FOR_LOANS = 1
                                          THEN
                                             'LOAN'
                                          WHEN PRODUCT_FOR_DEPOSITS = 1
                                          THEN
                                             CASE
                                                WHEN PRODUCT_FOR_RUN_ACS = 1
                                                THEN
                                                   'SAVING/CURRENT'
                                                ELSE
                                                   CASE
                                                      WHEN PRODUCT_CONTRACT_ALLOWED =
                                                              1
                                                      THEN
                                                         'FD'
                                                      ELSE
                                                         'RD'
                                                   END
                                             END
                                          ELSE
                                             'OTHERS'
                                       END
                                          PROD_TYPE,
                                       PRODUCT_CODE
                                  FROM PRODUCTS) PROD_CODE_TYPE
                         WHERE     ACNTS_ENTITY_NUM = 1
                               AND PROD_CODE_TYPE.PRODUCT_CODE =
                                      ACNTS_PROD_CODE
                               AND ACNTS_OPENING_DATE = :P_ASON_DATE
                               AND BRANCH = ACNTS_BRN_CODE AND ACNTS_BRN_CODE = idx.branch_code
                                                          ))
      GROUP BY ACNTS_BRN_CODE,
               PO_BRANCH,
               GMO_BRANCH,
               PARENT_BRANCH,
               PROD_TYPE,
               TRANSACTION_TYPE
      ORDER BY ACNTS_BRN_CODE,
               PO_BRANCH,
               GMO_BRANCH,
               PARENT_BRANCH,
               PROD_TYPE,
               TRANSACTION_TYPE;


   COMMIT;
end loop;
end;