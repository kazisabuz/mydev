/*
Sctipt to generate the branches for whose the total income and expense balance is mismatched with 2 reports(On the language of bank, those are F12 and F42B).
*/


SELECT *
  FROM (  SELECT RPT_BRN_CODE,
                 SUM (IncomeBalance) IncomeBalance,
                 SUM (Expense_Balance) Expense_Balance
            FROM (SELECT RPT_BRN_CODE,
                         RPT_HEAD_CODE,
                         CASE
                            WHEN SUBSTR (RPT_HEAD_CODE, 1, 1) = 'I'
                            THEN
                               RPT_HEAD_CREDIT_BAL + RPT_HEAD_DEBIT_BAL
                            ELSE
                               0
                         END
                            IncomeBalance,
                         CASE
                            WHEN SUBSTR (RPT_HEAD_CODE, 1, 1) = 'E'
                            THEN
                               RPT_HEAD_CREDIT_BAL + RPT_HEAD_DEBIT_BAL
                            ELSE
                               0
                         END
                            Expense_Balance
                    FROM INCOMEEXPENSE
                   WHERE     RPT_ENTRY_DATE = '31-DEC-2019'
                         AND SUBSTR (RPT_HEAD_CODE, 1, 1) IN ('I', 'E'))
        GROUP BY RPT_BRN_CODE) A,
       (  SELECT RPT_BRN_CODE,
                 SUM (EXPENSE_BAL) EXPENSE_BAL,
                 SUM (INCOME_BAL) INCOME_BAL
            FROM (SELECT RPT_BRN_CODE,
                         RPT_HEAD_CODE,
                         CASE
                            WHEN RPT_HEAD_CODE = 'L2701'
                            THEN
                               RPT_HEAD_CREDIT_BAL + RPT_HEAD_DEBIT_BAL
                            ELSE
                               0
                         END
                            INCOME_BAL,
                         CASE
                            WHEN RPT_HEAD_CODE = 'A1001'
                            THEN
                               RPT_HEAD_CREDIT_BAL + RPT_HEAD_DEBIT_BAL
                            ELSE
                               0
                         END
                            EXPENSE_BAL
                    FROM STATMENTOFAFFAIRS
                   WHERE     RPT_ENTRY_DATE = '31-DEC-2019'
                         AND RPT_HEAD_CODE IN ('L2701', 'A1001'))
        GROUP BY RPT_BRN_CODE
        ORDER BY RPT_BRN_CODE) B
 WHERE     A.RPT_BRN_CODE = B.RPT_BRN_CODE
       AND (   A.IncomeBalance <> B.INCOME_BAL
            OR A.Expense_Balance <> B.EXPENSE_BAL)