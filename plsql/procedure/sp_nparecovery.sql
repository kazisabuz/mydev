CREATE OR REPLACE PROCEDURE SP_NPARECOVERY (V_ENTITY_NUM IN NUMBER,
                          P_BRN_CODE    IN NUMBER,
                          P_PROD_CODE   IN NUMBER,
                          P_ASSET_CODE  IN VARCHAR2,
                          P_FROM_DATE    IN VARCHAR2,
                          P_UPTO_DATE    IN VARCHAR2,
                          P_TEMP_SL     OUT NUMBER,
                          P_ERR_MSG     OUT VARCHAR2
                          ) IS



  W_BRN_CODE NUMBER(4) := 0;
  W_PROD_CODE NUMBER(6) := 0;
  W_ASSET_CODE VARCHAR2(5) := '';
  W_INP_ASTCD  VARCHAR2(5) := ''; 
  W_TEMP_SL NUMBER(7) := 0;
  W_ERR_MSG VARCHAR2(3000) := NULL;

  W_PROC_ACNUM NUMBER(14) := 0;
  W_PROD_NAME VARCHAR2(50) := NULL;
  W_ACNT_NAME VARCHAR2(50) := NULL;
  W_CURR_CODE VARCHAR2(3) := NULL;

  W_NPA_FROM_AMT    NUMBER(18,3) := 0;
  W_NPA_UPTO_AMT    NUMBER(18,3) := 0;
  W_BAL2            NUMBER(18,3) := 0;
  W_BAL1            NUMBER(18,3) := 0;
  W_ASON_BC_BAL     NUMBER(18,3) := 0;
  W_NPA_BAL1        NUMBER(18,3) := 0;
  W_NPA_BAL2        NUMBER(18,3) := 0;
  W_CHGSUS_BAL    NUMBER(18,3) := 0;
  W_SUSP_BAL NUMBER(18,3) := 0;
  W_TOT_INT_CR NUMBER(18,3) := 0;
  W_TOT_INT_DB NUMBER(18,3) := 0;
  W_TOT_CHGS_CR NUMBER(18,3) := 0;
  W_TOT_CHGS_DB NUMBER(18,3) := 0;
  W_INT_RECOV_AMT NUMBER(18,3) := 0;
  W_CHGS_RECOV_AMT NUMBER(18,3) := 0;
  W_INT_REV_AMT NUMBER(18,3) := 0;
  W_CHG_REV_AMT NUMBER(18,3) := 0;

  W_SUSP_AMT NUMBER(18,3) := 0;
  W_RECOVERY_AMT NUMBER(18,3) := 0;

  W_MONTH NUMBER(2) := 0;
  W_YEAR NUMBER(4) := 0;
  W_NPA_DATE DATE := NULL;
  W_CBD DATE := NULL;
  W_TEMP_SER_FLG NUMBER := 0;

  W_NPA_FROM_CNT NUMBER(1) := 0;
  W_NPA_UPTO_CNT NUMBER(1) := 0;

  W_SQL VARCHAR2(5300) := NULL;
  MYEXCEPTION EXCEPTION;
  V_ERR_MSG         VARCHAR2(100);
  V_RECOV_AMT       NUMBER(18,3);
  V_RECOV_SUSP_BAL  NUMBER(18,3);
  V_INT_REV_AMT     NUMBER(18,3);
  V_ADD_BAL         NUMBER(18,3);
  V_ADD_SUSP_BAL    NUMBER(18,3);
  W_FROM_DATE    DATE := NULL;
  W_UPTO_DATE    DATE := NULL;
  W_TEMP_SER     NUMBER(7) := 0;
  W_NS_DATE      DATE := NULL;
  W_UA_DATE      DATE := NULL;
  W_AW_DATE      DATE := NULL;
  W_EX_DATE      DATE := NULL;
  W_SA_DATE      DATE := NULL;
  W_OTS_DATE     DATE := NULL;
  W_ST_DATE      DATE := NULL;
  W_MAX_DATE     DATE := NULL;
  W_LEG_CODE     VARCHAR2(5):='';
  W_ASSET_CLASS  CHAR(1) :='';
  W_ERROR_MSG     VARCHAR2(100);
  W_NPA_AMT      NUMBER(18,3) := 0;

  TYPE ACNUM_TAB IS RECORD(
    ACNTS_BRN_CODE       NUMBER(6),
    ACNTS_INTERNAL_ACNUM NUMBER(14),
    ACNTS_CURR_CODE      VARCHAR2(3),
    ACNTS_PROD_CODE      VARCHAR2(6),
    ACNTS_NAME           VARCHAR2(50),
    PRODUCT_NAME         VARCHAR2(50));
    TYPE IN_ACNUM_TAB IS TABLE OF ACNUM_TAB INDEX BY PLS_INTEGER;
    V_ACNUM_TAB IN_ACNUM_TAB;

  PROCEDURE UPDATE_TEMP_TABLE IS
  BEGIN
  IF nvl(W_RECOVERY_AMT,0)<>0 THEN 
            INSERT INTO RTMPNPARECOVERY(
                RTMPNPAREC_TMP_SER,
                RTMPNPAREC_BRN_CODE,
                RTMPNPAREC_PROD_CODE,
                RTMPNPAREC_INTERNAL_ACNUM,
                RTMPNPAREC_ACTUAL_ACNUM,
                RTMPNPAREC_ACNT_NAME,
                RTMPNPAREC_ACNT_CURR,
                RTMPNPAREC_PROD_NAME,
                RTMPNPAREC_ASSET_CD,
                RTMPNPAREC_NPA_DATE,
                RTMPNPAREC_NPA_AMT_START,
                RTMPNPAREC_NPA_START_CNT,
                RTMPNPAREC_NPA_AMT_ASON,
                RTMPNPAREC_NPA_ASON_CNT,
                RTMPNPAREC_RECOV_AMT,
                RTMPNPAREC_RECOV_SUSP_AMT,
                RTMPNPAREC_LEGAL_DATE,
                RTMPNPAREC_LEGAL_CODE)
              VALUES(W_TEMP_SL,
                     W_BRN_CODE,
                     W_PROD_CODE,
                     W_PROC_ACNUM,
                     FACNO(PKG_ENTITY.FN_GET_ENTITY_CODE,W_PROC_ACNUM),
                     W_ACNT_NAME,
                     W_CURR_CODE,
                     W_PROD_NAME,
                     W_ASSET_CODE,
                     W_NPA_DATE,
                     NVL(W_NPA_FROM_AMT,0),
                     NVL(W_NPA_FROM_CNT,0),
                     NVL(W_NPA_UPTO_AMT,0),
                     NVL(W_NPA_UPTO_CNT,0),
                     W_RECOVERY_AMT,
                     W_SUSP_AMT,
                     W_MAX_DATE,
                     W_LEG_CODE);
