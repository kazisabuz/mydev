SELECT *
  FROM (SELECT GLBALH_BRN_CODE,
               GLBALH_BC_BAL,
               TRAN_ACING_BRN_CODE,
               NVL (TRAN_AMT, 0),
               GLBALH_BC_BAL + NVL (TRAN_AMT, 0) BAL_ON_11_OCT
          FROM (SELECT GLBALH_BRN_CODE, GLBALH_BC_BAL
                  FROM GLBALASONHIST
                 WHERE     GLBALH_ENTITY_NUM = 1
                       AND GLBALH_GLACC_CODE = '217101101'
                       AND GLBALH_ASON_DATE = :P_TRAN_DATE - 1) A
               FULL OUTER JOIN
               (  SELECT TRAN_ACING_BRN_CODE,
                         SUM (CREDIT_AMT),
                         SUM (DEBIT_AMT),
                         SUM (CREDIT_AMT) - SUM (DEBIT_AMT) TRAN_AMT
                    FROM (SELECT TRAN_ACING_BRN_CODE,
                                 TRAN_DB_CR_FLG,
                                 CASE
                                    WHEN TRAN_DB_CR_FLG = 'C' THEN TRAN_AMOUNT
                                    ELSE 0
                                 END
                                    CREDIT_AMT,
                                 CASE
                                    WHEN TRAN_DB_CR_FLG = 'D' THEN TRAN_AMOUNT
                                    ELSE 0
                                 END
                                    DEBIT_AMT
                            FROM TRAN2015
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_DATE_OF_TRAN = :P_TRAN_DATE
                                 AND TRAN_GLACC_CODE = '217101101'
                                 AND TRAN_AUTH_BY IS NOT NULL)
                GROUP BY TRAN_ACING_BRN_CODE) B
                  ON (A.GLBALH_BRN_CODE = B.TRAN_ACING_BRN_CODE)) AA FULL OUTER JOIN 
       (SELECT G.GLBALH_BRN_CODE, G.GLBALH_BC_BAL
          FROM GLBALASONHIST G
         WHERE     G.GLBALH_ENTITY_NUM = 1
               AND G.GLBALH_GLACC_CODE = '217101101'
               AND G.GLBALH_ASON_DATE = :P_TRAN_DATE) BB
                 ON (AA.GLBALH_BRN_CODE = BB.GLBALH_BRN_CODE)
                 WHERE AA.BAL_ON_11_OCT <> BB.GLBALH_BC_BAL ;


  SELECT T.TRAN_ENTITY_NUM,
         T.TRAN_BRN_CODE,
         T.TRAN_DATE_OF_TRAN,
         T.TRAN_BATCH_NUMBER,
         COUNT (DISTINCT  TRAN_ACING_BRN_CODE),
         TO_CHAR(wm_concat (DISTINCT  TRAN_ACING_BRN_CODE)),
         (SELECT SUM(TRAN_AMOUNT)
               FROM TRAN2018
              WHERE     TRAN_ENTITY_NUM = 1
                    AND TRAN_GLACC_CODE = '217101101'
                    AND TRAN_DATE_OF_TRAN = :P_TRAN_DATE
                    AND TRAN_BRN_CODE = T.TRAN_BRN_CODE 
                    AND TRAN_BATCH_NUMBER = T.TRAN_BATCH_NUMBER) AMOUNT
    FROM TRAN2018 T
   WHERE (T.TRAN_ENTITY_NUM,
          T.TRAN_BRN_CODE,
          T.TRAN_DATE_OF_TRAN,
          T.TRAN_BATCH_NUMBER) IN
            (SELECT TRAN_ENTITY_NUM,
                    TRAN_BRN_CODE,
                    TRAN_DATE_OF_TRAN,
                    TRAN_BATCH_NUMBER
               FROM TRAN2018
              WHERE     TRAN_ENTITY_NUM = 1
                    AND TRAN_GLACC_CODE = '217101101'
                    AND TRAN_DATE_OF_TRAN = :P_TRAN_DATE--AND TRAN_AMOUNT = 500
            )
GROUP BY T.TRAN_ENTITY_NUM,
         T.TRAN_BRN_CODE,
         T.TRAN_DATE_OF_TRAN,
         T.TRAN_BATCH_NUMBER
         having COUNT (DISTINCT  TRAN_ACING_BRN_CODE) < 2  ;