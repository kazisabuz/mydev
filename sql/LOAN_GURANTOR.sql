-----------loan guarantor informaion------------------------------
SELECT FACNO (1, ACNTS_INTERNAL_ACNUM)
           LOAN_AC_NO,
       LOAN_AC_NAME,
       LOAN_PRODUCT_CODE,
       PRODUCT_NAME,
       SANCTION_AMOUNT,
       OUTSTANDING,
       CL_STATUS,
       CLIENTS_CODE
           GUARANTOR_CUSTOMER_CODE,
       CLIENTS_NAME
           GUARANTOR_NAME,
       RELATION_DESCN
           RELATION_WITH_CLIENTS,
       (SELECT INDCLIENT_FATHER_NAME
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
           "Father Name",
       (SELECT INDCLIENT_MOTHER_NAME
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
           "Mother Name",
       (SELECT INDSPOUSE_SPOUSE_NAME
          FROM INDCLIENTSPOUSE
         WHERE INDSPOUSE_CLIENT_CODE = CLIENTS_CODE AND INDSPOUSE_SL = 1)
           "Spouse Name",
       FN_GET_PIDWITHTYPE (CLIENTS_CODE)
           NID_NUM,
       GET_MOBILE_NUM (CLIENTS_CODE)
           "Mobile No",
       FN_GET_ADDRESS (CLIENTS_CODE, '01')
           "PRESENT ADDRESS",
       FN_GET_ADDRESS (CLIENTS_CODE, '02')
           "PERMANENT ADDRESS"
  FROM (SELECT ACNTS_INTERNAL_ACNUM,
               ACNTS_AC_NAME1 || ACNTS_AC_NAME2
                   LOAN_AC_NAME,
               ACNTS_PROD_CODE
                   LOAN_PRODUCT_CODE,
               PRODUCT_NAME
                   PRODUCT_NAME,
               LMTLINE_SANCTION_AMT
                   SANCTION_AMOUNT,
               FN_GET_ASON_ACBAL ( :ENTITY_NO,
                                  ACNTS_INTERNAL_ACNUM,
                                  ACNTS_CURR_CODE,
                                  TO_DATE ( :W_CURR_DATE, 'DD-MM-YYYY'),
                                  TO_DATE ( :W_CURR_DATE, 'DD-MM-YYYY'))
                   OUTSTANDING,
               ASSETCLS_ASSET_CODE
                   CL_STATUS
          FROM PRODUCTS,
               ACNTS,
               ACASLLDTL,
               LIMITLINE,
               ASSETCLS
         WHERE     ACNTS_ENTITY_NUM = :ENTITY_NO
               AND ACNTS_PROD_CODE = PRODUCT_CODE
               AND ASSETCLS_ENTITY_NUM = :ENTITY_NO
               AND LMTLINE_ENTITY_NUM = :ENTITY_NO
               AND PRODUCT_FOR_LOANS = 1
               AND ASSETCLS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACASLLDTL_ENTITY_NUM = 1
               AND ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
               AND ACNTS_BRN_CODE = :BRN_CODE
               AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
               AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM) A
       LEFT JOIN
       (SELECT LNGUAR_INTERNAL_ACNUM,
               CLIENTS_CODE,
               CLIENTS_NAME,
               RELATION_DESCN
          FROM LNACGUAR, CLIENTS, RELATION
         WHERE     CLIENTS_CODE = LNGUAR_GUAR_CLIENT_CODE
               AND RELATION_CODE = LNGUAR_RELATION_CODE) B
           ON (B.LNGUAR_INTERNAL_ACNUM = A.ACNTS_INTERNAL_ACNUM)