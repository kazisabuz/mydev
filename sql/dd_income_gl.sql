/* Formatted on 10/13/2021 1:02:01 PM (QP5 v5.149.1003.31008) */
SELECT                                                       /*+PARALELL (8)*/
      TRAN_BRN_CODE,
       (SELECT mbrn_name
          FROM mbrn
         WHERE mbrn_code = TRAN_BRN_CODE)
          mbrn_name,
       TRAN_DATE_OF_TRAN,
       TRAN_BATCH_NUMBER,
       TRAN_GLACC_CODE,
       TRAN_DB_CR_FLG,
       TRAN_AMOUNT,
       TRAN_ENTD_BY,
       TRAN_AUTH_BY
  FROM tran2020
 WHERE (TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER) IN
          (SELECT                                            /*+PARALELL (8)*/
                 TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER
             FROM TRAN2020 T
            WHERE (TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER) IN
                     (SELECT                                 /*+PARALELL (8)*/
                            TRAN_BRN_CODE,
                             TRAN_DATE_OF_TRAN,
                             TRAN_BATCH_NUMBER
                        FROM TRAN2020
                       WHERE     TRAN_ENTITY_NUM = 1
                             AND TRAN_DB_CR_FLG = 'D'
                             AND TRAN_AMOUNT <> 0
                             AND TRAN_GLACC_CODE IN
                                    ('134101101', '134101102'))
                  AND TRAN_ENTITY_NUM = 1
                  AND TRAN_DB_CR_FLG = 'C'
                  AND TRAN_GLACC_CODE NOT IN ('300122101', '300122107')
                  AND TRAN_ENTITY_NUM = 1
                  AND TRAN_AMOUNT <> 0)