

CREATE OR REPLACE PACKAGE PKG_ATM_CHARGE IS

  PROCEDURE SP_START_BRNWISE(V_ENTITY_NUM IN NUMBER,
                          P_BRN_CODE IN NUMBER DEFAULT 0);

END PKG_ATM_CHARGE;
/

CREATE OR REPLACE PACKAGE BODY PKG_ATM_CHARGE IS

  E_MY_EXCEPTION EXCEPTION;
  W_ERROR_MSG        VARCHAR2(1000);
  W_ENTITY_CODE      NUMBER;
  W_ASON_DATE        DATE;
  W_USER_BRANCH      USERS.USER_BRANCH_CODE%TYPE;
  W_USER_ID          USERS.USER_ID%TYPE;
  W_FROM_DATE        DATE;
  W_UPTO_DATE        DATE;
  W_TOTAL_CHARGE_AMT NUMBER := 0;
  W_TOTAL_VAT_AMT    NUMBER := 0;
  W_AC_CHARGE_AMT    NUMBER := 0;
  W_AC_VAT_AMT       NUMBER := 0;
  W_PKG_VAT_AMT      NUMBER := 0;
  W_BRN_CODE         NUMBER;
  W_BATCH_NUM        NUMBER;
  W_POST_ARRAY_INDEX NUMBER := 0;
  W_LOAN_IDX         NUMBER := 0;
  W_SQL_DATA         CLOB;
  W_CHARGE_INDEX     NUMBER := 0;
  W_AC_BALANCE       NUMBER(18, 3);
  V_DUMMY_N          NUMBER(18, 3);
  V_DUMMY_C          CHAR(1);
  V_DUMMY_C2         CHAR(3);
  V_DUMMY_D          DATE;
  V_ERR_MSG          VARCHAR2(100);
  W_INTERNAL_ACNUM   ACNTS.ACNTS_INTERNAL_ACNUM%TYPE;
  W_AC_TRAN_NARATION VARCHAR2(100);

  W_AC_BRN_CHARGE_GL EXTGL.EXTGL_ACCESS_CODE%TYPE;
  W_AC_BRN_VAT_GL    EXTGL.EXTGL_ACCESS_CODE%TYPE;
  --  W_IBR_CHARGE_GL     EXTGL.EXTGL_ACCESS_CODE%TYPE;
  W_IBR_VAT_GL EXTGL.EXTGL_ACCESS_CODE%TYPE;
  --  W_IBR_GL_CODE       EXTGL.EXTGL_ACCESS_CODE%TYPE;
  W_IBR_CHARGE_AC NUMBER(14);

  --V_CHGCD_CHG_TYPE        CHGCD.CHGCD_CHG_TYPE%TYPE;
  V_CHGCD_GLACCESS_CD   CHGCD.CHGCD_STAT_TYPE%TYPE;
  V_STAX_RCVD_HEAD      STAXACPM.STAXACPM_STAX_RCVD_HEAD%TYPE;
  V_CHGCD_CHG_CURR_CODE VARCHAR2(3) := 'BDT';

  --charge heads, edite by mahamud
  W_BRN_CODE_ITCL    ATM_MAINT_CHRG_ACC.BRN_CODE_ITCL%TYPE;
  W_ACNUM_ITCL       ATM_MAINT_CHRG_ACC.ACNUM_ITCL%TYPE;
  W_BRANCH_PRONOD_GL ATM_MAINT_CHRG_ACC.BRANCH_PRONOD_GL%TYPE;
  W_INCOME_HEAD      ATM_MAINT_CHRG_ACC.INCOME_HEAD%TYPE;
  W_TAX_REC_HEAD     ATM_MAINT_CHRG_ACC.TAX_REC_HEAD%TYPE;
  ----------------------

  TYPE TT_ATMCHARGE_ENTITY_NUM IS TABLE OF NUMBER(4) INDEX BY PLS_INTEGER;
  TYPE TT_ATMCHARGE_BRN_CODE IS TABLE OF NUMBER(6) INDEX BY PLS_INTEGER;
  TYPE TT_ATMCHARGE_INTERNAL_ACNUM IS TABLE OF NUMBER(14) INDEX BY PLS_INTEGER;
  TYPE TT_ATMCHARGE_PROCESS_DATE IS TABLE OF DATE INDEX BY PLS_INTEGER;
  TYPE TT_ATMCHARGE_FIN_YEAR IS TABLE OF NUMBER(4) INDEX BY PLS_INTEGER;
  TYPE TT_ATMCHARGE_CHARGE_AMT IS TABLE OF NUMBER(18, 3) INDEX BY PLS_INTEGER;
  TYPE TT_ATMCHARGE_VAT_AMT IS TABLE OF NUMBER(18, 3) INDEX BY PLS_INTEGER;
  TYPE TT_ATMCHARGE_ENTD_BY IS TABLE OF VARCHAR2(8) INDEX BY PLS_INTEGER;
  TYPE TT_ATMCHARGE_ENTD_ON IS TABLE OF DATE INDEX BY PLS_INTEGER;
  TYPE TT_ATMCHARGE_AUTH_BY IS TABLE OF VARCHAR2(8) INDEX BY PLS_INTEGER;
  TYPE TT_ATMCHARGE_AUTH_ON IS TABLE OF DATE INDEX BY PLS_INTEGER;

  T_ATMCHARGE_ENTITY_NUM     TT_ATMCHARGE_ENTITY_NUM;
  T_ATMCHARGE_BRN_CODE       TT_ATMCHARGE_BRN_CODE;
  T_ATMCHARGE_INTERNAL_ACNUM TT_ATMCHARGE_INTERNAL_ACNUM;
  T_ATMCHARGE_PROCESS_DATE   TT_ATMCHARGE_PROCESS_DATE;
  T_ATMCHARGE_FIN_YEAR       TT_ATMCHARGE_FIN_YEAR;
  T_ATMCHARGE_CHARGE_AMT     TT_ATMCHARGE_CHARGE_AMT;
  T_ATMCHARGE_VAT_AMT        TT_ATMCHARGE_VAT_AMT;
  T_ATMCHARGE_ENTD_BY        TT_ATMCHARGE_ENTD_BY;
  T_ATMCHARGE_ENTD_ON        TT_ATMCHARGE_ENTD_ON;
  T_ATMCHARGE_AUTH_BY        TT_ATMCHARGE_AUTH_BY;
  T_ATMCHARGE_AUTH_ON        TT_ATMCHARGE_AUTH_ON;

  W_SETTLE_BRANCH NUMBER;
  -- W_SETTLE_BRANCH_RAT NUMBER;

  W_SETTLE_BRN_CHARGE_AMT NUMBER := 0;
  --W_SETTLE_BRN_VAT_AMT      NUMBER := 0;

  W_BRN_CHARGE_AMT NUMBER := 0;
  -- W_BRN_VAT_AMT      NUMBER := 0;

  W_TOTAL_BRN_CHARGE_AMT NUMBER := 0;
  W_TOTAL_ITCL_COM_AMT   NUMBER := 0;
  W_TOTAL_BRN_INCEN_AMT  NUMBER := 0;

  W_LOAN_ACNTS NUMBER := 0;

  W_ACNTS_CURR_CODE ACNTS.ACNTS_CURR_CODE%TYPE;

  W_IBACPM_IBR_HEAD_DB IBACPM.IBACPM_IBR_HEAD_DB%TYPE;
  W_IBACPM_IBR_HEAD_CR IBACPM.IBACPM_IBR_HEAD_DB%TYPE;

  W_AC_BNK_COMMISION_AMT NUMBER;
  W_AC_ITCL_COMISION_AMT NUMBER;
  W_AC_INCENTIVE_AMT     NUMBER;
  W_AC_VAT_CHRG_AMT      NUMBER;

  W_AC_BNK_COMMISION_PERC NUMBER;
  W_AC_ITCL_COMISION_PERC NUMBER;
  W_AC_INCENTIVE_PERC     NUMBER;
  W_ACNT_CHARGE_AMOUNT    NUMBER;

  --W_AC_VAR_CHRG_AMT NUMBER;

  TYPE REC_ACNTS IS RECORD(
    ACNTS_ENTITY_NUM         ACNTS.ACNTS_ENTITY_NUM%TYPE,
    ACNTS_INTERNAL_ACNUM     ACNTS.ACNTS_INTERNAL_ACNUM%TYPE,
    ACNTS_BRN_CODE           ACNTS.ACNTS_BRN_CODE%TYPE,
    ACNTS_CURR_CODE          ACNTS.ACNTS_CURR_CODE%TYPE,
    ACNTBAL_AC_BAL           ACNTBAL.ACNTBAL_AC_BAL%TYPE,
    ACNTBAL_BC_BAL           ACNTBAL.ACNTBAL_BC_BAL%TYPE,
    PRODUCT_FOR_DEPOSITS     PRODUCTS.PRODUCT_FOR_DEPOSITS%TYPE,
    PRODUCT_FOR_LOANS        PRODUCTS.PRODUCT_FOR_LOANS%TYPE,
    PRODUCT_CONTRACT_ALLOWED PRODUCTS.PRODUCT_CONTRACT_ALLOWED%TYPE,
    PRODUCT_FOR_RUN_ACS      PRODUCTS.PRODUCT_FOR_RUN_ACS%TYPE,
    ATM_CARD_TYPE            ATM_CHRG_MAST.ATM_BIN%TYPE,
    ATM_CHRG_CODE            ATM_CHRG_MAST.ATM_CHRG_CODE%TYPE,
    BANK_PORTION_TP          ATM_CHRG_MAST.BANK_PORTION_TP%TYPE,
    ITCL_PORTION_TP          ATM_CHRG_MAST.ITCL_PORTION_TP%TYPE,
    PRONOD_PORTION_TP        ATM_CHRG_MAST.PRONOD_PORTION_TP%TYPE,
    CHGCD_CHG_TYPE           CHGCD.CHGCD_CHG_TYPE%TYPE,
    CIFISS_ISS_TYPE          CIFISS.CIFISS_ISS_TYPE%TYPE,
    CIFISS_ISS_DATE          CIFISS.CIFISS_ISS_DATE%TYPE);
  TYPE TT_ACNTS IS TABLE OF REC_ACNTS INDEX BY PLS_INTEGER;

  T_ACNTS TT_ACNTS;
  -----------------------------------------------------------------------------------
  PROCEDURE SP_GET_STAXACPM_INFO IS
  BEGIN
    SELECT DECODE(CHGCD_STAT_ALLOWED_FLG,
                  1,
                  CHGCD_STAT_TYPE,
                  0,
                  CHGCD_DB_REFUND_HEAD) CHGCD_GLACCESS_CD,
           STAXACPM_STAX_RCVD_HEAD
      into V_CHGCD_GLACCESS_CD, V_STAX_RCVD_HEAD
      FROM CHGCD C, STAXACPM V
     WHERE C.CHGCD_CHARGE_CODE = 'ASC'
       AND C.CHGCD_SERVICE_TAX_CODE = V.STAXACPM_TAX_CODE;

    --  SELECT V.STAXACPM_STAX_RCVD_HEAD INTO V_STAX_RCVD_HEAD FROM STAXACPM V WHERE V.STAXACPM_TAX_CODE='VAT';

    --  SELECT   DECODE (CHGCD_STAT_ALLOWED_FLG, 1, CHGCD_STAT_TYPE, 0, CHGCD_DB_REFUND_HEAD)   CHGCD_GLACCESS_CD, STAXACPM_STAX_RCVD_HEAD INTO V_CHGCD_GLACCESS_CD, V_STAX_RCVD_HEAD FROM  CHGCD C, STAXACPM V   WHERE C.CHGCD_CHARGE_CODE = 'ASC'  AND  C.CHGCD_CHG_CURR_CODE = 'BDT'  AND  C.CHGCD_SERVICE_TAX_CODE=V.STAXACPM_TAX_CODE ;

  END SP_GET_STAXACPM_INFO;
  -------------------------------------------------------------------------------------------
  -----------------Inserting charge head, edited by mahamud
  PROCEDURE SP_GET_GHARGE_HEAD IS
  BEGIN
    SELECT M.BRN_CODE_ITCL,
           M.ACNUM_ITCL,
           M.BRANCH_PRONOD_GL,
           M.INCOME_HEAD,
           M.TAX_REC_HEAD
      into W_BRN_CODE_ITCL,
           W_ACNUM_ITCL,
           W_BRANCH_PRONOD_GL,
           W_INCOME_HEAD,
           W_TAX_REC_HEAD
      FROM ATM_MAINT_CHRG_ACC M;

  END SP_GET_GHARGE_HEAD;
  ----------------------------------------------
  PROCEDURE SP_CHARGE_DATA_INSERT IS
  BEGIN
    FORALL IND IN T_ATMCHARGE_ENTITY_NUM.FIRST .. T_ATMCHARGE_ENTITY_NUM.LAST
      INSERT INTO ATM_CHG_REC
        (ATM_CHG_REC_ENTITY_NUM,
         ATM_CHG_REC_BRN_CODE,
         ATM_CHG_REC_INTERNAL_ACNUM,
         ATM_CHG_REC_PROCESS_DATE,
         ATM_CHG_REC_FIN_YEAR,
         ATM_CHG_REC_CHARGE_AMT,
         ATM_CHG_REC_VAT_AMT,
         ATM_CHG_REC_POST_TRAN_BRN,
         ATM_CHG_REC_POST_TRAN_DATE,
         ATM_CHG_REC_TRAN_BATCH_NUM,
         ATM_CHG_REC_ENTD_BY,
         ATM_CHG_REC_ENTD_ON,
         ATM_CHG_REC_AUTH_BY,
         ATM_CHG_REC_AUTH_ON)
      VALUES
        (T_ATMCHARGE_ENTITY_NUM(IND),
         T_ATMCHARGE_BRN_CODE(IND),
         T_ATMCHARGE_INTERNAL_ACNUM(IND),
         T_ATMCHARGE_PROCESS_DATE(IND),
         T_ATMCHARGE_FIN_YEAR(IND),
         T_ATMCHARGE_CHARGE_AMT(IND),
         T_ATMCHARGE_VAT_AMT(IND),
         T_ATMCHARGE_BRN_CODE(IND),
         W_ASON_DATE,
         W_BATCH_NUM,
         T_ATMCHARGE_ENTD_BY(IND),
         T_ATMCHARGE_ENTD_ON(IND),
         T_ATMCHARGE_AUTH_BY(IND),
         T_ATMCHARGE_AUTH_ON(IND));

    T_ATMCHARGE_ENTITY_NUM .DELETE;
    T_ATMCHARGE_BRN_CODE .DELETE;
    T_ATMCHARGE_INTERNAL_ACNUM.DELETE;
    T_ATMCHARGE_PROCESS_DATE .DELETE;
    T_ATMCHARGE_FIN_YEAR .DELETE;
    T_ATMCHARGE_CHARGE_AMT .DELETE;
    T_ATMCHARGE_VAT_AMT .DELETE;
    T_ATMCHARGE_ENTD_BY .DELETE;
    T_ATMCHARGE_ENTD_ON .DELETE;
    T_ATMCHARGE_AUTH_BY .DELETE;
    T_ATMCHARGE_AUTH_ON .DELETE;
  END;

  -------------------------------------------------------------------------------------------

  PROCEDURE SP_MOVE_CHARGE_TABLE(P_ENTITY_NUM     NUMBER,
                                 P_BRN_CODE       NUMBER,
                                 P_INTERNAL_ACNUM NUMBER,
                                 P_PROCESS_DATE   DATE,
                                 P_CHARGE_AMT     NUMBER,
                                 P_VAT_AMT        NUMBER,
                                 P_USER_ID        VARCHAR2) IS
  BEGIN
    W_CHARGE_INDEX := W_CHARGE_INDEX + 1;

    T_ATMCHARGE_ENTITY_NUM(W_CHARGE_INDEX) := P_ENTITY_NUM;
    T_ATMCHARGE_BRN_CODE(W_CHARGE_INDEX) := P_BRN_CODE;
    T_ATMCHARGE_INTERNAL_ACNUM(W_CHARGE_INDEX) := P_INTERNAL_ACNUM;
    T_ATMCHARGE_PROCESS_DATE(W_CHARGE_INDEX) := P_PROCESS_DATE;
    T_ATMCHARGE_FIN_YEAR(W_CHARGE_INDEX) := TO_NUMBER(TO_CHAR(P_PROCESS_DATE,
                                                              'YYYY'));
    T_ATMCHARGE_CHARGE_AMT(W_CHARGE_INDEX) := P_CHARGE_AMT;
    T_ATMCHARGE_VAT_AMT(W_CHARGE_INDEX) := P_VAT_AMT;
    T_ATMCHARGE_ENTD_BY(W_CHARGE_INDEX) := P_USER_ID;
    T_ATMCHARGE_ENTD_ON(W_CHARGE_INDEX) := SYSDATE;
    T_ATMCHARGE_AUTH_BY(W_CHARGE_INDEX) := P_USER_ID;
    T_ATMCHARGE_AUTH_ON(W_CHARGE_INDEX) := SYSDATE;
  END;

  -----------------------------------------------------------------------------------------

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
    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_TABLE := 'ATM_CHG_REC';
    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_KEY   := P_TRAN_BRN_CODE;
    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL1    := 'ATM Charge';

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
      /*need to disable during testing*/

      PKG_APOST_INTERFACE.SP_POST_SODEOD_BATCH(W_ENTITY_CODE,
                                               'A',
                                               W_POST_ARRAY_INDEX,
                                               0,
                                               V_AUTOPOST_ERRCD,
                                               V_AUTOPOST_ERRM,
                                               W_BATCH_NUM);

      -----------------------End of Block-------------------------
      /* need to enable during testing*/
      /*
        PKG_APOST_INTERFACE.SP_POST_AUTO_AUTHORIZED(W_ENTITY_CODE,
                                                    'A',
                                                    W_POST_ARRAY_INDEX,
                                                    0,
                                                    V_AUTOPOST_ERRCD,
                                                    V_AUTOPOST_ERRM,
                                                    W_BATCH_NUM);
      */
      ---------------------------End of Block-----------------------------

      W_POST_ARRAY_INDEX := 0;
      W_LOAN_IDX         := 0;
      PKG_AUTOPOST.PV_TRAN_REC.DELETE;

      IF (V_AUTOPOST_ERRCD <> '0000') THEN
        W_ERROR_MSG := SUBSTR('ERROR IN POST_TRANSACTION For ATM Charge-  ' ||
                              W_BRN_CODE || ' ' || V_AUTOPOST_ERRCD ||
                              V_AUTOPOST_ERRM ||
                              FN_GET_AUTOPOST_ERR_MSG(W_ENTITY_CODE),
                              1,
                              1000);
        RAISE E_MY_EXCEPTION;
      ELSE
        SP_CHARGE_DATA_INSERT;
        W_LOAN_IDX := 0;
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
    W_TOTAL_BRN_CHARGE_AMT  := 0;
    W_TOTAL_ITCL_COM_AMT    := 0;
    W_TOTAL_BRN_INCEN_AMT   := 0;

    W_BATCH_NUM := NULL;
  END;

  PROCEDURE SP_ATM_CHARGE_PROC(P_ENTITY_NUM IN NUMBER,
                               P_BRN_CODE   IN NUMBER) IS
    V_NEW_AC_VAT        NUMBER;
    V_NEW_AC_CHARGE_AMT NUMBER;
    V_PBDCONT_CONT_NUM  NUMBER;
  BEGIN
    W_SQL_DATA := 'SELECT A.ACNTS_ENTITY_NUM,
                       A.ACNTS_INTERNAL_ACNUM,
                       A.ACNTS_BRN_CODE,
                       A.ACNTS_CURR_CODE,
                       B.ACNTBAL_AC_BAL,
                       B.ACNTBAL_BC_BAL,
                       P.PRODUCT_FOR_DEPOSITS,
                       P.PRODUCT_FOR_LOANS,
                       P.PRODUCT_CONTRACT_ALLOWED,
                       P.PRODUCT_FOR_RUN_ACS,
                       C.ATM_BIN,
                       C.ATM_CHRG_CODE,
                       C.BANK_PORTION_TP,
                       C.ITCL_PORTION_TP,
                       C.PRONOD_PORTION_TP,
                       CC.CHGCD_CHG_TYPE,
                       S.CIFISS_ISS_TYPE,
                       S.CIFISS_ISS_DATE
                  FROM CIFISS S,
                       ACNTS A,
                       ACNTBAL B,
                       IACLINK I,
                       PRODUCTS P,
                       ATM_CHRG_MAST C,
                       CHGCD CC
                 WHERE  C.ATM_CHRG_CODE=CC.CHGCD_CHARGE_CODE
                       AND S.CIFISS_ACC_NUM =  A.ACNTS_INTERNAL_ACNUM
                       AND S.CIFISS_CARD_NUMBER IS NOT NULL
 					   AND S.CIFISS_ISS_DATE BETWEEN ADD_MONTHS(TRUNC(SYSDATE,''MONTH''), -47)  AND LAST_DAY(TRUNC(SYSDATE, ''MONTH''))
                       AND SUBSTR(S.CIFISS_CARD_NUMBER,0,5)=C.ATM_BIN
                       AND I.IACLINK_ENTITY_NUM = A.ACNTS_ENTITY_NUM
                       AND I.IACLINK_INTERNAL_ACNUM = A.ACNTS_INTERNAL_ACNUM
                       AND I.IACLINK_ENTITY_NUM = B.ACNTBAL_ENTITY_NUM
                       AND I.IACLINK_INTERNAL_ACNUM = B.ACNTBAL_INTERNAL_ACNUM
                       AND A.ACNTS_ENTITY_NUM = B.ACNTBAL_ENTITY_NUM
                       AND A.ACNTS_INTERNAL_ACNUM = B.ACNTBAL_INTERNAL_ACNUM
                       AND A.ACNTS_CURR_CODE = B.ACNTBAL_CURR_CODE
                       AND P.PRODUCT_CODE = A.ACNTS_PROD_CODE
                       AND A.ACNTS_ENTITY_NUM =:ENTITY_NUMBER
                       AND I.IACLINK_ENTITY_NUM =:ENTITY_NUMBER
                       AND A.ACNTS_BRN_CODE =:BRANCH_CODE
                       AND B.ACNTBAL_CURR_CODE = :CURR_CODE
                       AND A.ACNTS_CURR_CODE = :CURR_CODE
					   AND A.ACNTS_AC_TYPE <> :AC_TYPE
                       AND ACNTS_INOP_ACNT = 0
                       AND B.ACNTBAL_AC_BAL <> 0
                       AND A.ACNTS_CLOSURE_DATE IS NULL';

    EXECUTE IMMEDIATE W_SQL_DATA BULK COLLECT
      INTO T_ACNTS
      USING P_ENTITY_NUM, P_ENTITY_NUM, P_BRN_CODE, 'BDT', 'BDT','SBSS';

    INIT_VALUES;

    IF T_ACNTS.COUNT > 0 THEN

      BEGIN

        FOR INX IN 1 .. T_ACNTS.COUNT LOOP

          -- W_AC_BALANCE:=T_ACNTS(INX).ACNTBAL_AC_BAL;
          W_AC_BALANCE       := 0;
          W_INTERNAL_ACNUM   := T_ACNTS(INX).ACNTS_INTERNAL_ACNUM;
          V_PBDCONT_CONT_NUM := 0;
          W_LOAN_ACNTS       := 0;
          W_ACNTS_CURR_CODE  := T_ACNTS(INX).ACNTS_CURR_CODE;

          --ATM_CARD_TYPE,CIFISS_ISS_DATE
          IF T_ACNTS(INX).ATM_CARD_TYPE = '70150' AND T_ACNTS(INX).CIFISS_ISS_DATE < ADD_MONTHS(TRUNC(SYSDATE,'MONTH'), -23) THEN
            CONTINUE;
          END IF;
          
          IF  T_ACNTS(INX).CIFISS_ISS_TYPE='C' THEN
            CONTINUE;
          END IF;

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

            W_AC_BNK_COMMISION_AMT := 0;
            W_AC_ITCL_COMISION_AMT := 0;
            W_AC_INCENTIVE_AMT     := 0;
            W_AC_VAT_CHRG_AMT      := 0;
            W_AC_CHARGE_AMT        := 0;
            W_ACNT_CHARGE_AMOUNT   := 0;
            --   V_CHGCD_CHG_CURR_CODE :='BDT';
            --edited by mahamud
            -- ATM_BIN := TRIM(T_ACNTS(INX).ATM_CARD_TYPE);
            PKG_CHARGES.SP_GET_CHARGES(T_ACNTS             (INX)
                                       .ACNTS_ENTITY_NUM,
                                       T_ACNTS             (INX)
                                       .ACNTS_INTERNAL_ACNUM,
                                       T_ACNTS             (INX)
                                       .ACNTS_CURR_CODE,
                                       W_AC_BALANCE,
                                       T_ACNTS             (INX)
                                       .ATM_CHRG_CODE,
                                       T_ACNTS             (INX)
                                       .CHGCD_CHG_TYPE,
                                       W_ACNTS_CURR_CODE,
                                       W_ACNT_CHARGE_AMOUNT,
                                       V_DUMMY_N,
                                       W_PKG_VAT_AMT,
                                       V_DUMMY_N,
                                       V_DUMMY_N,
                                       W_ERROR_MSG);

            W_AC_BNK_COMMISION_PERC := T_ACNTS(INX).BANK_PORTION_TP;
            W_AC_ITCL_COMISION_PERC := T_ACNTS(INX).ITCL_PORTION_TP;
            W_AC_INCENTIVE_PERC     := T_ACNTS(INX).PRONOD_PORTION_TP;
            --This value already coming from above charge package
            -- W_ACNT_CHARGE_AMOUNT    := W_ACNT_CHARGE_AMOUNT;
            --end
            IF W_ACNT_CHARGE_AMOUNT > 0 THEN
              IF (W_AC_BALANCE >= (W_ACNT_CHARGE_AMOUNT + W_PKG_VAT_AMT)) THEN
                W_AC_VAT_CHRG_AMT := W_PKG_VAT_AMT;

                --IF T_ACNTS(INX)
                -- .CIFISS_ISS_DATE < TO_DATE('01-JAN-2018', 'DD-MM-YYYY') THEN
                --  W_AC_BNK_COMMISION_AMT := W_ACNT_CHARGE_AMOUNT;
                --ELSE
                  W_AC_BNK_COMMISION_AMT := ROUND((W_AC_BNK_COMMISION_PERC *
                                                  W_ACNT_CHARGE_AMOUNT) / 100,
                                                  2);
                  W_AC_ITCL_COMISION_AMT := ROUND((W_AC_ITCL_COMISION_PERC *
                                                  W_ACNT_CHARGE_AMOUNT) / 100,
                                                  2);
                  W_AC_INCENTIVE_AMT     := W_ACNT_CHARGE_AMOUNT -
                                            W_AC_BNK_COMMISION_AMT -
                                            W_AC_ITCL_COMISION_AMT;
                --END IF;
                ---------------------------------------------------------

              ELSE
                IF (W_AC_BALANCE > 1) THEN

                  V_NEW_AC_CHARGE_AMT  := W_AC_BALANCE / 1.15;
                  V_NEW_AC_VAT         := CEIL((W_AC_BALANCE -
                                               V_NEW_AC_CHARGE_AMT));
                  W_AC_VAT_CHRG_AMT    := V_NEW_AC_VAT;
                  V_NEW_AC_CHARGE_AMT  := W_AC_BALANCE - V_NEW_AC_VAT;
                  W_ACNT_CHARGE_AMOUNT := V_NEW_AC_CHARGE_AMT;

                  --IF T_ACNTS(INX)
                  -- .CIFISS_ISS_DATE < TO_DATE('01-JAN-2018', 'DD-MM-YYYY') THEN
                  --  W_AC_BNK_COMMISION_AMT := W_ACNT_CHARGE_AMOUNT;
                  --ELSE
                    W_AC_BNK_COMMISION_AMT := ROUND((W_ACNT_CHARGE_AMOUNT *
                                                    W_AC_BNK_COMMISION_PERC) / 100,
                                                    2);
                    W_AC_ITCL_COMISION_AMT := ROUND((W_ACNT_CHARGE_AMOUNT *
                                                    W_AC_ITCL_COMISION_PERC) / 100,
                                                    2);
                    W_AC_INCENTIVE_AMT     := W_ACNT_CHARGE_AMOUNT -
                                              W_AC_BNK_COMMISION_AMT -
                                              W_AC_ITCL_COMISION_AMT;
                  --END IF;

                  IF (W_AC_INCENTIVE_AMT < 0) THEN
                    CONTINUE;
                  END IF;

                
                 

                  IF (W_AC_BALANCE <
                     (W_AC_VAT_CHRG_AMT + W_AC_BNK_COMMISION_AMT +
                     W_AC_ITCL_COMISION_AMT + W_AC_INCENTIVE_AMT)) THEN
                    CONTINUE;
                  END IF;

                ELSE
                  CONTINUE;

                END IF;
              END IF;
			  
			   IF T_ACNTS(INX).CIFISS_ISS_DATE >= TO_DATE('01-JAN-2020', 'DD-MM-YYYY')  AND T_ACNTS(INX).CIFISS_ISS_TYPE='I'  THEN
                          
                           IF  W_AC_ITCL_COMISION_AMT > 110 THEN                     
                             W_AC_BNK_COMMISION_AMT :=W_AC_BNK_COMMISION_AMT + W_AC_ITCL_COMISION_AMT-110;
                             W_AC_ITCL_COMISION_AMT :=110;
                           END IF;
                           IF  W_AC_INCENTIVE_AMT > 10 THEN                     
                             W_AC_BNK_COMMISION_AMT :=W_AC_BNK_COMMISION_AMT + W_AC_INCENTIVE_AMT-10;
                             W_AC_INCENTIVE_AMT :=10;
                           END IF;
                           
               
                   ELSIF T_ACNTS(INX).CIFISS_ISS_DATE >= TO_DATE('01-JAN-2020', 'DD-MM-YYYY') AND T_ACNTS(INX).CIFISS_ISS_TYPE='R' THEN
                           IF  W_AC_ITCL_COMISION_AMT > 120 THEN                     
                             W_AC_BNK_COMMISION_AMT :=W_AC_BNK_COMMISION_AMT + W_AC_ITCL_COMISION_AMT-120;
                             W_AC_ITCL_COMISION_AMT :=120;
                           END IF;
                           IF  W_AC_INCENTIVE_AMT > 0 THEN                     
                             W_AC_BNK_COMMISION_AMT :=W_AC_BNK_COMMISION_AMT + W_AC_INCENTIVE_AMT;
                             W_AC_INCENTIVE_AMT :=0;
                           END IF;
                   ELSE
                        W_AC_BNK_COMMISION_AMT := W_AC_BNK_COMMISION_AMT + W_AC_ITCL_COMISION_AMT +W_AC_INCENTIVE_AMT;   
                        W_AC_ITCL_COMISION_AMT :=0; 
                        W_AC_INCENTIVE_AMT :=0;
                 END IF;
			  
            ELSE
              CONTINUE;
            END IF;

          END;

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

          V_PBDCONT_CONT_NUM := NVL(V_PBDCONT_CONT_NUM, 0);

          -- W_TOTAL_CHARGE_AMT   NUMBER := 0;
          --  W_TOTAL_VAT_AMT      NUMBER := 0;

          W_AC_CHARGE_AMT := W_AC_BNK_COMMISION_AMT +
                             W_AC_ITCL_COMISION_AMT + W_AC_INCENTIVE_AMT;

          W_TOTAL_BRN_CHARGE_AMT := W_TOTAL_BRN_CHARGE_AMT +
                                    W_AC_BNK_COMMISION_AMT;
          W_TOTAL_ITCL_COM_AMT   := W_TOTAL_ITCL_COM_AMT +
                                    W_AC_ITCL_COMISION_AMT;
          W_TOTAL_BRN_INCEN_AMT  := W_TOTAL_BRN_INCEN_AMT +
                                    W_AC_INCENTIVE_AMT;

          W_AC_TRAN_NARATION := 'ATM Yearly Charge';

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

          W_AC_TRAN_NARATION := 'VAT On Charge';

          MOVE_TO_TRAN_REC(P_TRAN_BRN_CODE       => P_BRN_CODE,
                           P_TRAN_ACING_BRN_CODE => P_BRN_CODE,
                           P_TRAN_DATE_OF_TRAN   => W_ASON_DATE,
                           P_TRAN_INTERNAL_ACNUM => W_INTERNAL_ACNUM,
                           P_TRAN_CONTRACT_NUM   => V_PBDCONT_CONT_NUM,
                           P_TRAN_GLACC_CODE     => '0',
                           P_TRAN_DB_CR_FLG      => 'D',
                           P_TRAN_CURR_CODE      => W_ACNTS_CURR_CODE,
                           P_TRAN_AMOUNT         => W_AC_VAT_CHRG_AMT,
                           P_TRAN_VALUE_DATE     => W_ASON_DATE,
                           P_TRAN_NARR_DTL       => W_AC_TRAN_NARATION);

          W_TOTAL_VAT_AMT := W_TOTAL_VAT_AMT + W_AC_VAT_CHRG_AMT;

          SP_MOVE_CHARGE_TABLE(P_ENTITY_NUM     => P_ENTITY_NUM,
                               P_BRN_CODE       => P_BRN_CODE,
                               P_INTERNAL_ACNUM => W_INTERNAL_ACNUM,
                               P_PROCESS_DATE   => W_ASON_DATE,
                               P_CHARGE_AMT     => W_AC_CHARGE_AMT,
                               P_VAT_AMT        => W_AC_VAT_CHRG_AMT,
                               P_USER_ID        => W_USER_ID);

        END LOOP;

        --When Total Branch Charge Amount <=0 -------
        IF W_TOTAL_BRN_CHARGE_AMT <= 0 THEN
          RETURN;
        END IF;
        BEGIN
          SELECT IBACPM_IBR_HEAD_DB, IBACPM_IBR_HEAD_CR
            INTO W_IBACPM_IBR_HEAD_DB, W_IBACPM_IBR_HEAD_CR
            FROM IBACPM
           WHERE IBACPM_ENTITY_NUM = P_ENTITY_NUM
             AND IBACPM_BRN_CODE = P_BRN_CODE
             AND IBACPM_CURR_CODE = 'BDT';
        END;

        W_AC_BRN_CHARGE_GL := V_CHGCD_GLACCESS_CD;
        W_AC_BRN_VAT_GL    := V_STAX_RCVD_HEAD;
        W_IBR_VAT_GL       := V_STAX_RCVD_HEAD;
        W_IBR_CHARGE_AC    := W_ACNUM_ITCL; --V_ATM_ACNUM_ITCL  /*Internal Account Number*/;
        W_SETTLE_BRANCH    := W_BRN_CODE_ITCL; --V_ATM_BRN_CODE_ITCL /*itcl account for atm_chrg_mast itcl acc brn*/;

        V_CHGCD_CHG_CURR_CODE := 'BDT';

        IF W_SETTLE_BRANCH <> P_BRN_CODE THEN

          W_AC_TRAN_NARATION := 'ATM Commission';

          MOVE_TO_TRAN_REC(P_TRAN_BRN_CODE       => P_BRN_CODE,
                           P_TRAN_ACING_BRN_CODE => P_BRN_CODE,
                           P_TRAN_DATE_OF_TRAN   => W_ASON_DATE,
                           P_TRAN_INTERNAL_ACNUM => '0',
                           P_TRAN_CONTRACT_NUM   => '0',
                           P_TRAN_GLACC_CODE     => W_INCOME_HEAD, --V_ATM_INCOME_HEAD /*for atm_chrg_mast income head*/,
                           P_TRAN_DB_CR_FLG      => 'C',
                           P_TRAN_CURR_CODE      => V_CHGCD_CHG_CURR_CODE,
                           P_TRAN_AMOUNT         => W_TOTAL_BRN_CHARGE_AMT,
                           P_TRAN_VALUE_DATE     => W_ASON_DATE,
                           P_TRAN_NARR_DTL       => W_AC_TRAN_NARATION);

          ---------------------When incentive amount greater than zero---------------------
          IF W_TOTAL_BRN_INCEN_AMT > 0 THEN
            W_AC_TRAN_NARATION := 'Branch Incentive';

            MOVE_TO_TRAN_REC(P_TRAN_BRN_CODE       => P_BRN_CODE,
                             P_TRAN_ACING_BRN_CODE => P_BRN_CODE,
                             P_TRAN_DATE_OF_TRAN   => W_ASON_DATE,
                             P_TRAN_INTERNAL_ACNUM => '0',
                             P_TRAN_CONTRACT_NUM   => '0',
                             P_TRAN_GLACC_CODE     => W_BRANCH_PRONOD_GL, --V_ATM_ACNUM_PRONOD_GL/*for atm_chrg_mast BRANCH_PRONOD_GL*/,
                             P_TRAN_DB_CR_FLG      => 'C',
                             P_TRAN_CURR_CODE      => V_CHGCD_CHG_CURR_CODE,

                             P_TRAN_AMOUNT     => W_TOTAL_BRN_INCEN_AMT,
                             P_TRAN_VALUE_DATE => W_ASON_DATE,
                             P_TRAN_NARR_DTL   => W_AC_TRAN_NARATION);
          END IF;
          -----------------------------When commission amount greater than zero-------------
          IF W_TOTAL_ITCL_COM_AMT > 0 THEN
            W_AC_TRAN_NARATION := 'ITCL Commision';
            MOVE_TO_TRAN_REC(P_TRAN_BRN_CODE       => P_BRN_CODE,
                             P_TRAN_ACING_BRN_CODE => W_SETTLE_BRANCH,
                             P_TRAN_DATE_OF_TRAN   => W_ASON_DATE,
                             P_TRAN_INTERNAL_ACNUM => '0',
                             P_TRAN_CONTRACT_NUM   => '0',
                             P_TRAN_GLACC_CODE     => W_IBR_CHARGE_AC,
                             P_TRAN_DB_CR_FLG      => 'C',
                             P_TRAN_CURR_CODE      => V_CHGCD_CHG_CURR_CODE,
                             P_TRAN_AMOUNT         => W_TOTAL_ITCL_COM_AMT,
                             P_TRAN_VALUE_DATE     => W_ASON_DATE,
                             P_TRAN_NARR_DTL       => W_AC_TRAN_NARATION);

            W_AC_TRAN_NARATION := '';
            MOVE_TO_TRAN_REC(P_TRAN_BRN_CODE       => P_BRN_CODE,
                             P_TRAN_ACING_BRN_CODE => W_SETTLE_BRANCH,
                             P_TRAN_DATE_OF_TRAN   => W_ASON_DATE,
                             P_TRAN_INTERNAL_ACNUM => '0',
                             P_TRAN_CONTRACT_NUM   => '0',
                             P_TRAN_GLACC_CODE     => W_IBACPM_IBR_HEAD_DB,
                             P_TRAN_DB_CR_FLG      => 'D',
                             P_TRAN_CURR_CODE      => V_CHGCD_CHG_CURR_CODE,
                             P_TRAN_AMOUNT         => W_TOTAL_ITCL_COM_AMT,
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
                             P_TRAN_AMOUNT         => W_TOTAL_ITCL_COM_AMT,
                             P_TRAN_VALUE_DATE     => W_ASON_DATE,
                             P_TRAN_NARR_DTL       => W_AC_TRAN_NARATION);
          END IF;
          ------------------------------------------------

        ELSE
          --V_ATM_ACNUM_PRONOD_GL,V_ATM_INCOME_HEAD, V_ATM_TAX_REC_HEAD
          W_AC_TRAN_NARATION := 'ATM Commission';

          MOVE_TO_TRAN_REC(P_TRAN_BRN_CODE       => P_BRN_CODE,
                           P_TRAN_ACING_BRN_CODE => P_BRN_CODE,
                           P_TRAN_DATE_OF_TRAN   => W_ASON_DATE,
                           P_TRAN_INTERNAL_ACNUM => '0',
                           P_TRAN_CONTRACT_NUM   => '0',
                           P_TRAN_GLACC_CODE     => W_INCOME_HEAD, --V_ATM_INCOME_HEAD/*for atm_chrg_mast INCOME_HEAD*/,
                           P_TRAN_DB_CR_FLG      => 'C',
                           P_TRAN_CURR_CODE      => V_CHGCD_CHG_CURR_CODE,
                           P_TRAN_AMOUNT         => W_TOTAL_BRN_CHARGE_AMT,
                           P_TRAN_VALUE_DATE     => W_ASON_DATE,
                           P_TRAN_NARR_DTL       => W_AC_TRAN_NARATION);
          IF W_TOTAL_BRN_INCEN_AMT > 0 THEN
            W_AC_TRAN_NARATION := 'Branch Incentive ';
            MOVE_TO_TRAN_REC(P_TRAN_BRN_CODE       => P_BRN_CODE,
                             P_TRAN_ACING_BRN_CODE => P_BRN_CODE,
                             P_TRAN_DATE_OF_TRAN   => W_ASON_DATE,
                             P_TRAN_INTERNAL_ACNUM => '0',
                             P_TRAN_CONTRACT_NUM   => '0',
                             P_TRAN_GLACC_CODE     => W_BRANCH_PRONOD_GL, --V_ATM_ACNUM_PRONOD_GL/*for atm_chrg_mast BRANCH_PRONOD_GL*/,
                             P_TRAN_DB_CR_FLG      => 'C',
                             P_TRAN_CURR_CODE      => V_CHGCD_CHG_CURR_CODE,
                             P_TRAN_AMOUNT         => W_TOTAL_BRN_INCEN_AMT,
                             P_TRAN_VALUE_DATE     => W_ASON_DATE,
                             P_TRAN_NARR_DTL       => W_AC_TRAN_NARATION);
          END IF;
          IF W_TOTAL_ITCL_COM_AMT > 0 THEN
            W_AC_TRAN_NARATION := 'ITCL Commision';
            MOVE_TO_TRAN_REC(P_TRAN_BRN_CODE       => P_BRN_CODE,
                             P_TRAN_ACING_BRN_CODE => W_SETTLE_BRANCH,
                             P_TRAN_DATE_OF_TRAN   => W_ASON_DATE,
                             P_TRAN_INTERNAL_ACNUM => '0',
                             P_TRAN_CONTRACT_NUM   => '0',
                             P_TRAN_GLACC_CODE     => W_IBR_CHARGE_AC,
                             P_TRAN_DB_CR_FLG      => 'C',
                             P_TRAN_CURR_CODE      => V_CHGCD_CHG_CURR_CODE,
                             P_TRAN_AMOUNT         => W_TOTAL_ITCL_COM_AMT,
                             P_TRAN_VALUE_DATE     => W_ASON_DATE,
                             P_TRAN_NARR_DTL       => W_AC_TRAN_NARATION);
          END IF;

        END IF;

        W_AC_TRAN_NARATION := 'VAT Collection ATM';

        MOVE_TO_TRAN_REC(P_TRAN_BRN_CODE       => P_BRN_CODE,
                         P_TRAN_ACING_BRN_CODE => P_BRN_CODE,
                         P_TRAN_DATE_OF_TRAN   => W_ASON_DATE,
                         P_TRAN_INTERNAL_ACNUM => '0',
                         P_TRAN_CONTRACT_NUM   => '0',
                         P_TRAN_GLACC_CODE     => W_TAX_REC_HEAD, --V_ATM_TAX_REC_HEAD/*for atm_chrg_mast TAX_REC_HEAD*/,
                         P_TRAN_DB_CR_FLG      => 'C',
                         P_TRAN_CURR_CODE      => V_CHGCD_CHG_CURR_CODE,
                         P_TRAN_AMOUNT         => W_TOTAL_VAT_AMT,
                         P_TRAN_VALUE_DATE     => W_ASON_DATE,
                         P_TRAN_NARR_DTL       => W_AC_TRAN_NARATION);

        W_TOTAL_VAT_AMT := 0;

        SET_TRAN_KEY_VALUES(P_BRN_CODE, W_ASON_DATE);
        SET_TRANBAT_VALUES(P_BRN_CODE);
        POST_TRANSACTION;

      END;
    END IF;

  END SP_ATM_CHARGE_PROC;

  PROCEDURE SP_START_BRNWISE(V_ENTITY_NUM IN NUMBER,
                             P_BRN_CODE   IN NUMBER DEFAULT 0) IS
    W_BRN_CODE NUMBER(6);
  BEGIN

    W_ENTITY_CODE := V_ENTITY_NUM;
    W_ASON_DATE   := PKG_EODSOD_FLAGS.PV_CURRENT_DATE;
    W_USER_ID     := PKG_EODSOD_FLAGS.PV_USER_ID;
    W_FROM_DATE   := PKG_PB_GLOBAL.SP_GET_FIN_YEAR_START(V_ENTITY_NUM);
    W_UPTO_DATE   := PKG_EODSOD_FLAGS.PV_CURRENT_DATE;
    W_USER_BRANCH := PKG_PB_GLOBAL.FN_GET_USER_BRN_CODE(V_ENTITY_NUM,
                                                        W_USER_ID);

    --for testing purpose
    /*
    W_ENTITY_CODE               := V_ENTITY_NUM;
    PKG_EODSOD_FLAGS.PV_USER_ID := 'INTELECT';
    PKG_AUTOPOST.PV_USERID      := 'INTELECT';
    W_ASON_DATE                 := TO_DATE('23-APR-2017', 'DD-MM-YYYY');
    W_USER_ID                   := 'INTELECT';
    W_FROM_DATE                 := TO_DATE('10-MAY-2016', 'DD-MM-YYYY');
    W_UPTO_DATE                 := TO_DATE('10-MAY-2016', 'DD-MM-YYYY');
    W_USER_BRANCH               := PKG_PB_GLOBAL.FN_GET_USER_BRN_CODE(V_ENTITY_NUM,
                                                                      W_USER_ID);
    */
    -------------------------------End of Block-----------------------------------
    PKG_PROCESS_CHECK.INIT_PROC_BRN_WISE(W_ENTITY_CODE, P_BRN_CODE);
    SP_GET_STAXACPM_INFO;
    SP_GET_GHARGE_HEAD;
    FOR IDX IN 1 .. PKG_PROCESS_CHECK.V_ACNTBRN.COUNT LOOP
      BEGIN
        W_BRN_CODE := PKG_PROCESS_CHECK.V_ACNTBRN(IDX).LN_BRN_CODE;

        IF PKG_PROCESS_CHECK.CHK_BRN_ALREADY_PROCESSED(W_ENTITY_CODE,
                                                       W_BRN_CODE) = FALSE THEN

          PKG_AUTOPOST.PV_TRAN_REC.DELETE;
          W_POST_ARRAY_INDEX := 0;
          W_LOAN_IDX         := 0;

          SP_ATM_CHARGE_PROC(W_ENTITY_CODE, W_BRN_CODE);

          /* This block also need to comment when testing require*/

          IF TRIM(PKG_EODSOD_FLAGS.PV_ERROR_MSG) IS NULL THEN
            PKG_PROCESS_CHECK.INSERT_ROW_INTO_EODSODPROCBRN(W_ENTITY_CODE,
                                                            W_BRN_CODE);
          END IF;

          PKG_PROCESS_CHECK.CHECK_COMMIT_ROLLBACK_STATUS(W_ENTITY_CODE);

          --------------------End of above block--------------------------
        END IF;

      END;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      /* This block also need to comment when testing require*/

      IF TRIM(W_ERROR_MSG) IS NULL THEN
        W_ERROR_MSG := PKG_EODSOD_FLAGS.PV_ERROR_MSG ||
                       SUBSTR(SQLERRM, 1, 1000);
      END IF;

      PKG_EODSOD_FLAGS.PV_ERROR_MSG := W_ERROR_MSG;

      --------------------End of above block--------------------------
      PKG_PB_GLOBAL.DETAIL_ERRLOG(W_ENTITY_CODE, 'E', W_ERROR_MSG, ' ', 0);
      RAISE_APPLICATION_ERROR(-20100,
                              'ERROR IN ATM CHARGE ' || W_ERROR_MSG);
  END SP_START_BRNWISE;
END PKG_ATM_CHARGE;
/
