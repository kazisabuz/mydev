/* Formatted on 3/16/2022 2:26:38 PM (QP5 v5.252.13127.32867) */
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
       BRANCH_PO PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = ACNTS_BRN_CODE)
          BRANCH_NAME,
       A.*
  FROM (SELECT /*+ PARALLEL( 16) */
              ACNTS_BRN_CODE,
               ACNTS_PROD_CODE,
               PRODUCT_NAME,
               FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NO,
               ACNTS_AC_NAME1 || ACNTS_AC_NAME2 AC_NAME,
               ACNTS_AC_TYPE,
               (SELECT LMTLINE_DATE_OF_SANCTION
                  FROM LIMITLINE
                 WHERE     LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
                       AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM)
                  SANCTION_DATE,
               (SELECT LMTLINE_LIMIT_EXPIRY_DATE
                  FROM LIMITLINE
                 WHERE     LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
                       AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM)
                  LIMIT_EXPIRY_DATE,
               (SELECT LNACRSDTL_REPAY_FROM_DATE
                  FROM LNACRSDTL
                 WHERE     LNACRSDTL_ENTITY_NUM = 1
                       AND LNACRSDTL_ENTITY_NUM = 1
                       AND LNACRSDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM)
                  REPAY_DATE,
               (SELECT LNACRSDTL_REPAY_AMT
                  FROM LNACRSDTL
                 WHERE     LNACRSDTL_ENTITY_NUM = 1
                       AND LNACRSDTL_ENTITY_NUM = 1
                       AND LNACRSDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM)
                  REPAY_AMT,
               GET_SECURED_VALUE (ACNTS_INTERNAL_ACNUM,
                                  '29-nov-2021',
                                  '30-nov-2021',
                                  'BDT')
                  ELIGIBLE_SECURITY,
               FN_GET_SUSPBAL (1, ACNTS_INTERNAL_ACNUM, '29-nov-2021')
                  SUSPBAL,
               ABS (FN_GET_ASON_ACBAL (1,
                                       ACNTS_INTERNAL_ACNUM,
                                       'BDT',
                                       '29-nov-2021',
                                       '30-nov-2021'))
                  OUTSTANDING_BAL,
               (SELECT LNACMIS_HO_DEPT_CODE
                  FROM LNACMIS
                 WHERE     LNACMIS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                       AND LNACMIS_ENTITY_NUM = 1)
                  CL_CODE,
               (SELECT ASSETCLS_ASSET_CODE
                  FROM ASSETCLS
                 WHERE     ASSETCLS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                       AND ASSETCLS_ENTITY_NUM = 1)
                  ASSET_CODE,
               FN_GET_WRITEOFF_BAL (1,
                                    ACNTS_INTERNAL_ACNUM,
                                    '29-nov-2021',               ----ason date
                                    'O')
                  WRITEOFF_BAL,
               FN_GET_WRITEOFF_BAL (1,
                                    ACNTS_INTERNAL_ACNUM,
                                    '29-nov-2021',               ----ason date
                                    'P')
                  WRITEOFF_PRIN,
               FN_GET_WRITEOFF_BAL (1,
                                    ACNTS_INTERNAL_ACNUM,
                                    '29-nov-2021',               ----ason date
                                    'I')
                  WRITEOFF_INT,
               FN_GET_WRITEOFF_BAL (1,
                                    ACNTS_INTERNAL_ACNUM,
                                    '29-nov-2021',               ----ason date
                                    'C')
                  WRITEOFF_CHARGE
          FROM PRODUCTS, ACNTS, ACASLLDTL
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACASLLDTL_ENTITY_NUM = 1
               AND PRODUCT_CODE = ACNTS_PROD_CODE
               --  AND ACNTS_BRN_CODE = 10090
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACNTS_PROD_CODE IN (2401,
                                       2402,
                                       2403,
                                       2404,
                                       2405,
                                       2406,
                                       2407,
                                       2408,
                                       2409,
                                       2410,
                                       2411)) A,
       MBRN_TREE2
 WHERE A.ACNTS_BRN_CODE = BRANCH_CODE;


 ------BB AUDIT FOR MIS----
-------INTEREST APPLY DATA

 BEGIN
   FOR IDX IN (  SELECT *
                   FROM MIG_DETAIL
               ORDER BY 1)
   LOOP
      INSERT INTO BACKUPTABLE.BRPD_DATA
         SELECT BRANCH_CODE,
                (SELECT MBRN_NAME
                   FROM MBRN
                  WHERE MBRN_CODE = BRANCH_CODE)
                   BRANCH_NAME,
                FACNO (1, LOANIA_ACNT_NUM) ACCOUNT_NO,
                ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
                ABS (FN_GET_ASON_ACBAL (1,
                                        LOANIA_ACNT_NUM,
                                        'BDT',
                                        '31-DEC-2022',
                                         '31-DEC-2022'))
                   OUTSTANDING_BALANCE,
                (SELECT SUM (AMOUNT)
                   FROM TABLE (PKG_LOAN_ACC_STMT.LOAN_ACC_STMT (
                                  1,
                                  BRANCH_CODE,
                                  LOANIA_ACNT_NUM,
                                  'BDT',
                                  '01-JAN-2022',
                                  '31-DEC-2022'))
                  WHERE DB_CR = 'C')
                   ACTUAL_RECOVERY_AMOUNT,
                APPLIED_INTEREST,
                APPLIED_INTEREST_INCOME,
                APPLIED_INTEREST_SUSPENSE
           FROM (  SELECT LOANIA_BRN_CODE BRANCH_CODE,
                          LOANIA_ACNT_NUM,
                          SUM (LOANIA_INT_AMT_RND) APPLIED_INTEREST,
                          SUM (
                             CASE
                                WHEN LOANIA_NPA_STATUS = 0
                                THEN
                                   LOANIA_INT_AMT_RND
                                ELSE
                                   0
                             END)
                             APPLIED_INTEREST_INCOME,
                          SUM (
                             CASE
                                WHEN LOANIA_NPA_STATUS = 1
                                THEN
                                   LOANIA_INT_AMT_RND
                                ELSE
                                   0
                             END)
                             APPLIED_INTEREST_SUSPENSE
                     FROM ACC5, IACLINK, LOANIA
                    WHERE     IACLINK_ENTITY_NUM = 1
                          AND IACLINK_ACTUAL_ACNUM = ACC_NO
                          AND IACLINK_INTERNAL_ACNUM = LOANIA_ACNT_NUM
                          AND LOANIA_ENTITY_NUM = 1
                          
                          AND LOANIA_ACCRUAL_DATE >= '01-JAN-2022'
                          AND LOANIA_BRN_CODE = IDX.BRANCH_CODE
                 GROUP BY LOANIA_ACNT_NUM, LOANIA_BRN_CODE),
                ACNTS
          WHERE     LOANIA_ACNT_NUM = ACNTS_INTERNAL_ACNUM
          AND ACNTS_OPENING_DATE <= '31-dec-2022'
                          AND (   ACNTS_CLOSURE_DATE IS NULL
                               OR ACNTS_CLOSURE_DATE > '31-dec-2022')
                AND ACNTS_ENTITY_NUM = 1;

      COMMIT;
   END LOOP;
END;


INSERT INTO BACKUPTABLE.BRPD_DATA
   SELECT ACNTS_BRN_CODE BRANCH_CODE,
          (SELECT MBRN_NAME
             FROM MBRN
            WHERE MBRN_CODE = ACNTS_BRN_CODE)
             BRANCH_NAME,
          ACC_NO ACCOUNT_NO,
          ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
          ABS (FN_GET_ASON_ACBAL (1,
                                  ACNTS_INTERNAL_ACNUM,
                                  'BDT',
                                  '31-dec-2022',
                                  '31-dec-2022'))
             OUTSTANDING_BALANCE,
          (SELECT SUM (AMOUNT)
             FROM TABLE (PKG_LOAN_ACC_STMT.LOAN_ACC_STMT (
                            1,
                            ACNTS_BRN_CODE,
                            ACNTS_INTERNAL_ACNUM,
                            'BDT',
                            '01-JAN-2021',
                            '31-DEC-2022'))
            WHERE DB_CR = 'C')
             ACTUAL_RECOVERY_AMOUNT,
          0 APPLIED_INTEREST,
          0 APPLIED_INTEREST_INCOME,
          0 APPLIED_INTEREST_SUSPENSE
     FROM (SELECT ACC_NO FROM ACC5
           MINUS
           SELECT ACCOUNT_NO FROM BACKUPTABLE.BRPD_DATA),
          IACLINK,
          ACNTS
    WHERE     ACC_NO = IACLINK_ACTUAL_ACNUM
          AND IACLINK_ENTITY_NUM = 1
          AND ACNTS_OPENING_DATE <= '31-dec-2021'
          AND (   ACNTS_CLOSURE_DATE IS NULL
               OR ACNTS_CLOSURE_DATE > '31-dec-2021')
          AND IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
          AND ACNTS_ENTITY_NUM = 1;


  -----WRITE-OFF AC LEVEL DATA------------------------------

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
       BRANCH_PO PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = ACNTS_BRN_CODE)
          BRANCH_NAME,
       A.*
  FROM (SELECT /*+ PARALLEL( 16) */
              ACNTS_BRN_CODE,
               ACNTS_PROD_CODE,
               PRODUCT_NAME,
               FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NO,
               ACNTS_AC_NAME1 || ACNTS_AC_NAME2 AC_NAME,
               ACNTS_AC_TYPE,
               FN_GET_WRITEOFF_BAL (1,
                                    ACNTS_INTERNAL_ACNUM,
                                    '31-DEC-2021',               ----ason date
                                    'O')
                  WRITEOFF_BAL,
               FN_GET_WRITEOFF_BAL (1,
                                    ACNTS_INTERNAL_ACNUM,
                                    '31-DEC-2021',               ----ason date
                                    'P')
                  WRITEOFF_PRIN,
               FN_GET_WRITEOFF_BAL (1,
                                    ACNTS_INTERNAL_ACNUM,
                                    '31-DEC-2021',               ----ason date
                                    'I')
                  WRITEOFF_INT,
               FN_GET_WRITEOFF_BAL (1,
                                    ACNTS_INTERNAL_ACNUM,
                                    '31-DEC-2021',               ----ason date
                                    'C')
                  WRITEOFF_CHARGE
          FROM PRODUCTS, ACNTS, LNWRTOFF
         WHERE     ACNTS_ENTITY_NUM = 1
               -- AND ACNTS_BRN_CODE = 10090
               AND PRODUCT_CODE = ACNTS_PROD_CODE
               AND ACNTS_OPENING_DATE <= '31-dec-2021'
               AND (   ACNTS_CLOSURE_DATE IS NULL
                    OR ACNTS_CLOSURE_DATE > '31-dec-2021')
               -- AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_INTERNAL_ACNUM = LNWRTOFF_ACNT_NUM) A,
       MBRN_TREE2
 WHERE A.ACNTS_BRN_CODE = BRANCH_CODE AND NVL (WRITEOFF_BAL, 0) <> 0;


