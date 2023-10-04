/* Formatted on 9/10/2023 10:46:18 AM (QP5 v5.388) */
SELECT *
  FROM (  SELECT /*+ PARALLEL( 8) */
                 facno(1,ACNTS_INTERNAL_ACNUM) acc_no,
                 CASE
                     WHEN PRODUCT_FOR_RUN_ACS = 0 THEN 'Term loan'
                     ELSE 'Continious Loan'
                 END
                     LOAN_TYPE,
                 (SELECT SUM (NVL (LNACDISB_DISB_AMT, 0))
                    FROM LNACDISB
                   WHERE     LNACDISB_ENTITY_NUM = 1
                         AND LNACDISB_AUTH_BY IS NOT NULL
                         AND LNACDISB_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM)
                     DISB_AMOUNT,
                 SUM (
                     (SELECT NVL ((LMTLINE_SANCTION_AMT), 0)
                       FROM ACASLLDTL, LIMITLINE
                      WHERE     ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
                            AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
                            AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                            AND LMTLINE_ENTITY_NUM = 1))
                     SANCTION_AMOUNT,
                 SUM (
                     (SELECT NVL (ACBALH_BC_BAL, 0)
                       FROM ACBALASONHIST A
                      WHERE     A.ACBALH_ENTITY_NUM = 1
                            AND A.ACBALH_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                            AND A.ACBALH_ASON_DATE =
                                (SELECT MAX (ACBALH_ASON_DATE)
                                  FROM ACBALASONHIST
                                 WHERE     ACBALH_ENTITY_NUM = 1
                                       AND ACBALH_INTERNAL_ACNUM =
                                           ACNTS_INTERNAL_ACNUM
                                       AND ACBALH_ASON_DATE <= :START_DATE)))
                     OUTSTANDING_BALANCE
            FROM ACNTS, PRODUCTS, ASSETCLS
           WHERE     ACNTS_ENTITY_NUM = 1
                 AND ACNTS_OPENING_DATE <= :START_DATE
                 AND (   ACNTS_CLOSURE_DATE IS NULL
                      OR ACNTS_CLOSURE_DATE > :START_DATE)
                 AND PRODUCT_CODE = ACNTS_PROD_CODE
                 AND PRODUCT_FOR_LOANS = 1
                 AND PRODUCT_FOR_RUN_ACS = 1
                 --  and ACNTS_BRN_CODE=26
                 AND ASSETCLS_ENTITY_NUM = 1
                 AND ASSETCLS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                 AND ASSETCLS_ASSET_CODE = 'UC'
                 AND ACNTS_INTERNAL_ACNUM NOT IN
                         (SELECT LNACRS_INTERNAL_ACNUM
                           FROM LNACRS
                          WHERE     LNACRS_ENTITY_NUM = 1
                                AND LNACRS_REPHASEMENT_ENTRY = '1'
                                AND LNACRS_PURPOSE = 'R')
                 AND ACNTS_PROD_CODE NOT IN (2101,
                                             3047,
                                             3045,
                                             3043,
                                             3041,
                                             3039,
                                             3037,
                                             3035,
                                             3033,
                                             3031,
                                             3029,
                                             3027,
                                             3025,
                                             3023,
                                             3017,
                                             3015,
                                             3013,
                                             3011,
                                             3009,
                                             3007,
                                             3005,
                                             3003,
                                             3002,
                                             3001,
                                             2029,
                                             3041,
                                             3963,
                                             3961,
                                             3953,
                                             3951,
                                             3029,
                                             3023,
                                             3025,
                                             3027,
                                             3031,
                                             3951,
                                             3953,
                                             3047,
                                             3011,
                                             3013,
                                             3015,
                                             3039,
                                             3045,
                                             3043,
                                             3035,
                                             3099,
                                             3037,
                                             3005,
                                             3001,
                                             3003,
                                             3007,
                                             3009,
                                             3963,
                                             3017,
                                             2102,
                                             2103,
                                             2104,
                                             2105,
                                             2106,
                                             2107,
                                             2108,
                                             2109,
                                             2031,
                                             2042)               -- Staff Loan
        GROUP BY PRODUCT_FOR_RUN_ACS, ACNTS_INTERNAL_ACNUM
        ORDER BY PRODUCT_FOR_RUN_ACS)
 WHERE SANCTION_AMOUNT >= (DISB_AMOUNT) AND OUTSTANDING_BALANCE <> 0