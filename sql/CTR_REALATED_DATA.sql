/* Formatted on 5/24/2022 3:41:06 PM (QP5 v5.252.13127.32867) */
-----total ctr -----
SELECT 'WITHOUT WAGE BRANCH',
       COUNT (AC_NUM) total_account,
       SUM (TRAN_AMOUNT) TRAN_AMOUNT
  FROM BACKUPTABLE.CTR_REPORT, IACLINK
 WHERE     AC_NUM = IACLINK_ACTUAL_ACNUM
       AND IACLINK_ENTITY_NUM = 1
       AND IACLINK_BRN_CODE <> 34
UNION ALL
SELECT 'ALL BRANCH',
       COUNT (AC_NUM) total_account,
       SUM (TRAN_AMOUNT) TRAN_AMOUNT
  FROM BACKUPTABLE.CTR_REPORT;

--invalid nid

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
       tt.*
  FROM (SELECT CLIENTS_HOME_BRN_CODE,
               ACNTS_BRN_CODE,
               facno (1, ACNTS_INTERNAL_ACNUM) acc_no,
               INDCLIENT_CODE,
               CLIENTS_NAME,
               PIDDOCS_PID_TYPE,
               PIDDOCS_DOCID_NUM
          FROM acnts,
               clients,
               INDCLIENTS,
               piddocs
         WHERE     INDCLIENT_PID_INV_NUM = PIDDOCS_INV_NUM
               AND INDCLIENT_CODE = CLIENTS_CODE
               AND PIDDOCS_PID_TYPE IN ('NID', 'SID')
               AND PIDDOCS_PID_TYPE IN ('NID', 'SID')
               AND (   PIDDOCS_DOCID_NUM LIKE '12345%'
                    OR PIDDOCS_DOCID_NUM LIKE '00%'
                    OR PIDDOCS_DOCID_NUM LIKE '11111%'
                    OR PIDDOCS_DOCID_NUM LIKE '22222%'
                    OR PIDDOCS_DOCID_NUM LIKE '33333%'
                    OR PIDDOCS_DOCID_NUM LIKE '44444%'
                    OR PIDDOCS_DOCID_NUM LIKE '55555%'
                    OR PIDDOCS_DOCID_NUM LIKE '66666%'
                    OR PIDDOCS_DOCID_NUM LIKE '77777%'
                    OR PIDDOCS_DOCID_NUM LIKE '88888%'
                    OR PIDDOCS_DOCID_NUM LIKE '99999%')
               AND ACNTS_ENTITY_NUM = 1
               AND CLIENTS_CODE IN (SELECT CLIENTNUMBER
                                      FROM GOAML_TRAN_MASTER
                                     WHERE     RPT_YEAR = 2021
                                           AND RPT_MONTH = 7
                                           AND RTP_TYPE = 'CTR')
               --  AND CLIENTS_HOME_BRN_CODE = 1115
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE) TT,
       MBRN_TREE2
 WHERE TT.CLIENTS_HOME_BRN_CODE = BRANCH_CODE;

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
       tt.*
  FROM (SELECT CLIENTS_HOME_BRN_CODE,
               ACNTS_BRN_CODE,
               facno (1, ACNTS_INTERNAL_ACNUM) acc_no,
               INDCLIENT_CODE,
               CLIENTS_NAME,
               CASE
                  WHEN CLIENTS_TYPE_FLG = 'I' THEN 'INDIVIDUAL'
                  ELSE NULL
               END
                  CLIENT_TYPE,
               UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) ACCOUNT_NAME
          FROM acnts, clients, INDCLIENTS
         WHERE     INDCLIENT_CODE = CLIENTS_CODE
               AND ACNTS_ENTITY_NUM = 1
               AND (   UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE '%TRAD%'
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
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE '%RICE%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%CONST%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%TELECOM%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%TRANS%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE '%M/S%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%MESARCE%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE '%BADC%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%PUBLIC%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE '%FUND%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%DORIDRO%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE '%RICE%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%UPAJILA%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%UPOZILA%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%SOCIAL%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%BROTHER%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%SCIENTIFIC%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE '%BKB%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%B.K.B%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE '%POST%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%BIMOCHON%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%CHAIRMAN%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE '%GRAM%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE '%RICE%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE '%UNO%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%U.N.O%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%PROCURE%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%TAHABIL%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%POLICE%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%SUPER%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%HIGHWAY%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%CORPORATION%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%INTERNATIONAL%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%COMMIT%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%SOMITY%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%SAMITY%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%TEACHER%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%TELECOM%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%BANGLADESH%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%THANA%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%BUILDERS%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%UBCCA%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%MOHILA%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%INSTITUTE%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%REGIONAL%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%FORUM%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%CIVIL%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%SURGEON%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%SERVICE%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%ENTERP%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%UPOZELA%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%PORIBAR%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%HOSPITAL%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%MULTIMEDIA%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%KURMOCHUCI%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE '%BRAC%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%HOUSE%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE '%DRUG%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%AGRICUL%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%DISTRICT%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%MAYOR%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%DIVISONAL%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%BUSINEES%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%BANIJJO%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%REGISTER%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%EXECUTIVE%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%DEVELOPMENT%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%ORGANIZATION%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%FAMILY%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%STORE%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%HEALTH%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%PLANNING%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%COMPUTER%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%STATIS%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%PROKALPO%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%BRANCH%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%NIRBAHI%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%RELIF%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE '%BFDC%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%DAIRY%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE '%TNO%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%PROGRAMM%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%CENTER%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%PRESS%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%GOVT.%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%NATIONAL%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%INCOME%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%PROJECT%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE '%TMSS%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%MOTOR%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%TRAINING%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%PRIMAY%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%MASJID%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE
                          '%MOSZID%'
                    OR UPPER (ACNTS_AC_NAME1 || ACNTS_AC_NAME2) LIKE '%UCCA%')
               --     AND CLIENTS_HOME_BRN_CODE = 1115
               AND CLIENTS_CODE IN (SELECT CLIENTNUMBER
                                      FROM GOAML_TRAN_MASTER
                                     WHERE     RPT_YEAR = 2022
                                           AND RPT_MONTH = 5
                                           AND RTP_TYPE = 'CTR')
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE) TT,
       MBRN_TREE2
 WHERE TT.CLIENTS_HOME_BRN_CODE = BRANCH_CODE;

 ----->top 20 tran

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
         RPT_BRANCH_CODE,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = RPT_BRANCH_CODE)
            BRANCH_NAME,
         m.CLIENTNUMBER,
         CASE
            WHEN CLIENTTYPE = 'I' THEN 'Individual'
            WHEN CLIENTTYPE = 'C' THEN 'Corporate'
            WHEN CLIENTTYPE = 'J' THEN 'Joint Clients'
            ELSE NULL
         END
            CLIENTTYPE,
         d.ACCOUNT_INFO,
         ACCOUNTNAME,
         INVALID_MESSAGE,
         RECORD_STATUS,
         total_tran
    FROM (  SELECT ACCOUNT_INFO, COUNT (*) total_tran
              FROM GOAML_TRAN_INDV D, GOAML_TRAN_MASTER M
             WHERE     D.SEQ_NO = M.SEQ_NO
                   AND RPT_YEAR = 2022
                   AND RPT_MONTH = 4
                   AND ACCOUNT_INFO IS NOT NULL
                   AND NVL (TO_NUMBER (AMOUNTLOCAL), 0) <> 0
          GROUP BY ACCOUNT_INFO
            HAVING COUNT (*) >= 10) TT,
         GOAML_TRAN_INDV D,
         GOAML_TRAN_MASTER M,
         MBRN_TREE2 T
   WHERE     M.RPT_BRANCH_CODE = T.BRANCH_CODE
         AND TT.ACCOUNT_INFO = D.ACCOUNT_INFO
         AND RPT_YEAR = 2022
         AND RPT_MONTH = 5
         AND D.SEQ_NO = M.SEQ_NO
