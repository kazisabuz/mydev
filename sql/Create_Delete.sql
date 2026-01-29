/*Script to generate the create backup table script from the whole schema for a particular branch*/
SELECT TABLE_NAME,
      NUM_ROWS,
      FN_COL_NAME (TABLE_NAME),
      CASE
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRN') != 0
         THEN
            'BRANCH_CODE'
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRAN') != 0
         THEN
            'BRANCH_CODE'
          WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRCODE') != 0
         THEN
            'BRANCH_CODE'  
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'INTER') != 0
         THEN
            'ACCOUNT_NUMBER'
      END IDENTIFIER,
      'CREATE TABLE '|| TABLE_NAME || '_231017 AS SELECT * FROM ' ||TABLE_NAME || ' WHERE ' ||FN_COL_NAME ( TABLE_NAME ) || ' IN  (SELECT A.ACNTS_INTERNAL_ACNUM FROM acnts a  WHERE a.ACNTS_BRN_CODE = 1065);' CREATE_STATMENT
 FROM USER_TABLES T
 WHERE NVL(NUM_ROWS,0) <> 0
 AND (CASE
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRN') != 0
         THEN
            'BRANCH_CODE'
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRAN') != 0
         THEN
            'BRANCH_CODE'
          WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRCODE') != 0
         THEN
            'BRANCH_CODE'  
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'INTER') != 0
         THEN
            'ACCOUNT_NUMBER'
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'ACNT') != 0
         THEN
            'ACCOUNT_NUMBER'
      END ) = 'ACCOUNT_NUMBER'
 ORDER BY TABLE_NAME;
 
 
 
 SELECT TABLE_NAME,
      NUM_ROWS,
      FN_COL_NAME (TABLE_NAME),
      CASE
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRN') != 0
         THEN
            'BRANCH_CODE'
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRAN') != 0
         THEN
            'BRANCH_CODE'
          WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRCODE') != 0
         THEN
            'BRANCH_CODE'  
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'INTER') != 0
         THEN
            'ACCOUNT_NUMBER'
      END IDENTIFIER,
      'CREATE TABLE '|| TABLE_NAME || '_231017 AS SELECT * FROM ' ||TABLE_NAME || ' WHERE TO_NUMBER(' ||FN_COL_NAME ( TABLE_NAME ) || ')= 1065;' CREATE_STATMENT
 FROM USER_TABLES T
 WHERE NVL(NUM_ROWS,0) <> 0
 AND (CASE
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRN') != 0
         THEN
            'BRANCH_CODE'
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRAN') != 0
         THEN
            'BRANCH_CODE'
          WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRCODE') != 0
         THEN
            'BRANCH_CODE'  
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'INTER') != 0
         THEN
            'ACCOUNT_NUMBER'
      END ) = 'BRANCH_CODE'
 ORDER BY TABLE_NAME;
 
 
 
 SELECT TABLE_NAME,
      NUM_ROWS,
      FN_COL_NAME (TABLE_NAME),
      CASE
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRN') != 0
         THEN
            'BRANCH_CODE'
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRAN') != 0
         THEN
            'BRANCH_CODE'
          WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRCODE') != 0
         THEN
            'BRANCH_CODE'  
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'INTER') != 0
         THEN
            'ACCOUNT_NUMBER'
      END IDENTIFIER,
      'DELETE FROM '|| TABLE_NAME ||  ' WHERE TO_NUMBER(' ||FN_COL_NAME ( TABLE_NAME ) || ')= 1065;' DELETE_STATMENT
 FROM USER_TABLES T
 WHERE NVL(NUM_ROWS,0) <> 0
 AND (CASE
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRN') != 0
         THEN
            'BRANCH_CODE'
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRAN') != 0
         THEN
            'BRANCH_CODE'
          WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRCODE') != 0
         THEN
            'BRANCH_CODE'  
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'INTER') != 0
         THEN
            'ACCOUNT_NUMBER'
      END ) = 'BRANCH_CODE'
 ORDER BY TABLE_NAME;
 
 
 SELECT TABLE_NAME,
      NUM_ROWS,
      FN_COL_NAME (TABLE_NAME),
      CASE
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRN') != 0
         THEN
            'BRANCH_CODE'
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRAN') != 0
         THEN
            'BRANCH_CODE'
          WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRCODE') != 0
         THEN
            'BRANCH_CODE'  
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'INTER') != 0
         THEN
            'ACCOUNT_NUMBER'
      END IDENTIFIER,
      'DELETE FROM '|| TABLE_NAME || ' WHERE ' ||FN_COL_NAME ( TABLE_NAME ) || ' IN  (SELECT A.ACNTS_INTERNAL_ACNUM FROM acnts a  WHERE a.ACNTS_BRN_CODE = 1065);' DELETE_STATMENT
 FROM USER_TABLES T
 WHERE NVL(NUM_ROWS,0) <> 0
 AND (CASE
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRN') != 0
         THEN
            'BRANCH_CODE'
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRAN') != 0
         THEN
            'BRANCH_CODE'
          WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'BRCODE') != 0
         THEN
            'BRANCH_CODE'  
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'INTER') != 0
         THEN
            'ACCOUNT_NUMBER'
         WHEN INSTR (FN_COL_NAME (TABLE_NAME), 'ACNT') != 0
         THEN
            'ACCOUNT_NUMBER'
      END ) = 'ACCOUNT_NUMBER'
 ORDER BY TABLE_NAME;