/* Formatted on 6/25/2023 10:25:54 PM (QP5 v5.388) */
SELECT *
  FROM (  SELECT ACNTS_INTERNAL_ACNUM,
                 ROUND (SUM (SBCAIA_AC_INT_ACCR_AMT), 0)     CREDIT_SUM
            FROM ACNTS, SBCAIA
           WHERE     ACNTS_ENTITY_NUM = 1
                 AND ACNTS_INTERNAL_ACNUM = SBCAIA_INTERNAL_ACNUM
                 AND ACNTS_BRN_CODE = SBCAIA_BRN_CODE
                 AND ACNTS_CLOSURE_DATE IS NULL
                 AND SBCAIA_ENTITY_NUM = 1
                 AND SBCAIA_CR_DB_INT_FLG = 'C'
                 AND SBCAIA_SOURCE_TABLE <> 'SBCAINTREV'
                 AND SBCAIA_DATE_OF_ENTRY BETWEEN '01-JAN-2016'
                                              AND '30-JUN-2016'
        GROUP BY ACNTS_INTERNAL_ACNUM) A
       LEFT OUTER JOIN
       (  SELECT ACNTS_INTERNAL_ACNUM,
                 ROUND (SUM (SBCAIA_AC_INT_ACCR_AMT), 0)     DEBIT_SUM
            FROM ACNTS, SBCAIA
           WHERE     ACNTS_ENTITY_NUM = 1
                 AND ACNTS_INTERNAL_ACNUM = SBCAIA_INTERNAL_ACNUM
                 AND ACNTS_BRN_CODE = SBCAIA_BRN_CODE
                 AND ACNTS_CLOSURE_DATE IS NULL
                 AND SBCAIA_ENTITY_NUM = 1
                 AND SBCAIA_CR_DB_INT_FLG = 'D'
                 AND SBCAIA_SOURCE_TABLE <> 'SBCAINTREV'
                 AND SBCAIA_DATE_OF_ENTRY BETWEEN '01-JAN-2016'
                                              AND '30-JUN-2016'
        GROUP BY ACNTS_INTERNAL_ACNUM) B
           ON (A.ACNTS_INTERNAL_ACNUM = B.ACNTS_INTERNAL_ACNUM)
 WHERE A.CREDIT_SUM - B.DEBIT_SUM < 0;

SELECT *
  FROM (  SELECT ACNTS_INTERNAL_ACNUM,
                 ROUND (SUM (SBCAIA_AC_INT_ACCR_AMT), 0)     CREDIT_SUM
            FROM ACNTS, SBCAIA
           WHERE     ACNTS_ENTITY_NUM = 1
                 AND ACNTS_INTERNAL_ACNUM = SBCAIA_INTERNAL_ACNUM
                 AND ACNTS_BRN_CODE = SBCAIA_BRN_CODE
                 AND ACNTS_CLOSURE_DATE IS NULL
                 AND SBCAIA_ENTITY_NUM = 1
                 AND SBCAIA_INT_ACCR_DB_CR = 'C'
                 AND SBCAIA_SOURCE_TABLE <> 'SBCAINTREV'
                 AND SBCAIA_DATE_OF_ENTRY BETWEEN '01-JAN-2016'
                                              AND '30-JUN-2016'
        GROUP BY ACNTS_INTERNAL_ACNUM) A
       LEFT OUTER JOIN
       (  SELECT ACNTS_INTERNAL_ACNUM,
                 ROUND (SUM (SBCAIA_AC_INT_ACCR_AMT), 0)     DEBIT_SUM
            FROM ACNTS, SBCAIA
           WHERE     ACNTS_ENTITY_NUM = 1
                 AND ACNTS_INTERNAL_ACNUM = SBCAIA_INTERNAL_ACNUM
                 AND ACNTS_BRN_CODE = SBCAIA_BRN_CODE
                 AND ACNTS_CLOSURE_DATE IS NULL
                 AND SBCAIA_ENTITY_NUM = 1
                 AND SBCAIA_INT_ACCR_DB_CR = 'D'
                 AND SBCAIA_SOURCE_TABLE <> 'SBCAINTREV'
                 AND SBCAIA_DATE_OF_ENTRY BETWEEN '01-JAN-2016'
                                              AND '30-JUN-2016'
        GROUP BY ACNTS_INTERNAL_ACNUM) B
           ON (A.ACNTS_INTERNAL_ACNUM = B.ACNTS_INTERNAL_ACNUM)
 WHERE A.CREDIT_SUM - B.DEBIT_SUM < 0