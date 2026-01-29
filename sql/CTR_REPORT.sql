/*Cash Transaction Report of the clients of the whole bank.*/

/*
CREATE TABLE CTR_REPORT AS  
 SELECT TRAN_DATE_OF_TRAN,
         TRAN_INTERNAL_ACNUM,
         FACNO (TRAN_ENTITY_NUM, TRAN_INTERNAL_ACNUM) AC_NUM,
         ACNTS_PROD_CODE,
         ACNTS_AC_TYPE,
         TRAN_DB_CR_FLG,
         SUM (TRAN_AMOUNT) TRAN_AMOUNT
    FROM TRAN2018, ACNTS
   WHERE     TRAN_ENTITY_NUM = 1
         AND ACNTS_ENTITY_NUM = 1
         AND ACNTS_INTERNAL_ACNUM = TRAN_INTERNAL_ACNUM
         AND ACNTS_AC_TYPE NOT IN
                ('SBOFF',
                 'SBCOL',
                 'SBGOV',
                 'CAOFF',
                 'CACOL',
                 'CAGOV',
                 'SNDS',
                 'CAOB',
                 'SNDOB',
                 'CAGOV')
         AND TRAN_DATE_OF_TRAN BETWEEN :P_FROM_DATE AND :P_TO_DATE
         AND TRAN_INTERNAL_ACNUM <> 0
         AND ACNTS_PROD_CODE IN (1000, 1020, 1030, 1040, 1060)
         AND TRAN_SYSTEM_POSTED_TRAN <> 1
         AND TRAN_AUTH_BY IS NOT NULL
GROUP BY TRAN_DATE_OF_TRAN,
         TRAN_INTERNAL_ACNUM,
         FACNO (TRAN_ENTITY_NUM, TRAN_INTERNAL_ACNUM),
         ACNTS_PROD_CODE,
         ACNTS_AC_TYPE,
         TRAN_DB_CR_FLG
  HAVING SUM (TRAN_AMOUNT) >= 1000000 
UNION ALL
  SELECT TRAN_DATE_OF_TRAN,
         TRAN_INTERNAL_ACNUM,
         FACNO (TRAN_ENTITY_NUM, TRAN_INTERNAL_ACNUM) AC_NUM,
         ACNTS_PROD_CODE,
         ACNTS_AC_TYPE,
         TRAN_DB_CR_FLG,
         SUM (TRAN_AMOUNT)
    FROM TRAN2018, ACNTS
   WHERE     TRAN_ENTITY_NUM = 1
         AND ACNTS_ENTITY_NUM = 1
         AND ACNTS_INTERNAL_ACNUM = TRAN_INTERNAL_ACNUM
         AND ACNTS_AC_TYPE = 'CAGOV'
         AND ACNTS_PROD_CODE = 1020
         AND TRAN_DATE_OF_TRAN BETWEEN :P_FROM_DATE AND :P_TO_DATE
         AND TRAN_INTERNAL_ACNUM <> 0
         AND TRAN_SYSTEM_POSTED_TRAN <> 1
         AND TRAN_DB_CR_FLG = 'D'
         AND TRAN_AUTH_BY IS NOT NULL
GROUP BY TRAN_DATE_OF_TRAN,
         TRAN_INTERNAL_ACNUM,
         FACNO (TRAN_ENTITY_NUM, TRAN_INTERNAL_ACNUM),
         ACNTS_PROD_CODE,
         ACNTS_AC_TYPE,
         TRAN_DB_CR_FLG
  HAVING SUM (TRAN_AMOUNT) >= 1000000
ORDER BY 3, 1 ;
/

*/

