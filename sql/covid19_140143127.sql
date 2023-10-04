/* Formatted on 4/29/2021 11:42:46 AM (QP5 v5.252.13127.32867) */
SELECT GMO_BRANCH GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = GMO_BRANCH)
          GMO_NAME,
       PO_BRANCH PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PO_BRANCH)
          PO_NAME,
       BRANCH_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = TT.BRANCH_CODE)
          BRANCH_NAME,
       ACC_NO,
       ACCOUNT_NAME,
       WAIVED_INTEREST_AMOUNT,
       ACCOUNT_STATUS
  FROM (  SELECT IACLINK_BRN_CODE BRANCH_CODE,
                 MBRN_NAME,
                 ACC_NO,
                 ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
                   (WAIVED_INTEREST_AMOUNT) WAIVED_INTEREST_AMOUNT,
                 CASE
                    WHEN ACNTS_CLOSURE_DATE IS NULL THEN 'Open'
                    ELSE 'Closed'
                 END
                    ACCOUNT_STATUS,ASSETCLS_ASSET_CODE
            FROM COVID_SBL_DATA,
                 IACLINK,
                 MBRN,
                 ACNTS,assetcls
           WHERE     ACC_NO NOT IN (SELECT FACNO (1, ACBLK_INTERNAL_ACNUM)
                                      FROM ACBLKCOVID
                                     WHERE ACBLK_ENTITY_NUM = 1)
                 AND IACLINK_ENTITY_NUM = 1
                 AND ACNTS_INTERNAL_ACNUM = IACLINK_INTERNAL_ACNUM
                 AND ACNTS_ENTITY_NUM = 1
                 AND IACLINK_ACTUAL_ACNUM = ACC_NO
              --   AND ACNTS_CLOSURE_DATE <= '03-mar-2021'
               --AND ACNTS_BRN_CODE = 26
                 and ASSETCLS_INTERNAL_ACNUM=ACNTS_INTERNAL_ACNUM
                 and ASSETCLS_ENTITY_NUM=1
                 AND IACLINK_BRN_CODE = Mbrn_CODE
       ) TT,
       MBRN_TREE1
 WHERE TT.BRANCH_CODE = BRANCH
 