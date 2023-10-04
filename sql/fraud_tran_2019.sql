SELECT TRAN_BRN_CODE,
       TRAN_DATE_OF_TRAN,
       TRAN_BATCH_NUMBER,
       TRAN_ACING_BRN_CODE,
       FACNO (1, TRAN_INTERNAL_ACNUM) ACCOUNT_NUMBER,
       TRAN_GLACC_CODE,
       TRAN_DB_CR_FLG,
       TRAN_AMOUNT
  FROM TRAN2018
 WHERE (TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER) IN
          (SELECT TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER
             FROM TRAN2018
            WHERE     TRAN_ENTITY_NUM = 1
                  --AND TRAN_BRN_CODE = 16196
                  AND (TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER) IN
                         (SELECT TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER
                            FROM TRAN2018, ACNTS
                           WHERE     ACNTS_ENTITY_NUM = 1
                                 AND ACNTS_INTERNAL_ACNUM =
                                        TRAN_INTERNAL_ACNUM
                                 AND ACNTS_PROD_CODE = 1000
                                 AND ACNTS_AC_TYPE = 'SBSS'
                                 -- AND TRAN_BRN_CODE = 1115
                                 AND TRAN_INTERNAL_ACNUM <> 0
                                 AND TRAN_AUTH_ON IS NOT NULL
                                 AND TRAN_AUTH_BY IS NOT NULL
                                 AND TRAN_DB_CR_FLG = 'D' --AND TRAN_BATCH_NUMBER=112
                                                         )
                  AND TRAN_INTERNAL_ACNUM <> 0
                   /*
                  AND TRAN_INTERNAL_ACNUM IN
                         (SELECT ACNTS_INTERNAL_ACNUM
                            FROM ACNTS
                           WHERE     ACNTS_PROD_CODE = 1000
                                 AND ACNTS_ENTITY_NUM = 1
                                 AND ACNTS_AC_TYPE = 'SBST')*/
                  AND TRAN_AMOUNT <> 0)
                  union all
                  SELECT TRAN_BRN_CODE,
       TRAN_DATE_OF_TRAN,
       TRAN_BATCH_NUMBER,
       TRAN_ACING_BRN_CODE,
       FACNO (1, TRAN_INTERNAL_ACNUM) ACCOUNT_NUMBER,
       TRAN_GLACC_CODE,
       TRAN_DB_CR_FLG,
       TRAN_AMOUNT
  FROM tran2017
 WHERE (TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER) IN
          (SELECT TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER
             FROM tran2017
            WHERE     TRAN_ENTITY_NUM = 1
                  --AND TRAN_BRN_CODE = 16196
                  AND (TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER) IN
                         (SELECT TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER
                            FROM tran2017, ACNTS
                           WHERE     ACNTS_ENTITY_NUM = 1
                                 AND ACNTS_INTERNAL_ACNUM =
                                        TRAN_INTERNAL_ACNUM
                                 AND ACNTS_PROD_CODE = 1000
                                 AND ACNTS_AC_TYPE = 'SBSS'
                                 -- AND TRAN_BRN_CODE = 1115
                                 AND TRAN_INTERNAL_ACNUM <> 0
                                 AND TRAN_AUTH_ON IS NOT NULL
                                 AND TRAN_AUTH_BY IS NOT NULL
                                 AND TRAN_DB_CR_FLG = 'D' --AND TRAN_BATCH_NUMBER=112
                                                         )
                  AND TRAN_INTERNAL_ACNUM <> 0
                   /*
                  AND TRAN_INTERNAL_ACNUM IN
                         (SELECT ACNTS_INTERNAL_ACNUM
                            FROM ACNTS
                           WHERE     ACNTS_PROD_CODE = 1000
                                 AND ACNTS_ENTITY_NUM = 1
                                 AND ACNTS_AC_TYPE = 'SBST')*/
                  AND TRAN_AMOUNT <> 0)
                  union all
                  SELECT TRAN_BRN_CODE,
       TRAN_DATE_OF_TRAN,
       TRAN_BATCH_NUMBER,
       TRAN_ACING_BRN_CODE,
       FACNO (1, TRAN_INTERNAL_ACNUM) ACCOUNT_NUMBER,
       TRAN_GLACC_CODE,
       TRAN_DB_CR_FLG,
       TRAN_AMOUNT
  FROM tran2016
 WHERE (TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER) IN
          (SELECT TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER
             FROM tran2016
            WHERE     TRAN_ENTITY_NUM = 1
                  --AND TRAN_BRN_CODE = 16196
                  AND (TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER) IN
                         (SELECT TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER
                            FROM tran2016, ACNTS
                           WHERE     ACNTS_ENTITY_NUM = 1
                                 AND ACNTS_INTERNAL_ACNUM =
                                        TRAN_INTERNAL_ACNUM
                                 AND ACNTS_PROD_CODE = 1000
                                 AND ACNTS_AC_TYPE = 'SBSS'
                                 -- AND TRAN_BRN_CODE = 1115
                                 AND TRAN_INTERNAL_ACNUM <> 0
                                 AND TRAN_AUTH_ON IS NOT NULL
                                 AND TRAN_AUTH_BY IS NOT NULL
                                 AND TRAN_DB_CR_FLG = 'D' --AND TRAN_BATCH_NUMBER=112
                                                         )
                  AND TRAN_INTERNAL_ACNUM <> 0
                   /*
                  AND TRAN_INTERNAL_ACNUM IN
                         (SELECT ACNTS_INTERNAL_ACNUM
                            FROM ACNTS
                           WHERE     ACNTS_PROD_CODE = 1000
                                 AND ACNTS_ENTITY_NUM = 1
                                 AND ACNTS_AC_TYPE = 'SBST')*/
                  AND TRAN_AMOUNT <> 0)
                  union all
                  SELECT TRAN_BRN_CODE,
       TRAN_DATE_OF_TRAN,
       TRAN_BATCH_NUMBER,
       TRAN_ACING_BRN_CODE,
       FACNO (1, TRAN_INTERNAL_ACNUM) ACCOUNT_NUMBER,
       TRAN_GLACC_CODE,
       TRAN_DB_CR_FLG,
       TRAN_AMOUNT
  FROM tran2015
 WHERE (TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER) IN
          (SELECT TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER
             FROM tran2015
            WHERE     TRAN_ENTITY_NUM = 1
                  --AND TRAN_BRN_CODE = 16196
                  AND (TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER) IN
                         (SELECT TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER
                            FROM tran2015, ACNTS
                           WHERE     ACNTS_ENTITY_NUM = 1
                                 AND ACNTS_INTERNAL_ACNUM =
                                        TRAN_INTERNAL_ACNUM
                                 AND ACNTS_PROD_CODE = 1000
                                 AND ACNTS_AC_TYPE = 'SBSS'
                                 -- AND TRAN_BRN_CODE = 1115
                                 AND TRAN_INTERNAL_ACNUM <> 0
                                 AND TRAN_AUTH_ON IS NOT NULL
                                 AND TRAN_AUTH_BY IS NOT NULL
                                 AND TRAN_DB_CR_FLG = 'D' --AND TRAN_BATCH_NUMBER=112
                                                         )
                  AND TRAN_INTERNAL_ACNUM <> 0
                   /*
                  AND TRAN_INTERNAL_ACNUM IN
                         (SELECT ACNTS_INTERNAL_ACNUM
                            FROM ACNTS
                           WHERE     ACNTS_PROD_CODE = 1000
                                 AND ACNTS_ENTITY_NUM = 1
                                 AND ACNTS_AC_TYPE = 'SBST')*/
                  AND TRAN_AMOUNT <> 0)
                  union all
                  SELECT TRAN_BRN_CODE,
       TRAN_DATE_OF_TRAN,
       TRAN_BATCH_NUMBER,
       TRAN_ACING_BRN_CODE,
       FACNO (1, TRAN_INTERNAL_ACNUM) ACCOUNT_NUMBER,
       TRAN_GLACC_CODE,
       TRAN_DB_CR_FLG,
       TRAN_AMOUNT
  FROM tran2014
 WHERE (TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER) IN
          (SELECT TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER
             FROM tran2014
            WHERE     TRAN_ENTITY_NUM = 1
                  --AND TRAN_BRN_CODE = 16196
                  AND (TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER) IN
                         (SELECT TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER
                            FROM tran2014, ACNTS
                           WHERE     ACNTS_ENTITY_NUM = 1
                                 AND ACNTS_INTERNAL_ACNUM =
                                        TRAN_INTERNAL_ACNUM
                                 AND ACNTS_PROD_CODE = 1000
                                 AND ACNTS_AC_TYPE = 'SBSS'
                                 -- AND TRAN_BRN_CODE = 1115
                                 AND TRAN_INTERNAL_ACNUM <> 0
                                 AND TRAN_AUTH_ON IS NOT NULL
                                 AND TRAN_AUTH_BY IS NOT NULL
                                 AND TRAN_DB_CR_FLG = 'D' --AND TRAN_BATCH_NUMBER=112
                                                         )
                  AND TRAN_INTERNAL_ACNUM <> 0
                   /*
                  AND TRAN_INTERNAL_ACNUM IN
                         (SELECT ACNTS_INTERNAL_ACNUM
                            FROM ACNTS
                           WHERE     ACNTS_PROD_CODE = 1000
                                 AND ACNTS_ENTITY_NUM = 1
                                 AND ACNTS_AC_TYPE = 'SBST')*/
                  AND TRAN_AMOUNT <> 0)