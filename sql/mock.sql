/* Formatted on 12/18/2019 11:17:42 AM (QP5 v5.227.12220.39754) */
SELECT DISTINCT ACNTS_BRN_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_CODE = ACNTS_BRN_CODE)
          MBRN_NAME,
       FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NO,
       ACNTS_AC_TYPE,
       ACNTS_AC_SUB_TYPE,
       SBCAINTPAY_APPLY_AMOUNT,
       SBCACALC_INT_RATE,
       SBCAINTPAY_DATE_OF_ENTRY
  FROM  ACNTS, ACNTEXCISEAMT
 WHERE     SBCAINTPAY_ENTITY_NUM = 1
       -- AND SBCAINTPAY_BRN_CODE = 1180
       AND SBCAINTPAY_DATE_OF_ENTRY =
              TO_DATE ('12/31/2019 00:00:00', 'MM/DD/YYYY HH24:MI:SS')
      -- AND SBCACALC_INT_ACCR_UPTO_DATE = SBCAINTPAY_DATE_OF_ENTRY
       AND ACNTS_PROD_CODE = 1030
      -- AND SBCACALC_INTERNAL_ACNUM = SBCAINTPAY_INTERNAL_ACNUM
       AND ACNTEXCAMT_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
     --  AND SBCACALC_INT_RATE > 3.5
       AND ACNTS_ENTITY_NUM = 1
       
       
       
       /* Formatted on 12/18/2019 11:17:42 AM (QP5 v5.227.12220.39754) */
SELECT DISTINCT ACNTS_BRN_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_CODE = ACNTS_BRN_CODE)
          MBRN_NAME,
       FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NO,
       ACNTS_AC_TYPE,
       ACNTS_AC_SUB_TYPE,
       ACNTEXCAMT_EXCISE_AMT,ACNTEXCAMT_PROCESS_DATE
  FROM  ACNTS, ACNTEXCISEAMT
 WHERE     ACNTEXCAMT_ENTITY_NUM = 1
       -- AND SBCAINTPAY_BRN_CODE = 1180
       AND ACNTEXCAMT_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
     --  AND SBCACALC_INT_RATE > 3.5
       AND ACNTS_ENTITY_NUM = 1
    and    ACNTEXCAMT_ENTITY_NUM = 1
---AND ACNTEXCAMT_INTERNAL_ACNUM = 10101600004580
AND ACNTEXCAMT_FIN_YEAR = 2019
AND ACNTEXCAMT_EXCISE_AMT not in (150, 500, 2500, 12000 , 25000)
and ACNTEXCAMT_EXCISE_AMT<>0



/* Formatted on 12/18/2019 11:17:42 AM (QP5 v5.227.12220.39754) */
SELECT distinct ACNTS_BRN_CODE,
       (SELECT mbrn_name
          FROM mbrn
         WHERE mbrn_code = ACNTS_BRN_CODE)
          mbrn_name,
       facno (1, ACNTS_INTERNAL_ACNUM) account_no,
       ACNTS_AC_TYPE,
       ACNTS_AC_SUB_TYPE,
       SBCAINTPAY_APPLY_AMOUNT,
     --  SBCACALC_INT_RATE,
       SBCAINTPAY_DATE_OF_ENTRY
  FROM SBCAINTPAY, ACNTS
 WHERE     SBCAINTPAY_ENTITY_NUM = 1
       AND SBCAINTPAY_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       -- AND SBCAINTPAY_BRN_CODE = 1180
       AND SBCAINTPAY_DATE_OF_ENTRY =
              TO_DATE ('12/31/2019 00:00:00', 'MM/DD/YYYY HH24:MI:SS')
      -- AND SBCACALC_INT_ACCR_UPTO_DATE = SBCAINTPAY_DATE_OF_ENTRY
       AND ACNTS_PROD_CODE = 1030
      -- AND SBCACALC_INTERNAL_ACNUM = SBCAINTPAY_INTERNAL_ACNUM
     --  AND SBCACALC_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
     --  AND SBCACALC_INT_RATE > 3.5
     and SBCAINTPAY_APPLY_AMOUNT>5000000
       AND ACNTS_ENTITY_NUM = 1
       
       
       /* Formatted on 12/18/2019 12:09:12 PM (QP5 v5.227.12220.39754) */
