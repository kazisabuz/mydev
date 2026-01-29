/*Generating the data of the profit and loss branches after year closing. This report were normally asked by the customers.*/
SELECT TEMP_DATA.RPT_BRN_CODE,
       TEMP_DATA.TOTAL_INCOME_EXPENSE,
       CASE SIGN(TEMP_DATA.TOTAL_INCOME_EXPENSE)
          WHEN 0 THEN 'NO INCOME EXPENSE'
          WHEN 1   THEN
          'Profit'
          WHEN -1 THEN 
          'Loss'
       END
  FROM (  SELECT RPT_BRN_CODE,
                 SUM (RPT_HEAD_CREDIT_BAL) + SUM (RPT_HEAD_DEBIT_BAL)
                    TOTAL_INCOME_EXPENSE
            FROM INCOMEEXPENSE
           WHERE RPT_ENTRY_DATE = :P_DATE
        GROUP BY RPT_BRN_CODE) TEMP_DATA