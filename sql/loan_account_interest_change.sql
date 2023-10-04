/* Formatted on 6/29/2022 1:46:39 PM (QP5 v5.252.13127.32867) */
SELECT ACNTS_BRN_CODE,
       facno (1, ACNTS_INTERNAL_ACNUM) account_no,
       ACNTS_PROD_CODE,
       ACNTS_AC_TYPE,
       ACNTS_AC_NAME1,
       fn_get_ason_acbal (1,
                          ACNTS_INTERNAL_ACNUM,
                          'BDT',
                          '29-JUN-2022',
                          '29-JUN-2022')
          ACBAL,
       ASSETCLS_ASSET_CODE ASSET_CODE,
       (SELECT LNACIR_APPL_INT_RATE
          FROM lnacir
         WHERE     LNACIR_ENTITY_NUM = 1
               AND LNACIR_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM)
          int_rate,
       LNACIRSH_EFF_DATE,
       LNACIRSH_AUTH_BY,
       LNACIRSH_AUTH_ON
  FROM lnacirshist, acnts, assetcls
 WHERE     LNACIRSh_ENTITY_NUM = 1
       AND ASSETCLS_ENTITY_NUM = 1
       AND ASSETCLS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND LNACIRSh_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND ACNTS_ENTITY_NUM = 1
       AND LNACIRSH_EFF_DATE =
              (SELECT MAX (LNACIRSH_EFF_DATE)
                 FROM lnacirshist
                WHERE     LNACIRSH_ENTITY_NUM = 1
                      AND LNACIRSH_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM)
       AND LNACIRSh_INTERNAL_ACNUM NOT IN (SELECT LNACIRh_INTERNAL_ACNUM
                                             FROM lnacirhist
                                            WHERE LNACIRh_ENTITY_NUM = 1)
       AND LNACIRSH_AC_LEVEL_INT_REQD = '1'
       AND ACNTS_CLOSURE_DATE IS NULL;