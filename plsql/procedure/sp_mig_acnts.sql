CREATE OR REPLACE PROCEDURE SP_MIG_ACNTS(P_BRANCH_CODE NUMBER,
                                         P_ERR_MSG     OUT VARCHAR2) IS

  /*
    Author:S.Rajalakshmi
    Date  :
  
  
    List of  Table/s Referred
    1. MIG_ACNTS
    2. MIG_ACNTLIEN
  
  
  
    List of Tables Updated
    1. ACNTOTN
    2. ACNTS
    3. ACNTMAIL
    4. ACNTFRZ
    5. ACNTSTATUS
    6. ACNTLIEN
    7. ACNTBAL
    8. CONNPINFO
    9. ECSACMAP
  
    Modification History
    -----------------------------------------------------------------------------------------
    Sl.            Description                                    Mod By             Mod on
    -----------------------------------------------------------------------------------------
     1.    Instead of Acntotn  ACNTOTNNEW TABLE IS UPDATED       K. NEELAKANTAN     03-NOV-2009 --NEELS-MDS-03-11-2009
    -----------------------------------------------------------------------------------------
  */

  W_CURR_DATE     DATE;
  W_ENTD_BY_GLOB  VARCHAR2(8) := 'MIG';
  W_SRC_KEY       VARCHAR2(1000);
  W_ER_CODE       VARCHAR2(5);
  W_ER_DESC       VARCHAR2(1000);
  W_REPAY_TO      NUMBER(3);
  W_CLIENT_TYPE   CHAR(1);
  W_LOC_CODE      VARCHAR2(6);
  W_BUS_DIV_CODE  VARCHAR2(3);
  W_CURR_CODE     VARCHAR2(3) := 'BDT'; --shamsudeen-chn-24may2012-changed INR to BDT
  W_ENTITY_NUMBER NUMBER(3) := GET_OTN.ENTITY_NUMBER;

  -- S.RAJALAKSHMI- 27-OCT-2009- BEGIN
  W_CONNP_NUM     NUMBER(10);
  W_INTERN_ACCNUM NUMBER(14);
  W_CLIENT_CODE   NUMBER(12);
  -- S.RAJALAKSHMI- 27-OCT-2009-END

  W_LIEN_INTERN_ACC NUMBER(14);

  W_ACNUM_WITHOUT_CHARS NUMBER(20);

  TYPE ACNTS_MIG IS RECORD(
    W_ACNUM               VARCHAR2(25),
    W_BRN_CODE            NUMBER(6),
    W_CLIENT_NUM          NUMBER(12),
    W_PROD_CODE           NUMBER(4),
    W_AC_TYPE             VARCHAR2(5),
    W_AC_SUB_TYPE         NUMBER(3),
    W_SCHEME_CODE         VARCHAR2(6),
    W_OPENING_DATE        DATE,
    W_AC_NAME1            VARCHAR2(50),
    W_AC_NAME2            VARCHAR2(50),
    W_SHORT_NAME          VARCHAR2(25),
    W_AC_ADDR1            VARCHAR2(35),
    W_AC_ADDR2            VARCHAR2(35),
    W_AC_ADDR3            VARCHAR2(35),
    W_AC_ADDR4            VARCHAR2(35),
    W_AC_ADDR5            VARCHAR2(35),
    W_LOCN_CODE           VARCHAR2(6),
    W_CURR_CODE           VARCHAR2(3),
    W_GLACC_CODE          VARCHAR2(15),
    W_SALARY_ACNT         CHAR(1),
    W_PASSBK_REQD         CHAR(1),
    W_DCHANNEL_CODE       VARCHAR2(6),
    W_MKT_CHANNEL_CODE    VARCHAR2(6),
    W_MKT_BY_STAFF        VARCHAR2(8),
    W_MKT_BY_BRN          NUMBER(6),
    W_DSA_CODE            VARCHAR2(8),
    W_MODE_OF_OPERN       NUMBER(3),
    W_MOPR_ADDN_INFO      VARCHAR2(50),
    W_REPAYABLE_TO        NUMBER(3),
    W_SPECIAL_ACNT        CHAR(1),
    W_NOMINATION_REQD     CHAR(1),
    W_CREDIT_INT_REQD     CHAR(1),
    W_MINOR_ACNT          CHAR(1),
    W_POWER_OF_ATTORNEY   CHAR(1),
    W_NUM_SIG_COMB        NUMBER(5),
    W_TELLER_OPERN        CHAR(1),
    W_ATM_OPERN           CHAR(1),
    W_CALL_CENTER_OPERN   CHAR(1),
    W_INET_OPERN          CHAR(1),
    W_CR_CARDS_ALLOWED    CHAR(1),
    W_KIOSK_BANKING       CHAR(1),
    W_SMS_OPERN           CHAR(1),
    W_OD_ALLOWED          CHAR(1),
    W_CHQBK_REQD          CHAR(1),
    W_BUSDIVN_CODE        VARCHAR2(3),
    W_BASE_DATE           DATE,
    W_INOP_ACNT           CHAR(1),
    W_DORMANT_ACNT        CHAR(1),
    W_LAST_TRAN_DATE      DATE,
    W_INT_CALC_UPTO       DATE,
    W_INT_ACCR_UPTO       DATE,
    W_INT_DBCR_UPTO       DATE,
    W_TRF_TO_OVERDUE      DATE,
    W_DB_FREEZED          CHAR(1),
    W_CR_FREEZED          CHAR(1),
    W_LAST_CHQBK_ISSUED   DATE,
    W_CLOSURE_DATE        DATE,
    W_ADDR_CHOICE         CHAR(1),
    W_THIRD_PARTY         VARCHAR2(8),
    W_OTH_TITLE           VARCHAR2(4),
    W_OTH_NAME            VARCHAR2(50),
    W_OTH_ADDR1           VARCHAR2(35),
    W_OTH_ADDR2           VARCHAR2(35),
    W_OTH_ADDR3           VARCHAR2(35),
    W_OTH_ADDR4           VARCHAR2(35),
    W_OTH_ADDR5           VARCHAR2(35),
    W_STMT_REQD           CHAR(1),
    W_STMT_FREQ           CHAR(1),
    W_STMT_PRINT_OPTION   CHAR(1),
    W_WEEKDAY_STMT        CHAR(1),
    W_ENTD_BY             VARCHAR2(8),
    W_ENTD_ON             DATE,
    W_FREEZED_ON          DATE,
    W_FREEZE_REQ_BY1      VARCHAR2(35),
    W_FREEZE_REQ_BY2      VARCHAR2(35),
    W_FREEZE_REQ_BY3      VARCHAR2(35),
    W_FREEZE_REQ_BY4      VARCHAR2(35),
    W_REASON1             VARCHAR2(35),
    W_REASON2             VARCHAR2(35),
    W_REASON3             VARCHAR2(35),
    W_REASON4             VARCHAR2(35),
    W_ABB_TRAN_ALLOWED    VARCHAR2(1),
    W_ACNTS_DECEASED_APPL VARCHAR2(1));

  MYEXCEPTION EXCEPTION;

  W_TMP_CLIENTCODE NUMBER(14);
  W_TMP_ACNUM      NUMBER(14);
  W_FIRST          BOOLEAN;
  W_DAYSL          NUMBER(5);
  W_AC             VARCHAR2(2);
  W_INOP_DORM      VARCHAR2(1);

  TYPE IN_ACNTS_MIG IS TABLE OF ACNTS_MIG INDEX BY PLS_INTEGER;
  V_IN_ACNTS_MIG IN_ACNTS_MIG;

  W_CL_CODE NUMBER(12) := 0;

  W_INT_AC_NUM NUMBER(14);
  W_INT_NUM    VARCHAR2(25);
  W_OUT_SQ     ACNTLINK.ACNTLINK_AC_SEQ_NUM%TYPE;

  FUNCTION GET_NEWCLN(BRNNUM NUMBER, OLDCLN NUMBER) RETURN NUMBER IS
    W_NEW_CLCODE NUMBER(20);
    W_MYERR      VARCHAR2(500);
  BEGIN
    SELECT NEW_CLCODE
      INTO W_NEW_CLCODE
      FROM TEMP_CLIENT
     WHERE OLD_CLCODE = OLDCLN
       AND BRN_CODE = BRNNUM;
    RETURN W_NEW_CLCODE;
  EXCEPTION
    WHEN OTHERS THEN
      W_MYERR := SQLERRM;
      DBMS_OUTPUT.PUT_LINE(W_MYERR);
      RETURN 0;
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

  FUNCTION ACNUM_WITHOUT_CHARS(P_STR VARCHAR2) RETURN NUMBER IS
    W_STR     VARCHAR2(100);
    W_TMP_STR NUMBER(20);
  BEGIN
    W_STR := P_STR;
    W_STR := REPLACE(W_STR, 'A', '');
    W_STR := REPLACE(W_STR, 'B', '');
    W_STR := REPLACE(W_STR, 'C', '');
    W_STR := REPLACE(W_STR, 'D', '');
    W_STR := REPLACE(W_STR, 'E', '');
    W_STR := REPLACE(W_STR, 'F', '');
    W_STR := REPLACE(W_STR, 'G', '');
    W_STR := REPLACE(W_STR, 'H', '');
    W_STR := REPLACE(W_STR, 'I', '');
    W_STR := REPLACE(W_STR, 'J', '');
    W_STR := REPLACE(W_STR, 'K', '');
    W_STR := REPLACE(W_STR, 'L', '');
    W_STR := REPLACE(W_STR, 'M', '');
    W_STR := REPLACE(W_STR, 'N', '');
    W_STR := REPLACE(W_STR, 'O', '');
    W_STR := REPLACE(W_STR, 'P', '');
    W_STR := REPLACE(W_STR, 'Q', '');
    W_STR := REPLACE(W_STR, 'R', '');
    W_STR := REPLACE(W_STR, 'S', '');
    W_STR := REPLACE(W_STR, 'T', '');
    W_STR := REPLACE(W_STR, 'U', '');
    W_STR := REPLACE(W_STR, 'V', '');
    W_STR := REPLACE(W_STR, 'W', '');
    W_STR := REPLACE(W_STR, 'X', '');
    W_STR := REPLACE(W_STR, 'Y', '');
    W_STR := REPLACE(W_STR, 'Z', '');
  
    W_TMP_STR := TO_NUMBER(W_STR);
    RETURN W_TMP_STR;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END ACNUM_WITHOUT_CHARS;

  PROCEDURE FETCH_ACNUM(W_OLDACCNUM VARCHAR2, W_NEWACNUM OUT NUMBER) IS
  BEGIN
    SELECT ACNTOTN_INTERNAL_ACNUM
      INTO W_NEWACNUM
      FROM ACNTOTN
     WHERE ACNTOTN_ENTITY_NUM = W_ENTITY_NUMBER
       AND ACNTOTN.ACNTOTN_OLD_ACNT_NUM = W_OLDACCNUM;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      W_ER_CODE := 'ACCP2';
      W_ER_DESC := 'SELECT- CHECK INTERNAL ACC NUM -ACNTLIEN- ' || SQLERRM;
      W_SRC_KEY := P_BRANCH_CODE || '-' || W_OLDACCNUM;
      POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
  END FETCH_ACNUM;

  PROCEDURE INSERT_CONNPINFO(P_CONNP_INV_NUM             NUMBER,
                             P_CONNP_CONN_ROLE           VARCHAR2,
                             P_CONNP_SL                  NUMBER,
                             P_CONNP_INTERNAL_ACNUM      NUMBER,
                             P_CONNP_CLIENT_NUM          NUMBER,
                             P_CONNP_CLIENT_NAME         VARCHAR2,
                             P_CONNP_DATE_OF_BIRTH       DATE,
                             P_CONNP_CLIENT_DEPT         VARCHAR2,
                             P_CONNP_DESIG_CODE          VARCHAR2,
                             P_CONNP_CLIENT_ADDR1        VARCHAR2,
                             P_CONNP_CLIENT_ADDR2        VARCHAR2,
                             P_CONNP_CLIENT_ADDR3        VARCHAR2,
                             P_CONNP_CLIENT_ADDR4        VARCHAR2,
                             P_CONNP_CLIENT_ADDR5        VARCHAR2,
                             P_CONNP_CLIENT_CNTRY        VARCHAR2,
                             P_CONNP_NATURE_OF_GUARDIAN  CHAR,
                             P_CONNP_GUARDIAN_FOR        CHAR,
                             P_CONNP_GUARDIAN_FOR_CLIENT NUMBER,
                             P_CONNP_RELATIONSHIP_INFO   VARCHAR2,
                             P_CONNP_RES_TEL             VARCHAR2,
                             P_CONNP_OFF_TEL             VARCHAR2,
                             P_CONNP_GSM_NUM             VARCHAR2,
                             P_CONNP_EMAIL_ADDR          VARCHAR2,
                             P_CONNP_REM1                VARCHAR2,
                             P_CONNP_REM2                VARCHAR2,
                             P_CONNP_REM3                VARCHAR2,
                             P_CONNP_SHARE_HOLD_PER      NUMBER,
                             P_CONNP_PID_INV_NUM         NUMBER,
                             P_CONNP_SOURCE_TABLE        VARCHAR2,
                             P_CONNP_SOURCE_KEY          VARCHAR2) IS
  BEGIN
    INSERT INTO CONNPINFO
      (CONNP_INV_NUM,
       CONNP_CONN_ROLE,
       CONNP_SL,
       CONNP_INTERNAL_ACNUM,
       CONNP_CLIENT_NUM,
       CONNP_CLIENT_NAME,
       CONNP_DATE_OF_BIRTH,
       CONNP_CLIENT_DEPT,
       CONNP_DESIG_CODE,
       CONNP_CLIENT_ADDR1,
       CONNP_CLIENT_ADDR2,
       CONNP_CLIENT_ADDR3,
       CONNP_CLIENT_ADDR4,
       CONNP_CLIENT_ADDR5,
       CONNP_CLIENT_CNTRY,
       CONNP_NATURE_OF_GUARDIAN,
       CONNP_GUARDIAN_FOR,
       CONNP_GUARDIAN_FOR_CLIENT,
       CONNP_RELATIONSHIP_INFO,
       CONNP_RES_TEL,
       CONNP_OFF_TEL,
       CONNP_GSM_NUM,
       CONNP_EMAIL_ADDR,
       CONNP_REM1,
       CONNP_REM2,
       CONNP_REM3,
       CONNP_SHARE_HOLD_PER,
       CONNP_PID_INV_NUM,
       CONNP_SOURCE_TABLE,
       CONNP_SOURCE_KEY)
    VALUES
      (P_CONNP_INV_NUM,
       P_CONNP_CONN_ROLE,
       P_CONNP_SL,
       P_CONNP_INTERNAL_ACNUM,
       P_CONNP_CLIENT_NUM,
       P_CONNP_CLIENT_NAME,
       P_CONNP_DATE_OF_BIRTH,
       P_CONNP_CLIENT_DEPT,
       P_CONNP_DESIG_CODE,
       P_CONNP_CLIENT_ADDR1,
       P_CONNP_CLIENT_ADDR2,
       P_CONNP_CLIENT_ADDR3,
       P_CONNP_CLIENT_ADDR4,
       P_CONNP_CLIENT_ADDR5,
       P_CONNP_CLIENT_CNTRY,
       P_CONNP_NATURE_OF_GUARDIAN,
       P_CONNP_GUARDIAN_FOR,
       P_CONNP_GUARDIAN_FOR_CLIENT,
       P_CONNP_RELATIONSHIP_INFO,
       P_CONNP_RES_TEL,
       P_CONNP_OFF_TEL,
       P_CONNP_GSM_NUM,
       P_CONNP_EMAIL_ADDR,
       P_CONNP_REM1,
       P_CONNP_REM2,
       P_CONNP_REM3,
       P_CONNP_SHARE_HOLD_PER,
       P_CONNP_PID_INV_NUM,
       P_CONNP_SOURCE_TABLE,
       P_CONNP_SOURCE_KEY);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('ERROR ' || SQLERRM);
  END INSERT_CONNPINFO;

  FUNCTION GET_CL_AC(P_CL_AC VARCHAR2, P_CA VARCHAR2) RETURN VARCHAR2 IS
    W_NEW_CODE VARCHAR2(20);
  BEGIN
  
    IF P_CA = 'C' THEN
      SELECT NEW_CLCODE
        INTO W_NEW_CODE
        FROM TEMP_CLIENT
       WHERE OLD_CLCODE = P_CL_AC
         AND BRN_CODE = P_BRANCH_CODE;
    
    ELSIF P_CA = 'A' THEN
    
      SELECT ACNTOTN_INTERNAL_ACNUM
        INTO W_NEW_CODE
        FROM ACNTOTN
       WHERE ACNTOTN_ENTITY_NUM = W_ENTITY_NUMBER
         AND ACNTOTN.ACNTOTN_OLD_ACNT_NUM = P_CL_AC
         AND ACNTOTN_OLD_ACNT_BRN = P_BRANCH_CODE;
    
    ELSIF P_CA = 'NA' THEN
    
      SELECT ACNTS.ACNTS_CLIENT_NUM
        INTO W_NEW_CODE
        FROM ACNTS
       WHERE ACNTS_ENTITY_NUM = W_ENTITY_NUMBER
         AND ACNTS_INTERNAL_ACNUM = P_CL_AC;
    
    END IF;
  
    RETURN W_NEW_CODE;
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    WHEN OTHERS THEN
      P_ERR_MSG := SQLERRM;
      DBMS_OUTPUT.PUT_LINE('OLD CLIENT CODE ' || P_CL_AC || P_ERR_MSG);
      RETURN 0;
  END GET_CL_AC;

