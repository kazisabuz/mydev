/*Inter branch interest calculation process had some bug and due to those bug, system calculated the interest wrongly. This script is the rectification of that problem in the production.*/
----------------------- Generated data ----------------------------

SELECT A.BRANCH_CODE,
         A.MIG_DATE FROM_DATE,
         A.MIG_BALANCE,
         B.IBRNICDTL_RUN_NUMBER,
         B.IBRNICDTL_GLACC_CODE GL_CODE,
         B.IBRNICDTL_UPTO_DATE - 1 UPTO_DATE,
         (B.IBRNICDTL_UPTO_DATE - A.MIG_DATE) TOTAL_DAYS,
         6 INTEREST_RATE,
         ROUND((A.MIG_BALANCE * 6) / 36000, 0) *  (B.IBRNICDTL_UPTO_DATE - A.MIG_DATE)  INTEREST_AMOUNT
    FROM (SELECT BRANCH_CODE BRANCH_CODE,
                 MIG_END_DATE MIG_DATE,
                 GLSUM_GLACC_CODE GL_CODE,
                 (GLSUM_BC_CR_SUM - GLSUM_BC_DB_SUM) MIG_BALANCE
            FROM MIG_DETAIL, GLSUM2016
           WHERE     BRANCH_CODE = GLSUM_BRANCH_CODE
                 AND MIG_END_DATE = GLSUM_TRAN_DATE
                 AND GLSUM_ENTITY_NUM = 1
                 AND GLSUM_GLACC_CODE IN
                        (SELECT EXTGL_ACCESS_CODE
                           FROM EXTGL, GLMAST
                          WHERE     GL_NUMBER = EXTGL_GL_HEAD
                                AND GL_NUMBER IN (216, 217))
                 AND MIG_END_DATE BETWEEN '01-MAR-2016' AND '31-MAR-2016') A,
         (  SELECT I.IBRNICDTL_RUN_NUMBER,
       I.IBRNICDTL_BRN_CODE,
       I.IBRNICDTL_GLACC_CODE,
       I.IBRNICDTL_UPTO_DATE
  FROM IBRNINTCALCDTL I
 WHERE (I.IBRNICDTL_BRN_CODE, I.IBRNICDTL_GLACC_CODE, I.IBRNICDTL_UPTO_DATE) IN
          (  SELECT BRANCH_CODE,
                    IBRNICDTL_GLACC_CODE,
                    MIN (IBRNICDTL_FROM_DATE) MAX_DATE
               FROM IBRNINTCALCDTL, MIG_DETAIL
              WHERE     IBRNICDTL_BRN_CODE = BRANCH_CODE
                    AND MIG_END_DATE BETWEEN '01-MAR-2016' AND '31-MAR-2016'
           GROUP BY BRANCH_CODE, IBRNICDTL_GLACC_CODE)) B
   WHERE A.BRANCH_CODE = B.IBRNICDTL_BRN_CODE AND A.GL_CODE = B.IBRNICDTL_GLACC_CODE
ORDER BY A.MIG_DATE, A.BRANCH_CODE, A.GL_CODE ;


-------------------- IBRNINTCALCDTL serial number update -----------------------------



UPDATE IBRNINTCALCDTL
   SET IBRNICDTL_DTL_SL_NUM = IBRNICDTL_DTL_SL_NUM + 1
 WHERE     IBRNICDTL_ENTITY_NUM = 1
       AND IBRNICDTL_BRN_CODE IN
              (SELECT BRANCH_CODE
                 FROM MIG_DETAIL
                WHERE MIG_END_DATE BETWEEN '01-MAR-2016' AND '31-MAR-2016')
       AND IBRNICDTL_GLACC_CODE IN
              (SELECT EXTGL_ACCESS_CODE
                 FROM EXTGL, GLMAST
                WHERE GL_NUMBER = EXTGL_GL_HEAD AND GL_NUMBER IN (216, 217))
       AND IBRNICDTL_PROC_DATE = '31-MAR-2016'
       AND IBRNICDTL_RUN_NUMBER = 981694 ;
	   
	   
	   
	   
	   
	   
--------------------------- IBRNINTCALC update ---------------------------------


