/* Formatted on 7/30/2019 2:25:20 PM (QP5 v5.227.12220.39754) */
SELECT
       (SELECT GMO_BRANCH
          FROM MBRN_TREE1
         WHERE BRANCH = IACLINK_BRN_CODE)
          GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN M
         WHERE MBRN_CODE = (SELECT GMO_BRANCH
                              FROM MBRN_TREE1
                             WHERE BRANCH = IACLINK_BRN_CODE))
          GMO_NAME,(SELECT PO_BRANCH
          FROM MBRN_TREE1
         WHERE BRANCH = IACLINK_BRN_CODE)
          PO_RO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN M
         WHERE MBRN_CODE = (SELECT PO_BRANCH
                              FROM MBRN_TREE1
                             WHERE BRANCH = IACLINK_BRN_CODE))
          PO_RO_NAME,
       IACLINK_BRN_CODE BRANCH_CODE,
       MBRN_NAME BR_NAME,
       AC_NUM ACNTS_ACNUM,
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACC_NAME,
       ACNTS_OPENING_DATE ACNTS_OPENING_DATE,
       A.ACNTS_AC_TYPE ACNTS_AC_TYPE,
       A.ACNTS_PROD_CODE PRODUCT_CODE,
       ACNTS_CLIENT_NUM CLIENTS_CODE,
       --CLIENTS_TYPE_FLG CLIENTS_TYPE_FLG,
       ---  CLIENTS_CONST_CODE CLIENTS_CONST_CODE,
       TRAN_DATE_OF_TRAN TRANSACTION_DATE,
       TRAN_AMOUNT TRANSACTION_AMOUNT,
       TRAN_DB_CR_FLG TRANSACTION_FLAG,
       -- ACNTS_AC_NAME1 || ACNTS_AC_NAME2 TITLE_NAME,
       (SELECT INDCLIENT_FIRST_NAME
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
          FIRST_NAME,
       (SELECT INDCLIENT_LAST_NAME
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
          MIDDLE_NAME,
       (SELECT INDCLIENT_SUR_NAME
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
          LAST_NAME,
       (SELECT INDCLIENT_FATHER_NAME
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
          CLIENT_FATHER_NAME,
       (SELECT INDCLIENT_MOTHER_NAME
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
          CLIENT_MOTHER_NAME,
       (SELECT INDSPOUSE_SPOUSE_NAME
          FROM INDCLIENTSPOUSE
         WHERE INDSPOUSE_CLIENT_CODE = CLIENTS_CODE AND INDSPOUSE_SL = 1)
          SPOUSE_NAME,
       (SELECT INDCLIENT_BIRTH_DATE
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
          BIRTH_DATE,
       (SELECT INDCLIENT_SEX
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
          GENDER,
       (SELECT OCCUPATIONS_DESCN
          FROM INDCLIENTS, OCCUPATIONS
         WHERE     INDCLIENT_CODE = CLIENTS_CODE
               AND INDCLIENT_OCCUPN_CODE = OCCUPATIONS_CODE)
          OCCUPATION,
       (SELECT TRIM (DESIG_DESCN)
          FROM INDCLIENTS, DESIGNATIONS
         WHERE     INDCLIENT_CODE = CLIENTS_CODE
               AND INDCLIENT_DESIG_CODE = DESIG_CODE)
          "DESIGNATIONS/POSITION",
       (SELECT INDCLIENT_EMP_CMP_NAME
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
          "COMPANY/ORGANIZATION",
       (SELECT PIDDOCS_DOCID_NUM
          FROM PIDDOCS, INDCLIENTS
         WHERE     INDCLIENT_PID_INV_NUM = PIDDOCS_INV_NUM
               AND PIDDOCS_PID_TYPE ='NID'
             --  AND PIDDOCS_DOC_SL = 1
               AND INDCLIENT_CODE = CLIENTS_CODE)
          NID_NUMBER,
       (SELECT PIDDOCS_DOCID_NUM
          FROM PIDDOCS, INDCLIENTS
         WHERE     INDCLIENT_PID_INV_NUM = PIDDOCS_INV_NUM
               AND PIDDOCS_PID_TYPE IN ('SID')
            --   AND PIDDOCS_DOC_SL = 1
               AND INDCLIENT_CODE = CLIENTS_CODE)
          SMART_CARD,
       CLIENTS_PAN_GIR_NUM TIN,
       NULL ETIN,
       (SELECT PIDDOCS_DOCID_NUM
          FROM PIDDOCS, INDCLIENTS
         WHERE     INDCLIENT_PID_INV_NUM = PIDDOCS_INV_NUM
               AND PIDDOCS_PID_TYPE = 'PP'
            --   AND PIDDOCS_DOC_SL = 1
               AND INDCLIENT_CODE = CLIENTS_CODE)
          PASPORT_NUMBER,
       (SELECT PIDDOCS_DOCID_NUM
          FROM PIDDOCS, INDCLIENTS
         WHERE     INDCLIENT_PID_INV_NUM = PIDDOCS_INV_NUM
               AND PIDDOCS_PID_TYPE = 'DL'
             --  AND PIDDOCS_DOC_SL = 1
               AND INDCLIENT_CODE = CLIENTS_CODE)
          DRIVING_LICENCE_NO,
       NULL TRADE_LICENCE_NO,
       (SELECT PIDDOCS_DOCID_NUM
          FROM PIDDOCS, INDCLIENTS
         WHERE     INDCLIENT_PID_INV_NUM = PIDDOCS_INV_NUM
               AND PIDDOCS_PID_TYPE = 'BC'
             --  AND PIDDOCS_DOC_SL = 1
               AND INDCLIENT_CODE = CLIENTS_CODE)
          BIRTH_REG_NO,
       (SELECT ADDRDTLS_MOBILE_NUM
          FROM ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_SL = 1)
          MOBILE_NUM,
       -- NULL BUSINESS_ID_NO,
       (SELECT INDCLIENT_TEL_RES
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
          LAND_PHONE_NUMBER,
       (SELECT NVL (INDCLIENT_EMAIL_ADDR1, INDCLIENT_EMAIL_ADDR2)
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
          EMAIL_ADDRESS, /*
       (SELECT STATE_NAME
          FROM STATE, ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '01'
               AND STATE_CODE = ADDRDTLS_STATE_CODE)
          "PRESENT STATE/DIVISION",
       (SELECT DISTRICT_NAME
          FROM DISTRICT, ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '01'
               AND ADDRDTLS_DISTRICT_CODE = DISTRICT_CODE)
          "PRESENT CITY/DISTRICT",
       (SELECT POSTAL_NAME
          FROM POSTAL, ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '01'
               AND ADDRDTLS_POSTAL_CODE = POSTAL_CODE)
          "PRESENT PS NAME",
       (SELECT LOCN_NAME
          FROM LOCATION, ADDRDTLS
         WHERE     LOCN_CODE = ADDRDTLS_LOCN_CODE
               AND ADDRDTLS_ADDR_TYPE = '01'
               AND ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM)
          " PRESENT POST/LOCATION",
       (SELECT CLIENTS_ADDR1
          FROM ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '01')
          "PRESENT VILL/HOUSE",
       (SELECT CLIENTS_ADDR2
          FROM ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '01')
          "PRESENT ROAD/SECTOR/BLOCK",
       (SELECT STATE_NAME
          FROM STATE, ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '02'
               AND STATE_CODE = ADDRDTLS_STATE_CODE)
          "PERMANENT STATE/DIVISION",
       (SELECT DISTRICT_NAME
          FROM DISTRICT, ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '02'
               AND ADDRDTLS_DISTRICT_CODE = DISTRICT_CODE)
          "PERMANENT CITY/DISTRICT",
       (SELECT POSTAL_NAME
          FROM POSTAL, ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '02'
               AND ADDRDTLS_POSTAL_CODE = POSTAL_CODE)
          "PERMANENT PS NAME",
       (SELECT LOCN_NAME
          FROM LOCATION, ADDRDTLS
         WHERE     LOCN_CODE = ADDRDTLS_LOCN_CODE
               AND ADDRDTLS_ADDR_TYPE = '02'
               AND ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM)
          "PERMANENT POST/LOCATION",
       (SELECT CLIENTS_ADDR1
          FROM ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '02')
          "PERMANENT VILL/HOUSE",
       (SELECT CLIENTS_ADDR2
          FROM ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '02')
          "PERMANENT ROAD/SECTOR/BLOCK" */
       CASE
          WHEN ADDRDTLS_ADDR_TYPE = '02' AND ADDRDTLS_CURR_ADDR = '1'
          THEN
             (SELECT STATE_NAME
                FROM STATE, ADDRDTLS
               WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                     AND ADDRDTLS_ADDR_TYPE = '02'
                     AND STATE_CODE = ADDRDTLS_STATE_CODE)
          ELSE
             (SELECT STATE_NAME
                FROM STATE, ADDRDTLS
               WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                     AND ADDRDTLS_ADDR_TYPE = '01'
                     AND STATE_CODE = ADDRDTLS_STATE_CODE)
       END
          "PRESENT STATE/DIVISION",
       CASE
          WHEN ADDRDTLS_ADDR_TYPE = '02' AND ADDRDTLS_CURR_ADDR = '1'
          THEN
             (SELECT DISTRICT_NAME
                FROM DISTRICT, ADDRDTLS
               WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                     AND ADDRDTLS_ADDR_TYPE = '02'
                     AND ADDRDTLS_DISTRICT_CODE = DISTRICT_CODE)
          ELSE
             (SELECT DISTRICT_NAME
                FROM DISTRICT, ADDRDTLS
               WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                     AND ADDRDTLS_ADDR_TYPE = '01'
                     AND ADDRDTLS_DISTRICT_CODE = DISTRICT_CODE)
       END
          "PRESENT CITY/DISTRICT",
       CASE
          WHEN ADDRDTLS_ADDR_TYPE = '02' AND ADDRDTLS_CURR_ADDR = '1'
          THEN
             (SELECT POSTAL_NAME
                FROM POSTAL, ADDRDTLS
               WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                     AND ADDRDTLS_ADDR_TYPE = '02'
                      AND ADDRDTLS_DISTRICT_CODE=POSTAL_DISTRICT_CODE
                     AND ADDRDTLS_POSTAL_CODE = POSTAL_CODE)
          ELSE
             (SELECT POSTAL_NAME
                FROM POSTAL, ADDRDTLS
               WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                     AND ADDRDTLS_ADDR_TYPE = '01'
                      AND ADDRDTLS_DISTRICT_CODE=POSTAL_DISTRICT_CODE
                     AND ADDRDTLS_POSTAL_CODE = POSTAL_CODE)
       END
          "PRESENT PS NAME",
       CASE
          WHEN ADDRDTLS_ADDR_TYPE = '02' AND ADDRDTLS_CURR_ADDR = '1'
          THEN
             (SELECT LOCN_NAME
                FROM LOCATION, ADDRDTLS
               WHERE     LOCN_CODE = ADDRDTLS_LOCN_CODE
                     AND ADDRDTLS_ADDR_TYPE = '02'
                     AND ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM)
          ELSE
             (SELECT LOCN_NAME
                FROM LOCATION, ADDRDTLS
               WHERE     LOCN_CODE = ADDRDTLS_LOCN_CODE
                     AND ADDRDTLS_ADDR_TYPE = '01'
                     AND ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM)
       END
          "PRESENT POST/LOCATION",
       CASE
          WHEN ADDRDTLS_ADDR_TYPE = '02' AND ADDRDTLS_CURR_ADDR = '1'
          THEN
             (SELECT CLIENTS_ADDR1
                FROM ADDRDTLS
               WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                     AND ADDRDTLS_ADDR_TYPE = '02')
          ELSE
             (SELECT CLIENTS_ADDR1
                FROM ADDRDTLS
               WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                     AND ADDRDTLS_ADDR_TYPE = '01')
       END
          "PRESENT VILL/HOUSE",
       CASE
          WHEN ADDRDTLS_ADDR_TYPE = '02' AND ADDRDTLS_CURR_ADDR = '1'
          THEN
             (SELECT CLIENTS_ADDR2
                FROM ADDRDTLS
               WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                     AND ADDRDTLS_ADDR_TYPE = '02')
          ELSE
             (SELECT CLIENTS_ADDR2
                FROM ADDRDTLS
               WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                     AND ADDRDTLS_ADDR_TYPE = '01')
       END
          "PRESENT ROAD/SECTOR/BLOCK",
       CASE
          WHEN ADDRDTLS_ADDR_TYPE = '01' AND ADDRDTLS_PERM_ADDR = '1'
          THEN
             (SELECT STATE_NAME
                FROM STATE, ADDRDTLS
               WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                     AND ADDRDTLS_ADDR_TYPE = '01'
                     AND STATE_CODE = ADDRDTLS_STATE_CODE)
          ELSE
             (SELECT STATE_NAME
                FROM STATE, ADDRDTLS
               WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                     AND ADDRDTLS_ADDR_TYPE = '02'
                     AND STATE_CODE = ADDRDTLS_STATE_CODE)
       END
          "PERMANENT STATE/DIVISION",
       CASE
          WHEN ADDRDTLS_ADDR_TYPE = '01' AND ADDRDTLS_PERM_ADDR = '1'
          THEN
             (SELECT DISTRICT_NAME
                FROM DISTRICT, ADDRDTLS
               WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                     AND ADDRDTLS_ADDR_TYPE = '01'
                     AND ADDRDTLS_DISTRICT_CODE = DISTRICT_CODE)
          ELSE
             (SELECT DISTRICT_NAME
                FROM DISTRICT, ADDRDTLS
               WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                     AND ADDRDTLS_ADDR_TYPE = '02'
                     AND ADDRDTLS_DISTRICT_CODE = DISTRICT_CODE)
       END
          "PERMANENT CITY/DISTRICT",
       CASE
          WHEN ADDRDTLS_ADDR_TYPE = '01' AND ADDRDTLS_PERM_ADDR = '1'
          THEN
             (SELECT POSTAL_NAME
                FROM POSTAL, ADDRDTLS
               WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                     AND ADDRDTLS_ADDR_TYPE = '01'
                     AND ADDRDTLS_DISTRICT_CODE=POSTAL_DISTRICT_CODE
                     AND ADDRDTLS_POSTAL_CODE = POSTAL_CODE)
          ELSE
             (SELECT POSTAL_NAME
                FROM POSTAL, ADDRDTLS
               WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                     AND ADDRDTLS_ADDR_TYPE = '02'
                     AND ADDRDTLS_DISTRICT_CODE=POSTAL_DISTRICT_CODE
                     AND ADDRDTLS_POSTAL_CODE = POSTAL_CODE)
       END
          "PERMANENT PS NAME",
       CASE
          WHEN ADDRDTLS_ADDR_TYPE = '01' AND ADDRDTLS_PERM_ADDR = '1'
          THEN
             (SELECT LOCN_NAME
                FROM LOCATION, ADDRDTLS
               WHERE     LOCN_CODE = ADDRDTLS_LOCN_CODE
                     AND ADDRDTLS_ADDR_TYPE = '01'
                     AND ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM)
          ELSE
             (SELECT LOCN_NAME
                FROM LOCATION, ADDRDTLS
               WHERE     LOCN_CODE = ADDRDTLS_LOCN_CODE
                     AND ADDRDTLS_ADDR_TYPE = '02'
                     AND ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM)
       END
          "PERMANENT POST/LOCATION",
       CASE
          WHEN ADDRDTLS_ADDR_TYPE = '01' AND ADDRDTLS_PERM_ADDR = '1'
          THEN
             (SELECT CLIENTS_ADDR1
                FROM ADDRDTLS
               WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                     AND ADDRDTLS_ADDR_TYPE = '01')
          ELSE
             (SELECT CLIENTS_ADDR1
                FROM ADDRDTLS
               WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                     AND ADDRDTLS_ADDR_TYPE = '02')
       END
          "PERMANENT VILL/HOUSE",
       CASE
          WHEN ADDRDTLS_ADDR_TYPE = '01' AND ADDRDTLS_PERM_ADDR = '1'
          THEN
             (SELECT CLIENTS_ADDR2
                FROM ADDRDTLS
               WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                     AND ADDRDTLS_ADDR_TYPE = '01')
          ELSE
             (SELECT CLIENTS_ADDR2
                FROM ADDRDTLS
               WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                     AND ADDRDTLS_ADDR_TYPE = '02')
       END
          "PERMANENT ROAD/SECTOR/BLOCK"
  FROM backuptable.CTR_REPORT,
       IACLINK,
       ACNTS A,
       ADDRDTLS,
       CLIENTS,
       MBRN
 WHERE     IACLINK_ENTITY_NUM = 1
       AND ACNTS_ENTITY_NUM = 1
       AND IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND CLIENTS_CODE = ACNTS_CLIENT_NUM
       AND IACLINK_ACTUAL_ACNUM = AC_NUM
       AND ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
       AND CLIENTS_TYPE_FLG = 'I'
       --AND AC_NUM = '4430501020450'
       AND IACLINK_BRN_CODE = MBRN_CODE
       AND MBRN_CODE in(1040  ,
16089 ,
16170 ,
16196 ,
44305 ,
44263 ,
16063 ,
16014 ,
16071 ,
16121 ,
44321 ,
16287 ,
1347  ,
16220 ,
44354 ,
26    ,
44164 ,
16337 ,
44123 ,
16204 ,
1156  ,
1123  


);

     -- AND ACNTS_CLIENT_NUM = 5923713;