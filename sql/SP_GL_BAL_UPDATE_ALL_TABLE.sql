CREATE OR REPLACE PROCEDURE SP_GL_BAL_UPDATE_ALL_TABLE (
   P_ASON_DATE DATE)
AS
   V_GLBALHIST_D_MINUS_1_ACBAL   NUMBER (18, 3);
   V_GLBALHIST_D_MINUS_1_BCBAL   NUMBER (18, 3);
   V_GLBALHIST_ASON_ACBAL        NUMBER (18, 3);
   V_GLBALHIST_ASON_BCBAL        NUMBER (18, 3);

   PROCEDURE GLBBAL_UPDATE (P_BRN_CODE         NUMBER,
                            P_GL_CODE          VARCHAR2,
                            P_CURRENCY_CODE    VARCHAR2)
   AS
      V_AC_DEBIT_SUM         NUMBER (18, 3);
      V_AC_CREDIT_SUM        NUMBER (18, 3);
      V_BC_DEBIT_SUM         NUMBER (18, 3);
      V_BC_CREDIT_SUM        NUMBER (18, 3);

      V_OPEN_AC_DEBIT_SUM    NUMBER (18, 3);
      V_OPEN_AC_CREDIT_SUM   NUMBER (18, 3);
      V_OPEN_BC_DEBIT_SUM    NUMBER (18, 3);
      V_OPEN_BC_CREDIT_SUM   NUMBER (18, 3);

      V_CBD                  DATE;
      V_CBD_YEAR             NUMBER;
   BEGIN
      V_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (1);

      V_CBD_YEAR := TO_NUMBER (TO_CHAR (V_CBD, 'YYYY'));


      BEGIN
         SELECT SUM (DEBIT_TRAN) AC_DEBIT_SUM,
                SUM (CREDIT_TRAN) AC_CREDIT_SUM,
                SUM (DEBIT_TRAN_EQ_AMT) BC_DEBIT_SUM,
                SUM (CREDIT_TRAN_EQ_AMT) BC_CREDIT_SUM
           INTO V_AC_DEBIT_SUM,
                V_AC_CREDIT_SUM,
                V_BC_DEBIT_SUM,
                V_BC_CREDIT_SUM
           FROM (SELECT TRAN_ACING_BRN_CODE,
                        TRAN_GLACC_CODE,
                        TRAN_DB_CR_FLG,
                        TRAN_CURR_CODE,
                        CASE
                           WHEN TRAN_DB_CR_FLG = 'C' THEN TRAN_AMOUNT
                           ELSE 0
                        END
                           CREDIT_TRAN,
                        CASE
                           WHEN TRAN_DB_CR_FLG = 'D' THEN TRAN_AMOUNT
                           ELSE 0
                        END
                           DEBIT_TRAN,
                        TRAN_AMOUNT,
                        CASE
                           WHEN TRAN_DB_CR_FLG = 'C'
                           THEN
                              TRAN_BASE_CURR_EQ_AMT
                           ELSE
                              0
                        END
                           CREDIT_TRAN_EQ_AMT,
                        CASE
                           WHEN TRAN_DB_CR_FLG = 'D'
                           THEN
                              TRAN_BASE_CURR_EQ_AMT
                           ELSE
                              0
                        END
                           DEBIT_TRAN_EQ_AMT,
                        TRAN_BASE_CURR_EQ_AMT
                   FROM TRAN2019
                  WHERE     TRAN_ENTITY_NUM = 1
                        AND TRAN_ACING_BRN_CODE = P_BRN_CODE
                        AND TRAN_GLACC_CODE = P_GL_CODE
                        AND TRAN_CURR_CODE = P_CURRENCY_CODE
                        AND TRAN_AUTH_BY IS NOT NULL);
      EXCEPTION
         WHEN OTHERS
         THEN
            V_AC_DEBIT_SUM := 0;
            V_AC_CREDIT_SUM := 0;
            V_BC_DEBIT_SUM := 0;
            V_BC_CREDIT_SUM := 0;
      END;


      BEGIN
         SELECT GLBBAL_AC_OPNG_DB_SUM,
                GLBBAL_AC_OPNG_CR_SUM,
                GLBBAL_BC_OPNG_DB_SUM,
                GLBBAL_BC_OPNG_CR_SUM
           INTO V_OPEN_AC_DEBIT_SUM,
                V_OPEN_AC_CREDIT_SUM,
                V_OPEN_BC_DEBIT_SUM,
                V_OPEN_BC_CREDIT_SUM
           FROM GLBBAL
          WHERE     GLBBAL_ENTITY_NUM = 1
                AND GLBBAL_BRANCH_CODE = P_BRN_CODE
                AND GLBBAL_GLACC_CODE = P_GL_CODE
                AND GLBBAL_CURR_CODE = P_CURRENCY_CODE
                AND GLBBAL_YEAR = V_CBD_YEAR;
      EXCEPTION
         WHEN OTHERS
         THEN
            V_OPEN_AC_DEBIT_SUM := 0;
            V_OPEN_AC_CREDIT_SUM := 0;
            V_OPEN_BC_DEBIT_SUM := 0;
            V_OPEN_BC_CREDIT_SUM := 0;
      END;


      V_AC_DEBIT_SUM := V_OPEN_AC_DEBIT_SUM + V_AC_DEBIT_SUM;
      V_AC_CREDIT_SUM := V_OPEN_AC_CREDIT_SUM + V_AC_CREDIT_SUM;
      V_BC_DEBIT_SUM := V_OPEN_BC_DEBIT_SUM + V_BC_DEBIT_SUM;
      V_BC_CREDIT_SUM := V_OPEN_BC_CREDIT_SUM + V_BC_CREDIT_SUM;


      UPDATE GLBBAL
         SET GLBBAL_AC_CUR_DB_SUM = V_AC_DEBIT_SUM,
             GLBBAL_AC_CUR_CR_SUM = V_AC_CREDIT_SUM,
             GLBBAL_BC_CUR_DB_SUM = V_BC_DEBIT_SUM,
             GLBBAL_BC_CUR_CR_SUM = V_BC_CREDIT_SUM,
             GLBBAL_AC_BAL = V_AC_CREDIT_SUM - V_AC_DEBIT_SUM,
             GLBBAL_BC_BAL = V_BC_CREDIT_SUM - V_BC_DEBIT_SUM
       WHERE     GLBBAL_ENTITY_NUM = 1
             AND GLBBAL_BRANCH_CODE = P_BRN_CODE
             AND GLBBAL_GLACC_CODE = P_GL_CODE
             AND GLBBAL_CURR_CODE = P_CURRENCY_CODE
             AND GLBBAL_YEAR = V_CBD_YEAR;
   END GLBBAL_UPDATE;