BEGIN
   FOR IDX
      IN (SELECT 1 IBRNICDTL_ENTITY_NUM,
                 B.IBRNICDTL_RUN_NUMBER IBRNICDTL_RUN_NUMBER,
                 A.BRANCH_CODE IBRNICDTL_BRN_CODE,
                 B.IBRNICDTL_GLACC_CODE IBRNICDTL_GLACC_CODE,
                 'BDT' IBRNICDTL_CURR_CODE,
                 '31-MAR-2016' IBRNICDTL_PROC_DATE,
                 1 IBRNICDTL_DTL_SL_NUM,
                 A.MIG_DATE IBRNICDTL_FROM_DATE,
                 B.IBRNICDTL_UPTO_DATE - 1 IBRNICDTL_UPTO_DATE,
                 A.MIG_BALANCE IBRNICDTL_BALANCE,
                 CASE WHEN A.MIG_BALANCE > 0 THEN 6 ELSE 0 END
                    IBRNICDTL_CR_INT_RATE,
                 CASE WHEN A.MIG_BALANCE < 0 THEN 6 ELSE 0 END
                    IBRNICDTL_DB_INT_RATE,
                 (B.IBRNICDTL_UPTO_DATE - A.MIG_DATE) IBRNICDTL_NUM_OF_DAYS,
                 CASE
                    WHEN A.MIG_BALANCE < 0 THEN ABS (A.MIG_BALANCE)
                    ELSE 0
                 END
                    IBRNICDTL_DB_PRODUCT,
                 CASE
                    WHEN A.MIG_BALANCE > 0 THEN ABS (A.MIG_BALANCE)
                    ELSE 0
                 END
                    IBRNICDTL_CR_PRODUCT,
                 CASE
                    WHEN A.MIG_BALANCE > 0
                    THEN
                       ABS (ROUND ( (A.MIG_BALANCE * 6) / 36000, 0))  * (B.IBRNICDTL_UPTO_DATE - A.MIG_DATE)
                    ELSE
                       0
                 END
                    IBRNICDTL_CR_INT_AMOUNT,
                 CASE
                    WHEN A.MIG_BALANCE < 0
                    THEN
                       ABS (ROUND ( (A.MIG_BALANCE * 6) / 36000, 0))  * (B.IBRNICDTL_UPTO_DATE - A.MIG_DATE)
                    ELSE
                       0
                 END
                    IBRNICDTL_DB_INT_AMOUNT
            FROM (SELECT BRANCH_CODE BRANCH_CODE,
                         MIG_END_DATE MIG_DATE,
                         GLSUM_GLACC_CODE GL_CODE,
                         (GLSUM_BC_CR_SUM - GLSUM_BC_DB_SUM) MIG_BALANCE
                    FROM MIG_DETAIL, GLSUM2016
                   WHERE     BRANCH_CODE = GLSUM_BRANCH_CODE
                         AND MIG_END_DATE = GLSUM_TRAN_DATE
                         AND GLSUM_ENTITY_NUM = 1
                         AND GLSUM_GLACC_CODE IN
                                (SELECT EXTGL_ACCESS_CODE
                                   FROM EXTGL, GLMAST
                                  WHERE     GL_NUMBER = EXTGL_GL_HEAD
                                        AND GL_NUMBER IN (216, 217))
                         AND MIG_END_DATE BETWEEN '01-MAR-2016'
                                              AND '31-MAR-2016') A,
                 (SELECT I.IBRNICDTL_RUN_NUMBER,
                         I.IBRNICDTL_BRN_CODE,
                         I.IBRNICDTL_GLACC_CODE,
                         I.IBRNICDTL_UPTO_DATE
                    FROM IBRNINTCALCDTL I
                   WHERE (I.IBRNICDTL_BRN_CODE,
                          I.IBRNICDTL_GLACC_CODE,
                          I.IBRNICDTL_UPTO_DATE) IN
                            (  SELECT BRANCH_CODE,
                                      IBRNICDTL_GLACC_CODE,
                                      MIN (IBRNICDTL_FROM_DATE) MAX_DATE
                                 FROM IBRNINTCALCDTL, MIG_DETAIL
                                WHERE     IBRNICDTL_BRN_CODE = BRANCH_CODE
                                      AND MIG_END_DATE BETWEEN '01-MAR-2016'
                                                           AND '31-MAR-2016'
                             GROUP BY BRANCH_CODE, IBRNICDTL_GLACC_CODE)) B
           WHERE     A.BRANCH_CODE = B.IBRNICDTL_BRN_CODE
                 AND A.GL_CODE = B.IBRNICDTL_GLACC_CODE)
   LOOP
      UPDATE IBRNINTCALC
         SET IBRNINTCALC_INT_FROM_DATE = IDX.IBRNICDTL_FROM_DATE,
             IBRNINTCALC_CR_BAL_INT =
                IBRNINTCALC_CR_BAL_INT + IDX.IBRNICDTL_CR_INT_AMOUNT,
             IBRNINTCALC_DB_BAL_INT =
                IBRNINTCALC_DB_BAL_INT + IDX.IBRNICDTL_DB_INT_AMOUNT,
             IBRNINTCALC_CR_BAL_INT_RND =
                IBRNINTCALC_CR_BAL_INT_RND + IDX.IBRNICDTL_CR_INT_AMOUNT,
             IBRNINTCALC_DB_BAL_INT_RND =
                IBRNINTCALC_DB_BAL_INT_RND + IDX.IBRNICDTL_DB_INT_AMOUNT
       WHERE     IBRNINTCALC_ENTITY_NUM = 1
             AND IBRNINTCALC_RUN_NUMBER = IDX.IBRNICDTL_RUN_NUMBER
             AND IBRNINTCALC_BRN_CODE = IDX.IBRNICDTL_BRN_CODE
             AND IBRNINTCALC_GLACC_CODE = IDX.IBRNICDTL_GLACC_CODE
             AND IBRNINTCALC_CURR_CODE = IDX.IBRNICDTL_CURR_CODE
             AND IBRNINTCALC_PROC_DATE = IDX.IBRNICDTL_PROC_DATE;
   END LOOP;
