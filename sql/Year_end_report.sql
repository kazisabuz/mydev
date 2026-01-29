/*Different report for the customer after running the yearend.*/


SELECT PL_2015.TRAN_ACING_BRN_CODE BRANCH_CODE, CASE  WHEN PL_2015.TOTAL_PL > 0 THEN 'Profit' ELSE 'Loss' END PL_2015, PL_2015.TOTAL_PL TOTAL_PL_2015,
CASE  WHEN PL_2016.TOTAL_PL > 0 THEN 'Profit' ELSE 'Loss' END PL_2016, PL_2016.TOTAL_PL TOTAL_PL_2016  fROM 
(SELECT TRAN_ACING_BRN_CODE,
       SUM(CASE
          WHEN TRAN_DB_CR_FLG = 'C' THEN TRAN_AMOUNT
          ELSE (-1 * TRAN_AMOUNT)
       END) TOTAL_PL
  FROM TRAN2015
 WHERE     TRAN_ENTITY_NUM = 1
       --AND TRAN_BRN_CODE = 1065
       AND TRAN_DATE_OF_TRAN =
              TO_DATE ('12/31/2015 00:00:00', 'MM/DD/YYYY HH24:MI:SS')
       AND TRAN_CODE = 'TPL'
       AND TRAN_GLACC_CODE = '140148101'
       AND TRAN_ACING_BRN_CODE IN (SELECT BRANCH_CODE FROM MIG_DETAIL WHERE MIG_END_DATE <= '31-DEC-2015')
       GROUP BY TRAN_ACING_BRN_CODE ) PL_2015,
(SELECT TRAN_ACING_BRN_CODE,
       SUM(CASE
          WHEN TRAN_DB_CR_FLG = 'C' THEN TRAN_AMOUNT
          ELSE (-1 * TRAN_AMOUNT)
       END) TOTAL_PL
  FROM TRAN2016
 WHERE     TRAN_ENTITY_NUM = 1
       --AND TRAN_BRN_CODE = 1065
       AND TRAN_DATE_OF_TRAN =
              TO_DATE ('12/31/2016 00:00:00', 'MM/DD/YYYY HH24:MI:SS')
       AND TRAN_CODE = 'TPL'
       AND TRAN_GLACC_CODE = '140148101'
       AND TRAN_ACING_BRN_CODE IN (SELECT BRANCH_CODE FROM MIG_DETAIL WHERE MIG_END_DATE <= '31-DEC-2015')
       GROUP BY TRAN_ACING_BRN_CODE) PL_2016
       WHERE PL_2015.TRAN_ACING_BRN_CODE = PL_2016.TRAN_ACING_BRN_CODE 
       ORDER BY PL_2015.TRAN_ACING_BRN_CODE ;
	   
	   
	   
	   
/* Formatted on 01/05/2017 2:56:31 PM (QP5 v5.227.12220.39754) */
  SELECT PL_2015.TRAN_ACING_BRN_CODE BRANCH_CODE,
         CASE WHEN PL_2015.TOTAL_PL > 0 THEN 'Profit' ELSE 'Loss' END PL_2015,
         PL_2015.TOTAL_PL TOTAL_PL_2015,
         CASE WHEN PL_2016.TOTAL_PL > 0 THEN 'Profit' ELSE 'Loss' END PL_2016,
         PL_2016.TOTAL_PL TOTAL_PL_2016
    FROM (  SELECT TRAN_ACING_BRN_CODE,
                   SUM (
                      CASE
                         WHEN TRAN_DB_CR_FLG = 'D' THEN TRAN_AMOUNT
                         ELSE (-1 * TRAN_AMOUNT)
                      END)
                      TOTAL_PL
              FROM TRAN2015
             WHERE     TRAN_ENTITY_NUM = 1
                   --AND TRAN_BRN_CODE = 1065
                   AND TRAN_DATE_OF_TRAN =
                          TO_DATE ('12/31/2015 00:00:00',
                                   'MM/DD/YYYY HH24:MI:SS')
                   AND TRAN_CODE = 'TPL'
                   AND TRAN_GLACC_CODE NOT IN
                          ('140148101',
                           '300116107',
                           '300116101',
                           '300116104',
                           '300116109',
                           '300116111',
                           '300116107',
                           '400104106',
                           '400104101',
                           '400104104',
                           '400104108',
                           '400104110',
                           '400104106')
                   AND TRAN_ACING_BRN_CODE IN
                          (SELECT BRANCH_CODE
                             FROM MIG_DETAIL
                            WHERE MIG_END_DATE <= '31-DEC-2015')
          GROUP BY TRAN_ACING_BRN_CODE) PL_2015,
         (  SELECT TRAN_ACING_BRN_CODE,
                   SUM (
                      CASE
                         WHEN TRAN_DB_CR_FLG = 'D' THEN TRAN_AMOUNT
                         ELSE (-1 * TRAN_AMOUNT)
                      END)
                      TOTAL_PL
              FROM TRAN2016
             WHERE     TRAN_ENTITY_NUM = 1
                   --AND TRAN_BRN_CODE = 1065
                   AND TRAN_DATE_OF_TRAN =
                          TO_DATE ('12/31/2016 00:00:00',
                                   'MM/DD/YYYY HH24:MI:SS')
                   AND TRAN_CODE = 'TPL'
                   AND TRAN_GLACC_CODE NOT IN
                          ('140148101',
                           '300116107',
                           '300116101',
                           '300116104',
                           '300116109',
                           '300116111',
                           '300116107',
                           '400104106',
                           '400104101',
                           '400104104',
                           '400104108',
                           '400104110',
                           '400104106')
                   AND TRAN_ACING_BRN_CODE IN
                          (SELECT BRANCH_CODE
                             FROM MIG_DETAIL
                            WHERE MIG_END_DATE <= '31-DEC-2015')
          GROUP BY TRAN_ACING_BRN_CODE) PL_2016
   WHERE PL_2015.TRAN_ACING_BRN_CODE = PL_2016.TRAN_ACING_BRN_CODE
ORDER BY PL_2015.TRAN_ACING_BRN_CODE ;