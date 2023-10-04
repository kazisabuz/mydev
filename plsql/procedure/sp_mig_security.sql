CREATE OR REPLACE PROCEDURE SP_MIG_SECURITY(P_BRANCH_CODE NUMBER,

                                            P_ERR_MSG OUT VARCHAR2) IS
  /*
    Author:S.Rajalakshmi
    Date  :

  List of  Table/s Referred

   1.MIG_SECMORT
   2.MIG_SECINVEST
   3.MIG_SECVPM
   4.MIG_SECSHA
   5.MIG_SECSHACER  -- To be added
   6.MIG_SECSTOCK
   7.MIG_LAD
   8.MIG_LADDTL
   9.MIG_SECINSUR
   10.MIG_SECRCPTNUM --- To be verified

   11.TEMP_SEC - Temporary Table for storing Old and New Security Numbers

  List of Tables Updated
   1.SECRCPT
   2.SECASSIGNMENTS
   3.SECASSIGNMTDTL
   4.SECASSIGNMTBAL
   5.SECASSIGNMTDBAL
   6.SECMORTGAGE
   7.SECMORTEC
   8.SECINVEST
   9.SECVEHICLE
   10.SECCLIENT
   11.SECSHARES
   12.SECSHARESDTL
   13.LADACNTS
   14.LADACNTDTL
   15.SECINSUR
   16.SECSTKBKDB
   17.SECSTKBKDBDTL
   18.SECSTKBKDT
   19.SECSTKBKDTDTL
   20.SECSHADEMAT
   21.SECVAL
   20.MIG_SECRCPTNUM --- To be verified

  Modification History
  -----------------------------------------------------------------------------------------
  Sl.            Description                                    Mod By             Mod on
  -----------------------------------------------------------------------------------------
  1.   Default Values                                      Neelakantan          15-JAN-2010   NEELS-AHBAD-15-JAN-2010

  -----------------------------------------------------------------------------------------
  */

  W_CURR_DATE    DATE;
  W_ENTD_BY      VARCHAR2(8) := 'MIGS';
  W_SQL          VARCHAR2(4000);
  W_NULL         VARCHAR2(1);
  W_LP_NAT       CHAR(1);
  W_ER_CODE      VARCHAR2(5);
  W_ER_DESC      VARCHAR2(1000);
  W_SRC_KEY      VARCHAR2(1000);
  W_CLIENT_NUM   NUMBER(12);
  W_DEP_NUM      NUMBER(14);
  W_INSURE_CODE  CHAR(1);
  W_RCPTCNT      NUMBER(7) := 0;
  W_DATESL       NUMBER(4) := 1;
  W_DAYSL        NUMBER(6) := 1;
  W_SL           NUMBER(6) := 0;
  W_LP_OPBAL     NUMBER(18, 3) := 0;
  W_LP_ADD       NUMBER(18, 3) := 0;
  W_LP_RED       NUMBER(18, 3) := 0;
  W_LP_CLBAL     NUMBER(18, 3) := 0;
  W_LP_MARGIN    NUMBER(5, 2) := 0;
  W_DATE_EC      DATE;
  W_FROM_DATE    DATE;
  W_TO_DATE      DATE;
  W_REG_NAME     VARCHAR2(35);
  W_REG_VALUE    NUMBER(18, 3) := 0;
  W_CURR_VAL     VARCHAR2(3);
  W_LP_ACNUM     VARCHAR2(25);
  W_LP_PER       NUMBER(5, 2) := 0;
  W_LIMIT_NUM    NUMBER(6) := 0;
  W_INTERNAL_NUM NUMBER(14) := 0;
  W_ASSIGN_AMT   NUMBER(18, 3) := 0;
  W_CURR_CODE    VARCHAR2(3) := 'INR';
  --W_CERT_SL         NUMBER(5) := 1;
  W_OWNER           NUMBER(12) := 0;
  W_IN_OWNER_CLIENT NUMBER(12) := 0;
  W_CLIENT_SL       NUMBER(2) := 1;
  W_NATCODE         CHAR(1);
  W_ENTITY_NUM      NUMBER(3) := 1;
  W_LNSL            NUMBER(10);
  --  W_LIM          NUMBER(6);
  W_INTMARGIN LNGSACNTDTL.LNGSACNTDTL_INT_MARGIN%TYPE;

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
  EXCEPTION
    WHEN OTHERS THEN
      P_ERR_MSG := 'ERROR IN MIG_ERRORLOG ' || SQLERRM;
  END POST_ERR_LOG;

  PROCEDURE FETCH_CLIENT(W_OLDCLIENT NUMBER, W_NEWCLIENT OUT NUMBER) IS
  BEGIN
    SELECT TO_NUMBER(NEW_CLCODE)
    INTO W_NEWCLIENT
    FROM TEMP_CLIENT
    WHERE OLD_CLCODE = W_OLDCLIENT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      W_NEWCLIENT := 0;
    WHEN OTHERS THEN
      W_ER_CODE := 'SEC1';
      W_ER_DESC := 'SELECT- CHECK CLEINT CODE -TEMP_CLIENT-SECURITY ' ||
                   SQLERRM;
      W_SRC_KEY := P_BRANCH_CODE || '-' || W_OLDCLIENT;
      POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
  END FETCH_CLIENT;

  PROCEDURE FETCH_ACNUM(W_OLDACCNUM VARCHAR2, W_NEWACNUM OUT NUMBER) IS
  BEGIN
    SELECT ACNTOTN_INTERNAL_ACNUM
    INTO W_NEWACNUM
    FROM ACNTOTN
    WHERE ACNTOTN.ACNTOTN_OLD_ACNT_NUM = TO_CHAR(W_OLDACCNUM);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      W_NEWACNUM := 0;
    WHEN OTHERS THEN
      W_ER_CODE := 'SEC2';
      W_ER_DESC := 'SELECT- CHECK INTERNAL ACC NUM -ACNTS-SECURITY ' ||
                   SQLERRM;
      W_SRC_KEY := P_BRANCH_CODE || '-' || W_OLDACCNUM;
      POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);

  END FETCH_ACNUM;

  PROCEDURE FETCH_LIMITLINE(W_ACCNUM    NUMBER,
                            W_CLIENTNUM NUMBER,
                            W_LIMITNUM  OUT NUMBER) IS
  BEGIN

    SELECT ACASLLDTL_LIMIT_LINE_NUM
    INTO W_LIMITNUM
    FROM ACASLLDTL
    WHERE --ACASLLDTL_CLIENT_NUM = W_CLIENTNUM AND
     ACASLLDTL_ENTITY_NUM = W_ENTITY_NUM
     AND ACASLLDTL_INTERNAL_ACNUM = W_ACCNUM;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      W_LIMITNUM := 0;
    WHEN OTHERS THEN
      W_ER_CODE := 'SEC3';
      W_ER_DESC := 'SELECT- CHECK LIMITLINE-ACASLLDTL-SECURITY ' || SQLERRM;
      W_SRC_KEY := P_BRANCH_CODE || '-' || W_CLIENTNUM;
      POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
  END FETCH_LIMITLINE;

  PROCEDURE IN_SECRCPT(W_RCPTNUM              NUMBER,
                       P_BRANCH_CODE          NUMBER,
                       W_CHRG_DATE            DATE,
                       W_CL_NUM               NUMBER,
                       W_SEC_TYPE             VARCHAR2,
                       W_MODE_OF_SEC          CHAR,
                       W_TYPE_OF_MORTGAGE     CHAR,
                       W_MORTAGER_NAME        VARCHAR2,
                       W_DATE_OF_MORT         DATE,
                       W_PLAC_OF_MORT         VARCHAR2,
                       W_PLEDGE_EXISTS        CHAR,
                       W_PLEDGE_DATE          DATE,
                       W_CONFIRMATION_DATE    DATE,
                       W_CURR_CODE            VARCHAR2,
                       W_DESCN1               VARCHAR2,
                       W_DESCN2               VARCHAR2,
                       W_DESCN3               VARCHAR2,
                       W_DESCN4               VARCHAR2,
                       W_DESCN5               VARCHAR2,
                       W_MARGIN_PER           NUMBER,
                       W_VALUATION_DATE       DATE,
                       W_LIEN_CHGS_DATE       DATE,
                       W_TAX_PAID_UPTO        DATE,
                       W_INSUR_REQD           CHAR,
                       W_INSUR_BY             CHAR,
                       W_VAL_OF_SECURITY      NUMBER,
                       W_SECURED_VALUE        NUMBER,
                       W_NUM_OF_CHGS          NUMBER,
                       W_OUR_PRIORITY_CHGS    NUMBER,
                       W_TYPE_OF_PROPERTY     CHAR,
                       W_ELIGFIN_COLLATERAL   CHAR,
                       W_ELIG_CASH_COLLATERAL CHAR,
                       W_CLAIM_CATG           VARCHAR2,
                       W_CLAIM_SUB_CATG       VARCHAR2,
                       W_REM1                 VARCHAR2,
                       W_REM2                 VARCHAR2,
                       W_REM3                 VARCHAR2,
                       W_REM4                 VARCHAR2,
                       W_REM5                 VARCHAR2,
                       W_RELEASED_ON          DATE,
                       W_DETAILS_ENTD         CHAR,
                       W_ENTD_BY              VARCHAR2,
                       W_ENTD_ON              DATE,
                       W_LAST_MOD_BY          VARCHAR2,
                       W_LAST_MOD_ON          DATE,
                       W_AUTH_BY              VARCHAR2,
                       W_AUTH_ON              DATE,
                       W_REJ_BY               VARCHAR2,
                       W_REJ_ON               DATE,
                       W_UNIQ_ID              VARCHAR2,
                       P_ERROR                OUT VARCHAR2) IS
  BEGIN
    W_SQL := 'INSERT INTO SECRCPT
        (SECRCPT_ENTITY_NUM,
         SECRCPT_SECURITY_NUM,
         SECRCPT_CREATED_BY_BRN,
         SECRCPT_TAKING_CHRG_DATE,
         SECRCPT_CLIENT_NUM,
         SECRCPT_SEC_TYPE,
         SECRCPT_MODE_OF_SEC,
         SECRCPT_TYPE_OF_MORTGAGE,
         SECRCPT_MORTAGER_NAME,
         SECRCPT_DATE_OF_MORTGAGE,
         SECRCPT_PLACE_OF_MORTGAGE,
         SECRCPT_PLEDGE_EXISTS,
         SECRCPT_PLEDGE_DATE,
         SECRCPT_CONFIRMATION_DATE,
         SECRCPT_CURR_CODE,
         SECRCPT_SEC_DESCN1,
         SECRCPT_SEC_DESCN2,
         SECRCPT_SEC_DESCN3,
         SECRCPT_SEC_DESCN4,
         SECRCPT_SEC_DESCN5,
         SECRCPT_MARGIN_PER,
         SECRCPT_VALUATION_DATE,
         SECRCPT_LIEN_CHGS_DATE,
         SECRCPT_TAX_PAID_UPTO,
         SECRCPT_INSURANCE_REQD,
         SECRCPT_INSURANCE_BY,
         SECRCPT_VALUE_OF_SECURITY,
         SECRCPT_SECURED_VALUE,
         SECRCPT_NUM_OF_CHGS,
         SECRCPT_OUR_PRIORITY_CHGS,
         SECRCPT_TYPE_OF_PROPERTY,
         SECRCPT_ELIGFIN_COLLATERAL,
         SECRCPT_ELIG_CASH_COLLATERAL,
         SECRCPT_CLAIM_CATG,
         SECRCPT_CLAIM_SUB_CATG,
         SECRCPT_REM1,
         SECRCPT_REM2,
         SECRCPT_REM3,
         SECRCPT_REM4,
         SECRCPT_REM5,
         SECRCPT_RELEASED_ON,
         SECRCPT_DETAILS_ENTD,
         SECRCPT_ENTD_BY,
         SECRCPT_ENTD_ON,
         SECRCPT_LAST_MOD_BY,
         SECRCPT_LAST_MOD_ON,
         SECRCPT_AUTH_BY,
         SECRCPT_AUTH_ON,
         SECRCPT_REJ_BY,
         SECRCPT_REJ_ON,
         SECRCPT_UNIQ_ID)
      VALUES
        (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,:18,:19,:20,:21,:22,:23,:24,:25,:26,:27,:28,:29,:30,:31,:32,:33,:34,:35,:36,:37,:38,:39,:40,:41,:42,:43,:44,:45,:46,:47,:48,:49,:50,:51)';
    EXECUTE IMMEDIATE W_SQL
      USING W_ENTITY_NUM, W_RCPTNUM, P_BRANCH_CODE, W_CHRG_DATE, W_CL_NUM, W_SEC_TYPE, W_MODE_OF_SEC, W_TYPE_OF_MORTGAGE, W_MORTAGER_NAME, W_DATE_OF_MORT, W_PLAC_OF_MORT, W_PLEDGE_EXISTS, W_PLEDGE_DATE, W_CONFIRMATION_DATE, W_CURR_CODE, W_DESCN1, W_DESCN2, W_DESCN3, W_DESCN4, W_DESCN5, W_MARGIN_PER, W_VALUATION_DATE, W_LIEN_CHGS_DATE, W_TAX_PAID_UPTO, W_INSUR_REQD, W_INSUR_BY, W_VAL_OF_SECURITY, W_SECURED_VALUE, W_NUM_OF_CHGS, W_OUR_PRIORITY_CHGS, W_TYPE_OF_PROPERTY, W_ELIGFIN_COLLATERAL, W_ELIG_CASH_COLLATERAL, W_CLAIM_CATG, W_CLAIM_SUB_CATG, W_REM1, W_REM2, W_REM3, W_REM4, W_REM5, W_RELEASED_ON, W_DETAILS_ENTD, W_ENTD_BY, W_ENTD_ON, W_LAST_MOD_BY, W_LAST_MOD_ON, W_AUTH_BY, W_AUTH_ON, W_REJ_BY, W_REJ_ON, W_UNIQ_ID;
  EXCEPTION
    WHEN OTHERS THEN
      W_ER_CODE := 'SEC4';
      W_ER_DESC := 'INSERT-SECRCPT-SECURITY ' || SQLERRM;
      W_SRC_KEY := P_BRANCH_CODE || '-' || P_ERROR;
      POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
  END IN_SECRCPT;

  PROCEDURE IN_SECASSIGNMENTS(W_RCPTNUM   NUMBER,
                              W_ASS_DATE  DATE,
                              W_DSL       NUMBER,
                              W_ASS_AMT   NUMBER,
                              W_F_VAL     NUMBER,
                              W_REM1      VARCHAR2,
                              W_REM2      VARCHAR2,
                              W_REM3      VARCHAR2,
                              W_ENTD      VARCHAR2,
                              W_CUR_DATE  DATE,
                              W_NUL1      VARCHAR2,
                              W_NUL2      VARCHAR2,
                              W_ENTD1     VARCHAR2,
                              W_CUR_DATE1 DATE,
                              W_NUL3      VARCHAR2,
                              W_NUL4      VARCHAR2,
                              P_ERROR     VARCHAR2) IS
  BEGIN
    W_SQL := 'INSERT INTO SECASSIGNMENTS
          (SECAGMT_ENTITY_NUM,SECAGMT_SEC_NUM,
           SECAGMT_DATE,
           SECAGMT_DAY_SL,
           SECAGMT_ASSIGN_AMT,
           SECAGMT_FREE_VALUE,
           SECAGMT_REMARKS1,
           SECAGMT_REMARKS2,
           SECAGMT_REMARKS3,
           SECAGMT_ENTD_BY,
           SECAGMT_ENTD_ON,
           SECAGMT_LAST_MOD_BY,
           SECAGMT_LAST_MOD_ON,
           SECAGMT_AUTH_BY,
           SECAGMT_AUTH_ON,
           SECAGMT_REJ_BY,
           SECAGMT_REJ_ON)
        VALUES
          (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17)';
    EXECUTE IMMEDIATE W_SQL
      USING W_ENTITY_NUM, W_RCPTNUM, W_ASS_DATE, W_DSL, W_ASS_AMT, W_F_VAL, W_REM1, W_REM2, W_REM3, W_ENTD, W_CUR_DATE, W_NUL1, W_NUL2, W_ENTD1, W_CUR_DATE1, W_NUL3, W_NUL4;
  EXCEPTION
    WHEN OTHERS THEN
      W_ER_CODE := 'SEC6';
      W_ER_DESC := 'INSERT-SECASSIGNMENTS-SECURITY ' || SQLERRM;
      W_SRC_KEY := P_BRANCH_CODE || '-' || P_ERROR;
      POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
  END IN_SECASSIGNMENTS;

  PROCEDURE IN_SECASSIGNMTDTL(W_RCPTNUM  NUMBER,
                              W_ASS_DATE DATE,
                              W_DSL      NUMBER,
                              W_DYSL     NUMBER,
                              W_CL       NUMBER,
                              W_LM_NUM   NUMBER,
                              W_PER      NUMBER,
                              W_AS_AMT   NUMBER,
                              W_NAT      CHAR,
                              P_ERROR    VARCHAR2) IS
  BEGIN

    W_SQL := ' INSERT INTO SECASSIGNMTDTL
          (SECAGMTDTL_ENTITY_NUM,SECAGMTDTL_SEC_NUM,
           SECAGMTDTL_DATE,
           SECAGMTDTL_DAY_SL,
           SECAGMTDTL_DTL_SL,
           SECAGMTDTL_CLIENT_NUM,
           SECAGMTDTL_LIMIT_LINE_NUM,
           SECAGMTDTL_ASSIGN_PERC,
           SECAGMTDTL_ASSIGN_AMT,
           SECAGMTDTL_SEC_NATURE)
        VALUES
          (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10)';
    EXECUTE IMMEDIATE W_SQL
      USING W_ENTITY_NUM, W_RCPTNUM, W_ASS_DATE, W_DSL, W_DYSL, W_CL, W_LM_NUM, NVL(W_PER, 100), W_AS_AMT, W_NAT;
  EXCEPTION
    WHEN OTHERS THEN
      W_ER_CODE := 'SEC5';
      W_ER_DESC := 'INSERT-SECASSIGNMTDTL-SECURITY ' || SQLERRM;
      W_SRC_KEY := P_BRANCH_CODE || '-' || P_ERROR;
      POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
  END IN_SECASSIGNMTDTL;

  PROCEDURE IN_SECASSIGNMTBAL(W_RCPNUM  NUMBER,
                              W_CL_NUM  NUMBER,
                              W_LM_NUM  NUMBER,
                              W_PER     NUMBER,
                              W_ASS_AMT NUMBER,
                              W_NAT     CHAR,
                              P_ERROR   VARCHAR2) IS
  BEGIN

    W_SQL := ' INSERT INTO SECASSIGNMTBAL
          (SECAGMTBAL_ENTITY_NUM,SECAGMTBAL_SEC_NUM,
           SECAGMTBAL_CLIENT_NUM,
           SECAGMTBAL_LIMIT_LINE_NUM,
           SECAGMTBAL_ASSIGN_PERC,
           SECAGMTBAL_ASSIGN_AMT,
           SECAGMTBAL_SEC_NATURE)
        VALUES
          (:1,:2,:3,:4,:5,:6,:7)';
    EXECUTE IMMEDIATE W_SQL
      USING W_ENTITY_NUM, W_RCPNUM, W_CL_NUM, W_LM_NUM, NVL(W_PER, 100), W_ASS_AMT, W_NAT;
  EXCEPTION
    WHEN OTHERS THEN
      W_ER_CODE := 'SEC7';
      W_ER_DESC := 'INSERT-SECASSIGNMTBAL-SECURITY' || SQLERRM;
      W_SRC_KEY := P_BRANCH_CODE || '-' || P_ERROR;
      POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
  END IN_SECASSIGNMTBAL;

  PROCEDURE IN_SECASSIGNMTDBAL(W_CL_NUM    NUMBER,
                               W_LIMIT_NUM NUMBER,
                               W_ASS_DATE  DATE,
                               W_RCPNUM    NUMBER,
                               W_PER       NUMBER,
                               W_NAT       VARCHAR2,
                               P_ERROR     VARCHAR2) IS
  BEGIN
    NULL;

    W_SQL := 'INSERT INTO SECASSIGNMTDBAL
          (SECAGMTDBAL_ENTITY_NUM,SECAGMTDBAL_CLIENT_NUM,
           SECAGMTDBAL_LIMIT_LINE_NUM,
           SECAGMTDBAL_EFF_DATE,
           SECAGMTDBAL_SEC_NUM,
           SECAGMTDBAL_ASSIGN_PERC,
           SECAGMTDBAL_SEC_NATURE)
        VALUES
          (:1,:2,:3,:4,:5,:6,:7)';
    EXECUTE IMMEDIATE W_SQL
      USING W_ENTITY_NUM, W_CL_NUM, W_LIMIT_NUM, W_ASS_DATE, W_RCPNUM, NVL(W_PER, 100), W_NAT;

  EXCEPTION
    WHEN OTHERS THEN
      W_ER_CODE := 'SEC8';
      W_ER_DESC := 'INSERT-SECASSIGNMTDBAL-SECURITY ' || SQLERRM;
      W_SRC_KEY := P_BRANCH_CODE || '-' || P_ERROR;
      POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
  END IN_SECASSIGNMTDBAL;

  PROCEDURE INSERT_SECCLIENT(W_RCPTCNT NUMBER, W_OWNER_CLIENT NUMBER) IS
    W_CLIENT_SL NUMBER(5);
  BEGIN
    W_CLIENT_SL := 1;
    FETCH_CLIENT(W_OWNER_CLIENT, W_IN_OWNER_CLIENT);
    IF W_IN_OWNER_CLIENT > 0
    THEN
      EXECUTE IMMEDIATE 'INSERT INTO SECCLIENT
        (SECCLIENT_ENTITY_NUM,SECCLIENT_SECURITY_NUM,
         SECCLIENT_CLIENT_SL,
         SECCLIENT_CLIENT_NUM)
      VALUES
        (:1,:2,:3,:4)'
        USING W_ENTITY_NUM, W_RCPTCNT, W_CLIENT_SL, W_IN_OWNER_CLIENT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      W_ER_CODE := 'SEC22';
      W_ER_DESC := 'INSERT-SECCLIENT' || SQLERRM;
      W_SRC_KEY := P_BRANCH_CODE || '-' || W_OWNER;
      POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
  END INSERT_SECCLIENT;