--  AND d.ACCOUNT_INFO = '1707001019345'
GROUP BY m.CLIENTNUMBER,
         CLIENTTYPE,
         d.ACCOUNT_INFO,
         ACCOUNTNAME,
         INVALID_MESSAGE,
         BRANCH_GMO,
         RECORD_STATUS,
         BRANCH_PO,
         total_tran,
         RPT_BRANCH_CODE;



         ----

UPDATE GOAML_TRAN_MASTER
   SET RECORD_STATUS = 'Invalid',
       INVALID_MESSAGE = 'Corpaorate account open as individual account'
 WHERE     CLIENTNUMBER IN (SELECT CLIENTNUMBER
                              FROM acc4, GOAML_TRAN_MASTER t, clients
                             WHERE     RPT_YEAR = 2023
                                   AND RPT_MONTH = 3
                                   AND CLIENTNUMBER = acc_no
                                   AND CLIENTTYPE = 'I'
                                   AND acc_no = clients_code
                                   AND RECORD_STATUS = 'Valid')
       AND RPT_YEAR = 2023
       AND RPT_MONTH = 3
       AND CLIENTTYPE = 'I'
       AND RECORD_STATUS = 'Valid';


---ZERO CTR BRANCH

SELECT BRANCH_GMO GMO_CODE,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_GMO)
            GMO_NAME,
         BRANCH_PO PO_CODE,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_PO)
            PO_NAME,MBRN_CODE,
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
         WHERE RPT_YEAR = 2022 AND RPT_MONTH = 7) T, MBRN_TREE2
          WHERE T.MBRN_CODE = BRANCH_CODE;

         ;



