CREATE OR REPLACE PROCEDURE SP_QCUSTBROWSER(V_ENTITY_NUM IN NUMBER,
                                            P_IN_MSG     IN VARCHAR2,
                                            P_REPORT_SL  IN OUT NUMBER,
                                            P_ERR_MSG    OUT VARCHAR2) IS
  

  TYPE TY_LST_RECORD IS RECORD(
    CLIENTS_CODE          NUMBER(12),
    CLIENTS_NAME          VARCHAR2(100),
    INDCLIENT_FATHER_NAME VARCHAR2(100),
    IACLINK_ACTUAL_ACNUM  VARCHAR2(100),
    CLIENTS_PHN           VARCHAR2(100),
    CLIENTS_HOME_BRN_CODE NUMBER(6),
    CLIENTS_TYPE_FLG      CHAR(1),
    CLIENTS_PAN_GIR_NUM   VARCHAR2(100),
    CLIENTS_ADDR1         VARCHAR2(35),
    CLIENTS_ADDR2         VARCHAR2(35),
    CLIENTS_ADDR3         VARCHAR2(35),
    CLIENTS_ADDR4         VARCHAR2(35),
    CLIENTS_ADDR5         VARCHAR2(35));

  TYPE T_LST_REC IS TABLE OF TY_LST_RECORD INDEX BY PLS_INTEGER;
  LST_REC T_LST_REC;

  TYPE T_LIST_MY_REC IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
  V_LIST_MY_REC T_LIST_MY_REC;

  W_SQL          VARCHAR2(3300):='';
  W_REGN_NO      VARCHAR2(30);
  W_TELEPHONE_NO VARCHAR2(20);
  W_MOBILE_NO    VARCHAR2(20);
  W_TIN_NO       VARCHAR2(35);
  W_BRN_CODE     NUMBER(6);
  W_PID_TYPE     VARCHAR2(3);
  W_PID_NO       VARCHAR2(35);
  W_DOB          VARCHAR2(10);
  W_NAME_XML     VARCHAR2(100);
  W_ADDRESS_XML  VARCHAR2(100);
  W_TEMP_SL      NUMBER;
  W_ERR_MSG      VARCHAR2(1000);
  W_FLAG         CHAR(1);
  W_COUNT_NAME   NUMBER(2);
  W_COUNT_ADDR   NUMBER(2);
  W_MY_LIST      VARCHAR2(1000);

  FUNCTION GET_MY_TOKEN(THE_INDEX NUMBER, THE_DELIM VARCHAR2) RETURN VARCHAR2 IS
    START_POS NUMBER;
    END_POS   NUMBER;
  BEGIN
    IF THE_INDEX = 1 THEN
      START_POS := 1;
    ELSE
      START_POS := INSTR(W_MY_LIST, THE_DELIM, 1, THE_INDEX - 1);
      IF START_POS = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Check Input Values');
      ELSE
        START_POS := START_POS + LENGTH(THE_DELIM);
      END IF;
    END IF;
    END_POS := INSTR(W_MY_LIST, THE_DELIM, START_POS, 1);

    IF END_POS = 0 THEN
      RETURN SUBSTR(W_MY_LIST, START_POS);
    ELSE
      RETURN SUBSTR(W_MY_LIST, START_POS, END_POS - START_POS);

    END IF;
  END GET_MY_TOKEN;

  PROCEDURE SP_SPILIT_MY_TOKEN(W_TOKEN_COUNT IN NUMBER,
                               W_DELIM       IN VARCHAR2,
                               W_LIST        IN VARCHAR2) IS
  BEGIN
    W_MY_LIST := W_LIST;
    FOR V_IND IN 1 .. W_TOKEN_COUNT LOOP
      V_LIST_MY_REC(V_IND) := GET_MY_TOKEN(V_IND, W_DELIM);
    END LOOP;
  END SP_SPILIT_MY_TOKEN;

  PROCEDURE READ_CLIENTS IS
  BEGIN
    PKG_REPORT_XML.SP_INIT_VARIABLES(PKG_ENTITY.FN_GET_ENTITY_CODE);
    PKG_REPORT_XML.V_COLUMN_COUNT := 10;
    W_SQL :='SELECT CLIENTS_CODE,CLIENTS_NAME,INDCLIENT_FATHER_NAME,IACLINK_ACTUAL_ACNUM,TO_CHAR (GET_MOBILE_NUM (CLIENTS_CODE)) AS CLIENTS_PHN,CLIENTS_HOME_BRN_CODE,CLIENTS_TYPE_FLG,CLIENTS_PAN_GIR_NUM,CLIENTS_ADDR1,CLIENTS_ADDR2,CLIENTS_ADDR3,CLIENTS_ADDR4,CLIENTS_ADDR5 FROM (';
    W_SQL := W_SQL || 'SELECT CLIENTS_CODE, CLIENTS_NAME,INDCLIENT_FATHER_NAME,IACLINK_ACTUAL_ACNUM,COALESCE ( TO_CHAR(INDCLIENT_TEL_RES),TO_CHAR(INDCLIENT_TEL_OFF),TO_CHAR(INDCLIENT_TEL_OFF1))||' ||
                                     CHR(39) || '/' || CHR(39) ||
                                     '|| TO_CHAR(INDCLIENT_TEL_GSM) AS "CLIENTS_PHN",CLIENTS_HOME_BRN_CODE,CLIENTS_TYPE_FLG,CLIENTS_PAN_GIR_NUM, CLIENTS_ADDR1, CLIENTS_ADDR2 ,
                CLIENTS_ADDR3, CLIENTS_ADDR4, CLIENTS_ADDR5,CLIENTS_ADDR_INV_NUM  FROM CLIENTS,INDCLIENTS left join iaclink on INDCLIENT_CODE=IACLINK_CIF_NUMBER WHERE CLIENTS_CODE = INDCLIENT_CODE   ';

    IF W_REGN_NO IS NOT NULL THEN
      W_SQL := W_SQL || ' AND  CLIENTS_TYPE_FLG = ''C'' AND ';
    ELSIF (W_PID_TYPE IS NOT NULL OR W_DOB IS NOT NULL OR
          W_TELEPHONE_NO IS NOT NULL) THEN
      W_SQL := W_SQL ||
               ' AND  (CLIENTS_TYPE_FLG = ''I'' OR CLIENTS_TYPE_FLG = ''J'')  ';
    END IF;

    IF W_BRN_CODE <> 0 THEN
      W_SQL  := W_SQL || 'AND CLIENTS_HOME_BRN_CODE = ' || W_BRN_CODE;
      W_FLAG := 'S';
    END IF;

    -- DBMS_OUTPUT.PUT_LINE('W_COUNT_NAME : ' || W_COUNT_NAME || ' : '|| W_NAME_XML);
    SP_SPILIT_MY_TOKEN(W_COUNT_NAME, '@', W_NAME_XML);

    IF (W_COUNT_NAME > 0) THEN
      FOR IDXNAME IN 1 .. W_COUNT_NAME LOOP
        IF (W_FLAG = 'S') THEN
          W_SQL := W_SQL || ' AND   REGEXP_LIKE (UPPER(TRIM(CLIENTS_NAME)),'''|| V_LIST_MY_REC(IDXNAME)||''')';
                   
                   
        ELSE
          W_SQL  := W_SQL || ' AND   REGEXP_LIKE (UPPER(TRIM(CLIENTS_NAME)),''' ||
                    V_LIST_MY_REC(IDXNAME) || ''')';
          W_FLAG := 'S';
        END IF;
      END LOOP;
    END IF;

    SP_SPILIT_MY_TOKEN(W_COUNT_ADDR, '@', W_ADDRESS_XML);

    IF (W_COUNT_ADDR > 0) THEN
      FOR IDXADDR IN 1 .. W_COUNT_ADDR LOOP
        IF (W_FLAG = 'S') THEN
          W_SQL := W_SQL ||
                   ' AND REGEXP_LIKE(UPPER(TRIM(CLIENTS_ADDR1) || '' '' || TRIM(CLIENTS_ADDR2) || '' '' || TRIM(CLIENTS_ADDR3)
                            || '' '' || TRIM(CLIENTS_ADDR4) || '' '' || TRIM(CLIENTS_ADDR5)),''' ||
                   V_LIST_MY_REC(IDXADDR) || ''')';
        ELSE
          W_SQL  := W_SQL ||
                    ' AND REGEXP_LIKE(UPPER(TRIM(CLIENTS_ADDR1) || '' '' || TRIM(CLIENTS_ADDR2) || '' '' || TRIM(CLIENTS_ADDR3)
                            || '' '' || TRIM(CLIENTS_ADDR4) || '' '' || TRIM(CLIENTS_ADDR5)),''' ||
                   V_LIST_MY_REC(IDXADDR) || ''')';
          W_FLAG := 'S';
        END IF;
      END LOOP;
    END IF;

    IF W_REGN_NO IS NOT NULL THEN
      IF (W_FLAG = 'S') THEN
        W_SQL := W_SQL ||
                 ' AND CLIENTS_CODE IN (SELECT CORPCL_CLIENT_CODE FROM CORPCLIENTS
                               WHERE CORPCL_CLIENT_CODE = CLIENTS_CODE AND CORPCL_REG_NUM = ' ||
                 CHR(39) || W_REGN_NO || CHR(39) || ' )';
      ELSE
        W_SQL  := W_SQL ||
                  ' and CLIENTS_CODE IN (SELECT CORPCL_CLIENT_CODE FROM CORPCLIENTS
                               WHERE CORPCL_CLIENT_CODE = CLIENTS_CODE AND CORPCL_REG_NUM = ' ||
                  CHR(39) || W_REGN_NO || CHR(39) || ' )';
        W_FLAG := 'S';
      END IF;
    END IF;

    IF (W_PID_TYPE IS NOT NULL AND W_DOB IS NULL) THEN
      IF (W_FLAG = 'S') THEN
        W_SQL := W_SQL ||
                 ' AND CLIENTS_CODE IN (SELECT INDCLIENT_CODE FROM INDCLIENTS,PIDDOCS WHERE
                               INDCLIENT_PID_INV_NUM = PIDDOCS_INV_NUM AND PIDDOCS_PID_TYPE = ' ||
                 CHR(39) || W_PID_TYPE || CHR(39) ||
                 ' AND PIDDOCS_DOCID_NUM = ' || CHR(39) || W_PID_NO ||
                 CHR(39) || ') ';
      ELSE
        W_SQL  := W_SQL ||
                  ' and CLIENTS_CODE IN(SELECT INDCLIENT_CODE FROM INDCLIENTS,PIDDOCS WHERE
                               INDCLIENT_PID_INV_NUM = PIDDOCS_INV_NUM AND PIDDOCS_PID_TYPE = ' ||
                  CHR(39) || W_PID_TYPE || CHR(39) ||
                  ' AND PIDDOCS_DOCID_NUM = ' || CHR(39) || W_PID_NO ||
                  CHR(39) || ') ';
        W_FLAG := 'S';
      END IF;
    END IF;

    IF (W_PID_TYPE IS NULL AND W_DOB IS NOT NULL) THEN
      IF (W_FLAG = 'S') THEN
        W_SQL := W_SQL ||
                 ' AND CLIENTS_CODE IN (SELECT INDCLIENT_CODE FROM INDCLIENTS WHERE TO_CHAR(INDCLIENT_BIRTH_DATE,''DD-MM-YYYY'') = ' ||
                 CHR(39) || W_DOB || CHR(39) || ') ';
      ELSE
        W_SQL  := W_SQL ||
                  ' and CLIENTS_CODE IN (SELECT INDCLIENT_CODE FROM INDCLIENTS WHERE TO_CHAR(INDCLIENT_BIRTH_DATE,''DD-MM-YYYY'') = ' ||
                  CHR(39) || W_DOB || CHR(39) || ') ';
        W_FLAG := 'S';
      END IF;
    END IF;

    IF (W_PID_TYPE IS NOT NULL AND W_DOB IS NOT NULL) THEN
      IF (W_FLAG = 'S') THEN
        W_SQL := W_SQL ||
                 ' AND CLIENTS_CODE IN (SELECT INDCLIENT_CODE FROM INDCLIENTS,PIDDOCS WHERE TO_CHAR(INDCLIENT_BIRTH_DATE,''DD-MM-YYYY'') = ' ||
                 CHR(39) || W_DOB || CHR(39) || '
                               AND INDCLIENT_PID_INV_NUM = PIDDOCS_INV_NUM AND PIDDOCS_PID_TYPE = ' ||
                 CHR(39) || W_PID_TYPE || CHR(39) ||
                 ' AND PIDDOCS_DOCID_NUM = ' || CHR(39) || W_PID_NO ||
                 CHR(39) || ') ';
      ELSE
        W_SQL  := W_SQL ||
                  'and  CLIENTS_CODE IN (SELECT INDCLIENT_CODE FROM INDCLIENTS,PIDDOCS WHERE TO_CHAR(INDCLIENT_BIRTH_DATE,''DD-MM-YYYY'') = ' ||
                  CHR(39) || W_DOB || CHR(39) || '
                               AND INDCLIENT_PID_INV_NUM = PIDDOCS_INV_NUM AND PIDDOCS_PID_TYPE = ' ||
                  W_PID_TYPE || CHR(39) || ' AND PIDDOCS_DOCID_NUM = ' ||
                  CHR(39) || W_PID_NO || CHR(39) || ') ';
        W_FLAG := 'S';
      END IF;
    END IF;

    IF W_TELEPHONE_NO IS NOT NULL THEN
      IF (W_FLAG = 'S') THEN
        W_SQL := W_SQL ||
                 ' AND CLIENTS_CODE IN (SELECT  INDCLIENT_CODE FROM INDCLIENTS WHERE REGEXP_LIKE (INDCLIENT_TEL_RES ,  '''  || 
                 W_TELEPHONE_NO || ''')'' ' ||
                 ' OR REGEXP_LIKE (INDCLIENT_TEL_OFF   ,''' || W_TELEPHONE_NO ||
                 ''')'' ' || ' OR REGEXP_LIKE (INDCLIENT_TEL_OFF1  ,''' ||
                 W_TELEPHONE_NO || ''')'' ' ||
                 'OR REGEXP_LIKE (INDCLIENT_TEL_GSM  ,''' || W_TELEPHONE_NO ||
                 ''')'') ';
      ELSE
        W_SQL  := W_SQL ||
                 --                    ' CLIENTS_CODE IN (SELECT  INDCLIENT_CODE FROM INDCLIENTS WHERE INDCLIENT_TEL_RES = ' ||
                 --                  --MURALI - 26/04/2011 - beg
                 --                   -- W_TELEPHONE_NO || CHR(39) || ' OR INDCLIENT_TEL_OFF=' ||
                 --                    CHR(39) || W_TELEPHONE_NO || CHR(39) || ' OR INDCLIENT_TEL_OFF=' ||
                 --                    --MURALI- 26/04/2011 - end
                 --                    CHR(39) || W_TELEPHONE_NO || CHR(39) ||
                 --                    ' OR INDCLIENT_TEL_OFF1=' || CHR(39) || W_TELEPHONE_NO ||
                 --                    CHR(39) || ' OR INDCLIENT_TEL_GSM=' || CHR(39) ||
                 --                    W_TELEPHONE_NO || CHR(39) || ') ';
                  '  CLIENTS_CODE IN (SELECT  INDCLIENT_CODE FROM INDCLIENTS WHERE REGEXP_LIKE (INDCLIENT_TEL_RES  ,''' ||
                  W_TELEPHONE_NO || ''')'' ' ||
                  ' OR REGEXP_LIKE (INDCLIENT_TEL_OFF , ''' || W_TELEPHONE_NO ||
                  ')'' ' || ' OR REGEXP_LIKE (INDCLIENT_TEL_OFF1 , ''' ||
                  W_TELEPHONE_NO || ''')'' ' ||
                  'OR REGEXP_LIKE INDCLIENT_TEL_GSM ,  ''' || W_TELEPHONE_NO ||
                  ''')'') ';
        W_FLAG := 'S';
      END IF;
    END IF;
    --DBMS_OUTPUT.PUT_LINE('W_SQL : ' || W_SQL);

    IF W_MOBILE_NO IS NOT NULL THEN
      IF (W_FLAG = 'S') THEN
        W_SQL := W_SQL ||
                 ' AND CLIENTS_CODE IN (SELECT CLIENTS_CODE FROM CLIENTS C, ADDRDTLS A WHERE  CLIENTS_ADDR_INV_NUM = ADDRDTLS_INV_NUM AND REGEXP_LIKE (ADDRDTLS_MOBILE_NUM  , 
                 ''' ||
                 W_MOBILE_NO || ''')' || ') ';

      ELSE
        W_SQL  := W_SQL ||
                  ' and CLIENTS_CODE IN (SELECT CLIENTS_CODE FROM CLIENTS C, ADDRDTLS A WHERE  CLIENTS_ADDR_INV_NUM = ADDRDTLS_INV_NUM 
                  AND  REGEXP_LIKE (ADDRDTLS_MOBILE_NUM , ''' ||
                  W_MOBILE_NO || ''') ' || ') ';
        W_FLAG := 'S';
      END IF;
    END IF;

    IF W_TIN_NO IS NOT NULL THEN
      IF (W_FLAG = 'S') THEN
        W_SQL := W_SQL ||
                 ' AND CLIENTS_CODE IN (SELECT CLIENTS_CODE FROM CLIENTS WHERE REGEXP_LIKE ( CLIENTS_PAN_GIR_NUM , ''' ||
                 W_TIN_NO || ''')'  || ') ';

      ELSE
        W_SQL  := W_SQL ||
                  ' CLIENTS_CODE IN (SELECT CLIENTS_CODE FROM CLIENTS WHERE REGEXP_LIKE (CLIENTS_PAN_GIR_NUM  ,''' ||
                  W_TIN_NO || ''')'  || ') ';
        W_FLAG := 'S';
      END IF;
    END IF;
    W_SQL  := W_SQL || ' ) B';
--    
--    BEGIN 
--LOG_ERROR('QCUS', W_SQL);   -------ADD THIS PROCEDURE FOR PRINT W_SQL RESULT
--END ;
----commit;
   EXECUTE IMMEDIATE W_SQL BULK COLLECT
      INTO LST_REC;

    IF LST_REC.FIRST IS NOT NULL THEN
      FOR I IN LST_REC.FIRST .. LST_REC.LAST LOOP
        PKG_REPORT_XML.FINAL_REC.DELETE;

        PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := I;
        PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := LST_REC(I)
                                                                                .CLIENTS_CODE;
        PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := REPLACE(LST_REC(I)
                                                                                        .CLIENTS_NAME,
                                                                                        '&',
                                                                                        '');
        PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := REPLACE(LST_REC(I)
                                                                                        .INDCLIENT_FATHER_NAME,
                                                                                        '&',
                                                                                        '');
        PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := REPLACE(LST_REC(I)
                                                                                        .IACLINK_ACTUAL_ACNUM,
                                                                                        '&',
                                                                                        '');
        PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := REPLACE(LST_REC(I)
                                                                                        .CLIENTS_PHN,
                                                                                        '&',
                                                                                        '');

        PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := LST_REC(I)
                                                                                .CLIENTS_HOME_BRN_CODE;
        PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := LST_REC(I)
                                                                                .CLIENTS_TYPE_FLG;
        PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := REPLACE(LST_REC(I)
                                                                                .CLIENTS_PAN_GIR_NUM,
                                                                                '&',
                                                                                '');
        PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := REPLACE(LST_REC(I)
                                                                                        .CLIENTS_ADDR1,
                                                                                        '&',
                                                                                        '');
        PKG_REPORT_XML.SP_SET_IND_VALUES(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                         PKG_REPORT_XML.FINAL_REC);
        PKG_REPORT_XML.FINAL_REC.DELETE;

        IF (TRIM(LST_REC(I).CLIENTS_ADDR2) IS NOT NULL) THEN
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := REPLACE(LST_REC(I)
                                                                                          .CLIENTS_ADDR2,
                                                                                          '&',
                                                                                          '');
          PKG_REPORT_XML.SP_SET_IND_VALUES(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                           PKG_REPORT_XML.FINAL_REC);
          PKG_REPORT_XML.FINAL_REC.DELETE;
        END IF;

        IF (TRIM(LST_REC(I).CLIENTS_ADDR3) IS NOT NULL) THEN
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := REPLACE(LST_REC(I)
                                                                                          .CLIENTS_ADDR3,
                                                                                          '&',
                                                                                          '');
          PKG_REPORT_XML.SP_SET_IND_VALUES(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                           PKG_REPORT_XML.FINAL_REC);
          PKG_REPORT_XML.FINAL_REC.DELETE;
        END IF;

        IF (TRIM(LST_REC(I).CLIENTS_ADDR4) IS NOT NULL) THEN
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := REPLACE(LST_REC(I)
                                                                                          .CLIENTS_ADDR4,
                                                                                          '&',
                                                                                          '');
          PKG_REPORT_XML.SP_SET_IND_VALUES(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                           PKG_REPORT_XML.FINAL_REC);
          PKG_REPORT_XML.FINAL_REC.DELETE;

        END IF;

        IF (TRIM(LST_REC(I).CLIENTS_ADDR5) IS NOT NULL) THEN
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := '';
          PKG_REPORT_XML.FINAL_REC(NVL(PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) := REPLACE(LST_REC(I)
                                                                                          .CLIENTS_ADDR5,
                                                                                          '&',
                                                                                          '');
          PKG_REPORT_XML.SP_SET_IND_VALUES(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                           PKG_REPORT_XML.FINAL_REC);
          PKG_REPORT_XML.FINAL_REC.DELETE;
        END IF;

      END LOOP;
       PKG_REPORT_XML.FINAL_REC.DELETE;
       W_SQL:=NULL;
    END IF;
  END READ_CLIENTS;

  PROCEDURE INIT_PARA IS
  BEGIN
    W_REGN_NO      := '';
    W_TELEPHONE_NO := '';
    W_MOBILE_NO    := '';
    W_TIN_NO       := '';
    W_BRN_CODE     := 0;
    W_TEMP_SL      := 0;
    W_PID_NO       := '';
    W_PID_TYPE     := '';
    W_DOB          := '';
    W_NAME_XML     := '';
    W_ADDRESS_XML  := '';
    W_FLAG         := 'N';
    W_ERR_MSG      := '';
  END INIT_PARA;

BEGIN
  <<PROC_BEGIN>>
  BEGIN
    --ENTITY CODE COMMONLY ADDED - 06-11-2009  - BEG
    PKG_ENTITY.SP_SET_ENTITY_CODE(V_ENTITY_NUM);
    --ENTITY CODE COMMONLY ADDED - 06-11-2009  - END

    INIT_PARA;
    PKG_SPILIT_TOKEN.SP_SPILIT_TOKEN(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                     13,
                                     P_IN_MSG);
    W_BRN_CODE     := PKG_SPILIT_TOKEN.V_LIST_REC(1);
    W_PID_TYPE     := PKG_SPILIT_TOKEN.V_LIST_REC(2);
    W_PID_NO       := PKG_SPILIT_TOKEN.V_LIST_REC(3);
    W_REGN_NO      := PKG_SPILIT_TOKEN.V_LIST_REC(4);
    W_DOB          := PKG_SPILIT_TOKEN.V_LIST_REC(5);
    W_TELEPHONE_NO := PKG_SPILIT_TOKEN.V_LIST_REC(6);
    W_NAME_XML     := PKG_SPILIT_TOKEN.V_LIST_REC(7);
    W_ADDRESS_XML  := PKG_SPILIT_TOKEN.V_LIST_REC(8);
    W_COUNT_NAME   := PKG_SPILIT_TOKEN.V_LIST_REC(9);
    W_COUNT_ADDR   := PKG_SPILIT_TOKEN.V_LIST_REC(10);
    W_TEMP_SL      := PKG_SPILIT_TOKEN.V_LIST_REC(11);
    W_MOBILE_NO    := PKG_SPILIT_TOKEN.V_LIST_REC(12);
    W_TIN_NO       := PKG_SPILIT_TOKEN.V_LIST_REC(13);

    IF (W_TEMP_SL = 0) THEN
      W_TEMP_SL := PKG_PB_GLOBAL.SP_GET_REPORT_SL(PKG_ENTITY.FN_GET_ENTITY_CODE);
    END IF;

    DELETE FROM AMLCHKLOGSTAT WHERE AMLCHKLOG_TMP_SL = W_TEMP_SL;

    READ_CLIENTS;

    P_REPORT_SL := PKG_REPORT_XML.V_REPORT_SL;
    P_ERR_MSG   := W_ERR_MSG;

  EXCEPTION
    WHEN OTHERS THEN
      IF (TRIM(W_ERR_MSG) IS NULL) THEN
        W_ERR_MSG := SUBSTR('ERROR IN SP_QCUSTBROWSER ' || SQLERRM, 1, 1000);
      END IF;
  END PROC_BEGIN;

  PKG_CHECK_DUP_CLIENT.INSERT_AMLCHKLOGSTAT(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                            W_TEMP_SL,
                                            '1',
                                            W_ERR_MSG);

  COMMIT;
  P_ERR_MSG := W_ERR_MSG;

END SP_QCUSTBROWSER;

/