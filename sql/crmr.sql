/* Formatted on 2/14/2022 2:55:01 PM (QP5 v5.252.13127.32867) */
SELECT 'No. of accounts having excess over limit' HEADING,
       COUNT (account_no)account_no ,
       SUM (OUTSTANDING) OUTSTANDING
  FROM (SELECT  ACNTS_INTERNAL_ACNUM account_no,
               LMTLINE_SANCTION_AMT,
               ABS (FN_GET_ASON_ACBAL (1,
                                       ACNTS_INTERNAL_ACNUM,
                                       'BDT',
                                       '31-dec-2021',
                                       '14-FEB-2022'))
                  OUTSTANDING
          FROM ACASLLDTL,
               LIMITLINE,
               ACNTS,
               products,
               ASSETCLS
         WHERE     ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
               AND ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLIENT_NUM = LMTLINE_CLIENT_CODE
               AND LMTLINE_ENTITY_NUM = 1
               AND ASSETCLS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ASSETCLS_ASSET_CODE IN ('UC', 'SM')
               AND ACNTS_OPENING_DATE <= '31-dec-2021'
               AND (   ACNTS_CLOSURE_DATE IS NULL
                    OR ACNTS_CLOSURE_DATE > '31-dec-2021')
               AND PRODUCT_FOR_LOANS = 1
               AND PRODUCT_CODE = ACNTS_PROD_CODE
               AND ACNTS_BRN_CODE = 26
               AND ACASLLDTL_ENTITY_NUM = 1)
 WHERE OUTSTANDING > LMTLINE_SANCTION_AMT;



-----

SELECT 'No. of overdue accounts having excess over limit' HEADING,
       COUNT (account_no) account_no,
       SUM (OUTSTANDING) OUTSTANDING,
       LMTLINE_SANCTION_AMT
  FROM (SELECT  ACNTS_INTERNAL_ACNUM account_no,
               LMTLINE_SANCTION_AMT,
               ABS (FN_GET_ASON_ACBAL (1,
                                       ACNTS_INTERNAL_ACNUM,
                                       'BDT',
                                       '31-dec-2021',
                                       '14-FEB-2022'))
                  OUTSTANDING
          FROM ACASLLDTL,
               LIMITLINE,
               ACNTS,
               products,
               ASSETCLS
         WHERE     ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
               AND ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLIENT_NUM = LMTLINE_CLIENT_CODE
               AND LMTLINE_ENTITY_NUM = 1
               AND PRODUCT_FOR_LOANS = 1
               AND PRODUCT_CODE = ACNTS_PROD_CODE
               AND ASSETCLS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ASSETCLS_ASSET_CODE IN ('UC', 'SM')
               AND ACNTS_BRN_CODE = 26
               AND ACNTS_OPENING_DATE <= '31-dec-2021'
               AND (   ACNTS_CLOSURE_DATE IS NULL
                    OR ACNTS_CLOSURE_DATE > '31-dec-2021')
               AND ACASLLDTL_ENTITY_NUM = 1
               AND ACNTS_INTERNAL_ACNUM IN (SELECT ACNTS_INTERNAL_ACNUM
                                              FROM (SELECT ACNTS_INTERNAL_ACNUM,
                                                           OVERDUE_AMOUNT
                                                      FROM (SELECT ACNTS_INTERNAL_ACNUM,
                                                                   FN_GET_OD_AMT (
                                                                      1,
                                                                      ACNTS_INTERNAL_ACNUM,
                                                                      '31-dec-2021',
                                                                      '31-dec-2021')
                                                                      OVERDUE_AMOUNT
                                                              FROM ACNTS,
                                                                   PRODUCTS,
                                                                   ASSETCLS
                                                             WHERE     ACNTS_ENTITY_NUM =
                                                                          1
                                                                   AND ACNTS_ENTITY_NUM =
                                                                          1
                                                                   AND ACNTS_BRN_CODE =
                                                                          26
                                                                   AND ASSETCLS_INTERNAL_ACNUM =
                                                                          ACNTS_INTERNAL_ACNUM
                                                                   AND ASSETCLS_ASSET_CODE IN ('UC',
                                                                                               'SM')
                                                                   AND PRODUCT_CODE =
                                                                          ACNTS_PROD_CODE
                                                                   AND PRODUCT_FOR_LOANS =
                                                                          1
                                                                   AND ACNTS_OPENING_DATE <=
                                                                          '31-dec-2021'
                                                                   AND (   ACNTS_CLOSURE_DATE
                                                                              IS NULL
                                                                        OR ACNTS_CLOSURE_DATE >
                                                                              '31-dec-2021'))
                                                     WHERE NVL (
                                                              OVERDUE_AMOUNT,
                                                              0) <> 0)))
 WHERE OUTSTANDING > LMTLINE_SANCTION_AMT;



--------

SELECT 'No. of accounts having unsatisfactory repayment' HEADING,
       COUNT (ACNTS_INTERNAL_ACNUM) ACC_NO,
       SUM (ABS (FN_GET_ASON_ACBAL (1,
                                    ACNTS_INTERNAL_ACNUM,
                                    'BDT',
                                    '31-dec-2021',
                                    '14-FEB-2022')))
          OUTSTANDING_AMOUNT
  FROM (SELECT ACNTS_INTERNAL_ACNUM,
               FN_GET_PAID_AMT (1, ACNTS_INTERNAL_ACNUM, '31-OCT-2021')
                  OCT_RECOVERY,
               FN_GET_PAID_AMT (1, ACNTS_INTERNAL_ACNUM, '31-dec-2021')
                  DEC_RECOVERY
          FROM ACNTS, PRODUCTS, assetcls
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_BRN_CODE = 26
               AND ASSETCLS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ASSETCLS_ASSET_CODE IN ('UC', 'SM')
               AND PRODUCT_FOR_RUN_ACS = 1
               AND PRODUCT_CODE = ACNTS_PROD_CODE
               AND ACNTS_OPENING_DATE <= '31-dec-2021'
               AND (   ACNTS_CLOSURE_DATE IS NULL
                    OR ACNTS_CLOSURE_DATE > '31-dec-2021')
               AND PRODUCT_FOR_LOANS = 1)
 WHERE (NVL (OCT_RECOVERY, 0) - NVL (DEC_RECOVERY, 0)) = 0;