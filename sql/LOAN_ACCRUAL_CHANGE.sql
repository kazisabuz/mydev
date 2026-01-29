/*Rectification script of the loan account accrual process.*/
DECLARE
  V_COUNT NUMBER := 0;
BEGIN
  FOR IDX IN (SELECT TEM.LOANIA_BRN_CODE,
                     TEM.IACLINK_INTERNAL_ACNUM,
                     TEM.LOANIA_VALUE_DATE,
                     TEM.LOANIA_ACCRUAL_DATE,
                     TEM.LOANIA_INT_ON_AMT -
                     NVL(L.LOANIAMRR_TOTAL_NEW_INT_AMT, 0) DIFF
                FROM (SELECT T.LOANIA_BRN_CODE,
                             T.LOANIA_ACNT_NUM,
                             I.IACLINK_INTERNAL_ACNUM,
                             T.LOANIA_VALUE_DATE,
                             T.LOANIA_ACCRUAL_DATE,
                             T.LOANIA_INT_ON_AMT
                        FROM TEMP_LOANIA T,
                             IACLINK     I,
                             ACNTS       A,
                             LOANACNTS   LOAN
                       WHERE T.LOANIA_ACNT_NUM = I.IACLINK_ACTUAL_ACNUM
                         AND I.IACLINK_ENTITY_NUM = 1
                         AND A.ACNTS_ENTITY_NUM = 1
                         AND A.ACNTS_INTERNAL_ACNUM =
                             I.IACLINK_INTERNAL_ACNUM
                         AND LOAN.LNACNT_ENTITY_NUM = 1
                         AND LOAN.LNACNT_INTERNAL_ACNUM =
                             A.ACNTS_INTERNAL_ACNUM
                         AND LOAN.LNACNT_INT_APPLIED_UPTO_DATE <
                             T.LOANIA_ACCRUAL_DATE
                         AND A.ACNTS_CLOSURE_DATE IS NULL) TEM
                LEFT JOIN LOANIAMRR L
                  ON (L.LOANIAMRR_ENTITY_NUM = 1 AND
                     L.LOANIAMRR_BRN_CODE = TEM.LOANIA_BRN_CODE AND
                     L.LOANIAMRR_ACNT_NUM = TEM.IACLINK_INTERNAL_ACNUM AND
                     L.LOANIAMRR_VALUE_DATE = TEM.LOANIA_VALUE_DATE AND
                     L.LOANIAMRR_ACCRUAL_DATE = TEM.LOANIA_ACCRUAL_DATE)
               WHERE TEM.LOANIA_INT_ON_AMT -
                     NVL(L.LOANIAMRR_TOTAL_NEW_INT_AMT, 0) <> 0)
  
   LOOP
    UPDATE LOANIAMRR LM
       SET LM.LOANIAMRR_TOTAL_NEW_INT_AMT = LM.LOANIAMRR_TOTAL_NEW_INT_AMT -
                                            IDX.DIFF,
           LM.LOANIAMRR_INT_AMT           = LM.LOANIAMRR_INT_AMT - IDX.DIFF,
           LOANIAMRR_INT_AMT_RND          = LM.LOANIAMRR_INT_AMT_RND -
                                            IDX.DIFF
     WHERE LM.LOANIAMRR_ENTITY_NUM = 1
       AND LM.LOANIAMRR_BRN_CODE = IDX.LOANIA_BRN_CODE
       AND LM.LOANIAMRR_ACNT_NUM = IDX.IACLINK_INTERNAL_ACNUM
       AND LM.LOANIAMRR_VALUE_DATE = IDX.LOANIA_VALUE_DATE
       AND LM.LOANIAMRR_ACCRUAL_DATE = IDX.LOANIA_ACCRUAL_DATE;
  
    UPDATE LOANIAMRRDTL LM
       SET LM.LOANIAMRRDTL_UPTO_AMT = LM.LOANIAMRRDTL_UPTO_AMT - IDX.DIFF,
           LM.LOANIAMRRDTL_INT_AMT  = LM.LOANIAMRRDTL_INT_AMT - IDX.DIFF,
           LOANIAMRRDTL_INT_AMT_RND = LM.LOANIAMRRDTL_INT_AMT_RND - IDX.DIFF
     WHERE LM.LOANIAMRRDTL_ENTITY_NUM = 1
       AND LM.LOANIAMRRDTL_BRN_CODE = IDX.LOANIA_BRN_CODE
       AND LM.LOANIAMRRDTL_ACNT_NUM = IDX.IACLINK_INTERNAL_ACNUM
       AND LM.LOANIAMRRDTL_VALUE_DATE = IDX.LOANIA_VALUE_DATE
       AND LM.LOANIAMRRDTL_ACCRUAL_DATE = IDX.LOANIA_ACCRUAL_DATE;
    V_COUNT := V_COUNT + SQL%ROWCOUNT;
  END LOOP;
  DBMS_OUTPUT.put_line(V_COUNT);
