select TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER, TRAN_ACING_BRN_CODE, facno(1, TRAN_INTERNAL_ACNUM) account_number,TRAN_GLACC_CODE, TRAN_DB_CR_FLG, TRAN_AMOUNT 
from tran2014
WHERE  (TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER ) in 
        (
       SELECT  TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER  
       FROM TRAN2014
       WHERE  TRAN_ENTITY_NUM = 1
            AND TRAN_BRN_CODE = 16196
            AND (TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER) IN (SELECT
                          TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER
                FROM TRAN2014
               WHERE  TRAN_ENTITY_NUM = 1
                     AND TRAN_BRN_CODE = 16196
                     AND TRAN_GLACC_CODE IN
                            ('140146135',
                             '140146110',
                             '140146107',
                             '225125101',
                             '140146121',
                             '140146123',
                             '140146133',
                             '140146101',
                             '300122201')
                     AND TRAN_AUTH_ON IS NOT NULL
                     AND TRAN_AUTH_by IS NOT NULL 
                     AND TRAN_DB_CR_FLG='D'  
                     --AND TRAN_BATCH_NUMBER=112
                     )
              AND TRAN_INTERNAL_ACNUM <> 0
              AND TRAN_AMOUNT <> 0
              )
union all 
select TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER, TRAN_ACING_BRN_CODE, facno(1, TRAN_INTERNAL_ACNUM) account_number,TRAN_GLACC_CODE, TRAN_DB_CR_FLG, TRAN_AMOUNT 
from tran2015
WHERE  (TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER ) in 
        (
       SELECT  TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER  
       FROM TRAN2015
       WHERE  TRAN_ENTITY_NUM = 1
            AND TRAN_BRN_CODE = 16196
            AND (TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER) IN (SELECT
                          TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER
                FROM TRAN2015
               WHERE  TRAN_ENTITY_NUM = 1
                     AND TRAN_BRN_CODE = 16196
                     AND TRAN_GLACC_CODE IN
                            ('140146135',
                             '140146110',
                             '140146107',
                             '225125101',
                             '140146121',
                             '140146123',
                             '140146133',
                             '140146101',
                             '300122201')
                     AND TRAN_AUTH_ON IS NOT NULL
                     AND TRAN_AUTH_by IS NOT NULL 
                     AND TRAN_DB_CR_FLG='D'  
                     --AND TRAN_BATCH_NUMBER=112
                     )
              AND TRAN_INTERNAL_ACNUM <> 0
              AND TRAN_AMOUNT <> 0
              )
              UNION ALL
 select TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER, TRAN_ACING_BRN_CODE, facno(1, TRAN_INTERNAL_ACNUM) account_number,TRAN_GLACC_CODE, TRAN_DB_CR_FLG, TRAN_AMOUNT 
from tran2016
WHERE  (TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER ) in 
        (
       SELECT  TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER  
       FROM TRAN2016
       WHERE  TRAN_ENTITY_NUM = 1
            AND TRAN_BRN_CODE = 16196
            AND (TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER) IN (SELECT
                          TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER
                FROM TRAN2016
               WHERE  TRAN_ENTITY_NUM = 1
                     AND TRAN_BRN_CODE = 16196
                     AND TRAN_GLACC_CODE IN
                            ('140146135',
                             '140146110',
                             '140146107',
                             '225125101',
                             '140146121',
                             '140146123',
                             '140146133',
                             '140146101',
                             '300122201')
                     AND TRAN_AUTH_ON IS NOT NULL
                     AND TRAN_AUTH_by IS NOT NULL 
                     AND TRAN_DB_CR_FLG='D'  
                     --AND TRAN_BATCH_NUMBER=112
                     )
              AND TRAN_INTERNAL_ACNUM <> 0
              AND TRAN_AMOUNT <> 0
              )
              UNION ALL
select TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER, TRAN_ACING_BRN_CODE, facno(1, TRAN_INTERNAL_ACNUM) account_number,TRAN_GLACC_CODE, TRAN_DB_CR_FLG, TRAN_AMOUNT 
from tran2017
WHERE  (TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER ) in 
        (
       SELECT  TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER  
       FROM TRAN2017
       WHERE  TRAN_ENTITY_NUM = 1
            AND TRAN_BRN_CODE = 16196
            AND (TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER) IN (SELECT
                          TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER
                FROM TRAN2017
               WHERE  TRAN_ENTITY_NUM = 1
                     AND TRAN_BRN_CODE = 16196
                     AND TRAN_GLACC_CODE IN
                            ('140146135',
                             '140146110',
                             '140146107',
                             '225125101',
                             '140146121',
                             '140146123',
                             '140146133',
                             '140146101',
                             '300122201')
                     AND TRAN_AUTH_ON IS NOT NULL
                     AND TRAN_AUTH_by IS NOT NULL 
                     AND TRAN_DB_CR_FLG='D'  
                     --AND TRAN_BATCH_NUMBER=112
                     )
              AND TRAN_INTERNAL_ACNUM <> 0
              AND TRAN_AMOUNT <> 0
              )
              UNION ALL
select TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER, TRAN_ACING_BRN_CODE, facno(1, TRAN_INTERNAL_ACNUM) account_number,TRAN_GLACC_CODE, TRAN_DB_CR_FLG, TRAN_AMOUNT 
from tran2018
WHERE  (TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER ) in 
        (
       SELECT  TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER  
       FROM TRAN2018
       WHERE  TRAN_ENTITY_NUM = 1
            AND TRAN_BRN_CODE = 16196
            AND (TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER) IN (SELECT
                          TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER
                FROM TRAN2018
               WHERE  TRAN_ENTITY_NUM = 1
                     AND TRAN_BRN_CODE = 16196
                     AND TRAN_GLACC_CODE IN
                            ('140146135',
                             '140146110',
                             '140146107',
                             '225125101',
                             '140146121',
                             '140146123',
                             '140146133',
                             '140146101',
                             '300122201')
                     AND TRAN_AUTH_ON IS NOT NULL
                     AND TRAN_AUTH_by IS NOT NULL 
                     AND TRAN_DB_CR_FLG='D'  
                     --AND TRAN_BATCH_NUMBER=112
                     )
              AND TRAN_INTERNAL_ACNUM <> 0
              AND TRAN_AMOUNT <> 0
              )
ORDER BY  TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER;



---------------------------------------------------------
  SELECT DEBIT_TRAN.TRAN_BRN_CODE,
       DEBIT_TRAN.TRAN_DATE_OF_TRAN,
       DEBIT_TRAN.TRAN_BATCH_NUMBER,
       FACNO (1, DEBIT_TRAN.TRAN_INTERNAL_ACNUM) DEBIT_ACCOUNT,
       FACNO (1, CREDIT_TRAN.TRAN_INTERNAL_ACNUM) CREDIT_ACCOUNT,DEBIT_TRAN.TRAN_AMOUNT
  FROM (SELECT TRAN_BRN_CODE,
               TRAN_DATE_OF_TRAN,
               TRAN_BATCH_NUMBER,
               TRAN_INTERNAL_ACNUM,TRAN_AMOUNT
          FROM TRAN2014, ACNTS
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_ACING_BRN_CODE <> 16196
               AND ACNTS_ENTITY_NUM = 1
               AND ACNTS_BRN_CODE = TRAN_ACING_BRN_CODE
               AND ACNTS_AC_TYPE = 'SBST'
               AND TRAN_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND TRAN_DB_CR_FLG = 'D') DEBIT_TRAN,
       (SELECT TRAN_BRN_CODE,
               TRAN_DATE_OF_TRAN,
               TRAN_BATCH_NUMBER,
               TRAN_INTERNAL_ACNUM
          FROM TRAN2014, ACNTS
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_ACING_BRN_CODE = 16196
               AND ACNTS_ENTITY_NUM = 1
               AND ACNTS_BRN_CODE = TRAN_ACING_BRN_CODE
               AND ACNTS_AC_TYPE = 'SBST'
               AND TRAN_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND TRAN_DB_CR_FLG = 'C') CREDIT_TRAN
 WHERE     DEBIT_TRAN.TRAN_BRN_CODE = CREDIT_TRAN.TRAN_BRN_CODE
       AND DEBIT_TRAN.TRAN_DATE_OF_TRAN = CREDIT_TRAN.TRAN_DATE_OF_TRAN
       AND DEBIT_TRAN.TRAN_BATCH_NUMBER = CREDIT_TRAN.TRAN_BATCH_NUMBER