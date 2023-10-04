/* Formatted on 7/3/2022 4:16:35 PM (QP5 v5.227.12220.39754) */
SELECT T.*
  FROM (  SELECT CASE
                    WHEN    SUBSTR (CL_FORM_NO, 1, 2)
                         || '-'
                         || SUBSTR (CL_FORM_NO, 3, 1) = 'CL-7'
                    THEN
                       'CL-6'
                    ELSE
                          SUBSTR (CL_FORM_NO, 1, 2)
                       || '-'
                       || SUBSTR (CL_FORM_NO, 3, 1)
                 END
                    CLHEAD,
                 LPAD (BRANCH_CODE, 5, 0) BRCODE,
                 ACC_NAME || ' ' || NID_NO NAME_AND_NID,
                 (SELECT A.ACNTS_AC_TYPE
                    FROM ACNTS A
                   WHERE     A.ACNTS_ENTITY_NUM = 1
                         AND A.ACNTS_INTERNAL_ACNUM =
                                (SELECT IACLINK_INTERNAL_ACNUM
                                   FROM IACLINK
                                  WHERE     IACLINK_ACTUAL_ACNUM = L.ACC_NO
                                        AND IACLINK_ENTITY_NUM = 1))
                    NATURE_OF_LOAN,
                 (SELECT 1
                    FROM PRODUCTS P1
                   WHERE     P1.PRODUCT_FOR_LOANS = 1
                         AND P1.PRODUCT_FOR_RUN_ACS = 0
                         AND P1.PRODUCT_CODE = L.PROD_CODE)
                    TERM_LOAN,
                 (SELECT 1
                    FROM PRODUCTS P1
                   WHERE     P1.PRODUCT_FOR_LOANS = 1
                         AND P1.PRODUCT_FOR_RUN_ACS = 1
                         AND P1.PRODUCT_CODE = L.PROD_CODE)
                    CONT_LOAN,
                 (SELECT LS.LNACRSDTL_REPAY_FROM_DATE
                    FROM LNACRSDTL LS
                   WHERE     LS.LNACRSDTL_ENTITY_NUM = 1
                         AND LS.LNACRSDTL_INTERNAL_ACNUM =
                                (SELECT IACLINK_INTERNAL_ACNUM
                                   FROM IACLINK
                                  WHERE     IACLINK_ACTUAL_ACNUM = L.ACC_NO
                                        AND IACLINK_ENTITY_NUM = 1))
                    LNACRSDTL_REPAY_FROM_DATE,
                 CASE
                    WHEN LENGTH (CL_FORM_NO) = 3
                    THEN
                       CASE
                          WHEN    SUBSTR (CL_FORM_NO, 1, 2)
                               || '-'
                               || SUBSTR (CL_FORM_NO, 3, 1) = 'CL-7'
                          THEN
                             'STAFF'
                          ELSE
                                SUBSTR (CL_FORM_NO, 1, 2)
                             || '-'
                             || SUBSTR (CL_FORM_NO, 3, 1)
                       END
                    WHEN LENGTH (CL_FORM_NO) = 4
                    THEN
                          SUBSTR (CL_FORM_NO, 1, 2)
                       || '-'
                       || SUBSTR (CL_FORM_NO, 3, 1)
                       || '('
                       || CASE
                             WHEN SUBSTR (CL_FORM_NO, 4) = 1 THEN 'i' || ')'
                             WHEN SUBSTR (CL_FORM_NO, 4) = 2 THEN 'ii' || ')'
                             WHEN SUBSTR (CL_FORM_NO, 4) = 3 THEN 'iii' || ')'
                             WHEN SUBSTR (CL_FORM_NO, 4) = 4 THEN 'iv' || ')'
                             WHEN SUBSTR (CL_FORM_NO, 4) = 5 THEN 'v' || ')'
                             WHEN SUBSTR (CL_FORM_NO, 4) = 6 THEN 'vi' || ')'
                          END
                 END
                    ENTRY_SL,
                 ACC_NO ACCNO,
                 BORROWER_FIS_CODE FIS_CODE,
                 TO_DATE (SANC_RESCHE_DATE, 'DD/MM/YYYY') SANC_DATE,
                 ROUND (FIRST_SANC_LIMIT) SANC_AMOUNT,
                 ROUND (OUTSTANDING_BAL) BAL_OUT,
                 CASE
                    WHEN    SUBSTR (CL_FORM_NO, 1, 2)
                         || '-'
                         || SUBSTR (CL_FORM_NO, 3, 1) = 'CL-4'
                    THEN
                       TO_DATE (FIRST_REPAY_DUE_DATE, 'DD/MM/YYYY')
                    WHEN TRIM (EXPIRY_DATE) IS NOT NULL
                    THEN
                       TO_DATE (EXPIRY_DATE, 'DD/MM/YYYY')
                 END
                    EXP_DATE,
                 FN_GET_PAID_AMT (
                    1,
                    (SELECT IACLINK_INTERNAL_ACNUM
                       FROM IACLINK
                      WHERE     IACLINK_ACTUAL_ACNUM = L.ACC_NO
                            AND IACLINK_ENTITY_NUM = 1),
                    FN_GET_CURRENT_BUSINESS_DATE)
                    AMT_PAID,
                 ROUND (INSTALL_AMT) "SIZE",
                 DECODE (REPAY_FREQ,  'M', 1,  'Q', 3,  'H', 6,  'Y', 12)
                    FREQUENCY,
                 ROUND (INT_SUSP) INTT_SUSP,
                 CASE
                    WHEN SEC_CODE = '50' THEN ROUND (ELIGIBLE_SEC_VAL) / 2
                    ELSE ROUND (ELIGIBLE_SEC_VAL)
                 END
                    VAL_OF_SECURITY
            FROM TABLE (PKG_MIS_STATS.GET_BRANCH_WISE (
                           1,
                           :P_BRANCH_CODE,
                           CASE
                              WHEN 2 = '1' THEN '01-JAN-' || '2022'
                              WHEN 2 = '2' THEN '01-APR-' || '2022'
                              WHEN 2 = '3' THEN '01-JUL-' || '2022'
                              WHEN 2 = '4' THEN '01-OCT-' || '2022'
                           END,
                           CASE
                              WHEN 2 = '1' THEN '31-MAR-' || '2022'
                              WHEN 2 = '2' THEN '30-JUN-' || '2022'
                              WHEN 2 = '3' THEN '30-SEP-' || '2022'
                           END)) L
         ) T;
         
         
         
