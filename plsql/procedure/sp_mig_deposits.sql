CREATE OR REPLACE PROCEDURE SP_MIG_DEPOSITS(P_BRANCH_CODE NUMBER,
                                            P_ERR_MSG     OUT VARCHAR2) IS

  /*
     Author:S.Rajalakshmi
     Date  :

     List of  Table/s Referred

     1. MIG_DEPOSITS
     2. MIG_TDSPIDTL
     3. MIG_RDINS
     4. MIG_TDSREMITGOV
     5. MIG_DEPIA -- RAJALAKSHMI  ADDED

     List of Tables Updated


     1. PBDCONTRACT
     2. ACNTCBAL
     3. ACNTCONTRACT
     4. ACNTBAL
     5. NOMREG
     6. DEPACCLIEN
     7. PBDCONTDSA
     8. PBDCONTTRFOD
     9. DEPRCPTPRNT
     10. RDINS
     11. TDSPIDTL
     12. DEPIA
     13. DEPCLS
     14. TDSPI   -- RAJALAKSHMI-ADDED
     15. TDSREMITGOV
     16.PBDCONTDSAHIST

     Modification History
     -----------------------------------------------------------------------------------------
     Sl.            Description                                    Mod By             Mod on
     -----------------------------------------------------------------------------------------
  */

  W_CURR_DATE       DATE;
  W_ENTD_BY         VARCHAR2(8) := 'MIG';
  W_CLIENT_NUM      VARCHAR2(14);
  W_BASE_CURR       VARCHAR2(3);
  W_DEP_ACNT_NUMBER NUMBER(14);
  W_DEFAULT         NUMBER(18, 3) := 0;
  W_SL              NUMBER(6) := 0;

  W_SRC_KEY               VARCHAR2(1000);
  W_ER_CODE               VARCHAR2(5);
  W_ER_DESC               VARCHAR2(1000);
  W_INT_CR_ACNT_NUMBER    NUMBER(14);
  W_CLOSURE_STL_AC_NUMBER NUMBER(14);
  W_LIEN_ACNT_NUMBER      NUMBER(14);
  W_DEPIA_DAYSL           NUMBER(10);
  W_TEMP_ACNTNUM          VARCHAR2(25);
  W_REMARKS               VARCHAR2(100);
  W_TMP                   VARCHAR2(1000);
  W_FIRST                 BOOLEAN;
  W_PREV_YEAR_INT         NUMBER(18, 3);
  W_UPDATE_PREV_INT       BOOLEAN;
  W_FINYEAR               NUMBER(4);
  W_ENTITY_NUM            NUMBER(3) := GET_OTN.ENTITY_NUMBER;

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

  FUNCTION CURRENCY_CALC(P_CURRENCY VARCHAR2, P_AMT NUMBER) RETURN NUMBER IS
    W_AC_AMT NUMBER(18, 3) := 0;
  BEGIN
    CASE
      WHEN P_CURRENCY = 'BDT' THEN
        W_AC_AMT := P_AMT / 68;
      WHEN P_CURRENCY = 'CHF' THEN
        W_AC_AMT := P_AMT / 30;
      WHEN P_CURRENCY = 'USD' THEN
        W_AC_AMT := P_AMT / 45;
      WHEN P_CURRENCY = 'CAD' THEN
        W_AC_AMT := P_AMT / 37;
      WHEN P_CURRENCY = 'AUD' THEN
        W_AC_AMT := P_AMT / 32;
      WHEN P_CURRENCY = 'EUR' THEN
        W_AC_AMT := P_AMT / 48;
    END CASE;
    RETURN W_AC_AMT;
  END CURRENCY_CALC;

  PROCEDURE FETCH_ACNUM(P_OLDAC      VARCHAR2,
                        O_ACNUM      OUT NUMBER,
                        PUT_ERR      VARCHAR2,
                        PUT_ERR_DESC VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE 'SELECT I.IACLINK_INTERNAL_ACNUM , I.IACLINK_CIF_NUMBER
  FROM IACLINK I
 WHERE IACLINK_ENTITY_NUM = :1 
   and I.IACLINK_BRN_CODE = :2
   AND I.IACLINK_ACTUAL_ACNUM = :3 '
      INTO O_ACNUM, W_CLIENT_NUM
      USING W_ENTITY_NUM, P_BRANCH_CODE, P_OLDAC;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      W_ER_CODE := PUT_ERR;
      W_ER_DESC := PUT_ERR_DESC || SQLERRM;
      W_SRC_KEY := P_BRANCH_CODE || '-' || P_OLDAC;
      POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      O_ACNUM := NULL;
  END FETCH_ACNUM;

BEGIN
  P_ERR_MSG   := '0';
  W_SL        := 1;
  W_BASE_CURR := 'BDT'; --shamsudeen-chn-24may2012-changed INR to BDT

  SELECT MN_CURR_BUSINESS_DATE INTO W_CURR_DATE FROM MAINCONT;
  --SELECT INS_BASE_CURR_CODE INTO W_BASE_CURR FROM INSTALL;

  FOR IDX IN (SELECT MIGDEP_BRN_CODE,
                     MIGDEP_DEP_AC_NUM,
                     MIGDEP_CONT_NUM,
                     MIGDEP_PROD_CODE,
                     MIGDEP_DEP_OPEN_DATE,
                     MIGDEP_EFF_DATE,
                     NVL(MIGDEP_DEP_CURR, W_BASE_CURR) MIGDEP_DEP_CURR,
                     MIGDEP_UNIT_AMT,
                     MIGDEP_AC_DEP_AMT,
                     MIGDEP_BC_DEP_AMT,
                     MIGDEP_DEP_UNITS,
                     MIGDEP_DEP_PRD_MONTHS,
                     MIGDEP_DEP_PRD_DAYS,
                     MIGDEP_MAT_DATE,
                     MIGDEP_STD_INT_RATE,
                     MIGDEP_ACTUAL_INT_RATE,
                     MIGDEP_MAT_VALUE,
                     MIGDEP_MAT_VALUE_PER_UNIT,
                     MIGDEP_INT_PAY_FREQ,
                     MIGDEP_DISC_INT_RATE,
                     MIGDEP_PERIODICAL_INT_AMT,
                     MIGDEP_RENEWAL,
                     MIGDEP_TRF_FROM_ANOTHER_BRN,
                     MIGDEP_TRF_FROM_BRN,
                     MIGDEP_TRF_DEP_AC_NUM,
                     MIGDEP_TRF_CONT_NUM,
                     MIGDEP_TOT_AMT_TRFD,
                     MIGDEP_INT_POR_OF_AMT_TRFD,
                     MIGDEP_IBR_ADV_NUM,
                     MIGDEP_IBR_ADV_DATE,
                     MIGDEP_IBR_TYPE_CODE,
                     MIGDEP_TRANSTLMNT_INV_NUM,
                     MIGDEP_AUTO_INT_PAYMENT,
                     MIGDEP_STLMNT_OPTION,
                     MIGDEP_RENEWAL_OPTION,
                     MIGDEP_NUM_AUTO_RENEWALS,
                     MIGDEP_INT_CR_TO_ACNT,
                     MIGDEP_DEP_DUE_NOTICE_REQD,
                     MIGDEP_FREQ_OF_DEP,
                     MIGDEP_NO_OF_INST,
                     MIGDEP_INST_PAY_OPTION,
                     MIGDEP_AUTO_INST_REC_REQD,
                     MIGDEP_INST_REC_FROM_AC,
                     MIGDEP_INST_REC_DAY,
                     MIGDEP_COLL_CODE,
                     MIGDEP_INT_ACCR_UPTO,
                     MIGDEP_CLOSURE_DATE,
                     MIGDEP_TRF_TO_OD_ON,
                     MIGDEP_INT_PAID_UPTO,
                     MIGDEP_COMPLETED_ROLLOVERS,
                     MIGDEP_EXCLUDE_DAY_FLAG,
                     MIGDEP_PER_INT_UNIT_AMT,
                     MIGDEP_BAL_DEP_UNITS,
                     MIGDEP_BAL_PER_UNIT,
                     MIGDEP_TOT_BAL_FOR_REM_UNITS,
                     MIGDEP_AC_INT_ACCR_AMT,
                     MIGDEP_BC_INT_ACCR_AMT,
                     MIGDEP_AC_INT_PAY_AMT,
                     MIGDEP_BC_INT_PAY_AMT,
                     MIGDEP_BK_DT_OP_REASON,
                     MIGDEP_INT_CALC_UPTO,
                     MIGDEP_INT_CALC_AMT,
                     MIGDEP_INT_CALC_AMT_PAYABLE,
                     MIGDEP_INT_CALC_PAYABLE_UPTO,
                     MIGDEP_CONT_AMT,
                     MIGDEP_INT_CR_AC_NUM, --
                     MIGDEP_CLOSURE_STL_AC_NUM, --
                     MIGDEP_LIEN_DATE,
                     MIGDEP_AC_LIEN_AMT,
                     MIGDEP_LIEN_TO_BRN,
                     MIGDEP_LIEN_TO_ACNUM, --
                     MIGDEP_TRF_ON,
                     MIGDEP_INT_BAL,
                     MIGDEP_AMT_TRF_OD,
                     MIGDEP_PREV_YEAR_INT,
                     MIGDEP_NOMINATION_REQD,
                     MIGDEP_REG_DATE,
                     MIGDEP_MANUAL_REF_NUM,
                     MIGDEP_CUST_LTR_REF_DATE,
                     MIGDEP_CUST_CODE,
                     MIGDEP_NOMINEE_NAME,
                     MIGDEP_DOB,
                     MIGDEP_GUAR_CUST_CODE,
                     MIGDEP_GUAR_CUST_NAME,
                     MIGDEP_NATURE_OF_GUAR,
                     MIGDEP_RELATIONSHIP,
                     MIGDEP_ADDR1,
                     MIGDEP_ADDR2,
                     MIGDEP_ADDR3,
                     MIGDEP_ADDR4,
                     MIGDEP_ADDR5,
                     MIGDEP_REMARKS,
                     MIGDEP_ENTD_BY,
                     MIGDEP_ENTD_ON,
                     MIGDEP_RECPT_NUM,
                     MIGDEP_PROV_CALC_ON,
                     MIGDEP_CURR_PROV_AMT
                FROM MIG_PBDCONTRACT MIG_DEPOSITS, ACNTOTN
               WHERE MIGDEP_BRN_CODE = P_BRANCH_CODE --AND MIGDEP_DEP_AC_NUM='0002-2925053816'
                 AND MIGDEP_DEP_AC_NUM = ACNTOTN_OLD_ACNT_NUM
                 AND ACNTOTN_INTERNAL_ACNUM NOT IN
                     (SELECT PBDCONTRACT.PBDCONT_DEP_AC_NUM FROM PBDCONTRACT)) LOOP

    FETCH_ACNUM(IDX.MIGDEP_DEP_AC_NUM,
                W_DEP_ACNT_NUMBER,
                'DEP1',
                'MIG_DEPOSITS GETOTN');
    /*
    DBMS_OUTPUT.PUT_LINE('PBDCONT_ENTITY_NUM, : '||W_ENTITY_NUM);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_BRN_CODE : '||P_BRANCH_CODE);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_DEP_AC_NUM : '||W_DEP_ACNT_NUMBER);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_CONT_NUM : '||IDX.MIGDEP_CONT_NUM);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_PROD_CODE : '||IDX.MIGDEP_PROD_CODE);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_DEP_OPEN_DATE : '||IDX.MIGDEP_DEP_OPEN_DATE);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_EFF_DATE : '||IDX.MIGDEP_EFF_DATE);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_DEP_CURR : '||NVL(IDX.MIGDEP_DEP_CURR ,W_BASE_CURR));
    DBMS_OUTPUT.PUT_LINE('PBDCONT_UNIT_AMT : '||IDX.MIGDEP_UNIT_AMT);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_AC_DEP_AMT : '||IDX.MIGDEP_AC_DEP_AMT);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_BC_DEP_AMT : '||IDX.MIGDEP_BC_DEP_AMT);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_DEP_UNITS : '||IDX.MIGDEP_DEP_UNITS);
    DBMS_OUTPUT.PUT_LINE('PDBCONT_DEP_PRD_MONTHS : '||IDX.MIGDEP_DEP_PRD_MONTHS);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_DEP_PRD_DAYS : '||IDX.MIGDEP_DEP_PRD_DAYS);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_MAT_DATE : '||IDX.MIGDEP_MAT_DATE);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_STD_INT_RATE : '||IDX.MIGDEP_STD_INT_RATE);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_ACTUAL_INT_RATE : '||IDX.MIGDEP_ACTUAL_INT_RATE);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_MAT_VALUE : '||IDX.MIGDEP_MAT_VALUE);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_MAT_VALUE_PER_UNIT : '||IDX.MIGDEP_MAT_VALUE_PER_UNIT);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_INT_PAY_FREQ : '||IDX.MIGDEP_INT_PAY_FREQ);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_DISC_INT_RATE : '||IDX.MIGDEP_DISC_INT_RATE);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_PERIODICAL_INT_AMT : '||IDX.MIGDEP_PERIODICAL_INT_AMT);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_RENEWAL : '||IDX.MIGDEP_RENEWAL);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_TRF_FROM_ANOTHER_BRN : '||IDX.MIGDEP_TRF_FROM_ANOTHER_BRN);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_TRF_FROM_BRN : '||IDX.MIGDEP_TRF_FROM_BRN);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_TRF_DEP_AC_NUM : '||IDX.MIGDEP_TRF_DEP_AC_NUM);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_TRF_CONT_NUM : '||IDX.MIGDEP_TRF_CONT_NUM);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_TOT_AMT_TRFD : '||IDX.MIGDEP_TOT_AMT_TRFD);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_INT_POR_OF_AMT_TRFD : '||IDX.MIGDEP_INT_POR_OF_AMT_TRFD);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_IBR_ADV_NUM : '||IDX.MIGDEP_IBR_ADV_NUM);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_IBR_ADV_DATE : '||IDX.MIGDEP_IBR_ADV_DATE);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_IBR_TYPE_CODE : '||IDX.MIGDEP_IBR_TYPE_CODE);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_TRANSTLMNT_INV_NUM : '||IDX.MIGDEP_TRANSTLMNT_INV_NUM);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_AUTO_INT_PAYMENT : '||IDX.MIGDEP_AUTO_INT_PAYMENT);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_STLMNT_OPTION : '||IDX.MIGDEP_STLMNT_OPTION);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_RENEWAL_OPTION : '||IDX.MIGDEP_RENEWAL_OPTION);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_NUM_AUTO_RENEWALS : '||IDX.MIGDEP_NUM_AUTO_RENEWALS);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_INT_CR_TO_ACNT : '||IDX.MIGDEP_INT_CR_TO_ACNT);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_DEP_DUE_NOTICE_REQD : '||IDX.MIGDEP_DEP_DUE_NOTICE_REQD);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_FREQ_OF_DEP : '||IDX.MIGDEP_FREQ_OF_DEP);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_NO_OF_INST : '||IDX.MIGDEP_NO_OF_INST);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_INST_PAY_OPTION : '||IDX.MIGDEP_INST_PAY_OPTION);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_AUTO_INST_REC_REQD : '||IDX.MIGDEP_AUTO_INST_REC_REQD);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_INST_REC_FROM_AC : '||IDX.MIGDEP_INST_REC_FROM_AC);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_INST_REC_DAY : '||IDX.MIGDEP_INST_REC_DAY);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_COLL_CODE : '||IDX.MIGDEP_COLL_CODE);
    DBMS_OUTPUT.PUT_LINE('POST_TRAN_BRN : '||NULL);
    DBMS_OUTPUT.PUT_LINE('POST_TRAN_DATE : '||NULL);
    DBMS_OUTPUT.PUT_LINE('POST_TRAN_BATCH_NUM : '||NULL);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_INT_ACCR_UPTO : '||IDX.MIGDEP_INT_ACCR_UPTO);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_CLOSURE_DATE : '||IDX.MIGDEP_CLOSURE_DATE);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_TRF_TO_OD_ON : '||IDX.MIGDEP_TRF_TO_OD_ON);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_INT_PAID_UPTO : '||IDX.MIGDEP_INT_PAID_UPTO);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_COMPLETED_ROLLOVERS : '||IDX.MIGDEP_COMPLETED_ROLLOVERS);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_EXCLUDE_DAY_FLAG : '||IDX.MIGDEP_EXCLUDE_DAY_FLAG);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_PER_INT_UNIT_AMT : '||IDX.MIGDEP_PER_INT_UNIT_AMT);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_BAL_DEP_UNITS : '||IDX.MIGDEP_BAL_DEP_UNITS);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_BAL_PER_UNIT : '||IDX.MIGDEP_BAL_PER_UNIT);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_TOT_BAL_FOR_REM_UNITS : '||IDX.MIGDEP_TOT_BAL_FOR_REM_UNITS);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_AC_INT_ACCR_AMT : '||IDX.MIGDEP_AC_INT_ACCR_AMT);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_BC_INT_ACCR_AMT : '||IDX.MIGDEP_BC_INT_ACCR_AMT);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_AC_INT_PAY_AMT : '||IDX.MIGDEP_AC_INT_PAY_AMT);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_BC_INT_PAY_AMT : '||IDX.MIGDEP_BC_INT_PAY_AMT);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_REMARKS1 : '||NULL);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_REMARKS2 : '||NULL);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_REMARKS3 : '||IDX.MIGDEP_RECPT_NUM );
    DBMS_OUTPUT.PUT_LINE('PBDCONT_BK_DT_OP_REASON : '||IDX.MIGDEP_BK_DT_OP_REASON);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_ENTD_BY : '||W_ENTD_BY);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_ENTD_ON : '||W_CURR_DATE);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_LAST_MOD_BY : '||NULL);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_LAST_MOD_ON : '||NULL);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_AUTH_BY : '||W_ENTD_BY);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_AUTH_ON : '||W_CURR_DATE);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_REJ_BY : '||NULL);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_REJ_ON : '||NULL);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_INT_CALC_UPTO : '||IDX.MIGDEP_INT_CALC_UPTO);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_INT_CALC_AMT : '||IDX.MIGDEP_INT_CALC_AMT);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_INT_CALC_AMT_PAYABLE : '||IDX.MIGDEP_INT_CALC_AMT_PAYABLE);
    DBMS_OUTPUT.PUT_LINE('PBDCONT_INT_CALC_PAYABLE_UPTO : '||IDX.MIGDEP_INT_CALC_PAYABLE_UPTO);
    */

    <<IN_PBDCONTRACT>>
    BEGIN
      INSERT INTO PBDCONTRACT
        (PBDCONT_ENTITY_NUM,
         PBDCONT_BRN_CODE,
         PBDCONT_DEP_AC_NUM,
         PBDCONT_CONT_NUM,
         PBDCONT_PROD_CODE,
         PBDCONT_DEP_OPEN_DATE,
         PBDCONT_EFF_DATE,
         PBDCONT_DEP_CURR,
         PBDCONT_UNIT_AMT,
         PBDCONT_AC_DEP_AMT,
         PBDCONT_BC_DEP_AMT,
         PBDCONT_DEP_UNITS,
         PDBCONT_DEP_PRD_MONTHS,
         PBDCONT_DEP_PRD_DAYS,
         PBDCONT_MAT_DATE,
         PBDCONT_STD_INT_RATE,
         PBDCONT_ACTUAL_INT_RATE,
         PBDCONT_MAT_VALUE,
         PBDCONT_MAT_VALUE_PER_UNIT,
         PBDCONT_INT_PAY_FREQ,
         PBDCONT_DISC_INT_RATE,
         PBDCONT_PERIODICAL_INT_AMT,
         PBDCONT_RENEWAL,
         PBDCONT_TRF_FROM_ANOTHER_BRN,
         PBDCONT_TRF_FROM_BRN,
         PBDCONT_TRF_DEP_AC_NUM,
         PBDCONT_TRF_CONT_NUM,
         PBDCONT_TOT_AMT_TRFD,
         PBDCONT_INT_POR_OF_AMT_TRFD,
         PBDCONT_IBR_ADV_NUM,
         PBDCONT_IBR_ADV_DATE,
         PBDCONT_IBR_TYPE_CODE,
         PBDCONT_TRANSTLMNT_INV_NUM,
         PBDCONT_AUTO_INT_PAYMENT,
         PBDCONT_STLMNT_OPTION,
         PBDCONT_RENEWAL_OPTION,
         PBDCONT_NUM_AUTO_RENEWALS,
         PBDCONT_INT_CR_TO_ACNT,
         PBDCONT_DEP_DUE_NOTICE_REQD,
         PBDCONT_FREQ_OF_DEP,
         PBDCONT_NO_OF_INST,
         PBDCONT_INST_PAY_OPTION,
         PBDCONT_AUTO_INST_REC_REQD,
         PBDCONT_INST_REC_FROM_AC,
         PBDCONT_INST_REC_DAY,
         PBDCONT_COLL_CODE,
         POST_TRAN_BRN,
         POST_TRAN_DATE,
         POST_TRAN_BATCH_NUM,
         PBDCONT_INT_ACCR_UPTO,
         PBDCONT_CLOSURE_DATE,
         PBDCONT_TRF_TO_OD_ON,
         PBDCONT_INT_PAID_UPTO,
         PBDCONT_COMPLETED_ROLLOVERS,
         PBDCONT_EXCLUDE_DAY_FLAG,
         PBDCONT_PER_INT_UNIT_AMT,
         PBDCONT_BAL_DEP_UNITS,
         PBDCONT_BAL_PER_UNIT,
         PBDCONT_TOT_BAL_FOR_REM_UNITS,
         PBDCONT_AC_INT_ACCR_AMT,
         PBDCONT_BC_INT_ACCR_AMT,
         PBDCONT_AC_INT_PAY_AMT,
         PBDCONT_BC_INT_PAY_AMT,
         PBDCONT_REMARKS1,
         PBDCONT_REMARKS2,
         PBDCONT_REMARKS3,
         PBDCONT_BK_DT_OP_REASON,
         PBDCONT_ENTD_BY,
         PBDCONT_ENTD_ON,
         PBDCONT_LAST_MOD_BY,
         PBDCONT_LAST_MOD_ON,
         PBDCONT_AUTH_BY,
         PBDCONT_AUTH_ON,
         PBDCONT_REJ_BY,
         PBDCONT_REJ_ON,
         PBDCONT_INT_CALC_UPTO,
         PBDCONT_INT_CALC_AMT,
         PBDCONT_INT_CALC_AMT_PAYABLE,
         PBDCONT_INT_CALC_PAYABLE_UPTO)
      VALUES
        (W_ENTITY_NUM,
         P_BRANCH_CODE,
         W_DEP_ACNT_NUMBER,
         IDX.MIGDEP_CONT_NUM,
         IDX.MIGDEP_PROD_CODE,
         IDX.MIGDEP_DEP_OPEN_DATE,
         IDX.MIGDEP_EFF_DATE,
         NVL(IDX.MIGDEP_DEP_CURR, W_BASE_CURR),
         IDX.MIGDEP_UNIT_AMT,
         IDX.MIGDEP_AC_DEP_AMT,
         IDX.MIGDEP_BC_DEP_AMT,
         IDX.MIGDEP_DEP_UNITS,
         IDX.MIGDEP_DEP_PRD_MONTHS,
         IDX.MIGDEP_DEP_PRD_DAYS,
         IDX.MIGDEP_MAT_DATE,
         IDX.MIGDEP_STD_INT_RATE,
         IDX.MIGDEP_ACTUAL_INT_RATE,
         IDX.MIGDEP_MAT_VALUE,
         IDX.MIGDEP_MAT_VALUE_PER_UNIT,
         IDX.MIGDEP_INT_PAY_FREQ,
         IDX.MIGDEP_DISC_INT_RATE,
         IDX.MIGDEP_PERIODICAL_INT_AMT,
         IDX.MIGDEP_RENEWAL,
         IDX.MIGDEP_TRF_FROM_ANOTHER_BRN,
         IDX.MIGDEP_TRF_FROM_BRN,
         IDX.MIGDEP_TRF_DEP_AC_NUM,
         IDX.MIGDEP_TRF_CONT_NUM,
         IDX.MIGDEP_TOT_AMT_TRFD,
         IDX.MIGDEP_INT_POR_OF_AMT_TRFD,
         IDX.MIGDEP_IBR_ADV_NUM,
         IDX.MIGDEP_IBR_ADV_DATE,
         IDX.MIGDEP_IBR_TYPE_CODE,
         IDX.MIGDEP_TRANSTLMNT_INV_NUM,
         IDX.MIGDEP_AUTO_INT_PAYMENT,
         IDX.MIGDEP_STLMNT_OPTION,
         IDX.MIGDEP_RENEWAL_OPTION,
         IDX.MIGDEP_NUM_AUTO_RENEWALS,
         IDX.MIGDEP_INT_CR_TO_ACNT,
         IDX.MIGDEP_DEP_DUE_NOTICE_REQD,
         IDX.MIGDEP_FREQ_OF_DEP,
         IDX.MIGDEP_NO_OF_INST,
         IDX.MIGDEP_INST_PAY_OPTION,
         IDX.MIGDEP_AUTO_INST_REC_REQD,
         0, --IDX.MIGDEP_INST_REC_FROM_AC, --Ramesh M
         IDX.MIGDEP_INST_REC_DAY,
         IDX.MIGDEP_COLL_CODE,
         NULL,
         NULL,
         NULL,
         IDX.MIGDEP_INT_ACCR_UPTO,
         IDX.MIGDEP_CLOSURE_DATE,
         IDX.MIGDEP_TRF_TO_OD_ON,
         IDX.MIGDEP_INT_PAID_UPTO,
         IDX.MIGDEP_COMPLETED_ROLLOVERS,
         IDX.MIGDEP_EXCLUDE_DAY_FLAG,
         IDX.MIGDEP_PER_INT_UNIT_AMT,
         IDX.MIGDEP_BAL_DEP_UNITS,
         IDX.MIGDEP_BAL_PER_UNIT,
         IDX.MIGDEP_TOT_BAL_FOR_REM_UNITS,
         IDX.MIGDEP_AC_INT_ACCR_AMT,
         IDX.MIGDEP_BC_INT_ACCR_AMT,
         IDX.MIGDEP_AC_INT_PAY_AMT,
         IDX.MIGDEP_BC_INT_PAY_AMT,
         NULL,
         NULL,
         IDX.MIGDEP_RECPT_NUM, --NULL,
         IDX.MIGDEP_BK_DT_OP_REASON,
         W_ENTD_BY,
         W_CURR_DATE,
         NULL,
         NULL,
         W_ENTD_BY,
         W_CURR_DATE,
         NULL,
         NULL,
         IDX.MIGDEP_INT_CALC_UPTO,
         IDX.MIGDEP_INT_CALC_AMT,
         IDX.MIGDEP_INT_CALC_AMT_PAYABLE,
         IDX.MIGDEP_INT_CALC_PAYABLE_UPTO);
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'DEP2';
        W_ER_DESC := 'SP_DEPOSITS-INSERT-PBDCONTRACT' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     IDX.MIGDEP_DEP_AC_NUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_PBDCONTRACT;

    IF IDX.MIGDEP_CONT_NUM > 0 THEN

      <<IN_ACNTCBAL>>
      BEGIN
        EXECUTE IMMEDIATE 'INSERT INTO ACNTCBAL
          (ACNTCBAL_ENTITY_NUM,ACNTCBAL_INTERNAL_ACNUM,
           ACNTCBAL_CURR_CODE,
           ACNTCBAL_CONTRACT_NUM,
           ACNTCBAL_AC_CUR_DB_SUM,
           ACNTCBAL_AC_CUR_CR_SUM,
           ACNTCBAL_BC_CUR_DB_SUM,
           ACNTCBAL_BC_CUR_CR_SUM,
           ACNTCBAL_AC_BAL,
           ACNTCBAL_BC_BAL,
           ACNTCBAL_AC_UNAUTH_CR_SUM,
           ACNTCBAL_AC_UNAUTH_DB_SUM,
           ACNTCBAL_BC_UNAUTH_CR_SUM,
           ACNTCBAL_BC_UNAUTH_DB_SUM,
           ACNTCBAL_AC_FWDVAL_CR_SUM,
           ACNTCBAL_AC_FWDVAL_DB_SUM,
           ACNTCBAL_BC_FWDVAL_CR_SUM,
           ACNTCBAL_BC_FWDVAL_DB_SUM,
           ACNTCBAL_AC_LIEN_AMT,
           ACNTCBAL_BC_LIEN_AMT,
           ACNTCBAL_AC_AMT_ON_HOLD,
           ACNTCBAL_BC_AMT_ON_HOLD,
           ACNTCBAL_AC_DB_QUEUE_AMT,
           ACNTCBAL_BC_DB_QUEUE_AMT,
           ACNTCBAL_AC_CLG_CR_SUM,
           ACNTCBAL_AC_CLG_DB_SUM,
           ACNTCBAL_BC_CLG_CR_SUM,
           ACNTCBAL_BC_CLG_DB_SUM)
        VALUES
          (:1,
           :2,
           :3,
           :4,
           :5,
           :6,
           :7,
           :8,
           :9,
           :10,
           :11,
           :12,
           :13,
           :14,
           :15,
           :16,
           :17,
           :18,
           :19,
           :20,
           :21,
           :22,
           :23,
           :24,
           :25,
           :26,
           :27,:28)'
          USING W_ENTITY_NUM, W_DEP_ACNT_NUMBER, IDX.MIGDEP_DEP_CURR, IDX.MIGDEP_CONT_NUM, W_DEFAULT, W_DEFAULT, W_DEFAULT, W_DEFAULT, W_DEFAULT, W_DEFAULT, W_DEFAULT, W_DEFAULT, W_DEFAULT, W_DEFAULT, W_DEFAULT, W_DEFAULT, W_DEFAULT, W_DEFAULT, W_DEFAULT, W_DEFAULT, W_DEFAULT, W_DEFAULT, W_DEFAULT, W_DEFAULT, W_DEFAULT, W_DEFAULT, W_DEFAULT, W_DEFAULT;
      EXCEPTION
        WHEN OTHERS THEN
          W_ER_CODE := 'DEP3';
          W_ER_DESC := 'SP_DEPOSITS-INSERT-ACNTCBAL' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                       IDX.MIGDEP_DEP_AC_NUM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END IN_ACNTCBAL;

      <<IN_ACNTCONTRACT>>
      BEGIN
        INSERT INTO ACNTCONTRACT
          (ACONT_ENTITY_NUM,
           ACONT_ACNT_NUM,
           ACONT_CONTRACT_SL,
           ACONT_OPENED_DATE,
           ACONT_CLOSED_DATE,
           ACONT_CONT_CURR,
           ACONT_CONT_AMT,
           ACONT_CONT_BC_AMT,
           ACONT_SOURCE_TABLE,
           ACONT_SOURCE_KEY,
           ACONT_EXT_REF_NUM,
           ACONT_PGM_ID)
        VALUES
          (W_ENTITY_NUM,
           W_DEP_ACNT_NUMBER,
           IDX.MIGDEP_CONT_NUM,
           IDX.MIGDEP_DEP_OPEN_DATE,
           NULL,
           IDX.MIGDEP_DEP_CURR,
           IDX.MIGDEP_AC_DEP_AMT,
           IDX.MIGDEP_BC_DEP_AMT,
           NULL,
           NULL,
           NULL,
           NULL);
      EXCEPTION
        WHEN OTHERS THEN
          W_ER_CODE := 'DEP4';
          W_ER_DESC := 'SP_DEPOSITS-INSERT-ACNTCONTRACT' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                       IDX.MIGDEP_DEP_AC_NUM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END IN_ACNTCONTRACT;
    END IF;

    IF IDX.MIGDEP_NOMINATION_REQD = 'Y' THEN
      <<IN_NOMREG>>
      BEGIN
        /* -- This table is updation in Nomination details migration commented by Ramesh M on 31-dec-13
        INSERT INTO NOMREG
          (NOMREG_ENTITY_NUM,
           NOMREG_AC_NUM,
           NOMREG_CONT_NUM,
           NOMREG_REG_YEAR,
           NOMREG_REG_SL,
           NOMREG_REG_DATE,
           NOMREG_MANUAL_REF_NUM,
           NOMREG_CUST_LTR_REF_DATE,
           NOMREG_CUST_CODE,
           NOMREG_NOMINEE_NAME,
           NOMREG_DOB,
           NOMREG_GUAR_CUST_CODE,
           NOMREG_GUAR_CUST_NAME,
           NOMREG_NATURE_OF_GUAR,
           NOMREG_RELATIONSHIP,
           NOMREG_ADDR1,
           NOMREG_ADDR2,
           NOMREG_ADDR3,
           NOMREG_ADDR4,
           NOMREG_ADDR5,
           NOMREG_ENTD_BY,
           NOMREG_ENTD_ON,
           NOMREG_LAST_MOD_BY,
           NOMREG_LAST_MOD_ON,
           NOMREG_AUTH_BY,
           NOMREG_AUTH_ON,
           NOMREG_CANC_ON,
           TBA_MAIN_KEY)
        VALUES
          (W_ENTITY_NUM,
           W_DEP_ACNT_NUMBER,
           IDX.MIGDEP_CONT_NUM,
           GETFINYEAR(W_CURR_DATE),
           W_SL,
           IDX.MIGDEP_REG_DATE,
           IDX.MIGDEP_MANUAL_REF_NUM,
           IDX.MIGDEP_CUST_LTR_REF_DATE,
           IDX.MIGDEP_CUST_CODE,
           IDX.MIGDEP_NOMINEE_NAME,
           IDX.MIGDEP_DOB,
           IDX.MIGDEP_GUAR_CUST_CODE,
           IDX.MIGDEP_GUAR_CUST_NAME,
           IDX.MIGDEP_NATURE_OF_GUAR,
           IDX.MIGDEP_RELATIONSHIP,
           IDX.MIGDEP_ADDR1,
           IDX.MIGDEP_ADDR2,
           IDX.MIGDEP_ADDR3,
           IDX.MIGDEP_ADDR4,
           IDX.MIGDEP_ADDR5,
           W_ENTD_BY,
           W_CURR_DATE,
           NULL,
           NULL,
           W_ENTD_BY,
           W_CURR_DATE,
           NULL,
           NULL);
		   */
		   NULL;


      EXCEPTION
        WHEN OTHERS THEN
          W_ER_CODE := 'DEP6';
          W_ER_DESC := 'SP_DEPOSITS-INSERT-NOMREG' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                       IDX.MIGDEP_DEP_AC_NUM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END IN_NOMREG;

    END IF;

    IF IDX.MIGDEP_LIEN_DATE IS NOT NULL THEN
      W_REMARKS := NULL;
      IF SUBSTR(IDX.MIGDEP_LIEN_TO_ACNUM, 6) <> '39009' AND
         SUBSTR(IDX.MIGDEP_LIEN_TO_ACNUM, 6) <> '51011' THEN
        FETCH_ACNUM(IDX.MIGDEP_LIEN_TO_ACNUM,
                    W_LIEN_ACNT_NUMBER,
                    'DEP20',
                    'MIG_DEPOSITS GETOTN');
      ELSE
        W_REMARKS              := 'HEAD OFFICE 39009';
        W_LIEN_ACNT_NUMBER     := 0;
        IDX.MIGDEP_LIEN_TO_BRN := 100;
      END IF;

      IF W_LIEN_ACNT_NUMBER IS NOT NULL THEN
        <<IN_DEPACCLIEN>>
        BEGIN
          INSERT INTO DEPACCLIEN
            (DEPACLIEN_ENTITY_NUM,
             DEPACLIEN_BRN_CODE,
             DEPACLIEN_DEP_AC_NUM,
             DEPACLIEN_CONT_NUM,
             DEPACLIEN_LIEN_SL,
             DEPACLIEN_LIEN_DATE,
             DEPACLIEN_AC_LIEN_AMT,
             DEPACLIEN_LIEN_TO_BRN,
             DEPACLIEN_LIEN_TO_ACNUM,
             DEPACLIEN_REASON1,
             DEPACLIEN_REASON2,
             DEPACLIEN_REASON3,
             DEPACLIEN_REASON4,
             DEPACLIEN_REVOKED_ON,
             DEPACLIEN_SOURCE_TABLE,
             DEPACLIEN_SOURCE_KEY,
             DEPACLIEN_ENTD_BY,
             DEPACLIEN_ENTD_ON,
             DEPACLIEN_LAST_MOD_BY,
             DEPACLIEN_LAST_MOD_ON,
             DEPACLIEN_AUTH_BY,
             DEPACLIEN_AUTH_ON,
             TBA_MAIN_KEY)
          VALUES
            (W_ENTITY_NUM,
             P_BRANCH_CODE,
             W_DEP_ACNT_NUMBER,
             IDX.MIGDEP_CONT_NUM,
             W_SL,
             IDX.MIGDEP_LIEN_DATE,
             IDX.MIGDEP_AC_LIEN_AMT,
             IDX.MIGDEP_LIEN_TO_BRN,
             W_LIEN_ACNT_NUMBER,
             W_REMARKS,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             W_ENTD_BY,
             W_CURR_DATE,
             NULL,
             NULL,
             W_ENTD_BY,
             W_CURR_DATE,
             NULL);
        EXCEPTION
          WHEN OTHERS THEN
            W_ER_CODE := 'DEP7';
            W_ER_DESC := 'SP_DEPOSITS-INSERT-DEPACCLIEN' || SQLERRM;
            W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                         IDX.MIGDEP_DEP_AC_NUM;
            POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
        END IN_DEPACCLIEN;
      END IF;
    END IF;

    IF NVL(IDX.MIGDEP_INT_CR_AC_NUM, '0') <> '00000' AND
       NVL(IDX.MIGDEP_INT_CR_AC_NUM, '0') <> '0' THEN
      FETCH_ACNUM(IDX.MIGDEP_INT_CR_AC_NUM,
                  W_INT_CR_ACNT_NUMBER,
                  'DEP18',
                  'INT_CR_AC_NUM GETOTN');
    ELSE
      W_INT_CR_ACNT_NUMBER := NULL;
    END IF;

    IF NVL(IDX.MIGDEP_CLOSURE_STL_AC_NUM, 0) <> 0 THEN
      FETCH_ACNUM(IDX.MIGDEP_CLOSURE_STL_AC_NUM,
                  W_CLOSURE_STL_AC_NUMBER,
                  'DEP19',
                  'CLOSURE_STL_AC_NUM GETOTN');
    ELSE
      W_CLOSURE_STL_AC_NUMBER := NULL;
    END IF;

    IF W_INT_CR_ACNT_NUMBER IS NOT NULL OR
       W_CLOSURE_STL_AC_NUMBER IS NOT NULL THEN
      <<IN_PBDCONTDSA>>
      BEGIN
        INSERT INTO PBDCONTDSA
          (PBDCONTDSA_ENTITY_NUM,
           PBDCONTDSA_DEP_AC_NUM,
           PBDCONTDSA_CONT_NUM,
           PBDCONTDSA_LATEST_EFF_DATE,
           PBDCONTDSA_INT_CR_AC_NUM,
           PBDCONTDSA_CLOSURE_STL_AC_NUM,
           PBDCONTDSA_STLMNT_CHOICE)
        VALUES
          (W_ENTITY_NUM,
           W_DEP_ACNT_NUMBER,
           IDX.MIGDEP_CONT_NUM,
           IDX.MIGDEP_DEP_OPEN_DATE,
           NVL(W_INT_CR_ACNT_NUMBER, 0),
           NVL(W_CLOSURE_STL_AC_NUMBER, 0),
           'A');
      EXCEPTION
        WHEN OTHERS THEN
          W_ER_CODE := 'DEP8';
          W_ER_DESC := 'SP_DEPOSITS-INSERT-PBDCONTDSA' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                       IDX.MIGDEP_DEP_AC_NUM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END IN_PBDCONTDSA;
    END IF;

    IF IDX.MIGDEP_TRF_TO_OD_ON IS NOT NULL THEN

      <<IN_PBDCONTTRFOD>>
      BEGIN
        INSERT INTO PBDCONTTRFOD
          (PBDOD_ENTITY_NUM,
           PBDOD_BRN_CODE,
           PBDOD_DEP_AC_NUM,
           PBDOD_CONT_NUM,
           PBDOD_TRF_ON,
           PBDOD_DEP_AMT,
           PBDOD_INT_BAL,
           PBDOD_AMT_TRF_OD,
           PBDOD_ENTD_BY,
           PBDOD_ENTD_ON,
           POST_TRAN_BRN,
           POST_TRAN_DATE,
           POST_TRAN_BATCH_NUM,
           PBDOD_PROV_CALC_ON,
           PBDOD_PREV_PROV_AMT,
           PBDOD_CURR_PROV_AMT)
        VALUES
          (W_ENTITY_NUM,
           P_BRANCH_CODE,
           W_DEP_ACNT_NUMBER,
           IDX.MIGDEP_CONT_NUM,
           IDX.MIGDEP_TRF_TO_OD_ON,
           IDX.MIGDEP_BC_DEP_AMT,
           IDX.MIGDEP_INT_BAL,
           IDX.MIGDEP_AMT_TRF_OD,
           W_ENTD_BY,
           W_CURR_DATE,
           NULL,
           NULL,
           NULL,
           IDX.MIGDEP_PROV_CALC_ON,
           NULL,
           IDX.MIGDEP_CURR_PROV_AMT);
      EXCEPTION
        WHEN OTHERS THEN
          W_ER_CODE := 'DEP9';
          W_ER_DESC := 'SP_DEPOSITS-INSERT-PBDCONTTRFOD' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                       IDX.MIGDEP_DEP_AC_NUM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END IN_PBDCONTTRFOD;
    END IF;

    -- S.RAJALAKSHMI-19-OCT-2009-BEGIN

    IF IDX.MIGDEP_CLOSURE_DATE IS NOT NULL AND
       IDX.MIGDEP_CLOSURE_DATE >= '01-APR-2009' THEN

      <<IN_DEPCLS>>
      BEGIN
        INSERT INTO DEPCLS
          (DEPCLS_ENTITY_NUM,
           DEPCLS_BRN_CODE,
           DEPCLS_DEP_AC_NUM,
           DEPCLS_CONT_NUM,
           DEPCLS_CLOSURE_DATE,
           DEPCLS_TYPE_OF_CLOSURE,
           DEPCLS_RUN_PRD_MNTHS,
           DEPCLS_RUN_PRD_DAYS,
           DEPCLS_PREMAT_INT_RATE,
           DEPCLS_PENAL_INT_WAIVED,
           DEPCLS_PENAL_WAIV_REASON,
           DEPCLS_PENAL_INT_RATE,
           DEPCLS_OD_PRD_DAYS,
           DEPCLS_OD_INT_RATE,
           DEPCLS_OD_INT_AMT,
           DEPCLS_TOT_INT_AMT,
           DEPCLS_TDS_AMT,
           DEPCLS_SURCHARGE_AMT,
           DEPCLS_NET_AMT,
           DEPCLS_RENEW_TRF,
           DEPCLS_TRF_TO_BRN,
           DEPCLS_TRF_IBR_CODE,
           DEPCLS_AMT_FOR_RENEWAL,
           DEPCLS_TRANSTLMNT_INV_NUM,
           DEPCLS_REMARKS1,
           DEPCLS_REMARKS2,
           DEPCLS_REMARKS3,
           POST_TRAN_BRN,
           POST_TRAN_DATE,
           POST_TRAN_BATCH_NUM,
           DEPCLS_ENTD_BY,
           DEPCLS_ENTD_ON,
           DEPCLS_LAST_MOD_BY,
           DEPCLS_LAST_MOD_ON,
           DEPCLS_AUTH_BY,
           DEPCLS_AUTH_ON,
           DEPCLS_REJ_BY,
           DEPCLS_REJ_ON)
        VALUES
          (W_ENTITY_NUM,
           P_BRANCH_CODE,
           W_DEP_ACNT_NUMBER,
           IDX.MIGDEP_CONT_NUM,
           IDX.MIGDEP_CLOSURE_DATE,
           NULL,
           IDX.MIGDEP_DEP_PRD_MONTHS,
           IDX.MIGDEP_DEP_PRD_DAYS,
           NULL,
           NULL,
           NULL,
           NULL,
           IDX.MIGDEP_DEP_PRD_DAYS,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           IDX.MIGDEP_IBR_TYPE_CODE,
           NULL,
           IDX.MIGDEP_TRANSTLMNT_INV_NUM,
           IDX.MIGDEP_REMARKS,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           W_ENTD_BY,
           W_CURR_DATE,
           NULL,
           NULL,
           W_ENTD_BY,
           W_CURR_DATE,
           NULL,
           NULL);
      EXCEPTION
        WHEN OTHERS THEN
          W_ER_CODE := 'DEP18';
          W_ER_DESC := 'SP_DEPOSITS-INSERT-DEPCLS' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                       IDX.MIGDEP_DEP_AC_NUM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);

      END IN_DEPCLS;
    END IF;
    -- S.RAJALAKSHMI-19-OCT-2009-END

  /*
                                                                                      <<IN_DEPRCPTPRNT>>
                                                                                      BEGIN
                                                                                        INSERT INTO DEPRCPTPRNT
                                                                                          (DEPRCPTPRNT_BRN_CODE,
                                                                                           DEPRCPTPRNT_INTERNAL_AC_NUM,
                                                                                           DEPRCPT_CONT_NUM,
                                                                                           DEPRCPT_PRINT_DATE,
                                                                                           DEPRCPT_RECPT_NUM,
                                                                                           DEPRCPT_DUP_PRINT,
                                                                                           DEPRCPT_DUP_PRINT_ON,
                                                                                           DEPRCPT_DUP_RECPT_NUM)
                                                                                        VALUES
                                                                                          (P_BRANCH_CODE,
                                                                                           W_DEP_ACNT_NUMBER,
                                                                                           IDX.MIGDEP_CONT_NUM,
                                                                                           W_CURR_DATE,
                                                                                           IDX.MIGDEP_RECPT_NUM, -- IDX.MIGDEP_RECPT_NUM,
                                                                                           'N',
                                                                                           NULL,
                                                                                           NULL);
                                                                                      EXCEPTION
                                                                                        WHEN OTHERS THEN
                                                                                          W_ER_CODE := 'DEP10';
                                                                                          W_ER_DESC := 'SP_DEPOSITS-INSERT-DEPRCPTPRNT' || SQLERRM;
                                                                                          W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                                                                                                       IDX.MIGDEP_DEP_AC_NUM;
                                                                                          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
                                                                                      END IN_DEPRCPTPRNT;
                                                                                    */
  END LOOP;

  W_FIRST := TRUE;
  FOR ADX IN (SELECT RDINS_RD_AC_NUM,
                     RDINS_ENTRY_DATE,
                     RDINS_ENTRY_DAY_SL,
                     RDINS_EFF_DATE,
                     RDINS_AMT_OF_PYMT,
                     RDINS_TWDS_INSTLMNT,
                     RDINS_TWDS_PENAL_CHGS,
                     RDINS_TWDS_INT,
                     RDINS_REM1,
                     RDINS_TRANSTL_INV_NUM,
                     RDINS_ENTD_BY,
                     RDINS_ENTD_ON
                FROM MIG_RDINS
               ORDER BY RDINS_RD_AC_NUM, RDINS_ENTRY_DATE) LOOP

    FETCH_ACNUM(ADX.RDINS_RD_AC_NUM,
                W_DEP_ACNT_NUMBER,
                'DEP11',
                'MIG_RDINS GETOTN');

    IF W_FIRST = TRUE THEN
      W_TMP   := ADX.RDINS_RD_AC_NUM || ADX.RDINS_ENTRY_DATE;
      W_SL    := 1;
      W_FIRST := FALSE;
    ELSIF W_TMP <> ADX.RDINS_RD_AC_NUM || ADX.RDINS_ENTRY_DATE THEN
      W_TMP := ADX.RDINS_RD_AC_NUM || ADX.RDINS_ENTRY_DATE;
      W_SL  := 1;
    ELSE
      W_SL := W_SL + 1;
    END IF;

    <<IN_RDINS>>
    BEGIN
      INSERT INTO RDINS
        (RDINS_ENTITY_NUM,
         RDINS_RD_AC_NUM,
         RDINS_ENTRY_DATE,
         RDINS_ENTRY_DAY_SL,
         RDINS_EFF_DATE,
         RDINS_AMT_OF_PYMT,
         RDINS_TWDS_INSTLMNT,
         RDINS_TWDS_PENAL_CHGS,
         RDINS_TWDS_INT,
         RDINS_REM1,
         RDINS_REM2,
         RDINS_REM3,
         RDINS_TRANSTL_INV_NUM,
         POST_TRAN_BRN,
         POST_TRAN_DATE,
         POST_TRAN_BATCH_NUM,
         RDINS_ENTD_BY,
         RDINS_ENTD_ON,
         RDINS_LAST_MOD_BY,
         RDINS_LAST_MOD_ON,
         RDINS_AUTH_BY,
         RDINS_AUTH_ON,
         RDINS_REJ_BY,
         RDINS_REJ_ON)
      VALUES
        (W_ENTITY_NUM,
         W_DEP_ACNT_NUMBER,
         ADX.RDINS_ENTRY_DATE,
         --rashmi/ramesh unique constraint errorW_SL, --ADX.RDINS_ENTRY_DAY_SL,
         (select nvl(max(RDINS_ENTRY_DAY_SL), 0) + 1
            from rdins
           where RDINS_ENTITY_NUM = w_entity_num
             and RDINS_RD_AC_NUM = W_DEP_ACNT_NUMBER
             and RDINS_ENTRY_DATE = ADX.RDINS_ENTRY_DATE),
         ADX.RDINS_EFF_DATE,
         ADX.RDINS_AMT_OF_PYMT,
         ADX.RDINS_TWDS_INSTLMNT,
         ADX.RDINS_TWDS_PENAL_CHGS,
         ADX.RDINS_TWDS_INT,
         ADX.RDINS_REM1,
         NULL,
         NULL,
         ADX.RDINS_TRANSTL_INV_NUM,
         NULL,
         NULL,
         NULL,
         W_ENTD_BY,
         W_CURR_DATE,
         NULL,
         NULL,
         W_ENTD_BY,
         W_CURR_DATE,
         NULL,
         NULL);
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'DEP12';
        W_ER_DESC := 'SP_DEPOSITS-INSER-RDINS' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     ADX.RDINS_RD_AC_NUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_RDINS;

  END LOOP;
  W_FIRST := TRUE;
  FOR BDX IN (SELECT DEPIA_BRN_CODE,
                     DEPIA_ACCOUNTNUM,
                     DEPIA_CONTRACT_NUM,
                     DEPIA_DATE_OF_ENTRY,
                     DEPIA_DAY_SL,
                     DEPIA_AC_INT_ACCR_AMT,
                     DEPIA_INT_ACCR_DB_CR,
                     DEPIA_BC_INT_ACCR_AMT,
                     DEPIA_ACCR_FROM_DATE,
                     DEPIA_ACCR_UPTO_DATE,
                     DEPIA_ENTRY_TYPE,
                     MIGDEP_PREV_YEAR_INT
                FROM MIG_DEPIA, MIG_PBDCONTRACT
               WHERE DEPIA_BRN_CODE = P_BRANCH_CODE
                 AND MIG_DEPIA.DEPIA_ACCOUNTNUM =
                     MIG_PBDCONTRACT.MIGDEP_DEP_AC_NUM
                 AND MIG_DEPIA.DEPIA_CONTRACT_NUM =
                     MIG_PBDCONTRACT.MIGDEP_CONT_NUM
                 AND DEPIA_AC_INT_ACCR_AMT > 0
               ORDER BY DEPIA_ACCOUNTNUM,
                        DEPIA_CONTRACT_NUM,
                        DEPIA_DATE_OF_ENTRY,
                        DEPIA_ENTRY_TYPE) LOOP

    IF W_DEPIA_DAYSL IS NULL OR
       W_TEMP_ACNTNUM <> BDX.DEPIA_ACCOUNTNUM || BDX.DEPIA_CONTRACT_NUM ||
       BDX.DEPIA_DATE_OF_ENTRY THEN

      W_TEMP_ACNTNUM := BDX.DEPIA_ACCOUNTNUM || BDX.DEPIA_CONTRACT_NUM ||
                        BDX.DEPIA_DATE_OF_ENTRY;
      W_DEPIA_DAYSL  := 1;
      FETCH_ACNUM(BDX.DEPIA_ACCOUNTNUM,
                  W_DEP_ACNT_NUMBER,
                  'DEP13',
                  'MIG_DEPIA GETOTN');

      IF W_FIRST = TRUE THEN
        W_FINYEAR := SP_GETFINYEAR(1, BDX.DEPIA_DATE_OF_ENTRY);
        W_FIRST   := FALSE;
      END IF;
    END IF;
    /*
    if W_UPDATE_PREV_INT=true and bdx.DEPIA_ACCR_FROM_DATE>='01-APR-2009' then
      W_PREV_YEAR_INT:=BDX.MIGDEP_PREV_YEAR_INT;
      W_UPDATE_PREV_INT:=false;
      else
      W_PREV_YEAR_INT:=0;
    end if;
    */

    IF W_FIRST = FALSE AND
       W_FINYEAR <> SP_GETFINYEAR(1, BDX.DEPIA_DATE_OF_ENTRY) THEN
      W_FINYEAR         := SP_GETFINYEAR(1, BDX.DEPIA_DATE_OF_ENTRY);
      W_UPDATE_PREV_INT := TRUE;
    END IF;
    W_PREV_YEAR_INT := 0;
    IF W_UPDATE_PREV_INT = TRUE AND W_DEPIA_DAYSL = 1 THEN
      --W_PREV_YEAR_INT:=BDX.MIGDEP_PREV_YEAR_INT;
      W_UPDATE_PREV_INT := FALSE;

      SELECT NVL(SUM(NVL(DEPIA_AC_INT_ACCR_AMT, 0)), 0)
        INTO W_PREV_YEAR_INT
        FROM DEPIA
       WHERE DEPIA_ENTITY_NUM = W_ENTITY_NUM
         AND DEPIA_INTERNAL_ACNUM = W_DEP_ACNT_NUMBER
         AND DEPIA_CONTRACT_NUM = BDX.DEPIA_CONTRACT_NUM
         AND DEPIA_ENTRY_TYPE = 'IA'
         AND DEPIA_DATE_OF_ENTRY BETWEEN
             TO_DATE('01-APR-' || (W_FINYEAR - 1), 'DD-MON-YYYY') AND
             TO_DATE(('31-MAR-' || W_FINYEAR), 'DD-MON-YYYY');

    END IF;

    <<IN_DEPIA>>
    BEGIN
      INSERT INTO DEPIA
        (DEPIA_ENTITY_NUM,
         DEPIA_BRN_CODE,
         DEPIA_INTERNAL_ACNUM,
         DEPIA_CONTRACT_NUM,
         DEPIA_AUTO_ROLLOVER_SL,
         DEPIA_DATE_OF_ENTRY,
         DEPIA_DAY_SL,
         DEPIA_AC_INT_ACCR_AMT,
         DEPIA_INT_ACCR_DB_CR,
         DEPIA_BC_INT_ACCR_AMT,
         DEPIA_AC_FULL_INT_ACCR_AMT,
         DEPIA_BC_FULL_INT_ACCR_AMT,
         DEPIA_AC_PREV_INT_ACCR_AMT,
         DEPIA_BC_PREV_INT_ACCR_AMT,
         DEPIA_ACCR_FROM_DATE,
         DEPIA_ACCR_UPTO_DATE,
         DEPIA_ENTRY_TYPE,
         DEPIA_ACCR_POSTED_BY,
         DEPIA_ACCR_POSTED_ON,
         DEPIA_LAST_MOD_BY,
         DEPIA_LAST_MOD_ON,
         DEPIA_SOURCE_TABLE,
         DEPIA_SOURCE_KEY,
         DEPIA_PREV_YR_INT_ACCR)
      VALUES
        (W_ENTITY_NUM,
         P_BRANCH_CODE,
         W_DEP_ACNT_NUMBER,
         BDX.DEPIA_CONTRACT_NUM,
         0,
         BDX.DEPIA_DATE_OF_ENTRY,
         W_DEPIA_DAYSL,
         BDX.DEPIA_AC_INT_ACCR_AMT,
         BDX.DEPIA_INT_ACCR_DB_CR,
         BDX.DEPIA_BC_INT_ACCR_AMT,
         NULL,
         NULL,
         NULL,
         NULL,
         BDX.DEPIA_ACCR_FROM_DATE,
         BDX.DEPIA_ACCR_UPTO_DATE,
         BDX.DEPIA_ENTRY_TYPE,
         W_ENTD_BY,
         W_CURR_DATE,
         NULL,
         NULL,
         NULL,
         NULL,
         W_PREV_YEAR_INT);
      W_DEPIA_DAYSL := W_DEPIA_DAYSL + 1;
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'DEP14';
        W_ER_DESC := 'SP_DEPOSITS-INSERT--DEPIA' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     BDX.DEPIA_ACCOUNTNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_DEPIA;
  END LOOP;

  /*
  FOR TDX IN (SELECT TDSPIDT_BRN_CODE,
                     TDSPIDT_CUST_CODE,
                     TDSPIDT_CURR,
                     TDSPIDT_FIN_YR,
                     TDSPIDT_DATE_OF_REC,
                     TDSPIDT_AC_NUM,
                     TDSPIDT_CONT_NUM,
                     TDSPIDT_SL,
                     TDSPIDT_TOT_INT_CR,
                     TDSPIDT_TDS_AMT,
                     TDSPIDT_SURCHARGE_AMT,
                     TDSPIDT_TDS_REC,
                     TDSPIDT_SURCHARGE_REC,
                     TDSPIDT_OTH_BRN_TDS
                FROM MIG_TDSPIDTL
               WHERE TDSPIDT_BRN_CODE = P_BRANCH_CODE) LOOP

      FETCH_ACNUM(tdx.TDSPIDT_AC_NUM,W_DEP_ACNT_NUMBER,'DEP15','MIG_TDSPIDTL GETOTN');
    if TDX.TDSPIDT_TDS_AMT>0 then
    <<IN_TDSPIDTL>>
    BEGIN
      INSERT INTO TDSPIDTL
        (TDSPIDT_BRN_CODE,
         TDSPIDT_CUST_CODE,
         TDSPIDT_CURR,
         TDSPIDT_FIN_YR,
         TDSPIDT_DATE_OF_REC,
         TDSPIDT_AC_NUM,
         TDSPIDT_CONT_NUM,
         TDSPIDT_SL,
         TDSPIDT_TOT_INT_CR,
         TDSPIDT_TDS_AMT,
         TDSPIDT_SURCHARGE_AMT,
         TDSPIDT_TDS_REC,
         TDSPIDT_SURCHARGE_REC,
         TDSPIDT_SOURCE_TABLE,
         TDSPIDT_SOURCE_KEY,
         TDSPIDT_OTH_BRN_TDS)
      VALUES
        (P_BRANCH_CODE,
         W_CLIENT_NUM,
         NVL(TDX.TDSPIDT_CURR, W_BASE_CURR),
         GETFINYEAR(W_CURR_DATE),
         TDX.TDSPIDT_DATE_OF_REC,
         W_DEP_ACNT_NUMBER,
         TDX.TDSPIDT_CONT_NUM,
         TDX.TDSPIDT_SL,
         TDX.TDSPIDT_TOT_INT_CR,
         TDX.TDSPIDT_TDS_AMT,
         TDX.TDSPIDT_SURCHARGE_AMT,
         TDX.TDSPIDT_TDS_REC,
         TDX.TDSPIDT_SURCHARGE_REC,
         NULL,
         NULL,
         TDX.TDSPIDT_OTH_BRN_TDS);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        W_ER_CODE := 'DEP16';
        W_ER_DESC := 'SP_DEPOSITS-INSERT-TDSPIDTL' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     TDX.TDSPIDT_AC_NUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_TDSPIDTL;
            end if;
  END LOOP;
  */
  --SHAMSUDEEN-CHN-24MAY2012-START
 /* -- RAMESH M 24/MAY/12
  INSERT INTO TDSPIDTL
    (TDSPIDT_ENTITY_NUM,
     TDSPIDT_BRN_CODE,
     TDSPIDT_CUST_CODE,
     TDSPIDT_CURR,
     TDSPIDT_FIN_YR,
     TDSPIDT_DATE_OF_REC,
     TDSPIDT_AC_NUM,
     TDSPIDT_CONT_NUM,
     TDSPIDT_SL,
     TDSPIDT_TOT_INT_CR,
     TDSPIDT_TDS_AMT,
     TDSPIDT_SURCHARGE_AMT,
     TDSPIDT_TDS_REC,
     TDSPIDT_SURCHARGE_REC,
     TDSPIDT_OTH_BRN_TDS,
     TDSPIDT_OTH_CHGS,
     TDSPIDT_OTH_CHGS_REC)
    SELECT W_ENTITY_NUM,
           TDSPIDT_BRN_CODE,
          -- S.Karthik/S.Ganesan -20-FEB-2011-BEG
           /*(SELECT ACNTS_CLIENT_NUM
            FROM ACNTS, ACNTOTN
            WHERE ACNTS_ENTITY_NUM = ACNTOTN_ENTITY_NUM
            AND ACNTOTN_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
            AND ACNTOTN.ACNTOTN_OLD_ACNT_NUM = TDSPIDT_AC_NUM), */
  -- S.Karthik/S.Ganesan -20-FEB-2011-END
   /*
   (SELECT TEMP_CLIENT.NEW_CLCODE FROM  TEMP_CLIENT
         WHERE TEMP_CLIENT.OLD_CLCODE=MIG_TDSPIDTL.TDSPIDT_CUST_CODE), -- Ramesh M
         TDSPIDT_CURR,
         TDSPIDT_FIN_YR,
         TDSPIDT_DATE_OF_REC,
         NVL
         (
         (CASE
         WHEN TDSPIDT_AC_NUM IS NOT NULL THEN
         (
          SELECT NVL(ACNTOTN_INTERNAL_ACNUM,'0')
          FROM ACNTOTN
          WHERE ACNTOTN.ACNTOTN_OLD_ACNT_NUM = TDSPIDT_AC_NUM
          )
          ELSE
          0
          END),
          0) ACNUM,
         TDSPIDT_CONT_NUM,
         row_number()  over(partition by TDSPIDT_BRN_CODE, TDSPIDT_CUST_CODE, TDSPIDT_CURR, TDSPIDT_FIN_YR, TDSPIDT_DATE_OF_REC, TDSPIDT_AC_NUM, TDSPIDT_CONT_NUM, TDSPIDT_SL
         order by TDSPIDT_BRN_CODE, TDSPIDT_CUST_CODE, TDSPIDT_CURR, TDSPIDT_FIN_YR, TDSPIDT_DATE_OF_REC, TDSPIDT_AC_NUM, TDSPIDT_CONT_NUM, TDSPIDT_SL),
         TDSPIDT_TOT_INT_CR,
         TDSPIDT_TDS_AMT,
         TDSPIDT_SURCHARGE_AMT,
         TDSPIDT_TDS_REC,
         TDSPIDT_SURCHARGE_REC,
         TDSPIDT_OTH_BRN_TDS,
         TDSPIDT_OTH_CHGS_REC,
         TDSPIDT_OTH_CHGS
  FROM MIG_TDSPIDTL
  WHERE TDSPIDT_TDS_AMT > 0;
  */     -- RAMESH M 24/MAY/2012.


  FOR TDX IN (SELECT TDSPIDT_BRN_CODE,
                     TDSPIDT_CUST_CODE,
                     TDSPIDT_CURR,
                     TDSPIDT_FIN_YR,
                     TDSPIDT_DATE_OF_REC,
                     TDSPIDT_AC_NUM,
                     TDSPIDT_CONT_NUM,
                     TDSPIDT_SL,
                     TDSPIDT_TOT_INT_CR,
                     TDSPIDT_TDS_AMT,
                     TDSPIDT_SURCHARGE_AMT,
                     TDSPIDT_TDS_REC,
                     TDSPIDT_SURCHARGE_REC,
                     TDSPIDT_OTH_BRN_TDS
                FROM MIG_TDSPIDTL
               WHERE TDSPIDT_BRN_CODE = P_BRANCH_CODE
                 AND TDSPIDT_TDS_AMT > 0) LOOP

    FETCH_ACNUM(tdx.TDSPIDT_AC_NUM,
                W_DEP_ACNT_NUMBER,
                'DEP15',
                'MIG_TDSPIDTL GETOTN');
    if TDX.TDSPIDT_TDS_AMT > 0 then
      <<IN_TDSPIDTL>>
      BEGIN
        INSERT INTO TDSPIDTL
          (TDSPIDT_ENTITY_NUM,
           TDSPIDT_BRN_CODE,
           TDSPIDT_CUST_CODE,
           TDSPIDT_CURR,
           TDSPIDT_FIN_YR,
           TDSPIDT_DATE_OF_REC,
           TDSPIDT_AC_NUM,
           TDSPIDT_CONT_NUM,
           TDSPIDT_SL,
           TDSPIDT_TOT_INT_CR,
           TDSPIDT_TDS_AMT,
           TDSPIDT_SURCHARGE_AMT,
           TDSPIDT_TDS_REC,
           TDSPIDT_SURCHARGE_REC,
           TDSPIDT_SOURCE_TABLE,
           TDSPIDT_SOURCE_KEY,
           TDSPIDT_OTH_BRN_TDS)
        VALUES
          (W_ENTITY_NUM,
           P_BRANCH_CODE,
           W_CLIENT_NUM,
           NVL(TDX.TDSPIDT_CURR, W_BASE_CURR),
           TDX.TDSPIDT_FIN_YR,
           TDX.TDSPIDT_DATE_OF_REC,
           (SELECT NVL((CASE
                 WHEN TDX.TDSPIDT_AC_NUM IS NOT NULL THEN

                  (SELECT NVL(ACNTOTN_INTERNAL_ACNUM, '0')
                     FROM ACNTOTN
                    WHERE ACNTOTN.ACNTOTN_OLD_ACNT_NUM = TDX.TDSPIDT_AC_NUM)
                 ELSE
                  0
               END),
               0) ACNUM FROM DUAL),

           TDX.TDSPIDT_CONT_NUM,
           --TDX.TDSPIDT_SL,
           (SELECT NVL(MAX(TDSPIDT_SL),0)+1
           FROM TDSPIDTL
           WHERE TDSPIDT_ENTITY_NUM = W_ENTITY_NUM
           AND TDSPIDT_BRN_CODE = P_BRANCH_CODE
           AND TDSPIDT_CUST_CODE = W_CLIENT_NUM
           AND TDSPIDT_CURR = NVL(TDX.TDSPIDT_CURR, W_BASE_CURR)
           AND TDSPIDT_FIN_YR = TDX.TDSPIDT_FIN_YR
           AND TDSPIDT_DATE_OF_REC = TDX.TDSPIDT_DATE_OF_REC
           AND TDSPIDT_AC_NUM = (SELECT NVL((CASE
                 WHEN TDX.TDSPIDT_AC_NUM IS NOT NULL THEN

                  (SELECT NVL(ACNTOTN_INTERNAL_ACNUM, '0')
                     FROM ACNTOTN
                    WHERE ACNTOTN.ACNTOTN_OLD_ACNT_NUM = TDX.TDSPIDT_AC_NUM)
                 ELSE
                  0
               END),
               0) ACNUM FROM DUAL)
           AND TDSPIDT_CONT_NUM = TDX.TDSPIDT_CONT_NUM),
           TDX.TDSPIDT_TOT_INT_CR,
           TDX.TDSPIDT_TDS_AMT,
           TDX.TDSPIDT_SURCHARGE_AMT,
           TDX.TDSPIDT_TDS_REC,
           TDX.TDSPIDT_SURCHARGE_REC,
           NULL,
           NULL,
           TDX.TDSPIDT_OTH_BRN_TDS);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          W_ER_CODE := 'DEP16';
          W_ER_DESC := 'SP_DEPOSITS-INSERT-TDSPIDTL' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                       TDX.TDSPIDT_AC_NUM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END IN_TDSPIDTL;
    end if;
  END LOOP;
  --SHAMSUDEEN-CHN-24MAY2012-END

  /*
  FOR INR IN (SELECT TDSPIDT_AC_NUM,
                     TDSPIDT_FIN_YR,
                     TDSPIDT_CURR,
                     SUM(TDSPIDT_TOT_INT_CR) TDSPIDT_TOT_INT_CR,
                     SUM(TDSPIDT_TDS_AMT) TDSPIDT_TDS_AMT,
                     SUM(TDSPIDT_SURCHARGE_AMT) TDSPIDT_SURCHARGE_AMT,
                     SUM(TDSPIDT_TDS_REC) TDSPIDT_TDS_REC,
                     SUM(TDSPIDT_SURCHARGE_REC) TDSPIDT_SURCHARGE_REC
                FROM TDSPIDTL
               WHERE TDSPIDT_FIN_YR = getfinyear(W_CURR_DATE)
               GROUP BY TDSPIDT_AC_NUM, TDSPIDT_FIN_YR, TDSPIDT_CURR) LOOP

    SELECT ACNTS_CLIENT_NUM
      INTO W_CLIENT_NUM
      FROM acnts
     WHERE ACNTS_INTERNAL_ACNUM = inr.TDSPIDT_AC_NUM;

    <<IN_TDSPI>>
    begin
      INSERT INTO TDSPI
        (TDSPI_BRN_CODE,
         TDSPI_CUST_CODE,
         TDSPI_CURR,
         TDSPI_FIN_YR,
         TDSPI_TOT_INT_CR,
         TDSPI_TDS_AMT,
         TDSPI_SURCHARGE_AMT,
         TDSPI_TDS_REC,
         TDSPI_SURCHARGE_REC)
      VALUES
        (p_branch_code,
         W_CLIENT_NUM,
         NVL(INR.TDSPIDT_CURR, W_BASE_CURR),
         INR.TDSPIDT_FIN_YR,
         INR.TDSPIDT_TOT_INT_CR,
         INR.TDSPIDT_TDS_AMT,
         INR.TDSPIDT_SURCHARGE_AMT,
         INR.TDSPIDT_TDS_REC,
         INR.TDSPIDT_SURCHARGE_REC);
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'DEP17';
        W_ER_DESC := 'SP_DEPOSITS-INSERT-TDSPI' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     INR.TDSPIDT_AC_NUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_TDSPI;

  END LOOP;*/

  INSERT INTO TDSPI
    (TDSPI_ENTITY_NUM,
     TDSPI_BRN_CODE,
     TDSPI_CUST_CODE,
     TDSPI_CURR,
     TDSPI_FIN_YR,
     TDSPI_TOT_INT_CR,
     TDSPI_TDS_AMT,
     TDSPI_SURCHARGE_AMT,
     TDSPI_TDS_REC,
     TDSPI_SURCHARGE_REC,
     TDSPI_OTH_CHGS,
     TDSPI_OTH_CHGS_REC)

    SELECT W_ENTITY_NUM,
           TDSPIDT_BRN_CODE,
           TDSPIDT_CUST_CODE,
           TDSPIDT_CURR,
           TDSPIDT_FIN_YR,
           SUM(TDSPIDT_TOT_INT_CR),
           SUM(TDSPIDT_TDS_AMT),
           SUM(TDSPIDT_SURCHARGE_AMT),
           SUM(TDSPIDT_TDS_REC),
           SUM(TDSPIDT_SURCHARGE_REC),
           SUM(TDSPIDT_OTH_CHGS),
           SUM(TDSPIDT_OTH_CHGS_REC)
      FROM TDSPIDTL
     GROUP BY TDSPIDT_BRN_CODE,
              TDSPIDT_CUST_CODE,
              TDSPIDT_CURR,
              TDSPIDT_FIN_YR;

  -- S.RAJALAKSHMI-19-OCT-2009-BEGIN
  FOR REM IN (SELECT TDSREMGO_BRN_CODE,
                     NVL(TDSREMGO_INT_CURR_CODE, W_CURR_DATE) TDSREMGO_INT_CURR_CODE,
                     TDSREMGO_REMIT_DATE,
                     TDSREMGO_DAY_SL,
                     TDSREMGO_ENTRY_DATE,
                     TDSREMGO_CHALLAN_NUM,
                     TDSREMGO_CHALLAN_DATE,
                     TDSREMGO_TOT_AMT_REMIT,
                     TDSREMGO_DOM_TDS,
                     TDSREMGO_DOM_SURCHARGE,
                     TDSREMGO_NR_TDS,
                     TDSREMGO_NR_SURCHARGE,
                     TDSREMGO_OTH_TDS,
                     TDSREMGO_OTH_SURCHARGE,
                     TDSREMGO_REMIT_PRD_MNTH,
                     TDSREMGO_REMIT_PRD_YEAR,
                     TDSREMGO_REMIT_PRD_FROM,
                     TDSREMGO_REMIT_PRD_UPTO,
                     TDSREMGO_REMIT_AT_BANK,
                     TDSREMGO_REMIT_AT_BANK_NAME,
                     TDSREMGO_REMIT_AT_BRN,
                     TDSREMGO_REMIT_AT_BRN_NAME,
                     TDSREMGO_PAYMENT_MODE,
                     TDSREMGO_DDPO_PREFIIX,
                     TDSREMGO_DDPO_NUM,
                     TDSREMGO_DDPO_DATE,
                     TDSREMGO_DDPO_ON_BRN,
                     TDSREMGO_REM1,
                     TDSREMGO_REM2,
                     TDSREMGO_REM3
                FROM MIG_TDSREMITGOV
               WHERE TDSREMGO_BRN_CODE = P_BRANCH_CODE) LOOP
    <<IN_TDSREMITGOV>>
    BEGIN
      INSERT INTO TDSREMITGOV
        (TDSREMGOV_ENTITY_NUM,
         TDSREMGOV_BRN_CODE,
         TDSREMGOV_INT_CURR_CODE,
         TDSREMGOV_REMIT_DATE,
         TDSREMGOV_DAY_SL,
         TDSREMGOV_ENTRY_DATE,
         TDSREMGOV_CHALLAN_NUM,
         TDSREMGOV_CHALLAN_DATE,
         TDSREMGOV_TOT_AMT_REMIT,
         TDSREMGOV_DOM_TDS,
         TDSREMGOV_DOM_SURCHARGE,
         TDSREMGOV_NR_TDS,
         TDSREMGOV_NR_SURCHARGE,
         TDSREMGOV_OTH_TDS,
         TDSREMGOV_OTH_SURCHARGE,
         TDSREMGOV_REMIT_PRD_MNTH,
         TDSREMGOV_REMIT_PRD_YEAR,
         TDSREMGOV_REMIT_PRD_FROM,
         TDSREMGOV_REMIT_PRD_UPTO,
         TDSREMGOV_REMIT_AT_BANK,
         TDSREMGOV_REMIT_AT_BANK_NAME,
         TDSREMGOV_REMIT_AT_BRN,
         TDSREMGOV_REMIT_AT_BRN_NAME,
         TDSREMGOV_PAYMENT_MODE,
         TDSREMGOV_DDPO_PREFIX,
         TDSREMGOV_DDPO_NUM,
         TDSREMGOV_DDPO_DATE,
         TDSREMGOV_DDPO_ON_BRN,
         TDSREMGOV_REM1,
         TDSREMGOV_REM2,
         TDSREMGOV_REM3,
         TDSREMGOV_ENTD_BY,
         TDSREMGOV_ENTD_ON,
         TDSREMGOV_LAST_MOD_BY,
         TDSREMGOV_LAST_MOD_ON,
         TDSREMGOV_AUTH_BY,
         TDSREMGOV_AUTH_ON,
         TBA_MAIN_KEY)
      VALUES
        (W_ENTITY_NUM,
         P_BRANCH_CODE,
         REM.TDSREMGO_INT_CURR_CODE,
         REM.TDSREMGO_REMIT_DATE,
         REM.TDSREMGO_DAY_SL,
         REM.TDSREMGO_ENTRY_DATE,
         REM.TDSREMGO_CHALLAN_NUM,
         REM.TDSREMGO_CHALLAN_DATE,
         REM.TDSREMGO_TOT_AMT_REMIT,
         REM.TDSREMGO_DOM_TDS,
         REM.TDSREMGO_DOM_SURCHARGE,
         REM.TDSREMGO_NR_TDS,
         REM.TDSREMGO_NR_SURCHARGE,
         REM.TDSREMGO_OTH_TDS,
         REM.TDSREMGO_OTH_SURCHARGE,
         REM.TDSREMGO_REMIT_PRD_MNTH,
         REM.TDSREMGO_REMIT_PRD_YEAR,
         REM.TDSREMGO_REMIT_PRD_FROM,
         REM.TDSREMGO_REMIT_PRD_UPTO,
         REM.TDSREMGO_REMIT_AT_BANK,
         REM.TDSREMGO_REMIT_AT_BANK_NAME,
         REM.TDSREMGO_REMIT_AT_BRN,
         REM.TDSREMGO_REMIT_AT_BRN_NAME,
         REM.TDSREMGO_PAYMENT_MODE,
         REM.TDSREMGO_DDPO_PREFIIX,
         REM.TDSREMGO_DDPO_NUM,
         REM.TDSREMGO_DDPO_DATE,
         REM.TDSREMGO_DDPO_ON_BRN,
         REM.TDSREMGO_REM1,
         REM.TDSREMGO_REM2,
         REM.TDSREMGO_REM3,
         W_ENTD_BY,
         W_CURR_DATE,
         NULL,
         NULL,
         W_ENTD_BY,
         W_CURR_DATE,
         NULL);
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'DEP18';
        W_ER_DESC := 'SP_DEPOSITS-INSERT-TDSREMITGOV' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     REM.TDSREMGO_CHALLAN_NUM || '-' ||
                     REM.TDSREMGO_CHALLAN_DATE;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_TDSREMITGOV;
  END LOOP;

  FOR IDX IN (SELECT PBDCONTDSA_STLMNT_CHOICE,
                     MIGDEP_DEP_AC_NUM,
                     MIGDEP_CONT_NUM,
                     DECODE(PBDCONTDSA_LATEST_EFF_DATE,
                            NULL,
                            MIGDEP_DEP_OPEN_DATE,
                            PBDCONTDSA_LATEST_EFF_DATE) PBDCONTDSA_LATEST_EFF_DATE,
                     PBDCONTDSA_REMIT_CODE,
                     PBDCONTDSA_ON_AC_OF,
                     PBDCONTDSA_ECS_AC_BANK_CD,
                     PBDCONTDSA_ECS_AC_BRANCH_CD,
                     PBDCONTDSA_ECS_CREDIT_AC_NUM,
                     PBDCONTDSA_ECS_AC_TYPE
                FROM MIG_PBDCONTDSA, MIG_PBDCONTRACT
               WHERE MIGDEP_DEP_AC_NUM = PBDCONTDSA_DEP_AC_NUM
                 AND MIGDEP_RECPT_NUM = RCPTNO) LOOP

    FOR JDX IN (SELECT ACNTS_INTERNAL_ACNUM, ACNTS_AC_NAME1
                  FROM ACNTS, ACNTOTN
                 WHERE ACNTS_INTERNAL_ACNUM = ACNTOTN_INTERNAL_ACNUM
                   AND ACNTOTN_OLD_ACNT_NUM = IDX.MIGDEP_DEP_AC_NUM) LOOP

      UPDATE PBDCONTDSA
         SET PBDCONTDSA_STLMNT_CHOICE     = IDX.PBDCONTDSA_STLMNT_CHOICE,
             PBDCONTDSA_REMIT_CODE        = IDX.PBDCONTDSA_REMIT_CODE,
             PBDCONTDSA_BENEF_NAME1       = JDX.ACNTS_AC_NAME1,
             PBDCONTDSA_BENEF_NAME2       = '',
             PBDCONTDSA_ON_AC_OF          = IDX.PBDCONTDSA_ON_AC_OF,
             PBDCONTDSA_ECS_AC_BANK_CD    = IDX.PBDCONTDSA_ECS_AC_BANK_CD,
             PBDCONTDSA_ECS_AC_BRANCH_CD  = IDX.PBDCONTDSA_ECS_AC_BRANCH_CD,
             PBDCONTDSA_ECS_CREDIT_AC_NUM = IDX.PBDCONTDSA_ECS_CREDIT_AC_NUM,
             PBDCONTDSA_ECS_AC_TYPE       = IDX.PBDCONTDSA_ECS_AC_TYPE
       WHERE PBDCONTDSA_ENTITY_NUM = W_ENTITY_NUM
         AND PBDCONTDSA_DEP_AC_NUM = JDX.ACNTS_INTERNAL_ACNUM
         AND PBDCONTDSA_CONT_NUM = IDX.MIGDEP_CONT_NUM;
      IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO PBDCONTDSA
          (PBDCONTDSA_ENTITY_NUM,
           PBDCONTDSA_DEP_AC_NUM,
           PBDCONTDSA_CONT_NUM,
           PBDCONTDSA_LATEST_EFF_DATE,
           PBDCONTDSA_INT_CR_AC_NUM,
           PBDCONTDSA_CLOSURE_STL_AC_NUM,
           PBDCONTDSA_REMIT_CODE,
           PBDCONTDSA_BENEF_NAME1,
           PBDCONTDSA_BENEF_NAME2,
           PBDCONTDSA_ON_AC_OF,
           PBDCONTDSA_ECS_AC_BANK_CD,
           PBDCONTDSA_ECS_AC_BRANCH_CD,
           PBDCONTDSA_ECS_CREDIT_AC_NUM,
           PBDCONTDSA_ECS_AC_TYPE,
           PBDCONTDSA_STLMNT_CHOICE)
        VALUES
          (W_ENTITY_NUM,
           JDX.ACNTS_INTERNAL_ACNUM,
           IDX.MIGDEP_CONT_NUM,
           IDX.PBDCONTDSA_LATEST_EFF_DATE,
           0,
           0,
           IDX.PBDCONTDSA_REMIT_CODE,
           JDX.ACNTS_AC_NAME1,
           '',
           IDX.PBDCONTDSA_ON_AC_OF,
           IDX.PBDCONTDSA_ECS_AC_BANK_CD,
           IDX.PBDCONTDSA_ECS_AC_BRANCH_CD,
           IDX.PBDCONTDSA_ECS_CREDIT_AC_NUM,
           IDX.PBDCONTDSA_ECS_AC_TYPE,
           IDX.PBDCONTDSA_STLMNT_CHOICE);
      END IF;
    END LOOP;
  END LOOP;

  INSERT INTO PBDCONTDSAHIST
    (PBDCDSAH_ENTITY_NUM,
     PBDCDSAH_DEP_AC_NUM,
     PBDCDSAH_CONT_NUM,
     PBDCDSAH_EFF_DATE,
     PBDCDSAH_INT_CR_AC_NUM,
     PBDCDSAH_CLOSURE_STL_AC_NUM,
     PBDCDSAH_ENTD_BY,
     PBDCDSAH_ENTD_ON,
     PBDCDSAH_AUTH_BY,
     PBDCDSAH_AUTH_ON,
     TBA_MAIN_KEY,
     PBDCDSAH_STLMNT_CHOICE,
     PBDCDSAH_REMIT_CODE,
     PBDCDSAH_BENEF_NAME1,
     PBDCDSAH_BENEF_NAME2,
     PBDCDSAH_ON_AC_OF,
     PBDCDSAH_ECS_AC_BANK_CD,
     PBDCDSAH_ECS_AC_BRANCH_CD,
     PBDCDSAH_ECS_CREDIT_AC_NUM,
     PBDCDSAH_ECS_AC_TYPE)
    SELECT 1,
           PBDCONTDSA_DEP_AC_NUM,
           PBDCONTDSA_CONT_NUM,
           PBDCONT_DEP_OPEN_DATE,
           PBDCONTDSA_INT_CR_AC_NUM,
           PBDCONTDSA_CLOSURE_STL_AC_NUM,
           W_ENTD_BY,
           W_CURR_DATE,
           W_ENTD_BY,
           W_CURR_DATE,
           NULL,
           PBDCONTDSA_STLMNT_CHOICE,
           PBDCONTDSA_REMIT_CODE,
           PBDCONTDSA_BENEF_NAME1,
           PBDCONTDSA_BENEF_NAME2,
           PBDCONTDSA_ON_AC_OF,
           PBDCONTDSA_ECS_AC_BANK_CD,
           PBDCONTDSA_ECS_AC_BRANCH_CD,
           PBDCONTDSA_ECS_CREDIT_AC_NUM,
           PBDCONTDSA_ECS_AC_TYPE
      FROM PBDCONTRACT, PBDCONTDSA
     WHERE PBDCONT_DEP_AC_NUM = PBDCONTDSA_DEP_AC_NUM
       AND PBDCONT_CONT_NUM = PBDCONTDSA_CONT_NUM;

  INSERT INTO DEPRCPTPRNT
    (SELECT PBDCONT_ENTITY_NUM,
            PBDCONT_BRN_CODE,
            PBDCONT_DEP_AC_NUM,
            PBDCONT_CONT_NUM,
            PBDCONT_EFF_DATE,
            0,
            0,
            NULL,
            0,
            NULL, --RASHMI K
            '0'
       FROM PBDCONTRACT
      WHERE (PBDCONT_ENTITY_NUM, PBDCONT_BRN_CODE, PBDCONT_DEP_AC_NUM,
             PBDCONT_CONT_NUM) NOT IN
            (SELECT DEPRCPTPRNT_ENTITY_NUM,
                    DEPRCPTPRNT_BRN_CODE,
                    DEPRCPTPRNT_INTERNAL_AC_NUM,
                    DEPRCPT_CONT_NUM
               FROM DEPRCPTPRNT)
        AND PBDCONT_CONT_NUM > 0
        AND PBDCONT_ENTD_BY = 'MIG');

  INSERT INTO DEPRCPTPRNT
    (SELECT PBDCONT_ENTITY_NUM,
            PBDCONT_BRN_CODE,
            PBDCONT_DEP_AC_NUM,
            PBDCONT_CONT_NUM,
            PBDCONT_EFF_DATE,
            0,
            0,
            NULL,
            0,
            NULL, --RASHMI K
            '0'
       FROM PBDCONTRACT
      WHERE (PBDCONT_ENTITY_NUM, PBDCONT_BRN_CODE, PBDCONT_DEP_AC_NUM,
             PBDCONT_CONT_NUM) NOT IN
            (SELECT DEPRCPTPRNT_ENTITY_NUM,
                    DEPRCPTPRNT_BRN_CODE,
                    DEPRCPTPRNT_INTERNAL_AC_NUM,
                    DEPRCPT_CONT_NUM
               FROM DEPRCPTPRNT)
        AND PBDCONT_CONT_NUM > 0
        AND PBDCONT_ENTD_BY = 'MIG');

  COMMIT;

  --Added 28-Nov-2010-Beg
  /* UPDATE PBDCONTRACT   ---- Commented by Rashmi K on 04-MAY-2012.
  SET PBDCONT_INST_REC_FROM_AC = (SELECT IACLINK.IACLINK_INTERNAL_ACNUM
                                  FROM IACLINK
                                  WHERE IACLINK.IACLINK_ACTUAL_ACNUM =
                                        --'0' ||  COMMENTED BY RAMESH M ON 03-MAY-2012.
                                        PBDCONT_INST_REC_FROM_AC)
  WHERE PBDCONT_INST_REC_FROM_AC IS NOT NULL; */

  UPDATE PBDCONTRACT -- Modified by Rashmi K on 04-MAY-2012.
     SET PBDCONT_INST_REC_FROM_AC =
         (SELECT IACLINK.IACLINK_INTERNAL_ACNUM
            FROM IACLINK
           WHERE IACLINK.IACLINK_ACTUAL_ACNUM =
                --'0' ||  COMMENTED BY RAMESH M ON 03-MAY-2012.
                 to_char(PBDCONT_INST_REC_FROM_AC))
   WHERE PBDCONT_INST_REC_FROM_AC IS NOT NULL;
  --Added 28-Nov-2010-End
EXCEPTION
  WHEN OTHERS THEN
    P_ERR_MSG := SQLERRM;
    ROLLBACK;
    /*
    TRUNCATE TABLE  PBDCONTRACT;
    TRUNCATE TABLE  ACNTCBAL;
    TRUNCATE TABLE  ACNTCONTRACT;
    TRUNCATE TABLE  ACNTBAL;
    TRUNCATE TABLE  NOMREG;
    TRUNCATE TABLE  DEPACCLIEN;
    TRUNCATE TABLE  PBDCONTDSA;
    TRUNCATE TABLE  PBDCONTDSAHIST;
    TRUNCATE TABLE  PBDCONTTRFOD;
    TRUNCATE TABLE  DEPRCPTPRNT;
    TRUNCATE TABLE  RDINS;
    TRUNCATE TABLE  TDSPIDTL;
    TRUNCATE TABLE  DEPIA;
    TRUNCATE TABLE  TDSPI;
    TRUNCATE TABLE  DEPCLS;
    TRUNCATE TABLE  TDSREMITGOV;
    */

END SP_MIG_DEPOSITS;
/
