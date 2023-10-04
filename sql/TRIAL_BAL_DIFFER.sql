/* Formatted on 6/21/2023 6:22:38 PM (QP5 v5.388) */
-------GLSUM---------------------------

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
                         AND TRAN_ACING_BRN_CODE = 1164
                         --AND TRAN_CURR_CODE = 'BDT'
                        AND TRAN_DATE_OF_TRAN = '01-OCT-2023'
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
           WHERE GLSUM_ENTITY_NUM = 1 AND GLSUM_BRANCH_CODE = 1164
         AND GLSUM_TRAN_DATE = '01-OCT-2023'
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

-------------------GLBBAL-------------------------------------------

SELECT /*+ PARALLEL( 4) */
       NVL (A.TRAN_GLACC_CODE, B.GLBBAL_GLACC_CODE)                      GL_CODE,
       NVL (A.TRAN_CURR_CODE, B.GLBBAL_CURR_CODE)                        GL_CODE,
       A.CREDIT_BAL                                                      TRAN_CREDIT_SUM,
       NVL (B.GLBBAL_BC_CUR_CR_SUM, 0)                                   GL_CREDIT_SUM,
       NVL (A.DEBIT_BAL, 0)                                              TRAN_DEBIT_SUM,
       NVL (B.GLBBAL_BC_CUR_DB_SUM, 0)                                   GL_DEBIT_SUM,
       NVL (A.CREDIT_BAL - A.DEBIT_BAL, 0)                               TRAN_BALANCE,
       NVL (B.GLBBAL_BC_BAL, 0)                                          GL_BALANCE,
       NVL (A.CREDIT_BAL - A.DEBIT_BAL, 0) - NVL (B.GLBBAL_BC_BAL, 0)    BANALCE_DIFFER
  FROM (  SELECT TRAN_GLACC_CODE,
                 TRAN_CURR_CODE,
                 SUM (CREDIT_BAL)     CREDIT_BAL,
                 SUM (DEBIT_BAL)      DEBIT_BAL
            FROM (SELECT /*+ PARALLEL( 4) */
                         TRAN_GLACC_CODE,
                         TRAN_CURR_CODE,
                         CASE
                             WHEN TRAN_DB_CR_FLG = 'C'
                             THEN
                                 TRAN_BASE_CURR_EQ_AMT
                             ELSE
                                 0
                         END    CREDIT_BAL,
                         CASE
                             WHEN TRAN_DB_CR_FLG = 'D'
                             THEN
                                 TRAN_BASE_CURR_EQ_AMT
                             ELSE
                                 0
                         END    DEBIT_BAL
                    FROM (SELECT /*+ PARALLEL( 8) */
                                 *
                            FROM TRAN2014
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 8243
                                 AND TRAN_GLACC_CODE = '140126101'
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT /*+ PARALLEL( 8) */
                                 *
                            FROM TRAN2015
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 8243
                                 AND TRAN_GLACC_CODE = '140126101'
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT /*+ PARALLEL( 8) */
                                 *
                            FROM TRAN2016
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 8243
                                AND TRAN_GLACC_CODE = '140126101'
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT /*+ PARALLEL( 8) */
                                 *
                            FROM TRAN2017
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 8243
                                 AND TRAN_GLACC_CODE = '140126101'
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT /*+ PARALLEL( 8) */
                                 *
                            FROM TRAN2018
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 8243
                                  AND TRAN_GLACC_CODE = '140126101'
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT /*+ PARALLEL( 8) */
                                 *
                            FROM TRAN2019
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 8243
                                AND TRAN_GLACC_CODE = '140126101'
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT /*+ PARALLEL( 8) */
                                 *
                            FROM TRAN2020
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 8243
                                  AND TRAN_GLACC_CODE = '140126101'
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT /*+ PARALLEL( 8) */
                                 *
                            FROM TRAN2021
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 8243
                                  AND TRAN_GLACC_CODE = '140126101'
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT /*+ PARALLEL( 8) */
                                 *
                            FROM TRAN2022
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 8243
                                  AND TRAN_GLACC_CODE = '140126101'
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT /*+ PARALLEL( 8) */
                                 *
                            FROM TRAN2023
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 18
                                  AND TRAN_GLACC_CODE = '140126101'
                                 AND TRAN_AUTH_ON IS NOT NULL))
        GROUP BY TRAN_GLACC_CODE, TRAN_CURR_CODE
          HAVING SUM (CREDIT_BAL) - SUM (DEBIT_BAL) <> 0
        ORDER BY TRAN_GLACC_CODE) A
       FULL OUTER JOIN
       (  SELECT /*+ PARALLEL( 16) */
                 GLBBAL_GLACC_CODE,
                 GLBBAL_CURR_CODE,
                 GLBBAL_BC_CUR_CR_SUM,
                 GLBBAL_BC_CUR_DB_SUM,
                 GLBBAL_BC_CUR_CR_SUM - GLBBAL_BC_CUR_DB_SUM,
                 GLBBAL_BC_BAL
            FROM GLBBAL
           WHERE     GLBBAL_ENTITY_NUM = 1
                 AND GLBBAL_BRANCH_CODE = 18
                 AND GLBBAL_YEAR = 2023
                 AND GLBBAL_GLACC_CODE='140126101'
                 AND GLBBAL_BC_BAL <> 0
        ORDER BY GLBBAL_GLACC_CODE) B
           ON (    A.TRAN_GLACC_CODE = B.GLBBAL_GLACC_CODE
               AND A.TRAN_CURR_CODE = B.GLBBAL_CURR_CODE)
 WHERE NVL (A.CREDIT_BAL - A.DEBIT_BAL, 0) <> NVL (B.GLBBAL_BC_BAL, 0);



 -----------------GLBBAL IBR