--------CL 2
/* Formatted on 7/3/2022 4:16:35 PM (QP5 v5.227.12220.39754) */
SELECT T.*
  FROM (  SELECT CLHEAD,
       BRCODE,
       ACNAME,
       NATURE_OF_LOAN,
       ENTRY_SL,
       ACNO,
       SANC_DT,
       RENEWAL_DT,
       RENEWAL_NO,
       SANC_AMT,
       RENEWAL_AMT,
       BAL_OUT,
       EXP_DT POA1,
       AMT_PAID,
       NO_INT,
       POA,
       OC,
       QJ,
       CL_STATUS,
       BASIS_OF_CL,
       OUT_AMT_STD,
       OUT_AMT_SMA,
       OUT_AMT_SS,
       OUT_AMT_DF,
       OUT_AMT_BL,
       OUT_AMT_DEFLTR,
       SUSP_AMT_UC,
       SUSP_AMT_SMA,
       SUSP_AMT_CLAC,
       TOTAL_SUSP,
       SIZEE,
       FREQUENCY,
       INT_SUSP,
       VAL_OF_SECURITY,
       BASE_SMA,
       BASE_SS,
       BASE_DF,
       BASE_BL,
       REMARKS,
       NID,
       RPT_QTR,
       ENTRYDT,
       USER_ID,
       AMT_PROB_REQ,
       TRANSTATS,
       BASE_SMA1,
       BASE_SS1,
       BASE_DF1,
       BASE_BL1,
       TRANNO,
       OUT_AMT_DEFLTR1,
       AMT_BASE_EXIT,
       PRODUCT_CODE,
       LOAN_CODE,
       SME_ID,
       ACTUAL_PROV,
       FIS_CODE,
       SECTOR_CODE SECURITY_CODE,
       AUTO_MANUAL,
       PROV_REQUIRED,
       PROV_MAINTAIN
            FROM TABLE (PKG_MIS_STATS.GET_BRANCH_WISE (
                           1,
                           :P_BRANCH_CODE,
                           CASE
                              WHEN 2 = '1' THEN '01-JAN-' || '2022'
                              WHEN 2 = '2' THEN '01-APR-' || '2022'
                              WHEN 2 = '3' THEN '01-JUL-' || '2022'
                              WHEN 2 = '4' THEN '01-OCT-' || '2022'
                           END,
                           CASE
                              WHEN 2 = '1' THEN '31-MAR-' || '2022'
                              WHEN 2 = '2' THEN '30-JUN-' || '2022'
                              WHEN 2 = '3' THEN '30-SEP-' || '2022'
                           END)) L
         ) T;