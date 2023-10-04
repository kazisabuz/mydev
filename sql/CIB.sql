/* Formatted on 8/3/2022 12:40:41 PM (QP5 v5.252.13127.32867) */
--INSERT INTO CIB_BORROWER

SELECT PERIOD,
       BRCODE,
       SUB_TYPE,
       INS_TYPE,
       BCODE,
       SFI_CODE,
       ACCOUNT_NUMBER,
       TITLE,
       BNAME,
       FTITLE,
       FNAME,
       MTITLE,
       MNAME,
       STITLE,
       SNAME,
       SECTORTYPE,
       SECTORCODE,
       GENDER,
       DOB,
       BIRTH_PLACE,
       BCNTY_CODE,
       NID_NO,
       NID_NO_AIV,
       TIN,
       E_TIN,
       PER_ADDRESS PADDRESS,
       PER_ADDRDTLS_POSTAL_CODE PPOSTCODE,
       (SELECT POSTAL_NAME
          FROM POSTAL
         WHERE POSTAL_CODE = PER_ADDRDTLS_POSTAL_CODE)
          PPOSTNAME,
       PER_ADDRDTLS_DISTRICT_CODE PDISTCODE,
       (SELECT DISTINCT DISTRICT_NAME
          FROM district
         WHERE DISTRICT_CODE = PER_ADDRDTLS_DISTRICT_CODE)
          PDISTNAME,
       'BD' PCNTY_CODE,
       CURR_ADDRESS CADDRESS,
       CURR_ADDRDTLS_POSTAL_CODE CPOSTCODE,
       (SELECT POSTAL_NAME
          FROM POSTAL
         WHERE POSTAL_CODE = CURR_ADDRDTLS_POSTAL_CODE)
          CPOSTNAME,
       CURR_ADDRDTLS_DISTRICT_CODE CDISTCODE,
       (SELECT DISTINCT DISTRICT_NAME
          FROM district
         WHERE DISTRICT_CODE = CURR_ADDRDTLS_DISTRICT_CODE)
          CDISTNAME,
       'BD' CCNTY_CODE,
       COM_ADDRESS BADDRESS,
       COM_ADDRDTLS_POSTAL_CODE BPOSTCODE,
       (SELECT POSTAL_NAME
          FROM POSTAL
         WHERE POSTAL_CODE = COM_ADDRDTLS_POSTAL_CODE)
          BPOSNAME,
       COM_ADDRDTLS_DISTRICT_CODE BDISTCODE,
       (SELECT DISTINCT DISTRICT_NAME
          FROM district
         WHERE DISTRICT_CODE = COM_ADDRDTLS_DISTRICT_CODE)
          BDISTNAME,
       'BD' BSCNTY_CODE,
       NULL FADDRESS,
       NULL FPOSTCODE,
       NULL FPOSTNAME,
       NULL FDISTCODE,
       NULL FDISTNAME,
       NULL FCNTY_CODE,
       ID_TYPE,
       ID_NO,
       ID_DATE,
       ID_CNTY,
       PHONE_NO,
       REG_NO,
       REG_DATE,
       SISTER_CON,
       GROUP_NAME,
       CRG_SCORE,
       CREDIT_RATE,
       USER_ID,
       MACHINE_NAME,
       ENTRY_DATE,
       STAY_ORDER,
       BSCN,
       CHK,
       REMARKS,
       SUBJECT
  FROM (SELECT NULL PERIOD,
               SUBSTR (MBRN_BSR_CODE, 3, 4) BRCODE,
               CASE
                  WHEN CLIENTS_TYPE_FLG = 'I'
                  THEN
                     'P'
                  WHEN     CLIENTS_TYPE_FLG = 'C'
                       AND TRIM (CLIENTS_CONST_CODE) IN (8, 13)
                  THEN
                     'I'
                  WHEN     CLIENTS_TYPE_FLG = 'C'
                       AND TRIM (CLIENTS_CONST_CODE) IN (2,
                                                         3,
                                                         7,
                                                         9,
                                                         10,
                                                         11,
                                                         15)
                  THEN
                     'C'
                  ELSE
                     'P'
               END
                  SUB_TYPE,
               DECODE (CLIENTS_TYPE_FLG,  'C', '2',  'J', '1',  'I', '10')
                  INS_TYPE,
               NULL BCODE,
               NULL SFI_CODE,
               IACLINK_ACTUAL_ACNUM Account_Number,
               (SELECT TITLES_DESCN
                  FROM TITLES
                 WHERE TITLES_CODE = CLIENTS_TITLE_CODE)
                  TITLE,
               CLIENTS_NAME BNAME,
               NULL FTITLE,
               CASE
                  WHEN CLIENTS_TYPE_FLG = 'I'
                  THEN
                     (SELECT INDCLIENT_FATHER_NAME
                        FROM INDCLIENTS
                       WHERE INDCLIENT_CODE = CLIENTS_CODE)
               END
                  FNAME,
               NULL MTITLE,
               CASE
                  WHEN CLIENTS_TYPE_FLG = 'I'
                  THEN
                     (SELECT INDCLIENT_MOTHER_NAME
                        FROM INDCLIENTS
                       WHERE INDCLIENT_CODE = CLIENTS_CODE)
               END
                  MNAME,
               NULL STITLE,
               CASE
                  WHEN CLIENTS_TYPE_FLG = 'I'
                  THEN
                     (SELECT INDSPOUSE_SPOUSE_NAME
                        FROM INDCLIENTSPOUSE
                       WHERE INDSPOUSE_CLIENT_CODE = CLIENTS_CODE)
               END
                  SNAME,
               DECODE (FN_GET_SECTORTYPE (CLIENTS_SEGMENT_CODE),
                       '1', '1',
                       '9')
                  SECTORTYPE,
               CLIENTS_SEGMENT_CODE SECTORCODE,
               CASE
                  WHEN CLIENTS_TYPE_FLG = 'I'
                  THEN
                     (SELECT INDCLIENT_SEX
                        FROM INDCLIENTS
                       WHERE INDCLIENT_CODE = CLIENTS_CODE)
               END
                  GENDER,
               CASE
                  WHEN CLIENTS_TYPE_FLG = 'I'
                  THEN
                     (SELECT INDCLIENT_BIRTH_DATE
                        FROM INDCLIENTS
                       WHERE INDCLIENT_CODE = CLIENTS_CODE)
               END
                  DOB,
               CASE
                  WHEN CLIENTS_TYPE_FLG = 'I'
                  THEN
                     (SELECT LOCN_NAME
                        FROM INDCLIENTS, LOCATION
                       WHERE     INDCLIENT_CODE = CLIENTS_CODE
                             AND LOCN_CODE = INDCLIENT_BIRTH_PLACE_CODE)
               END
                  BIRTH_PLACE,
               CASE
                  WHEN CLIENTS_TYPE_FLG = 'I'
                  THEN
                     (SELECT LOCN_CNTRY_CODE
                        FROM INDCLIENTS, LOCATION
                       WHERE     INDCLIENT_CODE = CLIENTS_CODE
                             AND LOCN_CODE = INDCLIENT_BIRTH_PLACE_CODE)
               END
                  BCNTY_CODE,
               GET_NID_NUMBER (CLIENTS_CODE, 'NID') NID_NO,
               DECODE (GET_NID_NUMBER (CLIENTS_CODE, 'NID'), NULL, '0', '1')
                  NID_NO_AIV,
               GET_NID_NUMBER (CLIENTS_CODE, 'TIN') TIN,
               NULL E_TIN,
               'BD' FCNTY_CODE,
               NULL ID_TYPE,
               NULL ID_NO,
               NULL ID_DATE,
               NULL ID_CNTY,
               CASE
                  WHEN CLIENTS_TYPE_FLG = 'I'
                  THEN
                     (SELECT INDCLIENT_TEL_GSM
                        FROM INDCLIENTS
                       WHERE INDCLIENT_CODE = CLIENTS_CODE)
               END
                  PHONE_NO,
               NULL REG_NO,
               NULL REG_DATE,
               NULL SISTER_CON,
               NULL GROUP_NAME,
               NULL CRG_SCORE,
               NULL CREDIT_RATE,
               NULL USER_ID,
               NULL MACHINE_NAME,
               NULL ENTRY_DATE,
               NULL STAY_ORDER,
               NULL BSCN,
               NULL CHK,
               NULL REMARKS,
               NULL SUBJECT,
               CLIENTS_ADDR_INV_NUM
          FROM ACNTS,
               IACLINK,
               PRODUCTS,
               MBRN,
               CLIENTS
         WHERE     IACLINK_ENTITY_NUM = 1
               AND IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACNTS_ENTITY_NUM = 1
               AND ACNTS_BRN_CODE = 17160
               AND PRODUCT_CODE = ACNTS_PROD_CODE
               AND PRODUCT_FOR_LOANS = 1
               AND MBRN_ENTITY_NUM = 1
               AND MBRN_CODE = ACNTS_BRN_CODE
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE) AA,
       (SELECT ADDRDTLS_INV_NUM,
               ADDRDTLS_ADDR_SL,
               ADDRDTLS_ADDR_TYPE,
               CASE
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_CURRADDR_TYPE
                       AND ADDRDTLS_CURR_ADDR = '1'
                  THEN
                     TRIM (
                           ADDRDTLS_ADDR1
                        || ADDRDTLS_ADDR2
                        || ADDRDTLS_ADDR3
                        || ADDRDTLS_ADDR4
                        || ADDRDTLS_ADDR5)
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_PERMADDR_TYPE
                       AND ADDRDTLS_CURR_ADDR = '1'
                  THEN
                     TRIM (
                        (   ADDRDTLS_ADDR1
                         || ADDRDTLS_ADDR2
                         || ADDRDTLS_ADDR3
                         || ADDRDTLS_ADDR4
                         || ADDRDTLS_ADDR5))
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_COMMUNICATION_ADDR
                       AND ADDRDTLS_CURR_ADDR = '1'
                  THEN
                     TRIM (
                        (   ADDRDTLS_ADDR1
                         || ADDRDTLS_ADDR2
                         || ADDRDTLS_ADDR3
                         || ADDRDTLS_ADDR4
                         || ADDRDTLS_ADDR5))
               END
                  CURR_ADDRESS,
               CASE
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_CURRADDR_TYPE
                       AND ADDRDTLS_CURR_ADDR = '1'
                  THEN
                     TRIM (ADDRDTLS_POSTAL_CODE)
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_PERMADDR_TYPE
                       AND ADDRDTLS_CURR_ADDR = '1'
                  THEN
                     TRIM (ADDRDTLS_POSTAL_CODE)
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_COMMUNICATION_ADDR
                       AND ADDRDTLS_CURR_ADDR = '1'
                  THEN
                     TRIM (ADDRDTLS_POSTAL_CODE)
               END
                  CURR_ADDRDTLS_POSTAL_CODE,
               CASE
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_CURRADDR_TYPE
                       AND ADDRDTLS_CURR_ADDR = '1'
                  THEN
                     TRIM (ADDRDTLS_DISTRICT_CODE)
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_PERMADDR_TYPE
                       AND ADDRDTLS_CURR_ADDR = '1'
                  THEN
                     TRIM (ADDRDTLS_DISTRICT_CODE)
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_COMMUNICATION_ADDR
                       AND ADDRDTLS_CURR_ADDR = '1'
                  THEN
                     TRIM (ADDRDTLS_DISTRICT_CODE)
               END
                  CURR_ADDRDTLS_DISTRICT_CODE,
               CASE
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_CURRADDR_TYPE
                       AND ADDRDTLS_PERM_ADDR = '1'
                  THEN
                     TRIM (
                           ADDRDTLS_ADDR1
                        || ADDRDTLS_ADDR2
                        || ADDRDTLS_ADDR3
                        || ADDRDTLS_ADDR4
                        || ADDRDTLS_ADDR5)
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_PERMADDR_TYPE
                       AND ADDRDTLS_PERM_ADDR = '1'
                  THEN
                     TRIM (
                        (   ADDRDTLS_ADDR1
                         || ADDRDTLS_ADDR2
                         || ADDRDTLS_ADDR3
                         || ADDRDTLS_ADDR4
                         || ADDRDTLS_ADDR5))
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_COMMUNICATION_ADDR
                       AND ADDRDTLS_PERM_ADDR = '1'
                  THEN
                     TRIM (
                        (   ADDRDTLS_ADDR1
                         || ADDRDTLS_ADDR2
                         || ADDRDTLS_ADDR3
                         || ADDRDTLS_ADDR4
                         || ADDRDTLS_ADDR5))
               END
                  PER_ADDRESS,
               CASE
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_CURRADDR_TYPE
                       AND ADDRDTLS_PERM_ADDR = '1'
                  THEN
                     TRIM (ADDRDTLS_POSTAL_CODE)
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_PERMADDR_TYPE
                       AND ADDRDTLS_PERM_ADDR = '1'
                  THEN
                     TRIM (ADDRDTLS_POSTAL_CODE)
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_COMMUNICATION_ADDR
                       AND ADDRDTLS_PERM_ADDR = '1'
                  THEN
                     TRIM (ADDRDTLS_POSTAL_CODE)
               END
                  PER_ADDRDTLS_POSTAL_CODE,
               CASE
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_CURRADDR_TYPE
                       AND ADDRDTLS_PERM_ADDR = '1'
                  THEN
                     TRIM (ADDRDTLS_DISTRICT_CODE)
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_PERMADDR_TYPE
                       AND ADDRDTLS_CURR_ADDR = '1'
                  THEN
                     TRIM (ADDRDTLS_DISTRICT_CODE)
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_COMMUNICATION_ADDR
                       AND ADDRDTLS_CURR_ADDR = '1'
                  THEN
                     TRIM (ADDRDTLS_DISTRICT_CODE)
               END
                  PER_ADDRDTLS_DISTRICT_CODE,
               CASE
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_CURRADDR_TYPE
                       AND ADDRDTLS_COMM_ADDR = '1'
                  THEN
                     TRIM (
                           ADDRDTLS_ADDR1
                        || ADDRDTLS_ADDR2
                        || ADDRDTLS_ADDR3
                        || ADDRDTLS_ADDR4
                        || ADDRDTLS_ADDR5)
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_PERMADDR_TYPE
                       AND ADDRDTLS_COMM_ADDR = '1'
                  THEN
                     TRIM (
                        (   ADDRDTLS_ADDR1
                         || ADDRDTLS_ADDR2
                         || ADDRDTLS_ADDR3
                         || ADDRDTLS_ADDR4
                         || ADDRDTLS_ADDR5))
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_COMMUNICATION_ADDR
                       AND ADDRDTLS_COMM_ADDR = '1'
                  THEN
                     TRIM (
                        (   ADDRDTLS_ADDR1
                         || ADDRDTLS_ADDR2
                         || ADDRDTLS_ADDR3
                         || ADDRDTLS_ADDR4
                         || ADDRDTLS_ADDR5))
               END
                  COM_ADDRESS,
               CASE
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_CURRADDR_TYPE
                       AND ADDRDTLS_COMM_ADDR = '1'
                  THEN
                     TRIM (ADDRDTLS_POSTAL_CODE)
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_PERMADDR_TYPE
                       AND ADDRDTLS_COMM_ADDR = '1'
                  THEN
                     TRIM (ADDRDTLS_POSTAL_CODE)
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_COMMUNICATION_ADDR
                       AND ADDRDTLS_COMM_ADDR = '1'
                  THEN
                     TRIM (ADDRDTLS_POSTAL_CODE)
               END
                  COM_ADDRDTLS_POSTAL_CODE,
               CASE
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_CURRADDR_TYPE
                       AND ADDRDTLS_COMM_ADDR = '1'
                  THEN
                     TRIM (ADDRDTLS_DISTRICT_CODE)
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_PERMADDR_TYPE
                       AND ADDRDTLS_CURR_ADDR = '1'
                  THEN
                     TRIM (ADDRDTLS_DISTRICT_CODE)
                  WHEN     ADDRDTLS_ADDR_TYPE = :V_COMMUNICATION_ADDR
                       AND ADDRDTLS_CURR_ADDR = '1'
                  THEN
                     TRIM (ADDRDTLS_DISTRICT_CODE)
               END
                  COM_ADDRDTLS_DISTRICT_CODE
          FROM (SELECT ROW_NUMBER ()
                       OVER (
                          PARTITION BY ADDRDTLS_INV_NUM, ADDRDTLS_ADDR_TYPE
                          ORDER BY
                             ADDRDTLS_INV_NUM ASC, ADDRDTLS_ADDR_SL DESC)
                          SL,
                       ADDRDTLS_INV_NUM,
                       ADDRDTLS_ADDR_SL,
                       ADDRDTLS_ADDR_TYPE,
                       ADDRDTLS_CMP_TPARTY_NAME,
                       ADDRDTLS_ADDR1,
                       ADDRDTLS_ADDR2,
                       ADDRDTLS_ADDR3,
                       ADDRDTLS_ADDR4,
                       ADDRDTLS_ADDR5,
                       ADDRDTLS_STATE_CODE,
                       ADDRDTLS_DISTRICT_CODE,
                       ADDRDTLS_POSTAL_CODE,
                       ADDRDTLS_POSTOFFC_NAME,
                       ADDRDTLS_CURR_ADDR,
                       ADDRDTLS_PERM_ADDR,
                       ADDRDTLS_COMM_ADDR
                  FROM ADDRDTLS)
         WHERE SL = 1) T
 WHERE T.ADDRDTLS_INV_NUM = AA.CLIENTS_ADDR_INV_NUM