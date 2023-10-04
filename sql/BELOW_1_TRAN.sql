  SELECT TRAN_BRN_CODE,
         TRAN_DATE_OF_TRAN,
         TRAN_BATCH_NUMBER,
         TRAN_PROD_CODE,
         TRAN_INTERNAL_ACNUM,
         TRAN_GLACC_CODE,
         TRAN_AMOUNT,
         TRAN_ENTD_BY,
         COUNT (TRAN_ENTD_BY)
    FROM TRAN2014
   WHERE     TRAN_AMOUNT = 1
         AND TRAN_ENTD_BY NOT IN ( 'INTELECT','MIG')
         AND TRAN_ENTITY_NUM = '1'
         AND TRAN_AUTH_BY IS NOT  NULL
         AND  TRAN_AUTH_ON IS NOT NULL
GROUP BY TRAN_BRN_CODE,
         TRAN_DATE_OF_TRAN,
         TRAN_BATCH_NUMBER,
         TRAN_PROD_CODE,
         TRAN_INTERNAL_ACNUM,
         TRAN_GLACC_CODE,
         TRAN_AMOUNT,
         TRAN_ENTD_BY
  HAVING COUNT (TRAN_ENTD_BY) >= 10
  UNION ALL
    SELECT TRAN_BRN_CODE,
         TRAN_DATE_OF_TRAN,
         TRAN_BATCH_NUMBER,
         TRAN_PROD_CODE,
         TRAN_INTERNAL_ACNUM,
         TRAN_GLACC_CODE,
         TRAN_AMOUNT,
         TRAN_ENTD_BY,
         COUNT (TRAN_ENTD_BY)
    FROM TRAN2015
   WHERE     TRAN_AMOUNT = 1
         AND TRAN_ENTD_BY  NOT IN ( 'INTELECT','MIG')
         AND TRAN_ENTITY_NUM = '1'
         AND TRAN_AUTH_BY IS NOT  NULL
         AND  TRAN_AUTH_ON IS NOT NULL
  UNION ALL
    SELECT TRAN_BRN_CODE,
         TRAN_DATE_OF_TRAN,
         TRAN_BATCH_NUMBER,
         TRAN_PROD_CODE,
         TRAN_INTERNAL_ACNUM,
         TRAN_GLACC_CODE,
         TRAN_AMOUNT,
         TRAN_ENTD_BY,
         COUNT (TRAN_ENTD_BY)
    FROM TRAN2016
   WHERE     TRAN_AMOUNT = 1
         AND TRAN_ENTD_BY NOT IN ( 'INTELECT','MIG')
         AND TRAN_ENTITY_NUM = '1'
         AND TRAN_AUTH_BY IS NOT  NULL
         AND  TRAN_AUTH_ON IS NOT NULL
GROUP BY TRAN_BRN_CODE,
         TRAN_DATE_OF_TRAN,
         TRAN_BATCH_NUMBER,
         TRAN_PROD_CODE,
         TRAN_INTERNAL_ACNUM,
         TRAN_GLACC_CODE,
         TRAN_AMOUNT,
         TRAN_ENTD_BY 
         
         
-----
/* Formatted on 20/01/2021 1:11:11 PM (QP5 v5.227.12220.39754) */
SELECT TRAN_BRN_CODE,
       TRAN_DATE_OF_TRAN,
       TRAN_BATCH_NUMBER,
       TRAN_PROD_CODE,
       facno (1, TRAN_INTERNAL_ACNUM) account_no,
       TRAN_GLACC_CODE,TRAN_DB_CR_FLG,
       TRAN_AMOUNT,
       TRAN_ENTD_BY,
       TRAN_AUTH_BY
  FROM TRAN2014
 WHERE     (   TRAN_ENTD_BY IN ('47068', '46077')
            OR TRAN_AUTH_BY IN ('47068', '46077'))
       AND TRAN_ENTITY_NUM = '1'
       AND TRAN_AUTH_BY IS NOT NULL
       AND TRAN_AUTH_ON IS NOT NULL
       AND TRAN_INTERNAL_ACNUM IN
              (SELECT IACLINK_INTERNAL_ACNUM
                 FROM acc4, iaclink
                WHERE     acc_no = IACLINK_ACTUAL_ACNUM
                      AND IACLINK_ENTITY_NUM = 1)
