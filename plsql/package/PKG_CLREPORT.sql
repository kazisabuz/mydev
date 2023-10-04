CREATE OR REPLACE PACKAGE PKG_CLREPORT IS
  TYPE TY_TEMP IS RECORD(
    PG_NO          NUMBER(5),
    Rpt_Descn      VARCHAR2(250),
    Rpt_Short_Desc VARCHAR2(250),
    Rpt_head_code  VARCHAR2(50),
    -----BALANCE OUTSTANDING -----

    BAL_UNCLASS  NUMBER(18, 3),
    BAL_SPECIAL  NUMBER(18, 3),
    BAL_SUBSS    NUMBER(18, 3),
    BAL_DOUBT    NUMBER(18, 3),
    BAL_BAD_LOSS NUMBER(18, 3),
    TOT_BAL_OUT  NUMBER(18, 3),
    ---BASE FOR PROVISION---
    PRO_BASE_UN NUMBER(18, 3),
    PRO_BASE_SP NUMBER(18, 3),
    PRO_BASE_SS NUMBER(18, 3),
    PRO_BASE_DF NUMBER(18, 3),
    PRO_BASE_BL NUMBER(18, 3),
    ---AMOUNT FOR PROVISION REQURIED---

    AMT_PROV_RE NUMBER(18, 3),
    ---INTEREST SUSPENSE ON
    INT_SUS_UN  NUMBER(18, 3),
    INT_SUS_SP  NUMBER(18, 3),
    INT_CLA_TOT NUMBER(18, 3),
    INT_SUS_SS  NUMBER(18, 3),
    INT_SUS_DF  NUMBER(18, 3),
    INT_SUS_BL  NUMBER(18, 3),
    INT_SUS_TOT NUMBER(18, 3),
    -- TO GET BSR CODE FOR BRANCH
    SEC_VAL   NUMBER(18, 3),
    BRN_BSRCD NUMBER(6), -- ADDED BY VIJAY ON 12TH MARCH 2013
    INT_SS_MIN_SUM NUMBER(18, 3)
    );

  TYPE TY_TEMP_WS IS RECORD(
    CL_SL_NO         NUMBER(5),
    CL_NO            VARCHAR2(10),
    CL_PAGE_NO       NUMBER(5),
    CL_BRN_NAME      VARCHAR2(150),
    CL_OS_BAL        NUMBER(18, 3),
    CL_OS_UC_ST_BAL  NUMBER(18, 3),
    CL_OS_UC_SMA_BAL NUMBER(18, 3),
    CL_OS_SS_BAL     NUMBER(18, 3),
    CL_OS_DF_BAL     NUMBER(18, 3),
    CL_OS_BL_BAL     NUMBER(18, 3),
    CL_PROV_SMA_BAL  NUMBER(18, 3),
    CL_PROV_SS_BAL   NUMBER(18, 3),
    CL_PROV_DF_BAL   NUMBER(18, 3),
    CL_PROV_BL_BAL   NUMBER(18, 3),
    CL_SEC_VAL       NUMBER(18, 3),
    CL_SUSP_ST_BAL   NUMBER(18, 3),
    CL_SUSP_SMA_BAL  NUMBER(18, 3),
    CL_SUSP_CL_BAL   NUMBER(18, 3),
    CL_TOTAL_BAL     NUMBER(18, 3),
    CL_OS_DEF_BAL    NUMBER(18, 3));

  TYPE TY_TMP IS TABLE OF TY_TEMP;
  TYPE TY_TMP_WS IS TABLE OF TY_TEMP_WS;

  FUNCTION CL_RPT(P_ENTITY_NUM IN NUMBER,
                  P_ASON_DATE  IN DATE,
                  P_BRN_CODE   IN NUMBER) RETURN TY_TMP
    PIPELINED;

     FUNCTION CL_RPT_CONSOLIDATED(P_ENTITY_NUM IN NUMBER,
                  P_ASON_DATE  IN DATE,
                  P_BRN_CODE   IN NUMBER) RETURN TY_TMP
    PIPELINED;
  --RETURN VARCHAR2;

  FUNCTION CL_RPT_WORKSHEET(P_ENTITY_NUM IN NUMBER,
                            P_ASON_DATE  IN DATE,
                            P_BRN_CODE   IN NUMBER) RETURN TY_TMP_WS
    PIPELINED;
  --RETURN VARCHAR2;
  FUNCTION GET_SECURED_VALUE(INTERNAL_ACNUM   VARCHAR2,
                             W_ASON_DATE      DATE,
                             W_CBD            DATE,
                             W_BASE_CURR_CODE VARCHAR2) RETURN NUMBER;
  FUNCTION GET_LOAN_SUSPBAL(P_ACNUM NUMBER, P_CURR VARCHAR2) RETURN NUMBER;

END PKG_CLREPORT;
/

CREATE OR REPLACE PACKAGE BODY PKG_CLREPORT IS
  PRINT             PKG_CLREPORT.TY_TEMP;
  PRINT_WS          PKG_CLREPORT.TY_TEMP_WS;
  V_GLOB_ENTITY_NUM MAINCONT.MN_ENTITY_NUM%TYPE;
  W_SQL             VARCHAR2(10000);
  W_ERROR           VARCHAR2(100);
  -- TOT
  TOT_CL_OS_BAL        NUMBER(18, 3) := 0;
  TOT_CL_OS_UC_ST_BAL  NUMBER(18, 3) := 0;
  TOT_CL_OS_UC_SMA_BAL NUMBER(18, 3) := 0;
  TOT_CL_OS_SS_BAL     NUMBER(18, 3) := 0;
  TOT_CL_OS_DF_BAL     NUMBER(18, 3) := 0;
  TOT_CL_OS_DEF_BAL    NUMBER(18, 3) := 0;
  TOT_CL_OS_BL_BAL     NUMBER(18, 3) := 0;
  TOT_CL_PROV_SMA_BAL  NUMBER(18, 3) := 0;
  TOT_CL_PROV_SS_BAL   NUMBER(18, 3) := 0;
  TOT_CL_PROV_DF_BAL   NUMBER(18, 3) := 0;
  TOT_CL_PROV_BL_BAL   NUMBER(18, 3) := 0;
  TOT_CL_SEC_VAL       NUMBER(18, 3) := 0;
  TOT_CL_SUSP_ST_BAL   NUMBER(18, 3) := 0;
  TOT_CL_SUSP_SMA_BAL  NUMBER(18, 3) := 0;
  TOT_CL_SUSP_CL_BAL   NUMBER(18, 3) := 0;
  TOT_CL_TOTAL_BAL     NUMBER(18, 3) := 0;
  W_SUSP_BAL           NUMBER(18, 3) := 0;
  W_DUMMY_BAL          NUMBER(18, 3);
  -- SEC
  W_SEC_TYPE          VARCHAR2(6) := '';
  W_SECPROV_VALID_FLG VARCHAR2(1) := '';
  W_SECPROV_DISC_PER  NUMBER := 0;
  W_ASON_DATE         DATE := NULL;
  W_CBD               DATE := NULL;
  W_SEC_CURR_CODE     VARCHAR2(3);
  W_SECURED_VALUE     NUMBER;
  W_SEC_AMT           NUMBER;
  W_TOT_SEC_AMT_AC    NUMBER;
  W_TOT_SEC_AMT_BC    NUMBER;
  LN_SUSPBAL          NUMBER(18, 3) := 0;
  -- Off banance sheet
  P_GL_BAL_AC             NUMBER(18, 3);
  P_GL_BAL_BC             NUMBER(18, 3);
  P_TOT_OFF_BAL_SHEET_AMT NUMBER(18, 3);
  V_CL4_SS_DATA           NUMBER (18, 3);
  V_SS_SUBTOTAL       NUMBER(18,3) ;

  PROCEDURE RESET_TOT_VALUES IS
  BEGIN
    TOT_CL_OS_BAL        := 0;
    TOT_CL_OS_UC_ST_BAL  := 0;
    TOT_CL_OS_UC_SMA_BAL := 0;
    TOT_CL_OS_SS_BAL     := 0;
    TOT_CL_OS_DF_BAL     := 0;
    TOT_CL_OS_DEF_BAL    := 0;
    TOT_CL_OS_BL_BAL     := 0;
    TOT_CL_PROV_SMA_BAL  := 0;
    TOT_CL_PROV_SS_BAL   := 0;
    TOT_CL_PROV_DF_BAL   := 0;
    TOT_CL_PROV_BL_BAL   := 0;
    TOT_CL_SEC_VAL       := 0;
    TOT_CL_SUSP_ST_BAL   := 0;
    TOT_CL_SUSP_SMA_BAL  := 0;
    TOT_CL_SUSP_CL_BAL   := 0;
    TOT_CL_TOTAL_BAL     := 0;
  END RESET_TOT_VALUES;

  FUNCTION CL_RPT(P_ENTITY_NUM IN NUMBER,
                  P_ASON_DATE  IN DATE,
                  P_BRN_CODE   IN NUMBER) RETURN TY_TMP
    PIPELINED
  --RETURN VARCHAR2
   IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    E_USEREXCEP EXCEPTION;
    W_ERROR_MSG VARCHAR2(30);
    W_DUMMY     NUMBER;

    AMT_CLASS          NUMBER(18, 3) := 0;
    PROVISION_BASE_AMT NUMBER(18, 3) := 0;
    INT_SUSPENSE_AMT   NUMBER(18, 3) := 0;
    V_BAL_UN           NUMBER(18, 3) := 0;
    V_BAL_SP           NUMBER(18, 3) := 0;
    V_BAL_SUB          NUMBER(18, 3) := 0;
    V_BAL_DOU          NUMBER(18, 3) := 0;
    V_BAL_BLOS         NUMBER(18, 3) := 0;
    V_TOT_BAL_AMT      NUMBER(18, 3) := 0;
    V_PRO_BASE_UN      NUMBER(18, 3) := 0;
    V_PRO_BASE_SP      NUMBER(18, 3) := 0;
    V_PRO_BASE_SUB     NUMBER(18, 3) := 0;
    V_PRO_BASE_DF      NUMBER(18, 3) := 0;
    V_PRO_BASE_BL      NUMBER(18, 3) := 0;
    V_INT_SUS_UN       NUMBER(18, 3) := 0;
    V_INT_SUS_SP       NUMBER(18, 3) := 0;
    V_INT_SUS_SS       NUMBER(18, 3) := 0;
    V_INT_SUS_DF       NUMBER(18, 3) := 0;
    V_INT_SUS_BL       NUMBER(18, 3) := 0;
    V_INT_SUS_TO       NUMBER(18, 3) := 0;
    V_TOT_AMT_PROV_REQ NUMBER(18, 3) := 0;
    PG_NUMBER          NUMBER(5) := 0;
    BC_PROV_AMT        NUMBER(18, 3) := 0;
    V_TOT_SEC_AMT1     NUMBER(18, 3) := 0;
    V_TOT_SEC_AMT      NUMBER(18, 3) := 0;

    SUBTOTAL_BAL_UN  NUMBER(18, 3) := 0;
    SUBTOTAL_BAL_SP  NUMBER(18, 3) := 0;
    SUBTOTAL_BAL_SS  NUMBER(18, 3) := 0;
    SUBTOTAL_BAL_DF  NUMBER(18, 3) := 0;
    SUBTOTAL_BAL_BL  NUMBER(18, 3) := 0;
    SUBTOTAL_BAL_TOT NUMBER(18, 3) := 0;

    SUBTOTAL_BASE_UN NUMBER(18, 3) := 0;
    SUBTOTAL_BASE_SP NUMBER(18, 3) := 0;
    SUBTOTAL_BASE_SS NUMBER(18, 3) := 0;
    SUBTOTAL_BASE_DF NUMBER(18, 3) := 0;
    SUBTOTAL_BASE_BL NUMBER(18, 3) := 0;

    SUBTOTAL_INS_UN  NUMBER(18, 3) := 0;
    SUBTOTAL_INS_SP  NUMBER(18, 3) := 0;
    SUBTOTAL_INS_SS  NUMBER(18, 3) := 0;
    SUBTOTAL_INS_DF  NUMBER(18, 3) := 0;
    SUBTOTAL_INS_BL  NUMBER(18, 3) := 0;
    SUBTOTAL_INS_TOT NUMBER(18, 3) := 0;
    V_SUBTOT_SEC_AMT NUMBER(18, 3) := 0;

    GRANDTOTAL_BAL_UN  NUMBER(18, 3) := 0;
    GRANDTOTAL_BAL_SP  NUMBER(18, 3) := 0;
    GRANDTOTAL_BAL_SS  NUMBER(18, 3) := 0;
    GRANDTOTAL_BAL_DF  NUMBER(18, 3) := 0;
    GRANDTOTAL_BAL_BL  NUMBER(18, 3) := 0;
    GRANDTOTAL_BAL_TOT NUMBER(18, 3) := 0;

    GRANDTOTAL_BASE_UN NUMBER(18, 3) := 0;
    GRANDTOTAL_BASE_SP NUMBER(18, 3) := 0;
    GRANDTOTAL_BASE_SS NUMBER(18, 3) := 0;
    GRANDTOTAL_BASE_DF NUMBER(18, 3) := 0;
    GRANDTOTAL_BASE_BL NUMBER(18, 3) := 0;

    GRANDTOTAL_INS_UN  NUMBER(18, 3) := 0;
    GRANDTOTAL_INS_SP  NUMBER(18, 3) := 0;
    GRANDTOTAL_INS_SS  NUMBER(18, 3) := 0;
    GRANDTOTAL_INS_DF  NUMBER(18, 3) := 0;
    GRANDTOTAL_INS_BL  NUMBER(18, 3) := 0;
    GRANDTOTAL_INS_TOT NUMBER(18, 3) := 0;
    V_GRANDTOT_SEC_AMT NUMBER(18, 3) := 0;

    -----AMOUNT PROVISION REQUIRED---
    V_AMT_PROV_REQ         NUMBER(18, 3) := 0;
    SUBTOTAL_AMT_PRO_REQ   NUMBER(18, 3) := 0;
    GRANDTOTAL_AMT_PRO_REQ NUMBER(18, 3) := 0;
    ---AMOUNT PROVISION REQUIRED---

    ---SUSANTHA CHANGES---
    V_INT_CLA              NUMBER(18, 3) := 0;
    SUBTOTAL_INS_CLA_TOT   NUMBER(18, 3) := 0;
    GRANDTOTAL_INS_CLA_TOT NUMBER(18, 3) := 0;
    -----------------

    V_ASON_AC_BAL   NUMBER(18, 3) := 0;
    V_CURR_BUS_DATE DATE;
    V_ASON_BC_BAL   NUMBER(18, 3) := 0;
    V_ERR_MSG       NUMBER(18, 3) := 0;
    O_SECURITY_VAL  NUMBER(18, 3);
    TMP_BP_SM_AMT   NUMBER(18, 3) := 0;
    TMP_BP_SS_AMT   NUMBER(18, 3) := 0;
    TMP_BP_DF_AMT   NUMBER(18, 3) := 0;
    TMP_BP_BL_AMT   NUMBER(18, 3) := 0;

    GET_SUS_SM_AMT NUMBER(18, 3) := 0;
    GET_SUS_SS_AMT NUMBER(18, 3) := 0;
    GET_SUS_DF_AMT NUMBER(18, 3) := 0;
    GET_SUS_BL_AMT NUMBER(18, 3) := 0;

    O_ASON_AMT NUMBER(18, 3) := 0;

    W_BASE_PRO_CAL_SM NUMBER(18, 3) := 0;
    W_BASE_PRO_CAL_SS NUMBER(18, 3) := 0;
    W_BASE_PRO_CAL_DF NUMBER(18, 3) := 0;
    W_BASE_PRO_CAL_BL NUMBER(18, 3) := 0;

    PERCENTAGE NUMBER(5, 2) := 0;

    --NEWELY ADDED VARIABLES  START--

    V_ERR_MSG        VARCHAR2(200);
    V_SECURITY_VALUE NUMBER(18, 3) DEFAULT 0;
    W_DF_PROV_BASE   NUMBER(18, 3) DEFAULT 0;
    W_RATE_TYPE      VARCHAR2(8);
    W_RATE_TYPE_FLG  VARCHAR2(1);
    W_ERROR          VARCHAR2(1300);

    W_SEC_TYPE           VARCHAR2(6);
    W_SECPROV_VALID_FLG  VARCHAR2(1);
    W_SECPROV_DISC_PER   NUMBER;
    W_LIM_LINE_NUM       NUMBER;
    W_LIM_CLIENT         NUMBER;
    W_ASSIGN_PERC        NUMBER;
    W_SEC_NUM            NUMBER;
    W_SEC_CURR_CODE      VARCHAR2(3);
    W_SECURED_VALUE      NUMBER(18, 3);
    W_SEC_AMT            NUMBER(18, 3);
    W_CURR_CODE          VARCHAR2(3);
    W_SEC_AMT_ACNT_CURR  NUMBER(18, 3);
    W_SEC_AMT_BASE_CURR  NUMBER(18, 3);
    DUMMY                NUMBER;
    W_BASE_CURR_CODE     VARCHAR2(3);
    W_TOT_SEC_AMT_AC     NUMBER(18, 3);
    W_TOT_SEC_AMT_BC     NUMBER(18, 3);
    W_TOT_SEC_AMT        NUMBER(18, 3);
    W_REDUCE_TANG_SEC    VARCHAR2(1);
    W_SEC_VAL_REDUCE_PER NUMBER;
    W_SEC_RED_AMT_AC     NUMBER(18, 3);
    W_SEC_RED_AMT_BC     NUMBER(18, 3);
    W_PROVPM_DATE        DATE;
    W_TOT_CL4_SS_DATA    NUMBER (18, 3):= 0;

    --NEWELY ADDED VARIABLES  END --

    TYPE RR_TABLEA IS RECORD(
      TMP_CL_DESCN VARCHAR2(200),
      TMP_CL_CODE  VARCHAR2(50));

    TYPE TABLEA IS TABLE OF RR_TABLEA INDEX BY PLS_INTEGER;

    V_TEMP_TABLEA TABLEA;

    TYPE RR_TABLED IS RECORD(
      TMP_ASSET_CODE  VARCHAR2(5),
      TMP_ASSET_CLASS CHAR(1),
      TMP_PER_CAT     CHAR(1),
      TMP_NONPER_CAT  CHAR(1),
      TMP_ASON_AMT    NUMBER(18, 3) ,
      TMP_LNSUP_AMT   NUMBER(18, 3),
      TMP_SECURITY_AMT NUMBER(18, 3),
      TMP_BASE_PROV_AMT_BC NUMBER(18, 3),
      TMP_BC_PROV_AMT NUMBER(18, 3)

      );

    TYPE TABLED IS TABLE OF RR_TABLED INDEX BY PLS_INTEGER;

    V_TEMP_TABLED TABLED;

    TYPE RR_TABLEF IS RECORD(
      TMP_ASSET_CODE  VARCHAR2(5),
      TMP_ASSET_CLASS CHAR(1),
      TMP_PER_CAT     CHAR(1),
      TMP_NONPER_CAT  CHAR(1),
      TMP_LNSUP_AMT   NUMBER(18, 3));

    TYPE TABLEF IS TABLE OF RR_TABLEF INDEX BY PLS_INTEGER;

    V_TEMP_TABLEF TABLEF;

    TYPE RR_TABLEG IS RECORD(
      TMP_AC_NUMBER VARCHAR2(14),
      TMP_CURR_CODE VARCHAR2(3),
      --TMP_PROD_CODE NUMBER(4), -- COMMENTED BY VIJAY ON 14TH 04 2013
      TMP_HODEPT_CODE    VARCHAR2(4),
      TMP_CLIENT_CODE    NUMBER(12),
      TMP_LIMIT_NUM      NUMBER(6),
      TMP_ASSET_CODE     VARCHAR2(5),
      TMP_ASSET_CLASS    CHAR(1),
      TMP_PER_CAT        CHAR(1),
      TMP_NONPER_CAT     CHAR(1),
      TMP_GET_ASON_ACBAL NUMBER(18, 3));

    TYPE TABLEG IS TABLE OF RR_TABLEG INDEX BY PLS_INTEGER;

    V_TEMP_TABLEG TABLEG;

    TYPE RR_TABLEH IS RECORD(
      TMP_AC_NUMBER        NUMBER,
      TMP_ASSET_CODE       VARCHAR2(5),
      TMP_BASE_PROV_AMT_BC NUMBER(18, 3),
      TMP_ASSET_CLASS      CHAR(1),
      TMP_PER_CAT          CHAR(1),
      TMP_NONPER_CAT       CHAR(1),
      TMP_HODEPT_CODE      VARCHAR2(4),
      TMP_OS_BAL           NUMBER(18, 3));

    TYPE TABLEH IS TABLE OF RR_TABLEH INDEX BY PLS_INTEGER;

    V_TEMP_TABLEH TABLEH;

    V_LN_SUSPBAL  NUMBER(18, 3) := 0;
    V_WDBRN_BSRCD NUMBER(6);

    PROCEDURE INITIALIZE_VALUES IS
    BEGIN
      W_SEC_TYPE           := '';
      W_SECPROV_VALID_FLG  := '';
      W_SECPROV_DISC_PER   := 0;
      W_LIM_LINE_NUM       := 0;
      W_LIM_CLIENT         := 0;
      W_ASSIGN_PERC        := 0;
      W_SEC_NUM            := 0;
      W_SEC_CURR_CODE      := '';
      W_SECURED_VALUE      := 0;
      W_SEC_AMT            := 0;
      W_CURR_CODE          := '';
      W_SEC_AMT_ACNT_CURR  := 0;
      W_SEC_AMT_BASE_CURR  := 0;
      W_TOT_SEC_AMT_AC     := 0;
      W_TOT_SEC_AMT_BC     := 0;
      W_TOT_SEC_AMT        := 0;
      DUMMY                := 0;
      W_REDUCE_TANG_SEC    := '';
      W_SEC_VAL_REDUCE_PER := 0;
      W_SEC_RED_AMT_AC     := 0;
      W_SEC_RED_AMT_BC     := 0;
      W_PROVPM_DATE        := NULL;
      W_DUMMY_BAL          := 0;
      V_SECURITY_VALUE     := 0;
    END INITIALIZE_VALUES;


    PROCEDURE GET_RATE_TYPE IS
    BEGIN
      SELECT CMNPM_MID_RATE_TYPE_PUR INTO W_RATE_TYPE FROM CMNPARAM;

      IF (W_RATE_TYPE IS NULL) THEN
        W_ERROR := 'Common Rate Type Parameter not defined';
        --RAISE E_USEREXCEP;
      END IF;

      W_RATE_TYPE_FLG := 'M';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        W_ERROR := 'Common Rate Type Parameter not defined';
        --RAISE E_USEREXCEP;
    END GET_RATE_TYPE;


 PROCEDURE CL_INSERT_DATA (P_ENTITY_NUM IN NUMBER,
                         P_ASON_DATE  IN DATE,
                         P_CBD        IN DATE,
                         P_BRN_CODE   IN NUMBER ) IS