-----WRITE-OFF GL LEVEL DATA-------------

SELECT (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = GMO_BRANCH)
          GMO_NAME,
       GMO_BRANCH,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PO_BRANCH)
          PO_NAME,
       PO_BRANCH,
       TT.*
  FROM (SELECT MBRN_CODE,
               MBRN_NAME,
               '516101102' GL_CODE,
               'Written off Loans A/C s as per Contra(Cr)(Block)' GL_NAME,
               FN_BIS_GET_ASON_GLBAL (1,
                                      MBRN_CODE,
                                      '516101102',
                                      'BDT',
                                      '31-DEC-2021',
                                      '14-FEB-2022')
                  GLBAL
          FROM MBRN) TT,
       MBRN_TREE1 MB
 WHERE TT.MBRN_CODE = MB.BRANCH AND GLBAL <> 0;


-----SUSPENSE TO INCOME GL----------------------

  SELECT GLSUM_BRANCH_CODE BRANCH_CODE,
         GLSUM_GLACC_CODE GLACC_CODE,
         (SELECT EXTGL_EXT_HEAD_DESCN
            FROM EXTGL
           WHERE EXTGL_ACCESS_CODE = GLSUM_GLACC_CODE)
            GL_NAME,
         SUM (TRAN_AMOUNT) TRAN_AMOUNT
    FROM (SELECT GLSUM_BRANCH_CODE,
                 GLSUM_GLACC_CODE,
                 GLSUM_BC_DB_SUM TRAN_AMOUNT
            FROM GLSUM2021
           WHERE GLSUM_GLACC_CODE = '140107101'
          UNION ALL
          SELECT GLSUM_BRANCH_CODE,
                 GLSUM_GLACC_CODE,
                 GLSUM_BC_CR_SUM TRAN_AMOUNT
            FROM GLSUM2021
           WHERE GLSUM_GLACC_CODE = '300137113')
GROUP BY GLSUM_BRANCH_CODE, GLSUM_GLACC_CODE
ORDER BY GLSUM_BRANCH_CODE, GLSUM_GLACC_CODE;

------ACCOUNT LEVEL SUSPENSE DETAILS----------------

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
       BRANCH_PO PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = ACNTS_BRN_CODE)
          BRANCH_NAME,
       A.*
  FROM (  SELECT ACNTS_BRN_CODE,
                 ACNTS_PROD_CODE,
                 ACNTS_AC_TYPE,
                 FACNO (1, LNSUSPREC_INTERNAL_ACNUM) ACCOUNT_NO,
                 ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
                 SUM (LNSUSPREC_INT_AMT) RECOVERD_AMOUNT
            FROM LNSUSPREC@DR, ACNTS@DR
           WHERE     LNSUSPREC_ENTITY_NUM = 1
                 AND LNSUSPREC_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                 AND ACNTS_ENTITY_NUM = 1
                 AND POST_TRAN_BRN = ACNTS_BRN_CODE
                 AND ACNTS_OPENING_DATE <= '31-dec-2021'
                 AND (   ACNTS_CLOSURE_DATE IS NULL
                      OR ACNTS_CLOSURE_DATE > '31-dec-2021')
                 AND ACNTS_BRN_CODE = 1057
                 AND LNSUSPREC_ENTRY_DATE BETWEEN '01-JAN-2021'
                                              AND '31-dec-2021'
                 AND LNSUSPREC_AUTH_BY IS NOT NULL
        GROUP BY ACNTS_BRN_CODE,
                 ACNTS_PROD_CODE,
                 LNSUSPREC_INTERNAL_ACNUM,
                 ACNTS_AC_NAME1 || ACNTS_AC_NAME2,
                 ACNTS_AC_TYPE) A,
       MBRN_TREE2@DR
 WHERE A.ACNTS_BRN_CODE = BRANCH_CODE;



 ------------------LIMIT RENEWAL DATA--------------------------

SELECT ACNTS_BRN_CODE BRANCH_CODE,
       (SELECT mbrn_name
          FROM mbrn
         WHERE mbrn_code = ACNTS_BRN_CODE)
          BRANCH_NAME,
       ACNTS_INTERNAL_ACNUM ACCOUNT_NUMBER,
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
       LIMLNEHIST_LIMIT_LINE_NUM LIMIT_NUMBER,
       LIMLNEHIST_EFF_DATE EFFECTIVE_DATE,
       LIMLNEHIST_SANCTION_AMT RENEWAL_AMOUNT,
       LIMLNEHIST_LIMIT_EXPIRY_DATE LIMIT_EXPIRY_DATE
  FROM LIMITLINEHIST, ACASLLDTL, ACNTS
 WHERE     ACASLLDTL_CLIENT_NUM = LIMLNEHIST_CLIENT_CODE
       AND ACASLLDTL_LIMIT_LINE_NUM = LIMLNEHIST_LIMIT_LINE_NUM
       AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND LIMLNEHIST_ENTITY_NUM = 1
       AND ACASLLDTL_ENTITY_NUM = 1
       AND ACNTS_ENTITY_NUM = 1
       AND ACNTS_OPENING_DATE <= '31-dec-2021'
       AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE > '31-dec-2021')
       -- AND ACNTS_BRN_CODE=6064
       AND (LIMLNEHIST_CLIENT_CODE,
            LIMLNEHIST_LIMIT_LINE_NUM,
            LIMLNEHIST_EFF_DATE) IN (SELECT LIMLNEHIST_CLIENT_CODE,
                                            LMTLINE_NUM,
                                            LIMLNEHIST_EFF_DATE
                                       FROM (  SELECT LIMLNEHIST_CLIENT_CODE,
                                                      LIMLNEHIST_LIMIT_LINE_NUM
                                                         LMTLINE_NUM,
                                                      MAX (LIMLNEHIST_EFF_DATE)
                                                         LIMLNEHIST_EFF_DATE,
                                                      COUNT (*) SL_NO
                                                 FROM LIMITLINEHIST
                                                WHERE LIMLNEHIST_AUTH_BY
                                                         IS NOT NULL
                                             GROUP BY LIMLNEHIST_CLIENT_CODE,
                                                      LIMLNEHIST_LIMIT_LINE_NUM
                                               HAVING COUNT (*) > 1)
                                      WHERE LIMLNEHIST_EFF_DATE BETWEEN '01-jan-2021'
                                                                    AND '31-dec-2021');

 -------------CODE WISE GL BALANCE---------------------------------

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
  FROM (  SELECT MBRN_CODE BR_CODE,
                 MBRN_NAME,
                 GLBALH_GLACC_CODE,
                 EXTGL_EXT_HEAD_DESCN,
                 RPTHDGLDTL_CODE,
                 NVL (GLBALH_BC_BAL, 0) OUTSTANDING_BALANCE
            FROM GLBALASONHIST,
                 RPTHEADGLDTL H,
                 EXTGL,
                 MBRN
           WHERE     RPTHDGLDTL_GLACC_CODE = GLBALH_GLACC_CODE
                 AND GLBALH_ENTITY_NUM = 1
                 AND GLBALH_BRN_CODE = MBRN_CODE
                 AND GLBALH_BRN_CODE = 1024
                 AND GLBALH_ASON_DATE = '31-DEC-2021'
                 AND GLBALH_GLACC_CODE = EXTGL_ACCESS_CODE
                 AND GLBALH_BC_BAL <> 0
                 --AND GLBALH_ASON_DATE = '31-AUG-2018'
                 AND H.RPTHDGLDTL_CODE IN (SELECT RPTLAYOUTDTL_RPT_HEAD_CODE
                                             FROM RPTLAYOUTDTL
                                            WHERE RPTLAYOUTDTL_RPT_CODE =
                                                     'F12')
                 AND RPTHDGLDTL_CODE IN ('A0801', 'A0903', 'A0905', 'A0910')
        ORDER BY 1) TT,
       MBRN_TREE2
 WHERE TT.BR_CODE = BRANCH_CODE;

 ---------------RPT CODE WISE ACC LEVEL INTEREST CA FIRM---------------------------------------------------


   SELECT LOANIA_BRN_CODE,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_CODE = LOANIA_BRN_CODE)
            MBRN_NAME,
         P.PRODUCT_NAME,
         P.PRODUCT_CODE,
         RPTHDGLDTL_CODE,
         ASSETCD_CODE,
         FACNO (1, LOANIA_ACNT_NUM) AS LOANIA_ACNT_NUM,
         (A.ACNTS_AC_NAME1 || A.ACNTS_AC_NAME2) ACNAME,
         COUNT (LOANIA_VALUE_DATE) AS NO_OF_DAYS,
         MIN (LOANIA_VALUE_DATE),
         MAX (LOANIA_VALUE_DATE),
         LOANIA_INT_RATE,
         AD.ASSETCD_CODE ASSET_CODE,
         LOANIA_INT_AMT_RND * COUNT (LOANIA_VALUE_DATE)   AS TOTAL_INTEREST_INCOME
     FROM LOANIA,
         ASSETCD AD,
         ASSETCLS AL,
         ACNTS A,
         PRODUCTS P,
         RPTHEADGLDTL,
         lnprodacpm
   WHERE     AL.ASSETCLS_ASSET_CODE = AD.ASSETCD_CODE
         AND P.PRODUCT_CODE = A.ACNTS_PROD_CODE
         AND LOANIA_ACNT_NUM = AL.ASSETCLS_INTERNAL_ACNUM
         AND A.ACNTS_INTERNAL_ACNUM = AL.ASSETCLS_INTERNAL_ACNUM
         AND ACNTS_PROD_CODE = LNPRDAC_PROD_CODE
         AND RPTHDGLDTL_CODE IN('I0103', 'I0112', 'I0242', 'I0120', 'I0123')
         AND   RPTHDGLDTL_GLACC_CODE = LNPRDAC_INT_INCOME_GL
         AND LOANIA_ENTITY_NUM = 1
         AND LOANIA_BRN_CODE = 36137
         AND LOANIA_NPA_STATUS = 0
         AND AL.ASSETCLS_ENTITY_NUM = 1
         AND LOANIA_VALUE_DATE BETWEEN '01-jan-2021' AND '31-dec-2021'
