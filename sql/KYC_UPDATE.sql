/* Formatted on 3/30/2022 11:49:00 AM (QP5 v5.252.13127.32867) */
------------------------------------ACCOUNT PURPOSE UPDATE-----------------------------------------------------------------


BEGIN
   FOR IDX
      IN (SELECT /*+ PARALLEL( 16) */
                C.CLIENTS_CODE, SECTOR_CODE, CLIENTS_SEGMENT_CODE
            FROM BR_DEPOSIT_TEST T, CLIENTS C
           WHERE     T.CLIENT_CODE = C.CLIENTS_CODE
                 AND CLIENTS_HOME_BRN_CODE in (23259,23184,17160,33167)
              --   AND CLIENTS_SEGMENT_CODE <> '915001'
                 AND TRIM (SECTOR_CODE) <> TRIM (CLIENTS_SEGMENT_CODE))
   LOOP
      UPDATE CLIENTS
         SET CLIENTS_SEGMENT_CODE = IDX.SECTOR_CODE
       WHERE CLIENTS_CODE = IDX.CLIENTS_CODE;
       commit;
   END LOOP;
END;

--------------UPDATE OCCUPAPTION BY SECTOR CODE----------------------

BEGIN
   FOR IDX
      IN (SELECT CLIENTS_CODE,
                 OCCUPATIONS_ID,
                 SECTOR_ID,
                 INDCLIENT_SEX GENDER
            FROM CLIENTS C, INDCLIENTS, KYC_SECTOR_CODE
           WHERE     CLIENTS_HOME_BRN_CODE in (23259,23184,17160,33167)
                 AND CLIENTS_SEGMENT_CODE = SECTOR_ID
                 -- and INDCLIENT_CODE=17968105
                 -- AND CLIENTS_TYPE_FLG = 'I'
                 AND CLIENTS_CODE = INDCLIENT_CODE
                 AND (   TRIM (INDCLIENT_OCCUPN_CODE) = '99'
                      OR TRIM (INDCLIENT_OCCUPN_CODE) IS NULL))
   LOOP
      IF idx.SECTOR_ID = '915001' AND idx.GENDER = 'F'
      THEN
         UPDATE INDCLIENTS
            SET INDCLIENT_OCCUPN_CODE = IDX.OCCUPATIONS_ID
          WHERE INDCLIENT_CODE = IDX.CLIENTS_CODE;
      END IF;
      commit;
   END LOOP;
END;


BEGIN
   FOR IDX
      IN (SELECT CLIENTS_CODE,
                 OCCUPATIONS_ID,
                 SECTOR_ID,
                 INDCLIENT_SEX GENDER
            FROM CLIENTS C, INDCLIENTS, KYC_SECTOR_CODE
           WHERE     CLIENTS_HOME_BRN_CODE in (23259,23184,17160,33167)
                 AND CLIENTS_SEGMENT_CODE = SECTOR_ID
                 AND SECTOR_ID != '915001'
                 AND CLIENTS_CODE = INDCLIENT_CODE
                 AND (   TRIM (INDCLIENT_OCCUPN_CODE) = '99'
                      OR TRIM (INDCLIENT_OCCUPN_CODE) IS NULL))
   LOOP
      UPDATE INDCLIENTS
         SET INDCLIENT_OCCUPN_CODE = IDX.OCCUPATIONS_ID
       WHERE INDCLIENT_CODE = IDX.CLIENTS_CODE;
       commit;
   END LOOP;
END;



----------------UPDATE PURPOSE BY OCCUPATION-------------------


