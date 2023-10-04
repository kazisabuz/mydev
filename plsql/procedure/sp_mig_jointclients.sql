CREATE OR REPLACE PROCEDURE SP_MIG_JOINTCLIENTS(P_BRANCH_CODE NUMBER,
                                                P_ERR_MSG     OUT VARCHAR2) IS

  /*
  Author:S.Rajalakshmi
  Date  :


  List of  Table/s Referred

  1. MIG_JOINTCLIENTS

  List of Tables Updated

  1. JOINTCLIENTS
  2. JOINTCLIENTSDTL
  3. CLIENTS
  4. ADDRDTLS

   Modification History
   -----------------------------------------------------------------------------------------
   Sl.            Description                                    Mod By             Mod on
   -----------------------------------------------------------------------------------------
    */
  TYPE MIG_JOINT IS RECORD(
    W_BRN_CODE           NUMBER(6),
    W_JCL_SL             NUMBER(12),
    W_TITLE_CODE         VARCHAR2(4),
    W_CLIENT_NAME        VARCHAR2(100),
    W_INDIV_CLIENT_CODE1 NUMBER(12),
    W_RELATION_CODE1     VARCHAR2(6),
    W_INDIV_CLIENT_CODE2 NUMBER(12),
    W_RELATION_CODE2     VARCHAR2(6),
    W_INDIV_CLIENT_CODE3 NUMBER(12),
    W_RELATION_CODE3     VARCHAR2(6),
    W_INDIV_CLIENT_CODE4 NUMBER(12),
    W_RELATION_CODE4     VARCHAR2(6),
    W_INDIV_CLIENT_CODE5 NUMBER(12),
    W_RELATION_CODE5     VARCHAR2(6),
    W_INDIV_CLIENT_CODE6 NUMBER(12),
    W_RELATION_CODE6     VARCHAR2(6));
  TYPE IN_MIG_JOINT IS TABLE OF MIG_JOINT INDEX BY PLS_INTEGER;
  V_IN_MIG_JOINT IN_MIG_JOINT;
  W_ENTITY_NUM   NUMBER(3) := GET_OTN.ENTITY_NUMBER;

  W_CNT            NUMBER(7) := 0;
  W_NUM_OF_CLIENTS NUMBER(2) := 0;
  W_OLDCLCODE      VARCHAR2(25);
  W_ENTD_BY        VARCHAR2(8) := 'MIG';
  W_CURR_DATE      DATE;
  W_RELATION       VARCHAR2(6) := '99';
  -- W_ALL_CODES      VARCHAR2(100);
  --W_ALL_RCODES     VARCHAR2(100);
  W_CLIENT_NAME VARCHAR2(35);
  W_NEWCLCODE   VARCHAR2(25);
  --w_sql            VARCHAR2(4000);
  W_CODE     VARCHAR2(25);
  W_1ST_CODE VARCHAR2(25);
  -- TYPE CLIENT IS TABLE OF NUMBER(6) INDEX BY PLS_INTEGER;
  --V_CLIENT CLIENT;
  -- TYPE CODES IS TABLE OF NUMBER(6) INDEX BY PLS_INTEGER;
  --V_CODES CODES;
  TYPE GEN_CLIENT IS RECORD(
    BRN_CODE   NUMBER(6),
    OLD_CLCODE NUMBER(20),
    ENTD_BY    VARCHAR2(8),
    ENTD_ON    DATE);
  TYPE IN_GEN_CLIENT IS TABLE OF GEN_CLIENT INDEX BY PLS_INTEGER;
  V_GEN_CLIENT IN_GEN_CLIENT;
  W_CL_CODE    VARCHAR2(25);
  MYEXCEPTION EXCEPTION;

  W_NULL        VARCHAR2(1);
  W_CODE1       NUMBER(12);
  W_REL1        VARCHAR2(6);
  W_CODE2       NUMBER(12);
  W_REL2        VARCHAR2(6);
  W_CODE3       NUMBER(12);
  W_REL3        VARCHAR2(6);
  W_CODE4       NUMBER(12);
  W_REL4        VARCHAR2(6);
  W_CODE5       NUMBER(12);
  W_REL5        VARCHAR2(6);
  W_CODE6       NUMBER(12);
  W_REL6        VARCHAR2(6);
  W_LOCATION    VARCHAR2(6);
  W_ER_CODE     VARCHAR2(5);
  W_ER_DESC     VARCHAR2(1000);
  W_SRC_KEY     VARCHAR2(1000);
  W_ADDR_INVNUM NUMBER(10);
  W_NAME        VARCHAR2(100);
  W_ALL_NAME    VARCHAR2(500);

  PROCEDURE GET_NEWCLN(OLDCLN  NUMBER,
                       W_ERR   OUT VARCHAR2,
                       W_FIRST BOOLEAN DEFAULT FALSE) IS
  BEGIN

    IF W_FIRST = TRUE THEN
      SELECT NEW_CLCODE
        INTO W_NEWCLCODE
        FROM TEMP_CLIENT
       WHERE BRN_CODE = P_BRANCH_CODE
         AND OLD_CLCODE = OLDCLN;

    ELSE
      SELECT NEW_CLCODE, CLIENTS_NAME
        INTO W_NEWCLCODE, W_NAME
        FROM TEMP_CLIENT, CLIENTS
       WHERE CLIENTS_CODE = TEMP_CLIENT.NEW_CLCODE
         AND TEMP_CLIENT.BRN_CODE = CLIENTS_HOME_BRN_CODE
         AND BRN_CODE = P_BRANCH_CODE
         AND OLD_CLCODE = OLDCLN;

      IF W_ALL_NAME IS NULL THEN
        W_ALL_NAME := SUBSTR(TRIM(W_NAME), 1, 50);
      ELSE
        IF LENGTH(W_ALL_NAME) >= 100 THEN
          W_ALL_NAME := W_ALL_NAME;
        ELSIF LENGTH(W_ALL_NAME) > 75 THEN
          W_ALL_NAME := SUBSTR(W_ALL_NAME, 1, 75) || ',' ||
                        SUBSTR(TRIM(W_NAME), 1, 25);
        ELSE
          W_ALL_NAME := W_ALL_NAME || ',' || SUBSTR(TRIM(W_NAME), 1, 25);
        END IF;
        W_ALL_NAME := SUBSTR(W_ALL_NAME, 1, 100);
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      W_ERR := SQLERRM;
  END GET_NEWCLN;

  PROCEDURE POST_ERR_LOG(W_SOURCE_KEY VARCHAR2,
                         W_START_DATE DATE,
                         W_ERROR_CODE VARCHAR2,
                         W_ERROR      VARCHAR2) IS
    --   PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO MIG_ERRORLOG
      (MIG_ERR_SRC_KEY,
       MIG_ERR_DTL_SL,
       MIG_ERR_MIGDATE,
       MIG_ERR_CODE,
       MIG_ERR_DESC)
    VALUES
      (W_SOURCE_KEY,
       (SELECT NVL(MAX(MIG_ERR_DTL_SL), 0) + 1
          FROM MIG_ERRORLOG P
         WHERE P.MIG_ERR_MIGDATE = W_START_DATE),
       W_START_DATE,
       W_ERROR_CODE,
       W_ERROR);
    COMMIT;
  END POST_ERR_LOG;

  PROCEDURE INSERT_JOINTCLIENTS IS
  BEGIN
    INSERT INTO JOINTCLIENTSDTL
      (JNTCLDTL_CLIENT_CODE,
       JNTCLDTL_DTL_SL,
       JNTCLDTL_INDIV_CLIENT_CODE,
       JNTCLDTL_RELATION_CODE)
    VALUES
      (W_CL_CODE, W_CNT, W_NEWCLCODE, NVL(W_REL6, W_RELATION));
  EXCEPTION
    WHEN OTHERS THEN
      W_ER_CODE := 'JNT18';
      W_ER_DESC := 'INSERT-CODE-JOINTCLIENTSDTL ' || SQLERRM;
      W_SRC_KEY := P_BRANCH_CODE || '-' || W_CODE;
      POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
  END INSERT_JOINTCLIENTS;