BEGIN

  SELECT MN_CURR_BUSINESS_DATE
  INTO W_CURR_DATE
  FROM MAINCONT
  WHERE MN_ENTITY_NUM = W_ENTITY_NUM;
  W_RCPTCNT := 1;

  SELECT MIG_LAST_SECURITY_NUM + 1 INTO W_RCPTCNT FROM MIG_SECRCPTNUM;

  /*
  =============================================================================================
                         SECURITY MORTGAGE MIGRATION -beg
  =============================================================================================

  */

  FOR MORT IN (SELECT SECMORT_BRN_CODE,
                      SECMORT_SEC_SL_NUM,
                      SECMORT_TAKING_CHRG_DATE,
                      SECMORT_CLIENT_NUM,
                      SECMORT_OWNER1,
                      SECMORT_OWNER2,
                      SECMORT_OWNER3,
                      SECMORT_OWNER4,
                      SECMORT_OWNER5,
                      SECMORT_OWNER6,
                      SECMORT_OWNER7,
                      SECMORT_OWNER8,
                      SECMORT_OWNER9,
                      SECMORT_OWNER10,
                      SECMORT_SEC_TYPE,
                      SECMORT_MODE_OF_SEC,
                      SECMORT_TYPE_OF_MORTGAGE,
                      SECMORT_MORTAGER_NAME,
                      SECMORT_DATE_OF_MORTGAGE,
                      SECMORT_PLACE_OF_MORTGAGE,
                      NVL(SECMORT_CURR_CODE, W_CURR_CODE) SECMORT_CURR_CODE,
                      SECMORT_SEC_DESCN1,
                      SECMORT_SEC_DESCN2,
                      SECMORT_SEC_DESCN3,
                      SECMORT_SEC_DESCN4,
                      SECMORT_SEC_DESCN5,
                      SECMORT_MARGIN_PER,
                      SECMORT_VALUATION_DATE,
                      SECMORT_LIEN_CHGS_DATE,
                      SECMORT_TAX_PAID_UPTO,
                      SECMORT_INSURANCE_REQD,
                      SECMORT_INSURANCE_BY,
                      SECMORT_VALUE_OF_SECURITY,
                      SECMORT_SECURED_VALUE,
                      SECMORT_NUM_OF_CHGS,
                      SECMORT_OUR_PRIORITY_CHGS,
                      SECMORT_TYPE_OF_PROPERTY,
                      SECMORT_REM1,
                      SECMORT_REM2,
                      SECMORT_REM3,
                      SECMORT_REM4,
                      SECMORT_REM5,
                      SECMORT_RELEASED_ON,
                      SECMORT_SEC_REL_APPR_BY,
                      SECMORT_CONFIRMATION_DATE,
                      SECMORT_ENTD_BY,
                      SECMORT_ENTD_ON,
                      SECMORT_ASSIGN_ACNUM1,
                      SECMORT_ASSIGN_PER1,
                      SECMORT_ASSIGN_ACNUM2,
                      SECMORT_ASSIGN_PER2,
                      SECMORT_ASSIGN_ACNUM3,
                      SECMORT_ASSIGN_PER3,
                      SECMORT_ASSIGN_ACNUM4,
                      SECMORT_ASSIGN_PER4,
                      SECMORT_ASSIGN_ACNUM5,
                      SECMORT_ASSIGN_PER5,
                      SECMORT_ASSIGN_ACNUM6,
                      SECMORT_ASSIGN_PER6,
                      SECMORT_ASSIGN_ACNUM7,
                      SECMORT_ASSIGN_PER7,
                      SECMORT_ASSIGN_ACNUM8,
                      SECMORT_ASSIGN_PER8,
                      SECMORT_ASSIGN_ACNUM9,
                      SECMORT_ASSIGN_PER9,
                      SECMORT_ASSIGN_ACNUM10,
                      SECMORT_ASSIGN_PER10,
                      SECMORT_ASSIGNMENT_DATE,
                      SECMORT_LOCN_ADDR1,
                      SECMORT_LOCN_ADDR2,
                      SECMORT_LOCN_ADDR3,
                      SECMORT_LOCN_ADDR4,
                      SECMORT_VILLAGE_NAME,
                      SECMORT_STATE_CODE,
                      SECMORT_DISTRICT_CODE,
                      SECMORT_TITLE_DEED1,
                      SECMORT_TITLE_DEED2,
                      SECMORT_TITLE_DEED3,
                      SECMORT_TITLE_DEED4,
                      SECMORT_TITLE_DEED5,
                      SECMORT_REGN_NUM,
                      SECMORT_REGN_DATE,
                      SECMORT_SURVEY_NUM,
                      SECMORT_LEGAL_OBTAINED_DATE,
                      SECMORT_EXTENT_OF_LAND,
                      SECMORT_EXTENT_LAND_VALUE,
                      SECMORT_BUILD_UP_AREA,
                      SECMORT_LAND_VALUATION_RATE,
                      SECMORT_DATE_OF_EC1,
                      SECMORT_PERIOD_FROM_DATE1,
                      SECMORT_PERIOD_UPTO_DATE1,
                      SECMORT_SUB_REG_NAME1,
                      NVL(SECMORT_CURR_CODE1, W_CURR_CODE) SECMORT_CURR_CODE1,
                      SECMORT_REGISTERED_VALUE1,
                      SECMORT_DATE_OF_EC2,
                      SECMORT_PERIOD_FROM_DATE2,
                      SECMORT_PERIOD_UPTO_DATE2,
                      SECMORT_SUB_REG_NAME2,
                      NVL(SECMORT_CURR_CODE2, W_CURR_CODE) SECMORT_CURR_CODE2,
                      SECMORT_REGISTERED_VALUE2,
                      SECMORT_DATE_OF_EC3,
                      SECMORT_PERIOD_FROM_DATE3,
                      SECMORT_PERIOD_UPTO_DATE3,
                      SECMORT_SUB_REG_NAME3,
                      NVL(SECMORT_CURR_CODE3, W_CURR_CODE) SECMORT_CURR_CODE3,
                      SECMORT_REGISTERED_VALUE3,
                      SECMORT_DATE_OF_EC4,
                      SECMORT_PERIOD_FROM_DATE4,
                      SECMORT_PERIOD_UPTO_DATE4,
                      SECMORT_SUB_REG_NAME4,
                      NVL(SECMORT_CURR_CODE4, W_CURR_CODE) SECMORT_CURR_CODE4,
                      SECMORT_REGISTERED_VALUE4,
                      SECMORT_DATE_OF_EC5,
                      SECMORT_PERIOD_FROM_DATE5,
                      SECMORT_PERIOD_UPTO_DATE5,
                      SECMORT_SUB_REG_NAME5,
                      NVL(SECMORT_CURR_CODE5, W_CURR_CODE) SECMORT_CURR_CODE5,
                      SECMORT_REGISTERED_VALUE5,
                      SECMORT_SEC_NAT1,
                      SECMORT_SEC_NAT2,
                      SECMORT_SEC_NAT3,
                      SECMORT_SEC_NAT4,
                      SECMORT_SEC_NAT5,
                      SECMORT_SEC_NAT6,
                      SECMORT_SEC_NAT7,
                      SECMORT_SEC_NAT8,
                      SECMORT_SEC_NAT9,
                      SECMORT_SEC_NAT10
               FROM MIG_SECMORT
               WHERE SECMORT_BRN_CODE = P_BRANCH_CODE
               --and SECMORT_CLIENT_NUM=600072014
               ) LOOP

    FETCH_CLIENT(MORT.SECMORT_CLIENT_NUM, W_CLIENT_NUM);

    IF W_CLIENT_NUM > 0
    THEN

      INSERT INTO TEMP_SEC
      VALUES
        (P_BRANCH_CODE, MORT.SECMORT_SEC_SL_NUM, W_RCPTCNT, 'MORT');

      IN_SECRCPT(W_RCPTCNT, --W_RCPTCNT
                 P_BRANCH_CODE,
                 MORT.SECMORT_TAKING_CHRG_DATE, --W_CHRG_DATE
                 W_CLIENT_NUM, --W_CL_NUM
                 MORT.SECMORT_SEC_TYPE, --W_SEC_TYPE
                 MORT.SECMORT_MODE_OF_SEC, --W_MODE_OF_SEC
                 MORT.SECMORT_TYPE_OF_MORTGAGE, --W_TYPE_OF_MORTGAGE
                 MORT.SECMORT_MORTAGER_NAME, --W_MORTAGER_NAME
                 MORT.SECMORT_DATE_OF_MORTGAGE, --W_DATE_OF_MORT
                 MORT.SECMORT_PLACE_OF_MORTGAGE, --W_PLAC_OF_MORT
                 NULL, --W_PLEDGE_EXISTS
                 NULL, --W_PLEDGE_DATE
                 MORT.SECMORT_CONFIRMATION_DATE, --W_CONFIRMATION_DATE
                 MORT.SECMORT_CURR_CODE, --W_CURR_CODE
                 MORT.SECMORT_SEC_DESCN1, --W_DESCN1
                 MORT.SECMORT_SEC_DESCN2, --W_DESCN2
                 MORT.SECMORT_SEC_DESCN3, --W_DESCN3
                 MORT.SECMORT_SEC_DESCN4, --W_DESCN4
                 MORT.SECMORT_SEC_DESCN5, --W_DESCN5
                 NVL(MORT.SECMORT_MARGIN_PER, 0), --W_MARGIN_PER
                 MORT.SECMORT_VALUATION_DATE, --W_VALUATION_DATE
                 MORT.SECMORT_LIEN_CHGS_DATE, --W_LIEN_CHGS_DATE
                 MORT.SECMORT_TAX_PAID_UPTO, --W_TAX_PAID_UPTO
                 MORT.SECMORT_INSURANCE_REQD, --W_INSUR_REQD
                 MORT.SECMORT_INSURANCE_BY, --W_INSUR_BY
                 MORT.SECMORT_VALUE_OF_SECURITY, --W_VAL_OF_SECURITY
                 MORT.SECMORT_SECURED_VALUE, --W_SECURED_VALUE
                 NVL(MORT.SECMORT_NUM_OF_CHGS, 0), --W_NUM_OF_CHGS
                 MORT.SECMORT_OUR_PRIORITY_CHGS, --W_OUR_PRIORITY_CHGS
                 MORT.SECMORT_TYPE_OF_PROPERTY, --W_TYPE_OF_PROPERTY
                 NULL, --W_ELIGFIN_COLLATERAL
                 NULL, --W_ELIG_CASH_COLLATERAL
                 NULL, --W_CLAIM_CATG
                 NULL, --W_CLAIM_SUB_CATG
                 MORT.SECMORT_REM1, --W_REM1
                 MORT.SECMORT_REM2, --W_REM2
                 MORT.SECMORT_REM3, --W_REM3
                 MORT.SECMORT_REM4, --W_REM4
                 MORT.SECMORT_REM5, --W_REM5
                 MORT.SECMORT_RELEASED_ON, --W_RELEASED_ON
                 NULL, --W_DETAILS_ENTD
                 W_ENTD_BY, --W_ENTD_BY
                 W_CURR_DATE, --W_ENTD_ON
                 NULL, --W_LAST_MOD_BY
                 NULL, --W_LAST_MOD_ON
                 W_ENTD_BY, --W_AUTH_BY
                 W_CURR_DATE, --W_AUTH_ON
                 NULL, --W_REJ_BY
                 NULL, --W_REJ_ON
                 'MIG_SECMORT' || '-' || W_CLIENT_NUM, --W_UNIQ_ID
                 P_ERR_MSG);

      FOR I IN 1 .. 10 LOOP

        W_LP_ACNUM := 0;
        W_LP_PER   := 0;

        IF I = 1
        THEN
          W_LP_ACNUM := MORT.SECMORT_ASSIGN_ACNUM1;
          W_LP_PER   := MORT.SECMORT_ASSIGN_PER1;
          W_OWNER    := MORT.SECMORT_OWNER1;
          W_NATCODE  := MORT.SECMORT_SEC_NAT1;
        ELSIF I = 2
        THEN
          W_LP_ACNUM := MORT.SECMORT_ASSIGN_ACNUM2;
          W_LP_PER   := MORT.SECMORT_ASSIGN_PER2;
          W_OWNER    := MORT.SECMORT_OWNER2;
          W_NATCODE  := MORT.SECMORT_SEC_NAT2;
        ELSIF I = 3
        THEN
          W_LP_ACNUM := MORT.SECMORT_ASSIGN_ACNUM3;
          W_LP_PER   := MORT.SECMORT_ASSIGN_PER3;
          W_OWNER    := MORT.SECMORT_OWNER3;
          W_NATCODE  := MORT.SECMORT_SEC_NAT3;
        ELSIF I = 4
        THEN
          W_LP_ACNUM := MORT.SECMORT_ASSIGN_ACNUM4;
          W_LP_PER   := MORT.SECMORT_ASSIGN_PER4;
          W_OWNER    := MORT.SECMORT_OWNER4;
          W_NATCODE  := MORT.SECMORT_SEC_NAT4;
        ELSIF I = 5
        THEN
          W_LP_ACNUM := MORT.SECMORT_ASSIGN_ACNUM5;
          W_LP_PER   := MORT.SECMORT_ASSIGN_PER5;
          W_OWNER    := MORT.SECMORT_OWNER5;
          W_NATCODE  := MORT.SECMORT_SEC_NAT5;
        ELSIF I = 6
        THEN
          W_LP_ACNUM := MORT.SECMORT_ASSIGN_ACNUM6;
          W_LP_PER   := MORT.SECMORT_ASSIGN_PER6;
          W_OWNER    := MORT.SECMORT_OWNER6;
          W_NATCODE  := MORT.SECMORT_SEC_NAT6;
        ELSIF I = 7
        THEN
          W_LP_ACNUM := MORT.SECMORT_ASSIGN_ACNUM7;
          W_LP_PER   := MORT.SECMORT_ASSIGN_PER7;
          W_OWNER    := MORT.SECMORT_OWNER7;
          W_NATCODE  := MORT.SECMORT_SEC_NAT7;
        ELSIF I = 8
        THEN
          W_LP_ACNUM := MORT.SECMORT_ASSIGN_ACNUM8;
          W_LP_PER   := MORT.SECMORT_ASSIGN_PER8;
          W_OWNER    := MORT.SECMORT_OWNER8;
          W_NATCODE  := MORT.SECMORT_SEC_NAT8;
        ELSIF I = 9
        THEN
          W_LP_ACNUM := MORT.SECMORT_ASSIGN_ACNUM9;
          W_LP_PER   := MORT.SECMORT_ASSIGN_PER9;
          W_OWNER    := MORT.SECMORT_OWNER9;
          W_NATCODE  := MORT.SECMORT_SEC_NAT9;
        ELSIF I = 10
        THEN
          W_LP_ACNUM := MORT.SECMORT_ASSIGN_ACNUM10;
          W_LP_PER   := MORT.SECMORT_ASSIGN_PER10;
          W_OWNER    := MORT.SECMORT_OWNER10;
          W_NATCODE  := MORT.SECMORT_SEC_NAT10;
        END IF;

        INSERT_SECCLIENT(W_RCPTCNT, W_OWNER);

        FETCH_ACNUM(W_LP_ACNUM, W_INTERNAL_NUM);

        FETCH_LIMITLINE(W_INTERNAL_NUM, W_CLIENT_NUM, W_LIMIT_NUM);

        W_ASSIGN_AMT := MORT.SECMORT_SECURED_VALUE * W_LP_PER / 100;

        IF W_INTERNAL_NUM <> 0
        THEN

          IN_SECASSIGNMENTS(W_RCPTCNT,
                            NVL(MORT.SECMORT_ASSIGNMENT_DATE, W_CURR_DATE),
                            W_DAYSL,
                            W_ASSIGN_AMT,
                            0,
                            MORT.SECMORT_REM1,
                            MORT.SECMORT_REM2,
                            MORT.SECMORT_REM3,
                            W_ENTD_BY,
                            W_CURR_DATE,
                            W_NULL,
                            W_NULL,
                            W_ENTD_BY,
                            W_CURR_DATE,
                            W_NULL,
                            W_NULL,
                            'SECMORT' || '-' || MORT.SECMORT_CLIENT_NUM);

          IN_SECASSIGNMTDTL(W_RCPTCNT,
                            NVL(MORT.SECMORT_ASSIGNMENT_DATE, W_CURR_DATE),
                            W_DAYSL,
                            W_DATESL,
                            W_CLIENT_NUM,
                            W_LIMIT_NUM,
                            W_LP_PER,
                            W_ASSIGN_AMT,
                            W_NATCODE, --'P',
                            'SECMORT' || '-' || MORT.SECMORT_CLIENT_NUM);

          IN_SECASSIGNMTBAL(W_RCPTCNT,
                            W_CLIENT_NUM,
                            W_LIMIT_NUM,
                            W_LP_PER,
                            W_ASSIGN_AMT,
                            W_NATCODE, --'P',
                            'SECMORT' || '-' || MORT.SECMORT_CLIENT_NUM);
          /*
          IN_SECASSIGNMTDBAL(W_CLIENT_NUM,
                             W_LIMIT_NUM,
                             NVL(MORT.SECMORT_ASSIGNMENT_DATE, W_CURR_DATE),
                             W_RCPTCNT,
                             W_LP_PER,
                             W_NATCODE, --'P',
                             'SECMORT' || '-' || MORT.SECMORT_CLIENT_NUM);
          */
        END IF;

      END LOOP;

      <<IN_SECMORTGAGE>>
      BEGIN
        W_SQL := 'INSERT INTO SECMORTGAGE
          (SECMG_ENTITY_NUM,SECMG_SECURITY_NUM,
           SECMG_LOCN_ADDR1,
           SECMG_LOCN_ADDR2,
           SECMG_LOCN_ADDR3,
           SECMG_LOCN_ADDR4,
           SECMG_VILLAGE_NAME,
           SECMG_STATE_CODE,
           SECMG_DISTRICT_CODE,
           SECMG_TITLE_DEED1,
           SECMG_TITLE_DEED2,
           SECMG_TITLE_DEED3,
           SECMG_TITLE_DEED4,
           SECMG_TITLE_DEED5,
           SECMG_REGN_NUM,
           SECMG_REGN_DATE,
           SECMG_SURVEY_NUM,
           SECMG_LEGAL_OPINION,
           SECMG_LEGAL_OBTAINED_DATE,
           SECMG_EXTENT_OF_LAND,
           SECMG_EXTENT_LAND_VALUE,
           SECMG_BUILD_UP_AREA,
           SECMG_LAND_VALUATION_RATE,
           SECMG_ENTD_BY,
           SECMG_ENTD_ON,
           SECMG_LAST_MOD_BY,
           SECMG_LAST_MOD_ON)
        VALUES
          (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,:18,:19,:20,:21,:22,:23,:24,:25,:26,:27)';
        EXECUTE IMMEDIATE W_SQL
          USING W_ENTITY_NUM, W_RCPTCNT, MORT.SECMORT_LOCN_ADDR1, MORT.SECMORT_LOCN_ADDR2, MORT.SECMORT_LOCN_ADDR3, MORT.SECMORT_LOCN_ADDR4, MORT.SECMORT_VILLAGE_NAME, MORT.SECMORT_STATE_CODE, MORT.SECMORT_DISTRICT_CODE, MORT.SECMORT_TITLE_DEED1, MORT.SECMORT_TITLE_DEED2, MORT.SECMORT_TITLE_DEED3, MORT.SECMORT_TITLE_DEED4, MORT.SECMORT_TITLE_DEED5, MORT.SECMORT_REGN_NUM, MORT.SECMORT_REGN_DATE, MORT.SECMORT_SURVEY_NUM, W_NULL, MORT.SECMORT_LEGAL_OBTAINED_DATE, MORT.SECMORT_EXTENT_OF_LAND, MORT.SECMORT_EXTENT_LAND_VALUE, MORT.SECMORT_BUILD_UP_AREA, MORT.SECMORT_LAND_VALUATION_RATE, W_ENTD_BY, W_CURR_DATE, W_NULL, W_NULL;
      EXCEPTION
        WHEN OTHERS THEN
          W_ER_CODE := 'SEC9';
          W_ER_DESC := 'INSERT-SECMORTGAGE-SECURITY ' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || MORT.SECMORT_CLIENT_NUM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END IN_SECMORTGAGE;

      W_SL := 1;
      FOR I IN 1 .. 5 LOOP
        IF I = 1
        THEN

          W_DATE_EC   := MORT.SECMORT_DATE_OF_EC1;
          W_FROM_DATE := MORT.SECMORT_PERIOD_FROM_DATE1;
          W_TO_DATE   := MORT.SECMORT_PERIOD_UPTO_DATE1;
          W_REG_NAME  := MORT.SECMORT_SUB_REG_NAME1;
          W_CURR_VAL  := MORT.SECMORT_CURR_CODE1;
          W_REG_VALUE := MORT.SECMORT_REGISTERED_VALUE1;

        ELSIF I = 2
        THEN
          W_DATE_EC   := MORT.SECMORT_DATE_OF_EC2;
          W_FROM_DATE := MORT.SECMORT_PERIOD_FROM_DATE2;
          W_TO_DATE   := MORT.SECMORT_PERIOD_UPTO_DATE2;
          W_REG_NAME  := MORT.SECMORT_SUB_REG_NAME2;
          W_CURR_VAL  := MORT.SECMORT_CURR_CODE2;
          W_REG_VALUE := MORT.SECMORT_REGISTERED_VALUE2;

        ELSIF I = 3
        THEN
          W_DATE_EC   := MORT.SECMORT_DATE_OF_EC3;
          W_FROM_DATE := MORT.SECMORT_PERIOD_FROM_DATE3;
          W_TO_DATE   := MORT.SECMORT_PERIOD_UPTO_DATE3;
          W_REG_NAME  := MORT.SECMORT_SUB_REG_NAME3;
          W_CURR_VAL  := MORT.SECMORT_CURR_CODE3;
          W_REG_VALUE := MORT.SECMORT_REGISTERED_VALUE3;

        ELSIF I = 4
        THEN
          W_DATE_EC   := MORT.SECMORT_DATE_OF_EC4;
          W_FROM_DATE := MORT.SECMORT_PERIOD_FROM_DATE4;
          W_TO_DATE   := MORT.SECMORT_PERIOD_UPTO_DATE4;
          W_REG_NAME  := MORT.SECMORT_SUB_REG_NAME4;
          W_CURR_VAL  := MORT.SECMORT_CURR_CODE4;
          W_REG_VALUE := MORT.SECMORT_REGISTERED_VALUE4;

        ELSIF I = 5
        THEN
          W_DATE_EC   := MORT.SECMORT_DATE_OF_EC5;
          W_FROM_DATE := MORT.SECMORT_PERIOD_FROM_DATE5;
          W_TO_DATE   := MORT.SECMORT_PERIOD_UPTO_DATE5;
          W_REG_NAME  := MORT.SECMORT_SUB_REG_NAME5;
          W_CURR_VAL  := MORT.SECMORT_CURR_CODE5;
          W_REG_VALUE := MORT.SECMORT_REGISTERED_VALUE5;
        END IF;

        IF W_DATE_EC IS NOT NULL
        THEN
          W_SQL := 'INSERT INTO SECMORTEC
            (SECMGEC_ENTITY_NUM,SECMGEC_SECURITY_NUM,
             SECMGEC_SL,
             SECMGEC_DATE_OF_EC,
             SECMGEC_PERIOD_FROM_DATE,
             SECMGEC_PERIOD_UPTO_DATE,
             SECMGEC_SUB_REG_NAME,
             SECMGEC_CURR_CODE,
             SECMGEC_REGISTERED_VALUE)
          VALUES
            (:1,:2,:3,:4,:5,:6,:7,:8,:9)';

          <<IN_SECMORTEC>>
          BEGIN
            EXECUTE IMMEDIATE W_SQL
              USING W_ENTITY_NUM, W_RCPTCNT, W_SL, W_DATE_EC, W_FROM_DATE, W_TO_DATE, W_REG_NAME, W_CURR_VAL, W_REG_VALUE;
            W_SL := W_SL + 1;
          EXCEPTION
            WHEN OTHERS THEN
              W_ER_CODE := 'SEC10';
              W_ER_DESC := 'INSERT-SECMORTEC-SECURITY ' || SQLERRM;
              W_SRC_KEY := P_BRANCH_CODE || '-' || MORT.SECMORT_CLIENT_NUM;
              POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
          END IN_SECMORTEC;
        END IF;
      END LOOP;

      W_RCPTCNT := W_RCPTCNT + 1;
    END IF;

  END LOOP;

  UPDATE MIG_SECRCPTNUM SET MIG_LAST_SECURITY_NUM = W_RCPTCNT;

  /*
  =============================================================================================
                         SECURITY MORTGAGE MIGRATION -end
  =============================================================================================

  =============================================================================================
                         SECURITY INVESTMENTS MIGRATION -beg
  =============================================================================================

  */

  SELECT MIG_LAST_SECURITY_NUM INTO W_RCPTCNT FROM MIG_SECRCPTNUM;

  FOR INV IN (SELECT SECINVEST_BRN_CODE,
                     SECINVEST_SEC_SL_NUM,
                     SECINVEST_TAKING_CHRG_DATE,
                     SECINVEST_CLIENT_NUM,
                     SECINVEST_OWNER1,
                     SECINVEST_OWNER2,
                     SECINVEST_OWNER3,
                     SECINVEST_OWNER4,
                     SECINVEST_OWNER5,
                     SECINVEST_OWNER6,
                     SECINVEST_OWNER7,
                     SECINVEST_OWNER8,
                     SECINVEST_OWNER9,
                     SECINVEST_OWNER10,
                     SECINVEST_SEC_TYPE,
                     SECINVEST_MODE_OF_SEC,
                     SUBSTR(SECINVEST_PLEDGE_EXISTS, 1, 1) SECINVEST_PLEDGE_EXISTS,
                     SECINVEST_PLEDGE_DATE,
                     SECINVEST_CONFIRMATION_DATE,
                     NVL(SECINVEST_CURR_CODE, W_CURR_CODE) SECINVEST_CURR_CODE,
                     SECINVEST_SEC_DESCN1,
                     SECINVEST_SEC_DESCN2,
                     SECINVEST_SEC_DESCN3,
                     SECINVEST_SEC_DESCN4,
                     SECINVEST_SEC_DESCN5,
                     SECINVEST_MARGIN_PER,
                     SECINVEST_VALUATION_DATE,
                     SECINVEST_LIEN_CHGS_DATE,
                     SECINVEST_TAX_PAID_UPTO,
                     SECINVEST_VALUE_OF_SECURITY,
                     SECINVEST_SECURED_VALUE,
                     SECINVEST_NUM_OF_CHGS,
                     SECINVEST_OUR_PRIORITY_CHGS,
                     SECINVEST_REM1,
                     SECINVEST_REM2,
                     SECINVEST_REM3,
                     SECINVEST_REM4,
                     SECINVEST_REM5,
                     SECINVEST_RELEASED_ON,
                     SECINVEST_SEC_REL_APPR_BY,
                     SECINVEST_CONFIRMATION_DATE1,
                     SECINVEST_ENTD_BY,
                     SECINVEST_ENTD_ON,
                     SECINVEST_ASSIGN_ACNUM1,
                     SECINVEST_ASSIGN_PER1,
                     SECINVEST_ASSIGN_ACNUM2,
                     SECINVEST_ASSIGN_PER2,
                     SECINVEST_ASSIGN_ACNUM3,
                     SECINVEST_ASSIGN_PER3,
                     SECINVEST_ASSIGN_ACNUM4,
                     SECINVEST_ASSIGN_PER4,
                     SECINVEST_ASSIGN_ACNUM5,
                     SECINVEST_ASSIGN_PER5,
                     SECINVEST_ASSIGN_ACNUM6,
                     SECINVEST_ASSIGN_PER6,
                     SECINVEST_ASSIGN_ACNUM7,
                     SECINVEST_ASSIGN_PER7,
                     SECINVEST_ASSIGN_ACNUM8,
                     SECINVEST_ASSIGN_PER8,
                     SECINVEST_ASSIGN_ACNUM9,
                     SECINVEST_ASSIGN_PER9,
                     SECINVEST_ASSIGN_ACNUM10,
                     SECINVEST_ASSIGN_PER10,
                     SECINVEST_ASSIGNMENT_DATE,
                     SECINVEST_ISSUER_CODE,
                     SECINVEST_DATE_ISS_INVST,
                     SECINVEST_NUM_UNITS,
                     SECINVEST_FACE_VALUE,
                     SECINVEST_TOT_FACE_VAL,
                     SECINVEST_EXPIRY_DATE,
                     SECINVEST_MATURITY_VALUE,
                     SECINVEST_INT_ACCR_REQD,
                     SECINVEST_INT_RATE,
                     SECINVEST_INT_ACCRUED_VALUE,
                     SECINVEST_INT_ACCR_UPTO_DATE,
                     SECINVEST_AMT_ELIG_FACEVALUE,
                     SECINVEST_AMT_ELIG_ACCRINT
              FROM MIG_SECINVEST
              WHERE SECINVEST_BRN_CODE = P_BRANCH_CODE
              ORDER BY SECINVEST_SEC_SL_NUM) LOOP

    FETCH_CLIENT(INV.SECINVEST_CLIENT_NUM, W_CLIENT_NUM);

    IF W_CLIENT_NUM > 0
    THEN

      INSERT INTO TEMP_SEC
      VALUES
        (P_BRANCH_CODE, INV.SECINVEST_SEC_SL_NUM, W_RCPTCNT, 'INVEST');

      IN_SECRCPT(W_RCPTCNT, --W_RCPTCNT
                 P_BRANCH_CODE,
                 INV.SECINVEST_TAKING_CHRG_DATE, --W_CHRG_DATE
                 W_CLIENT_NUM, --W_CL_NUM
                 INV.SECINVEST_SEC_TYPE, --W_SEC_TYPE
                 INV.SECINVEST_MODE_OF_SEC, --W_MODE_OF_SEC
                 NULL, --W_TYPE_OF_MORTGAGE
                 INV.SECINVEST_REM1, --W_MORTAGER_NAME
                 NULL, --W_DATE_OF_MORT
                 NULL, --W_PLAC_OF_MORT
                 INV.SECINVEST_PLEDGE_EXISTS, --W_PLEDGE_EXISTS
                 INV.SECINVEST_PLEDGE_DATE, --W_PLEDGE_DATE
                 INV.SECINVEST_CONFIRMATION_DATE, --W_CONFIRMATION_DATE
                 INV.SECINVEST_CURR_CODE, --W_CURR_CODE
                 INV.SECINVEST_SEC_DESCN1, --W_DESCN1
                 INV.SECINVEST_SEC_DESCN2, --W_DESCN2
                 INV.SECINVEST_SEC_DESCN3, --W_DESCN3
                 INV.SECINVEST_SEC_DESCN4, --W_DESCN4
                 INV.SECINVEST_SEC_DESCN5, --W_DESCN5
                 NVL(INV.SECINVEST_MARGIN_PER, 0), --W_MARGIN_PER
                 INV.SECINVEST_VALUATION_DATE, --W_VALUATION_DATE
                 INV.SECINVEST_LIEN_CHGS_DATE, --W_LIEN_CHGS_DATE
                 INV.SECINVEST_TAX_PAID_UPTO, --W_TAX_PAID_UPTO
                 0, --W_INSUR_REQD
                 NULL, --W_INSUR_BY
                 INV.SECINVEST_VALUE_OF_SECURITY, --W_VAL_OF_SECURITY
                 INV.SECINVEST_SECURED_VALUE, --W_SECURED_VALUE
                 NVL(INV.SECINVEST_NUM_OF_CHGS, 0), --W_NUM_OF_CHGS
                 NULL, --W_OUR_PRIORITY_CHGS
                 INV.SECINVEST_OUR_PRIORITY_CHGS, --W_TYPE_OF_PROPERTY
                 NULL, --W_ELIGFIN_COLLATERAL
                 NULL, --W_ELIG_CASH_COLLATERAL
                 NULL, --W_CLAIM_CATG
                 NULL, --W_CLAIM_SUB_CATG
                 INV.SECINVEST_REM1, --W_REM1
                 INV.SECINVEST_REM2, --W_REM2
                 INV.SECINVEST_REM3, --W_REM3
                 INV.SECINVEST_REM4, --W_REM4
                 INV.SECINVEST_REM5, --W_REM5
                 INV.SECINVEST_RELEASED_ON, --W_RELEASED_ON
                 NULL, --W_DETAILS_ENTD
                 W_ENTD_BY, --W_ENTD_BY
                 W_CURR_DATE, --W_ENTD_ON
                 NULL, --W_LAST_MOD_BY
                 NULL, --W_LAST_MOD_ON
                 W_ENTD_BY, --W_AUTH_BY
                 W_CURR_DATE, --W_AUTH_ON
                 NULL, --W_REJ_BY
                 NULL, --W_REJ_ON
                 'MIG_SECINVEST' || '-' || W_CLIENT_NUM, --W_UNIQ_ID
                 P_ERR_MSG);

      FOR I IN 1 .. 10 LOOP
        W_LP_ACNUM := 0;
        W_LP_PER   := 0;
        IF I = 1
        THEN
          W_LP_ACNUM := INV.SECINVEST_ASSIGN_ACNUM1;
          W_LP_PER   := INV.SECINVEST_ASSIGN_PER1;
          W_OWNER    := INV.SECINVEST_OWNER1;
        ELSIF I = 2
        THEN
          W_LP_ACNUM := INV.SECINVEST_ASSIGN_ACNUM2;
          W_LP_PER   := INV.SECINVEST_ASSIGN_PER2;
          W_OWNER    := INV.SECINVEST_OWNER2;
        ELSIF I = 3
        THEN
          W_LP_ACNUM := INV.SECINVEST_ASSIGN_ACNUM3;
          W_LP_PER   := INV.SECINVEST_ASSIGN_PER3;
          W_OWNER    := INV.SECINVEST_OWNER3;
        ELSIF I = 4
        THEN
          W_LP_ACNUM := INV.SECINVEST_ASSIGN_ACNUM4;
          W_LP_PER   := INV.SECINVEST_ASSIGN_PER4;
          W_OWNER    := INV.SECINVEST_OWNER4;
        ELSIF I = 5
        THEN
          W_LP_ACNUM := INV.SECINVEST_ASSIGN_ACNUM5;
          W_LP_PER   := INV.SECINVEST_ASSIGN_PER5;
          W_OWNER    := INV.SECINVEST_OWNER5;
        ELSIF I = 6
        THEN
          W_LP_ACNUM := INV.SECINVEST_ASSIGN_ACNUM6;
          W_LP_PER   := INV.SECINVEST_ASSIGN_PER6;
          W_OWNER    := INV.SECINVEST_OWNER6;
        ELSIF I = 7
        THEN
          W_LP_ACNUM := INV.SECINVEST_ASSIGN_ACNUM7;
          W_LP_PER   := INV.SECINVEST_ASSIGN_PER7;
          W_OWNER    := INV.SECINVEST_OWNER7;
        ELSIF I = 8
        THEN
          W_LP_ACNUM := INV.SECINVEST_ASSIGN_ACNUM8;
          W_LP_PER   := INV.SECINVEST_ASSIGN_PER8;
          W_OWNER    := INV.SECINVEST_OWNER8;
        ELSIF I = 9
        THEN
          W_LP_ACNUM := INV.SECINVEST_ASSIGN_ACNUM9;
          W_LP_PER   := INV.SECINVEST_ASSIGN_PER9;
          W_OWNER    := INV.SECINVEST_OWNER9;
        ELSIF I = 10
        THEN
          W_LP_ACNUM := INV.SECINVEST_ASSIGN_ACNUM10;
          W_LP_PER   := INV.SECINVEST_ASSIGN_PER10;
          W_OWNER    := INV.SECINVEST_OWNER10;
        END IF;

        FETCH_ACNUM(W_LP_ACNUM, W_INTERNAL_NUM);
        INSERT_SECCLIENT(W_RCPTCNT, W_OWNER);

        IF W_INTERNAL_NUM > 0
        THEN

          FETCH_LIMITLINE(W_INTERNAL_NUM, W_CLIENT_NUM, W_LIMIT_NUM);

          W_ASSIGN_AMT := W_LP_PER * INV.SECINVEST_SECURED_VALUE / 100;

          IN_SECASSIGNMENTS(W_RCPTCNT,
                            NVL(INV.SECINVEST_ASSIGNMENT_DATE, W_CURR_DATE),
                            W_DAYSL,
                            W_ASSIGN_AMT,
                            W_NULL,
                            INV.SECINVEST_REM1,
                            INV.SECINVEST_REM2,
                            INV.SECINVEST_REM3,
                            W_ENTD_BY,
                            W_CURR_DATE,
                            W_NULL,
                            W_NULL,
                            W_ENTD_BY,
                            W_CURR_DATE,
                            W_NULL,
                            W_NULL,
                            'SECINVEST' || '-' || INV.SECINVEST_CLIENT_NUM);
          IN_SECASSIGNMTDTL(W_RCPTCNT,
                            NVL(INV.SECINVEST_ASSIGNMENT_DATE, W_CURR_DATE),
                            W_DATESL,
                            W_DAYSL,
                            W_CLIENT_NUM,
                            W_LIMIT_NUM,
                            W_LP_PER,
                            W_ASSIGN_AMT,
                            'P',
                            'SECINVEST' || '-' || INV.SECINVEST_CLIENT_NUM);
          IN_SECASSIGNMTBAL(W_RCPTCNT,
                            W_CLIENT_NUM,
                            W_LIMIT_NUM,
                            W_LP_PER,
                            W_ASSIGN_AMT,
                            'P',
                            'SECINVEST' || '-' || INV.SECINVEST_CLIENT_NUM);
          /*
          IN_SECASSIGNMTDBAL(W_CLIENT_NUM,
                             W_LIMIT_NUM,
                             NVL(INV.SECINVEST_ASSIGNMENT_DATE, W_CURR_DATE),
                             W_RCPTCNT,
                             W_LP_PER,
                             'P',
                             'SECINVEST' || '-' || INV.SECINVEST_CLIENT_NUM);
          */

        END IF;

        IF W_INTERNAL_NUM = 1000600006594
        THEN
          NULL;
        END IF;

        IF W_INTERNAL_NUM > 0
        THEN
          <<ERR_HAND>>
          BEGIN
            IF INV.SECINVEST_INT_ACCRUED_VALUE = 0
            THEN
              W_INTMARGIN := 0;
            ELSE
              W_INTMARGIN := (1 - (INV.SECINVEST_AMT_ELIG_ACCRINT /
                             INV.SECINVEST_INT_ACCRUED_VALUE)) * 100;
            END IF;

            SELECT NVL(MAX(LNGSACNTDTL_SL_NUM), 0) + 1
            INTO W_LNSL
            FROM LNGSACNTDTL
            WHERE LNGSACNTDTL_INTERNAL_ACNUM = W_INTERNAL_NUM;

            INSERT INTO LNGSACNTDTL
              (LNGSACNTDTL_ENTITY_NUM,
               LNGSACNTDTL_INTERNAL_ACNUM,
               LNGSACNTDTL_SL_NUM,
               LNGSACNTDTL_SEC_TYPE,
               LNGSACNTDTL_ISSUER_CODE,
               LNGSACNTDTL_INVEST_DATE,
               LNGSACNTDTL_SEC_CURR,
               LNGSACNTDTL_UNIT_FACE_VALUE,
               LNGSACNTDTL_NUM_OF_UNITS,
               LNGSACNTDTL_TOT_FACE_VALUE,
               LNGSACNTDTL_PRINCIPAL_MARGIN,
               LNGSACNTDTL_INT_RATE,
               LNGSACNTDTL_INT_ACCR_AMT,
               LNGSACNTDTL_INT_MARGIN,
               LNGSACNTDTL_MAT_VALUE,
               LNGSACNTDTL_AMT_ELIG_ON_PRIN,
               LNGSACNTDTL_AMT_ELIG_ON_INT,
               LNGSACNTDTL_TOT_ELIG_LIMIT_AMT,
               LNGSACNTDTL_MAT_DATE,
               LNGSACNTDTL_REMARKS1,
               LNGSACNTDTL_REMARKS2,
               LNGSACNTDTL_REMARKS3,
               LNGSACNTDTL_SEC_REGNUM)
            VALUES
              (W_ENTITY_NUM,
               W_INTERNAL_NUM,
               W_LNSL,
               INV.SECINVEST_SEC_TYPE,
               INV.SECINVEST_ISSUER_CODE,
               INV.SECINVEST_DATE_ISS_INVST,
               W_CURR_CODE,
               INV.SECINVEST_FACE_VALUE,
               INV.SECINVEST_NUM_UNITS,
               (INV.SECINVEST_FACE_VALUE * INV.SECINVEST_NUM_UNITS),
               (1 - (INV.SECINVEST_AMT_ELIG_FACEVALUE /
               ((INV.SECINVEST_FACE_VALUE * INV.SECINVEST_NUM_UNITS)))) * 100,
               INV.SECINVEST_INT_RATE,
               INV.SECINVEST_INT_ACCRUED_VALUE,
               W_INTMARGIN,
               INV.SECINVEST_MATURITY_VALUE,
               INV.SECINVEST_AMT_ELIG_FACEVALUE,
               INV.SECINVEST_AMT_ELIG_ACCRINT,
               (INV.SECINVEST_AMT_ELIG_FACEVALUE +
               INV.SECINVEST_AMT_ELIG_ACCRINT),
               INV.SECINVEST_EXPIRY_DATE,
               'MIG',
               NULL,
               NULL,
               W_RCPTCNT);

          EXCEPTION
            WHEN OTHERS THEN
              P_ERR_MSG := SQLERRM;
              DBMS_OUTPUT.PUT_LINE(P_ERR_MSG);
          END ERR_HAND;
        END IF;
      END LOOP;

      W_SQL := 'INSERT INTO SECINVEST
            (SECINVEST_ENTITY_NUM,SECINVEST_SEC_NUM,
             SECINVEST_ISSUER_CODE,
             SECINVEST_DATE_ISS_INVST,
             SECINVEST_NUM_UNITS,
             SECINVEST_FACE_VALUE,
             SECINVEST_TOT_FACE_VAL,
             SECINVEST_EXPIRY_DATE,
             SECINVEST_MATURITY_VALUE,
             SECINVEST_ENTD_BY,
             SECINVEST_ENTD_ON,
             SECINVEST_LAST_MOD_BY,
             SECINVEST_LAST_MOD_ON)
          VALUES
            (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13)';
      <<IN_SECINVEST>>
      BEGIN
        EXECUTE IMMEDIATE W_SQL
          USING W_ENTITY_NUM, W_RCPTCNT, INV.SECINVEST_ISSUER_CODE, INV.SECINVEST_DATE_ISS_INVST, INV.SECINVEST_NUM_UNITS, INV.SECINVEST_FACE_VALUE, INV.SECINVEST_TOT_FACE_VAL, INV.SECINVEST_EXPIRY_DATE, INV.SECINVEST_MATURITY_VALUE, W_ENTD_BY, W_CURR_DATE, W_NULL, W_NULL;
      EXCEPTION
        WHEN OTHERS THEN
          W_ER_CODE := 'SEC16';
          W_ER_DESC := 'INSERT-SECINVEST-SECURITY ' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || INV.SECINVEST_SEC_SL_NUM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END IN_SECINVEST;

      W_RCPTCNT := W_RCPTCNT + 1;
    END IF;

  END LOOP;
  UPDATE MIG_SECRCPTNUM SET MIG_LAST_SECURITY_NUM = W_RCPTCNT;

  /*
  =============================================================================================
                         SECURITY INVESTMENTS MIGRATION -end
  =============================================================================================

  =============================================================================================
                         SECURITY VEHICLE MIGRATION -beg
  =============================================================================================
  */

  SELECT MIG_LAST_SECURITY_NUM INTO W_RCPTCNT FROM MIG_SECRCPTNUM;

  FOR VPM IN (SELECT SECVPM_BRN_CODE,
                     SECVPM_SEC_SL_NUM,
                     SECVPM_TAKING_CHRG_DATE,
                     SECVPM_CLIENT_NUM,
                     SECVPM_OWNER1,
                     SECVPM_OWNER2,
                     SECVPM_OWNER3,
                     SECVPM_OWNER4,
                     SECVPM_OWNER5,
                     SECVPM_OWNER6,
                     SECVPM_OWNER7,
                     SECVPM_OWNER8,
                     SECVPM_OWNER9,
                     SECVPM_OWNER10,
                     SECVPM_SEC_TYPE,
                     SECVPM_MODE_OF_SEC,
                     NVL(SECVPM_CURR_CODE, W_CURR_CODE) SECVPM_CURR_CODE,
                     SECVPM_SEC_DESCN1,
                     SECVPM_SEC_DESCN2,
                     SECVPM_SEC_DESCN3,
                     SECVPM_SEC_DESCN4,
                     SECVPM_SEC_DESCN5,
                     SECVPM_MARGIN_PER,
                     SECVPM_VALUATION_DATE,
                     SECVPM_LIEN_CHGS_DATE,
                     SECVPM_TAX_PAID_UPTO,
                     SECVPM_INSURANCE_REQD,
                     SECVPM_INSURANCE_BY,
                     SECVPM_VALUE_OF_SECURITY,
                     SECVPM_SECURED_VALUE,
                     SECVPM_NUM_OF_CHGS,
                     SECVPM_OUR_PRIORITY_CHGS,
                     SECVPM_TYPE_OF_PROPERTY,
                     SECVPM_REM1,
                     SECVPM_REM2,
                     SECVPM_REM3,
                     SECVPM_REM4,
                     SECVPM_REM5,
                     SECVPM_RELEASED_ON,
                     SECVPM_SEC_REL_APPR_BY,
                     SECVPM_CONFIRMATION_DATE,
                     SECVPM_ENTD_BY,
                     SECVPM_ENTD_ON,
                     SECVPM_ASSIGN_ACNUM1,
                     SECVPM_ASSIGN_PER1,
                     SECVPM_ASSIGN_ACNUM2,
                     SECVPM_ASSIGN_PER2,
                     SECVPM_ASSIGN_ACNUM3,
                     SECVPM_ASSIGN_PER3,
                     SECVPM_ASSIGN_ACNUM4,
                     SECVPM_ASSIGN_PER4,
                     SECVPM_ASSIGN_ACNUM5,
                     SECVPM_ASSIGN_PER5,
                     SECVPM_ASSIGN_ACNUM6,
                     SECVPM_ASSIGN_PER6,
                     SECVPM_ASSIGN_ACNUM7,
                     SECVPM_ASSIGN_PER7,
                     SECVPM_ASSIGN_ACNUM8,
                     SECVPM_ASSIGN_PER8,
                     SECVPM_ASSIGN_ACNUM9,
                     SECVPM_ASSIGN_PER9,
                     SECVPM_ASSIGN_ACNUM10,
                     SECVPM_ASSIGN_PER10,
                     SECVPM_ASSIGNMENT_DATE,
                     SECVPM_EQUIP_VEHICLE_CODE,
                     SECVPM_VEHICLE_NAME,
                     SECVPM_MANUF_CODE,
                     SECVPM_MANUF_NAME,
                     SECVPM_YR_OF_MANUF,
                     SECVPM_REGN_NUM,
                     SECVPM_REGN_EXPIRY_DATE,
                     SECVPM_CHASSIS_NUM,
                     SECVPM_ENGINE_NUM,
                     SECVPM_HP_LIEN_NOTED_DATE,
                     SECVPM_MAKE_HP_CC,
                     SECVPM_INVOICE_NUM,
                     SECVPM_INVOICE_DATE,
                     NVL(SECVPM_INVOICE_PUR_CURR, W_CURR_CODE) SECVPM_INVOICE_PUR_CURR,
                     SECVPM_INVOICE_PUR_AMT,
                     SECVPM_SUPP_DLR_NAME,
                     SECVPM_SUP_DLR_ADDR1,
                     SECVPM_SUP_DLR_ADDR2,
                     SECVPM_SUP_DLR_ADDR3,
                     SECVPM_SUP_DLR_ADDR4,
                     SECVPM_SUP_DLR_ADDR5,
                     SECVPM_CENTRAL_STAX_NUM,
                     SECVPM_STATE_STAX_NUM,
                     SECVPM_DUPLICATE_KEY,
                     SECVPM_DUPLICATE_KEY_NUM,
                     SECVPM_INSUR_COMPANY,
                     SECVPM_NATURE_OF_INSUR
              FROM MIG_SECVPM
              WHERE SECVPM_BRN_CODE = P_BRANCH_CODE
              ORDER BY SECVPM_SEC_SL_NUM) LOOP

    FETCH_CLIENT(VPM.SECVPM_CLIENT_NUM, W_CLIENT_NUM);

    IF VPM.SECVPM_SEC_SL_NUM = 1497
    THEN
      NULL;
    END IF;

    IF W_CLIENT_NUM > 0
    THEN

      INSERT INTO TEMP_SEC
      VALUES
        (P_BRANCH_CODE, VPM.SECVPM_SEC_SL_NUM, W_RCPTCNT, 'VPM');

      IN_SECRCPT(W_RCPTCNT,
                 P_BRANCH_CODE,
                 VPM.SECVPM_TAKING_CHRG_DATE,
                 W_CLIENT_NUM,
                 VPM.SECVPM_SEC_TYPE,
                 VPM.SECVPM_MODE_OF_SEC,
                 W_NULL,
                 W_NULL,
                 W_NULL,
                 W_NULL,
                 W_NULL,
                 W_NULL,
                 VPM.SECVPM_CONFIRMATION_DATE,
                 VPM.SECVPM_CURR_CODE,
                 VPM.SECVPM_SEC_DESCN1,
                 VPM.SECVPM_SEC_DESCN2,
                 VPM.SECVPM_SEC_DESCN3,
                 VPM.SECVPM_SEC_DESCN4,
                 VPM.SECVPM_SEC_DESCN5,
                 VPM.SECVPM_MARGIN_PER,
                 VPM.SECVPM_VALUATION_DATE,
                 VPM.SECVPM_LIEN_CHGS_DATE,
                 VPM.SECVPM_TAX_PAID_UPTO,
                 VPM.SECVPM_INSURANCE_REQD,
                 VPM.SECVPM_INSURANCE_BY,
                 VPM.SECVPM_VALUE_OF_SECURITY,
                 VPM.SECVPM_SECURED_VALUE,
                 VPM.SECVPM_NUM_OF_CHGS,
                 VPM.SECVPM_OUR_PRIORITY_CHGS,
                 VPM.SECVPM_TYPE_OF_PROPERTY,
                 W_NULL,
                 W_NULL,
                 W_NULL,
                 W_NULL,
                 VPM.SECVPM_REM1,
                 VPM.SECVPM_REM2,
                 VPM.SECVPM_REM3,
                 VPM.SECVPM_REM4,
                 VPM.SECVPM_REM5,
                 VPM.SECVPM_RELEASED_ON,
                 W_NULL,
                 W_ENTD_BY,
                 W_CURR_DATE,
                 W_NULL,
                 W_NULL,
                 W_ENTD_BY,
                 W_CURR_DATE,
                 W_NULL,
                 W_NULL,
                 'MIG_SECVPM' || '-' || W_CLIENT_NUM,
                 P_ERR_MSG);
      FOR I IN 1 .. 10 LOOP

        W_LP_ACNUM := 0;
        W_LP_PER   := 0;

        IF I = 1
        THEN
          W_LP_ACNUM := VPM.SECVPM_ASSIGN_ACNUM1;
          W_LP_PER   := VPM.SECVPM_ASSIGN_PER1;
          W_OWNER    := VPM.SECVPM_OWNER1;
        ELSIF I = 2
        THEN
          W_LP_ACNUM := VPM.SECVPM_ASSIGN_ACNUM2;
          W_LP_PER   := VPM.SECVPM_ASSIGN_PER2;
          W_OWNER    := VPM.SECVPM_OWNER2;
        ELSIF I = 3
        THEN
          W_LP_ACNUM := VPM.SECVPM_ASSIGN_ACNUM3;
          W_LP_PER   := VPM.SECVPM_ASSIGN_PER3;
          W_OWNER    := VPM.SECVPM_OWNER3;
        ELSIF I = 4
        THEN
          W_LP_ACNUM := VPM.SECVPM_ASSIGN_ACNUM4;
          W_LP_PER   := VPM.SECVPM_ASSIGN_PER4;
          W_OWNER    := VPM.SECVPM_OWNER4;
        ELSIF I = 5
        THEN
          W_LP_ACNUM := VPM.SECVPM_ASSIGN_ACNUM5;
          W_LP_PER   := VPM.SECVPM_ASSIGN_PER5;
          W_OWNER    := VPM.SECVPM_OWNER5;
        ELSIF I = 6
        THEN
          W_LP_ACNUM := VPM.SECVPM_ASSIGN_ACNUM6;
          W_LP_PER   := VPM.SECVPM_ASSIGN_PER6;
          W_OWNER    := VPM.SECVPM_OWNER6;
        ELSIF I = 7
        THEN
          W_LP_ACNUM := VPM.SECVPM_ASSIGN_ACNUM7;
          W_LP_PER   := VPM.SECVPM_ASSIGN_PER7;
          W_OWNER    := VPM.SECVPM_OWNER7;
        ELSIF I = 8
        THEN
          W_LP_ACNUM := VPM.SECVPM_ASSIGN_ACNUM8;
          W_LP_PER   := VPM.SECVPM_ASSIGN_PER8;
          W_OWNER    := VPM.SECVPM_OWNER8;
        ELSIF I = 9
        THEN
          W_LP_ACNUM := VPM.SECVPM_ASSIGN_ACNUM9;
          W_LP_PER   := VPM.SECVPM_ASSIGN_PER9;
          W_OWNER    := VPM.SECVPM_OWNER9;
        ELSIF I = 10
        THEN
          W_LP_ACNUM := VPM.SECVPM_ASSIGN_ACNUM10;
          W_LP_PER   := VPM.SECVPM_ASSIGN_PER10;
          W_OWNER    := VPM.SECVPM_OWNER10;
        END IF;

        FETCH_ACNUM(W_LP_ACNUM, W_INTERNAL_NUM);
        INSERT_SECCLIENT(W_RCPTCNT, W_OWNER);

        IF W_INTERNAL_NUM > 0
        THEN
          FETCH_LIMITLINE(W_INTERNAL_NUM, W_CLIENT_NUM, W_LIMIT_NUM);

          W_ASSIGN_AMT := VPM.SECVPM_SECURED_VALUE * W_LP_PER / 100;

          IN_SECASSIGNMENTS(W_RCPTCNT,
                            NVL(VPM.SECVPM_ASSIGNMENT_DATE, W_CURR_DATE),
                            W_DAYSL,
                            W_ASSIGN_AMT,
                            0,
                            VPM.SECVPM_REM1,
                            VPM.SECVPM_REM2,
                            VPM.SECVPM_REM3,
                            W_ENTD_BY,
                            W_CURR_DATE,
                            W_NULL,
                            W_NULL,
                            W_ENTD_BY,
                            W_CURR_DATE,
                            W_NULL,
                            W_NULL,
                            'SECVPM' || '-' || VPM.SECVPM_CLIENT_NUM);
          IN_SECASSIGNMTDTL(W_RCPTCNT,
                            NVL(VPM.SECVPM_ASSIGNMENT_DATE, W_CURR_DATE),
                            W_DATESL,
                            W_DAYSL,
                            W_CLIENT_NUM,
                            W_LIMIT_NUM,
                            W_LP_PER,
                            W_ASSIGN_AMT,
                            'P',
                            'SECVPM' || '-' || VPM.SECVPM_CLIENT_NUM);
          IN_SECASSIGNMTBAL(W_RCPTCNT,
                            W_CLIENT_NUM,
                            W_LIMIT_NUM,
                            W_LP_PER,
                            W_ASSIGN_AMT,
                            'P',
                            'SECVPM' || '-' || VPM.SECVPM_CLIENT_NUM);
          /*
          IN_SECASSIGNMTDBAL(W_CLIENT_NUM,
                             W_LIMIT_NUM,
                             NVL(VPM.SECVPM_ASSIGNMENT_DATE, W_CURR_DATE),
                             W_RCPTCNT,
                             W_LP_PER,
                             'P',
                             'SECVPM' || '-' || VPM.SECVPM_CLIENT_NUM);
          */
        END IF;

      END LOOP;

    --MODIFIED BY RASHMI K FOR THIRD PARTY DEALER CODE
      /*W_SQL := 'INSERT INTO SECVEHICLE
          (
          SECVEH_ENTITY_NUM,
          SECVEH_SECURITY_NUM,
          SECVEH_EQUIP_VEHICLE_CODE,
          SECVEH_VEHICLE_NAME,
          SECVEH_MANUF_CODE,
          SECVEH_MANUF_NAME,
          SECVEH_YR_OF_MANUF,
          SECVEH_REGN_NUM,
          SECVEH_REGN_EXPIRY_DATE,
          SECVEH_CHASSIS_NUM,
          SECVEH_ENGINE_NUM,
          SECVEH_HP_LIEN_NOTED_DATE,
          SECVEH_MAKE_HP_CC,
          SECVEH_INVOICE_NUM,
          SECVEH_INVOICE_DATE,
          SECVEH_INVOICE_PUR_CURR,
          SECVEH_INVOICE_PUR_AMT,
          SECVEH_DLR_THPARTY_CODE,
          SECVEH_SUPP_DLR_NAME,
          SECVEH_SUP_DLR_ADDR1,
          SECVEH_SUP_DLR_ADDR2,
          SECVEH_SUP_DLR_ADDR3,
          SECVEH_SUP_DLR_ADDR4,
          SECVEH_SUP_DLR_ADDR5,
          SECVEH_CENTRAL_STAX_NUM,
          SECVEH_STATE_STAX_NUM,
          SECVEH_DUPLICATE_KEY,
          SECVEH_DUPLICATE_KEY_NUM,
          SECVEH_INSUR_COMPANY,
          SECVEH_NATURE_OF_INSUR,
          SECVEH_ENTD_BY,
          SECVEH_ENTD_ON,
          SECVEH_LAST_MOD_BY,
          SECVEH_LAST_MOD_ON
          )*/