BEGIN
  P_ERR_MSG := '0';
  DBMS_OUTPUT.DISABLE();
  DBMS_OUTPUT.ENABLE(90000000);
  SELECT MN_CURR_BUSINESS_DATE INTO W_CURR_DATE FROM MAINCONT;

  <<BRN_CHECK>>
  BEGIN
    SELECT MBRN_LOCN_CODE
      INTO W_LOC_CODE
      FROM MBRN
     WHERE MBRN_ENTITY_NUM = W_ENTITY_NUMBER
       AND MBRN_CODE = P_BRANCH_CODE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      W_ER_CODE := 'AC1';
      W_ER_DESC := 'SP_ACNTS- BRN_CHECK' || SQLERRM;
      W_SRC_KEY := P_BRANCH_CODE || '-' || SQLERRM;
      POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
  END BRN_CHECK;

  <<BULK_CHECK>>
  BEGIN
    SELECT ACNTS_ACNUM,
           ACNTS_BRN_CODE,
           ACNTS_CLIENT_NUM,
           ACNTS_PROD_CODE,
           ACNTS_AC_TYPE,
           ACNTS_AC_SUB_TYPE,
           ACNTS_SCHEME_CODE,
           ACNTS_OPENING_DATE,
           ACNTS_AC_NAME1,
           ACNTS_AC_NAME2,
           ACNTS_SHORT_NAME,
           ACNTS_AC_ADDR1,
           ACNTS_AC_ADDR2,
           ACNTS_AC_ADDR3,
           ACNTS_AC_ADDR4,
           ACNTS_AC_ADDR5,
           NVL(ACNTS_LOCN_CODE, W_LOC_CODE),
           NVL(ACNTS_CURR_CODE, W_CURR_CODE),
           ACNTS_GLACC_CODE,
           ACNTS_SALARY_ACNT,
           ACNTS_PASSBK_REQD,
           ACNTS_DCHANNEL_CODE,
           ACNTS_MKT_CHANNEL_CODE,
           ACNTS_MKT_BY_STAFF,
           ACNTS_MKT_BY_BRN,
           ACNTS_DSA_CODE,
           ACNTS_MODE_OF_OPERN,
           ACNTS_MOPR_ADDN_INFO,
           ACNTS_REPAYABLE_TO,
           ACNTS_SPECIAL_ACNT,
           ACNTS_NOMINATION_REQD,
           ACNTS_CREDIT_INT_REQD,
           ACNTS_MINOR_ACNT,
           ACNTS_POWER_OF_ATTORNEY,
           ACNTS_NUM_SIG_COMB,
           ACNTS_TELLER_OPERN,
           ACNTS_ATM_OPERN,
           ACNTS_CALL_CENTER_OPERN,
           ACNTS_INET_OPERN,
           ACNTS_CR_CARDS_ALLOWED,
           ACNTS_KIOSK_BANKING,
           ACNTS_SMS_OPERN,
           ACNTS_OD_ALLOWED,
           ACNTS_CHQBK_REQD,
           ACNTS_BUSDIVN_CODE,
           ACNTS_BASE_DATE,
           ACNTS_INOP_ACNT,
           ACNTS_DORMANT_ACNT,
           ACNTS_LAST_TRAN_DATE,
           ACNTS_INT_CALC_UPTO,
           ACNTS_INT_ACCR_UPTO,
           ACNTS_INT_DBCR_UPTO,
           ACNTS_TRF_TO_OVERDUE,
           ACNTS_DB_FREEZED,
           ACNTS_CR_FREEZED,
           ACNTS_LAST_CHQBK_ISSUED,
           ACNTS_CLOSURE_DATE,
           ACNTMAIL_ADDR_CHOICE ACNTS_ADDR_CHOICE,
           ACNTMAIL_THIRD_PARTY ACNTS_THIRD_PARTY,
           ACNTMAIL_OTH_TITLE ACNTS_OTH_TITLE,
           ACNTMAIL_OTH_TITLE ACNTS_OTH_NAME,
           ACNTMAIL_OTH_ADDR1 ACNTS_OTH_ADDR1,
           ACNTMAIL_OTH_ADDR2 ACNTS_OTH_ADDR2,
           ACNTMAIL_OTH_ADDR3 ACNTS_OTH_ADDR3,
           ACNTMAIL_OTH_ADDR4 ACNTS_OTH_ADDR4,
           ACNTMAIL_OTH_ADDR5 ACNTS_OTH_ADDR5,
           ACNTMAIL_STMT_REQD ACNTS_STMT_REQD,
           ACNTMAIL_STMT_FREQ ACNTS_STMT_FREQ,
           ACNTMAIL_STMT_PRINT_OPTION ACNTS_STMT_PRINT_OPTION,
           ACNTMAIL_WEEKDAY_STMT ACNTS_WEEKDAY_STMT,
           ACNTS_ENTD_BY,
           ACNTS_ENTD_ON,
           ACNTS_FREEZED_ON,
           ACNTS_FREEZE_REQ_BY1,
           ACNTS_FREEZE_REQ_BY2,
           ACNTS_FREEZE_REQ_BY3,
           ACNTS_FREEZE_REQ_BY4,
           ACNTS_REASON1,
           ACNTS_REASON2,
           ACNTS_REASON3,
           ACNTS_REASON4,
           ACNTS_ABB_TRAN_ALLOWED,
           ACNTS_DECEASED_APPL BULK COLLECT
      INTO V_IN_ACNTS_MIG
      FROM MIG_ACNTS
     WHERE ACNTS_BRN_CODE = P_BRANCH_CODE;
  EXCEPTION
    WHEN OTHERS THEN
      W_ER_CODE := 'AC2';
      W_ER_DESC := 'SP_ACNTS-SELECT-BULK_CHECK';
      W_SRC_KEY := P_BRANCH_CODE || '-' || SQLERRM;
      POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
  END BULK_CHECK;

  --  DBMS_OUTPUT.PUT_LINE(V_IN_ACNTS_MIG.COUNT);

  IF V_IN_ACNTS_MIG.COUNT > 0 THEN
    FOR IDX IN V_IN_ACNTS_MIG.FIRST .. V_IN_ACNTS_MIG.LAST LOOP
    
      <<CHECK_CODE>>
      BEGIN
      
        W_CL_CODE := GET_NEWCLN(V_IN_ACNTS_MIG(IDX).W_BRN_CODE,
                                V_IN_ACNTS_MIG(IDX).W_CLIENT_NUM);
      EXCEPTION
        WHEN OTHERS THEN
          W_ER_CODE := 'AC3';
          W_ER_DESC := 'SP_ACNTS-CLIENT_CODE CHECK CALLING PROCEDURE';
          W_SRC_KEY := P_BRANCH_CODE || '-' || 'CLIENT CODE ' || W_CL_CODE ||
                       'PROD CODE' || V_IN_ACNTS_MIG(IDX).W_PROD_CODE || V_IN_ACNTS_MIG(IDX)
                      .W_CLIENT_NUM || SQLERRM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END CHECK_CODE;
    
      <<CHECK_NUMBER>>
      BEGIN
        PKG_GEN_ACNUM.SP_ACNTS_NUM(W_ENTITY_NUMBER,
                                   V_IN_ACNTS_MIG (IDX).W_BRN_CODE,
                                   W_CL_CODE,
                                   V_IN_ACNTS_MIG (IDX).W_PROD_CODE,
                                   V_IN_ACNTS_MIG (IDX).W_CURR_CODE,
                                   W_INT_AC_NUM,
                                   W_INT_NUM,
                                   0,
                                   W_OUT_SQ,
                                   P_ERR_MSG);
      EXCEPTION
        WHEN OTHERS THEN
          W_ER_CODE := 'AC4';
          W_ER_DESC := 'SP_ACNTS-CLIENT_CHECK_NUMBER CALLING PACKAGE' ||
                       SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || 'NEW_CL_CODE' || W_CL_CODE || V_IN_ACNTS_MIG(IDX)
                      .W_CLIENT_NUM || 'PROD CODE ' || V_IN_ACNTS_MIG(IDX)
                      .W_PROD_CODE;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END CHECK_NUMBER;
    
      <<TYPE_CHECK>>
      BEGIN
        SELECT CLIENTS_TYPE_FLG
          INTO W_CLIENT_TYPE
          FROM CLIENTS
         WHERE CLIENTS.CLIENTS_CODE = W_CL_CODE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          W_ER_CODE := 'AC5';
          W_ER_DESC := 'SP_ACNTS-CLIENT_TYPE_FLAG_CHECKING' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || V_IN_ACNTS_MIG(IDX)
                      .W_CLIENT_NUM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END TYPE_CHECK;
    
      IF W_CLIENT_TYPE IN ('I', 'C') THEN
        W_REPAY_TO := 1;
      ELSIF W_CLIENT_TYPE = 'J' THEN
        W_REPAY_TO := 2;
      END IF;
    
      IF W_CLIENT_TYPE = 'I' OR W_CLIENT_TYPE = 'J' THEN
        W_BUS_DIV_CODE := '01';
      ELSIF W_CLIENT_TYPE = 'C' THEN
        W_BUS_DIV_CODE := '02';
      END IF;
    
      --  DBMS_OUTPUT.PUT_LINE(W_INT_NUM);
      --  dbms_output.put_line(W_INT_AC_NUM);
    
      <<INSERT_ACNTOTN>>
    
      BEGIN
        INSERT INTO ACNTOTN
          (ACNTOTN_ENTITY_NUM,
           ACNTOTN_INTERNAL_ACNUM,
           ACNTOTN_OTN_SL,
           ACNTOTN_OLD_ACNT_BRN,
           ACNTOTN_OLD_ACNT_GL,
           ACNTOTN_OLD_ACNT_NUM,
           ACNTOTN_OLD_ACNT_CURR,
           ACNTOTN_REMARKS1,
           ACNTOTN_REMARKS2,
           ACNTOTN_REMARKS3,
           ACNTOTN_ENTD_BY,
           ACNTOTN_ENTD_ON,
           ACNTOTN_LAST_MOD_BY,
           ACNTOTN_LAST_MOD_ON)
        VALUES
          (W_ENTITY_NUMBER,
           W_INT_AC_NUM,
           1,
           V_IN_ACNTS_MIG (IDX).W_BRN_CODE,
           V_IN_ACNTS_MIG (IDX).W_GLACC_CODE,
           V_IN_ACNTS_MIG (IDX).W_ACNUM,
           V_IN_ACNTS_MIG (IDX).W_CURR_CODE,
           NULL,
           NULL,
           NULL,
           W_ENTD_BY_GLOB,
           W_CURR_DATE,
           NULL,
           NULL);
        --NEELS-MDS-03-11-2009 BEG
        EXECUTE IMMEDIATE 'INSERT INTO ACNTOTNNEW
       (
       ACNTOTNNEW_ENTITY_NUM,ACNTOTN_INTERNAL_ACNUM,ACNTOTN_OTN_SL,ACNTOTN_OLD_ACNUM,
       ACNTOTN_OLD_DISP_ACNUM,ACNTOTN_REMARKS1,
       ACNTOTN_REMARKS2,ACNTOTN_REMARKS3,
       ACNTOTN_ENTD_BY,ACNTOTN_ENTD_ON,
       ACNTOTN_LAST_MOD_BY,ACNTOTN_LAST_MOD_ON
           ) VALUES (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12)'
          USING W_ENTITY_NUMBER, W_INT_AC_NUM, 1, V_IN_ACNTS_MIG(IDX).W_ACNUM, V_IN_ACNTS_MIG(IDX).W_ACNUM, 'MIGRATION', ' ', ' ', W_ENTD_BY_GLOB, W_CURR_DATE, W_ENTD_BY_GLOB, W_CURR_DATE;
        --NEELS-MDS-03-11-2009 END
      EXCEPTION
        WHEN OTHERS THEN
          W_ER_CODE := 'AC6';
          W_ER_DESC := 'SP_ACNTS-INSERT_ACNTOTN CHECK CALLING PROCEDURE' ||
                       SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || V_IN_ACNTS_MIG(IDX)
                      .W_CLIENT_NUM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END INSERT_ACNTOTN;
    
      <<INSERT_ACNTS>>
      BEGIN
        INSERT INTO ACNTS
          (ACNTS_ENTITY_NUM,
           ACNTS_INTERNAL_ACNUM,
           ACNTS_BRN_CODE,
           ACNTS_CLIENT_NUM,
           ACNTS_AC_SEQ_NUM,
           ACNTS_ACCOUNT_NUMBER,
           ACNTS_PROD_CODE,
           ACNTS_AC_TYPE,
           ACNTS_AC_SUB_TYPE,
           ACNTS_SCHEME_CODE,
           ACNTS_OPENING_DATE,
           ACNTS_AC_NAME1,
           ACNTS_AC_NAME2,
           ACNTS_SHORT_NAME,
           ACNTS_AC_ADDR1,
           ACNTS_AC_ADDR2,
           ACNTS_AC_ADDR3,
           ACNTS_AC_ADDR4,
           ACNTS_AC_ADDR5,
           ACNTS_LOCN_CODE,
           ACNTS_CURR_CODE,
           ACNTS_GLACC_CODE,
           ACNTS_SALARY_ACNT,
           ACNTS_PASSBK_REQD,
           ACNTS_DCHANNEL_CODE,
           ACNTS_MKT_CHANNEL_CODE,
           ACNTS_MKT_BY_STAFF,
           ACNTS_MKT_BY_BRN,
           ACNTS_DSA_CODE,
           ACNTS_MODE_OF_OPERN,
           ACNTS_MOPR_ADDN_INFO,
           ACNTS_REPAYABLE_TO,
           ACNTS_SPECIAL_ACNT,
           ACNTS_NOMINATION_REQD,
           ACNTS_CREDIT_INT_REQD,
           ACNTS_MINOR_ACNT,
           ACNTS_POWER_OF_ATTORNEY,
           ACNTS_CONNP_INV_NUM,
           ACNTS_NUM_SIG_COMB,
           ACNTS_TELLER_OPERN,
           ACNTS_ATM_OPERN,
           ACNTS_CALL_CENTER_OPERN,
           ACNTS_INET_OPERN,
           ACNTS_CR_CARDS_ALLOWED,
           ACNTS_KIOSK_BANKING,
           ACNTS_SMS_OPERN,
           ACNTS_OD_ALLOWED,
           ACNTS_CHQBK_REQD,
           ACNTS_ARM_CRM,
           ACNTS_ARM_ROLE,
           ACNTS_BUSDIVN_CODE,
           ACNTS_CREATION_STATUS,
           ACNTS_BASE_DATE,
           ACNTS_INOP_ACNT,
           ACNTS_DORMANT_ACNT,
           ACNTS_LAST_TRAN_DATE,
           ACNTS_NONSYS_LAST_DATE,
           ACNTS_INT_CALC_UPTO,
           ACNTS_MMB_INT_ACCR_UPTO,
           ACNTS_INT_ACCR_UPTO,
           ACNTS_INT_DBCR_UPTO,
           ACNTS_TRF_TO_OVERDUE,
           ACNTS_DB_FREEZED,
           ACNTS_CR_FREEZED,
           ACNTS_CONTRACT_BASED_FLG,
           ACNTS_ACST_UPTO_DATE,
           ACNTS_LAST_STMT_NUM,
           ACNTS_LAST_CHQBK_ISSUED,
           ACNTS_CLOSURE_DATE,
           ACNTS_PREOPEN_ENTD_BY,
           ACNTS_PREOPEN_ENTD_ON,
           ACNTS_PREOPEN_LAST_MOD_BY,
           ACNTS_PREOPEN_LAST_MOD_ON,
           ACNTS_ENTD_BY,
           ACNTS_ENTD_ON,
           ACNTS_LAST_MOD_BY,
           ACNTS_LAST_MOD_ON,
           ACNTS_AUTH_BY,
           ACNTS_AUTH_ON,
           TBA_MAIN_KEY,
           ACNTS_ABB_TRAN_ALLOWED,
           ACNTS_DECEASED_APPL)
        VALUES
          (W_ENTITY_NUMBER,
           W_INT_AC_NUM,
           V_IN_ACNTS_MIG(IDX).W_BRN_CODE,
           W_CL_CODE,
           W_OUT_SQ,
           W_INT_NUM,
           V_IN_ACNTS_MIG(IDX).W_PROD_CODE,
           V_IN_ACNTS_MIG(IDX).W_AC_TYPE,
           NVL(V_IN_ACNTS_MIG(IDX).W_AC_SUB_TYPE, 0),
           V_IN_ACNTS_MIG(IDX).W_SCHEME_CODE,
           V_IN_ACNTS_MIG(IDX).W_OPENING_DATE,
           V_IN_ACNTS_MIG(IDX).W_AC_NAME1,
           V_IN_ACNTS_MIG(IDX).W_AC_NAME2,
           V_IN_ACNTS_MIG(IDX).W_SHORT_NAME,
           V_IN_ACNTS_MIG(IDX).W_AC_ADDR1,
           V_IN_ACNTS_MIG(IDX).W_AC_ADDR2,
           V_IN_ACNTS_MIG(IDX).W_AC_ADDR3,
           V_IN_ACNTS_MIG(IDX).W_AC_ADDR4,
           V_IN_ACNTS_MIG(IDX).W_AC_ADDR5,
           V_IN_ACNTS_MIG(IDX).W_LOCN_CODE,
           V_IN_ACNTS_MIG(IDX).W_CURR_CODE,
           V_IN_ACNTS_MIG(IDX).W_GLACC_CODE,
           V_IN_ACNTS_MIG(IDX).W_SALARY_ACNT,
           V_IN_ACNTS_MIG(IDX).W_PASSBK_REQD,
           V_IN_ACNTS_MIG(IDX).W_DCHANNEL_CODE,
           V_IN_ACNTS_MIG(IDX).W_MKT_CHANNEL_CODE,
           V_IN_ACNTS_MIG(IDX).W_MKT_BY_STAFF,
           V_IN_ACNTS_MIG(IDX).W_MKT_BY_BRN,
           V_IN_ACNTS_MIG(IDX).W_DSA_CODE,
           V_IN_ACNTS_MIG(IDX).W_MODE_OF_OPERN,
           V_IN_ACNTS_MIG(IDX).W_MOPR_ADDN_INFO,
           V_IN_ACNTS_MIG(IDX).W_REPAYABLE_TO,
           V_IN_ACNTS_MIG(IDX).W_SPECIAL_ACNT,
           V_IN_ACNTS_MIG(IDX).W_NOMINATION_REQD,
           V_IN_ACNTS_MIG(IDX).W_CREDIT_INT_REQD,
           V_IN_ACNTS_MIG(IDX).W_MINOR_ACNT,
           V_IN_ACNTS_MIG(IDX).W_POWER_OF_ATTORNEY,
           NULL,
           V_IN_ACNTS_MIG(IDX).W_NUM_SIG_COMB,
           V_IN_ACNTS_MIG(IDX).W_TELLER_OPERN,
           V_IN_ACNTS_MIG(IDX).W_ATM_OPERN,
           V_IN_ACNTS_MIG(IDX).W_CALL_CENTER_OPERN,
           V_IN_ACNTS_MIG(IDX).W_INET_OPERN,
           V_IN_ACNTS_MIG(IDX).W_CR_CARDS_ALLOWED,
           V_IN_ACNTS_MIG(IDX).W_KIOSK_BANKING,
           V_IN_ACNTS_MIG(IDX).W_SMS_OPERN,
           V_IN_ACNTS_MIG(IDX).W_OD_ALLOWED,
           V_IN_ACNTS_MIG(IDX).W_CHQBK_REQD,
           NULL,
           NULL,
           W_BUS_DIV_CODE,
           'F',
           V_IN_ACNTS_MIG(IDX).W_BASE_DATE,
           V_IN_ACNTS_MIG(IDX).W_INOP_ACNT,
           V_IN_ACNTS_MIG(IDX).W_DORMANT_ACNT,
           V_IN_ACNTS_MIG(IDX).W_LAST_TRAN_DATE,
           NULL,
           V_IN_ACNTS_MIG(IDX).W_INT_CALC_UPTO,
           NULL,
           V_IN_ACNTS_MIG(IDX).W_INT_ACCR_UPTO,
           V_IN_ACNTS_MIG(IDX).W_INT_DBCR_UPTO,
           V_IN_ACNTS_MIG(IDX).W_TRF_TO_OVERDUE,
           V_IN_ACNTS_MIG(IDX).W_DB_FREEZED,
           V_IN_ACNTS_MIG(IDX).W_CR_FREEZED,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           W_ENTD_BY_GLOB,
           W_CURR_DATE,
           NULL,
           NULL,
           W_ENTD_BY_GLOB,
           W_CURR_DATE,
           NULL,
           V_IN_ACNTS_MIG(IDX).W_ABB_TRAN_ALLOWED,
           V_IN_ACNTS_MIG(IDX).W_ACNTS_DECEASED_APPL);
      
        W_ACNUM_WITHOUT_CHARS := ACNUM_WITHOUT_CHARS(V_IN_ACNTS_MIG(IDX)
                                                     .W_ACNUM);
        /* RAMESH M (69287) COMMENTED ON 02/NOV/2012
                UPDATE IACLINK
                   SET IACLINK_ACTUAL_ACNUM   = V_IN_ACNTS_MIG(IDX).W_ACNUM,
                       IACLINK_ACNT_IN_NUMBER = W_ACNUM_WITHOUT_CHARS,
                       IACLINK_PROD_CODE      = V_IN_ACNTS_MIG(IDX).W_PROD_CODE
                 WHERE IACLINK_INTERNAL_ACNUM = W_INT_AC_NUM;
        */
        UPDATE IACLINK -- Comments removed by Ramesh M on 31-Mar-13
           SET IACLINK_ACTUAL_ACNUM   = V_IN_ACNTS_MIG(IDX).W_ACNUM,
               IACLINK_ACNT_IN_NUMBER = W_ACNUM_WITHOUT_CHARS,
               IACLINK_PROD_CODE      = V_IN_ACNTS_MIG(IDX).W_PROD_CODE
         WHERE IACLINK_INTERNAL_ACNUM = W_INT_AC_NUM;
      EXCEPTION
        WHEN OTHERS THEN
          W_ER_CODE := 'AC7';
          W_ER_DESC := 'SP_ACNTS-INSERT_ACNTS' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || V_IN_ACNTS_MIG(IDX)
                      .W_CLIENT_NUM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END INSERT_ACNTS;
    
      <<INSERT_ACNTMAIL>>
      BEGIN
        INSERT INTO ACNTMAIL
          (ACNTMAIL_ENTITY_NUM,
           ACNTMAIL_INTERNAL_ACNUM,
           ACNTMAIL_ADDR_CHOICE,
           ACNTMAIL_THIRD_PARTY,
           ACNTMAIL_OTH_TITLE,
           ACNTMAIL_OTH_NAME,
           ACNTMAIL_OTH_ADDR1,
           ACNTMAIL_OTH_ADDR2,
           ACNTMAIL_OTH_ADDR3,
           ACNTMAIL_OTH_ADDR4,
           ACNTMAIL_OTH_ADDR5,
           ACNTMAIL_STMT_REQD,
           ACNTMAIL_STMT_FREQ,
           ACNTMAIL_STMT_PRINT_OPTION,
           ACNTMAIL_WEEKDAY_STMT,
           ACNTMAIL_ELEC_STMT_REQD,
           ACNTMAIL_ELEC_STMT_FREQ,
           ACNTMAIL_ELEC_WEEKDAY_STMT,
           ACNTMAIL_ELEC_STMT_MODE,
           ACNTMAIL_EMAIL_ADDR,
           ACNTMAIL_FAX_NUMBER)
        VALUES
          (W_ENTITY_NUMBER,
           W_INT_AC_NUM,
           V_IN_ACNTS_MIG (IDX).W_ADDR_CHOICE,
           V_IN_ACNTS_MIG (IDX).W_THIRD_PARTY,
           V_IN_ACNTS_MIG (IDX).W_OTH_TITLE,
           V_IN_ACNTS_MIG (IDX).W_OTH_NAME,
           V_IN_ACNTS_MIG (IDX).W_OTH_ADDR1,
           V_IN_ACNTS_MIG (IDX).W_OTH_ADDR2,
           V_IN_ACNTS_MIG (IDX).W_OTH_ADDR3,
           V_IN_ACNTS_MIG (IDX).W_OTH_ADDR4,
           V_IN_ACNTS_MIG (IDX).W_OTH_ADDR5,
           V_IN_ACNTS_MIG (IDX).W_STMT_REQD,
           V_IN_ACNTS_MIG (IDX).W_STMT_FREQ,
           V_IN_ACNTS_MIG (IDX).W_STMT_PRINT_OPTION,
           V_IN_ACNTS_MIG (IDX).W_WEEKDAY_STMT,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL);
      EXCEPTION
        WHEN OTHERS THEN
          W_ER_CODE := 'AC8';
          W_ER_DESC := 'SP_ACNTS-INSERT-ACNTMAIL' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || V_IN_ACNTS_MIG(IDX)
                      .W_CLIENT_NUM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
        
      END INSERT_ACNTMAIL;
    
      IF V_IN_ACNTS_MIG(IDX).W_FREEZED_ON IS NOT NULL THEN
      
        <<INSERT_ACNTFRZ>>
        BEGIN
          INSERT INTO ACNTFRZ
            (ACNTFRZ_ENTITY_NUM,
             ACNTFRZ_INTERNAL_ACNUM,
             ACNTFRZ_FREEZED_ON,
             ACNTFRZ_STOP_DB,
             ACNTFRZ_STOP_CR,
             ACNTFRZ_FREEZE_REQ_BY1,
             ACNTFRZ_FREEZE_REQ_BY2,
             ACNTFRZ_FREEZE_REQ_BY3,
             ACNTFRZ_FREEZE_REQ_BY4,
             ACNTFRZ_REASON1,
             ACNTFRZ_REASON2,
             ACNTFRZ_REASON3,
             ACNTFRZ_REASON4,
             ACNTFRZ_ENTD_BY,
             ACNTFRZ_ENTD_ON,
             ACNTFRZ_LAST_MOD_BY,
             ACNTFRZ_LAST_MOD_ON,
             ACNTFRZ_AUTH_BY,
             ACNTFRZ_AUTH_ON,
             TBA_MAIN_KEY)
          VALUES
            (W_ENTITY_NUMBER,
             W_INT_AC_NUM,
             V_IN_ACNTS_MIG (IDX).W_FREEZED_ON,
             1,
             1,
             V_IN_ACNTS_MIG (IDX).W_FREEZE_REQ_BY1,
             V_IN_ACNTS_MIG (IDX).W_FREEZE_REQ_BY2,
             V_IN_ACNTS_MIG (IDX).W_FREEZE_REQ_BY3,
             V_IN_ACNTS_MIG (IDX).W_FREEZE_REQ_BY4,
             V_IN_ACNTS_MIG (IDX).W_REASON1,
             V_IN_ACNTS_MIG (IDX).W_REASON2,
             V_IN_ACNTS_MIG (IDX).W_REASON3,
             'MIGRATION',
             W_ENTD_BY_GLOB,
             W_CURR_DATE,
             NULL,
             NULL,
             W_ENTD_BY_GLOB,
             W_CURR_DATE,
             NULL);
        EXCEPTION
          WHEN OTHERS THEN
            W_ER_CODE := 'AC9';
            W_ER_DESC := 'SP_ACNTS-INSERT-ACNTFRZ' || SQLERRM;
            W_SRC_KEY := P_BRANCH_CODE || '-' || V_IN_ACNTS_MIG(IDX)
                        .W_CLIENT_NUM;
            POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
          
        END INSERT_ACNTFRZ;
      END IF;
    
      IF (V_IN_ACNTS_MIG(IDX)
         .W_INOP_ACNT = 1 OR V_IN_ACNTS_MIG(IDX).W_DORMANT_ACNT = 1) THEN
      
        IF V_IN_ACNTS_MIG(IDX).W_LAST_TRAN_DATE IS NULL THEN
        
          V_IN_ACNTS_MIG(IDX).W_LAST_TRAN_DATE := W_CURR_DATE;
          W_ER_CODE := 'AC10';
          W_ER_DESC := 'SP_ACNTS-INSERT-ACNTSTATUS-LAST_TRAN_DATE IS NULL,moved mig date ';
          W_SRC_KEY := P_BRANCH_CODE || '-' || V_IN_ACNTS_MIG(IDX)
                      .W_PROD_CODE || '-' || W_INT_AC_NUM;
          --POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
        END IF;
      
        IF V_IN_ACNTS_MIG(IDX).W_INOP_ACNT = 1 THEN
          W_INOP_DORM := 'I';
        END IF;
        IF (V_IN_ACNTS_MIG(IDX)
           .W_INOP_ACNT = 0 AND V_IN_ACNTS_MIG(IDX).W_DORMANT_ACNT = 1) THEN
          W_INOP_DORM := 'D';
        END IF;
      
        INSERT INTO ACNTSTATUS
          (ACNTSTATUS_ENTITY_NUM,
           ACNTSTATUS_INTERNAL_ACNUM,
           ACNTSTATUS_EFF_DATE,
           ACNTSTATUS_FLG,
           ACNTSTATUS_REMARKS1,
           ACNTSTATUS_REMARKS2,
           ACNTSTATUS_REMARKS3,
           ACNTSTATUS_ENTD_BY,
           ACNTSTATUS_ENTD_ON,
           ACNTSTATUS_LAST_MOD_BY,
           ACNTSTATUS_LAST_MOD_ON)
        VALUES
          (W_ENTITY_NUMBER,
           W_INT_AC_NUM,
           V_IN_ACNTS_MIG(IDX).W_LAST_TRAN_DATE,
           W_INOP_DORM, --1,--W_CLIENT_TYPE,
           NULL,
           NULL,
           'MIGRATION',
           W_ENTD_BY_GLOB,
           W_CURR_DATE,
           NULL,
           NULL);
      
      END IF;
    
      <<INSERT_ACNTBAL>>
      BEGIN
        INSERT INTO ACNTBAL
          (ACNTBAL_ENTITY_NUM,
           ACNTBAL_INTERNAL_ACNUM,
           ACNTBAL_CURR_CODE,
           ACNTBAL_AC_CUR_DB_SUM,
           ACNTBAL_AC_CUR_CR_SUM,
           ACNTBAL_BC_CUR_DB_SUM,
           ACNTBAL_BC_CUR_CR_SUM,
           ACNTBAL_AC_BAL,
           ACNTBAL_BC_BAL,
           ACNTBAL_AC_UNAUTH_CR_SUM,
           ACNTBAL_AC_UNAUTH_DB_SUM,
           ACNTBAL_BC_UNAUTH_CR_SUM,
           ACNTBAL_BC_UNAUTH_DB_SUM,
           ACNTBAL_AC_FWDVAL_CR_SUM,
           ACNTBAL_AC_FWDVAL_DB_SUM,
           ACNTBAL_BC_FWDVAL_CR_SUM,
           ACNTBAL_BC_FWDVAL_DB_SUM,
           ACNTBAL_AC_LIEN_AMT,
           ACNTBAL_BC_LIEN_AMT,
           ACNTBAL_AC_AMT_ON_HOLD,
           ACNTBAL_AC_DB_QUEUE_AMT,
           ACNTBAL_BC_DB_QUEUE_AMT,
           ACNTBAL_MIN_BAL_AMT,
           ACNTBAL_AC_CLG_CR_SUM,
           ACNTBAL_AC_CLG_DB_SUM,
           ACNTBAL_BC_CLG_CR_SUM,
           ACNTBAL_BC_CLG_DB_SUM,
           ACNTBAL_EARLY_REALSN_AMT,
           ACNTBAL_POSTPONED_DBS)
        VALUES
        
          (W_ENTITY_NUMBER,
           W_INT_AC_NUM,
           V_IN_ACNTS_MIG(IDX).W_CURR_CODE,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0);
      EXCEPTION
        WHEN OTHERS THEN
          W_ER_CODE := 'AC12';
          W_ER_DESC := 'SP_ACNTS-ACNTSTATUS-LAST_TRAN_DATE IS NULL' ||
                       SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || V_IN_ACNTS_MIG(IDX)
                      .W_PROD_CODE || '-' || W_INT_AC_NUM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END INSERT_ACNTBAL;
    
    END LOOP;
  END IF;

  SELECT INVNUM_LAST_NUM_USED
    INTO W_CONNP_NUM
    FROM INVNUM
   WHERE INVNUM_SOURCE_TYPE = 'C';

  FOR IDX IN (SELECT ACNTLIEN_ACNUM,
                     ROW_NUMBER() OVER(PARTITION BY ACNTLIEN_ACNUM ORDER BY ACNTLIEN_ACNUM) ACNTLIEN_LIEN_SL,
                     ACNTLIEN_LIEN_DATE,
                     ACNTLIEN_LIEN_AMOUNT,
                     ACNTLIEN_LIEN_TO_BRN,
                     ACNTLIEN_LIEN_TO_ACNUM,
                     ACNTLIEN_REASON1,
                     ACNTLIEN_REVOKED_ON,
                     ACNTLIEN_ENTD_BY,
                     ACNTLIEN_ENTD_ON
                FROM MIG_ACNTLIEN
               WHERE ACNTLIEN_ACNUM IS NOT NULL) LOOP
  
    FETCH_ACNUM(IDX.ACNTLIEN_ACNUM, W_INTERN_ACCNUM);
  
    FETCH_ACNUM(IDX.ACNTLIEN_LIEN_TO_ACNUM, W_LIEN_INTERN_ACC);
  
    <<IN_ACNTLIEN>>
    BEGIN
      INSERT INTO ACNTLIEN
        (ACNTLIEN_ENTITY_NUM,
         ACNTLIEN_INTERNAL_ACNUM,
         ACNTLIEN_LIEN_SL,
         ACNTLIEN_LIEN_DATE,
         ACNTLIEN_LIEN_AMOUNT,
         ACNTLIEN_LIEN_TO_BRN,
         ACNTLIEN_LIEN_TO_ACNUM,
         ACNTLIEN_LIEN_CONT_NUM,
         ACNTLIEN_LIEN_AUTH1,
         ACNTLIEN_LIEN_AUTH2,
         ACNTLIEN_LIEN_AUTH3,
         ACNTLIEN_LIEN_AUTH4,
         ACNTLIEN_REASON1,
         ACNTLIEN_REASON2,
         ACNTLIEN_REASON3,
         ACNTLIEN_REASON4,
         ACNTLIEN_REVOKED_ON,
         ACNTLIEN_ENTD_BY,
         ACNTLIEN_ENTD_ON,
         ACNTLIEN_LAST_MOD_BY,
         ACNTLIEN_LAST_MOD_ON,
         ACNTLIEN_AUTH_BY,
         ACNTLIEN_AUTH_ON,
         TBA_MAIN_KEY)
      VALUES
        (W_ENTITY_NUMBER,
         W_INTERN_ACCNUM,
         IDX.ACNTLIEN_LIEN_SL,
         IDX.ACNTLIEN_LIEN_DATE,
         IDX.ACNTLIEN_LIEN_AMOUNT,
         IDX.ACNTLIEN_LIEN_TO_BRN,
         W_LIEN_INTERN_ACC,
         0,
         NULL,
         NULL,
         NULL,
         NULL,
         IDX.ACNTLIEN_REASON1,
         NULL,
         NULL,
         NULL,
         IDX.ACNTLIEN_REVOKED_ON,
         W_ENTD_BY_GLOB,
         W_CURR_DATE,
         NULL,
         NULL,
         W_ENTD_BY_GLOB,
         W_CURR_DATE,
         NULL);
    
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'ACCP1';
        W_ER_DESC := 'INSERT-ACNTLIEN ' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || W_CLIENT_CODE;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_ACNTLIEN;
  
  END LOOP;

  W_FIRST     := TRUE;
  W_CONNP_NUM := W_CONNP_NUM + 1;
  FOR IDX IN (SELECT CONNP_AC_CLIENT_FLAG,
                     CONNP_CLIENT_CODE,
                     CONNP_ACCOUNT_NUMBER,
                     CONNP_SERIAL,
                     CONNP_CONN_ROLE,
                     CONNP_CONN_ACNUM,
                     CONNP_CONN_CLIENT_NUM,
                     CONNP_CLIENT_NAME,
                     CONNP_DATE_OF_BIRTH,
                     CONNP_CLIENT_DEPT,
                     CONNP_DESIG_CODE,
                     CONNP_CLIENT_ADDR1,
                     CONNP_CLIENT_ADDR2,
                     CONNP_CLIENT_ADDR3,
                     CONNP_CLIENT_ADDR4,
                     CONNP_CLIENT_ADDR5,
                     CONNP_CLIENT_CNTRY,
                     CONNP_NATURE_OF_GUARDIAN,
                     CONNP_GUARDIAN_FOR,
                     CONNP_GUARDIAN_FOR_CLIENT,
                     CONNP_RELATIONSHIP_INFO,
                     CONNP_RES_TEL,
                     CONNP_OFF_TEL,
                     CONNP_GSM_NUM,
                     CONNP_EMAIL_ADDR,
                     CONNP_REM1,
                     CONNP_REM2,
                     CONNP_REM3,
                     CONNP_SHARE_HOLD_PER
                FROM MIG_CONNPINFO
              --where CONNP_ACCOUNT_NUMBER='0620103390'
               ORDER BY CONNP_CLIENT_CODE,
                        CONNP_ACCOUNT_NUMBER,
                        CONNP_CONN_ROLE) LOOP
  
    IF IDX.CONNP_AC_CLIENT_FLAG = 'C' THEN
      W_CLIENT_CODE   := GET_CL_AC(IDX.CONNP_CLIENT_CODE, 'C');
      W_INTERN_ACCNUM := NULL;
    END IF;
  
    IF IDX.CONNP_AC_CLIENT_FLAG = 'A' THEN
      W_INTERN_ACCNUM := GET_CL_AC(IDX.CONNP_ACCOUNT_NUMBER, 'A');
      W_CLIENT_CODE   := GET_CL_AC(W_INTERN_ACCNUM, 'NA');
    END IF;
  
    IF W_FIRST = TRUE AND IDX.CONNP_AC_CLIENT_FLAG = 'C' THEN
      W_TMP_CLIENTCODE := W_CLIENT_CODE;
      W_FIRST          := FALSE;
      W_DAYSL          := 1;
      W_AC             := 'C';
    END IF;
  
    IF W_AC = 'C' AND IDX.CONNP_AC_CLIENT_FLAG = 'A' THEN
      W_AC    := 'A';
      W_FIRST := TRUE;
    END IF;
  
    IF W_FIRST = TRUE AND IDX.CONNP_AC_CLIENT_FLAG = 'A' THEN
      W_TMP_ACNUM := W_INTERN_ACCNUM;
      W_FIRST     := FALSE;
      W_DAYSL     := 1;
    END IF;
  
    IF IDX.CONNP_AC_CLIENT_FLAG = 'C' AND W_FIRST = FALSE AND
       W_CLIENT_CODE <> W_TMP_CLIENTCODE THEN
      W_TMP_CLIENTCODE := W_CLIENT_CODE;
      W_CONNP_NUM      := W_CONNP_NUM + 1;
      W_DAYSL          := 1;
    END IF;
  
    IF IDX.CONNP_AC_CLIENT_FLAG = 'A' AND W_FIRST = FALSE AND
       W_TMP_ACNUM <> W_INTERN_ACCNUM THEN
      W_TMP_ACNUM := W_INTERN_ACCNUM;
      W_CONNP_NUM := W_CONNP_NUM + 1;
      W_DAYSL     := 1;
    END IF;
  
    INSERT_CONNPINFO(W_CONNP_NUM,
                     IDX.CONNP_CONN_ROLE,
                     W_DAYSL, --IDX.CONNP_SERIAL,
                     GET_CL_AC(IDX.CONNP_CONN_ACNUM, 'A'),
                     GET_CL_AC(IDX.CONNP_CONN_CLIENT_NUM, 'C'),
                     IDX.CONNP_CLIENT_NAME,
                     IDX.CONNP_DATE_OF_BIRTH,
                     IDX.CONNP_CLIENT_DEPT,
                     IDX.CONNP_DESIG_CODE,
                     IDX.CONNP_CLIENT_ADDR1,
                     IDX.CONNP_CLIENT_ADDR2,
                     IDX.CONNP_CLIENT_ADDR3,
                     IDX.CONNP_CLIENT_ADDR4,
                     IDX.CONNP_CLIENT_ADDR5,
                     IDX.CONNP_CLIENT_CNTRY,
                     IDX.CONNP_NATURE_OF_GUARDIAN,
                     IDX.CONNP_GUARDIAN_FOR,
                     IDX.CONNP_GUARDIAN_FOR_CLIENT,
                     IDX.CONNP_RELATIONSHIP_INFO,
                     IDX.CONNP_RES_TEL,
                     IDX.CONNP_OFF_TEL,
                     IDX.CONNP_GSM_NUM,
                     IDX.CONNP_EMAIL_ADDR,
                     IDX.CONNP_REM1,
                     IDX.CONNP_REM2,
                     IDX.CONNP_REM3,
                     IDX.CONNP_SHARE_HOLD_PER,
                     NULL,
                     'ACNTS', --null,
                     W_INTERN_ACCNUM --null
                     );
    W_DAYSL := W_DAYSL + 1;
  
    IF W_DAYSL > 5 THEN
      NULL;
    END IF;
  
    IF IDX.CONNP_AC_CLIENT_FLAG = 'C' THEN
      UPDATE CORPCLIENTS
         SET CORPCLIENTS.CORPCL_CONNP_INV_NUM = W_CONNP_NUM
       WHERE CORPCL_CLIENT_CODE = W_CLIENT_CODE;
    ELSE
      UPDATE ACNTS
         SET ACNTS.ACNTS_CONNP_INV_NUM = W_CONNP_NUM
       WHERE ACNTS.ACNTS_INTERNAL_ACNUM = W_INTERN_ACCNUM;
    END IF;
  
  END LOOP;

  UPDATE INVNUM
     SET INVNUM_LAST_NUM_USED = W_CONNP_NUM
   WHERE INVNUM_SOURCE_TYPE = 'C';

  UPDATE ACNTS
     SET ACNTS_CONTRACT_BASED_FLG = '1'
   WHERE ACNTS_ENTITY_NUM = W_ENTITY_NUMBER
     AND ACNTS.ACNTS_PROD_CODE IN
         (SELECT PRODUCT_CODE
            FROM PRODUCTS
           WHERE PRODUCT_CONTRACT_ALLOWED = '1');

  UPDATE ACNTS
     SET ACNTS_CONTRACT_BASED_FLG = '0'
   WHERE ACNTS_ENTITY_NUM = W_ENTITY_NUMBER
     AND ACNTS.ACNTS_PROD_CODE IN
         (SELECT PRODUCT_CODE
            FROM PRODUCTS
           WHERE PRODUCT_CONTRACT_ALLOWED = '0');

  UPDATE ACNTS
     SET ACNTS_CR_FREEZED = 0
   WHERE ACNTS_ENTITY_NUM = W_ENTITY_NUMBER
     AND ACNTS_CR_FREEZED IS NULL;
  UPDATE ACNTS
     SET ACNTS_DB_FREEZED = 0
   WHERE ACNTS_ENTITY_NUM = W_ENTITY_NUMBER
     AND ACNTS_DB_FREEZED IS NULL;
  UPDATE ACNTS SET ACNTS_NONSYS_LAST_DATE = ACNTS_LAST_TRAN_DATE;
  UPDATE ACNTS SET ACNTS_MKT_CHANNEL_CODE = 01;
  UPDATE ACNTS
     SET ACNTS.ACNTS_DB_FREEZED = 1, ACNTS_CR_FREEZED = 1
   WHERE ACNTS_ENTITY_NUM = W_ENTITY_NUMBER
     AND ACNTS.ACNTS_INTERNAL_ACNUM IN
         (SELECT ACNTFRZ.ACNTFRZ_INTERNAL_ACNUM FROM ACNTFRZ);

  UPDATE CONNPINFO
     SET CONNP_SOURCE_TABLE = 'ACNTS',
         CONNP_SOURCE_KEY  =
         (SELECT ACNTS_INTERNAL_ACNUM
            FROM ACNTS
           WHERE ACNTS_CONNP_INV_NUM = CONNP_INV_NUM);

  UPDATE CONNPINFO
     SET CONNP_CLIENT_NAME = 'INTRO BY BANK'
   WHERE TRIM(CONNP_CLIENT_NAME) IS NULL
     AND CONNP_CONN_ROLE = '01';

  UPDATE ACNTS
     SET ACNTS_AC_SUB_TYPE = 0
   WHERE ACNTS_ENTITY_NUM = W_ENTITY_NUMBER
     AND ACNTS_AC_SUB_TYPE IS NULL;

  INSERT INTO ECSACMAP
    SELECT W_ENTITY_NUMBER,
           P_BRANCH_CODE,
           ACNTOTN_OLD_ACNT_NUM,
           ACNTOTN_INTERNAL_ACNUM,
           W_ENTD_BY_GLOB,
           W_CURR_DATE,
           NULL,
           NULL,
           W_ENTD_BY_GLOB,
           W_CURR_DATE,
           NULL,
           NULL
      FROM ACNTOTN
     WHERE ACNTOTN.ACNTOTN_INTERNAL_ACNUM IN
           (SELECT ACNTS_INTERNAL_ACNUM
              FROM ACNTS
             WHERE ACNTS.ACNTS_PROD_CODE IN
                   (SELECT PRODUCT_CODE
                      FROM PRODUCTS
                     WHERE PRODUCT_FOR_RUN_ACS = 1));

  /* Ramesh M on 15/11/2012
  
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ACSEQGEN';
  
  INSERT INTO ACSEQGEN
    (ACSEQGEN_ENTITY_NUM,
     ACSEQGEN_BRN_CODE,
     ACSEQGEN_CIF_NUMBER,
     ACSEQGEN_PROD_CODE,
     ACSEQGEN_SEQ_NUMBER,
     ACSEQGEN_LAST_NUM_USED)
    SELECT W_ENTITY_NUMBER,
           ACNO_BRANCH_CODE,
           0,
           ACNO_PRODUCT_CODE,
           0,
           NVL(ACNO_LAST_NUMBER, 0)
      FROM MIG_ACSEQGEN;
   */ -- Ramesh M on 15/11/2012.

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    P_ERR_MSG := 'Main Acnts ' || SQLERRM;
    ROLLBACK;
  
  /*
  truncate table
  ;
  truncate table acntlink;
  truncate table ACNTOTN;
  truncate table ACNTS;
  truncate table ACNTMAIL;
  truncate table ACNTFRZ;
  truncate table ACNTSTATUS;
  truncate table ACNTLIEN;
  truncate table ACNTBAL;
  truncate table CONNPINFO;
  truncate table acntotnnew;
  truncate table mig_errorlog;
  TRUNCATE TABLE ECSACMAP;
  */
END SP_MIG_ACNTS;

/
