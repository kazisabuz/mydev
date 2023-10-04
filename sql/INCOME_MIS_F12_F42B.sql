/* Formatted on 1/15/2020 2:05:00 PM (QP5 v5.227.12220.39754) */
SELECT RPT_BRN_CODE,
       F12_INCOME,                                        ---8,35,30,15,652.91
       F42_INCOME,                                         --8,35,30,15,652.91
       F12_INCOME - F42_INCOME DIFFER
  FROM (SELECT RPT_BRN_CODE,
               RPT_HEAD_BAL F12_INCOME,
               (SELECT SUM (RPT_HEAD_BAL)
                  FROM INCOMEEXPENSE
                 WHERE     RPT_ENTRY_DATE = '31-DEC-2019'
                       AND RPT_HEAD_CODE LIKE 'I%'
                       AND RPT_BRN_CODE = F12.RPT_BRN_CODE
                       AND CASHTYPE = 1)
                  F42_INCOME
          FROM STATMENTOFAFFAIRS F12
         WHERE     RPT_ENTRY_DATE = '31-DEC-2019'   --AND RPT_BRN_CODE = 45104
               AND RPT_HEAD_CODE = 'L2701'
               AND CASHTYPE = 1)