BEGIN
   FOR IDX
      IN (SELECT ACNTS_INTERNAL_ACNUM, OCCUPATION_ID, ACC_OP_PUR
            FROM INDCLIENTS,
                 ACNTS,
                 KYC_OCCUPATION,
                 products
           WHERE     INDCLIENT_CODE = ACNTS_CLIENT_NUM
                 AND ACNTS_ENTITY_NUM = 1
                 AND ACNTS_CLOSURE_DATE IS NULL
                 AND PRODUCT_CODE = ACNTS_PROD_CODE
                 AND TRIM (INDCLIENT_OCCUPN_CODE) = TRIM (OCCUPATION_ID)
                 --   AND PRODUCT_FOR_LOANS = 0
                 AND ACNTS_BRN_CODE in (23259,23184,17160,33167))
   LOOP
      UPDATE ACNTS
         SET ACNTS_PURPOSE_AC_OPEN = idx.ACC_OP_PUR
       WHERE ACNTS_INTERNAL_ACNUM = IDX.ACNTS_INTERNAL_ACNUM;

      COMMIT;
   END LOOP;
END;

----------------UPDATE PURPOSE BY SECOTR CODE-------------------


BEGIN
   FOR IDX
      IN (SELECT ACNTS_INTERNAL_ACNUM, ACC_OP_PUR
            FROM CLIENTS,
                 ACNTS,
                 KYC_SECTOR_CODE,
                 products
           WHERE     CLIENTS_CODE = ACNTS_CLIENT_NUM
                 AND ACNTS_ENTITY_NUM = 1
                 AND ACNTS_CLOSURE_DATE IS NULL
                 --  and CLIENTS_CODE=17968105
                 AND PRODUCT_CODE = ACNTS_PROD_CODE
                 AND TRIM (CLIENTS_SEGMENT_CODE) = TRIM (SECTOR_ID)
                 --   AND TRIM (ACNTS_PURPOSE_AC_OPEN) IS NULL
                 --   AND PRODUCT_FOR_LOANS = 0
                 AND ACNTS_BRN_CODE in (23259,23184,17160,33167))
   LOOP
      UPDATE ACNTS
         SET ACNTS_PURPOSE_AC_OPEN = idx.ACC_OP_PUR
       WHERE ACNTS_INTERNAL_ACNUM = IDX.ACNTS_INTERNAL_ACNUM;

      COMMIT;
   END LOOP;
END;



BEGIN
   FOR IDX
      IN (SELECT ACNTS_INTERNAL_ACNUM,
                 PRODUCT_FOR_DEPOSITS,
                 PRODUCT_FOR_LOANS,
                 PRODUCT_FOR_RUN_ACS,
                 PRODUCT_CONTRACT_ALLOWED,
                 PRODUCT_NAME
            FROM CLIENTS, ACNTS, PRODUCTS
           WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                 AND ACNTS_ENTITY_NUM = 1
                 AND ACNTS_BRN_CODE in (23259,23184,17160,33167)
                 --   AND CLIENTS_TYPE_FLG <> 'C'
                 AND CLIENTS_CODE = ACNTS_CLIENT_NUM
                 AND ACNTS_CLOSURE_DATE IS NULL)
   LOOP
      IF IDX.PRODUCT_FOR_LOANS = 1
      THEN
         UPDATE ACNTS
            SET ACNTS_PURPOSE_AC_OPEN = IDX.PRODUCT_NAME
          WHERE ACNTS_INTERNAL_ACNUM = IDX.ACNTS_INTERNAL_ACNUM;
      ELSIF IDX.PRODUCT_FOR_DEPOSITS = 1 AND IDX.PRODUCT_CONTRACT_ALLOWED = 1
      THEN
         UPDATE ACNTS
            SET ACNTS_PURPOSE_AC_OPEN = 'Investment'
          WHERE ACNTS_INTERNAL_ACNUM = IDX.ACNTS_INTERNAL_ACNUM;
      ELSIF     IDX.PRODUCT_FOR_DEPOSITS = 1
            AND IDX.PRODUCT_FOR_RUN_ACS = 0
            AND idx.PRODUCT_CONTRACT_ALLOWED = 0
      THEN
         UPDATE ACNTS
            SET ACNTS_PURPOSE_AC_OPEN = 'Savings'
          WHERE ACNTS_INTERNAL_ACNUM = IDX.ACNTS_INTERNAL_ACNUM;
      END IF;

      COMMIT;
   END LOOP;
END;