CREATE TABLE CTR_REPORT_FULL
(
   ACNTS_BRN_CODE                 NUMBER,
   BR_NAME                        VARCHAR2 (100),
   ACNTS_ACNUM                    VARCHAR2 (13),
   ACC_TITLE                      VARCHAR2 (200),
   PRODUCT_CODE                   NUMBER,
   CLIENTS_CODE                   NUMBER,
   ACNTS_OPENING_DATE             DATE,
   ACNTS_AC_TYPE                  VARCHAR2 (10),
   PO_RO_CODE                     NUMBER,
   PO_RO_NAME                     VARCHAR2 (100),
   GMO_CODE                       NUMBER,
   GMO_NAME                       VARCHAR2 (100),
   CLIENTS_TYPE_FLG               VARCHAR2 (1),
   CLIENTS_CONST_CODE             VARCHAR2 (100),
   TRANSACTION_DATE               DATE,
   TRANSACTION_AMOUNT             NUMBER,
   TITLE_NAME                     VARCHAR2 (100),
   FIRST_NAME                     VARCHAR2 (100),
   LAST_NAME                      VARCHAR2 (100),
   CLIENT_FATHER_NAME             VARCHAR2 (100),
   CLIENT_MOTHER_NAME             VARCHAR2 (100),
   BIRTH_DATE                     DATE,
   GENDER                         VARCHAR2 (1),
   OCCUPATION                     VARCHAR2 (100),
   NID_NUMBER                     VARCHAR2 (100),
   PHONE_NO                       VARCHAR2 (100),
   MOBILE_NO_GSM                  VARCHAR2 (100),
   TIN                            VARCHAR2 (100),
   ETIN                           VARCHAR2 (100),
   PASPORT_NUMBER                 VARCHAR2 (100),
   DRIVING_LICENCE_NO             VARCHAR2 (100),
   TRADE_LICENCE_NO               VARCHAR2 (100),
   BIRTH_REG_NO                   VARCHAR2 (100),
   BUSINESS_ID_NO                 VARCHAR2 (100),
   TELEPHON_NUMBER                VARCHAR2 (100),
   ACCOUNT_OPENED_BY              VARCHAR2 (10),
   ACCOUNT_OPENED_AUTHORIZED_BY   VARCHAR2 (10),
   CLIENTS_ADDR                   VARCHAR2 (100),
   TOWN                           VARCHAR2 (100),
   CITY                           VARCHAR2 (100),
   STATE                          VARCHAR2 (100),
   NATIOALITY                     VARCHAR2 (100),
   TRANACTION_LOCATION            VARCHAR2 (100),
   BUSINESS                       VARCHAR2 (100),
   ADDRESS                        VARCHAR2 (100),
   CONSTITUTUION_CODE             VARCHAR2 (100),
   CUSTOMER_CATEGORY_CODE         VARCHAR2 (100),
   CUSTOMER_SUB_CATEGORY_CODE     VARCHAR2 (100),
   CUSTOMER_SECTOR_CODE           VARCHAR2 (100),
   ECONOMIC_PURPOSE_GROUP_CODE    VARCHAR2 (100),
   PROPRIETOR                     VARCHAR2 (100),
   SIGNATURY                      VARCHAR2 (100),
   EMPLOYER_NAME                  VARCHAR2 (100),
   TRANSACTION_LOCATION           VARCHAR2 (100)
);


DROP TABLE CTR_REPORT ;

CREATE TABLE CTR_REPORT AS
SELECT T.TRAN_DATE_OF_TRAN,
       FACNO (T.TRAN_ENTITY_NUM, T.TRAN_INTERNAL_ACNUM) AC_NUM,
       A.ACNTS_PROD_CODE,
       A.ACNTS_AC_TYPE,
       T.TRAN_DB_CR_FLG,
       T.TRAN_AMOUNT
  FROM TRAN2018 T, ACNTS A
 WHERE     T.TRAN_ENTITY_NUM = 1
       AND A.ACNTS_INTERNAL_ACNUM = T.TRAN_INTERNAL_ACNUM
       AND (T.TRAN_DATE_OF_TRAN, T.TRAN_INTERNAL_ACNUM, T.TRAN_DB_CR_FLG) IN
              ( SELECT TRAN_DATE_OF_TRAN, TRAN_INTERNAL_ACNUM, TRAN_DB_CR_FLG
                   FROM TRAN2018, ACNTS
                  WHERE     TRAN_ENTITY_NUM = 1
                        AND ACNTS_ENTITY_NUM = 1
                        AND ACNTS_INTERNAL_ACNUM = TRAN_INTERNAL_ACNUM
                        AND ACNTS_AC_TYPE NOT IN
                               ('SBOFF',
                                'SBCOL',
                                'SBGOV',
                                'CAOFF',
                                'CACOL',
                                'SNDS',
                                'CAOB',
                                'SNDOB',
                                'CAGOV')
                        AND TRAN_DATE_OF_TRAN BETWEEN '01-SEP-2018'
                                                  AND '30-SEP-2018'
                        AND TRAN_INTERNAL_ACNUM <> 0
                        AND ACNTS_PROD_CODE IN (1000, 1020, 1030, 1040, 1060)
                        AND TRAN_SYSTEM_POSTED_TRAN <> 1
                        AND TRAN_AUTH_BY IS NOT NULL
                        --AND TRAN_INTERNAL_ACNUM = 11102300013027
               GROUP BY TRAN_DATE_OF_TRAN,
                        TRAN_INTERNAL_ACNUM,
                        ACNTS_PROD_CODE,
                        ACNTS_AC_TYPE,
                        TRAN_DB_CR_FLG
                 HAVING SUM (TRAN_AMOUNT) >= 1000000)
