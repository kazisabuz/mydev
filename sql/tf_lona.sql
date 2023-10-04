/* Formatted on 9/27/2023 1:16:28 PM (QP5 v5.388) */
BEGIN
    FOR idx IN (SELECT * FROM mig_detail)
    LOOP
        INSERT INTO backuptable.tf_prod_data
              SELECT SANCTION_YEAR,
                     PRODUCT_CODE,
                     PRODUCT_NAME,
                     SUM (DISB_AMT)                   DISB_AMT,
                     SUM (recovery_amount)            recovery_amount,
                     SUM (INT_APPLY_AMT)              INT_APPLY_AMT,
                     SUM (ADVBBAL_INTRD_BC_OPBAL)     TOTAL_INT,
                     SUM (TOTAL)                      OUTSTANDING
                FROM (SELECT /*+ PARALLEL( 4) */
                             TO_CHAR (LMTLINE_DATE_OF_SANCTION, 'MON-RRRR')
                                 SANCTION_YEAR,
                             PRODUCT_CODE,
                             PRODUCT_NAME,
                             ACNTS_INTERNAL_ACNUM,
                             LMTLINE_SANCTION_AMT
                                 DISB_AMT,
                             (SELECT SUM (NVL (LNINTAPPL_ACT_INT_AMT, 0))
                               FROM LNINTAPPL
                              WHERE     TO_CHAR (LNINTAPPL_APPL_DATE, 'MON-RRRR') =
                                        '2021'
                                    AND LNINTAPPL_ACNT_NUM =
                                        ACNTS_INTERNAL_ACNUM)
                                 INT_APPLY_AMT,
                             ADVBBAL_INTRD_BC_OPBAL,
                               (ADVBBAL_PRIN_BC_OPBAL)
                             + (ADVBBAL_INTRD_BC_OPBAL)
                             + (ADVBBAL_CHARGE_BC_OPBAL)
                                 TOTAL,
                             FN_GET_PAID_AMT (1,
                                              ACNTS_INTERNAL_ACNUM,
                                              '30-april-2021')
                                 recovery_amount
                        FROM ACNTS,
                             ACASLLDTL,
                             LIMITLINE,
                             PRODUCTS,
                             ADVBBAL
                       WHERE     ACNTS_ENTITY_NUM = 1
                             AND PRODUCT_CODE = ACNTS_PROD_CODE
                             AND ACASLLDTL_ENTITY_NUM = LMTLINE_ENTITY_NUM
                             AND LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
                             AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
                             AND ACASLLDTL_INTERNAL_ACNUM =
                                 ACNTS_INTERNAL_ACNUM
                             AND (   ACNTS_CLOSURE_DATE IS NULL
                                  OR ACNTS_CLOSURE_DATE > '30-APR-2021')
                             AND ACNTS_INTERNAL_ACNUM = ADVBBAL_INTERNAL_ACNUM
                             AND ADVBBAL_INTERNAL_ACNUM =
                                 ACASLLDTL_INTERNAL_ACNUM
                             AND ADVBBAL_YEAR = 2021
                             AND ADVBBAL_MONTH = 5
                             AND ADVBBAL_CURR_CODE = 'BDT'
                             AND ACNTS_BRN_CODE = idx.branch_code
                             AND PRODUCT_CODE IN (3001,
                                                  3002,
                                                  3003,
                                                  3005,
                                                  3007,
                                                  3009,
                                                  3017,
                                                  3043,
                                                  3045)
                             AND TO_CHAR (LMTLINE_DATE_OF_SANCTION, 'RRRR') =
                                 '2021')
            GROUP BY PRODUCT_CODE, SANCTION_YEAR, PRODUCT_NAME;

        COMMIT;

        INSERT INTO backuptable.tf_prod_data
              SELECT SANCTION_YEAR,
                     PRODUCT_CODE,
                     PRODUCT_NAME,
                     SUM (DISB_AMT)                   DISB_AMT,
                     SUM (recovery_amount)            recovery_amount,
                     SUM (INT_APPLY_AMT)              INT_APPLY_AMT,
                     SUM (ADVBBAL_INTRD_BC_OPBAL)     TOTAL_INT,
                     SUM (TOTAL)                      OUTSTANDING
                FROM (SELECT /*+ PARALLEL( 4) */
                             TO_CHAR (LMTLINE_DATE_OF_SANCTION, 'RRRR')
                                 SANCTION_YEAR,
                             PRODUCT_CODE,
                             PRODUCT_NAME,
                             ACNTS_INTERNAL_ACNUM,
                             LMTLINE_SANCTION_AMT
                                 DISB_AMT,
                             (SELECT SUM (NVL (LNINTAPPL_ACT_INT_AMT, 0))
                               FROM LNINTAPPL
                              WHERE     TO_CHAR (LNINTAPPL_APPL_DATE, 'RRRR') =
                                        '2020'
                                    AND LNINTAPPL_ACNT_NUM =
                                        ACNTS_INTERNAL_ACNUM)
                                 INT_APPLY_AMT,
                             ADVBBAL_INTRD_BC_OPBAL,
                               (ADVBBAL_PRIN_BC_OPBAL)
                             + (ADVBBAL_INTRD_BC_OPBAL)
                             + (ADVBBAL_CHARGE_BC_OPBAL)
                                 TOTAL,
                             FN_GET_PAID_AMT (1,
                                              ACNTS_INTERNAL_ACNUM,
                                              '31-dec-2020')
                                 recovery_amount
                        FROM ACNTS,
                             ACASLLDTL,
                             LIMITLINE,
                             PRODUCTS,
                             ADVBBAL
                       WHERE     ACNTS_ENTITY_NUM = 1
                             AND PRODUCT_CODE = ACNTS_PROD_CODE
                             AND ACASLLDTL_ENTITY_NUM = LMTLINE_ENTITY_NUM
                             AND LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
                             AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
                             AND ACASLLDTL_INTERNAL_ACNUM =
                                 ACNTS_INTERNAL_ACNUM
                             AND (   ACNTS_CLOSURE_DATE IS NULL
                                  OR ACNTS_CLOSURE_DATE > '31-dec-2020')
                             AND ACNTS_INTERNAL_ACNUM = ADVBBAL_INTERNAL_ACNUM
                             AND ADVBBAL_INTERNAL_ACNUM =
                                 ACASLLDTL_INTERNAL_ACNUM
                             AND ADVBBAL_YEAR = 2021
                             AND ADVBBAL_MONTH = 1
                             AND ADVBBAL_CURR_CODE = 'BDT'
                             AND ACNTS_BRN_CODE = idx.branch_code
                             AND PRODUCT_CODE IN (3001,
                                                  3002,
                                                  3003,
                                                  3005,
                                                  3007,
                                                  3009,
                                                  3017,
                                                  3043,
                                                  3045)
                             AND TO_CHAR (LMTLINE_DATE_OF_SANCTION, 'RRRR') =
                                 '2020')
            GROUP BY PRODUCT_CODE, SANCTION_YEAR, PRODUCT_NAME;

        COMMIT;

        INSERT INTO backuptable.tf_prod_data
              SELECT SANCTION_YEAR,
                     PRODUCT_CODE,
                     PRODUCT_NAME,
                     SUM (DISB_AMT)                   DISB_AMT,
                     SUM (recovery_amount)            recovery_amount,
                     SUM (INT_APPLY_AMT)              INT_APPLY_AMT,
                     SUM (ADVBBAL_INTRD_BC_OPBAL)     TOTAL_INT,
                     SUM (TOTAL)                      OUTSTANDING
                FROM (SELECT /*+ PARALLEL( 4) */
                             TO_CHAR (LMTLINE_DATE_OF_SANCTION, 'RRRR')
                                 SANCTION_YEAR,
                             PRODUCT_CODE,
                             PRODUCT_NAME,
                             ACNTS_INTERNAL_ACNUM,
                             LMTLINE_SANCTION_AMT
                                 DISB_AMT,
                             (SELECT SUM (AMOUNT)
                                FROM TABLE (PKG_LOAN_ACC_STMT.LOAN_ACC_STMT (
                                                1,
                                                ACNTS_BRN_CODE,
                                                ACNTS_INTERNAL_ACNUM,
                                                'BDT',
                                                '01-JAN-2022',
                                                '31-DEC-2022'))
                               WHERE DB_CR = 'D')
                                 TRAN_DISB_AMT,
                             (SELECT SUM (NVL (LNINTAPPL_ACT_INT_AMT, 0))
                               FROM LNINTAPPL
                              WHERE     TO_CHAR (LNINTAPPL_APPL_DATE, 'RRRR') =
                                        '2019'
                                    AND LNINTAPPL_ACNT_NUM =
                                        ACNTS_INTERNAL_ACNUM)
                                 INT_APPLY_AMT,
                             ADVBBAL_INTRD_BC_OPBAL,
                               (ADVBBAL_PRIN_BC_OPBAL)
                             + (ADVBBAL_INTRD_BC_OPBAL)
                             + (ADVBBAL_CHARGE_BC_OPBAL)
                                 TOTAL,
                             FN_GET_PAID_AMT (1,
                                              ACNTS_INTERNAL_ACNUM,
                                              '31-dec-2019')
                                 recovery_amount
                        FROM ACNTS,
                             ACASLLDTL,
                             LIMITLINE,
                             PRODUCTS,
                             ADVBBAL
                       WHERE     ACNTS_ENTITY_NUM = 1
                             AND PRODUCT_CODE = ACNTS_PROD_CODE
                             AND ACASLLDTL_ENTITY_NUM = LMTLINE_ENTITY_NUM
                             AND LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
                             AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
                             AND ACASLLDTL_INTERNAL_ACNUM =
                                 ACNTS_INTERNAL_ACNUM
                             AND (   ACNTS_CLOSURE_DATE IS NULL
                                  OR ACNTS_CLOSURE_DATE > '31-dec-2019')
                             AND ACNTS_INTERNAL_ACNUM = ADVBBAL_INTERNAL_ACNUM
                             AND ADVBBAL_INTERNAL_ACNUM =
                                 ACASLLDTL_INTERNAL_ACNUM
                             AND ADVBBAL_YEAR = 2020
                             AND ADVBBAL_MONTH = 1
                             AND ADVBBAL_CURR_CODE = 'BDT'
                             AND ACNTS_BRN_CODE = idx.branch_code
                             AND PRODUCT_CODE IN (3001,
                                                  3002,
                                                  3003,
                                                  3005,
                                                  3007,
                                                  3009,
                                                  3017,
                                                  3043,
                                                  3045)
                             AND TO_CHAR (LMTLINE_DATE_OF_SANCTION, 'RRRR') =
                                 '2019')
            GROUP BY PRODUCT_CODE, SANCTION_YEAR, PRODUCT_NAME;

        COMMIT;

        INSERT INTO backuptable.tf_prod_data
              SELECT SANCTION_YEAR,
                     PRODUCT_CODE,
                     PRODUCT_NAME,
                     SUM (DISB_AMT)                   DISB_AMT,
                     SUM (recovery_amount)            recovery_amount,
                     SUM (INT_APPLY_AMT)              INT_APPLY_AMT,
                     SUM (ADVBBAL_INTRD_BC_OPBAL)     TOTAL_INT,
                     SUM (TOTAL)                      OUTSTANDING
                FROM (SELECT /*+ PARALLEL( 4) */
                             TO_CHAR (LMTLINE_DATE_OF_SANCTION, 'RRRR')
                                 SANCTION_YEAR,
                             PRODUCT_CODE,
                             PRODUCT_NAME,
                             ACNTS_INTERNAL_ACNUM,
                             LMTLINE_SANCTION_AMT
                                 DISB_AMT,
                             (SELECT SUM (NVL (LNINTAPPL_ACT_INT_AMT, 0))
                               FROM LNINTAPPL
                              WHERE     TO_CHAR (LNINTAPPL_APPL_DATE, 'RRRR') =
                                        '2018'
                                    AND LNINTAPPL_ACNT_NUM =
                                        ACNTS_INTERNAL_ACNUM)
                                 INT_APPLY_AMT,
                             ADVBBAL_INTRD_BC_OPBAL,
                               (ADVBBAL_PRIN_BC_OPBAL)
                             + (ADVBBAL_INTRD_BC_OPBAL)
                             + (ADVBBAL_CHARGE_BC_OPBAL)
                                 TOTAL,
                             FN_GET_PAID_AMT (1,
                                              ACNTS_INTERNAL_ACNUM,
                                              '31-dec-2018')
                                 recovery_amount
                        FROM ACNTS,
                             ACASLLDTL,
                             LIMITLINE,
                             PRODUCTS,
                             ADVBBAL
                       WHERE     ACNTS_ENTITY_NUM = 1
                             AND PRODUCT_CODE = ACNTS_PROD_CODE
                             AND ACASLLDTL_ENTITY_NUM = LMTLINE_ENTITY_NUM
                             AND LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
                             AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
                             AND ACASLLDTL_INTERNAL_ACNUM =
                                 ACNTS_INTERNAL_ACNUM
                             AND (   ACNTS_CLOSURE_DATE IS NULL
                                  OR ACNTS_CLOSURE_DATE > '31-dec-2018')
                             AND ACNTS_INTERNAL_ACNUM = ADVBBAL_INTERNAL_ACNUM
                             AND ADVBBAL_INTERNAL_ACNUM =
                                 ACASLLDTL_INTERNAL_ACNUM
                             AND ADVBBAL_YEAR = 2019
                             AND ADVBBAL_MONTH = 1
                             AND ADVBBAL_CURR_CODE = 'BDT'
                             AND ACNTS_BRN_CODE = idx.branch_code
                             AND PRODUCT_CODE IN (3001,
                                                  3002,
                                                  3003,
                                                  3005,
                                                  3007,
                                                  3009,
                                                  3017,
                                                  3043,
                                                  3045)
                             AND TO_CHAR (LMTLINE_DATE_OF_SANCTION, 'RRRR') =
                                 '2018')
            GROUP BY PRODUCT_CODE, SANCTION_YEAR, PRODUCT_NAME;

        COMMIT;

        INSERT INTO backuptable.tf_prod_data
              SELECT SANCTION_YEAR,
                     PRODUCT_CODE,
                     PRODUCT_NAME,
                     SUM (DISB_AMT)                   DISB_AMT,
                     SUM (recovery_amount)            recovery_amount,
                     SUM (INT_APPLY_AMT)              INT_APPLY_AMT,
                     SUM (ADVBBAL_INTRD_BC_OPBAL)     TOTAL_INT,
                     SUM (TOTAL)                      OUTSTANDING
                FROM (SELECT /*+ PARALLEL( 4) */
                             TO_CHAR (LMTLINE_DATE_OF_SANCTION, 'RRRR')
                                 SANCTION_YEAR,
                             PRODUCT_CODE,
                             PRODUCT_NAME,
                             ACNTS_INTERNAL_ACNUM,
                             LMTLINE_SANCTION_AMT
                                 DISB_AMT,
                             (SELECT SUM (NVL (LNINTAPPL_ACT_INT_AMT, 0))
                               FROM LNINTAPPL
                              WHERE     TO_CHAR (LNINTAPPL_APPL_DATE, 'RRRR') =
                                        '2017'
                                    AND LNINTAPPL_ACNT_NUM =
                                        ACNTS_INTERNAL_ACNUM)
                                 INT_APPLY_AMT,
                             ADVBBAL_INTRD_BC_OPBAL,
                               (ADVBBAL_PRIN_BC_OPBAL)
                             + (ADVBBAL_INTRD_BC_OPBAL)
                             + (ADVBBAL_CHARGE_BC_OPBAL)
                                 TOTAL,
                             FN_GET_PAID_AMT (1,
                                              ACNTS_INTERNAL_ACNUM,
                                              '31-dec-2017')
                                 recovery_amount
                        FROM ACNTS,
                             ACASLLDTL,
                             LIMITLINE,
                             PRODUCTS,
                             ADVBBAL
                       WHERE     ACNTS_ENTITY_NUM = 1
                             AND PRODUCT_CODE = ACNTS_PROD_CODE
                             AND ACASLLDTL_ENTITY_NUM = LMTLINE_ENTITY_NUM
                             AND LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
                             AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
                             AND ACASLLDTL_INTERNAL_ACNUM =
                                 ACNTS_INTERNAL_ACNUM
                             AND (   ACNTS_CLOSURE_DATE IS NULL
                                  OR ACNTS_CLOSURE_DATE > '31-dec-2017')
                             AND ACNTS_INTERNAL_ACNUM = ADVBBAL_INTERNAL_ACNUM
                             AND ADVBBAL_INTERNAL_ACNUM =
                                 ACASLLDTL_INTERNAL_ACNUM
                             AND ADVBBAL_YEAR = 2018
                             AND ADVBBAL_MONTH = 1
                             AND ADVBBAL_CURR_CODE = 'BDT'
                             AND ACNTS_BRN_CODE = idx.branch_code
                             AND PRODUCT_CODE IN (3001,
                                                  3002,
                                                  3003,
                                                  3005,
                                                  3007,
                                                  3009,
                                                  3017,
                                                  3043,
                                                  3045)
                             AND TO_CHAR (LMTLINE_DATE_OF_SANCTION, 'RRRR') =
                                 '2017')
            GROUP BY PRODUCT_CODE, SANCTION_YEAR, PRODUCT_NAME;

        COMMIT;
    END LOOP;
END;