UNION ALL
SELECT TRAN_BRN_CODE,
       TRAN_DATE_OF_TRAN,
       TRAN_BATCH_NUMBER,
       TRAN_PROD_CODE,
       facno (1, TRAN_INTERNAL_ACNUM) account_no,
       TRAN_GLACC_CODE,TRAN_DB_CR_FLG,
       TRAN_AMOUNT,
       TRAN_ENTD_BY,
       TRAN_AUTH_BY
  FROM TRAN2015
 WHERE     (   TRAN_ENTD_BY IN ('47068', '46077')
            OR TRAN_AUTH_BY IN ('47068', '46077'))
       AND TRAN_ENTITY_NUM = '1'
       AND TRAN_AUTH_BY IS NOT NULL
       AND TRAN_AUTH_ON IS NOT NULL
       AND TRAN_INTERNAL_ACNUM IN
              (SELECT IACLINK_INTERNAL_ACNUM
                 FROM acc4, iaclink
                WHERE     acc_no = IACLINK_ACTUAL_ACNUM
                      AND IACLINK_ENTITY_NUM = 1)
UNION ALL
SELECT TRAN_BRN_CODE,
       TRAN_DATE_OF_TRAN,
       TRAN_BATCH_NUMBER,
       TRAN_PROD_CODE,
       facno (1, TRAN_INTERNAL_ACNUM) account_no,
       TRAN_GLACC_CODE,TRAN_DB_CR_FLG,
       TRAN_AMOUNT,
       TRAN_ENTD_BY,
       TRAN_AUTH_BY
  FROM TRAN2016
 WHERE    (   TRAN_ENTD_BY IN ('47068', '46077')
            OR TRAN_AUTH_BY IN ('47068', '46077'))
       AND TRAN_ENTITY_NUM = '1'
       AND TRAN_AUTH_BY IS NOT NULL
       AND TRAN_AUTH_ON IS NOT NULL
       AND TRAN_INTERNAL_ACNUM IN
              (SELECT IACLINK_INTERNAL_ACNUM
                 FROM acc4, iaclink
                WHERE     acc_no = IACLINK_ACTUAL_ACNUM
                      AND IACLINK_ENTITY_NUM = 1)
UNION ALL
SELECT TRAN_BRN_CODE,
       TRAN_DATE_OF_TRAN,
       TRAN_BATCH_NUMBER,
       TRAN_PROD_CODE,
       facno (1, TRAN_INTERNAL_ACNUM) account_no,
       TRAN_GLACC_CODE,TRAN_DB_CR_FLG,
       TRAN_AMOUNT,
       TRAN_ENTD_BY,
       TRAN_AUTH_BY
  FROM TRAN2017
 WHERE    (   TRAN_ENTD_BY IN ('47068', '46077')
            OR TRAN_AUTH_BY IN ('47068', '46077'))
       AND TRAN_ENTITY_NUM = '1'
       AND TRAN_AUTH_BY IS NOT NULL
       AND TRAN_AUTH_ON IS NOT NULL
       AND TRAN_INTERNAL_ACNUM IN
              (SELECT IACLINK_INTERNAL_ACNUM
                 FROM acc4, iaclink
                WHERE     acc_no = IACLINK_ACTUAL_ACNUM
                      AND IACLINK_ENTITY_NUM = 1)