SELECT DISTINCT ACNTS_BRN_CODE,
                (SELECT MBRN_NAME
                   FROM MBRN
                  WHERE MBRN_CODE = ACNTS_BRN_CODE)
                   MBRN_NAME,
                FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NO,
                ACNTS_AC_TYPE,
                ACNTS_AC_SUB_TYPE,
                ACNTBAL_BC_BAL
  FROM acnts, acntbal
 WHERE     ACNTS_INTERNAL_ACNUM = ACNTBAL_INTERNAL_ACNUM
       AND ACNTS_ENTITY_NUM = 1
       AND ACNTS_CLOSURE_DATE IS NOT NULL
       AND ACNTBAL_BC_BAL <> 0
       
       
       
       
       
       /* Formatted on 12/18/2019 1:34:09 PM (QP5 v5.227.12220.39754) */
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
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = ACNTS_BRN_CODE)
            MBRN_NAME,
         TT.*
    FROM (SELECT ACNTS_BRN_CODE,
                 FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NO,
                 ACNTS_CLIENT_NUM client_code,
                 ACNTS_AC_NAME1 || ACNTS_AC_NAME2 account_name,
                 ACNTS_AC_TYPE,
                 ACNTS_AC_SUB_TYPE
            FROM CLCHGWAIVER, ACNTS,CLCHGWAIVEDTL
           WHERE     ACNTS_ENTITY_NUM = 1
           AND CLCHGWAIVDT_CHARGE_CODE = 'ED'
                -- AND LNPRODIR_AC_TYPE = ACNTS_AC_TYPE
               --  AND LNPRODIR_AC_SUB_TYPE = ACNTS_AC_SUB_TYPE
                 AND ACNTS_CLOSURE_DATE IS NOT NULL
                 AND (   CLCHGWAIV_CLIENT_NUM <> 0
                      OR CLCHGWAIV_INTERNAL_ACNUM <> 0)
                 AND (   ACNTS_INTERNAL_ACNUM = CLCHGWAIV_INTERNAL_ACNUM
                      OR ACNTS_CLIENT_NUM = CLCHGWAIV_CLIENT_NUM)
                 AND CLCHGWAIV_WAIVE_REQD = 1
                 and  CLCHGWAIV_CLIENT_NUM=CLCHGWAIVDT_CLIENT_NUM 
                 and  CLCHGWAIV_INTERNAL_ACNUM=CLCHGWAIVDT_INTERNAL_ACNUM
                ) TT,
         MBRN_TREE2
   WHERE BRANCH_CODE = TT.ACNTS_BRN_CODE
ORDER BY ACNTS_BRN_CODE





/* Formatted on 12/18/2019 12:52:34 PM (QP5 v5.227.12220.39754) */
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
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = ACNTS_BRN_CODE)
            MBRN_NAME,
         TT.*
    FROM (SELECT ACNTS_BRN_CODE,
                 FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NO,
                 ACNTS_CLIENT_NUM client_code,
                 ACNTS_AC_NAME1 || ACNTS_AC_NAME2 account_name,
                 ACNTS_AC_TYPE,
                 ACNTS_AC_SUB_TYPE,
                 LNPRODIR_APPL_INT_RATE
            FROM LNPRODIR, ACNTS,LNPRODPM
           WHERE     ACNTS_PROD_CODE = LNPRODIR_PROD_CODE
                 AND ACNTS_ENTITY_NUM = 1
                 and LNPRODIR_AC_TYPE=ACNTS_AC_TYPE
                 and LNPRODIR_AC_SUB_TYPE=ACNTS_AC_SUB_TYPE
                 AND ACNTS_CLOSURE_DATE IS NOT NULL
                 AND LNPRODIR_APPL_INT_RATE < 9
                 and LNPRD_STAFF_LOAN=0
                 and LNPRD_PROD_CODE=LNPRODIR_PROD_CODE
                 AND ACNTS_PROD_CODE <> 2034) TT,
         MBRN_TREE2
   WHERE BRANCH_CODE = TT.ACNTS_BRN_CODE
ORDER BY ACNTS_BRN_CODE