BEGIN
  P_ERR_MSG := '0';
  DBMS_OUTPUT.DISABLE;
  W_NULL := NULL;
  DELETE FROM TEMP_CLIENT
   WHERE OLD_CLCODE IN (SELECT JNTCL_JCL_SL FROM MIG_JOINTCLIENTS);

  SELECT MN_CURR_BUSINESS_DATE INTO W_CURR_DATE FROM MAINCONT;

  SELECT TO_NUMBER(JNTCL_BRN_CODE),
         TO_NUMBER(JNTCL_JCL_SL),
         'MIG' MIG_ENTD_BY,
         '01-APR-2009' MIG_ENTD_ON BULK COLLECT
    INTO V_GEN_CLIENT
    FROM MIG_JOINTCLIENTS;

  SELECT MBRN_LOCN_CODE
    INTO W_LOCATION
    FROM MBRN
   WHERE MBRN_ENTITY_NUM = W_ENTITY_NUM
     AND MBRN_CODE = P_BRANCH_CODE;

  SELECT MAX(ADDRDTLS_INV_NUM) INTO W_ADDR_INVNUM FROM ADDRDTLS;

  FOR IDX IN V_GEN_CLIENT.FIRST .. V_GEN_CLIENT.LAST LOOP
    SP_MIG_CLIENTCODE('A',
                      V_GEN_CLIENT(IDX).ENTD_BY,
                      V_GEN_CLIENT(IDX).ENTD_ON,
                      W_CL_CODE,
                      P_ERR_MSG);
    IF P_ERR_MSG IS NOT NULL THEN
      W_ER_CODE := 'JNT01';
      W_ER_DESC := 'ERROR IN GENERATING CLIENT CODE IN JNT CLIENTS ' ||
                   SQLERRM;
      W_SRC_KEY := P_BRANCH_CODE || '-' || W_CL_CODE;
      POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      RAISE MYEXCEPTION;
    END IF;

    INSERT INTO TEMP_CLIENT
    VALUES
      (V_GEN_CLIENT(IDX).BRN_CODE, V_GEN_CLIENT(IDX).OLD_CLCODE, W_CL_CODE);
  END LOOP;

  SELECT JNTCL_BRN_CODE,
         JNTCL_JCL_SL,
         JNCTL_TITLE_CODE,
         JNTCL_CLIENT_NAME,
         JNTCL_INDIV_CLIENT_CODE1,
         JNTCL_RELATION_CODE1,
         JNTCL_INDIV_CLIENT_CODE2,
         JNTCL_RELATION_CODE2,
         JNTCL_INDIV_CLIENT_CODE3,
         JNTCL_RELATION_CODE3,
         JNTCL_INDIV_CLIENT_CODE4,
         JNTCL_RELATION_CODE4,
         JNTCL_INDIV_CLIENT_CODE5,
         JNTCL_RELATION_CODE5,
         JNTCL_INDIV_CLIENT_CODE6,
         JNTCL_RELATION_CODE6 BULK COLLECT
    INTO V_IN_MIG_JOINT
    FROM MIG_JOINTCLIENTS
   WHERE JNTCL_BRN_CODE = P_BRANCH_CODE;

  DBMS_OUTPUT.PUT_LINE(V_IN_MIG_JOINT.COUNT);

  IF V_IN_MIG_JOINT.COUNT > 0 THEN
    FOR IDX IN V_IN_MIG_JOINT.FIRST .. V_IN_MIG_JOINT.LAST LOOP
      GET_NEWCLN(V_IN_MIG_JOINT(IDX).W_JCL_SL, P_ERR_MSG, TRUE);
      W_CL_CODE := W_NEWCLCODE;

      SELECT DECODE(JNTCL_INDIV_CLIENT_CODE3,
                    NULL,
                    2,
                    JNTCL_INDIV_CLIENT_CODE4,
                    NULL,
                    3,
                    JNTCL_INDIV_CLIENT_CODE5,
                    NULL,
                    4,
                    JNTCL_INDIV_CLIENT_CODE6,
                    NULL,
                    5)
        INTO W_NUM_OF_CLIENTS
        FROM MIG_JOINTCLIENTS
       WHERE JNTCL_JCL_SL = V_IN_MIG_JOINT(IDX).W_JCL_SL;
      <<JOINTCLIENT>>
      BEGIN
        INSERT INTO JOINTCLIENTS
          (JNTCLIENT_CODE,
           JNTCLIENT_HOME_BRN_CODE,
           JNTCLIENT_TITLE_CODE,
           JNTCLIENT_NAME,
           JNTCLIENT_ALPHA_ID,
           JNTCLIENT_NUM_JNT_CLNT,
           JNTCLIENT_ADDR1,
           JNTCLIENT_ADDR2,
           JNTCLIENT_ADDR3,
           JNTCLIENT_ADDR4,
           JNTCLIENT_ADDR5,
           JNTCLIENT_LOCN_CODE)
        VALUES
          (W_CL_CODE,
           V_IN_MIG_JOINT  (IDX).W_BRN_CODE,
           V_IN_MIG_JOINT  (IDX).W_TITLE_CODE,
           V_IN_MIG_JOINT  (IDX).W_CLIENT_NAME,
           NULL,
           W_NUM_OF_CLIENTS,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           W_LOCATION);
      EXCEPTION
        WHEN OTHERS THEN
          W_ER_CODE := 'JNT4';
          W_ER_DESC := 'INSERT-JOINTCLIENTSDTL ' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || W_CL_CODE;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END JOINTCLIENT;
      W_CNT := 1;

      <<OLD_CODE>>
      BEGIN
        SELECT OLD_CLCODE
          INTO W_OLDCLCODE
          FROM TEMP_CLIENT
         WHERE NEW_CLCODE = W_CL_CODE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          W_ER_CODE := 'JNT5';
          W_ER_DESC := 'INSERT-CLIENTS-JOINTCLIENTSDTL ' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || W_CODE;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END OLD_CODE;

      <<ALL_CODES>>
      BEGIN
        SELECT JNTCL_INDIV_CLIENT_CODE1,
               JNTCL_RELATION_CODE1,
               JNTCL_INDIV_CLIENT_CODE2,
               JNTCL_RELATION_CODE2,
               JNTCL_INDIV_CLIENT_CODE3,
               JNTCL_RELATION_CODE3,
               JNTCL_INDIV_CLIENT_CODE4,
               JNTCL_RELATION_CODE4,
               JNTCL_INDIV_CLIENT_CODE5,
               JNTCL_RELATION_CODE5,
               JNTCL_INDIV_CLIENT_CODE6,
               JNTCL_RELATION_CODE6
          INTO W_CODE1,
               W_REL1,
               W_CODE2,
               W_REL2,
               W_CODE3,
               W_REL3,
               W_CODE4,
               W_REL4,
               W_CODE5,
               W_REL5,
               W_CODE6,
               W_REL6
          FROM MIG_JOINTCLIENTS
         WHERE JNTCL_JCL_SL = W_OLDCLCODE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          W_ER_CODE := 'JNT6';
          W_ER_DESC := 'INSERT-ALLCODES-JOINTCLIENTSDTL ' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || W_CODE;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END ALL_CODES;

      W_ALL_NAME := NULL;
      --Inserting Joint Clients
      IF W_CODE1 IS NOT NULL THEN
        GET_NEWCLN(W_CODE1, P_ERR_MSG);
        INSERT_JOINTCLIENTS;
        W_CODE     := W_NEWCLCODE;
        W_1ST_CODE := W_NEWCLCODE;
        W_CNT      := W_CNT + 1;
      END IF;

      IF W_CODE2 IS NOT NULL THEN
        GET_NEWCLN(W_CODE2, P_ERR_MSG);
        INSERT_JOINTCLIENTS;
        W_CNT := W_CNT + 1;
        IF W_CODE IS NULL THEN
          W_CODE := W_NEWCLCODE;
        END IF;
      END IF;

      IF W_CODE3 IS NOT NULL THEN
        GET_NEWCLN(W_CODE3, P_ERR_MSG);
        INSERT_JOINTCLIENTS;
        IF W_CODE IS NULL THEN
          W_CODE := W_NEWCLCODE;
        END IF;
        W_CNT := W_CNT + 1;
      END IF;

      IF W_CODE4 IS NOT NULL THEN
        GET_NEWCLN(W_CODE4, P_ERR_MSG);
        INSERT_JOINTCLIENTS;
        IF W_CODE IS NULL THEN
          W_CODE := W_NEWCLCODE;
        END IF;
        W_CNT := W_CNT + 1;
      END IF;

      IF W_CODE5 IS NOT NULL THEN
        GET_NEWCLN(W_CODE5, P_ERR_MSG);
        INSERT_JOINTCLIENTS;
        IF W_CODE IS NULL THEN
          W_CODE := W_NEWCLCODE;
        END IF;
        W_CNT := W_CNT + 1;
      END IF;

      IF W_CODE6 IS NOT NULL THEN
        GET_NEWCLN(W_CODE6, P_ERR_MSG);
        INSERT_JOINTCLIENTS;
        IF W_CODE IS NULL THEN
          W_CODE := W_NEWCLCODE;
        END IF;
        W_CNT := W_CNT + 1;
      END IF;
      UPDATE JOINTCLIENTS
         SET JNTCLIENT_NAME = W_ALL_NAME
       WHERE JNTCLIENT_CODE = W_CL_CODE;

      FOR MDX IN (SELECT CLIENTS_ALPHA_ID,
                         CLIENTS_CONST_CODE,
                         CLIENTS_ADDR1,
                         CLIENTS_ADDR2,
                         CLIENTS_ADDR3,
                         CLIENTS_ADDR4,
                         CLIENTS_ADDR5,
                         CLIENTS_LOCN_CODE,
                         CLIENTS_CUST_CATG,
                         CLIENTS_CUST_SUB_CATG,
                         CLIENTS_SEGMENT_CODE,
                         CLIENTS_BUSDIVN_CODE,
                         CLIENTS_RISK_CNTRY,
                         CLIENTS_NUM_OF_DOCS,
                         CLIENTS_CONT_PERSON_AVL,
                         CLIENTS_CR_LIMITS_OTH_BK,
                         CLIENTS_ACS_WITH_OTH_BK,
                         CLIENTS_OPENING_DATE,
                         CLIENTS_ARM_CODE,
                         CLIENTS_GROUP_CODE,
                         CLIENTS_PAN_GIR_NUM,
                         CLIENTS_IT_STAT_CODE,
                         CLIENTS_IT_SUB_STAT_CODE,
                         CLIENTS_EXEMP_IN_TDS,
                         CLIENTS_EXEMP_TDS_PER,
                         CLIENTS_EXEMP_REM1,
                         CLIENTS_EXEMP_REM2,
                         CLIENTS_EXEMP_REM3,
                         CLIENTS_BSR_TYPE_FLG,
                         CLIENTS_RISK_CATEGORIZATION,
                         CLIENTS_CREATION_STATUS,
                         CLIENTS_ENTD_BY,
                         CLIENTS_ENTD_ON,
                         CLIENTS_LAST_MOD_BY,
                         CLIENTS_LAST_MOD_ON,
                         CLIENTS_AUTH_BY,
                         CLIENTS_AUTH_ON,
                         CLIENTS_PREOPEN_ENTD_BY,
                         CLIENTS_PREOPEN_ENTD_ON,
                         CLIENTS_PREOPEN_LAST_MOD_BY,
                         CLIENTS_PREOPEN_LAST_MOD_ON,
                         TBA_MAIN_KEY,
                         CLIENTS_ADDR_INV_NUM
                    FROM CLIENTS
                   WHERE CLIENTS_CODE = W_1ST_CODE) LOOP

        <<CLIENTNUM_VALID>>
        BEGIN
          INSERT INTO CLIENTNUM VALUES (TO_NUMBER(TRIM(W_CL_CODE)));
        EXCEPTION
          WHEN OTHERS THEN
            W_ER_CODE := 'JNT2';
            W_ER_DESC := 'INSERT-CLIENTS-JOINTCLIENTSDTL ' || SQLERRM;
            W_SRC_KEY := P_BRANCH_CODE || '-' || W_CL_CODE;
            POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
        END CLIENTNUM_VALID;

        W_ADDR_INVNUM := W_ADDR_INVNUM + 1;
        EXECUTE IMMEDIATE 'INSERT INTO ADDRDTLS
            (
              ADDRDTLS_INV_NUM,
              ADDRDTLS_ADDR_SL,
              ADDRDTLS_ADDR_TYPE,
              ADDRDTLS_CMP_TPARTY_NAME,
              ADDRDTLS_ADDR1,
              ADDRDTLS_ADDR2,
              ADDRDTLS_ADDR3,
              ADDRDTLS_ADDR4,
              ADDRDTLS_ADDR5,
              ADDRDTLS_PIN_ZIP_CODE,
              ADDRDTLS_LOCN_CODE,
              ADDRDTLS_CNTRY_CODE,
              ADDRDTLS_PHONE_NUM1,
              ADDRDTLS_PHONE_NUM2,
              ADDRDTLS_MOBILE_NUM,
              ADDRDTLS_STAYING_MTH,
              ADDRDTLS_STAYING_YEAR,
              ADDRDTLS_CURR_ADDR,
              ADDRDTLS_PERM_ADDR,
              ADDRDTLS_COMM_ADDR,
              ADDRDTLS_SOURCE_TABLE,
              ADDRDTLS_SOURCE_KEY,
              ADDRDTLS_PGM_ID,
              ADDRDTLS_EFF_FROM_DATE,
              ADDRDTLS_INVALID_FROM_DATE
            )
            VALUES
            (
              :1,
              :2,
              :3,:4,
             :5,
               :6,
               :7,
               :8,
               :9,
               :10,
               :11,
               :12,
               :13,:14,:15,:16,:17,:18,:19,:20,:21,:21,:22,:23,:24
            )'
          USING W_ADDR_INVNUM, 1, '01', W_NULL, MDX.CLIENTS_ADDR1, MDX.CLIENTS_ADDR2, MDX.CLIENTS_ADDR3, MDX.CLIENTS_ADDR4, MDX.CLIENTS_ADDR5, W_NULL, W_LOCATION, 'GB', W_NULL, W_NULL, W_NULL, W_NULL, W_NULL, 1, 1, 1, 'CLIENTS', W_CL_CODE, 'MJOINTCLIENTS', MDX.CLIENTS_OPENING_DATE, W_NULL; --shamsudeen-chn-24may2012-changed IN to BD

        <<CLIENT>>
        BEGIN
          INSERT INTO CLIENTS
            (CLIENTS_CODE,
             CLIENTS_TYPE_FLG,
             CLIENTS_HOME_BRN_CODE,
             CLIENTS_TITLE_CODE,
             CLIENTS_NAME,
             CLIENTS_ALPHA_ID,
             CLIENTS_CONST_CODE,
             CLIENTS_ADDR1,
             CLIENTS_ADDR2,
             CLIENTS_ADDR3,
             CLIENTS_ADDR4,
             CLIENTS_ADDR5,
             CLIENTS_LOCN_CODE,
             CLIENTS_CUST_CATG,
             CLIENTS_CUST_SUB_CATG,
             CLIENTS_SEGMENT_CODE,
             CLIENTS_BUSDIVN_CODE,
             CLIENTS_RISK_CNTRY,
             CLIENTS_NUM_OF_DOCS,
             CLIENTS_CONT_PERSON_AVL,
             CLIENTS_CR_LIMITS_OTH_BK,
             CLIENTS_ACS_WITH_OTH_BK,
             CLIENTS_OPENING_DATE,
             CLIENTS_ARM_CODE,
             CLIENTS_GROUP_CODE,
             CLIENTS_PAN_GIR_NUM,
             CLIENTS_IT_STAT_CODE,
             CLIENTS_IT_SUB_STAT_CODE,
             CLIENTS_EXEMP_IN_TDS,
             CLIENTS_EXEMP_TDS_PER,
             CLIENTS_EXEMP_REM1,
             CLIENTS_EXEMP_REM2,
             CLIENTS_EXEMP_REM3,
             CLIENTS_BSR_TYPE_FLG,
             CLIENTS_RISK_CATEGORIZATION,
             CLIENTS_CREATION_STATUS,
             CLIENTS_ENTD_BY,
             CLIENTS_ENTD_ON,
             CLIENTS_LAST_MOD_BY,
             CLIENTS_LAST_MOD_ON,
             CLIENTS_AUTH_BY,
             CLIENTS_AUTH_ON,
             CLIENTS_PREOPEN_ENTD_BY,
             CLIENTS_PREOPEN_ENTD_ON,
             CLIENTS_PREOPEN_LAST_MOD_BY,
             CLIENTS_PREOPEN_LAST_MOD_ON,
             TBA_MAIN_KEY,
             CLIENTS_ADDR_INV_NUM)
          VALUES
            (W_CL_CODE,
             'J',
             P_BRANCH_CODE,
             4, --V_IN_MIG_JOINT(IDX).W_TITLE_CODE,
             W_ALL_NAME,
             NULL, --MDX.CLIENTS_ALPHA_ID,
             9, --MDX.CLIENTS_CONST_CODE,
             MDX.CLIENTS_ADDR1,
             MDX.CLIENTS_ADDR2,
             MDX.CLIENTS_ADDR3,
             MDX.CLIENTS_ADDR4,
             MDX.CLIENTS_ADDR5,
             MDX.CLIENTS_LOCN_CODE,
             MDX.CLIENTS_CUST_CATG,
             MDX.CLIENTS_CUST_SUB_CATG,
             MDX.CLIENTS_SEGMENT_CODE,
             MDX.CLIENTS_BUSDIVN_CODE,
             MDX.CLIENTS_RISK_CNTRY,
             MDX.CLIENTS_NUM_OF_DOCS,
             MDX.CLIENTS_CONT_PERSON_AVL,
             MDX.CLIENTS_CR_LIMITS_OTH_BK,
             MDX.CLIENTS_ACS_WITH_OTH_BK,
             MDX.CLIENTS_OPENING_DATE,
             MDX.CLIENTS_ARM_CODE,
             MDX.CLIENTS_GROUP_CODE,
             MDX.CLIENTS_PAN_GIR_NUM,
             MDX.CLIENTS_IT_STAT_CODE,
             MDX.CLIENTS_IT_SUB_STAT_CODE,
             MDX.CLIENTS_EXEMP_IN_TDS,
             MDX.CLIENTS_EXEMP_TDS_PER,
             MDX.CLIENTS_EXEMP_REM1,
             MDX.CLIENTS_EXEMP_REM2,
             MDX.CLIENTS_EXEMP_REM3,
             MDX.CLIENTS_BSR_TYPE_FLG,
             MDX.CLIENTS_RISK_CATEGORIZATION,
             MDX.CLIENTS_CREATION_STATUS,
             W_ENTD_BY,
             W_CURR_DATE,
             MDX.CLIENTS_LAST_MOD_BY,
             MDX.CLIENTS_LAST_MOD_ON,
             W_ENTD_BY,
             W_CURR_DATE,
             MDX.CLIENTS_PREOPEN_ENTD_BY,
             MDX.CLIENTS_PREOPEN_ENTD_ON,
             MDX.CLIENTS_PREOPEN_LAST_MOD_BY,
             MDX.CLIENTS_PREOPEN_LAST_MOD_ON,
             MDX.TBA_MAIN_KEY,
             W_ADDR_INVNUM);
        EXCEPTION
          WHEN OTHERS THEN
            W_ER_CODE := 'JNT3';
            W_ER_DESC := 'INSERT-CLIENTS-JOINTCLIENTSDTL ' || SQLERRM;
            W_SRC_KEY := P_BRANCH_CODE || '-' || W_CL_CODE;
            POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
        END CLIENT;
      END LOOP;

    END LOOP;
  END IF;
  UPDATE INVNUM
     SET INVNUM_LAST_NUM_USED = W_ADDR_INVNUM
   WHERE INVNUM_SOURCE_TYPE = 'A';

  INSERT INTO CLIENTOTN
    SELECT CLIENTNUM_CODE,
           'MIGRATION',
           NULL,
           NULL,
           'MIG',
           SYSDATE,
           NULL,
           NULL
      FROM CLIENTNUM;

  INSERT INTO CLIENTOTNDTL
    SELECT NEW_CLCODE, 1, BRN_CODE, OLD_CLCODE, CLIENTS_NAME, NULL
      FROM TEMP_CLIENT, CLIENTS
     WHERE CLIENTS_CODE = NEW_CLCODE;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    P_ERR_MSG := SQLERRM || 'MAIN';
    ROLLBACK;

END SP_MIG_JOINTCLIENTS;

 
 
 
/