UNION ALL
SELECT TRAN_BRN_CODE,
       TRAN_DATE_OF_TRAN,
       TRAN_BATCH_NUMBER,
       TRAN_PROD_CODE,
       facno (1, TRAN_INTERNAL_ACNUM) account_no,
       TRAN_GLACC_CODE,TRAN_DB_CR_FLG,
       TRAN_AMOUNT,
       TRAN_ENTD_BY,
       TRAN_AUTH_BY
  FROM TRAN2018
 WHERE     (   TRAN_ENTD_BY IN ('47068', '46077')
            OR TRAN_AUTH_BY IN ('47068', '46077'))
       AND TRAN_ENTITY_NUM = '1'
       AND TRAN_AUTH_BY IS NOT NULL
       AND TRAN_AUTH_ON IS NOT NULL
       AND TRAN_INTERNAL_ACNUM IN
              (SELECT IACLINK_INTERNAL_ACNUM
                 FROM acc4, iaclink
                WHERE     acc_no = IACLINK_ACTUAL_ACNUM
                      AND IACLINK_ENTITY_NUM = 1)
UNION ALL
SELECT TRAN_BRN_CODE,
       TRAN_DATE_OF_TRAN,
       TRAN_BATCH_NUMBER,
       TRAN_PROD_CODE,
       facno (1, TRAN_INTERNAL_ACNUM) account_no,
       TRAN_GLACC_CODE,TRAN_DB_CR_FLG,
       TRAN_AMOUNT,
       TRAN_ENTD_BY,
       TRAN_AUTH_BY
  FROM TRAN2019
 WHERE     (   TRAN_ENTD_BY IN ('47068', '46077')
            OR TRAN_AUTH_BY IN ('47068', '46077'))
       AND TRAN_ENTITY_NUM = '1'
       AND TRAN_AUTH_BY IS NOT NULL
       AND TRAN_AUTH_ON IS NOT NULL
       AND TRAN_INTERNAL_ACNUM IN
              (SELECT IACLINK_INTERNAL_ACNUM
                 FROM acc4, iaclink
                WHERE     acc_no = IACLINK_ACTUAL_ACNUM
                      AND IACLINK_ENTITY_NUM = 1)
UNION ALL
SELECT TRAN_BRN_CODE,
       TRAN_DATE_OF_TRAN,
       TRAN_BATCH_NUMBER,
       TRAN_PROD_CODE,
       facno (1, TRAN_INTERNAL_ACNUM) account_no,
       TRAN_GLACC_CODE,TRAN_DB_CR_FLG,
       TRAN_AMOUNT,
       TRAN_ENTD_BY,
       TRAN_AUTH_BY
  FROM TRAN2020
 WHERE    (   TRAN_ENTD_BY IN ('47068', '46077')
            OR TRAN_AUTH_BY IN ('47068', '46077'))
       AND TRAN_ENTITY_NUM = '1'
       AND TRAN_AUTH_BY IS NOT NULL
       AND TRAN_AUTH_ON IS NOT NULL
       AND TRAN_INTERNAL_ACNUM IN
              (SELECT IACLINK_INTERNAL_ACNUM
                 FROM acc4, iaclink
                WHERE     acc_no = IACLINK_ACTUAL_ACNUM
                      AND IACLINK_ENTITY_NUM = 1)
UNION ALL
SELECT TRAN_BRN_CODE,
       TRAN_DATE_OF_TRAN,
       TRAN_BATCH_NUMBER,
       TRAN_PROD_CODE,
       facno (1, TRAN_INTERNAL_ACNUM) account_no,
       TRAN_GLACC_CODE,TRAN_DB_CR_FLG,
       TRAN_AMOUNT,
       TRAN_ENTD_BY,
       TRAN_AUTH_BY
  FROM TRAN2021
 WHERE    (   TRAN_ENTD_BY IN ('47068', '46077')
            OR TRAN_AUTH_BY IN ('47068', '46077'))
       AND TRAN_ENTITY_NUM = '1'
       AND TRAN_AUTH_BY IS NOT NULL
       AND TRAN_AUTH_ON IS NOT NULL
       AND TRAN_INTERNAL_ACNUM IN
              (SELECT IACLINK_INTERNAL_ACNUM
                 FROM acc4, iaclink
                WHERE     acc_no = IACLINK_ACTUAL_ACNUM
                      AND IACLINK_ENTITY_NUM = 1)