/* Formatted on 10/27/2022 3:10:22 PM (QP5 v5.388) */
SELECT tt.*, '2020' "Year"
  FROM (  SELECT a.ACNTS_BRN_CODE
                     "Branch Code",
                 mbrn_name
                     "Name of the Branch",
                 facno (1, a.ACNTS_INTERNAL_ACNUM)
                     account_no,
                 ACNTS_AC_NAME1 || ACNTS_AC_NAME2
                     "Name of the Borrower",
                 a.ACNTS_AC_TYPE
                     "Nature of Loan",
                 LMTLINE_LIMIT_EFF_DATE
                     "Loan Sanction/ Renewal Date",
                 LMTLINE_SANCTION_AMT
                     "Total Sanctioned Loan",
                 ACBAL
                     "Total Outst on current year",
                 LMTLINE_LIMIT_EXPIRY_DATE
                     "Expiry Date",
                 ASSETCLSH_ASSET_CODE
                     "Classification Status"
            FROM mbrn,
                 CL_TMP_DATA c,
                 acnts      a,
                 ACASLLDTL,
                 limitline
           WHERE     c.ACNTS_ENTITY_NUM = 1
                 AND a.ACNTS_BRN_CODE = mbrn_code
                 AND ASON_DATE = TO_DATE ('12/31/2020', 'MM/DD/YYYY')
                 AND ASSETCLSH_ASSET_CODE = 'SM'
                 AND c.ACNTS_INTERNAL_ACNUM = a.ACNTS_INTERNAL_ACNUM
                 AND ACASLLDTL_ENTITY_NUM = 1
                 AND a.ACNTS_ENTITY_NUM = 1
                 AND ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
                 AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
                 AND ACASLLDTL_INTERNAL_ACNUM = a.ACNTS_INTERNAL_ACNUM
                 AND LMTLINE_LIMIT_EFF_DATE =
                     (SELECT MAX (LMTLINE_LIMIT_EFF_DATE)
                       FROM limitline
                      WHERE     LMTLINE_ENTITY_NUM = 1
                            AND LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
                            AND LMTLINE_LIMIT_EFF_DATE <=
                                TO_DATE ('12/31/2020', 'MM/DD/YYYY')
                            AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM)
        ORDER BY ABS (ACBAL) DESC) tt
 WHERE ROWNUM <= 20