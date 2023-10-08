CREATE OR REPLACE FUNCTION FN_GET_ACCRUAL_AMOUNT (
   P_ENTITY_NUM      NUMBER,
   P_INT_ACC_NUM     NUMBER,
   P_BRN_CODE        NUMBER,
   P_PRODUCT_CODE    NUMBER)
   RETURN NUMBER
IS
   V_PRODUCT_FOR_DEPOSITS       VARCHAR2 (1);
   V_PRODUCT_FOR_LOANS          VARCHAR2 (1);
   V_PRODUCT_FOR_RUN_ACS        VARCHAR2 (1);
   V_PRODUCT_CONTRACT_ALLOWED   VARCHAR2 (1);
   V_ACCRUAL_AMOUNT             NUMBER (18, 3);
BEGIN
   BEGIN
      SELECT PRODUCT_FOR_DEPOSITS,
             PRODUCT_FOR_LOANS,
             PRODUCT_FOR_RUN_ACS,
             PRODUCT_CONTRACT_ALLOWED
        INTO V_PRODUCT_FOR_DEPOSITS,
             V_PRODUCT_FOR_LOANS,
             V_PRODUCT_FOR_RUN_ACS,
             V_PRODUCT_CONTRACT_ALLOWED
        FROM PRODUCTS
       WHERE PRODUCT_CODE = P_PRODUCT_CODE;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 0;
   END;

   IF V_PRODUCT_FOR_LOANS = '1'
   THEN
      BEGIN
         SELECT ABS (SUM (NVL (LOANIAMRR_INT_AMT_RND, 0))) ACCRUAL_AMT
           INTO V_ACCRUAL_AMOUNT
           FROM LOANIAMRR, LOANACNTS
          WHERE     LOANIAMRR_ENTITY_NUM = P_ENTITY_NUM
                AND LOANIAMRR_BRN_CODE = P_BRN_CODE
                AND LOANIAMRR_ACNT_NUM = LNACNT_INTERNAL_ACNUM
                AND LNACNT_INTERNAL_ACNUM = P_INT_ACC_NUM
                AND LOANIAMRR_VALUE_DATE > LNACNT_INT_ACCR_UPTO
                AND LNACNT_ENTITY_NUM = P_ENTITY_NUM;
      EXCEPTION
         WHEN OTHERS
         THEN
            V_ACCRUAL_AMOUNT := 0;
      END;
   ELSE
      IF V_PRODUCT_FOR_DEPOSITS = '1'
      THEN
         IF V_PRODUCT_FOR_RUN_ACS = '1'
         THEN
            BEGIN
               SELECT SUM (CREDIT_INT) - SUM (DEBIT_INT) ACCRUAL_AMT
                 INTO V_ACCRUAL_AMOUNT
                 FROM (SELECT SBCAIA_INT_ACCR_DB_CR,
                              CASE
                                 WHEN SBCAIA_INT_ACCR_DB_CR = 'C'
                                 THEN
                                    NVL (SBCAIA_AC_INT_ACTUAL_ACCR_AMT, 0)
                              END
                                 CREDIT_INT,
                              CASE
                                 WHEN SBCAIA_INT_ACCR_DB_CR = 'D'
                                 THEN
                                    NVL (SBCAIA_AC_INT_ACTUAL_ACCR_AMT, 0)
                              END
                                 DEBIT_INT
                         FROM SBCAIA
                        WHERE     SBCAIA_ENTITY_NUM = P_ENTITY_NUM
                              AND SBCAIA_BRN_CODE = P_BRN_CODE
                              AND SBCAIA_INTERNAL_ACNUM = P_INT_ACC_NUM);
            EXCEPTION
               WHEN OTHERS
               THEN
                  V_ACCRUAL_AMOUNT := 0;
            END;
         ELSE
            IF V_PRODUCT_CONTRACT_ALLOWED = '0'
            THEN
               BEGIN
                  SELECT NVL (SUM (DEPIA_BC_INT_ACCR_AMT), 0) ACCRUAL_AMT
                    INTO V_ACCRUAL_AMOUNT
                    FROM PBDCONTRACT, DEPIA
                   WHERE     PBDCONT_ENTITY_NUM = P_ENTITY_NUM
                         AND PBDCONT_BRN_CODE = DEPIA_BRN_CODE
                         AND DEPIA_BRN_CODE = P_BRN_CODE
                         AND PBDCONT_DEP_AC_NUM = P_INT_ACC_NUM
                         AND DEPIA_DATE_OF_ENTRY >
                                NVL (PBDCONT_INT_PAID_UPTO, PBDCONT_EFF_DATE)
                         AND DEPIA_ENTITY_NUM = P_ENTITY_NUM
                         AND DEPIA_INTERNAL_ACNUM = PBDCONT_DEP_AC_NUM
                         AND DEPIA_ENTRY_TYPE = 'IA'
                         AND PBDCONT_CLOSURE_DATE IS NULL;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     V_ACCRUAL_AMOUNT := 0;
               END;
            ELSE
               BEGIN
                  SELECT SUM (IA_AMT) - SUM (IP_AMT) ACCRUAL_AMT
                    INTO V_ACCRUAL_AMOUNT
                    FROM (SELECT DEPPR_TYPE_OF_DEP,
                                 DEPIA_ENTRY_TYPE,
                                 NVL (
                                    CASE
                                       WHEN DEPIA_ENTRY_TYPE = 'IA'
                                       THEN
                                          NVL (DEPIA_BC_INT_ACCR_AMT, 0)
                                    END,
                                    0)
                                    IA_AMT,
                                 NVL (
                                    CASE
                                       WHEN     DEPIA_ENTRY_TYPE = 'IP'
                                            
                                       THEN
                                          NVL (DEPIA_BC_INT_ACCR_AMT, 0)
                                    END,
                                    0)
                                    IP_AMT
                            FROM DEPIA, ACNTS, DEPPROD
                           WHERE     DEPIA_ENTITY_NUM = P_ENTITY_NUM
                                 AND DEPIA_INTERNAL_ACNUM = P_INT_ACC_NUM
                                 AND DEPIA_BRN_CODE = P_BRN_CODE
                                 AND DEPPR_PROD_CODE = ACNTS_PROD_CODE
                                 AND ACNTS_ENTITY_NUM = P_ENTITY_NUM
                                 AND ACNTS_BRN_CODE = DEPIA_BRN_CODE
                                 AND ACNTS_INTERNAL_ACNUM =
                                        DEPIA_INTERNAL_ACNUM);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     V_ACCRUAL_AMOUNT := 0;
               END;
            END IF;
         END IF;
      END IF;
   END IF;

   
   RETURN V_ACCRUAL_AMOUNT;
END;
/
