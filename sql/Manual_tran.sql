DECLARE
V_BATCH_NUMBER NUMBER;
BEGIN
  FOR IND IN (SELECT SERIAL_NUMBER,BRANCH_CODE, DEBIT_AC_NUMBER, CREDIT_AC_NUMBER, DEBIT_GL_NUMBER, CREDIT_GL_NUMBER, DEBIT_AMOUNT, CREDIT_AMOUNT, BATCH_NUMBER,CONTRACT_NUMBER, NARATION
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
                           0 ,-- CR contract number
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