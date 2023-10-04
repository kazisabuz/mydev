/* Formatted on 9/28/2022 4:59:46 PM (QP5 v5.388) */
--LATEST

SELECT *
  FROM (SELECT /*+ PARALLEL( 16) */
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
               TT.BR_CODE,
               TT.MBRN_NAME,
               TT.ACC_SUSPENSE_BAL,
               TT.gl_140107101,
               TT.gl_140107102
          FROM (  SELECT MBRN_CODE
                             BR_CODE,
                         MBRN_NAME,
                        nvl( SUM (
                             (SELECT SUM (LNSUSPBAL_SUSP_BAL)
                               FROM acnts, lnsuspbal
                              WHERE     ACNTS_ENTITY_NUM = 1
                                    AND ACNTS_INTERNAL_ACNUM =
                                        LNSUSPBAL_ACNT_NUM
                                    AND ACNTS_INTERNAL_ACNUM NOT IN
                                            (SELECT LNWRTOFF_ACNT_NUM
                                               FROM lnwrtoff
                                              WHERE LNWRTOFF_ENTITY_NUM = 1)
                                    AND ACNTS_BRN_CODE = MBRN_CODE
                                    AND LNSUSPBAL_ENTITY_NUM = 1
                                    AND NVL (LNSUSPBAL_SUSP_BAL, 0) <> 0)),0)
                             ACC_SUSPENSE_BAL,
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
                    FROM MBRN
                GROUP BY MBRN_CODE, MBRN_NAME
                ORDER BY 1) TT,
               MBRN_TREE
         WHERE TT.BR_CODE = BRANCH); -- and GMO_BRANCH IN ( 50995 ,18994));

------------------------------glbbal-----------------
SELECT *
  FROM (SELECT /*+ PARALLEL( 16) */
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
               TT.BR_CODE,
               TT.MBRN_NAME,
               TT.ACC_SUSPENSE_BAL,
               TT.gl_140107101,
               TT.gl_140107102
          FROM (  SELECT MBRN_CODE
                             BR_CODE,
                         MBRN_NAME,
                        nvl( SUM (
                             (SELECT SUM (LNSUSPBAL_SUSP_BAL)
                               FROM acnts, lnsuspbal
                              WHERE     ACNTS_ENTITY_NUM = 1
                                    AND ACNTS_INTERNAL_ACNUM =
                                        LNSUSPBAL_ACNT_NUM
                                    AND ACNTS_INTERNAL_ACNUM NOT IN
                                            (SELECT LNWRTOFF_ACNT_NUM
                                               FROM lnwrtoff
                                              WHERE LNWRTOFF_ENTITY_NUM = 1)
                                    AND ACNTS_BRN_CODE = MBRN_CODE
                                    AND LNSUSPBAL_ENTITY_NUM = 1
                                    AND NVL (LNSUSPBAL_SUSP_BAL, 0) <> 0)),0)
                             ACC_SUSPENSE_BAL,
                        (SELECT GLBBAL_BC_BAL GLBALH_BC_BAL
                 FROM glbbal  
                WHERE     GLBBAL_ENTITY_NUM = 1
                      AND GLBBAL_GLACC_CODE = '140107101'
                      AND GLBBAL_BRANCH_CODE = MBRN_CODE
                      and GLBBAL_YEAR=2023
                      )
                   gl_140107101,
               (SELECT GLBBAL_BC_BAL GLBALH_BC_BAL
                 FROM glbbal
                WHERE     GLBBAL_ENTITY_NUM = 1
                      AND GLBBAL_GLACC_CODE = '140107102'
                      AND GLBBAL_BRANCH_CODE = MBRN_CODE
                       and GLBBAL_YEAR=2023
                       )
                   gl_140107102
                    FROM MBRN
                GROUP BY MBRN_CODE, MBRN_NAME
                ORDER BY 1) TT,
               MBRN_TREE
         WHERE TT.BR_CODE = BRANCH);
-----------ZERO SUSPBAL------------------

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
           MBRN_NAME,
       TT.*
  FROM (SELECT ACNTS_BRN_CODE,
               LNSUSPBAL_ACNT_NUM,
               ACNTS_AC_NAME1 || ACNTS_AC_NAME2     ACCOUNT_NAME,
               LNSUSPBAL_SUSP_BAL
          FROM lnsuspbal, acnts
         WHERE     LNSUSPBAL_ENTITY_NUM = 1
               AND LNSUSPBAL_SUSP_BAL <>0
               AND ACNTS_INTERNAL_ACNUM = LNSUSPBAL_ACNT_NUM
               AND ACNTS_ENTITY_NUM = 1) TT,
       MBRN_TREE1
 WHERE TT.BR_CODE = BRANCH   and GMO_BRANCH IN ( 50995 ,18994);


