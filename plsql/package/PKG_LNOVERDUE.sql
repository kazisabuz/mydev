DROP PACKAGE SBLPROD.PKG_LNOVERDUE;

CREATE OR REPLACE PACKAGE SBLPROD.PKG_LNOVERDUE AS
  V_OVERDUE_EOD_PROC BOOLEAN := FALSE;
  PROCEDURE SP_LNOVERDUE(V_ENTITY_NUM        IN NUMBER,
                         P_INTERNAL_ACNUM    IN NUMBER,
                         P_ASON_DATE         IN VARCHAR2,
                         P_CBD_DATE          IN VARCHAR2,
                         P_ERR_MSG           OUT VARCHAR2,
                         P_CURR_AC_BAL       OUT NUMBER,
                         P_ACTUAL_LIMIT_AMT  OUT NUMBER,
                         P_ACTUAL_DP_AMT     OUT NUMBER,
                         P_LIMIT_AMT         OUT NUMBER,
                         P_OD_AMT            OUT NUMBER,
                         P_OD_DATE           OUT VARCHAR2,
                         P_PRIN_OD_AMT       OUT NUMBER,
                         P_PRIN_OD_DATE      OUT VARCHAR,
                         P_INT_OD_AMT        OUT NUMBER,
                         P_INT_DUE_FROM_DATE OUT VARCHAR,
                         P_CHG_OD_AMT        OUT NUMBER,
                         P_CHG_DUE_FROM_DATE OUT VARCHAR,
                         --
                         W_CURR_CODE                 IN VARCHAR DEFAULT NULL,
                         W_OPENING_DATE              IN DATE DEFAULT NULL,
                         W_MIG_DATE                  IN DATE DEFAULT NULL,
                         W_ACC_PROD_CODE             IN NUMBER DEFAULT 0,
                         W_LNPRD_INT_RECOVERY_OPTION IN CHAR DEFAULT '0',
                         W_PRODUCT_FOR_RUN_ACS       IN VARCHAR DEFAULT NULL,
                         W_LIMIT_EXPIRY_DATE         IN DATE DEFAULT NULL,
                         W_ACASLL_CLINET_NUM         IN NUMBER DEFAULT 0,
                         W_ACASLL_LIMITLINE_NUM      IN NUMBER DEFAULT 0,
                         W_CALLER_FLAG               IN NUMBER DEFAULT 0);

  PROCEDURE INIT_ACTUAL_PRIN;

  P_ACTUAL_OD_AMT   NUMBER(18, 3);
  P_REPH_ON_AMT     NUMBER(18, 3);
  P_TOT_DISB_AMOUNT NUMBER(18, 3);

END PKG_LNOVERDUE;
/
DROP PACKAGE BODY SBLPROD.PKG_LNOVERDUE;

