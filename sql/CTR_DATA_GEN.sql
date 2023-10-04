/* Formatted on 7/17/2019 6:34:45 PM (QP5 v5.227.12220.39754) */
-----------------------INDCLIENTS---------------------------

  SELECT BRANCH_HO,
         HO_NAME,
         BRANCH_GMO,
         GMO_NAME,
         BRANCH_PO,
         PO_NAME,
         BRANCH_NAME,
         ACNTS_BRN_CODE,
         ACCOUNT_NUMBER,
         ACOUNT_NAME,
         ACNTS_OPENING_DATE,
         ACNTS_AC_TYPE,
         ACNTS_CLOSURE_DATE,
         ACCOUNT_BAL,
         TRAN_AMOUNT,
         INDCLIENT_FIRST_NAME,
         INDCLIENT_LAST_NAME,
         INDCLIENT_MIDDLE_NAME,
         INDCLIENT_FATHER_NAME,
         SPOUSE_NAME,
         MOTHER_NAME,
         BIRTH_DATE,
         GENDER,
         OCCUPATION,
         NID,
         BIRTH_REG,
         PASSPORT,
         TIN,
         MOBILE_NUM,
         LAND_PHONE,
         EMAIL,
         STATE_DIVISION,
         CITY_DISTRICT,
         POLICE_STATION,
         ROAD_SECTOR_BLOCK_VILL_HOUSE,
         INDCLIENT_CODE,
         TRAN_DATE_OF_TRAN,
         SUM (TRAN_AMOUNT)
    FROM (  SELECT BRANCH_HO,
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
                      BRANCH_NAME,
                   TT.*
              FROM (SELECT ACNTS_BRN_CODE,
                           FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NUMBER,
                           ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACOUNT_NAME,
                           ACNTS_OPENING_DATE,
                           ACNTS_AC_TYPE,
                           INDCLIENT_CODE,
                           ACNTS_CLOSURE_DATE,
                           /*    (NVL (FN_GET_ASON_ACBAL (1,
                                                        ACNTS_INTERNAL_ACNUM,
                                                        'BDT',
                                                        '30-JUNE-2019',
                                                        '17-JULY-2019'),
                                     0))  */
                           0 ACCOUNT_BAL,
                           TRAN_AMOUNT,
                           INDCLIENT_FIRST_NAME,
                           INDCLIENT_LAST_NAME,
                           INDCLIENT_MIDDLE_NAME,
                           INDCLIENT_FATHER_NAME,
                           (SELECT INDSPOUSE_SPOUSE_NAME
                              FROM INDCLIENTSPOUSE
                             WHERE     INDSPOUSE_CLIENT_CODE = INDCLIENT_CODE
                                   AND INDSPOUSE_SL = 1)
                              SPOUSE_NAME,
                           INDCLIENT_MOTHER_NAME MOTHER_NAME,
                           TRAN_DATE_OF_TRAN,
                           INDCLIENT_BIRTH_DATE BIRTH_DATE,
                           INDCLIENT_SEX GENDER,
                           (SELECT OCCUPATIONS_DESCN
                              FROM OCCUPATIONS
                             WHERE OCCUPATIONS_CODE = INDCLIENT_OCCUPN_CODE)
                              OCCUPATION,
                           (SELECT PIDDOCS_DOCID_NUM
                              FROM (SELECT PIDDOCS_DOCID_NUM,
                                           PIDDOCS_INV_NUM,
                                           ROW_NUMBER ()
                                           OVER (PARTITION BY PIDDOCS_INV_NUM
                                                 ORDER BY PIDDOCS_INV_NUM)
                                              AS RN
                                      FROM PIDDOCS
                                     WHERE PIDDOCS_PID_TYPE = 'NID')
                             WHERE     RN = 1
                                   AND PIDDOCS_INV_NUM = INDCLIENT_PID_INV_NUM)
                              NID,
                           (SELECT PIDDOCS_DOCID_NUM
                              FROM (SELECT PIDDOCS_DOCID_NUM,
                                           PIDDOCS_INV_NUM,
                                           ROW_NUMBER ()
                                           OVER (PARTITION BY PIDDOCS_INV_NUM
                                                 ORDER BY PIDDOCS_INV_NUM)
                                              AS RN
                                      FROM PIDDOCS
                                     WHERE PIDDOCS_PID_TYPE = 'BC')
                             WHERE     RN = 1
                                   AND PIDDOCS_INV_NUM = INDCLIENT_PID_INV_NUM)
                              BIRTH_REG,
                           (SELECT PIDDOCS_DOCID_NUM
                              FROM (SELECT PIDDOCS_DOCID_NUM,
                                           PIDDOCS_INV_NUM,
                                           ROW_NUMBER ()
                                           OVER (PARTITION BY PIDDOCS_INV_NUM
                                                 ORDER BY PIDDOCS_INV_NUM)
                                              AS RN
                                      FROM PIDDOCS
                                     WHERE PIDDOCS_PID_TYPE = 'PP')
                             WHERE     RN = 1
                                   AND PIDDOCS_INV_NUM = INDCLIENT_PID_INV_NUM)
                              PASSPORT,
                           (SELECT PIDDOCS_DOCID_NUM
                              FROM (SELECT PIDDOCS_DOCID_NUM,
                                           PIDDOCS_INV_NUM,
                                           ROW_NUMBER ()
                                           OVER (PARTITION BY PIDDOCS_INV_NUM
                                                 ORDER BY PIDDOCS_INV_NUM)
                                              AS RN
                                      FROM PIDDOCS
                                     WHERE PIDDOCS_PID_TYPE = 'TIN')
                             WHERE     RN = 1
                                   AND PIDDOCS_INV_NUM = INDCLIENT_PID_INV_NUM)
                              TIN,
                           (SELECT ADDRDTLS_MOBILE_NUM
                              FROM ADDRDTLS, CLIENTS
                             WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                                   AND CLIENTS_CODE = INDCLIENT_CODE
                                   AND ADDRDTLS_ADDR_SL = 1)
                              MOBILE_NUM,
                           INDCLIENT_TEL_RES LAND_PHONE,
                           INDCLIENT_EMAIL_ADDR1 EMAIL,
                           (SELECT STATE_NAME
                              FROM STATE, ADDRDTLS, CLIENTS
                             WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                                   AND CLIENTS_CODE = INDCLIENT_CODE
                                   AND ADDRDTLS_ADDR_SL = 1
                                   AND STATE_CODE = ADDRDTLS_STATE_CODE)
                              STATE_DIVISION,
                           (SELECT DISTRICT_NAME
                              FROM DISTRICT, ADDRDTLS, CLIENTS
                             WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                                   AND CLIENTS_CODE = INDCLIENT_CODE
                                   AND ADDRDTLS_ADDR_SL = 1
                                   AND ADDRDTLS_DISTRICT_CODE = DISTRICT_CODE)
                              CITY_DISTRICT,
                           (SELECT POSTAL_NAME
                              FROM POSTAL, ADDRDTLS, CLIENTS
                             WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                                   AND CLIENTS_CODE = INDCLIENT_CODE
                                   AND ADDRDTLS_ADDR_SL = 1
                                   AND ADDRDTLS_POSTAL_CODE = POSTAL_CODE)
                              POLICE_STATION,
                           (SELECT    CLIENTS_ADDR1
                                   || CLIENTS_ADDR2
                                   || CLIENTS_ADDR3
                                   || CLIENTS_ADDR4
                                   || CLIENTS_ADDR5
                              FROM ADDRDTLS, CLIENTS
                             WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                                   AND CLIENTS_CODE = INDCLIENT_CODE
                                   AND ADDRDTLS_ADDR_SL = 1)
                              ROAD_SECTOR_BLOCK_VILL_HOUSE
                      FROM TRAN2019, ACNTS, INDCLIENTS
                     WHERE     TRAN_ENTITY_NUM = 1
                           AND TRAN_DATE_OF_TRAN BETWEEN '01-JUNE-2019'
                                                     AND '30-JUNE-2019'
                           AND TRAN_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                           AND TRAN_INTERNAL_ACNUM <> 0
                           AND ACNTS_ENTITY_NUM = 1
                           AND ACNTS_PROD_CODE IN (1000, 1005, 1020, 1030, 1060)
                           ---  AND TRAN_AMOUNT >= 1000000
                           -- AND ACNTS_BRN_CODE = 1065
                           AND ACNTS_CLIENT_NUM = INDCLIENT_CODE
                           AND TRAN_CODE IN ('CW', 'CD', 'CC', 'CWSP', 'CW1')) TT,
                   MBRN_TREE2 T
             WHERE T.BRANCH_CODE = TT.ACNTS_BRN_CODE
          ORDER BY TT.ACNTS_BRN_CODE)