SELECT *
  FROM (  SELECT /*+ PARALLEL( 16) */
                 BRANCH_GMO
                     GMO_CODE,
                 (SELECT MBRN_NAME
                    FROM MBRN
                   WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_GMO)
                     GMO_NAME,
                 BRANCH_PO
                     PO_CODE,
                 (SELECT MBRN_NAME
                    FROM MBRN
                   WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_PO)
                     PO_NAME,
                 TT.BR_CODE,
                 TT.MBRN_NAME,
                 TT.GL_CODE,
                 TT.ACC_SUSPENSE_BAL,
                 TT.GL_BALANCE,
                 TT.ACC_SUSPENSE_BAL - TT.GL_BALANCE
                     DIFFER
            FROM ( /*+ PARALLEL( 16) */
                  SELECT MBRN_CODE
                             BR_CODE,
                         MBRN_NAME,
                         SUM (
                             (SELECT   SUM (
                                           CASE
                                               WHEN LNSUSP_DB_CR_FLG = 'C'
                                               THEN
                                                   LNSUSP_AMOUNT
                                               ELSE
                                                   0
                                           END)
                                     - SUM (
                                           CASE
                                               WHEN LNSUSP_DB_CR_FLG = 'D'
                                               THEN
                                                   LNSUSP_AMOUNT
                                               ELSE
                                                   0
                                           END)    CR
                               FROM lnsuspLED, acnts
                              WHERE     ACNTS_ENTITY_NUM = 1
                                    AND ACNTS_INTERNAL_ACNUM = LNSUSP_ACNT_NUM
                                    AND LNSUSP_ENTITY_NUM = 1
                                    AND LNSUSP_TRAN_DATE <= '31-DEC-2020'
                                    AND LNSUSP_AUTH_BY IS NOT NULL
                                    -- and ACNTS_CLOSURE_DATE is nulL
                                    AND ACNTS_BRN_CODE = MBRN_CODE))
                             ACC_SUSPENSE_BAL,
                         SUM ( select                     (   NVL          (   GLBALH_BC_BAL, 0)                                                                                                                                                                                                                              )
                    FROM GLBALASONHIST
                   WHERE     GLBALH_ENTITY_NUM = 1
                         AND GLBALH_GLACC_CODE = '140107101'
                         AND GLBALH_BRN_CODE = MBRN_CODE
                         AND GLBALH_ASON_DATE = '31-DEC-2020'
                         --  and MBRN_CODE=26
                         AND GLBALH_BC_BAL <> 0) gl_140107101 FROM         MBRN
        GROUP BY MBRN_CODE, MBRN_NAME
        ORDER BY 1) TT,
       MBRN_TREE2
 WHERE TT.BR_CODE = BRANCH_CODE        )
         where                DIFFER                  <>      0;


 --------------------------------------------------

SELECT /*+ PARALLEL( 8) */
       BRANCH_GMO
           GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_GMO)
           GMO_NAME,
       BRANCH_PO
           PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_PO)
           PO_NAME,
       A.ACNTS_BRN_CODE
           BRANCH_CODE,
       MBRN_NAME
           BRANCH_NAME,
       FACNO (1, LNSUSP_ACNT_NUM)
           ACCOUNT_NUMBER,
       AC_NAME,
       OUTSTANDING_BAL,
       SUSPBAL,
       (SELECT ASSETCLS_ASSET_CODE
         FROM assetcls
        WHERE     ASSETCLS_INTERNAL_ACNUM = LNSUSP_ACNT_NUM
              AND ASSETCLS_ENTITY_NUM = 1)
           ASSET_CODE
  FROM (  SELECT /*+ PARALLEL( 8) */
                 ACNTS_BRN_CODE,
                 LNSUSP_ACNT_NUM,
                 AC_NAME,
                 ABS (FN_GET_ASON_ACBAL (1,
                                         LNSUSP_ACNT_NUM,
                                         'BDT',
                                         '31-DEC-2019',
                                         '23-JAN-2020'))    OUTSTANDING_BAL,
                 SUM (CR_BAL) - SUM (DR_BAL)                SUSPBAL
            FROM (SELECT /*+ PARALLEL( 8) */
                         ACNTS_BRN_CODE,
                         LNSUSP_ACNT_NUM,
                         ACNTS_AC_NAME1 || ACNTS_AC_NAME2    AC_NAME,
                         CASE
                             WHEN LNSUSP_DB_CR_FLG = 'C' THEN LNSUSP_AMOUNT
                             ELSE 0
                         END                                 CR_BAL,
                         CASE
                             WHEN LNSUSP_DB_CR_FLG = 'D' THEN LNSUSP_AMOUNT
                             ELSE 0
                         END                                 DR_BAL
                    FROM LNSUSPLED, ACNTS
                   WHERE     ACNTS_ENTITY_NUM = 1
                         AND ACNTS_INTERNAL_ACNUM = LNSUSP_ACNT_NUM
                         AND LNSUSP_ENTITY_NUM = 1
                         AND ACNTS_CLOSURE_DATE IS NULL)
        GROUP BY ACNTS_BRN_CODE, LNSUSP_ACNT_NUM, AC_NAME) A,
       MBRN_TREE2,
       MBRN
 WHERE     A.ACNTS_BRN_CODE = BRANCH_CODE
       AND A.ACNTS_BRN_CODE = MBRN_CODE
       AND A.SUSPBAL <> 0
       AND OUTSTANDING_BAL >= 1000000;



     ------------SUSPENSE DETAILS-------------------------------

