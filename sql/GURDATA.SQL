/* Formatted on 7/24/2022 1:26:55 PM (QP5 v5.252.13127.32867) */
--invalid nid

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
                        NULL NOMINEE_NAME,
                        ACNTS_CONNP_INV_NUM
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
                                INDCLIENTS I
                                LEFT JOIN PIDDOCS P
                                   ON P.PIDDOCS_INV_NUM =
                                         I.INDCLIENT_PID_INV_NUM
                          WHERE     INDCLIENT_CODE = CLIENTS_CODE
                                AND CLIENTS_CODE = ACNTS_CLIENT_NUM
                                AND ACNTS_BRN_CODE = IDX.BRANCH_CODE
                                AND ACNTS_CLOSURE_DATE IS NULL
                                 AND PIDDOCS_PID_TYPE IN ('NID', 'SID')
                                AND (    TRIM (INDCLIENT_MOTHER_NAME) IS NULL
                                     OR LENGTH (PIDDOCS_DOCID_NUM) NOT IN (10,
                                                                           13,
                                                                           17)
                                    -- OR  REGEXP_LIKE(PIDDOCS_DOCID_NUM, '^[[:digit:]]+$')
                                     or PIDDOCS_DOCID_NUM like '111%'
                                     or PIDDOCS_DOCID_NUM like '1234%'
                                     or PIDDOCS_DOCID_NUM like '2222%'
                                     or PIDDOCS_DOCID_NUM like '3333%'
                                     or PIDDOCS_DOCID_NUM like '3333%'
                                     OR TRIM (PIDDOCS_DOCID_NUM) IS NULL
                                     OR TRIM (INDCLIENT_FATHER_NAME) IS NULL
                                     OR LENGTH (TRIM (INDCLIENT_FATHER_NAME)) <
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
                                           OR UPPER (INDCLIENT_FATHER_NAME) =
                                           'DADY' 
                                            OR UPPER (INDCLIENT_FATHER_NAME) =
                                           'N/A' 
                                         OR UPPER (INDCLIENT_FATHER_NAME) =
                                           'ABCD'  
                                           OR UPPER (INDCLIENT_FATHER_NAME) =
                                           'NILL' 
                                            
                                            OR UPPER (INDCLIENT_FATHER_NAME) =
                                           'KYC'  
                                            OR UPPER (INDCLIENT_FATHER_NAME) =
                                           'VATA' 
                                             OR UPPER (INDCLIENT_FATHER_NAME) =
                                           'NEED' 
                                             OR UPPER (INDCLIENT_FATHER_NAME) =
                                           'UPDATE' 
                                             OR UPPER (INDCLIENT_FATHER_NAME) =
                                           'GOVT A/C' 
                                           OR UPPER (INDCLIENT_FATHER_NAME) LIKE
                                           '%NOT%'
                                     OR LENGTH (TRIM (INDCLIENT_MOTHER_NAME)) <
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
                                           '%NOT%'
                                           OR UPPER (INDCLIENT_MOTHER_NAME) =
                                           'NILL'  
                                            OR UPPER (INDCLIENT_MOTHER_NAME) =
                                           'KYC' 
                                            OR UPPER (INDCLIENT_MOTHER_NAME) =
                                           'VATA' 
                                           OR UPPER (INDCLIENT_MOTHER_NAME) =
                                           'NEED' 
                                             OR UPPER (INDCLIENT_MOTHER_NAME) =
                                           'UPDATE' 
                                             OR UPPER (INDCLIENT_MOTHER_NAME) =
                                           'GOVT A/C' 
                                           OR UPPER (INDCLIENT_MOTHER_NAME) =
                                           'BIBI'
                                             OR UPPER (INDCLIENT_MOTHER_NAME) =
                                           'NESSA'
                                     OR LENGTH (TRIM (CLIENTS_NAME)) <= 3
                                     OR INDCLIENT_BIRTH_DATE <= '01-JAN-1900')
                                AND ACNTS_ENTITY_NUM = 1)) TT,
                MBRN_TREE1
          WHERE TT.ACNTS_BRN_CODE = BRANCH;

      COMMIT;
   END LOOP;
END;

/* Formatted on 7/24/2022 1:12:05 PM (QP5 v5.252.13127.32867) */
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
                       INDCLIENTS I
                       LEFT OUTER JOIN PIDDOCS P
                          ON P.PIDDOCS_INV_NUM = I.INDCLIENT_PID_INV_NUM
                 WHERE     INDCLIENT_CODE = CLIENTS_CODE
                       AND CLIENTS_CODE = ACNTS_CLIENT_NUM
                       AND ACNTS_BRN_CODE = 26
                       AND ACNTS_CLOSURE_DATE IS NULL
                      -- AND PIDDOCS_PID_TYPE IN ('NID', 'SID')
                       AND (   NOT REGEXP_LIKE (INDCLIENT_FATHER_NAME,
                                                '[A-Za-z]')
                            OR NOT REGEXP_LIKE (INDCLIENT_MOTHER_NAME,
                                                '[A-Za-z]')
                            OR TRIM (INDCLIENT_MOTHER_NAME) IS NULL
                          --  OR LENGTH (PIDDOCS_DOCID_NUM) NOT IN (10, 13, 17)
                            OR REGEXP_LIKE (PIDDOCS_DOCID_NUM,
                                            '([0-9]+)\1{5}')
                            OR TRIM (PIDDOCS_DOCID_NUM) IS NULL
                            OR TRIM (INDCLIENT_FATHER_NAME) IS NULL
                            OR LENGTH (TRIM (INDCLIENT_FATHER_NAME)) <= 3
                            OR UPPER (INDCLIENT_FATHER_NAME) = 'BABA'
                            OR UPPER (INDCLIENT_FATHER_NAME) = 'ABBA'
                            OR UPPER (INDCLIENT_FATHER_NAME) = 'FATHER'
                            OR LENGTH (TRIM (INDCLIENT_MOTHER_NAME)) <= 3
                            OR UPPER (INDCLIENT_MOTHER_NAME) = 'AMMA'
                            OR UPPER (INDCLIENT_MOTHER_NAME) = 'MA'
                            OR UPPER (INDCLIENT_MOTHER_NAME) = 'MOTHER'
                            OR UPPER (INDCLIENT_MOTHER_NAME) LIKE 'NOT%'
                            OR LENGTH (TRIM (CLIENTS_NAME)) <= 3
                            OR LENGTH (TRIM (PIDDOCS_DOCID_NUM)) NOT IN (10,
                                                                         13,
                                                                         17)
                            OR INDCLIENT_BIRTH_DATE = '01-JAN-1972')
                       AND ACNTS_ENTITY_NUM = 1) ABC
               LEFT OUTER JOIN CONNPINFO ON CONNP_INV_NUM = ABC.ACNTS_CONNP_INV_NUM
         WHERE (   UPPER (CONNP_CLIENT_NAME) LIKE '%NOT%'
                OR UPPER (CONNP_CLIENT_NAME) LIKE '%NOMINE%'
                OR UPPER (CONNP_CLIENT_NAME) LIKE '%NOMINI%'
                OR LENGTH (TRIM (CONNP_CLIENT_NAME)) < 3
                OR NOT REGEXP_LIKE (CONNP_CLIENT_NAME, '[A-Za-z]'))) TT,
       MBRN_TREE1
 WHERE TT.ACNTS_BRN_CODE = BRANCH