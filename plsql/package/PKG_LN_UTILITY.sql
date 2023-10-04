CREATE OR REPLACE PACKAGE PKG_LN_UTILITY IS
  V_SINGLE_INT_RATE NUMBER(8, 5);
  PV_ERR_MSG        VARCHAR2(1000);

  PROCEDURE SP_LOAN_DUE_DATE(P_ENTITY_NUM    IN NUMBER,
                             P_ACCOUNTNUMBER IN NUMBER,
                             P_ASON_DATE     IN DATE,
                             P_DUE_DATE      OUT DATE,
                             P_ERR_MSG       OUT VARCHAR2);

  FUNCTION GET_EXTRA_INT_RATE(P_ENTITY_NUM    IN NUMBER,
                              P_ACCOUNTNUMBER IN NUMBER,
                              P_ASON_DATE     IN DATE) RETURN NUMBER;

  PROCEDURE GET_BLK_LOAN_INT(P_ENTITY_NUM IN NUMBER,
                             P_ACC_NUM    IN NUMBER,
                             P_REF_DESC   OUT VARCHAR2,
                             P_AMOUNT     OUT NUMBER,
                             P_ERR_MSG    OUT VARCHAR2);

  PROCEDURE GET_BLK_LOAN_INT_TO_RECV(P_ENTITY_NUM         IN NUMBER,
                                     P_ACC_NUM            IN NUMBER,
                                     P_DUE_AMOUNT         OUT NUMBER,
                                     P_TOT_BLK_AMOUNT     OUT NUMBER,
                                     P_TOT_INCENTIVE_RECV OUT NUMBER,
                                     P_ASSET_TYPE         OUT VARCHAR2,
                                     P_PURPOSE_CODE       OUT CHAR,
                                     P_PURPOSE_DESC       OUT VARCHAR2,
                                     P_GL_LIST            OUT VARCHAR2,
                                     P_ERR_MSG            OUT VARCHAR2);
  PROCEDURE UPD_RECV_BLK_LOAN_INT(P_ENTITY_NUM IN NUMBER,
                                  P_BRN_CODE   IN NUMBER,
                                  P_BATCH_NO   IN NUMBER,
                                  P_TRAN_DATE  IN VARCHAR2,
                                  P_ERR_MSG    OUT VARCHAR2);

  PROCEDURE UPDATE_LNACIRECAL_INDV_ACC(V_ENTITY_NUM IN NUMBER,
                                       V_ENTD_BY    IN VARCHAR2,
                                       P_BRN_CODE IN NUMBER,
                                       P_AC_NUM IN VARCHAR2,
                                       P_PROD_CODE IN NUMBER,
                                       P_CUR_CODE IN VARCHAR2,
                                       P_AC_OPEN_DATE DATE,
                                       P_RECALC_FROM_DT IN DATE,
                                       P_ERROR_MSG OUT VARCHAR2);

END PKG_LN_UTILITY;
/

CREATE OR REPLACE PACKAGE BODY PKG_LN_UTILITY IS
  W_ERR_MSG              VARCHAR2(200);
  W_ERROR_DTL_STR        VARCHAR2(1000);
  W_ACCOUNTNUMBER        NUMBER(14);
  W_ASON_DATE            DATE;
  V_ACNTS_PROD_CODE      NUMBER(4);
  V_CLIENTS_SEGMANT_CODE VARCHAR2(6);
  V_ACNTS_CURR_CODE      VARCHAR(3);
  V_ACNTS_AC_TYPE        VARCHAR2(5);
  V_ACNTS_AC_SUB_TYPE    NUMBER(3);
  V_ACNTS_SCHEME_CODE    VARCHAR2(6);
  V_ACNTS_CLIENT_NUM     ACNTS.ACNTS_CLIENT_NUM%TYPE;
  E_EXCEP EXCEPTION;
  LNPRD_GRACE_MONTH          LNPRODPM.LNPRD_GRACE_MONTH_EXP_DATE%TYPE;
  V_LIMIT_EXP_DATE           LIMITLINE.LMTLINE_LIMIT_EXPIRY_DATE%TYPE;
  V_LIMIT_GRACE_DATE         LIMITLINE.LMTLINE_DUE_DATE_GRACE_MON%TYPE;
  LOAN_DUE_DATE              DATE;
  LOAN_EXTRA_INT_RATE        LNPRODIR.LNPRODIR_APPL_INT_RATE_EXPIRY%TYPE;
  ERROR_MSG                  VARCHAR2(1000);
  W_SQL                      VARCHAR2(4300);
  W_SQL_DUMMY                VARCHAR2(4000);
  V_LNPRODPM_ROW             LNPRODPM%ROWTYPE;
  V_LNACIRSHIST_ROW          LNACIRSHIST%ROWTYPE;
  W_CYCLE_NUM                NUMBER(2);
  V_PURPOSE_CODE             CHAR(1); -- Recovery Purpuse Code; 1: COVID-19, 2: 5% BLK TRF 3: More Reasons
  V_ACBLK_AMT_TRF_BLK_GL_AMT NUMBER(18, 3);
  V_ACBLK_RECV_INCENTIVE_AMT NUMBER(18, 3);
  V_ACBLK_ASSET_TYPE         VARCHAR2(1);
  V_PRODUCT_CODE             NUMBER(6);
  --INTEREST RECALC----------------------
  W_BRN_CODE                 NUMBER(6);
  V_AMOUNT                   NUMBER(18, 3);
  V_INCOME_GL                VARCHAR2(15);
  V_ACR_GL                   VARCHAR2(15);
  V_RECALC_START_DATE        DATE;
  IDX                        NUMBER;
  IDX1                       NUMBER;
  W_ERR_CODE                 VARCHAR2(10);
  W_BATCH_NUMBER             NUMBER(7);
  W_ERROR                    VARCHAR2(1300);
  V_GLOB_ENTITY_NUM          MAINCONT.MN_ENTITY_NUM%TYPE;
  E_USEREXCEP                EXCEPTION;
  TMP_COUNT                  NUMBER;
  TMP_COUNT1                 NUMBER;
  V_ACTUAL_ACNUM             VARCHAR2(14);
  W_USER_ID                  VARCHAR2(10);
  V_ACNTS_OPENING_DATE       DATE;
  
  /*----*/

  V_ENTITY_NUM         NUMBER(1) ;
  V_BRN_CODE           NUMBER(6) ;
  V_TRAN_DATE          VARCHAR2(15) ;
  V_BATCH_NO           NUMBER(7) ;
  V_ACBLK_INTERNAL_ACC NUMBER(14);
  V_TOT_TRAN_AMOUNT    NUMBER(18, 3);
  V_ACBLK_PURPOSE      CHAR(1);

  TYPE TY_AMT_UPD_REC IS RECORD(
    V_ACBLK_INTERNAL_ACC NUMBER(14),
    V_TOT_TRAN_AMOUNT    NUMBER(18, 3),
    V_ACBLK_PURPOSE      VARCHAR2(1));

  TYPE TAB_AMT_UPD_REC IS TABLE OF TY_AMT_UPD_REC INDEX BY PLS_INTEGER;
  T_AMT_UPD_REC TAB_AMT_UPD_REC;