SELECT /*+ PARALLEL( 16) */
       BRANCH_GMO
           GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_GMO)
           GMO_NAME,
       BRANCH_PO
           PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_PO)
           PO_NAME,
       A.ACNTS_BRN_CODE
           BRANCH_CODE,
       MBRN_NAME
           BRANCH_NAME,
       ACNTS_BRN_CODE,
       ACNTS_PROD_CODE,
       FACNO (1, LNSUSP_ACNT_NUM)
           ACCOUNT_NUMBER,
       AC_NAME,
       ACNTS_AC_TYPE,
       Sanction_Date,
       LIMIT_EXPIRY_DATE,
       OUTSTANDING_BAL,
       CL_CODE,
       REPAY_DATE,
       REPAY_AMT,
       SUSPBAL,
       Eligible_Security,
       (SELECT ASSETCLSH_ASSET_CODE
         FROM assetclshist
        WHERE     ASSETCLSH_EFF_DATE =
                  (SELECT MAX (ASSETCLSH_EFF_DATE)
                    FROM assetclshist
                   WHERE     ASSETCLSH_ENTITY_NUM = 1
                         AND ASSETCLSH_INTERNAL_ACNUM = LNSUSP_ACNT_NUM
                         AND ASSETCLSH_EFF_DATE <= '30-jun-2020')
              AND ASSETCLSH_INTERNAL_ACNUM = LNSUSP_ACNT_NUM)
           asset_code
  FROM (  SELECT /*+ PARALLEL( 16) */
                 ACNTS_BRN_CODE,
                 ACNTS_PROD_CODE,
                 LNSUSP_ACNT_NUM,
                 AC_NAME,
                 ACNTS_AC_TYPE,
                 Sanction_Date,
                 LIMIT_EXPIRY_DATE,
                 ABS (FN_GET_ASON_ACBAL (1,
                                         LNSUSP_ACNT_NUM,
                                         'BDT',
                                         '30-jun-2020',
                                         '04-OCT-2020'))    OUTSTANDING_BAL,
                 CL_CODE,
                 REPAY_DATE,
                 REPAY_AMT,
                 SUM (CR_BAL) - SUM (DR_BAL)                SUSPBAL,
                 Eligible_Security
            FROM (SELECT /*+ PARALLEL( 16) */
                         ACNTS_BRN_CODE,
                         ACNTS_PROD_CODE,
                         LNSUSP_ACNT_NUM,
                         ACNTS_AC_NAME1 || ACNTS_AC_NAME2
                             AC_NAME,
                         ACNTS_AC_TYPE,
                         (SELECT LMTLINE_DATE_OF_SANCTION
                            FROM LIMITLINE
                           WHERE     LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
                                 AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM)
                             Sanction_Date,
                         (SELECT LMTLINE_LIMIT_EXPIRY_DATE
                           FROM LIMITLINE
                          WHERE     LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
                                AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM)
                             LIMIT_EXPIRY_DATE,
                         (SELECT LNACRSDTL_REPAY_FROM_DATE
                           FROM LNACRSDTL
                          WHERE     LNACRSDTL_ENTITY_NUM = 1
                                AND LNACRSDTL_ENTITY_NUM = 1
                                AND LNACRSDTL_INTERNAL_ACNUM =
                                    ACNTS_INTERNAL_ACNUM)
                             REPAY_DATE,
                         (SELECT LNACMIS_HO_DEPT_CODE
                           FROM lnacmis
                          WHERE     LNACMIS_INTERNAL_ACNUM =
                                    ACNTS_INTERNAL_ACNUM
                                AND LNACMIS_ENTITY_NUM = 1)
                             CL_CODE,
                         (SELECT LNACRSDTL_REPAY_AMT
                           FROM LNACRSDTL
                          WHERE     LNACRSDTL_ENTITY_NUM = 1
                                AND LNACRSDTL_ENTITY_NUM = 1
                                AND LNACRSDTL_INTERNAL_ACNUM =
                                    ACNTS_INTERNAL_ACNUM)
                             REPAY_AMT,
                         (SELECT SUM (SECRCPT_VALUE_OF_SECURITY)
                           FROM SECRCPT
                          WHERE     SECRCPT_CLIENT_NUM = ACASLLDTL_CLIENT_NUM
                                AND SECRCPT_ENTITY_NUM = 1)
                             Eligible_Security,
                         CASE
                             WHEN LNSUSP_DB_CR_FLG = 'C' THEN LNSUSP_AMOUNT
                             ELSE 0
                         END
                             CR_BAL,
                         CASE
                             WHEN LNSUSP_DB_CR_FLG = 'D' THEN LNSUSP_AMOUNT
                             ELSE 0
                         END
                             DR_BAL
                    FROM LNSUSPLED, ACNTS, ACASLLDTL
                   WHERE     ACNTS_ENTITY_NUM = 1
                         AND ACNTS_INTERNAL_ACNUM = LNSUSP_ACNT_NUM
                         AND ACASLLDTL_ENTITY_NUM = 1
                         AND LNSUSP_ENTITY_NUM = 1
                         AND LNSUSP_ACNT_NUM = ACASLLDTL_INTERNAL_ACNUM
                         AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                         AND ACNTS_OPENING_DATE <= '30-jun-2020'
                         AND (   ACNTS_CLOSURE_DATE IS NULL
                              OR ACNTS_CLOSURE_DATE > '30-jun-2020'))
        GROUP BY ACNTS_BRN_CODE,
                 ACNTS_PROD_CODE,
                 LNSUSP_ACNT_NUM,
                 AC_NAME,
                 ACNTS_AC_TYPE,
                 Sanction_Date,
                 LIMIT_EXPIRY_DATE,
                 cL_CODE,
                 REPAY_DATE,
                 REPAY_AMT,
                 Eligible_Security) A,
       MBRN_TREE2,
       MBRN
 WHERE     A.ACNTS_BRN_CODE = BRANCH_CODE
       AND A.ACNTS_BRN_CODE = MBRN_CODE
       AND A.SUSPBAL <> 0
       AND ACNTS_BRN_CODE = 9035;