GROUP BY BRANCH_HO,
         HO_NAME,
         BRANCH_GMO,
         GMO_NAME,
         BRANCH_PO,
         PO_NAME,
         BRANCH_NAME,
         ACNTS_BRN_CODE,
         ACCOUNT_NUMBER,
         ACOUNT_NAME,
         ACNTS_OPENING_DATE,
         ACNTS_AC_TYPE,
         ACNTS_CLOSURE_DATE,
         ACCOUNT_BAL,
         TRAN_AMOUNT,
         INDCLIENT_FIRST_NAME,
         INDCLIENT_LAST_NAME,
         INDCLIENT_MIDDLE_NAME,
         INDCLIENT_FATHER_NAME,
         SPOUSE_NAME,
         MOTHER_NAME,
         BIRTH_DATE,
         GENDER,
         OCCUPATION,
         NID,
         BIRTH_REG,
         PASSPORT,
         TIN,
         MOBILE_NUM,
         LAND_PHONE,
         EMAIL,
         STATE_DIVISION,
         CITY_DISTRICT,
         POLICE_STATION,
         ROAD_SECTOR_BLOCK_VILL_HOUSE,
         INDCLIENT_CODE,
         TRAN_DATE_OF_TRAN
  HAVING SUM (TRAN_AMOUNT) >= 1000000;

