  SELECT DEPOSITE.ACNTS_BRN_CODE,
         DEPOSITE.DEPOSIT_INTERNAL_ACNUM,
         DEPOSITE.DEPOSIT_BALANCE,
         loan.LOAN_INTERNAL_ACNUM,
         loan.LOAN_BALANCE
    FROM (  SELECT ACNTS_BRN_CODE,
                   COUNT (ACNTS_INTERNAL_ACNUM) dd_INTERNAL_ACNUM,
                   SUM (NVL (GET_ASON_ACBAL (1,
                                             ACNTS_INTERNAL_ACNUM,
                                             'BDT',
                                             '31-DEC-2017',
                                             '31-DEC-2017'),
                             0))
                      DEPOSIT_BALANCE
              FROM ACNTS, PRODUCTS
             WHERE     ACNTS_PROD_CODE = PRODUCT_CODE
                   -- AND ACNTS_INTERNAL_ACNUM = ACBALH_INTERNAL_ACNUM
                   AND PRODUCT_FOR_DEPOSITS = '1'
                   AND PRODUCT_FOR_RUN_ACS = '0'
                   AND ACNTS_ENTITY_NUM = 1
                   -- AND ACBALH_ENTITY_NUM = 1
                   AND ACNTS_OPENING_DATE <= '31-DEC-2017'
          --AND ACBALH_ASON_DATE <='31-DE-2017'
          GROUP BY ACNTS_BRN_CODE) DEPOSITE
         FULL OUTER JOIN
         (  SELECT ACNTS_BRN_CODE,
                   COUNT (ACNTS_INTERNAL_ACNUM) ACNTS_INTERNAL_ACNUM,
                   SUM (NVL (GET_ASON_ACBAL (1,
                                             ACNTS_INTERNAL_ACNUM,
                                             'BDT',
                                             '31-DEC-2017',
                                             '31-DEC-2017'),
                             0))
                      LOAN_BALANCE
              FROM ACNTS, PRODUCTS
             WHERE     ACNTS_PROD_CODE = PRODUCT_CODE
                  -- AND ACNTS_INTERNAL_ACNUM = ACBALH_INTERNAL_ACNUM
                   AND PRODUCT_FOR_LOANS = '1'
                   AND ACNTS_ENTITY_NUM = 1
                   AND ACBALH_ENTITY_NUM = 1
                   AND ACNTS_OPENING_DATE <= '31-DEC-2017'
                   --AND ACBALH_ASON_DATE <= '31-DEC-2017'
          GROUP BY ACNTS_BRN_CODE) LOAN
            ON (DEPOSITE.ACNTS_BRN_CODE = LOAN.ACNTS_BRN_CODE)
ORDER BY LOAN.ACNTS_BRN_CODE



-------------------
SELECT TEMP_DATA.RPT_BRN_CODE,
       TEMP_DATA.TOTAL_INCOME_EXPENSE,
       CASE SIGN (TEMP_DATA.TOTAL_INCOME_EXPENSE)
          WHEN 0 THEN 'NO INCOME EXPENSE'
          WHEN 1 THEN 'Profit'
          WHEN -1 THEN 'Loss'
       END
          PROFIT_LOSS
  FROM (  SELECT RPT_BRN_CODE,
                 SUM (RPT_HEAD_CREDIT_BAL) + SUM (RPT_HEAD_DEBIT_BAL)
                    TOTAL_INCOME_EXPENSE
            FROM INCOMEEXPENSE
           WHERE RPT_ENTRY_DATE = '31-DEC-2017'
        -- AND RPT_BRN_CODE <>18
        GROUP BY RPT_BRN_CODE) TEMP_DATA
 WHERE TOTAL_INCOME_EXPENSE <> 0