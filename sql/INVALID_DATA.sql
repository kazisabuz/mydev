SELECT ACNTS_INTERNAL_ACNUM,
       CASE
          WHEN PRODUCT_FOR_RUN_ACS = 0 THEN 'Term loan'
          ELSE 'Continious Loan'
       END
          LOAN_TYPE,
       'Sanction date > Effective' PROBLEM
  FROM ACNTS,
       LIMITLINE,
       ACASLLDTL,
       PRODUCTS
 WHERE     LMTLINE_DATE_OF_SANCTION > LMTLINE_LIMIT_EFF_DATE
       AND ACNTS_PROD_CODE = PRODUCT_CODE
       AND (ACNTS_CLOSURE_DATE  IS NULL OR ACNTS_CLOSURE_DATE>=:P_DATE)
       AND LMTLINE_ENTITY_NUM = 1
       AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
       AND LMTLINE_CLIENT_CODE = ACNTS_CLIENT_NUM
       AND ACASLLDTL_ENTITY_NUM = 1
       AND ACNTS_ENTITY_NUM = 1
UNION ALL
SELECT ACNTS_INTERNAL_ACNUM,
       CASE
          WHEN PRODUCT_FOR_RUN_ACS = 0 THEN 'Term loan'
          ELSE 'Continious Loan'
       END
          LOAN_TYPE,
       'Sanction date > Expire date' PROBLEM
  FROM ACNTS,
       LIMITLINE,
       ACASLLDTL,
       PRODUCTS
 WHERE     LMTLINE_DATE_OF_SANCTION > LMTLINE_LIMIT_EXPIRY_DATE
       AND ACNTS_PROD_CODE = PRODUCT_CODE
       AND LMTLINE_ENTITY_NUM = 1
       AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND (ACNTS_CLOSURE_DATE  IS NULL OR ACNTS_CLOSURE_DATE>=:P_DATE)
       AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
       AND LMTLINE_CLIENT_CODE = ACNTS_CLIENT_NUM
       AND ACASLLDTL_ENTITY_NUM = 1
       AND ACNTS_ENTITY_NUM = 1
UNION ALL
SELECT ACNTS_INTERNAL_ACNUM,
       CASE
          WHEN PRODUCT_FOR_RUN_ACS = 0 THEN 'Term loan'
          ELSE 'Continious Loan'
       END
          LOAN_TYPE,
       'Principal Amount > Sanction Amount' PROBLEM
  FROM ACNTS,
       LIMITLINEHIST L,
       ACASLLDTL A,
       PRODUCTS,
       ADVBBAL
 WHERE     ABS (ADVBBAL_PRIN_AC_OPBAL) > L.LIMLNEHIST_SANCTION_AMT
       AND ACNTS_PROD_CODE = PRODUCT_CODE
       AND L.LIMLNEHIST_ENTITY_NUM = 1
       AND A.ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND (ACNTS_CLOSURE_DATE  IS NULL OR ACNTS_CLOSURE_DATE>=:P_DATE)
       AND A.ACASLLDTL_LIMIT_LINE_NUM = LIMLNEHIST_LIMIT_LINE_NUM
       AND ACNTS_INTERNAL_ACNUM = ADVBBAL_INTERNAL_ACNUM
       AND L.LIMLNEHIST_CLIENT_CODE = ACNTS_CLIENT_NUM
       AND ADVBBAL_YEAR = TO_NUMBER (TO_CHAR (:P_DATE + 1, 'YYYY'))
       AND ADVBBAL_MONTH = TO_NUMBER (TO_CHAR (:P_DATE + 1, 'MM'))
       AND L.LIMLNEHIST_EFF_DATE =
              (SELECT MAX (LIMLNEHIST_EFF_DATE)
                 FROM LIMITLINEHIST, ACASLLDTL
                WHERE     ACASLLDTL_ENTITY_NUM = 1
                      AND ACASLLDTL_CLIENT_NUM = LIMLNEHIST_CLIENT_CODE
                      AND ACASLLDTL_LIMIT_LINE_NUM =
                             LIMLNEHIST_LIMIT_LINE_NUM
                      AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                      AND LIMLNEHIST_EFF_DATE <= :P_DATE)
       AND A.ACASLLDTL_ENTITY_NUM = 1
       AND ACNTS_ENTITY_NUM = 1
       AND ADVBBAL_ENTITY_NUM = 1