-------------------------------CORPORATE-------------------------------------

  SELECT BRANCH_HO,
         HO_NAME,
         BRANCH_GMO,
         GMO_NAME,
         BRANCH_PO,
         PO_NAME,
         BRANCH_NAME,
         ACNTS_BRN_CODE,
         ACCOUNT_NUMBER,
         ACOUNT_NAME,
         ACNTS_OPENING_DATE,
         ACNTS_AC_TYPE,
         ACNTS_CLOSURE_DATE,
         ACCOUNT_BAL,
         TRAN_AMOUNT,
         INDCLIENT_FIRST_NAME,
         INDCLIENT_LAST_NAME,
         INDCLIENT_MIDDLE_NAME,
         INDCLIENT_FATHER_NAME,
         SPOUSE_NAME,
         MOTHER_NAME,
         BIRTH_DATE,
         GENDER,
         OCCUPATION,
         NID,
         BIRTH_REG,
         PASSPORT,
         TIN,
         MOBILE_NUM,
         LAND_PHONE,
         EMAIL,
         STATE_DIVISION,
         CITY_DISTRICT,
         POLICE_STATION,
         ROAD_SECTOR_BLOCK_VILL_HOUSE,
         TRAN_DATE_OF_TRAN,
         SUM (TRAN_AMOUNT)
    FROM (  SELECT BRANCH_HO,
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
                      BRANCH_NAME,
                   TT.*
              FROM (SELECT ACNTS_BRN_CODE,
                           FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NUMBER,
                           ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACOUNT_NAME,
                           ACNTS_OPENING_DATE,
                           ACNTS_AC_TYPE,
                           TRAN_DATE_OF_TRAN,
                           ACNTS_CLOSURE_DATE,
                        /*   (NVL (FN_GET_ASON_ACBAL (1,
                                                    ACNTS_INTERNAL_ACNUM,
                                                    'BDT',
                                                    '30-JUNE-2019',
                                                    '17-JULY-2019'),
                                 0)) */
                            0  ACCOUNT_BAL,
                           TRAN_AMOUNT,
                           CLIENTS_NAME INDCLIENT_FIRST_NAME,
                           NULL INDCLIENT_LAST_NAME,
                           NULL INDCLIENT_MIDDLE_NAME,
                           NULL INDCLIENT_FATHER_NAME,
                           (SELECT INDSPOUSE_SPOUSE_NAME
                              FROM INDCLIENTSPOUSE
                             WHERE INDSPOUSE_CLIENT_CODE = CLIENTS_CODE)
                              SPOUSE_NAME,
                           NULL MOTHER_NAME,
                           NULL BIRTH_DATE,
                           NULL GENDER,
                           (SELECT OCCUPATIONS_DESCN
                              FROM OCCUPATIONS
                             WHERE OCCUPATIONS_CODE = 0)
                              OCCUPATION,
                           (SELECT PIDDOCS_DOCID_NUM
                              FROM PIDDOCS
                             WHERE     PIDDOCS_INV_NUM = 0
                                   AND PIDDOCS_PID_TYPE = 'NID')
                              NID,
                           (SELECT PIDDOCS_DOCID_NUM
                              FROM PIDDOCS
                             WHERE     PIDDOCS_INV_NUM = 0
                                   AND PIDDOCS_PID_TYPE = 'BC')
                              BIRTH_REG,
                           (SELECT PIDDOCS_DOCID_NUM
                              FROM PIDDOCS
                             WHERE     PIDDOCS_INV_NUM = 0
                                   AND PIDDOCS_PID_TYPE = 'PP')
                              PASSPORT,
                           (SELECT DISTINCT PIDDOCS_DOCID_NUM
                              FROM PIDDOCS
                             WHERE     PIDDOCS_INV_NUM = 0
                                   AND PIDDOCS_PID_TYPE = 'TIN')
                              TIN,
                           (SELECT ADDRDTLS_MOBILE_NUM
                              FROM ADDRDTLS
                             WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM --- AND CLIENTS_CODE = INDCLIENT_CODE
                                   AND ADDRDTLS_ADDR_SL = 1)
                              MOBILE_NUM,
                           (SELECT NVL (ADDRDTLS_PHONE_NUM1, ADDRDTLS_PHONE_NUM2)
                              FROM ADDRDTLS
                             WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM --- AND CLIENTS_CODE = INDCLIENT_CODE
                                   AND ADDRDTLS_ADDR_SL = 1)
                              LAND_PHONE,
                           NULL EMAIL,
                           (SELECT STATE_NAME
                              FROM STATE, ADDRDTLS
                             WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                                   -- AND CLIENTS_CODE = INDCLIENT_CODE
                                   AND ADDRDTLS_ADDR_SL = 1
                                   AND STATE_CODE = ADDRDTLS_STATE_CODE)
                              STATE_DIVISION,
                           (SELECT DISTRICT_NAME
                              FROM DISTRICT, ADDRDTLS
                             WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                                   -- AND CLIENTS_CODE = INDCLIENT_CODE
                                   AND ADDRDTLS_ADDR_SL = 1
                                   AND ADDRDTLS_DISTRICT_CODE = DISTRICT_CODE)
                              CITY_DISTRICT,
                           (SELECT POSTAL_NAME
                              FROM POSTAL, ADDRDTLS
                             WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                                   -- AND CLIENTS_CODE = INDCLIENT_CODE
                                   AND ADDRDTLS_ADDR_SL = 1
                                   AND ADDRDTLS_POSTAL_CODE = POSTAL_CODE)
                              POLICE_STATION,
                           (SELECT    CLIENTS_ADDR1
                                   || CLIENTS_ADDR2
                                   || CLIENTS_ADDR3
                                   || CLIENTS_ADDR4
                                   || CLIENTS_ADDR5
                              FROM ADDRDTLS
                             WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM -- AND CLIENTS_CODE = CLIENT_CODE
                                   AND ADDRDTLS_ADDR_SL = 1)
                              ROAD_SECTOR_BLOCK_VILL_HOUSE
                      FROM TRAN2019, ACNTS, CLIENTS
                     WHERE     TRAN_ENTITY_NUM = 1
                           AND TRAN_DATE_OF_TRAN BETWEEN '01-JUNE-2019'
                                                     AND '30-JUNE-2019'
                           AND TRAN_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                           AND ACNTS_ENTITY_NUM = 1
                           AND ACNTS_PROD_CODE IN (1000, 1005, 1020, 1030, 1060)
                           --AND TRAN_AMOUNT >= 1000000
                           AND CLIENTS_TYPE_FLG <> 'I'
                           -- AND ACNTS_BRN_CODE = 1065
                           AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                           AND TRAN_CODE IN ('CW', 'CD', 'CC', 'CWSP', 'CW1')) TT,
                   MBRN_TREE2 T
             WHERE T.BRANCH_CODE = TT.ACNTS_BRN_CODE
          ORDER BY TT.ACNTS_BRN_CODE)
GROUP BY BRANCH_HO,
         HO_NAME,
         BRANCH_GMO,
         GMO_NAME,
         BRANCH_PO,
         PO_NAME,
         BRANCH_NAME,
         ACNTS_BRN_CODE,
         ACCOUNT_NUMBER,
         ACOUNT_NAME,
         ACNTS_OPENING_DATE,
         ACNTS_AC_TYPE,
         ACNTS_CLOSURE_DATE,
         ACCOUNT_BAL,
         TRAN_AMOUNT,
         INDCLIENT_FIRST_NAME,
         INDCLIENT_LAST_NAME,
         INDCLIENT_MIDDLE_NAME,
         INDCLIENT_FATHER_NAME,
         SPOUSE_NAME,
         MOTHER_NAME,
         BIRTH_DATE,
         GENDER,
         OCCUPATION,
         NID,
         BIRTH_REG,
         PASSPORT,
         TIN,
         MOBILE_NUM,
         LAND_PHONE,
         EMAIL,
         STATE_DIVISION,
         CITY_DISTRICT,
         POLICE_STATION,
         ROAD_SECTOR_BLOCK_VILL_HOUSE,
         TRAN_DATE_OF_TRAN
  HAVING SUM (TRAN_AMOUNT) >= 1000000;