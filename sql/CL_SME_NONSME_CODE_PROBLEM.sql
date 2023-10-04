/* Formatted on 7/5/2023 4:29:17 PM (QP5 v5.388) */
--02 List of Loan Accounts which are reported in  CL2(1), CL3(1) or CL4(1) but SME-Non SME Code are  99-91

SELECT /*+ PARALLEL( 16) */
       GMO_BRANCH
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
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = ACNTS_BRN_CODE)
           mbrn_name,
       tt.*
  FROM (SELECT ACNTS_BRN_CODE,
               facno (1, ACNTS_INTERNAL_ACNUM)     account_no,
               ACNTS_AC_NAME1                      account_name,
               LNACMIS_HO_DEPT_CODE                CL_REPORT_CODE,
               LNACMIS_NATURE_BORROWAL_AC          SME_NONSME_CODE
          FROM lnacmis, acnts
         WHERE     TRIM (LNACMIS_HO_DEPT_CODE) IN ('CL21', 'CL31', 'CL41')
               AND LNACMIS_ENTITY_NUM = 1
               AND (   TRIM (LNACMIS_NATURE_BORROWAL_AC) IN ('99', '91')
                    OR TRIM (LNACMIS_NATURE_BORROWAL_AC) IS NULL)
               AND LNACMIS_ENTITY_NUM = 1
               AND LNACMIS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_ENTITY_NUM = 1) tt,
       MBRN_TREE
 WHERE TT.ACNTS_BRN_CODE = BRANCH;
 


--04. List of Loan Accounts which are reported  except  the CL2(1), CL3(1) or CL4(1) but SME-Non SME Code are 11,12,13,21,22,23,31,32,33 & 43

SELECT /*+ PARALLEL( 16) */
       GMO_BRANCH
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
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = ACNTS_BRN_CODE)
           mbrn_name,
       tt.*
  FROM (SELECT ACNTS_BRN_CODE,
               PRODUCT_CODE,
               PRODUCT_NAME,
               facno (1, ACNTS_INTERNAL_ACNUM)     account_no,
               ACNTS_AC_NAME1                      account_name,
               LNACMIS_HO_DEPT_CODE                CL_REPORT_CODE,
               LNACMIS_NATURE_BORROWAL_AC          SME_NONSME_CODE
          FROM lnacmis, acnts, products
         WHERE     TRIM (LNACMIS_HO_DEPT_CODE) NOT IN ('CL21', 'CL31','CL41')
               AND LNACMIS_ENTITY_NUM = 1
               AND LNACMIS_ENTITY_NUM = 1
               AND LNACMIS_NATURE_BORROWAL_AC IN (11,12,13,21,22,23,31,32,33 , 43)
               AND PRODUCT_CODE = ACNTS_PROD_CODE
               AND LNACMIS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_ENTITY_NUM = 1) tt,
       MBRN_TREE
 WHERE TT.ACNTS_BRN_CODE = BRANCH;


 --06.A/C wise details with Branch, PO, GMO Name who reported Consumer financing (2034 ) in CL-2(ii).

SELECT /*+ PARALLEL( 16) */
       GMO_BRANCH
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
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = ACNTS_BRN_CODE)
           mbrn_name,
       tt.*
  FROM (SELECT ACNTS_BRN_CODE,
               PRODUCT_CODE,
               PRODUCT_NAME,
               facno (1, ACNTS_INTERNAL_ACNUM)     account_no,
               ACNTS_AC_NAME1                      account_name,
               LNACMIS_HO_DEPT_CODE                CL_REPORT_CODE,
               LNACMIS_NATURE_BORROWAL_AC          SME_NONSME_CODE
          FROM lnacmis, acnts, products
         WHERE     TRIM (LNACMIS_HO_DEPT_CODE) not IN ('CL42')
               AND LNACMIS_ENTITY_NUM = 1
               AND LNACMIS_ENTITY_NUM = 1
               AND PRODUCT_CODE = ACNTS_PROD_CODE
               AND ACNTS_PROD_CODE = 2034
               AND LNACMIS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_ENTITY_NUM = 1) tt,
       MBRN_TREE
 WHERE TT.ACNTS_BRN_CODE = BRANCH;



  --06.A/C wise details with Branch, PO, GMO Name who reported Consumer financing in CL-4(v).

SELECT /*+ PARALLEL( 16) */
       GMO_BRANCH
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
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = ACNTS_BRN_CODE)
           mbrn_name,
       tt.*
  FROM (SELECT ACNTS_BRN_CODE,
               PRODUCT_CODE,
               PRODUCT_NAME,
               facno (1, ACNTS_INTERNAL_ACNUM)     account_no,
               ACNTS_AC_NAME1                      account_name,
               LNACMIS_HO_DEPT_CODE                CL_REPORT_CODE,
               LNACMIS_NATURE_BORROWAL_AC          SME_NONSME_CODE
          FROM lnacmis, acnts, products
         WHERE     TRIM (LNACMIS_HO_DEPT_CODE) IN ('CL45')
               AND LNACMIS_ENTITY_NUM = 1
               AND LNACMIS_ENTITY_NUM = 1
               AND PRODUCT_CODE = ACNTS_PROD_CODE
               -- and ACNTS_PROD_CODE=2034
               AND LNACMIS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_ENTITY_NUM = 1) tt,
       MBRN_TREE
 WHERE TT.ACNTS_BRN_CODE = BRANCH;



  --06.A/C wise details with Branch, PO, GMO Name who reported Consumer financing (  ) in CL22','CL23','CL32','CL33'.

SELECT /*+ PARALLEL( 16) */
       GMO_BRANCH
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
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = ACNTS_BRN_CODE)
           mbrn_name,
       tt.*
  FROM (SELECT ACNTS_BRN_CODE,
               PRODUCT_CODE,
               PRODUCT_NAME,
               facno (1, ACNTS_INTERNAL_ACNUM)     account_no,
               ACNTS_AC_NAME1                      account_name,
               LNACMIS_HO_DEPT_CODE                CL_REPORT_CODE,
               LNACMIS_NATURE_BORROWAL_AC          SME_NONSME_CODE
          FROM lnacmis, acnts, products
         WHERE     TRIM (LNACMIS_HO_DEPT_CODE) IN ('CL22',
                                                   'CL23',
                                                   'CL32',
                                                   'CL33')
               AND LNACMIS_ENTITY_NUM = 1
               AND LNACMIS_ENTITY_NUM = 1
               AND PRODUCT_CODE = ACNTS_PROD_CODE
               AND LNACMIS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_ENTITY_NUM = 1) tt,
       MBRN_TREE
 WHERE TT.ACNTS_BRN_CODE = BRANCH;