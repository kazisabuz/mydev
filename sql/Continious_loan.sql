/*Script to generate data to the customer. */
CREATE TABLE BACKUPTABLE.CONTINUOUS_LOAN_FORMAT AS 
SELECT ROWNUM SL,
       ACNTS_BRN_CODE Branch_code,
       (SELECT MBRN_PARENT_ADMIN_CODE
                                 FROM MBRN
                                WHERE MBRN_CODE = ACNTS_BRN_CODE) "PO Code",
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
       (SELECT NVL (SUM (SD.SECAGMTDTL_ASSIGN_AMT), 0)
          FROM SECASSIGNMENTS S, SECASSIGNMTDTL SD, SECRCPT SC
         WHERE     S.SECAGMT_ENTITY_NUM = 1
               AND SD.SECAGMTDTL_ENTITY_NUM = 1
               AND ACASLLDTL_ENTITY_NUM = 1
               AND SC.SECRCPT_ENTITY_NUM = 1
               AND S.SECAGMT_SEC_NUM = SD.SECAGMTDTL_SEC_NUM
               AND S.SECAGMT_AUTH_BY IS NOT NULL
               AND S.SECAGMT_REJ_BY IS NULL
               AND ACASLLDTL_ENTITY_NUM = SD.SECAGMTDTL_ENTITY_NUM
               AND SD.SECAGMTDTL_SEC_NUM = SC.SECRCPT_SECURITY_NUM
               AND SC.SECRCPT_CLIENT_NUM = SD.SECAGMTDTL_CLIENT_NUM
               AND ACASLLDTL_CLIENT_NUM = SD.SECAGMTDTL_CLIENT_NUM
               AND ACASLLDTL_LIMIT_LINE_NUM = SD.SECAGMTDTL_LIMIT_LINE_NUM
               AND ACASLLDTL_CLIENT_NUM = SECAGMTDTL_CLIENT_NUM
               AND ACASLLDTL_LIMIT_LINE_NUM = ACASLLDTL_LIMIT_LINE_NUM
               AND SECAGMTDTL_DATE =
                      (SELECT MAX (SECAGMTDTL_DATE)
                         FROM SECASSIGNMTDTL
                        WHERE     S.SECAGMT_ENTITY_NUM = 1
                              AND SD.SECAGMTDTL_ENTITY_NUM = 1
                              AND ACASLLDTL_ENTITY_NUM = 1
                              AND SC.SECRCPT_ENTITY_NUM = 1
                              AND S.SECAGMT_SEC_NUM = SD.SECAGMTDTL_SEC_NUM
                              AND S.SECAGMT_AUTH_BY IS NOT NULL
                              AND S.SECAGMT_REJ_BY IS NULL
                              AND ACASLLDTL_ENTITY_NUM =
                                     SD.SECAGMTDTL_ENTITY_NUM
                              AND SD.SECAGMTDTL_SEC_NUM =
                                     SC.SECRCPT_SECURITY_NUM
                              AND SC.SECRCPT_CLIENT_NUM =
                                     SD.SECAGMTDTL_CLIENT_NUM
                              AND ACASLLDTL_CLIENT_NUM =
                                     SD.SECAGMTDTL_CLIENT_NUM
                              AND ACASLLDTL_LIMIT_LINE_NUM =
                                     SD.SECAGMTDTL_LIMIT_LINE_NUM
                              AND ACASLLDTL_CLIENT_NUM =
                                     SECAGMTDTL_CLIENT_NUM
                              AND ACASLLDTL_LIMIT_LINE_NUM =
                                     ACASLLDTL_LIMIT_LINE_NUM
                              AND SECAGMTDTL_DATE <= '31-MAR-2018'))
          "Value of Security",
       NVL (
          (SELECT NVL (LNSUSPBAL_SUSP_BAL, 0)
             FROM LNSUSPBAL
            WHERE     LNSUSPBAL_ENTITY_NUM = 1
                  AND LNSUSPBAL_ACNT_NUM = ACNTS_INTERNAL_ACNUM),
          0)
          "Suspense Balance",
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
       MIG_DETAIL
 WHERE     ACNTS_ENTITY_NUM = 1
       AND PRODUCT_CODE = ACNTS_PROD_CODE
       AND PRODUCT_FOR_LOANS = 1
       AND PRODUCT_FOR_RUN_ACS = 1
       --AND ACNTS_BRN_CODE = 27193
       AND BRANCH_CODE = ACNTS_BRN_CODE
       AND ACASLLDTL_ENTITY_NUM = LMTLINE_ENTITY_NUM
       AND LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
       AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
       AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND ACNTS_CLOSURE_DATE IS NULL;
      