CREATE OR REPLACE PACKAGE BODY SBLPROD.PKG_LNOVERDUE AS
  /*
   Modification History
    -----------------------------------------------------------------------------------------
   Sl.            Description                              Mod By             Mod on
   -----------------------------------------------------------------------------------------
   1   Pending Interest Portion for Running Account
   -----------------------------------------------------------------------------------------
   */
  V_GLOB_ENTITY_NUM NUMBER(6); -- ADDED BY RAJIB USE AS A GLOBAL VARIABLE FOR ENTITY NUMBER CONTAIN
  E_USEREXCEP EXCEPTION;
  W_ERROR                 VARCHAR2(1300);
  W_SQL                   VARCHAR2(4300);
  W_INTERNAL_ACNUM        NUMBER;
  W_INT_RECOV_GRACE_DAYS  NUMBER(2);
  W_INT_RECOVERY_OPTION   VARCHAR(1);
  W_PROD_FOR_RUN_ACS      VARCHAR(1);
  W_ACNTS_OPENING_DATE    DATE;
  W_ACNTS_CURR_CODE       VARCHAR2(3);
  W_ACNTS_PROD_CODE       NUMBER;
  W_LIMIT_CHK_REQ         CHAR(1);
  W_LNPRD_DISB_CHECK_REQD CHAR(1);
  W_ACNTS_BRN_CODE        NUMBER(6);
  W_TOT_DISB_AMOUNT       NUMBER(18, 3);
  W_ASON_DATE             DATE;
  W_CBD                   DATE;
  W_ASON_AC_BAL           NUMBER(18, 3);
  W_ASON_BC_BAL           NUMBER(18, 3);
  W_LIMIT_AMT             NUMBER(18, 3);
  W_ACTUAL_LIMIT_AMT      NUMBER(18, 3);
  W_ACTUAL_DP_AMT         NUMBER(18, 3);
  W_TOT_INT_DB_MIG        NUMBER(18, 3);
  W_REPH_ON_AMT           NUMBER(18, 3);
  W_EQU_INSTALL_FLAG      VARCHAR2(1);
  W_LIMIT_CHK_AMT         NUMBER(18, 3);
  W_TOT_INT_DB            NUMBER(18, 3);
  W_TOT_INT_DB_SO_FAR     NUMBER(18, 3);
  W_TOT_CHGS_DB_SO_FAR    NUMBER(18, 3);

  W_INT_NOT_DUE     NUMBER(18, 3);
  W_CHGS_NOT_DUE    NUMBER(18, 3);
  W_OD_AMT          NUMBER(18, 3);
  W_TMP_OD_AMT      NUMBER(18, 3);
  W_CHG_OD_AMT      NUMBER(18, 3);
  W_CHGS_OS         NUMBER(18, 3);
  W_INT_OD_AMT      NUMBER(18, 3);
  W_INT_OS          NUMBER(18, 3);
  W_NOTIONAL_OS_BAL NUMBER(18, 3);
  --**--
  W_PRIN_OD_AMT           NUMBER(18, 3);
  W_LATEST_REPAY_DATE     DATE;
  W_ASSET_CLASS           VARCHAR2(1);
  W_MAX_EFF_DATE          DATE;
  W_CURR_AC_BAL           NUMBER(18, 3);
  W_TEMP_INT_DUE_DATE     DATE;
  W_NEXT_REPAY_DUE_DATE   DATE;
  W_MAX_SL_NUM            NUMBER;
  W_CHK_PRIN_OD_AMT       NUMBER(18, 3);
  HDTL_REPAY_AMT_CURR     VARCHAR2(3);
  HDTL_REPAY_AMT          NUMBER(18, 3);
  HDTL_REPAY_FREQ         VARCHAR2(1);
  HDTL_REPAY_FROM_DATE    DATE;
  HDTL_NUM_OF_INSTALLMENT NUMBER;
  W_NOF_INSTALL_DUE       NUMBER;
  W_REPAY_FROM_DATE       DATE;
  W_CHK_REPAY_DATE        DATE;
  W_QUIT                  VARCHAR2(1);
  W_NOF_INSTALL_AVAL      NUMBER;
  W_PENDING_AMOUNT        NUMBER(18, 3);
  V_ACASLL_CLINET_NUM     NUMBER(12);
  V_ACASLL_LIMITLINE_NUM  NUMBER(12);
  V_LIMIT_EXPIRY_DATE     DATE DEFAULT NULL;
  V_GRACE_MON_DUE_DATE    DATE DEFAULT NULL;
  V_LIMIT_DP_REQD         VARCHAR2(1);
  V_CALLER_FLAG           NUMBER;
  -- added by rajib.pradhan for handle table not found exception
  E_TABLE_NOT_FOUND EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_TABLE_NOT_FOUND, -942);
  --**--
  -- For Repay Amount
  W_LAT_EFF_DATE     DATE;
  W_EXIT             VARCHAR2(1);
  W_TOT_REPAY_AMT    NUMBER(18, 3);
  W_REPAY_DATE       DATE;
  W_REPAY_FREQ       VARCHAR(1);
  W_REPAY_AMT        NUMBER(18, 3);
  W_NOF_INSTALL      NUMBER(5);
  W_EXIT_SUB         VARCHAR2(1);
  I                  NUMBER;
  J                  NUMBER;
  W_FINAL_DUE_DATE   DATE;
  W_FREQ_COUNT       NUMBER(4);
  W_FREQ_START_DATE  DATE;
  W_PRIN_OD_DATE     DATE;
  W_OD_DATE          DATE;
  W_LNODHIST_OD_AMT  NUMBER(18, 3);
  W_LNODHIST_OD_DATE DATE;
  W_NPA_ACNT         VARCHAR2(1);
  W_NPA_DATE         DATE;
  W_REPAY_SL_NUM     NUMBER;
  --== Charge Related Info
  W_TOT_INT_CR        NUMBER(18, 3);
  W_TOT_CHGS_DB       NUMBER(18, 3);
  W_TOT_CHGS_CR       NUMBER(18, 3);
  W_INT_DUE_FROM_DATE DATE;
  W_CHG_DUE_FROM_DATE DATE;
  W_PROC_YEAR         NUMBER;
  W_UPTO_YEAR         NUMBER;
  W_INTRD_BC_AMT      NUMBER(18, 3);
  W_CHARGE_BC_AMT     NUMBER(18, 3);
  W_DB_CR_FLG         VARCHAR2(1);
  W_DATE_OF_TRAN      DATE;
  W_INT_IGN           VARCHAR2(1);
  W_ACT_INT_DUE_DATE  DATE;
  W_IS_LIMIT_EXP      BOOLEAN;
  W_ACC_MIG_DATE      DATE;
  -- Re-Schedule
  V_REPHASEMENT_ENTRY LNACRSHIST.LNACRSH_REPHASEMENT_ENTRY%TYPE;
  V_REPH_ON_AMT       LNACRSHIST.LNACRSH_REPH_ON_AMT%TYPE;
  V_PURPOSE_CODE      CHAR(1);
  V_REPHASE_ON_DATE   DATE;

  TYPE ARRAYINFO IS RECORD(
    FIELD1 DATE);
  TYPE V_ARRAYINFO IS TABLE OF ARRAYINFO INDEX BY PLS_INTEGER;
  V_FIELD V_ARRAYINFO;

  TYPE TY_TRAN_REC IS RECORD(
    V_INTRD_BC_AMT  NUMBER(18, 3),
    V_CHARGE_BC_AMT NUMBER(18, 3),
    V_DB_CR_FLG     VARCHAR2(1),
    V_DATE_OF_TRAN  DATE);

  TYPE TAB_TRAN_REC IS TABLE OF TY_TRAN_REC INDEX BY PLS_INTEGER;
  TRAN_REC TAB_TRAN_REC;

  PROCEDURE TRANADV_PROC;
  PROCEDURE INIT_PARA IS
  BEGIN
    W_LATEST_REPAY_DATE     := NULL;
    W_ASON_DATE             := NULL;
    W_CBD                   := NULL;
    W_ERROR                 := '';
    W_INTERNAL_ACNUM        := 0;
    W_INT_RECOV_GRACE_DAYS  := 0;
    W_INT_RECOVERY_OPTION   := '';
    W_PROD_FOR_RUN_ACS      := '';
    W_ACNTS_OPENING_DATE    := NULL;
    W_ACNTS_CURR_CODE       := '';
    W_ACNTS_PROD_CODE       := 0;
    W_NPA_ACNT              := 0;
    W_NPA_DATE              := NULL;
    W_ASSET_CLASS           := '';
    W_MAX_EFF_DATE          := NULL;
    W_ASON_AC_BAL           := 0;
    W_CURR_AC_BAL           := 0;
    W_ASON_BC_BAL           := 0;
    W_LIMIT_AMT             := 0;
    W_ACTUAL_LIMIT_AMT      := 0;
    W_ACTUAL_DP_AMT         := 0;
    W_OD_AMT                := 0;
    W_OD_DATE               := NULL;
    W_LAT_EFF_DATE          := NULL;
    W_LNODHIST_OD_AMT       := 0;
    W_LNODHIST_OD_DATE      := NULL;
    W_EQU_INSTALL_FLAG      := '';
    W_EXIT                  := '0';
    W_TOT_REPAY_AMT         := 0;
    W_REPAY_DATE            := NULL;
    W_REPAY_FREQ            := '';
    W_REPAY_AMT             := 0;
    W_NOF_INSTALL           := 0;
    W_EXIT_SUB              := '0';
    W_TOT_INT_DB            := 0;
    W_TOT_INT_CR            := 0;
    W_TOT_CHGS_DB           := 0;
    W_TOT_CHGS_CR           := 0;
    W_INT_NOT_DUE           := 0;
    W_CHGS_NOT_DUE          := 0;
    W_INT_DUE_FROM_DATE     := NULL;
    W_CHG_DUE_FROM_DATE     := NULL;
    W_PROC_YEAR             := 0;
    W_UPTO_YEAR             := 0;
    W_FINAL_DUE_DATE        := NULL;
    I                       := 0;
    J                       := 0;
    W_SQL                   := '';
    W_INTRD_BC_AMT          := 0;
    W_CHARGE_BC_AMT         := 0;
    W_INT_IGN               := 0;
    W_DB_CR_FLG             := '';
    W_DATE_OF_TRAN          := NULL;
    W_TEMP_INT_DUE_DATE     := NULL;
    W_NEXT_REPAY_DUE_DATE   := NULL;
    W_INT_OS                := 0;
    W_CHGS_OS               := 0;
    W_LIMIT_CHK_AMT         := 0;
    W_TMP_OD_AMT            := 0;
    W_CHG_OD_AMT            := 0;
    W_INT_OD_AMT            := 0;
    W_PRIN_OD_AMT           := 0;
    W_MAX_SL_NUM            := 0;
    W_CHK_PRIN_OD_AMT       := 0;
    HDTL_REPAY_AMT_CURR     := '';
    HDTL_REPAY_AMT          := 0;
    HDTL_REPAY_FREQ         := '';
    HDTL_REPAY_FROM_DATE    := NULL;
    HDTL_NUM_OF_INSTALLMENT := 0;
    W_NOF_INSTALL_DUE       := 0;
    W_REPAY_FROM_DATE       := NULL;
    W_CHK_REPAY_DATE        := NULL;
    W_QUIT                  := '';
    W_NOF_INSTALL_AVAL      := 0;
    W_PRIN_OD_DATE          := NULL;
    W_ACT_INT_DUE_DATE      := NULL;
    W_LIMIT_CHK_REQ         := '0';
    W_PENDING_AMOUNT        := 0;
    W_LNPRD_DISB_CHECK_REQD := '';
    W_REPH_ON_AMT           := 0;
    W_ACNTS_BRN_CODE        := 0;
    W_TOT_DISB_AMOUNT       := 0;
    W_REPAY_SL_NUM          := 0;
    V_ACASLL_CLINET_NUM     := 0;
    V_ACASLL_LIMITLINE_NUM  := 0;
    V_LIMIT_EXPIRY_DATE     := NULL;
    V_GRACE_MON_DUE_DATE    := NULL;
    V_LIMIT_DP_REQD         := '';
    W_IS_LIMIT_EXP          := FALSE;
    W_TOT_INT_DB_SO_FAR     := 0;
    W_TOT_CHGS_DB_SO_FAR    := 0;
    V_REPHASEMENT_ENTRY     := 0;
    V_REPH_ON_AMT           := 0;
    V_PURPOSE_CODE          := '';
    V_REPHASE_ON_DATE       := NULL;
    V_CALLER_FLAG           := 0;
  END INIT_PARA;

  -- To Get Expiry Date

  PROCEDURE GETEXPIRYDATE(V_ACNTS_INTERNAL_ACNUM IN NUMBER) IS

  BEGIN
    <<READ_ACASLLDTL>>
    BEGIN
      SELECT ACASLLDTL_CLIENT_NUM, ACASLLDTL_LIMIT_LINE_NUM
        INTO V_ACASLL_CLINET_NUM, V_ACASLL_LIMITLINE_NUM
        FROM ACASLLDTL
       WHERE ACASLLDTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
         AND ACASLLDTL_INTERNAL_ACNUM = V_ACNTS_INTERNAL_ACNUM;

      <<READ_LIMITLINE>>
      BEGIN
        SELECT LMTLINE_LIMIT_EXPIRY_DATE, LMTLINE_DP_REQD
          INTO V_LIMIT_EXPIRY_DATE, V_LIMIT_DP_REQD FROM LIMITLINE
         WHERE LMTLINE_ENTITY_NUM = V_GLOB_ENTITY_NUM
           AND LMTLINE_CLIENT_CODE = V_ACASLL_CLINET_NUM
           AND LMTLINE_NUM = V_ACASLL_LIMITLINE_NUM;

        <<COMPARE_DATES>>
        BEGIN
       IF V_GRACE_MON_DUE_DATE IS NOT NULL THEN
        IF V_GRACE_MON_DUE_DATE > V_LIMIT_EXPIRY_DATE THEN
         V_LIMIT_EXPIRY_DATE := V_GRACE_MON_DUE_DATE;
        END IF;
       END IF;

          IF (V_LIMIT_EXPIRY_DATE < W_ASON_DATE) THEN
            W_IS_LIMIT_EXP := TRUE;
          ELSE
            W_IS_LIMIT_EXP := FALSE;
          END IF;

        EXCEPTION
          WHEN OTHERS THEN
            IF (W_ERROR IS NULL) THEN
              W_ERROR := 'ERROR IN COMPARE_DATES';
            END IF;
            RAISE E_USEREXCEP;
        END COMPARE_DATES;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF (W_ERROR IS NULL) THEN
            W_ERROR := '';
          END IF;
        WHEN OTHERS THEN
          IF (W_ERROR IS NULL) THEN
            W_ERROR := 'ERROR IN READ_LIMITLINE';
          END IF;
          RAISE E_USEREXCEP;
      END READ_LIMITLINE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        IF (W_ERROR IS NULL) THEN
          W_ERROR := 'ERROR IN READ_ACASLLDTL';
        END IF;
        RAISE E_USEREXCEP;
    END READ_ACASLLDTL;
  END GETEXPIRYDATE;

  PROCEDURE READ_LNDETAILS(W1_INTERNAL_ACNUM IN NUMBER,
                           W_ASON_DATE       IN VARCHAR2) IS
  BEGIN
    <<FETCH_LNDETAILS>>
    BEGIN

      W_INTERNAL_ACNUM := W1_INTERNAL_ACNUM;

      SELECT LNPRD_INT_RECOV_GRACE_DAYS,
             LNPRD_INT_RECOVERY_OPTION,
             PRODUCT_FOR_RUN_ACS,
             ACNTS_OPENING_DATE,
             ACNTS_CURR_CODE,
             ACNTS_PROD_CODE,
             LNPRD_LIMIT_CHK_REQD,
             LNPRD_DISB_CHECK_REQD,
             ACNTS_BRN_CODE
        INTO W_INT_RECOV_GRACE_DAYS,
             W_INT_RECOVERY_OPTION,
             W_PROD_FOR_RUN_ACS,
             W_ACNTS_OPENING_DATE,
             W_ACNTS_CURR_CODE,
             W_ACNTS_PROD_CODE,
             W_LIMIT_CHK_REQ,
             W_LNPRD_DISB_CHECK_REQD,
             W_ACNTS_BRN_CODE
        FROM ACNTS, LOANACNTS, PRODUCTS, LNPRODPM
       WHERE LNACNT_ENTITY_NUM = V_GLOB_ENTITY_NUM
         AND ACNTS_ENTITY_NUM = V_GLOB_ENTITY_NUM
         AND ACNTS_PROD_CODE = PRODUCT_CODE
         AND PRODUCT_FOR_LOANS = '1'
         AND ACNTS_PROD_CODE = LNPRD_PROD_CODE
         AND LNPRD_INT_APPL_FREQ <> 'I'
         AND ACNTS_INTERNAL_ACNUM = LNACNT_INTERNAL_ACNUM
         AND ACNTS_INTERNAL_ACNUM = W_INTERNAL_ACNUM
         AND (ACNTS_CLOSURE_DATE IS NULL OR
             ACNTS_CLOSURE_DATE > W_ASON_DATE)
         AND ACNTS_AUTH_ON IS NOT NULL;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        W_ERROR := 'Not a Valid Loan Account Number';
        RAISE E_USEREXCEP;
    END FETCH_LNDETAILS;
  END READ_LNDETAILS;

  --==  Fetching Loan OutStanding.

  PROCEDURE FETCH_LLACNTOS(W_INTERNAL_ACNUM  IN NUMBER,
                           V_TOT_DISB_AMOUNT OUT NUMBER) AS
    W_CLIENT_NUM     NUMBER(12) := 0;
    W_LIMIT_LINE_NUM NUMBER(6) := 0;

  BEGIN

    /*
      <<FETCH_ACASLLDTL>>
      BEGIN
        SELECT ACASLLDTL_CLIENT_NUM, ACASLLDTL_LIMIT_LINE_NUM
          INTO W_CLIENT_NUM, W_LIMIT_LINE_NUM
          FROM ACASLLDTL
         WHERE ACASLLDTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
           AND ACASLLDTL_INTERNAL_ACNUM = W_INTERNAL_ACNUM;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          W_CLIENT_NUM     := 0;
          W_LIMIT_LINE_NUM := 0;
      END FETCH_ACASLLDTL;
    */
    -- Comment Added by Tamim

    IF (V_REPHASEMENT_ENTRY = 0 OR
       (V_REPHASEMENT_ENTRY = 1 AND V_PURPOSE_CODE <> 'R')) THEN

      SELECT LLACNTOS_LIMIT_CURR_DISB_MADE
        INTO V_TOT_DISB_AMOUNT
        FROM LLACNTOS
       WHERE LLACNTOS_ENTITY_NUM = V_GLOB_ENTITY_NUM
         AND LLACNTOS_CLIENT_CODE = V_ACASLL_CLINET_NUM
         AND LLACNTOS_LIMIT_LINE_NUM = V_ACASLL_LIMITLINE_NUM
         AND LLACNTOS_CLIENT_ACNUM = W_INTERNAL_ACNUM;

      /*
      SELECT SUM(LNACDISB_DISB_AMT)
        INTO V_TOT_DISB_AMOUNT
        FROM LNACDISB
       WHERE LNACDISB_ENTITY_NUM = V_GLOB_ENTITY_NUM
         AND LNACDISB_INTERNAL_ACNUM = W_INTERNAL_ACNUM
         AND LNACDISB_AUTH_ON IS NOT NULL; */
    ELSE
      V_TOT_DISB_AMOUNT := V_REPH_ON_AMT;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_TOT_DISB_AMOUNT := 0;
  END FETCH_LLACNTOS;

  -- ======== For Term Loan MIG Related Information ==
  PROCEDURE FETCH_MIG_DETAILS(P_ACNTS_BRN_CODE IN NUMBER,
                              P_MIG_END_DATE   OUT DATE) AS
  BEGIN
    SELECT MIG_END_DATE
      INTO P_MIG_END_DATE
      FROM MIG_DETAIL
     WHERE BRANCH_CODE = P_ACNTS_BRN_CODE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      P_MIG_END_DATE := NULL;

  END FETCH_MIG_DETAILS;

  PROCEDURE FETCH_LNTOTPRINDBMIG(V_MIG_END_DATE    IN DATE,
                                 V_TOT_DISB_AMOUNT OUT NUMBER) AS
    W_PRIN_DB_MIG         NUMBER(18, 3) := 0;
    W_DISB_MADE_AFT_MIG   NUMBER(18, 3) := 0;
    W_DISB_TRAN_FROM_DATE DATE := NULL;
    W_DUMMY_NUM           NUMBER := 0;
    W_ERR                 VARCHAR2(1000) := '';
    W_RECORD_FOUND        CHAR(1) := '0';

  BEGIN
    <<LNTOTPRINDBMIG>>
    BEGIN
      SELECT LNTOTPRINDB_PRIN_DB_TILL_MIG
        INTO W_PRIN_DB_MIG
        FROM LNTOTPRINDBMIG
       WHERE LNTOTPRINDB_ENTITY_NUM = V_GLOB_ENTITY_NUM
         AND LNTOTPRINDB_INTERNAL_ACNUM = W_INTERNAL_ACNUM;
      W_DISB_TRAN_FROM_DATE := V_MIG_END_DATE + 1;
      W_RECORD_FOUND        := '1';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        W_PRIN_DB_MIG         := 0;
        V_TOT_DISB_AMOUNT     := W_LIMIT_AMT;
        W_RECORD_FOUND        := '0';
        W_DISB_TRAN_FROM_DATE := W_ACNTS_OPENING_DATE;
    END LNTOTPRINDBMIG;

    IF TRIM(W_RECORD_FOUND) = '1' THEN
      SP_LNTRANSUM(V_GLOB_ENTITY_NUM,
                   W_INTERNAL_ACNUM,
                   NULL,
                   W_CBD,
                   W_DISB_TRAN_FROM_DATE,
                   W_ASON_DATE,
                   W_ERR,
                   W_DISB_MADE_AFT_MIG,
                   W_DUMMY_NUM,
                   W_DUMMY_NUM,
                   W_DUMMY_NUM,
                   W_DUMMY_NUM,
                   W_DUMMY_NUM,
                   W_DUMMY_NUM,
                   W_DUMMY_NUM,
                   W_DUMMY_NUM,
                   W_DUMMY_NUM,
                   W_DUMMY_NUM,
                   W_DUMMY_NUM);
      IF (TRIM(W_ERR) IS NOT NULL) THEN
        W_DISB_MADE_AFT_MIG := 0;
      END IF;
      V_TOT_DISB_AMOUNT := W_PRIN_DB_MIG + W_DISB_MADE_AFT_MIG;
    END IF;
  END FETCH_LNTOTPRINDBMIG;

  PROCEDURE GET_TOT_INT_DB_MIG IS
  BEGIN
    <<READLNTOTINTDBMIG>>
    BEGIN
      -- Reschedule
      IF (V_REPHASEMENT_ENTRY = 0 OR
         (V_REPHASEMENT_ENTRY = 1 AND V_PURPOSE_CODE <> 'R') OR
         (V_REPHASEMENT_ENTRY = 1 AND V_PURPOSE_CODE = 'R' AND
         V_REPHASE_ON_DATE <= W_ACC_MIG_DATE)) THEN
        SELECT ABS(NVL(L.LNTOTINTDB_TOT_INT_DB_AMT, 0))
          INTO W_TOT_INT_DB_MIG
          FROM LNTOTINTDBMIG L
         WHERE L.LNTOTINTDB_ENTITY_NUM = V_GLOB_ENTITY_NUM
           AND L.LNTOTINTDB_INTERNAL_ACNUM = W_INTERNAL_ACNUM;
      ELSE
        W_TOT_INT_DB_MIG := 0;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        W_TOT_INT_DB_MIG := 0;
    END READLNTOTINTDBMIG;
  END GET_TOT_INT_DB_MIG;

  --=== Repay Amount.

  PROCEDURE REPAY_CALC_PROC_SUB IS
  BEGIN

    IF (W_REPAY_DATE > W_ASON_DATE) THEN
      W_EXIT_SUB := 1;
      W_EXIT     := 1;
    END IF;

    V_FIELD(I).FIELD1 := W_REPAY_DATE;
    I := I + 1;

    IF (W_EXIT_SUB = '0') THEN
      W_TOT_REPAY_AMT := W_TOT_REPAY_AMT + W_REPAY_AMT;

      W_NOF_INSTALL := W_NOF_INSTALL - 1;

      W_FREQ_COUNT := W_FREQ_COUNT + 1;
      IF (W_REPAY_FREQ = 'M') THEN
        W_REPAY_DATE := ADD_MONTHS(W_FREQ_START_DATE, (1 * W_FREQ_COUNT));
      ELSE
        IF (W_REPAY_FREQ = 'Q') THEN
          W_REPAY_DATE := ADD_MONTHS(W_FREQ_START_DATE, (3 * W_FREQ_COUNT));
        ELSE
          IF (W_REPAY_FREQ = 'H') THEN
            W_REPAY_DATE := ADD_MONTHS(W_FREQ_START_DATE,
                                       (6 * W_FREQ_COUNT));
          ELSE
            IF (W_REPAY_FREQ = 'Y') THEN
              W_REPAY_DATE := ADD_MONTHS(W_FREQ_START_DATE,
                                         (12 * W_FREQ_COUNT));
            ELSE
              IF (W_REPAY_FREQ = 'X') THEN
                W_EXIT_SUB := 1;
                W_EXIT     := 1;
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;

    IF (W_NOF_INSTALL = 0) THEN
      W_EXIT_SUB := 1;
      W_EXIT     := 1;
    END IF;
  END REPAY_CALC_PROC_SUB;

  PROCEDURE GET_FINAL_DUE_DATE IS
  BEGIN
    IF (W_REPAY_FREQ = 'M') THEN
      W_FINAL_DUE_DATE := ADD_MONTHS(W_REPAY_DATE, (W_NOF_INSTALL - 1) * 1);
    ELSE
      IF (W_REPAY_FREQ = 'Q') THEN
        W_FINAL_DUE_DATE := ADD_MONTHS(W_REPAY_DATE,
                                       (W_NOF_INSTALL - 1) * 3);
      ELSE
        IF (W_REPAY_FREQ = 'H') THEN
          W_FINAL_DUE_DATE := ADD_MONTHS(W_REPAY_DATE,
                                         (W_NOF_INSTALL - 1) * 6);
        ELSE
          IF (W_REPAY_FREQ = 'Y') THEN
            W_FINAL_DUE_DATE := ADD_MONTHS(W_REPAY_DATE,
                                           (W_NOF_INSTALL - 1) * 12);
          ELSE
            IF (W_REPAY_FREQ = 'X') THEN
              W_FINAL_DUE_DATE := W_REPAY_DATE;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;

  END GET_FINAL_DUE_DATE;

  PROCEDURE REPAY_CALC_PROC IS
  BEGIN
    GET_FINAL_DUE_DATE;
    W_EXIT_SUB        := 0;
    W_FREQ_COUNT      := 0;
    W_FREQ_START_DATE := NULL;
    W_FREQ_START_DATE := W_REPAY_DATE;

    WHILE (W_EXIT_SUB = 0) LOOP
      REPAY_CALC_PROC_SUB;
    END LOOP;
  END REPAY_CALC_PROC;

  PROCEDURE FETCH_TOT_REPAY_AMT_PROC(W_INTERNAL_ACNUM IN NUMBER,
                                     W_ASON_DATE      IN DATE) IS
  BEGIN
    W_LAT_EFF_DATE      := NULL;
    V_REPHASEMENT_ENTRY := 0;
    V_REPH_ON_AMT       := 0;
    V_PURPOSE_CODE      := '';
    V_REPHASE_ON_DATE   := NULL;
    SELECT LNACRSH_EFF_DATE,
           NVL(LNACRSH_REPHASEMENT_ENTRY, 0),
           LNACRSH_REPH_ON_AMT,
           NVL(LNACRSH_PURPOSE, 'X'),
           LNACRSH_EFF_DATE
      INTO W_LAT_EFF_DATE,
           V_REPHASEMENT_ENTRY,
           V_REPH_ON_AMT,
           V_PURPOSE_CODE,
           V_REPHASE_ON_DATE
      FROM LNACRSHIST
     WHERE LNACRSH_EFF_DATE =
           (SELECT MAX(LNACRSH_EFF_DATE)
              FROM LNACRSHIST
             WHERE LNACRSH_ENTITY_NUM = V_GLOB_ENTITY_NUM
               AND LNACRSH_INTERNAL_ACNUM = W_INTERNAL_ACNUM
               AND LNACRSH_EFF_DATE <= W_ASON_DATE)
       AND LNACRSH_INTERNAL_ACNUM = W_INTERNAL_ACNUM;

    IF (W_LAT_EFF_DATE IS NULL) THEN
      W_ERROR := 'Repayment Details Not Found for ' ||
                 FACNO(V_GLOB_ENTITY_NUM, W_INTERNAL_ACNUM);
      RAISE E_USEREXCEP;
    END IF;

    IF (W_LAT_EFF_DATE IS NOT NULL) THEN
      SELECT LNACRSH_EQU_INSTALLMENT, LNACRSH_REPH_ON_AMT
        INTO W_EQU_INSTALL_FLAG, W_REPH_ON_AMT
        FROM LNACRSHIST
       WHERE LNACRSH_ENTITY_NUM = V_GLOB_ENTITY_NUM
         AND LNACRSH_INTERNAL_ACNUM = W_INTERNAL_ACNUM
         AND LNACRSH_EFF_DATE = W_LAT_EFF_DATE;

      W_EXIT          := '0';
      W_TOT_REPAY_AMT := 0;
      BEGIN
        DECLARE
          CURSOR D_TMPLNACRSHDTL IS
            SELECT LNACRSHDTL_REPAY_AMT,
                   NVL(TRIM(LNACRSHDTL_REPAY_FREQ), 'M') LNACRSHDTL_REPAY_FREQ,
                   LNACRSHDTL_REPAY_FROM_DATE,
                   LNACRSHDTL_NUM_OF_INSTALLMENT
              FROM LNACRSHDTL
             WHERE LNACRSHDTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
               AND LNACRSHDTL_INTERNAL_ACNUM = W_INTERNAL_ACNUM
               AND LNACRSHDTL_EFF_DATE = W_LAT_EFF_DATE;
          D_LNACRSH D_TMPLNACRSHDTL%ROWTYPE;
        BEGIN
          WHILE (W_EXIT = 0) LOOP
            FOR D_LNACRSH IN D_TMPLNACRSHDTL LOOP
              IF (W_EXIT <> 0) THEN
                EXIT;
              END IF;
              W_REPAY_DATE  := D_LNACRSH.LNACRSHDTL_REPAY_FROM_DATE;
              W_REPAY_FREQ  := D_LNACRSH.LNACRSHDTL_REPAY_FREQ;
              W_REPAY_AMT   := D_LNACRSH.LNACRSHDTL_REPAY_AMT;
              W_NOF_INSTALL := D_LNACRSH.LNACRSHDTL_NUM_OF_INSTALLMENT;

              I := 0;

              REPAY_CALC_PROC;
            END LOOP;
            W_EXIT := 1;
          END LOOP;
        END;
      END;
    END IF;

  END FETCH_TOT_REPAY_AMT_PROC;

  PROCEDURE FETCH_TOT_INT_CHG_AMT_PROC IS
    W_MIN_PROC_DATE DATE;

  BEGIN
    W_TOT_INT_DB        := 0;
    W_TOT_INT_CR        := 0;
    W_TOT_CHGS_DB       := 0;
    W_TOT_CHGS_CR       := 0;
    W_INT_NOT_DUE       := 0;
    W_CHGS_NOT_DUE      := 0;
    W_INT_DUE_FROM_DATE := NULL;
    W_CHG_DUE_FROM_DATE := NULL;
    W_PROC_YEAR         := SP_GETFINYEAR(V_GLOB_ENTITY_NUM,
                                         W_ACNTS_OPENING_DATE);
    -- added by rajib.pradhan for reduce tran access before 2014 (live operation in sonali)
    IF W_PROC_YEAR < 2014 THEN
      W_PROC_YEAR := 2014;
    END IF;

    W_UPTO_YEAR := SP_GETFINYEAR(V_GLOB_ENTITY_NUM, W_ASON_DATE);

    WHILE (W_PROC_YEAR <= W_UPTO_YEAR) LOOP
      ---IF SP_TABLEAVAIL(V_GLOB_ENTITY_NUM,'TRANADV' || W_PROC_YEAR,'PKG_LNOVERDUE') = 1 THEN    -- remove by rajib.pradhan for reduce tran access before 2014 (live operation in sonali)
      TRANADV_PROC;
      ---END IF;
      W_PROC_YEAR := W_PROC_YEAR + 1;
    END LOOP;

    IF ABS(W_INT_NOT_DUE) > ABS(W_INT_OS) THEN
      W_INT_NOT_DUE := ABS(W_INT_OS);
    END IF;
    IF ABS(W_CHGS_NOT_DUE) > ABS(W_CHGS_OS) THEN
      W_CHGS_NOT_DUE := ABS(W_CHGS_OS);
    END IF;

  END FETCH_TOT_INT_CHG_AMT_PROC;

  --===== Process For Continuous Loan

  PROCEDURE OVERDUE_FOR_RUN_ACNTS_PROC IS
  BEGIN
    IF W_IS_LIMIT_EXP AND (W_ASON_AC_BAL < 0) THEN
      W_OD_AMT := ABS(W_ASON_AC_BAL);
    ELSIF (W_ASON_AC_BAL < 0) THEN
      W_OD_AMT := ABS(W_ASON_AC_BAL);
    ELSE
      W_OD_AMT := 0;
    END IF;

    IF (W_OD_AMT > 0) THEN
      P_ACTUAL_OD_AMT := W_OD_AMT;
      --Code For FETCH_OD_DATE
    /*
      SELECT MAX(LNODHIST_EFF_DATE)
        INTO W_LAT_EFF_DATE
        FROM LNODHIST
       WHERE LNODHIST_ENTITY_NUM = V_GLOB_ENTITY_NUM
         AND LNODHIST_INTERNAL_ACNUM = W_INTERNAL_ACNUM
         AND LNODHIST_EFF_DATE <= W_ASON_DATE;
    */
      IF (W_LAT_EFF_DATE IS NULL) THEN
        W_OD_DATE := W_CBD;
      END IF;

      IF (W_LAT_EFF_DATE IS NOT NULL) THEN
        SELECT LNODHIST_OD_AMT, LNODHIST_OD_DATE
          INTO W_LNODHIST_OD_AMT, W_LNODHIST_OD_DATE
          FROM LNODHIST
         WHERE LNODHIST_ENTITY_NUM = V_GLOB_ENTITY_NUM
           AND LNODHIST_INTERNAL_ACNUM = W_INTERNAL_ACNUM
           AND LNODHIST_EFF_DATE = W_LAT_EFF_DATE;

        IF (W_LNODHIST_OD_AMT > 0) THEN
          W_OD_DATE := W_LNODHIST_OD_DATE;
        ELSE
          W_OD_DATE := W_CBD;
        END IF;
      END IF;

    END IF;

    FETCH_TOT_INT_CHG_AMT_PROC;
    --== CHARGE BF
    IF W_OD_AMT > 0 AND W_OD_AMT > ABS(W_CHGS_OS) THEN
      W_CHG_OD_AMT := ABS(W_CHGS_OS);
      W_TMP_OD_AMT := W_OD_AMT - W_CHG_OD_AMT;
    ELSIF W_OD_AMT > 0 THEN
      W_CHG_OD_AMT := W_OD_AMT;
      W_TMP_OD_AMT := 0;
    END IF;

    --== INT BF
    IF W_TMP_OD_AMT > 0 AND W_TMP_OD_AMT > ABS(W_INT_OS) THEN
      W_INT_OD_AMT  := ABS(W_INT_OS);
      W_PRIN_OD_AMT := W_TMP_OD_AMT - W_INT_OD_AMT;
    ELSE
      W_INT_OD_AMT := ABS(W_TMP_OD_AMT);
      W_TMP_OD_AMT := 0;
    END IF;

  END OVERDUE_FOR_RUN_ACNTS_PROC;

  --== Process For Term Laon
  -- DUE DATE

  PROCEDURE CHECK_REPAY_DATES_SUB IS
  BEGIN
    IF (W_CHK_REPAY_DATE > W_ASON_DATE) THEN
      W_QUIT := 1;
    END IF;

    IF (W_QUIT = 0) THEN
      W_LATEST_REPAY_DATE := W_CHK_REPAY_DATE;
      W_FREQ_COUNT        := W_FREQ_COUNT + 1;

      W_NOF_INSTALL_AVAL := W_NOF_INSTALL_AVAL + 1;

      IF (W_REPAY_FREQ = 'M') THEN
        W_CHK_REPAY_DATE := ADD_MONTHS(W_FREQ_START_DATE,
                                       (1 * W_FREQ_COUNT));
      ELSE
        IF (W_REPAY_FREQ = 'Q') THEN
          W_CHK_REPAY_DATE := ADD_MONTHS(W_FREQ_START_DATE,
                                         (3 * W_FREQ_COUNT));
        ELSE
          IF (W_REPAY_FREQ = 'H') THEN
            W_CHK_REPAY_DATE := ADD_MONTHS(W_FREQ_START_DATE,
                                           (6 * W_FREQ_COUNT));
          ELSE
            IF (W_REPAY_FREQ = 'Y') THEN
              W_CHK_REPAY_DATE := ADD_MONTHS(W_FREQ_START_DATE,
                                             (12 * W_FREQ_COUNT));
            ELSE
              IF (W_REPAY_FREQ = 'X') THEN
                W_QUIT := 1;
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
  END CHECK_REPAY_DATES_SUB;

  PROCEDURE CHECK_REPAY_DATES IS
  BEGIN
    W_CHK_REPAY_DATE    := W_REPAY_FROM_DATE;
    W_LATEST_REPAY_DATE := W_CHK_REPAY_DATE;
    W_FREQ_COUNT        := 0;
    W_FREQ_START_DATE   := W_CHK_REPAY_DATE;

    W_QUIT             := 0;
    W_NOF_INSTALL_AVAL := 0;

    WHILE (W_QUIT = 0) LOOP
      CHECK_REPAY_DATES_SUB;
    END LOOP;
    W_CHK_REPAY_DATE := W_LATEST_REPAY_DATE;
  END CHECK_REPAY_DATES;

  PROCEDURE GET_PRI_OD_DATE_NEXT IS
  BEGIN
    IF NVL(HDTL_REPAY_AMT, 0) = 0 THEN
      HDTL_REPAY_AMT := W_CHK_PRIN_OD_AMT;
    END IF;
    W_NOF_INSTALL_DUE := W_CHK_PRIN_OD_AMT / HDTL_REPAY_AMT;

    CHECK_REPAY_DATES;
    IF (W_NOF_INSTALL_AVAL < W_NOF_INSTALL_DUE) THEN
      W_NOF_INSTALL_DUE := W_NOF_INSTALL_AVAL;
    END IF;
    -- The is OK For Monthly Frequency But For Quarterly, its Not Corect.
    --W_NOF_INSTALL_DUE := FLOOR(ABS(W_NOF_INSTALL_DUE));
    IF W_NOF_INSTALL_DUE > 1 THEN
      W_NOF_INSTALL_DUE := W_NOF_INSTALL_DUE; -- - 1;
    ELSE
      W_NOF_INSTALL_DUE := 0;
    END IF;

    IF (FLOOR(ABS(W_NOF_INSTALL_DUE)) <= HDTL_NUM_OF_INSTALLMENT) THEN
      IF (W_REPAY_FREQ = 'M') THEN
        W_PRIN_OD_DATE := ADD_MONTHS(W_CHK_REPAY_DATE,
                                     (FLOOR(ABS(W_NOF_INSTALL_DUE))) * -1);
      ELSE
        IF (W_REPAY_FREQ = 'Q') THEN
          W_PRIN_OD_DATE := ADD_MONTHS(W_CHK_REPAY_DATE,
                                       (FLOOR(ABS(W_NOF_INSTALL_DUE * 3))) * -1);
        ELSE
          IF (W_REPAY_FREQ = 'H') THEN
            W_PRIN_OD_DATE := ADD_MONTHS(W_CHK_REPAY_DATE,
                                         (FLOOR(ABS(W_NOF_INSTALL_DUE * 6))) * -1);
          ELSE
            IF (W_REPAY_FREQ = 'Y') THEN
              W_PRIN_OD_DATE := ADD_MONTHS(W_CHK_REPAY_DATE,
                                           (FLOOR(ABS(W_NOF_INSTALL_DUE * 12))) * -1);
            ELSE
              IF (W_REPAY_FREQ = 'X') THEN
                W_PRIN_OD_DATE := W_CHK_REPAY_DATE;
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;

    W_CHK_PRIN_OD_AMT := W_CHK_PRIN_OD_AMT -
                         (FLOOR(ABS(W_NOF_INSTALL_DUE)) * HDTL_REPAY_AMT);

    IF (W_CHK_PRIN_OD_AMT <= 0) OR FLOOR(ABS(W_NOF_INSTALL_DUE)) < 1 THEN
      W_EXIT := 1;
    END IF;

  END GET_PRI_OD_DATE_NEXT;

  PROCEDURE GET_PRI_OD_DATE_SUB IS
  BEGIN
    SELECT NVL(MAX(LNACRSHDTL_SL_NUM), 0)
      INTO W_REPAY_SL_NUM
      FROM LNACRSHDTL
     WHERE LNACRSHDTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
       AND LNACRSHDTL_INTERNAL_ACNUM = W_INTERNAL_ACNUM
       AND LNACRSHDTL_EFF_DATE = W_LAT_EFF_DATE
       AND LNACRSHDTL_SL_NUM < W_MAX_SL_NUM;

    W_MAX_SL_NUM := W_REPAY_SL_NUM;

    SELECT LNACRSHDTL_REPAY_AMT_CURR,
           LNACRSHDTL_REPAY_AMT,
           LNACRSHDTL_REPAY_FREQ,
           LNACRSHDTL_REPAY_FROM_DATE,
           LNACRSHDTL_NUM_OF_INSTALLMENT
      INTO HDTL_REPAY_AMT_CURR,
           HDTL_REPAY_AMT,
           HDTL_REPAY_FREQ,
           HDTL_REPAY_FROM_DATE,
           HDTL_NUM_OF_INSTALLMENT
      FROM LNACRSHDTL
     WHERE LNACRSHDTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
       AND LNACRSHDTL_INTERNAL_ACNUM = W_INTERNAL_ACNUM
       AND LNACRSHDTL_EFF_DATE = W_LAT_EFF_DATE
       AND LNACRSHDTL_SL_NUM = W_REPAY_SL_NUM;

    IF (HDTL_REPAY_FROM_DATE <= W_ASON_DATE) THEN
      W_NOF_INSTALL_DUE := 0;
      W_REPAY_FROM_DATE := HDTL_REPAY_FROM_DATE;
      GET_PRI_OD_DATE_NEXT;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      W_EXIT := 1;
  END GET_PRI_OD_DATE_SUB;

  PROCEDURE GET_PRIN_OD_DATE IS
  BEGIN
    W_LAT_EFF_DATE := NULL;
    SELECT MAX(LNACRSH_EFF_DATE)
      INTO W_LAT_EFF_DATE
      FROM LNACRSHIST
     WHERE LNACRSH_ENTITY_NUM = V_GLOB_ENTITY_NUM
       AND LNACRSH_INTERNAL_ACNUM = W_INTERNAL_ACNUM
       AND LNACRSH_EFF_DATE <= W_ASON_DATE;

    IF (W_LAT_EFF_DATE IS NULL) THEN
      W_ERROR := 'Repayment Details Not Found for ' ||
                 FACNO(V_GLOB_ENTITY_NUM, W_INTERNAL_ACNUM);
      RAISE E_USEREXCEP;
    END IF;

    IF (W_LAT_EFF_DATE IS NOT NULL) THEN
      W_EXIT       := 0;
      W_MAX_SL_NUM := 100;
      --W_CHK_PRIN_OD_AMT := W_PRIN_OD_AMT;
      W_CHK_PRIN_OD_AMT := W_OD_AMT;
      WHILE (W_EXIT = 0) LOOP
        GET_PRI_OD_DATE_SUB;
      END LOOP;
    END IF;
  END GET_PRIN_OD_DATE;

  -- End To Calculate DUE Date
  FUNCTION GET_CREDIT_AMT(V_ACC_NUM VARCHAR) RETURN NUMBER IS
    V_TOT_MIG_CR_AMT NUMBER(18, 3) := 0;
    V_TOT_INT_CR_AMT NUMBER(18, 3) := 0;
  BEGIN
    V_TOT_MIG_CR_AMT := 0;
    V_TOT_INT_CR_AMT := 0;
    <<MIG_CREDIT>>
    BEGIN
      SELECT NVL(L.LNTOTINTDB_TOT_PRIN_DB_AMT, 0)
        INTO V_TOT_MIG_CR_AMT
        FROM LNTOTINTDBMIG L
       WHERE L.LNTOTINTDB_INTERNAL_ACNUM = V_ACC_NUM;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_TOT_MIG_CR_AMT := 0;
    END MIG_CREDIT;

    <<INT_CREDIT>>
    BEGIN
      SELECT NVL(ADVBAL_PRIN_BC_CR_SUM, 0) + NVL(ADVBAL_INTRD_BC_CR_SUM, 0) +
             NVL(ADVBAL_CHARGE_BC_CR_SUM, 0)
        INTO V_TOT_INT_CR_AMT
        FROM ADVBAL
       WHERE ADVBAL_INTERNAL_ACNUM = V_ACC_NUM;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_TOT_INT_CR_AMT := 0;
    END INT_CREDIT;
    IF V_TOT_INT_CR_AMT IS NULL THEN
      V_TOT_INT_CR_AMT := 0;
    END IF;
    RETURN(ABS(V_TOT_MIG_CR_AMT) + ABS(V_TOT_INT_CR_AMT));
  END GET_CREDIT_AMT;
  --=

  PROCEDURE CALC_OD_TERM_LOAN_PROC IS
    W_S_LIMIT_AMT  NUMBER(18, 3) := 0;
    W_MIG_END_DATE DATE := NULL;
    W_TOT_CR_AMT   NUMBER(18, 3) := 0;

    W_PAID_AMOUNT NUMBER(18, 3) := 0;

  BEGIN
    W_TOT_DISB_AMOUNT := 0;
    FETCH_LLACNTOS(W_INTERNAL_ACNUM, W_TOT_DISB_AMOUNT);
    GET_TOT_INT_DB_MIG;

    -- Start Method 1

    W_PAID_AMOUNT := (ABS(NVL(W_TOT_DISB_AMOUNT, 0)) +
                     NVL(W_TOT_INT_DB_MIG, 0) + ABS(W_TOT_INT_DB_SO_FAR) +
                     ABS(W_TOT_CHGS_DB_SO_FAR)) - ABS(W_ASON_AC_BAL);

    W_OD_AMT := ABS(W_TOT_REPAY_AMT) - W_PAID_AMOUNT;
    /*
    DBMS_OUTPUT.PUT_LINE('=================');
    DBMS_OUTPUT.put_line('TOT_REPAY_AMT = ' || W_TOT_REPAY_AMT);
    DBMS_OUTPUT.put_line('PAID AMT = ' || ABS(NVL(W_TOT_DISB_AMOUNT, 0)) || '+' ||
                         NVL(W_TOT_INT_DB_MIG, 0) || '+ ' ||
                         ABS(W_TOT_INT_DB_SO_FAR) || '+ ' ||
                         ABS(W_TOT_CHGS_DB_SO_FAR) || '-' ||
                         ABS(W_ASON_AC_BAL) || '=' || W_PAID_AMOUNT);

    DBMS_OUTPUT.PUT_LINE('W_OD_AMT = ' || W_OD_AMT);
    DBMS_OUTPUT.PUT_LINE('=================');*/
    -- End Method 1

    W_TOT_INT_DB_MIG     := 0;
    W_TOT_INT_DB_SO_FAR  := 0;
    W_TOT_CHGS_DB_SO_FAR := 0;

    IF W_IS_LIMIT_EXP AND W_ASON_AC_BAL < 0 THEN
      W_OD_AMT := ABS(W_ASON_AC_BAL);
    ELSIF W_ASON_AC_BAL > 0 THEN
      W_OD_AMT := 0;
    ELSIF W_OD_AMT > 0 THEN
      W_OD_AMT := ABS(W_OD_AMT);
    ELSE
      W_OD_AMT := 0;
    END IF;

    --== CHARGE BF
    IF W_OD_AMT > 0 AND W_OD_AMT > ABS(W_CHGS_OS) THEN
      W_CHG_OD_AMT := ABS(W_CHGS_OS);
      W_TMP_OD_AMT := W_OD_AMT - W_CHG_OD_AMT;
    ELSIF W_OD_AMT > 0 THEN
      W_CHG_OD_AMT := W_OD_AMT;
      W_TMP_OD_AMT := 0;
    END IF;

    --== INT BF
    IF W_TMP_OD_AMT > 0 AND W_TMP_OD_AMT > ABS(W_INT_OS) THEN
      W_INT_OD_AMT  := ABS(W_INT_OS);
      W_PRIN_OD_AMT := W_TMP_OD_AMT - W_INT_OD_AMT;
    ELSE
      W_INT_OD_AMT := ABS(W_TMP_OD_AMT);
      W_TMP_OD_AMT := 0;
    END IF;

    -- Finding OD Date.
    IF (W_OD_AMT > 0) THEN
      GET_PRIN_OD_DATE;
    END IF;

  END CALC_OD_TERM_LOAN_PROC;

  PROCEDURE TRANADV_PROC IS
    V_WP VARCHAR2(5);
  BEGIN
    IF PKG_LOAN_INT_CALC_PROCESS.V_OVERDUR_LOAN_ACC = TRUE THEN
      W_SQL := 'SELECT TRANADV_INTRD_BC_AMT, TRANADV_CHARGE_BC_AMT,TRAN_DB_CR_FLG,TRAN_DATE_OF_TRAN FROM TEMP_LOAN_OVERDUE
        WHERE VALUE_YEAR=:1 AND TRAN_INTERNAL_ACNUM=:2';

      IF (V_REPHASEMENT_ENTRY = 1 AND V_PURPOSE_CODE = 'R') THEN
        W_SQL := W_SQL || ' AND TRAN_DATE_OF_TRAN >= ' || CHR(39) ||
                 W_LAT_EFF_DATE || CHR(39);
      END IF;
      EXECUTE IMMEDIATE W_SQL BULK COLLECT
        INTO TRAN_REC
        USING W_PROC_YEAR, W_INTERNAL_ACNUM;
    ELSIF PKG_LNOVERDUE.V_OVERDUE_EOD_PROC THEN
      W_SQL := 'SELECT TRANADV_INTRD_BC_AMT, TRANADV_CHARGE_BC_AMT,TRAN_DB_CR_FLG,TRAN_DATE_OF_TRAN FROM MV_LOAN_ACCOUNT_BAL_OD
        WHERE VALUE_YEAR=:1 AND TRAN_INTERNAL_ACNUM=:2 AND TRAN_DATE_OF_TRAN <= :3';
      --Note: Rescheduling Purpose,
      IF (V_REPHASEMENT_ENTRY = 1 AND V_PURPOSE_CODE = 'R') THEN
        W_SQL := W_SQL || ' AND TRAN_DATE_OF_TRAN >= ' || CHR(39) ||
                 W_LAT_EFF_DATE || CHR(39);
      END IF;

      EXECUTE IMMEDIATE W_SQL BULK COLLECT
        INTO TRAN_REC
        USING W_PROC_YEAR, W_INTERNAL_ACNUM, W_ASON_DATE;
    ELSE
      W_SQL := 'SELECT TRANADV_INTRD_BC_AMT, TRANADV_CHARGE_BC_AMT,TRAN_DB_CR_FLG,TRAN_DATE_OF_TRAN FROM TRANADV' ||
               W_PROC_YEAR || ', TRAN' || W_PROC_YEAR ||
               ' WHERE TRAN_ENTITY_NUM = :1 AND TRANADV_ENTITY_NUM = :2 AND
                 TRAN_DATE_OF_TRAN <= ' || CHR(39) ||
               W_ASON_DATE || CHR(39) || ' AND TRAN_INTERNAL_ACNUM = ' ||
               W_INTERNAL_ACNUM ||
               ' AND
                 TRAN_AUTH_ON IS NOT NULL AND
                 TRANADV_BRN_CODE = TRAN_BRN_CODE AND
                 TRANADV_DATE_OF_TRAN = TRAN_DATE_OF_TRAN AND
                 TRANADV_BATCH_NUMBER = TRAN_BATCH_NUMBER AND
                 TRANADV_BATCH_SL_NUM = TRAN_BATCH_SL_NUM';
      -- Note: Rescheduling Purpose
      IF (V_REPHASEMENT_ENTRY = 1 AND V_PURPOSE_CODE = 'R') THEN
        W_SQL := W_SQL || ' AND TRAN_DATE_OF_TRAN >= ' || CHR(39) ||
                 W_LAT_EFF_DATE || CHR(39);
      END IF;

      EXECUTE IMMEDIATE W_SQL BULK COLLECT
        INTO TRAN_REC
        USING V_GLOB_ENTITY_NUM, V_GLOB_ENTITY_NUM;

    END IF;
    J := 0;
    IF TRAN_REC.FIRST IS NOT NULL THEN
      FOR J IN TRAN_REC.FIRST .. TRAN_REC.LAST LOOP
        W_INTRD_BC_AMT  := TRAN_REC(J).V_INTRD_BC_AMT;
        W_CHARGE_BC_AMT := TRAN_REC(J).V_CHARGE_BC_AMT;
        W_DB_CR_FLG     := TRAN_REC(J).V_DB_CR_FLG;
        W_DATE_OF_TRAN  := TRAN_REC(J).V_DATE_OF_TRAN;

        W_INT_IGN := 0;

        IF W_INTRD_BC_AMT > 0 THEN
          IF (W_DB_CR_FLG = 'D') THEN
            W_TOT_INT_DB := W_TOT_INT_DB + W_INTRD_BC_AMT;
          ELSE
            W_TOT_INT_CR := W_TOT_INT_CR + W_INTRD_BC_AMT;
          END IF;
        END IF;

        IF W_CHARGE_BC_AMT > 0 THEN
          IF (W_DB_CR_FLG = 'D') THEN
            W_TOT_CHGS_DB := W_TOT_CHGS_DB + W_CHARGE_BC_AMT;
          ELSE
            W_TOT_CHGS_CR := W_TOT_CHGS_CR + W_CHARGE_BC_AMT;
          END IF;
        END IF;

        IF (W_INTRD_BC_AMT > 0) THEN
          IF (W_DB_CR_FLG = 'D') THEN
            IF (W_INT_RECOVERY_OPTION = '1') THEN
              --DBMS_OUTPUT.PUT_LINE('-');
              V_WP := '';
            ELSE
              IF (W_INT_RECOVERY_OPTION = '2') AND
                 (W_PROD_FOR_RUN_ACS <> '1') THEN
                --DBMS_OUTPUT.PUT_LINE('CHECK_FINAL_DUE_DATE');
                V_WP := '';
              ELSE
                IF (W_INT_RECOVERY_OPTION = '3') THEN
                  --DBMS_OUTPUT.PUT_LINE('GET_NEXT_REPAY_DUE_DATE');
                  V_WP := '';
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;

        W_INT_OS := W_TOT_INT_CR - W_TOT_INT_DB;

        IF (W_INT_OS < 0) AND (W_INT_DUE_FROM_DATE IS NULL) AND
           (W_INT_IGN = 0) THEN
          W_INT_DUE_FROM_DATE := W_ACT_INT_DUE_DATE;
        END IF;

        IF (W_INT_OS >= 0) THEN
          W_INT_DUE_FROM_DATE := NULL;
          W_INT_OS            := 0;
        END IF;

        W_CHGS_OS := W_TOT_CHGS_CR - W_TOT_CHGS_DB;

        IF (W_CHGS_OS < 0) AND (W_CHG_DUE_FROM_DATE IS NULL) THEN
          W_CHG_DUE_FROM_DATE := W_DATE_OF_TRAN;
        END IF;

        IF (W_CHGS_OS >= 0) THEN
          W_CHG_DUE_FROM_DATE := NULL;
          W_CHGS_OS           := 0;
        END IF;

        --  Noor(Avoid the ADV entry of on Migartion Date )
        IF W_DB_CR_FLG = 'D' THEN
          IF W_ACC_MIG_DATE = W_DATE_OF_TRAN THEN

            W_INTRD_BC_AMT  := 0;
            W_CHARGE_BC_AMT := 0;
          END IF;
          W_TOT_INT_DB_SO_FAR  := W_TOT_INT_DB_SO_FAR + W_INTRD_BC_AMT;
          W_TOT_CHGS_DB_SO_FAR := W_TOT_CHGS_DB_SO_FAR + W_CHARGE_BC_AMT;
        END IF;

      ---
      END LOOP;

    END IF;

    <<TABLE_NOT_FOUND>> -- added by rajib.pradhan for handle table not found exception
    W_ERROR := NULL;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      W_ERROR := '';
  END TRANADV_PROC;

  PROCEDURE OVERDUE_FOR_TERM_LOANS_PROC IS
  BEGIN
    W_REPH_ON_AMT := 0;
    FETCH_TOT_REPAY_AMT_PROC(W_INTERNAL_ACNUM, W_ASON_DATE);
    FETCH_TOT_INT_CHG_AMT_PROC;
    CALC_OD_TERM_LOAN_PROC;

  END OVERDUE_FOR_TERM_LOANS_PROC;

  PROCEDURE SP_LNOVERDUE(V_ENTITY_NUM        IN NUMBER,
                         P_INTERNAL_ACNUM    IN NUMBER,
                         P_ASON_DATE         IN VARCHAR2,
                         P_CBD_DATE          IN VARCHAR2,
                         P_ERR_MSG           OUT VARCHAR2,
                         P_CURR_AC_BAL       OUT NUMBER,
                         P_ACTUAL_LIMIT_AMT  OUT NUMBER,
                         P_ACTUAL_DP_AMT     OUT NUMBER,
                         P_LIMIT_AMT         OUT NUMBER,
                         P_OD_AMT            OUT NUMBER,
                         P_OD_DATE           OUT VARCHAR2,
                         P_PRIN_OD_AMT       OUT NUMBER,
                         P_PRIN_OD_DATE      OUT VARCHAR,
                         P_INT_OD_AMT        OUT NUMBER,
                         P_INT_DUE_FROM_DATE OUT VARCHAR,
                         P_CHG_OD_AMT        OUT NUMBER,
                         P_CHG_DUE_FROM_DATE OUT VARCHAR,
                         --
                         W_CURR_CODE                 IN VARCHAR DEFAULT NULL,
                         W_OPENING_DATE              IN DATE DEFAULT NULL,
                         W_MIG_DATE                  IN DATE DEFAULT NULL,
                         W_ACC_PROD_CODE             IN NUMBER DEFAULT 0,
                         W_LNPRD_INT_RECOVERY_OPTION IN CHAR DEFAULT '0',
                         W_PRODUCT_FOR_RUN_ACS       IN VARCHAR DEFAULT NULL,
                         W_LIMIT_EXPIRY_DATE         IN DATE DEFAULT NULL,
                         W_ACASLL_CLINET_NUM         IN NUMBER DEFAULT 0,
                         W_ACASLL_LIMITLINE_NUM      IN NUMBER DEFAULT 0,
                         W_CALLER_FLAG               IN NUMBER DEFAULT 0
                         --
                         ) IS

    V_REPAY_FREQ         VARCHAR2(5);
    V_RESTRICT_PROD_CODE NUMBER;
  BEGIN

    PKG_ENTITY.SP_SET_ENTITY_CODE(V_ENTITY_NUM);
    V_GLOB_ENTITY_NUM := V_ENTITY_NUM;

    <<START_PROC>>
    BEGIN
      INIT_PARA;
      V_REPAY_FREQ  := '';
      W_ASON_DATE   := TO_DATE(P_ASON_DATE, 'DD-MM-YYYY');
      W_CBD         := TO_DATE(P_CBD_DATE, 'DD-MM-YYYY');
      V_CALLER_FLAG := NVL(W_CALLER_FLAG, 0);

      IF (P_INTERNAL_ACNUM IS NULL) THEN
        W_INTERNAL_ACNUM := 0;
      ELSE
        W_INTERNAL_ACNUM := P_INTERNAL_ACNUM;
      END IF;

      IF (W_INTERNAL_ACNUM = 0) THEN
        W_ERROR := 'Invalid Account Number';
        RAISE E_USEREXCEP;
      END IF;

      IF (W_ASON_DATE IS NULL) THEN
        W_ERROR := 'Ason Date Should Be Specified';
        RAISE E_USEREXCEP;
      END IF;

      IF (W_CBD IS NULL) THEN
        W_ERROR := 'Current Business Date not Specified';
        RAISE E_USEREXCEP;
      END IF;

      IF (W_ASON_DATE > W_CBD) THEN
        W_ERROR := 'Ason Date Should be Less than or Equal to Current Business Date ';
        RAISE E_USEREXCEP;
      END IF;

      PKG_LNOVERDUE.INIT_ACTUAL_PRIN;
      <<GET_LOAN_DUE_DATE>>
    BEGIN
      PKG_LN_UTILITY.SP_LOAN_DUE_DATE(V_GLOB_ENTITY_NUM,W_INTERNAL_ACNUM,W_ASON_DATE,V_GRACE_MON_DUE_DATE,W_ERROR);
       EXCEPTION
       WHEN OTHERS THEN
        V_GRACE_MON_DUE_DATE :=NULL;
        W_ERROR := 'Error in Getting Loan Due Date, Account Number = ' || W_INTERNAL_ACNUM;
        RAISE E_USEREXCEP;
    END GET_LOAN_DUE_DATE;
      --- Added by Tamim
      IF V_CALLER_FLAG <> 0 THEN

     

        W_PROD_FOR_RUN_ACS     := W_PRODUCT_FOR_RUN_ACS;
        W_ACNTS_OPENING_DATE   := W_OPENING_DATE;
        W_ACNTS_CURR_CODE      := W_CURR_CODE;
        W_ACC_MIG_DATE         := W_MIG_DATE;
        W_INT_RECOVERY_OPTION  := W_LNPRD_INT_RECOVERY_OPTION;
        V_LIMIT_EXPIRY_DATE    := W_LIMIT_EXPIRY_DATE;
        V_ACASLL_CLINET_NUM    := W_ACASLL_CLINET_NUM;
        V_ACASLL_LIMITLINE_NUM := W_ACASLL_LIMITLINE_NUM;
        IF V_GRACE_MON_DUE_DATE IS NOT NULL THEN
          IF V_GRACE_MON_DUE_DATE > V_LIMIT_EXPIRY_DATE THEN
            V_LIMIT_EXPIRY_DATE :=V_GRACE_MON_DUE_DATE;
            END IF;
          END IF;
        IF (V_LIMIT_EXPIRY_DATE < W_ASON_DATE) THEN
          W_IS_LIMIT_EXP := TRUE;
        ELSE
          W_IS_LIMIT_EXP := FALSE;
        END IF;

      ELSE

        GETEXPIRYDATE(W_INTERNAL_ACNUM);
        READ_LNDETAILS(P_INTERNAL_ACNUM, P_ASON_DATE);
        FETCH_MIG_DETAILS(W_ACNTS_BRN_CODE, W_ACC_MIG_DATE);

      END IF;
      ----

      FETCH_LLACNTOS(P_INTERNAL_ACNUM, W_TOT_DISB_AMOUNT);

      GET_ASON_ACBAL(V_GLOB_ENTITY_NUM,
                     P_INTERNAL_ACNUM,
                     W_ACNTS_CURR_CODE,
                     W_ASON_DATE,
                     W_CBD,
                     W_ASON_AC_BAL,
                     W_ASON_BC_BAL,
                     W_ERROR);

      IF (W_ERROR IS NOT NULL) THEN
        RAISE E_USEREXCEP;
      END IF;
      W_CURR_AC_BAL := W_ASON_AC_BAL;

      PKG_SP_INTERFACE.SP_GETLMTASONDATE(V_GLOB_ENTITY_NUM,
                                         0,
                                         0,
                                         P_INTERNAL_ACNUM,
                                         W_ASON_DATE,
                                         W_LIMIT_AMT,
                                         W_ACTUAL_LIMIT_AMT,
                                         W_ACTUAL_DP_AMT,
                                         W_ERROR);

      W_PRIN_OD_AMT       := 0;
      W_PRIN_OD_DATE      := NULL;
      W_INT_OD_AMT        := 0;
      W_INT_DUE_FROM_DATE := NULL;
      W_CHG_OD_AMT        := 0;
      W_CHG_DUE_FROM_DATE := NULL;

      <<CHECK_DEMAND_LOAN>>
      BEGIN
        SELECT LNACRSHDTL_REPAY_FREQ
          INTO V_REPAY_FREQ
          FROM LNACRSHDTL
         WHERE LNACRSHDTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
           AND LNACRSHDTL_INTERNAL_ACNUM = P_INTERNAL_ACNUM
           AND LNACRSHDTL_EFF_DATE =
               (SELECT MAX(LNACRSHDTL_EFF_DATE)
                  FROM LNACRSHDTL
                 WHERE LNACRSHDTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
                   AND LNACRSHDTL_INTERNAL_ACNUM = P_INTERNAL_ACNUM
                   AND LNACRSHDTL_EFF_DATE <= W_ASON_DATE);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_REPAY_FREQ := '';
      END CHECK_DEMAND_LOAN;

      V_RESTRICT_PROD_CODE := W_ACC_PROD_CODE;
      IF NVL(V_RESTRICT_PROD_CODE, 0) = 0 THEN
        SELECT ACNTS_PROD_CODE
          INTO V_RESTRICT_PROD_CODE
          FROM ACNTS
         WHERE ACNTS_ENTITY_NUM = V_GLOB_ENTITY_NUM
           AND ACNTS_INTERNAL_ACNUM = P_INTERNAL_ACNUM;
      END IF;

      IF (V_RESTRICT_PROD_CODE = 2101 OR V_RESTRICT_PROD_CODE = 2102 OR
         V_RESTRICT_PROD_CODE = 2103 OR V_RESTRICT_PROD_CODE = 2104 OR
         V_RESTRICT_PROD_CODE = 2105 OR V_RESTRICT_PROD_CODE = 2106 OR
         V_RESTRICT_PROD_CODE = 2107 OR V_RESTRICT_PROD_CODE = 2108 OR
         V_RESTRICT_PROD_CODE = 2109 OR V_RESTRICT_PROD_CODE = 2501 OR
         V_RESTRICT_PROD_CODE = 2502 OR V_RESTRICT_PROD_CODE = 2504 OR
         V_RESTRICT_PROD_CODE = 2509 OR V_RESTRICT_PROD_CODE = 2511 OR
         V_RESTRICT_PROD_CODE = 2512 OR V_RESTRICT_PROD_CODE = 2514 OR
         V_RESTRICT_PROD_CODE = 2515 OR V_RESTRICT_PROD_CODE = 2516 OR
         V_RESTRICT_PROD_CODE = 2517 OR V_RESTRICT_PROD_CODE = 2528 OR
         V_RESTRICT_PROD_CODE = 2529 OR V_RESTRICT_PROD_CODE = 2530 OR
         V_RESTRICT_PROD_CODE = 2532 OR V_RESTRICT_PROD_CODE = 2533 OR
         V_RESTRICT_PROD_CODE = 2534 OR V_RESTRICT_PROD_CODE = 2538 OR
         V_RESTRICT_PROD_CODE = 2540 OR V_RESTRICT_PROD_CODE = 2546 OR 
         V_RESTRICT_PROD_CODE = 2553
         ) THEN
        W_PROD_FOR_RUN_ACS := '1';
      END IF;

      IF (W_PROD_FOR_RUN_ACS = '1') OR (V_REPAY_FREQ = 'X') THEN
        --IF (TO_DATE(V_LIMIT_EXPIRY_DATE,'DD-MON-YYYY') <= W_ASON_DATE ) THEN
        IF (V_LIMIT_EXPIRY_DATE < W_ASON_DATE) THEN
          OVERDUE_FOR_RUN_ACNTS_PROC;
          V_REPAY_FREQ := '';
        END IF;
      ELSE
        OVERDUE_FOR_TERM_LOANS_PROC;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        IF TRIM(W_ERROR) IS NULL THEN
          W_ERROR := ' Error in SP_LNOVERDUE ' || SUBSTR(SQLERRM, 1, 100) || '  ' ||
                     SUBSTR(FACNO(V_GLOB_ENTITY_NUM, W_INTERNAL_ACNUM),
                            1,
                            100);
        ELSE
          W_ERROR := ' Error in SP_LNOVERDUE ' || TRIM(W_ERROR) || ' ' ||
                     SUBSTR(SQLERRM, 1, 100) || '  ' ||
                     SUBSTR(FACNO(V_GLOB_ENTITY_NUM, W_INTERNAL_ACNUM),
                            1,
                            100);
        END IF;
    END START_PROC;

    P_ERR_MSG          := W_ERROR;
    P_CURR_AC_BAL      := W_CURR_AC_BAL;
    P_ACTUAL_LIMIT_AMT := W_ACTUAL_LIMIT_AMT;
    P_ACTUAL_DP_AMT    := W_ACTUAL_DP_AMT;
    P_LIMIT_AMT        := W_LIMIT_AMT;
    P_OD_AMT           := W_OD_AMT;

    V_LIMIT_EXPIRY_DATE := TO_DATE(TO_CHAR(V_LIMIT_EXPIRY_DATE,
                                           'DD-MM-YYYY'),
                                   'DD-MM-YYYY');

    --IF P_OD_AMT <> 0 THEN    SAYFULLAH
    IF W_IS_LIMIT_EXP THEN
      P_OD_DATE := TO_CHAR(V_LIMIT_EXPIRY_DATE+1, 'DD-MM-YYYY');
    ELSIF P_OD_AMT <> 0 THEN
      P_OD_DATE := TO_CHAR(W_PRIN_OD_DATE, 'DD-MM-YYYY');
    ELSE
      P_OD_DATE := NULL;
    END IF;

    P_PRIN_OD_AMT := W_PRIN_OD_AMT;
    IF P_PRIN_OD_AMT <> 0 THEN
      IF W_IS_LIMIT_EXP THEN
        P_PRIN_OD_DATE := TO_CHAR(V_LIMIT_EXPIRY_DATE+1, 'DD-MM-YYYY');
      ELSE
        P_PRIN_OD_DATE := TO_CHAR(W_PRIN_OD_DATE, 'DD-MM-YYYY');
      END IF;
    ELSE
      P_PRIN_OD_DATE := NULL;
    END IF;

    P_INT_OD_AMT := W_INT_OD_AMT;
    IF P_INT_OD_AMT <> 0 THEN
      IF W_IS_LIMIT_EXP THEN
        P_INT_DUE_FROM_DATE := TO_CHAR(V_LIMIT_EXPIRY_DATE+1, 'DD-MM-YYYY');
      ELSE
        P_INT_DUE_FROM_DATE := TO_CHAR(W_PRIN_OD_DATE, 'DD-MM-YYYY');
      END IF;
    ELSE
      P_INT_DUE_FROM_DATE := NULL;
    END IF;
    P_CHG_OD_AMT := W_CHG_OD_AMT;
    IF P_CHG_OD_AMT <> 0 THEN
      IF W_IS_LIMIT_EXP THEN
        P_CHG_DUE_FROM_DATE := TO_CHAR(V_LIMIT_EXPIRY_DATE+1, 'DD-MM-YYYY');
      ELSE
        P_CHG_DUE_FROM_DATE := TO_CHAR(W_PRIN_OD_DATE, 'DD-MM-YYYY');
      END IF;
    ELSE
      P_CHG_DUE_FROM_DATE := NULL;
    END IF;
    P_REPH_ON_AMT     := W_REPH_ON_AMT;
    P_TOT_DISB_AMOUNT := ABS(W_TOT_DISB_AMOUNT);

  END SP_LNOVERDUE;

  PROCEDURE INIT_ACTUAL_PRIN IS
  BEGIN
    P_ACTUAL_OD_AMT := 0;
  END INIT_ACTUAL_PRIN;

END PKG_LNOVERDUE;
/
