/* Formatted on 7/6/2020 3:16:28 PM (QP5 v5.227.12220.39754) */
SELECT BRANCH_GMO GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_GMO)
          GMO_NAME,
       BRANCH_PO PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_PO)
          PO_NAME,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRN_CODE)
          BRANCH_NAME,
       TT.*
  FROM (SELECT ACNTS_BRN_CODE  BRN_CODE,
               FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NO,
               ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
               PRODUCT_CODE,
               PRODUCT_NAME,
               NVL ( (LMTLINE_SANCTION_AMT), 0) SANCTION_AMOUNT,
               LMTLINE_DATE_OF_SANCTION DATE_OF_SANCTION,
               (SELECT SUM (NVL (LNACDISB_DISB_AMT, 0))
                  FROM LNACDISB
                 WHERE     LNACDISB_ENTITY_NUM = 1
                       AND LNACDISB_AUTH_BY IS NOT NULL
                       AND LNACDISB_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM)
                  DISB_AMOUNT
          FROM products,
               acnts,
               ACASLLDTL,
               LIMITLINE
         WHERE     ACNTS_PROD_CODE = PRODUCT_CODE
               AND LMTLINE_DATE_OF_SANCTION BETWEEN '01-jan-2019'
                                                AND '31-DEC-2019'
               AND PRODUCT_CODE IN (2101, 2105, 2106, 2107)
               AND ACNTS_ENTITY_NUM = 1
               AND ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
               AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
               AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND LMTLINE_ENTITY_NUM = 1
                ) TT,
       MBRN_TREE2
 WHERE TT.BRN_CODE = BRANCH_CODE;