BEGIN
   UPDATE ACNTS
      SET ACNTS_PURPOSE_AC_OPEN = 'Receiving Govt. Bhata'
    WHERE     ACNTS_AC_TYPE = 'SBSS'
          AND ACNTS_BRN_CODE in (23259,23184,17160,33167)
          AND ACNTS_ENTITY_NUM = 1;

   UPDATE ACNTS
      SET ACNTS_PURPOSE_AC_OPEN = 'Savings for Students'
    WHERE     ACNTS_AC_TYPE IN ('SBS', 'SSAO')
          AND ACNTS_BRN_CODE in (23259,23184,17160,33167)
          AND ACNTS_ENTITY_NUM = 1;

   UPDATE ACNTS
      SET ACNTS_PURPOSE_AC_OPEN = 'Salary From Service'
    WHERE     ACNTS_AC_TYPE = 'SBST'
          AND ACNTS_BRN_CODE in (23259,23184,17160,33167)
          AND ACNTS_ENTITY_NUM = 1;

   UPDATE ACNTS
      SET ACNTS_PURPOSE_AC_OPEN = 'Savings For Students'
    WHERE     ACNTS_PROD_CODE = 1060
          AND ACNTS_BRN_CODE in (23259,23184,17160,33167)
          AND ACNTS_ENTITY_NUM = 1;

   UPDATE ACNTS
      SET ACNTS_PURPOSE_AC_OPEN = 'Govt. Transaction'
    WHERE     ACNTS_AC_TYPE IN ('CAGOV', 'SBGOV', 'SNDS')
          AND ACNTS_BRN_CODE in (23259,23184,17160,33167)
          AND ACNTS_ENTITY_NUM = 1;

   UPDATE ACNTS
      SET ACNTS_PURPOSE_AC_OPEN = 'Branches Internal Transaction'
    WHERE     ACNTS_AC_TYPE IN ('CAOFF', 'CACOL')
          AND ACNTS_BRN_CODE in (23259,23184,17160,33167)
          AND ACNTS_ENTITY_NUM = 1;
          commit;
END;

------UPDATE INVALID CHARACTER IN SOURCE OF FOUND---------------

BEGIN
   UPDATE ACNTRNPR
      SET ACTP_SRC_FUND = REPLACE (ACTP_SRC_FUND, '.', '');

   UPDATE ACNTRNPR
      SET ACTP_SRC_FUND = REGEXP_REPLACE (ACTP_SRC_FUND, '[0-9]', '');

   UPDATE ACNTRNPRHIST
      SET ACTPH_SRC_FUND = REPLACE (ACTPH_SRC_FUND, '.', '');

   UPDATE ACNTRNPRHIST
      SET ACTPH_SRC_FUND = REGEXP_REPLACE (ACTPH_SRC_FUND, '[0-9]', '');

   COMMIT;
END;

---------SOURCE OF FUND UPDATE ---------------------------------------------------------------------------------------------

BEGIN
   FOR IDX
     IN (SELECT ACNTS_INTERNAL_ACNUM, OCCUPATION_ID, SOURCE_OF_FOUND
            FROM INDCLIENTS,
                 ACNTS,
                 KYC_OCCUPATION,
                 products
           WHERE     INDCLIENT_CODE = ACNTS_CLIENT_NUM
                 AND ACNTS_ENTITY_NUM = 1
                 AND ACNTS_CLOSURE_DATE IS NULL
                 AND PRODUCT_CODE = ACNTS_PROD_CODE
                 AND TRIM (INDCLIENT_OCCUPN_CODE) = TRIM (OCCUPATION_ID)
                 --   AND PRODUCT_FOR_LOANS = 0
                 AND ACNTS_BRN_CODE in (23259,23184,17160,33167))
   LOOP
      UPDATE ACNTRNPR
         SET ACTP_SRC_FUND = IDX.SOURCE_OF_FOUND
       WHERE     ACTP_ACNT_NUM = IDX.ACNTS_INTERNAL_ACNUM
             AND (   TRIM (ACTP_SRC_FUND) IS NULL
                  OR LENGTH (TRIM (ACTP_SRC_FUND)) <= 4);

      UPDATE ACNTRNPRHIST
         SET ACTPH_SRC_FUND = IDX.SOURCE_OF_FOUND
       WHERE     ACTPH_ACNT_NUM = IDX.ACNTS_INTERNAL_ACNUM
             AND (   TRIM (ACTPH_SRC_FUND) IS NULL
                  OR LENGTH (TRIM (ACTPH_SRC_FUND)) <= 4);
                  commit;
   END LOOP;
   
