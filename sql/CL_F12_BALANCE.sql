-----data query-----------------------
SELECT /*+ PARALLEL( 16) */ GMO_BRANCH
           GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = GMO_BRANCH)
           GMO_NAME,
       PO_BRANCH
           PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PO_BRANCH)
           PO_NAME,
       MBRN_CODE,
       MBRN_NAME,
       ABS (CL_BALANCE)
           CL_BALANCE,
       F12_BALANCE,
       ABS (gl_140107101)
           gl_140107101,
       ABS (gl_140107102)
           gl_140107102
  FROM (SELECT MBRN_CODE,
               MBRN_NAME,
               (SELECT SUM (ACBAL)
                  FROM CL_TMP_DATA
                 WHERE     ACNTS_BRN_CODE = MBRN_CODE
                       AND ASON_DATE = '30-sep-2023')
                   CL_BALANCE,
               (SELECT SUM (RPT_HEAD_BAL)
                  FROM statmentofaffairs
                 WHERE     RPT_ENTRY_DATE = '30-sep-2023'
                       AND CASHTYPE = '1'
                       AND RPT_BRN_CODE = MBRN_CODE
                       AND RPT_HEAD_CODE IN
                               (SELECT RPTHDTHDDTL_HEAD_CODE
                                  FROM RPTHEADTHDDTL
                                 WHERE RPTHDTHDDTL_TOTAL_HEAD_CODE = 'TK'))
                   F12_BALANCE,
               (SELECT GLBALH_BC_BAL
                 FROM GLBALASONHIST
                WHERE     GLBALH_ENTITY_NUM = 1
                      AND GLBALH_GLACC_CODE = '140107101'
                      AND GLBALH_BRN_CODE = MBRN_CODE
                      AND GLBALH_ASON_DATE = '30-sep-2023')
                   gl_140107101,
               (SELECT GLBALH_BC_BAL
                 FROM GLBALASONHIST
                WHERE     GLBALH_ENTITY_NUM = 1
                      AND GLBALH_GLACC_CODE = '140107102'
                      AND GLBALH_BRN_CODE = MBRN_CODE
                      AND GLBALH_ASON_DATE = '30-sep-2023')
                   gl_140107102
          FROM MBRN) TT,
       MBRN_TREE
 WHERE TT.MBRN_CODE = BRANCH AND GMO_BRANCH IN (50995,18994,46995,6999,56993);


--------mismatch find--------

SELECT GMO_BRANCH
           GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = GMO_BRANCH)
           GMO_NAME,
       PO_BRANCH
           PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PO_BRANCH)
           PO_NAME,
       branch_code,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = branch_code)
           branch_name,
       facno (1, ACNTS_INTERNAL_ACNUM)
           account_no,
       ACNTS_AC_TYPE,
       ACBAL
  FROM (SELECT ACNTS_BRN_CODE                       branch_code,
               ACNTS_PROD_CODE,
               ACNTS_INTERNAL_ACNUM,
               ACNTS_AC_TYPE,
               fn_get_ason_acbal (1,
                                  ACNTS_INTERNAL_ACNUM,
                                  'BDT',
                                  '30-sep-2023',
                                  '30-sep-2023')    ACBAL
          FROM acnts, products, lnwrtoff
         WHERE     ACNTS_PROD_CODE = PRODUCT_CODE
               AND ACNTS_ENTITY_NUM = 1
               AND ACNTS_BRN_CODE IN (18010,
                                      19018,
                                      19109,
                                      19117,
                                      50039,
                                      50062,
                                      52027,
                                      52035,
                                      52050,
                                      52084)
               AND PRODUCT_FOR_LOANS = 1
               AND LNWRTOFF_ENTITY_NUM = 1
               AND LNWRTOFF_ACNT_NUM = ACNTS_INTERNAL_ACNUM
               AND ACNTS_CLOSURE_DATE IS NULL
               AND fn_get_ason_acbal (1,
                                      ACNTS_INTERNAL_ACNUM,
                                      'BDT',
                                      '30-sep-2023',
                                      '30-sep-2023') < 0) tt,
       MBRN_TREE1
 WHERE tt.branch_code = BRANCH;

SELECT *
  FROM (SELECT ACNTS_CLOSURE_DATE,
               ACNTS_INTERNAL_ACNUM,
               FN_GET_ASON_ACBAL (1,
                                  ACNTS_INTERNAL_ACNUM,
                                  'BDT',
                                  '31-DEC-2020',
                                  '29-MAR-2021')    ACNTBAL_BC_BAL,
               FN_GET_ASON_ACBAL (1,
                                  ACNTS_INTERNAL_ACNUM,
                                  'BDT',
                                  '29-mar-2021',
                                  '29-MAR-2021')    CURRBAL
          FROM LOANACNTS, ACNTS
         WHERE     ACNTS_INTERNAL_ACNUM = LNACNT_INTERNAL_ACNUM
               AND ACNTS_ENTITY_NUM = 1
               AND ACNTS_BRN_CODE = 62018
               AND ACNTS_CLOSURE_DATE IS NOT NULL)
 WHERE ACNTBAL_BC_BAL < 0