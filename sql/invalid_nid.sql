/* Formatted on 7/3/2022 6:30:20 PM (QP5 v5.252.13127.32867) */
--invalid nid
/* Formatted on 7/24/2022 12:45:07 PM (QP5 v5.252.13127.32867) */
BEGIN
   FOR IDX IN (  SELECT *
                   FROM MIG_DETAIL
               ORDER BY BRANCH_CODE)
   LOOP
      INSERT INTO BACKUPTABLE.KYC_DATA_GURBAGE_2
         SELECT GMO_BRANCH GMO_CODE,
                (SELECT MBRN_NAME
                   FROM MBRN
                  WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = GMO_BRANCH)
                   GMO_NAME,
                PO_BRANCH PO_CODE,
                (SELECT MBRN_NAME
                   FROM MBRN
                  WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PO_BRANCH)
                   PO_NAME,
                (SELECT MBRN_NAME
                   FROM MBRN
                  WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = ACNTS_BRN_CODE)
                   BRANCH_NAME,
                TT.*
           FROM (SELECT ACNTS_BRN_CODE,
                        ACC_NO,
                        INDCLIENT_CODE,
                        CLIENTS_NAME,
                        PIDDOCS_PID_TYPE,
                        PIDDOCS_DOCID_NUM,
                        BIRTH_DATE,
                        FATHER_NAME,
                        MOTHER_NAME,
                        CONNP_CLIENT_NAME NOMINEE_NAME
                   FROM (SELECT ACNTS_BRN_CODE,
                                FACNO (1, ACNTS_INTERNAL_ACNUM) ACC_NO,
                                INDCLIENT_CODE,
                                ACNTS_CONNP_INV_NUM,
                                CLIENTS_NAME,
                                PIDDOCS_PID_TYPE,
                                TRIM (PIDDOCS_DOCID_NUM) PIDDOCS_DOCID_NUM,
                                INDCLIENT_BIRTH_DATE BIRTH_DATE,
                                INDCLIENT_FATHER_NAME FATHER_NAME,
                                INDCLIENT_MOTHER_NAME MOTHER_NAME
                           FROM ACNTS,
                                CLIENTS,
                                INDCLIENTS
                                LEFT JOIN PIDDOCS
                                   ON PIDDOCS_INV_NUM = INDCLIENT_PID_INV_NUM
                          WHERE     INDCLIENT_CODE = CLIENTS_CODE
                                AND CLIENTS_CODE = ACNTS_CLIENT_NUM
                                AND ACNTS_BRN_CODE = 1065
                                AND ACNTS_CLOSURE_DATE IS NULL
                                AND PIDDOCS_PID_TYPE IN ('NID', 'SID')
                                AND (   NOT REGEXP_LIKE (
                                               INDCLIENT_FATHER_NAME,
                                               '[A-Za-z]')
                                     OR NOT REGEXP_LIKE (
                                               INDCLIENT_MOTHER_NAME,
                                               '[A-Za-z]')
                                     OR TRIM (INDCLIENT_MOTHER_NAME) IS NULL
                                     OR LENGTH (PIDDOCS_DOCID_NUM) NOT IN (10,
                                                                           13,
                                                                           17)
                                     OR REGEXP_LIKE (PIDDOCS_DOCID_NUM,
                                                     '([0-9]+)\1{5}')
                                     OR TRIM (PIDDOCS_DOCID_NUM) IS NULL
                                     OR TRIM (INDCLIENT_FATHER_NAME) IS NULL
                                     OR LENGTH (TRIM (INDCLIENT_FATHER_NAME)) <=
                                           3
                                     OR UPPER (INDCLIENT_FATHER_NAME) =
                                           'BABA'
                                     OR NOT REGEXP_LIKE (
                                               INDCLIENT_FATHER_NAME,
                                               '[A-Za-z]')
                                     OR UPPER (INDCLIENT_FATHER_NAME) =
                                           'ABBA'
                                     OR UPPER (INDCLIENT_FATHER_NAME) =
                                           'FATHER'
                                     OR LENGTH (TRIM (INDCLIENT_MOTHER_NAME)) <=
                                           3
                                     OR UPPER (INDCLIENT_MOTHER_NAME) =
                                           'AMMA'
                                     OR NOT REGEXP_LIKE (
                                               INDCLIENT_MOTHER_NAME,
                                               '[A-Za-z]')
                                     OR UPPER (INDCLIENT_MOTHER_NAME) = 'MA'
                                     OR UPPER (INDCLIENT_MOTHER_NAME) =
                                           'MOTHER'
                                     OR UPPER (INDCLIENT_MOTHER_NAME) LIKE
                                           'NOT%'
                                     OR LENGTH (TRIM (CLIENTS_NAME)) <= 3
                                     -- OR NOT REGEXP_LIKE (INDCLIENT_MOTHER_NAME, '^[A-Za-z]+$')
                                     --OR NOT REGEXP_LIKE (INDCLIENT_FATHER_NAME, '^[A-Za-z]+$')
                                     --  OR NOT REGEXP_LIKE (CLIENTS_NAME, '^[A-Za-z]+$')
                                     -- OR NOT REGEXP_LIKE (CONNP_CLIENT_NAME, '^[A-Za-z]+$')
                                     OR LENGTH (TRIM (PIDDOCS_DOCID_NUM)) NOT IN (10,
                                                                                  13,
                                                                                  17)
                                     OR INDCLIENT_BIRTH_DATE = '01-DEC-1972')
                                AND ACNTS_ENTITY_NUM = 1) ABC
                        LEFT JOIN CONNPINFO
                           ON CONNP_INV_NUM = ABC.ACNTS_CONNP_INV_NUM
                  WHERE     CONNP_CONN_ROLE = '2'
                        AND (   UPPER (CONNP_CLIENT_NAME) LIKE 'NOT%'
                             OR UPPER (CONNP_CLIENT_NAME) LIKE 'NOMINE%'
                             OR UPPER (CONNP_CLIENT_NAME) LIKE 'NOMINI%'
                             OR LENGTH (TRIM (CONNP_CLIENT_NAME)) <= 3
                             OR NOT REGEXP_LIKE (CONNP_CLIENT_NAME,
                                                 '[A-Za-z]'))) TT,
                MBRN_TREE1
          WHERE TT.ACNTS_BRN_CODE = BRANCH;

      COMMIT;
   END LOOP;