UNION ALL
SELECT ACNTS_INTERNAL_ACNUM,
       CASE
          WHEN PRODUCT_FOR_RUN_ACS = 0 THEN 'Term loan'
          ELSE 'Continious Loan'
       END
          LOAN_TYPE,
       'Asset code not in (UC, SM, SS, DF, BL, ST)' PROBLEM
  FROM ACNTS, ASSETCLSHIST, PRODUCTS
 WHERE     ACNTS_INTERNAL_ACNUM = ASSETCLSH_INTERNAL_ACNUM
 AND (ACNTS_CLOSURE_DATE  IS NULL OR ACNTS_CLOSURE_DATE>=:P_DATE)
       AND ACNTS_PROD_CODE = PRODUCT_CODE
       AND ASSETCLSH_ASSET_CODE NOT IN ('UC', 'SM', 'SS', 'DF', 'BL', 'ST')
       AND ASSETCLSH_EFF_DATE =
              (SELECT MAX (ASSETCLSH_EFF_DATE)
                 FROM ASSETCLSHIST
                WHERE     ASSETCLSH_ENTITY_NUM = 1
                      AND ASSETCLSH_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                      AND ASSETCLSH_EFF_DATE <= :P_DATE)
       AND ACNTS_ENTITY_NUM = 1
       AND ASSETCLSH_ENTITY_NUM = 1
UNION ALL 
SELECT ACNTS_INTERNAL_ACNUM,
       CASE
          WHEN PRODUCT_FOR_RUN_ACS = 0 THEN 'Term loan'
          ELSE 'Continious Loan'
       END
          LOAN_TYPE,
       'Interest accrual date > Sanction date' PROBLEM
  FROM ACNTS,
       LIMITLINEHIST L,
       ACASLLDTL A,
       PRODUCTS,LOANACNTS
 WHERE     LNACNT_INT_ACCR_UPTO <LIMLNEHIST_DATE_OF_SANCTION
       AND ACNTS_PROD_CODE = PRODUCT_CODE
       AND L.LIMLNEHIST_ENTITY_NUM = 1
       AND A.ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND (ACNTS_CLOSURE_DATE  IS NULL OR ACNTS_CLOSURE_DATE>=:P_DATE)
       AND A.ACASLLDTL_LIMIT_LINE_NUM = LIMLNEHIST_LIMIT_LINE_NUM
        AND L.LIMLNEHIST_CLIENT_CODE = ACNTS_CLIENT_NUM
       AND LNACNT_INTERNAL_ACNUM=ACNTS_INTERNAL_ACNUM
       AND L.LIMLNEHIST_EFF_DATE =
              (SELECT MAX (LIMLNEHIST_EFF_DATE)
                 FROM LIMITLINEHIST, ACASLLDTL
                WHERE     ACASLLDTL_ENTITY_NUM = 1
                      AND ACASLLDTL_CLIENT_NUM = LIMLNEHIST_CLIENT_CODE
                      AND ACASLLDTL_LIMIT_LINE_NUM =
                             LIMLNEHIST_LIMIT_LINE_NUM
                      AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                      AND LIMLNEHIST_EFF_DATE <= :P_DATE)
       AND A.ACASLLDTL_ENTITY_NUM = 1
       AND ACNTS_ENTITY_NUM = 1
 UNION ALL
 SELECT  ACNTS_INTERNAL_ACNUM,
       CASE
          WHEN PRODUCT_FOR_RUN_ACS = 0 THEN 'Term loan'
          ELSE 'Continious Loan'
       END
          LOAN_TYPE,
       'Interest applied date > Migration date' PROBLEM