UNION ALL 
SELECT T.TRAN_DATE_OF_TRAN,
       FACNO (T.TRAN_ENTITY_NUM, T.TRAN_INTERNAL_ACNUM) AC_NUM,
       A.ACNTS_PROD_CODE,
       A.ACNTS_AC_TYPE,
       T.TRAN_DB_CR_FLG,
       T.TRAN_AMOUNT
  FROM TRAN2018 T, ACNTS A
 WHERE     T.TRAN_ENTITY_NUM = 1
       AND A.ACNTS_INTERNAL_ACNUM = T.TRAN_INTERNAL_ACNUM
       AND (T.TRAN_DATE_OF_TRAN, T.TRAN_INTERNAL_ACNUM, T.TRAN_DB_CR_FLG) IN
              (  SELECT TRAN_DATE_OF_TRAN, TRAN_INTERNAL_ACNUM, TRAN_DB_CR_FLG
                   FROM TRAN2018, ACNTS
                  WHERE     TRAN_ENTITY_NUM = 1
                        AND ACNTS_ENTITY_NUM = 1
                        AND ACNTS_INTERNAL_ACNUM = TRAN_INTERNAL_ACNUM
                        AND ACNTS_AC_TYPE = 'CAGOV'
                        AND TRAN_DATE_OF_TRAN BETWEEN '01-SEP-2018'
                                                  AND '30-SEP-2018'
                        AND TRAN_INTERNAL_ACNUM <> 0
                        AND ACNTS_PROD_CODE = 1020
                        AND TRAN_SYSTEM_POSTED_TRAN <> 1
                        AND TRAN_AUTH_BY IS NOT NULL
                        AND TRAN_DB_CR_FLG = 'D'
                        --AND TRAN_INTERNAL_ACNUM = 11102300013027
               GROUP BY TRAN_DATE_OF_TRAN,
                        TRAN_INTERNAL_ACNUM,
                        ACNTS_PROD_CODE,
                        ACNTS_AC_TYPE,
                        TRAN_DB_CR_FLG
                 HAVING SUM (TRAN_AMOUNT) >= 1000000)
ORDER BY 1, 2, 5;
/


--474,042

