 DECLARE
V_BATCH_NUMBER NUMBER;
BEGIN
  FOR IND IN (SELECT SERIAL_NUMBER, TRAN_BRN, TRAN_ACCOUNT_BRN, PRODUCT_CODE, DEBIT_AC_NUMBER, CREDIT_AC_NUMBER, DEBIT_GL_TRAN, CREDIT_GL_TRAN, DEBIT_GL_TRANAC, CREDIT_GL_TRANAC, DEBIT_AMOUNT, CREDIT_AMOUNT, BATCH_NUMBER, ACNTS_CLOSER_DATE, NARATION
FROM MANUAL_TRAN_INR WHERE BATCH_NUMBER IS NULL
ORDER BY BATCH_NUMBER)
  LOOP
       SP_AUTOPOST_INTER_BRAN(
                           IND.TRAN_BRN, --transaction branch code
                           IND.TRAN_ACCOUNT_BRN,-- transaction accounting branch code
                           IND.DEBIT_GL_TRAN, --transaction branch debit gl
                           IND.CREDIT_GL_TRAN, --transaction branch credit gl 
                           IND.DEBIT_GL_TRANAC, --- transaction branch debit gl code.
                           IND.CREDIT_GL_TRANAC,
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
                           
             UPDATE MANUAL_TRAN_INR
       SET BATCH_NUMBER=V_BATCH_NUMBER
       WHERE TRAN_BRN=IND.TRAN_BRN
       AND SERIAL_NUMBER=IND.SERIAL_NUMBER;
       
  END LOOP;
END;
/