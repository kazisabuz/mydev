--------------------------------
/* Formatted on 5/25/2021 1:04:29 PM (QP5 v5.252.13127.32867) */
SELECT GMO_CODE,
       GMO_NAME,
       PO_CODE,
       PO_NAME,
       IACLINK_BRN_CODE branch_code,
       BRANCH_NAME,
       PRODUCT_CODE,
       PRODUCT_NAME,
       TMP_ACTUAL_ACNUM,
       TMP_ACCNT_NAME,
       OUTSTANDING,
       EXPIRY_DATE,
       CASE WHEN PERIOD_OF_BEARER < 0 THEN 0 ELSE PERIOD_OF_BEARER END
          PERIOD_OF_ARRIER
  FROM BACKUPTABLE.TF_LOAN_DATA, iaclink
 WHERE TMP_ACTUAL_ACNUM = IACLINK_ACTUAL_ACNUM AND IACLINK_ENTITY_NUM = 1
 order by GMO_CODE;

-------------------------------------
SELECT FACNO(1,ACNTS_INTERNAL_ACNUM) ACC_NUMBER,ACBALH_ASON_DATE,LOAN_TYPE,SANCTION_AMOUNT,OUTSTANDING_BALANCE
FROM(SELECT ACNTS_INTERNAL_ACNUM,
     ACBALH_ASON_DATE,
     LOAN_TYPE,
    SUM( SANCTION_AMOUNT) SANCTION_AMOUNT,
     SUM(OUTSTANDING_BALANCE) OUTSTANDING_BALANCE
FROM (  SELECT /*+ PARALLEL( 8) */ACNTS_INTERNAL_ACNUM,
              
               CASE
                  WHEN PRODUCT_FOR_RUN_ACS = 0 THEN 'Term loan'
                  ELSE 'Continious Loan'
               END
                  LOAN_TYPE,
               NVL(SUM (LMTLINE_SANCTION_AMT),0) SANCTION_AMOUNT,
               SUM (
                  (SELECT NVL(ACBALH_BC_BAL,0)
                     FROM ACBALASONHIST A
                    WHERE     A.ACBALH_ENTITY_NUM = 1
                          AND A.ACBALH_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                          AND A.ACBALH_ASON_DATE =
                                 (SELECT MAX (ACBALH_ASON_DATE)
                                    FROM ACBALASONHIST
                                   WHERE     ACBALH_ENTITY_NUM = 1
                                         AND ACBALH_INTERNAL_ACNUM =
                                                ACNTS_INTERNAL_ACNUM
                                         AND ACBALH_ASON_DATE <=
                                                '31-MAR-2018')))
                  OUTSTANDING_BALANCE
               
          FROM ACNTS,
               PRODUCTS,
               LIMITLINE,
               ACASLLDTL,assetcls 
         WHERE     ACNTS_ENTITY_NUM = 1
               AND (   ACNTS_CLOSURE_DATE IS NULL
                    OR ACNTS_CLOSURE_DATE >= '31-MAR-2018')
               AND PRODUCT_CODE = ACNTS_PROD_CODE
               AND PRODUCT_FOR_LOANS = 1
               AND ACASLLDTL_ENTITY_NUM = 1
               AND ASSETCLS_ENTITY_NUM=1
               AND ASSETCLS_INTERNAL_ACNUM=ACNTS_INTERNAL_ACNUM
               AND ASSETCLS_ASSET_CODE='UC'
               AND LMTLINE_ENTITY_NUM = 1
               AND ACNTS_BRN_CODE = LMTLINE_HOME_BRANCH
               AND ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
               AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM
               AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACNTS_CLIENT_NUM = LMTLINE_CLIENT_CODE
               -- and ACNTS_BRN_CODE in(33068, 18259, 52019, 7054, 35121, 18044, 19133,  49122, 32011, 19158, 6130, 46045, 48116, 36137, 19117, 19166, 1024)
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_PROD_CODE NOT IN
                      (2101, 2102, 2103, 2104, 2105, 2106, 2107, 2108, 2109,2031,2042) -- Staff Loan
      GROUP BY  PRODUCT_FOR_RUN_ACS,ACNTS_INTERNAL_ACNUM
      ORDER BY  PRODUCT_FOR_RUN_ACS) A,
     ACBALASONHIST
WHERE  OUTSTANDING_BALANCE<>0 
and a.ACNTS_INTERNAL_ACNUM=ACBALH_INTERNAL_ACNUM
and ACBALH_ASON_DATE between '31-MAR-2018' AND '31-MAR-2018'
group by ACBALH_ASON_DATE,     LOAN_TYPE,ACNTS_INTERNAL_ACNUM
ORDER BY ACBALH_ASON_DATE);