GROUP BY LOANIA_ACNT_NUM,
         (A.ACNTS_AC_NAME1 || A.ACNTS_AC_NAME2),
         LOANIA_ACNT_BAL,
         ASSETCD_CODE,
         LOANIA_INT_RATE,
         LOANIA_BRN_CODE,
         LOANIA_INT_AMT_RND,
         AD.ASSETCD_CODE,LOANIA_NPA_STATUS,
         LOANIA_ACNT_CURR,
         P.PRODUCT_NAME,RPTHDGLDTL_CODE,
         P.PRODUCT_CODE union all
SELECT ACNTS_BRN_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_CODE = ACNTS_BRN_CODE)
          MBRN_NAME,
       P.PRODUCT_NAME,
       P.PRODUCT_CODE,
       'I0232' RPTHDGLDTL_CODE,
       NULL ASSETCD_CODE,
       FACNO (1, ACNTS_INTERNAL_ACNUM) AS LOANIA_ACNT_NUM,
       (A.ACNTS_AC_NAME1 || A.ACNTS_AC_NAME2) ACNAME,
       NULL NO_OF_DAYS,
       NULL LOANIA_VALUE_DATE,
       NULL LOANIA_VALUE_DATE,
       NULL LOANIA_INT_RATE,
       NULL ASSET_CODE,
       SUM (NVL (LNWRTOFFREC_RECOV_AMT, 0)) AS TOTAL_INTEREST_INCOME
  FROM lnwrtoffrecov, ACNTS A, PRODUCTS P
 WHERE     LNWRTOFFREC_ENTITY_NUM = 1
       AND ACNTS_ENTITY_NUM = 1
       AND LNWRTOFFREC_LN_ACNUM = ACNTS_INTERNAL_ACNUM
       AND P.PRODUCT_CODE = A.ACNTS_PROD_CODE
       AND a.ACNTS_BRN_CODE = 36137
       AND LNWRTOFFREC_ENTRY_DATE BETWEEN '01-jan-2021' AND '31-dec-2021'
       AND LNWRTOFFREC_AUTH_BY IS NOT NULL
       GROUP BY ACNTS_BRN_CODE,
         P.PRODUCT_NAME,
         P.PRODUCT_CODE,
         (A.ACNTS_AC_NAME1 || A.ACNTS_AC_NAME2),
         ACNTS_INTERNAL_ACNUM
         union all
  SELECT ACNTS_BRN_CODE,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_CODE = ACNTS_BRN_CODE)
            MBRN_NAME,
         P.PRODUCT_NAME,
         P.PRODUCT_CODE,
         'I0301' RPTHDGLDTL_CODE,
         NULL ASSETCD_CODE,
         FACNO (1, ACNTS_INTERNAL_ACNUM) AS LOANIA_ACNT_NUM,
         (A.ACNTS_AC_NAME1 || A.ACNTS_AC_NAME2) ACNAME,
         NULL NO_OF_DAYS,
         NULL LOANIA_VALUE_DATE,
         NULL LOANIA_VALUE_DATE,
         NULL LOANIA_INT_RATE,
         NULL ASSET_CODE,
         SUM (NVL (LNSUSPREC_INT_AMT, 0)) AS TOTAL_INTEREST_INCOME
    FROM LNSUSPREC, ACNTS A, PRODUCTS P
   WHERE     LNSUSPREC_ENTITY_NUM = 1
         AND ACNTS_ENTITY_NUM = 1
         AND LNSUSPREC_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
         AND P.PRODUCT_CODE = A.ACNTS_PROD_CODE
         AND a.ACNTS_BRN_CODE = 36137
         AND LNSUSPREC_ENTRY_DATE BETWEEN '01-JAN-2021' AND '31-dec-2021'
         AND LNSUSPREC_AUTH_BY IS NOT NULL
GROUP BY ACNTS_BRN_CODE,
         P.PRODUCT_NAME,
         P.PRODUCT_CODE,
         (A.ACNTS_AC_NAME1 || A.ACNTS_AC_NAME2),
         ACNTS_INTERNAL_ACNUM;



         --------------------------------

CREATE TABLE CL_REPORT_2017

AS
   (SELECT ACNTS_BRN_CODE BRCODE,
           ACNTS_AC_NAME1,
           ACNTS_AC_TYPE,
           (SELECT LNACMIS_HO_DEPT_CODE
              FROM LNACMIS
             WHERE     LNACMIS_INTERNAL_ACNUM = A.ACNTS_INTERNAL_ACNUM
                   AND LNACMIS_ENTITY_NUM = 1)
              CL_REPORT_CODE,
           FACNO (1, A.ACNTS_INTERNAL_ACNUM) ACCOUNT_NO,
           (SELECT (LMTLINE_DATE_OF_SANCTION)
              FROM LIMITLINE
             WHERE     LMTLINE_CLIENT_CODE = B.ACASLLDTL_CLIENT_NUM
                   AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM
                   AND LMTLINE_ENTITY_NUM = 1)
              SANC_DATE,
           (SELECT NVL (LMTLINE_SANCTION_AMT, 0)
              FROM LIMITLINE
             WHERE     LMTLINE_CLIENT_CODE = B.ACASLLDTL_CLIENT_NUM
                   AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM
                   AND LMTLINE_ENTITY_NUM = 1)
              SANC_AMOUNT,
           (SELECT FN_GET_ASON_ACBAL (1,
                                      A.ACNTS_INTERNAL_ACNUM,
                                      'BDT',
                                      '31-MAR-2017',
                                      '06-APR-2017')
              FROM DUAL)
              BAL_OUT,
           (SELECT LMTLINE_LIMIT_EXPIRY_DATE
              FROM LIMITLINE
             WHERE     LMTLINE_CLIENT_CODE = B.ACASLLDTL_CLIENT_NUM
                   AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM
                   AND LMTLINE_ENTITY_NUM = 1)
              EXP_DATE,
           (SELECT NVL (LNTOTINTDB_TOT_INT_DB_AMT, 0)
              FROM LNTOTINTDBMIG
             WHERE     LNTOTINTDB_INTERNAL_ACNUM = A.ACNTS_INTERNAL_ACNUM
                   AND LNTOTINTDB_ENTITY_NUM = 1)
              AMT_PAID,
           (SELECT NVL (LNSUSPBAL_SUSP_BAL, 0)
              FROM LNSUSPBAL
             WHERE     LNSUSPBAL_ACNT_NUM = A.ACNTS_INTERNAL_ACNUM
                   AND LNSUSPBAL_ENTITY_NUM = 1)
              TOTAL_SUSP,
           (SELECT NVL (LNACRSDTL_TOT_REPAY_AMT, 0)
              FROM LNACRSDTL
             WHERE     LNACRSDTL_INTERNAL_ACNUM = A.ACNTS_INTERNAL_ACNUM
                   AND LNACRSDTL_ENTITY_NUM = 1)
              L_SIZE,
           (SELECT LNACRSDTL_REPAY_FREQ
              FROM LNACRSDTL
             WHERE     LNACRSDTL_INTERNAL_ACNUM = A.ACNTS_INTERNAL_ACNUM
                   AND LNACRSDTL_ENTITY_NUM = 1)
              FREQUENCY,
           (SELECT NVL (LNSUSPBAL_INT_BAL, 0)
              FROM LNSUSPBAL
             WHERE     LNSUSPBAL_ACNT_NUM = A.ACNTS_INTERNAL_ACNUM
                   AND ACNTS_ENTITY_NUM = 1)
              INTT_SUSP,
           (SELECT SUM (NVL (SECRCPT_VALUE_OF_SECURITY, 0))
              FROM SECRCPT
             WHERE     SECRCPT_CLIENT_NUM = A.ACNTS_CLIENT_NUM
                   AND SECRCPT_ENTITY_NUM = 1)
              VAL_OF_SECURITY
      FROM ACNTS A,
           ACNTBAL,
           PRODUCTS,
           ACASLLDTL B
     WHERE     ACNTS_ENTITY_NUM = 1
           AND ACNTBAL_ENTITY_NUM = 1
           AND ACNTS_INTERNAL_ACNUM = ACNTBAL_INTERNAL_ACNUM
           AND ACNTS_INTERNAL_ACNUM = ACASLLDTL_INTERNAL_ACNUM
           AND ACNTS_PROD_CODE = PRODUCT_CODE
           AND PRODUCT_FOR_LOANS = 1
           AND ACNTS_CLOSURE_DATE IS NULL);