-------------------director missing

UPDATE GOAML_TRAN_MASTER
   SET RECORD_STATUS = 'Valid', INVALID_MESSAGE = NULL
 WHERE     INVALID_MESSAGE = 'Director Missing'
       AND RPT_YEAR = 2023
       AND RPT_MONTH = 3;

---LENTH

SELECT RPT_BRANCH_CODE,
       ACNTS_INTERNAL_ACNUM Account_Number,
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2 Account_Name,
       ACNTS_AC_TYPE AC_Type,
       CLIENTNUMBER Client_Number,
       (AMOUNTLOCAL) Transaction_Amount,
       DATETRANSACTION Transaction_date,
       RPT_MONTH
  FROM GOAML_TRAN_MASTER, acnts
 WHERE     ACNTS_CLIENT_NUM = CLIENTNUMBER
       AND ACNTS_ENTITY_NUM = 1
       AND RPT_YEAR = '2022'
       AND RPT_MONTH = 7
       AND LENGTH (TO_NUMBER (AMOUNTLOCAL)) > 11;

------month wise CTR data ---------------------------

  SELECT RPT_BRANCH_CODE,
         ACNTS_INTERNAL_ACNUM Account_Number,
         ACNTS_AC_NAME1 || ACNTS_AC_NAME2 Account_Name,
         ACNTS_AC_TYPE AC_Type,
         CLIENTNUMBER Client_Number,
         SUM (AMOUNTLOCAL) Transaction_Amount,
         DATETRANSACTION Transaction_date,
         RPT_MONTH
    FROM GOAML_TRAN_MASTER, acnts
   WHERE     ACNTS_CLIENT_NUM = CLIENTNUMBER
         AND ACNTS_ENTITY_NUM = 1
         AND RPT_YEAR = '2022'
         AND RPT_MONTH = 4
