/*System generates the trial balance with a procedure and keeps the records in a temporary table. This script is the simplified format of the procedure.*/
  SELECT A.GLBBAL_BRANCH_CODE,
         A.GLBBAL_CURR_CODE,
         A.GLBBAL_BC_BAL,
         NVL (B.TOTAL_TRAN, 0) TOTAL_TRAN,
         A.GLBBAL_BC_BAL + NVL (B.TOTAL_TRAN, 0) GL_BALANCE
    FROM (SELECT GLBBAL_BRANCH_CODE, GLBBAL_CURR_CODE, GLBBAL_BC_BAL
            FROM GLBBAL
           WHERE     GLBBAL_ENTITY_NUM = 1
                 AND GLBBAL_GLACC_CODE = '216101110'
                 AND GLBBAL_YEAR = 2019) A
         FULL OUTER JOIN
         (  SELECT GLSUM_BRANCH_CODE,
                   GLSUM_CURR_CODE,
                   SUM (GLSUM_BC_CR_SUM - GLSUM_BC_DB_SUM) TOTAL_TRAN
              FROM GLSUM2020
             WHERE     GLSUM_ENTITY_NUM = 1
                   AND GLSUM_GLACC_CODE = '216101110'
                   AND GLSUM_TRAN_DATE <= '31-DEC-2020'
          GROUP BY GLSUM_BRANCH_CODE, GLSUM_CURR_CODE) B
            ON (    A.GLBBAL_BRANCH_CODE = B.GLSUM_BRANCH_CODE
                AND A.GLBBAL_CURR_CODE = B.GLSUM_CURR_CODE)
   WHERE A.GLBBAL_BC_BAL + NVL (B.TOTAL_TRAN, 0) <> 0
ORDER BY A.GLBBAL_BRANCH_CODE ;