--------------------------------------------------------------

SELECT ACNTS_PROD_CODE PRODUCT_CODE,
       PRODUCT_NAME,
       FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NUMBER,
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
       NVL (LNINTAPPL_ACT_INT_AMT, 0) INT_APPLY_AMT,
       LNINTAPPL_APPL_DATE INT_APPLY_DATE
  FROM PRODUCTS,
       ASSETCLS,
       ACNTS,
       LNINTAPPL
 WHERE     ASSETCLS_ENTITY_NUM = 1
       --   AND ACNTS_OPENING_DATE BETWEEN '01-JAN-2018' AND '31-DEC-2018'
       AND ACNTS_ENTITY_NUM = 1
       AND ACNTS_INTERNAL_ACNUM = ASSETCLS_INTERNAL_ACNUM
       --AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE > '30-jun-2020')
       AND ASSETCLS_ASSET_CODE IN ('UC', 'SM')
       AND ACNTS_BRN_CODE = 26
       AND LNINTAPPL_ENTITY_NUM = 1
       AND ACNTS_PROD_CODE = PRODUCT_CODE
       AND ACNTS_PROD_CODE IN (2301,
                               2302,
                               2303,
                               2304,
                               2305,
                               2306,
                               2307,
                               2308,
                               2309,
                               2201,
                               2205,
                               2208,
                               2209,
                               2028)
       AND LNINTAPPL_BRN_CODE = ACNTS_BRN_CODE
       AND LNINTAPPL_ACNT_NUM = ACNTS_INTERNAL_ACNUM
       AND LNINTAPPL_APPL_DATE BETWEEN '31-dec-2019' AND '30-jun-2020';


 -----------interest apply in income-------------------

  SELECT ACNTS_BRN_CODE,
         PRODUCT_CODE,
         PRODUCT_NAME,
         ACNTS_AC_TYPE,
         IACLINK_ACTUAL_ACNUM ACCOUNT_NO,
         ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
         SUM (LNINTAPPL_ACT_INT_AMT) INTEREST_AMOUNT
    FROM LNINTAPPL T,
         ACNTS A,
         ASSETCLS,
         PRODUCTS P,
         IACLINK,
         ACC4
   WHERE     ACNTS_INTERNAL_ACNUM = LNINTAPPL_ACNT_NUM
         AND ACNTS_ENTITY_NUM = 1
         AND P.PRODUCT_CODE = A.ACNTS_PROD_CODE
         AND ASSETCLS_ENTITY_NUM = 1
         AND P.PRODUCT_FOR_LOANS = 1
         AND ACNTS_INTERNAL_ACNUM = ASSETCLS_INTERNAL_ACNUM
         AND IACLINK_ENTITY_NUM = 1
         AND IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
         AND IACLINK_ACTUAL_ACNUM = ACC_NO
         AND ASSETCLS_ASSET_CODE IN ('UC', 'SM')
         AND T.LNINTAPPL_APPL_DATE BETWEEN '01-JAN-2021' AND '30-SEP-2021'
GROUP BY ACNTS_BRN_CODE,
         PRODUCT_CODE,
         PRODUCT_NAME,
         ACNTS_AC_TYPE,
         IACLINK_ACTUAL_ACNUM,
         ACNTS_AC_NAME1 || ACNTS_AC_NAME2;

 -----------recovery---------------------------------

  SELECT TRAN_ACING_BRN_CODE,
         PRODUCT_CODE,
         PRODUCT_NAME,
         ACNTS_AC_TYPE,
         IACLINK_ACTUAL_ACNUM ACCOUNT_NO,
         ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
         SUM (TRAN_AMOUNT) RECOVERY_AMOUNT
    FROM TRAN2021 T,
         ACNTS A,
         PRODUCTS P,
         IACLINK,
         ACC4
   WHERE     TRAN_ENTITY_NUM = 1
         -- AND TRAN_ACING_BRN_CODE = 26
         AND ACNTS_INTERNAL_ACNUM = TRAN_INTERNAL_ACNUM
         AND TRAN_INTERNAL_ACNUM <> 0
         AND ACNTS_ENTITY_NUM = 1
         AND P.PRODUCT_CODE = A.ACNTS_PROD_CODE
         AND P.PRODUCT_FOR_LOANS = 1
         AND T.TRAN_DB_CR_FLG = 'C'
         AND T.TRAN_AMOUNT <> 0
         AND IACLINK_ENTITY_NUM = 1
         AND IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
         AND IACLINK_ACTUAL_ACNUM = ACC_NO
         AND T.TRAN_DATE_OF_TRAN BETWEEN '01-JAN-2021' AND '30-SEP-2021'
         AND T.TRAN_AUTH_BY IS NOT NULL
GROUP BY TRAN_ACING_BRN_CODE,
         PRODUCT_CODE,
         PRODUCT_NAME,
         ACNTS_AC_TYPE,
         IACLINK_ACTUAL_ACNUM,
         ACNTS_AC_NAME1 || ACNTS_AC_NAME2;

-------------------------total interest apply---------------------------------

  SELECT ACNTS_BRN_CODE,
         PRODUCT_CODE,
         PRODUCT_NAME,
         ACNTS_AC_TYPE,
         ACCOUNT_NO,
         ACCOUNT_NAME,
         SUM (INTEREST_AMOUNT) INTEREST_AMOUNT
    FROM (  SELECT ACNTS_BRN_CODE,
                   PRODUCT_CODE,
                   PRODUCT_NAME,
                   ACNTS_AC_TYPE,
                   IACLINK_ACTUAL_ACNUM ACCOUNT_NO,
                   ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
                   SUM (LOANIA_INT_AMT_RND) INTEREST_AMOUNT
              FROM LOANIA T,
                   ACNTS A,
                   PRODUCTS P,
                   IACLINK,
                   ACC4
             WHERE     ACNTS_INTERNAL_ACNUM = LOANIA_ACNT_NUM
                   AND ACNTS_ENTITY_NUM = 1
                   AND P.PRODUCT_CODE = A.ACNTS_PROD_CODE
                   AND P.PRODUCT_FOR_LOANS = 1
                   AND IACLINK_ENTITY_NUM = 1
                   AND LOANIA_ENTITY_NUM = 1
                   AND LOANIA_BRN_CODE = ACNTS_BRN_CODE
                   AND IACLINK_ACTUAL_ACNUM = ACC_NO
                   AND LOANIA_VALUE_DATE BETWEEN '01-JAN-2021' AND '30-SEP-2021'
                   AND LOANIA_NPA_STATUS = 1
                   AND IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
          GROUP BY ACNTS_BRN_CODE,
                   PRODUCT_CODE,
                   PRODUCT_NAME,
                   ACNTS_AC_TYPE,
                   IACLINK_ACTUAL_ACNUM,
                   ACNTS_AC_NAME1 || ACNTS_AC_NAME2
          UNION ALL
            SELECT ACNTS_BRN_CODE,
                   PRODUCT_CODE,
                   PRODUCT_NAME,
                   ACNTS_AC_TYPE,
                   IACLINK_ACTUAL_ACNUM ACCOUNT_NO,
                   ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
                   SUM (LOANIA_INT_AMT_RND) INTEREST_AMOUNT
              FROM LOANIA T,
                   ACNTS A,
                   PRODUCTS P,
                   IACLINK,
                   ACC4
             WHERE     ACNTS_INTERNAL_ACNUM = LOANIA_ACNT_NUM
                   AND ACNTS_ENTITY_NUM = 1
                   AND P.PRODUCT_CODE = A.ACNTS_PROD_CODE
                   AND P.PRODUCT_FOR_LOANS = 1
                   AND IACLINK_ENTITY_NUM = 1
                   AND LOANIA_ENTITY_NUM = 1
                   AND IACLINK_ACTUAL_ACNUM = ACC_NO
                   AND LOANIA_BRN_CODE = ACNTS_BRN_CODE
                   AND LOANIA_VALUE_DATE BETWEEN '01-JAN-2021' AND '30-SEP-2021'
                   AND LOANIA_NPA_STATUS = 0
                   AND IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
          GROUP BY ACNTS_BRN_CODE,
                   PRODUCT_CODE,
                   PRODUCT_NAME,
                   ACNTS_AC_TYPE,
                   IACLINK_ACTUAL_ACNUM,
                   ACNTS_AC_NAME1 || ACNTS_AC_NAME2)
GROUP BY ACNTS_BRN_CODE,
         PRODUCT_CODE,
         PRODUCT_NAME,
         ACNTS_AC_TYPE,
         ACCOUNT_NO,
         ACCOUNT_NAME;

-----------------------------suspense---------------------------------------------------

  SELECT ACNTS_BRN_CODE,
         PRODUCT_CODE,
         PRODUCT_NAME,
         ACNTS_AC_TYPE,
         IACLINK_ACTUAL_ACNUM ACCOUNT_NO,
         ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
         SUM (LOANIA_INT_AMT_RND) INTEREST_AMOUNT
    FROM LOANIA T,
         ACNTS A,
         PRODUCTS P,
         IACLINK,
         ACC4
   WHERE     ACNTS_INTERNAL_ACNUM = LOANIA_ACNT_NUM
         AND ACNTS_ENTITY_NUM = 1
         AND P.PRODUCT_CODE = A.ACNTS_PROD_CODE
         AND P.PRODUCT_FOR_LOANS = 1
         AND IACLINK_ENTITY_NUM = 1
         AND LOANIA_ENTITY_NUM = 1
         AND LOANIA_BRN_CODE = ACNTS_BRN_CODE
         AND LOANIA_VALUE_DATE BETWEEN '01-JAN-2021' AND '30-SEP-2021'
         AND LOANIA_NPA_STATUS = 1
         AND IACLINK_ACTUAL_ACNUM = ACC_NO
         AND IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
