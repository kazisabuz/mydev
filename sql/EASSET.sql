/* Formatted on 6/29/2022 12:40:42 PM (QP5 v5.252.13127.32867) */
SELECT /*+ PARALLEL( 16) */
      GMO_BRANCH GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = GMO_BRANCH)
          GMO_NAME,
       PO_BRANCH PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PO_BRANCH)
          PO_NAME,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = ACNTS_BRN_CODE)
          BRANCH_NAME,
       TT.*
  FROM (SELECT ACNTS_BRN_CODE,
               facno (1, a.ASSETCLSH_INTERNAL_ACNUM) account_no,
               ACNTS_AC_NAME1 || ACNTS_AC_NAME2 account_name,
               FN_GET_ASON_ACBAL (1,
                                  a.ASSETCLSH_INTERNAL_ACNUM,
                                  'BDT',
                                  '31-dec-2022',
                                  '31-dec-2022')
                  acbal,
               ASSETCLSH_ASSET_CODE ASSET_CODE,
               ASSETCLSH_EFF_DATE
          FROM ASSETCLSHIST a, acnts
         WHERE     ASSETCLSH_AUTO_MAN_FLG = 'M'
               AND ACNTS_INTERNAL_ACNUM = a.ASSETCLSH_INTERNAL_ACNUM
               AND ASSETCLSH_LAST_MOD_BY != 'INTELECT'
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ASSETCLSH_ENTD_BY <> 'MIG'
               AND ASSETCLSH_REMARKS <> 'Auto Reclassification'
               AND ASSETCLSH_EFF_DATE =
                      (SELECT MAX (ASSETCLSH_EFF_DATE)
                         FROM ASSETCLSHIST
                        WHERE     ASSETCLSH_ENTITY_NUM = 1
                              AND ASSETCLSH_EFF_DATE <= '31-dec-2022'
                              AND ASSETCLSH_INTERNAL_ACNUM =
                                     a.ASSETCLSH_INTERNAL_ACNUM)) TT,
       MBRN_TREE1
 WHERE TT.ACNTS_BRN_CODE = BRANCH