SELECT GLSUM_TRAN_DATE,
                   TRAN_DATA.TRAN_GLACC_CODE,
                   TRAN_DATA.TRAN_ACING_BRN_CODE,
                   GLSUM_BC_DB_SUM,
                   TRAN_DATA.DEBIT_BAL_SUM,
                   TRAN_DATA.NUMBER_OF_DEBIT,
                   GLSUM_BC_CR_SUM,
                   TRAN_DATA.CREDIT_BAL_SUM,
                   TRAN_DATA.NUMBER_OF_CREDIT,
                   GLSUM_BC_DB_SUM - TRAN_DATA.DEBIT_BAL_SUM,
                   GLSUM_BC_CR_SUM - TRAN_DATA.CREDIT_BAL_SUM
              FROM GLSUM2022,
                   (  SELECT TRAN_GLACC_CODE,
                             TRAN_ACING_BRN_CODE,
                             SUM (CREDIT_BAL) CREDIT_BAL_SUM,
                             SUM (NUMBER_OF_CREDIT) NUMBER_OF_CREDIT,
                             SUM (DEBIT_BAL) DEBIT_BAL_SUM,
                             SUM (NUMBER_OF_DEBIT) NUMBER_OF_DEBIT,
                             SUM (CREDIT_BAL) - SUM (DEBIT_BAL)
                        FROM (SELECT TRAN_GLACC_CODE,
                                     TRAN_ACING_BRN_CODE,
                                     CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                           TRAN_BASE_CURR_EQ_AMT
                                        ELSE
                                           0
                                     END
                                        CREDIT_BAL,
                                     CASE
                                        WHEN TRAN_DB_CR_FLG = 'C' THEN 1
                                        ELSE 0
                                     END
                                        NUMBER_OF_CREDIT,
                                     CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                           TRAN_BASE_CURR_EQ_AMT
                                        ELSE
                                           0
                                     END
                                        DEBIT_BAL,
                                     CASE
                                        WHEN TRAN_DB_CR_FLG = 'D' THEN 1
                                        ELSE 0
                                     END
                                        NUMBER_OF_DEBIT
                                FROM TRAN2022
                               WHERE     TRAN_ENTITY_NUM = 1
                                   --  AND TRAN_DATE_OF_TRAN = '10-JAN-2022'
                                     AND TRAN_CURR_CODE = 'BDT'
                                     AND TRAN_ACING_BRN_CODE=1024
                                     AND TRAN_AUTH_BY IS NOT NULL)
                    GROUP BY TRAN_GLACC_CODE, TRAN_ACING_BRN_CODE) TRAN_DATA
             WHERE     GLSUM_ENTITY_NUM = 1
                  -- AND GLSUM_TRAN_DATE = '10-JAN-2022'
                   AND GLSUM_CURR_CODE = 'BDT'
                   AND GLSUM_BRANCH_CODE=1024
                   AND GLSUM_BRANCH_CODE = TRAN_DATA.TRAN_ACING_BRN_CODE
                   AND GLSUM_GLACC_CODE = TRAN_DATA.TRAN_GLACC_CODE
                   AND (   GLSUM_BC_DB_SUM <> TRAN_DATA.DEBIT_BAL_SUM
                        OR GLSUM_BC_CR_SUM <> TRAN_DATA.CREDIT_BAL_SUM)
          ORDER BY TRAN_DATA.TRAN_ACING_BRN_CODE, TRAN_DATA.TRAN_GLACC_CODE ;
		  
		  
		  

BEGIN
   FOR IDX
      IN (/* Formatted on 1/18/2022 6:48:17 PM (QP5 v5.252.13127.32867) */
SELECT GLSUM_BRANCH_CODE,
       GLSUM_GLACC_CODE,
       GLSUM_TRAN_DATE,
       TRAN_CURR_CODE,TRAN_ACING_BRN_CODE,
       NVL (AC_CREDIT_AMT, 0) AC_CREDIT_AMT,
       NVL (GLSUM_AC_CR_SUM, 0) GLSUM_AC_CR_SUM,
       NVL (AC_DEBIT_AMT, 0) AC_DEBIT_AMT,
       NVL (GLSUM_AC_DB_SUM, 0) GLSUM_AC_DB_SUM,
       NVL (BC_CREDIT_AMT, 0) BC_CREDIT_AMT,
       NVL (GLSUM_BC_CR_SUM, 0) GLSUM_BC_CR_SUM,
       NVL (BC_DEBIT_AMT, 0) BC_DEBIT_AMT,
       NVL (GLSUM_BC_DB_SUM, 0) GLSUM_BC_DB_SUM
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
                    FROM TRAN2021
                   WHERE     TRAN_ENTITY_NUM = 1
                         AND TRAN_ACING_BRN_CODE = 1024 ----BRANCH 
                         --AND TRAN_CURR_CODE = 'BDT'
                          AND TRAN_DATE_OF_TRAN = '30-DEC-2021'   ---DATE --
                         AND TRAN_BASE_CURR_EQ_AMT <> 0
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
                 SUM (GLSUM_AC_DB_SUM) GLSUM_AC_DB_SUM,
                 SUM (GLSUM_AC_CR_SUM) GLSUM_AC_CR_SUM,
                 SUM (GLSUM_BC_DB_SUM) GLSUM_BC_DB_SUM,
                 SUM (GLSUM_BC_CR_SUM) GLSUM_BC_CR_SUM
            FROM GLSUM2021
           WHERE GLSUM_ENTITY_NUM = 1 AND GLSUM_BRANCH_CODE = 1024  --BRANCH
        AND GLSUM_TRAN_DATE = '30-DEC-2021'
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
        OR NVL (BC_DEBIT_AMT, 0) <> NVL (GLSUM_BC_DB_SUM, 0)))
   LOOP
      UPDATE GLSUM2021 G
         SET G.GLSUM_AC_DB_SUM = IDX.AC_DEBIT_AMT,
             G.GLSUM_BC_DB_SUM = IDX.BC_DEBIT_AMT,
             --G.GLSUM_NUM_DBS = IDX.NUMBER_OF_DEBIT,
             G.GLSUM_AC_CR_SUM = IDX.AC_CREDIT_AMT,
             G.GLSUM_BC_CR_SUM = IDX.BC_CREDIT_AMT
            -- G.GLSUM_NUM_CRS = IDX.NUMBER_OF_CREDIT
       WHERE     G.GLSUM_ENTITY_NUM = 1
             AND G.GLSUM_BRANCH_CODE = IDX.TRAN_ACING_BRN_CODE
             AND G.GLSUM_GLACC_CODE = IDX.GLSUM_GLACC_CODE
             AND G.GLSUM_CURR_CODE = idx.TRAN_CURR_CODE
             AND G.GLSUM_TRAN_DATE = IDX.GLSUM_TRAN_DATE;
   END LOOP;
END;