/* Formatted on 12/3/2018 3:40:23 PM (QP5 v5.227.12220.39754) */
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
            FROM (SELECT CLIENTS_CODE,
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
                         MBRN
                   WHERE     CLIENTS_CODE = INDCLIENT_CODE
                         AND ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                         AND CLIENTS_HOME_BRN_CODE = MBRN_CODE
                         AND (   TRIM (CLIENTS_TITLE_CODE) IS NULL
                              OR TRIM (ADDRDTLS_MOBILE_NUM) IS NULL
                              OR NOT EXISTS
                                        (SELECT 1
                                           FROM PIDDOCS
                                          WHERE PIDDOCS_INV_NUM =
                                                   INDCLIENT_PID_INV_NUM)
                              OR TRIM (CLIENTS_LOCN_CODE) IS NULL
                              OR TRIM (INDCLIENT_FIRST_NAME) IS NULL
                              OR TRIM (INDCLIENT_LAST_NAME) IS NULL
                              OR TRIM (INDCLIENT_FATHER_NAME) IS NULL
                              OR INDCLIENT_BIRTH_DATE IS NULL
                              OR TRIM (INDCLIENT_SEX) IS NULL
                              OR TRIM (INDCLIENT_MOTHER_NAME) IS NULL
                              OR TRIM (INDCLIENT_OCCUPN_CODE) IS NULL
                              OR    TRIM (ADDRDTLS_ADDR1)
                                 || TRIM (ADDRDTLS_ADDR2)
                                 || TRIM (ADDRDTLS_ADDR3)
                                 || TRIM (ADDRDTLS_ADDR4)
                                 || TRIM (ADDRDTLS_ADDR5)
                                    IS NULL)))
GROUP BY GMO_NAME,
         GMO_CODE,
         PO_NAME,
         PO_CODE,
         CLIENTS_HOME_BRN_CODE,
         MBRN_NAME
ORDER BY GMO_CODE, PO_CODE, CLIENTS_HOME_BRN_CODE;


------------------------------------
SELECT CLIENTS_CODE,
       CLIENTS_HOME_BRN_CODE,
       CLIENTS_TITLE_CODE,
       CLIENTS_NAME,
       INDCLIENT_SEX
  FROM INDCLIENTS, CLIENTS
 WHERE     CLIENTS_CODE = INDCLIENT_CODE
       AND UPPER (CLIENTS_NAME) LIKE 'MD%'
       AND (TRIM (INDCLIENT_SEX) = 'F' OR TRIM (INDCLIENT_SEX) IS NULL);
--and CLIENTS_HOME_BRN_CODE=16121
-----------------------------------------------------------------------------
SELECT CLIENTS_CODE,
       CLIENTS_HOME_BRN_CODE,
       CLIENTS_TITLE_CODE,
       CLIENTS_NAME,
       INDCLIENT_SEX
  FROM INDCLIENTS, CLIENTS
 WHERE     CLIENTS_CODE = INDCLIENT_CODE
       AND (UPPER (CLIENTS_NAME) LIKE 'MST%' OR UPPER (CLIENTS_NAME) LIKE '%BEGUM%')
       AND (TRIM (INDCLIENT_SEX) = 'M' OR TRIM (INDCLIENT_SEX) IS NULL);
--and CLIENTS_HOME_BRN_CODE=16121




---query1
/* Formatted on 05/11/2020 12:20:39 PM (QP5 v5.227.12220.39754) */
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
            FROM (SELECT CLIENTS_CODE,
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
                         MBRN
                   WHERE     CLIENTS_CODE = INDCLIENT_CODE
                         AND ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                         AND CLIENTS_HOME_BRN_CODE = MBRN_CODE
                         -- AND    TRIM (CLIENTS_TITLE_CODE) IS NOT  NULL
                         AND TRIM (ADDRDTLS_MOBILE_NUM) IS NOT  NULL
                         AND  NOT EXISTs
                                    (SELECT 1
                                       FROM PIDDOCS
                                      WHERE     PIDDOCS_INV_NUM =
                                                   INDCLIENT_PID_INV_NUM
                                            AND PIDDOCS_PID_TYPE IN
                                                   ('SID', 'NID', 'PP', 'BC'))
                         AND TRIM (CLIENTS_LOCN_CODE) IS NOT  NULL
                         AND  TRIM (INDCLIENT_FIRST_NAME)||TRIM (INDCLIENT_LAST_NAME )IS NOT null
                         AND TRIM (INDCLIENT_FATHER_NAME) IS NOT  NULL
                         AND INDCLIENT_BIRTH_DATE IS NOT  NULL
                         AND TRIM (INDCLIENT_SEX) IS NOT  NULL
                         AND TRIM (INDCLIENT_MOTHER_NAME) IS NOT  NULL
                         AND TRIM (INDCLIENT_OCCUPN_CODE) IS NOT  NULL
                         AND TRIM (ADDRDTLS_STATE_CODE) IS NOT  NULL
                         AND TRIM (ADDRDTLS_DISTRICT_CODE) IS NOT  NULL
                         AND TRIM (ADDRDTLS_POSTAL_CODE) IS NOT  NULL))
