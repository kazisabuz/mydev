/* Formatted on 10/6/2021 6:06:59 PM (QP5 v5.149.1003.31008) */
--------KYC CLIENTS---------------

SELECT CLIENTS_HOME_BRN_CODE,
       MBRN_NAME,
       PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_CODE = PO_CODE)
          PO_NAME,
       GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_CODE = GMO_CODE)
          GMO_NAME,
       CLIENTS_CODE,
       INDCLIENT_FIRST_NAME,
       INDCLIENT_LAST_NAME,
       INDCLIENT_SUR_NAME,
       INDCLIENT_MIDDLE_NAME,
       CLIENTS_NAME,
       CLIENTS_TITLE_CODE,
       INDCLIENT_FATHER_NAME,
       INDCLIENT_MOTHER_NAME,
       INDCLIENT_SEX,
       ADDRDTLS_MOBILE_NUM,  ACNTS_PROD_CODE,
               ACNTS_AC_TYPE,account_number,CLOSURE_DATE
  FROM (SELECT                                             /*+ PARALLEL( 8) */
              CLIENTS_CODE,
               INDCLIENT_FIRST_NAME,
               INDCLIENT_LAST_NAME,
               CLIENTS_NAME,
               CLIENTS_TYPE_FLG,
               CLIENTS_HOME_BRN_CODE,
               CLIENTS_TITLE_CODE,
               CLIENTS_LOCN_CODE,
               INDCLIENT_SUR_NAME,
               INDCLIENT_MIDDLE_NAME,
               INDCLIENT_FATHER_NAME,
               INDCLIENT_BIRTH_DATE,
               INDCLIENT_SEX,
               INDCLIENT_MOTHER_NAME,
               ADDRDTLS_MOBILE_NUM,
               ACNTS_PROD_CODE,
               ACNTS_AC_TYPE,
               facno (1, ACNTS_INTERNAL_ACNUM) account_number,
               ACNTS_CLOSURE_DATE CLOSURE_DATE,
               (SELECT MBRN_PARENT_ADMIN_CODE
                  FROM MBRN
                 WHERE MBRN_CODE = CLIENTS_HOME_BRN_CODE)
                  PO_CODE,
               (SELECT MBRN_PARENT_ADMIN_CODE
                  FROM MBRN
                 WHERE MBRN_CODE IN
                          (SELECT MBRN_PARENT_ADMIN_CODE
                             FROM MBRN
                            WHERE MBRN_CODE = CLIENTS_HOME_BRN_CODE))
                  GMO_CODE,
               MBRN_NAME
          FROM INDCLIENTS,
               CLIENTS,
               ADDRDTLS,
               MBRN,
               acnts
         WHERE     CLIENTS_CODE = INDCLIENT_CODE
               AND ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND CLIENTS_HOME_BRN_CODE = MBRN_CODE
               AND CLIENTS_HOME_BRN_CODE = 3046
               AND ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE
               and ACNTS_PROD_CODE in (1000)
               AND EXISTS
                      (SELECT 1
                         FROM PIDDOCS
                        WHERE PIDDOCS_INV_NUM = INDCLIENT_PID_INV_NUM
                              AND PIDDOCS_PID_TYPE IN
                                     ('SID', 'NID', 'PP', 'BC', 'NIN'))
               -- AND TRIM (CLIENTS_LOCN_CODE) IS NOT  NULL
               AND TRIM (INDCLIENT_FIRST_NAME) || TRIM (INDCLIENT_LAST_NAME)
                      IS NOT NULL
               AND TRIM (INDCLIENT_FATHER_NAME) IS NOT NULL
               AND INDCLIENT_BIRTH_DATE IS NOT NULL
               AND TRIM (INDCLIENT_SEX) IS NOT NULL
               AND TRIM (INDCLIENT_MOTHER_NAME) IS NOT NULL
               AND TRIM (INDCLIENT_OCCUPN_CODE) IS NOT NULL);

------NON KYC CLINETS