GROUP BY ACNTS_BRN_CODE,
         PRODUCT_CODE,
         PRODUCT_NAME,
         ACNTS_AC_TYPE,
         IACLINK_ACTUAL_ACNUM,
         ACNTS_AC_NAME1 || ACNTS_AC_NAME2;

--------------income amount------------------------

  SELECT ACNTS_BRN_CODE,
         PRODUCT_CODE,
         PRODUCT_NAME,
         ACNTS_AC_TYPE,
         IACLINK_ACTUAL_ACNUM ACCOUNT_NO,
         ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
         SUM (LOANIA_INT_AMT_RND) INTEREST_AMOUNT
    FROM LOANIA T,
         ACNTS A,
         PRODUCTS P,
         IACLINK,
         ACC4
   WHERE     ACNTS_INTERNAL_ACNUM = LOANIA_ACNT_NUM
         AND ACNTS_ENTITY_NUM = 1
         AND P.PRODUCT_CODE = A.ACNTS_PROD_CODE
         AND P.PRODUCT_FOR_LOANS = 1
         AND IACLINK_ENTITY_NUM = 1
         AND LOANIA_ENTITY_NUM = 1
         AND LOANIA_BRN_CODE = ACNTS_BRN_CODE
         AND IACLINK_ACTUAL_ACNUM = ACC_NO
         AND LOANIA_VALUE_DATE BETWEEN '01-JAN-2021' AND '30-SEP-2021'
         AND LOANIA_NPA_STATUS = 0
         AND IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
GROUP BY ACNTS_BRN_CODE,
         PRODUCT_CODE,
         PRODUCT_NAME,
         ACNTS_AC_TYPE,
         IACLINK_ACTUAL_ACNUM,
         ACNTS_AC_NAME1 || ACNTS_AC_NAME2;

--------------FINAL----------------------

  SELECT /*+ PARALLEL( 24) */
        ACNTS_BRN_CODE,
         PRODUCT_CODE,
         PRODUCT_NAME,
         ACNTS_AC_TYPE,
         LNACRSDTL_REPAY_FROM_DATE,
         (SELECT MIN (LNACDISB_DISB_ON)
            FROM LNACDISB
           WHERE     LNACDISB_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                 AND LNACDISB_AUTH_BY IS NOT NULL)
            LNACDISB_DISB_ON,
         LNACRSDTL_REPAY_AMT,
         LNACRSDTL_NUM_OF_INSTALLMENT,
         FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NO,
         ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
         LMTLINE_SANCTION_AMT,
         SUM (ABS (FN_GET_ASON_ACBAL (1,
                                      ACNTS_INTERNAL_ACNUM,
                                      'BDT',
                                      '31-oct-2021',
                                      '10-nov-2021')))
            OUTSTANDING,
         (SELECT SUM (LNACDISB_DISB_AMT)
            FROM LNACDISB
           WHERE     LNACDISB_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                 AND LNACDISB_AUTH_BY IS NOT NULL)
            LNACDISB_DISB_AMT,
         FN_GET_PAID_AMT (1, ACNTS_INTERNAL_ACNUM, '31-oct-2021')
            RECOVERY_AMOUNT,
         GET_MOBILE_NUM (ACNTS_CLIENT_NUM) MOBILE_NO
    FROM ACNTS A,
         PRODUCTS P,
         LNACRSDTL,
         ACASLLDTL,
         LIMITLINE
   WHERE     ACNTS_BRN_CODE = 26
         AND ACNTS_ENTITY_NUM = 1
         AND P.PRODUCT_CODE = A.ACNTS_PROD_CODE
         AND ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
         AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
         AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
         AND LNACRSDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
         AND ACNTS_CLOSURE_DATE IS NULL
         AND PRODUCT_CODE IN (2101,
                              2102,
                              2103,
                              2104,
                              2105,
                              2106,
                              2107,
                              2108,
                              2109)
GROUP BY LNACRSDTL_REPAY_FROM_DATE,
         ACNTS_BRN_CODE,
         LNACRSDTL_REPAY_AMT,
         LNACRSDTL_NUM_OF_INSTALLMENT,
         ACNTS_INTERNAL_ACNUM,
         ACNTS_CLIENT_NUM,
         LMTLINE_SANCTION_AMT,
         PRODUCT_CODE,
         PRODUCT_NAME,
         ACNTS_AC_TYPE,
         ACNTS_AC_NAME1 || ACNTS_AC_NAME2;
         
         
         
-----------BB Audit----------------
/* Formatted on 02/02/2021 4:22:07 PM (QP5 v5.227.12220.39754) */
------------------loan details---------------------------------------------------

  SELECT BRANCH_HO,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_HO)
            HO_NAME,
         BRANCH_GMO,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_GMO)
            GMO_NAME,
         BRANCH_PO,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_PO)
            PO_NAME,
         tt.Branch_Code,
         Branch_Name,
         Product_Code,
         Product_Name,
         Account_Number,
         Account_Name,
         Sanction_Date,
         Sanction_amt,
         Disburement_Date,
         LIMIT_EXPIRY_DATE,
         Disburement_Amount,
         NVL (Recovery_Amount, 0) Recovery_Amount,
         OUTSTANDING_BAL,
         Mobile_number
    FROM (SELECT ACNTS_BRN_CODE Branch_Code,
                 MBRN_NAME Branch_Name,
                 ACNTS_PROD_CODE Product_Code,
                 PRODUCT_NAME Product_Name,
                 FACNO (1, ACNTS_INTERNAL_ACNUM) Account_Number,
                 ACNTS_AC_NAME1 || ACNTS_AC_NAME2 Account_Name,
                 (SELECT LMTLINE_DATE_OF_SANCTION
                    FROM LIMITLINE
                   WHERE     LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
                         AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM)
                    Sanction_Date,
                 (SELECT LMTLINE_SANCTION_AMT
                    FROM LIMITLINE
                   WHERE     LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
                         AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM)
                    Sanction_amt,
                 (SELECT LMTLINE_LIMIT_EXPIRY_DATE
                    FROM LIMITLINE
                   WHERE     LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
                         AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM)
                    LIMIT_EXPIRY_DATE,
                 (SELECT MAX (LNACDISB_DISB_ON)
                    FROM LNACDISB
                   WHERE     LNACDISB_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                         AND LNACDISB_ENTITY_NUM = 1
                         AND LNACDISB_AUTH_BY IS NOT NULL)
                    Disburement_Date,
                 (SELECT NVL (SUM (TRAN_AMOUNT), 0)
                    FROM TRAN2020
                   WHERE     TRAN_ENTITY_NUM = 1
                         AND TRAN_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                         AND TRAN_DB_CR_FLG = 'D'
                         AND TRAN_AUTH_BY IS NOT NULL)
                    Disburement_Amount,
                 (SELECT NVL (SUM (TRAN_AMOUNT), 0)
                    FROM TRAN2020
                   WHERE     TRAN_ENTITY_NUM = 1
                         AND TRAN_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                         AND TRAN_DB_CR_FLG = 'C'
                         AND TRAN_DATE_OF_TRAN BETWEEN '30-JUN-2020'
                                                   AND '15-sep-2020'
                         AND TRAN_AUTH_BY IS NOT NULL)
                    Recovery_Amount,
                 (SELECT INDCLIENT_TEL_GSM
                    FROM INDCLIENTS
                   WHERE INDCLIENT_CODE = ACNTS_CLIENT_NUM)
                    Mobile_number,
                 FN_GET_ASON_ACBAL (1,
                                    ACNTS_INTERNAL_ACNUM,
                                    'BDT',
                                    '15-sep-2020',
                                    '16-sep-2020')
                    OUTSTANDING_BAL,
                 ACNTS_CLOSURE_DATE
            FROM PRODUCTS,
                 MBRN,
                 ACNTS,
                 ACASLLDTL
           WHERE     ACNTS_PROD_CODE IN (2201, 2217, 2220)
                 AND ACNTS_ENTITY_NUM = 1
                 AND ACNTS_PROD_CODE = PRODUCT_CODE
                 AND ACNTS_OPENING_DATE BETWEEN '30-JUN-2020' AND '15-sep-2020'
                 AND MBRN_CODE = ACNTS_BRN_CODE
                 AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM) TT,
         MBRN_TREE2
   WHERE MBRN_TREE2.BRANCH_CODE = TT.Branch_Code
ORDER BY tt.Branch_Code;

---------------TERM LOAN DETAILS --------------------------------------------

  SELECT BRANCH_HO,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_HO)
            HO_NAME,
         BRANCH_GMO,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_GMO)
            GMO_NAME,
         BRANCH_PO,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_PO)
            PO_NAME,
         ACNTS_BRN_CODE MBRN_CODE,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = ACNTS_BRN_CODE)
            MBRN_NAME,
         TT.Account_Number,
         TT.Account_Name,
         (JUN_DUE - JAN_DUE) Number_of_Installment_due,
         JUN_REC - JAN_REC Recovered_Amount,
         Overdue_Amount,
         Outstanding_Amount
    FROM (SELECT ACNTS_BRN_CODE,
                 FACNO (1, ACNTS_INTERNAL_ACNUM) Account_Number,
                 ACNTS_AC_NAME1 || ACNTS_AC_NAME2 Account_Name,
                 FN_GET_OD_MONTH_DATA (1, ACNTS_INTERNAL_ACNUM, '01-JAN-2020')
                    JAN_DUE,
                 FN_GET_OD_MONTH_DATA (1, ACNTS_INTERNAL_ACNUM, '30-JUN-2020')
                    JUN_DUE,
                 FN_GET_PAID_AMT (1, ACNTS_INTERNAL_ACNUM, '01-JAN-2020')
                    JAN_REC,
                 FN_GET_PAID_AMT (1, ACNTS_INTERNAL_ACNUM, '30-JUN-2020')
                    JUN_REC,
                 FN_GET_OD_AMT (1,
                                ACNTS_INTERNAL_ACNUM,
                                '30-JUN-2020',
                                '27-JUL-2020')
                    Overdue_Amount,
                 FN_GET_ASON_ACBAL (1,
                                    ACNTS_INTERNAL_ACNUM,
                                    'BDT',
                                    '30-JUN-2020',
                                    '27-JUL-2020')
                    Outstanding_Amount,
                 (SELECT CASE
                            WHEN LNACRSDTL_REPAY_FREQ = 'M' THEN 1
                            WHEN LNACRSDTL_REPAY_FREQ = 'Q' THEN 3
                            WHEN LNACRSDTL_REPAY_FREQ = 'H' THEN 6
                            ELSE 12
                         END
                    FROM LNACRSDTL LD
                   WHERE LD.LNACRSDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM)
                    repay_fre
            FROM acnts
           WHERE     ACNTS_ENTITY_NUM = 1
                 AND ACNTS_BRN_CODE = 26
                 AND ACNTS_PROD_CODE IN (2401, 2402)) TT,
         MBRN_TREE2
   WHERE MBRN_TREE2.BRANCH_CODE = TT.ACNTS_BRN_CODE AND Outstanding_Amount <> 0