GROUP BY GMO_NAME,
         GMO_CODE,
         PO_NAME,
         PO_CODE,
         CLIENTS_HOME_BRN_CODE,
         MBRN_NAME
ORDER BY GMO_CODE, PO_CODE, CLIENTS_HOME_BRN_CODE;



------query2
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
            FROM (SELECT /*+ PARALLEL( 8) */  CLIENTS_CODE,
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
                         MBRN
                   WHERE     CLIENTS_CODE = INDCLIENT_CODE
                         AND ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                         AND CLIENTS_HOME_BRN_CODE = MBRN_CODE
                         -- AND    TRIM (CLIENTS_TITLE_CODE) IS NOT  NULL
                        -- AND TRIM (ADDRDTLS_MOBILE_NUM) IS NOT  NULL
                         AND  NOT EXISTs
                                    (SELECT 1
                                       FROM PIDDOCS
                                      WHERE     PIDDOCS_INV_NUM =
                                                   INDCLIENT_PID_INV_NUM
                                            AND PIDDOCS_PID_TYPE IN
                                                   ('SID', 'NID', 'PP', 'BC','NIN'))
                        -- AND TRIM (CLIENTS_LOCN_CODE) IS NOT  NULL
                         AND  TRIM (INDCLIENT_FIRST_NAME)||TRIM (INDCLIENT_LAST_NAME )IS NOT null
                         AND TRIM (INDCLIENT_FATHER_NAME) IS NOT  NULL
                         AND INDCLIENT_BIRTH_DATE IS NOT  NULL
                         AND TRIM (INDCLIENT_SEX) IS NOT  NULL
                         AND TRIM (INDCLIENT_MOTHER_NAME) IS NOT  NULL
                         AND TRIM (INDCLIENT_OCCUPN_CODE) IS NOT  NULL))
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

------nonKYC  ----------------
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
            FROM (SELECT /*+ PARALLEL( 16) */ CLIENTS_CODE,
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
                         MBRN
                   WHERE     CLIENTS_CODE = INDCLIENT_CODE
                         AND ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                         AND CLIENTS_HOME_BRN_CODE = MBRN_CODE
                         -- AND    TRIM (CLIENTS_TITLE_CODE) IS NOT  NULL
                         AND (TRIM (ADDRDTLS_MOBILE_NUM) IS   NULL
                         OR  NOT EXISTs
                                    (SELECT 1
                                       FROM PIDDOCS
                                      WHERE     PIDDOCS_INV_NUM =
                                                   INDCLIENT_PID_INV_NUM
                                            AND PIDDOCS_PID_TYPE IN
                                                   ('SID', 'NID', 'PP', 'BC','NIN'))
                        -- AND TRIM (CLIENTS_LOCN_CODE) IS NOT  NULL
                         OR  TRIM (INDCLIENT_FIRST_NAME)||TRIM (INDCLIENT_LAST_NAME )IS  null
                         OR TRIM (INDCLIENT_FATHER_NAME) IS   NULL
                         OR INDCLIENT_BIRTH_DATE IS   NULL
                         OR TRIM (INDCLIENT_SEX) IS   NULL
                         OR TRIM (INDCLIENT_MOTHER_NAME) IS   NULL
                         OR TRIM (INDCLIENT_OCCUPN_CODE) IS   NULL)))
                        -- AND TRIM (ADDRDTLS_STATE_CODE) IS NOT  NULL
                        -- AND TRIM (ADDRDTLS_DISTRICT_CODE) IS NOT  NULL
                        -- AND TRIM (ADDRDTLS_POSTAL_CODE) IS NOT  NULL))
                       -- WHERE GMO_CODE=1990
GROUP BY GMO_NAME,
         GMO_CODE,
         PO_NAME,
         PO_CODE,
         CLIENTS_HOME_BRN_CODE,
         MBRN_NAME
ORDER BY GMO_CODE, PO_CODE, CLIENTS_HOME_BRN_CODE;