W_DATA_SQL CLOB;

  BEGIN
         W_DATA_SQL :='DELETE FROM CL_TMP_DATA CLS WHERE CLS.ACNTS_BRN_CODE = :1';
         EXECUTE IMMEDIATE W_DATA_SQL USING P_BRN_CODE ;

         W_DATA_SQL :='    INSERT INTO CL_TMP_DATA
       WITH ACCOUNT_LIST
            AS (SELECT ACA_BAL1.*,
                       NVL (LS.LNSUSPBAL_SUSP_BAL, 0) INT_SUSPENSE_AMT
                  FROM (SELECT ACNTS_ENTITY_NUM,
                               A.ACNTS_BRN_CODE,
                               A.ACNTS_INTERNAL_ACNUM,
                               ACLSH.ASSETCLSH_ASSET_CODE,
                               LN.LNACMIS_HO_DEPT_CODE,
                               CL.REPORT_DESC,
                               AD.ASSETCD_ASSET_CLASS,
                               AD.ASSETCD_PERF_CAT,
                               AD.ASSETCD_NONPERF_CAT,
                               FN_GET_ASON_DR_OR_CR_BAL (A.ACNTS_ENTITY_NUM,
                                                         A.ACNTS_INTERNAL_ACNUM,
                                                         A.ACNTS_CURR_CODE,
                                                         :P_ASON_DATE,
                                                         :W_CBD,
                                                         ''D'',
                                                         0)
                                  ACBAL,
                               pkg_clreport_opt.GET_SECURED_VALUE (
                                  ACNTS_INTERNAL_ACNUM,
                                  :P_ASON_DATE,
                                  :W_CBD,
                                  ''BDT'')
                                  SECURITY_AMOUNT,
                               --CL21
                               PROVLED_BC_PROV_AMT BC_PROV_AMT                 --,
                          -- NVL (LS.LNSUSPBAL_SUSP_BAL, 0) INT_SUSPENSE_AMT
                          FROM ASSETCLSHIST ACLSH,
                               ASSETCD AD,
                               ACNTS A,
                               LNACMIS LN,
                               CLREPORT CL,
                               (  SELECT PROVLED_ENTITY_NUM,
                                         PROVLED_ACNT_NUM,
                                         SUM (
                                            NVL (
                                               (CASE
                                                   WHEN PR.PROVLED_ENTRY_TYPE = ''P''
                                                   THEN
                                                      PR.PROVLED_BC_PROV_AMT
                                                   ELSE
                                                      (-1) * PR.PROVLED_BC_PROV_AMT
                                                END),
                                               0))
                                            PROVLED_BC_PROV_AMT
                                    FROM PROVLED PR
                                GROUP BY PROVLED_ENTITY_NUM, PROVLED_ACNT_NUM) P
                         WHERE     ACNTS_ENTITY_NUM = 1
                               AND LNACMIS_ENTITY_NUM = 1
                               AND ASSETCLSH_ENTITY_NUM = 1
                               AND ACNTS_BRN_CODE = :P_BRN_CODE
                               AND ACLSH.ASSETCLSH_ASSET_CODE = AD.ASSETCD_CODE
                               AND ACLSH.ASSETCLSH_INTERNAL_ACNUM =
                                      A.ACNTS_INTERNAL_ACNUM
                               AND ACLSH.ASSETCLSH_INTERNAL_ACNUM NOT IN
                                      (SELECT L.LNWRTOFF_ACNT_NUM
                                         FROM LNWRTOFF L)
                               AND A.ACNTS_OPENING_DATE <= :P_ASON_DATE
                               AND (   A.ACNTS_CLOSURE_DATE IS NULL
                                    OR A.ACNTS_CLOSURE_DATE > :P_ASON_DATE)
                               AND A.ACNTS_AUTH_ON IS NOT NULL
                               AND LN.LNACMIS_INTERNAL_ACNUM =
                                      A.ACNTS_INTERNAL_ACNUM
                               AND ACLSH.ASSETCLSH_EFF_DATE =
                                      (SELECT MAX (H.ASSETCLSH_EFF_DATE)
                                         FROM ASSETCLSHIST H
                                        WHERE     H.ASSETCLSH_INTERNAL_ACNUM =
                                                     A.ACNTS_INTERNAL_ACNUM
                                              AND H.ASSETCLSH_EFF_DATE <=
                                                     :P_ASON_DATE)
                               AND CL.REPORT_CODE = LNACMIS_HO_DEPT_CODE
                               AND LN.LNACMIS_ENTITY_NUM =
                                      P.PROVLED_ENTITY_NUM(+)
                               AND LN.LNACMIS_INTERNAL_ACNUM =
                                      P.PROVLED_ACNT_NUM(+)) ACA_BAL1,
                       LNSUSPBAL LS
                 WHERE     ACA_BAL1.ACNTS_INTERNAL_ACNUM =
                              LS.LNSUSPBAL_ACNT_NUM(+)
                       AND ACA_BAL1.ACNTS_ENTITY_NUM = LS.LNSUSPBAL_ENTITY_NUM(+)),
            PROVCALC_DATA
            AS (SELECT PROVC_INTERNAL_ACNUM,
                       PROVC_ENTITY_NUM,
                       PROVC_PROV_ON_BAL_BC,
                       PROVC_PROC_DATE
                  FROM PROVCALC
                 WHERE PROVC_PROC_DATE = :P_ASON_DATE)
       SELECT *
         FROM ACCOUNT_LIST, PROVCALC_DATA
        WHERE     ACCOUNT_LIST.ACNTS_INTERNAL_ACNUM =
                     PROVCALC_DATA.PROVC_INTERNAL_ACNUM(+)
              AND ACCOUNT_LIST.ACNTS_ENTITY_NUM =
                     PROVCALC_DATA.PROVC_ENTITY_NUM(+)
              AND ACCOUNT_LIST.ACNTS_BRN_CODE = :P_BRN_CODE';

     EXECUTE IMMEDIATE W_DATA_SQL USING P_ASON_DATE, P_CBD, P_ASON_DATE, P_CBD, P_BRN_CODE, P_ASON_DATE,
                                   P_ASON_DATE,P_ASON_DATE,P_ASON_DATE, P_BRN_CODE;
                                   COMMIT ;

  END CL_INSERT_DATA;

    --Note: Main Calling Start From Here.
  BEGIN
    W_RATE_TYPE      := '';
    W_RATE_TYPE_FLG  := '';
    W_ASON_DATE      := P_ASON_DATE;
    W_CBD            := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE(P_ENTITY_NUM);
    W_BASE_CURR_CODE := PKG_PB_GLOBAL.FN_GET_INS_BASE_CURR(P_ENTITY_NUM);
    GET_RATE_TYPE;
    V_GLOB_ENTITY_NUM := P_ENTITY_NUM;

    V_WDBRN_BSRCD := '';

    IF NVL(P_BRN_CODE, 0) <> 0 THEN
      BEGIN
        W_SQL := 'SELECT M.MBRN_BSR_CODE FROM MBRN M WHERE M.MBRN_CODE=' ||
                 P_BRN_CODE;

        EXECUTE IMMEDIATE W_SQL
          INTO V_WDBRN_BSRCD;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_WDBRN_BSRCD := '';
      END;
    ELSE
      V_WDBRN_BSRCD := '';
    END IF;

    ---
    V_SS_SUBTOTAL := 0 ;

    SP_CL_INSERT_DATA(P_ENTITY_NUM,W_ASON_DATE,W_CBD,P_BRN_CODE);

    W_ERROR := '';
    W_SQL   := 'SELECT CL.REPORT_DESC,CL.REPORT_CODE FROM CLREPORT CL ORDER BY CL.SERIAL_NO';

    --W_SQL := 'SELECT CL.REPORT_DESC,CL.REPORT_CODE FROM CLREPORT CL WHERE CL.REPORT_CODE = ''CL46''
    --ORDER BY CL.SERIAL_NO';

    EXECUTE IMMEDIATE W_SQL BULK COLLECT
      INTO V_TEMP_TABLEA;

    IF (V_TEMP_TABLEA.FIRST IS NOT NULL) THEN

      FOR I IN V_TEMP_TABLEA.FIRST .. V_TEMP_TABLEA.LAST LOOP

        PRINT.BAL_UNCLASS  := 0;
        PRINT.BAL_SPECIAL  := 0;
        PRINT.BAL_SUBSS    := 0;
        PRINT.BAL_DOUBT    := 0;
        PRINT.BAL_BAD_LOSS := 0;
        PRINT.TOT_BAL_OUT  := 0;

        PRINT.PRO_BASE_UN := 0;
        PRINT.PRO_BASE_SP := 0;
        PRINT.PRO_BASE_SS := 0;
        PRINT.PRO_BASE_DF := 0;
        PRINT.PRO_BASE_BL := 0;

        PRINT.INT_SUS_UN  := 0;
        PRINT.INT_SUS_SP  := 0;
        PRINT.INT_SUS_SS  := 0;
        PRINT.INT_SUS_DF  := 0;
        PRINT.INT_SUS_BL  := 0;
        PRINT.INT_SUS_TOT := 0;
        PRINT.INT_SS_MIN_SUM := 0;

        PRINT.INT_CLA_TOT := 0;
        V_ASON_AC_BAL     := 0;
        V_ASON_BC_BAL     := 0;
        O_SECURITY_VAL    := 0;
        TMP_BP_SM_AMT     := 0;
        TMP_BP_SS_AMT     := 0;

        TMP_BP_DF_AMT  := 0;
        TMP_BP_BL_AMT  := 0;
        GET_SUS_SM_AMT := 0;
        GET_SUS_SS_AMT := 0;
        GET_SUS_DF_AMT := 0;
        GET_SUS_BL_AMT := 0;

        O_ASON_AMT        := 0;
        W_BASE_PRO_CAL_SM := 0;
        W_BASE_PRO_CAL_SS := 0;
        W_BASE_PRO_CAL_DF := 0;
        W_BASE_PRO_CAL_BL := 0;
        W_DUMMY_BAL       := 0;

        INITIALIZE_VALUES;

        ----END FOR VARIABLE INITIZALATIONS----

        -- VIJAY - 12TH MARCH 2013 - ADD - BEG
        IF (V_TEMP_TABLEA(I)
           .TMP_CL_CODE = 'CL2' OR V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL3' OR V_TEMP_TABLEA(I)
           .TMP_CL_CODE = 'CL4' OR V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL5') THEN

          PRINT.BAL_UNCLASS  := '';
          PRINT.BAL_SPECIAL  := '';
          PRINT.BAL_SUBSS    := '';
          PRINT.BAL_DOUBT    := '';
          PRINT.BAL_BAD_LOSS := '';
          PRINT.TOT_BAL_OUT  := '';

          PRINT.PRO_BASE_UN := '';
          PRINT.PRO_BASE_SP := '';
          PRINT.PRO_BASE_SS := '';
          PRINT.PRO_BASE_DF := '';
          PRINT.PRO_BASE_BL := '';

          PRINT.INT_SUS_UN  := '';
          PRINT.INT_SUS_SP  := '';
          PRINT.INT_SUS_SS  := '';
          PRINT.INT_SUS_DF  := '';
          PRINT.INT_SUS_BL  := '';
          PRINT.INT_SUS_TOT := '';
          PRINT.INT_CLA_TOT := '';
          PRINT.SEC_VAL     := '';
          PRINT.INT_SS_MIN_SUM := 0;

          PRINT.AMT_PROV_RE := '';
          PRINT.RPT_DESCN   := V_TEMP_TABLEA(I).TMP_CL_DESCN;

          PG_NUMBER       := PG_NUMBER + 1;
          PRINT.PG_NO     := PG_NUMBER;
          PRINT.BRN_BSRCD := V_WDBRN_BSRCD;

          PIPE ROW(PRINT);
        ELSE
          ------FUNCTION START FOR  BALANCE OUTSTANDING------

          IF (V_TEMP_TABLEA(I)
             .TMP_CL_CODE = 'CL21' OR V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL22' OR V_TEMP_TABLEA(I)
             .TMP_CL_CODE = 'CL23' OR V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL24' OR V_TEMP_TABLEA(I)
             .TMP_CL_CODE = 'CL31' OR V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL32' OR V_TEMP_TABLEA(I)
             .TMP_CL_CODE = 'CL33' OR V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL34' OR V_TEMP_TABLEA(I)
             .TMP_CL_CODE = 'CL41' OR V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL42' OR V_TEMP_TABLEA(I)
             .TMP_CL_CODE = 'CL43' OR V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL44' OR V_TEMP_TABLEA(I)
             .TMP_CL_CODE = 'CL45' OR V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL46' OR V_TEMP_TABLEA(I)
             .TMP_CL_CODE = 'CL51' OR V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL52' OR V_TEMP_TABLEA(I)
             .TMP_CL_CODE = 'CL7') THEN
            --------------------- WE'RE INTERESTED ON DEBIT BALANCE OF ACCOUNTS NOT CREDIT ONES------------

          -- Need To Replace

            W_SQL :=   'SELECT  ASSETCLSH_ASSET_CODE,
                            ASSETCD_ASSET_CLASS,
                            ASSETCD_PERF_CAT,
                            ASSETCD_NONPERF_CAT,ABS( SUM (NVL(CL_S.ACBAL,0))) , ABS(NVL(SUM( CASE WHEN CL_S.ACBAL <> 0  THEN CL_S.INT_SUSPENSE_AMT  ELSE 0  END   ),0))  ,ABS(NVL(SUM( CASE WHEN CL_S.ACBAL <> 0  THEN CL_S.SECURITY_AMOUNT  ELSE 0 END   ),0)),  ABS(NVL(SUM( CASE WHEN CL_S.ACBAL <> 0  THEN CL_S.provc_prov_on_bal_bc  ELSE 0 END   ),0)) , sum (CASE WHEN CL_S.Acbal<> 0 THEN NVL(CL_S.BC_PROV_AMT,0) ELSE 0 END )
          FROM CL_TMP_DATA CL_S  WHERE CL_S.LNACMIS_HO_DEPT_CODE = :1 AND ASON_DATE=:W_ASON_DATE' ;
           IF NVL(P_BRN_CODE, 0) <> 0 THEN
              W_SQL := W_SQL || ' AND  CL_S.ACNTS_BRN_CODE = ' || P_BRN_CODE;
            END IF;
            W_SQL := W_SQL ||
                     ' GROUP BY ASSETCLSH_ASSET_CODE,
                                          ASSETCD_ASSET_CLASS,
                                          ASSETCD_PERF_CAT,
                                          ASSETCD_NONPERF_CAT ';
                --Dbms_Output.put_line(W_SQL) ;
            EXECUTE IMMEDIATE W_SQL BULK COLLECT INTO V_TEMP_TABLED USING V_TEMP_TABLEA(I).TMP_CL_CODE, W_ASON_DATE;

               --Note:  START FOR BALANCE OUTSTANDING AMOUNT / SUSPENSE AMOUNT / SECURITY
                 V_TOT_SEC_AMT1 :=0;
                 BC_PROV_AMT := 0 ;
                 PRINT.SEC_VAL := 0 ;
                 PRINT.AMT_PROV_RE := 0 ;
                 V_CL4_SS_DATA := 0;
                  PRINT.INT_SS_MIN_SUM := 0;

                  BEGIN
                     SELECT NVL(SUM (DEFAULT_AMT), 0)
                          INTO V_CL4_SS_DATA
                          FROM CL_TMP_DATA
                         WHERE     ACNTS_ENTITY_NUM = 1
                               AND ACNTS_BRN_CODE = P_BRN_CODE
                               AND LNACMIS_HO_DEPT_CODE =
                                      V_TEMP_TABLEA (I).TMP_CL_CODE
                               AND ASSETCD_NONPERF_CAT = '1'
                               AND ASSETCD_ASSET_CLASS = 'N'
                               AND ASON_DATE = W_ASON_DATE;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        V_CL4_SS_DATA := 0;
                  END;
        PRINT.INT_SS_MIN_SUM := V_CL4_SS_DATA;
        W_TOT_CL4_SS_DATA := W_TOT_CL4_SS_DATA+V_CL4_SS_DATA;
        IF V_TEMP_TABLED.FIRST IS NOT NULL THEN
        --

         PRINT.SEC_VAL := 0 ;
         PRINT.AMT_PROV_RE := 0 ;

         FOR INS IN V_TEMP_TABLED.FIRST .. V_TEMP_TABLED.LAST LOOP


            AMT_CLASS := V_TEMP_TABLED(INS).TMP_ASON_AMT;
            INT_SUSPENSE_AMT := V_TEMP_TABLED(INS).TMP_LNSUP_AMT;
            V_TOT_SEC_AMT1 :=  V_TOT_SEC_AMT1+ V_TEMP_TABLED(INS).TMP_SECURITY_AMT;
            BC_PROV_AMT :=  BC_PROV_AMT + V_TEMP_TABLED(INS).TMP_BC_PROV_AMT;

            IF (V_TEMP_TABLED(INS).TMP_ASSET_CLASS = 'P') THEN
              --UC
              IF (V_TEMP_TABLED(INS).TMP_PER_CAT = '1') THEN
                PRINT.BAL_UNCLASS := PRINT.BAL_UNCLASS + AMT_CLASS;
                PRINT.INT_SUS_UN := PRINT.INT_SUS_UN + INT_SUSPENSE_AMT;

             --   PRINT.INT_SUS_UN  := SUBTOTAL_INS_UN;


                --SM
              ELSE 
                PRINT.BAL_SPECIAL := PRINT.BAL_SPECIAL + AMT_CLASS;
                PRINT.INT_SUS_SP := PRINT.INT_SUS_SP + INT_SUSPENSE_AMT;
                PRINT.PRO_BASE_SP := PRINT.PRO_BASE_SP + V_TEMP_TABLED(INS).TMP_BASE_PROV_AMT_BC;

              END IF;
            ELSE
              --SS
              IF (V_TEMP_TABLED(INS).TMP_NONPER_CAT = 1) THEN
                PRINT.BAL_SUBSS := PRINT.BAL_SUBSS + AMT_CLASS;
                PRINT.INT_SUS_SS := PRINT.INT_SUS_SS + INT_SUSPENSE_AMT;
               PRINT.PRO_BASE_SS := PRINT.PRO_BASE_SS + V_TEMP_TABLED(INS).
                                          TMP_BASE_PROV_AMT_BC;
                --DF
              ELSIF (V_TEMP_TABLED(INS).TMP_NONPER_CAT = 2) THEN
                PRINT.BAL_DOUBT := PRINT.BAL_DOUBT + AMT_CLASS;
                PRINT.INT_SUS_DF := PRINT.INT_SUS_DF + INT_SUSPENSE_AMT;
                PRINT.PRO_BASE_DF := PRINT.PRO_BASE_DF + V_TEMP_TABLED(INS).TMP_BASE_PROV_AMT_BC;
                --BL
              ELSIF (V_TEMP_TABLED(INS).TMP_NONPER_CAT = 3) THEN
                PRINT.BAL_BAD_LOSS := PRINT.BAL_BAD_LOSS + AMT_CLASS;
                PRINT.INT_SUS_BL := PRINT.INT_SUS_BL + INT_SUSPENSE_AMT;
                PRINT.PRO_BASE_BL := PRINT.PRO_BASE_BL + V_TEMP_TABLED(INS)
                                          .TMP_BASE_PROV_AMT_BC;
              END IF;
            END IF;
           -- V_TOT_SEC_AMT1 := V_TOT_SEC_AMT1 + V_TEMP_TABLED(INS).TMP_SECURITY_AMT ;
          --  BC_PROV_AMT  := BC_PROV_AMT + V_TEMP_TABLED(INS).TMP_PROVC_PROV_ON_BAL_BC  ;

              --
          END LOOP;
          PRINT.SEC_VAL := V_TOT_SEC_AMT1 ;
          PRINT.AMT_PROV_RE := BC_PROV_AMT;

          V_TOT_SEC_AMT := V_TOT_SEC_AMT + V_TOT_SEC_AMT1 ;

           --PRINT.AMT_PROV_RE := BC_PROV_AMT;








       END IF;



            PRINT.TOT_BAL_OUT := PRINT.BAL_UNCLASS + PRINT.BAL_SPECIAL +
                                 PRINT.BAL_SUBSS + PRINT.BAL_DOUBT +
                                 PRINT.BAL_BAD_LOSS;
            PRINT.INT_CLA_TOT := PRINT.INT_SUS_SS + PRINT.INT_SUS_DF +
                                 PRINT.INT_SUS_BL;
            PRINT.INT_SUS_TOT := PRINT.INT_SUS_UN + PRINT.INT_SUS_SP +
                                 PRINT.INT_SUS_SS + PRINT.INT_SUS_DF +
                                 PRINT.INT_SUS_BL;

            V_BAL_UN      := V_BAL_UN + PRINT.BAL_UNCLASS;
            V_BAL_SP      := V_BAL_SP + PRINT.BAL_SPECIAL;
            V_BAL_SUB     := V_BAL_SUB + PRINT.BAL_SUBSS;
            V_BAL_DOU     := V_BAL_DOU + PRINT.BAL_DOUBT;
            V_BAL_BLOS    := V_BAL_BLOS + PRINT.BAL_BAD_LOSS;
            V_TOT_BAL_AMT := V_TOT_BAL_AMT + PRINT.TOT_BAL_OUT;

            V_AMT_PROV_REQ := V_AMT_PROV_REQ + PRINT.AMT_PROV_RE;

            V_INT_SUS_UN := V_INT_SUS_UN + PRINT.INT_SUS_UN;
            V_INT_SUS_SP := V_INT_SUS_SP + PRINT.INT_SUS_SP;
            V_INT_SUS_SS := V_INT_SUS_SS + PRINT.INT_SUS_SS;
            V_INT_SUS_DF := V_INT_SUS_DF + PRINT.INT_SUS_DF;
            V_INT_SUS_BL := V_INT_SUS_BL + PRINT.INT_SUS_BL;
            V_INT_SUS_TO := V_INT_SUS_TO + PRINT.INT_SUS_TOT;
            V_INT_CLA    := V_INT_CLA + PRINT.INT_CLA_TOT;

            V_PRO_BASE_SP  := V_PRO_BASE_SP + PRINT.PRO_BASE_SP;
            V_PRO_BASE_SUB := V_PRO_BASE_SUB + PRINT.PRO_BASE_SS;
            V_PRO_BASE_DF  := V_PRO_BASE_DF + PRINT.PRO_BASE_DF;
            V_PRO_BASE_BL  := V_PRO_BASE_BL + PRINT.PRO_BASE_BL;

            PRINT.PG_NO     := '';
            PRINT.Rpt_Descn := V_TEMP_TABLEA(I).TMP_CL_DESCN;
            PRINT.BRN_BSRCD := V_WDBRN_BSRCD;

            PIPE ROW(PRINT);
            ----CALCULATION FOR TOTALS END---

            /*
             REMOVED BY VIJAY ON 12TH MARCH 2013 - BEG

            ELSIF(V_TEMP_TABLEA(I).TMP_CL_CODE='CL24' OR
                V_TEMP_TABLEA(I).TMP_CL_CODE='CL34' OR
                V_TEMP_TABLEA(I).TMP_CL_CODE='CL46' OR
                V_TEMP_TABLEA(I).TMP_CL_CODE='CL56' OR
                V_TEMP_TABLEA(I).TMP_CL_CODE='CL63'
              )THEN
              REMOVED BY VIJAY ON 12TH MARCH 2013 - END
              */
            -- VIJAY - ADD - 12TH MARCH 2013 - BEG
          ELSIF (V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL25' OR V_TEMP_TABLEA(I)
                .TMP_CL_CODE = 'CL35' OR V_TEMP_TABLEA(I)
                .TMP_CL_CODE = 'CL47' OR V_TEMP_TABLEA(I)
                .TMP_CL_CODE = 'CL53') THEN
            -- VIJAY - ADD - 12TH MARCH 2013 - END

            ---SUB TOTAL FOR EVERY CL HEAD CODE

            PRINT.BAL_UNCLASS  := V_BAL_UN;
            PRINT.BAL_SPECIAL  := V_BAL_SP;
            PRINT.BAL_SUBSS    := V_BAL_SUB;
            PRINT.BAL_DOUBT    := V_BAL_DOU;
            PRINT.BAL_BAD_LOSS := V_BAL_BLOS;
            PRINT.TOT_BAL_OUT  := V_TOT_BAL_AMT;

            PRINT.AMT_PROV_RE := V_AMT_PROV_REQ;

            PRINT.INT_SUS_UN  := V_INT_SUS_UN;
            PRINT.INT_SUS_SP  := V_INT_SUS_SP;
            PRINT.INT_SUS_SS  := V_INT_SUS_SS;
            PRINT.INT_SUS_DF  := V_INT_SUS_DF;
            PRINT.INT_SUS_BL  := V_INT_SUS_BL;
            PRINT.INT_SUS_TOT := V_INT_SUS_TO;
            PRINT.INT_CLA_TOT := V_INT_CLA;

            PRINT.PRO_BASE_SP := V_PRO_BASE_SP;
            PRINT.PRO_BASE_SS := V_PRO_BASE_SUB;
            PRINT.PRO_BASE_DF := V_PRO_BASE_DF;
            PRINT.PRO_BASE_BL := V_PRO_BASE_BL;
            PRINT.SEC_VAL     := V_TOT_SEC_AMT;

            PRINT.PG_NO := '';

            SUBTOTAL_BAL_UN  := SUBTOTAL_BAL_UN + PRINT.BAL_UNCLASS;
            SUBTOTAL_BAL_SP  := SUBTOTAL_BAL_SP + PRINT.BAL_SPECIAL;
            SUBTOTAL_BAL_SS  := SUBTOTAL_BAL_SS + PRINT.BAL_SUBSS;
            SUBTOTAL_BAL_DF  := SUBTOTAL_BAL_DF + PRINT.BAL_DOUBT;
            SUBTOTAL_BAL_BL  := SUBTOTAL_BAL_BL + PRINT.BAL_BAD_LOSS;
            SUBTOTAL_BAL_TOT := SUBTOTAL_BAL_TOT + PRINT.TOT_BAL_OUT;

            SUBTOTAL_AMT_PRO_REQ := SUBTOTAL_AMT_PRO_REQ +
                                    PRINT.AMT_PROV_RE;

            SUBTOTAL_INS_UN      := SUBTOTAL_INS_UN + PRINT.INT_SUS_UN;
            SUBTOTAL_INS_SP      := SUBTOTAL_INS_SP + PRINT.INT_SUS_SP;
            SUBTOTAL_INS_SS      := SUBTOTAL_INS_SS + PRINT.INT_SUS_SS;
            SUBTOTAL_INS_DF      := SUBTOTAL_INS_DF + PRINT.INT_SUS_DF;
            SUBTOTAL_INS_BL      := SUBTOTAL_INS_BL + PRINT.INT_SUS_BL;
            SUBTOTAL_INS_TOT     := SUBTOTAL_INS_TOT + PRINT.INT_SUS_TOT;
            SUBTOTAL_INS_CLA_TOT := SUBTOTAL_INS_CLA_TOT +
                                    PRINT.INT_CLA_TOT;

            SUBTOTAL_BASE_SP := SUBTOTAL_BASE_SP + PRINT.PRO_BASE_SP;
            SUBTOTAL_BASE_SS := SUBTOTAL_BASE_SS + PRINT.PRO_BASE_SS;
            SUBTOTAL_BASE_DF := SUBTOTAL_BASE_DF + PRINT.PRO_BASE_DF;
            SUBTOTAL_BASE_BL := SUBTOTAL_BASE_BL + PRINT.PRO_BASE_BL;
            V_SUBTOT_SEC_AMT := V_SUBTOT_SEC_AMT + PRINT.SEC_VAL;

            PRINT.Rpt_Descn := V_TEMP_TABLEA(I).TMP_CL_DESCN;
            PRINT.INT_SS_MIN_SUM := W_TOT_CL4_SS_DATA;
            V_SS_SUBTOTAL := V_SS_SUBTOTAL +   W_TOT_CL4_SS_DATA ;

            PIPE ROW(PRINT);

            V_BAL_UN      := 0;
            V_BAL_SP      := 0;
            V_BAL_SUB     := 0;
            V_BAL_DOU     := 0;
            V_BAL_BLOS    := 0;
            V_TOT_BAL_AMT := 0;

            V_AMT_PROV_REQ := 0;

            V_INT_SUS_UN := 0;
            V_INT_SUS_SP := 0;
            V_INT_SUS_SS := 0;
            V_INT_SUS_DF := 0;
            V_INT_SUS_BL := 0;
            V_INT_SUS_TO := 0;
            V_INT_CLA    := 0;

            V_PRO_BASE_SP  := 0;
            V_PRO_BASE_SUB := 0;
            V_PRO_BASE_DF  := 0;
            V_PRO_BASE_BL  := 0;
            V_TOT_SEC_AMT  := 0;
            W_TOT_CL4_SS_DATA :=0;
            /*
               REMOVED BY VIJAY ON 12TH MARCH 2013 - BEG
            ELSIF(V_TEMP_TABLEA(I).TMP_CL_CODE='CL64')THEN
               REMOVED BY VIJAY ON 12TH MARCH 2013  -END
            */

          ELSIF (V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL54') THEN

            --OVER ALL SUB TOTAL---

            PRINT.BAL_UNCLASS  := SUBTOTAL_BAL_UN;
            PRINT.BAL_SPECIAL  := SUBTOTAL_BAL_SP;
            PRINT.BAL_SUBSS    := SUBTOTAL_BAL_SS;
            PRINT.BAL_DOUBT    := SUBTOTAL_BAL_DF;
            PRINT.BAL_BAD_LOSS := SUBTOTAL_BAL_BL;
            PRINT.TOT_BAL_OUT  := SUBTOTAL_BAL_TOT;

            PRINT.AMT_PROV_RE := SUBTOTAL_AMT_PRO_REQ;

            PRINT.INT_SUS_UN  := SUBTOTAL_INS_UN;
            PRINT.INT_SUS_SP  := SUBTOTAL_INS_SP;
            PRINT.INT_SUS_SS  := SUBTOTAL_INS_SS;
            PRINT.INT_SUS_DF  := SUBTOTAL_INS_DF;
            PRINT.INT_SUS_BL  := SUBTOTAL_INS_BL;
            PRINT.INT_SUS_TOT := SUBTOTAL_INS_TOT;
            PRINT.INT_CLA_TOT := SUBTOTAL_INS_CLA_TOT;

            PRINT.PRO_BASE_SP := SUBTOTAL_BASE_SP;
            PRINT.PRO_BASE_SS := SUBTOTAL_BASE_SS;
            PRINT.PRO_BASE_DF := SUBTOTAL_BASE_DF;
            PRINT.PRO_BASE_BL := SUBTOTAL_BASE_BL;

            PRINT.PG_NO := '';

            PRINT.Rpt_Descn := V_TEMP_TABLEA(I).TMP_CL_DESCN;
            PRINT.INT_SS_MIN_SUM := V_SS_SUBTOTAL ;

            PIPE ROW(PRINT);
            --  ELSIF(V_TEMP_TABLEA(I).TMP_CL_CODE='CL8')THEN REMOVED BY VIJAY ON 12TH MARCH 2013
          ELSIF (V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL6') THEN

            ---GRAND TOTAL---

            GRANDTOTAL_BAL_UN  := V_BAL_UN + SUBTOTAL_BAL_UN;
            GRANDTOTAL_BAL_SP  := V_BAL_SP + SUBTOTAL_BAL_SP;
            GRANDTOTAL_BAL_SS  := V_BAL_SUB + SUBTOTAL_BAL_SS;
            GRANDTOTAL_BAL_DF  := V_BAL_DOU + SUBTOTAL_BAL_DF;
            GRANDTOTAL_BAL_BL  := V_BAL_BLOS + SUBTOTAL_BAL_BL;
            GRANDTOTAL_BAL_TOT := V_TOT_BAL_AMT + SUBTOTAL_BAL_TOT;

            GRANDTOTAL_AMT_PRO_REQ := V_AMT_PROV_REQ + SUBTOTAL_AMT_PRO_REQ;

            GRANDTOTAL_INS_UN      := V_INT_SUS_UN + SUBTOTAL_INS_UN;
            GRANDTOTAL_INS_SP      := V_INT_SUS_SP + SUBTOTAL_INS_SP;
            GRANDTOTAL_INS_SS      := V_INT_SUS_SS + SUBTOTAL_INS_SS;
            GRANDTOTAL_INS_DF      := V_INT_SUS_DF + SUBTOTAL_INS_DF;
            GRANDTOTAL_INS_BL      := V_INT_SUS_BL + SUBTOTAL_INS_BL;
            GRANDTOTAL_INS_TOT     := V_INT_SUS_TO + SUBTOTAL_INS_TOT;
            GRANDTOTAL_INS_CLA_TOT := V_INT_CLA + SUBTOTAL_INS_CLA_TOT;

            GRANDTOTAL_BASE_SP := V_PRO_BASE_SP + SUBTOTAL_BASE_SP;
            GRANDTOTAL_BASE_SS := V_PRO_BASE_SUB + SUBTOTAL_BASE_SS;
            GRANDTOTAL_BASE_DF := V_PRO_BASE_DF + SUBTOTAL_BASE_DF;
            GRANDTOTAL_BASE_BL := V_PRO_BASE_BL + SUBTOTAL_BASE_BL;
            V_GRANDTOT_SEC_AMT := V_TOT_SEC_AMT + V_SUBTOT_SEC_AMT;

            PRINT.BAL_UNCLASS  := GRANDTOTAL_BAL_UN;
            PRINT.BAL_SPECIAL  := GRANDTOTAL_BAL_SP;
            PRINT.BAL_SUBSS    := GRANDTOTAL_BAL_SS;
            PRINT.BAL_DOUBT    := GRANDTOTAL_BAL_DF;
            PRINT.BAL_BAD_LOSS := GRANDTOTAL_BAL_BL;
            PRINT.TOT_BAL_OUT  := GRANDTOTAL_BAL_TOT;

            PRINT.AMT_PROV_RE := GRANDTOTAL_AMT_PRO_REQ;

            PRINT.INT_SUS_UN  := GRANDTOTAL_INS_UN;
            PRINT.INT_SUS_SP  := GRANDTOTAL_INS_SP;
            PRINT.INT_SUS_SS  := GRANDTOTAL_INS_SS;
            PRINT.INT_SUS_DF  := GRANDTOTAL_INS_DF;
            PRINT.INT_SUS_BL  := GRANDTOTAL_INS_BL;
            PRINT.INT_SUS_TOT := GRANDTOTAL_INS_TOT;
            PRINT.INT_CLA_TOT := GRANDTOTAL_INS_CLA_TOT;

            PRINT.PRO_BASE_SP := GRANDTOTAL_BASE_SP;
            PRINT.PRO_BASE_SS := GRANDTOTAL_BASE_SS;
            PRINT.PRO_BASE_DF := GRANDTOTAL_BASE_DF;
            PRINT.PRO_BASE_BL := GRANDTOTAL_BASE_BL;
            PRINT.SEC_VAL     := V_GRANDTOT_SEC_AMT;
            PRINT.INT_SS_MIN_SUM := V_SS_SUBTOTAL ;

            PRINT.PG_NO     := '';
            PRINT.Rpt_Descn := V_TEMP_TABLEA(I).TMP_CL_DESCN;

            PIPE ROW(PRINT);

          ELSIF (V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL8') THEN
            ---GRAND TOTAL---

            GRANDTOTAL_BAL_UN  := '';
            GRANDTOTAL_BAL_SP  := '';
            GRANDTOTAL_BAL_SS  := '';
            GRANDTOTAL_BAL_DF  := '';
            GRANDTOTAL_BAL_BL  := '';
            GRANDTOTAL_BAL_TOT := '';

            GRANDTOTAL_AMT_PRO_REQ := '';

            GRANDTOTAL_INS_UN      := '';
            GRANDTOTAL_INS_SP      := '';
            GRANDTOTAL_INS_SS      := '';
            GRANDTOTAL_INS_DF      := '';
            GRANDTOTAL_INS_BL      := '';
            GRANDTOTAL_INS_TOT     := '';
            GRANDTOTAL_INS_CLA_TOT := '';

            GRANDTOTAL_BASE_SP := '';
            GRANDTOTAL_BASE_SS := '';
            GRANDTOTAL_BASE_DF := '';
            GRANDTOTAL_BASE_BL := '';
            V_GRANDTOT_SEC_AMT := '';

            PRINT.BAL_UNCLASS  := '';
            PRINT.BAL_SPECIAL  := '';
            PRINT.BAL_SUBSS    := '';
            PRINT.BAL_DOUBT    := '';
            PRINT.BAL_BAD_LOSS := '';
            PRINT.TOT_BAL_OUT  := '';

            PRINT.AMT_PROV_RE := '';

            PRINT.INT_SUS_UN  := '';
            PRINT.INT_SUS_SP  := '';
            PRINT.INT_SUS_SS  := '';
            PRINT.INT_SUS_DF  := '';
            PRINT.INT_SUS_BL  := '';
            PRINT.INT_SUS_TOT := '';
            PRINT.INT_CLA_TOT := '';

            PRINT.PRO_BASE_SP := '';
            PRINT.PRO_BASE_SS := '';
            PRINT.PRO_BASE_DF := '';
            PRINT.PRO_BASE_BL := '';
            PRINT.SEC_VAL     := '';

            PRINT.PG_NO := '';
            --========= OFF BALANCE SHEET   |  Liabilites (Cr.) Contra:  'L2401', 'L2402', 'L2403', 'L2404', 'L2405', 'L2501', 'L2502', 'L2503', 'L2504'
            P_TOT_OFF_BAL_SHEET_AMT := 0;
            FOR IDX IN (SELECT RPTHDGLDTL_GLACC_CODE
                          FROM RPTHEADGLDTL R2
                         WHERE R2.RPTHDGLDTL_CODE IN
                               ( 'L2401', 'L2402', 'L2404', 'L2405', 'L2501', 'L2502', 'L2503', 'L2504' )) LOOP
              GET_ASON_GLBAL(1,
                             P_BRN_CODE,
                             IDX.RPTHDGLDTL_GLACC_CODE,
                             W_BASE_CURR_CODE,
                             W_ASON_DATE,
                             W_CBD,
                             P_GL_BAL_AC,
                             P_GL_BAL_BC,
                             W_ERROR_MSG);

              P_TOT_OFF_BAL_SHEET_AMT := P_TOT_OFF_BAL_SHEET_AMT +
                                         P_GL_BAL_BC;

            END LOOP;
            PRINT.BAL_UNCLASS := P_TOT_OFF_BAL_SHEET_AMT;
            PRINT.TOT_BAL_OUT := P_TOT_OFF_BAL_SHEET_AMT;
            PRINT.AMT_PROV_RE := ROUND((P_TOT_OFF_BAL_SHEET_AMT * 0.01), 0);
            --==========
            PRINT.Rpt_Descn := V_TEMP_TABLEA(I).TMP_CL_DESCN;

            PIPE ROW(PRINT);
            -- VIJAY - 12TH MARCH 2013 - ADD - END

          END IF;
        END IF;
      END LOOP;
      ---FIRST FOR LOOP END------------------

    ELSE
      NULL;
    END IF;

    /*EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
       DBMS_OUTPUT.PUT_LINE ('EXCEPTION' || SQLERRM);
    WHEN E_USEREXCEP
    THEN
       DBMS_OUTPUT.PUT_LINE ('ERROR IN CL REPORT');
    WHEN OTHERS
    THEN
       DBMS_OUTPUT.PUT_LINE (SQLERRM);*/
    --(Noor)   RETURN 'NULL';
  END CL_RPT;


FUNCTION CL_RPT_CONSOLIDATED(P_ENTITY_NUM IN NUMBER,
                  P_ASON_DATE  IN DATE,
                  P_BRN_CODE   IN NUMBER) RETURN TY_TMP
    PIPELINED
  --RETURN VARCHAR2
   IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    E_USEREXCEP EXCEPTION;
    W_ERROR_MSG VARCHAR2(30);
    W_DUMMY     NUMBER;

    AMT_CLASS          NUMBER(18, 3) := 0;
    PROVISION_BASE_AMT NUMBER(18, 3) := 0;
    INT_SUSPENSE_AMT   NUMBER(18, 3) := 0;
    V_BAL_UN           NUMBER(18, 3) := 0;
    V_BAL_SP           NUMBER(18, 3) := 0;
    V_BAL_SUB          NUMBER(18, 3) := 0;
    V_BAL_DOU          NUMBER(18, 3) := 0;
    V_BAL_BLOS         NUMBER(18, 3) := 0;
    V_TOT_BAL_AMT      NUMBER(18, 3) := 0;
    V_PRO_BASE_UN      NUMBER(18, 3) := 0;
    V_PRO_BASE_SP      NUMBER(18, 3) := 0;
    V_PRO_BASE_SUB     NUMBER(18, 3) := 0;
    V_PRO_BASE_DF      NUMBER(18, 3) := 0;
    V_PRO_BASE_BL      NUMBER(18, 3) := 0;
    V_INT_SUS_UN       NUMBER(18, 3) := 0;
    V_INT_SUS_SP       NUMBER(18, 3) := 0;
    V_INT_SUS_SS       NUMBER(18, 3) := 0;
    V_INT_SUS_DF       NUMBER(18, 3) := 0;
    V_INT_SUS_BL       NUMBER(18, 3) := 0;
    V_INT_SUS_TO       NUMBER(18, 3) := 0;
    V_TOT_AMT_PROV_REQ NUMBER(18, 3) := 0;
    PG_NUMBER          NUMBER(5) := 0;
    BC_PROV_AMT        NUMBER(18, 3) := 0;
    V_TOT_SEC_AMT1     NUMBER(18, 3) := 0;
    V_TOT_SEC_AMT      NUMBER(18, 3) := 0;

    SUBTOTAL_BAL_UN  NUMBER(18, 3) := 0;
    SUBTOTAL_BAL_SP  NUMBER(18, 3) := 0;
    SUBTOTAL_BAL_SS  NUMBER(18, 3) := 0;
    SUBTOTAL_BAL_DF  NUMBER(18, 3) := 0;
    SUBTOTAL_BAL_BL  NUMBER(18, 3) := 0;
    SUBTOTAL_BAL_TOT NUMBER(18, 3) := 0;

    SUBTOTAL_BASE_UN NUMBER(18, 3) := 0;
    SUBTOTAL_BASE_SP NUMBER(18, 3) := 0;
    SUBTOTAL_BASE_SS NUMBER(18, 3) := 0;
    SUBTOTAL_BASE_DF NUMBER(18, 3) := 0;
    SUBTOTAL_BASE_BL NUMBER(18, 3) := 0;

    SUBTOTAL_INS_UN  NUMBER(18, 3) := 0;
    SUBTOTAL_INS_SP  NUMBER(18, 3) := 0;
    SUBTOTAL_INS_SS  NUMBER(18, 3) := 0;
    SUBTOTAL_INS_DF  NUMBER(18, 3) := 0;
    SUBTOTAL_INS_BL  NUMBER(18, 3) := 0;
    SUBTOTAL_INS_TOT NUMBER(18, 3) := 0;
    V_SUBTOT_SEC_AMT NUMBER(18, 3) := 0;

    GRANDTOTAL_BAL_UN  NUMBER(18, 3) := 0;
    GRANDTOTAL_BAL_SP  NUMBER(18, 3) := 0;
    GRANDTOTAL_BAL_SS  NUMBER(18, 3) := 0;
    GRANDTOTAL_BAL_DF  NUMBER(18, 3) := 0;
    GRANDTOTAL_BAL_BL  NUMBER(18, 3) := 0;
    GRANDTOTAL_BAL_TOT NUMBER(18, 3) := 0;

    GRANDTOTAL_BASE_UN NUMBER(18, 3) := 0;
    GRANDTOTAL_BASE_SP NUMBER(18, 3) := 0;
    GRANDTOTAL_BASE_SS NUMBER(18, 3) := 0;
    GRANDTOTAL_BASE_DF NUMBER(18, 3) := 0;
    GRANDTOTAL_BASE_BL NUMBER(18, 3) := 0;

    GRANDTOTAL_INS_UN  NUMBER(18, 3) := 0;
    GRANDTOTAL_INS_SP  NUMBER(18, 3) := 0;
    GRANDTOTAL_INS_SS  NUMBER(18, 3) := 0;
    GRANDTOTAL_INS_DF  NUMBER(18, 3) := 0;
    GRANDTOTAL_INS_BL  NUMBER(18, 3) := 0;
    GRANDTOTAL_INS_TOT NUMBER(18, 3) := 0;
    V_GRANDTOT_SEC_AMT NUMBER(18, 3) := 0;

    -----AMOUNT PROVISION REQUIRED---
    V_AMT_PROV_REQ         NUMBER(18, 3) := 0;
    SUBTOTAL_AMT_PRO_REQ   NUMBER(18, 3) := 0;
    GRANDTOTAL_AMT_PRO_REQ NUMBER(18, 3) := 0;
    ---AMOUNT PROVISION REQUIRED---

    ---SUSANTHA CHANGES---
    V_INT_CLA              NUMBER(18, 3) := 0;
    SUBTOTAL_INS_CLA_TOT   NUMBER(18, 3) := 0;
    GRANDTOTAL_INS_CLA_TOT NUMBER(18, 3) := 0;
    -----------------

    V_ASON_AC_BAL   NUMBER(18, 3) := 0;
    V_CURR_BUS_DATE DATE;
    V_ASON_BC_BAL   NUMBER(18, 3) := 0;
    V_ERR_MSG       NUMBER(18, 3) := 0;
    O_SECURITY_VAL  NUMBER(18, 3);
    TMP_BP_SM_AMT   NUMBER(18, 3) := 0;
    TMP_BP_SS_AMT   NUMBER(18, 3) := 0;
    TMP_BP_DF_AMT   NUMBER(18, 3) := 0;
    TMP_BP_BL_AMT   NUMBER(18, 3) := 0;

    GET_SUS_SM_AMT NUMBER(18, 3) := 0;
    GET_SUS_SS_AMT NUMBER(18, 3) := 0;
    GET_SUS_DF_AMT NUMBER(18, 3) := 0;
    GET_SUS_BL_AMT NUMBER(18, 3) := 0;

    O_ASON_AMT NUMBER(18, 3) := 0;

    W_BASE_PRO_CAL_SM NUMBER(18, 3) := 0;
    W_BASE_PRO_CAL_SS NUMBER(18, 3) := 0;
    W_BASE_PRO_CAL_DF NUMBER(18, 3) := 0;
    W_BASE_PRO_CAL_BL NUMBER(18, 3) := 0;

    PERCENTAGE NUMBER(5, 2) := 0;

    --NEWELY ADDED VARIABLES  START--

    V_ERR_MSG        VARCHAR2(200);
    V_SECURITY_VALUE NUMBER(18, 3) DEFAULT 0;
    W_DF_PROV_BASE   NUMBER(18, 3) DEFAULT 0;
    W_RATE_TYPE      VARCHAR2(8);
    W_RATE_TYPE_FLG  VARCHAR2(1);
    W_ERROR          VARCHAR2(1300);

    W_SEC_TYPE           VARCHAR2(6);
    W_SECPROV_VALID_FLG  VARCHAR2(1);
    W_SECPROV_DISC_PER   NUMBER;
    W_LIM_LINE_NUM       NUMBER;
    W_LIM_CLIENT         NUMBER;
    W_ASSIGN_PERC        NUMBER;
    W_SEC_NUM            NUMBER;
    W_SEC_CURR_CODE      VARCHAR2(3);
    W_SECURED_VALUE      NUMBER(18, 3);
    W_SEC_AMT            NUMBER(18, 3);
    W_CURR_CODE          VARCHAR2(3);
    W_SEC_AMT_ACNT_CURR  NUMBER(18, 3);
    W_SEC_AMT_BASE_CURR  NUMBER(18, 3);
    DUMMY                NUMBER;
    W_BASE_CURR_CODE     VARCHAR2(3);
    W_TOT_SEC_AMT_AC     NUMBER(18, 3);
    W_TOT_SEC_AMT_BC     NUMBER(18, 3);
    W_TOT_SEC_AMT        NUMBER(18, 3);
    W_REDUCE_TANG_SEC    VARCHAR2(1);
    W_SEC_VAL_REDUCE_PER NUMBER;
    W_SEC_RED_AMT_AC     NUMBER(18, 3);
    W_SEC_RED_AMT_BC     NUMBER(18, 3);
    W_PROVPM_DATE        DATE;
    W_TOT_CL4_SS_DATA    NUMBER (18, 3):= 0;

    --NEWELY ADDED VARIABLES  END --

    TYPE RR_TABLEA IS RECORD(
      TMP_CL_DESCN VARCHAR2(200),
      TMP_CL_CODE  VARCHAR2(50));

    TYPE TABLEA IS TABLE OF RR_TABLEA INDEX BY PLS_INTEGER;

    V_TEMP_TABLEA TABLEA;

    TYPE RR_TABLED IS RECORD(
      TMP_ASSET_CODE  VARCHAR2(5),
      TMP_ASSET_CLASS CHAR(1),
      TMP_PER_CAT     CHAR(1),
      TMP_NONPER_CAT  CHAR(1),
      TMP_ASON_AMT    NUMBER(18, 3) ,
      TMP_LNSUP_AMT   NUMBER(18, 3),
      TMP_SECURITY_AMT NUMBER(18, 3),
      TMP_BASE_PROV_AMT_BC NUMBER(18, 3),
      TMP_BC_PROV_AMT NUMBER(18, 3)

      );

    TYPE TABLED IS TABLE OF RR_TABLED INDEX BY PLS_INTEGER;

    V_TEMP_TABLED TABLED;

    TYPE RR_TABLEF IS RECORD(
      TMP_ASSET_CODE  VARCHAR2(5),
      TMP_ASSET_CLASS CHAR(1),
      TMP_PER_CAT     CHAR(1),
      TMP_NONPER_CAT  CHAR(1),
      TMP_LNSUP_AMT   NUMBER(18, 3));

    TYPE TABLEF IS TABLE OF RR_TABLEF INDEX BY PLS_INTEGER;

    V_TEMP_TABLEF TABLEF;

    TYPE RR_TABLEG IS RECORD(
      TMP_AC_NUMBER VARCHAR2(14),
      TMP_CURR_CODE VARCHAR2(3),
      --TMP_PROD_CODE NUMBER(4), -- COMMENTED BY VIJAY ON 14TH 04 2013
      TMP_HODEPT_CODE    VARCHAR2(4),
      TMP_CLIENT_CODE    NUMBER(12),
      TMP_LIMIT_NUM      NUMBER(6),
      TMP_ASSET_CODE     VARCHAR2(5),
      TMP_ASSET_CLASS    CHAR(1),
      TMP_PER_CAT        CHAR(1),
      TMP_NONPER_CAT     CHAR(1),
      TMP_GET_ASON_ACBAL NUMBER(18, 3));

    TYPE TABLEG IS TABLE OF RR_TABLEG INDEX BY PLS_INTEGER;

    V_TEMP_TABLEG TABLEG;

    TYPE RR_TABLEH IS RECORD(
      TMP_AC_NUMBER        NUMBER,
      TMP_ASSET_CODE       VARCHAR2(5),
      TMP_BASE_PROV_AMT_BC NUMBER(18, 3),
      TMP_ASSET_CLASS      CHAR(1),
      TMP_PER_CAT          CHAR(1),
      TMP_NONPER_CAT       CHAR(1),
      TMP_HODEPT_CODE      VARCHAR2(4),
      TMP_OS_BAL           NUMBER(18, 3));

    TYPE TABLEH IS TABLE OF RR_TABLEH INDEX BY PLS_INTEGER;

    V_TEMP_TABLEH TABLEH;

    V_LN_SUSPBAL  NUMBER(18, 3) := 0;
    V_WDBRN_BSRCD NUMBER(6);

    PROCEDURE INITIALIZE_VALUES IS
    BEGIN
      W_SEC_TYPE           := '';
      W_SECPROV_VALID_FLG  := '';
      W_SECPROV_DISC_PER   := 0;
      W_LIM_LINE_NUM       := 0;
      W_LIM_CLIENT         := 0;
      W_ASSIGN_PERC        := 0;
      W_SEC_NUM            := 0;
      W_SEC_CURR_CODE      := '';
      W_SECURED_VALUE      := 0;
      W_SEC_AMT            := 0;
      W_CURR_CODE          := '';
      W_SEC_AMT_ACNT_CURR  := 0;
      W_SEC_AMT_BASE_CURR  := 0;
      W_TOT_SEC_AMT_AC     := 0;
      W_TOT_SEC_AMT_BC     := 0;
      W_TOT_SEC_AMT        := 0;
      DUMMY                := 0;
      W_REDUCE_TANG_SEC    := '';
      W_SEC_VAL_REDUCE_PER := 0;
      W_SEC_RED_AMT_AC     := 0;
      W_SEC_RED_AMT_BC     := 0;
      W_PROVPM_DATE        := NULL;
      W_DUMMY_BAL          := 0;
      V_SECURITY_VALUE     := 0;
    END INITIALIZE_VALUES;


    PROCEDURE GET_RATE_TYPE IS
    BEGIN
      SELECT CMNPM_MID_RATE_TYPE_PUR INTO W_RATE_TYPE FROM CMNPARAM;

      IF (W_RATE_TYPE IS NULL) THEN
        W_ERROR := 'Common Rate Type Parameter not defined';
        --RAISE E_USEREXCEP;
      END IF;

      W_RATE_TYPE_FLG := 'M';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        W_ERROR := 'Common Rate Type Parameter not defined';
        --RAISE E_USEREXCEP;
    END GET_RATE_TYPE;


 PROCEDURE CL_INSERT_DATA (P_ENTITY_NUM IN NUMBER,
                         P_ASON_DATE  IN DATE,
                         P_CBD        IN DATE,
                         P_BRN_CODE   IN NUMBER ) IS

W_DATA_SQL CLOB;

  BEGIN
         W_DATA_SQL :='DELETE FROM CL_TMP_DATA CLS WHERE CLS.ACNTS_BRN_CODE = :1';
         EXECUTE IMMEDIATE W_DATA_SQL USING P_BRN_CODE ;

         W_DATA_SQL :='    INSERT INTO CL_TMP_DATA
       WITH ACCOUNT_LIST
            AS (SELECT ACA_BAL1.*,
                       NVL (LS.LNSUSPBAL_SUSP_BAL, 0) INT_SUSPENSE_AMT
                  FROM (SELECT ACNTS_ENTITY_NUM,
                               A.ACNTS_BRN_CODE,
                               A.ACNTS_INTERNAL_ACNUM,
                               ACLSH.ASSETCLSH_ASSET_CODE,
                               LN.LNACMIS_HO_DEPT_CODE,
                               CL.REPORT_DESC,
                               AD.ASSETCD_ASSET_CLASS,
                               AD.ASSETCD_PERF_CAT,
                               AD.ASSETCD_NONPERF_CAT,
                               FN_GET_ASON_DR_OR_CR_BAL (A.ACNTS_ENTITY_NUM,
                                                         A.ACNTS_INTERNAL_ACNUM,
                                                         A.ACNTS_CURR_CODE,
                                                         :P_ASON_DATE,
                                                         :W_CBD,
                                                         ''D'',
                                                         0)
                                  ACBAL,
                               pkg_clreport_opt.GET_SECURED_VALUE (
                                  ACNTS_INTERNAL_ACNUM,
                                  :P_ASON_DATE,
                                  :W_CBD,
                                  ''BDT'')
                                  SECURITY_AMOUNT,
                               --CL21
                               PROVLED_BC_PROV_AMT BC_PROV_AMT                 --,
                          -- NVL (LS.LNSUSPBAL_SUSP_BAL, 0) INT_SUSPENSE_AMT
                          FROM ASSETCLSHIST ACLSH,
                               ASSETCD AD,
                               ACNTS A,
                               LNACMIS LN,
                               CLREPORT CL,
                               (  SELECT PROVLED_ENTITY_NUM,
                                         PROVLED_ACNT_NUM,
                                         SUM (
                                            NVL (
                                               (CASE
                                                   WHEN PR.PROVLED_ENTRY_TYPE = ''P''
                                                   THEN
                                                      PR.PROVLED_BC_PROV_AMT
                                                   ELSE
                                                      (-1) * PR.PROVLED_BC_PROV_AMT
                                                END),
                                               0))
                                            PROVLED_BC_PROV_AMT
                                    FROM PROVLED PR
                                GROUP BY PROVLED_ENTITY_NUM, PROVLED_ACNT_NUM) P
                         WHERE     ACNTS_ENTITY_NUM = 1
                               AND LNACMIS_ENTITY_NUM = 1
                               AND ASSETCLSH_ENTITY_NUM = 1
                               AND ACNTS_BRN_CODE = :P_BRN_CODE
                               AND ACLSH.ASSETCLSH_ASSET_CODE = AD.ASSETCD_CODE
                               AND ACLSH.ASSETCLSH_INTERNAL_ACNUM =
                                      A.ACNTS_INTERNAL_ACNUM
                               AND ACLSH.ASSETCLSH_INTERNAL_ACNUM NOT IN
                                      (SELECT L.LNWRTOFF_ACNT_NUM
                                         FROM LNWRTOFF L)
                               AND A.ACNTS_OPENING_DATE <= :P_ASON_DATE
                               AND (   A.ACNTS_CLOSURE_DATE IS NULL
                                    OR A.ACNTS_CLOSURE_DATE > :P_ASON_DATE)
                               AND A.ACNTS_AUTH_ON IS NOT NULL
                               AND LN.LNACMIS_INTERNAL_ACNUM =
                                      A.ACNTS_INTERNAL_ACNUM
                               AND ACLSH.ASSETCLSH_EFF_DATE =
                                      (SELECT MAX (H.ASSETCLSH_EFF_DATE)
                                         FROM ASSETCLSHIST H
                                        WHERE     H.ASSETCLSH_INTERNAL_ACNUM =
                                                     A.ACNTS_INTERNAL_ACNUM
                                              AND H.ASSETCLSH_EFF_DATE <=
                                                     :P_ASON_DATE)
                               AND CL.REPORT_CODE = LNACMIS_HO_DEPT_CODE
                               AND LN.LNACMIS_ENTITY_NUM =
                                      P.PROVLED_ENTITY_NUM(+)
                               AND LN.LNACMIS_INTERNAL_ACNUM =
                                      P.PROVLED_ACNT_NUM(+)) ACA_BAL1,
                       LNSUSPBAL LS
                 WHERE     ACA_BAL1.ACNTS_INTERNAL_ACNUM =
                              LS.LNSUSPBAL_ACNT_NUM(+)
                       AND ACA_BAL1.ACNTS_ENTITY_NUM = LS.LNSUSPBAL_ENTITY_NUM(+)),
            PROVCALC_DATA
            AS (SELECT PROVC_INTERNAL_ACNUM,
                       PROVC_ENTITY_NUM,
                       PROVC_PROV_ON_BAL_BC,
                       PROVC_PROC_DATE
                  FROM PROVCALC
                 WHERE PROVC_PROC_DATE = :P_ASON_DATE)
       SELECT *
         FROM ACCOUNT_LIST, PROVCALC_DATA
        WHERE     ACCOUNT_LIST.ACNTS_INTERNAL_ACNUM =
                     PROVCALC_DATA.PROVC_INTERNAL_ACNUM(+)
              AND ACCOUNT_LIST.ACNTS_ENTITY_NUM =
                     PROVCALC_DATA.PROVC_ENTITY_NUM(+)
              AND ACCOUNT_LIST.ACNTS_BRN_CODE = :P_BRN_CODE';

     EXECUTE IMMEDIATE W_DATA_SQL USING P_ASON_DATE, P_CBD, P_ASON_DATE, P_CBD, P_BRN_CODE, P_ASON_DATE,
                                   P_ASON_DATE,P_ASON_DATE,P_ASON_DATE, P_BRN_CODE;
                                   COMMIT ;

  END CL_INSERT_DATA;

    --Note: Main Calling Start From Here.
  BEGIN
    W_RATE_TYPE      := '';
    W_RATE_TYPE_FLG  := '';
    W_ASON_DATE      := P_ASON_DATE;
    W_CBD            := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE(P_ENTITY_NUM);
    W_BASE_CURR_CODE := PKG_PB_GLOBAL.FN_GET_INS_BASE_CURR(P_ENTITY_NUM);
    GET_RATE_TYPE;
    V_GLOB_ENTITY_NUM := P_ENTITY_NUM;

    V_WDBRN_BSRCD := '';

    IF NVL(P_BRN_CODE, 0) <> 0 THEN
      BEGIN
        W_SQL := 'SELECT M.MBRN_BSR_CODE FROM MBRN M WHERE M.MBRN_CODE=' ||
                 P_BRN_CODE;

        EXECUTE IMMEDIATE W_SQL
          INTO V_WDBRN_BSRCD;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_WDBRN_BSRCD := '';
      END;
    ELSE
      V_WDBRN_BSRCD := '';
    END IF;

    ---
    V_SS_SUBTOTAL := 0 ;

BEGIN
  FOR IDX IN (SELECT MBRN_CODE
    FROM MBRN
   START WITH MBRN_CODE = P_BRN_CODE
  CONNECT BY PRIOR MBRN_CODE = MBRN_PARENT_ADMIN_CODE
   ORDER SIBLINGS BY MBRN_CODE) LOOP
  SP_CL_INSERT_DATA(P_ENTITY_NUM,W_ASON_DATE,W_CBD,IDX.MBRN_CODE);
  END LOOP;
END;


    W_ERROR := '';
    W_SQL   := 'SELECT CL.REPORT_DESC,CL.REPORT_CODE FROM CLREPORT CL ORDER BY CL.SERIAL_NO';

    --W_SQL := 'SELECT CL.REPORT_DESC,CL.REPORT_CODE FROM CLREPORT CL WHERE CL.REPORT_CODE = ''CL46''
    --ORDER BY CL.SERIAL_NO';

    EXECUTE IMMEDIATE W_SQL BULK COLLECT
      INTO V_TEMP_TABLEA;

    IF (V_TEMP_TABLEA.FIRST IS NOT NULL) THEN

      FOR I IN V_TEMP_TABLEA.FIRST .. V_TEMP_TABLEA.LAST LOOP

        PRINT.BAL_UNCLASS  := 0;
        PRINT.BAL_SPECIAL  := 0;
        PRINT.BAL_SUBSS    := 0;
        PRINT.BAL_DOUBT    := 0;
        PRINT.BAL_BAD_LOSS := 0;
        PRINT.TOT_BAL_OUT  := 0;

        PRINT.PRO_BASE_UN := 0;
        PRINT.PRO_BASE_SP := 0;
        PRINT.PRO_BASE_SS := 0;
        PRINT.PRO_BASE_DF := 0;
        PRINT.PRO_BASE_BL := 0;

        PRINT.INT_SUS_UN  := 0;
        PRINT.INT_SUS_SP  := 0;
        PRINT.INT_SUS_SS  := 0;
        PRINT.INT_SUS_DF  := 0;
        PRINT.INT_SUS_BL  := 0;
        PRINT.INT_SUS_TOT := 0;
        PRINT.INT_SS_MIN_SUM := 0;

        PRINT.INT_CLA_TOT := 0;
        V_ASON_AC_BAL     := 0;
        V_ASON_BC_BAL     := 0;
        O_SECURITY_VAL    := 0;
        TMP_BP_SM_AMT     := 0;
        TMP_BP_SS_AMT     := 0;

        TMP_BP_DF_AMT  := 0;
        TMP_BP_BL_AMT  := 0;
        GET_SUS_SM_AMT := 0;
        GET_SUS_SS_AMT := 0;
        GET_SUS_DF_AMT := 0;
        GET_SUS_BL_AMT := 0;

        O_ASON_AMT        := 0;
        W_BASE_PRO_CAL_SM := 0;
        W_BASE_PRO_CAL_SS := 0;
        W_BASE_PRO_CAL_DF := 0;
        W_BASE_PRO_CAL_BL := 0;
        W_DUMMY_BAL       := 0;

        INITIALIZE_VALUES;

        ----END FOR VARIABLE INITIZALATIONS----

        -- VIJAY - 12TH MARCH 2013 - ADD - BEG
        IF (V_TEMP_TABLEA(I)
           .TMP_CL_CODE = 'CL2' OR V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL3' OR V_TEMP_TABLEA(I)
           .TMP_CL_CODE = 'CL4' OR V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL5') THEN

          PRINT.BAL_UNCLASS  := '';
          PRINT.BAL_SPECIAL  := '';
          PRINT.BAL_SUBSS    := '';
          PRINT.BAL_DOUBT    := '';
          PRINT.BAL_BAD_LOSS := '';
          PRINT.TOT_BAL_OUT  := '';

          PRINT.PRO_BASE_UN := '';
          PRINT.PRO_BASE_SP := '';
          PRINT.PRO_BASE_SS := '';
          PRINT.PRO_BASE_DF := '';
          PRINT.PRO_BASE_BL := '';

          PRINT.INT_SUS_UN  := '';
          PRINT.INT_SUS_SP  := '';
          PRINT.INT_SUS_SS  := '';
          PRINT.INT_SUS_DF  := '';
          PRINT.INT_SUS_BL  := '';
          PRINT.INT_SUS_TOT := '';
          PRINT.INT_CLA_TOT := '';
          PRINT.SEC_VAL     := '';
          PRINT.INT_SS_MIN_SUM := 0;

          PRINT.AMT_PROV_RE := '';
          PRINT.RPT_DESCN   := V_TEMP_TABLEA(I).TMP_CL_DESCN;

          PG_NUMBER       := PG_NUMBER + 1;
          PRINT.PG_NO     := PG_NUMBER;
          PRINT.BRN_BSRCD := V_WDBRN_BSRCD;

          PIPE ROW(PRINT);
        ELSE
          ------FUNCTION START FOR  BALANCE OUTSTANDING------

          IF (V_TEMP_TABLEA(I)
             .TMP_CL_CODE = 'CL21' OR V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL22' OR V_TEMP_TABLEA(I)
             .TMP_CL_CODE = 'CL23' OR V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL24' OR V_TEMP_TABLEA(I)
             .TMP_CL_CODE = 'CL31' OR V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL32' OR V_TEMP_TABLEA(I)
             .TMP_CL_CODE = 'CL33' OR V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL34' OR V_TEMP_TABLEA(I)
             .TMP_CL_CODE = 'CL41' OR V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL42' OR V_TEMP_TABLEA(I)
             .TMP_CL_CODE = 'CL43' OR V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL44' OR V_TEMP_TABLEA(I)
             .TMP_CL_CODE = 'CL45' OR V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL46' OR V_TEMP_TABLEA(I)
             .TMP_CL_CODE = 'CL51' OR V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL52' OR V_TEMP_TABLEA(I)
             .TMP_CL_CODE = 'CL7') THEN
            --------------------- WE'RE INTERESTED ON DEBIT BALANCE OF ACCOUNTS NOT CREDIT ONES------------

          -- Need To Replace

            W_SQL :=   'SELECT  ASSETCLSH_ASSET_CODE,
                            ASSETCD_ASSET_CLASS,
                            ASSETCD_PERF_CAT,
                            ASSETCD_NONPERF_CAT,ABS( SUM (NVL(CL_S.ACBAL,0))) , ABS(NVL(SUM( CASE WHEN CL_S.ACBAL <> 0  THEN CL_S.INT_SUSPENSE_AMT  ELSE 0  END   ),0))  ,ABS(NVL(SUM( CASE WHEN CL_S.ACBAL <> 0  THEN CL_S.SECURITY_AMOUNT  ELSE 0 END   ),0)),  ABS(NVL(SUM( CASE WHEN CL_S.ACBAL <> 0  THEN CL_S.provc_prov_on_bal_bc  ELSE 0 END   ),0)) , sum (CASE WHEN CL_S.Acbal<> 0 THEN NVL(CL_S.BC_PROV_AMT,0) ELSE 0 END )
          FROM CL_TMP_DATA CL_S  WHERE CL_S.LNACMIS_HO_DEPT_CODE = :1 AND ASON_DATE=:W_ASON_DATE' ;
           IF NVL(P_BRN_CODE, 0) <> 0 THEN
              W_SQL := W_SQL || ' AND  CL_S.ACNTS_BRN_CODE IN (SELECT MBRN_CODE
           FROM MBRN START WITH MBRN_CODE = ' || P_BRN_CODE || ' CONNECT BY PRIOR MBRN_CODE = MBRN_PARENT_ADMIN_CODE)';
            END IF;
            W_SQL := W_SQL ||
                     ' GROUP BY ASSETCLSH_ASSET_CODE,
                                          ASSETCD_ASSET_CLASS,
                                          ASSETCD_PERF_CAT,
                                          ASSETCD_NONPERF_CAT ';
                --Dbms_Output.put_line(W_SQL) ;
            EXECUTE IMMEDIATE W_SQL BULK COLLECT INTO V_TEMP_TABLED USING V_TEMP_TABLEA(I).TMP_CL_CODE, W_ASON_DATE;

               --Note:  START FOR BALANCE OUTSTANDING AMOUNT / SUSPENSE AMOUNT / SECURITY
                 V_TOT_SEC_AMT1 :=0;
                 BC_PROV_AMT := 0 ;
                 PRINT.SEC_VAL := 0 ;
                 PRINT.AMT_PROV_RE := 0 ;
                 V_CL4_SS_DATA := 0;
                  PRINT.INT_SS_MIN_SUM := 0;

                  BEGIN
                     SELECT NVL(SUM (DEFAULT_AMT), 0)
                          INTO V_CL4_SS_DATA
                          FROM CL_TMP_DATA
                         WHERE     ACNTS_ENTITY_NUM = 1
                               AND ACNTS_BRN_CODE = P_BRN_CODE
                               AND LNACMIS_HO_DEPT_CODE =
                                      V_TEMP_TABLEA (I).TMP_CL_CODE
                               AND ASSETCD_NONPERF_CAT = '1'
                               AND ASSETCD_ASSET_CLASS = 'N'
                               AND ASON_DATE = W_ASON_DATE;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        V_CL4_SS_DATA := 0;
                  END;
        PRINT.INT_SS_MIN_SUM := V_CL4_SS_DATA;
        W_TOT_CL4_SS_DATA := W_TOT_CL4_SS_DATA+V_CL4_SS_DATA;
        IF V_TEMP_TABLED.FIRST IS NOT NULL THEN
        --

         PRINT.SEC_VAL := 0 ;
         PRINT.AMT_PROV_RE := 0 ;

         FOR INS IN V_TEMP_TABLED.FIRST .. V_TEMP_TABLED.LAST LOOP


            AMT_CLASS := V_TEMP_TABLED(INS).TMP_ASON_AMT;
            INT_SUSPENSE_AMT := V_TEMP_TABLED(INS).TMP_LNSUP_AMT;
            V_TOT_SEC_AMT1 :=  V_TOT_SEC_AMT1+ V_TEMP_TABLED(INS).TMP_SECURITY_AMT;
            BC_PROV_AMT :=  BC_PROV_AMT + V_TEMP_TABLED(INS).TMP_BC_PROV_AMT;

            IF (V_TEMP_TABLED(INS).TMP_ASSET_CLASS = 'P') THEN
              --UC
              IF (V_TEMP_TABLED(INS).TMP_PER_CAT = '1') THEN
                PRINT.BAL_UNCLASS := PRINT.BAL_UNCLASS + AMT_CLASS;
                PRINT.INT_SUS_UN := PRINT.INT_SUS_UN + INT_SUSPENSE_AMT;

             --   PRINT.INT_SUS_UN  := SUBTOTAL_INS_UN;


                --SM
              ELSE
                PRINT.BAL_SPECIAL := PRINT.BAL_SPECIAL + AMT_CLASS;
                PRINT.INT_SUS_SP := PRINT.INT_SUS_SP + INT_SUSPENSE_AMT;
                PRINT.PRO_BASE_SP := PRINT.PRO_BASE_SP + V_TEMP_TABLED(INS).TMP_BASE_PROV_AMT_BC;

              END IF;
            ELSE
              --SS
              IF (V_TEMP_TABLED(INS).TMP_NONPER_CAT = 1) THEN
                PRINT.BAL_SUBSS := PRINT.BAL_SUBSS + AMT_CLASS;
                PRINT.INT_SUS_SS := PRINT.INT_SUS_SS + INT_SUSPENSE_AMT;
               PRINT.PRO_BASE_SS := PRINT.PRO_BASE_SS + V_TEMP_TABLED(INS).
                                          TMP_BASE_PROV_AMT_BC;
                --DF
              ELSIF (V_TEMP_TABLED(INS).TMP_NONPER_CAT = 2) THEN
                PRINT.BAL_DOUBT := PRINT.BAL_DOUBT + AMT_CLASS;
                PRINT.INT_SUS_DF := PRINT.INT_SUS_DF + INT_SUSPENSE_AMT;
                PRINT.PRO_BASE_DF := PRINT.PRO_BASE_DF + V_TEMP_TABLED(INS).TMP_BASE_PROV_AMT_BC;
                --BL
              ELSIF (V_TEMP_TABLED(INS).TMP_NONPER_CAT = 3) THEN
                PRINT.BAL_BAD_LOSS := PRINT.BAL_BAD_LOSS + AMT_CLASS;
                PRINT.INT_SUS_BL := PRINT.INT_SUS_BL + INT_SUSPENSE_AMT;
                PRINT.PRO_BASE_BL := PRINT.PRO_BASE_BL + V_TEMP_TABLED(INS)
                                          .TMP_BASE_PROV_AMT_BC;
              END IF;
            END IF;
           -- V_TOT_SEC_AMT1 := V_TOT_SEC_AMT1 + V_TEMP_TABLED(INS).TMP_SECURITY_AMT ;
          --  BC_PROV_AMT  := BC_PROV_AMT + V_TEMP_TABLED(INS).TMP_PROVC_PROV_ON_BAL_BC  ;

              --
          END LOOP;
          PRINT.SEC_VAL := V_TOT_SEC_AMT1 ;
          PRINT.AMT_PROV_RE := BC_PROV_AMT;

          V_TOT_SEC_AMT := V_TOT_SEC_AMT + V_TOT_SEC_AMT1 ;

           --PRINT.AMT_PROV_RE := BC_PROV_AMT;








       END IF;



            PRINT.TOT_BAL_OUT := PRINT.BAL_UNCLASS + PRINT.BAL_SPECIAL +
                                 PRINT.BAL_SUBSS + PRINT.BAL_DOUBT +
                                 PRINT.BAL_BAD_LOSS;
            PRINT.INT_CLA_TOT := PRINT.INT_SUS_SS + PRINT.INT_SUS_DF +
                                 PRINT.INT_SUS_BL;
            PRINT.INT_SUS_TOT := PRINT.INT_SUS_UN + PRINT.INT_SUS_SP +
                                 PRINT.INT_SUS_SS + PRINT.INT_SUS_DF +
                                 PRINT.INT_SUS_BL;

            V_BAL_UN      := V_BAL_UN + PRINT.BAL_UNCLASS;
            V_BAL_SP      := V_BAL_SP + PRINT.BAL_SPECIAL;
            V_BAL_SUB     := V_BAL_SUB + PRINT.BAL_SUBSS;
            V_BAL_DOU     := V_BAL_DOU + PRINT.BAL_DOUBT;
            V_BAL_BLOS    := V_BAL_BLOS + PRINT.BAL_BAD_LOSS;
            V_TOT_BAL_AMT := V_TOT_BAL_AMT + PRINT.TOT_BAL_OUT;

            V_AMT_PROV_REQ := V_AMT_PROV_REQ + PRINT.AMT_PROV_RE;

            V_INT_SUS_UN := V_INT_SUS_UN + PRINT.INT_SUS_UN;
            V_INT_SUS_SP := V_INT_SUS_SP + PRINT.INT_SUS_SP;
            V_INT_SUS_SS := V_INT_SUS_SS + PRINT.INT_SUS_SS;
            V_INT_SUS_DF := V_INT_SUS_DF + PRINT.INT_SUS_DF;
            V_INT_SUS_BL := V_INT_SUS_BL + PRINT.INT_SUS_BL;
            V_INT_SUS_TO := V_INT_SUS_TO + PRINT.INT_SUS_TOT;
            V_INT_CLA    := V_INT_CLA + PRINT.INT_CLA_TOT;

            V_PRO_BASE_SP  := V_PRO_BASE_SP + PRINT.PRO_BASE_SP;
            V_PRO_BASE_SUB := V_PRO_BASE_SUB + PRINT.PRO_BASE_SS;
            V_PRO_BASE_DF  := V_PRO_BASE_DF + PRINT.PRO_BASE_DF;
            V_PRO_BASE_BL  := V_PRO_BASE_BL + PRINT.PRO_BASE_BL;

            PRINT.PG_NO     := '';
            PRINT.Rpt_Descn := V_TEMP_TABLEA(I).TMP_CL_DESCN;
            PRINT.BRN_BSRCD := V_WDBRN_BSRCD;

            PIPE ROW(PRINT);
            ----CALCULATION FOR TOTALS END---

            /*
             REMOVED BY VIJAY ON 12TH MARCH 2013 - BEG

            ELSIF(V_TEMP_TABLEA(I).TMP_CL_CODE='CL24' OR
                V_TEMP_TABLEA(I).TMP_CL_CODE='CL34' OR
                V_TEMP_TABLEA(I).TMP_CL_CODE='CL46' OR
                V_TEMP_TABLEA(I).TMP_CL_CODE='CL56' OR
                V_TEMP_TABLEA(I).TMP_CL_CODE='CL63'
              )THEN
              REMOVED BY VIJAY ON 12TH MARCH 2013 - END
              */
            -- VIJAY - ADD - 12TH MARCH 2013 - BEG
          ELSIF (V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL25' OR V_TEMP_TABLEA(I)
                .TMP_CL_CODE = 'CL35' OR V_TEMP_TABLEA(I)
                .TMP_CL_CODE = 'CL47' OR V_TEMP_TABLEA(I)
                .TMP_CL_CODE = 'CL53') THEN
            -- VIJAY - ADD - 12TH MARCH 2013 - END

            ---SUB TOTAL FOR EVERY CL HEAD CODE

            PRINT.BAL_UNCLASS  := V_BAL_UN;
            PRINT.BAL_SPECIAL  := V_BAL_SP;
            PRINT.BAL_SUBSS    := V_BAL_SUB;
            PRINT.BAL_DOUBT    := V_BAL_DOU;
            PRINT.BAL_BAD_LOSS := V_BAL_BLOS;
            PRINT.TOT_BAL_OUT  := V_TOT_BAL_AMT;

            PRINT.AMT_PROV_RE := V_AMT_PROV_REQ;

            PRINT.INT_SUS_UN  := V_INT_SUS_UN;
            PRINT.INT_SUS_SP  := V_INT_SUS_SP;
            PRINT.INT_SUS_SS  := V_INT_SUS_SS;
            PRINT.INT_SUS_DF  := V_INT_SUS_DF;
            PRINT.INT_SUS_BL  := V_INT_SUS_BL;
            PRINT.INT_SUS_TOT := V_INT_SUS_TO;
            PRINT.INT_CLA_TOT := V_INT_CLA;

            PRINT.PRO_BASE_SP := V_PRO_BASE_SP;
            PRINT.PRO_BASE_SS := V_PRO_BASE_SUB;
            PRINT.PRO_BASE_DF := V_PRO_BASE_DF;
            PRINT.PRO_BASE_BL := V_PRO_BASE_BL;
            PRINT.SEC_VAL     := V_TOT_SEC_AMT;

            PRINT.PG_NO := '';

            SUBTOTAL_BAL_UN  := SUBTOTAL_BAL_UN + PRINT.BAL_UNCLASS;
            SUBTOTAL_BAL_SP  := SUBTOTAL_BAL_SP + PRINT.BAL_SPECIAL;
            SUBTOTAL_BAL_SS  := SUBTOTAL_BAL_SS + PRINT.BAL_SUBSS;
            SUBTOTAL_BAL_DF  := SUBTOTAL_BAL_DF + PRINT.BAL_DOUBT;
            SUBTOTAL_BAL_BL  := SUBTOTAL_BAL_BL + PRINT.BAL_BAD_LOSS;
            SUBTOTAL_BAL_TOT := SUBTOTAL_BAL_TOT + PRINT.TOT_BAL_OUT;

            SUBTOTAL_AMT_PRO_REQ := SUBTOTAL_AMT_PRO_REQ +
                                    PRINT.AMT_PROV_RE;

            SUBTOTAL_INS_UN      := SUBTOTAL_INS_UN + PRINT.INT_SUS_UN;
            SUBTOTAL_INS_SP      := SUBTOTAL_INS_SP + PRINT.INT_SUS_SP;
            SUBTOTAL_INS_SS      := SUBTOTAL_INS_SS + PRINT.INT_SUS_SS;
            SUBTOTAL_INS_DF      := SUBTOTAL_INS_DF + PRINT.INT_SUS_DF;
            SUBTOTAL_INS_BL      := SUBTOTAL_INS_BL + PRINT.INT_SUS_BL;
            SUBTOTAL_INS_TOT     := SUBTOTAL_INS_TOT + PRINT.INT_SUS_TOT;
            SUBTOTAL_INS_CLA_TOT := SUBTOTAL_INS_CLA_TOT +
                                    PRINT.INT_CLA_TOT;

            SUBTOTAL_BASE_SP := SUBTOTAL_BASE_SP + PRINT.PRO_BASE_SP;
            SUBTOTAL_BASE_SS := SUBTOTAL_BASE_SS + PRINT.PRO_BASE_SS;
            SUBTOTAL_BASE_DF := SUBTOTAL_BASE_DF + PRINT.PRO_BASE_DF;
            SUBTOTAL_BASE_BL := SUBTOTAL_BASE_BL + PRINT.PRO_BASE_BL;
            V_SUBTOT_SEC_AMT := V_SUBTOT_SEC_AMT + PRINT.SEC_VAL;

            PRINT.Rpt_Descn := V_TEMP_TABLEA(I).TMP_CL_DESCN;
            PRINT.INT_SS_MIN_SUM := W_TOT_CL4_SS_DATA;
            V_SS_SUBTOTAL := V_SS_SUBTOTAL +   W_TOT_CL4_SS_DATA ;

            PIPE ROW(PRINT);

            V_BAL_UN      := 0;
            V_BAL_SP      := 0;
            V_BAL_SUB     := 0;
            V_BAL_DOU     := 0;
            V_BAL_BLOS    := 0;
            V_TOT_BAL_AMT := 0;

            V_AMT_PROV_REQ := 0;

            V_INT_SUS_UN := 0;
            V_INT_SUS_SP := 0;
            V_INT_SUS_SS := 0;
            V_INT_SUS_DF := 0;
            V_INT_SUS_BL := 0;
            V_INT_SUS_TO := 0;
            V_INT_CLA    := 0;

            V_PRO_BASE_SP  := 0;
            V_PRO_BASE_SUB := 0;
            V_PRO_BASE_DF  := 0;
            V_PRO_BASE_BL  := 0;
            V_TOT_SEC_AMT  := 0;
            W_TOT_CL4_SS_DATA :=0;
            /*
               REMOVED BY VIJAY ON 12TH MARCH 2013 - BEG
            ELSIF(V_TEMP_TABLEA(I).TMP_CL_CODE='CL64')THEN
               REMOVED BY VIJAY ON 12TH MARCH 2013  -END
            */

          ELSIF (V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL54') THEN

            --OVER ALL SUB TOTAL---

            PRINT.BAL_UNCLASS  := SUBTOTAL_BAL_UN;
            PRINT.BAL_SPECIAL  := SUBTOTAL_BAL_SP;
            PRINT.BAL_SUBSS    := SUBTOTAL_BAL_SS;
            PRINT.BAL_DOUBT    := SUBTOTAL_BAL_DF;
            PRINT.BAL_BAD_LOSS := SUBTOTAL_BAL_BL;
            PRINT.TOT_BAL_OUT  := SUBTOTAL_BAL_TOT;

            PRINT.AMT_PROV_RE := SUBTOTAL_AMT_PRO_REQ;

            PRINT.INT_SUS_UN  := SUBTOTAL_INS_UN;
            PRINT.INT_SUS_SP  := SUBTOTAL_INS_SP;
            PRINT.INT_SUS_SS  := SUBTOTAL_INS_SS;
            PRINT.INT_SUS_DF  := SUBTOTAL_INS_DF;
            PRINT.INT_SUS_BL  := SUBTOTAL_INS_BL;
            PRINT.INT_SUS_TOT := SUBTOTAL_INS_TOT;
            PRINT.INT_CLA_TOT := SUBTOTAL_INS_CLA_TOT;

            PRINT.PRO_BASE_SP := SUBTOTAL_BASE_SP;
            PRINT.PRO_BASE_SS := SUBTOTAL_BASE_SS;
            PRINT.PRO_BASE_DF := SUBTOTAL_BASE_DF;
            PRINT.PRO_BASE_BL := SUBTOTAL_BASE_BL;

            PRINT.PG_NO := '';

            PRINT.Rpt_Descn := V_TEMP_TABLEA(I).TMP_CL_DESCN;
            PRINT.INT_SS_MIN_SUM := V_SS_SUBTOTAL ;

            PIPE ROW(PRINT);
            --  ELSIF(V_TEMP_TABLEA(I).TMP_CL_CODE='CL8')THEN REMOVED BY VIJAY ON 12TH MARCH 2013
          ELSIF (V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL6') THEN

            ---GRAND TOTAL---

            GRANDTOTAL_BAL_UN  := V_BAL_UN + SUBTOTAL_BAL_UN;
            GRANDTOTAL_BAL_SP  := V_BAL_SP + SUBTOTAL_BAL_SP;
            GRANDTOTAL_BAL_SS  := V_BAL_SUB + SUBTOTAL_BAL_SS;
            GRANDTOTAL_BAL_DF  := V_BAL_DOU + SUBTOTAL_BAL_DF;
            GRANDTOTAL_BAL_BL  := V_BAL_BLOS + SUBTOTAL_BAL_BL;
            GRANDTOTAL_BAL_TOT := V_TOT_BAL_AMT + SUBTOTAL_BAL_TOT;

            GRANDTOTAL_AMT_PRO_REQ := V_AMT_PROV_REQ + SUBTOTAL_AMT_PRO_REQ;

            GRANDTOTAL_INS_UN      := V_INT_SUS_UN + SUBTOTAL_INS_UN;
            GRANDTOTAL_INS_SP      := V_INT_SUS_SP + SUBTOTAL_INS_SP;
            GRANDTOTAL_INS_SS      := V_INT_SUS_SS + SUBTOTAL_INS_SS;
            GRANDTOTAL_INS_DF      := V_INT_SUS_DF + SUBTOTAL_INS_DF;
            GRANDTOTAL_INS_BL      := V_INT_SUS_BL + SUBTOTAL_INS_BL;
            GRANDTOTAL_INS_TOT     := V_INT_SUS_TO + SUBTOTAL_INS_TOT;
            GRANDTOTAL_INS_CLA_TOT := V_INT_CLA + SUBTOTAL_INS_CLA_TOT;

            GRANDTOTAL_BASE_SP := V_PRO_BASE_SP + SUBTOTAL_BASE_SP;
            GRANDTOTAL_BASE_SS := V_PRO_BASE_SUB + SUBTOTAL_BASE_SS;
            GRANDTOTAL_BASE_DF := V_PRO_BASE_DF + SUBTOTAL_BASE_DF;
            GRANDTOTAL_BASE_BL := V_PRO_BASE_BL + SUBTOTAL_BASE_BL;
            V_GRANDTOT_SEC_AMT := V_TOT_SEC_AMT + V_SUBTOT_SEC_AMT;

            PRINT.BAL_UNCLASS  := GRANDTOTAL_BAL_UN;
            PRINT.BAL_SPECIAL  := GRANDTOTAL_BAL_SP;
            PRINT.BAL_SUBSS    := GRANDTOTAL_BAL_SS;
            PRINT.BAL_DOUBT    := GRANDTOTAL_BAL_DF;
            PRINT.BAL_BAD_LOSS := GRANDTOTAL_BAL_BL;
            PRINT.TOT_BAL_OUT  := GRANDTOTAL_BAL_TOT;

            PRINT.AMT_PROV_RE := GRANDTOTAL_AMT_PRO_REQ;

            PRINT.INT_SUS_UN  := GRANDTOTAL_INS_UN;
            PRINT.INT_SUS_SP  := GRANDTOTAL_INS_SP;
            PRINT.INT_SUS_SS  := GRANDTOTAL_INS_SS;
            PRINT.INT_SUS_DF  := GRANDTOTAL_INS_DF;
            PRINT.INT_SUS_BL  := GRANDTOTAL_INS_BL;
            PRINT.INT_SUS_TOT := GRANDTOTAL_INS_TOT;
            PRINT.INT_CLA_TOT := GRANDTOTAL_INS_CLA_TOT;

            PRINT.PRO_BASE_SP := GRANDTOTAL_BASE_SP;
            PRINT.PRO_BASE_SS := GRANDTOTAL_BASE_SS;
            PRINT.PRO_BASE_DF := GRANDTOTAL_BASE_DF;
            PRINT.PRO_BASE_BL := GRANDTOTAL_BASE_BL;
            PRINT.SEC_VAL     := V_GRANDTOT_SEC_AMT;
            PRINT.INT_SS_MIN_SUM := V_SS_SUBTOTAL ;

            PRINT.PG_NO     := '';
            PRINT.Rpt_Descn := V_TEMP_TABLEA(I).TMP_CL_DESCN;

            PIPE ROW(PRINT);

          ELSIF (V_TEMP_TABLEA(I).TMP_CL_CODE = 'CL8') THEN
            ---GRAND TOTAL---

            GRANDTOTAL_BAL_UN  := '';
            GRANDTOTAL_BAL_SP  := '';
            GRANDTOTAL_BAL_SS  := '';
            GRANDTOTAL_BAL_DF  := '';
            GRANDTOTAL_BAL_BL  := '';
            GRANDTOTAL_BAL_TOT := '';

            GRANDTOTAL_AMT_PRO_REQ := '';

            GRANDTOTAL_INS_UN      := '';
            GRANDTOTAL_INS_SP      := '';
            GRANDTOTAL_INS_SS      := '';
            GRANDTOTAL_INS_DF      := '';
            GRANDTOTAL_INS_BL      := '';
            GRANDTOTAL_INS_TOT     := '';
            GRANDTOTAL_INS_CLA_TOT := '';

            GRANDTOTAL_BASE_SP := '';
            GRANDTOTAL_BASE_SS := '';
            GRANDTOTAL_BASE_DF := '';
            GRANDTOTAL_BASE_BL := '';
            V_GRANDTOT_SEC_AMT := '';

            PRINT.BAL_UNCLASS  := '';
            PRINT.BAL_SPECIAL  := '';
            PRINT.BAL_SUBSS    := '';
            PRINT.BAL_DOUBT    := '';
            PRINT.BAL_BAD_LOSS := '';
            PRINT.TOT_BAL_OUT  := '';

            PRINT.AMT_PROV_RE := '';

            PRINT.INT_SUS_UN  := '';
            PRINT.INT_SUS_SP  := '';
            PRINT.INT_SUS_SS  := '';
            PRINT.INT_SUS_DF  := '';
            PRINT.INT_SUS_BL  := '';
            PRINT.INT_SUS_TOT := '';
            PRINT.INT_CLA_TOT := '';

            PRINT.PRO_BASE_SP := '';
            PRINT.PRO_BASE_SS := '';
            PRINT.PRO_BASE_DF := '';
            PRINT.PRO_BASE_BL := '';
            PRINT.SEC_VAL     := '';

            PRINT.PG_NO := '';
            --========= OFF BALANCE SHEET
            P_TOT_OFF_BAL_SHEET_AMT := 0;
            FOR IDX IN (SELECT RPTHDGLDTL_GLACC_CODE
                          FROM RPTHEADGLDTL R2
                         WHERE R2.RPTHDGLDTL_CODE IN
                               ('L2401', 'L2402', 'L2403', 'L2501', 'L2502')) LOOP
                               FOR IDX1 IN (SELECT MBRN_CODE FROM MBRN START WITH MBRN_CODE = P_BRN_CODE
                               CONNECT BY PRIOR MBRN_CODE = MBRN_PARENT_ADMIN_CODE
                               ORDER SIBLINGS BY MBRN_CODE) LOOP
			                             GET_ASON_GLBAL(1,
			                             IDX1.MBRN_CODE,
			                             IDX.RPTHDGLDTL_GLACC_CODE,
			                             W_BASE_CURR_CODE,
			                             W_ASON_DATE,
			                             W_CBD,
			                             P_GL_BAL_AC,
			                             P_GL_BAL_BC,
			                             W_ERROR_MSG);

              P_TOT_OFF_BAL_SHEET_AMT := P_TOT_OFF_BAL_SHEET_AMT +
                                         P_GL_BAL_BC;
                                END LOOP;
                               
            END LOOP;
            PRINT.BAL_UNCLASS := P_TOT_OFF_BAL_SHEET_AMT;
            PRINT.TOT_BAL_OUT := P_TOT_OFF_BAL_SHEET_AMT;
            PRINT.AMT_PROV_RE := ROUND((P_TOT_OFF_BAL_SHEET_AMT * 0.01), 0);
            --==========
            PRINT.Rpt_Descn := V_TEMP_TABLEA(I).TMP_CL_DESCN;

            PIPE ROW(PRINT);
            -- VIJAY - 12TH MARCH 2013 - ADD - END

          END IF;
        END IF;
      END LOOP;
      ---FIRST FOR LOOP END------------------

    ELSE
      NULL;
    END IF;

    /*EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
       DBMS_OUTPUT.PUT_LINE ('EXCEPTION' || SQLERRM);
    WHEN E_USEREXCEP
    THEN
       DBMS_OUTPUT.PUT_LINE ('ERROR IN CL REPORT');
    WHEN OTHERS
    THEN
       DBMS_OUTPUT.PUT_LINE (SQLERRM);*/
    --(Noor)   RETURN 'NULL';
  END CL_RPT_CONSOLIDATED;
----============ PROCEDURE TO INSERT data into table =========== ------------

 --================= START CL WORKSHEET (Alam) ===============

  FUNCTION CL_RPT_WORKSHEET(P_ENTITY_NUM IN NUMBER,
                            P_ASON_DATE  IN DATE,
                            P_BRN_CODE   IN NUMBER) RETURN TY_TMP_WS
    PIPELINED
  --RETURN VARCHAR2
   IS
    E_USEREXCEP EXCEPTION;
    W_ERROR_MSG VARCHAR2(30);
    W_DUMMY     NUMBER;

    W_CL_NO              VARCHAR2(30) := '1';
    W_CL_WS_PAGE_NO      NUMBER(3) := 0;
    W_CL_ROW_COUNT       NUMBER(3) := 0;
    W_CL_EMPTY_ROW_COUNT NUMBER(3) := 0;
    W_CL_SL_NO           NUMBER(5) := 0;

  BEGIN
    W_CBD                := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE(P_ENTITY_NUM);
    PRINT.PG_NO          := NULL;
    PRINT.RPT_DESCN      := '';
    PRINT.RPT_SHORT_DESC := '';
    PRINT.RPT_HEAD_CODE  := '';

    PRINT.BAL_UNCLASS  := 0;
    PRINT.BAL_SPECIAL  := 0;
    PRINT.BAL_SUBSS    := 0;
    PRINT.BAL_DOUBT    := 0;
    PRINT.BAL_BAD_LOSS := 0;
    PRINT.TOT_BAL_OUT  := 0;

    PRINT.PRO_BASE_UN := 0;
    PRINT.PRO_BASE_SP := 0;
    PRINT.PRO_BASE_SS := 0;
    PRINT.PRO_BASE_DF := 0;
    PRINT.PRO_BASE_BL := 0;

    PRINT.INT_SUS_UN  := 0;
    PRINT.INT_SUS_SP  := 0;
    PRINT.INT_SUS_SS  := 0;
    PRINT.INT_SUS_DF  := 0;
    PRINT.INT_SUS_BL  := 0;
    PRINT.INT_SUS_TOT := 0;
    PRINT.INT_CLA_TOT := 0;

    FOR IDX_REC IN (SELECT DISTINCT CL_NO || '    -    ' || CL_PAGE_NO CL_BRN_NAME,
                                    CL_NO,
                                    CL_PAGE_NO,
                                    CL_OS_BAL,
                                    CL_OS_UC_ST_BAL,
                                    CL_OS_UC_SMA_BAL,
                                    CL_OS_SS_BAL,
                                    CL_OS_DF_BAL,
                                    CL_OS_BL_BAL,
                                    CL_PROV_SMA_BAL,
                                    CL_PROV_SS_BAL,
                                    CL_PROV_DF_BAL,
                                    CL_PROV_BL_BAL,
                                    CL_SEC_VAL,
                                    CL_SUSP_ST_BAL,
                                    CL_SUSP_SMA_BAL,
                                    CL_SUSP_CL_BAL,
                                    CL_TOTAL_BAL,
                                    CL_OS_DEF_BAL
                      FROM CLWORKSHEET
                     WHERE CL_BRN_CODE = P_BRN_CODE
                     ORDER BY CL_NO, CL_PAGE_NO) LOOP
      -- RESET VARIABLES (Start)
      PRINT_WS.CL_SL_NO         := NULL;
      PRINT_WS.CL_NO            := '';
      PRINT_WS.CL_PAGE_NO       := 0;
      PRINT_WS.CL_BRN_NAME      := '';
      PRINT_WS.CL_OS_BAL        := 0.0;
      PRINT_WS.CL_OS_UC_ST_BAL  := 0.0;
      PRINT_WS.CL_OS_UC_SMA_BAL := 0.0;
      PRINT_WS.CL_OS_SS_BAL     := 0.0;
      PRINT_WS.CL_OS_DF_BAL     := 0.0;
      PRINT_WS.CL_OS_BL_BAL     := 0.0;
      PRINT_WS.CL_PROV_SMA_BAL  := 0.0;
      PRINT_WS.CL_PROV_SS_BAL   := 0.0;
      PRINT_WS.CL_PROV_DF_BAL   := 0.0;
      PRINT_WS.CL_PROV_BL_BAL   := 0.0;
      PRINT_WS.CL_SEC_VAL       := 0.0;
      PRINT_WS.CL_SUSP_ST_BAL   := 0.0;
      PRINT_WS.CL_SUSP_SMA_BAL  := 0.0;
      PRINT_WS.CL_SUSP_CL_BAL   := 0.0;
      PRINT_WS.CL_TOTAL_BAL     := 0.0;
      PRINT_WS.CL_OS_DEF_BAL    := 0.0;
      -- RESET VARIABLES (END)

      IF W_CL_NO = '1' THEN
        W_CL_NO        := IDX_REC.CL_NO;
        W_CL_ROW_COUNT := 1;
      ELSIF W_CL_NO = IDX_REC.CL_NO THEN
        W_CL_ROW_COUNT := W_CL_ROW_COUNT + 1;
      ELSE
        W_CL_WS_PAGE_NO      := FLOOR(W_CL_ROW_COUNT / 20);
        W_CL_EMPTY_ROW_COUNT := ((W_CL_WS_PAGE_NO + 1) * 20) -
                                W_CL_ROW_COUNT;

        IF W_CL_EMPTY_ROW_COUNT = 0 THEN
          PRINT_WS.CL_BRN_NAME      := 'TOTAL';
          PRINT_WS.CL_OS_BAL        := TOT_CL_OS_BAL;
          PRINT_WS.CL_OS_UC_ST_BAL  := TOT_CL_OS_UC_ST_BAL;
          PRINT_WS.CL_OS_UC_SMA_BAL := TOT_CL_OS_UC_SMA_BAL;
          PRINT_WS.CL_OS_SS_BAL     := TOT_CL_OS_SS_BAL;
          PRINT_WS.CL_OS_DF_BAL     := TOT_CL_OS_DF_BAL;
          PRINT_WS.CL_OS_BL_BAL     := TOT_CL_OS_BL_BAL;
          PRINT_WS.CL_PROV_SMA_BAL  := TOT_CL_PROV_SMA_BAL;
          PRINT_WS.CL_PROV_SS_BAL   := TOT_CL_PROV_SS_BAL;
          PRINT_WS.CL_PROV_DF_BAL   := TOT_CL_PROV_DF_BAL;
          PRINT_WS.CL_PROV_BL_BAL   := TOT_CL_PROV_BL_BAL;
          PRINT_WS.CL_SEC_VAL       := TOT_CL_SEC_VAL;
          PRINT_WS.CL_SUSP_ST_BAL   := TOT_CL_SUSP_ST_BAL;
          PRINT_WS.CL_SUSP_SMA_BAL  := TOT_CL_SUSP_SMA_BAL;
          PRINT_WS.CL_SUSP_CL_BAL   := TOT_CL_SUSP_CL_BAL;
          PRINT_WS.CL_TOTAL_BAL     := TOT_CL_TOTAL_BAL;
          PRINT_WS.CL_OS_DEF_BAL    := TOT_CL_OS_DEF_BAL;

          PIPE ROW(PRINT_WS);
          W_CL_ROW_COUNT := W_CL_ROW_COUNT + 1;
        END IF;

        FOR IDX1 IN 1 .. W_CL_EMPTY_ROW_COUNT - 1 LOOP
          PRINT_WS.CL_BRN_NAME := '';

          PIPE ROW(PRINT_WS);
          W_CL_ROW_COUNT := W_CL_ROW_COUNT + 1;
        END LOOP;

        PRINT_WS.CL_BRN_NAME      := 'TOTAL';
        PRINT_WS.CL_OS_BAL        := TOT_CL_OS_BAL;
        PRINT_WS.CL_OS_UC_ST_BAL  := TOT_CL_OS_UC_ST_BAL;
        PRINT_WS.CL_OS_UC_SMA_BAL := TOT_CL_OS_UC_SMA_BAL;
        PRINT_WS.CL_OS_SS_BAL     := TOT_CL_OS_SS_BAL;
        PRINT_WS.CL_OS_DF_BAL     := TOT_CL_OS_DF_BAL;
        PRINT_WS.CL_OS_BL_BAL     := TOT_CL_OS_BL_BAL;
        PRINT_WS.CL_PROV_SMA_BAL  := TOT_CL_PROV_SMA_BAL;
        PRINT_WS.CL_PROV_SS_BAL   := TOT_CL_PROV_SS_BAL;
        PRINT_WS.CL_PROV_DF_BAL   := TOT_CL_PROV_DF_BAL;
        PRINT_WS.CL_PROV_BL_BAL   := TOT_CL_PROV_BL_BAL;
        PRINT_WS.CL_SEC_VAL       := TOT_CL_SEC_VAL;
        PRINT_WS.CL_SUSP_ST_BAL   := TOT_CL_SUSP_ST_BAL;
        PRINT_WS.CL_SUSP_SMA_BAL  := TOT_CL_SUSP_SMA_BAL;
        PRINT_WS.CL_SUSP_CL_BAL   := TOT_CL_SUSP_CL_BAL;
        PRINT_WS.CL_TOTAL_BAL     := TOT_CL_TOTAL_BAL;
        PRINT_WS.CL_OS_DEF_BAL    := TOT_CL_OS_DEF_BAL;

        PIPE ROW(PRINT_WS);
        W_CL_ROW_COUNT := W_CL_ROW_COUNT + 1;
        W_CL_NO        := IDX_REC.CL_NO;
        W_CL_ROW_COUNT := W_CL_ROW_COUNT + 1;
        RESET_TOT_VALUES;

      END IF;

      --=
      W_CL_SL_NO                := W_CL_SL_NO + 1;
      PRINT_WS.CL_NO            := '';
      PRINT_WS.CL_PAGE_NO       := 0;
      PRINT_WS.CL_SL_NO         := W_CL_SL_NO;
      PRINT_WS.CL_BRN_NAME      := W_CL_NO || ' - ' || IDX_REC.CL_PAGE_NO;
      PRINT_WS.CL_OS_BAL        := IDX_REC.CL_OS_BAL;
      PRINT_WS.CL_OS_UC_ST_BAL  := IDX_REC.CL_OS_UC_ST_BAL;
      PRINT_WS.CL_OS_UC_SMA_BAL := IDX_REC.CL_OS_UC_SMA_BAL;
      PRINT_WS.CL_OS_SS_BAL     := IDX_REC.CL_OS_SS_BAL;
      PRINT_WS.CL_OS_DF_BAL     := IDX_REC.CL_OS_DF_BAL;
      PRINT_WS.CL_OS_BL_BAL     := IDX_REC.CL_OS_BL_BAL;
      PRINT_WS.CL_PROV_SMA_BAL  := IDX_REC.CL_PROV_SMA_BAL;
      PRINT_WS.CL_PROV_SS_BAL   := IDX_REC.CL_PROV_SS_BAL;
      PRINT_WS.CL_PROV_DF_BAL   := IDX_REC.CL_PROV_DF_BAL;
      PRINT_WS.CL_PROV_BL_BAL   := IDX_REC.CL_PROV_BL_BAL;
      PRINT_WS.CL_SEC_VAL       := IDX_REC.CL_SEC_VAL;
      PRINT_WS.CL_SUSP_ST_BAL   := IDX_REC.CL_SUSP_ST_BAL;
      PRINT_WS.CL_SUSP_SMA_BAL  := IDX_REC.CL_SUSP_SMA_BAL;
      PRINT_WS.CL_SUSP_CL_BAL   := IDX_REC.CL_SUSP_CL_BAL;
      PRINT_WS.CL_TOTAL_BAL     := IDX_REC.CL_TOTAL_BAL;
      PRINT_WS.CL_OS_DEF_BAL    := IDX_REC.CL_OS_DEF_BAL;

      PIPE ROW(PRINT_WS);

      TOT_CL_OS_BAL        := TOT_CL_OS_BAL + IDX_REC.CL_OS_BAL;
      TOT_CL_OS_UC_ST_BAL  := TOT_CL_OS_UC_ST_BAL + IDX_REC.CL_OS_UC_ST_BAL;
      TOT_CL_OS_UC_SMA_BAL := TOT_CL_OS_UC_SMA_BAL +
                              IDX_REC.CL_OS_UC_SMA_BAL;
      TOT_CL_OS_SS_BAL     := TOT_CL_OS_SS_BAL + IDX_REC.CL_OS_SS_BAL;
      TOT_CL_OS_DF_BAL     := TOT_CL_OS_DF_BAL + IDX_REC.CL_OS_DF_BAL;
      TOT_CL_OS_BL_BAL     := TOT_CL_OS_BL_BAL + IDX_REC.CL_OS_BL_BAL;
      TOT_CL_PROV_SMA_BAL  := TOT_CL_PROV_SMA_BAL + IDX_REC.CL_PROV_SMA_BAL;
      TOT_CL_PROV_SS_BAL   := TOT_CL_PROV_SS_BAL + IDX_REC.CL_PROV_SS_BAL;
      TOT_CL_PROV_DF_BAL   := TOT_CL_PROV_DF_BAL + IDX_REC.CL_PROV_DF_BAL;
      TOT_CL_PROV_BL_BAL   := TOT_CL_PROV_BL_BAL + IDX_REC.CL_PROV_BL_BAL;
      TOT_CL_SEC_VAL       := TOT_CL_SEC_VAL + IDX_REC.CL_SEC_VAL;
      TOT_CL_SUSP_ST_BAL   := TOT_CL_SUSP_ST_BAL + IDX_REC.CL_SUSP_ST_BAL;
      TOT_CL_SUSP_SMA_BAL  := TOT_CL_SUSP_SMA_BAL + IDX_REC.CL_SUSP_SMA_BAL;
      TOT_CL_SUSP_CL_BAL   := TOT_CL_SUSP_CL_BAL + IDX_REC.CL_SUSP_CL_BAL;
      TOT_CL_TOTAL_BAL     := TOT_CL_TOTAL_BAL + IDX_REC.CL_TOTAL_BAL;
      TOT_CL_OS_DEF_BAL    := TOT_CL_OS_DEF_BAL + IDX_REC.CL_OS_DEF_BAL;

    END LOOP;

    W_CL_WS_PAGE_NO      := FLOOR(W_CL_ROW_COUNT / 20);
    W_CL_EMPTY_ROW_COUNT := ((W_CL_WS_PAGE_NO + 1) * 20) - W_CL_ROW_COUNT;

    IF W_CL_EMPTY_ROW_COUNT = 0 THEN
      PRINT_WS.CL_SL_NO         := NULL;
      PRINT_WS.CL_BRN_NAME      := 'TOTAL';
      PRINT_WS.CL_OS_BAL        := TOT_CL_OS_BAL;
      PRINT_WS.CL_OS_UC_ST_BAL  := TOT_CL_OS_UC_ST_BAL;
      PRINT_WS.CL_OS_UC_SMA_BAL := TOT_CL_OS_UC_SMA_BAL;
      PRINT_WS.CL_OS_SS_BAL     := TOT_CL_OS_SS_BAL;
      PRINT_WS.CL_OS_DF_BAL     := TOT_CL_OS_DF_BAL;
      PRINT_WS.CL_OS_BL_BAL     := TOT_CL_OS_BL_BAL;
      PRINT_WS.CL_PROV_SMA_BAL  := TOT_CL_PROV_SMA_BAL;
      PRINT_WS.CL_PROV_SS_BAL   := TOT_CL_PROV_SS_BAL;
      PRINT_WS.CL_PROV_DF_BAL   := TOT_CL_PROV_DF_BAL;
      PRINT_WS.CL_PROV_BL_BAL   := TOT_CL_PROV_BL_BAL;
      PRINT_WS.CL_SEC_VAL       := TOT_CL_SEC_VAL;
      PRINT_WS.CL_SUSP_ST_BAL   := TOT_CL_SUSP_ST_BAL;
      PRINT_WS.CL_SUSP_SMA_BAL  := TOT_CL_SUSP_SMA_BAL;
      PRINT_WS.CL_SUSP_CL_BAL   := TOT_CL_SUSP_CL_BAL;
      PRINT_WS.CL_TOTAL_BAL     := TOT_CL_TOTAL_BAL;
      PRINT_WS.CL_OS_DEF_BAL    := TOT_CL_OS_DEF_BAL;

      PIPE ROW(PRINT_WS);
      RESET_TOT_VALUES;
      W_CL_ROW_COUNT := W_CL_ROW_COUNT + 1;
      --ELSE
      -- PRINT_WS.CL_BRN_NAME  := 'TOTAL';
      --PIPE ROW (PRINT_WS);
      --W_CL_ROW_COUNT := W_CL_ROW_COUNT + 1;
    END IF;

    FOR IDX1 IN 1 .. W_CL_EMPTY_ROW_COUNT - 1 LOOP
      PRINT_WS.CL_BRN_NAME := '';
      PRINT_WS.CL_SL_NO    := NUlL;

      PIPE ROW(PRINT_WS);
      W_CL_ROW_COUNT := W_CL_ROW_COUNT + 1;
    END LOOP;
    PRINT_WS.CL_SL_NO         := NULL;
    PRINT_WS.CL_BRN_NAME      := 'TOTAL';
    PRINT_WS.CL_OS_BAL        := TOT_CL_OS_BAL;
    PRINT_WS.CL_OS_UC_ST_BAL  := TOT_CL_OS_UC_ST_BAL;
    PRINT_WS.CL_OS_UC_SMA_BAL := TOT_CL_OS_UC_SMA_BAL;
    PRINT_WS.CL_OS_SS_BAL     := TOT_CL_OS_SS_BAL;
    PRINT_WS.CL_OS_DF_BAL     := TOT_CL_OS_DF_BAL;
    PRINT_WS.CL_OS_BL_BAL     := TOT_CL_OS_BL_BAL;
    PRINT_WS.CL_PROV_SMA_BAL  := TOT_CL_PROV_SMA_BAL;
    PRINT_WS.CL_PROV_SS_BAL   := TOT_CL_PROV_SS_BAL;
    PRINT_WS.CL_PROV_DF_BAL   := TOT_CL_PROV_DF_BAL;
    PRINT_WS.CL_PROV_BL_BAL   := TOT_CL_PROV_BL_BAL;
    PRINT_WS.CL_SEC_VAL       := TOT_CL_SEC_VAL;
    PRINT_WS.CL_SUSP_ST_BAL   := TOT_CL_SUSP_ST_BAL;
    PRINT_WS.CL_SUSP_SMA_BAL  := TOT_CL_SUSP_SMA_BAL;
    PRINT_WS.CL_SUSP_CL_BAL   := TOT_CL_SUSP_CL_BAL;
    PRINT_WS.CL_TOTAL_BAL     := TOT_CL_TOTAL_BAL;
    PRINT_WS.CL_OS_DEF_BAL    := TOT_CL_OS_DEF_BAL;

    PIPE ROW(PRINT_WS);
    W_CL_ROW_COUNT := W_CL_ROW_COUNT + 1;
    RESET_TOT_VALUES;

    W_CL_NO        := W_CL_NO;
    W_CL_ROW_COUNT := W_CL_ROW_COUNT + 1;

    --
    --RETURN 'CL_WS';
  END CL_RPT_WORKSHEET;

  PROCEDURE GET_SECPROVPM IS
  BEGIN
    SELECT SECPROV_VALID_PROV_CALC_FLG, SECPROV_SEC_VALUE_DISC_PER
      INTO W_SECPROV_VALID_FLG, W_SECPROV_DISC_PER
      FROM SECPROV
     WHERE SECPROV_SEC_TYPE = W_SEC_TYPE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      W_SECPROV_VALID_FLG := '1';
      W_SECPROV_DISC_PER  := 0;
  END GET_SECPROVPM;

  PROCEDURE GET_SECPROVPMHIST (W_ASON_DATE IN DATE ) IS
  BEGIN

 --   Dbms_Output.put_line( W_SEC_TYPE|| W_ASON_DATE) ;
   --  W_ASON_DATE := W_ASON_DATE1  ;

    SELECT SECPROVH_VALID_PROV_CALC_FLG, SECPROVH_SEC_VALUE_DISC_PER
      INTO W_SECPROV_VALID_FLG, W_SECPROV_DISC_PER
      FROM SECPROVHIST
     WHERE SECPROVH_SEC_TYPE = W_SEC_TYPE
       AND SECPROVH_EFF_DATE =
           (SELECT MAX(SECPROVH_EFF_DATE)
              FROM SECPROVHIST
             WHERE SECPROVH_SEC_TYPE = W_SEC_TYPE
               AND SECPROVH_EFF_DATE <= W_ASON_DATE);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      W_SECPROV_VALID_FLG := '1';
      W_SECPROV_DISC_PER  := 0;
  END GET_SECPROVPMHIST;

  PROCEDURE GET_SECPROV_PARAM (W_CBD in DATE , W_ASON_DATE IN DATE )   IS
  BEGIN

    IF (W_ASON_DATE = W_CBD) THEN

      GET_SECPROVPM;
    ELSE
      GET_SECPROVPMHIST(W_ASON_DATE);
    END IF;
  END GET_SECPROV_PARAM;

  FUNCTION GET_SECURED_VALUE(INTERNAL_ACNUM   VARCHAR2,
                             W_ASON_DATE      DATE,
                             W_CBD            DATE,
                             W_BASE_CURR_CODE VARCHAR2) RETURN NUMBER IS
    W_PROD_CODE VARCHAR2(10) := '';

    W_DEP_ACC       VARCHAR2(20) := '';
    W_ACC_BAL       NUMBER(18, 3) := 0;
    W_SEC_VALUE     NUMBER(18, 3) := 0;
    W_CLIENT_NUM    VARCHAR2(10) := '';
    W_LIMIT_LINE_NO NUMBER := 0;
    W_CNT           NUMBER := 0;
    W_ASSIGN_PERC   NUMBER;
    W_SEC_NUM       NUMBER;
  BEGIN
    W_CNT            := 0;
    W_PROD_CODE      := '';
    W_DEP_ACC        := '';
    W_ACC_BAL        := 0;
    W_CLIENT_NUM     := '';
    W_LIMIT_LINE_NO  := 0;
    W_SEC_VALUE      := 0;
    W_ASSIGN_PERC    := 0;
    W_SEC_NUM        := 0;
    W_TOT_SEC_AMT_AC := 0;
    W_TOT_SEC_AMT_BC := 0;

    PKG_ENTITY.SP_SET_ENTITY_CODE(1);

    SELECT ACNTS_PROD_CODE
      INTO W_PROD_CODE
      FROM ACNTS A
     WHERE A.ACNTS_INTERNAL_ACNUM = INTERNAL_ACNUM;
    SELECT COUNT(*)
      INTO W_CNT
      FROM LADPRODMAP LNMAP
     WHERE LNMAP.LADPRODMAP_PROD_CODE = W_PROD_CODE;

    IF W_CNT > 0 THEN
      <<DEP_ACC_AMT>>
      BEGIN

        FOR DEP_ACC IN (SELECT LADDTL_DEP_ACNT_NUM
                          FROM LADACNTDTL LNDTL
                         WHERE LNDTL.LADDTL_INTERNAL_ACNUM = INTERNAL_ACNUM) LOOP
          W_ACC_BAL := W_ACC_BAL + FN_GET_ASON_ACBAL(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                                     DEP_ACC.LADDTL_DEP_ACNT_NUM,
                                                     W_BASE_CURR_CODE,
                                                     W_ASON_DATE,
                                                     W_CBD);
        END LOOP;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          W_DEP_ACC := 0;
      END DEP_ACC_AMT;
    ELSE
      /*
        --
        <<SECURED_VALUE>>
        BEGIN
          SELECT ACASLLDTL_CLIENT_NUM, ACASLLDTL_LIMIT_LINE_NUM
            INTO W_CLIENT_NUM, W_LIMIT_LINE_NO
            FROM ACASLLDTL A
           WHERE A.ACASLLDTL_INTERNAL_ACNUM = INTERNAL_ACNUM;

          FOR SEC_NUM IN (SELECT SECAGMTDTL_SEC_NUM
                            FROM SECASSIGNMTDTL
                           WHERE SECAGMTDTL_CLIENT_NUM = W_CLIENT_NUM
                             AND SECAGMTDTL_LIMIT_LINE_NUM = W_LIMIT_LINE_NO) LOOP
            --spftl
            SELECT SECRCPT_SECURED_VALUE
              INTO W_SEC_VALUE
              FROM SECRCPT S1
             WHERE S1.SECRCPT_SECURITY_NUM = SEC_NUM.SECAGMTDTL_SEC_NUM
               AND S1.SECRCPT_TAKING_CHRG_DATE <= W_ASON_DATE;
            --spftl
            W_ACC_BAL   := W_ACC_BAL + W_SEC_VALUE;
            W_SEC_VALUE := 0;
          END LOOP;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            W_ACC_BAL   := 0;
            W_SEC_VALUE := 0;
        END SECURED_VALUE;
        --
      END IF;
       */

      <<SECURED_VALUE>>
      BEGIN
        SELECT ACASLLDTL_CLIENT_NUM, ACASLLDTL_LIMIT_LINE_NUM
          INTO W_CLIENT_NUM, W_LIMIT_LINE_NO
          FROM ACASLLDTL A
         WHERE A.ACASLLDTL_INTERNAL_ACNUM = INTERNAL_ACNUM;

        FOR IDX_REC_SECBAL IN (SELECT SECAGMTBAL_ASSIGN_PERC,
                                      SECAGMTBAL_SEC_NUM
                                 FROM SECASSIGNMTBAL
                                WHERE SECAGMTBAL_ENTITY_NUM =
                                      PKG_ENTITY.FN_GET_ENTITY_CODE
                                  AND SECAGMTBAL_CLIENT_NUM = W_CLIENT_NUM
                                  AND SECAGMTBAL_LIMIT_LINE_NUM =
                                      W_LIMIT_LINE_NO) LOOP
          W_ASSIGN_PERC := IDX_REC_SECBAL.SECAGMTBAL_ASSIGN_PERC;
          W_SEC_NUM     := IDX_REC_SECBAL.SECAGMTBAL_SEC_NUM;

          <<FETCH_SECRCPT>>
          BEGIN
            SELECT SECRCPT_SEC_TYPE,
                   SECRCPT_CURR_CODE,
                   SECRCPT_SECURED_VALUE
              INTO W_SEC_TYPE, W_SEC_CURR_CODE, W_SECURED_VALUE
              FROM SECRCPT
             WHERE SECRCPT_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
               AND SECRCPT_SECURITY_NUM = W_SEC_NUM;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              --RAISE E_USEREXCEP;
              EXIT;
          END FETCH_SECRCPT;

          W_SEC_AMT := W_SECURED_VALUE * (W_ASSIGN_PERC / 100);
          --DBMS_OUTPUT.put_line ('W_ASON_DATE  IN MAIN' || W_ASON_DATE ) ;
          GET_SECPROV_PARAM (W_CBD ,W_ASON_DATE  )  ;

          IF (W_SECPROV_VALID_FLG = '1') THEN
            W_SEC_AMT := W_SEC_AMT * (1 - (W_SECPROV_DISC_PER / 100));
          END IF;

          IF (W_SECPROV_VALID_FLG = '0') THEN
            W_SEC_AMT := 0;
          END IF;

          W_TOT_SEC_AMT_AC := W_TOT_SEC_AMT_AC + W_SEC_AMT;
          W_TOT_SEC_AMT_BC := W_TOT_SEC_AMT_BC + W_SEC_AMT;
        END LOOP;
      END SECURED_VALUE;

      W_ACC_BAL := W_TOT_SEC_AMT_BC;

    END IF;

    RETURN W_ACC_BAL;
  END GET_SECURED_VALUE;

  FUNCTION GET_LOAN_SUSPBAL(P_ACNUM NUMBER, P_CURR VARCHAR2) RETURN NUMBER IS
  BEGIN
    W_ERROR    := '';
    LN_SUSPBAL := 0;
    PKG_LNSUSPASON.SP_LNSUSPASON(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                 P_ACNUM,
                                 P_CURR,
                                 TO_CHAR(W_ASON_DATE, 'DD-MM-YYYY'),
                                 W_ERROR,
                                 W_DUMMY_BAL,
                                 W_DUMMY_BAL,
                                 LN_SUSPBAL,
                                 W_DUMMY_BAL,
                                 W_DUMMY_BAL,
                                 W_DUMMY_BAL,
                                 W_DUMMY_BAL,
                                 W_DUMMY_BAL,
                                 W_DUMMY_BAL,
                                 W_DUMMY_BAL,
                                 W_DUMMY_BAL);

    IF W_ERROR IS NOT NULL THEN
      LN_SUSPBAL := 0;
    END IF;

    RETURN LN_SUSPBAL;
  END GET_LOAN_SUSPBAL;

BEGIN
  NULL;
END PKG_CLREPORT;
/
