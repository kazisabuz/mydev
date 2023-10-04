/* Formatted on 5/21/2023 7:08:30 PM (QP5 v5.388) */
-----------------gts double identified script --------------------

SELECT TRAN2023.*
  FROM TRAN2023, tranbat2023, GLBBAL
 WHERE     TRAN_DATE_OF_TRAN = '27-JUL-2023'
       AND TRANBAT_ENTITY_NUM = 1
       AND TRANBAT_BRN_CODE = TRAN_BRN_CODE
       AND TRANBAT_DATE_OF_TRAN = TRAN_DATE_OF_TRAN
       AND GLBBAL_ENTITY_NUM = 1
       AND GLBBAL_BRANCH_CODE = TRAN_BRN_CODE
       AND GLBBAL_GLACC_CODE = TRAN_GLACC_CODE
       AND TRANBAT_SOURCE_TABLE <> 'TRAN'
       AND TRAN_AMOUNT IN
               (SELECT TRAN_AMOUNT
                 FROM TRAN2023
                WHERE     TRAN_DB_CR_FLG IN ('C', 'D')
                      AND TRAN_GLACC_CODE IN ('140143114')
                      AND TRAN_DATE_OF_TRAN = '26-JUL-2023'
                      AND TRAN_ENTITY_NUM = 1)
       AND GLBBAL_YEAR = 2023
       AND GLBBAL_BC_BAL <> 0
       AND TRANBAT_BATCH_NUMBER = TRAN_BATCH_NUMBER
       AND TRAN_NARR_DTL1 = 'CR'
       AND TRAN_DB_CR_FLG IN ('C', 'D')
       AND TRAN_GLACC_CODE IN ('140143114')
       AND TRAN_ENTITY_NUM = 1;

-----------------update script-----------------------------


UPDATE tranbat2023
   SET TRANBAT_SOURCE_TABLE = 'TRAN'
 WHERE (TRANBAT_BRN_CODE, TRANBAT_BATCH_NUMBER, TRANBAT_DATE_OF_TRAN) IN
           (SELECT TRAN_BRN_CODE, TRAN_BATCH_NUMBER, TRAN_DATE_OF_TRAN
             FROM TRAN2023, tranbat2023, GLBBAL
            WHERE     TRAN_DATE_OF_TRAN = '21-MAY-2023'
                  AND TRANBAT_ENTITY_NUM = 1
                  AND TRANBAT_BRN_CODE = TRAN_BRN_CODE
                  AND TRANBAT_DATE_OF_TRAN = TRAN_DATE_OF_TRAN
                  AND GLBBAL_ENTITY_NUM = 1
                  AND GLBBAL_BRANCH_CODE = TRAN_BRN_CODE
                  AND GLBBAL_GLACC_CODE = TRAN_GLACC_CODE
                  AND TRANBAT_SOURCE_TABLE <> 'TRAN'
                  AND TRAN_AMOUNT IN
                          (SELECT TRAN_AMOUNT
                            FROM TRAN2023
                           WHERE     TRAN_DB_CR_FLG IN ('C', 'D')
                                 AND TRAN_GLACC_CODE IN ('140143114')
                                 AND TRAN_DATE_OF_TRAN = '18-MAY-2023'
                                 AND TRAN_ENTITY_NUM = 1)
                  AND GLBBAL_YEAR = 2023
                  AND GLBBAL_BC_BAL <> 0
                  AND TRANBAT_BATCH_NUMBER = TRAN_BATCH_NUMBER
                  AND TRAN_NARR_DTL1 = 'CR'
                  AND TRAN_DB_CR_FLG IN ('C', 'D')
                  AND TRAN_GLACC_CODE IN ('140143114')
                  AND TRAN_ENTITY_NUM = 1);



  SELECT *
    FROM (  SELECT a.TRAN_BRN_CODE,
                   SUM (DR_AMT),
                   SUM (CR_AMT),
                   SUM (CR_AMT) - SUM (DR_AMT)     TOTAL_AMT
              FROM (SELECT TRAN_BRN_CODE,
                           TRAN_BATCH_NUMBER,
                           TRAN_GLACC_CODE,
                           TRAN_DB_CR_FLG,
                           CASE
                               WHEN TRAN_DB_CR_FLG = 'D' THEN TRAN_AMOUNT
                               ELSE 0
                           END    DR_AMT,
                           CASE
                               WHEN TRAN_DB_CR_FLG = 'C' THEN TRAN_AMOUNT
                               ELSE 0
                           END    CR_AMT,
                           TRAN_AMOUNT,
                           TRAN_NARR_DTL1
                      FROM TRAN2023
                     WHERE     TRAN_DATE_OF_TRAN = '21-MAY-2023'
                           AND TRAN_NARR_DTL1 = 'CR'
                           AND TRAN_GLACC_CODE IN ('140143114')
                           AND TRAN_ENTITY_NUM = 1) a
          GROUP BY TRAN_BRN_CODE)
   WHERE TOTAL_AMT <> 0
ORDER BY TRAN_BRN_CODE