-------------------------------------
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
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = TT.ACNTS_BRN_CODE)
          BRANCH_NAME,TT.*
FROM (SELECT ACNTS_BRN_CODE,PRODUCT_CODE,PRODUCT_NAME,
       FACNO(1,ACNTS_INTERNAL_ACNUM) ACCOUNT_NUMBER,
       ACNTS_AC_NAME1 ACCOUNT_NAME,
       fn_get_ason_acbal (1,
                          ACNTS_INTERNAL_ACNUM,
                          'BDT',
                          '24-MAY-2021',
                          '25-MAY-2021')
          OUTSTANDING,
       LMTLINE_LIMIT_EXPIRY_DATE EXPIRY_DATE
  FROM ACNTS, LIMITLINE, ACASLLDTL,PRODUCTS
 WHERE     ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
       AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM
       AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND ACNTS_CLIENT_NUM = LMTLINE_CLIENT_CODE
       AND ACASLLDTL_ENTITY_NUM = 1
       AND ACNTS_ENTITY_NUM = 1
       AND PRODUCT_CODE=ACNTS_PROD_CODE
       AND ACNTS_PROD_CODE >= 3000
       AND ACNTS_CLOSURE_DATE IS NULL)TT,
       MBRN_TREE1
 WHERE TT.ACNTS_BRN_CODE = BRANCH;
---------------------------
/* Formatted on 5/25/2021 12:35:18 PM (QP5 v5.252.13127.32867) */
BEGIN
   FOR IDX IN (SELECT *
                 FROM MBRN
                WHERE TRIM (MBRN_AUTH_DLR_CODE) IS NOT NULL)
   LOOP
      INSERT INTO BACKUPTABLE.TF_LOAN_DATA
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
                (SELECT MBRN_NAME
                   FROM MBRN
                  WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = IACLINK_BRN_CODE)
                   BRANCH_NAME,
                TMP_ACTUAL_ACNUM,
                TMP_ACCNT_NAME,
                FN_GET_ASON_ACBAL (1,
                                   IACLINK_INTERNAL_ACNUM,
                                   'BDT',
                                   '31-MAR-2021',
                                   '25-MAY-2021')
                   OUTSTANDING,
                LMTLINE_LIMIT_EXPIRY_DATE EXPIRY_DATE,
                TMP_PER_REPAY SHOULD_BE_REPAY,
                TMP_TIME_EQV REPAY,
                TMP_PER_REPAY - TMP_TIME_EQV PERIOD_OF_BEARER,
                PRODUCT_CODE,
                PRODUCT_NAME
           FROM (SELECT *
                   FROM TABLE (PKG_PARALLEL_CL.GET_LOAN_DETAILS_CL4 (
                                  'CL4',
                                  1,
                                  IDX.MBRN_CODE,
                                  '31-MAR-2021',
                                  1,
                                  'CL4%'))) A,
                MBRN_TREE1,
                IACLINK,
                LIMITLINE,
                ACASLLDTL,
                PRODUCTS
          WHERE     TMP_ACTUAL_ACNUM = IACLINK_ACTUAL_ACNUM
                AND IACLINK_PROD_CODE IN (3007,
                                          3009,
                                          3013,
                                          3015,
                                          3043,
                                          3045,
                                          3025,
                                          3027,
                                          3031,
                                          3955,
                                          3957,
                                          3035,
                                          3037,
                                          3047)
                AND IACLINK_ENTITY_NUM = 1
                AND TMP_ACTUAL_ACNUM IS NOT NULL
                AND IACLINK_BRN_CODE = BRANCH
                AND IACLINK_PROD_CODE = PRODUCT_CODE
                AND ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
                AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM
                AND ACASLLDTL_INTERNAL_ACNUM = IACLINK_INTERNAL_ACNUM
                AND IACLINK_BRN_CODE = IDX.MBRN_CODE
                AND ACASLLDTL_ENTITY_NUM = 1;

      COMMIT;
   END LOOP;
END;