FROM ACNTS,LOANACNTS,PRODUCTS
WHERE ACNTS_INTERNAL_ACNUM=LNACNT_INTERNAL_ACNUM
AND ACNTS_ENTD_ON>LNACNT_INT_APPLIED_UPTO_DATE
AND ACNTS_PROD_CODE = PRODUCT_CODE
AND (ACNTS_CLOSURE_DATE  IS NULL OR ACNTS_CLOSURE_DATE>=:P_DATE)
AND ACNTS_ENTD_BY='MIG'
AND LNACNT_ENTITY_NUM=1
AND ACNTS_ENTITY_NUM=1
UNION ALL
SELECT ACNTS_INTERNAL_ACNUM,
       CASE
          WHEN PRODUCT_FOR_RUN_ACS = 0 THEN 'Term loan'
          ELSE 'Continious Loan'
       END
          LOAN_TYPE,
       'NPA date is Null for SS, DF, BL' PROBLEM
  FROM ACNTS, ASSETCLSHIST, PRODUCTS
 WHERE     ACNTS_INTERNAL_ACNUM = ASSETCLSH_INTERNAL_ACNUM
 AND (ACNTS_CLOSURE_DATE  IS NULL OR ACNTS_CLOSURE_DATE<:P_DATE)
 and ASSETCLSH_NPA_DATE is null
       AND ACNTS_PROD_CODE = PRODUCT_CODE
       AND ASSETCLSH_ASSET_CODE   IN ('SS', 'DF', 'BL')
       AND ASSETCLSH_EFF_DATE =
              (SELECT MAX (ASSETCLSH_EFF_DATE)
                 FROM ASSETCLSHIST
                WHERE     ASSETCLSH_ENTITY_NUM = 1
                      AND ASSETCLSH_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                      AND ASSETCLSH_EFF_DATE <= :P_DATE)
       AND ACNTS_ENTITY_NUM = 1
       AND ASSETCLSH_ENTITY_NUM = 1
       
       
       SELECT ACNTS_INTERNAL_ACNUM,
       CASE
          WHEN PRODUCT_FOR_RUN_ACS = 0 THEN 'Term loan'
          ELSE 'Continious Loan'
       END
          LOAN_TYPE,
       'Interest accrual date > Sanction date' PROBLEM
  FROM ACNTS,
       LIMITLINEHIST L,
       ACASLLDTL A,
       PRODUCTS,ASSETCLSHIST
 WHERE     ASSETCLSH_NPA_DATE <LIMLNEHIST_DATE_OF_SANCTION
       AND ACNTS_PROD_CODE = PRODUCT_CODE
       AND L.LIMLNEHIST_ENTITY_NUM = 1
       AND A.ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND (ACNTS_CLOSURE_DATE  IS NULL OR ACNTS_CLOSURE_DATE<:P_DATE)
        AND A.ACASLLDTL_LIMIT_LINE_NUM = LIMLNEHIST_LIMIT_LINE_NUM
       AND ASSETCLSH_NPA_DATE IS NOT NULL
        AND L.LIMLNEHIST_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
       AND ASSETCLSH_EFF_DATE =
              (SELECT MAX (ASSETCLSH_EFF_DATE)
                 FROM   ASSETCLSHIST
                WHERE     ASSETCLSH_ENTITY_NUM = 1
                       
                      AND ASSETCLSH_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                      AND ASSETCLSH_EFF_DATE <= :P_DATE)
       AND A.ACASLLDTL_ENTITY_NUM = 1
       AND ACNTS_ENTITY_NUM = 1
        AND ASSETCLSH_ASSET_CODE   IN ('SS', 'DF', 'BL')