END;






	   
	   
	   
	   
	   
	   

	   

----------------------------- GL voucher --------------------------------





INSERT INTO MANUAL_TRAN
SELECT ROWNUM SERIAL_NUMBER,
       BRANCH_CODE BRANCH_CODE,
       NULL PRODUCT_CODE,
       0 DEBIT_AC_NUMBER,
       0 CREDIT_AC_NUMBER,
       GLIBRIPM_INT_RECVRY_GL_HEAD DEBIT_GL_NUMBER,
       GLIBRIPM_INCOME_HEAD CREDIT_GL_NUMBER,
       ABS(INTEREST_AMOUNT) DEBIT_AMOUNT,
       ABS(INTEREST_AMOUNT) CREDIT_AMOUNT,
       NULL BATCH_NUMBER,
       NULL ACNTS_CLOSER_DATE,
       'SBG interest accrual' NARATION,
       NULL CONTRACT_NUMBER,
       NULL INT_CHECK_PREF,
       NULL INT_CHECK_NUM,
       NULL INST_DATE,
       NULL BASE_CURR_CODE,
       NULL BASE_CURR_CONV_RATE,
       NULL TRAN_BASE_CURR_EQ_AMT
  FROM GLIBRINTPM TEST_A,
       (SELECT A.BRANCH_CODE,
               B.IBRNICDTL_GLACC_CODE GL_CODE,
                 ROUND ( (A.MIG_BALANCE * 6) / 36000, 0)
               * (B.IBRNICDTL_UPTO_DATE - A.MIG_DATE)
                  INTEREST_AMOUNT
          FROM (SELECT BRANCH_CODE BRANCH_CODE,
                       MIG_END_DATE MIG_DATE,
                       GLSUM_GLACC_CODE GL_CODE,
                       (GLSUM_BC_CR_SUM - GLSUM_BC_DB_SUM) MIG_BALANCE
                  FROM MIG_DETAIL, GLSUM2016
                 WHERE     BRANCH_CODE = GLSUM_BRANCH_CODE
                       AND MIG_END_DATE = GLSUM_TRAN_DATE
                       AND GLSUM_ENTITY_NUM = 1
                       AND GLSUM_GLACC_CODE IN
                              (SELECT EXTGL_ACCESS_CODE
                                 FROM EXTGL, GLMAST
                                WHERE     GL_NUMBER = EXTGL_GL_HEAD
                                      AND GL_NUMBER IN (216, 217))
                       AND MIG_END_DATE BETWEEN '01-MAR-2016'
                                            AND '31-MAR-2016') A,
               (SELECT I.IBRNICDTL_RUN_NUMBER,
                       I.IBRNICDTL_BRN_CODE,
                       I.IBRNICDTL_GLACC_CODE,
                       I.IBRNICDTL_UPTO_DATE
                  FROM IBRNINTCALCDTL I
                 WHERE (I.IBRNICDTL_BRN_CODE,
                        I.IBRNICDTL_GLACC_CODE,
                        I.IBRNICDTL_UPTO_DATE) IN
                          (  SELECT BRANCH_CODE,
                                    IBRNICDTL_GLACC_CODE,
                                    MIN (IBRNICDTL_FROM_DATE) MAX_DATE
                               FROM IBRNINTCALCDTL, MIG_DETAIL
                              WHERE     IBRNICDTL_BRN_CODE = BRANCH_CODE
                                    AND MIG_END_DATE BETWEEN '01-MAR-2016'
                                                         AND '31-MAR-2016'
                           GROUP BY BRANCH_CODE, IBRNICDTL_GLACC_CODE)) B
         WHERE     A.BRANCH_CODE = B.IBRNICDTL_BRN_CODE
               AND A.GL_CODE = B.IBRNICDTL_GLACC_CODE) TEST_B
 WHERE     TEST_A.GLIBRIPM_INTER_GL_HEAD = TEST_B.GL_CODE
       AND TEST_B.INTEREST_AMOUNT < 0 ;
	   
	   
	   

