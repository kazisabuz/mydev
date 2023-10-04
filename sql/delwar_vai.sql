/* Formatted on 6/8/2021 5:42:52 PM (QP5 v5.252.13127.32867) */
  SELECT GMO_BRANCH,
         (SELECT mbrn_name
            FROM mbrn
           WHERE mbrn_code = GMO_BRANCH),
         TRAN_ACING_BRN_CODE,
         (SELECT mbrn_name
            FROM mbrn
           WHERE mbrn_code = TRAN_ACING_BRN_CODE)
            branch_code,
         (SELECT GLBBAL_BC_OPNG_DB_SUM
            FROM GLBBAL
           WHERE     GLBBAL_ENTITY_NUM = 1
                 AND GLBBAL_GLACC_CODE = '210125101'
                 AND GLBBAL_YEAR = 2021
                 AND GLBBAL_BRANCH_CODE = TRAN_ACING_BRN_CODE)
            OPEING_DEBIT_SUM,
         SUM (DEBIT_SUM) DEBIT_SUM,
         (SELECT GLBBAL_BC_OPNG_CR_SUM
            FROM GLBBAL
           WHERE     GLBBAL_ENTITY_NUM = 1
                 AND GLBBAL_GLACC_CODE = '210125101'
                 AND GLBBAL_YEAR = 2021
                 AND GLBBAL_BRANCH_CODE = TRAN_ACING_BRN_CODE)
            OPENING_CREDIT_SUM,
         SUM (CREDIT_SUM) CREDIT_SUM,
         FN_BIS_GET_ASON_GLBAL (1,
                                TRAN_ACING_BRN_CODE,
                                '210125101',
                                'BDT',
                                '31-MAY-2021',
                                '08-JUNE-2021')
            GL_BALANCE
    FROM (SELECT TRAN_ACING_BRN_CODE,
                 CASE WHEN TRAN_DB_CR_FLG = 'D' THEN TRAN_AMOUNT ELSE 0 END
                    DEBIT_SUM,
                 CASE WHEN TRAN_DB_CR_FLG = 'C' THEN TRAN_AMOUNT ELSE 0 END
                    CREDIT_SUM
            FROM tran2021
           WHERE     TRAN_GLACC_CODE = '210125101'
                 AND TRAN_DATE_OF_TRAN BETWEEN '01-jan-2021' AND '31-may-2021')
         TT,
         MBRN_TREE1
   WHERE TT.TRAN_ACING_BRN_CODE = BRANCH AND GMO_BRANCH = 33993
GROUP BY GMO_BRANCH, TRAN_ACING_BRN_CODE;