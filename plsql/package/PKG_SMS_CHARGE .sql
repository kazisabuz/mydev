DROP PACKAGE SBLPROD.PKG_SMS_CHARGE;

CREATE OR REPLACE PACKAGE SBLPROD.PKG_SMS_CHARGE IS

  -- AUTHOR  : RAJIB.PRADHAN
  -- CREATED : 15-DEC-2015
  -- PURPOSE : SMS Charge Deduct from accounts.
  
 --Edited By: Mahamud
 --Modified: 14-DEC-2017
 
 --Edited By: Ibrahim
 --Date:11-JUN-2018
 
 --Edited By: sabuj 
 --Date: 20-JUN-2018

  PROCEDURE SP_START_BRNWISE(V_ENTITY_NUM IN NUMBER,
                          P_BRN_CODE IN NUMBER DEFAULT 0);

END PKG_SMS_CHARGE;
/
DROP PACKAGE BODY SBLPROD.PKG_SMS_CHARGE;

CREATE OR REPLACE PACKAGE BODY SBLPROD.PKG_SMS_CHARGE IS

  E_MY_EXCEPTION EXCEPTION;
  W_ERROR_MSG         VARCHAR2(1000);
  W_ENTITY_CODE       NUMBER;
  W_ASON_DATE         DATE;
  W_USER_BRANCH       USERS.USER_BRANCH_CODE%TYPE;
  W_USER_ID           USERS.USER_ID%TYPE;
  W_FROM_DATE         DATE;
  W_UPTO_DATE         DATE;
  W_TOTAL_CHARGE_AMT  NUMBER := 0;
  W_TOTAL_VAT_AMT     NUMBER := 0;
  W_AC_CHARGE_AMT     NUMBER := 0;
  W_AC_VAT_AMT        NUMBER := 0;
  W_BRN_CODE          NUMBER;
  W_BATCH_NUM         NUMBER;
  W_POST_ARRAY_INDEX  NUMBER := 0;
  W_LOAN_IDX          NUMBER := 0;
  W_SQL_DATA          CLOB;
  W_QUERY_PART1       VARCHAR2(1000);
  W_QUERY_PART2       VARCHAR2(1000);
  W_CHARGE_INDEX      NUMBER := 0;
  W_AC_BALANCE        NUMBER(18, 3);
  W_INTERNAL_ACNUM    ACNTS.ACNTS_INTERNAL_ACNUM%TYPE;
  W_AC_TRAN_NARATION  VARCHAR2(100);
  W_INS_OUR_BANK_CODE INSTALL.INS_OUR_BANK_CODE%TYPE;
  W_AC_BRN_CHARGE_GL  EXTGL.EXTGL_ACCESS_CODE%TYPE;
  W_AC_BRN_VAT_GL     EXTGL.EXTGL_ACCESS_CODE%TYPE;
  W_IBR_CHARGE_GL     EXTGL.EXTGL_ACCESS_CODE%TYPE;
  W_IBR_VAT_GL        EXTGL.EXTGL_ACCESS_CODE%TYPE;
  W_IBR_GL_CODE       EXTGL.EXTGL_ACCESS_CODE%TYPE;
  W_IBR_CHARGE_AC     NUMBER(14);

  W_SETTLE_BRANCH     NUMBER;
  W_SETTLE_BRANCH_RAT NUMBER;

  W_SETTLE_BRN_CHARGE_AMT NUMBER := 0;
  W_SETTLE_BRN_VAT_AMT    NUMBER := 0;

  W_BRN_CHARGE_AMT NUMBER := 0;
  W_BRN_VAT_AMT    NUMBER := 0;
  
  V_DUMMY_N          NUMBER(18, 3);
  V_DUMMY_C          CHAR(1);
  V_DUMMY_C2         CHAR(3);
  V_DUMMY_D          DATE;
  V_ERR_MSG          VARCHAR2(100);

  TYPE TT_SMSCHARGE_ENTITY_NUM IS TABLE OF NUMBER(4) INDEX BY PLS_INTEGER;
  TYPE TT_SMSCHARGE_BRN_CODE IS TABLE OF NUMBER(6) INDEX BY PLS_INTEGER;
  TYPE TT_SMSCHARGE_INTERNAL_ACNUM IS TABLE OF NUMBER(14) INDEX BY PLS_INTEGER;
  TYPE TT_SMSCHARGE_PROCESS_DATE IS TABLE OF DATE INDEX BY PLS_INTEGER;
  TYPE TT_SMSCHARGE_FIN_YEAR IS TABLE OF NUMBER(4) INDEX BY PLS_INTEGER;
  TYPE TT_SMSCHARGE_CHARGE_AMT IS TABLE OF NUMBER(18, 3) INDEX BY PLS_INTEGER;
  TYPE TT_SMSCHARGE_VAT_AMT IS TABLE OF NUMBER(18, 3) INDEX BY PLS_INTEGER;
  TYPE TT_SMSCHARGE_ENTD_BY IS TABLE OF VARCHAR2(8) INDEX BY PLS_INTEGER;
  TYPE TT_SMSCHARGE_ENTD_ON IS TABLE OF DATE INDEX BY PLS_INTEGER;
  TYPE TT_SMSCHARGE_AUTH_BY IS TABLE OF VARCHAR2(8) INDEX BY PLS_INTEGER;
  TYPE TT_SMSCHARGE_AUTH_ON IS TABLE OF DATE INDEX BY PLS_INTEGER;
  TYPE TT_SMSCHARGE_SERVICE_TYPE IS TABLE OF VARCHAR2(21) INDEX BY PLS_INTEGER;

  T_SMSCHARGE_ENTITY_NUM     TT_SMSCHARGE_ENTITY_NUM;
  T_SMSCHARGE_BRN_CODE       TT_SMSCHARGE_BRN_CODE;
  T_SMSCHARGE_INTERNAL_ACNUM TT_SMSCHARGE_INTERNAL_ACNUM;
  T_SMSCHARGE_PROCESS_DATE   TT_SMSCHARGE_PROCESS_DATE;
  T_SMSCHARGE_FIN_YEAR       TT_SMSCHARGE_FIN_YEAR;
  T_SMSCHARGE_CHARGE_AMT     TT_SMSCHARGE_CHARGE_AMT;
  T_SMSCHARGE_VAT_AMT        TT_SMSCHARGE_VAT_AMT;
  T_SMSCHARGE_ENTD_BY        TT_SMSCHARGE_ENTD_BY;
  T_SMSCHARGE_ENTD_ON        TT_SMSCHARGE_ENTD_ON;
  T_SMSCHARGE_AUTH_BY        TT_SMSCHARGE_AUTH_BY;
  T_SMSCHARGE_AUTH_ON        TT_SMSCHARGE_AUTH_ON;
  T_SMSCHARGE_SERVICE_TYPE   TT_SMSCHARGE_SERVICE_TYPE;

  TYPE REC_ACNTS IS RECORD(
    ACNTS_INTERNAL_ACNUM     ACNTS.ACNTS_INTERNAL_ACNUM%TYPE,
    ACNTS_ENTITY_NUM         ACNTS.ACNTS_ENTITY_NUM%TYPE,
    ACNTS_BRN_CODE           ACNTS.ACNTS_BRN_CODE%TYPE,
    ACNTS_CURR_CODE          ACNTS.ACNTS_CURR_CODE%TYPE,
    ACNTBAL_AC_BAL           ACNTBAL.ACNTBAL_AC_BAL%TYPE,
    ACNTBAL_BC_BAL           ACNTBAL.ACNTBAL_BC_BAL%TYPE,
    PRODUCT_FOR_DEPOSITS     PRODUCTS.PRODUCT_FOR_DEPOSITS%TYPE,
    PRODUCT_FOR_LOANS        PRODUCTS.PRODUCT_FOR_LOANS%TYPE,
    PRODUCT_CONTRACT_ALLOWED PRODUCTS.PRODUCT_CONTRACT_ALLOWED%TYPE,
    PRODUCT_FOR_RUN_ACS      PRODUCTS.PRODUCT_FOR_RUN_ACS%TYPE);

  TYPE TT_ACNTS IS TABLE OF REC_ACNTS INDEX BY PLS_INTEGER;

  T_ACNTS TT_ACNTS;
  --new type
  TYPE REC_SMS IS RECORD(
    SMSCHRG_ENTITY_NUM      SMSCHRGPM.SMSCHRG_ENTITY_NUM%TYPE,
    SMSCHRG_CODE            SMSCHRGPM.SMSCHRG_CODE%TYPE,
    SMSCHRG_BRN_CODE        SMSCHRGPM.SMSCHRG_BRN_CODE%TYPE,
    SMSCHRG_ACNUM           SMSCHRGPM.SMSCHRG_ACNUM%TYPE,
    SMSCHARGE_SPLIT_RATE    SMSCHRGPM.SMSCHARGE_SPLIT_RATE%TYPE,
    SERVICE_TYPE            SMSCHRGPM.SERVICE_TYPE%TYPE,
    CHGCD_CHG_TYPE          CHGCD.CHGCD_CHG_TYPE%TYPE,
    CHGCD_GLACCESS_CD       CHGCD.CHGCD_STAT_TYPE%TYPE,
    STAXACPM_STAX_RCVD_HEAD STAXACPM.STAXACPM_STAX_RCVD_HEAD%TYPE,
    CHGCD_CHG_CURR_CODE     CHGCD.CHGCD_CHG_CURR_CODE%TYPE);

  TYPE TT_SMS IS TABLE OF REC_SMS INDEX BY VARCHAR2(2);

  T_SMS TT_SMS;

  ---new type end
  V_SMSCHRG_ENTITY_NUM   SMSCHRGPM.SMSCHRG_ENTITY_NUM%TYPE;
  V_SMSCHRG_CODE         SMSCHRGPM.SMSCHRG_CODE%TYPE;
  V_SMSCHRG_BRN_CODE     SMSCHRGPM.SMSCHRG_BRN_CODE%TYPE;
  V_SMSCHRG_ACNUM        SMSCHRGPM.SMSCHRG_ACNUM%TYPE;
  V_SMSCHARGE_SPLIT_RATE SMSCHRGPM.SMSCHARGE_SPLIT_RATE%TYPE;
  V_CHGCD_CHG_TYPE       CHGCD.CHGCD_CHG_TYPE%TYPE;
  V_CHGCD_GLACCESS_CD    CHGCD.CHGCD_STAT_TYPE%TYPE;
  V_STAX_RCVD_HEAD       STAXACPM.STAXACPM_STAX_RCVD_HEAD%TYPE;
  V_CHGCD_CHG_CURR_CODE  CHGCD.CHGCD_CHG_CURR_CODE%TYPE;
  V_SERVICE_TYPE         SMSCHRGPM.SERVICE_TYPE%TYPE;

  TEMP_SERVICE_TYPE     SMSCHRGPM.SERVICE_TYPE%TYPE;
  TEMP_SERVICE_TYPE1    SMSCHRGPM.SERVICE_TYPE%TYPE;
  W_SERVICE_AMOUNT      NUMBER(18, 3);
  W_SERVICE_ADDN_AMOUNT NUMBER(18, 3);
  W_SERVICE_CESS_AMOUNT NUMBER(18, 3);
  W_ERROR               VARCHAR2(1000);
  W_ACNTS_CURR_CODE     ACNTS.ACNTS_CURR_CODE%TYPE;

  W_IBACPM_IBR_HEAD_DB IBACPM.IBACPM_IBR_HEAD_DB%TYPE;
  W_IBACPM_IBR_HEAD_CR IBACPM.IBACPM_IBR_HEAD_DB%TYPE;
  W_LOAN_ACNTS         NUMBER := 0;
  ------Taken from iftekhar vai update
  CURSOR CURSORLP is(
    SELECT S.SMSCHRG_ENTITY_NUM,
           S.SMSCHRG_CODE,
           S.SMSCHRG_BRN_CODE,
           S.SMSCHRG_ACNUM,
           S.SMSCHARGE_SPLIT_RATE,
           S.SERVICE_TYPE,
           CHGCD_CHG_TYPE,
           DECODE(CHGCD_STAT_ALLOWED_FLG,
                  1,
                  CHGCD_STAT_TYPE,
                  0,
                  CHGCD_DB_REFUND_HEAD) CHGCD_GLACCESS_CD,
           STAXACPM_STAX_RCVD_HEAD,
           CHGCD_CHG_CURR_CODE
      FROM SMSCHRGPM S, CHGCD C, STAXACPM V
     WHERE C.CHGCD_CHARGE_CODE = S.SMSCHRG_CODE
       AND SMSCHARGE_ENABLE_STATUS = '1'
       AND C.CHGCD_SERVICE_TAX_CODE = V.STAXACPM_TAX_CODE) ORDER BY S.SERVICE_TYPE ASC;
  PROCEDURE INIT_BANK_CODE IS
  BEGIN
    SELECT INS_OUR_BANK_CODE
      INTO W_INS_OUR_BANK_CODE
      from INSTALL
     WHERE ROWNUM = 1;
  END INIT_BANK_CODE;
  PROCEDURE SP_GET_CHARGE_VALUE IS
  BEGIN
    FOR INX IN CURSORLP LOOP
      T_SMS(INX.SERVICE_TYPE).SMSCHRG_ENTITY_NUM := INX.SMSCHRG_ENTITY_NUM;
      T_SMS(INX.SERVICE_TYPE).SMSCHRG_CODE := INX.SMSCHRG_CODE;
      T_SMS(INX.SERVICE_TYPE).SMSCHRG_BRN_CODE := INX.SMSCHRG_BRN_CODE;
      T_SMS(INX.SERVICE_TYPE).SMSCHRG_ACNUM := INX.SMSCHRG_ACNUM;
      T_SMS(INX.SERVICE_TYPE).SMSCHARGE_SPLIT_RATE := INX.SMSCHARGE_SPLIT_RATE;
      T_SMS(INX.SERVICE_TYPE).SERVICE_TYPE := INX.SERVICE_TYPE;
      T_SMS(INX.SERVICE_TYPE).CHGCD_CHG_TYPE := INX.CHGCD_CHG_TYPE;
      T_SMS(INX.SERVICE_TYPE).CHGCD_GLACCESS_CD := INX.CHGCD_GLACCESS_CD;
      T_SMS(INX.SERVICE_TYPE).STAXACPM_STAX_RCVD_HEAD := INX.STAXACPM_STAX_RCVD_HEAD;
      T_SMS(INX.SERVICE_TYPE).CHGCD_CHG_CURR_CODE := INX.CHGCD_CHG_CURR_CODE;

    END LOOP;
  EXCEPTION
    WHEN E_MY_EXCEPTION THEN
      DBMS_OUTPUT.put_line('EXCEPTION IS CALLING');
  END SP_GET_CHARGE_VALUE;

  -----------------------------------------------

  PROCEDURE SP_MOVE_CHARGE_TABLE(P_ENTITY_NUM     NUMBER,
                                 P_BRN_CODE       NUMBER,
                                 P_INTERNAL_ACNUM NUMBER,
                                 P_PROCESS_DATE   DATE,
                                 P_CHARGE_AMT     NUMBER,
                                 P_VAT_AMT        NUMBER,
                                 P_USER_ID        VARCHAR2,
                                 P_SERVICE_TYPE   VARCHAR2) IS
  BEGIN
    W_CHARGE_INDEX := W_CHARGE_INDEX + 1;

    T_SMSCHARGE_ENTITY_NUM(W_CHARGE_INDEX) := P_ENTITY_NUM;
    T_SMSCHARGE_BRN_CODE(W_CHARGE_INDEX) := P_BRN_CODE;
    T_SMSCHARGE_INTERNAL_ACNUM(W_CHARGE_INDEX) := P_INTERNAL_ACNUM;
    T_SMSCHARGE_PROCESS_DATE(W_CHARGE_INDEX) := P_PROCESS_DATE;
    T_SMSCHARGE_FIN_YEAR(W_CHARGE_INDEX) := TO_NUMBER(TO_CHAR(P_PROCESS_DATE,
                                                              'YYYY'));
    T_SMSCHARGE_CHARGE_AMT(W_CHARGE_INDEX) := P_CHARGE_AMT;
    T_SMSCHARGE_VAT_AMT(W_CHARGE_INDEX) := P_VAT_AMT;
    T_SMSCHARGE_ENTD_BY(W_CHARGE_INDEX) := P_USER_ID;
    T_SMSCHARGE_ENTD_ON(W_CHARGE_INDEX) := SYSDATE;
    T_SMSCHARGE_AUTH_BY(W_CHARGE_INDEX) := P_USER_ID;
    T_SMSCHARGE_AUTH_ON(W_CHARGE_INDEX) := SYSDATE;
    T_SMSCHARGE_SERVICE_TYPE(W_CHARGE_INDEX) := P_SERVICE_TYPE;
  END;

  PROCEDURE SP_CHARGE_DATA_INSERT IS
  BEGIN
    FORALL IND IN T_SMSCHARGE_ENTITY_NUM.FIRST .. T_SMSCHARGE_ENTITY_NUM.LAST
      INSERT INTO SMSCHARGE
        (SMSCHARGE_ENTITY_NUM,
         SMSCHARGE_BRN_CODE,
         SMSCHARGE_INTERNAL_ACNUM,
         SMSCHARGE_PROCESS_DATE,
         SMSCHARGE_FIN_YEAR,
         SMSCHARGE_CHARGE_AMT,
         SMSCHARGE_VAT_AMT,
         SMSCHARGE_POST_TRAN_BRN,
         SMSCHARGE_POST_TRAN_DATE,
         SMSCHARGE_POST_TRAN_BATCH_NUM,
         SMSCHARGE_ENTD_BY,
         SMSCHARGE_ENTD_ON,
         SMSCHARGE_AUTH_BY,
         SMSCHARGE_AUTH_ON,
         SMSCHARGE_SERVICE_TYPE)
      VALUES
        (T_SMSCHARGE_ENTITY_NUM(IND),
         T_SMSCHARGE_BRN_CODE(IND),
         T_SMSCHARGE_INTERNAL_ACNUM(IND),
         T_SMSCHARGE_PROCESS_DATE(IND),
         T_SMSCHARGE_FIN_YEAR(IND),
         T_SMSCHARGE_CHARGE_AMT(IND),
         T_SMSCHARGE_VAT_AMT(IND),
         W_BRN_CODE,
         W_ASON_DATE,
         W_BATCH_NUM,
         T_SMSCHARGE_ENTD_BY(IND),
         T_SMSCHARGE_ENTD_ON(IND),
         T_SMSCHARGE_AUTH_BY(IND),
         T_SMSCHARGE_AUTH_ON(IND),
         T_SMSCHARGE_SERVICE_TYPE(IND));

    T_SMSCHARGE_ENTITY_NUM .DELETE;
    T_SMSCHARGE_BRN_CODE .DELETE;
    T_SMSCHARGE_INTERNAL_ACNUM.DELETE;
    T_SMSCHARGE_PROCESS_DATE .DELETE;
    T_SMSCHARGE_FIN_YEAR .DELETE;
    T_SMSCHARGE_CHARGE_AMT .DELETE;
    T_SMSCHARGE_VAT_AMT .DELETE;
    T_SMSCHARGE_ENTD_BY .DELETE;
    T_SMSCHARGE_ENTD_ON .DELETE;
    T_SMSCHARGE_AUTH_BY .DELETE;
    T_SMSCHARGE_AUTH_ON .DELETE;
    T_SMSCHARGE_SERVICE_TYPE.DELETE;
  END;

  -------------- Transaction posting ----------------------
  PROCEDURE MOVE_TO_TRAN_REC(P_TRAN_BRN_CODE       IN NUMBER,
                             P_TRAN_ACING_BRN_CODE IN NUMBER,
                             P_TRAN_DATE_OF_TRAN   IN DATE,
                             P_TRAN_INTERNAL_ACNUM IN NUMBER,
                             P_TRAN_CONTRACT_NUM   IN NUMBER,
                             P_TRAN_GLACC_CODE     IN VARCHAR2,
                             P_TRAN_DB_CR_FLG      IN VARCHAR2,
                             P_TRAN_CURR_CODE      IN VARCHAR2,
                             P_TRAN_AMOUNT         IN NUMBER,
                             P_TRAN_VALUE_DATE     IN DATE,
                             P_TRAN_NARR_DTL       IN VARCHAR2) IS

  BEGIN

    IF P_TRAN_AMOUNT > 0 THEN
      W_POST_ARRAY_INDEX := W_POST_ARRAY_INDEX + 1;
      PKG_AUTOPOST.PV_TRAN_REC(W_POST_ARRAY_INDEX).TRAN_BRN_CODE := P_TRAN_BRN_CODE;
      PKG_AUTOPOST.PV_TRAN_REC(W_POST_ARRAY_INDEX).TRAN_ACING_BRN_CODE := P_TRAN_ACING_BRN_CODE;
      PKG_AUTOPOST.PV_TRAN_REC(W_POST_ARRAY_INDEX).TRAN_DATE_OF_TRAN := P_TRAN_DATE_OF_TRAN;
      PKG_AUTOPOST.PV_TRAN_REC(W_POST_ARRAY_INDEX).TRAN_INTERNAL_ACNUM := P_TRAN_INTERNAL_ACNUM;
      PKG_AUTOPOST.PV_TRAN_REC(W_POST_ARRAY_INDEX).TRAN_CONTRACT_NUM := P_TRAN_CONTRACT_NUM;
      PKG_AUTOPOST.PV_TRAN_REC(W_POST_ARRAY_INDEX).TRAN_GLACC_CODE := P_TRAN_GLACC_CODE;
      PKG_AUTOPOST.PV_TRAN_REC(W_POST_ARRAY_INDEX).TRAN_DB_CR_FLG := P_TRAN_DB_CR_FLG;

      IF P_TRAN_INTERNAL_ACNUM > 0 AND W_LOAN_ACNTS <> 0 THEN
        PKG_AUTOPOST.PV_TRAN_REC(W_POST_ARRAY_INDEX).TRAN_AMT_BRKUP := '1';
        W_LOAN_IDX := W_LOAN_IDX + 1;
        PKG_AUTOPOST.PV_TRAN_ADV_REC(W_LOAN_IDX).TRANADV_BATCH_SL_NUM := W_POST_ARRAY_INDEX;
        PKG_AUTOPOST.PV_TRAN_ADV_REC(W_LOAN_IDX).TRANADV_PRIN_AC_AMT := 0;
        PKG_AUTOPOST.PV_TRAN_ADV_REC(W_LOAN_IDX).TRANADV_INTRD_AC_AMT := 0;
        PKG_AUTOPOST.PV_TRAN_ADV_REC(W_LOAN_IDX).TRANADV_CHARGE_AC_AMT := P_TRAN_AMOUNT;
      END IF;

      PKG_AUTOPOST.PV_TRAN_REC(W_POST_ARRAY_INDEX).TRAN_CURR_CODE := P_TRAN_CURR_CODE;
      PKG_AUTOPOST.PV_TRAN_REC(W_POST_ARRAY_INDEX).TRAN_AMOUNT := P_TRAN_AMOUNT;
      PKG_AUTOPOST.PV_TRAN_REC(W_POST_ARRAY_INDEX).TRAN_VALUE_DATE := P_TRAN_VALUE_DATE;
      PKG_AUTOPOST.PV_TRAN_REC(W_POST_ARRAY_INDEX).TRAN_NARR_DTL1 := SUBSTR(P_TRAN_NARR_DTL,
                                                                            1,
                                                                            35);
      PKG_AUTOPOST.PV_TRAN_REC(W_POST_ARRAY_INDEX).TRAN_NARR_DTL2 := SUBSTR(P_TRAN_NARR_DTL,
                                                                            36,
                                                                            35);
      PKG_AUTOPOST.PV_TRAN_REC(W_POST_ARRAY_INDEX).TRAN_NARR_DTL3 := SUBSTR(P_TRAN_NARR_DTL,
                                                                            71,
                                                                            35);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      W_ERROR_MSG := 'ERROR IN MOVE_TO_TRAN_REC ' || '-' ||
                     SUBSTR(SQLERRM, 1, 500);
      RAISE E_MY_EXCEPTION;
  END MOVE_TO_TRAN_REC;

  PROCEDURE SET_TRAN_KEY_VALUES(P_TRAN_BRN_CODE     IN NUMBER,
                                P_TRAN_DATE_OF_TRAN IN DATE) IS
  BEGIN
    PKG_AUTOPOST.PV_SYSTEM_POSTED_TRANSACTION  := TRUE;
    PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BRN_CODE     := P_TRAN_BRN_CODE;
    PKG_AUTOPOST.PV_TRAN_KEY.TRAN_DATE_OF_TRAN := P_TRAN_DATE_OF_TRAN;
    PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_NUMBER := 0;
    PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_SL_NUM := 0;
  EXCEPTION
    WHEN OTHERS THEN
      W_ERROR_MSG := 'ERROR IN SET_TRAN_KEY_VALUES ' || '-' ||
                     SUBSTR(SQLERRM, 1, 500);
      RAISE E_MY_EXCEPTION;
  END SET_TRAN_KEY_VALUES;
  ------------------------------------------------------------------------------------------------------
  PROCEDURE SET_TRANBAT_VALUES(P_TRAN_BRN_CODE IN NUMBER) IS
  BEGIN
    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_TABLE := 'SMSCHARGE';
    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_KEY   := P_TRAN_BRN_CODE;
    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL1    := 'SMS Charge';

  EXCEPTION
    WHEN OTHERS THEN
      W_ERROR_MSG := 'ERROR IN SET_TRANBAT_VALUES ' || P_TRAN_BRN_CODE ||
                     SUBSTR(SQLERRM, 1, 500);
      RAISE E_MY_EXCEPTION;
  END SET_TRANBAT_VALUES;

  ---------------------------------------------------------------------------------------------------------
  PROCEDURE POST_TRANSACTION IS
    V_AUTOPOST_ERRCD VARCHAR2(100) := '0000';
    V_AUTOPOST_ERRM  VARCHAR2(1000);
  BEGIN

    IF W_POST_ARRAY_INDEX > 0 THEN
      /* Need to disable during testing*/
      PKG_APOST_INTERFACE.SP_POST_SODEOD_BATCH(W_ENTITY_CODE,
                                                'A',
                                                W_POST_ARRAY_INDEX,
                                                0,
                                                V_AUTOPOST_ERRCD,
                                                V_AUTOPOST_ERRM,
                                                W_BATCH_NUM); 
     -----------------------End of Block---------------------
     /* Need to enable during testing*/
     /*      
      PKG_APOST_INTERFACE.SP_POST_AUTO_AUTHORIZED(W_ENTITY_CODE,
                                                  'A',
                                                  W_POST_ARRAY_INDEX,
                                                  0,
                                                  V_AUTOPOST_ERRCD,
                                                  V_AUTOPOST_ERRM,
                                                  W_BATCH_NUM);
     */
     ----------------------------End Of Block-----------------
      W_POST_ARRAY_INDEX := 0;
      W_LOAN_IDX         := 0;
      PKG_AUTOPOST.PV_TRAN_REC.DELETE;

      IF (V_AUTOPOST_ERRCD <> '0000') THEN
        W_ERROR_MSG := SUBSTR('ERROR IN POST_TRANSACTION For SMS Charge-  ' ||
                              W_BRN_CODE || ' ' || V_AUTOPOST_ERRCD ||
                              V_AUTOPOST_ERRM ||
                              FN_GET_AUTOPOST_ERR_MSG(W_ENTITY_CODE),
                              1,
                              1000);
        RAISE E_MY_EXCEPTION;
      ELSE
        SP_CHARGE_DATA_INSERT;

      END IF;

    END IF;

    PKG_AUTOPOST.PV_TRAN_REC.DELETE;
    W_POST_ARRAY_INDEX := 0;

  END POST_TRANSACTION;

  PROCEDURE INIT_VALUES IS
  BEGIN
    W_TOTAL_CHARGE_AMT      := 0;
    W_TOTAL_VAT_AMT         := 0;
    W_AC_CHARGE_AMT         := 0;
    W_AC_VAT_AMT            := 0;
    W_SETTLE_BRN_CHARGE_AMT := 0;
    W_BRN_CHARGE_AMT        := 0;
    W_AC_BALANCE            := 0;

    W_BATCH_NUM := NULL;
  END;

  PROCEDURE SP_SMS_CHARGE_PROC(P_ENTITY_NUM IN NUMBER,
                               P_BRN_CODE   IN NUMBER) IS
    V_NEW_AC_VAT        NUMBER;
    V_NEW_AC_CHARGE_AMT NUMBER;
    V_PBDCONT_CONT_NUM  NUMBER;

    ----------------------------------
  BEGIN
      --Loop for multiple service type
    FOR SVCINX IN 1 .. T_SMS.COUNT LOOP

      -----------Clearing previous data
      W_TOTAL_VAT_AMT    := 0;
      W_TOTAL_CHARGE_AMT := 0;
      -- TEMP_SERVICE_TYPE  := 0;
      TEMP_SERVICE_TYPE := T_SMS(SVCINX).SERVICE_TYPE;
      --------for sonali rupali base service type
      IF W_INS_OUR_BANK_CODE = '200' THEN
          --for sonali
          IF TEMP_SERVICE_TYPE = 1 THEN
            W_QUERY_PART2 := '  AND SMSCHARGE_SERVICE_TYPE=' || TEMP_SERVICE_TYPE ||
                             ') AND ' ||
                             '  (M.SERVICE1 = 1 OR (M.SERVICE1 = 0 AND (M.SERVICE1_DEACTIVATED_ON BETWEEN ADD_MONTHS(TRUNC(SYSDATE,''MONTH''), -6)  AND LAST_DAY(TRUNC(SYSDATE, ''MONTH''))))) ';
          ELSIF TEMP_SERVICE_TYPE = 2 THEN
            W_QUERY_PART2 := '  AND SMSCHARGE_SERVICE_TYPE=' || TEMP_SERVICE_TYPE ||
                             ') AND ' ||
                             '  ( M.SERVICE2 = 1 OR (M.SERVICE2 = 0 AND (M.SERVICE2_DEACTIVATED_ON BETWEEN ADD_MONTHS(TRUNC(SYSDATE,''MONTH''), -6)  AND LAST_DAY(TRUNC(SYSDATE, ''MONTH''))))) ';
          ELSE
            continue;
          END IF;
      ELSIF W_INS_OUR_BANK_CODE = '185' THEN
        --for rupali
        IF TEMP_SERVICE_TYPE = 1 THEN
          W_QUERY_PART1 := '';
          W_QUERY_PART2 := ' ) AND S.SMSBREG_ACNT_CLOSED_ON IS NULL AND A.ACNTS_AC_TYPE    <> ''SBS'' ';
        ELSE
          continue;
        END IF;
      ELSE
          W_ERROR_MSG := 'Bank code undefined';
          Exit;

      END IF;
      ------------------------------------
      IF W_INS_OUR_BANK_CODE = '200' THEN
         W_SQL_DATA := 'SELECT DISTINCT M.INT_ACNUM SMSBREG_ACNT_NUMBER,
                       A.ACNTS_ENTITY_NUM,
                       A.ACNTS_BRN_CODE,
                       A.ACNTS_CURR_CODE,
                       B.ACNTBAL_AC_BAL,
                       B.ACNTBAL_BC_BAL,
                       P.PRODUCT_FOR_DEPOSITS,
                       P.PRODUCT_FOR_LOANS,
                       P.PRODUCT_CONTRACT_ALLOWED,
                       P.PRODUCT_FOR_RUN_ACS
                  FROM MOBILEREG M,
                       ACNTS A,
                       ACNTBAL B,
                       PRODUCTS P 
                  WHERE
                       M.ENTITY_NUM = A.ACNTS_ENTITY_NUM
                       AND M.INT_ACNUM = A.ACNTS_INTERNAL_ACNUM
                       AND A.ACNTS_ENTITY_NUM = B.ACNTBAL_ENTITY_NUM
                       AND A.ACNTS_INTERNAL_ACNUM = B.ACNTBAL_INTERNAL_ACNUM
                       AND A.ACNTS_CURR_CODE = B.ACNTBAL_CURR_CODE
                       AND P.PRODUCT_CODE = A.ACNTS_PROD_CODE
                       AND A.ACNTS_ENTITY_NUM = :ENTITY_NUMBER
                       AND A.ACNTS_BRN_CODE = :BRANCH_CODE
                       AND B.ACNTBAL_CURR_CODE = :CURR_CODE
                       AND ACNTS_INOP_ACNT = 0
                       AND NOT EXISTS
                                  (SELECT 1
                                     FROM SMSCHARGE
                                    WHERE     SMSCHARGE_ENTITY_NUM = A.ACNTS_ENTITY_NUM
                                          AND SMSCHARGE_BRN_CODE = A.ACNTS_BRN_CODE
                                          AND SMSCHARGE_INTERNAL_ACNUM = A.ACNTS_INTERNAL_ACNUM
                                          AND SMSCHARGE_PROCESS_DATE = :PROC_DATE
                       ' || W_QUERY_PART2 || '
                       AND B.ACNTBAL_AC_BAL <> 0
                       AND A.ACNTS_CLOSURE_DATE IS NULL 
					   AND NOT EXISTS (SELECT 1 FROM SMS_ACC_TYPE_EXC WHERE AC_TYPE = A.ACNTS_AC_TYPE AND AC_SUB_TYPE = A.ACNTS_AC_SUB_TYPE) ';

      ELSIF W_INS_OUR_BANK_CODE = '185' THEN
           W_SQL_DATA := 'SELECT DISTINCT S.SMSBREG_ACNT_NUMBER,
                       A.ACNTS_ENTITY_NUM,
                       A.ACNTS_BRN_CODE,
                       A.ACNTS_CURR_CODE,
                       B.ACNTBAL_AC_BAL,
                       B.ACNTBAL_BC_BAL,
                       P.PRODUCT_FOR_DEPOSITS,
                       P.PRODUCT_FOR_LOANS,
                       P.PRODUCT_CONTRACT_ALLOWED,
                       P.PRODUCT_FOR_RUN_ACS
                  FROM SMSBREGDTL S,
                       ACNTS A,
                       ACNTBAL B,
                       PRODUCTS P ' || W_QUERY_PART1 || '
                 WHERE
                       S.SMSBREG_ACNT_NUMBER = A.ACNTS_INTERNAL_ACNUM
                       AND A.ACNTS_ENTITY_NUM = B.ACNTBAL_ENTITY_NUM
                       AND A.ACNTS_INTERNAL_ACNUM = B.ACNTBAL_INTERNAL_ACNUM
                       AND A.ACNTS_CURR_CODE = B.ACNTBAL_CURR_CODE
                       AND P.PRODUCT_CODE = A.ACNTS_PROD_CODE
                       AND A.ACNTS_ENTITY_NUM = :ENTITY_NUMBER
                       AND A.ACNTS_BRN_CODE = :BRANCH_CODE
                       AND B.ACNTBAL_CURR_CODE = :CURR_CODE
                       AND ACNTS_INOP_ACNT = 0
                       AND NOT EXISTS
                                  (SELECT 1
                                     FROM SMSCHARGE
                                    WHERE     SMSCHARGE_ENTITY_NUM = A.ACNTS_ENTITY_NUM
                                          AND SMSCHARGE_BRN_CODE = A.ACNTS_BRN_CODE
                                          AND SMSCHARGE_INTERNAL_ACNUM =
                                                 A.ACNTS_INTERNAL_ACNUM
                                          AND SMSCHARGE_PROCESS_DATE = :PROC_DATE
                       ' || W_QUERY_PART2 || '
                       AND B.ACNTBAL_AC_BAL <> 0
                       AND A.ACNTS_CLOSURE_DATE IS NULL';
      ELSE
         continue;
      END IF;
         
      
      --dbms_output.put_line('W_SQL_DATA ='||W_SQL_DATA); 

      EXECUTE IMMEDIATE W_SQL_DATA BULK COLLECT
        INTO T_ACNTS
        USING P_ENTITY_NUM, --P_ENTITY_NUM, 
        P_BRN_CODE, --'BDT', 
        'BDT', W_ASON_DATE;

      INIT_VALUES;
      
	  IF T_ACNTS.COUNT < 1 THEN
	  	CONTINUE;
	  END IF;
	  
      FOR INX IN 1 .. T_ACNTS.COUNT LOOP

        W_AC_BALANCE       := 0;
        -- W_AC_BALANCE    := T_ACNTS(INX).ACNTBAL_AC_BAL;
        W_INTERNAL_ACNUM   := T_ACNTS(INX).ACNTS_INTERNAL_ACNUM;
        V_PBDCONT_CONT_NUM := 0;
        W_LOAN_ACNTS       := 0;
        W_ACNTS_CURR_CODE  := T_ACNTS(INX).ACNTS_CURR_CODE;

        IF T_ACNTS(INX).PRODUCT_FOR_LOANS = '1' AND T_ACNTS(INX)
           .PRODUCT_FOR_DEPOSITS <> '1' THEN
          W_LOAN_ACNTS := 1;
        END IF;
		
        BEGIN
            SP_AVLBAL(PKG_ENTITY.FN_GET_ENTITY_CODE,
                      T_ACNTS(INX).ACNTS_INTERNAL_ACNUM,
                      V_DUMMY_C2,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      W_AC_BALANCE,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_DUMMY_D,
                      V_DUMMY_C,
                      V_DUMMY_D,
                      V_DUMMY_C,
                      V_DUMMY_C,
                      V_DUMMY_C,
                      V_DUMMY_C,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_ERR_MSG,
                      V_DUMMY_C,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      V_DUMMY_N,
                      1,
                      V_DUMMY_N);

          EXCEPTION
            WHEN OTHERS THEN
              W_AC_BALANCE := 0;
        END;
        
        BEGIN
          PKG_CHARGES.SP_GET_CHARGES(T_ACNTS              (INX)
                                     .ACNTS_ENTITY_NUM,
                                     T_ACNTS              (INX)
                                     .ACNTS_INTERNAL_ACNUM,
                                     T_ACNTS              (INX)
                                     .ACNTS_CURR_CODE,
                                     W_AC_BALANCE,
                                     T_SMS                (SVCINX)
                                     .SMSCHRG_CODE,
                                     T_SMS                (SVCINX)
                                     .CHGCD_CHG_TYPE,
                                     V_CHGCD_CHG_CURR_CODE,
                                     W_AC_CHARGE_AMT,
                                     W_SERVICE_AMOUNT,
                                     W_AC_VAT_AMT,
                                     W_SERVICE_ADDN_AMOUNT,
                                     W_SERVICE_CESS_AMOUNT,
                                     W_ERROR);
        END;
        
        IF T_ACNTS (INX).PRODUCT_CONTRACT_ALLOWED = '1'
          THEN
            BEGIN
              SELECT MAX(PBDCONT_CONT_NUM)
                INTO V_PBDCONT_CONT_NUM
                FROM PBDCONTRACT
               WHERE PBDCONT_ENTITY_NUM = P_ENTITY_NUM
                 AND PBDCONT_BRN_CODE = P_BRN_CODE
                 AND PBDCONT_DEP_AC_NUM = W_INTERNAL_ACNUM
                 AND PBDCONT_CLOSURE_DATE IS NULL;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                V_PBDCONT_CONT_NUM := 0;
            END;
        END IF;

        V_PBDCONT_CONT_NUM := NVL(V_PBDCONT_CONT_NUM, 0);

        IF W_AC_CHARGE_AMT > 0 THEN
          IF W_AC_BALANCE < (W_AC_CHARGE_AMT + W_AC_VAT_AMT) AND
             W_LOAN_ACNTS = 0 THEN

            IF W_AC_BALANCE > 1 THEN
              V_NEW_AC_CHARGE_AMT := W_AC_BALANCE / 1.15;
              V_NEW_AC_VAT        := CEIL((W_AC_BALANCE -
                                           V_NEW_AC_CHARGE_AMT) );
              V_NEW_AC_CHARGE_AMT := W_AC_BALANCE - V_NEW_AC_VAT;
              IF W_AC_BALANCE < (V_NEW_AC_CHARGE_AMT + V_NEW_AC_VAT) THEN
                CONTINUE;
              ELSE
                W_AC_CHARGE_AMT := V_NEW_AC_CHARGE_AMT;
                W_AC_VAT_AMT    := V_NEW_AC_VAT;
              END IF;
            ELSE
              CONTINUE;
            END IF;
          END IF;
        ELSE
          CONTINUE;
        END IF;

           IF TEMP_SERVICE_TYPE='1' THEN
        W_AC_TRAN_NARATION := 'SMS Charge(Transactional Alert)';
        ELSE
           W_AC_TRAN_NARATION := 'SMS Charge(Push Pull)';
          END IF;

        MOVE_TO_TRAN_REC(P_TRAN_BRN_CODE       => P_BRN_CODE,
                         P_TRAN_ACING_BRN_CODE => P_BRN_CODE,
                         P_TRAN_DATE_OF_TRAN   => W_ASON_DATE,
                         P_TRAN_INTERNAL_ACNUM => W_INTERNAL_ACNUM,
                         P_TRAN_CONTRACT_NUM   => V_PBDCONT_CONT_NUM,
                         P_TRAN_GLACC_CODE     => '0',
                         P_TRAN_DB_CR_FLG      => 'D',
                         P_TRAN_CURR_CODE      => W_ACNTS_CURR_CODE,
                         P_TRAN_AMOUNT         => W_AC_CHARGE_AMT,
                         P_TRAN_VALUE_DATE     => W_ASON_DATE,
                         P_TRAN_NARR_DTL       => W_AC_TRAN_NARATION);

        W_TOTAL_CHARGE_AMT := W_TOTAL_CHARGE_AMT + W_AC_CHARGE_AMT;

          IF TEMP_SERVICE_TYPE='1' THEN
        W_AC_TRAN_NARATION := 'SMS Charge VAT(Transactional Alert)';
        ELSE
           W_AC_TRAN_NARATION := 'SMS Charge VAT(Push Pull)';
          END IF;

        MOVE_TO_TRAN_REC(P_TRAN_BRN_CODE       => P_BRN_CODE,
                         P_TRAN_ACING_BRN_CODE => P_BRN_CODE,
                         P_TRAN_DATE_OF_TRAN   => W_ASON_DATE,
                         P_TRAN_INTERNAL_ACNUM => W_INTERNAL_ACNUM,
                         P_TRAN_CONTRACT_NUM   => V_PBDCONT_CONT_NUM,
                         P_TRAN_GLACC_CODE     => '0',
                         P_TRAN_DB_CR_FLG      => 'D',
                         P_TRAN_CURR_CODE      => W_ACNTS_CURR_CODE,
                         P_TRAN_AMOUNT         => W_AC_VAT_AMT,
                         P_TRAN_VALUE_DATE     => W_ASON_DATE,
                         P_TRAN_NARR_DTL       => W_AC_TRAN_NARATION);

        W_TOTAL_VAT_AMT := W_TOTAL_VAT_AMT + W_AC_VAT_AMT;

        SP_MOVE_CHARGE_TABLE(P_ENTITY_NUM     => P_ENTITY_NUM,
                             P_BRN_CODE       => P_BRN_CODE,
                             P_INTERNAL_ACNUM => W_INTERNAL_ACNUM,
                             P_PROCESS_DATE   => W_ASON_DATE,
                             P_CHARGE_AMT     => W_AC_CHARGE_AMT,
                             P_VAT_AMT        => W_AC_VAT_AMT,
                             P_USER_ID        => W_USER_ID,
                             P_SERVICE_TYPE   => TEMP_SERVICE_TYPE);

      END LOOP;

      BEGIN
        SELECT IBACPM_IBR_HEAD_DB, IBACPM_IBR_HEAD_CR
          INTO W_IBACPM_IBR_HEAD_DB, W_IBACPM_IBR_HEAD_CR
          FROM IBACPM
         WHERE IBACPM_ENTITY_NUM = P_ENTITY_NUM
           AND IBACPM_BRN_CODE = P_BRN_CODE
           AND IBACPM_CURR_CODE = 'BDT';
      END;
      if (W_TOTAL_CHARGE_AMT + W_TOTAL_VAT_AMT) > 0 then
        W_AC_BRN_CHARGE_GL  := T_SMS(SVCINX).CHGCD_GLACCESS_CD; -- instead of V_CHGCD_GLACCESS_CD;
        W_AC_BRN_VAT_GL     := T_SMS(SVCINX).STAXACPM_STAX_RCVD_HEAD; --instead of V_STAX_RCVD_HEAD;
        W_IBR_VAT_GL        := T_SMS(SVCINX).STAXACPM_STAX_RCVD_HEAD; --instead of V_STAX_RCVD_HEAD;
        W_IBR_CHARGE_AC     := T_SMS(SVCINX).SMSCHRG_ACNUM; --instead of V_SMSCHRG_ACNUM;
        W_SETTLE_BRANCH     := T_SMS(SVCINX).SMSCHRG_BRN_CODE; -- instead of V_SMSCHRG_BRN_CODE;
        W_SETTLE_BRANCH_RAT := T_SMS(SVCINX).SMSCHARGE_SPLIT_RATE; --instead of V_SMSCHARGE_SPLIT_RATE;

        W_SETTLE_BRN_CHARGE_AMT := ROUND((W_TOTAL_CHARGE_AMT *
                                         W_SETTLE_BRANCH_RAT) / 100,2);
        W_BRN_CHARGE_AMT        := W_TOTAL_CHARGE_AMT -
                                   W_SETTLE_BRN_CHARGE_AMT;

         IF TEMP_SERVICE_TYPE='1' THEN
            W_AC_TRAN_NARATION := 'SMS Charge(Transactional Alert)';
         ELSE
            W_AC_TRAN_NARATION := 'SMS Charge(Push Pull)';
         END IF;

        IF W_SETTLE_BRANCH <> P_BRN_CODE THEN

          MOVE_TO_TRAN_REC(P_TRAN_BRN_CODE       => P_BRN_CODE,
                           P_TRAN_ACING_BRN_CODE => P_BRN_CODE,
                           P_TRAN_DATE_OF_TRAN   => W_ASON_DATE,
                           P_TRAN_INTERNAL_ACNUM => '0',
                           P_TRAN_CONTRACT_NUM   => '0',
                           P_TRAN_GLACC_CODE     => W_AC_BRN_CHARGE_GL,
                           P_TRAN_DB_CR_FLG      => 'C',
                           P_TRAN_CURR_CODE      => V_CHGCD_CHG_CURR_CODE,
                           P_TRAN_AMOUNT         => W_BRN_CHARGE_AMT,
                           P_TRAN_VALUE_DATE     => W_ASON_DATE,
                           P_TRAN_NARR_DTL       => W_AC_TRAN_NARATION);
          W_BRN_CHARGE_AMT := 0;
          ----------------when vendor charge rate is not 0
          IF W_SETTLE_BRANCH_RAT > 0 THEN
            MOVE_TO_TRAN_REC(P_TRAN_BRN_CODE       => P_BRN_CODE,
                             P_TRAN_ACING_BRN_CODE => W_SETTLE_BRANCH,
                             P_TRAN_DATE_OF_TRAN   => W_ASON_DATE,
                             P_TRAN_INTERNAL_ACNUM => W_IBR_CHARGE_AC,
                             P_TRAN_CONTRACT_NUM   => '0',
                             P_TRAN_GLACC_CODE     => '0',
                             P_TRAN_DB_CR_FLG      => 'C',
                             P_TRAN_CURR_CODE      => V_CHGCD_CHG_CURR_CODE,
                             P_TRAN_AMOUNT         => W_SETTLE_BRN_CHARGE_AMT,
                             P_TRAN_VALUE_DATE     => W_ASON_DATE,
                             P_TRAN_NARR_DTL       => W_AC_TRAN_NARATION);
          END IF;

          MOVE_TO_TRAN_REC(P_TRAN_BRN_CODE       => P_BRN_CODE,
                           P_TRAN_ACING_BRN_CODE => W_SETTLE_BRANCH,
                           P_TRAN_DATE_OF_TRAN   => W_ASON_DATE,
                           P_TRAN_INTERNAL_ACNUM => '0',
                           P_TRAN_CONTRACT_NUM   => '0',
                           P_TRAN_GLACC_CODE     => W_IBACPM_IBR_HEAD_DB,
                           P_TRAN_DB_CR_FLG      => 'D',
                           P_TRAN_CURR_CODE      => V_CHGCD_CHG_CURR_CODE,
                           P_TRAN_AMOUNT         => W_SETTLE_BRN_CHARGE_AMT,
                           P_TRAN_VALUE_DATE     => W_ASON_DATE,
                           P_TRAN_NARR_DTL       => W_AC_TRAN_NARATION);

          MOVE_TO_TRAN_REC(P_TRAN_BRN_CODE       => P_BRN_CODE,
                           P_TRAN_ACING_BRN_CODE => P_BRN_CODE,
                           P_TRAN_DATE_OF_TRAN   => W_ASON_DATE,
                           P_TRAN_INTERNAL_ACNUM => '0',
                           P_TRAN_CONTRACT_NUM   => '0',
                           P_TRAN_GLACC_CODE     => W_IBACPM_IBR_HEAD_CR,
                           P_TRAN_DB_CR_FLG      => 'C',
                           P_TRAN_CURR_CODE      => V_CHGCD_CHG_CURR_CODE,
                           P_TRAN_AMOUNT         => W_SETTLE_BRN_CHARGE_AMT,
                           P_TRAN_VALUE_DATE     => W_ASON_DATE,
                           P_TRAN_NARR_DTL       => W_AC_TRAN_NARATION);
          W_SETTLE_BRN_CHARGE_AMT := 0;

        ELSE

          MOVE_TO_TRAN_REC(P_TRAN_BRN_CODE       => P_BRN_CODE,
                           P_TRAN_ACING_BRN_CODE => P_BRN_CODE,
                           P_TRAN_DATE_OF_TRAN   => W_ASON_DATE,
                           P_TRAN_INTERNAL_ACNUM => '0',
                           P_TRAN_CONTRACT_NUM   => '0',
                           P_TRAN_GLACC_CODE     => W_AC_BRN_CHARGE_GL,
                           P_TRAN_DB_CR_FLG      => 'C',
                           P_TRAN_CURR_CODE      => V_CHGCD_CHG_CURR_CODE,
                           P_TRAN_AMOUNT         => W_BRN_CHARGE_AMT,
                           P_TRAN_VALUE_DATE     => W_ASON_DATE,
                           P_TRAN_NARR_DTL       => W_AC_TRAN_NARATION);
          W_BRN_CHARGE_AMT := 0;
          ----------------when vendor charge rate is not 0
          IF W_SETTLE_BRANCH_RAT > 0 THEN
            MOVE_TO_TRAN_REC(P_TRAN_BRN_CODE       => P_BRN_CODE,
                             P_TRAN_ACING_BRN_CODE => W_SETTLE_BRANCH,
                             P_TRAN_DATE_OF_TRAN   => W_ASON_DATE,
                             P_TRAN_INTERNAL_ACNUM => W_IBR_CHARGE_AC,
                             P_TRAN_CONTRACT_NUM   => '0',
                             P_TRAN_GLACC_CODE     => '0',
                             P_TRAN_DB_CR_FLG      => 'C',
                             P_TRAN_CURR_CODE      => V_CHGCD_CHG_CURR_CODE,
                             P_TRAN_AMOUNT         => W_SETTLE_BRN_CHARGE_AMT,
                             P_TRAN_VALUE_DATE     => W_ASON_DATE,
                             P_TRAN_NARR_DTL       => W_AC_TRAN_NARATION);
          END IF;
          W_SETTLE_BRN_CHARGE_AMT := 0;
        END IF;

          IF TEMP_SERVICE_TYPE='1' THEN
              W_AC_TRAN_NARATION := 'SMS Charge VAT(Transactional Alert)';
          ELSE
              W_AC_TRAN_NARATION := 'SMS Charge VAT(Push Pull)';
          END IF;

        MOVE_TO_TRAN_REC(P_TRAN_BRN_CODE       => P_BRN_CODE,
                         P_TRAN_ACING_BRN_CODE => P_BRN_CODE,
                         P_TRAN_DATE_OF_TRAN   => W_ASON_DATE,
                         P_TRAN_INTERNAL_ACNUM => '0',
                         P_TRAN_CONTRACT_NUM   => '0',
                         P_TRAN_GLACC_CODE     => W_AC_BRN_VAT_GL,
                         P_TRAN_DB_CR_FLG      => 'C',
                         P_TRAN_CURR_CODE      => V_CHGCD_CHG_CURR_CODE,
                         P_TRAN_AMOUNT         => W_TOTAL_VAT_AMT,
                         P_TRAN_VALUE_DATE     => W_ASON_DATE,
                         P_TRAN_NARR_DTL       => W_AC_TRAN_NARATION);

        W_TOTAL_VAT_AMT := 0;

        SET_TRAN_KEY_VALUES(P_BRN_CODE, W_ASON_DATE);
        SET_TRANBAT_VALUES(P_BRN_CODE);
        POST_TRANSACTION;
      end if;
    END LOOP;
  END SP_SMS_CHARGE_PROC;

  PROCEDURE SP_START_BRNWISE(V_ENTITY_NUM IN NUMBER,
                             P_BRN_CODE   IN NUMBER DEFAULT 0) IS
    W_BRN_CODE NUMBER(6);
  BEGIN
    /*Below block need to enable during production*/
     
     W_ENTITY_CODE := V_ENTITY_NUM;
     W_ASON_DATE   := PKG_EODSOD_FLAGS.PV_CURRENT_DATE;
     W_USER_ID     := PKG_EODSOD_FLAGS.PV_USER_ID;
     W_FROM_DATE   := PKG_PB_GLOBAL.SP_GET_FIN_YEAR_START(V_ENTITY_NUM);
     W_UPTO_DATE   := PKG_EODSOD_FLAGS.PV_CURRENT_DATE;
     W_USER_BRANCH := PKG_PB_GLOBAL.FN_GET_USER_BRN_CODE(V_ENTITY_NUM,W_USER_ID);
     
     -----------------End Of Block-------------------------------------
  /*Below block need to enable during testing*/
  /*
    W_ENTITY_CODE               := V_ENTITY_NUM;
    PKG_EODSOD_FLAGS.PV_USER_ID := 'INTELECT';
    PKG_AUTOPOST.PV_USERID      := 'INTELECT';
    W_ASON_DATE                 := TO_DATE('23-APR-2017', 'DD-MM-YYYY');
    W_USER_ID                   := 'INTELECT';
    W_FROM_DATE                 := TO_DATE('01-MAR-2016', 'DD-MM-YYYY');
    W_UPTO_DATE                 := TO_DATE('01-MAR-2016', 'DD-MM-YYYY');
    W_USER_BRANCH               := PKG_PB_GLOBAL.FN_GET_USER_BRN_CODE(V_ENTITY_NUM,
                                                                      W_USER_ID);
    */
    ---------------------------End Of Block---------------------------------------------

    PKG_PROCESS_CHECK.INIT_PROC_BRN_WISE(W_ENTITY_CODE, P_BRN_CODE);
    INIT_BANK_CODE;
    SP_GET_CHARGE_VALUE;

    FOR IDX IN 1 .. PKG_PROCESS_CHECK.V_ACNTBRN.COUNT LOOP
      BEGIN
        W_BRN_CODE := PKG_PROCESS_CHECK.V_ACNTBRN(IDX).LN_BRN_CODE;

        IF PKG_PROCESS_CHECK.CHK_BRN_ALREADY_PROCESSED(W_ENTITY_CODE,
                                                       W_BRN_CODE) = FALSE THEN

          PKG_AUTOPOST.PV_TRAN_REC.DELETE;
          W_POST_ARRAY_INDEX := 0;
          W_LOAN_IDX         := 0;

          SP_SMS_CHARGE_PROC(W_ENTITY_CODE, W_BRN_CODE);
          /* Below block need to disable during testing*/
          IF TRIM(PKG_EODSOD_FLAGS.PV_ERROR_MSG) IS NULL THEN
            PKG_PROCESS_CHECK.INSERT_ROW_INTO_EODSODPROCBRN(W_ENTITY_CODE,
                                                            W_BRN_CODE);
          END IF;
          
          PKG_PROCESS_CHECK.CHECK_COMMIT_ROLLBACK_STATUS(W_ENTITY_CODE);
         --------------------------End of Block--------------------------
        END IF;

      END;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
    /*Below block need to disable during testing*/
       IF TRIM(W_ERROR_MSG) IS NULL THEN
          W_ERROR_MSG := PKG_EODSOD_FLAGS.PV_ERROR_MSG ||
                         SUBSTR(SQLERRM, 1, 1000);
        END IF;

        PKG_EODSOD_FLAGS.PV_ERROR_MSG := W_ERROR_MSG;
   ---------------------------End of Block---------------------------------
      PKG_PB_GLOBAL.DETAIL_ERRLOG(W_ENTITY_CODE, 'E', W_ERROR_MSG, ' ', 0);
      RAISE_APPLICATION_ERROR(-20100, 'ERROR IN SMS CHARGE ' || W_ERROR_MSG);

  END SP_START_BRNWISE;
END PKG_SMS_CHARGE;
/