INSERT INTO MANUAL_TRAN	   
SELECT ROWNUM SERIAL_NUMBER,
       BRANCH_CODE BRANCH_CODE,
       NULL PRODUCT_CODE,
       0 DEBIT_AC_NUMBER,
       0 CREDIT_AC_NUMBER,
       GLIBRIPM_EXPENSE_HEAD DEBIT_GL_NUMBER,
       GLIBRIPM_INT_PAY_GL_HEAD CREDIT_GL_NUMBER,
       ABS(INTEREST_AMOUNT) DEBIT_AMOUNT,
       ABS(INTEREST_AMOUNT) CREDIT_AMOUNT,
       NULL BATCH_NUMBER,
       NULL ACNTS_CLOSER_DATE,
       'SBG interest accrual' NARATION,
       NULL CONTRACT_NUMBER,
       NULL INT_CHECK_PREF,
       NULL INT_CHECK_NUM,
       NULL INST_DATE,
       NULL BASE_CURR_CODE,
       NULL BASE_CURR_CONV_RATE,
       NULL TRAN_BASE_CURR_EQ_AMT
  FROM GLIBRINTPM TEST_A,
       (SELECT A.BRANCH_CODE,
               B.IBRNICDTL_GLACC_CODE GL_CODE,
                 ROUND ( (A.MIG_BALANCE * 6) / 36000, 0)
               * (B.IBRNICDTL_UPTO_DATE - A.MIG_DATE)
                  INTEREST_AMOUNT
          FROM (SELECT BRANCH_CODE BRANCH_CODE,
                       MIG_END_DATE MIG_DATE,
                       GLSUM_GLACC_CODE GL_CODE,
                       (GLSUM_BC_CR_SUM - GLSUM_BC_DB_SUM) MIG_BALANCE
                  FROM MIG_DETAIL, GLSUM2016
                 WHERE     BRANCH_CODE = GLSUM_BRANCH_CODE
                       AND MIG_END_DATE = GLSUM_TRAN_DATE
                       AND GLSUM_ENTITY_NUM = 1
                       AND GLSUM_GLACC_CODE IN
                              (SELECT EXTGL_ACCESS_CODE
                                 FROM EXTGL, GLMAST
                                WHERE     GL_NUMBER = EXTGL_GL_HEAD
                                      AND GL_NUMBER IN (216, 217))
                       AND MIG_END_DATE BETWEEN '01-MAR-2016'
                                            AND '31-MAR-2016') A,
               (SELECT I.IBRNICDTL_RUN_NUMBER,
                       I.IBRNICDTL_BRN_CODE,
                       I.IBRNICDTL_GLACC_CODE,
                       I.IBRNICDTL_UPTO_DATE
                  FROM IBRNINTCALCDTL I
                 WHERE (I.IBRNICDTL_BRN_CODE,
                        I.IBRNICDTL_GLACC_CODE,
                        I.IBRNICDTL_UPTO_DATE) IN
                          (  SELECT BRANCH_CODE,
                                    IBRNICDTL_GLACC_CODE,
                                    MIN (IBRNICDTL_FROM_DATE) MAX_DATE
                               FROM IBRNINTCALCDTL, MIG_DETAIL
                              WHERE     IBRNICDTL_BRN_CODE = BRANCH_CODE
                                    AND MIG_END_DATE BETWEEN '01-MAR-2016'
                                                         AND '31-MAR-2016'
                           GROUP BY BRANCH_CODE, IBRNICDTL_GLACC_CODE)) B
         WHERE     A.BRANCH_CODE = B.IBRNICDTL_BRN_CODE
               AND A.GL_CODE = B.IBRNICDTL_GLACC_CODE) TEST_B
 WHERE     TEST_A.GLIBRIPM_INTER_GL_HEAD = TEST_B.GL_CODE
       AND TEST_B.INTEREST_AMOUNT > 0 ;





	   
	   
	   
	   

	   
	   
---------------------------- IBRNINTCALCDTL insert ----------------------------------