ORDER BY tt.ACNTS_BRN_CODE;

---------------loan summary--------------------------------------------------

  SELECT PRODUCT_CODE,
         PRODUCT_NAME,
         COUNT (Account_Number) nof_account,
         SUM (DISBUREMENT_AMOUNT) DISBUREMENT_AMOUNT,
         (Recovery_Amount) Recovery_Amount,
         OUTSTANDING_BAL
    FROM (SELECT ACNTS_BRN_CODE Branch_Code,
                 MBRN_NAME Branch_Name,
                 ACNTS_PROD_CODE Product_Code,
                 PRODUCT_NAME Product_Name,
                 FACNO (1, ACNTS_INTERNAL_ACNUM) Account_Number,
                 ACNTS_AC_NAME1 || ACNTS_AC_NAME2 Account_Name,
                 (SELECT MAX (LNACDISB_DISB_ON)
                    FROM LNACDISB
                   WHERE     LNACDISB_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                         AND LNACDISB_ENTITY_NUM = 1
                         AND LNACDISB_AUTH_BY IS NOT NULL)
                    Disburement_Date,
                 (SELECT NVL (SUM (TRAN_AMOUNT), 0)
                    FROM TRAN2020
                   WHERE     TRAN_ENTITY_NUM = 1
                         AND TRAN_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                         AND TRAN_DB_CR_FLG = 'D'
                         AND TRAN_AUTH_BY IS NOT NULL)
                    Disburement_Amount,
                 (SELECT NVL (SUM (TRAN_AMOUNT), 0)
                    FROM TRAN2020, acnts a
                   WHERE     TRAN_ENTITY_NUM = 1
                         AND TRAN_INTERNAL_ACNUM = a.ACNTS_INTERNAL_ACNUM
                         AND TRAN_DB_CR_FLG = 'C'
                         AND a.ACNTS_ENTITY_NUM = 1
                         AND a.ACNTS_PROD_CODE = PRODUCT_CODE
                         AND TRAN_DATE_OF_TRAN BETWEEN '15-OCT-2020'
                                                   AND '21-OCT-2020'
                         AND TRAN_AUTH_BY IS NOT NULL)
                    Recovery_Amount,
                 (SELECT INDCLIENT_TEL_GSM
                    FROM INDCLIENTS
                   WHERE INDCLIENT_CODE = ACNTS_CLIENT_NUM)
                    Mobile_number,
                 (SELECT (FN_GET_ASON_ACBAL (1,
                                             ACNTS_INTERNAL_ACNUM,
                                             'BDT',
                                             '21-OCT-2020',
                                             '21-OCT-2020'))
                    FROM acnts a
                   WHERE     a.ACNTS_ENTITY_NUM = 1
                         AND a.ACNTS_PROD_CODE = PRODUCT_CODE)
                    OUTSTANDING_BAL,
                 ACNTS_CLOSURE_DATE
            FROM PRODUCTS, MBRN, ACNTS
           WHERE     ACNTS_PROD_CODE IN (2577, 2578, 2580, 2504)
                 AND ACNTS_ENTITY_NUM = 1
                 AND ACNTS_PROD_CODE = PRODUCT_CODE
                 AND ACNTS_OPENING_DATE BETWEEN '15-OCT-2020' AND '21-OCT-2020'
                 AND MBRN_CODE = ACNTS_BRN_CODE)
GROUP BY PRODUCT_CODE,
         PRODUCT_NAME,
         OUTSTANDING_BAL,
         Recovery_Amount;

-----------------------------------------------------
----------------AC TYPE------------

  SELECT BRANCH_HO,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_HO)
            HO_NAME,
         BRANCH_GMO,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_GMO)
            GMO_NAME,
         BRANCH_PO,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_PO)
            PO_NAME,
         ACNTS_BRN_CODE MBRN_CODE,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = ACNTS_BRN_CODE)
            MBRN_NAME,
         TT.*
    FROM (SELECT ACNTS_BRN_CODE ACNTS_BRN_CODE,
                 MBRN_NAME Branch_Name,
                 ACNTS_PROD_CODE Product_Code,
                 PRODUCT_NAME Product_Name,
                 FACNO (1, ACNTS_INTERNAL_ACNUM) Account_Number,
                 ACNTS_AC_NAME1 || ACNTS_AC_NAME2 Account_Name,
                 ACNTS_AC_TYPE,
                 ACNTS_AC_SUB_TYPE,
                 (SELECT MAX (LNACDISB_DISB_ON)
                    FROM LNACDISB
                   WHERE     LNACDISB_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                         AND LNACDISB_ENTITY_NUM = 1
                         AND LNACDISB_AUTH_BY IS NOT NULL)
                    Disburement_Date,
                 (SELECT LMTLINE_DATE_OF_SANCTION
                    FROM LIMITLINE, ACASLLDTL
                   WHERE     LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
                         AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM
                         AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                         AND ACASLLDTL_ENTITY_NUM = 1)
                    Sanction_Date,
                 (SELECT NVL (SUM (TRAN_AMOUNT), 0)
                    FROM TRAN2020
                   WHERE     TRAN_ENTITY_NUM = 1
                         AND TRAN_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                         AND TRAN_DB_CR_FLG = 'D'
                         AND TRAN_AUTH_BY IS NOT NULL)
                    Disburement_Amount,
                 (SELECT INDCLIENT_TEL_GSM
                    FROM INDCLIENTS
                   WHERE INDCLIENT_CODE = ACNTS_CLIENT_NUM)
                    Mobile_number,
                 (FN_GET_ASON_ACBAL (1,
                                     ACNTS_INTERNAL_ACNUM,
                                     'BDT',
                                     '30-JUL-2020',
                                     '30-JUL-2020'))
                    OUTSTANDING_BAL,
                 ACNTS_CLOSURE_DATE
            FROM PRODUCTS, MBRN, ACNTS
           WHERE     ACNTS_PROD_CODE = 2580
                 AND ACNTS_ENTITY_NUM = 1
                 AND ACNTS_PROD_CODE = PRODUCT_CODE
                 -- AND ACNTS_OPENING_DATE BETWEEN '1-JUL-2020' AND '30-JUL-2020'
                 AND MBRN_CODE = ACNTS_BRN_CODE) TT,
         MBRN_TREE2
   WHERE MBRN_TREE2.BRANCH_CODE = TT.ACNTS_BRN_CODE
ORDER BY tt.ACNTS_BRN_CODE;

-------------------------


SELECT *
  FROM (SELECT facno (1, ASSETCLSH_INTERNAL_ACNUM) account_number,
               ASSETCLSH_ASSET_CODE,
               ASSETCLSH_EFF_DATE,
               (SELECT NVL ( (LMTLINE_SANCTION_AMT), 0)
                  FROM ACASLLDTL, LIMITLINE
                 WHERE     ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
                       AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
                       AND ACASLLDTL_INTERNAL_ACNUM =
                              ASSETCLSH_INTERNAL_ACNUM
                       AND LMTLINE_ENTITY_NUM = 1)
                  SANCTION_AMOUNT,
               ABS (NVL (FN_GET_ASON_ACBAL (1,
                                            ASSETCLSH_INTERNAL_ACNUM,
                                            'BDT',
                                            '31-DEC-2018',
                                            '10-APR-2019'),
                         0))
                  OUTSTANDING
          FROM ASSETCLSHIST
         WHERE     ASSETCLSH_ENTITY_NUM = 1
               AND ASSETCLSH_EFF_DATE BETWEEN '01-JUL-2018' AND '31-DEC-2018'
               AND ASSETCLSH_ASSET_CODE IN ('UC', 'SM'))
 WHERE SANCTION_AMOUNT < OUTSTANDING;

  ------------------------------------------------------------------