SELECT COUNT (DISTINCT BRANCH_CODE) FROM RSOL_REPORT_DATA;

SELECT A.GLBBAL_BRANCH_CODE,
       A.GLBBAL_GLACC_CODE,
       A.GLBBAL_CURR_CODE,
       A.GLBBAL_AC_CUR_CR_SUM - B.GLBBAL_AC_OPNG_CR_SUM     DIFFER_CR,
       A.GLBBAL_AC_CUR_CR_SUM,
       B.GLBBAL_AC_OPNG_CR_SUM,
       B.GLBBAL_BC_OPNG_DB_SUM - A.GLBBAL_BC_CUR_DB_SUM     DIFF_DB
  FROM (SELECT GLBBAL_BRANCH_CODE,
               GLBBAL_GLACC_CODE,
               GLBBAL_CURR_CODE,
               GLBBAL_AC_CUR_CR_SUM,
               GLBBAL_AC_CUR_DB_SUM,
               GLBBAL_BC_CUR_CR_SUM,
               GLBBAL_BC_CUR_DB_SUM
          FROM glbbal
         WHERE     GLBBAL_ENTITY_NUM = 1
               -- AND GLBBAL_BRANCH_CODE = 18
               AND GLBBAL_GLACC_CODE = '217101101'
               AND GLBBAL_YEAR = 2022) A
       FULL OUTER JOIN
       (  SELECT GLBBAL_BRANCH_CODE,
                 GLBBAL_GLACC_CODE,
                 GLBBAL_CURR_CODE,
                 GLBBAL_AC_OPNG_CR_SUM,
                 GLBBAL_BC_OPNG_CR_SUM,
                 GLBBAL_BC_OPNG_DB_SUM,
                 GLBBAL_BC_CUR_DB_SUM
            FROM glbbal
           WHERE     GLBBAL_ENTITY_NUM = 1
                 --AND GLBBAL_BRANCH_CODE = 18
                 AND GLBBAL_GLACC_CODE = '217101101'
                 AND GLBBAL_YEAR = 2023
        ORDER BY GLBBAL_GLACC_CODE) B
           ON (    A.GLBBAL_GLACC_CODE = B.GLBBAL_GLACC_CODE
               AND A.GLBBAL_CURR_CODE = B.GLBBAL_CURR_CODE
               AND A.GLBBAL_BRANCH_CODE = B.GLBBAL_BRANCH_CODE)
 WHERE (   NVL (A.GLBBAL_AC_CUR_CR_SUM, 0) - NVL (B.GLBBAL_AC_OPNG_CR_SUM, 0) <>
           0
        OR NVL (B.GLBBAL_BC_OPNG_DB_SUM, 0) - NVL (A.GLBBAL_BC_CUR_DB_SUM, 0) <>
           0);



-----------------------------gbbbal with tran----------------------

SELECT b.GLBBAL_BRANCH_CODE,
       b.GLBBAL_GLACC_CODE,
       b.GLBBAL_CURR_CODE,
       A.AC_DEBIT_AMT,
       a.AC_CREDIT_AMT,
       a.BC_CREDIT_AMT,
       a.BC_DEBIT_AMT,
       b.GLBBAL_AC_CUR_DB_SUM,
       b.GLBBAL_AC_CUR_CR_SUM,
       b.GLBBAL_BC_CUR_DB_SUM,
       b.GLBBAL_BC_CUR_CR_SUM
  FROM (  SELECT /*+ PARALLEL( 8) */
                 TRAN_ACING_BRN_CODE,
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
                    FROM TRAN2015@dr
                   WHERE     TRAN_ENTITY_NUM = 1
                         --AND TRAN_CURR_CODE = 'BDT'
                         --  and TRAN_ACING_BRN_CODE=18
                         -- AND TRAN_DATE_OF_TRAN = '13-DEC-2022'
                         AND TRAN_BASE_CURR_EQ_AMT <> 0
                         AND TRAN_GLACC_CODE = '217101101'
                         AND TRAN_AUTH_ON IS NOT NULL)
        GROUP BY TRAN_GLACC_CODE, TRAN_ACING_BRN_CODE, TRAN_CURR_CODE) A
       FULL OUTER JOIN
       (  SELECT /*+ PARALLEL( 4) */
                 GLBBAL_BRANCH_CODE,
                 GLBBAL_GLACC_CODE,
                 GLBBAL_AC_OPNG_CR_SUM,
                 GLBBAL_BC_OPNG_DB_SUM,
                 GLBBAL_CURR_CODE,
                 GLBBAL_AC_CUR_DB_SUM,
                 GLBBAL_AC_CUR_CR_SUM,
                 GLBBAL_BC_CUR_DB_SUM,
                 GLBBAL_BC_CUR_CR_SUM
            FROM glbbal@dr
           WHERE     GLBBAL_ENTITY_NUM = 1
                 -- AND GLBBAL_BRANCH_CODE = 18
                 AND GLBBAL_GLACC_CODE = '217101101'
                 AND GLBBAL_YEAR = 2016
        ORDER BY GLBBAL_GLACC_CODE) B
           ON (    A.TRAN_GLACC_CODE = B.GLBBAL_GLACC_CODE
               AND A.TRAN_CURR_CODE = B.GLBBAL_CURR_CODE
               AND A.TRAN_ACING_BRN_CODE = B.GLBBAL_BRANCH_CODE)
 WHERE (   NVL (A.AC_CREDIT_AMT, 0) - NVL (B.GLBBAL_AC_OPNG_CR_SUM, 0) <> 0
        OR NVL (B.GLBBAL_BC_OPNG_DB_SUM, 0) - NVL (A.BC_DEBIT_AMT, 0) <> 0)