BEGIN
   FOR IDX
      IN (  SELECT TRAN_ACING_BRN_CODE,
                   TRAN_GLACC_CODE,
                   TRAN_CURR_CODE,
                   SUM (CREDIT_TRAN) AC_CREDIT_SUM,
                   SUM (DEBIT_TRAN) AC_DEBIT_SUM,
                   SUM (CREDIT_TRAN) - SUM (DEBIT_TRAN) BALANCE,
                   SUM (CREDIT_TRAN_NUMBER) CREDIT_TRAN_NUMBER,
                   SUM (DEBIT_TRAN_NUMBER) DEBIT_TRAN_NUMBER,
                   SUM (CREDIT_TRAN_EQ_AMT) BC_CREDIT_SUM,
                   SUM (DEBIT_TRAN_EQ_AMT) BC_DEBIT_SUM,
                   SUM (CREDIT_TRAN_EQ_AMT) - SUM (DEBIT_TRAN_EQ_AMT)
                      BALANCE_EQ_AMT
              FROM (SELECT TRAN_ACING_BRN_CODE,
                           TRAN_GLACC_CODE,
                           TRAN_DB_CR_FLG,
                           TRAN_CURR_CODE,
                           CASE
                              WHEN TRAN_DB_CR_FLG = 'C' THEN TRAN_AMOUNT
                              ELSE 0
                           END
                              CREDIT_TRAN,
                           CASE
                              WHEN TRAN_DB_CR_FLG = 'C' AND TRAN_AMOUNT <> 0
                              THEN
                                 1
                              ELSE
                                 0
                           END
                              CREDIT_TRAN_NUMBER,
                           CASE
                              WHEN TRAN_DB_CR_FLG = 'D' THEN TRAN_AMOUNT
                              ELSE 0
                           END
                              DEBIT_TRAN,
                           CASE
                              WHEN TRAN_DB_CR_FLG = 'D' AND TRAN_AMOUNT <> 0
                              THEN
                                 1
                              ELSE
                                 0
                           END
                              DEBIT_TRAN_NUMBER,
                           TRAN_AMOUNT,
                           CASE
                              WHEN TRAN_DB_CR_FLG = 'C'
                              THEN
                                 TRAN_BASE_CURR_EQ_AMT
                              ELSE
                                 0
                           END
                              CREDIT_TRAN_EQ_AMT,
                           CASE
                              WHEN TRAN_DB_CR_FLG = 'D'
                              THEN
                                 TRAN_BASE_CURR_EQ_AMT
                              ELSE
                                 0
                           END
                              DEBIT_TRAN_EQ_AMT,
                           TRAN_BASE_CURR_EQ_AMT
                      FROM TRAN2019
                     WHERE     TRAN_ENTITY_NUM = 1
                           AND TRAN_DATE_OF_TRAN = P_ASON_DATE
                           --AND TRAN_AMOUNT <> 0
                           AND TRAN_AUTH_BY IS NOT NULL)
          GROUP BY TRAN_ACING_BRN_CODE, TRAN_GLACC_CODE, TRAN_CURR_CODE
          ORDER BY TRAN_ACING_BRN_CODE, TRAN_GLACC_CODE, TRAN_CURR_CODE)
   LOOP
      -------------- GLBALASONHIST update started -----------------------
      BEGIN
         SELECT GLBALH_AC_BAL, GLBALH_BC_BAL
           INTO V_GLBALHIST_D_MINUS_1_ACBAL, V_GLBALHIST_D_MINUS_1_BCBAL
           FROM GLBALASONHIST
          WHERE     GLBALH_ENTITY_NUM = 1
                AND GLBALH_GLACC_CODE = IDX.TRAN_GLACC_CODE
                AND GLBALH_BRN_CODE = IDX.TRAN_ACING_BRN_CODE
                AND GLBALH_CURR_CODE = IDX.TRAN_CURR_CODE
                AND GLBALH_ASON_DATE = P_ASON_DATE - 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            V_GLBALHIST_D_MINUS_1_ACBAL := 0;
            V_GLBALHIST_D_MINUS_1_BCBAL := 0;
      END;

      V_GLBALHIST_ASON_ACBAL := V_GLBALHIST_D_MINUS_1_ACBAL + IDX.BALANCE;
      V_GLBALHIST_ASON_BCBAL :=
         V_GLBALHIST_D_MINUS_1_BCBAL + IDX.BALANCE_EQ_AMT;



      UPDATE GLBALASONHIST
         SET GLBALH_AC_BAL = V_GLBALHIST_ASON_ACBAL,
             GLBALH_BC_BAL = V_GLBALHIST_ASON_BCBAL
       WHERE     GLBALH_ENTITY_NUM = 1
             AND GLBALH_GLACC_CODE = IDX.TRAN_GLACC_CODE
             AND GLBALH_BRN_CODE = IDX.TRAN_ACING_BRN_CODE
             AND GLBALH_CURR_CODE = IDX.TRAN_CURR_CODE
             AND GLBALH_ASON_DATE = P_ASON_DATE;



      -------------- GLBALASONHIST update finished -----------------------

      -------------- GLSUM2019 update started ----------------------------


      UPDATE GLSUM2019
         SET GLSUM_AC_DB_SUM = IDX.AC_DEBIT_SUM,
             GLSUM_BC_DB_SUM = IDX.BC_DEBIT_SUM,
             GLSUM_NUM_DBS = IDX.DEBIT_TRAN_NUMBER,
             GLSUM_AC_CR_SUM = IDX.AC_CREDIT_SUM,
             GLSUM_BC_CR_SUM = IDX.BC_CREDIT_SUM,
             GLSUM_NUM_CRS = IDX.CREDIT_TRAN_NUMBER
       WHERE     GLSUM_ENTITY_NUM = 1
             AND GLSUM_BRANCH_CODE = IDX.TRAN_ACING_BRN_CODE
             AND GLSUM_GLACC_CODE = IDX.TRAN_GLACC_CODE
             AND GLSUM_CURR_CODE = IDX.TRAN_CURR_CODE
             AND GLSUM_TRAN_DATE = P_ASON_DATE;

      -------------- GLSUM2019 update finished ----------------------------

      --------------- GLBBAL update started --------------------------

      --SP_GL_BAL_CORRECTION (IDX.TRAN_ACING_BRN_CODE, IDX.TRAN_GLACC_CODE);
      GLBBAL_UPDATE (IDX.TRAN_ACING_BRN_CODE,
                     IDX.TRAN_GLACC_CODE,
                     IDX.TRAN_CURR_CODE);
                     
   --------------- GLBBAL update finished --------------------------


   END LOOP;
END SP_GL_BAL_UPDATE_ALL_TABLE;
/