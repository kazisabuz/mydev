CREATE OR REPLACE PROCEDURE SP_MACRO_DDPO  IS
  W_BRN_CODE NUMBER(5)  ;
  W_ROWCOUNT NUMBER := 0;
  W_MIG_DATE DATE;
  
BEGIN
  

  DELETE FROM ERRORLOG WHERE TEMPLATE_NAME = 'MIG_DDPO';
  COMMIT;
  
  
  SELECT DISTINCT ACOP_BRANCH_CODE INTO W_BRN_CODE FROM MIG_ACOP_BAL;
  SELECT DISTINCT ACOP_BAL_DATE INTO W_MIG_DATE FROM MIG_ACOP_BAL;

  --- branch code checking

  SELECT COUNT(*)
    INTO W_ROWCOUNT
    FROM (SELECT DDPOISS_INST_NUM_PFX, DDPOISS_INST_NUM
            FROM MIG_DDPO
           GROUP BY DDPOISS_INST_NUM_PFX, DDPOISS_INST_NUM
          HAVING COUNT(*) > 1);

  IF W_ROWCOUNT > 0 THEN
    INSERT INTO ERRORLOG
      (TEMPLATE_NAME, COLUMN_NAME, ROW_COUNT, SUGGESTION, QUERY)
    VALUES
      ('MIG_DDPO',
       'DDPOISS_INST_NUM',
       W_ROWCOUNT,
       'DUPLICATE VALUE IN DDPOISS_INST_NUM_PFX || DDPOISS_INST_NUM',
       'SELECT D.DDPOISS_REMIT_CODE,
       D.DDPOISS_INST_AMT,
       D.DDPOISS_INST_NUM_PFX,
       D.DDPOISS_INST_NUM
  FROM MIG_DDPO D
 WHERE (D.DDPOISS_INST_NUM_PFX, D.DDPOISS_INST_NUM) IN
       (SELECT DDPOISS_INST_NUM_PFX, DDPOISS_INST_NUM
          FROM MIG_DDPO
         GROUP BY DDPOISS_INST_NUM_PFX, DDPOISS_INST_NUM
        HAVING COUNT(*) > 1)');
  END IF;

  SELECT COUNT(*)
    INTO W_ROWCOUNT
    FROM MIG_DDPO
   WHERE DDPOISS_REMIT_CODE = '1'
     AND DDPOISS_BRN_CODE <> W_BRN_CODE;

  IF W_ROWCOUNT > 0 THEN
    INSERT INTO ERRORLOG
      (TEMPLATE_NAME, COLUMN_NAME, ROW_COUNT, SUGGESTION, QUERY)
    VALUES
      ('MIG_DDPO',
       'DDPOISS_BRN_CODE',
       W_ROWCOUNT,
       'DDPOISS_BRN_CODE SHOULD BE MIGRATION BRANCH FOR PAYMENT ORDER',
       'SELECT DDPOISS_BRN_CODE , DDPOISS_REMIT_CODE, DDPOISS_INST_NUM_PFX, DDPOISS_INST_NUM
  FROM MIG_DDPO
 WHERE DDPOISS_REMIT_CODE = ''1'' AND DDPOISS_BRN_CODE <>' ||
       W_BRN_CODE || ';');
  END IF;
  
  SELECT COUNT(*)
    INTO W_ROWCOUNT
    FROM MIG_DDPO
   WHERE DDPOISS_REMIT_CODE = '10'
     AND DDPOISS_BRN_CODE <> W_BRN_CODE;

  IF W_ROWCOUNT > 0 THEN
    INSERT INTO ERRORLOG
      (TEMPLATE_NAME, COLUMN_NAME, ROW_COUNT, SUGGESTION, QUERY)
    VALUES
      ('MIG_DDPO',
       'DDPOISS_BRN_CODE',
       W_ROWCOUNT,
       'DDPOISS_BRN_CODE SHOULD BE MIGRATION BRANCH FOR CALL DEPOSIT PAYMENT ORDER',
       'SELECT DDPOISS_BRN_CODE , DDPOISS_REMIT_CODE, DDPOISS_INST_NUM_PFX, DDPOISS_INST_NUM
  FROM MIG_DDPO
 WHERE DDPOISS_REMIT_CODE = ''10'' AND DDPOISS_BRN_CODE <>' ||
       W_BRN_CODE || ';');
  END IF;

  SELECT COUNT(*)
    INTO W_ROWCOUNT
    FROM MIG_DDPO
   WHERE DDPOISS_REMIT_CODE = '2'
     AND DDPOISS_BRN_CODE = W_BRN_CODE;

  IF W_ROWCOUNT > 0 THEN
    INSERT INTO ERRORLOG
      (TEMPLATE_NAME, COLUMN_NAME, ROW_COUNT, SUGGESTION, QUERY)
    VALUES
      ('MIG_DDPO',
       'DDPOISS_BRN_CODE',
       W_ROWCOUNT,
       'DDPOISS_BRN_CODE SHOULD NOT BE MIGRATION BRANCH FOR DD',
       'SELECT DDPOISS_BRN_CODE , DDPOISS_REMIT_CODE, DDPOISS_INST_NUM_PFX, DDPOISS_INST_NUM
  FROM MIG_DDPO
 WHERE DDPOISS_REMIT_CODE = ''2'' AND DDPOISS_BRN_CODE =' ||
       W_BRN_CODE || ';');
  END IF;
  
  SELECT COUNT(*)
    INTO W_ROWCOUNT
    FROM MIG_DDPO
   WHERE DDPOISS_REMIT_CODE = '3'
     AND DDPOISS_BRN_CODE = W_BRN_CODE;

  IF W_ROWCOUNT > 0 THEN
    INSERT INTO ERRORLOG
      (TEMPLATE_NAME, COLUMN_NAME, ROW_COUNT, SUGGESTION, QUERY)
    VALUES
      ('MIG_DDPO',
       'DDPOISS_BRN_CODE',
       W_ROWCOUNT,
       'DDPOISS_BRN_CODE SHOULD NOT BE MIGRATION BRANCH FOR GOVRNMENT DD',
       'SELECT DDPOISS_BRN_CODE , DDPOISS_REMIT_CODE, DDPOISS_INST_NUM_PFX, DDPOISS_INST_NUM
  FROM MIG_DDPO
 WHERE DDPOISS_REMIT_CODE = ''3'' AND DDPOISS_BRN_CODE =' ||
       W_BRN_CODE || ';');
  END IF;

  SELECT COUNT(*)
    INTO W_ROWCOUNT
    FROM MIG_DDPO
   WHERE DDPOISS_INST_BRN <> W_BRN_CODE;

  IF W_ROWCOUNT > 0 THEN
    INSERT INTO ERRORLOG
      (TEMPLATE_NAME, COLUMN_NAME, ROW_COUNT, SUGGESTION, QUERY)
    VALUES
      ('MIG_DDPO',
       'DDPOISS_INST_BRN',
       W_ROWCOUNT,
       'DDPOISS_INST_BRN SHOULD BE MIGRATION BRANCH',
       'SELECT DDPOISS_BRN_CODE , DDPOISS_REMIT_CODE, DDPOISS_INST_NUM_PFX, DDPOISS_INST_NUM
  FROM MIG_DDPO
 WHERE DDPOISS_INST_BRN <> ' || W_BRN_CODE || ';');
  END IF;

  SELECT COUNT(*)
    INTO W_ROWCOUNT
    FROM MIG_DDPO
   WHERE DDPOISS_INST_BANK IS NULL;

  IF W_ROWCOUNT > 0 THEN
    INSERT INTO ERRORLOG
      (TEMPLATE_NAME, COLUMN_NAME, ROW_COUNT, SUGGESTION, QUERY)
    VALUES
      ('MIG_DDPO',
       'DDPOISS_INST_BANK',
       W_ROWCOUNT,
       'DDPOISS_INST_BANK CAN NOT BE NULL ',
       'SELECT DDPOISS_BRN_CODE , DDPOISS_REMIT_CODE, DDPOISS_INST_NUM_PFX, DDPOISS_INST_NUM, DDPOISS_INST_BANK
  FROM MIG_DDPO
 WHERE DDPOISS_INST_BANK IS NULL;');
  END IF;

  SELECT COUNT(*)
    INTO W_ROWCOUNT
    FROM MIG_DDPO
   WHERE DDPOISS_BENEF_NAME1 IS NULL;

  IF W_ROWCOUNT > 0 THEN
    INSERT INTO ERRORLOG
      (TEMPLATE_NAME, COLUMN_NAME, ROW_COUNT, SUGGESTION, QUERY)
    VALUES
      ('MIG_DDPO',
       'DDPOISS_BENEF_NAME1',
       W_ROWCOUNT,
       'DDPOISS_BENEF_NAME1 CAN NOT BE NULL ',
       'SELECT DDPOISS_BRN_CODE , DDPOISS_REMIT_CODE, DDPOISS_INST_NUM_PFX, DDPOISS_INST_NUM
  FROM MIG_DDPO
 WHERE DDPOISS_BENEF_NAME1 IS NULL;');
  END IF;

  SELECT COUNT(*)
    INTO W_ROWCOUNT
    FROM MIG_DDPO
   WHERE DDPOISS_INST_NUM_PFX IS NULL;

  IF W_ROWCOUNT > 0 THEN
    INSERT INTO ERRORLOG
      (TEMPLATE_NAME, COLUMN_NAME, ROW_COUNT, SUGGESTION, QUERY)
    VALUES
      ('MIG_DDPO',
       'DDPOISS_INST_NUM_PFX',
       W_ROWCOUNT,
       'DDPOISS_INST_NUM_PFX CAN NOT BE NULL ',
       'SELECT DDPOISS_BRN_CODE , DDPOISS_REMIT_CODE, DDPOISS_INST_NUM_PFX, DDPOISS_INST_NUM
  FROM MIG_DDPO
 WHERE DDPOISS_INST_NUM_PFX IS NULL;');
  END IF;

  SELECT COUNT(*)
    INTO W_ROWCOUNT
    FROM MIG_DDPO
   WHERE DDPOISS_INST_NUM IS NULL;

  IF W_ROWCOUNT > 0 THEN
    INSERT INTO ERRORLOG
      (TEMPLATE_NAME, COLUMN_NAME, ROW_COUNT, SUGGESTION, QUERY)
    VALUES
      ('MIG_DDPO',
       'DDPOISS_INST_NUM',
       W_ROWCOUNT,
       'DDPOISS_INST_NUM CAN NOT BE NULL ',
       'SELECT DDPOISS_BRN_CODE , DDPOISS_REMIT_CODE, DDPOISS_INST_NUM_PFX, DDPOISS_INST_NUM
  FROM MIG_DDPO
 WHERE DDPOISS_INST_NUM IS NULL;');
  END IF;

  -- DDPOISS_BRN_CODE    DDPOISS_REMIT_CODE    DDPOISS_ISSUE_DATE

  SELECT COUNT(*)
    INTO W_ROWCOUNT
    FROM MIG_DDPO
   WHERE DDPOISS_BRN_CODE IS NULL;

  IF W_ROWCOUNT > 0 THEN
    INSERT INTO ERRORLOG
      (TEMPLATE_NAME, COLUMN_NAME, ROW_COUNT, SUGGESTION, QUERY)
    VALUES
      ('MIG_DDPO',
       'DDPOISS_BRN_CODE',
       W_ROWCOUNT,
       'DDPOISS_BRN_CODE CAN NOT BE NULL ',
       'SELECT DDPOISS_BRN_CODE , DDPOISS_REMIT_CODE, DDPOISS_INST_NUM_PFX, DDPOISS_INST_NUM
  FROM MIG_DDPO
 WHERE DDPOISS_BRN_CODE IS NULL;');
  END IF;

  SELECT COUNT(*)
    INTO W_ROWCOUNT
    FROM MIG_DDPO
   WHERE DDPOISS_REMIT_CODE IS NULL;

  IF W_ROWCOUNT > 0 THEN
    INSERT INTO ERRORLOG
      (TEMPLATE_NAME, COLUMN_NAME, ROW_COUNT, SUGGESTION, QUERY)
    VALUES
      ('MIG_DDPO',
       'DDPOISS_REMIT_CODE',
       W_ROWCOUNT,
       'DDPOISS_REMIT_CODE CAN NOT BE NULL ',
       'SELECT DDPOISS_BRN_CODE , DDPOISS_REMIT_CODE, DDPOISS_INST_NUM_PFX, DDPOISS_INST_NUM
  FROM MIG_DDPO
 WHERE DDPOISS_REMIT_CODE IS NULL;');
  END IF;

  SELECT COUNT(*)
    INTO W_ROWCOUNT
    FROM MIG_DDPO
   WHERE DDPOISS_ISSUE_DATE IS NULL;

  IF W_ROWCOUNT > 0 THEN
    INSERT INTO ERRORLOG
      (TEMPLATE_NAME, COLUMN_NAME, ROW_COUNT, SUGGESTION, QUERY)
    VALUES
      ('MIG_DDPO',
       'DDPOISS_ISSUE_DATE',
       W_ROWCOUNT,
       'DDPOISS_ISSUE_DATE CAN NOT BE NULL ',
       'SELECT DDPOISS_BRN_CODE , DDPOISS_REMIT_CODE, DDPOISS_INST_NUM_PFX, DDPOISS_INST_NUM, DDPOISS_ISSUE_DATE
  FROM MIG_DDPO
 WHERE DDPOISS_ISSUE_DATE IS NULL;');
  END IF;

  -- DDPOISS_INST_CURRENCY

  SELECT COUNT(*)
    INTO W_ROWCOUNT
    FROM MIG_DDPO
   WHERE DDPOISS_INST_CURRENCY IS NULL;

  IF W_ROWCOUNT > 0 THEN
    INSERT INTO ERRORLOG
      (TEMPLATE_NAME, COLUMN_NAME, ROW_COUNT, SUGGESTION, QUERY)
    VALUES
      ('MIG_DDPO',
       'DDPOISS_INST_CURRENCY',
       W_ROWCOUNT,
       'DDPOISS_INST_CURRENCY CAN NOT BE NULL ',
       'SELECT DDPOISS_BRN_CODE , DDPOISS_REMIT_CODE, DDPOISS_INST_NUM_PFX, DDPOISS_INST_NUM, DDPOISS_ISSUE_DATE, DDPOISS_INST_CURRENCY
  FROM MIG_DDPO
 WHERE DDPOISS_INST_CURRENCY IS NULL;');
  END IF;

  -- DDPOISS_INST_AMT

  SELECT COUNT(*)
    INTO W_ROWCOUNT
    FROM MIG_DDPO
   WHERE DDPOISS_INST_AMT IS NULL;

  IF W_ROWCOUNT > 0 THEN
    INSERT INTO ERRORLOG
      (TEMPLATE_NAME, COLUMN_NAME, ROW_COUNT, SUGGESTION, QUERY)
    VALUES
      ('MIG_DDPO',
       'DDPOISS_INST_AMT',
       W_ROWCOUNT,
       'DDPOISS_INST_AMT CAN NOT BE NULL ',
       'SELECT DDPOISS_BRN_CODE , DDPOISS_REMIT_CODE, DDPOISS_INST_NUM_PFX, DDPOISS_INST_NUM, DDPOISS_ISSUE_DATE, DDPOISS_INST_AMT
  FROM MIG_DDPO
 WHERE DDPOISS_INST_AMT IS NULL;');
  END IF;

  SELECT COUNT(*)
    INTO W_ROWCOUNT
    FROM MIG_DDPO
   WHERE DDPOISS_REMIT_CODE NOT IN (SELECT REMCD_REMIT_CODE FROM REMCD);

  IF W_ROWCOUNT > 0 THEN
    INSERT INTO ERRORLOG
      (TEMPLATE_NAME, COLUMN_NAME, ROW_COUNT, SUGGESTION, QUERY)
    VALUES
      ('MIG_DDPO',
       'DDPOISS_REMIT_CODE',
       W_ROWCOUNT,
       'DDPOISS_REMIT_CODE IS NOT PRESENT IN MASTER ',
       'SELECT DDPOISS_BRN_CODE , DDPOISS_REMIT_CODE, DDPOISS_INST_NUM_PFX, DDPOISS_INST_NUM, DDPOISS_ISSUE_DATE, DDPOISS_INST_AMT
  FROM MIG_DDPO
 WHERE DDPOISS_REMIT_CODE NOT IN (SELECT REMCD_REMIT_CODE FROM REMCD) ;');
  END IF;

  SELECT COUNT(*)
    INTO W_ROWCOUNT
    FROM MIG_DDPO
   WHERE DDPOISS_REMIT_CODE <> '1'
     AND DDPOISS_BRN_CODE NOT IN (SELECT MBRN_CODE FROM MBRN);

  IF W_ROWCOUNT > 0 THEN
    INSERT INTO ERRORLOG
      (TEMPLATE_NAME, COLUMN_NAME, ROW_COUNT, SUGGESTION, QUERY)
    VALUES
      ('MIG_DDPO',
       'DDPOISS_BRN_CODE',
       W_ROWCOUNT,
       'DDPOISS_BRN_CODE IS NOT PRESENT IN MASTER FOR DD ',
       'SELECT DDPOISS_BRN_CODE , DDPOISS_REMIT_CODE, DDPOISS_INST_NUM_PFX, DDPOISS_INST_NUM, DDPOISS_ISSUE_DATE, DDPOISS_INST_AMT
  FROM MIG_DDPO
 WHERE     DDPOISS_REMIT_CODE <> ''1''
       AND DDPOISS_BRN_CODE NOT IN (SELECT MBRN_CODE FROM MBRN);');
  END IF;

END SP_MACRO_DDPO;

/