END;

---------------------INVALID CLINET-----------------------

SELECT BRANCH_GMO GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_GMO)
          GMO_NAME,
       BRANCH_PO PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_PO)
          PO_NAME,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = CLIENTS_HOME_BRN_CODE)
          BRANCH_NAME,
       TT.*
  FROM (SELECT CLIENTS_HOME_BRN_CODE,
               ACNTS_BRN_CODE,
               FACNO (1, ACNTS_INTERNAL_ACNUM) ACC_NO,
               INDCLIENT_CODE,
               CLIENTS_NAME,
               CASE
                  WHEN CLIENTS_TYPE_FLG = 'I' THEN 'INDIVIDUAL'
                  ELSE NULL
               END
                  CLIENT_TYPE,
               UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) ACCOUNT_NAME
          FROM ACNTS, CLIENTS, INDCLIENTS
         WHERE     INDCLIENT_CODE = CLIENTS_CODE
               AND ACNTS_ENTITY_NUM = 1
               AND (   UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%TRADING%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%ENTERPRISE%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%ENGINEERING%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE '%MILL%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%MADRASA%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%FOUNDATION%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%INDUSTRIES%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%COLLEGE%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%SCHOOL%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%OFFICER%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%UPAZILA%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%UNIVERSITY%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%COMMITTEE%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%UNION%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%SOMITEE%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%POULTRY%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE '%BANK%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE '%AUTO%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE '%RICE%')
               --     AND CLIENTS_HOME_BRN_CODE = 1115
               AND CLIENTS_CODE IN (SELECT CLIENTNUMBER
                                      FROM GOAML_TRAN_MASTER
                                     WHERE     RPT_YEAR = 2021
                                           AND RPT_MONTH = 3
                                           AND RTP_TYPE = 'CTR')
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE) TT,
       MBRN_TREE2
 WHERE TT.CLIENTS_HOME_BRN_CODE = BRANCH_CODE;

 ----->50 tran