ELSE NULL;
END IF;
  END UPDATE_TEMP_TABLE;

  PROCEDURE READ_LEGAL_STATUS IS
  BEGIN
    SELECT RTMPLEGALST_NOTICE_SENT_DATE,RTMPLEGALST_UA_DATE,RTMPLEGALST_AWARD_DATE,RTMPLEGALST_EXEC_DATE,RTMPLEGALST_SEC_ACT_DATE,
        RTMPLEGALST_OTS_DATE,RTMPLEGALST_SETTLEMENT_DATE
        INTO W_NS_DATE,W_UA_DATE,W_AW_DATE,W_EX_DATE,W_SA_DATE,W_OTS_DATE,W_ST_DATE
        FROM RTMPLEGSTAT
        WHERE RTMPLEGALST_TMP_SER =  W_TEMP_SER
        AND RTMPLEGALST_BRN_CODE = W_BRN_CODE
        AND RTMPLEGALST_PROD_CODE = W_PROD_CODE
        AND RTMPLEGALST_INTERNAL_AC_NO = W_PROC_ACNUM;

         IF W_NS_DATE IS NOT NULL THEN
            W_MAX_DATE := W_NS_DATE;
            W_LEG_CODE := 'NS';
         ELSIF W_UA_DATE IS NOT NULL THEN
            W_MAX_DATE := W_UA_DATE;
            W_LEG_CODE := 'UA';
         ELSIF W_AW_DATE IS NOT NULL THEN
            W_MAX_DATE := W_AW_DATE;
            W_LEG_CODE := 'AW';
         ELSIF W_EX_DATE IS NOT NULL THEN
            W_MAX_DATE := W_EX_DATE;
            W_LEG_CODE := 'EX';
         ELSIF W_SA_DATE IS NOT NULL THEN
            W_MAX_DATE := W_SA_DATE;
            W_LEG_CODE := 'SA';
         ELSIF W_OTS_DATE IS NOT NULL THEN
            W_MAX_DATE := W_OTS_DATE;
            W_LEG_CODE := 'OTS';
         ELSIF W_ST_DATE IS NOT NULL THEN
            W_MAX_DATE := W_ST_DATE;
            W_LEG_CODE := 'ST';
         END IF;

          IF W_UA_DATE > W_MAX_DATE THEN
            W_MAX_DATE := W_UA_DATE;
            W_LEG_CODE := 'UA';
          END IF;

          IF W_AW_DATE > W_MAX_DATE THEN
            W_MAX_DATE := W_AW_DATE;
            W_LEG_CODE := 'AW';
          END IF;

          IF W_EX_DATE > W_MAX_DATE THEN
            W_MAX_DATE := W_EX_DATE;
            W_LEG_CODE := 'EX';
          END IF;

          IF W_SA_DATE > W_MAX_DATE THEN
            W_MAX_DATE := W_SA_DATE;
            W_LEG_CODE := 'SA';
          END IF;

          IF W_OTS_DATE > W_MAX_DATE THEN
            W_MAX_DATE := W_OTS_DATE;
            W_LEG_CODE := 'OTS';
          END IF;

          IF W_ST_DATE > W_MAX_DATE THEN
            W_MAX_DATE := W_ST_DATE;
            W_LEG_CODE := 'ST';
          END IF;

        EXCEPTION WHEN NO_DATA_FOUND THEN
          W_MAX_DATE := NULL;
          W_LEG_CODE := '';
  END READ_LEGAL_STATUS;

  PROCEDURE GET_UPTODT_DETAILS IS

  BEGIN
    W_NPA_UPTO_CNT      := 0;

    <<ASSET_DETAILS>>
    BEGIN
      SELECT ASSETCLSH_ASSET_CODE,ASSETCD_ASSET_CLASS,ASSETCLSH_NPA_DATE
      INTO W_ASSET_CODE,W_ASSET_CLASS,W_NPA_DATE
      FROM ASSETCLSHIST,ASSETCD
      WHERE ASSETCLSH_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
      AND ASSETCLSH_ASSET_CODE = ASSETCD_CODE
      AND ASSETCLSH_INTERNAL_ACNUM = W_PROC_ACNUM
       AND (W_INP_ASTCD IS NULL OR (W_INP_ASTCD IS NOT NULL AND ASSETCLSH_ASSET_CODE = W_INP_ASTCD)) --poorani - CHN - 26/07/2010 ADD
      AND ASSETCLSH_EFF_DATE = (SELECT MAX(ASSETCLSH_EFF_DATE)
                                FROM ASSETCLSHIST
                                WHERE ASSETCLSH_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                                AND ASSETCLSH_INTERNAL_ACNUM = W_PROC_ACNUM
                                AND ASSETCLSH_EFF_DATE <=  W_UPTO_DATE);
    EXCEPTION WHEN NO_DATA_FOUND THEN
      W_ASSET_CODE        := '';
      W_ASSET_CLASS       := '';
      W_NPA_DATE          := NULL;
    END ASSET_DETAILS;

        IF W_ASSET_CLASS = 'N' THEN

          GET_ASON_ACBAL(PKG_ENTITY.FN_GET_ENTITY_CODE,W_PROC_ACNUM,W_CURR_CODE,W_UPTO_DATE, W_CBD,W_BAL2, W_ASON_BC_BAL,W_ERR_MSG,'0');

           PKG_LNSUSPASON.SP_LNSUSPASON(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                 W_PROC_ACNUM,
                                 W_CURR_CODE,
                                 W_UPTO_DATE ,
                                 W_ERR_MSG,
                                 W_NPA_BAL2,
                                 W_CHGSUS_BAL,
                                 W_SUSP_BAL,
                                 W_TOT_INT_CR,
                                 W_TOT_INT_DB,
                                 W_TOT_CHGS_CR,
                                 W_TOT_CHGS_DB,
                                 W_INT_RECOV_AMT,
                                 W_CHGS_RECOV_AMT,
                                 W_INT_REV_AMT,
                                 W_CHG_REV_AMT);

            W_NPA_UPTO_AMT      := W_BAL2 + W_NPA_BAL2;
            W_NPA_UPTO_CNT      := 1;
        ELSE
            W_NPA_UPTO_AMT      := 0;
        END IF;
  END GET_UPTODT_DETAILS;

  PROCEDURE GET_FROMDT_DETAILS IS

  BEGIN
    W_NPA_FROM_CNT        := 0;


    <<ASSET_DETAILS>>
    BEGIN
      SELECT ASSETCLSH_ASSET_CODE,ASSETCD_ASSET_CLASS,ASSETCLSH_NPA_DATE
      INTO W_ASSET_CODE,W_ASSET_CLASS,W_NPA_DATE
      FROM ASSETCLSHIST,ASSETCD
      WHERE ASSETCLSH_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
      AND ASSETCLSH_ASSET_CODE = ASSETCD_CODE
      AND ASSETCLSH_INTERNAL_ACNUM = W_PROC_ACNUM
       AND (W_INP_ASTCD IS NULL OR (W_INP_ASTCD IS NOT NULL AND ASSETCLSH_ASSET_CODE = W_INP_ASTCD)) --poorani - CHN - 26/07/2010 ADD
      AND ASSETCLSH_EFF_DATE = (SELECT MAX(ASSETCLSH_EFF_DATE)
                                FROM ASSETCLSHIST
                                WHERE ASSETCLSH_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                                AND ASSETCLSH_INTERNAL_ACNUM = W_PROC_ACNUM
                                AND ASSETCLSH_EFF_DATE <=  W_FROM_DATE);
    EXCEPTION WHEN NO_DATA_FOUND THEN
      W_ASSET_CODE        := '';
      W_ASSET_CLASS       := '';
      W_NPA_DATE          := NULL;
    END ASSET_DETAILS;

        IF W_ASSET_CLASS = 'N' THEN

          GET_ASON_ACBAL(PKG_ENTITY.FN_GET_ENTITY_CODE,W_PROC_ACNUM,W_CURR_CODE,W_FROM_DATE, W_CBD,W_BAL1, W_ASON_BC_BAL,W_ERR_MSG,'0');

           PKG_LNSUSPASON.SP_LNSUSPASON(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                 W_PROC_ACNUM,
                                 W_CURR_CODE,
                                 W_FROM_DATE ,
                                 W_ERR_MSG,
                                 W_NPA_BAL1,
                                 W_CHGSUS_BAL,
                                 W_SUSP_BAL,
                                 W_TOT_INT_CR,
                                 W_TOT_INT_DB,
                                 W_TOT_CHGS_CR,
                                 W_TOT_CHGS_DB,
                                 W_INT_RECOV_AMT,
                                 W_CHGS_RECOV_AMT,
                                 W_INT_REV_AMT,
                                 W_CHG_REV_AMT);

            W_NPA_FROM_AMT      := W_BAL1 + W_NPA_BAL1;
            W_NPA_FROM_CNT      := 1;
        ELSE
            W_NPA_FROM_AMT      := 0;
        END IF;
  END GET_FROMDT_DETAILS;

  PROCEDURE MAIN_PROC IS
  BEGIN
    <<CALL_LEGAL_STATUS>>
      BEGIN
         SP_RLEGALSTATRPT(PKG_ENTITY.FN_GET_ENTITY_CODE,
                          W_BRN_CODE,
                          W_PROD_CODE,
                          TO_CHAR(W_CBD,'DD-MON-YYYY'),
                          TO_CHAR(W_UPTO_DATE,'DD-MON-YYYY'),
                          W_TEMP_SER,
                          W_ERR_MSG);

      END CALL_LEGAL_STATUS;

    W_SQL := 'SELECT A.ACNTS_BRN_CODE,A.ACNTS_INTERNAL_ACNUM,A.ACNTS_CURR_CODE,A.ACNTS_PROD_CODE,A.ACNTS_AC_NAME1,PRODUCT_NAME
             FROM ACNTS A,PRODUCTS WHERE A.ACNTS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
             AND (A.ACNTS_CLOSURE_DATE IS NULL OR A.ACNTS_CLOSURE_DATE > ' || CHR(39) || W_FROM_DATE || CHR(39) || ')
             AND A.ACNTS_PROD_CODE = PRODUCT_CODE AND PRODUCT_FOR_LOANS=''1''';
    IF W_BRN_CODE <> 0 THEN
      W_SQL := W_SQL || ' AND ACNTS_BRN_CODE = ' || W_BRN_CODE;
    END IF;

    IF W_PROD_CODE > 0 THEN
      W_SQL := W_SQL || ' AND ACNTS_PROD_CODE = ' || W_PROD_CODE;
    END IF;

    EXECUTE IMMEDIATE W_SQL BULK COLLECT INTO V_ACNUM_TAB;

    IF V_ACNUM_TAB.COUNT > 0 THEN
      FOR IDX IN V_ACNUM_TAB.FIRST .. V_ACNUM_TAB.LAST LOOP

        W_BRN_CODE := V_ACNUM_TAB(IDX).ACNTS_BRN_CODE;
        W_PROC_ACNUM := V_ACNUM_TAB(IDX).ACNTS_INTERNAL_ACNUM;
        W_CURR_CODE := V_ACNUM_TAB(IDX).ACNTS_CURR_CODE;
        W_PROD_CODE := V_ACNUM_TAB(IDX).ACNTS_PROD_CODE;
        W_ACNT_NAME := V_ACNUM_TAB(IDX).ACNTS_NAME;
        W_PROD_NAME := V_ACNUM_TAB(IDX).PRODUCT_NAME;

        W_NPA_FROM_AMT            := 0;
        W_NPA_UPTO_AMT            := 0;

        GET_FROMDT_DETAILS;
        GET_UPTODT_DETAILS;

        IF W_ASSET_CLASS = 'N' THEN
          SP_NPARECPERIOD(PKG_ENTITY.FN_GET_ENTITY_CODE,
                          W_PROC_ACNUM,
                          TO_CHAR(W_FROM_DATE,'DD-MON-YYYY'),
                          TO_CHAR(W_UPTO_DATE,'DD-MON-YYYY'),
                          V_ERR_MSG,
                          V_RECOV_AMT,
                          V_RECOV_SUSP_BAL,
                          V_INT_REV_AMT,
                          V_ADD_BAL,
                          V_ADD_SUSP_BAL);

          W_RECOVERY_AMT  := V_RECOV_AMT;
          W_SUSP_AMT      := V_RECOV_SUSP_BAL;

          READ_LEGAL_STATUS;
          UPDATE_TEMP_TABLE;
        END IF;
      END LOOP;
    END IF;
  END MAIN_PROC;
BEGIN
  PKG_ENTITY.SP_SET_ENTITY_CODE(V_ENTITY_NUM);

  W_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE(PKG_ENTITY.FN_GET_ENTITY_CODE);
  W_TEMP_SL := PKG_PB_GLOBAL.SP_GET_REPORT_SL(PKG_ENTITY.FN_GET_ENTITY_CODE);

  IF P_BRN_CODE IS NOT NULL THEN
    W_BRN_CODE := P_BRN_CODE;
  END IF;

  IF P_PROD_CODE IS NOT NULL THEN
    W_PROD_CODE := P_PROD_CODE;
  ELSE
    W_PROD_CODE           := 0;
  END IF;

  IF P_ASSET_CODE IS NOT NULL THEN
    --W_ASSET_CODE := P_ASSET_CODE;
    W_INP_ASTCD := P_ASSET_CODE;  
  END IF;

  IF P_FROM_DATE IS NULL THEN
    W_ERR_MSG := 'From Date Not Passed';
    RAISE MYEXCEPTION;
  ELSE
    W_FROM_DATE := P_FROM_DATE;
  END IF;

  IF P_UPTO_DATE IS NULL THEN
    W_ERR_MSG := 'Upto Date Not Passed';
    RAISE MYEXCEPTION;
  ELSE
    W_UPTO_DATE := P_UPTO_DATE;
  END IF;

  MAIN_PROC;

  IF W_TEMP_SER_FLG = 0 THEN
    P_TEMP_SL := W_TEMP_SL;
  ELSE
    P_TEMP_SL := 0;
  END IF;
  COMMIT;
  V_ACNUM_TAB.DELETE;

  EXCEPTION
    WHEN MYEXCEPTION THEN
      P_ERR_MSG := W_ERR_MSG;
      ROLLBACK;
      V_ACNUM_TAB.DELETE;
    WHEN OTHERS THEN
      W_ERR_MSG := SQLERRM;
      P_ERR_MSG := W_ERR_MSG;
    ROLLBACK;
    V_ACNUM_TAB.DELETE;

END SP_NPARECOVERY;
/