END;


----------source of found update by sectore code -----------------

BEGIN
   FOR IDX
      IN (SELECT ACNTS_INTERNAL_ACNUM, SOURCE_OF_FOUND
            FROM CLIENTS,
                 ACNTS,
                 KYC_SECTOR_CODE,
                 products
           WHERE     CLIENTS_CODE = ACNTS_CLIENT_NUM
                 AND ACNTS_ENTITY_NUM = 1
                 AND ACNTS_CLOSURE_DATE IS NULL
                 --  and CLIENTS_CODE=17968105
                 AND PRODUCT_CODE = ACNTS_PROD_CODE
                 AND TRIM (CLIENTS_SEGMENT_CODE) = TRIM (SECTOR_ID)
                 --   AND TRIM (ACNTS_PURPOSE_AC_OPEN) IS NULL
                 --   AND PRODUCT_FOR_LOANS = 0
                 AND ACNTS_BRN_CODE in (23259,23184,17160,33167))
   LOOP
      UPDATE ACNTRNPR
         SET ACTP_SRC_FUND = IDX.SOURCE_OF_FOUND
       WHERE     ACTP_ACNT_NUM = IDX.ACNTS_INTERNAL_ACNUM
             AND (   TRIM (ACTP_SRC_FUND) IS NULL
                  OR LENGTH (TRIM (ACTP_SRC_FUND)) <= 4);

      UPDATE ACNTRNPRHIST
         SET ACTPH_SRC_FUND = IDX.SOURCE_OF_FOUND
       WHERE     ACTPH_ACNT_NUM = IDX.ACNTS_INTERNAL_ACNUM
             AND (   TRIM (ACTPH_SRC_FUND) IS NULL
                  OR LENGTH (TRIM (ACTPH_SRC_FUND)) <= 4);
                  commit;
   END LOOP;
END;
/* Formatted on 3/30/2022 5:16:48 PM (QP5 v5.252.13127.32867) */
BEGIN
   FOR idx
      IN (SELECT ACNTS_INTERNAL_ACNUM,
                 ACNTS_AC_TYPE,
                 CASE
                    WHEN ACNTS_AC_TYPE = 'SBSS'
                    THEN
                       'Govt. Bhata'
                    WHEN ACNTS_AC_TYPE IN ('SBS', 'SSAO')
                    THEN
                       'Scholarship and Family income'
                    WHEN ACNTS_AC_TYPE = 'SBST'
                    THEN
                       'Salary From Service'
                    WHEN ACNTS_AC_TYPE IN ('CAGOV', 'SBGOV', 'SNDS')
                    THEN
                       'Govtment Fund'
                    WHEN ACNTS_AC_TYPE IN ('CAOFF', 'CACOL')
                    THEN
                       'Official Collection'
                    ELSE
                       NULL
                 END
                    SOURCE_OF_FOUND
            FROM ACNTS
           WHERE     ACNTS_BRN_CODE IN (23259,
                                        23184,
                                        17160,
                                        33167)
                 AND ACNTS_ENTITY_NUM = 1
                 AND ACNTS_CLOSURE_DATE IS NULL
                 AND ACNTS_AC_TYPE IN ('CAOFF',
                                       'CACOL',
                                       'CAGOV',
                                       'SBGOV',
                                       'SNDS',
                                       'SBST',
                                       'SBS',
                                       'SSAO',
                                       'SBSS'))
   LOOP
      UPDATE ACNTRNPR
         SET ACTP_SRC_FUND = IDX.SOURCE_OF_FOUND
       WHERE ACTP_ACNT_NUM = IDX.ACNTS_INTERNAL_ACNUM;

      UPDATE ACNTRNPRHIST
         SET ACTPH_SRC_FUND = IDX.SOURCE_OF_FOUND
       WHERE ACTPH_ACNT_NUM = IDX.ACNTS_INTERNAL_ACNUM;

      COMMIT;
   END LOOP;
