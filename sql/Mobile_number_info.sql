SELECT 'TOTAL_CLIENTS',COUNT (INDCLIENT_CODE)   FROM CLIENTS
UNION ALL
SELECT 'INVALID_MOBILE',  count(ADDRDTLS_MOBILE_NUM)  
 FROM addrdtls,clients
WHERE   ( NOT REGEXP_LIKE (  (ADDRDTLS_MOBILE_NUM), '^[0-9]+$') or ADDRDTLS_MOBILE_NUM is null)
and LENGTH (ADDRDTLS_MOBILE_NUM) < 11
and CLIENTS_ADDR_INV_NUM=ADDRDTLS_INV_NUM
UNION ALL
SELECT 'TOTAL_REGI_CLIENTS',COUNT (DISTINCT CLIENT_NUM)  
 FROM MOBILEREG
WHERE ACTIVE = '0'
UNION ALL
SELECT 'VALID_MOBILE',COUNT (ADDRDTLS_MOBILE_NUM)  
 FROM (SELECT (ADDRDTLS_MOBILE_NUM)
           FROM addrdtls,clients
        WHERE     ADDRDTLS_MOBILE_NUM IS NOT NULL
              AND REGEXP_LIKE (TRIM (ADDRDTLS_MOBILE_NUM), '^[[:digit:]]+$')
              and   CLIENTS_ADDR_INV_NUM=ADDRDTLS_INV_NUM)
WHERE LENGTH (ADDRDTLS_MOBILE_NUM) = 11
UNION ALL
SELECT 'VALID_MOB_NOT_REGI',COUNT (CLIENTS_CODE) 
 FROM (SELECT CLIENTS_CODE, (ADDRDTLS_MOBILE_NUM)
          FROM addrdtls,clients
        WHERE     ADDRDTLS_MOBILE_NUM IS NOT NULL
              AND REGEXP_LIKE (TRIM (ADDRDTLS_MOBILE_NUM), '^[[:digit:]]+$'))
WHERE     LENGTH (ADDRDTLS_MOBILE_NUM) = 11
      AND CLIENTS_CODE NOT IN (SELECT CLIENT_NUM
                                   FROM MOBILEREG
                                  WHERE ACTIVE = '0');
                                  
                                  
                                  
    /* Formatted on 20/12/2020 12:37:16 PM (QP5 v5.227.12220.39754) */
BEGIN
   FOR IDX IN (SELECT * FROM MIG_DETAIL)
   LOOP
      INSERT INTO VALID_MOBILE
         SELECT DISTINCT
                CLIENTS_HOME_BRN_CODE,
                CLIENTS_CODE,
                CLIENTS_NAME,
                COALESCE (TRIM (INDCLIENT_TEL_GSM),
                          TRIM (ADDRDTLS_MOBILE_NUM),
                          TRIM (ADDRDTLS_MOBILE_NUM))
                   MOBILE_NO,
                INDCLIENT_TEL_GSM,
                ADDRDTLS_MOBILE_NUM
           FROM ADDRDTLS,
                CLIENTS,
                INDCLIENTS,
                ACNTS
          WHERE     (   REGEXP_LIKE (TRIM (ADDRDTLS_MOBILE_NUM),
                                     '^[[:digit:]]+$')
                     OR REGEXP_LIKE (TRIM (INDCLIENT_TEL_GSM),
                                     '^[[:digit:]]+$'))
                AND CLIENTS_ADDR_INV_NUM = ADDRDTLS_INV_NUM
                AND (   LENGTH (ADDRDTLS_MOBILE_NUM) = 11
                     OR LENGTH (INDCLIENT_TEL_GSM) = 11)
                AND ACNTS_BRN_CODE = IDX.BRANCH_CODE
                AND CLIENTS_CODE = INDCLIENT_CODE
                AND (   TRIM (ADDRDTLS_MOBILE_NUM) IS NOT NULL
                     OR TRIM (INDCLIENT_TEL_GSM) IS NOT NULL)
                AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                AND ACNTS_CLIENT_NUM = INDCLIENT_CODE
                AND ACNTS_ENTITY_NUM = 1
                AND TO_CHAR (CLIENTS_ENTD_ON, 'DD-MM-RRRR') <= '30-NOV-2020'
                AND ACNTS_CLOSURE_DATE IS NULL
                AND CLIENTS_CODE NOT IN
                       (SELECT CLIENTS_CODE FROM VALID_CLIENTS);

      COMMIT;
   END LOOP;
END;