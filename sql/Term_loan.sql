/*Report for the customer*/
CREATE TABLE BACKUPTABLE.TERM_LOAN_FORMAT AS 
SELECT ROWNUM SL,
       ACNTS_BRN_CODE Branch_code,
       (SELECT MBRN_PARENT_ADMIN_CODE
          FROM MBRN
         WHERE MBRN_CODE = ACNTS_BRN_CODE)
          "PO Code",
       (SELECT MBRN_NAME
          FROM MBRN MM
         WHERE MM.MBRN_CODE = (SELECT MBRN_PARENT_ADMIN_CODE
                                 FROM MBRN
                                WHERE MBRN_CODE = ACNTS_BRN_CODE))
          "PO Name",
       FACNO (1, ACNTS_INTERNAL_ACNUM) "Account No",
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2 "Account Name",
       ACNTS_PROD_CODE "Product code",
       ACNTS_AC_TYPE "Loan Type/ Nature",
       LMTLINE_DATE_OF_SANCTION "Sanction Date",
       LMTLINE_LIMIT_EXPIRY_DATE "Expire Date",
       FN_GET_ASON_ACBAL (1,
                          ACNTS_INTERNAL_ACNUM,
                          'BDT',
                          '31-MAR-2018',
                          PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (1))
          "Outstanding Balance ",
       LNACRSDTL_REPAY_FROM_DATE "Repayment Start Date",
       LNACRSDTL_REPAY_FREQ "Frequency",
       (SELECT MAX (LNREPAY_ENTRY_DATE)
          FROM LNREPAY
         WHERE     LNREPAY_ENTITY_NUM = 1
               AND LNREPAY_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND LNREPAY_ENTRY_DATE <= '31-MAR-2018')
          "Last Instalment given",
       NVL (
          (SELECT NVL (LNSUSPBAL_SUSP_BAL, 0)
             FROM LNSUSPBAL
            WHERE     LNSUSPBAL_ENTITY_NUM = 1
                  AND LNSUSPBAL_ACNT_NUM = ACNTS_INTERNAL_ACNUM),
          0)
          "Suspense Balance",
       LNACRSDTL_REPAY_AMT "Instalment Size",
       (SELECT SUM (LNACDISB_DISB_AMT)
          FROM LNACDISB
         WHERE     LNACDISB_ENTITY_NUM = 1
               AND LNACDISB_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND LNACDISB_DISB_ON <= '31-MAR-2018'
               AND LNACDISB_AUTH_BY IS NOT NULL)
          "Disbursement Amount",
       (SELECT LNTOTINTDB_TOT_INT_DB_AMT
          FROM LNTOTINTDBMIG
         WHERE     LNTOTINTDB_ENTITY_NUM = 1
               AND LNTOTINTDB_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM)
          TOTAL_INT_AND_CHARG_BEFORE_MIG,
       (SELECT SUM (TRANADV_INTRD_BC_AMT + TRANADV_CHARGE_BC_AMT)
          FROM MV_LOAN_ACCOUNT_BAL_OD
         WHERE     TRAN_INTERNAL_ACNUM = LNACRSDTL_INTERNAL_ACNUM
               AND TRAN_DB_CR_FLG = 'D'
               AND TRAN_DATE_OF_TRAN <= '31-MAR-2018')
          TOTAL_INT_AND_CHARG_AFTER_MIG,
       (SELECT ASSETCLSH_ASSET_CODE
          FROM ASSETCLSHIST
         WHERE     ASSETCLSH_ENTITY_NUM = 1
               AND ASSETCLSH_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ASSETCLSH_EFF_DATE =
                      (SELECT MAX (ASSETCLSH_EFF_DATE)
                         FROM ASSETCLSHIST
                        WHERE     ASSETCLSH_ENTITY_NUM = 1
                              AND ASSETCLSH_INTERNAL_ACNUM =
                                     ACNTS_INTERNAL_ACNUM
                              AND ASSETCLSH_EFF_DATE <= '31-MAR-2018'))
          "CL Status",
       CASE WHEN ACNTS_ENTD_BY = 'MIG' THEN 'Legacy' ELSE 'CBS' END
          "Origin of Account(CBS/Legacy)",
       MIG_END_DATE "CBS Migration Date"
  FROM ACNTS,
       PRODUCTS,
       ACASLLDTL,
       LIMITLINE,
       LNACRSDTL,
       MIG_DETAIL
 WHERE     ACNTS_ENTITY_NUM = 1
       AND PRODUCT_CODE = ACNTS_PROD_CODE
       AND PRODUCT_FOR_LOANS = 1
       AND PRODUCT_FOR_RUN_ACS = 0
       --AND ACNTS_BRN_CODE = 27193
       AND ACASLLDTL_ENTITY_NUM = LMTLINE_ENTITY_NUM
       AND LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
       AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
       AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND BRANCH_CODE = ACNTS_BRN_CODE
       AND ACNTS_CLOSURE_DATE IS NULL
       AND LNACRSDTL_ENTITY_NUM = 1
       AND LNACRSDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND ACASLLDTL_ACNT_SL = 1;