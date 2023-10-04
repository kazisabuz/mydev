CREATE OR REPLACE PROCEDURE SP_GET_AVG_DETAIL (
   P_ENTITY_NUM      IN     NUMBER,
   P_ACC_NUMBER      IN     NUMBER,
   P_START_DATE      IN     DATE,
   P_END_DATE        IN     DATE,
   P_NO_OF_DAYS         OUT NUMBER,
   P_TOTAL_BALANCE      OUT NUMBER,
   P_AVG_BALANCE        OUT NUMBER)
IS
   V_SQLERRM   VARCHAR2 (3000);
BEGIN
   WITH TRAN_DETAILS
        AS (SELECT TRANSACTION_DATE,
                   COALESCE (
                      LAG (TRANSACTION_DATE, 1)
                         OVER (ORDER BY TRANSACTION_DATE),
                      TRANSACTION_DATE)
                      LAST_TRANSACTION_DATE,
                   ACCOUNT_BALANCE
              FROM (SELECT ACBALH_ASON_DATE TRANSACTION_DATE,
                           ACBALH_AC_BAL ACCOUNT_BALANCE
                      FROM ACBALASONHIST
                     WHERE     ACBALH_ENTITY_NUM = P_ENTITY_NUM
                           AND ACBALH_ASON_DATE =
                                  (SELECT MAX (ACBALH_ASON_DATE)
                                     FROM ACBALASONHIST
                                    WHERE     ACBALH_ENTITY_NUM =
                                                 P_ENTITY_NUM
                                          AND ACBALH_AC_BAL = P_ACC_NUMBER
                                          AND ACBALH_ASON_DATE <=
                                                 P_START_DATE)
                           AND ACBALH_INTERNAL_ACNUM = P_ACC_NUMBER
                    UNION ALL
                    SELECT ACBALH_ASON_DATE TRANSACTION_DATE,
                           ACBALH_AC_BAL ACCOUNT_BALANCE
                      FROM ACBALASONHIST
                     WHERE     ACBALH_ENTITY_NUM = P_ENTITY_NUM
                           AND ACBALH_ASON_DATE BETWEEN P_START_DATE
                                                    AND P_END_DATE
                           AND ACBALH_INTERNAL_ACNUM = P_ACC_NUMBER))
   SELECT SUM (TOTAL_ACCOUNT_BALANCE) TOTAL_ACCOUNT_BALANCE,
          SUM (NO_OF_DAYS) NO_OF_DAYS,
          SUM (TOTAL_ACCOUNT_BALANCE) / SUM (NO_OF_DAYS) AVG_BALANCE
     INTO P_TOTAL_BALANCE, P_NO_OF_DAYS, P_AVG_BALANCE
     FROM (SELECT TRANSACTION_DATE,
                  LAST_TRANSACTION_DATE,
                  TRANSACTION_DATE - LAST_TRANSACTION_DATE + 1 NO_OF_DAYS,
                  ACCOUNT_BALANCE,
                    (TRANSACTION_DATE - LAST_TRANSACTION_DATE + 1)
                  * ACCOUNT_BALANCE
                     TOTAL_ACCOUNT_BALANCE
             FROM TRAN_DETAILS);
EXCEPTION
   WHEN OTHERS
   THEN
      V_SQLERRM := SQLERRM;
END;
/