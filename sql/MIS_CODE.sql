
SELECT BRANCH_GMO GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_GMO)
          GMO_NAME,
       BRANCH_PO PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_PO)
          PO_NAME, (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = TT.ACNTS_BRN_CODE)
          BRANCH_NAME,
       tt.* from (
SELECT  /*+ PARALLEL( 8) */ ACNTS_BRN_CODE,
       ACNTS_PROD_CODE,
       facno (1, LNACNT_INTERNAL_ACNUM) account_no,
       ACNTS_AC_NAME1 || ' ' || ACNTS_AC_NAME2 account_name,
       ACNTS_AC_TYPE
  FROM loanacnts, acnts
 WHERE     LNACNT_ENTITY_NUM = 1
 AND ACNTS_ENTITY_NUM=1
      --  AND ACNTS_BRN_CODE = 26
       AND LNACNT_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND ACNTS_CLOSURE_DATE IS NULL
       AND NOT EXISTS
              (SELECT 1
                 FROM lnacmis
                WHERE    LNACMIS_INTERNAL_ACNUM=LNACNT_INTERNAL_ACNUM AND LNACMIS_ENTITY_NUM=1))
                TT,
       MBRN_TREE2
 WHERE TT.ACNTS_BRN_CODE = BRANCH_CODE;