END;
----------SOURCE OF FUND VERIFICATION  DOC------------

BEGIN
   FOR IDX
      IN (SELECT ACNTS_INTERNAL_ACNUM
            FROM ACNTS
           WHERE     ACNTS_BRN_CODE in (23259,23184,17160,33167)
                 AND ACNTS_CLOSURE_DATE IS NULL
                 AND ACNTS_ENTITY_NUM = 1)
   LOOP
      UPDATE ACNTRNPR
         SET ACTP_SRC_FUND_DOC1 = 'Documents Collected'
       WHERE     TRIM (ACTP_SRC_FUND_DOC1) IS NULL
             AND ACTP_ACNT_NUM = IDX.ACNTS_INTERNAL_ACNUM;


      UPDATE ACNTRNPRhist
         SET ACTPH_SRC_FUND_DOC1 = 'Documents Collected'
       WHERE     TRIM (ACTPH_SRC_FUND_DOC1) IS NULL
             AND ACTPH_ACNT_NUM = IDX.ACNTS_INTERNAL_ACNUM;


      UPDATE ACNTRNPR
         SET ACTP_SRC_FUND_DOC_VRFD = '1'
       WHERE     (   TRIM (ACTP_SRC_FUND_DOC_VRFD) = '0'
                  OR TRIM (ACTP_SRC_FUND_DOC_VRFD) IS NULL)
             AND ACTP_ACNT_NUM = IDX.ACNTS_INTERNAL_ACNUM;

      UPDATE ACNTRNPRHIST
         SET ACTPH_SRC_FUND_DOC_VRFD = '1'
       WHERE     (   TRIM (ACTPH_SRC_FUND_DOC_VRFD) = '0'
                  OR TRIM (ACTPH_SRC_FUND_DOC_VRFD) IS NULL)
             AND ACTPH_ACNT_NUM = IDX.ACNTS_INTERNAL_ACNUM;
             commit;
   END LOOP;
END;


-----------ADDRESS VERIFICATIONS DETAILS-------------------

BEGIN
   FOR IDX IN (SELECT CLIENTS_TYPE_FLG, C.CLIENTS_CODE
                 FROM CLIENTS C
                WHERE CLIENTS_HOME_BRN_CODE in (23259,23184,17160,33167))
   LOOP
      IF IDX.CLIENTS_TYPE_FLG = 'C'
      THEN
         UPDATE CORPCLIENTS
            SET CORPCL_ADDR_VERIF_DTLS1 = 'Thanks Letter'
          WHERE CORPCL_CLIENT_CODE = IDX.CLIENTS_CODE;
          
      ELSIF IDX.CLIENTS_TYPE_FLG = 'I' THEN
         UPDATE INDCLIENTS
            SET INDCLIENT_ADDR_VERIF_DTLS1 = 'Thanks Letter'
          WHERE INDCLIENT_CODE = IDX.CLIENTS_CODE;
      END IF;
      commit;
   END LOOP;
END;

--------------------------QUERY-------------------------------

