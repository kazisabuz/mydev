/* Formatted on 29/11/2020 4:02:50 PM (QP5 v5.227.12220.39754) */
  SELECT GMO_NAME,
         GMO_CODE,
         PO_NAME,
         PO_CODE,
         CLIENTS_HOME_BRN_CODE BRANCH_CODE,
         MBRN_NAME BRANCH_NAME,
         COUNT (*)
    FROM (SELECT CLIENTS_HOME_BRN_CODE,
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
                 ADDRDTLS_MOBILE_NUM
            FROM (SELECT /*+ PARALLEL( 16) */
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
                         ACNTS
                   WHERE     CLIENTS_CODE = INDCLIENT_CODE
                         AND ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                         AND CLIENTS_HOME_BRN_CODE = MBRN_CODE
                         AND CLIENTS_CODE = ACNTS_CLIENT_NUM
                         AND ACNTS_ENTITY_NUM = 1
                         -- AND    TRIM (CLIENTS_TITLE_CODE) IS NOT  NULL
                         AND (   TRIM (ADDRDTLS_MOBILE_NUM) IS NOT NULL
                              OR INDCLIENT_TEL_GSM IS NOT NULL)
                         AND (    NOT EXISTS
                                         (SELECT 1
                                            FROM PIDDOCS
                                           WHERE     PIDDOCS_INV_NUM =
                                                        INDCLIENT_PID_INV_NUM
                                                 AND PIDDOCS_PID_TYPE IN
                                                        ('SID',
                                                         'NID',
                                                         'PP',
                                                         'BC',
                                                         'NIN'))
                              AND NOT EXISTS
                                         (SELECT 1
                                            FROM CONNPINFO
                                           WHERE     CONNP_INV_NUM =
                                                        ACNTS_CONNP_INV_NUM
                                                 AND CONNP_CONN_ROLE = 2
                                                 AND ACNTS_ENTITY_NUM = 1)
                              -- AND TRIM (CLIENTS_LOCN_CODE) IS NOT  NULL
                              AND    TRIM (INDCLIENT_FIRST_NAME)
                                  || TRIM (INDCLIENT_LAST_NAME)
                                     IS NOT NULL
                              AND TRIM (INDCLIENT_FATHER_NAME) IS NOT NULL
                              AND INDCLIENT_BIRTH_DATE IS NOT NULL
                              --  AND TRIM (INDCLIENT_SEX) IS NOT  NULL
                              AND TRIM (INDCLIENT_MOTHER_NAME) IS NOT NULL
                              AND TRIM (INDCLIENT_OCCUPN_CODE) IS NOT NULL)))
-- AND TRIM (ADDRDTLS_STATE_CODE) IS NOT  NULL
-- AND TRIM (ADDRDTLS_DISTRICT_CODE) IS NOT  NULL
-- AND TRIM (ADDRDTLS_POSTAL_CODE) IS NOT  NULL))
GROUP BY GMO_NAME,
         GMO_CODE,
         PO_NAME,
         PO_CODE,
         CLIENTS_HOME_BRN_CODE,
         MBRN_NAME
ORDER BY GMO_CODE, PO_CODE, CLIENTS_HOME_BRN_CODE;