INSERT INTO IBRNINTCALCDTL 
SELECT 1 IBRNICDTL_ENTITY_NUM,
         B.IBRNICDTL_RUN_NUMBER IBRNICDTL_RUN_NUMBER,
         A.BRANCH_CODE IBRNICDTL_BRN_CODE,
         B.IBRNICDTL_GLACC_CODE IBRNICDTL_GLACC_CODE,
         'BDT' IBRNICDTL_CURR_CODE,
         '31-MAR-2016' IBRNICDTL_PROC_DATE,
         1 IBRNICDTL_DTL_SL_NUM,
         A.MIG_DATE IBRNICDTL_FROM_DATE,
         B.IBRNICDTL_UPTO_DATE - 1 IBRNICDTL_UPTO_DATE,
         A.MIG_BALANCE IBRNICDTL_BALANCE,
         CASE WHEN A.MIG_BALANCE > 0 THEN 6 ELSE 0 END IBRNICDTL_CR_INT_RATE,
         CASE WHEN A.MIG_BALANCE < 0 THEN 6 ELSE 0 END IBRNICDTL_DB_INT_RATE,
         (B.IBRNICDTL_UPTO_DATE - A.MIG_DATE) IBRNICDTL_NUM_OF_DAYS,
         CASE WHEN A.MIG_BALANCE < 0 THEN ABS (A.MIG_BALANCE) ELSE 0 END
            IBRNICDTL_DB_PRODUCT,
         CASE WHEN A.MIG_BALANCE > 0 THEN ABS (A.MIG_BALANCE) ELSE 0 END
            IBRNICDTL_CR_PRODUCT,
         CASE
            WHEN A.MIG_BALANCE > 0
            THEN
               ABS (ROUND ( (A.MIG_BALANCE * 6) / 36000, 0)) * (B.IBRNICDTL_UPTO_DATE - A.MIG_DATE)
            ELSE
               0
         END
            IBRNICDTL_CR_INT_AMOUNT,
         CASE
            WHEN A.MIG_BALANCE < 0
            THEN
               ABS (ROUND ( (A.MIG_BALANCE * 6) / 36000, 0)) * (B.IBRNICDTL_UPTO_DATE - A.MIG_DATE)
            ELSE
               0
         END
            IBRNICDTL_DB_INT_AMOUNT
    FROM (SELECT BRANCH_CODE BRANCH_CODE,
                 MIG_END_DATE MIG_DATE,
                 GLSUM_GLACC_CODE GL_CODE,
                 (GLSUM_BC_CR_SUM - GLSUM_BC_DB_SUM) MIG_BALANCE
            FROM MIG_DETAIL, GLSUM2016
           WHERE     BRANCH_CODE = GLSUM_BRANCH_CODE
                 AND MIG_END_DATE = GLSUM_TRAN_DATE
                 AND GLSUM_ENTITY_NUM = 1
                 AND GLSUM_GLACC_CODE IN
                        (SELECT EXTGL_ACCESS_CODE
                           FROM EXTGL, GLMAST
                          WHERE     GL_NUMBER = EXTGL_GL_HEAD
                                AND GL_NUMBER IN (216, 217))
                 AND MIG_END_DATE BETWEEN '01-MAR-2016' AND '31-MAR-2016') A,
         (SELECT I.IBRNICDTL_RUN_NUMBER,
                 I.IBRNICDTL_BRN_CODE,
                 I.IBRNICDTL_GLACC_CODE,
                 I.IBRNICDTL_UPTO_DATE
            FROM IBRNINTCALCDTL I
           WHERE (I.IBRNICDTL_BRN_CODE,
                  I.IBRNICDTL_GLACC_CODE,
                  I.IBRNICDTL_UPTO_DATE) IN
                    (  SELECT BRANCH_CODE,
                              IBRNICDTL_GLACC_CODE,
                              MIN (IBRNICDTL_FROM_DATE) MAX_DATE
                         FROM IBRNINTCALCDTL, MIG_DETAIL
                        WHERE     IBRNICDTL_BRN_CODE = BRANCH_CODE
                              AND MIG_END_DATE BETWEEN '01-MAR-2016'
                                                   AND '31-MAR-2016'
                     GROUP BY BRANCH_CODE, IBRNICDTL_GLACC_CODE)) B
   WHERE     A.BRANCH_CODE = B.IBRNICDTL_BRN_CODE
         AND A.GL_CODE = B.IBRNICDTL_GLACC_CODE
ORDER BY A.MIG_DATE, A.BRANCH_CODE, A.GL_CODE;


