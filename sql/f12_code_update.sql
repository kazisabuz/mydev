------------F12 UPDATE -----------------
BEGIN
   FOR IDX
      IN (SELECT RPT_BRN_CODE,
                 TRIM(RPT_HEAD_CODE) RPT_HEAD_CODE,
                 CASE
                    WHEN RPT_HEAD_CODE LIKE 'L%' THEN RPT_BALANCE
                    ELSE 0
                 END
                    RPT_HEAD_CREDIT_BAL,
                 CASE
                    WHEN RPT_HEAD_CODE LIKE 'A%' THEN -1 * RPT_BALANCE
                    ELSE 0
                 END
                    RPT_HEAD_DEBIT_BAL,
                 RPT_BALANCE RPT_HEAD_BAL,
                 CASHTYPE,RPT_DATE
            FROM F12_CODE_UPDATE WHERE RPT_TYPE='F12' ORDER BY  RPT_BRN_CODE,
                 RPT_HEAD_CODE ,CASHTYPE)
   LOOP
      UPDATE STATMENTOFAFFAIRS
         SET RPT_HEAD_CREDIT_BAL = IDX.RPT_HEAD_CREDIT_BAL,
              RPT_HEAD_DEBIT_BAL = IDX.RPT_HEAD_DEBIT_BAL,
             RPT_HEAD_BAL = IDX.RPT_HEAD_BAL
       WHERE     RPT_BRN_CODE = IDX.RPT_BRN_CODE
             AND RPT_ENTRY_DATE =idx.RPT_DATE
             AND RPT_HEAD_CODE = TRIM (IDX.RPT_HEAD_CODE)
             AND CASHTYPE = IDX.CASHTYPE;
   END LOOP;
END;

------------F42B UPDATE -----------------
BEGIN
   FOR IDX
      IN (SELECT RPT_BRN_CODE,
                 RPT_HEAD_CODE,
                 CASE
                    WHEN RPT_HEAD_CODE LIKE 'I%' THEN RPT_BALANCE
                    ELSE 0
                 END
                    RPT_HEAD_CREDIT_BAL,
                 CASE
                    WHEN RPT_HEAD_CODE LIKE 'E%' THEN -1 * RPT_BALANCE
                    ELSE 0
                 END
                    RPT_HEAD_DEBIT_BAL,
                 RPT_BALANCE RPT_HEAD_BAL,
                 CASHTYPE,RPT_DATE
            FROM F12_CODE_UPDATE WHERE RPT_TYPE='F42B')
   LOOP
      UPDATE INCOMEEXPENSE
         SET RPT_HEAD_CREDIT_BAL = IDX.RPT_HEAD_CREDIT_BAL,
              RPT_HEAD_DEBIT_BAL = IDX.RPT_HEAD_DEBIT_BAL,
             RPT_HEAD_BAL = IDX.RPT_HEAD_BAL
       WHERE     RPT_BRN_CODE = IDX.RPT_BRN_CODE
             AND RPT_ENTRY_DATE = idx.RPT_DATE
             AND RPT_HEAD_CODE = TRIM (IDX.RPT_HEAD_CODE)
             AND CASHTYPE = IDX.CASHTYPE;
   END LOOP;
END;

--------------------
  SELECT RPT_BRN_CODE,
         SUM (NVL (RPT_HEAD_CREDIT_BAL, 0) + NVL (RPT_HEAD_DEBIT_BAL, 0)),
         CASHTYPE
    FROM STATMENTOFAFFAIRS  
   WHERE     RPT_ENTRY_DATE = '31-dec-2022'
         AND NVL (RPT_HEAD_CREDIT_BAL, 0) + NVL (RPT_HEAD_DEBIT_BAL, 0) <> 0
GROUP BY RPT_BRN_CODE, CASHTYPE
  HAVING SUM (NVL (RPT_HEAD_CREDIT_BAL, 0) + NVL (RPT_HEAD_DEBIT_BAL, 0)) <>
            0
ORDER BY ABS (
            SUM (NVL (RPT_HEAD_CREDIT_BAL, 0) + NVL (RPT_HEAD_DEBIT_BAL, 0)));