END;










SELECT LNPRDAC_INT_ACCR_GL , LNPRDAC_INT_INCOME_GL, SUM(DIFF) FROM (
SELECT TEM.LNPRDAC_INT_ACCR_GL,
       TEM.LNPRDAC_INT_INCOME_GL,
       TEM.LOANIA_BRN_CODE,
       TEM.IACLINK_INTERNAL_ACNUM,
       TEM.LOANIA_VALUE_DATE,
       TEM.LOANIA_ACCRUAL_DATE,
       TEM.LOANIA_INT_ON_AMT - NVL(L.LOANIAMRR_TOTAL_NEW_INT_AMT, 0) DIFF
  FROM (SELECT LP.LNPRDAC_INT_ACCR_GL,
               LP.LNPRDAC_INT_INCOME_GL,
               T.LOANIA_BRN_CODE,
               T.LOANIA_ACNT_NUM,
               I.IACLINK_INTERNAL_ACNUM,
               T.LOANIA_VALUE_DATE,
               T.LOANIA_ACCRUAL_DATE,
               T.LOANIA_INT_ON_AMT
          FROM TEMP_LOANIA T,
               IACLINK     I,
               ACNTS       A,
               LOANACNTS   LOAN,
               LNPRODACPM  LP
         WHERE T.LOANIA_ACNT_NUM = I.IACLINK_ACTUAL_ACNUM
           AND LP.LNPRDAC_PROD_CODE = A.ACNTS_PROD_CODE
           AND I.IACLINK_ENTITY_NUM = 1
           AND A.ACNTS_ENTITY_NUM = 1
           AND A.ACNTS_INTERNAL_ACNUM = I.IACLINK_INTERNAL_ACNUM
           AND LOAN.LNACNT_ENTITY_NUM = 1
           AND LOAN.LNACNT_INTERNAL_ACNUM = A.ACNTS_INTERNAL_ACNUM
           AND LOAN.LNACNT_INT_APPLIED_UPTO_DATE < T.LOANIA_ACCRUAL_DATE
           AND A.ACNTS_CLOSURE_DATE IS NULL) TEM
  LEFT JOIN LOANIAMRR L
    ON (L.LOANIAMRR_ENTITY_NUM = 1 AND
       L.LOANIAMRR_BRN_CODE = TEM.LOANIA_BRN_CODE AND
       L.LOANIAMRR_ACNT_NUM = TEM.IACLINK_INTERNAL_ACNUM AND
       L.LOANIAMRR_VALUE_DATE = TEM.LOANIA_VALUE_DATE AND
       L.LOANIAMRR_ACCRUAL_DATE = TEM.LOANIA_ACCRUAL_DATE)
 WHERE TEM.LOANIA_INT_ON_AMT - NVL(L.LOANIAMRR_TOTAL_NEW_INT_AMT, 0) <> 0)
 GROUP BY LNPRDAC_INT_ACCR_GL , LNPRDAC_INT_INCOME_GL ;
 
 
DECLARE
V_BATCH_NUMBER NUMBER;
BEGIN
   FOR IND IN (SELECT SERIAL_NUMBER,BRANCH_CODE, DEBIT_AC_NUMBER, CREDIT_AC_NUMBER, DEBIT_GL_NUMBER, CREDIT_GL_NUMBER, DEBIT_AMOUNT, CREDIT_AMOUNT, BATCH_NUMBER, NARATION
FROM MANUAL_TRAN WHERE BATCH_NUMBER IS NULL
ORDER BY BRANCH_CODE)
   LOOP
        SP_AUTOPOST_TRANSACTION_MANUAL(
                            IND.BRANCH_CODE, -- branch code
                            IND.DEBIT_GL_NUMBER, -- debit gl
                            IND.CREDIT_GL_NUMBER, -- credit gl 
                            IND.DEBIT_AMOUNT, -- debit amount
                            IND.CREDIT_AMOUNT, -- credit amount 
                            IND.DEBIT_AC_NUMBER, -- debit account 
                            0, -- DR contract number
                            0, -- CR contract number
                            IND.CREDIT_AC_NUMBER, -- credit account
                            0, -- advice num debit
                            NULL,-- advice date debit 
                            0, -- advice num credit
                            NULL, -- advice date credit
                            'BDT', -- currency
                            '127.0.0.1', -- terminal id 
                            'INTELECT', -- user
                            IND.NARATION, -- narration
                            V_BATCH_NUMBER -- BATCH NUMBER
                            );
                            
              UPDATE MANUAL_TRAN
        SET BATCH_NUMBER=V_BATCH_NUMBER
        WHERE DEBIT_GL_NUMBER=IND.DEBIT_GL_NUMBER
        AND BRANCH_CODE=IND.BRANCH_CODE
        AND CREDIT_GL_NUMBER=IND.CREDIT_GL_NUMBER
        AND SERIAL_NUMBER=IND.SERIAL_NUMBER;
        
   END LOOP;
END;