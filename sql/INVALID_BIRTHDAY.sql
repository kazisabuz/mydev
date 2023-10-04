/* Formatted on 6/9/2022 4:05:47 PM (QP5 v5.252.13127.32867) */
SELECT ACNTS_INTERNAL_ACNUM,ACNTS_OPENING_DATE,INDCLIENT_CODE,
               ACNTS_PROD_CODE,
               ACNTS_AC_TYPE,
               ACNTS_NONSYS_LAST_DATE,
               INDCLIENT_BIRTH_DATE,last_tran_month,(BIRTH_MONTH-216) LESS_MONTH,ADD_MONTHS(INDCLIENT_BIRTH_DATE,(BIRTH_MONTH-216))
  FROM (SELECT ACNTS_INTERNAL_ACNUM,INDCLIENT_CODE,ACNTS_OPENING_DATE,
               ACNTS_PROD_CODE,
               ACNTS_AC_TYPE,
               ACNTS_NONSYS_LAST_DATE,
               INDCLIENT_BIRTH_DATE,
               TRUNC (
                  MONTHS_BETWEEN (TO_DATE ('09-jun-2022'),
                                  INDCLIENT_BIRTH_DATE))
                  BIRTH_MONTH,TRUNC (
                  MONTHS_BETWEEN (to_date ('09-jun-2022'), ACNTS_NONSYS_LAST_DATE))
                  last_tran_month
          FROM CLIENTS, INDCLIENTS, ACNTS
         WHERE     CLIENTS_CODE = INDCLIENT_CODE
               AND ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE
               AND ACNTS_INTERNAL_ACNUM=15217500041836
              -- AND ACNTS_AC_TYPE not in ('SBGOV', 'SBS','SBOFF','CAGOV','SNDGOV')
               AND INDCLIENT_BIRTH_DATE IS NOT  NULL
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_BRN_CODE = 52175)
 WHERE BIRTH_MONTH < 216
 AND last_tran_month>=6;