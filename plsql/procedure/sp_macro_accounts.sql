CREATE OR REPLACE PROCEDURE SP_MACRO_ACCOUNTS

 IS

  W_MIG_DATE DATE;
  W_BRN_CODE NUMBER(5);
  W_ROWCOUNT NUMBER := 0;

BEGIN


  DELETE FROM ERRORLOG WHERE TEMPLATE_NAME = 'MIG_CONNPINFO';
  COMMIT;
  
  
  SELECT DISTINCT ACOP_BRANCH_CODE INTO W_BRN_CODE FROM MIG_ACOP_BAL;
  SELECT DISTINCT ACOP_BAL_DATE INTO W_MIG_DATE FROM MIG_ACOP_BAL;

  BEGIN
    SP_ACNTS_VALIDATE(W_BRN_CODE, W_MIG_DATE);
  END;

  BEGIN
    SP_ACNTLIEN_VALIDATE(W_BRN_CODE, W_MIG_DATE);
  END;



  ----  checking cnnopinfo client code

  SELECT COUNT(*)
    INTO W_ROWCOUNT
    FROM MIG_CONNPINFO
   WHERE CONNP_CLIENT_CODE NOT IN
         (SELECT CLIENTS_CODE
            FROM MIG_CLIENTS
          UNION ALL
          SELECT JNTCL_JCL_SL
            FROM MIG_JOINTCLIENTS);

  IF W_ROWCOUNT > 0 THEN
  
    INSERT INTO ERRORLOG
      (TEMPLATE_NAME, COLUMN_NAME, ROW_COUNT, SUGGESTION, QUERY)
    VALUES
      ('MIG_CONNPINFO',
       'CONNP_CLIENT_CODE',
       W_ROWCOUNT,
       'CONNP_CLIENT_CODE NOT FOUND IN MAIN CLIENT CODE',
       'SELECT *  FROM MIG_CONNPINFO C
 WHERE C.CONNP_CLIENT_CODE NOT IN
       (SELECT CC.CLIENTS_CODE
          FROM MIG_CLIENTS CC
        UNION ALL
        SELECT J.JNTCL_JCL_SL
          FROM MIG_JOINTCLIENTS J);');
  
  END IF;

  ---- checkning connpinfo conn client number

  SELECT COUNT(*)
    INTO W_ROWCOUNT
    FROM MIG_CONNPINFO
   WHERE CONNP_CONN_CLIENT_NUM NOT IN
         (SELECT CLIENTS_CODE
            FROM MIG_CLIENTS
          UNION ALL
          SELECT JNTCL_JCL_SL
            FROM MIG_JOINTCLIENTS);

  IF W_ROWCOUNT > 0 THEN
  
    INSERT INTO ERRORLOG
      (TEMPLATE_NAME, COLUMN_NAME, ROW_COUNT, SUGGESTION, QUERY)
    VALUES
      ('MIG_CONNPINFO',
       'CONNP_CONN_CLIENT_NUM',
       W_ROWCOUNT,
       'CONNP_CONN_CLIENT_NUM NOT FOUND IN MAIN CLIENT CODE',
       'SELECT *
    FROM MIG_CONNPINFO C
   WHERE C.CONNP_CONN_CLIENT_NUM NOT IN
         (SELECT CC.CLIENTS_CODE
            FROM MIG_CLIENTS CC
          UNION ALL
          SELECT J.JNTCL_JCL_SL
            FROM MIG_JOINTCLIENTS J);');
  
  END IF;


END SP_MACRO_ACCOUNTS;

/