/*----*/





  TYPE TY_TOT_AMT_REC IS RECORD(
    V_TOT_DUE_AMOUNT           NUMBER,
    V_ACBLK_AMT_TRF_BLK_GL_AMT NUMBER(18, 3),
    V_ACBLK_RECV_INCENTIVE_AMT NUMBER(18, 3),
    V_ACBLK_ASSET_TYPE         VARCHAR2(1),
    V_PRODUCT_CODE             NUMBER(6));

  TYPE TAB_TOT_AMT_REC IS TABLE OF TY_TOT_AMT_REC INDEX BY PLS_INTEGER;
  T_BLOCKING_INT_DTL TAB_TOT_AMT_REC;

  PROCEDURE POST_PARA;
  PROCEDURE AUTOPOST_ARRAY_ASSIGN;
  PROCEDURE INITILIZE_TRANSACTION;
  PROCEDURE SET_TRAN_KEY_VALUES;
  PROCEDURE SET_TRANBAT_VALUES;

  PROCEDURE READ_LOAN_PRODUCT_DETAILS(P_ACNTS_PROD_CODE IN NUMBER);
  PROCEDURE READ_LOANACIR_DETAILS(P_ACCOUNTNUMBER IN NUMBER,
                                  P_ASON_DATE     IN DATE);
  PROCEDURE GET_LOAN_CYCLE_NUM(P_ACCOUNTNUMBER IN NUMBER);
  FUNCTION CHECK_INPUT_VALUES RETURN BOOLEAN IS
  BEGIN
    V_ACNTS_PROD_CODE      := 0;
    V_CLIENTS_SEGMANT_CODE := '';
    V_ACNTS_CURR_CODE      := '';
    V_ACNTS_AC_TYPE        := '';
    V_ACNTS_AC_SUB_TYPE    := 0;
    V_ACNTS_CLIENT_NUM     := 0;
    V_ACNTS_SCHEME_CODE    := '';
    IF W_ACCOUNTNUMBER = 0 THEN
      W_ERR_MSG := 'Account Number Should be specified';
      RETURN FALSE;
    END IF;
    V_LIMIT_EXP_DATE    := NULL;
    V_LIMIT_GRACE_DATE  := NULL;
    LOAN_DUE_DATE       := NULL;
    LOAN_EXTRA_INT_RATE := 0;
    RETURN TRUE;
  END CHECK_INPUT_VALUES;

  FUNCTION GET_EXTRA_INT_RATE(P_ENTITY_NUM    IN NUMBER,
                              P_ACCOUNTNUMBER IN NUMBER,
                              P_ASON_DATE     IN DATE) RETURN NUMBER IS
  BEGIN
    LOAN_DUE_DATE := NULL;
    ERROR_MSG     := '';
    SP_LOAN_DUE_DATE(P_ENTITY_NUM,
                     P_ACCOUNTNUMBER,
                     P_ASON_DATE,
                     LOAN_DUE_DATE,
                     ERROR_MSG);
    IF W_ASON_DATE > LOAN_DUE_DATE THEN
      <<GET_EXTRA_INT_RATE>>
      BEGIN
        READ_LOAN_PRODUCT_DETAILS(V_ACNTS_PROD_CODE);
        READ_LOANACIR_DETAILS(P_ACCOUNTNUMBER, P_ASON_DATE);
        GET_LOAN_CYCLE_NUM(P_ACCOUNTNUMBER);
        W_SQL       := 'SELECT NVL(L.LNPRODIRH_APPL_INT_RATE_EXPIRY, 0) ';
        W_SQL_DUMMY := ' FROM   LNPRODIRHIST L
                  WHERE LNPRODIRH_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND
                  L.LNPRODIRH_PROD_CODE = ' ||
                       V_ACNTS_PROD_CODE ||
                       'AND L.LNPRODIRH_CURR_CODE = ''' ||
                       V_ACNTS_CURR_CODE || CHR(39);
        IF V_LNPRODPM_ROW.LNPRD_INT_ACTYPE_REQD <> '1' THEN
          W_SQL_DUMMY := W_SQL_DUMMY ||
                         ' AND L.LNPRODIRH_AC_TYPE = '' '' AND L.LNPRODIRH_AC_SUB_TYPE = 0';
        ELSE
          W_SQL_DUMMY := W_SQL_DUMMY || ' AND L.LNPRODIRH_AC_TYPE = ''' ||
                         V_ACNTS_AC_TYPE ||
                         ''' AND L.LNPRODIRH_AC_SUB_TYPE = ' ||
                         V_ACNTS_AC_SUB_TYPE;
        END IF;
        IF W_CYCLE_NUM = 0 THEN
          W_SQL_DUMMY := W_SQL_DUMMY || ' AND LNPRODIRH_CYCLE_NUM = 0 ';
        ELSE
          W_SQL_DUMMY := W_SQL_DUMMY || ' AND LNPRODIRH_CYCLE_NUM = ' ||
                         W_CYCLE_NUM;
        END IF;
        IF V_LNPRODPM_ROW.LNPRD_INT_SCHEME_CODE_REQD <> '1' THEN
          W_SQL_DUMMY := W_SQL_DUMMY ||
                         ' AND L.LNPRODIRH_SCHEME_CODE = '' ''';
        ELSE
          W_SQL_DUMMY := W_SQL_DUMMY || ' AND L.LNPRODIRH_SCHEME_CODE = ''' ||
                         V_ACNTS_SCHEME_CODE || CHR(39);
        END IF;
        IF V_LNPRODPM_ROW.LNPRD_INT_CLSEG_REQD <> '1' THEN
          W_SQL_DUMMY := W_SQL_DUMMY ||
                         ' AND L.LNPRODIRH_CLSEG_CODE = '' ''';
        ELSE
          W_SQL_DUMMY := W_SQL_DUMMY || ' AND L.LNPRODIRH_CLSEG_CODE = ''' ||
                         V_CLIENTS_SEGMANT_CODE || CHR(39);
        END IF;
        IF V_LNPRODPM_ROW.LNPRD_INT_TENOR_SLABS_REQD <> '1' THEN
          W_SQL_DUMMY := W_SQL_DUMMY ||
                         ' AND L.LNPRODIRH_TENOR_SLAB_CODE = '' ''';
          W_SQL_DUMMY := W_SQL_DUMMY ||
                         ' AND L.LNPRODIRH_TENOR_SLAB_SL = 0';
        ELSE
          W_SQL_DUMMY := W_SQL_DUMMY ||
                         ' AND L.LNPRODIRH_TENOR_SLAB_CODE = ''' ||
                         V_LNACIRSHIST_ROW.LNACIRSH_TENOR_SLAB_CODE ||
                         CHR(39);
          W_SQL_DUMMY := W_SQL_DUMMY || ' AND L.LNPRODIRH_TENOR_SLAB_SL = ' ||
                         V_LNACIRSHIST_ROW.LNACIRSH_TENOR_SLAB_SL;
        END IF;

        W_SQL := W_SQL || W_SQL_DUMMY ||
                 ' AND LNPRODIRH_EFF_DATE = ( SELECT MAX(L.LNPRODIRH_EFF_DATE) ' ||
                 W_SQL_DUMMY || ' AND L.LNPRODIRH_EFF_DATE <= :1)';

        EXECUTE IMMEDIATE W_SQL
          INTO LOAN_EXTRA_INT_RATE
          USING P_ASON_DATE;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          W_ERR_MSG := 'Product Level Interest Rate Not Defined';
          RAISE E_EXCEP;

      END GET_EXTRA_INT_RATE;
    ELSE
      LOAN_EXTRA_INT_RATE := 0;
    END IF;

    IF ERROR_MSG IS NULL THEN
      RETURN LOAN_EXTRA_INT_RATE;
    ELSE
      RETURN 0;
    END IF;

  END GET_EXTRA_INT_RATE;
  PROCEDURE GET_LOAN_CYCLE_NUM(P_ACCOUNTNUMBER IN NUMBER) IS
  BEGIN
    W_CYCLE_NUM := 0;
    SELECT L.LNACDISBADDN_CYCLE_NUM
      INTO W_CYCLE_NUM
      FROM LNACDISBADDN L
     WHERE LNACDISBADDN_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
       AND L.LNACDISBADDN_LN_AC_NUM = P_ACCOUNTNUMBER
       AND L.LNACDISBADDN_DISB_SL =
           (SELECT MAX(LL.LNACDISBADDN_DISB_SL)
              FROM LNACDISBADDN LL
             WHERE LNACDISBADDN_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
               AND LL.LNACDISBADDN_LN_AC_NUM = P_ACCOUNTNUMBER);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      W_CYCLE_NUM := 0;
  END GET_LOAN_CYCLE_NUM;

  PROCEDURE READ_LOAN_PRODUCT_DETAILS(P_ACNTS_PROD_CODE IN NUMBER) IS
  BEGIN
    SELECT *
      INTO V_LNPRODPM_ROW
      FROM LNPRODPM L
     WHERE L.LNPRD_PROD_CODE = P_ACNTS_PROD_CODE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      W_ERR_MSG       := 'Product Code Not Available';
      W_ERROR_DTL_STR := 'Product Code  = ' || P_ACNTS_PROD_CODE;
      RAISE E_EXCEP;
  END READ_LOAN_PRODUCT_DETAILS;

  PROCEDURE READ_LOANACIR_DETAILS(P_ACCOUNTNUMBER IN NUMBER,
                                  P_ASON_DATE     IN DATE) IS
  BEGIN
    SELECT *
      INTO V_LNACIRSHIST_ROW
      FROM LNACIRSHIST L
     WHERE LNACIRSH_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
       AND L.LNACIRSH_INTERNAL_ACNUM = P_ACCOUNTNUMBER
       AND L.LNACIRSH_EFF_DATE =
           (SELECT MAX(LL.LNACIRSH_EFF_DATE)
              FROM LNACIRSHIST LL
             WHERE LNACIRSH_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
               AND LL.LNACIRSH_INTERNAL_ACNUM = P_ACCOUNTNUMBER
               AND LL.LNACIRSH_EFF_DATE <= P_ASON_DATE);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      W_ERR_MSG       := 'Loan Account Rate Available';
      W_ERROR_DTL_STR := 'Account Number  = ' ||
                         FACNO(PKG_ENTITY.FN_GET_ENTITY_CODE,
                               P_ACCOUNTNUMBER);
      RAISE E_EXCEP;
  END READ_LOANACIR_DETAILS;

  PROCEDURE READ_ACCOUNT_DETAILS IS
  BEGIN
    <<ACNTSREAD>>
    BEGIN
      SELECT A.ACNTS_PROD_CODE,
             A.ACNTS_CURR_CODE,
             A.ACNTS_AC_TYPE,
             A.ACNTS_AC_SUB_TYPE,
             A.ACNTS_SCHEME_CODE,
             C.CLIENTS_CODE,
             C.CLIENTS_SEGMENT_CODE
        INTO V_ACNTS_PROD_CODE,
             V_ACNTS_CURR_CODE,
             V_ACNTS_AC_TYPE,
             V_ACNTS_AC_SUB_TYPE,
             V_ACNTS_SCHEME_CODE,
             V_ACNTS_CLIENT_NUM,
             V_CLIENTS_SEGMANT_CODE
        FROM CLIENTS C, ACNTS A
       WHERE ACNTS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
         AND A.ACNTS_INTERNAL_ACNUM = W_ACCOUNTNUMBER
         AND C.CLIENTS_CODE = A.ACNTS_CLIENT_NUM;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        W_ERR_MSG       := 'Account Number Not Available';
        W_ERROR_DTL_STR := 'Account Number = ' ||
                           FACNO(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                 W_ACCOUNTNUMBER);
        RAISE E_EXCEP;
    END ACNTSREAD;

  END READ_ACCOUNT_DETAILS;

  PROCEDURE GET_LIMIT_DUE_DATE IS
  BEGIN
    <<GET_LIMIT_DETAILS>>
    BEGIN
      SELECT L.LMTLINE_LIMIT_EXPIRY_DATE,
             L.LMTLINE_DUE_DATE_GRACE_MON,
             P.LNPRD_GRACE_MONTH_EXP_DATE
        INTO V_LIMIT_EXP_DATE, V_LIMIT_GRACE_DATE, LNPRD_GRACE_MONTH
        FROM ACNTS A, ACASLLDTL LL, LIMITLINE L, LNPRODPM P
       WHERE A.ACNTS_ENTITY_NUM = 1
         AND L.LMTLINE_ENTITY_NUM = 1
         AND LL.ACASLLDTL_ENTITY_NUM = 1
         AND A.ACNTS_INTERNAL_ACNUM = LL.ACASLLDTL_INTERNAL_ACNUM
         AND LL.ACASLLDTL_CLIENT_NUM = L.LMTLINE_CLIENT_CODE
         AND LL.ACASLLDTL_LIMIT_LINE_NUM = L.LMTLINE_NUM
         AND A.ACNTS_INTERNAL_ACNUM = W_ACCOUNTNUMBER
         AND A.ACNTS_CLOSURE_DATE IS NULL
         AND P.LNPRD_PROD_CODE = A.ACNTS_PROD_CODE;
    EXCEPTION
      WHEN OTHERS THEN
        V_LIMIT_EXP_DATE   := '';
        V_LIMIT_GRACE_DATE := '';
        LNPRD_GRACE_MONTH  := 0;
    END GET_LIMIT_DETAILS;

    IF LNPRD_GRACE_MONTH > 0 THEN
      LOAN_DUE_DATE := ADD_MONTHS(V_LIMIT_EXP_DATE, LNPRD_GRACE_MONTH);
    ELSE
      LOAN_DUE_DATE := V_LIMIT_EXP_DATE;
    END IF;

  END GET_LIMIT_DUE_DATE;

  PROCEDURE SP_LOAN_DUE_DATE(P_ENTITY_NUM    IN NUMBER,
                             P_ACCOUNTNUMBER IN NUMBER,
                             P_ASON_DATE     IN DATE,
                             P_DUE_DATE      OUT DATE,
                             P_ERR_MSG       OUT VARCHAR2) IS
  BEGIN
    PKG_ENTITY.SP_SET_ENTITY_CODE(P_ENTITY_NUM);
    W_ERR_MSG       := '';
    W_ERROR_DTL_STR := '';
    W_ACCOUNTNUMBER := P_ACCOUNTNUMBER;
    W_ASON_DATE     := P_ASON_DATE;
    <<CHECK_LOAN_DUE_DATE>>
    BEGIN
      IF CHECK_INPUT_VALUES = TRUE THEN
        GET_LIMIT_DUE_DATE;
      END IF;

    EXCEPTION
      WHEN E_EXCEP THEN
        W_ERR_MSG := SUBSTR(W_ERR_MSG || ' ' || W_ERROR_DTL_STR, 1, 1000);
      WHEN OTHERS THEN
        W_ERR_MSG := SUBSTR('Error in SP_LOAN_DUE_DATE Calculation' || ' ' ||
                            SQLERRM,
                            1,
                            1000);
    END CHECK_LOAN_DUE_DATE;

    P_DUE_DATE := LOAN_DUE_DATE;
    P_ERR_MSG  := W_ERR_MSG;

  END SP_LOAN_DUE_DATE;

  --BLK INT VALIDATE:
  PROCEDURE GET_BLK_LOAN_INT(P_ENTITY_NUM IN NUMBER,
                             P_ACC_NUM    IN NUMBER,
                             P_REF_DESC   OUT VARCHAR2,
                             P_AMOUNT     OUT NUMBER,
                             P_ERR_MSG    OUT VARCHAR2)

   IS
    V_ACC_NUM    NUMBER(14);
    V_ERR_MSG    VARCHAR2(200);
    V_DUE_AMOUNT NUMBER(10, 4);
    W_SQL        VARCHAR2(500);
    V_ENTITY_NUM NUMBER;
  BEGIN
    V_DUE_AMOUNT   := 0;
    P_REF_DESC     := NULL;
    V_ENTITY_NUM   := P_ENTITY_NUM;
    V_ACC_NUM      := P_ACC_NUM;
    V_ERR_MSG      := '';
    V_PURPOSE_CODE := NULL;
    V_PRODUCT_CODE :=0;
    <<CONVD_19>>
    BEGIN

      W_SQL := 'SELECT NVL((NVL(ACBLK_AMT_TRF_BLK_GL,0)- NVL(ACBLK_RECV_INCENTIVE_AMT,0) -
               NVL(ACBLK_AMT_RECOVERED,0)),0) DUE_AMT,
               NVL(ACBLK_AMT_TRF_BLK_GL,0) ACBLK_AMT_TRF_BLK_GL ,
               NVL(ACBLK_RECV_INCENTIVE_AMT,0) ACBLK_RECV_INCENTIVE_AMT, ACBLK_ASSET_TYPE,ACBLK_PROD_CODE
               FROM ACBLKCOVID A WHERE A.ACBLK_ENTITY_NUM = :1 AND A.ACBLK_INTERNAL_ACNUM = :2';

      EXECUTE IMMEDIATE W_SQL BULK COLLECT
        INTO T_BLOCKING_INT_DTL
        USING V_ENTITY_NUM, V_ACC_NUM;

      V_DUE_AMOUNT := T_BLOCKING_INT_DTL(1).V_TOT_DUE_AMOUNT;
      IF V_DUE_AMOUNT > 0 THEN
        P_AMOUNT                   := V_DUE_AMOUNT;
        V_ACBLK_AMT_TRF_BLK_GL_AMT := ABS(T_BLOCKING_INT_DTL(1)
                                          .V_ACBLK_AMT_TRF_BLK_GL_AMT);
        V_ACBLK_RECV_INCENTIVE_AMT := ABS(T_BLOCKING_INT_DTL(1)
                                          .V_ACBLK_RECV_INCENTIVE_AMT);
        V_ACBLK_ASSET_TYPE         := T_BLOCKING_INT_DTL(1)
                                      .V_ACBLK_ASSET_TYPE;

        V_PURPOSE_CODE := 1;
        P_REF_DESC     := 'Please Recover Amount ' || P_AMOUNT ||
                          ' for Covid-19';
        RETURN;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_REF_DESC := '';
      WHEN OTHERS THEN
        P_REF_DESC := '';
    END COVID_19;

    <<FIVE_PERCENT_BLK>>
    BEGIN
      W_SQL := 'SELECT SUM(NVL(DEDUCTED_AMT,0))- SUM(NVL(AMT_RECOVERED,0))- SUM(NVL(BB_INCENTIVE_RCV,0)) DUE_AMT,0,0,''P'',A.ACNTS_PROD_CODE FROM DEDUCT_INT D, ACNTS A
 WHERE A.ACNTS_ENTITY_NUM =:1 AND D.ACNTS_BRN_CODE = A.ACNTS_BRN_CODE AND D.ACNTS_INTERNAL_ACNUM = A.ACNTS_INTERNAL_ACNUM AND A.ACNTS_INTERNAL_ACNUM = :2
 GROUP BY A.ACNTS_PROD_CODE';

      EXECUTE IMMEDIATE W_SQL BULK COLLECT
        INTO T_BLOCKING_INT_DTL
        USING V_ENTITY_NUM, V_ACC_NUM;
      V_DUE_AMOUNT := ABS(T_BLOCKING_INT_DTL(1).V_TOT_DUE_AMOUNT);
      IF V_DUE_AMOUNT > 0 THEN
        P_AMOUNT       := V_DUE_AMOUNT;
        P_REF_DESC     := 'Please Recover Amount ' || V_DUE_AMOUNT ||
                          ' for 5% Block amount';
        V_ACBLK_ASSET_TYPE         := T_BLOCKING_INT_DTL(1)
                                      .V_ACBLK_ASSET_TYPE;


        V_PRODUCT_CODE         := T_BLOCKING_INT_DTL(1)
                                      .V_PRODUCT_CODE;
        IF(V_PRODUCT_CODE = 2220)
        THEN
        V_PURPOSE_CODE := 2;
        END IF;
        IF(V_PRODUCT_CODE = 2223)
        THEN
        V_PURPOSE_CODE := 3;
        END IF;
        IF(V_PRODUCT_CODE = 2224)
        THEN
        V_PURPOSE_CODE := 4;
        END IF;
        -- added 23-Feb-2023 | Nazmul.
        IF(V_PRODUCT_CODE = 2240)
        THEN
        V_PURPOSE_CODE := 6;
        END IF;
        IF(V_PRODUCT_CODE = 2241)
        THEN
        V_PURPOSE_CODE := 7;        
        END IF;
        -- ---
        --TEST PURPOSE 2034--NEED TO DELLTE
       /*  IF(V_PRODUCT_CODE = 2034)
        THEN
        V_PURPOSE_CODE := 5;
        END IF;  */
        --END
        RETURN;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_REF_DESC := '';
      WHEN OTHERS THEN
        P_REF_DESC := '';
    END FIVE_PERCENT_BLK;

  END GET_BLK_LOAN_INT;
  --BLK INT RECOVERY:
  PROCEDURE GET_BLK_LOAN_INT_TO_RECV(P_ENTITY_NUM         IN NUMBER,
                                     P_ACC_NUM            IN NUMBER,
                                     P_DUE_AMOUNT         OUT NUMBER,
                                     P_TOT_BLK_AMOUNT     OUT NUMBER,
                                     P_TOT_INCENTIVE_RECV OUT NUMBER,
                                     P_ASSET_TYPE         OUT VARCHAR2,
                                     P_PURPOSE_CODE       OUT CHAR,
                                     P_PURPOSE_DESC       OUT VARCHAR2,
                                     P_GL_LIST            OUT VARCHAR2,
                                     P_ERR_MSG            OUT VARCHAR2)

   IS
    V_ACC_NUM    NUMBER(14);
    V_ERR_MSG    VARCHAR2(200);
    V_DUE_AMOUNT NUMBER(10, 4);
    V_REF_DESC   VARCHAR2(100);
    W_SQL        VARCHAR2(500);

  BEGIN

    V_ACC_NUM                  := P_ACC_NUM;
    V_ERR_MSG                  := '';
    V_PURPOSE_CODE             := NULL;
    V_DUE_AMOUNT               := 0;
    V_ACBLK_AMT_TRF_BLK_GL_AMT := 0;
    V_ACBLK_RECV_INCENTIVE_AMT := 0;
    V_ACBLK_ASSET_TYPE         := '';

    PKG_LN_UTILITY.GET_BLK_LOAN_INT(P_ENTITY_NUM,
                                    V_ACC_NUM,
                                    V_REF_DESC,
                                    P_DUE_AMOUNT,
                                    P_ERR_MSG);

    IF V_PURPOSE_CODE = 1 THEN
      P_PURPOSE_DESC := 'COVID-19 BLK RECOVERY.';
    ELSIF (V_PURPOSE_CODE = 2 OR V_PURPOSE_CODE = 3 OR V_PURPOSE_CODE = 4 OR V_PURPOSE_CODE = 5
        OR V_PURPOSE_CODE = 6 OR V_PURPOSE_CODE = 7) THEN
      P_PURPOSE_DESC := '5% BLK RECOVERY.';
    END IF;

    P_PURPOSE_CODE       := V_PURPOSE_CODE;
    P_TOT_BLK_AMOUNT     := V_ACBLK_AMT_TRF_BLK_GL_AMT;
    P_TOT_INCENTIVE_RECV := V_ACBLK_RECV_INCENTIVE_AMT;
    P_ASSET_TYPE         := V_ACBLK_ASSET_TYPE;

    <<GET_GL_LIST>>
    BEGIN
      SELECT BLOCK_INTEREST_GL || '/' || BLOCK_INCOME_GL || '/' ||
             BLOCK_INTEREST_RESCHEDULED_GL || '/' ||
             BLOCK_INTEREST_SUSPENSE
        INTO P_GL_LIST
        FROM COVID_GL_MASTER
       WHERE BLOCK_RECV_PURPOSE = P_PURPOSE_CODE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_GL_LIST := '';
    END GET_GL_LIST;

  END GET_BLK_LOAN_INT_TO_RECV;
  --BLK INT UPDATE:
  PROCEDURE UPD_RECV_BLK_LOAN_INT(P_ENTITY_NUM IN NUMBER,
                                  P_BRN_CODE   IN NUMBER,
                                  P_BATCH_NO   IN NUMBER,
                                  P_TRAN_DATE  IN VARCHAR2,
                                  P_ERR_MSG    OUT VARCHAR2)

   IS
    V_ACC_NUM    NUMBER(14);
    V_ERR_MSG    VARCHAR2(200);
    V_DUE_AMOUNT NUMBER(10, 4);
    V_REF_DESC   VARCHAR2(100);
    W_SQL        VARCHAR2(500);
    V_TRAN_AMT NUMBER(18, 3) := 0;
    V_DUE_AMT_AT_ROW NUMBER(18, 3);
    V_ROWID VARCHAR2(100);

  BEGIN
  V_BATCH_NO :=P_BATCH_NO;
  V_BRN_CODE:=P_BRN_CODE;
  V_TRAN_DATE :=P_TRAN_DATE;
  V_ENTITY_NUM :=P_ENTITY_NUM;

      W_SQL := 'SELECT A.ACBLKCOVIDTRAN_INTERNAL_ACNUM, A.ACBLKCOVIDTRAN_TRAN_AMT, A.BLOCK_INT_RECV_PURPOSE FROM ACBLKCOVIDTRAN A WHERE
             A.ACBLKCOVIDTRAN_ENTITY_NUM = :1 AND A.ACBLKCOVIDTRAN_BRN_CODE = :2 AND A.ACBLKCOVIDTRAN_TRAN_DATE =
             TO_DATE(:3, ''DD-MM-YYYY'') AND A.ACBLKCOVIDTRAN_BATCH_NUMBER =:4 ';

  EXECUTE IMMEDIATE W_SQL BULK COLLECT
    INTO T_AMT_UPD_REC
    USING V_ENTITY_NUM, V_BRN_CODE, V_TRAN_DATE, V_BATCH_NO;

  IF T_AMT_UPD_REC.COUNT > 0 THEN
    V_ACBLK_INTERNAL_ACC := T_AMT_UPD_REC(1).V_ACBLK_INTERNAL_ACC;
    V_TOT_TRAN_AMOUNT    := T_AMT_UPD_REC(1).V_TOT_TRAN_AMOUNT;
    V_ACBLK_PURPOSE      := T_AMT_UPD_REC(1).V_ACBLK_PURPOSE;
  END IF;
  IF (V_ACBLK_PURPOSE = '1') THEN
  UPDATE ACBLKCOVID  SET ACBLK_AMT_RECOVERED = ACBLK_AMT_RECOVERED+V_TOT_TRAN_AMOUNT WHERE ACBLK_ENTITY_NUM = P_ENTITY_NUM AND ACBLK_INTERNAL_ACNUM = V_ACBLK_INTERNAL_ACC;
  ELSIF(V_ACBLK_PURPOSE = '2' OR V_ACBLK_PURPOSE = '3' OR V_ACBLK_PURPOSE = '4' OR V_ACBLK_PURPOSE = '6' OR V_ACBLK_PURPOSE = '7'/*OR V_ACBLK_PURPOSE = '5'*/) THEN

    FOR IDX IN (SELECT ROWID,D.ACNTS_INTERNAL_ACNUM,(D.DEDUCTED_AMT -( D.AMT_RECOVERED+BB_INCENTIVE_RCV)) DUE_AMT_AT_ROW
      FROM DEDUCT_INT D WHERE D.ACNTS_INTERNAL_ACNUM = V_ACBLK_INTERNAL_ACC) LOOP

    V_DUE_AMT_AT_ROW := IDX.DUE_AMT_AT_ROW;
   IF V_TOT_TRAN_AMOUNT >= V_DUE_AMT_AT_ROW THEN
     V_TOT_TRAN_AMOUNT := V_TOT_TRAN_AMOUNT - V_DUE_AMT_AT_ROW;
   ELSE
     V_DUE_AMT_AT_ROW := V_TOT_TRAN_AMOUNT;
     V_TOT_TRAN_AMOUNT:=0;
   END IF;

   UPDATE DEDUCT_INT SET AMT_RECOVERED = AMT_RECOVERED + V_DUE_AMT_AT_ROW
          WHERE ROWID = IDX.ROWID AND ACNTS_INTERNAL_ACNUM = IDX.ACNTS_INTERNAL_ACNUM;
   END LOOP;
  END IF;

    EXCEPTION
      WHEN OTHERS THEN
        V_ERR_MSG := 'Table Updation Failed';
  END UPD_RECV_BLK_LOAN_INT;

  --*******************************************************************************************
    --******************************************************************************************
  PROCEDURE LNACIRECAL_TABLE_UPDATE
  IS
    W_SQL_UPDATE        VARCHAR2(2500);
  BEGIN
    W_SQL_UPDATE :='';

    W_SQL_UPDATE := 'INSERT INTO LOANIAMRRBACK( LOANIAMRR_ENTITY_NUM,LOANIAMRR_BRN_CODE,
                      LOANIAMRR_ACNT_NUM,LOANIAMRR_VALUE_DATE,LOANIAMRR_ACCRUAL_DATE,
                      LOANIAMRR_PREV_ACCR_DATE,LOANIAMRR_ACNT_CURR,LOANIAMRR_ACNT_BAL,
                      LOANIAMRR_TOTAL_NEW_INT_AMT,LOANIAMRR_INT_ON_AMT,LOANIAMRR_OD_PORTION,
                      LOANIAMRR_TOTAL_NEW_OD_INT_AMT,LOANIAMRR_INT_RATE,LOANIAMRR_SLAB_AMT,
                      LOANIAMRR_OD_INT_RATE,LOANIAMRR_LIMIT,LOANIAMRR_DP,LOANIAMRR_INT_AMT,
                      LOANIAMRR_INT_AMT_RND,LOANIAMRR_OD_INT_AMT,LOANIAMRR_OD_INT_AMT_RND,
                      LOANIAMRR_NPA_STATUS,LOANIAMRR_NPA_AMT,LOANIAMRR_NPA_INT_POSTED_AMT,
                      LOANIAMRR_ARR_INT_AMT)
                        SELECT * FROM LOANIAMRR LL WHERE LL.LOANIAMRR_ENTITY_NUM = 1
                        AND( LL.LOANIAMRR_BRN_CODE, LL.LOANIAMRR_ACNT_NUM, LL.LOANIAMRR_VALUE_DATE) IN (
                        SELECT ACNTS_BRN_CODE, L.LOANIAMRR_ACNT_NUM,L.LOANIAMRR_VALUE_DATE
                             FROM LOANIAMRR L, ACNTS A, LNPRODACPM P , LOANACNTS
                         WHERE A.ACNTS_ENTITY_NUM = 1
                           AND P.LNPRDAC_PROD_CODE = A.ACNTS_PROD_CODE
                           AND A.ACNTS_INTERNAL_ACNUM = L.LOANIAMRR_ACNT_NUM
                           AND A.ACNTS_BRN_CODE = L.LOANIAMRR_BRN_CODE
                           AND A.ACNTS_BRN_CODE = ' || W_BRN_CODE ||
                          ' AND A.ACNTS_INTERNAL_ACNUM = ' || W_ACCOUNTNUMBER;

       W_SQL_UPDATE := W_SQL_UPDATE || 'AND L.LOANIAMRR_VALUE_DATE >= '|| CHR(39) || V_RECALC_START_DATE || CHR(39)||
                         'AND LNACNT_ENTITY_NUM = 1
                          AND L.LOANIAMRR_ENTITY_NUM = 1
                          AND ACNTS_CLOSURE_DATE IS NULL
                         AND LNACNT_INTERNAL_ACNUM = L.LOANIAMRR_ACNT_NUM
                         AND L.LOANIAMRR_VALUE_DATE > NVL(LNACNT_INT_APPLIED_UPTO_DATE,A.ACNTS_OPENING_DATE))';

             EXECUTE IMMEDIATE W_SQL_UPDATE;


      W_SQL_UPDATE := '';

      W_SQL_UPDATE := 'DELETE FROM LOANIAMRRDTL WHERE LOANIAMRRDTL_ENTITY_NUM = 1
                     AND( LOANIAMRRDTL_BRN_CODE, LOANIAMRRDTL_ACNT_NUM, LOANIAMRRDTL_VALUE_DATE) IN (
                     SELECT ACNTS_BRN_CODE, L.LOANIAMRR_ACNT_NUM,L.LOANIAMRR_VALUE_DATE
                     FROM LOANIAMRR L, ACNTS A, LNPRODACPM P , LOANACNTS
                     WHERE A.ACNTS_ENTITY_NUM = 1
                     AND P.LNPRDAC_PROD_CODE = A.ACNTS_PROD_CODE
                     AND A.ACNTS_INTERNAL_ACNUM = L.LOANIAMRR_ACNT_NUM
                     AND A.ACNTS_BRN_CODE = L.LOANIAMRR_BRN_CODE
                     AND A.ACNTS_BRN_CODE = ' || W_BRN_CODE ||
                     ' AND A.ACNTS_INTERNAL_ACNUM = ' || W_ACCOUNTNUMBER;
      W_SQL_UPDATE := W_SQL_UPDATE || ' AND L.LOANIAMRR_VALUE_DATE >= ' || CHR(39) || V_RECALC_START_DATE || CHR(39)||
                     ' AND LNACNT_ENTITY_NUM = 1
                      AND L.LOANIAMRR_ENTITY_NUM = 1
                      AND ACNTS_CLOSURE_DATE IS NULL
                     AND LNACNT_INTERNAL_ACNUM = L.LOANIAMRR_ACNT_NUM
                     AND L.LOANIAMRR_VALUE_DATE >  NVL(LNACNT_INT_APPLIED_UPTO_DATE,A.ACNTS_OPENING_DATE))';

     EXECUTE IMMEDIATE W_SQL_UPDATE;

     W_SQL_UPDATE := '';
     W_SQL_UPDATE := 'DELETE FROM LOANIAMRR LL WHERE LL.LOANIAMRR_ENTITY_NUM = 1
                     AND( LL.LOANIAMRR_BRN_CODE, LL.LOANIAMRR_ACNT_NUM, LL.LOANIAMRR_VALUE_DATE) IN (
                     SELECT ACNTS_BRN_CODE, L.LOANIAMRR_ACNT_NUM,L.LOANIAMRR_VALUE_DATE
                      FROM LOANIAMRR L, ACNTS A, LNPRODACPM P , LOANACNTS
                     WHERE A.ACNTS_ENTITY_NUM = 1
                     AND P.LNPRDAC_PROD_CODE = A.ACNTS_PROD_CODE
                     AND A.ACNTS_INTERNAL_ACNUM = L.LOANIAMRR_ACNT_NUM
                     AND A.ACNTS_BRN_CODE = L.LOANIAMRR_BRN_CODE
                     AND A.ACNTS_BRN_CODE = ' || W_BRN_CODE ||
                     ' AND A.ACNTS_INTERNAL_ACNUM = ' || W_ACCOUNTNUMBER;
      W_SQL_UPDATE := W_SQL_UPDATE || ' AND L.LOANIAMRR_VALUE_DATE >= ' || CHR(39) || V_RECALC_START_DATE || CHR(39)||
                      ' AND LNACNT_ENTITY_NUM = 1
                       AND L.LOANIAMRR_ENTITY_NUM = 1
                       AND ACNTS_CLOSURE_DATE IS NULL
                       AND LNACNT_INTERNAL_ACNUM = L.LOANIAMRR_ACNT_NUM
                       AND L.LOANIAMRR_VALUE_DATE > NVL(LNACNT_INT_APPLIED_UPTO_DATE,A.ACNTS_OPENING_DATE))';

     EXECUTE IMMEDIATE W_SQL_UPDATE;


     W_SQL_UPDATE := '';
     W_SQL_UPDATE := 'DELETE FROM LOANIADLY LL WHERE (LL.RTMPLNIA_BRN_CODE, LL.RTMPLNIA_ACNT_NUM, LL.RTMPLNIA_VALUE_DATE) IN (
                      SELECT ACNTS_BRN_CODE, L.RTMPLNIA_ACNT_NUM, L.RTMPLNIA_VALUE_DATE
                           FROM LOANIADLY L, ACNTS A, LNPRODACPM P , LOANACNTS
                      WHERE A.ACNTS_ENTITY_NUM = 1
                      AND P.LNPRDAC_PROD_CODE = A.ACNTS_PROD_CODE
                      AND A.ACNTS_INTERNAL_ACNUM = L.RTMPLNIA_ACNT_NUM
                      AND A.ACNTS_BRN_CODE = L.RTMPLNIA_BRN_CODE
                      AND A.ACNTS_BRN_CODE = ' || W_BRN_CODE ||
                      ' AND A.ACNTS_PROD_CODE = ' || W_ACCOUNTNUMBER;
      W_SQL_UPDATE := W_SQL_UPDATE || ' AND L.RTMPLNIA_VALUE_DATE >= ' || CHR(39) || V_RECALC_START_DATE || CHR(39)||
                     ' AND LNACNT_ENTITY_NUM = 1
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND LNACNT_INTERNAL_ACNUM = L.RTMPLNIA_ACNT_NUM )';

         EXECUTE IMMEDIATE W_SQL_UPDATE;



     W_SQL_UPDATE := '';
     W_SQL_UPDATE := 'UPDATE LOANACNTS
                SET LNACNT_RTMP_ACCURED_UPTO = NULL, LNACNT_RTMP_PROCESS_DATE = NULL
               WHERE LNACNT_ENTITY_NUM = 1
                     AND LNACNT_INTERNAL_ACNUM IN
              (SELECT A.ACNTS_INTERNAL_ACNUM
                 FROM ACNTS A
                WHERE A.ACNTS_ENTITY_NUM = 1
                      AND A.ACNTS_INTERNAL_ACNUM = ' || W_ACCOUNTNUMBER ||
                      ' AND A.ACNTS_BRN_CODE = ' || W_BRN_CODE ;

      W_SQL_UPDATE := W_SQL_UPDATE || ' AND ACNTS_CLOSURE_DATE IS NULL)';


          EXECUTE IMMEDIATE W_SQL_UPDATE;


  END LNACIRECAL_TABLE_UPDATE;
 --***********************************************************************************
  PROCEDURE AUTOPOST_ARRAY_ASSIGN IS
  BEGIN
      IDX :=0;
      IDX := IDX + 1;
      PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_ACING_BRN_CODE := W_BRN_CODE;
      PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_DB_CR_FLG := 'D';
      PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_AMOUNT := V_AMOUNT;
      PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_CURR_CODE := V_ACNTS_CURR_CODE;
      PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_BASE_CURR_EQ_AMT := V_AMOUNT;
      PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_BASE_CURR_CODE := PKG_PB_GLOBAL.FN_GET_INS_BASE_CURR(V_GLOB_ENTITY_NUM);

      IF TRIM(V_INCOME_GL) IS NULL THEN
        W_ERR_MSG := 'Accounting Parameter Not Defined - Prod Code = ' ||
                     V_ACNTS_PROD_CODE || '  ' || ' Curr Code = ' || V_ACNTS_CURR_CODE;
        RAISE E_USEREXCEP;
      ELSE
        PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_GLACC_CODE := V_INCOME_GL;
      END IF;

      IDX := IDX + 1;
      PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_ACING_BRN_CODE := W_BRN_CODE;
      PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_DB_CR_FLG := 'C';
      PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_AMOUNT := V_AMOUNT;
      PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_CURR_CODE := V_ACNTS_CURR_CODE;
      PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_BASE_CURR_EQ_AMT := V_AMOUNT;
      PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_BASE_CURR_CODE := PKG_PB_GLOBAL.FN_GET_INS_BASE_CURR(V_GLOB_ENTITY_NUM);

      IF TRIM(V_ACR_GL) IS NULL THEN
        W_ERR_MSG := 'Accounting Parameter Not Defined - Prod Code = ' ||
                     V_ACNTS_PROD_CODE || '  ' || ' Curr Code = ' || V_ACNTS_CURR_CODE;
        RAISE E_USEREXCEP;
      ELSE
        PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_GLACC_CODE := V_ACR_GL;
      END IF;

  END AUTOPOST_ARRAY_ASSIGN;
  --*******************************************************************************
  PROCEDURE INITILIZE_TRANSACTION
  IS
  BEGIN
    PKG_AUTOPOST.pv_userid := W_USER_ID;
    PKG_AUTOPOST.PV_BOPAUTHQ_REQ := FALSE;
    PKG_AUTOPOST.PV_AUTH_DTLS_UPDATE_REQ := FALSE;
    PKG_AUTOPOST.PV_CALLED_BY_EOD_SOD := 0;
    PKG_AUTOPOST.PV_EXCEP_CHECK_NOT_REQD := FALSE;
    PKG_AUTOPOST.PV_OVERDRAFT_CHK_REQD := FALSE;
    PKG_AUTOPOST.PV_ALLOW_ZERO_TRANAMT := FALSE;
    PKG_PROCESS_BOPAUTHQ.V_BOPAUTHQ_UPD := FALSE;
    PKG_AUTOPOST.pv_cancel_flag := FALSE;
    PKG_AUTOPOST.pv_post_as_unauth_mod := FALSE;
    PKG_AUTOPOST.pv_clg_batch_closure := FALSE;
    PKG_AUTOPOST.pv_authorized_record_cancel := FALSE;
    PKG_AUTOPOST.PV_BACKDATED_TRAN_REQUIRED := 0;
    PKG_AUTOPOST.PV_CLG_REGN_POSTING := FALSE;
    PKG_AUTOPOST.pv_fresh_batch_sl := FALSE;
    PKG_AUTOPOST.pv_tran_key.Tran_Brn_Code := W_BRN_CODE;
    PKG_AUTOPOST.pv_tran_key.Tran_Date_Of_Tran := W_ASON_DATE;
    PKG_AUTOPOST.pv_tran_key.Tran_Batch_Number := 0;
    PKG_AUTOPOST.pv_tran_key.Tran_Batch_Sl_Num := 0;
    PKG_AUTOPOST.PV_AUTO_AUTHORISE := TRUE;
    --PKG_PB_GLOBAL.G_TERMINAL_ID := '10.10.7.149';
    PKG_POST_INTERFACE.G_BATCH_NUMBER_UPDATE_REQ := FALSE;
    PKG_POST_INTERFACE.G_SRC_TABLE_AUTH_REJ_REQ := FALSE;
    PKG_AUTOPOST.PV_TRAN_ONLY_UNDO := FALSE;
    PKG_AUTOPOST.PV_OCLG_POSTING_FLG := FALSE;
    PKG_POST_INTERFACE.G_IBR_REQUIRED := 0;
    -- PKG_PB_test.G_FORM_NAME := 'ETRAN';
    PKG_POST_INTERFACE.G_PGM_NAME := 'ETRAN';
    PKG_AUTOPOST.PV_USER_ROLE_CODE := '';
    PKG_AUTOPOST.PV_SUPP_TRAN_POST := FALSE;
    PKG_AUTOPOST.PV_FUTURE_TRANSACTION_ALLOWED := FALSE;
    PKG_AUTOPOST.pv_tranbat.TRANBAT_BRN_CODE := W_BRN_CODE;
    PKG_AUTOPOST.pv_tranbat.TRANBAT_DATE_OF_TRAN := W_ASON_DATE;
    PKG_AUTOPOST.pv_tranbat.TRANBAT_BATCH_NUMBER := 0;
    PKG_AUTOPOST.pv_tranbat.TRANBAT_ENTRY_BRN_CODE := W_BRN_CODE;
    PKG_AUTOPOST.pv_tranbat.TRANBAT_WITHDRAW_SLIP := '';
    PKG_AUTOPOST.pv_tranbat.TRANBAT_TOKEN_ISSUED := 0;
    PKG_AUTOPOST.pv_tranbat.TRANBAT_BACKOFF_SYS_CODE := '';
    PKG_AUTOPOST.pv_tranbat.TRANBAT_DEVICE_CODE := '';
    PKG_AUTOPOST.pv_tranbat.TRANBAT_DEVICE_UNIT_NUM := '';
    PKG_AUTOPOST.pv_tranbat.TRANBAT_CHANNEL_DT_TIME := NULL;
    PKG_AUTOPOST.pv_tranbat.TRANBAT_CHANNEL_UNIQ_NUM := '';
    PKG_AUTOPOST.pv_tranbat.TRANBAT_COST_CNTR_CODE := '';
    PKG_AUTOPOST.pv_tranbat.TRANBAT_SUB_COST_CNTR := '';
    PKG_AUTOPOST.pv_tranbat.TRANBAT_PROFIT_CNTR_CODE := '';
    PKG_AUTOPOST.pv_tranbat.TRANBAT_SUB_PROFIT_CNTR := '';
    PKG_AUTOPOST.pv_tranbat.TRANBAT_NUM_TRANS := 0;
    PKG_AUTOPOST.pv_tranbat.TRANBAT_BASE_CURR_TOT_CR := 0.0;
    PKG_AUTOPOST.pv_tranbat.TRANBAT_BASE_CURR_TOT_DB := 0.0;
    PKG_AUTOPOST.pv_tranbat.TRANBAT_CANCEL_BY := '';
    PKG_AUTOPOST.pv_tranbat.TRANBAT_CANCEL_ON := NULL;
    PKG_AUTOPOST.pv_tranbat.TRANBAT_CANCEL_REM1 := '';
    PKG_AUTOPOST.pv_tranbat.TRANBAT_CANCEL_REM2 := '';
    PKG_AUTOPOST.pv_tranbat.TRANBAT_CANCEL_REM3 := '';
    PKG_AUTOPOST.pv_tranbat.TRANBAT_SOURCE_TABLE := 'TRAN';
    PKG_AUTOPOST.pv_tranbat.TRANBAT_SOURCE_KEY :=W_BRN_CODE;
    PKG_AUTOPOST.pv_tranbat.TRANBAT_NARR_DTL1 := 'Int Recalculation for specific acc';
    PKG_AUTOPOST.pv_tranbat.TRANBAT_NARR_DTL2 := '';
    PKG_AUTOPOST.pv_tranbat.TRANBAT_NARR_DTL3 := '';
    PKG_AUTOPOST.pv_tranbat.TRANBAT_AUTH_BY := W_USER_ID;
    PKG_AUTOPOST.pv_tranbat.TRANBAT_AUTH_ON := NULL;
    PKG_AUTOPOST.pv_tranbat.TRANBAT_SHIFT_TO_TRAN_DATE := NULL;
    PKG_AUTOPOST.pv_tranbat.TRANBAT_SHIFT_TO_BAT_NUM := 0;
    PKG_AUTOPOST.pv_tranbat.TRANBAT_SHIFT_FROM_TRAN_DATE := NULL;
    PKG_AUTOPOST.pv_tranbat.TRANBAT_SHIFT_FROM_BAT_NUM := 0;
    PKG_AUTOPOST.pv_tranbat.TRANBAT_REV_TO_TRAN_DATE := NULL;
    PKG_AUTOPOST.pv_tranbat.TRANBAT_REV_TO_BAT_NUM := 0;
    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_REV_FROM_TRAN_DATE := NULL;
    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_REV_FROM_BAT_NUM := 0;
  END INITILIZE_TRANSACTION;
  --*******************************************************************************
  PROCEDURE SET_TRAN_KEY_VALUES
  IS
  BEGIN
  --  PKG_AUTOPOST.PV_SYSTEM_POSTED_TRANSACTION := TRUE;
    PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BRN_CODE := W_BRN_CODE;
    PKG_AUTOPOST.PV_TRAN_KEY.TRAN_DATE_OF_TRAN := W_ASON_DATE;
    PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_NUMBER := 0;
    PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_SL_NUM := 0;
    EXCEPTION
    WHEN OTHERS
    THEN
     W_ERROR := 'Fail to re-calculate the interest';
  END SET_TRAN_KEY_VALUES;
--**********************************************************************************
  PROCEDURE SET_TRANBAT_VALUES
  IS
  BEGIN
    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_TABLE := 'TRAN';
    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_KEY := W_BRN_CODE;
    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL1 := 'Int Recalculation for specific acc';
    EXCEPTION
    WHEN OTHERS
    THEN
     W_ERROR := 'Fail to re-calculate the interest';
  END SET_TRANBAT_VALUES;

 --**************************************************************************************
  PROCEDURE POST_PARA IS
  BEGIN

    SET_TRAN_KEY_VALUES;
    SET_TRANBAT_VALUES;
    AUTOPOST_ARRAY_ASSIGN;
    PKG_PB_AUTOPOST.G_FORM_NAME := 'ETRAN';
    INITILIZE_TRANSACTION;
    PKG_POST_INTERFACE.SP_AUTOPOSTTRAN(V_GLOB_ENTITY_NUM,
                                     'A',
                                     IDX,
                                     0,
                                     0,
                                     0,
                                     0,
                                     'N',
                                     W_ERR_CODE,
                                     W_ERROR,
                                     W_BATCH_NUMBER);
/*    PKG_APOST_INTERFACE.SP_POST_SODEOD_BATCH(V_GLOB_ENTITY_NUM,
                                             'A',
                                             IDX,
                                             IDX1,
                                             W_ERR_CODE,
                                             W_ERROR,
                                             W_BATCH_NUMBER);*/
    IF (W_ERR_CODE <> '0000') THEN
      W_ERROR := 'Fail to re-calculate the interest';
    END IF;

    IDX        := 0;
    IDX1       := 0;
    TMP_COUNT  := 0;
    TMP_COUNT1 := 0;
    PKG_APOST_INTERFACE.SP_POSTING_END(V_GLOB_ENTITY_NUM);
  END POST_PARA;

  --************************************************************************************************
  PROCEDURE UPDATE_LNACIRECAL_INDV_ACC(V_ENTITY_NUM IN NUMBER,
                                       V_ENTD_BY    IN VARCHAR2,
                                       P_BRN_CODE IN NUMBER,
                                       P_AC_NUM IN VARCHAR2,
                                       P_PROD_CODE IN NUMBER,
                                       P_CUR_CODE IN VARCHAR2,
                                       P_AC_OPEN_DATE DATE,
                                       P_RECALC_FROM_DT IN DATE,
                                       P_ERROR_MSG OUT VARCHAR2) IS

    W_SQL               VARCHAR2(2500);
  BEGIN
    W_ERROR               := '';
    W_SQL                 := '';
    IDX                   := 0;
    IDX1                  := 0;
    W_ERR_CODE            := '';
    W_BATCH_NUMBER        := 0;
    W_USER_ID             := V_ENTD_BY;
    V_ACTUAL_ACNUM        := P_AC_NUM;
    V_GLOB_ENTITY_NUM     := V_ENTITY_NUM;
    W_ASON_DATE           := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE(V_GLOB_ENTITY_NUM);
    V_RECALC_START_DATE   := P_RECALC_FROM_DT;
    W_BRN_CODE            := P_BRN_CODE;
    V_ACNTS_PROD_CODE     := P_PROD_CODE;
    V_ACNTS_CURR_CODE     := P_CUR_CODE;
    V_ACNTS_OPENING_DATE  := P_AC_OPEN_DATE;

    W_SQL := 'SELECT I.IACLINK_INTERNAL_ACNUM, SUM(ABS(L.LOANIAMRR_INT_AMT_RND)) AC_AMOUNT
                FROM LOANIAMRR L, LOANACNTS, IACLINK I
                 WHERE LNACNT_ENTITY_NUM = 1
                 AND I.IACLINK_ENTITY_NUM = 1
                 AND L.LOANIAMRR_ENTITY_NUM = 1
                 AND L.LOANIAMRR_NPA_STATUS = 0
                 AND I.IACLINK_INTERNAL_ACNUM = LNACNT_INTERNAL_ACNUM
                 AND I.IACLINK_INTERNAL_ACNUM = L.LOANIAMRR_ACNT_NUM
                 AND L.LOANIAMRR_VALUE_DATE > NVL(LNACNT_INT_APPLIED_UPTO_DATE,' ||CHR(39)|| V_ACNTS_OPENING_DATE ||CHR(39)|| ')' ||
               ' AND I.IACLINK_ACTUAL_ACNUM = ' ||V_ACTUAL_ACNUM ||
               ' AND L.LOANIAMRR_BRN_CODE = ' || W_BRN_CODE ||
               ' AND L.LOANIAMRR_VALUE_DATE >= ' ||CHR(39)|| V_RECALC_START_DATE ||CHR(39)||
               ' GROUP BY I.IACLINK_INTERNAL_ACNUM
                 HAVING SUM(ABS(L.LOANIAMRR_INT_AMT_RND)) > 0';

   BEGIN
   EXECUTE IMMEDIATE W_SQL
   INTO W_ACCOUNTNUMBER,V_AMOUNT;


    SELECT LNPRDAC_INT_INCOME_GL,
           LNPRDAC_INT_ACCR_GL
    INTO   V_INCOME_GL,V_ACR_GL
    FROM LNPRODACPM
    WHERE LNPRDAC_PROD_CODE = V_ACNTS_PROD_CODE
    AND   LNPRDAC_CURR_CODE = V_ACNTS_CURR_CODE;


    EXCEPTION WHEN NO_DATA_FOUND
      THEN  W_ACCOUNTNUMBER    := 0;
            V_AMOUNT           := 0;

    END;

     IF(V_AMOUNT > 0) THEN
      POST_PARA;
     END IF;
     IF TRIM(W_ERROR) IS NOT NULL THEN
       P_ERROR_MSG := W_ERROR;
       RETURN;
     END IF;
     IF (W_ERR_CODE = '0000' OR W_ERR_CODE IS NULL) THEN
       LNACIRECAL_TABLE_UPDATE;
     END IF;
  END UPDATE_LNACIRECAL_INDV_ACC;
  --*********************************************************************************************

END PKG_LN_UTILITY;
/
