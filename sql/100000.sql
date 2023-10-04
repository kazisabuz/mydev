/* Formatted on 6/20/2019 5:23:30 PM (QP5 v5.227.12220.39754) */
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
       TT.*
  FROM (  SELECT /*+ PARALLEL( 8) */
                MBRN_CODE BR_CODE,
                 MBRN_NAME,
                 facno (1, ACNTS_INTERNAL_ACNUM) account_no,
                 ACNTS_AC_NAME1,
                 SUM (
                    (SELECT NVL ( (LMTLINE_SANCTION_AMT), 0)
                       FROM ACASLLDTL, LIMITLINE
                      WHERE     ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
                            AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
                            AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                            AND LMTLINE_ENTITY_NUM = 1))
                    SANCTION_LIMIT,
                 SUM (NVL (FN_GET_ASON_ACBAL (1,
                                              ACNTS_INTERNAL_ACNUM,
                                              'BDT',
                                              '19-june-2019',
                                              '20-june-2019'),
                           0))
                    outs_BALANCE,
                 ASSETCLS_ASSET_CODE
            FROM products,
                 mbrn,
                 acnts,
                 assetcls
           WHERE     ASSETCLS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                 AND PRODUCT_FOR_LOANS = 1
                 AND PRODUCT_CODE = ACNTS_PROD_CODE
                 and MBRN_ENTITY_NUM=1
                 AND ACNTS_BRN_CODE = mbrn_code
                 AND ASSETCLS_ENTITY_NUM = 1
                 AND ACNTS_ENTITY_NUM = 1
        GROUP BY MBRN_CODE,
                 MBRN_NAME,
                 ACNTS_INTERNAL_ACNUM,
                 ACNTS_AC_NAME1,
                 ASSETCLS_ASSET_CODE
        ORDER BY 1) TT,
       MBRN_TREE2
 WHERE TT.BR_CODE = BRANCH_CODE AND ABS (OUTS_BALANCE) >= 10000000
 and BRANCH_GMO=1990