SELECT facno (1, ASSETCLS_INTERNAL_ACNUM) account_number,
       ASSETCLS_LATEST_EFF_DATE,
       ASSETCLS_ASSET_CODE,
       (SELECT NVL ( (LMTLINE_SANCTION_AMT), 0)
          FROM ACASLLDTL, LIMITLINE
         WHERE     ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
               AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
               AND ACASLLDTL_INTERNAL_ACNUM = ASSETCLS_INTERNAL_ACNUM
               AND LMTLINE_ENTITY_NUM = 1)
          SANCTION_AMOUNT,
       ABS (NVL (FN_GET_ASON_ACBAL (1,
                                    ASSETCLS_INTERNAL_ACNUM,
                                    'BDT',
                                    '31-DEC-2018',
                                    '10-APR-2019'),
                 0))
          OUTSTANDING
  FROM assetcls
 WHERE     ASSETCLS_ENTITY_NUM = 1
       -- AND   ASSETCLS_LATEST_EFF_DATE BETWEEN '01-JUL-2018' AND '31-DEC-2018'
       AND ASSETCLS_ASSET_CODE IN ('SS', 'DF', 'BL')
       AND ASSETCLS_INTERNAL_ACNUM IN
              (SELECT ASSETCLSH_INTERNAL_ACNUM
                 FROM (SELECT ASSETCLSH_INTERNAL_ACNUM,
                              ASSETCLSH_ASSET_CODE,
                              ASSETCLSH_EFF_DATE,
                              (SELECT NVL ( (LMTLINE_SANCTION_AMT), 0)
                                 FROM ACASLLDTL, LIMITLINE
                                WHERE     ACASLLDTL_CLIENT_NUM =
                                             LMTLINE_CLIENT_CODE
                                      AND ACASLLDTL_LIMIT_LINE_NUM =
                                             LMTLINE_NUM
                                      AND ACASLLDTL_INTERNAL_ACNUM =
                                             ASSETCLSH_INTERNAL_ACNUM
                                      AND LMTLINE_ENTITY_NUM = 1)
                                 SANCTION_AMOUNT,
                              ABS (
                                 NVL (
                                    FN_GET_ASON_ACBAL (
                                       1,
                                       ASSETCLSH_INTERNAL_ACNUM,
                                       'BDT',
                                       '31-DEC-2018',
                                       '10-APR-2019'),
                                    0))
                                 OUTSTANDING
                         FROM ASSETCLSHIST
                        WHERE     ASSETCLSH_ENTITY_NUM = 1
                              AND ASSETCLSH_EFF_DATE BETWEEN '01-JUL-2018'
                                                         AND '31-DEC-2018'
                              AND ASSETCLSH_ASSET_CODE IN ('UC', 'SM'))
                WHERE SANCTION_AMOUNT < OUTSTANDING);



SELECT COUNT (ASSETCLSH_INTERNAL_ACNUM) TOTAL_ACCOUNT,
       SUM (SANCTION_AMOUNT),
       SUM (OUTSTANDING)
  FROM (SELECT ASSETCLSH_INTERNAL_ACNUM,
               ASSETCLSH_ASSET_CODE,
               ASSETCLSH_EFF_DATE,
               (SELECT NVL ( (LMTLINE_SANCTION_AMT), 0)
                  FROM ACASLLDTL, LIMITLINE
                 WHERE     ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
                       AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
                       AND ACASLLDTL_INTERNAL_ACNUM =
                              ASSETCLSH_INTERNAL_ACNUM
                       AND LMTLINE_ENTITY_NUM = 1)
                  SANCTION_AMOUNT,
               ABS (NVL (FN_GET_ASON_ACBAL (1,
                                            ASSETCLSH_INTERNAL_ACNUM,
                                            'BDT',
                                            '31-DEC-2018',
                                            '10-APR-2019'),
                         0))
                  OUTSTANDING
          FROM ASSETCLSHIST
         WHERE     ASSETCLSH_ENTITY_NUM = 1
               AND ASSETCLSH_EFF_DATE BETWEEN '01-JUL-2018' AND '31-DEC-2018'
               AND ASSETCLSH_ASSET_CODE IN ('UC', 'SM'))
 WHERE SANCTION_AMOUNT < OUTSTANDING;


-----------------------------------------------------------------------

SELECT ACNTS_BRN_CODE "Branch Code",
       ACNTS_PROD_CODE "Product Code",
       PRODUCT_name "Product Name",
       ACCOUNT_NUMBER "Loan account Number",
       ACNTS_OPENING_DATE " Date of open",
       EXPIRY_DATE "Expiry Date",
       DISB_DATE "Disburement Date",
       NVL (LIMIT_AMOUNT, 0) "Limit Amount",
       NVL (DISB_AMOUNT, 0) "Disburement Amount",
       NVL (INT_AMT, 0) "INTEREST AMOUNT",
       NVL (OUTSTANDING, 0) "Outstanding Balance"
  FROM (SELECT ACNTS_BRN_CODE,
               ACNTS_PROD_CODE,
               PRODUCT_name,
               FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NUMBER,
               ACNTS_OPENING_DATE,
               (SELECT LMTLINE_LIMIT_EXPIRY_DATE
                  FROM ACASLLDTL, LIMITLINE
                 WHERE     ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
                       AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
                       AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                       AND LMTLINE_ENTITY_NUM = 1)
                  EXPIRY_DATE,
               (SELECT NVL (LMTLINE_SANCTION_AMT, 0)
                  FROM ACASLLDTL, LIMITLINE
                 WHERE     ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
                       AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
                       AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                       AND LMTLINE_ENTITY_NUM = 1)
                  LIMIT_AMOUNT,
               (SELECT SUM (NVL (LNACDISB_DISB_AMT, 0))
                  FROM LNACDISB
                 WHERE     LNACDISB_ENTITY_NUM = 1
                       AND LNACDISB_AUTH_BY IS NOT NULL
                       AND LNACDISB_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM)
                  DISB_AMOUNT,
               (SELECT MAX (LNACDISB_DISB_ON)
                  FROM LNACDISB
                 WHERE     LNACDISB_ENTITY_NUM = 1
                       AND LNACDISB_AUTH_BY IS NOT NULL
                       AND LNACDISB_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM)
                  DISB_DATE,
               (SELECT ABS (SUM (LNINTAPPL_ACT_INT_AMT))
                  FROM lnintappl
                 WHERE     LNINTAPPL_ENTITY_NUM = 1
                       AND LNINTAPPL_BRN_CODE = ACNTS_BRN_CODE
                       AND LNINTAPPL_ACNT_NUM = ACNTS_INTERNAL_ACNUM
                       AND LNINTAPPL_INT_UPTO_DATE <= '31-dec-2018')
                  INT_AMT,
               ABS (NVL (FN_GET_ASON_ACBAL (1,
                                            ACNTS_INTERNAL_ACNUM,
                                            'BDT',
                                            '31-DEC-2018',
                                            '11-APR-2019'),
                         0))
                  OUTSTANDING
          FROM PRODUCTS, ASSETCLS, ACNTS
         WHERE     ASSETCLS_ENTITY_NUM = 1
               AND ACNTS_OPENING_DATE BETWEEN '01-JAN-2018' AND '31-DEC-2018'
               AND ACNTS_ENTITY_NUM = 1
               AND ACNTS_PROD_CODE = PRODUCT_CODE
               AND ACNTS_INTERNAL_ACNUM = ASSETCLS_INTERNAL_ACNUM
               AND (   ACNTS_CLOSURE_DATE IS NULL
                    OR ACNTS_CLOSURE_DATE > '31-DEC-2018')
               AND ASSETCLS_ASSET_CODE IN ('UC', 'SM')
               -- AND ACNTS_BRN_CODE = 1065
               AND PRODUCT_FOR_LOANS = 1);

---------------------------------------------------------------------------------------------

SELECT ACNTS_BRN_CODE,
       ACNTS_PROD_CODE,
       PRODUCT_NAME,
       FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NAME,
       TRAN_AMOUNT REPAY_AMOUNT,
       OUTSTANDING EFE
  FROM (SELECT ACNTS_BRN_CODE,
               ACNTS_PROD_CODE,
               PRODUCT_NAME,
               ACNTS_INTERNAL_ACNUM,
               (SELECT NVL (SUM (TRAN_AMOUNT), 0)
                  FROM TRAN2018
                 WHERE     TRAN_ENTITY_NUM = 1
                       AND TRAN_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                       AND TRAN_DB_CR_FLG = 'C'
                       AND TRAN_AUTH_BY IS NOT NULL)
                  TRAN_AMOUNT,
               ABS (NVL (FN_GET_ASON_ACBAL (1,
                                            ACNTS_INTERNAL_ACNUM,
                                            'BDT',
                                            '31-DEC-2018',
                                            '11-APR-2019'),
                         0))
                  OUTSTANDING
          FROM PRODUCTS, ACNTS, assetcls
         WHERE     ACNTS_PROD_CODE = PRODUCT_CODE
               AND PRODUCT_FOR_LOANS = 1
               AND ACNTS_INTERNAL_ACNUM = ASSETCLS_INTERNAL_ACNUM
               AND ASSETCLS_ASSET_CODE IN ('UC', 'SM')
               AND ACNTS_OPENING_DATE <= '31-DEC-2018'
               --AND ACNTS_BRN_CODE=1065
               AND (   ACNTS_CLOSURE_DATE IS NULL
                    OR ACNTS_CLOSURE_DATE > '31-DEC-2018')
               AND ACNTS_ENTITY_NUM = 1
               AND ASSETCLS_LATEST_EFF_DATE BETWEEN '01-JUL-2018'
                                                AND '31-DEC-2018'
               AND PRODUCT_FOR_RUN_ACS = 1
               AND ACNTS_CLOSURE_DATE IS NULL)
 WHERE TRAN_AMOUNT <= 0 AND OUTSTANDING <> 0;

