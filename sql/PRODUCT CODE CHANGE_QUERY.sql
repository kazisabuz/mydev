/*Changing the product code of a particular account. The initial idea was to change the product code of the loan accounts only. But later, we managed the changes for all type of accounts.*/
DECLARE
  V_BATCH_NUMBER           NUMBER;
  V_BALANCE_TRANSFER_BATCH NUMBER; -- BATCH NUMBER
  V_PREVIOUS_ACCRUAL_BATCH NUMBER; -- BATCH NUMBER
  V_NEW_ACCRUAL_BATCH      NUMBER;
  V_ERROR_MSG              VARCHAR2(1000);
BEGIN
  FOR IND IN (SELECT BRANCH_CODE,
                     ACCTUAL_ACCOUNT_NUMBER,
                     PREVIOUS_ACCOUNT_TYPE,
                     NEW_ACCOUNT_TYPE,
                     PREVIOUS_ACCOUNT_SUB_TYPE,
                     NEW_ACCOUNT_SUB_TYPE,
                     PREVIOUS_PRODUCT_CODE,
                     NEW_PRODUCT_CODE,
                     REMARKS
                FROM PRODUCT_CHANGE
               WHERE BALANCE_TRANSFER_BATCH IS NULL
                 AND PREVIOUS_ACCRUAL_BATCH IS NULL
                 AND NEW_ACCRUAL_BATCH IS NULL
                 AND ERRORMSG IS NULL
               ORDER BY ACCTUAL_ACCOUNT_NUMBER) LOOP
    SP_PRODUCT_CODE_CHANGE(IND.BRANCH_CODE, -- BRANCH CODE
                           IND.ACCTUAL_ACCOUNT_NUMBER, --  
                           IND.PREVIOUS_ACCOUNT_TYPE, --   
                           IND.NEW_ACCOUNT_TYPE, --  
                           IND.PREVIOUS_ACCOUNT_SUB_TYPE, --   
                           IND.NEW_ACCOUNT_SUB_TYPE, --  
                           IND.PREVIOUS_PRODUCT_CODE, --  
                           IND.NEW_PRODUCT_CODE, --  
                           IND.REMARKS,
                           V_BALANCE_TRANSFER_BATCH, --  
                           V_PREVIOUS_ACCRUAL_BATCH, --  
                           V_NEW_ACCRUAL_BATCH,
                           V_ERROR_MSG --  
                           );

    UPDATE PRODUCT_CHANGE P
       SET P.BALANCE_TRANSFER_BATCH = V_BALANCE_TRANSFER_BATCH,
           P.PREVIOUS_ACCRUAL_BATCH = V_PREVIOUS_ACCRUAL_BATCH,
           P.NEW_ACCRUAL_BATCH      = V_NEW_ACCRUAL_BATCH,
           P.ERRORMSG                = V_ERROR_MSG
     WHERE P.ACCTUAL_ACCOUNT_NUMBER = IND.ACCTUAL_ACCOUNT_NUMBER;
  
  END LOOP;
END;
/