SELECT ACNTS_BRN_CODE,
       AC_NUM,
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
       ACNTS_PROD_CODE,
       ACNTS_AC_TYPE,
       NOF_TRAN
  FROM (  SELECT AC_NUM, COUNT (*) NOF_TRAN
            FROM BACKUPTABLE.CTR_REPORT
        GROUP BY AC_NUM
          HAVING COUNT (*) >= 50) A,
       ACNTS,
       IACLINK
 WHERE     A.AC_NUM = IACLINK_ACTUAL_ACNUM
       AND IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND ACNTS_ENTITY_NUM = 1
       AND IACLINK_ENTITY_NUM = 1;

---ZERO CTR BRANCH

SELECT MBRN_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_CODE = T.MBRN_CODE)
          MBRN_NAME
  FROM (SELECT MBRN_CODE
          FROM MBRN
         WHERE MBRN_CODE NOT IN (SELECT MBRN_PARENT_ADMIN_CODE FROM MBRN)
        MINUS
        SELECT RPT_BRANCH_CODE
          FROM GOAML_TRAN_MASTER
         WHERE RPT_YEAR = 2021 AND RPT_MONTH = 1) T;


 --invalid MOBILE

SELECT BRANCH_GMO GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_GMO)
          GMO_NAME,
       BRANCH_PO PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_PO)
          PO_NAME,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = CLIENTS_HOME_BRN_CODE)
          BRANCH_NAME,
       TT.*
  FROM (SELECT CLIENTS_HOME_BRN_CODE,
               FACNO (1, ACNTS_INTERNAL_ACNUM) ACC_NO,
               INDCLIENT_CODE,
               CLIENTS_NAME,
               PIDDOCS_PID_TYPE,
               TRIM (PIDDOCS_DOCID_NUM)
          FROM ACNTS,
               CLIENTS,
               INDCLIENTS,
               ADDRDTLS,
               PIDDOCS
         WHERE     INDCLIENT_PID_INV_NUM = PIDDOCS_INV_NUM
               AND INDCLIENT_CODE = CLIENTS_CODE
               AND PIDDOCS_PID_TYPE IN ('NID', 'SID')
               AND (   TRIM (PIDDOCS_DOCID_NUM) LIKE '12345%'
                    OR TRIM (PIDDOCS_DOCID_NUM) LIKE '00%'
                    OR TRIM (PIDDOCS_DOCID_NUM) IS NULL
                    OR TRIM (PIDDOCS_DOCID_NUM) LIKE '11111%'
                    OR TRIM (PIDDOCS_DOCID_NUM) LIKE '22222%'
                    OR TRIM (PIDDOCS_DOCID_NUM) LIKE '33333%'
                    OR TRIM (PIDDOCS_DOCID_NUM) LIKE '44444%'
                    OR TRIM (PIDDOCS_DOCID_NUM) LIKE '55555%'
                    OR TRIM (PIDDOCS_DOCID_NUM) LIKE '66666%'
                    OR TRIM (PIDDOCS_DOCID_NUM) LIKE '77777%'
                    OR TRIM (PIDDOCS_DOCID_NUM) LIKE '88888%'
                    OR TRIM (PIDDOCS_DOCID_NUM) LIKE '99999%')
               AND ACNTS_ENTITY_NUM = 1
               AND CLIENTS_CODE IN (SELECT CLIENTNUMBER
                                      FROM GOAML_TRAN_MASTER
                                     WHERE     RPT_YEAR = 2020
                                           AND RPT_MONTH = 12
                                           AND RTP_TYPE = 'CTR')
               --  AND CLIENTS_HOME_BRN_CODE = 1115
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE) TT,
       MBRN_TREE2
 WHERE TT.CLIENTS_HOME_BRN_CODE = BRANCH_CODE;