SELECT ACNTS_PROD_CODE,
       CLIENTS_CODE,
       CLIENTS_NAME,
       ACNTS_AC_TYPE,
       CLIENTS_SEGMENT_CODE,
       (SELECT SEGMENTS_DESCN
          FROM SEGMENTS
         WHERE SEGMENTS_CODE = CLIENTS_SEGMENT_CODE)
          SEGMENTS_DESCN,
       ACNTS_PURPOSE_AC_OPEN,
       OCCUPATIONS_CODE,
       OCCUPATIONS_DESCN
  FROM acnts,
       CLIENTS,
       INDCLIENTS,
       OCCUPATIONS
 WHERE     ACNTS_ENTITY_NUM = 1
       AND ACNTS_CLOSURE_DATE IS NULL
       AND INDCLIENT_OCCUPN_CODE = OCCUPATIONS_CODE
       AND ACNTS_BRN_CODE = 6064
       AND ACNTS_CLIENT_NUM = CLIENTS_CODE
       AND INDCLIENT_CODE = ACNTS_CLIENT_NUM
       AND TRIM (ACNTS_PURPOSE_AC_OPEN) = 'Others';

      -- AND OCCUPATIONS_CODE = '99'



SELECT ACNTS_INTERNAL_ACNUM,
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACNTS_PROD_CODE,
       ACNTS_AC_TYPE,
       CLIENTS_SEGMENT_CODE,
       (SELECT SEGMENTS_DESCN
          FROM SEGMENTS
         WHERE SEGMENTS_CODE = CLIENTS_SEGMENT_CODE)
  FROM ACNTS, clients
 WHERE     ACNTS_ENTITY_NUM = 1
       AND TRIM (ACNTS_PURPOSE_AC_OPEN) IS NULL
       AND ACNTS_BRN_CODE = 6064
       AND ACNTS_CLOSURE_DATE IS NULL
       AND ACNTS_CLIENT_NUM = CLIENTS_CODE
       AND ACNTS_ENTITY_NUM = 1
       AND ACNTS_BRN_CODE = 6064;


select * from (SELECT /*+ PARALLEL( 16) */
      ACNTS_BRN_CODE,
       ACNTS_CLIENT_NUM,
       CASE
          WHEN CLIENTS_TYPE_FLG = 'I' THEN 'Individual'
          WHEN CLIENTS_TYPE_FLG = 'C' THEN 'Corporate'
          WHEN CLIENTS_TYPE_FLG = 'J' THEN 'Joint'
          ELSE NULL
       END
          clients_type,
       ACNTS_PROD_CODE,
       FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NO,
       ACNTS_AC_TYPE,
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2 account_name,
       CLIENTS_SEGMENT_CODE sector_code,
       (SELECT SEGMENTS_DESCN
          FROM segments
         WHERE SEGMENTS_CODE = CLIENTS_SEGMENT_CODE)
          sector_name,
       ACNTS_PURPOSE_AC_OPEN,
       (SELECT ACTP_SRC_FUND
          FROM ACNTRNPR
         WHERE     ACTP_ACNT_NUM = ACNTS_INTERNAL_ACNUM
               AND ACTP_LATEST_EFF_DATE =
                      (SELECT MAX (ACTP_LATEST_EFF_DATE)
                         FROM ACNTRNPR
                        WHERE ACTP_ACNT_NUM = ACNTS_INTERNAL_ACNUM))
          ACTP_SRC_FUND,
       (SELECT ACTP_SRC_FUND_DOC1
          FROM ACNTRNPR
         WHERE     ACTP_ACNT_NUM = ACNTS_INTERNAL_ACNUM
               AND ACTP_LATEST_EFF_DATE =
                      (SELECT MAX (ACTP_LATEST_EFF_DATE)
                         FROM ACNTRNPR
                        WHERE ACTP_ACNT_NUM = ACNTS_INTERNAL_ACNUM))
          ACTP_SRC_FUND_DOC1,
       (SELECT CASE
                  WHEN ACTP_SRC_FUND_DOC_VRFD = 0 THEN 'Not Verified'
                  WHEN ACTP_SRC_FUND_DOC_VRFD = 1 THEN 'Verified'
                  ELSE NULL
               END
          FROM ACNTRNPR
         WHERE     ACTP_ACNT_NUM = ACNTS_INTERNAL_ACNUM
               AND ACTP_LATEST_EFF_DATE =
                      (SELECT MAX (ACTP_LATEST_EFF_DATE)
                         FROM ACNTRNPR
                        WHERE ACTP_ACNT_NUM = ACNTS_INTERNAL_ACNUM))
          SRC_FUND_DOC_VRFD,
       (SELECT CORPCL_ADDR_VERIF_DTLS1
          FROM CORPCLIENTS
         WHERE CORPCL_CLIENT_CODE = CLIENTS_CODE)
          DDR_VERIF_DTLS1_CROP,
       (SELECT INDCLIENT_ADDR_VERIF_DTLS1
          FROM INDCLIENTS
         WHERE INDCLIENT_CODE = CLIENTS_CODE)
          DDR_VERIF_DTLS_IND
  FROM acnts, clients
 WHERE     ACNTS_CLIENT_NUM = CLIENTS_CODE
       AND ACNTS_CLOSURE_DATE IS NULL
       AND ACNTS_BRN_CODE in (23259,23184,17160,33167)
       AND ACNTS_ENTITY_NUM = 1)
      ---where ACTP_SRC_FUND is null
