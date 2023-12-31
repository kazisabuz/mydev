/* Formatted on 5/17/2020 11:17:34 AM (QP5 v5.227.12220.39754) */
SELECT ACNTS_BRN_CODE,
       ACNTS_PROD_CODE,
       facno (1, ACNTS_INTERNAL_ACNUM) acc_no,ASSETCLS_ASSET_CODE,
       (FN_GET_ASON_ACBAL (1,
                           ACNTS_INTERNAL_ACNUM,
                           'BDT',
                           '30-APR-2020',
                           '17-MAY-2020'))
          OUTSTANDING_BAL
  FROM acnts, assetcls
 WHERE     ACNTS_PROD_CODE IN (3001, 3002, 3003, 3005, 3951, 3953)
       AND ACNTS_INTERNAL_ACNUM = ASSETCLS_INTERNAL_ACNUM
       AND ASSETCLS_ASSET_CODE IN ('UC', 'SM', 'SS', 'DF')
       AND ACNTS_ENTITY_NUM = 1
       AND ASSETCLS_ENTITY_NUM = 1
       AND ACNTS_OPENING_DATE <= '30-APR-2020'
       AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE > '30-APR-2020')