--------------

SELECT PRODUCT_CODE,
       PRODUCT_NAME,
       ACCOUNT_TYPE,
       CASE
           WHEN CLIENTS_TYPE_FLG = 'I' THEN 'Individual'
           WHEN CLIENTS_TYPE_FLG = 'C' THEN 'Corporate'
           WHEN CLIENTS_TYPE_FLG = 'J' THEN 'JOINT'
           ELSE NULL
       END    CLIENT_TYPE,
       NO_OF_ACCOUNT
  FROM (  SELECT ACNTS_PROD_CODE                  PRODUCT_CODE,
                 PRODUCT_NAME                     PRODUCT_NAME,
                 ACNTS_AC_TYPE                    ACCOUNT_TYPE,
                 CLIENTS_TYPE_FLG,
                 COUNT (ACNTS_INTERNAL_ACNUM)     NO_OF_ACCOUNT
            FROM PRODUCTS, ACNTS, CLIENTS
           WHERE     CLIENTS_CODE = ACNTS_CLIENT_NUM
                 AND PRODUCT_CODE = ACNTS_PROD_CODE
                 AND ACNTS_OPENING_DATE BETWEEN '01-oct-2019' AND '31-dec-2019'
                 AND ACNTS_PROD_CODE IN (1000,
                                         1005,
                                         1020,
                                         1030,
                                         1096)
                 AND ACNTS_ENTITY_NUM = 1
        GROUP BY ACNTS_PROD_CODE,
                 PRODUCT_NAME,
                 ACNTS_AC_TYPE,
                 CLIENTS_TYPE_FLG)