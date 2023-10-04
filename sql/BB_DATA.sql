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