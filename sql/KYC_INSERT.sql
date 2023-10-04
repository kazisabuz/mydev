/* Formatted on 5/4/2021 1:02:09 PM (QP5 v5.252.13127.32867) */
BEGIN
   FOR IDX
      IN (SELECT *
            FROM MIG_DETAIL
           WHERE BRANCH_CODE NOT IN (SELECT BRANCH_CODE
                                       FROM BACKUPTABLE.KYC_DATA_GMO))
   LOOP
      INSERT INTO BACKUPTABLE.KYC_DATA_GMO
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
                                    WHERE MBRN_CODE IN (SELECT MBRN_PARENT_ADMIN_CODE
                                                          FROM MBRN
                                                         WHERE MBRN_CODE =
                                                                  CLIENTS_HOME_BRN_CODE))
                                     GMO_CODE,
                                  MBRN_NAME
                             FROM INDCLIENTS,
                                  CLIENTS,
                                  ADDRDTLS,
                                  MBRN
                            WHERE     CLIENTS_CODE = INDCLIENT_CODE
                                  AND ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                                  AND CLIENTS_HOME_BRN_CODE = MBRN_CODE
                                  AND CLIENTS_HOME_BRN_CODE = IDX.BRANCH_CODE
                                  -- AND    TRIM (CLIENTS_TITLE_CODE) IS NOT  NULL
                                  AND (   TRIM (ADDRDTLS_MOBILE_NUM) IS NULL
                                       OR NOT EXISTS
                                                 (SELECT 1
                                                    FROM PIDDOCS
                                                   WHERE     PIDDOCS_INV_NUM =
                                                                INDCLIENT_PID_INV_NUM
                                                         AND PIDDOCS_PID_TYPE IN ('SID',
                                                                                  'NID',
                                                                                  'PP',
                                                                                  'BC',
                                                                                  'NIN'))
                                       -- AND TRIM (CLIENTS_LOCN_CODE) IS NOT  NULL
                                       OR    TRIM (INDCLIENT_FIRST_NAME)
                                          || TRIM (INDCLIENT_LAST_NAME)
                                             IS NULL
                                       OR TRIM (INDCLIENT_FATHER_NAME) IS NULL
                                       OR INDCLIENT_BIRTH_DATE IS NULL
                                       OR TRIM (INDCLIENT_SEX) IS NULL
                                       OR TRIM (INDCLIENT_MOTHER_NAME) IS NULL
                                       OR TRIM (INDCLIENT_OCCUPN_CODE) IS NULL)))
         GROUP BY GMO_NAME,
                  GMO_CODE,
                  PO_NAME,
                  PO_CODE,
                  CLIENTS_HOME_BRN_CODE,
                  MBRN_NAME;

      COMMIT;
   END LOOP;
END;