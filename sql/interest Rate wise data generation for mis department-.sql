1. DELETE FROM BRANCHWISE_DATA_DEP;
  DELETE FROM BRANCHWISE_DATA_LOAN;

2. Change date range that we want to generate data, for loan we need to execute:

  EXEC SP_MIS_DATA_BRANCHWISE_LOAN(1, '01-JUL-2019', '31-JUL-2019');
  
  for deposit we will execute a procedure that will create multiple thread in two instance
  
  first need to modify SP_GEN_MIS_DATA_THREAD. Date range need to be modified in this procedure 
  to run deposit related procedure(not CIB data). Compile the modified procedure.
  
  EXEC SP_GEN_MIS_DATA_THREAD;
  
3. Check using following query:
   
  select count( distinct branch_code) from BRANCHWISE_DATA_LOAN;
  
  select count( distinct branch_code) from BRANCHWISE_DATA_DEP;
  
4. Create excel using following scripts:

  
SELECT REPORTING_DATE,
      LOAN_CODE,
      CLASSIFICATION_CODE,
      INT_RATE,
      SUM (BALANCE)
 FROM BRANCHWISE_DATA_LOAN
GROUP BY REPORTING_DATE,
      LOAN_CODE,
      CLASSIFICATION_CODE,
      INT_RATE
HAVING SUM (BALANCE) <> 0
ORDER BY LOAN_CODE, CLASSIFICATION_CODE, INT_RATE;
--================================
SELECT REPORTING_DATE,
      F12,
      TYPE_OF_DEPOSIT,
      INT_RATE,
      SUM (BALANCE)
 FROM BRANCHWISE_DATA_DEP
GROUP BY REPORTING_DATE,
      F12,
      TYPE_OF_DEPOSIT,
      INT_RATE
HAVING SUM (BALANCE) <> 0
ORDER BY F12, TYPE_OF_DEPOSIT, INT_RATE;