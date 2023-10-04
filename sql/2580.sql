SELECT ACNTS_BRN_CODE Branch_Code,
       MBRN_NAME Branch_Name,
       ACNTS_PROD_CODE Product_Code,
       PRODUCT_NAME Product_Name,
       facno (1, ACNTS_INTERNAL_ACNUM) Account_Number,
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2 Account_Name,
       (SELECT LMTLINE_DATE_OF_SANCTION
          FROM LIMITLINE
         WHERE     LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
               AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM)
          Sanction_Date,
       NULL Disburement_Date,
       0 Disburement_Amount,
       (SELECT INDCLIENT_TEL_GSM
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = ACNTS_CLIENT_NUM)
          Mobile_number,
       (FN_GET_ASON_ACBAL (1,
                           ACNTS_INTERNAL_ACNUM,
                           'BDT',
                           '18-jun-2020',
                           '21-jun-2020'))
          OUTSTANDING_BAL,
       (SELECT SUM (TRAN_BASE_CURR_EQ_AMT)
          FROM tran2020
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND TRAN_DB_CR_FLG = 'C')
          credit_amount,
       (SELECT SUM (TRAN_BASE_CURR_EQ_AMT)
          FROM tran2020
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND TRAN_DB_CR_FLG = 'D')
          debit_amount,
       ACNTS_CLOSURE_DATE
  FROM PRODUCTS,
       MBRN,
       ACNTS,
       ACASLLDTL
 WHERE     ACNTS_PROD_CODE IN (2580)
       AND ACNTS_ENTITY_NUM = 1
       AND ACNTS_PROD_CODE = PRODUCT_CODE
     AND ACNTS_OPENING_DATE <= '18-jun-2020'
       AND MBRN_CODE = ACNTS_BRN_CODE
       AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM;