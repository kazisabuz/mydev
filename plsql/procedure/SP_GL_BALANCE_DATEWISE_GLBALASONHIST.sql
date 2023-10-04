


CREATE OR REPLACE PROCEDURE SP_GET_GL_BALANCE_DATEWISE (
   P_BRN_CODE     NUMBER,
   P_GL_CODE      VARCHAR2,
   P_CURR_CODE    VARCHAR2 DEFAULT 'BDT')
IS
   V_MIG_DATE             DATE;

   V_CBD                  DATE;
   V_MIG_YEAR             NUMBER;
   V_CURRENT_YEAR         NUMBER;
   V_SQL                  VARCHAR2 (4000);
   V_CURRENT_AC_BALANCE   NUMBER (18, 3) := 0;
   V_CURRENT_BC_BALANCE   NUMBER (18, 3) := 0;
   V_AC_CREDIT_TRAN       NUMBER (18, 3);
   V_AC_DEBIT_TRAN        NUMBER (18, 3);
   V_BC_CREDIT_TRAN       NUMBER (18, 3);
   V_BC_DEBIT_TRAN        NUMBER (18, 3);
BEGIN
   SELECT MIG_END_DATE
     INTO V_MIG_DATE
     FROM MIG_DETAIL
    WHERE BRANCH_CODE = P_BRN_CODE;

   V_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (1);

   V_MIG_YEAR := TO_NUMBER (TO_CHAR (V_MIG_DATE, 'YYYY'));
   V_CURRENT_YEAR := TO_NUMBER (TO_CHAR (V_CBD, 'YYYY'));



   WHILE V_MIG_DATE < V_CBD
   LOOP
      V_SQL :=
            'SELECT NVL(SUM (AC_CREDIT_BAL),0) AC_CREDIT_BAL, 
                    NVL(SUM (AC_DEBIT_BAL),0) AC_DEBIT_BAL, 
                    NVL(SUM (BC_CREDIT_BAL),0) BC_CREDIT_BAL, 
                    NVL(SUM (BC_DEBIT_BAL),0) BC_DEBIT_BAL
                   FROM (SELECT  
                CASE
                  WHEN TRAN_DB_CR_FLG = ''C'' THEN TRAN_AMOUNT
                  ELSE 0
               END
                  AC_CREDIT_BAL,
               CASE
                  WHEN TRAN_DB_CR_FLG = ''D'' THEN TRAN_AMOUNT
                  ELSE 0
               END
                  AC_DEBIT_BAL,
                CASE
                  WHEN TRAN_DB_CR_FLG = ''C'' THEN TRAN_BASE_CURR_EQ_AMT
                  ELSE 0
               END
                  BC_CREDIT_BAL,
               CASE
                  WHEN TRAN_DB_CR_FLG = ''D'' THEN TRAN_BASE_CURR_EQ_AMT
                  ELSE 0
               END
                  BC_DEBIT_BAL
                   FROM TRAN'
         || TO_NUMBER (TO_CHAR (V_MIG_DATE, 'YYYY'))
         || ' WHERE TRAN_ENTITY_NUM = 1
                      AND TRAN_DATE_OF_TRAN = '
         || ''''
         || V_MIG_DATE
         || ''''
         || '
                      AND TRAN_ACING_BRN_CODE = '
         || P_BRN_CODE
         || '
                      AND TRAN_GLACC_CODE = '
         || ''''
         || P_GL_CODE
         || ''''
         || '
                      AND TRAN_CURR_CODE = '
         || ''''
         || P_CURR_CODE
         || ''''
         || '
                      AND TRAN_AUTH_BY IS NOT NULL)';

      --DBMS_OUTPUT.PUT_LINE (V_SQL);

      EXECUTE IMMEDIATE V_SQL
         INTO V_AC_CREDIT_TRAN,
              V_AC_DEBIT_TRAN,
              V_BC_CREDIT_TRAN,
              V_BC_DEBIT_TRAN;

      V_CURRENT_AC_BALANCE :=
         V_CURRENT_AC_BALANCE + V_AC_CREDIT_TRAN - V_AC_DEBIT_TRAN;
      V_CURRENT_BC_BALANCE :=
         V_CURRENT_BC_BALANCE + V_BC_CREDIT_TRAN - V_BC_DEBIT_TRAN;
      DBMS_OUTPUT.PUT_LINE (
            V_MIG_DATE
         || ' '
         || V_CURRENT_AC_BALANCE
         || ' '
         || V_CURRENT_BC_BALANCE);

      INSERT INTO GL_BALANCE (BALANCE_DATE,
                              BRANCH_CODE,
                              GL_CODE,
                              AC_BALANCE,
                              BC_BALANCE,
                              CURRENCY_CODE)
           VALUES (V_MIG_DATE,
                   P_BRN_CODE,
                   P_GL_CODE,
                   V_CURRENT_AC_BALANCE,
                   V_CURRENT_BC_BALANCE,
                   P_CURR_CODE);


      V_MIG_DATE := V_MIG_DATE + 1;
   END LOOP;
END;
/





insert into BRN_GL
select  GLBALH_BRN_CODE,GLBALH_GLACC_CODE,GLBALH_CURR_CODE
from glbalasonhist
where GLBALH_ENTITY_NUM=1
and GLBALH_BRN_CODE=1024
and GLBALH_GLACC_CODE='217101101'
and GLBALH_ASON_DATE='31-dec-2021';

DECLARE
   V_BRN_CODE   NUMBER;
   V_GL_CODE    VARCHAR2 (32767);
   V_CUR_CODE   VARCHAR2 (3);
BEGIN
   BEGIN
      FOR IDX IN (  SELECT *
                      FROM BRN_GL
                  ORDER BY BRANCH_CODE, GL_CODE, CURRENCY)
      LOOP
         V_BRN_CODE := IDX.BRANCH_CODE;
         V_GL_CODE := IDX.GL_CODE;
         V_CUR_CODE := IDX.CURRENCY;

         SP_GET_GL_BALANCE_DATEWISE (V_BRN_CODE, V_GL_CODE, V_CUR_CODE);
        -- SP_GL_BAL_CORRECTION(V_BRN_CODE, V_GL_CODE, V_CUR_CODE);
         COMMIT;
      END LOOP;
   END;
END;


--------------- Dates that have mismatch ---------------------------

  SELECT GLBALH_GLACC_CODE,
         GLBALH_BRN_CODE,
         GLBALH_CURR_CODE,
         GLBALH_ASON_DATE,
         GLBALH_AC_BAL,
         AC_BALANCE,
         GLBALH_AC_BAL - AC_BALANCE AC_DIFFER,
         GLBALH_BC_BAL,
         BC_BALANCE,
         GLBALH_BC_BAL - BC_BALANCE BC_DIFFER
    FROM GL_BALANCE, GLBALASONHIST
   WHERE     GLBALH_ENTITY_NUM = 1
         AND GLBALH_GLACC_CODE = GL_CODE
         AND GLBALH_BRN_CODE = BRANCH_CODE
         AND GLBALH_CURR_CODE = CURRENCY_CODE
         --and GLBALH_BRN_CODE=4739
         AND GLBALH_ASON_DATE = BALANCE_DATE
         AND (GLBALH_AC_BAL <> AC_BALANCE OR GLBALH_BC_BAL <> BC_BALANCE)
ORDER BY GLBALH_BRN_CODE, GLBALH_GLACC_CODE, GLBALH_ASON_DATE;
 

------------------ Mismatch start date ------------------------------



  SELECT BRANCH_CODE, GL_CODE, MIN (BALANCE_DATE)
    FROM GL_BALANCE, GLBALASONHIST
   WHERE     GLBALH_ENTITY_NUM = 1
         AND GLBALH_GLACC_CODE = GL_CODE
         AND GLBALH_BRN_CODE = BRANCH_CODE
         AND GLBALH_CURR_CODE = CURRENCY_CODE
         AND GLBALH_ASON_DATE = BALANCE_DATE
         AND GLBALH_AC_BAL <> AC_BALANCE
GROUP BY BRANCH_CODE, GL_CODE
ORDER BY BRANCH_CODE, GL_CODE;



BEGIN
   FOR IDX
      IN (  SELECT GLBALH_GLACC_CODE,
                   GLBALH_BRN_CODE,
                   GLBALH_CURR_CODE,
                   GLBALH_ASON_DATE,
                   GLBALH_AC_BAL,
                   AC_BALANCE,
                   BC_BALANCE,
                   GLBALH_AC_BAL - AC_BALANCE
              FROM GL_BALANCE, GLBALASONHIST
             WHERE     GLBALH_ENTITY_NUM = 1
                   AND GLBALH_GLACC_CODE = GL_CODE
                   AND GLBALH_BRN_CODE = BRANCH_CODE
                   AND GLBALH_CURR_CODE = CURRENCY_CODE
                   AND GLBALH_ASON_DATE = BALANCE_DATE
                   AND (   GLBALH_AC_BAL <> AC_BALANCE
                        OR GLBALH_BC_BAL <> BC_BALANCE)
          ORDER BY GLBALH_BRN_CODE, GLBALH_GLACC_CODE, GLBALH_ASON_DATE)
   LOOP
      UPDATE GLBALASONHIST
         SET GLBALH_AC_BAL = IDX.AC_BALANCE, GLBALH_BC_BAL = IDX.BC_BALANCE
       WHERE     GLBALH_ENTITY_NUM = 1
             AND GLBALH_GLACC_CODE = IDX.GLBALH_GLACC_CODE
             AND GLBALH_BRN_CODE = IDX.GLBALH_BRN_CODE
             AND GLBALH_CURR_CODE = IDX.GLBALH_CURR_CODE
             AND GLBALH_ASON_DATE = IDX.GLBALH_ASON_DATE;
   END LOOP;
END;