SELECT CLIENTS_HOME_BRN_CODE,
       MBRN_NAME,
       PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_CODE = PO_CODE)
          PO_NAME,
       GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_CODE = GMO_CODE)
          GMO_NAME,
       CLIENTS_CODE,
       INDCLIENT_FIRST_NAME,
       INDCLIENT_LAST_NAME,
       INDCLIENT_SUR_NAME,
       INDCLIENT_MIDDLE_NAME,
       CLIENTS_NAME,
       CLIENTS_TITLE_CODE,
       INDCLIENT_FATHER_NAME,
       INDCLIENT_MOTHER_NAME,
       INDCLIENT_SEX,
       ADDRDTLS_MOBILE_NUM,
       account_status, ACNTS_PROD_CODE,
               ACNTS_AC_TYPE,
                account_number,
                CLOSURE_DATE
  FROM (SELECT                                            /*+ PARALLEL( 16) */
              CLIENTS_CODE,
               INDCLIENT_FIRST_NAME,
               INDCLIENT_LAST_NAME,
               CLIENTS_NAME,
               CLIENTS_TYPE_FLG,
               CLIENTS_HOME_BRN_CODE,
               CLIENTS_TITLE_CODE,
               CLIENTS_LOCN_CODE,
               INDCLIENT_SUR_NAME,
               INDCLIENT_MIDDLE_NAME,
               INDCLIENT_FATHER_NAME,
               INDCLIENT_BIRTH_DATE,
               INDCLIENT_SEX,
               INDCLIENT_MOTHER_NAME,
               ADDRDTLS_MOBILE_NUM, ACNTS_PROD_CODE,
               ACNTS_AC_TYPE,
               facno (1, ACNTS_INTERNAL_ACNUM) account_number,
               ACNTS_CLOSURE_DATE CLOSURE_DATE,
               CASE
                  WHEN ACNTS_INOP_ACNT = 1 THEN 'Inoperative'
                  WHEN ACNTS_DORMANT_ACNT = 1 THEN 'Dormant'
                  WHEN ACNTS_CLOSURE_DATE IS NULL THEN 'Open'
                  WHEN ACNTS_CLOSURE_DATE IS NOT NULL THEN 'Closed'
                  ELSE NULL
               END
                  account_status,
               (SELECT MBRN_PARENT_ADMIN_CODE
                  FROM MBRN
                 WHERE MBRN_CODE = CLIENTS_HOME_BRN_CODE)
                  PO_CODE,
               (SELECT MBRN_PARENT_ADMIN_CODE
                  FROM MBRN
                 WHERE MBRN_CODE IN
                          (SELECT MBRN_PARENT_ADMIN_CODE
                             FROM MBRN
                            WHERE MBRN_CODE = CLIENTS_HOME_BRN_CODE))
                  GMO_CODE,
               MBRN_NAME
          FROM INDCLIENTS,
               CLIENTS,
               ADDRDTLS,
               MBRN,
               acnts
         WHERE     CLIENTS_CODE = INDCLIENT_CODE
               AND ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
               AND CLIENTS_HOME_BRN_CODE = MBRN_CODE
               AND CLIENTS_HOME_BRN_CODE = 1149
                 AND ACNTS_CLIENT_NUM = CLIENTS_CODE
               and ACNTS_PROD_CODE in (1000,1005,1020,1060,1030)
               AND ACNTS_ENTITY_NUM = 1
               -- AND    TRIM (CLIENTS_TITLE_CODE) IS NOT  NULL
               AND (TRIM (ADDRDTLS_MOBILE_NUM) IS NULL
                    OR NOT EXISTS
                              (SELECT 1
                                 FROM PIDDOCS
                                WHERE PIDDOCS_INV_NUM = INDCLIENT_PID_INV_NUM
                                      AND PIDDOCS_PID_TYPE IN
                                             ('SID', 'NID', 'PP', 'BC', 'NIN'))
                    -- AND TRIM (CLIENTS_LOCN_CODE) IS NOT  NULL
                    OR TRIM (INDCLIENT_FIRST_NAME)
                       || TRIM (INDCLIENT_LAST_NAME)
                          IS NULL
                    OR TRIM (INDCLIENT_FATHER_NAME) IS NULL
                    OR INDCLIENT_BIRTH_DATE IS NULL
                    OR TRIM (INDCLIENT_SEX) IS NULL
                    OR TRIM (INDCLIENT_MOTHER_NAME) IS NULL
                    OR TRIM (INDCLIENT_OCCUPN_CODE) IS NULL))