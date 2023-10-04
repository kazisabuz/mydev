/* Formatted on 9/4/2023 1:17:31 PM (QP5 v5.388) */
--------------finding script---------------

SELECT GLSUM_BRANCH_CODE,
       GLSUM_GLACC_CODE,
       GLSUM_TRAN_DATE,
       TRAN_CURR_CODE,
       NVL (AC_CREDIT_AMT, 0)       AC_CREDIT_AMT,
       NVL (GLSUM_AC_CR_SUM, 0)     GLSUM_AC_CR_SUM,
       NVL (AC_DEBIT_AMT, 0)        AC_DEBIT_AMT,
       NVL (GLSUM_AC_DB_SUM, 0)     GLSUM_AC_DB_SUM,
       NVL (BC_CREDIT_AMT, 0)       BC_CREDIT_AMT,
       NVL (GLSUM_BC_CR_SUM, 0)     GLSUM_BC_CR_SUM,
       NVL (BC_DEBIT_AMT, 0)        BC_DEBIT_AMT,
       NVL (GLSUM_BC_DB_SUM, 0)     GLSUM_BC_DB_SUM
  FROM (  SELECT TRAN_ACING_BRN_CODE,
                 TRAN_DATE_OF_TRAN,
                 TRAN_GLACC_CODE,
                 TRAN_CURR_CODE,
                 SUM (
                     CASE WHEN TRAN_DB_CR_FLG = 'C' THEN TRAN_AMOUNT ELSE 0 END)
                     AC_CREDIT_AMT,
                 SUM (
                     CASE WHEN TRAN_DB_CR_FLG = 'D' THEN TRAN_AMOUNT ELSE 0 END)
                     AC_DEBIT_AMT,
                 SUM (
                     CASE
                         WHEN TRAN_DB_CR_FLG = 'C' THEN TRAN_BASE_CURR_EQ_AMT
                         ELSE 0
                     END)
                     BC_CREDIT_AMT,
                 SUM (
                     CASE
                         WHEN TRAN_DB_CR_FLG = 'D' THEN TRAN_BASE_CURR_EQ_AMT
                         ELSE 0
                     END)
                     BC_DEBIT_AMT
            FROM (SELECT *
                    FROM TRAN2023
                   WHERE     TRAN_ENTITY_NUM = 1
                         AND TRAN_ACING_BRN_CODE = :branch_code -----branch code
                         --AND TRAN_CURR_CODE = 'BDT'
                         AND TRAN_DATE_OF_TRAN = :mismatch_date ----mismatch date
                         AND TRAN_BASE_CURR_EQ_AMT <> 0
                         --    and TRAN_GLACC_CODE='201101101'
                         AND TRAN_AUTH_ON IS NOT NULL)
        GROUP BY TRAN_GLACC_CODE,
                 TRAN_ACING_BRN_CODE,
                 TRAN_DATE_OF_TRAN,
                 TRAN_CURR_CODE) A
       FULL OUTER JOIN
       (  SELECT GLSUM_BRANCH_CODE,
                 GLSUM_GLACC_CODE,
                 GLSUM_CURR_CODE,
                 GLSUM_TRAN_DATE,
                 SUM (GLSUM_AC_DB_SUM)     GLSUM_AC_DB_SUM,
                 SUM (GLSUM_AC_CR_SUM)     GLSUM_AC_CR_SUM,
                 SUM (GLSUM_BC_DB_SUM)     GLSUM_BC_DB_SUM,
                 SUM (GLSUM_BC_CR_SUM)     GLSUM_BC_CR_SUM
            FROM GLSUM2023
           WHERE     GLSUM_ENTITY_NUM = 1
                 AND GLSUM_BRANCH_CODE = :branch_code           ---branch code
                 AND GLSUM_TRAN_DATE = :mismatch_date         ---mismatch date
        --and GLSUM_GLACC_CODE='201101101'
        GROUP BY GLSUM_BRANCH_CODE,
                 GLSUM_GLACC_CODE,
                 GLSUM_TRAN_DATE,
                 GLSUM_CURR_CODE) B
           ON (    A.TRAN_ACING_BRN_CODE = B.GLSUM_BRANCH_CODE
               AND A.TRAN_DATE_OF_TRAN = B.GLSUM_TRAN_DATE
               AND A.TRAN_CURR_CODE = B.GLSUM_CURR_CODE
               AND A.TRAN_GLACC_CODE = B.GLSUM_GLACC_CODE)
 WHERE (   NVL (AC_CREDIT_AMT, 0) <> NVL (GLSUM_AC_CR_SUM, 0)
        OR NVL (AC_DEBIT_AMT, 0) <> NVL (GLSUM_AC_DB_SUM, 0)
        OR NVL (BC_CREDIT_AMT, 0) <> NVL (GLSUM_BC_CR_SUM, 0)
        OR NVL (BC_DEBIT_AMT, 0) <> NVL (GLSUM_BC_DB_SUM, 0));


 ------------------update script---------------