INSERT INTO CTR_REPORT_FULL 
SELECT IACLINK_BRN_CODE ACNTS_BRN_CODE,
       MBRN_NAME BR_NAME,
       AC_NUM ACNTS_ACNUM,
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACC_TITLE,
       A.ACNTS_PROD_CODE PRODUCT_CODE,
       ACNTS_CLIENT_NUM CLIENTS_CODE,
       ACNTS_OPENING_DATE ACNTS_OPENING_DATE,
       A.ACNTS_AC_TYPE ACNTS_AC_TYPE,
       (SELECT PO_BRANCH
          FROM MBRN_TREE1
         WHERE BRANCH = IACLINK_BRN_CODE)
          PO_RO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN M
         WHERE MBRN_CODE = (SELECT PO_BRANCH
                              FROM MBRN_TREE1
                             WHERE BRANCH = IACLINK_BRN_CODE))
          PO_RO_NAME,
       (SELECT GMO_BRANCH
          FROM MBRN_TREE1
         WHERE BRANCH = IACLINK_BRN_CODE)
          GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN M
         WHERE MBRN_CODE = (SELECT GMO_BRANCH
                              FROM MBRN_TREE1
                             WHERE BRANCH = IACLINK_BRN_CODE))
          GMO_NAME,
       CLIENTS_TYPE_FLG CLIENTS_TYPE_FLG,
       CLIENTS_CONST_CODE CLIENTS_CONST_CODE,
       TRAN_DATE_OF_TRAN TRANSACTION_DATE,
       TRAN_AMOUNT TRANSACTION_AMOUNT,
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2 TITLE_NAME,
       ACNTS_AC_NAME1 FIRST_NAME,
       ACNTS_AC_NAME2 LAST_NAME,
       (SELECT INDCLIENT_FATHER_NAME
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
          CLIENT_FATHER_NAME,
       (SELECT INDCLIENT_MOTHER_NAME
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
          CLIENT_MOTHER_NAME,
       (SELECT INDCLIENT_BIRTH_DATE
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
          BIRTH_DATE,
       (SELECT INDCLIENT_SEX
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
          GENDER,
       (SELECT INDCLIENT_OCCUPN_CODE
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
          OCCUPATION,
       (SELECT PIDDOCS_DOCID_NUM
          FROM PIDDOCS, INDCLIENTS
         WHERE     INDCLIENT_PID_INV_NUM = PIDDOCS_INV_NUM
               AND PIDDOCS_PID_TYPE IN ('NID', 'NIN')
               AND PIDDOCS_DOC_SL = 1
               AND INDCLIENT_CODE = CLIENTS_CODE)
          NID_NUMBER,
       (SELECT ADDRDTLS_MOBILE_NUM
          FROM ADDRDTLS
         WHERE ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
         AND ADDRDTLS_ADDR_SL = 1)
          PHONE_NO,
       (SELECT INDCLIENT_TEL_GSM
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
          MOBILE_NO_GSM,
       CLIENTS_PAN_GIR_NUM TIN,
       NULL ETIN,
       (SELECT PIDDOCS_DOCID_NUM
          FROM PIDDOCS, INDCLIENTS
         WHERE     INDCLIENT_PID_INV_NUM = PIDDOCS_INV_NUM
               AND PIDDOCS_PID_TYPE = 'PP'
               AND PIDDOCS_DOC_SL = 1
               AND INDCLIENT_CODE = CLIENTS_CODE)
          PASPORT_NUMBER,
       (SELECT PIDDOCS_DOCID_NUM
          FROM PIDDOCS, INDCLIENTS
         WHERE     INDCLIENT_PID_INV_NUM = PIDDOCS_INV_NUM
               AND PIDDOCS_PID_TYPE = 'DL'
               AND PIDDOCS_DOC_SL = 1
               AND INDCLIENT_CODE = CLIENTS_CODE)
          DRIVING_LICENCE_NO,
       NULL TRADE_LICENCE_NO,
       NULL BIRTH_REG_NO,
       NULL BUSINESS_ID_NO,
       (SELECT INDCLIENT_TEL_RES
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
          TELEPHON_NUMBER,
       ACNTS_ENTD_BY ACCOUNT_OPENED_BY,
       ACNTS_AUTH_BY ACCOUNT_OPENED_AUTHORIZED_BY,
          ACNTS_AC_ADDR1
       || ACNTS_AC_ADDR2
       || ACNTS_AC_ADDR3
       || ACNTS_AC_ADDR4
       || ACNTS_AC_ADDR5
          CLIENTS_ADDR,
       NULL TOWN,
       NULL CITY,
       NULL STATE,
       (SELECT INDCLIENT_NATNL_CODE
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
          NATIOALITY,
       NULL TRANACTION_LOCATION,
       NULL BUSINESS,
       NULL ADDRESS,
       NULL CONSTITUTUION_CODE,
       CLIENTS_CUST_CATG CUSTOMER_CATEGORY_CODE,
       CLIENTS_CUST_SUB_CATG CUSTOMER_SUB_CATEGORY_CODE,
       CLIENTS_SEGMENT_CODE CUSTOMER_SECTOR_CODE,
       NULL ECONOMIC_PURPOSE_GROUP_CODE,
       NULL PROPRIETOR,
       NULL SIGNATURY,
       NULL EMPLOYER_NAME,
       NULL TRANSACTION_LOCATION
  FROM CTR_REPORT,
       IACLINK,
       ACNTS A,
       CLIENTS,
       MBRN
 WHERE     IACLINK_ENTITY_NUM = 1
       AND ACNTS_ENTITY_NUM = 1
       AND IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND CLIENTS_CODE = ACNTS_CLIENT_NUM
       AND IACLINK_ACTUAL_ACNUM = AC_NUM
       AND IACLINK_BRN_CODE = MBRN_CODE; 
       