--
--
--
--DECLARE
----UDDATE_TYPE   VARCHAR2 (100);
---- V_CLIENTS     NUMBER (18);
--BEGIN
--   FOR IDX
--      IN (SELECT CLIENTS_SEGMENT_CODE UDDATE_TYPE,
--                 ACNTS_INTERNAL_ACNUM V_CLIENTS --- INTO UDDATE_TYPE, V_CLIENTS
--            FROM CLIENTS, acnts
--           WHERE     ACNTS_CLIENT_NUM = CLIENTS_CODE
--                 AND ACNTS_ENTITY_NUM = 1
--                 AND ACNTS_BRN_CODE = 6064)
--   LOOP
--      IF IDX.UDDATE_TYPE IN ('903009',
--                             '903010',
--                             '903020',
--                             '903030',
--                             '903040',
--                             '903050',
--                             '903090')
--      THEN
--         UPDATE ACNTS
--            SET ACNTS_PURPOSE_AC_OPEN = 'Business'
--          WHERE ACNTS_ENTITY_NUM = 1 AND ACNTS_INTERNAL_ACNUM = IDX.V_CLIENTS;
--      ELSIF IDX.UDDATE_TYPE = '911000'
--      THEN
--         UPDATE ACNTS
--            SET ACNTS_PURPOSE_AC_OPEN = 'Salary'
--          WHERE ACNTS_ENTITY_NUM = 1 AND ACNTS_INTERNAL_ACNUM = IDX.V_CLIENTS;
--      ELSIF IDX.UDDATE_TYPE LIKE '902%'
--      THEN
--         UPDATE ACNTS
--            SET ACNTS_PURPOSE_AC_OPEN = 'Business'
--          WHERE ACNTS_ENTITY_NUM = 1 AND ACNTS_INTERNAL_ACNUM = IDX.V_CLIENTS;
--      ELSIF IDX.UDDATE_TYPE = '910500'
--      THEN
--         UPDATE ACNTS
--            SET ACNTS_PURPOSE_AC_OPEN = 'Remittance'
--          WHERE ACNTS_ENTITY_NUM = 1 AND ACNTS_INTERNAL_ACNUM = IDX.V_CLIENTS;
--      ELSIF IDX.UDDATE_TYPE IN ('901001',
--                                '901002',
--                                '901003',
--                                '901004',
--                                '901009')
--      THEN
--         UPDATE ACNTS
--            SET ACNTS_PURPOSE_AC_OPEN = 'Agriculture'
--          WHERE ACNTS_ENTITY_NUM = 1 AND ACNTS_INTERNAL_ACNUM = IDX.V_CLIENTS;
--      ELSIF IDX.UDDATE_TYPE = '910000'
--      THEN
--         UPDATE ACNTS
--            SET ACNTS_PURPOSE_AC_OPEN = 'Savings'
--          WHERE ACNTS_ENTITY_NUM = 1 AND ACNTS_INTERNAL_ACNUM = IDX.V_CLIENTS;
--      END IF;
--
--      COMMIT;
--   END LOOP;
--END;
--