--and RPT_BRANCH_CODE<>34
GROUP BY RPT_BRANCH_CODE,
         ACNTS_INTERNAL_ACNUM,
         ACNTS_AC_NAME1 || ACNTS_AC_NAME2,
         ACNTS_AC_TYPE,
         CLIENTNUMBER,
         DATETRANSACTION,
         RPT_MONTH;


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
       tt.*
  FROM (SELECT CLIENTS_HOME_BRN_CODE,
               facno (1, ACNTS_INTERNAL_ACNUM) acc_no,
               INDCLIENT_CODE,
               CLIENTS_NAME,
               PIDDOCS_PID_TYPE,
               PIDDOCS_DOCID_NUM
          FROM acnts,
               clients,
               INDCLIENTS,
               ADDRDTLS,
               piddocs
         WHERE     INDCLIENT_PID_INV_NUM = PIDDOCS_INV_NUM
               AND INDCLIENT_CODE = CLIENTS_CODE
               AND PIDDOCS_PID_TYPE IN ('NID', 'SID')
               AND PIDDOCS_PID_TYPE IN ('NID', 'SID')
               AND (   PIDDOCS_DOCID_NUM LIKE '12345%'
                    OR PIDDOCS_DOCID_NUM LIKE '00%'
                    OR PIDDOCS_DOCID_NUM LIKE '11111%'
                    OR PIDDOCS_DOCID_NUM LIKE '22222%'
                    OR PIDDOCS_DOCID_NUM LIKE '33333%'
                    OR PIDDOCS_DOCID_NUM LIKE '44444%'
                    OR PIDDOCS_DOCID_NUM LIKE '55555%'
                    OR PIDDOCS_DOCID_NUM LIKE '66666%'
                    OR PIDDOCS_DOCID_NUM LIKE '77777%'
                    OR PIDDOCS_DOCID_NUM LIKE '88888%'
                    OR PIDDOCS_DOCID_NUM LIKE '99999%')
               AND ACNTS_ENTITY_NUM = 1
               AND CLIENTS_CODE IN (SELECT CLIENTNUMBER
                                      FROM GOAML_TRAN_MASTER
                                     WHERE     RPT_YEAR = 2021
                                           AND RPT_MONTH = 7
                                           AND RTP_TYPE = 'CTR')
               --  AND CLIENTS_HOME_BRN_CODE = 1115
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE) TT,
       MBRN_TREE2
 WHERE TT.CLIENTS_HOME_BRN_CODE = BRANCH_CODE;

 --------------details--------------

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
       RPT_BRANCH_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = RPT_BRANCH_CODE)
          BRANCH_NAME,
       CLIENTNUMBER,
       CLIENTS_NAME,
       CASE
          WHEN CLIENTTYPE = 'I' THEN 'Individual'
          WHEN CLIENTTYPE = 'C' THEN 'Corporate'
          WHEN CLIENTTYPE = 'J' THEN 'Joint Clients'
          ELSE NULL
       END
          CLIENTTYPE,
       ACCOUNT_INFO,
       ACNTS_AC_TYPE,
       ACCOUNTNAME,
       INVALID_MESSAGE,
       RECORD_STATUS,
       NVL (TO_NUMBER (AMOUNTLOCAL), 0)
  FROM (SELECT CLIENTTYPE,
               RPT_BRANCH_CODE,
               m.CLIENTNUMBER,
               d.ACCOUNT_INFO,
               NULL ACNTS_AC_TYPE,
               ACCOUNTNAME,
               CLIENTS_NAME,
               INVALID_MESSAGE,
               RECORD_STATUS,
               AMOUNTLOCAL
          FROM GOAML_TRAN_INDV D, GOAML_TRAN_MASTER M, clients c
         WHERE     D.SEQ_NO = M.SEQ_NO
               AND RPT_YEAR = 2022
               AND RPT_MONTH = 5
               AND D.CLIENTNUMBER = CLIENTS_CODE
               AND ACCOUNT_INFO IS NOT NULL
               AND NVL (TO_NUMBER (AMOUNTLOCAL), 0) <> 0) m,
       MBRN_TREE2 T
 WHERE M.RPT_BRANCH_CODE = T.BRANCH_CODE;


  SELECT COUNT (*) account_no, SUM (TO_NUMBER (AMOUNTLOCAL)) Transaction_Amount
    FROM GOAML_TRAN_MASTER
   WHERE RPT_YEAR = '2022' AND RPT_MONTH = 6
--and RPT_BRANCH_CODE<>34
 