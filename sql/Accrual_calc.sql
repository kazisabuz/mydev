SELECT ACNTS_BRN_CODE,
                    MBRN_NAME,
                    SUM ( (ACNTBAL_BC_BAL * .09 / 360 * 31)) ACCRUE_AMT
               FROM MBRN, ACNTS, ACNTBAL
              WHERE     ACNTS_ENTITY_NUM = 1
                    AND ACNTS_INTERNAL_ACNUM = ACNTBAL_INTERNAL_ACNUM
                    AND ACNTS_PROD_CODE = 2502
                    AND ACNTS_BRN_CODE = MBRN_CODE
                    AND ACNTBAL_ENTITY_NUM = 1
                    AND ACNTS_CLOSURE_DATE IS NULL
                    --AND ACNTBAL_BC_BAL <> 0
                    AND ACNTS_BRN_CODE NOT IN
                           (7039, 18176, 19125, 19190, 20230, 24158, 26054)
           GROUP BY ACNTS_BRN_CODE, MBRN_NAME