-----------------------------------------------------------------

  SELECT BRANCH_HO,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_HO)
            HO_NAME,
         BRANCH_GMO,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_GMO)
            GMO_NAME,
         BRANCH_PO,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_PO)
            PO_NAME,
         tt.*
    FROM (  SELECT BR_CODE,
                   MBRN_NAME,
                   SUM (TOTAL_ASSET) TOTAL_ASSET,
                   SUM (TOTAL_DEPOSIT) TOTAL_DEPOSIT,
                   SUM (CASHING_HAND) CASHING_HAND
              FROM (SELECT BR_CODE,
                           MBRN_NAME,
                           TOTAL_ASSET,
                           TOTAL_DEPOSIT,
                           CASHING_HAND
                      FROM (  SELECT MBRN_CODE BR_CODE,               ---48984
                                     MBRN_NAME,
                                     SUM (NVL (RPT_HEAD_BAL, 0)) TOTAL_ASSET,
                                     0 TOTAL_DEPOSIT,
                                     0 CASHING_HAND
                                FROM STATMENTOFAFFAIRS, MBRN
                               WHERE     RPT_BRN_CODE = MBRN_CODE
                                     AND RPT_ENTRY_DATE = '07-may-2020'
                                     AND RPT_HEAD_CODE IN
                                            ('A0301',
                                             'A0302',
                                             'A0303',
                                             'A0304',
                                             'A0305',
                                             'A0345',
                                             'A0306',
                                             'A0314',
                                             'A0307',
                                             'A0308',
                                             'A0327',
                                             'A0328',
                                             'A0309',
                                             'A0330',
                                             'A0331',
                                             'A0329',
                                             'A0334',
                                             'A0335',
                                             'A0337',
                                             'A0350',
                                             'A0338',
                                             'A0310',
                                             'A0311',
                                             'A0312',
                                             'A0313',
                                             'A0332',
                                             'A0316',
                                             'A0317',
                                             'A0318',
                                             'A0961',
                                             'A0319',
                                             'A0320',
                                             'A0321',
                                             'A0322',
                                             'A0323',
                                             'A0324',
                                             'A0325',
                                             'A0326',
                                             'A0339',
                                             'A0956',
                                             'A0351',
                                             'A0352',
                                             'A0353',
                                             'A0401',
                                             'A0402',
                                             'A0403')
                            GROUP BY MBRN_CODE, MBRN_NAME
                            UNION ALL
                              SELECT MBRN_CODE BR_CODE,               ---48984
                                     MBRN_NAME,
                                     0 TOTAL_ASSET,
                                     SUM (NVL (RPT_HEAD_BAL, 0)) TOTAL_DEPOSIT,
                                     0 CASHING_HAND
                                FROM STATMENTOFAFFAIRS, MBRN
                               WHERE     RPT_BRN_CODE = MBRN_CODE
                                     AND RPT_ENTRY_DATE = '07-may-2020'
                                     AND RPT_HEAD_CODE IN
                                            ('L2001',
                                             'L2002',
                                             'L2003',
                                             'L2004',
                                             'L2005',
                                             'L2006',
                                             'L2024',
                                             'L2008',
                                             'L2009',
                                             'L2010',
                                             'L2011',
                                             'L2012',
                                             'L2013',
                                             'L2014',
                                             'L2015',
                                             'L2016',
                                             'L2017',
                                             'L2018',
                                             'L2019',
                                             'L2020',
                                             'L2021',
                                             'L2022',
                                             'L2113',
                                             'L2114',
                                             'L2101',
                                             'L2102',
                                             'L2103',
                                             'L2105',
                                             'L2106',
                                             'L2107',
                                             'L2607',
                                             'L2112',
                                             'L2119',
                                             'L2110',
                                             'L2111')
                            GROUP BY MBRN_CODE, MBRN_NAME
                            UNION ALL
                              SELECT MBRN_CODE BR_CODE,               ---48984
                                     MBRN_NAME,
                                     0 TOTAL_ASSET,
                                     0 TOTAL_DEPOSIT,
                                     SUM (NVL (RPT_HEAD_BAL, 0)) CASHING_HAND
                                FROM STATMENTOFAFFAIRS, MBRN
                               WHERE     RPT_BRN_CODE = MBRN_CODE
                                     AND RPT_ENTRY_DATE = '07-may-2020'
                                     AND RPT_HEAD_CODE IN ('A0101')
                            GROUP BY MBRN_CODE, MBRN_NAME))
          GROUP BY BR_CODE, MBRN_NAME) Tt,
         MBRN_TREE2
   WHERE MBRN_TREE2.BRANCH_CODE = TT.BR_CODE
ORDER BY tt.BR_CODE;


------------------- comparison CL report

SELECT mbrn_code "Branch Code",
       mbrn_name "Branch Name",
       ACNTS_INTERNAL_ACNUM "Account Number",
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2 "Account Name",
       ACNTS_PROD_CODE "Product Code",
       product_name "Product Name",
       ACNTS_AC_TYPE "Account Type",
       LNACMIS_HO_DEPT_CODE "CL Code",
       ABS (NVL (FN_GET_ASON_ACBAL (1,
                                    ACNTS_INTERNAL_ACNUM,
                                    'BDT',
                                    '31-DEC-2020',
                                    '02-FEB-2019'),
                 0))
          "Outstan Balance(31/12/2020)",
       FN_GET_SUSPBAL (1, ACNTS_INTERNAL_ACNUM, '31-dec-2020')
          "Int Susp Balance(31/12/2020)",
       (SELECT ASSETCLSH_ASSET_CODE
          FROM assetclshist
         WHERE     ASSETCLSH_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ASSETCLSH_EFF_DATE =
                      (SELECT MAX (ASSETCLSH_EFF_DATE)
                         FROM ASSETCLSHIST
                        WHERE     ASSETCLSH_ENTITY_NUM = 1
                              AND ASSETCLSH_EFF_DATE <= '31-DEC-2020'
                              AND ASSETCLSH_INTERNAL_ACNUM =
                                     ACNTS_INTERNAL_ACNUM))
          "CL status(31/12/2020)",
       ABS (NVL (FN_GET_ASON_ACBAL (1,
                                    ACNTS_INTERNAL_ACNUM,
                                    'BDT',
                                    '31-DEC-2019',
                                    '02-FEB-2019'),
                 0))
          "Out Balance(31/12/2019)",
       FN_GET_SUSPBAL (1, ACNTS_INTERNAL_ACNUM, '31-dec-2019')
          "Int Sus Balance(31/12/2019)",
       (SELECT ASSETCLSH_ASSET_CODE
          FROM assetclshist
         WHERE     ASSETCLSH_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ASSETCLSH_EFF_DATE =
                      (SELECT MAX (ASSETCLSH_EFF_DATE)
                         FROM ASSETCLSHIST
                        WHERE     ASSETCLSH_ENTITY_NUM = 1
                              AND ASSETCLSH_EFF_DATE <= '31-DEC-2019'
                              AND ASSETCLSH_INTERNAL_ACNUM =
                                     ACNTS_INTERNAL_ACNUM))
          "CL status(31/12/2019)"
  FROM products,
       mbrn,
       acnts,
       lnacmis
 WHERE     mbrn_code = ACNTS_BRN_CODE
       AND ACNTS_ENTITY_NUM = 1
       AND ACNTS_INTERNAL_ACNUM = LNACMIS_INTERNAL_ACNUM
       AND LNACMIS_ENTITY_NUM = 1
       AND ACNTS_PROD_CODE = product_code
       and ACNTS_BRN_CODE in (
00018,
00026,
16170,
16063,
10090,
44255,
01024,
27151,
44263,
36137,
27086,
16089,
27094,
49098,
46177,
50195,
19190,
19125,
20230,
24158,
01156,
07039,
01206,
30122,
00034,
08011,
08284,
09035,
10033,
33043,
43158,
59113

)
       AND (LNACMIS_HO_DEPT_CODE   LIKE  'CL2%' OR LNACMIS_HO_DEPT_CODE LIKE 'CL3%'   OR LNACMIS_HO_DEPT_CODE LIKE  'CL4%')
       AND ACNTS_OPENING_DATE <= '31-dec-2020'
       AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE > '31-dec-2020')
        ;
---------------closed loan account list under One time Exit.(Urgent)
SELECT BRANCH_CODE,
       Branch_Name,
       ACNTS_PROD_CODE Product_code,
       Product_Name,
       Account_Number,
       account_name,
       Outstanding_Balance ,LNACRSH_EFF_DATE
  FROM (SELECT ACNTS_BRN_CODE BRANCH_CODE,
               ACNTS_AC_NAME1 || ACNTS_AC_NAME2 account_name,LNACRSH_EFF_DATE,
               ACNTS_PROD_CODE,
               Product_Name,
               (SELECT MBRN_NAME
                  FROM MBRN
                 WHERE MBRN_CODE = ACNTS_BRN_CODE)
                  BRANCH_NAME,
               facno (1, ACNTS_INTERNAL_ACNUM) Account_Number,
               FN_GET_ASON_ACBAL (1,
                                  ACNTS_INTERNAL_ACNUM,
                                  'BDT',
                                  '31-DEC-2020',
                                  '02-FEB-2021')
                  Outstanding_Balance
          FROM products, LNACRSHIST, ACNTS
         WHERE     LNACRSH_ENTITY_NUM = 1
               AND ACNTS_PROD_CODE NOT IN (2501, 2504)
               and ACNTS_PROD_CODE=product_code
               AND TRIM (LNACRSH_REPHASEMENT_ENTRY) = '1'
               AND TRIM (LNACRSH_PURPOSE) = 'R'
               AND ACNTS_INTERNAL_ACNUM = LNACRSH_INTERNAL_ACNUM
               AND ACNTS_INTERNAL_ACNUM IN
                      (SELECT ASSETCLSH_INTERNAL_ACNUM
                         FROM ASSETCLSHIST
                        WHERE     ASSETCLSH_ASSET_CODE IN ('UC', 'SM', 'ST')
                              AND ASSETCLSH_EFF_DATE <= '31-dec-2020')
               AND LNACRSH_EFF_DATE =
                      (SELECT MAX (LNACRSH_EFF_DATE)
                         FROM LNACRSHIST
                        WHERE     LNACRSH_ENTITY_NUM = 1
                              AND LNACRSH_INTERNAL_ACNUM =
                                     ACNTS_INTERNAL_ACNUM)
               AND ACNTS_ENTITY_NUM = 1
               AND LNACRSH_EFF_DATE BETWEEN '01-DEC-2019' AND '31-DEC-2020'
               AND LNACRSH_ENTITY_NUM = 1
               AND ACNTS_OPENING_DATE <= '31-DEC-2020'
               AND (   ACNTS_CLOSURE_DATE IS NULL
                    OR ACNTS_CLOSURE_DATE >= '31-DEC-2020'));