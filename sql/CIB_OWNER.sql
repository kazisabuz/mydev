/* Formatted on 8/4/2022 4:53:28 PM (QP5 v5.252.13127.32867) */
SELECT MBRN_BSR_CODE BB_BRCODE,
       MBRN_NAME BR_NAME,
       PRODUCT_CODE,
       PRODUCT_NAME,
       facno (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NUMBER,
       (SELECT DECODE (CLIENTS_TYPE_FLG,  'C', 'C',  'J', 'I',  'I', 'P')
          FROM clients
         WHERE CLIENTS_CODE = CONNP_CLIENT_NUM)
          SUB_TYPE,
       (SELECT DECODE (CLIENTS_TYPE_FLG,  'C', '2',  'J', '1',  'I', '10')
          FROM clients
         WHERE CLIENTS_CODE = CONNP_CLIENT_NUM)
          INS_TYPE,
       NULL SFI_CODE,
       NULL CFI_CODE,
       (SELECT TITLES_DESCN
          FROM TITLES, clients
         WHERE     TITLES_CODE = CLIENTS_TITLE_CODE
               AND CLIENTS_CODE = CONNP_CLIENT_NUM)
          OWNER_TITLE,
       (SELECT CLIENTS_NAME
          FROM clients
         WHERE CLIENTS_CODE = CONNP_CLIENT_NUM)
          OWNER_NAME,
       (SELECT CASE
                  WHEN INDCLIENT_SEX = 'M' THEN 'MALE'
                  WHEN INDCLIENT_SEX = 'F' THEN 'FEMALE'
               END
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CONNP_CLIENT_NUM)
          OWNER_GENDER,
       (SELECT CLIENTS_PAN_GIR_NUM
          FROM clients
         WHERE CLIENTS_CODE = CONNP_CLIENT_NUM)
          ETIN,
       NVL (GET_MOBILE_NUM (CONNP_CLIENT_NUM), CONNP_GSM_NUM) PHONE_NO,
       NVL ( (SELECT TO_CHAR (INDCLIENT_BIRTH_DATE, 'YYYY-MM-DD')
                FROM INDCLIENTS
               WHERE INDCLIENT_CODE = CONNP_CLIENT_NUM),
            TO_CHAR (CONNP_DATE_OF_BIRTH, 'YYYY-MM-DD'))
          DOB,
       GET_NID_NUMBER (CONNP_CLIENT_NUM, 'NID') NID,
       NULL HAS_NID,
       NULL FNAME_TITLE,
       NVL ( (SELECT TRIM (INDCLIENT_FATHER_NAME)
                FROM INDCLIENTS
               WHERE INDCLIENT_CODE = CONNP_CLIENT_NUM),
            CONNP_NOMINEE_FATHER_NAME)
          FNAME_BODY,
       NULL MNAME_TITLE,
       NVL ( (SELECT TRIM (INDCLIENT_MOTHER_NAME)
                FROM INDCLIENTS
               WHERE INDCLIENT_CODE = CONNP_CLIENT_NUM),
            CONNP_NOMINEE_MOTHER_NAME)
          MNAME_BODY,
       NULL SNAME_TITLE,
       NVL ( (SELECT DISTINCT TRIM (INDSPOUSE_SPOUSE_NAME)
                FROM INDCLIENTSPOUSE
               WHERE INDSPOUSE_CLIENT_CODE = CONNP_CLIENT_NUM),
            CONNP_NOMINEE_SPOUSE_NAME)
          SNAME_BODY,
       (SELECT INDCLIENT_BIRTH_PLACE_NAME
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CONNP_CLIENT_NUM)
          DOB_DISTRICT,
       C_STATE_DIVISION,
       C_CITY_DISTRICT,
       C_POSTAL_CODE,
       C_POST_NAME,
       C_LOC_CODE,
       C_VILL_HOUSE,
       C_ROAD_SECTORBLOCK,
       P_STATE_DIVISION,
       P_CITY_DISTRICT,
       P_POSTAL_CODE,
       P_POST_NAME,
       P_LOC_CODE,
       P_VILL_HOUSE,
       P_ROAD_SECTOR_BLOCK,
       B_STATE_DIVISION,
       B_CITY_DISTRICT,
       B_POSTAL_CODE,
       B_POST_NAME,
       B_LOC_CODE,
       B_VILL_HOUSE,
       B_ROAD_SECTOR_BLOCK,
       CURRENT_ADDR,
       PERMANANT_ADDR,
       BUSSINESS_ADDR,
       CLIENTS_ADDR_INV_NUM
  FROM (SELECT PRODUCT_CODE,
               PRODUCT_NAME,
               CLIENTS_ADDR_INV_NUM,
               ACNTS_INTERNAL_ACNUM,
               ACNTS_CONNP_INV_NUM,
               MBRN_NAME,
               MBRN_BSR_CODE,
               CONNP_NOMINEE_SPOUSE_NAME,
               CONNP_NOMINEE_MOTHER_NAME,
               CONNP_NOMINEE_FATHER_NAME,
               CONNP_CLIENT_NUM,
               CONNP_DATE_OF_BIRTH,
               CONNP_GSM_NUM,
               (SELECT DISTINCT STATE_NAME
                  FROM STATE
                 WHERE STATE_CODE = C_STATE_CODE)
                  C_STATE_DIVISION,
               (SELECT DISTINCT DISTRICT_NAME
                  FROM DISTRICT
                 WHERE DISTRICT_CODE = C_DISTRICT_CODE)
                  C_CITY_DISTRICT,
               C_POSTAL_CODE,
               (SELECT POSTAL_NAME
                  FROM POSTAL
                 WHERE POSTAL_CODE = C_POSTAL_CODE)
                  C_POST_NAME,
               (SELECT DISTINCT LOCN_NAME
                  FROM LOCATION
                 WHERE LOCN_CODE = C_LOC_CODE)
                  C_LOC_CODE,
               C_VILL_HOUSE,
               C_ROAD_SECTORBLOCK,
               (SELECT DISTINCT STATE_NAME
                  FROM STATE
                 WHERE STATE_CODE = P_STATE_CODE)
                  P_STATE_DIVISION,
               (SELECT DISTINCT DISTRICT_NAME
                  FROM DISTRICT
                 WHERE DISTRICT_CODE = P_DISTRICT_CODE)
                  P_CITY_DISTRICT,
               P_POSTAL_CODE,
               (SELECT POSTAL_NAME
                  FROM POSTAL
                 WHERE POSTAL_CODE = P_POSTAL_CODE)
                  P_POST_NAME,
               (SELECT DISTINCT LOCN_NAME
                  FROM LOCATION
                 WHERE LOCN_CODE = P_LOC_CODE)
                  P_LOC_CODE,
               P_VILL_HOUSE,
               P_ROAD_SECTOR_BLOCK,
               (SELECT DISTINCT STATE_NAME
                  FROM STATE
                 WHERE STATE_CODE = B_STATE_CODE)
                  B_STATE_DIVISION,
               (SELECT DISTINCT DISTRICT_NAME
                  FROM DISTRICT
                 WHERE DISTRICT_CODE = B_DISTRICT_CODE)
                  B_CITY_DISTRICT,
               B_POSTAL_CODE,
               (SELECT POSTAL_NAME
                  FROM POSTAL
                 WHERE POSTAL_CODE = B_POSTAL_CODE)
                  B_POST_NAME,
               (SELECT DISTINCT LOCN_NAME
                  FROM LOCATION
                 WHERE LOCN_CODE = B_LOC_CODE)
                  B_LOC_CODE,
               B_VILL_HOUSE,
               B_ROAD_SECTOR_BLOCK,
               CURRENT_ADDR,
               PERMANANT_ADDR,
               BUSSINESS_ADDR
          FROM (SELECT AA.CLIENTS_ADDR_INV_NUM,
                       AA.ACNTS_CONNP_INV_NUM,
                       AA.ACNTS_INTERNAL_ACNUM,
                       AA.MBRN_NAME,
                       AA.MBRN_BSR_CODE,
                       B.CONNP_NOMINEE_SPOUSE_NAME,
                       b.CONNP_NOMINEE_MOTHER_NAME,
                       b.CONNP_NOMINEE_FATHER_NAME,
                       b.CONNP_CLIENT_NUM,
                       b.CONNP_DATE_OF_BIRTH,
                       b.CONNP_GSM_NUM,
                       PRODUCT_CODE,
                       PRODUCT_NAME,
                       CASE
                          WHEN ADDRDTLS_ADDR_TYPE = '01'
                          THEN
                             ADDRDTLS_STATE_CODE
                          ELSE
                             NULL
                       END
                          C_STATE_CODE,
                       CASE
                          WHEN ADDRDTLS_ADDR_TYPE = '01'
                          THEN
                             ADDRDTLS_DISTRICT_CODE
                          ELSE
                             NULL
                       END
                          C_DISTRICT_CODE,
                       CASE
                          WHEN ADDRDTLS_ADDR_TYPE = '01'
                          THEN
                             ADDRDTLS_POSTAL_CODE
                          ELSE
                             NULL
                       END
                          C_POSTAL_CODE,
                       CASE
                          WHEN ADDRDTLS_ADDR_TYPE = '01'
                          THEN
                             ADDRDTLS_POSTOFFC_NAME
                          ELSE
                             NULL
                       END
                          C_POSTOFFC_NAME,
                       CASE
                          WHEN ADDRDTLS_ADDR_TYPE = '02'
                          THEN
                             ADDRDTLS_STATE_CODE
                          ELSE
                             NULL
                       END
                          P_STATE_CODE,
                       CASE
                          WHEN ADDRDTLS_ADDR_TYPE = '02'
                          THEN
                             ADDRDTLS_DISTRICT_CODE
                          ELSE
                             NULL
                       END
                          P_DISTRICT_CODE,
                       CASE
                          WHEN ADDRDTLS_ADDR_TYPE = '02'
                          THEN
                             ADDRDTLS_POSTAL_CODE
                          ELSE
                             NULL
                       END
                          P_POSTAL_CODE,
                       CASE
                          WHEN ADDRDTLS_ADDR_TYPE = '02'
                          THEN
                             ADDRDTLS_POSTOFFC_NAME
                          ELSE
                             NULL
                       END
                          P_POSTOFFC_NAME,
                       CASE
                          WHEN ADDRDTLS_ADDR_TYPE = '04'
                          THEN
                             ADDRDTLS_STATE_CODE
                          ELSE
                             NULL
                       END
                          B_STATE_CODE,
                       CASE
                          WHEN ADDRDTLS_ADDR_TYPE = '04'
                          THEN
                             ADDRDTLS_DISTRICT_CODE
                          ELSE
                             NULL
                       END
                          B_DISTRICT_CODE,
                       CASE
                          WHEN ADDRDTLS_ADDR_TYPE = '04'
                          THEN
                             ADDRDTLS_POSTAL_CODE
                          ELSE
                             NULL
                       END
                          B_POSTAL_CODE,
                       CASE
                          WHEN ADDRDTLS_ADDR_TYPE = '04'
                          THEN
                             ADDRDTLS_POSTOFFC_NAME
                          ELSE
                             NULL
                       END
                          B_POSTOFFC_NAME,
                       CASE
                          WHEN ADDRDTLS_ADDR_TYPE = '01' THEN ADDRDTLS_ADDR1
                          ELSE NULL
                       END
                          C_VILL_HOUSE,
                       CASE
                          WHEN ADDRDTLS_ADDR_TYPE = '01'
                          THEN
                             ADDRDTLS_LOCN_CODE
                          ELSE
                             NULL
                       END
                          C_LOC_CODE,
                       CASE
                          WHEN ADDRDTLS_ADDR_TYPE = '02'
                          THEN
                             ADDRDTLS_LOCN_CODE
                          ELSE
                             NULL
                       END
                          P_LOC_CODE,
                       CASE
                          WHEN ADDRDTLS_ADDR_TYPE = '04'
                          THEN
                             ADDRDTLS_LOCN_CODE
                          ELSE
                             NULL
                       END
                          B_LOC_CODE,
                       CASE
                          WHEN ADDRDTLS_ADDR_TYPE = '01' THEN ADDRDTLS_ADDR2
                          ELSE NULL
                       END
                          C_ROAD_SECTORBLOCK,
                       CASE
                          WHEN ADDRDTLS_ADDR_TYPE = '02' THEN ADDRDTLS_ADDR1
                          ELSE NULL
                       END
                          P_VILL_HOUSE,
                       CASE
                          WHEN ADDRDTLS_ADDR_TYPE = '02' THEN ADDRDTLS_ADDR2
                          ELSE NULL
                       END
                          P_ROAD_SECTOR_BLOCK,
                       CASE
                          WHEN ADDRDTLS_ADDR_TYPE = '04' THEN ADDRDTLS_ADDR1
                          ELSE NULL
                       END
                          B_VILL_HOUSE,
                       CASE
                          WHEN ADDRDTLS_ADDR_TYPE = '04' THEN ADDRDTLS_ADDR2
                          ELSE NULL
                       END
                          B_ROAD_SECTOR_BLOCK,
                       ADDRDTLS_CURR_ADDR CURRENT_ADDR,
                       ADDRDTLS_PERM_ADDR PERMANANT_ADDR,
                       ADDRDTLS_COMM_ADDR BUSSINESS_ADDR
                  FROM (SELECT DISTINCT C.CLIENTS_ADDR_INV_NUM,
                                        A.ACNTS_CONNP_INV_NUM,
                                        A.ACNTS_INTERNAL_ACNUM,
                                        MBRN_NAME,
                                        MBRN_BSR_CODE,
                                        PRODUCT_CODE,
                                        PRODUCT_NAME
                          FROM ACNTS A,
                               clients C,
                               products,
                               MBRN
                         WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                               AND PRODUCT_FOR_LOANS = 1
                               AND CLIENTS_CODE = ACNTS_CLIENT_NUM
                               AND CLIENTS_TYPE_FLG = 'C'
                               AND TRIM (CLIENTS_CONST_CODE) IN (8, 13)
                               AND ACNTS_ENTITY_NUM = 1
                               AND ACNTS_BRN_CODE = MBRN_CODE
                               AND ACNTS_BRN_CODE = :2
                               AND ACNTS_CLOSURE_DATE IS NULL
                               AND ACNTS_OPENING_DATE <= '31-JAN-2022'
                               AND (   ACNTS_CLOSURE_DATE IS NULL
                                    OR ACNTS_CLOSURE_DATE > '31-JAN-2022'))
                       AA
                       LEFT JOIN CONNPINFO B
                          ON (    AA.ACNTS_CONNP_INV_NUM = B.CONNP_INV_NUM
                              AND B.CONNP_CONN_ROLE = '8')
                       LEFT JOIN addrdtls ad
                          ON (AA.CLIENTS_ADDR_INV_NUM = ad.ADDRDTLS_INV_NUM))
               BB);

----------------------

SELECT DISTINCT
       MBRN_BSR_CODE BB_BRCODE,
       MBRN_NAME BR_NAME,
       facno (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NUMBER,
       DECODE (CLIENTS_TYPE_FLG,  'C', 'C',  'J', 'I',  'I', 'P') SUB_TYPE,
       DECODE (CLIENTS_TYPE_FLG,  'C', '2',  'J', '1',  'I', '10') INS_TYPE,
       NULL SFI_CODE,
       NULL CFI_CODE,
       (SELECT TITLES_DESCN
          FROM TITLES
         WHERE TITLES_CODE = CLIENTS_TITLE_CODE)
          OWNER_TITLE,
       (SELECT CASE
                  WHEN INDCLIENT_SEX = 'M' THEN 'MALE'
                  WHEN INDCLIENT_SEX = 'F' THEN 'FEMALE'
               END
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
          OWNER_GENDER,
       CLIENTS_PAN_GIR_NUM ETIN,
       NVL (GET_MOBILE_NUM (CLIENTS_CODE), CONNP_GSM_NUM) PHONE_NO,
       NVL ( (SELECT TO_CHAR (INDCLIENT_BIRTH_DATE, 'YYYY-MM-DD')
                FROM INDCLIENTS
               WHERE INDCLIENT_CODE = CLIENTS_CODE),
            TO_CHAR (CONNP_DATE_OF_BIRTH, 'YYYY-MM-DD'))
          DOB,
       GET_NID_NUMBER (CLIENTS_CODE, 'NID') NID,
       NULL HAS_NID,
       NULL FNAME_TITLE,
       NVL ( (SELECT TRIM (INDCLIENT_FATHER_NAME)
                FROM INDCLIENTS
               WHERE INDCLIENT_CODE = CLIENTS_CODE),
            CONNP_NOMINEE_FATHER_NAME)
          FNAME_BODY,
       NULL MNAME_TITLE,
       NVL ( (SELECT TRIM (INDCLIENT_MOTHER_NAME)
                FROM INDCLIENTS
               WHERE INDCLIENT_CODE = CLIENTS_CODE),
            CONNP_NOMINEE_MOTHER_NAME)
          MNAME_BODY,
       NULL SNAME_TITLE,
       NVL ( (SELECT TRIM (INDSPOUSE_SPOUSE_NAME)
                FROM INDCLIENTSPOUSE
               WHERE INDSPOUSE_CLIENT_CODE = CLIENTS_CODE),
            CONNP_NOMINEE_SPOUSE_NAME)
          SNAME_BODY,
       (SELECT INDCLIENT_BIRTH_PLACE_NAME
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
          DOB_DISTRICT,
       NVL (TRIM (CONNP_CLIENT_CNTRY), 'BD') DOB_COUNTRY,
       (SELECT DISTINCT STATE_NAME
          FROM STATE, ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '01'
               AND STATE_CODE = ADDRDTLS_STATE_CODE)
          "C STATE/DIVISION",
       (SELECT DISTINCT DISTRICT_NAME
          FROM DISTRICT, ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '01'
               AND ADDRDTLS_DISTRICT_CODE = DISTRICT_CODE)
          "C CITY/DISTRICT",
       (SELECT DISTINCT ADDRDTLS_POSTAL_CODE
          FROM ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '01')
          "C POST CODE",
       (SELECT POSTAL_NAME
          FROM POSTAL, ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '01'
               AND ADDRDTLS_POSTAL_CODE = POSTAL_CODE)
          "C POST NAME",
       (SELECT DISTINCT LOCN_NAME
          FROM LOCATION, ADDRDTLS
         WHERE     LOCN_CODE = ADDRDTLS_LOCN_CODE
               AND ADDRDTLS_ADDR_TYPE = '01'
               AND ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM)
          "C POST/LOCATION",
       (SELECT DISTINCT ADDRDTLS_ADDR1
          FROM ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '01')
          "C BUSINESS VILL/HOUSE",
       (SELECT ( (TRIM (ADDRDTLS_ADDR2)))
          FROM ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '01')
          "C BUSINESS ROAD/SECTOR/BLOCK",
       (SELECT DISTINCT STATE_NAME
          FROM STATE, ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '02'
               AND STATE_CODE = ADDRDTLS_STATE_CODE)
          "P STATE/DIVISION",
       (SELECT DISTINCT DISTRICT_NAME
          FROM DISTRICT, ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '02'
               AND ADDRDTLS_DISTRICT_CODE = DISTRICT_CODE)
          "P CITY/DISTRICT",
       (SELECT DISTINCT ADDRDTLS_POSTAL_CODE
          FROM ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '02')
          "P POST CODE",
       (SELECT DISTINCT POSTAL_NAME
          FROM POSTAL, ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '02'
               AND ADDRDTLS_POSTAL_CODE = POSTAL_CODE)
          "P POST NAME",
       (SELECT DISTINCT LOCN_NAME
          FROM LOCATION, ADDRDTLS
         WHERE     LOCN_CODE = ADDRDTLS_LOCN_CODE
               AND ADDRDTLS_ADDR_TYPE = '02'
               AND ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM)
          "P POST/LOCATION",
       (SELECT DISTINCT ADDRDTLS_ADDR1
          FROM ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '02')
          "P VILL/HOUSE",
       (SELECT DISTINCT ADDRDTLS_ADDR1
          FROM ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '02')
          "P ROAD/SECTOR/BLOCK",
       (SELECT DISTINCT STATE_NAME
          FROM STATE, ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '04'
               AND STATE_CODE = ADDRDTLS_STATE_CODE)
          "B STATE/DIVISION",
       (SELECT DISTINCT DISTRICT_NAME
          FROM DISTRICT, ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '04'
               AND ADDRDTLS_DISTRICT_CODE = DISTRICT_CODE)
          "B CITY/DISTRICT",
       (SELECT DISTINCT ADDRDTLS_POSTAL_CODE
          FROM ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '04')
          "B POST CODE",
       (SELECT DISTINCT POSTAL_NAME
          FROM POSTAL, ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '04'
               AND ADDRDTLS_POSTAL_CODE = POSTAL_CODE)
          "B POST NAME",
       (SELECT DISTINCT LOCN_NAME
          FROM LOCATION, ADDRDTLS
         WHERE     LOCN_CODE = ADDRDTLS_LOCN_CODE
               AND ADDRDTLS_ADDR_TYPE = '04'
               AND ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM)
          "B POST/LOCATION",
       (SELECT DISTINCT ADDRDTLS_ADDR1
          FROM ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '04')
          "B VILL/HOUSE",
       (SELECT DISTINCT ADDRDTLS_ADDR2
          FROM ADDRDTLS
         WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND ADDRDTLS_ADDR_TYPE = '04')
          "B ROAD/SECTOR/BLOCK",
       ACNTS_BRN_CODE
  FROM CONNPINFO,
       ACNTS A,
       products,
       CLIENTS,
       MBRN
 WHERE     ACNTS_ENTITY_NUM = 1
       AND CLIENTS_CODE = ACNTS_CLIENT_NUM
       AND CONNP_CLIENT_NUM = ACNTS_CLIENT_NUM
       AND CLIENTS_CODE = CONNP_CLIENT_NUM
       AND ACNTS_CONNP_INV_NUM = CONNP_INV_NUM
       AND CONNP_CONN_ROLE = '8'
       AND CONNP_CLIENT_NUM <> 0
       AND ACNTS_BRN_CODE = MBRN_CODE
       AND ACNTS_BRN_CODE = :1
       AND PRODUCT_CODE = ACNTS_PROD_CODE
       AND PRODUCT_FOR_LOANS = 1
       AND ACNTS_OPENING_DATE <= :2
       AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE > :3)