BEGIN
    FOR IDX
        IN (  SELECT GLSUM_BRANCH_CODE,
                     GLSUM_GLACC_CODE,
                     GLSUM_TRAN_DATE,
                     NVL (TRAN_CURR_CODE, GLSUM_CURR_CODE)     TRAN_CURR_CODE,
                     NVL (AC_CREDIT_AMT, 0)                    AC_CREDIT_AMT,
                     NVL (GLSUM_AC_CR_SUM, 0)                  GLSUM_AC_CR_SUM,
                     NVL (BC_CREDIT_AMT, 0)                    BC_CREDIT_AMT,
                     NVL (GLSUM_BC_CR_SUM, 0)                  GLSUM_BC_CR_SUM,
                     NVL (AC_DEBIT_AMT, 0)                     AC_DEBIT_AMT,
                     NVL (GLSUM_AC_DB_SUM, 0)                  GLSUM_AC_DB_SUM,
                     NVL (BC_DEBIT_AMT, 0)                     BC_DEBIT_AMT,
                     NVL (GLSUM_BC_DB_SUM, 0)                  GLSUM_BC_DB_SUM
               FROM (  SELECT TRAN_ACING_BRN_CODE,
                              TRAN_DATE_OF_TRAN,
                              TRAN_CURR_CODE,
                              TRAN_GLACC_CODE,
                              SUM (
                                  CASE
                                      WHEN TRAN_DB_CR_FLG = 'C' THEN TRAN_AMOUNT
                                      ELSE 0
                                  END)    AC_CREDIT_AMT,
                              SUM (
                                  CASE
                                      WHEN TRAN_DB_CR_FLG = 'D' THEN TRAN_AMOUNT
                                      ELSE 0
                                  END)    AC_DEBIT_AMT,
                              SUM (
                                  CASE
                                      WHEN TRAN_DB_CR_FLG = 'C'
                                      THEN
                                          TRAN_BASE_CURR_EQ_AMT
                                      ELSE
                                          0
                                  END)    BC_CREDIT_AMT,
                              SUM (
                                  CASE
                                      WHEN TRAN_DB_CR_FLG = 'D'
                                      THEN
                                          TRAN_BASE_CURR_EQ_AMT
                                      ELSE
                                          0
                                  END)    BC_DEBIT_AMT
                         FROM (SELECT *
                                 FROM TRAN2023
                                WHERE     TRAN_ENTITY_NUM = 1
                                      AND TRAN_ACING_BRN_CODE = :branch_code --branch code
                                      --AND TRAN_CURR_CODE = 'BDT'
                                      AND TRAN_DATE_OF_TRAN = :mismatch_date ---mismatch date
                                      AND TRAN_BASE_CURR_EQ_AMT <> 0
                                      AND TRAN_AUTH_ON IS NOT NULL)
                     GROUP BY TRAN_GLACC_CODE,
                              TRAN_ACING_BRN_CODE,
                              TRAN_DATE_OF_TRAN,
                              TRAN_CURR_CODE) A
                    FULL OUTER JOIN
                    (  SELECT GLSUM_BRANCH_CODE,
                              GLSUM_GLACC_CODE,
                              GLSUM_TRAN_DATE,
                              GLSUM_CURR_CODE,
                              SUM (GLSUM_AC_DB_SUM)     GLSUM_AC_DB_SUM,
                              SUM (GLSUM_AC_CR_SUM)     GLSUM_AC_CR_SUM,
                              SUM (GLSUM_BC_DB_SUM)     GLSUM_BC_DB_SUM,
                              SUM (GLSUM_BC_CR_SUM)     GLSUM_BC_CR_SUM
                         FROM GLSUM2023
                        WHERE     GLSUM_ENTITY_NUM = 1
                              AND GLSUM_BRANCH_CODE = :branch_code
                              AND GLSUM_TRAN_DATE = :mismatch_date
                     GROUP BY GLSUM_BRANCH_CODE,
                              GLSUM_GLACC_CODE,
                              GLSUM_TRAN_DATE,
                              GLSUM_CURR_CODE) B
                        ON (    A.TRAN_ACING_BRN_CODE = B.GLSUM_BRANCH_CODE
                            AND A.TRAN_DATE_OF_TRAN = B.GLSUM_TRAN_DATE
                            AND A.TRAN_GLACC_CODE = B.GLSUM_GLACC_CODE
                            AND A.TRAN_CURR_CODE = B.GLSUM_CURR_CODE)
              WHERE (   NVL (AC_CREDIT_AMT, 0) <> NVL (GLSUM_AC_CR_SUM, 0)
                     OR NVL (AC_DEBIT_AMT, 0) <> NVL (GLSUM_AC_DB_SUM, 0)
                     OR NVL (BC_CREDIT_AMT, 0) <> NVL (GLSUM_BC_CR_SUM, 0)
                     OR NVL (BC_DEBIT_AMT, 0) <> NVL (GLSUM_BC_DB_SUM, 0))
           ORDER BY 2, 3)
    LOOP
        UPDATE GLSUM2023 G
           SET G.GLSUM_AC_DB_SUM = IDX.AC_DEBIT_AMT,
               G.GLSUM_BC_DB_SUM = IDX.BC_DEBIT_AMT,
               --G.GLSUM_NUM_DBS = IDX.NUMBER_OF_DEBIT,
               G.GLSUM_AC_CR_SUM = IDX.AC_CREDIT_AMT,
               G.GLSUM_BC_CR_SUM = IDX.BC_CREDIT_AMT
         --G.GLSUM_NUM_CRS = IDX.NUMBER_OF_CREDIT
         WHERE     G.GLSUM_ENTITY_NUM = 1
               AND G.GLSUM_BRANCH_CODE = IDX.GLSUM_BRANCH_CODE
               AND G.GLSUM_GLACC_CODE = IDX.GLSUM_GLACC_CODE
               AND G.GLSUM_CURR_CODE = IDX.TRAN_CURR_CODE
               AND G.GLSUM_TRAN_DATE = IDX.GLSUM_TRAN_DATE;
    END LOOP;
END;