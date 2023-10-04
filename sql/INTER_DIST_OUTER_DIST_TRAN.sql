/* Formatted on 04/15/2018 4:27:41 PM (QP5 v5.227.12220.39754) */
SELECT 'outer dist', A.*
  FROM (SELECT TRAN_BRN_CODE,
               TRAN_ACING_BRN_CODE,
               (SELECT MBRN_LOCN_CODE
                  FROM MBRN
                 WHERE MBRN_CODE = TRAN_ACING_BRN_CODE)
                  ACC_LOC,
               (SELECT MBRN_LOCN_CODE
                  FROM MBRN
                 WHERE MBRN_CODE = TRAN_BRN_CODE)
                  TRAN_LOC,
               TRAN_DATE_OF_TRAN,
               SUM(TRAN_AMOUNT)
          FROM TRAN2018
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN BETWEEN '01-jan-2018' AND '28-feb-2018'
               GROUP BY TRAN_BRN_CODE, TRAN_ACING_BRN_CODE,TRAN_DATE_OF_TRAN ) A
 WHERE A.TRAN_BRN_CODE <> A.TRAN_ACING_BRN_CODE AND ACC_LOC <> TRAN_LOC
UNION ALL
SELECT 'inter dist', B.*
  FROM (SELECT TRAN_BRN_CODE,
               TRAN_ACING_BRN_CODE,
               (SELECT MBRN_LOCN_CODE
                  FROM MBRN
                 WHERE MBRN_CODE = TRAN_ACING_BRN_CODE)
                  ACC_LOC,
               (SELECT MBRN_LOCN_CODE
                  FROM MBRN
                 WHERE MBRN_CODE = TRAN_BRN_CODE)
                  TRAN_LOC,
               TRAN_DATE_OF_TRAN,
               SUM(TRAN_AMOUNT)
          FROM TRAN2018
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN BETWEEN '01-jan-2018' AND '28-feb-2018'  GROUP BY TRAN_BRN_CODE, TRAN_ACING_BRN_CODE,TRAN_DATE_OF_TRAN) B
 WHERE B.TRAN_BRN_CODE <> B.TRAN_ACING_BRN_CODE AND B.ACC_LOC = B.TRAN_LOC