W_SQL := 'INSERT INTO SECVEHICLE
          (
          SECVEH_ENTITY_NUM,
          SECVEH_SECURITY_NUM,
          SECVEH_EQUIP_VEHICLE_CODE,
          SECVEH_VEHICLE_NAME,
          SECVEH_MANUF_CODE,
          SECVEH_MANUF_NAME,
          SECVEH_YR_OF_MANUF,
          SECVEH_REGN_NUM,
          SECVEH_REGN_EXPIRY_DATE,
          SECVEH_CHASSIS_NUM,
          SECVEH_ENGINE_NUM,
          SECVEH_HP_LIEN_NOTED_DATE,
          SECVEH_MAKE_HP_CC,
          SECVEH_INVOICE_NUM,
          SECVEH_INVOICE_DATE,
          SECVEH_INVOICE_PUR_CURR,
          SECVEH_INVOICE_PUR_AMT,
          SECVEH_SUPP_DLR_NAME,
          SECVEH_SUP_DLR_ADDR1,
          SECVEH_SUP_DLR_ADDR2,
          SECVEH_SUP_DLR_ADDR3,
          SECVEH_SUP_DLR_ADDR4,
          SECVEH_SUP_DLR_ADDR5,
          SECVEH_CENTRAL_STAX_NUM,
          SECVEH_STATE_STAX_NUM,
          SECVEH_DUPLICATE_KEY,
          SECVEH_DUPLICATE_KEY_NUM,
          SECVEH_INSUR_COMPANY,
          SECVEH_NATURE_OF_INSUR,
          SECVEH_ENTD_BY,
          SECVEH_ENTD_ON,
          SECVEH_LAST_MOD_BY,
          SECVEH_LAST_MOD_ON
          )
          VALUES
          (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,:18,:19,:20,:21,:22,:23,:24,:25,:26,:27,:28,:29,:30,:31,:32,:33)';
      <<IN_SECVEHICLE>>
      BEGIN
        EXECUTE IMMEDIATE W_SQL
          --commented by rashmi k sec dlr is null USING W_ENTITY_NUM, W_RCPTCNT, VPM.SECVPM_EQUIP_VEHICLE_CODE, VPM.SECVPM_VEHICLE_NAME, VPM.SECVPM_MANUF_CODE, VPM.SECVPM_MANUF_NAME, VPM.SECVPM_YR_OF_MANUF, VPM.SECVPM_REGN_NUM, VPM.SECVPM_REGN_EXPIRY_DATE, VPM.SECVPM_CHASSIS_NUM, VPM.SECVPM_ENGINE_NUM, VPM.SECVPM_HP_LIEN_NOTED_DATE, VPM.SECVPM_MAKE_HP_CC, VPM.SECVPM_INVOICE_NUM, VPM.SECVPM_INVOICE_DATE, VPM.SECVPM_INVOICE_PUR_CURR, VPM.SECVPM_INVOICE_PUR_AMT, VPM.SECVPM_SUPP_DLR_NAME, VPM.SECVPM_SUP_DLR_ADDR1, VPM.SECVPM_SUP_DLR_ADDR2, VPM.SECVPM_SUP_DLR_ADDR3, VPM.SECVPM_SUP_DLR_ADDR4, VPM.SECVPM_SUP_DLR_ADDR5, VPM.SECVPM_CENTRAL_STAX_NUM, VPM.SECVPM_STATE_STAX_NUM, VPM.SECVPM_DUPLICATE_KEY, VPM.SECVPM_DUPLICATE_KEY_NUM, W_NULL, VPM.SECVPM_INSUR_COMPANY, VPM.SECVPM_NATURE_OF_INSUR, W_ENTD_BY, W_CURR_DATE, W_NULL, W_NULL;
          USING W_ENTITY_NUM, W_RCPTCNT, VPM.SECVPM_EQUIP_VEHICLE_CODE, VPM.SECVPM_VEHICLE_NAME, VPM.SECVPM_MANUF_CODE, VPM.SECVPM_MANUF_NAME, VPM.SECVPM_YR_OF_MANUF, VPM.SECVPM_REGN_NUM, VPM.SECVPM_REGN_EXPIRY_DATE, VPM.SECVPM_CHASSIS_NUM, VPM.SECVPM_ENGINE_NUM, VPM.SECVPM_HP_LIEN_NOTED_DATE, VPM.SECVPM_MAKE_HP_CC, VPM.SECVPM_INVOICE_NUM, VPM.SECVPM_INVOICE_DATE, VPM.SECVPM_INVOICE_PUR_CURR, VPM.SECVPM_INVOICE_PUR_AMT, VPM.SECVPM_SUPP_DLR_NAME, VPM.SECVPM_SUP_DLR_ADDR1, VPM.SECVPM_SUP_DLR_ADDR2, VPM.SECVPM_SUP_DLR_ADDR3, VPM.SECVPM_SUP_DLR_ADDR4, VPM.SECVPM_SUP_DLR_ADDR5, VPM.SECVPM_CENTRAL_STAX_NUM, VPM.SECVPM_STATE_STAX_NUM, VPM.SECVPM_DUPLICATE_KEY, VPM.SECVPM_DUPLICATE_KEY_NUM, VPM.SECVPM_INSUR_COMPANY, VPM.SECVPM_NATURE_OF_INSUR, W_ENTD_BY, W_CURR_DATE, W_NULL, W_NULL;
      EXCEPTION
        WHEN OTHERS THEN
          W_ER_CODE := 'SEC52';
          W_ER_DESC := 'INSERT-SECVEHICLE-SECURITY ' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || VPM.SECVPM_SEC_SL_NUM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END IN_SECVEHICLE;

      W_RCPTCNT := W_RCPTCNT + 1;
    END IF;
  END LOOP;

  UPDATE MIG_SECRCPTNUM SET MIG_LAST_SECURITY_NUM = W_RCPTCNT;

  /*
  =============================================================================================
                         SECURITY VEHICLE MIGRATION -end

  =============================================================================================
  =============================================================================================
                         SECURITY SHARES MIGRATION -beg
  =============================================================================================

  */

  SELECT MIG_LAST_SECURITY_NUM INTO W_RCPTCNT FROM MIG_SECRCPTNUM;

  FOR SHA IN (SELECT SECSHA_BRN_CODE,
                     SECSHA_SEC_SL_NUM,
                     SECSHA_TAKING_CHRG_DATE,
                     SECSHA_CLIENT_NUM,
                     SECSHA_OWNER1,
                     SECSHA_OWNER2,
                     SECSHA_OWNER3,
                     SECSHA_OWNER4,
                     SECSHA_OWNER5,
                     SECSHA_OWNER6,
                     SECSHA_OWNER7,
                     SECSHA_OWNER8,
                     SECSHA_OWNER9,
                     SECSHA_OWNER10,
                     SECSHA_SEC_TYPE,
                     SECSHA_MODE_OF_SEC,
                     SECSHA_PLEDGE_EXISTS,
                     SECSHA_PLEDGE_DATE,
                     SECSHA_CONFIRMATION_DATE,
                     SECSHA_CURR_CODE,
                     SECSHA_SEC_DESCN1,
                     SECSHA_SEC_DESCN2,
                     SECSHA_SEC_DESCN3,
                     SECSHA_SEC_DESCN4,
                     SECSHA_SEC_DESCN5,
                     SECSHA_MARGIN_PER,
                     SECSHA_VALUATION_DATE,
                     SECSHA_LIEN_CHGS_DATE,
                     SECSHA_TAX_PAID_UPTO,
                     SECSHA_VALUE_OF_SECURITY,
                     SECSHA_SECURED_VALUE,
                     SECSHA_NUM_OF_CHGS,
                     SECSHA_OUR_PRIORITY_CHGS,
                     SECSHA_TYPE_OF_PROPERTY,
                     SECSHA_REM1,
                     SECSHA_REM2,
                     SECSHA_REM3,
                     SECSHA_REM4,
                     SECSHA_REM5,
                     SECSHA_RELEASED_ON,
                     SECSHA_SEC_REL_APPR_BY,
                     SECSHA_CONFIRMATION_DATE1,
                     SECSHA_ENTD_BY,
                     SECSHA_ENTD_ON,
                     SECSHA_ASSIGN_ACNUM1,
                     SECSHA_ASSIGN_PER1,
                     SECSHA_ASSIGN_ACNUM2,
                     SECSHA_ASSIGN_PER2,
                     SECSHA_ASSIGN_ACNUM3,
                     SECSHA_ASSIGN_PER3,
                     SECSHA_ASSIGN_ACNUM4,
                     SECSHA_ASSIGN_PER4,
                     SECSHA_ASSIGN_ACNUM5,
                     SECSHA_ASSIGN_PER5,
                     SECSHA_ASSIGN_ACNUM6,
                     SECSHA_ASSIGN_PER6,
                     SECSHA_ASSIGN_ACNUM7,
                     SECSHA_ASSIGN_PER7,
                     SECSHA_ASSIGN_ACNUM8,
                     SECSHA_ASSIGN_PER8,
                     SECSHA_ASSIGN_ACNUM9,
                     SECSHA_ASSIGN_PER9,
                     SECSHA_ASSIGN_ACNUM10,
                     SECSHA_ASSIGN_PER10,
                     SECSHA_ASSIGNMENT_DATE,
                     SECSHA_FIN_INSTR_CODE,
                     SECSHA_DEMAT_FORM,
                     SECSHA_DEMAT_ACNUM,
                     SECSHA_DP_ID,
                     SECSHA_CLIENT_ID,
                     SECSHA_DP_NAME,
                     SECSHA_NUM_OF_SHARES,
                     SECSHA_FACE_VALUE,
                     SECSHA_TOT_FACE_VALUE,
                     SECSHA_PAIDUP_VALUE,
                     SECSHA_MKT_VALUE,
                     SECSHA_MKT_VALUE_DATE,
                     SECSHA_TOT_MKT_VALUE,
                     SECSHA_TRF_TO_BANK,
                     SECSHA_AUTHORITY_TO_SELL,
                     SECSHA_NUM_OF_TRF_DEEDS,
                     SECSHA_NUM_OF_CERT
              FROM MIG_SECSHA
              WHERE SECSHA_BRN_CODE = P_BRANCH_CODE
              AND SECSHA_FIN_INSTR_CODE IS NOT NULL) LOOP

    FETCH_CLIENT(SHA.SECSHA_CLIENT_NUM, W_CLIENT_NUM);

    IF W_CLIENT_NUM > 0
    THEN
      INSERT INTO TEMP_SEC
      VALUES
        (P_BRANCH_CODE, SHA.SECSHA_SEC_SL_NUM, W_RCPTCNT, 'SHARE');
      IN_SECRCPT(W_RCPTCNT,
                 P_BRANCH_CODE,
                 SHA.SECSHA_TAKING_CHRG_DATE,
                 W_CLIENT_NUM,
                 SHA.SECSHA_SEC_TYPE,
                 SHA.SECSHA_MODE_OF_SEC,
                 W_NULL,
                 W_NULL,
                 W_NULL,
                 W_NULL,
                 SHA.SECSHA_PLEDGE_EXISTS,
                 SHA.SECSHA_PLEDGE_DATE,
                 SHA.SECSHA_CONFIRMATION_DATE,
                 SHA.SECSHA_CURR_CODE,
                 SHA.SECSHA_SEC_DESCN1,
                 SHA.SECSHA_SEC_DESCN2,
                 SHA.SECSHA_SEC_DESCN3,
                 SHA.SECSHA_SEC_DESCN4,
                 SHA.SECSHA_SEC_DESCN5,
                 SHA.SECSHA_MARGIN_PER,
                 SHA.SECSHA_VALUATION_DATE,
                 SHA.SECSHA_LIEN_CHGS_DATE,
                 SHA.SECSHA_TAX_PAID_UPTO,
                 W_NULL,
                 W_NULL,
                 SHA.SECSHA_VALUE_OF_SECURITY,
                 SHA.SECSHA_SECURED_VALUE,
                 SHA.SECSHA_NUM_OF_CHGS,
                 SHA.SECSHA_OUR_PRIORITY_CHGS,
                 SHA.SECSHA_TYPE_OF_PROPERTY,
                 W_NULL,
                 W_NULL,
                 W_NULL,
                 W_NULL,
                 SHA.SECSHA_REM1,
                 SHA.SECSHA_REM2,
                 SHA.SECSHA_REM3,
                 SHA.SECSHA_REM4,
                 SHA.SECSHA_REM5,
                 SHA.SECSHA_RELEASED_ON,
                 W_NULL,
                 W_ENTD_BY,
                 W_CURR_DATE,
                 W_NULL,
                 W_NULL,
                 W_ENTD_BY,
                 W_CURR_DATE,
                 W_NULL,
                 W_NULL,
                 'MIG_SECSHARES' || '-' || W_CLIENT_NUM,
                 P_ERR_MSG);
      W_CLIENT_SL := 1;
      FOR I IN 1 .. 10 LOOP

        W_LP_ACNUM := 0;
        W_LP_PER   := 0;

        IF I = 1
        THEN
          W_LP_ACNUM := SHA.SECSHA_ASSIGN_ACNUM1;
          W_LP_PER   := SHA.SECSHA_ASSIGN_PER1;
          W_OWNER    := SHA.SECSHA_OWNER1;
        ELSIF I = 2
        THEN
          W_LP_ACNUM := SHA.SECSHA_ASSIGN_ACNUM2;
          W_LP_PER   := SHA.SECSHA_ASSIGN_PER2;
          W_OWNER    := SHA.SECSHA_OWNER2;
        ELSIF I = 3
        THEN
          W_LP_ACNUM := SHA.SECSHA_ASSIGN_ACNUM3;
          W_LP_PER   := SHA.SECSHA_ASSIGN_PER3;
          W_OWNER    := SHA.SECSHA_OWNER3;
        ELSIF I = 4
        THEN
          W_LP_ACNUM := SHA.SECSHA_ASSIGN_ACNUM4;
          W_LP_PER   := SHA.SECSHA_ASSIGN_PER4;
          W_OWNER    := SHA.SECSHA_OWNER4;
        ELSIF I = 5
        THEN
          W_LP_ACNUM := SHA.SECSHA_ASSIGN_ACNUM5;
          W_LP_PER   := SHA.SECSHA_ASSIGN_PER5;
          W_OWNER    := SHA.SECSHA_OWNER5;
        ELSIF I = 6
        THEN
          W_LP_ACNUM := SHA.SECSHA_ASSIGN_ACNUM6;
          W_LP_PER   := SHA.SECSHA_ASSIGN_PER6;
          W_OWNER    := SHA.SECSHA_OWNER6;
        ELSIF I = 7
        THEN
          W_LP_ACNUM := SHA.SECSHA_ASSIGN_ACNUM7;
          W_LP_PER   := SHA.SECSHA_ASSIGN_PER7;
          W_OWNER    := SHA.SECSHA_OWNER7;
        ELSIF I = 8
        THEN
          W_LP_ACNUM := SHA.SECSHA_ASSIGN_ACNUM8;
          W_LP_PER   := SHA.SECSHA_ASSIGN_PER8;
          W_OWNER    := SHA.SECSHA_OWNER8;
        ELSIF I = 9
        THEN
          W_LP_ACNUM := SHA.SECSHA_ASSIGN_ACNUM9;
          W_LP_PER   := SHA.SECSHA_ASSIGN_PER9;
          W_OWNER    := SHA.SECSHA_OWNER9;
        ELSIF I = 10
        THEN
          W_LP_ACNUM := SHA.SECSHA_ASSIGN_ACNUM10;
          W_LP_PER   := SHA.SECSHA_ASSIGN_PER10;
          W_OWNER    := SHA.SECSHA_OWNER10;
        END IF;

        INSERT_SECCLIENT(W_RCPTCNT, W_OWNER);

        FETCH_ACNUM(W_LP_ACNUM, W_INTERNAL_NUM);

        IF W_INTERNAL_NUM > 0
        THEN
          FETCH_LIMITLINE(W_INTERNAL_NUM, W_CLIENT_NUM, W_LIMIT_NUM);

          W_ASSIGN_AMT := W_LP_PER * SHA.SECSHA_SECURED_VALUE / 100;

          IN_SECASSIGNMENTS(W_RCPTCNT,
                            NVL(SHA.SECSHA_ASSIGNMENT_DATE, W_CURR_DATE),
                            W_DAYSL,
                            W_ASSIGN_AMT,
                            0,
                            SHA.SECSHA_REM1,
                            SHA.SECSHA_REM2,
                            SHA.SECSHA_REM3,
                            W_ENTD_BY,
                            W_CURR_DATE,
                            W_NULL,
                            W_NULL,
                            W_ENTD_BY,
                            W_CURR_DATE,
                            W_NULL,
                            W_NULL,
                            'MIG_SECSHARES' || '-' || SHA.SECSHA_CLIENT_NUM);
          IN_SECASSIGNMTDTL(W_RCPTCNT,
                            NVL(SHA.SECSHA_ASSIGNMENT_DATE, W_CURR_DATE),
                            W_DATESL,
                            W_DAYSL,
                            W_CLIENT_NUM,
                            W_LIMIT_NUM,
                            W_LP_PER,
                            W_ASSIGN_AMT,
                            'P',
                            'MIG_SECSHARES' || '-' || SHA.SECSHA_CLIENT_NUM);
          IN_SECASSIGNMTBAL(W_RCPTCNT,
                            W_CLIENT_NUM,
                            W_LIMIT_NUM,
                            W_LP_PER,
                            W_ASSIGN_AMT,
                            'P',
                            'MIG_SECSHARES' || '-' || SHA.SECSHA_CLIENT_NUM);
          /*
          IN_SECASSIGNMTDBAL(W_CLIENT_NUM,
                             W_LIMIT_NUM,
                             NVL(SHA.SECSHA_ASSIGNMENT_DATE, W_CURR_DATE),
                             W_RCPTCNT,
                             W_LP_PER,
                             'P',
                             'MIG_SECSHARES' || '-' ||
                             SHA.SECSHA_CLIENT_NUM);
          */
        END IF;
      END LOOP;

      IF SHA.SECSHA_DEMAT_FORM = '1' ----'Y' Instead of 1 ,Y is checked commented NEELS-AHBAD-15-JAN-2010
      THEN

        W_SQL := 'INSERT INTO SECSHARES
              (SECSHARES_ENTITY_NUM,SECSHARES_SECURITY_NUM,
               SECSHARES_FIN_INSTR_CODE,
               SECSHARES_DEMAT_FORM,
               SECSHARES_NUM_OF_CERT,
               SECSHARES_FACE_VALUE,
               SECSHARES_TOT_FACE_VALUE,
               SECSHARES_PAIDUP_VALUE,
               SECSHARES_MKT_VALUE,
               SECSHARES_MKT_VALUE_DATE,
               SECSHARES_TOT_MKT_VALUE,
               SECSHARES_TRF_TO_BANK,
               SECSHARES_AUTHORITY_TO_SELL,
               SECSHARES_NUM_OF_TRF_DEEDS,
               SECSHARES_ENTD_BY,
               SECSHARES_ENTD_ON,
               SECSHARES_LAST_MOD_BY,
               SECSHARES_LAST_MOD_ON,
               SECSHARES_NUM_OF_SHARES,
               SECSHARES_INIT_NUM_OF_SHARES)
            VALUES
              (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,:18,:19,:20)';
        <<IN_SECSHARES>>
        BEGIN
          EXECUTE IMMEDIATE W_SQL
            USING W_ENTITY_NUM, W_RCPTCNT, SHA.SECSHA_FIN_INSTR_CODE, SHA.SECSHA_DEMAT_FORM, 1, SHA.SECSHA_FACE_VALUE, SHA.SECSHA_TOT_FACE_VALUE, SHA.SECSHA_PAIDUP_VALUE, SHA.SECSHA_MKT_VALUE, SHA.SECSHA_MKT_VALUE_DATE, SHA.SECSHA_TOT_MKT_VALUE, SHA.SECSHA_TRF_TO_BANK, SHA.SECSHA_AUTHORITY_TO_SELL, SHA.SECSHA_NUM_OF_TRF_DEEDS, W_ENTD_BY, W_CURR_DATE, W_NULL, W_NULL, SHA.SECSHA_NUM_OF_SHARES, SHA.SECSHA_NUM_OF_SHARES;

        EXCEPTION
          WHEN OTHERS THEN
            W_ER_CODE := 'SEC27';
            W_ER_DESC := 'INSERT-SECSHARES-SECURITY ' || SQLERRM;
            W_SRC_KEY := P_BRANCH_CODE || '-' || SHA.SECSHA_CLIENT_NUM;
            POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
        END IN_SECSHARES;

        /* W_SQL := 'INSERT INTO SECSHARESDTL
                (SECSDTL_ENTITY_NUM,SECSDTL_SECURITY_NUM,
                 SECSDTL_CERT_SL,
                 SECSDTL_FOLIO_NUM,
                 SECSDTL_CERT_NUM,
                 SECSDTL_NUM_OF_UNITS,
                 SECSDTL_DISTINCTIVE_FROM,
                 SECSDTL_DISTINCTIVE_UPTO)
              VALUES
                (:1,:2,:3,:4,:5,:6,:7,:8)';
          <<IN_SECSHARESDTL>>
          BEGIN
            EXECUTE IMMEDIATE W_SQL
              USING W_ENTITY_NUM, W_RCPTCNT, W_CERT_SL, W_NULL, W_NULL, W_NULL, W_NULL, W_NULL;
          EXCEPTION
            WHEN OTHERS THEN
              W_ER_CODE := 'SEC28';
              W_ER_DESC := 'INSERT-SECSHARESDTL-SECURITY ' || SQLERRM;
              W_SRC_KEY := P_BRANCH_CODE || '-' || SHA.SECSHA_CLIENT_NUM;
              POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
          END IN_SECSHARESDTL;
        */
      END IF;

      INSERT INTO SECSHADEMAT
        (SECDEMAT_ENTITY_NUM,
         SECDEMAT_SECURITY_NUM,
         SECDEMAT_DEPOSITORY,
         SECDEMAT_DEMAT_ACNUM,
         SECDEMAT_DP_ID,
         SECDEMAT_DP_NAME,
         SECDEMAT_CLIENT_ID,
         SECDEMAT_BENEF_NAME)
      VALUES
        (W_ENTITY_NUM,
         W_RCPTCNT,
         NULL,
         SHA.SECSHA_DEMAT_ACNUM,
         SHA.SECSHA_DP_ID,
         SHA.SECSHA_DP_NAME,
         SHA.SECSHA_CLIENT_ID,
         NULL);

      W_RCPTCNT := W_RCPTCNT + 1;
    END IF;
  END LOOP;
  UPDATE MIG_SECRCPTNUM SET MIG_LAST_SECURITY_NUM = W_RCPTCNT;

  /*

  =============================================================================================
                         SECURITY SHARES MIGRATION -end
  =============================================================================================

  =============================================================================================
                         SECURITY LOANS AGAINS DEPOSIT MIGRATION -beg
  =============================================================================================

  */

  -- MIG_SECSHARES-END

  -- LAD-BEGIN

  FOR LAD IN (SELECT LADACNT_BRN_CODE,
                     LADACNT_ACCOUNT_NUM,
                     DECODE(LADACNT_PURP_CODE, 0, 99) LADACNT_PURP_CODE,
                     NVL(LADACNT_ELIGIBLE_LIMIT_CURR, W_CURR_CODE) LADACNT_ELIGIBLE_LIMIT_CURR,
                     LADACNT_ELIGIBLE_LIMIT_AMT,
                     LADACNT_SANC_BY,
                     NVL(LADACNT_SANC_LIMIT_CURR, W_CURR_CODE) LADACNT_SANC_LIMIT_CURR,
                     LADACNT_SANC_LIMIT,
                     LADACNT_SANC_REF_NUM,
                     LADACNT_LIMIT_EXPIRY_DATE,
                     NVL(LADACNT_DISB_AMT_CURR, W_CURR_CODE) LADACNT_DISB_AMT_CURR,
                     LADACNT_DISB_AMT,
                     NVL(LADACNT_DP_AMT_CURR, W_CURR_CODE) LADACNT_DP_AMT_CURR,
                     LADACNT_DP_AMT,
                     LADACNT_DP_REVIEW_DATE,
                     LADACNT_DEP_INT_RATE,
                     LADACNT_WT_AVG_INT_RATE,
                     LADACNT_INC_INT_RATE,
                     LADACNT_EFF_INT_RATE,
                     LADACNT_REM1,
                     LADACNT_REM2,
                     NVL(LADACNT_REM3, 'MIGRATION') LADACNT_REM3,
                     LADACNT_ENTD_BY,
                     LADACNT_ENTD_ON,
                     LADACNT_LAST_MOD_BY,
                     LADACNT_LAST_MOD_ON,
                     LADACNT_AUTH_BY,
                     LADACNT_AUTH_ON
              FROM MIG_LAD
              WHERE LADACNT_BRN_CODE = P_BRANCH_CODE) LOOP

    FETCH_ACNUM(LAD.LADACNT_ACCOUNT_NUM, W_INTERNAL_NUM);
    --DBMS_OUTPUT.PUT_LINE(W_INTERNAL_NUM);
    IF W_INTERNAL_NUM > 0
    THEN
      W_SQL := 'INSERT INTO LADACNTS
                        (
              LADACNT_ENTITY_NUM,
              LADACNT_INTERNAL_ACNUM,
              LADACNT_PURP_CODE,
              LADACNT_ELIGIBLE_LIMIT_CURR,
              LADACNT_ELIGIBLE_LIMIT_AMT,
              LADACNT_SANC_BY,
              LADACNT_SANC_LIMIT_CURR,
              LADACNT_SANC_LIMIT,
              LADACNT_SANC_REF_NUM,
              LADACNT_LIMIT_EXPIRY_DATE,
              LADACNT_DISB_AMT_CURR,
              LADACNT_DISB_AMT,
              LADACNT_DP_AMT_CURR,
              LADACNT_DP_AMT,
              LADACNT_DP_REVIEW_DATE,
              LADACNT_DEP_INT_RATE,
              LADACNT_WT_AVG_INT_RATE,
              LADACNT_INC_INT_RATE,
              LADACNT_EFF_INT_RATE,
              LADACNT_REM1,
              LADACNT_REM2,
              LADACNT_REM3,
              LADACNT_TRANSTL_INV_NUM,
              POST_TRAN_BRN,
              POST_TRAN_DATE,
              POST_TRAN_BATCH_NUM,
              LADACNT_ENTD_BY,
              LADACNT_ENTD_ON,
              LADACNT_LAST_MOD_BY,
              LADACNT_LAST_MOD_ON,
              LADACNT_AUTH_BY,
              LADACNT_AUTH_ON,
              LADACNT_REJ_BY,
              LADACNT_REJ_ON,
              TBA_MAIN_KEY)
            VALUES
              (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,:18,:19,:20,:21,:22,:23,:24,:25,:26,:27,:28,:29,:30,:31,:32,:33,:34,:35)';
      <<IN_LADACNTS>>
      BEGIN
        EXECUTE IMMEDIATE W_SQL
          USING
        --W_INTERNAL_NUM, LAD.LADACNT_PURP_CODE, LAD.LADACNT_ELIGIBLE_LIMIT_CURR, LAD.LADACNT_ELIGIBLE_LIMIT_AMT, LAD.LADACNT_SANC_BY, LAD.LADACNT_SANC_LIMIT_CURR, LAD.LADACNT_SANC_LIMIT, LAD.LADACNT_SANC_REF_NUM, LAD.LADACNT_LIMIT_EXPIRY_DATE, LAD.LADACNT_DISB_AMT_CURR, LAD.LADACNT_DISB_AMT, LAD.LADACNT_DEP_INT_RATE, LAD.LADACNT_INC_INT_RATE, LAD.LADACNT_EFF_INT_RATE, LAD.LADACNT_REM1, LAD.LADACNT_REM2, LAD.LADACNT_REM3, W_NULL, W_NULL, W_NULL, W_NULL, W_ENTD_BY, W_CURR_DATE, LAD.LADACNT_LAST_MOD_BY, LAD.LADACNT_LAST_MOD_ON, W_ENTD_BY, W_CURR_DATE, W_NULL, W_NULL;
        W_ENTITY_NUM, W_INTERNAL_NUM, LAD.LADACNT_PURP_CODE, LAD.LADACNT_ELIGIBLE_LIMIT_CURR, LAD.LADACNT_ELIGIBLE_LIMIT_AMT, LAD.LADACNT_SANC_BY, LAD.LADACNT_SANC_LIMIT_CURR, LAD.LADACNT_SANC_LIMIT, LAD.LADACNT_SANC_REF_NUM, LAD.LADACNT_LIMIT_EXPIRY_DATE, LAD.LADACNT_DISB_AMT_CURR, LAD.LADACNT_DISB_AMT, LAD.LADACNT_DP_AMT_CURR, LAD.LADACNT_DP_AMT, LAD.LADACNT_DP_REVIEW_DATE, LAD.LADACNT_DEP_INT_RATE, LAD.LADACNT_WT_AVG_INT_RATE, LAD.LADACNT_INC_INT_RATE, LAD.LADACNT_EFF_INT_RATE, LAD.LADACNT_REM1, LAD.LADACNT_REM2, LAD.LADACNT_REM3, W_NULL, W_NULL, W_NULL, W_NULL, W_ENTD_BY, W_CURR_DATE, W_NULL, W_NULL, W_ENTD_BY, W_CURR_DATE, W_NULL, W_NULL, W_NULL;

      EXCEPTION
        WHEN OTHERS THEN
          W_ER_CODE := 'SEC29';
          W_ER_DESC := 'INSERT-LADACNTS-SECURITY ' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || LAD.LADACNT_ACCOUNT_NUM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END IN_LADACNTS;
    END IF;
  END LOOP;

  FOR LADT IN (SELECT LADDTL_BRN_CODE,
                      LADDTL_ACCOUNT_NUM,
                      LADDDTL_SL_NUM,
                      LADACNT_DEP_BRN_CODE,
                      LADACNT_DEP_ACCOUNT_NUM,
                      LADACNT_DEP_CONTRACT_NUM,
                      NVL(LADACNT_DEP_BAL_CURR, W_CURR_CODE) LADACNT_DEP_BAL_CURR,
                      LADACNT_DEP_BAL,
                      LADACNT_PRIN_BAL,
                      LADACNT_INT_BAL,
                      LADACNT_PRIN_MARGIN,
                      LADACNT_INT_MARGIN,
                      LADACNT_LOAN_AMT_AVAIL,
                      LADACNT_LIEN_AMT
               FROM MIG_LADDTL
               WHERE LADDTL_BRN_CODE = P_BRANCH_CODE) LOOP

    FETCH_ACNUM(LADT.LADDTL_ACCOUNT_NUM, W_INTERNAL_NUM);
    FETCH_ACNUM(LADT.LADACNT_DEP_ACCOUNT_NUM, W_DEP_NUM);

    IF W_INTERNAL_NUM > 0
    THEN
      W_SQL := 'INSERT INTO LADACNTDTL
              (
          LADDTL_ENTITY_NUM,
          LADDTL_INTERNAL_ACNUM,
          LADDTL_SL_NUM,
          LADDTL_DEP_BRN_CODE,
          LADDTL_DEP_ACNT_NUM,
          LADDTL_DEP_CONTRACT_NUM,
          LADDTL_DEP_BALANCE,
          LADDTL_DEP_PRIN_BAL,
          LADDTL_DEP_INT_ACCR_OS,
          LADDTL_LIEN_ADJ_PRIN_BAL,
          LADDTL_MARGIN,
          LADDTL_INT_MARGIN,
          LADDTL_LOAN_AMT_AVAILABLE,
          LADDTL_LIEN_AMOUNT,
          LADDTL_ENTRY_TYPE,
          LADDTL_ENTRY_DATE
          )
            VALUES
              (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16)';
      <<IN_LADACNTDTL>>
      BEGIN
        EXECUTE IMMEDIATE W_SQL
          USING W_ENTITY_NUM, W_INTERNAL_NUM, LADT.LADDDTL_SL_NUM, P_BRANCH_CODE, W_DEP_NUM, LADT.LADACNT_DEP_CONTRACT_NUM, LADT.LADACNT_DEP_BAL, LADT.LADACNT_PRIN_BAL, W_NULL, W_NULL, LADT.LADACNT_PRIN_MARGIN, LADT.LADACNT_INT_MARGIN, LADT.LADACNT_LOAN_AMT_AVAIL, LADT.LADACNT_LIEN_AMT, W_NULL, W_CURR_DATE;

      EXCEPTION
        WHEN OTHERS THEN
          W_ER_CODE := 'SEC30';
          W_ER_DESC := 'INSERT-LADACNTSDTL-SECURITY ' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || LADT.LADDTL_ACCOUNT_NUM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END IN_LADACNTDTL;
    END IF;
  END LOOP;

  --Inserting into LADDEPLINK
  INSERT INTO LADDEPLINK
    (LADDEPLNK_ENTITY_NUM,
     LADDEPLNK_INTERNAL_ACNUM,
     LADDEPLNK_SL_NUM,
     LADDEPLNK_DEP_BRN_CODE,
     LADDEPLNK_DEP_ACNT_NUM,
     LADDEPLNK_DEP_CONTRACT_NUM,
     LADDEPLNK_DEP_BALANCE,
     LADDEPLNK_DEP_PRIN_BAL,
     LADDEPLNK_DEP_INT_ACCR_OS,
     LADDEPLNK_LIEN_ADJ_PRIN_BAL,
     LADDEPLNK_MARGIN,
     LADDEPLNK_INT_MARGIN,
     LADDEPLNK_LOAN_AMT_AVAILABLE,
     LADDEPLNK_LIEN_AMOUNT)
    SELECT LADDTL_ENTITY_NUM,
           LADDTL_INTERNAL_ACNUM,
           LADDTL_SL_NUM,
           LADDTL_DEP_BRN_CODE,
           LADDTL_DEP_ACNT_NUM,
           LADDTL_DEP_CONTRACT_NUM,
           LADDTL_DEP_BALANCE,
           LADDTL_DEP_PRIN_BAL,
           LADDTL_DEP_INT_ACCR_OS,
           LADDTL_LIEN_ADJ_PRIN_BAL,
           LADDTL_MARGIN,
           LADDTL_INT_MARGIN,
           LADDTL_LOAN_AMT_AVAILABLE,
           LADDTL_LIEN_AMOUNT
    FROM LADACNTDTL;

  --Inserting into LADDEPLINKHIST
  FOR I IN (SELECT DISTINCT LADACNT_INTERNAL_ACNUM FROM LADACNTS) LOOP
    INSERT INTO LADDEPLINKHIST
      (LADDEPLNKH_ENTITY_NUM,
       LADDEPLNKH_INTERNAL_ACNUM,
       LADDEPLNKH_EFF_DATE,
       LADDEPLNKH_SL_NUM,
       LADDEPLNKH_ELIGIBLE_LIMIT_CURR,
       LADDEPLNKH_ELIGIBLE_LIMIT_AMT,
       LADDEPLNKH_SANC_BY,
       LADDEPLNKH_SANC_LIMIT_CURR,
       LADDEPLNKH_SANC_LIMIT,
       LADDEPLNKH_SANC_REF_NUM,
       LADDEPLNKH_LIMIT_EXPIRY_DATE,
       LADDEPLNKH_DP_AMT_CURR,
       LADDEPLNKH_DP_AMT,
       LADDEPLNKH_DP_REVIEW_DATE,
       LADDEPLNKH_MAX_DEP_INT_RATE,
       LADDEPLNKH_WT_AVG_INT_RATE,
       LADDEPLNKH_INC_INT_RATE,
       LADDEPLNKH_EFF_INT_RATE,
       LADDEPLNKH_ENTRY_TYPE,
       LADDEPLNKH_SOURCE_KEY)
      SELECT LADACNT_ENTITY_NUM,
             LADACNT_INTERNAL_ACNUM,
             ACNTS_OPENING_DATE,
             ROWNUM,
             LADACNT_SANC_LIMIT_CURR,
             LADACNT_SANC_LIMIT,
             LADACNT_SANC_BY,
             LADACNT_SANC_LIMIT_CURR,
             LADACNT_SANC_LIMIT,
             LADACNT_SANC_REF_NUM,
             LADACNT_LIMIT_EXPIRY_DATE,
             LADACNT_DP_AMT_CURR,
             LADACNT_DP_AMT,
             LADACNT_DP_REVIEW_DATE,
             LADACNT_DEP_INT_RATE,
             LADACNT_WT_AVG_INT_RATE,
             LADACNT_INC_INT_RATE,
             LADACNT_EFF_INT_RATE,
             'O',
             LADACNT_INTERNAL_ACNUM
      FROM LADACNTS, ACNTS
      WHERE ACNTS_ENTITY_NUM = LADACNT_ENTITY_NUM
      AND ACNTS_INTERNAL_ACNUM = LADACNT_INTERNAL_ACNUM
      AND ACNTS_INTERNAL_ACNUM = I.LADACNT_INTERNAL_ACNUM
      ORDER BY ACNTS_OPENING_DATE;
  END LOOP;

  --Inserting into LADDEPLINKHISTDTL
  INSERT INTO LADDEPLINKHISTDTL
    (LADLNKHDTL_ENTITY_NUM,
     LADLNKHDTL_INTERNAL_ACNUM,
     LADLNKHDTL_EFF_DATE,
     LADLNKHDTL_SL_NUM,
     LADLNKHDTL_DTL_SL_NUM,
     LADLNKHDTL_DEP_BRN_CODE,
     LADLNKHDTL_DEP_ACNT_NUM,
     LADLNKHDTL_DEP_CONTRACT_NUM,
     LADLNKHDTL_DEP_BALANCE,
     LADLNKHDTL_DEP_PRIN_BAL,
     LADLNKHDTL_DEP_INT_ACCR_OS,
     LADLNKHDTL_LIEN_ADJ_PRIN_BAL,
     LADLNKHDTL_MARGIN,
     LADLNKHDTL_INT_MARGIN,
     LADLNKHDTL_LOAN_AMT_AVAILABLE,
     LADLNKHDTL_LIEN_AMOUNT)
    SELECT LADDTL_ENTITY_NUM,
           LADDTL_INTERNAL_ACNUM,
           (SELECT ACNTS_OPENING_DATE
            FROM ACNTS
            WHERE ACNTS_INTERNAL_ACNUM = LADDTL_INTERNAL_ACNUM),
           LADDTL_SL_NUM,
           1,
           LADDTL_DEP_BRN_CODE,
           LADDTL_DEP_ACNT_NUM,
           LADDTL_DEP_CONTRACT_NUM,
           LADDTL_DEP_BALANCE,
           LADDTL_DEP_PRIN_BAL,
           LADDTL_DEP_INT_ACCR_OS,
           LADDTL_LIEN_ADJ_PRIN_BAL,
           LADDTL_MARGIN,
           LADDTL_INT_MARGIN,
           LADDTL_LOAN_AMT_AVAILABLE,
           LADDTL_LIEN_AMOUNT
    FROM LADACNTDTL;

  /*
  =============================================================================================
                         SECURITY LOANS AGAINS DEPOSIT MIGRATION -end
  =============================================================================================


  =============================================================================================
                         SECURITY STOCK MIGRATION -beg
  =============================================================================================
  */

  SELECT MIG_LAST_SECURITY_NUM INTO W_RCPTCNT FROM MIG_SECRCPTNUM;

  FOR STK IN (SELECT SECSTK_BRN_CODE,
                     SECSTK_SEC_SL_NUM,
                     SECSTK_TAKING_CHRG_DATE,
                     SECSTK_CLIENT_NUM,
                     SECSTK_OWNER1,
                     SECSTK_OWNER2,
                     SECSTK_OWNER3,
                     SECSTK_OWNER4,
                     SECSTK_OWNER5,
                     SECSTK_OWNER6,
                     SECSTK_OWNER7,
                     SECSTK_OWNER8,
                     SECSTK_OWNER9,
                     SECSTK_OWNER10,
                     SECSTK_SEC_TYPE,
                     SECSTK_MODE_OF_SEC,
                     SECSTK_CURR_CODE,
                     SECSTK_SEC_DESCN1,
                     SECSTK_SEC_DESCN2,
                     SECSTK_SEC_DESCN3,
                     SECSTK_SEC_DESCN4,
                     SECSTK_SEC_DESCN5,
                     SECSTK_MARGIN_PER,
                     SECSTK_VALUATION_DATE,
                     SECSTK_LIEN_CHGS_DATE,
                     SECSTK_TAX_PAID_UPTO,
                     SECSTK_INSURANCE_REQD,
                     SECSTK_INSURANCE_BY,
                     SECSTK_VALUE_OF_SECURITY,
                     SECSTK_SECURED_VALUE,
                     SECSTK_NUM_OF_CHGS,
                     SECSTK_OUR_PRIORITY_CHGS,
                     SECSTK_TYPE_OF_PROPERTY,
                     SECSTK_REM1,
                     SECSTK_REM2,
                     SECSTK_REM3,
                     SECSTK_REM4,
                     SECSTK_REM5,
                     SECSTK_RELEASED_ON,
                     SECSTK_SEC_REL_APPR_BY,
                     SECSTK_CONFIRMATION_DATE,
                     SECSTK_ENTD_BY,
                     SECSTK_ENTD_ON,
                     SECSTK_ASSIGN_ACNUM1,
                     SECSTK_ASSIGN_PER1,
                     SECSTK_SEC_NAT1,
                     SECSTK_ASSIGN_ACNUM2,
                     SECSTK_ASSIGN_PER2,
                     SECSTK_SEC_NAT2,
                     SECSTK_ASSIGN_ACNUM3,
                     SECSTK_ASSIGN_PER3,
                     SECSTK_SEC_NAT3,
                     SECSTK_ASSIGN_ACNUM4,
                     SECSTK_ASSIGN_PER4,
                     SECSTK_SEC_NAT4,
                     SECSTK_ASSIGN_ACNUM5,
                     SECSTK_ASSIGN_PER5,
                     SECSTK_SEC_NAT5,
                     SECSTK_ASSIGN_ACNUM6,
                     SECSTK_ASSIGN_PER6,
                     SECSTK_SEC_NAT6,
                     SECSTK_ASSIGN_ACNUM7,
                     SECSTK_ASSIGN_PER7,
                     SECSTK_SEC_NAT7,
                     SECSTK_ASSIGN_ACNUM8,
                     SECSTK_ASSIGN_PER8,
                     SECSTK_SEC_NAT8,
                     SECSTK_ASSIGN_ACNUM9,
                     SECSTK_ASSIGN_PER9,
                     SECSTK_SEC_NAT9,
                     SECSTK_ASSIGN_ACNUM10,
                     SECSTK_ASSIGN_PER10,
                     SECSTK_SEC_NAT10,
                     SECSTK_ASSIGNMENT_DATE,
                     SECSTK_STOCK_STMT_DATE,
                     SECSTK_STMT_CODE,
                     SECSTK_STMT_FREQ,
                     SECSTK_STMT_END_DATE,
                     SECSTK_SUB_BEFORE_DAYS,
                     SECSTK_GODOWN_DTLS_REQD,
                     SECSTK_GODOWN_ADDR1,
                     SECSTK_GODOWN_ADDR2,
                     SECSTK_GODOWN_ADDR3,
                     SECSTK_GODOWN_ADDR4,
                     SECSTK_APPROX_DIST_FROM_BRN,
                     SECSTK_GODOWN_CONDITION,
                     SECSTK_RENT_OWN_PARTY,
                     SECSTK_RENT_NAME,
                     SECSTK_STK_UNDER_BANK,
                     SECSTK_KEY_NUMBER,
                     SECSTK_OPEN_BAL1,
                     SECSTK_ADDITIONS1,
                     SECSTK_REDUCTIONS1,
                     SECSTK_CLOSING_BAL1,
                     SECSTK_MARGIN1,
                     SECSTK_OPEN_BAL2,
                     SECSTK_ADDITIONS2,
                     SECSTK_REDUCTIONS2,
                     SECSTK_CLOSING_BAL2,
                     SECSTK_MARGIN2,
                     SECSTK_OPEN_BAL3,
                     SECSTK_ADDITIONS3,
                     SECSTK_REDUCTIONS3,
                     SECSTK_CLOSING_BAL3,
                     SECSTK_MARGIN3,
                     SECSTK_OPEN_BAL4,
                     SECSTK_ADDITIONS4,
                     SECSTK_REDUCTIONS4,
                     SECSTK_CLOSING_BAL4,
                     SECSTK_MARGIN4,
                     SECSTK_STOCK_STMT_DATE1
              FROM MIG_SECSTOCK
              WHERE SECSTK_BRN_CODE = P_BRANCH_CODE) LOOP

    FETCH_CLIENT(STK.SECSTK_CLIENT_NUM, W_CLIENT_NUM);

    IF W_CLIENT_NUM > 0
    THEN

      --insert_secclient(W_RCPTCNT,W_CLIENT_NUM);
      INSERT INTO TEMP_SEC
      VALUES
        (P_BRANCH_CODE, STK.SECSTK_SEC_SL_NUM, W_RCPTCNT, 'STOCK');
      IN_SECRCPT(W_RCPTCNT,
                 P_BRANCH_CODE,
                 STK.SECSTK_TAKING_CHRG_DATE,
                 W_CLIENT_NUM, --STK.SECSTK_CLIENT_NUM,
                 STK.SECSTK_SEC_TYPE,
                 STK.SECSTK_MODE_OF_SEC,
                 W_NULL,
                 W_NULL,
                 W_NULL,
                 W_NULL,
                 W_NULL,
                 W_NULL,
                 STK.SECSTK_CONFIRMATION_DATE,
                 STK.SECSTK_CURR_CODE,
                 STK.SECSTK_SEC_DESCN1,
                 STK.SECSTK_SEC_DESCN2,
                 STK.SECSTK_SEC_DESCN3,
                 STK.SECSTK_SEC_DESCN4,
                 STK.SECSTK_SEC_DESCN5,
                 0, --STK.SECSTK_MARGIN_PER,
                 STK.SECSTK_VALUATION_DATE,
                 STK.SECSTK_LIEN_CHGS_DATE,
                 STK.SECSTK_TAX_PAID_UPTO,
                 STK.SECSTK_INSURANCE_REQD,
                 STK.SECSTK_INSURANCE_BY,
                 STK.SECSTK_VALUE_OF_SECURITY,
                 STK.SECSTK_SECURED_VALUE,
                 STK.SECSTK_NUM_OF_CHGS,
                 STK.SECSTK_OUR_PRIORITY_CHGS,
                 STK.SECSTK_TYPE_OF_PROPERTY,
                 W_NULL,
                 W_NULL,
                 W_NULL,
                 W_NULL,
                 STK.SECSTK_REM1,
                 STK.SECSTK_REM2,
                 STK.SECSTK_REM3,
                 STK.SECSTK_REM4,
                 STK.SECSTK_REM5,
                 STK.SECSTK_RELEASED_ON,
                 W_NULL,
                 W_ENTD_BY,
                 W_CURR_DATE,
                 W_NULL,
                 W_NULL,
                 W_ENTD_BY,
                 W_CURR_DATE,
                 W_NULL,
                 W_NULL,
                 'MIG_SECSTK' || '-' || W_CLIENT_NUM,
                 P_ERR_MSG);

      FOR I IN 1 .. 10 LOOP

        W_LP_ACNUM := 0;
        W_LP_PER   := 0;
        W_LP_NAT   := NULL;

        IF I = 1
        THEN
          W_LP_ACNUM := STK.SECSTK_ASSIGN_ACNUM1;
          W_LP_PER   := STK.SECSTK_ASSIGN_PER1;
          W_LP_NAT   := STK.SECSTK_SEC_NAT1;
          W_OWNER    := STK.SECSTK_OWNER1;
        ELSIF I = 2
        THEN
          W_LP_ACNUM := STK.SECSTK_ASSIGN_ACNUM2;
          W_LP_PER   := STK.SECSTK_ASSIGN_PER2;
          W_LP_NAT   := STK.SECSTK_SEC_NAT2;
          W_OWNER    := STK.SECSTK_OWNER2;
        ELSIF I = 3
        THEN
          W_LP_ACNUM := STK.SECSTK_ASSIGN_ACNUM3;
          W_LP_PER   := STK.SECSTK_ASSIGN_PER3;
          W_LP_NAT   := STK.SECSTK_SEC_NAT3;
          W_OWNER    := STK.SECSTK_OWNER3;
        ELSIF I = 4
        THEN
          W_LP_ACNUM := STK.SECSTK_ASSIGN_ACNUM4;
          W_LP_PER   := STK.SECSTK_ASSIGN_PER4;
          W_LP_NAT   := STK.SECSTK_SEC_NAT4;
          W_OWNER    := STK.SECSTK_OWNER4;
        ELSIF I = 5
        THEN
          W_LP_ACNUM := STK.SECSTK_ASSIGN_ACNUM5;
          W_LP_PER   := STK.SECSTK_ASSIGN_PER5;
          W_LP_NAT   := STK.SECSTK_SEC_NAT5;
          W_OWNER    := STK.SECSTK_OWNER5;
        ELSIF I = 6
        THEN
          W_LP_ACNUM := STK.SECSTK_ASSIGN_ACNUM6;
          W_LP_PER   := STK.SECSTK_ASSIGN_PER6;
          W_LP_NAT   := STK.SECSTK_SEC_NAT6;
          W_OWNER    := STK.SECSTK_OWNER6;
        ELSIF I = 7
        THEN
          W_LP_ACNUM := STK.SECSTK_ASSIGN_ACNUM7;
          W_LP_PER   := STK.SECSTK_ASSIGN_PER7;
          W_LP_NAT   := STK.SECSTK_SEC_NAT7;
          W_OWNER    := STK.SECSTK_OWNER7;
        ELSIF I = 8
        THEN
          W_LP_ACNUM := STK.SECSTK_ASSIGN_ACNUM8;
          W_LP_PER   := STK.SECSTK_ASSIGN_PER8;
          W_LP_NAT   := STK.SECSTK_SEC_NAT8;
          W_OWNER    := STK.SECSTK_OWNER8;
        ELSIF I = 9
        THEN
          W_LP_ACNUM := STK.SECSTK_ASSIGN_ACNUM9;
          W_LP_PER   := STK.SECSTK_ASSIGN_PER9;
          W_LP_NAT   := STK.SECSTK_SEC_NAT9;
          W_OWNER    := STK.SECSTK_OWNER9;
        ELSIF I = 10
        THEN
          W_LP_ACNUM := STK.SECSTK_ASSIGN_ACNUM10;
          W_LP_PER   := STK.SECSTK_ASSIGN_PER10;
          W_LP_NAT   := STK.SECSTK_SEC_NAT10;
          W_OWNER    := STK.SECSTK_OWNER10;
        END IF;

        FETCH_ACNUM(W_LP_ACNUM, W_INTERNAL_NUM);
        INSERT_SECCLIENT(W_RCPTCNT, W_OWNER);

        IF W_INTERNAL_NUM > 0
        THEN

          FETCH_LIMITLINE(W_INTERNAL_NUM, W_CLIENT_NUM, W_LIMIT_NUM);

          W_ASSIGN_AMT := STK.SECSTK_SECURED_VALUE * W_LP_PER / 100;

          IN_SECASSIGNMENTS(W_RCPTCNT,
                            NVL(STK.SECSTK_ASSIGNMENT_DATE, W_CURR_DATE),
                            W_DAYSL,
                            W_ASSIGN_AMT,
                            0,
                            STK.SECSTK_REM1,
                            STK.SECSTK_REM1,
                            STK.SECSTK_REM1,
                            W_ENTD_BY,
                            W_CURR_DATE,
                            W_NULL,
                            W_NULL,
                            W_ENTD_BY,
                            W_CURR_DATE,
                            W_NULL,
                            W_NULL,
                            'MIG_SECSTOCK' || '-' || STK.SECSTK_CLIENT_NUM);
          IN_SECASSIGNMTDTL(W_RCPTCNT,
                            NVL(STK.SECSTK_ASSIGNMENT_DATE, W_CURR_DATE),
                            W_DATESL,
                            W_DAYSL,
                            W_CLIENT_NUM,
                            W_LIMIT_NUM,
                            W_LP_PER,
                            W_ASSIGN_AMT,
                            W_LP_NAT,
                            'MIG_SECSTOCK' || '-' || STK.SECSTK_CLIENT_NUM);
          IN_SECASSIGNMTBAL(W_RCPTCNT,
                            W_CLIENT_NUM,
                            W_LIMIT_NUM,
                            W_LP_PER,
                            W_ASSIGN_AMT,
                            W_LP_NAT,
                            'MIG_SECSTOCK' || '-' || STK.SECSTK_CLIENT_NUM);
          /*
           IN_SECASSIGNMTDBAL(W_CLIENT_NUM,
                              W_LIMIT_NUM,
                              NVL(STK.SECSTK_ASSIGNMENT_DATE, W_CURR_DATE),
                              W_RCPTCNT,
                              W_LP_PER,
                              W_LP_NAT,
                              'MIG_SECSTOCK' || '-' || STK.SECSTK_CLIENT_NUM);
          */
        END IF;
      END LOOP;

      <<IN_SECSTKBKDB>>
      BEGIN
        W_SQL := ' INSERT INTO SECSTKBKDB
      (
      SECSTKBK_ENTITY_NUM,
      SECSTKBK_SECURITY_NUM,
      SECSTKBK_ENTRY_DATE,
      SECSTKBK_DAY_SL, 
      SECSTKBK_STMT_CODE,
      SECSTKBK_STMT_FREQ,
      SECSTKBK_STMT_END_DATE,                                    
      SECSTKBK_SUB_BEFORE_DAYS,
      SECSTKBK_GODOWN_DTLS_REQD,
      SECSTKBK_GODOWN_ADDR1,
      SECSTKBK_GODOWN_ADDR2,
      SECSTKBK_GODOWN_ADDR3,
      SECSTKBK_GODOWN_ADDR4,
      SECSTKBK_APPROX_DIST_FROM_BRN,
      SECSTKBK_GODOWN_CONDITION,
      SECSTKBK_RENT_OWN_PARTY,
      SECSTKBK_RENT_NAME,
      SECSTKBK_STK_UNDER_BANK,
      SECSTKBK_KEY_NUMBER,
      SECSTKBK_ENTD_BY,
      SECSTKBK_ENTD_ON,
      SECSTKBK_LAST_MOD_BY,
      SECSTKBK_LAST_MOD_ON
      )
      VALUES
      (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,:18,:19,:20,:21,:22,:23)';
        EXECUTE IMMEDIATE W_SQL
          USING W_ENTITY_NUM, W_RCPTCNT, NVL(STK.SECSTK_ASSIGNMENT_DATE, W_CURR_DATE),
                            W_DAYSL,STK.SECSTK_STMT_CODE, STK.SECSTK_STMT_FREQ, STK.SECSTK_STMT_END_DATE, STK.SECSTK_SUB_BEFORE_DAYS, STK.SECSTK_GODOWN_DTLS_REQD, STK.SECSTK_GODOWN_ADDR1, STK.SECSTK_GODOWN_ADDR2, STK.SECSTK_GODOWN_ADDR3, STK.SECSTK_GODOWN_ADDR4, STK.SECSTK_APPROX_DIST_FROM_BRN, STK.SECSTK_GODOWN_CONDITION, STK.SECSTK_RENT_OWN_PARTY, STK.SECSTK_RENT_NAME, STK.SECSTK_STK_UNDER_BANK, STK.SECSTK_KEY_NUMBER, W_ENTD_BY, W_CURR_DATE, W_NULL, W_NULL;
      EXCEPTION
        WHEN OTHERS THEN
          W_ER_CODE := 'SEC38';
          W_ER_DESC := 'INSERT-SECSTKBKDB-SECURITY ' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || STK.SECSTK_CLIENT_NUM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END IN_SECSTKBKDB;

      FOR I IN 1 .. 4 LOOP
        W_LP_OPBAL  := 0;
        W_LP_ADD    := 0;
        W_LP_RED    := 0;
        W_LP_CLBAL  := 0;
        W_LP_MARGIN := 0;

        IF I = 1
        THEN
          W_LP_OPBAL  := NVL(STK.SECSTK_OPEN_BAL1, 0);
          W_LP_ADD    := STK.SECSTK_ADDITIONS1;
          W_LP_RED    := STK.SECSTK_REDUCTIONS1;
          W_LP_CLBAL  := STK.SECSTK_CLOSING_BAL1;
          W_LP_MARGIN := NVL(STK.SECSTK_MARGIN1, 0);
        ELSIF I = 2
        THEN
          W_LP_OPBAL  := NVL(STK.SECSTK_OPEN_BAL2, 0);
          W_LP_ADD    := STK.SECSTK_ADDITIONS2;
          W_LP_RED    := STK.SECSTK_REDUCTIONS2;
          W_LP_CLBAL  := STK.SECSTK_CLOSING_BAL2;
          W_LP_MARGIN := STK.SECSTK_MARGIN2;
        ELSIF I = 3
        THEN
          W_LP_OPBAL  := NVL(STK.SECSTK_OPEN_BAL3, 0);
          W_LP_ADD    := STK.SECSTK_ADDITIONS3;
          W_LP_RED    := STK.SECSTK_REDUCTIONS3;
          W_LP_CLBAL  := STK.SECSTK_CLOSING_BAL3;
          W_LP_MARGIN := STK.SECSTK_MARGIN3;
        ELSIF I = 4
        THEN
          W_LP_OPBAL  := NVL(STK.SECSTK_OPEN_BAL4, 0);
          W_LP_ADD    := STK.SECSTK_ADDITIONS4;
          W_LP_RED    := STK.SECSTK_REDUCTIONS4;
          W_LP_CLBAL  := STK.SECSTK_CLOSING_BAL4;
          W_LP_MARGIN := STK.SECSTK_MARGIN4;
        END IF;

        IF W_LP_MARGIN > 0
        THEN
          <<IN_SECSTKBKDBDTL>>
          BEGIN
            W_SQL := 'INSERT INTO SECSTKBKDBDTL
     (
      SECSTKBKDTL_ENTITY_NUM,
      SECSTKBKDTL_SECURITY_NUM,
      SECSTKBKDTL_ENTRY_DATE,
      SECSTKBKDTL_DAY_SL,
      SECSTKBKDTL_SL,
      SECSTKBKDTL_STK_BK_DEBTS,
      SECSTKBKDTL_OPEN_BAL,
      SECSTKBKDTL_ADDITIONS,
      SECSTKBKDTL_REDUCTIONS,
      SECSTKBKDTL_CLOSING_BAL,
      SECSTKBKDTL_MARGIN
     )
     VALUES
     (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11)';
            EXECUTE IMMEDIATE W_SQL
              USING W_ENTITY_NUM, W_RCPTCNT,NVL(STK.SECSTK_ASSIGNMENT_DATE, 
              W_CURR_DATE),W_DAYSL , 1, W_NULL, W_LP_OPBAL, W_LP_ADD, W_LP_RED, W_LP_CLBAL, W_LP_MARGIN;
          EXCEPTION
            WHEN OTHERS THEN
              W_ER_CODE := 'SEC39';
              W_ER_DESC := 'INSERT-SECSTKBKDBDTL-SECURITY ' || SQLERRM;
              W_SRC_KEY := P_BRANCH_CODE || '-' || STK.SECSTK_CLIENT_NUM;
              POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
          END IN_SECSTKBKDBDTL;

          <<IN_SECSTKBKDT>>
          BEGIN
            W_SQL := 'INSERT INTO SECSTKBKDT
      (
        SECSTKDT_ENTITY_NUM,
        SECSTKDT_SECURITY_NUM,
        SECSTKDT_ENTRY_DATE,
        SECSTKDT_DAY_SL,
        SECSTKDT_STMT_CODE,
        SECSTKDT_STMT_FREQ,
        SECSTKDT_STMT_END_DATE,
        SECSTKDT_SUB_BEFORE_DAYS,
        SECSTKDT_GODOWN_REQ_FLAG,
        SECSTKDT_GODOWN_ADDR1,
        SECSTKDT_GODOWN_ADDR2,
        SECSTKDT_GODOWN_ADDR3,
        SECSTKDT_GODOWN_ADDR4,
        SECSTKDT_APPROX_DIST_FROM_BRN,
        SECSTKDT_GODOWN_CONDITION,
        SECSTKDT_RENT_OWN_PARTY,
        SECSTKDT_RENT_NAME,
        SECSTKDT_STK_UNDER_BANK,
        SECSTKDT_KEY_NUMBER,
        SECSTKDT_ENTD_BY,
        SECSTKDT_ENTD_ON,
        SECSTKDT_LAST_MOD_BY,
        SECSTKDT_LAST_MOD_ON,
        SECSTKDT_AUTH_BY,
        SECSTKDT_AUTH_ON,
        SECSTKDT_REJ_BY,
        SECSTKDT_REJ_ON
      )
      VALUES
      (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,:18,:19,:20,:21,:22,:23,:24,:25,:26,:27)';
            EXECUTE IMMEDIATE W_SQL
              USING W_ENTITY_NUM, W_RCPTCNT, W_CURR_DATE,W_DAYSL, STK.SECSTK_STMT_CODE, STK.SECSTK_STMT_FREQ, STK.SECSTK_STMT_END_DATE, STK.SECSTK_SUB_BEFORE_DAYS, STK.SECSTK_GODOWN_DTLS_REQD, STK.SECSTK_GODOWN_ADDR1, STK.SECSTK_GODOWN_ADDR2, STK.SECSTK_GODOWN_ADDR3, STK.SECSTK_GODOWN_ADDR4, STK.SECSTK_APPROX_DIST_FROM_BRN, STK.SECSTK_GODOWN_CONDITION, STK.SECSTK_RENT_OWN_PARTY, STK.SECSTK_RENT_NAME, STK.SECSTK_STK_UNDER_BANK, STK.SECSTK_KEY_NUMBER, W_ENTD_BY, W_CURR_DATE, W_NULL, W_NULL, W_ENTD_BY, W_CURR_DATE, W_NULL, W_NULL;
          EXCEPTION
            WHEN OTHERS THEN
              W_ER_CODE := 'SEC40';
              W_ER_DESC := 'INSERT-SECSTKBKDT-SECURITY ' || SQLERRM;
              W_SRC_KEY := P_BRANCH_CODE || '-' || STK.SECSTK_CLIENT_NUM;
              POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
          END IN_SECSTKBKDT;

          <<IN_SECSTKBKDTDTL>>
          BEGIN
            W_SQL := 'INSERT INTO SECSTKBKDTDTL
       (
        SECSTKDTDTL_ENTITY_NUM,
        SECSTKDTDTL_SECURITY_NUM,
        SECSTKDTDTL_ENTRY_DATE,
        SECSTKDTDTL_DAY_SL,
        SECSTKDTDTL_SERIAL,
        SECSTKDTDTL_STK_BK_DEBTS,
        SECSTKDTDTL_OPEN_BAL,
        SECSTKDTDTL_ADDITIONS,
        SECSTKDTDTL_REDUCTION,
        SECSTKDTDTL_CLOSING_BAL,
        SECSTKDTDTL_MARGIN
       )
       VALUES
       (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11)';
            EXECUTE IMMEDIATE W_SQL
              USING W_ENTITY_NUM, W_RCPTCNT, W_CURR_DATE,W_DAYSL, 1, W_NULL, W_LP_OPBAL, W_LP_ADD, W_LP_RED, W_LP_CLBAL, W_LP_MARGIN;
          EXCEPTION
            WHEN OTHERS THEN
              W_ER_CODE := 'SEC41';
              W_ER_DESC := 'INSERT-SECSTKBKDTDTL-SECURITY ' || SQLERRM;
              W_SRC_KEY := P_BRANCH_CODE || '-' || STK.SECSTK_CLIENT_NUM;
              POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
          END IN_SECSTKBKDTDTL;
        END IF;

      END LOOP;

      W_RCPTCNT := W_RCPTCNT + 1;
    END IF;

  END LOOP;

  UPDATE MIG_SECRCPTNUM SET MIG_LAST_SECURITY_NUM = W_RCPTCNT;
  /*
  =============================================================================================
                         SECURITY STOCK MIGRATION -end
  =============================================================================================

  =============================================================================================
                         SECURITY INSURANCE MIGRATION -beg
  =============================================================================================

  */
  --SELECT MIG_LAST_SECURITY_NUM + 1 INTO W_RCPTCNT FROM MIG_SECRCPTNUM;

  FOR INSUR IN (SELECT SECINSUR_BRN_CODE,
                       SECINSUR_SEC_SL_NUM,
                       SECINSUR_POLICY_SL,
                       SECINSUR_RECEIPT_POLICY_DATE,
                       SECINSUR_RENEW_EXP_POLICY,
                       SECINSUR_EXP_INSUR_POLICY_NUN,
                       SECINSUR_BY_BANK_CUST,
                       SECINSUR_COMPANY_CODE,
                       SECINSUR_POLICY_NUM,
                       SECINSUR_POLICY_DATE,
                       SECINSUR_POLICY_VALUE,
                       SECINSUR_PREMIUM_FREQ,
                       SECINSUR_PREMIUM_AMT,
                       SECINSUR_FIRST_PAY_DATE,
                       SECINSUR_DT_UPTO_PREM_PAID,
                       SECINSUR_NEXT_DUE_PREM_DT,
                       SECINSUR_PREM_PAID,
                       SECINSUR_EXPIRY_DATE,
                       SECINSUR_RISK_COV1,
                       SECINSUR_RISK_COV2,
                       SECINSUR_RISK_COV3
                FROM MIG_SECINSUR
                WHERE SECINSUR_BRN_CODE = P_BRANCH_CODE
                AND SECINSUR_SEC_SL_NUM IS NOT NULL) LOOP

    <<CHECK_FLAG>>
    BEGIN
      SELECT SEC_NEW_SECSL
      INTO W_RCPTCNT
      FROM TEMP_SEC
      WHERE TEMP_SEC.SEC_BRN = P_BRANCH_CODE
      AND TEMP_SEC.SEC_OLD_SECSL = INSUR.SECINSUR_SEC_SL_NUM;

      W_INSURE_CODE := 1; -- To be checked

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        W_ER_CODE := 'SEC31';
        W_ER_DESC := 'SP_MIG_SECURITY-SELECT-SECINSUR CODE-SECURITY ' ||
                     SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || INSUR.SECINSUR_SEC_SL_NUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      WHEN OTHERS THEN
        W_ER_CODE := 'SEC53';
        W_ER_DESC := 'SP_MIG_SECURITY-SELECT-SECINSUR CODE-SECURITY ' ||
                     SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || INSUR.SECINSUR_SEC_SL_NUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END CHECK_FLAG;

    IF W_INSURE_CODE = '1'
    THEN

      <<IN_SECINSUR>>
      BEGIN
        W_SQL := 'INSERT INTO SECINSUR
                (SECINSUR_ENTITY_NUM,
                 SECINSUR_SEC_NUM,
                 SECINSUR_POLICY_SL,
                 SECINSUR_RECEIPT_POLICY_DATE,
                 SECINSUR_TAKING_CHGS_DATE,
                 SECINSUR_RENEW_EXP_POLICY,
                 SECINSUR_EXP_INSUR_SL,
                 SECINSUR_BY_BANK_CUST,
                 SECINSUR_COMPANY_CODE,
                 SECINSUR_POLICY_NUM,
                 SECINSUR_POLICY_DATE,
                 SECINSUR_POLICY_VALUE,
                 SECINSUR_PREMIUM_FREQ,
                 SECINSUR_PREMIUM_AMT,
                 SECINSUR_FIRST_PAY_DATE,
                 SECINSUR_DT_UPTO_PREM_PAID,
                 SECINSUR_NEXT_DUE_PREM_DT,
                 SECINSUR_PREM_PAID,
                 SECINSUR_EXPIRY_DATE,
                 SECINSUR_RISK_COV1,
                 SECINSUR_RISK_COV2,
                 SECINSUR_RISK_COV3,
                 SECINSUR_ENTD_BY,
                 SECINSUR_ENTD_ON,
                 SECINSUR_LAST_MOD_BY,
                 SECINSUR_LAST_MOD_ON,
                 SECINSUR_AUTH_BY,
                 SECINSUR_AUTH_ON,
                 SECINSUR_REJ_BY,
                 SECINSUR_REJ_ON)
              VALUES
                (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,:18,:19,:20,:21,:22,:23,:24,:25,:26,:27,:28,:29,:30)';
        EXECUTE IMMEDIATE W_SQL
          USING W_ENTITY_NUM, W_RCPTCNT, NVL(INSUR.SECINSUR_POLICY_SL, 1), INSUR.SECINSUR_RECEIPT_POLICY_DATE, W_NULL, INSUR.SECINSUR_RENEW_EXP_POLICY, W_NULL, INSUR.SECINSUR_BY_BANK_CUST, INSUR.SECINSUR_COMPANY_CODE, INSUR.SECINSUR_POLICY_NUM, INSUR.SECINSUR_POLICY_DATE, INSUR.SECINSUR_POLICY_VALUE, INSUR.SECINSUR_PREMIUM_FREQ, INSUR.SECINSUR_PREMIUM_AMT, INSUR.SECINSUR_FIRST_PAY_DATE, INSUR.SECINSUR_DT_UPTO_PREM_PAID, INSUR.SECINSUR_NEXT_DUE_PREM_DT, INSUR.SECINSUR_PREM_PAID, INSUR.SECINSUR_EXPIRY_DATE, INSUR.SECINSUR_RISK_COV1, INSUR.SECINSUR_RISK_COV2, INSUR.SECINSUR_RISK_COV3, W_ENTD_BY, W_CURR_DATE, W_NULL, W_NULL, W_ENTD_BY, W_CURR_DATE, W_NULL, W_NULL;
      EXCEPTION
        WHEN OTHERS THEN
          W_ER_CODE := 'SEC32';
          W_ER_DESC := 'INSERT-SECINSUR-SECURITY ' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || INSUR.SECINSUR_SEC_SL_NUM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END IN_SECINSUR;

    END IF;
  END LOOP;

  INSERT INTO LNGSACNTS
    SELECT W_ENTITY_NUM,
           LNACNT_INTERNAL_ACNUM,
           LNACNT_PURPOSE_CODE,
           LMTLINE_SANCTION_CURR,
           (SELECT LNDP_DP_AMT_AS_PER_SEC
            FROM LNDP
            WHERE LNDP_CLIENT_NUM = LMTLINE_CLIENT_CODE
            AND LNDP_LIMIT_NUM = LMTLINE_NUM),
           LMTLINE_SAUTH_CODE,
           LMTLINE_SANCTION_CURR,
           LMTLINE_SANCTION_AMT,
           LMTLINE_SANCTION_REF_NUM,
           LMTLINE_LIMIT_EXPIRY_DATE,
           NULL,
           0,
           LMTLINE_SANCTION_CURR,
           LMTLINE_DP_AMT,
           (SELECT LNDP_DP_REVIEW_DUE_DATE
            FROM LNDP
            WHERE LNDP_CLIENT_NUM = LMTLINE_CLIENT_CODE
            AND LNDP_LIMIT_NUM = LMTLINE_NUM),
           LNACIRS_AC_LEVEL_INT_REQD,
           LNACIRS_FIXED_FLOATING_RATE,
           LNACIRS_STD_INT_RATE_TYPE,
           LNACIRS_DIFF_INT_RATE_CHOICE,
           LNACIRS_DIFF_INT_RATE,
           LNACIRS_TENOR_SLAB_CODE,
           LNACIRS_TENOR_SLAB_SL,
           LNACIRS_AMT_SLAB_CODE,
           LNACIRS_AMT_SLAB_SL,
           LNACIRS_OVERDUE_INT_APPLICABLE,
           (SELECT LNACIR_AMT_SLABS_REQD
            FROM LNACIR
            WHERE LNACIR_INTERNAL_ACNUM = LNACNT_INTERNAL_ACNUM),
           (SELECT LNACIR_SLAB_APPL_CHOICE
            FROM LNACIR
            WHERE LNACIR_INTERNAL_ACNUM = LNACNT_INTERNAL_ACNUM),
           (SELECT LNACIR_APPL_INT_RATE
            FROM LNACIR
            WHERE LNACIR_INTERNAL_ACNUM = LNACNT_INTERNAL_ACNUM),
           (SELECT LNACRS_EQU_INSTALLMENT
            FROM LNACRS
            WHERE LNACRS_INTERNAL_ACNUM = LNACNT_INTERNAL_ACNUM),
           'MIGRATION',
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           LMTLINE_CLIENT_CODE,
           LMTLINE_NUM,
           W_ENTD_BY,
           W_CURR_DATE,
           NULL,
           NULL,
           W_ENTD_BY,
           W_CURR_DATE,
           NULL,
           NULL,
           NULL
    FROM LOANACNTS, LIMITLINE, ACASLLDTL, LNACIRS
    WHERE LNACNT_INTERNAL_ACNUM = ACASLLDTL_INTERNAL_ACNUM
    AND LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
    AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
    AND LNACIRS_INTERNAL_ACNUM = ACASLLDTL_INTERNAL_ACNUM
    AND LNACIRS_INTERNAL_ACNUM = LNACNT_INTERNAL_ACNUM
    AND LNACNT_INTERNAL_ACNUM IN
          (SELECT ACNTS_INTERNAL_ACNUM
           FROM ACNTS
           WHERE ACNTS_PROD_CODE IN
                 (SELECT LNPRD_PROD_CODE
                  FROM LNPRODPM
                  WHERE LNPRD_ADV_AGNST_GOVT_SEC = 1)
                  AND ACNTS.ACNTS_BRN_CODE = P_BRANCH_CODE);

  INSERT INTO SECVAL
    (SECVAL_ENTITY_NUM,
     SECVAL_SECURITY_NUM,
     SECVAL_EFF_DATE,
     SECVAL_ENTRY_DATE,
     SECVAL_CURR_CODE,
     SECVAL_SECURED_VALUE,
     SECVAL_VALUATION_BY,
     SECVAL_VALUATION_DATE,
     SECVAL_REM1,
     SECVAL_REM2,
     SECVAL_REM3,
     SECVAL_ENTD_BY,
     SECVAL_ENTD_ON,
     SECVAL_LAST_MOD_BY,
     SECVAL_LAST_MOD_ON,
     SECVAL_AUTH_BY,
     SECVAL_AUTH_ON,
     SECVAL_REJ_BY,
     SECVAL_REJ_ON)
    SELECT W_ENTITY_NUM,
           SECRCPT_SECURITY_NUM,
           SECRCPT_VALUATION_DATE,
           SECRCPT_VALUATION_DATE,
           SECRCPT_CURR_CODE,
           SECRCPT_SECURED_VALUE,
           'MIG',
           SECRCPT_VALUATION_DATE,
           'MIG',
           'CLIENT ' || SECRCPT_CLIENT_NUM,
           'SEC TYPE ' || SECRCPT_SEC_TYPE,
           SECRCPT_ENTD_BY,
           SECRCPT_ENTD_ON,
           SECRCPT_LAST_MOD_BY,
           SECRCPT_LAST_MOD_ON,
           SECRCPT_AUTH_BY,
           SECRCPT_AUTH_ON,
           NULL,
           NULL
    FROM SECRCPT;

  --Insert into SECASSIGNMTDBAL

  INSERT INTO SECASSIGNMTDBAL
    (SECAGMTDBAL_ENTITY_NUM,
     SECAGMTDBAL_CLIENT_NUM,
     SECAGMTDBAL_LIMIT_LINE_NUM,
     SECAGMTDBAL_EFF_DATE,
     SECAGMTDBAL_SEC_NUM,
     SECAGMTDBAL_ASSIGN_PERC,
     SECAGMTDBAL_SEC_NATURE)
    SELECT SECAGMTBAL_ENTITY_NUM,
           SECAGMTBAL_CLIENT_NUM,
           SECAGMTBAL_LIMIT_LINE_NUM,
           W_CURR_DATE,
           SECAGMTBAL_SEC_NUM,
           SECAGMTBAL_ASSIGN_PERC,
           SECAGMTBAL_SEC_NATURE
    FROM SECASSIGNMTBAL;

  INSERT INTO LNGOVTSEC
    (LNGOVTSEC_ENTITY_NUM,
     LNGOVTSEC_SEC_NUM,
     LNGOVTSEC_PRINCIPAL_MARGIN,
     LNGOVTSEC_INT_RATE,
     LNGOVTSEC_INT_ACCR_AMT,
     LNGOVTSEC_INT_MARGIN,
     LNGOVTSEC_AMT_ELIG_ON_PRIN,
     LNGOVTSEC_AMT_ELIG_ON_INT,
     LNGOVTSEC_TOT_ELIG_LIMIT_AMT,
     LNGOVTSEC_INTERNAL_ACNUM,
     LNGOVTSEC_ACT_PRIN_MARGIN,
     LNGOVTSEC_ACT_INT_MARGIN)
    SELECT LNGSACNTDTL_ENTITY_NUM,
           LNGSACNTDTL_SEC_REGNUM,
           LNGSACNTDTL_PRINCIPAL_MARGIN,
           LNGSACNTDTL_INT_RATE,
           LNGSACNTDTL_INT_ACCR_AMT,
           LNGSACNTDTL_INT_MARGIN,
           LNGSACNTDTL_AMT_ELIG_ON_PRIN,
           LNGSACNTDTL_AMT_ELIG_ON_INT,
           LNGSACNTDTL_TOT_ELIG_LIMIT_AMT,
           LNGSACNTDTL_INTERNAL_ACNUM,
           LNGSACNTDTL_PRINCIPAL_MARGIN,
           LNGSACNTDTL_INT_MARGIN
    FROM LNGSACNTDTL;

  UPDATE LNGSACNTDTL
  SET LNGSACNTDTL_ACT_PRIN_MARGIN = LNGSACNTDTL_PRINCIPAL_MARGIN,
      LNGSACNTDTL_ACT_INT_MARGIN  = LNGSACNTDTL_INT_MARGIN;

  /*
  insert into lngsacntdtl
  (
  LNGSACNTDTL_ENTITY_NUM
  LNGSACNTDTL_INTERNAL_ACNUM
  LNGSACNTDTL_SL_NUM
  LNGSACNTDTL_SEC_TYPE
  LNGSACNTDTL_ISSUER_CODE
  LNGSACNTDTL_INVEST_DATE
  LNGSACNTDTL_SEC_CURR
  LNGSACNTDTL_UNIT_FACE_VALUE
  LNGSACNTDTL_NUM_OF_UNITS
  LNGSACNTDTL_TOT_FACE_VALUE
  LNGSACNTDTL_PRINCIPAL_MARGIN
  LNGSACNTDTL_INT_RATE
  LNGSACNTDTL_INT_ACCR_AMT
  LNGSACNTDTL_INT_MARGIN
  LNGSACNTDTL_MAT_VALUE
  LNGSACNTDTL_AMT_ELIG_ON_PRIN
  LNGSACNTDTL_AMT_ELIG_ON_INT
  LNGSACNTDTL_TOT_ELIG_LIMIT_AMT
  LNGSACNTDTL_MAT_DATE
  LNGSACNTDTL_REMARKS1
  LNGSACNTDTL_REMARKS2
  LNGSACNTDTL_REMARKS3
  LNGSACNTDTL_SEC_REGNUM
  )
  select * from loanacnts.lnacnt_
  */

  /*
  =============================================================================================
                         SECURITY INSURANCE MIGRATION -end
  =============================================================================================

  */

  /*
  =============================================================================================
                         SECURITY JEWEL MIGRATION -beg
  =============================================================================================

  */

  FOR JWL IN (SELECT SECJWL_BRN_CODE,
SECJWL_SEC_SL_NUM,
SECJWL_TAKING_CHRG_DATE,
SECJWL_CLIENT_NUM,
SECJWL_SEC_TYPE,
SECJWL_MODE_OF_SEC,
SECJWL_PLEDGE_EXISTS,
SECJWL_PLEDGE_DATE,
SECJWL_CONFIRMATION_DATE,
SECJWL_MARGIN_PER,
SECJWL_METAL_CODE,
SECJWL_ORNAMENT_DESCN1,
SECJWL_ORNAMENT_DESCN2,
SECJWL_ORNAMENT_DESCN3,
SECJWL_NUM_OF_JEWELS,
SECJWL_GROSS_WEIGHT,
SECJWL_NET_WEIGHT,
SECJWL_ELIG_RATE_PER_GRAM,
SECJWL_CURR_CODE,
SECJWL_PERM_FINANCE_AMT,
SECJWL_VALUE_OF_SECURITY,
SECJWL_SECURED_VALUE,
SECJWL_REM1,
SECJWL_REM2,
SECJWL_REM3,
SECJWL_APPRAISAL_BY,
SECJWL_APPRAISAL_DATE,
SECJWL_ENTD_BY,
SECJWL_ENTD_ON,
SECJWL_LAST_MOD_BY,
SECJWL_LAST_MOD_ON,
SECJWL_ASSIGN_ACNUM1,
SECJWL_ASSIGN_PER1,
SECJWL_ASSIGN_ACNUM2,
SECJWL_ASSIGN_PER2,
SECJWL_ASSIGN_ACNUM3,
SECJWL_ASSIGN_PER3,
SECJWL_ASSIGN_ACNUM4,
SECJWL_ASSIGN_PER4,
SECJWL_ASSIGN_ACNUM5,
SECJWL_ASSIGN_PER5,
SECJWL_ASSIGN_ACNUM6,
SECJWL_ASSIGN_PER6,
SECJWL_ASSIGN_ACNUM7,
SECJWL_ASSIGN_PER7,
SECJWL_ASSIGN_ACNUM8,
SECJWL_ASSIGN_PER8,
SECJWL_ASSIGN_ACNUM9,
SECJWL_ASSIGN_PER9,
SECJWL_ASSIGN_ACNUM10,
SECJWL_ASSIGN_PER10,
SECJWL_ASSIGNMENT_DATE,
SECJWL_SEC_NAT1,
SECJWL_SEC_NAT2,
SECJWL_SEC_NAT3,
SECJWL_SEC_NAT4,
SECJWL_SEC_NAT5,
SECJWL_SEC_NAT6,
SECJWL_SEC_NAT7,
SECJWL_SEC_NAT8,
SECJWL_SEC_NAT9,
SECJWL_SEC_NAT10,
SECJWL_SEC_OWNER1,
SECJWL_SEC_OWNER2,
SECJWL_SEC_OWNER3,
SECJWL_SEC_OWNER4,
SECJWL_SEC_OWNER5,
SECJWL_SEC_OWNER6,
SECJWL_SEC_OWNER7,
SECJWL_SEC_OWNER8,
SECJWL_SEC_OWNER9,
SECJWL_SEC_OWNER10
              FROM MIG_SECJEWEL
               WHERE SECJWL_BRN_CODE = P_BRANCH_CODE
               --and SECJWL_CLIENT_NUM=600072014
               ) LOOP

    FETCH_CLIENT(JWL.SECJWL_CLIENT_NUM, W_CLIENT_NUM);

    IF W_CLIENT_NUM > 0
    THEN

      INSERT INTO TEMP_SEC
      VALUES
        (P_BRANCH_CODE, JWL.SECJWL_SEC_SL_NUM, W_RCPTCNT, 'JWL');

      IN_SECRCPT(W_RCPTCNT, --W_RCPTCNT
                 P_BRANCH_CODE,
                 JWL.SECJWL_TAKING_CHRG_DATE, --W_CHRG_DATE
                 W_CLIENT_NUM, --W_CL_NUM
                 JWL.SECJWL_SEC_TYPE, --W_SEC_TYPE
                 JWL.SECJWL_MODE_OF_SEC, --W_MODE_OF_SEC
                 NULL, --W_TYPE_OF_MORTGAGE
                 NULL, --W_MORTAGER_NAME
                 NULL, --W_DATE_OF_MORT
                 NULL, --W_PLAC_OF_MORT
                 JWL.SECJWL_PLEDGE_EXISTS, --W_PLEDGE_EXISTS
                 JWL.SECJWL_PLEDGE_DATE, --W_PLEDGE_DATE
                 JWL.SECJWL_CONFIRMATION_DATE, --W_CONFIRMATION_DATE
                 JWL.SECJWL_CURR_CODE, --W_CURR_CODE
                 JWL.SECJWL_ORNAMENT_DESCN1, --W_DESCN1
                 JWL.SECJWL_ORNAMENT_DESCN2, --W_DESCN2
                 JWL.SECJWL_ORNAMENT_DESCN3, --W_DESCN3
                 NULL, --W_DESCN4
                 NULL, --W_DESCN5
                 NVL(JWL.SECJWL_MARGIN_PER, 0), --W_MARGIN_PER
                 JWL.SECJWL_APPRAISAL_DATE, --W_VALUATION_DATE
                 JWL.SECJWL_APPRAISAL_DATE, --W_LIEN_CHGS_DATE
                 NULL, --W_TAX_PAID_UPTO
                 '0', --W_INSUR_REQD
                 NULL, --W_INSUR_BY
                 JWL.SECJWL_VALUE_OF_SECURITY, --W_VAL_OF_SECURITY
                 JWL.SECJWL_SECURED_VALUE, --W_SECURED_VALUE
                 0, --W_NUM_OF_CHGS
                 0, --W_OUR_PRIORITY_CHGS
                 'N', --W_TYPE_OF_PROPERTY
                 NULL, --W_ELIGFIN_COLLATERAL
                 NULL, --W_ELIG_CASH_COLLATERAL
                 NULL, --W_CLAIM_CATG
                 NULL, --W_CLAIM_SUB_CATG
                 JWL.SECJWL_REM1, --W_REM1
                 JWL.SECJWL_REM1, --W_REM2
                 JWL.SECJWL_REM1, --W_REM3
                 NULL, --W_REM4
                 NULL, --W_REM5
                 NULL, --W_RELEASED_ON
                 NULL, --W_DETAILS_ENTD
                 W_ENTD_BY, --W_ENTD_BY
                 W_CURR_DATE, --W_ENTD_ON
                 NULL, --W_LAST_MOD_BY
                 NULL, --W_LAST_MOD_ON
                 W_ENTD_BY, --W_AUTH_BY
                 W_CURR_DATE, --W_AUTH_ON
                 NULL, --W_REJ_BY
                 NULL, --W_REJ_ON
                 'MIG_SECJEWEL' || '-' || W_CLIENT_NUM, --W_UNIQ_ID
                 P_ERR_MSG);

        FOR I IN 1 .. 10 LOOP

        W_LP_ACNUM := 0;
        W_LP_PER   := 0;
        W_LP_NAT   := NULL;

        IF I = 1
        THEN
          W_LP_ACNUM := JWL.SECJWL_ASSIGN_ACNUM1;
          W_LP_PER   := JWL.SECJWL_ASSIGN_PER1;
          W_LP_NAT   := JWL.SECJWL_SEC_NAT1;
    --      W_OWNER    := JWL.SECJWL_OWNER1;
        ELSIF I = 2
        THEN
          W_LP_ACNUM := JWL.SECJWL_ASSIGN_ACNUM2;
          W_LP_PER   := JWL.SECJWL_ASSIGN_PER2;
          W_LP_NAT   := JWL.SECJWL_SEC_NAT2;
   --       W_OWNER    := JWL.SECJWL_OWNER2;
        ELSIF I = 3
        THEN
          W_LP_ACNUM := JWL.SECJWL_ASSIGN_ACNUM3;
          W_LP_PER   := JWL.SECJWL_ASSIGN_PER3;
          W_LP_NAT   := JWL.SECJWL_SEC_NAT3;
     --     W_OWNER    := JWL.SECJWL_OWNER3;
        ELSIF I = 4
        THEN
          W_LP_ACNUM := JWL.SECJWL_ASSIGN_ACNUM4;
          W_LP_PER   := JWL.SECJWL_ASSIGN_PER4;
          W_LP_NAT   := JWL.SECJWL_SEC_NAT4;
       --   W_OWNER    := JWL.SECJWL_OWNER4;
        ELSIF I = 5
        THEN
          W_LP_ACNUM := JWL.SECJWL_ASSIGN_ACNUM5;
          W_LP_PER   := JWL.SECJWL_ASSIGN_PER5;
          W_LP_NAT   := JWL.SECJWL_SEC_NAT5;
         -- W_OWNER    := JWL.SECJWL_OWNER5;
        ELSIF I = 6
        THEN
          W_LP_ACNUM := JWL.SECJWL_ASSIGN_ACNUM6;
          W_LP_PER   := JWL.SECJWL_ASSIGN_PER6;
          W_LP_NAT   := JWL.SECJWL_SEC_NAT6;
         -- W_OWNER    := JWL.SECJWL_OWNER6;
        ELSIF I = 7
        THEN
          W_LP_ACNUM := JWL.SECJWL_ASSIGN_ACNUM7;
          W_LP_PER   := JWL.SECJWL_ASSIGN_PER7;
          W_LP_NAT   := JWL.SECJWL_SEC_NAT7;
         -- W_OWNER    := JWL.SECJWL_OWNER7;
        ELSIF I = 8
        THEN
          W_LP_ACNUM := JWL.SECJWL_ASSIGN_ACNUM8;
          W_LP_PER   := JWL.SECJWL_ASSIGN_PER8;
          W_LP_NAT   := JWL.SECJWL_SEC_NAT8;
         -- W_OWNER    := JWL.SECJWL_OWNER8;
        ELSIF I = 9
        THEN
          W_LP_ACNUM := JWL.SECJWL_ASSIGN_ACNUM9;
          W_LP_PER   := JWL.SECJWL_ASSIGN_PER9;
          W_LP_NAT   := JWL.SECJWL_SEC_NAT9;
        --  W_OWNER    := JWL.SECJWL_OWNER9;
        ELSIF I = 10
        THEN
          W_LP_ACNUM := JWL.SECJWL_ASSIGN_ACNUM10;
          W_LP_PER   := JWL.SECJWL_ASSIGN_PER10;
          W_LP_NAT   := JWL.SECJWL_SEC_NAT10;
       --   W_OWNER    := JWL.SECJWL_OWNER10;
        END IF;

        FETCH_ACNUM(W_LP_ACNUM, W_INTERNAL_NUM);
        INSERT_SECCLIENT(W_RCPTCNT, W_OWNER);

        IF W_INTERNAL_NUM > 0
        THEN

          --FETCH_LIMITLINE(W_INTERNAL_NUM, W_CLIENT_NUM, W_LIMIT_NUM);

          W_ASSIGN_AMT := JWL.SECJWL_SECURED_VALUE * W_LP_PER / 100;

          IN_SECASSIGNMENTS(W_RCPTCNT,
                            NVL(JWL.SECJWL_ASSIGNMENT_DATE, W_CURR_DATE),
                            W_DAYSL,
                            W_ASSIGN_AMT,
                            0,
                            JWL.SECJWL_REM1,
                            JWL.SECJWL_REM2,
                            JWL.SECJWL_REM3,
                            W_ENTD_BY,
                            W_CURR_DATE,
                            W_NULL,
                            W_NULL,
                            W_ENTD_BY,
                            W_CURR_DATE,
                            W_NULL,
                            W_NULL,
                            'MIG_SECJEWEL' || '-' || JWL.SECJWL_CLIENT_NUM);
          IN_SECASSIGNMTDTL(W_RCPTCNT,
                            NVL(JWL.SECJWL_ASSIGNMENT_DATE, W_CURR_DATE),
                            W_DATESL,
                            W_DAYSL,
                            W_CLIENT_NUM,
                            W_LIMIT_NUM,
                            W_LP_PER,
                            W_ASSIGN_AMT,
                            W_LP_NAT,
                            'MIG_SECJEWEL' || '-' || JWL.SECJWL_CLIENT_NUM);
          IN_SECASSIGNMTBAL(W_RCPTCNT,
                            W_CLIENT_NUM,
                            W_LIMIT_NUM,
                            W_LP_PER,
                            W_ASSIGN_AMT,
                            W_LP_NAT,
                            'MIG_SECJEWEL' || '-' || JWL.SECJWL_CLIENT_NUM);
          /*
           IN_SECASSIGNMTDBAL(W_CLIENT_NUM,
                              W_LIMIT_NUM,
                              NVL(STK.SECSTK_ASSIGNMENT_DATE, W_CURR_DATE),
                              W_RCPTCNT,
                              W_LP_PER,
                              W_LP_NAT,
                              'MIG_SECSTOCK' || '-' || STK.SECSTK_CLIENT_NUM);
          */
        END IF;
      END LOOP;

      <<IN_SECJEWEL>>
      BEGIN
        INSERT INTO SECJEWEL
          (SECJWL_ENTITY_NUM,
           SECJWL_SECURITY_NUM,
           SECJWL_METAL_CODE,
           SECJWL_ORNAMENT_DESCN1,
           SECJWL_ORNAMENT_DESCN2,
           SECJWL_ORNAMENT_DESCN3,
           SECJWL_NUM_OF_JEWELS,
           SECJWL_GROSS_WEIGHT,
           SECJWL_NET_WEIGHT,
           SECJWL_ELIG_RATE_PER_GRAM,
           SECJWL_CURR_CODE,
     SECJWL_PERM_FINANCE_AMT,
           SECJWL_APPRAISAL_BY,
           SECJWL_APPRAISAL_DATE,
           SECJWL_ENTD_BY,
           SECJWL_ENTD_ON,
           SECJWL_LAST_MOD_BY,
           SECJWL_LAST_MOD_ON)
        VALUES
         (W_ENTITY_NUM,           W_RCPTCNT,
          JWL.SECJWL_METAL_CODE,
          JWL.SECJWL_ORNAMENT_DESCN1,
    JWL.SECJWL_ORNAMENT_DESCN2,
          JWL.SECJWL_ORNAMENT_DESCN3,
    JWL.SECJWL_NUM_OF_JEWELS,
    JWL.SECJWL_GROSS_WEIGHT,
    JWL.SECJWL_NET_WEIGHT,
    JWL.SECJWL_ELIG_RATE_PER_GRAM,
    JWL.SECJWL_CURR_CODE,
    JWL.SECJWL_PERM_FINANCE_AMT,
    JWL.SECJWL_APPRAISAL_BY,
    JWL.SECJWL_APPRAISAL_DATE,
    JWL.SECJWL_ENTD_BY,
    JWL.SECJWL_ENTD_ON,
    JWL.SECJWL_LAST_MOD_BY,
    JWL.SECJWL_LAST_MOD_ON);
      EXCEPTION
        WHEN OTHERS THEN
          W_ER_CODE := 'SEC9';
          W_ER_DESC := 'INSERT-SECJEWEL-SECURITY ' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || JWL.SECJWL_CLIENT_NUM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END IN_SECMORTGAGE;

      W_RCPTCNT := W_RCPTCNT + 1;
    END IF;

  END LOOP;

  UPDATE MIG_SECRCPTNUM SET MIG_LAST_SECURITY_NUM = W_RCPTCNT;




  /*
  =============================================================================================
                         SECURITY JEWEL MIGRATION -end
  =============================================================================================


  */

  -- NEELS-AHBAD-15-JAN-2010 BEG
  UPDATE SECINVEST SI
  SET SI.SECINVEST_TOT_FACE_VAL = SI.SECINVEST_FACE_VALUE *
                                  SI.SECINVEST_NUM_UNITS
  WHERE SI.SECINVEST_NUM_UNITS >= 0
  AND SI.SECINVEST_FACE_VALUE >= 0;

  UPDATE SECRCPT SR
  SET SR.SECRCPT_DETAILS_ENTD         = '1',
      SR.SECRCPT_ELIGFIN_COLLATERAL   = '0',
      SR.SECRCPT_ELIG_CASH_COLLATERAL = '0';

  UPDATE SECVEHICLE SV
  SET SV.SECVEH_EQUIP_VEHICLE_CODE = '999'
  WHERE SV.SECVEH_EQUIP_VEHICLE_CODE IS NULL
  OR SV.SECVEH_EQUIP_VEHICLE_CODE = '0';

  UPDATE SECVEHICLE SV
  SET SV.SECVEH_MANUF_CODE = '999'
  WHERE SV.SECVEH_MANUF_CODE IS NULL
  OR SV.SECVEH_MANUF_CODE = '0';
  -- NEELS-AHBAD-15-JAN-2010 END

  FOR IDX IN (SELECT SECAGMTBAL_ENTITY_NUM,
                     SECAGMTBAL_CLIENT_NUM,
                     SECAGMTBAL_LIMIT_LINE_NUM,
                     SUM(SECAGMTBAL_ASSIGN_AMT) SECAGMTBAL_ASSIGN_AMT,
                     SECRCPT_SEC_TYPE
              FROM SECASSIGNMTBAL, SECRCPT
              WHERE SECRCPT_ENTITY_NUM = SECAGMTBAL_ENTITY_NUM
              AND SECRCPT_SECURITY_NUM = SECAGMTBAL_SEC_NUM
              AND SECAGMTBAL_CLIENT_NUM = SECRCPT_CLIENT_NUM
              GROUP BY SECAGMTBAL_ENTITY_NUM,
                       SECAGMTBAL_CLIENT_NUM,
                       SECAGMTBAL_LIMIT_LINE_NUM,
                       SECRCPT_SEC_TYPE) LOOP
    INSERT INTO LIMITLINECTREQ
      (LLCTREQ_ENTITY_NUM,
       LLCTREQ_CLIENT_NUM,
       LLCTREQ_LIMIT_LINE_NUM,
       LLCTREQ_COLLATERAL_SL,
       LLCTREQ_COLLATERAL_TYPE,
       LLCTREQ_COLLATERAL_REQD_CURR,
       LLCTREQ_COLLATERAL_REQD_AMT)
    VALUES
      (W_ENTITY_NUM,
       IDX.SECAGMTBAL_CLIENT_NUM,
       IDX.SECAGMTBAL_LIMIT_LINE_NUM,
       (SELECT NVL(MAX(LLCTREQ_COLLATERAL_SL), 0) + 1
        FROM LIMITLINECTREQ
        WHERE LLCTREQ_ENTITY_NUM = W_ENTITY_NUM
        AND LLCTREQ_CLIENT_NUM = IDX.SECAGMTBAL_CLIENT_NUM
        AND LLCTREQ_LIMIT_LINE_NUM = IDX.SECAGMTBAL_LIMIT_LINE_NUM),
       IDX.SECRCPT_SEC_TYPE,
       W_CURR_CODE,
       IDX.SECAGMTBAL_ASSIGN_AMT);
  END LOOP;
  
  

  /* COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      P_ERR_MSG := SQLERRM;
      ROLLBACK; */

  /*

  truncate table                MIG_SECINVEST   ;
  truncate table                   MIG_SECMORT;
  truncate table                  MIG_SECSHA  ;
  truncate table                MIG_SECINSUR  ;
  truncate table                    MIG_SECVPM  ;
  truncate table                  MIG_SECSTOCK  ;



  truncate table SECRCPT;
  truncate table SECASSIGNMENTS;
  truncate table SECASSIGNMTDTL;
  truncate table SECASSIGNMTBAL;
  truncate table SECASSIGNMTDBAL;
  truncate table SECMORTGAGE;
  truncate table SECMORTEC;
  truncate table SECINVEST;
  truncate table SECVEHICLE;
  truncate table SECCLIENT;
  truncate table SECSHARES;
  truncate table SECSHARESDTL;
  truncate table LADACNTS;
  truncate table LADACNTDTL;
  truncate table LADDEPLINK;
  truncate table LADDEPLINKHIST;
  truncate table LADDEPLINKHISTDTL;
  truncate table SECINSUR;
  truncate table SECSTKBKDB;
  truncate table SECSTKBKDBDTL;
  truncate table SECSTKBKDT;
  truncate table SECSTKBKDTDTL;
  truncate table SECSHADEMAT;
  truncate table lngsacnts;
  truncate table lngsacntdtl;
  truncate table LNGOVTSEC;
  truncate table secval;
  truncate table LIMITLINECTREQ;
  update mig_secrcptnum ms set ms.mig_last_security_num =0;


  truncate table mig_errorlog;
  truncate table temp_sec;

  */

END SP_MIG_SECURITY;
/
