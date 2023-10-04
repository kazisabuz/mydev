/* Formatted on 6/30/2019 2:08:50 PM (QP5 v5.227.12220.39754) */
SELECT 140146122,
       TRAN_BRN_CODE,
       MBRN_NAME,
       DEBIT_GL,
       TRAN_AMOUNT
  FROM (  SELECT 140146107,
                 TRAN_BRN_CODE,
                 TRAN_GLACC_CODE DEBIT_GL,
                 SUM (TRAN_AMOUNT) TRAN_AMOUNT
            FROM TRAN2019
           WHERE     TRAN_ENTITY_NUM = 1
                 AND TRAN_DATE_OF_TRAN = '27-june-2019'
                 AND TRAN_DB_CR_FLG = 'D'
                 AND TRAN_GLACC_CODE IN
                        ('140146122',
                         '140146122',
                         '140146281',
                         '140146283',
                         '140146285',
                         '140146287',
                         '140146289',
                         '140146291',
                         '140146293',
                         '140146295',
                         '140146297',
                         '140146299',
                         '140146301',
                         '140146303',
                         '140146305',
                         '140146307',
                         '140146309',
                         '140146311',
                         '140146313',
                         '140146315',
                         '140146317',
                         '140146319',
                         '140146321',
                         '140146323',
                         '140146325',
                         '140146327',
                         '140146329')
                 AND (TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER) IN
                        (SELECT TRAN_BRN_CODE,
                                TRAN_DATE_OF_TRAN,
                                TRAN_BATCH_NUMBER
                           FROM TRAN2019
                          WHERE     TRAN_ACING_BRN_CODE = 18
                                AND TRAN_DB_CR_FLG = 'C'
                                AND TRAN_GLACC_CODE IN ('140146107')
                                AND TRAN_ENTITY_NUM = 1
                                AND TRAN_DATE_OF_TRAN = '27-june-2019')
        GROUP BY TRAN_BRN_CODE, TRAN_GLACC_CODE) A,
       MBRN
 WHERE TRAN_BRN_CODE = MBRN_CODE
 
 ------------------------------------------------
 /* Formatted on 8/4/2019 5:33:45 PM (QP5 v5.227.12220.39754) */
BEGIN
   FOR IDX IN (SELECT CREDIT_GL
                 FROM CAD_GL
                WHERE CREDIT_GL IS NOT NULL)
   LOOP
      INSERT INTO CAD_DATA_GEN
         SELECT IDX.CREDIT_GL,
                TRAN_BRN_CODE,
                MBRN_NAME,
                DEBIT_GL,
                TRAN_AMOUNT
           FROM (  SELECT 140146107,
                          TRAN_BRN_CODE,
                          TRAN_GLACC_CODE DEBIT_GL,
                          SUM (TRAN_AMOUNT) TRAN_AMOUNT
                     FROM TRAN2019
                    WHERE     TRAN_ENTITY_NUM = 1
                          AND TRAN_DATE_OF_TRAN = '31-jul-2019'
                          AND TRAN_DB_CR_FLG = 'D'
                          AND TRAN_GLACC_CODE IN (SELECT DEBIT_GL FROM CAD_GL)
                          AND (TRAN_BRN_CODE,
                               TRAN_DATE_OF_TRAN,
                               TRAN_BATCH_NUMBER) IN
                                 (SELECT TRAN_BRN_CODE,
                                         TRAN_DATE_OF_TRAN,
                                         TRAN_BATCH_NUMBER
                                    FROM TRAN2019
                                   WHERE     TRAN_ACING_BRN_CODE = 18
                                         AND TRAN_DB_CR_FLG = 'C'
                                         AND TRAN_GLACC_CODE = IDX.CREDIT_GL
                                         AND TRAN_ENTITY_NUM = 1
                                         AND TRAN_DATE_OF_TRAN = '31-jul-2019')
                 GROUP BY TRAN_BRN_CODE, TRAN_GLACC_CODE) A,
                MBRN
          WHERE TRAN_BRN_CODE = MBRN_CODE;

      COMMIT;
   END LOOP;
END;