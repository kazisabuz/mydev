CREATE OR REPLACE PROCEDURE SP_MIG_LOANS(P_BRANCH_CODE NUMBER,
                                         P_ERR_MSG     OUT VARCHAR2) AS
  /*

   LIST OF TABLE/S USED

  1. MIG_LNACNT
  2. MIG_LNACGUAR
  3. MIG_LNACIRS
  4. MIG_LNACDSDTL
  5. MIG_LNDP
  6. MIG_LNSUBRCV
  7. MIG_LNSUBSIDY
  8. MIG_LNSUSP
  9. MIG_ASSETCLS
  10. MIG_LNACRSDTL -- ADDED


   LIST OF TABLES UPDATED

   1. LOANACNTS
   2. LOANACHIST
   3. LOANACHISTDTL
   4. LOANACDTL
   5. LIMITLINE
   6. ACASLL
   7. ACASLLDTL
   8. LIMITLINEHIST
   9. LIMFACCURR
   10.LIMITLINEAUX
   11.LIMITSERIAL
   12.ASSETCLS
   13.ASSETCLSHIST
   14.LIMITLINECTREQ
   15.LNACGUAR
   16.LNACAODHIST
   17.LNACIRS
   18.LNACIRSHIST
   19.LNACRSDTL
   20.LNACRSHIST
   21.LNACRS
   22.LNACRSHDTL
   23.LNDP
   24.LNDPHIST
   25.LNACDSDTL
   26.LNSUBVENRECV
   27.LNACSUBSIDY
   28.LNSUSPBAL
   29.LNSUSPLED
   30.LLACNTOS
   31.LNACIR
   32.LNACIRHIST
   33.LNACIRDTL
   34.LNACIRHDTL
   35.LNACMIS
   36.LNACMISHIST
   37.LNACINTCTL
   38.LNACINTCTLHIST


     MODIFICATION HISTORY
     -----------------------------------------------------------------------------------------
     SL.            DESCRIPTION                                    MOD BY             MOD ON
     -----------------------------------------------------------------------------------------



   */

  W_ACNT_NUM        NUMBER(14);
  W_CLIENT_NUM      NUMBER(12);
  W_GURAN_CLIENTNUM NUMBER(12);
  W_ENTD_BY         VARCHAR2(8) := 'MIG';
  W_CURR_DATE       DATE;
  W_OPENING_DATE    DATE;
  W_SL              NUMBER(3);
  W_PROD_NAME       VARCHAR2(50);
  W_PROD_CODE       NUMBER(4);
  W_LIMIT_NUM       NUMBER(6) := 0;
  --W_COLL_TYPE       VARCHAR2(6);
  --W_COLL_CURR       VARCHAR2(3);
  --W_COLL_AMT        NUMBER(18, 3) := 0;
  --W_COLL_SL         NUMBER(6) := 0;
  W_RECOV_SL  NUMBER(6) := 0;
  W_NPA_DATE  DATE;
  W_CURR_CODE VARCHAR2(3) := 'BDT'; --shamsudeen-chn-24may2012-changed INR to BDT
  W_LEDCNT    NUMBER(6) := 0;

  W_SRC_KEY        VARCHAR2(1000);
  W_ER_CODE        VARCHAR2(5);
  W_ER_DESC        VARCHAR2(1000);
  W_TMP_RECOVACNT  VARCHAR2(25);
  W_TMP_RECOVACNT1 NUMBER(10); --rashmi/ramesh
  W_TEMP_ACNUM     VARCHAR2(25);
  W_NULL           VARCHAR2(10) := NULL;
  MYEXCEPTION EXCEPTION;
  W_ENTITY_NUM NUMBER(3) := GET_OTN.ENTITY_NUMBER;

  /*
   WHEN THE NEXT QUARTER CHANGES, THIS DATE HAS TO BE CHANGED
  */

  W_LAST_AOD_GIVEN_ON DATE := '30-JUN-2014';
  W_NEXT_AOD_GIVEN_ON DATE := '30-SEP-2014';

  V_LNACRSDTL_DATA NUMBER(1);

  V_LNACRS_DATA NUMBER(1);

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

  PROCEDURE INSERT_LNACIR(P_INTERNAL_ACNUM NUMBER,
                          P_EFF_DATE       DATE,
                          P_SL_NUM         NUMBER,
                          P_APPL_UPTO_AMT  NUMBER,
                          P_INT_RATE       NUMBER) IS
  BEGIN
    INSERT INTO LNACIRHDTL
      (LNACIRHDTL_ENTITY_NUM,
       LNACIRHDTL_INTERNAL_ACNUM,
       LNACIRHDTL_EFF_DATE,
       LNACIRHDTL_SL_NUM,
       LNACIRHDTL_APPL_UPTO_AMT,
       LNACIRHDTL_INT_RATE)
    VALUES
      (W_ENTITY_NUM,
       P_INTERNAL_ACNUM,
       P_EFF_DATE,
       P_SL_NUM,
       P_APPL_UPTO_AMT,
       P_INT_RATE);
  END INSERT_LNACIR;

  PROCEDURE FETCH_ACNUM(P_BRN        NUMBER,
                        P_OLDAC      VARCHAR2,
                        PUT_ERR      VARCHAR2,
                        PUT_ERR_DESC VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE 'SELECT ACNTOTN_INTERNAL_ACNUM,acnts_client_num,ACNTS_OPENING_DATE,ACNTS_PROD_CODE
   FROM ACNTOTN,acnts WHERE ACNTOTN_ENTITY_NUM=ACNTS_ENTITY_NUM and acntotn.acntotn_internal_acnum=acnts.acnts_internal_acnum and
     ACNTOTN_ENTITY_NUM=:1 and ACNTOTN_OLD_ACNT_BRN =:2 AND ACNTOTN.ACNTOTN_OLD_ACNT_NUM =:3 '
      INTO W_ACNT_NUM, W_CLIENT_NUM, W_OPENING_DATE, W_PROD_CODE
      USING W_ENTITY_NUM, P_BRN, P_OLDAC;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      W_ER_CODE := PUT_ERR;
      W_ER_DESC := PUT_ERR_DESC || SQLERRM;
      W_SRC_KEY := P_BRANCH_CODE || '-' || P_OLDAC;
      POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
  END FETCH_ACNUM;


BEGIN
  P_ERR_MSG := '0';

  SELECT MN_CURR_BUSINESS_DATE
    INTO W_CURR_DATE
    FROM MAINCONT
   WHERE MN_ENTITY_NUM = W_ENTITY_NUM;

  BEGIN
    FOR IDX IN (SELECT * FROM MIG_LNDP) LOOP
      UPDATE MIG_LNACNT L
         SET L.LNACNT_DP_REQD         = '1',
             L.LNACNT_DP_AMT          = IDX.LNDP_DP_AMT,
             L.LNACNT_DP_VALID_UPTO   = IDX.LNDP_DP_VALID_UPTO_DATE,
             L.LNACNT_DUE_DATE_REVIEW = IDX.LNDP_DP_REVIEW_DUE_DATE
       WHERE L.LNACNT_ACNUM = IDX.LNDP_ACNUM;
    END LOOP;
  END;

  -- SELECT INS_BASE_CURR_CODE INTO W_CURR_CODE FROM INSTALL;

  W_SL := 1;

  FOR IDX IN (SELECT LNACNT_ACNUM,
                     LNACNT_BRN_CODE,
                     LNACNT_CLIENT_NUM,
                     LNACNT_PURPOSE_CODE,
                     LNACNT_LAST_AOD_GIVEN_ON,
                     LNACNT_NEXT_AOD_DUE_ON,
                     LNACNT_DISB_TYPE,
                     LNACNT_SUBSIDY_AVAILABLE,
                     LNACNT_AUTO_INSTALL_RECOV_REQD,
                     LNACNT_RECOV_ACNT_NUM1,
                     LNACNT_RECOV_ACNT_NUM2,
                     LNACNT_RECOV_ACNT_NUM3,
                     LNACNT_RECOV_ACNT_NUM4,
                     LNACNT_RECOV_ACNT_NUM5,
                     LNACNT_RECOV_ACNT_NUM6,
                     LNACNT_RECOV_ACNT_NUM7,
                     LNACNT_RECOV_ACNT_NUM8,
                     LNACNT_RECOV_ACNT_NUM9,
                     LNACNT_RECOV_ACNT_NUM10,
                     LNACNT_INT_ACCR_UPTO,
                     LNACNT_INT_APPLIED_UPTO_DATE,
                     LNACNT_LIMIT_SANCTION_DATE,
                     LNACNT_LIMIT_SANCTION_REF_NUM,
                     LNACNT_LIMIT_EFF_DATE,
                     LNACNT_LIMIT_EXPIRY_DATE,
                     LNACNT_REVOLVING_LIMIT,
                     LNACNT_SAUTH_CODE,
                     NVL(LNACNT_SANCTION_CURR, W_CURR_CODE) LNACNT_SANCTION_CURR,
                     LNACNT_SANCTION_AMT,
                     LNACNT_LIMIT_AVL_ON_DATE,
                     LNACNT_SEC_LIMIT_LINE,
                     LNACNT_SEC_AMT_REQD,
                     LNACNT_DP_REQD,
                     LNACNT_DP_AMT,
                     LNACNT_DP_VALID_UPTO,
                     LNACNT_DUE_DATE_REVIEW,
                     LNACNT_LIMIT_CURR_DISB_MADE,
                     LNACNT_OUTSTANDING_BALANCE,
                     LNACNT_PRIN_OS,
                     LNACNT_INT_OS,
                     LNACNT_CHG_OS,
                     LNACNT_ASSET_STAT,
                     LNACNT_DATE_OF_NPA,
                     LNACNT_NPA_IDENTIFIED_DATE,
                     LNACNT_TOT_SUSPENSE_BALANCE,
                     LNACNT_INT_SUSP_BALANCE,
                     LNACNT_CHG_SUSP_BALANCE,
                     LNACNT_TOT_PROV_HELD,
                     LNACNT_WRITTEN_OFF_AMT,
                     LNACNT_AOD_GIVEN_ON,
                     LNACNT_REPAY_SCHD_REQD,
                     LNACNT_OD_AMT,
                     LNACNT_OD_DATE,
                     LNACNT_PRIN_OD_AMT,
                     LNACNT_INT_OD_AMT,
                     LNACNT_CHGS_OD_AMT,
                     LNACNT_PRIN_OD_DATE,
                     LNACNT_INT_OD_DATE,
                     LNACNT_CHGS_OD_DATE,
                     LNACNT_SEGMENT_CODE,
                     LNACNT_HO_DEPT_CODE,
                     LNACNT_INDUS_CODE,
                     LNACNT_SUB_INDUS_CODE,
                     LNACNT_BSR_ACT_OCC_CODE,
                     LNACNT_BSR_MAIN_ORG_CODE,
                     LNACNT_BSR_SUB_ORG_CODE,
                     LNACNT_BSR_STATE_CODE,
                     LNACNT_BSR_DISTRICT_CODE,
                     LNACNT_NATURE_BORROWAL_AC,
                     LNACNT_POP_GROUP_CODE,
                     LNACNT_SEC_TYPE_SPECIFIED,
                     LNACNT_COLLAT_TYPE1,
                     NVL(LNACNT_COLLAT_AMT_CURR1, W_CURR_CODE) LNACNT_COLLAT_AMT_CURR1,
                     LNACNT_COLLAT_AMT1 LNACNT_COLLAT_AMT_1,
                     LNACNT_COLLAT_TYPE2,
                     NVL(LNACNT_COLLAT_AMT_CURR2, W_CURR_CODE) LNACNT_COLLAT_AMT_CURR2,
                     LNACNT_COLLAT_AMT2 LNACNT_COLLAT_AMT_2,
                     LNACNT_COLLAT_TYPE3,
                     NVL(LNACNT_COLLAT_AMT_CURR3, W_CURR_CODE) LNACNT_COLLAT_AMT_CURR3,
                     LNACNT_COLLAT_AMT3 LNACNT_COLLAT_AMT_3,
                     LNACNT_COLLAT_TYPE4,
                     NVL(LNACNT_COLLAT_AMT_CURR4, W_CURR_CODE) LNACNT_COLLAT_AMT_CURR4,
                     LNACNT_COLLAT_AMT4 LNACNT_COLLAT_AMT_4,
                     LNACNT_COLLAT_TYPE5,
                     NVL(LNACNT_COLLAT_AMT_CURR5, W_CURR_CODE) LNACNT_COLLAT_AMT_CURR5,
                     LNACNT_COLLAT_AMT5 LNACNT_COLLAT_AMT_5,
                     LNACNT_COLLAT_TYPE6,
                     NVL(LNACNT_COLLAT_AMT_CURR6, W_CURR_CODE) LNACNT_COLLAT_AMT_CURR6,
                     LNACNT_COLLAT_AMT6 LNACNT_COLLAT_AMT_6,
                     LNACNT_COLLAT_TYPE7,
                     NVL(LNACNT_COLLAT_AMT_CURR7, W_CURR_CODE) LNACNT_COLLAT_AMT_CURR7,
                     LNACNT_COLLAT_AMT7 LNACNT_COLLAT_AMT_7,
                     LNACNT_COLLAT_TYPE8,
                     NVL(LNACNT_COLLAT_AMT_CURR8, W_CURR_CODE) LNACNT_COLLAT_AMT_CURR8,
                     LNACNT_COLLAT_AMT8 LNACNT_COLLAT_AMT_8,
                     LNACNT_COLLAT_TYPE9,
                     NVL(LNACNT_COLLAT_AMT_CURR9, W_CURR_CODE) LNACNT_COLLAT_AMT_CURR9,
                     LNACNT_COLLAT_AMT9 LNACNT_COLLAT_AMT_9,
                     LNACNT_COLLAT_TYPE10,
                     NVL(LNACNT_COLLAT_AMT_CURR10, W_CURR_CODE) LNACNT_COLLAT_AMT_CURR10,
                     LNACNT_COLLAT_AMT10 LNACNT_COLLAT_AMT_10,
                     LNACNT_TOT_CASH_MARGIN_RECVD,
                     LNACNT_TOT_CASH_MARGIN_REL V_IN_MIG_LOANS,
                     LNACNT_INT_APPL_DISABLED,
                     LNACNT_INT_DISABLED_DATE
                FROM MIG_LNACNT
               WHERE LNACNT_BRN_CODE = P_BRANCH_CODE) LOOP
    FETCH_ACNUM(IDX.LNACNT_BRN_CODE,
                IDX.LNACNT_ACNUM,
                'LN1',
                'MIG_LNACNT GETOTN');

    <<CHECK_PROD_CODE>>
    BEGIN
      SELECT PRODUCT_NAME
        INTO W_PROD_NAME
        FROM PRODUCTS
       WHERE PRODUCT_CODE = W_PROD_CODE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        W_ER_CODE := 'LN3';
        W_ER_DESC := 'SP_LOANS-SELECT-CHECK FOR PROD CODE' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     IDX.LNACNT_ACNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END CHECK_PROD_CODE;

    /*
    IF NVL(IDX.LNACNT_RECOV_ACNT_NUM1, 0) <> 0
    THEN
      SELECT IACLINK_INTERNAL_ACNUM
      INTO W_TMP_RECOVACNT
      FROM IACLINK
      WHERE IACLINK_ACTUAL_ACNUM = IDX.LNACNT_RECOV_ACNT_NUM1;
    END IF;
    */
    --Commented by Ramesh M for testing

    --Added by Ramesh M for testing Start
    BEGIN
      IF NVL(IDX.LNACNT_RECOV_ACNT_NUM1, '0') <> '0' THEN
        SELECT IACLINK_INTERNAL_ACNUM
          INTO W_TMP_RECOVACNT
          FROM IACLINK
         WHERE IACLINK_ACTUAL_ACNUM = IDX.LNACNT_RECOV_ACNT_NUM1;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    --Added by Ramesh M for testing End

    <<IN_LOANACNTS>>
    BEGIN
      INSERT INTO LOANACNTS
        (LNACNT_ENTITY_NUM,
         LNACNT_INTERNAL_ACNUM,
         LNACNT_PURPOSE_CODE,
         LNACNT_LAST_AOD_GIVEN_ON,
         LNACNT_NEXT_AOD_DUE_ON,
         LNACNT_DISB_TYPE,
         LNACNT_SUBSIDY_AVAILABLE,
         LNACNT_AUTO_INSTALL_RECOV_REQD,
         LNACNT_RECOV_ACNT_NUM,
         LNACNT_INT_ACCR_UPTO,
         LNACNT_INT_APPLIED_UPTO_DATE,
         LNACNT_PA_ACCR_POSTED_UPTO,
         LNACNT_ENTD_BY,
         LNACNT_ENTD_ON,
         LNACNT_AUTH_BY,
         LNACNT_AUTH_ON)
      VALUES
        (W_ENTITY_NUM,
         W_ACNT_NUM,
         IDX.LNACNT_PURPOSE_CODE,
         IDX.LNACNT_LAST_AOD_GIVEN_ON,
         IDX.LNACNT_NEXT_AOD_DUE_ON,
         IDX.LNACNT_DISB_TYPE,
         NVL(IDX.LNACNT_SUBSIDY_AVAILABLE, 0),
         NVL(IDX.LNACNT_AUTO_INSTALL_RECOV_REQD, 0),
         W_TMP_RECOVACNT, --IDX.LNACNT_RECOV_ACNT_NUM1,
         IDX.LNACNT_INT_ACCR_UPTO,
         IDX.LNACNT_INT_APPLIED_UPTO_DATE,
         NULL,
         W_ENTD_BY,
         W_CURR_DATE,
         W_ENTD_BY,
         W_CURR_DATE);
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'LN4';
        W_ER_DESC := 'SP_LOANS-INSERT-LOANACNTS' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     IDX.LNACNT_ACNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_LOANACNTS;

    <<IN_LOANACHIST>>
    BEGIN
      INSERT INTO LOANACHIST
        (LNACH_ENTITY_NUM,
         LNACH_INTERNAL_ACNUM,
         LNACH_EFF_DATE,
         LNACH_AUTO_INSTALL_RECOV_REQD,
         LNACH_RECOV_ACNT_NUM,
         LNACH_ENTD_BY,
         LNACH_ENTD_ON,
         LNACH_LAST_MOD_BY,
         LNACH_LAST_MOD_ON,
         LNACH_AUTH_BY,
         LNACH_AUTH_ON,
         TBA_MAIN_KEY)
      VALUES
        (W_ENTITY_NUM,
         W_ACNT_NUM,
         W_OPENING_DATE,
         IDX.LNACNT_AUTO_INSTALL_RECOV_REQD,
         W_TMP_RECOVACNT, --IDX.LNACNT_RECOV_ACNT_NUM1,
         W_ENTD_BY,
         W_CURR_DATE,
         NULL,
         NULL,
         W_ENTD_BY,
         W_CURR_DATE,
         NULL);
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'LN5';
        W_ER_DESC := 'SP_LOANS-INSERT-CHECK-LOANACHIST' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     IDX.LNACNT_ACNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_LOANACHIST;

    W_RECOV_SL := 1;

    FOR I IN 1 .. 10 LOOP
      W_TMP_RECOVACNT := NULL;

      IF I = 1 AND IDX.LNACNT_RECOV_ACNT_NUM1 IS NOT NULL THEN
        W_TMP_RECOVACNT := IDX.LNACNT_RECOV_ACNT_NUM1;
      ELSIF I = 2 AND IDX.LNACNT_RECOV_ACNT_NUM2 IS NOT NULL THEN
        W_TMP_RECOVACNT := IDX.LNACNT_RECOV_ACNT_NUM2;
      ELSIF I = 3 AND IDX.LNACNT_RECOV_ACNT_NUM3 IS NOT NULL THEN
        W_TMP_RECOVACNT := IDX.LNACNT_RECOV_ACNT_NUM3;
      ELSIF I = 4 AND IDX.LNACNT_RECOV_ACNT_NUM4 IS NOT NULL THEN
        W_TMP_RECOVACNT := IDX.LNACNT_RECOV_ACNT_NUM4;
      ELSIF I = 5 AND IDX.LNACNT_RECOV_ACNT_NUM5 IS NOT NULL THEN
        W_TMP_RECOVACNT := IDX.LNACNT_RECOV_ACNT_NUM5;
      ELSIF I = 6 AND IDX.LNACNT_RECOV_ACNT_NUM6 IS NOT NULL THEN
        W_TMP_RECOVACNT := IDX.LNACNT_RECOV_ACNT_NUM6;
      ELSIF I = 7 AND IDX.LNACNT_RECOV_ACNT_NUM7 IS NOT NULL THEN
        W_TMP_RECOVACNT := IDX.LNACNT_RECOV_ACNT_NUM7;
      ELSIF I = 8 AND IDX.LNACNT_RECOV_ACNT_NUM8 IS NOT NULL THEN
        W_TMP_RECOVACNT := IDX.LNACNT_RECOV_ACNT_NUM8;
      ELSIF I = 9 AND IDX.LNACNT_RECOV_ACNT_NUM9 IS NOT NULL THEN
        W_TMP_RECOVACNT := IDX.LNACNT_RECOV_ACNT_NUM9;
      ELSIF I = 10 AND IDX.LNACNT_RECOV_ACNT_NUM10 IS NOT NULL THEN
        W_TMP_RECOVACNT := IDX.LNACNT_RECOV_ACNT_NUM10;
      END IF;

      --Added 04-DEC-2010-beg
      --IF W_TMP_RECOVACNT IS NOT NULL
      --ramesh/rashmiIF NVL(W_TMP_RECOVACNT, 0) <> 0
      IF NVL(W_TMP_RECOVACNT, '0') <> '0' THEN
        --rashmi/ramesh
        BEGIN
          W_TMP_RECOVACNT1 := 0;

          SELECT IACLINK_INTERNAL_ACNUM
          --ramesh/rashmiINTO W_TMP_RECOVACNT
            INTO W_TMP_RECOVACNT1
            FROM IACLINK
           WHERE IACLINK_ACTUAL_ACNUM = W_TMP_RECOVACNT;
          --Added 04-DEC-2010-end
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;

        --rashmi/ramesh
        IF W_TMP_RECOVACNT1 <> 0 THEN
          --ramesh/rashmi
          <<IN_LOANACHISTDTL>>
          BEGIN
            INSERT INTO LOANACHISTDTL
              (LNACHDTL_ENTITY_NUM,
               LNACHDTL_INTERNAL_ACNUM,
               LNACHDTL_EFF_DATE,
               LNACHDTL_RECOV_SL_NUM,
               LNACHDTL_RECOV_ACNUM)
            VALUES
              (W_ENTITY_NUM,
               W_ACNT_NUM,
               W_OPENING_DATE,
               W_RECOV_SL,
               --ramesh/rashmiW_TMP_RECOVACNT);
               W_TMP_RECOVACNT1);
          EXCEPTION
            WHEN OTHERS THEN
              W_ER_CODE := 'LN6';
              W_ER_DESC := 'SP_LOANS-INSERT-LOANACHISTDTL' || SQLERRM;
              W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                           IDX.LNACNT_ACNUM;
              POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
          END IN_LOANACHISTDTL;

          <<IN_LOANACDTL>>
          BEGIN
            INSERT INTO LOANACDTL
              (LNACDTL_ENTITY_NUM,
               LNACDTL_INTERNAL_ACNUM,
               LNACDTL_RECOV_SL_NUM,
               LNACDTL_RECOV_ACNUM)
            VALUES --rashmi/ramesh(W_ENTITY_NUM, W_ACNT_NUM, W_RECOV_SL, W_TMP_RECOVACNT);
              (W_ENTITY_NUM, W_ACNT_NUM, W_RECOV_SL, W_TMP_RECOVACNT1);

            W_RECOV_SL := W_RECOV_SL + 1;
          EXCEPTION
            WHEN OTHERS THEN
              W_ER_CODE := 'LN7';
              W_ER_DESC := 'SP_LOANS-SELECT-INSERT LOANACDTL' || SQLERRM;
              W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                           IDX.LNACNT_ACNUM;
              POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
          END IN_LOANACDTL;
        END IF; --ramesh/rashmi
      END IF;
    END LOOP;

    SELECT COUNT(1)
      INTO W_LIMIT_NUM
      FROM CLIENTS
     WHERE CLIENTS_CODE = W_CLIENT_NUM;

    IF W_LIMIT_NUM > 0 THEN
      SELECT MAX(LMTLINE_NUM)
        INTO W_LIMIT_NUM
        FROM LIMITLINE
       WHERE LMTLINE_ENTITY_NUM = W_ENTITY_NUM
         AND LMTLINE_CLIENT_CODE = W_CLIENT_NUM;

      W_LIMIT_NUM := NVL(W_LIMIT_NUM, 0) + 1;
    ELSE
      RAISE MYEXCEPTION;
      P_ERR_MSG   := 'CLIENT NOT FOUND -limit creation failed ';
      W_LIMIT_NUM := 1;
    END IF;

    <<IN_LIMITLINE>>
    BEGIN
      INSERT INTO LIMITLINE
        (LMTLINE_ENTITY_NUM,
         LMTLINE_CLIENT_CODE,
         LMTLINE_NUM,
         LMTLINE_FACILITY_DESCN,
         LMTLINE_CREATION_DATE,
         LMTLINE_APEX_LEVEL_LIMIT,
         LMTLINE_SUB_LIMIT_LINE,
         LMTLINE_SAUTH_CODE,
         LMTLINE_DATE_OF_SANCTION,
         LMTLINE_SANCTION_REF_NUM,
         LMTLINE_LIMIT_EFF_DATE,
         LMTLINE_LIMIT_EXPIRY_DATE,
         LMTLINE_REVOLVING_LIMIT,
         LMTLINE_ADHOC_FACILITY,
         LMTLINE_SHARED_LIMIT_LINE,
         LMTLINE_PROD_CODE,
         LMTLINE_FACILITY_GRP_CODE,
         LMTLINE_SANCTION_CURR,
         LMTLINE_SANCTION_AMT,
         LMTLINE_AUTO_DECREMENT,
         LMTLINE_DECR_FIRST_DATE,
         LMTLINE_DECR_FREQ,
         LMTLINE_DECR_AMT,
         LMTLINE_LIMIT_AVL_ON_DATE,
         LMTLINE_SEC_LIMIT_LINE,
         LMTLINE_SEC_MARGIN,
         LMTLINE_SEC_AMT_REQD,
         LMTLINE_SEC_TYPE_SPECIFIED,
         LMTLINE_DP_REQD,
         LMTLINE_DP_AMT,
         LMTLINE_DP_VALID_UPTO,
         LMTLINE_DUE_DATE_REVIEW,
         LMTLINE_PENAL_EOL_CHARGED,
         LMTLINE_PENAL_EXP_CHARGED,
         LMTLINE_PENAL_RECOV_ACNUM,
         LMTLINE_REM1,
         LMTLINE_REM2,
         LMTLINE_REM3,
         LMTLINE_CANCELLED_DATE,
         LMTLINE_INCR_DECR_UPTO_DATE,
         LMTLINE_MARKED_AMT_OUT,
         LMTLINE_MARKED_AMT_INTO,
         LMTLINE_EARMARK_UNAUTH,
         LMTLINE_ENTD_BY,
         LMTLINE_ENTD_ON,
         LMTLINE_LAST_MOD_BY,
         LMTLINE_LAST_MOD_ON,
         LMTLINE_AUTH_BY,
         LMTLINE_AUTH_ON,
         TBA_MAIN_KEY,
         LMTLINE_HOME_BRANCH)
      VALUES
        (W_ENTITY_NUM,
         W_CLIENT_NUM, --LMTLINE_CLIENT_CODE,
         W_LIMIT_NUM, --LMTLINE_NUM,
         W_PROD_NAME, --LMTLINE_FACILITY_DESCN,
         W_OPENING_DATE, --LMTLINE_CREATION_DATE,
         1, --LMTLINE_APEX_LEVEL_LIMIT,
         0, --LMTLINE_SUB_LIMIT_LINE,
         IDX.LNACNT_SAUTH_CODE, --LMTLINE_SAUTH_CODE,
         IDX.LNACNT_LIMIT_SANCTION_DATE, --LMTLINE_DATE_OF_SANCTION,
         IDX.LNACNT_LIMIT_SANCTION_REF_NUM, --LMTLINE_SANCTION_REF_NUM,
         W_OPENING_DATE, --W_CURR_DATE, --LMTLINE_LIMIT_EFF_DATE,
         IDX.LNACNT_LIMIT_EXPIRY_DATE, --LMTLINE_LIMIT_EXPIRY_DATE,
         IDX.LNACNT_REVOLVING_LIMIT, --LMTLINE_REVOLVING_LIMIT,
         0, --LMTLINE_ADHOC_FACILITY,
         0, --LMTLINE_SHARED_LIMIT_LINE,
         W_PROD_CODE, --LMTLINE_PROD_CODE,
         NULL, -- FACILTIY GROUP CODE --LMTLINE_FACILITY_GRP_CODE,
         IDX.LNACNT_SANCTION_CURR, --LMTLINE_SANCTION_CURR,
         IDX.LNACNT_SANCTION_AMT, --LMTLINE_SANCTION_AMT,
         0, --LMTLINE_AUTO_DECREMENT,
         NULL, --LMTLINE_DECR_FIRST_DATE,
         NULL, --LMTLINE_DECR_FREQ,
         NULL, --LMTLINE_DECR_AMT,
         IDX.LNACNT_LIMIT_AVL_ON_DATE, --LMTLINE_LIMIT_AVL_ON_DATE,
         IDX.LNACNT_SEC_LIMIT_LINE, --LMTLINE_SEC_LIMIT_LINE,
         NULL, --LMTLINE_SEC_MARGIN,
         IDX.LNACNT_SEC_AMT_REQD, --LMTLINE_SEC_AMT_REQD,
         IDX.LNACNT_SEC_TYPE_SPECIFIED, --LMTLINE_SEC_TYPE_SPECIFIED,
         NULL, --LMTLINE_DP_REQD,
         NULL, --LMTLINE_DP_AMT,
         NULL, --LMTLINE_DP_VALID_UPTO,
         NULL, --LMTLINE_DUE_DATE_REVIEW,
         NULL, --LMTLINE_PENAL_EOL_CHARGED,
         NULL, --LMTLINE_PENAL_EXP_CHARGED,
         NULL, --LMTLINE_PENAL_RECOV_ACNUM,
         'LIMIT MIG', --LMTLINE_REM1,
         NULL, --LMTLINE_REM2,
         NULL, --LMTLINE_REM3,
         NULL, --LMTLINE_CANCELLED_DATE,
         NULL, --LMTLINE_INCR_DECR_UPTO_DATE,
         NULL, --LMTLINE_MARKED_AMT_OUT,
         NULL, --LMTLINE_MARKED_AMT_INTO,
         NULL, --LMTLINE_EARMARK_UNAUTH,
         W_ENTD_BY, --LMTLINE_ENTD_BY,
         W_OPENING_DATE, --W_CURR_DATE, --LMTLINE_ENTD_ON,
         NULL, --LMTLINE_LAST_MOD_BY,
         NULL, --LMTLINE_LAST_MOD_ON,
         W_ENTD_BY, --LMTLINE_AUTH_BY,
         W_OPENING_DATE, --W_CURR_DATE, --LMTLINE_AUTH_ON,
         NULL, --TBA_MAIN_KEY,
         P_BRANCH_CODE
         );
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'LN8';
        W_ER_DESC := 'SP_LOANS-INSERT LIMITLINE' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     IDX.LNACNT_ACNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_LIMITLINE;

    <<IN_ACASLL>>
    BEGIN
      INSERT INTO ACASLL
        (ACASLL_ENTITY_NUM,
         ACASLL_CLIENT_NUM,
         ACASLL_LIMIT_LINE_NUM,
         ACASLL_DATE_OF_ASSIGNMENT,
         ACASLL_REM1,
         ACASLL_REM2,
         ACASLL_REM3,
         ACASLL_ENTD_BY,
         ACASLL_ENTD_ON,
         ACASLL_LAST_MOD_BY,
         ACASLL_LAST_MOD_ON,
         ACASLL_AUTH_BY,
         ACASLL_AUTH_ON,
         TBA_MAIN_KEY)
      VALUES
        (W_ENTITY_NUM,
         W_CLIENT_NUM,
         W_LIMIT_NUM,
         W_OPENING_DATE, --W_CURR_DATE,
         NULL,
         NULL,
         NULL,
         W_ENTD_BY,
         W_OPENING_DATE, --W_CURR_DATE,
         NULL,
         NULL,
         W_ENTD_BY,
         W_OPENING_DATE, --W_CURR_DATE,
         NULL);
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'LN9';
        W_ER_DESC := 'SP_LOANS-SELECT-INSERT ACASLL' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     IDX.LNACNT_ACNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_ACASLL;

    <<IN_ACASLLDTL>>
    BEGIN
      INSERT INTO ACASLLDTL
        (ACASLLDTL_ENTITY_NUM,
         ACASLLDTL_CLIENT_NUM,
         ACASLLDTL_LIMIT_LINE_NUM,
         ACASLLDTL_ACNT_SL,
         ACASLLDTL_INTERNAL_ACNUM)
      VALUES
        (W_ENTITY_NUM, W_CLIENT_NUM, W_LIMIT_NUM, W_SL, W_ACNT_NUM);
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'LN10';
        W_ER_DESC := 'SP_LOANS-INSERT ACASLLDTL' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     IDX.LNACNT_ACNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_ACASLLDTL;

    -- Added By Abdullah Al Qayum
    --Dhaka SPFTL
    --INSERT INTO LLACNTOS
    <<IN_LLACNTOS>>
    BEGIN
      INSERT INTO LLACNTOS
        (LLACNTOS_ENTITY_NUM,
         LLACNTOS_CLIENT_CODE,
         LLACNTOS_LIMIT_LINE_NUM,
         LLACNTOS_CLIENT_ACNUM,
         LLACNTOS_LIMIT_CURR_OS_AMT,
         LLACNTOS_LIMIT_CURR_DISB_MADE)
      VALUES
        (W_ENTITY_NUM,
         W_CLIENT_NUM,
         W_LIMIT_NUM,
         W_ACNT_NUM,
         NVL(IDX.LNACNT_OUTSTANDING_BALANCE, 0),
         NVL(IDX.LNACNT_LIMIT_CURR_DISB_MADE, 0));
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'LN10.1';
        W_ER_DESC := 'SP_LOANS-INSERT LLACNTOS' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     IDX.LNACNT_ACNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_LLACNTOS;

    <<IN_LIMITLINEHIST>>
    BEGIN
      INSERT INTO LIMITLINEHIST
        (LIMLNEHIST_ENTITY_NUM,
         LIMLNEHIST_CLIENT_CODE,
         LIMLNEHIST_LIMIT_LINE_NUM,
         LIMLNEHIST_EFF_DATE,
         LIMLNEHIST_SAUTH_CODE,
         LIMLNEHIST_DATE_OF_SANCTION,
         LIMLNEHIST_SANCTION_REF_NUM,
         LIMLNEHIST_SANCTION_CURR,
         LIMLNEHIST_SANCTION_AMT,
         LIMLNEHIST_LIMIT_AVL_ON_DATE,
         LIMLNEHIST_LIMIT_EXPIRY_DATE,
         LIMLNEHIST_REM1,
         LIMLNEHIST_REM2,
         LIMLNEHIST_REM3,
         LIMLNEHIST_ENTD_BY,
         LIMLNEHIST_ENTD_ON,
         LIMLNEHIST_LAST_MOD_BY,
         LIMLNEHIST_LAST_MOD_ON,
         LIMLNEHIST_AUTH_BY,
         LIMLNEHIST_AUTH_ON,
         TBA_MAIN_KEY,
         LIMLNEHIST_HOME_BRANCH)
      VALUES
        (W_ENTITY_NUM,
         W_CLIENT_NUM,
         W_LIMIT_NUM,
         W_OPENING_DATE, --W_CURR_DATE,
         IDX.LNACNT_SAUTH_CODE,
         IDX.LNACNT_LIMIT_SANCTION_DATE,
         IDX.LNACNT_LIMIT_SANCTION_REF_NUM,
         IDX.LNACNT_SANCTION_CURR,
         IDX.LNACNT_SANCTION_AMT,
         IDX.LNACNT_LIMIT_AVL_ON_DATE,
         IDX.LNACNT_LIMIT_EXPIRY_DATE,
         NULL,
         NULL,
         NULL,
         W_ENTD_BY,
         W_OPENING_DATE, --W_CURR_DATE,
         NULL,
         NULL,
         W_ENTD_BY,
         W_OPENING_DATE, --W_CURR_DATE,
         NULL,
         P_BRANCH_CODE);
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'LN11';
        W_ER_DESC := 'SP_LOANS-INSERT LIMITLINEHIST' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     IDX.LNACNT_ACNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_LIMITLINEHIST;

    <<IN_LIMFACCURR>>
    BEGIN
      INSERT INTO LIMFACCURR
        (LFCURR_ENTITY_NUM,
         LFCURR_CLIENT_NUM,
         LFCURR_LIMIT_LINE_NUM,
         LFCURR_CURR_CODE)
      VALUES
        (W_ENTITY_NUM, W_CLIENT_NUM, W_LIMIT_NUM, IDX.LNACNT_SANCTION_CURR);
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'LN12';
        W_ER_DESC := 'SP_LOANS-INSERT LIMFACCURR' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     IDX.LNACNT_ACNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_LIMFACCURR;

    <<IN_LIMITLINEAUX>>
    BEGIN
      INSERT INTO LIMITLINEAUX
        (LMTLINEAUX_ENTITY_NUM,
         LMTLINEAUX_CLIENT_CODE,
         LMTLINEAUX_NUM,
         LMTLINEAUX_DP_CALC_ON,
         LMTLINEAUX_DP_CIELING_AMT)
      VALUES
        (W_ENTITY_NUM, W_CLIENT_NUM, W_LIMIT_NUM, NULL, NULL);
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'LN13';
        W_ER_DESC := 'SP_LOANS-INSERT LIMITLINEAUX' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     IDX.LNACNT_ACNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_LIMITLINEAUX;

    <<IN_ASSETCLS>>
    BEGIN
      INSERT INTO ASSETCLS
        (ASSETCLS_ENTITY_NUM,
         ASSETCLS_INTERNAL_ACNUM,
         ASSETCLS_LATEST_EFF_DATE,
         ASSETCLS_ASSET_CODE,
         ASSETCLS_NPA_DATE,
         ASSETCLS_AUTO_MAN_FLG,
         ASSETCLS_REMARKS)
      VALUES
        (W_ENTITY_NUM,
         W_ACNT_NUM,
         W_CURR_DATE,
         IDX.LNACNT_ASSET_STAT,
         IDX.LNACNT_DATE_OF_NPA,
         'A',
         'MIGRATION');
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'LN14';
        W_ER_DESC := 'SP_LOANS-INSERT ASSETCLS' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     IDX.LNACNT_ACNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_ASSETCLS;

    <<IN_ASSETCLSHIST>>
    BEGIN
      EXECUTE IMMEDIATE 'INSERT INTO ASSETCLSHIST
        (ASSETCLSH_ENTITY_NUM,ASSETCLSH_INTERNAL_ACNUM,
         ASSETCLSH_EFF_DATE,
         ASSETCLSH_ASSET_CODE,
         ASSETCLSH_NPA_DATE,
         ASSETCLSH_AUTO_MAN_FLG,
         ASSETCLSH_REMARKS,
         ASSETCLSH_ENTD_BY,
         ASSETCLSH_ENTD_ON,
         ASSETCLSH_LAST_MOD_BY,
         ASSETCLSH_LAST_MOD_ON,
         ASSETCLSH_AUTH_BY,
         ASSETCLSH_AUTH_ON,
         TBA_MAIN_KEY)
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
         :13,:14)'
        USING W_ENTITY_NUM, W_ACNT_NUM, W_CURR_DATE, IDX.LNACNT_ASSET_STAT, IDX.LNACNT_DATE_OF_NPA, 'A', 'MIGRATION', W_ENTD_BY, W_CURR_DATE, W_NULL, W_NULL, W_ENTD_BY, W_CURR_DATE, W_NULL;
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'LN15';
        W_ER_DESC := 'SP_LOANS-INSERT ASSETCLS' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     IDX.LNACNT_ACNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_ASSETCLSHIST;

    <<IN_LNACAODHIST>>
    BEGIN
      EXECUTE IMMEDIATE 'INSERT INTO LNACAODHIST
        (LNACAODH_ENTITY_NUM,LNACAODH_INTERNAL_ACNUM,
         LNACAODH_AOD_BY,
         LNACAODH_GUAR_SL,
         LNACAODH_ENTRY_DATE,
         LNACAODH_AOD_DATE,
         LNACAODH_NEXT_AOD_DUE_DATE,
         LNACAODH_REMARKS1,
         LNACAODH_REMARKS2,
         LNACAODH_REMARKS3,
         LNACAODH_ENTD_BY,
         LNACAODH_ENTD_ON,
         LNACAODH_LAST_MOD_BY,
         LNACAODH_LAST_MOD_ON,
         LNACAODH_AUTH_BY,
         LNACAODH_AUTH_ON,
         TBA_MAIN_KEY)
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
         :16,:17)'
        USING W_ENTITY_NUM, W_ACNT_NUM, 'B', 1, W_CURR_DATE, IDX.LNACNT_AOD_GIVEN_ON, IDX.LNACNT_NEXT_AOD_DUE_ON, 'MIGRATION', W_NULL, W_NULL, W_ENTD_BY, W_CURR_DATE, W_NULL, W_NULL, W_ENTD_BY, W_CURR_DATE, W_NULL;
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'LN16';
        W_ER_DESC := 'SP_LOANS-INSERT LNACAODHIST' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     IDX.LNACNT_ACNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_LNACAODHIST;

    --S.Karthik-31-AUG-2010-Beg
    IF NVL(IDX.LNACNT_INT_APPL_DISABLED, 0) = 1 THEN
      INSERT INTO LNACINTCTL
        (LNACINTCTL_ENTITY_NUM,
         LNACINTCTL_INTERNAL_ACNUM,
         LNACINTCTL_LATEST_EFF_DATE,
         LNACINTCTL_INT_ACCRUAL_REQD,
         LNACINTCTL_INT_APPL_REQD,
         LNACINTCTL_REMARKS1,
         LNACINTCTL_REMARKS2)
      VALUES
        (W_ENTITY_NUM,
         W_ACNT_NUM,
         IDX.LNACNT_INT_DISABLED_DATE,
         0,
         0,
         'INTEREST ACCR APPL DISABLED',
         'MIGRATION');

      INSERT INTO LNACINTCTLHIST
        (LNACINTCTLH_ENTITY_NUM,
         LNACINTCTLH_INTERNAL_ACNUM,
         LNACINTCTLH_EFF_DATE,
         LNACINTCTLH_INT_ACCRUAL_REQD,
         LNACINTCTLH_INT_APPL_REQD,
         LNACINTCTLH_REMARKS1,
         LNACINTCTLH_REMARKS2,
         LNACINTCTLH_REMARKS3,
         LNACINTCTLH_ENTD_BY,
         LNACINTCTLH_ENTD_ON,
         LNACINTCTLH_AUTH_BY,
         LNACINTCTLH_AUTH_ON)
      VALUES
        (W_ENTITY_NUM,
         W_ACNT_NUM,
         IDX.LNACNT_INT_DISABLED_DATE,
         0,
         0,
         'INTEREST ACCR APPL DISABLED',
         'MIGRATION',
         'M',
         W_ENTD_BY,
         IDX.LNACNT_INT_DISABLED_DATE,
         W_ENTD_BY,
         IDX.LNACNT_INT_DISABLED_DATE);
    END IF;
    --S.Karthik-31-AUG-2010-End
  /*
                                                       W_COLL_SL := 1;
                                                       IF IDX.LNACNT_SEC_TYPE_SPECIFIED = 1
                                                       THEN
                                                         FOR I IN 1 .. 10 LOOP
                                                           W_COLL_TYPE := NULL;
                                                           W_COLL_CURR := NULL;
                                                           W_COLL_AMT  := 0;
                                                           IF I = 1
                                                              AND IDX.LNACNT_COLLAT_TYPE1 IS NOT NULL
                                                           THEN
                                                             W_COLL_TYPE := IDX.LNACNT_COLLAT_TYPE1;
                                                             W_COLL_CURR := IDX.LNACNT_COLLAT_AMT_CURR1;
                                                             W_COLL_AMT  := IDX.LNACNT_COLLAT_AMT_1;
                                                           ELSIF I = 2
                                                                 AND IDX.LNACNT_COLLAT_TYPE2 IS NOT NULL
                                                           THEN
                                                             W_COLL_TYPE := IDX.LNACNT_COLLAT_TYPE2;
                                                             W_COLL_CURR := IDX.LNACNT_COLLAT_AMT_CURR2;
                                                             W_COLL_AMT  := IDX.LNACNT_COLLAT_AMT_2;
                                                           ELSIF I = 3
                                                                 AND IDX.LNACNT_COLLAT_TYPE3 IS NOT NULL
                                                           THEN
                                                             W_COLL_TYPE := IDX.LNACNT_COLLAT_TYPE3;
                                                             W_COLL_CURR := IDX.LNACNT_COLLAT_AMT_CURR3;
                                                             W_COLL_AMT  := IDX.LNACNT_COLLAT_AMT_3;
                                                           ELSIF I = 4
                                                                 AND IDX.LNACNT_COLLAT_TYPE4 IS NOT NULL
                                                           THEN
                                                             W_COLL_TYPE := IDX.LNACNT_COLLAT_TYPE4;
                                                             W_COLL_CURR := IDX.LNACNT_COLLAT_AMT_CURR4;
                                                             W_COLL_AMT  := IDX.LNACNT_COLLAT_AMT_4;
                                                           ELSIF I = 5
                                                                 AND IDX.LNACNT_COLLAT_TYPE5 IS NOT NULL
                                                           THEN
                                                             W_COLL_TYPE := IDX.LNACNT_COLLAT_TYPE5;
                                                             W_COLL_CURR := IDX.LNACNT_COLLAT_AMT_CURR5;
                                                             W_COLL_AMT  := IDX.LNACNT_COLLAT_AMT_5;
                                                           ELSIF I = 6
                                                                 AND IDX.LNACNT_COLLAT_TYPE6 IS NOT NULL
                                                           THEN
                                                             W_COLL_TYPE := IDX.LNACNT_COLLAT_TYPE6;
                                                             W_COLL_CURR := IDX.LNACNT_COLLAT_AMT_CURR6;
                                                             W_COLL_AMT  := IDX.LNACNT_COLLAT_AMT_6;
                                                           ELSIF I = 7
                                                                 AND IDX.LNACNT_COLLAT_TYPE7 IS NOT NULL
                                                           THEN
                                                             W_COLL_TYPE := IDX.LNACNT_COLLAT_TYPE7;
                                                             W_COLL_CURR := IDX.LNACNT_COLLAT_AMT_CURR7;
                                                             W_COLL_AMT  := IDX.LNACNT_COLLAT_AMT_7;
                                                           ELSIF I = 8
                                                                 AND IDX.LNACNT_COLLAT_TYPE8 IS NOT NULL
                                                           THEN
                                                             W_COLL_TYPE := IDX.LNACNT_COLLAT_TYPE8;
                                                             W_COLL_CURR := IDX.LNACNT_COLLAT_AMT_CURR8;
                                                             W_COLL_AMT  := IDX.LNACNT_COLLAT_AMT_8;
                                                           ELSIF I = 9
                                                                 AND IDX.LNACNT_COLLAT_TYPE9 IS NOT NULL
                                                           THEN
                                                             W_COLL_TYPE := IDX.LNACNT_COLLAT_TYPE9;
                                                             W_COLL_CURR := IDX.LNACNT_COLLAT_AMT_CURR9;
                                                             W_COLL_AMT  := IDX.LNACNT_COLLAT_AMT_9;
                                                           ELSIF I = 10
                                                                 AND IDX.LNACNT_COLLAT_TYPE10 IS NOT NULL
                                                           THEN
                                                             W_COLL_TYPE := IDX.LNACNT_COLLAT_TYPE10;
                                                             W_COLL_CURR := IDX.LNACNT_COLLAT_AMT_CURR10;
                                                             W_COLL_AMT  := IDX.LNACNT_COLLAT_AMT_10;
                                                           END IF;

                                                           IF W_COLL_TYPE <> '000'
                                                           THEN
                                                             <<IN_LIMITLINECTREQ>>
                                                             BEGIN
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
                                                                  W_CLIENT_NUM,
                                                                  W_LIMIT_NUM,
                                                                  W_COLL_SL,
                                                                  W_COLL_TYPE,
                                                                  NVL(W_COLL_CURR, W_CURR_CODE),
                                                                  W_COLL_AMT);
                                                             EXCEPTION
                                                               WHEN OTHERS THEN
                                                                 W_ER_CODE := 'LN17';
                                                                 W_ER_DESC := 'SP_LOANS-INSERT LIMITLINECTREQ' || SQLERRM;
                                                                 W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                                                                              IDX.LNACNT_ACNUM;
                                                                 POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
                                                             END IN_LIMITLINECTREQ;
                                                             W_COLL_SL := W_COLL_SL + 1;
                                                           END IF;
                                                         END LOOP;
                                                       END IF;
                                                     */
  END LOOP;

  <<IN_LIMITSERIAL>>
  BEGIN
    INSERT INTO LIMITSERIAL
      (LMTSL_ENTITY_NUM, LMTSL_CLIENT_CODE, LMTSL_LAST_SL)
      SELECT W_ENTITY_NUM, LMTLINE_CLIENT_CODE, MAX(LIMITLINE.LMTLINE_NUM)
        FROM LIMITLINE
       WHERE LMTLINE_ENTITY_NUM = W_ENTITY_NUM
       GROUP BY LMTLINE_CLIENT_CODE;
  EXCEPTION
    WHEN OTHERS THEN
      W_ER_CODE := 'LN18';
      W_ER_DESC := 'SP_LOANS-INSERT LIMITSERIAL' || SQLERRM;
      W_SRC_KEY := P_BRANCH_CODE || 'BULK INSERT';
      POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
  END IN_LIMITSERIAL;

  FOR GDX IN (SELECT LNACGUAR_ACNUM LNGUAR_ACNUM,
                     ROW_NUMBER() OVER(PARTITION BY LNACGUAR_ACNUM ORDER BY LNACGUAR_ACNUM) LNGUAR_SL_NUM,
                     LNACGUAR_BRN_CODE LNGUAR_BRN_CODE,
                     LNACGUAR_CLIENT_NUM LNGUAR_CLIENT_NUM,
                     LNGUAR_GUAR_COOBLIGANT,
                     LNACGUAR_TYPE_OF_GUARANTEE LNGUAR_TYPE_OF_GUARANTEE,
                     LNGUAR_RELATION_CODE,
                     LNGUAR_LAST_AOD_GIVEN_ON,
                     LNGUAR_NEXT_AOD_DUE_ON,
                     LNGUAR_REMARKS1,
                     LNGUAR_REMARKS2,
                     LNGUAR_REMARKS3,
                     LNGUAR_ENTD_BY,
                     LNGUAR_ENTD_ON
                FROM MIG_LNACGUAR) LOOP
    W_ER_CODE := NULL;
    FETCH_ACNUM(P_BRANCH_CODE,
                GDX.LNGUAR_ACNUM,
                'LN19',
                'MIG_LNACGUAR GETOTN ');

    IF W_ER_CODE IS NOT NULL THEN
      RAISE MYEXCEPTION;
    END IF;

    <<GU1>>
    BEGIN
      EXECUTE IMMEDIATE 'select temp_client.new_clcode from temp_client where old_clcode =:1'
        INTO W_GURAN_CLIENTNUM
        USING GDX.LNGUAR_CLIENT_NUM;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        W_ER_CODE := 'LN50';
        W_ER_DESC := 'GUARTOR CLIENT NOT FOUND ' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     GDX.LNGUAR_ACNUM || ' CLIENT ' ||
                     GDX.LNGUAR_CLIENT_NUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END GU1;

    IF W_ER_CODE IS NULL THEN
      <<IN_LNACGUAR>>
      BEGIN
        EXECUTE IMMEDIATE 'INSERT INTO LNACGUAR
        (LNGUAR_ENTITY_NUM,LNGUAR_INTERNAL_ACNUM,
         LNGUAR_SL_NUM,
         LNGUAR_GUAR_COOBLIGANT,
         LNGUAR_GUAR_CLIENT_CODE,
         LNGUAR_TYPE_OF_GUARANTEE,
         LNGUAR_RELATION_CODE,
         LNGUAR_LAST_AOD_GIVEN_ON,
         LNGUAR_NEXT_AOD_DUE_ON,
         LNGUAR_RELEASED_ON,
         LNGUAR_REMARKS1,
         LNGUAR_REMARKS2,
         LNGUAR_REMARKS3,
         LNGUAR_ENTD_BY,
         LNGUAR_ENTD_ON,
         LNGUAR_LAST_MOD_BY,
         LNGUAR_LAST_MOD_ON,
         LNGUAR_AUTH_BY,
         LNGUAR_AUTH_ON,
         TBA_MAIN_KEY)
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
         :19,:20)'
          USING W_ENTITY_NUM, W_ACNT_NUM, GDX.LNGUAR_SL_NUM, GDX.LNGUAR_GUAR_COOBLIGANT, W_GURAN_CLIENTNUM, --W_CLIENT_NUM,-- GDX.LNGUAR_CLIENT_NUM,
        GDX.LNGUAR_TYPE_OF_GUARANTEE, GDX.LNGUAR_RELATION_CODE, GDX.LNGUAR_LAST_AOD_GIVEN_ON, GDX.LNGUAR_NEXT_AOD_DUE_ON, W_NULL, GDX.LNGUAR_REMARKS1, GDX.LNGUAR_REMARKS2, NVL(GDX.LNGUAR_REMARKS3, 'MIGRATION'), W_ENTD_BY, W_CURR_DATE, W_NULL, W_NULL, W_ENTD_BY, W_CURR_DATE, W_NULL;
      EXCEPTION
        WHEN OTHERS THEN
          W_ER_CODE := 'LN19';
          W_ER_DESC := 'SP_LOANS-INSERT LNACGUAR' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                       GDX.LNGUAR_ACNUM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END IN_LNACGUAR;

      <<IN_LNACAODHIST>>
      BEGIN
        INSERT INTO LNACAODHIST
          (LNACAODH_ENTITY_NUM,
           LNACAODH_INTERNAL_ACNUM,
           LNACAODH_AOD_BY,
           LNACAODH_GUAR_SL,
           LNACAODH_ENTRY_DATE,
           LNACAODH_AOD_DATE,
           LNACAODH_NEXT_AOD_DUE_DATE,
           LNACAODH_REMARKS1,
           LNACAODH_REMARKS2,
           LNACAODH_REMARKS3,
           LNACAODH_ENTD_BY,
           LNACAODH_ENTD_ON,
           LNACAODH_LAST_MOD_BY,
           LNACAODH_LAST_MOD_ON,
           LNACAODH_AUTH_BY,
           LNACAODH_AUTH_ON,
           TBA_MAIN_KEY)
        VALUES
          (W_ENTITY_NUM,
           W_ACNT_NUM,
           'G',
           GDX.LNGUAR_SL_NUM,
           W_CURR_DATE,
           GDX.LNGUAR_LAST_AOD_GIVEN_ON,
           GDX.LNGUAR_NEXT_AOD_DUE_ON,
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
          W_ER_CODE := 'LN20';
          W_ER_DESC := 'SP_LOANS-INSERT LNACAODSHIST' || SQLERRM;
          W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                       GDX.LNGUAR_ACNUM;
          POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END IN_LNACAODHIST;
    END IF;
  END LOOP;

  FOR CDX IN (SELECT LNACIRS_ACNUM,
                     LNACIRS_EFF_DATE,
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
                     LNACIRS_AMT_SLABS_REQD,
                     LNACIRS_APPL_INT_RATE,
                     LNACIRS_UPTO_AMT1,
                     LNACIRS_INT_RATE1,
                     LNACIRS_UPTO_AMT2,
                     LNACIRS_INT_RATE2,
                     LNACIRS_UPTO_AMT3,
                     LNACIRS_INT_RATE3,
                     LNACIRS_UPTO_AMT4,
                     LNACIRS_INT_RATE4,
                     LNACIRS_UPTO_AMT5,
                     LNACIRS_INT_RATE5
                FROM MIG_LNACIRS) LOOP
    FETCH_ACNUM(P_BRANCH_CODE,
                CDX.LNACIRS_ACNUM,
                'LN21',
                'MIG_LNACIRS GETOTN ');

    <<IN_LNACIRSHIST>>
    BEGIN
      INSERT INTO LNACIRSHIST
        (LNACIRSH_ENTITY_NUM,
         LNACIRSH_INTERNAL_ACNUM,
         LNACIRSH_EFF_DATE,
         LNACIRSH_AC_LEVEL_INT_REQD,
         LNACIRSH_FIXED_FLOATING_RATE,
         LNACIRSH_STD_INT_RATE_TYPE,
         LNACIRSH_DIFF_INT_RATE_CHOICE,
         LNACIRSH_DIFF_INT_RATE,
         LNACIRSH_TENOR_SLAB_CODE,
         LNACIRSH_TENOR_SLAB_SL,
         LNACIRSH_AMT_SLAB_CODE,
         LNACIRSH_AMT_SLAB_SL,
         LNACIRSH_OD_INT_APPLICABLE,
         LNACIRSH_REMARKS1,
         LNACIRSH_REMARKS2,
         LNACIRSH_REMARKS3,
         LNACIRSH_ENTD_BY,
         LNACIRSH_ENTD_ON,
         LNACIRSH_LAST_MOD_BY,
         LNACIRSH_LAST_MOD_ON,
         LNACIRSH_AUTH_BY,
         LNACIRSH_AUTH_ON,
         TBA_MAIN_KEY)
      VALUES
        (W_ENTITY_NUM,
         W_ACNT_NUM,
         CDX.LNACIRS_EFF_DATE,
         CDX.LNACIRS_AC_LEVEL_INT_REQD,
         CDX.LNACIRS_FIXED_FLOATING_RATE,
         CDX.LNACIRS_STD_INT_RATE_TYPE,
         CDX.LNACIRS_DIFF_INT_RATE_CHOICE,
         CDX.LNACIRS_DIFF_INT_RATE,
         CDX.LNACIRS_TENOR_SLAB_CODE,
         CDX.LNACIRS_TENOR_SLAB_SL,
         CDX.LNACIRS_AMT_SLAB_CODE,
         CDX.LNACIRS_AMT_SLAB_SL,
         CDX.LNACIRS_OVERDUE_INT_APPLICABLE,
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
        W_ER_CODE := 'LN23';
        W_ER_DESC := 'SP_LOANS-INSERT-LNACIRSHIST' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     CDX.LNACIRS_ACNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_LNACIRSHIST;

    -- RAMESH M TESTING
    BEGIN
      --RAMESH/RASHMI
      INSERT INTO LNACIRHIST
        (LNACIRH_ENTITY_NUM,
         LNACIRH_INTERNAL_ACNUM,
         LNACIRH_EFF_DATE,
         LNACIRH_AMT_SLABS_REQD,
         LNACIRH_SLAB_APPL_CHOICE,
         LNACIRH_APPL_INT_RATE,
         LNACIRH_BACK_DATED_ENTRY,
         LNACIRH_RECALC_INT_APPL_DATE,
         LNACIRH_REMARKS1,
         LNACIRH_REMARKS2,
         LNACIRH_REMARKS3,
         LNACIRH_ENTD_BY,
         LNACIRH_ENTD_ON,
         LNACIRH_AUTH_BY,
         LNACIRH_AUTH_ON)
      VALUES
        (W_ENTITY_NUM,
         W_ACNT_NUM,
         CDX.LNACIRS_EFF_DATE,
         CDX.LNACIRS_AMT_SLABS_REQD,
         1,
         DECODE(CDX.LNACIRS_AMT_SLABS_REQD,
                '0',
                CDX.LNACIRS_APPL_INT_RATE,
                '1',
                0),
         NULL,
         NULL,
         'MIGRATION',
         NULL,
         NULL,
         W_ENTD_BY,
         W_CURR_DATE,
         W_ENTD_BY,
         W_CURR_DATE);
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'LNHIS';
        W_ER_DESC := 'SP_LOANS-INSERT-LNACIRSHIST' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     CDX.LNACIRS_ACNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END;

    --COMMENTED BY RAMESH TESTING
    IF CDX.LNACIRS_AMT_SLABS_REQD = 1 THEN
      IF NVL(CDX.LNACIRS_UPTO_AMT1, 0) <> 0 THEN
        INSERT_LNACIR(W_ACNT_NUM,
                      CDX.LNACIRS_EFF_DATE,
                      1,
                      CDX.LNACIRS_UPTO_AMT1,
                      CDX.LNACIRS_INT_RATE1);
      END IF;

      IF NVL(CDX.LNACIRS_UPTO_AMT2, 0) <> 0 THEN
        INSERT_LNACIR(W_ACNT_NUM,
                      CDX.LNACIRS_EFF_DATE,
                      2,
                      CDX.LNACIRS_UPTO_AMT2,
                      CDX.LNACIRS_INT_RATE2);
      END IF;

      IF NVL(CDX.LNACIRS_UPTO_AMT3, 0) <> 0 THEN
        INSERT_LNACIR(W_ACNT_NUM,
                      CDX.LNACIRS_EFF_DATE,
                      3,
                      CDX.LNACIRS_UPTO_AMT3,
                      CDX.LNACIRS_INT_RATE3);
      END IF;

      IF NVL(CDX.LNACIRS_UPTO_AMT4, 0) <> 0 THEN
        INSERT_LNACIR(W_ACNT_NUM,
                      CDX.LNACIRS_EFF_DATE,
                      4,
                      CDX.LNACIRS_UPTO_AMT4,
                      CDX.LNACIRS_INT_RATE4);
      END IF;

      IF NVL(CDX.LNACIRS_UPTO_AMT5, 0) <> 0 THEN
        INSERT_LNACIR(W_ACNT_NUM,
                      CDX.LNACIRS_EFF_DATE,
                      5,
                      CDX.LNACIRS_UPTO_AMT5,
                      CDX.LNACIRS_INT_RATE5);
      END IF;
    END IF;
  END LOOP;

  --rashmi/ramesh
  BEGIN
    INSERT INTO LNACIR
      (LNACIR_ENTITY_NUM,
       LNACIR_INTERNAL_ACNUM,
       LNACIR_LATEST_EFF_DATE,
       LNACIR_AMT_SLABS_REQD,
       LNACIR_SLAB_APPL_CHOICE,
       LNACIR_APPL_INT_RATE,
       LNACIR_BACK_DATED_ENTRY,
       LNACIR_RECALC_INT_APPL_DATE,
       LNACIR_REMARKS1,
       LNACIR_REMARKS2,
       LNACIR_REMARKS3)
      SELECT W_ENTITY_NUM,
             LNACIRH_INTERNAL_ACNUM,
             LNACIRH_EFF_DATE,
             LNACIRH_AMT_SLABS_REQD,
             LNACIRH_SLAB_APPL_CHOICE,
             LNACIRH_APPL_INT_RATE,
             LNACIRH_BACK_DATED_ENTRY,
             LNACIRH_RECALC_INT_APPL_DATE,
             'MIGRATION',
             NULL,
             NULL
        FROM LNACIRHIST
       WHERE (LNACIRH_INTERNAL_ACNUM, LNACIRH_EFF_DATE) IN
             (SELECT LNACIRH_INTERNAL_ACNUM, MAX(LNACIRH_EFF_DATE)
                FROM LNACIRHIST
               GROUP BY LNACIRH_INTERNAL_ACNUM);
  EXCEPTION
    --rashmi
    WHEN OTHERS THEN
      NULL;
  END;

  BEGIN
    --rashmi
    INSERT INTO LNACIRDTL
      (LNACIRDTL_ENTITY_NUM,
       LNACIRDTL_INTERNAL_ACNUM,
       LNACIRDTL_SL_NUM,
       LNACIRDTL_APPL_UPTO_AMT,
       LNACIRDTL_INT_RATE)
      SELECT W_ENTITY_NUM,
             LNACIRHDTL_INTERNAL_ACNUM,
             1,
             LNACIRHDTL_APPL_UPTO_AMT,
             LNACIRHDTL_INT_RATE
        FROM LNACIRHDTL
       WHERE (LNACIRHDTL_INTERNAL_ACNUM, LNACIRHDTL_EFF_DATE) IN
             (SELECT LNACIRHDTL_INTERNAL_ACNUM, MAX(LNACIRHDTL_EFF_DATE)
                FROM LNACIRHDTL
               GROUP BY LNACIRHDTL_INTERNAL_ACNUM);
  EXCEPTION
    --rashmi
    WHEN OTHERS THEN
      NULL;
  END;

  <<IN_LNACIRS>>
  BEGIN
    INSERT INTO LNACIRS
      (LNACIRS_ENTITY_NUM,
       LNACIRS_INTERNAL_ACNUM,
       LNACIRS_LATEST_EFF_DATE,
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
       LNACIRS_REMARKS1,
       LNACIRS_REMARKS2,
       LNACIRS_REMARKS3)
      SELECT W_ENTITY_NUM,
             LNACIRSH_INTERNAL_ACNUM,
             LNACIRSH_EFF_DATE,
             LNACIRSH_AC_LEVEL_INT_REQD,
             LNACIRSH_FIXED_FLOATING_RATE,
             LNACIRSH_STD_INT_RATE_TYPE,
             LNACIRSH_DIFF_INT_RATE_CHOICE,
             LNACIRSH_DIFF_INT_RATE,
             LNACIRSH_TENOR_SLAB_CODE,
             LNACIRSH_TENOR_SLAB_SL,
             LNACIRSH_AMT_SLAB_CODE,
             LNACIRSH_AMT_SLAB_SL,
             LNACIRSH_OD_INT_APPLICABLE,
             'MIGRATION',
             NULL,
             NULL
        FROM LNACIRSHIST
       WHERE (LNACIRSH_INTERNAL_ACNUM, LNACIRSH_EFF_DATE) IN
             (SELECT LNACIRSH_INTERNAL_ACNUM, MAX(LNACIRSH_EFF_DATE)
                FROM LNACIRSHIST
               WHERE LNACIRSH_ENTITY_NUM = W_ENTITY_NUM
               GROUP BY LNACIRSH_INTERNAL_ACNUM);
    /*WHERE LNACIRSH_EFF_DATE =
    (SELECT MAX(LNACIRSH_EFF_DATE)
       FROM LNACIRSHIST B
      WHERE B.LNACIRSH_INTERNAL_ACNUM = LNACIRSH_INTERNAL_ACNUM)*/
  EXCEPTION
    WHEN OTHERS THEN
      W_ER_CODE := 'LN22';
      W_ER_DESC := 'SP_LOANS-INSERT-LNACIRS' || SQLERRM;
      W_SRC_KEY := 'BULK INSERT';
      POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
  END IN_LNACIRS;

  FOR SDX IN (SELECT LNACDSDTL_INTERNAL_ACNUM,
                     LNACDSDTL_SL_NUM,
                     LNACDSDTL_STAGE_DESCN,
                     LNACDSDTL_DISB_CURR,
                     LNACDSDTL_DISB_DATE,
                     LNACDSDTL_DISB_AMOUNT
                FROM MIG_LNACDSDTL) LOOP
    FETCH_ACNUM(P_BRANCH_CODE,
                SDX.LNACDSDTL_INTERNAL_ACNUM,
                'LN24',
                'MIG_LNACDSDTL GETOTN ');

    <<IN_LNACDSDTL>>
    BEGIN
      INSERT INTO LNACDSDTL
        (LNACDSDTL_ENTITY_NUM,
         LNACDSDTL_INTERNAL_ACNUM,
         LNACDSDTL_SL_NUM,
         LNACDSDTL_STAGE_DESCN,
         LNACDSDTL_DISB_CURR,
         LNACDSDTL_DISB_DATE,
         LNACDSDTL_DISB_AMOUNT)
      VALUES
        (W_ENTITY_NUM,
         W_ACNT_NUM,
         SDX.LNACDSDTL_SL_NUM,
         SDX.LNACDSDTL_STAGE_DESCN,
         NVL(SDX.LNACDSDTL_DISB_CURR, W_CURR_CODE),
         SDX.LNACDSDTL_DISB_DATE,
         SDX.LNACDSDTL_DISB_AMOUNT);
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'LN24';
        W_ER_DESC := 'SP_LOANS-INSERT-LNACDSDTL' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     SDX.LNACDSDTL_INTERNAL_ACNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_LNACDSDTL;
  END LOOP;

  -- Ramesh M added on 21/Mar/2013 Starts
  INSERT INTO lnacdisb
    SELECT 1,
           LNACDSDTL_INTERNAL_ACNUM,
           ROW_NUMBER() OVER(PARTITION BY LNACDSDTL_ENTITY_NUM, LNACDSDTL_INTERNAL_ACNUM ORDER BY LNACDSDTL_ENTITY_NUM, LNACDSDTL_INTERNAL_ACNUM) LNACDSDTL_SL_NUM,
           LNACDSDTL_DISB_DATE,
           ROW_NUMBER() OVER(PARTITION BY LNACDSDTL_ENTITY_NUM, LNACDSDTL_INTERNAL_ACNUM ORDER BY LNACDSDTL_ENTITY_NUM, LNACDSDTL_INTERNAL_ACNUM) LNACDSDTL_SL_NUM1,
           LNACDSDTL_DISB_CURR,
           LNACDSDTL_DISB_AMOUNT,
           0,
           LNACDSDTL_STAGE_DESCN,
           '',
           '',
           2,
           LNACDSDTL_DISB_DATE,
           '',
           'MIG',
           LNACDSDTL_DISB_DATE,
           '',
           '',
           'MIG',
           LNACDSDTL_DISB_DATE,
           '',
           '',
           0,
           0,
           0,
           NULL,
           0,
           0
      FROM LNACDSDTL;

  -- Ramesh Ends

  --S.Karthik/S.Ganesan CHG-ADD-22-FEB-2011-BEG
  INSERT INTO LNACDSDTLHIST
    (LNACDSDTLH_ENTITY_NUM,
     LNACDSDTLH_INTERNAL_ACNUM,
     LNACDSDTLH_EFF_DATE,
     LNACDSDTLH_SL_NUM,
     LNACDSDTLH_STAGE_DESCN,
     LNACDSDTLH_DISB_CURR,
     LNACDSDTLH_DISB_DATE,
     LNACDSDTLH_DISB_AMOUNT)
    SELECT LNACDSDTL_ENTITY_NUM,
           LNACDSDTL_INTERNAL_ACNUM,
           W_OPENING_DATE,
           LNACDSDTL_SL_NUM,
           LNACDSDTL_STAGE_DESCN,
           LNACDSDTL_DISB_CURR,
           LNACDSDTL_DISB_DATE,
           LNACDSDTL_DISB_AMOUNT
      FROM LNACDSDTL;

  --S.Karthik/S.Ganesan CHG-ADD-22-FEB-2011-END

  FOR RDX IN (SELECT LNACRSDTL_ACNUM,
                     LNACRS_EFF_DATE,
                     LNACRS_EQU_INSTALLMENT,
                     LNACRS_REPH_ON_AMT,
                     LNACRS_SANC_BY,
                     LNACRS_SANC_REF_NUM,
                     LNACRS_SANC_DATE,
                     LNACRS_CLIENT_REF_NUM,
                     LNACRS_CLIENT_REF_DATE,
                     LNACRS_REMARKS1,
                     LNACRS_REMARKS2,
                     LNACRS_REMARKS3,
                     NVL(LNACRSDTL_REPAY_AMT_CURR, 'BDT') LNACRSDTL_REPAY_AMT_CURR, --shamsudeen-chn-24may2012-changed INR to BDT
                     LNACRSDTL_REPAY_AMT,
                     LNACRSDTL_REPAY_FREQ,
                     LNACRSDTL_REPAY_FROM_DATE,
                     LNACRSDTL_NUM_OF_INSTALLMENT,
                     LNACRSDTL_RS_NO,
                     LNACRSDTL_LIMIT_EXP_DATE
                FROM MIG_LNACRSDTL
               ORDER BY LNACRSDTL_ACNUM, LNACRS_EFF_DATE DESC) LOOP
    FETCH_ACNUM(P_BRANCH_CODE,
                RDX.LNACRSDTL_ACNUM,
                'LN25',
                'MIG_LNACRSDTL GETOTN ');

    <<ERR_HAND>>
    BEGIN
      BEGIN
        --- LNACRSDTL --- LNACRSDTL_LIMIT_EXP_DATE

        INSERT INTO LNACRSDTL
          (LNACRSDTL_ENTITY_NUM,
           LNACRSDTL_INTERNAL_ACNUM,
           LNACRSDTL_SL_NUM,
           LNACRSDTL_REPAY_AMT_CURR,
           LNACRSDTL_REPAY_AMT,
           LNACRSDTL_REPAY_FREQ,
           LNACRSDTL_REPAY_FROM_DATE,
           LNACRSDTL_NUM_OF_INSTALLMENT,
           LNACRSDTL_TOT_REPAY_AMT)
        VALUES
          (W_ENTITY_NUM,
           W_ACNT_NUM,
           1, -- LNACRSDTL_SL_NUM
           RDX.LNACRSDTL_REPAY_AMT_CURR,
           RDX.LNACRSDTL_REPAY_AMT,
           RDX.LNACRSDTL_REPAY_FREQ,
           RDX.LNACRSDTL_REPAY_FROM_DATE,
           RDX.LNACRSDTL_NUM_OF_INSTALLMENT,
           RDX.LNACRSDTL_REPAY_AMT * RDX.LNACRSDTL_NUM_OF_INSTALLMENT);
      EXCEPTION
        WHEN OTHERS THEN
          BEGIN
            SELECT COUNT(LNACRSDTL_INTERNAL_ACNUM)
              INTO V_LNACRSDTL_DATA
              FROM LNACRSDTL
             WHERE LNACRSDTL_ENTITY_NUM = W_ENTITY_NUM
               AND LNACRSDTL_INTERNAL_ACNUM = W_ACNT_NUM;
          END;

          IF V_LNACRSDTL_DATA = 1 THEN
            NULL;
          ELSE
            W_ER_DESC := SQLERRM;
            DBMS_OUTPUT.PUT_LINE(W_ER_DESC);
          END IF;
      END;

      BEGIN
        ----       LNACRSHDTL

        INSERT INTO LNACRSHIST
          (LNACRSH_ENTITY_NUM,
           LNACRSH_INTERNAL_ACNUM,
           LNACRSH_EFF_DATE,
           LNACRSH_EQU_INSTALLMENT,
           LNACRSH_REPH_ON_AMT,
           LNACRSH_REPHASEMENT_ENTRY,
           LNACRSH_AUTO_REPHASED_FLG,
           LNACRSH_SANC_BY,
           LNACRSH_SANC_REF_NUM,
           LNACRSH_SANC_DATE,
           LNACRSH_CLIENT_REF_NUM,
           LNACRSH_CLIENT_REF_DATE,
           LNACRSH_REMARKS1,
           LNACRSH_REMARKS2,
           LNACRSH_REMARKS3,
           LNACRSH_ENTD_BY,
           LNACRSH_ENTD_ON,
           LNACRSH_LAST_MOD_BY,
           LNACRSH_LAST_MOD_ON,
           LNACRSH_AUTH_BY,
           LNACRSH_AUTH_ON,
           TBA_MAIN_KEY)
        VALUES
          (W_ENTITY_NUM,
           W_ACNT_NUM,
           RDX.LNACRS_EFF_DATE,
           RDX.LNACRS_EQU_INSTALLMENT,
           RDX.LNACRSDTL_REPAY_AMT * RDX.LNACRSDTL_NUM_OF_INSTALLMENT,
           NULL,
           NULL,
           RDX.LNACRS_SANC_BY,
           RDX.LNACRS_SANC_REF_NUM,
           RDX.LNACRS_SANC_DATE,
           RDX.LNACRS_CLIENT_REF_NUM,
           RDX.LNACRS_SANC_DATE,
           'MIGRATION',
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
          NULL;
      END;

      BEGIN
        INSERT INTO LNACRS
          (LNACRS_ENTITY_NUM,
           LNACRS_INTERNAL_ACNUM,
           LNACRS_LATEST_EFF_DATE,
           LNACRS_EQU_INSTALLMENT,
           LNACRS_REPH_ON_AMT,
           LNACRS_REPHASEMENT_ENTRY,
           LNACRS_AUTO_REPHASED_FLG,
           LNACRS_SANC_BY,
           LNACRS_SANC_REF_NUM,
           LNACRS_SANC_DATE,
           LNACRS_CLIENT_REF_NUM,
           LNACRS_CLIENT_REF_DATE,
           LNACRS_REMARKS1,
           LNACRS_REMARKS2,
           LNACRS_REMARKS3)
        VALUES
          (W_ENTITY_NUM,
           W_ACNT_NUM,
           RDX.LNACRS_EFF_DATE,
           RDX.LNACRS_EQU_INSTALLMENT,
           RDX.LNACRSDTL_REPAY_AMT * RDX.LNACRSDTL_NUM_OF_INSTALLMENT,
           NULL,
           NULL,
           RDX.LNACRS_SANC_BY,
           RDX.LNACRS_SANC_REF_NUM,
           RDX.LNACRS_SANC_DATE,
           RDX.LNACRS_CLIENT_REF_NUM,
           RDX.LNACRS_CLIENT_REF_DATE,
           'MIGRATION',
           NULL,
           NULL);
      EXCEPTION
        WHEN OTHERS THEN
          BEGIN
            SELECT COUNT(LNACRS_INTERNAL_ACNUM)
              INTO V_LNACRS_DATA
              FROM LNACRS
             WHERE LNACRS_ENTITY_NUM = W_ENTITY_NUM
               AND LNACRS_INTERNAL_ACNUM = W_ACNT_NUM;
          END;

          IF V_LNACRS_DATA = 1 THEN
            NULL;
          ELSE
            W_ER_DESC := SQLERRM;
            DBMS_OUTPUT.PUT_LINE(W_ER_DESC);
          END IF;
      END;

      BEGIN
        ----       LNACRSHDTL --- LNACRSHDTL_LIMIT_EXP_DATE
        INSERT INTO LNACRSHDTL
          (LNACRSHDTL_ENTITY_NUM,
           LNACRSHDTL_INTERNAL_ACNUM,
           LNACRSHDTL_EFF_DATE,
           LNACRSHDTL_SL_NUM,
           LNACRSHDTL_REPAY_AMT_CURR,
           LNACRSHDTL_REPAY_AMT,
           LNACRSHDTL_REPAY_FREQ,
           LNACRSHDTL_REPAY_FROM_DATE,
           LNACRSHDTL_NUM_OF_INSTALLMENT,
           LNACRSHDTL_TOT_REPAY_AMT)
        VALUES
          (W_ENTITY_NUM,
           W_ACNT_NUM,
           RDX.LNACRS_EFF_DATE, -- '10-sep-2009',
           1, --SDX.LNACDSDTL_SL_NUM, DOUBT..?
           W_CURR_CODE,
           RDX.LNACRSDTL_REPAY_AMT,
           RDX.LNACRSDTL_REPAY_FREQ,
           RDX.LNACRSDTL_REPAY_FROM_DATE,
           RDX.LNACRSDTL_NUM_OF_INSTALLMENT,
           RDX.LNACRSDTL_REPAY_AMT * RDX.LNACRSDTL_NUM_OF_INSTALLMENT);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_DESC := SQLERRM;
        DBMS_OUTPUT.PUT_LINE(W_ER_DESC);
    END ERR_HAND;
  END LOOP;

  FOR PDX IN (SELECT LNDP_ACNUM,
                     LNDP_EFF_DATE,
                     NVL(LNDP_DP_CURR, W_CURR_CODE) LNDP_DP_CURR,
                     LNDP_DP_AMT,
                     LNDP_DP_AMT_AS_PER_SEC,
                     LNDP_DP_VALID_UPTO_DATE,
                     LNDP_DP_REVIEW_DUE_DATE
                FROM MIG_LNDP) LOOP
    FETCH_ACNUM(P_BRANCH_CODE, PDX.LNDP_ACNUM, 'LN33', 'MIG_LNDP GETOTN ');

    <<CHECK_LIMITLINE>>
    BEGIN
      SELECT ACASLLDTL_LIMIT_LINE_NUM
        INTO W_LIMIT_NUM
        FROM ACASLLDTL
       WHERE ACASLLDTL_ENTITY_NUM = W_ENTITY_NUM
         AND ACASLLDTL_CLIENT_NUM = W_CLIENT_NUM
         AND ACASLLDTL_INTERNAL_ACNUM = W_ACNT_NUM;
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'LN35';
        W_ER_DESC := 'SP_LOANS-SELECT-CHECK-LIMITLINE-LNDP' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     PDX.LNDP_ACNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END CHECK_LIMTLINE;

    <<IN_LNDPHIST>>
    BEGIN
      EXECUTE IMMEDIATE 'INSERT INTO LNDPHIST
        (LNDPHIST_ENTITY_NUM,
         LNDPHIST_CLIENT_NUM,
         LNDPHIST_LIMIT_NUM,
         LNDPHIST_EFF_DATE,
         LNDPHIST_DP_CURR,
         LNDPHIST_DP_AMT,
         LNDPHIST_AUTO_MANUAL_ENTRY,
         LNDPHIST_DP_CURR_AS_PER_SEC,
         LNDPHIST_DP_AMT_AS_PER_SEC,
         LNDPHIST_DP_VALID_UPTO_DATE,
         LNDPHIST_DP_REVIEW_DUE_DATE,
         LNDPHIST_REMARKS1,
         LNDPHIST_REMARKS2,
         LNDPHIST_REMARKS3,
         LNDPHIST_ENTD_BY,
         LNDPHIST_ENTD_ON,
         LNDPHIST_LAST_MOD_BY,
         LNDPHIST_LAST_MOD_ON,
         LNDPHIST_AUTH_BY,
         LNDPHIST_AUTH_ON,
         TBA_MAIN_KEY)
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
         :20,:21)'
        USING W_ENTITY_NUM, W_CLIENT_NUM, W_LIMIT_NUM, PDX.LNDP_EFF_DATE, NVL(PDX.LNDP_DP_CURR, W_CURR_CODE), PDX.LNDP_DP_AMT, W_NULL, NVL(PDX.LNDP_DP_CURR, W_CURR_CODE), PDX.LNDP_DP_AMT_AS_PER_SEC, PDX.LNDP_DP_VALID_UPTO_DATE, PDX.LNDP_DP_REVIEW_DUE_DATE, 'MIGRATION', W_NULL, W_NULL, W_ENTD_BY, W_CURR_DATE, W_NULL, W_NULL, W_ENTD_BY, W_CURR_DATE, W_NULL;
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'LN37';
        W_ER_DESC := 'SP_LOANS-INSERT-LNDPHIST' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     PDX.LNDP_ACNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_LNDPHIST;
  END LOOP;

  <<IN_LNDP>>
  BEGIN
    INSERT INTO LNDP
      (LNDP_ENTITY_NUM,
       LNDP_CLIENT_NUM,
       LNDP_LIMIT_NUM,
       LNDP_LATEST_EFF_DATE,
       LNDP_DP_CURR,
       LNDP_DP_AMT,
       LNDP_AUTO_MANUAL_ENTRY,
       LNDP_DP_CURR_AS_PER_SEC,
       LNDP_DP_AMT_AS_PER_SEC,
       LNDP_DP_VALID_UPTO_DATE,
       LNDP_DP_REVIEW_DUE_DATE,
       LNDP_REMARKS1,
       LNDP_REMARKS2,
       LNDP_REMARKS3)
      SELECT W_ENTITY_NUM,
             LNDPHIST_CLIENT_NUM,
             LNDPHIST_LIMIT_NUM,
             LNDPHIST.LNDPHIST_EFF_DATE,
             LNDPHIST.LNDPHIST_DP_CURR,
             LNDPHIST.LNDPHIST_DP_AMT,
             LNDPHIST_AUTO_MANUAL_ENTRY,
             LNDPHIST_DP_CURR_AS_PER_SEC,
             LNDPHIST_DP_AMT_AS_PER_SEC,
             LNDPHIST_DP_VALID_UPTO_DATE,
             LNDPHIST_DP_REVIEW_DUE_DATE,
             'MIGRATION',
             NULL,
             NULL
        FROM LNDPHIST
       WHERE (LNDPHIST_CLIENT_NUM, LNDPHIST_LIMIT_NUM, LNDPHIST_EFF_DATE) IN
             (SELECT LNDPHIST_CLIENT_NUM,
                     LNDPHIST_LIMIT_NUM,
                     MAX(LNDPHIST_EFF_DATE)
                FROM LNDPHIST B
               GROUP BY LNDPHIST_CLIENT_NUM, LNDPHIST_LIMIT_NUM);
    /*WHERE LNDPHIST.LNDPHIST_EFF_DATE =
    (SELECT MAX(LNDPHIST_EFF_DATE)
       FROM LNDPHIST B
      WHERE B.LNDPHIST_CLIENT_NUM = LNDPHIST_CLIENT_NUM
        AND LNDPHIST_LIMIT_NUM = B.LNDPHIST_LIMIT_NUM);*/
  EXCEPTION
    WHEN OTHERS THEN
      W_ER_CODE := 'LN36';
      W_ER_DESC := 'SP_LOANS-INSERT-LNDP' || SQLERRM;
      W_SRC_KEY := P_BRANCH_CODE || 'BULK INSERT ';
      POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
  END IN_LNDP;

  FOR VDX IN (SELECT LNSUBR_ACNUM,
                     LNSUBR_SUBSIDY_SL_NUM,
                     LNACSUBR_SUBSIDY_RCPT_SL,
                     NVL(LNACSUBR_SUBSIDY_CURR, W_CURR_CODE),
                     LNACSUBR_SUBSIDY_RECVD_AMT,
                     LNACSUBR_SUBSIDY_RECVD_ON_DATE,
                     LNACSUBR_AGENCY_REF_NUM,
                     LNACSUBR_AGENCY_REF_DATE,
                     LNACSUBR_INST_PFX,
                     LNACSUBR_INST_NUM,
                     LNACSUBR_INST_DATE,
                     LNACSUBR_DRAWN_ON_BANK,
                     LNACSUBR_DRAWN_ON_BRN,
                     LNACSUBR_CR_ACNT_NUM,
                     LNACSUBR_CR_GLACC_CODE,
                     LNACSUBR_REMARKS1,
                     LNACSUBR_REMARKS2,
                     LNACSUBR_REMARKS3,
                     LNACSUBR_ENTD_BY,
                     LNACSUBR_ENTD_ON
                FROM MIG_LNSUBRCV) LOOP
    FETCH_ACNUM(P_BRANCH_CODE,
                VDX.LNSUBR_ACNUM,
                'LN38',
                'MIG_LNSUBRCV GETOTN');

    <<IN_LNSUBVENRECV>>
    BEGIN
      INSERT INTO LNSUBVENRECV
        (LNSUBVENR_ENTITY_NUM,
         LNSUBVENR_INTERNAL_ACNUM,
         LNSUBVENR_SL_NUM,
         LNSUBVENR_RECVD_ON_DATE,
         LNSUBVENR_THPARTY_CODE,
         LNSUBVENR_TRANSTL_INV_NUM,
         POST_TRAN_BRN,
         POST_TRAN_DATE,
         POST_TRAN_BATCH_NUM,
         LNSUBVENR_ENTD_BY,
         LNSUBVENR_ENTD_ON,
         LNSUBVENR_LAST_MOD_BY,
         LNSUBVENR_LAST_MOD_ON,
         LNSUBVENR_AUTH_BY,
         LNSUBVENR_AUTH_ON,
         LNSUBVENR_REJ_BY,
         LNSUBVENR_REJ_ON)
      VALUES
        (W_ENTITY_NUM,
         W_ACNT_NUM,
         VDX.LNSUBR_SUBSIDY_SL_NUM,
         VDX.LNACSUBR_SUBSIDY_RECVD_ON_DATE,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         W_ENTD_BY,
         W_CURR_DATE,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL);
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'LN39';
        W_ER_DESC := 'SP_LOANS-INSERT-LNSUBVENRECV' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     VDX.LNSUBR_ACNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_LNSUBVENRECV;
  END LOOP;

  FOR LNS IN (SELECT LNSUBS_ACNUM,
                     LNSUBS_SUBSIDY_SL_NUM,
                     LNSUBS_AGENCY_CODE,
                     LNSUBS_SUBSIDY_TYPE,
                     LNSUBS_SUBSIDY_PERC,
                     NVL(LNSUBS_SUBSIDY_CURR, W_CURR_CODE) LNSUBS_SUBSIDY_CURR,
                     LNSUBS_SUBSIDY_ON_AMT,
                     LNSUBS_SUBSIDY_AMT,
                     LNSUBS_SUBSIDY_EXPECTED_DATE,
                     LNSUBS_SUBSIDY_EXPIRY_DATE,
                     LNSUBS_ADJUST_LOAN_AC_FLG,
                     LNSUBS_PARKING_ACNT_NUM,
                     LNSUBS_GLACC_CODE,
                     LNSUBS_REMARKS1,
                     LNSUBS_REMARKS2,
                     LNSUBS_REMARKS3,
                     LNSUBS_ENTD_BY,
                     LNSUBS_ENTD_ON
                FROM MIG_LNSUBSIDY) LOOP
    FETCH_ACNUM(P_BRANCH_CODE,
                LNS.LNSUBS_ACNUM,
                'LN49',
                'MIG_LNSUBSIDY GETOTN');

    <<IN_LNACSUBIDY>>
    BEGIN
      INSERT INTO LNACSUBSIDY
        (LNACSUBS_ENTITY_NUM,
         LNACSUBS_INTERNAL_ACNUM,
         LNACSUBS_SUBSIDY_SL_NUM,
         LNACSUBS_AGENCY_CODE,
         LNACSUBS_SUBSIDY_TYPE,
         LNACSUBS_SUBSIDY_PERC,
         LNACSUBS_SUBSIDY_CURR,
         LNACSUBS_SUBSIDY_ON_AMT,
         LNACSUBS_SUBSIDY_AMT,
         LNACSUBS_SUBSIDY_EXPECTED_DATE,
         LNACSUBS_SUBSIDY_EXPIRY_DATE,
         LNACSUBS_ADJUST_LOAN_AC_FLG,
         LNACSUBS_PARKING_ACNT_NUM,
         LNACSUBS_ACNT_CONT_NUM,
         LNACSUBS_GLACC_CODE,
         LNACSUBS_REMARKS1,
         LNACSUBS_REMARKS2,
         LNACSUBS_REMARKS3,
         LNACSUBS_ENTD_BY,
         LNACSUBS_ENTD_ON,
         LNACSUBS_LAST_MOD_BY,
         LNACSUBS_LAST_MOD_ON,
         LNACSUBS_AUTH_BY,
         LNACSUBS_AUTH_ON,
         TBA_MAIN_KEY)
      VALUES
        (W_ENTITY_NUM,
         W_ACNT_NUM,
         LNS.LNSUBS_SUBSIDY_SL_NUM,
         LNS.LNSUBS_AGENCY_CODE,
         LNS.LNSUBS_SUBSIDY_TYPE,
         LNS.LNSUBS_SUBSIDY_PERC,
         LNS.LNSUBS_SUBSIDY_CURR,
         LNS.LNSUBS_SUBSIDY_ON_AMT,
         LNS.LNSUBS_SUBSIDY_AMT,
         LNS.LNSUBS_SUBSIDY_EXPECTED_DATE,
         LNS.LNSUBS_SUBSIDY_EXPIRY_DATE,
         LNS.LNSUBS_ADJUST_LOAN_AC_FLG,
         LNS.LNSUBS_PARKING_ACNT_NUM,
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
        W_ER_CODE := 'LN50';
        W_ER_DESC := 'SP_LOANS-INSERT-LNSUBSIDY' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     LNS.LNSUBS_ACNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_LNACSUBIDY;
  END LOOP;

  W_LEDCNT := 1;

  FOR LED IN (SELECT LNSUSP_ACNUM,
                     LNSUSP_REC_SL_NUM,
                     LNSUSP_TRAN_DATE,
                     LNSUSP_ENTRY_TYPE,
                     --DECODE(LNSUSP_DB_CR_FLG, 1, 'C', 2, 'D') LNSUSP_DB_CR_FLG, -- modified
                     LNSUSP_DB_CR_FLG,
                     NVL(LNSUSP_CURR_CODE, W_CURR_CODE) LNSUSP_CURR_CODE,
                     LNSUSP_AMOUNT,
                     LNSUSP_INT_AMT,
                     LNSUSP_CHGS_AMT,
                     LNSUSP_INT_FROM_DATE,
                     LNSUSP_INT_UPTO_DATE,
                     LNSUSP_REMARKS1,
                     LNSUSP_REMARKS2,
                     LNSUSP_REMARKS3,
                     LNSUSP_ENTD_BY,
                     LNSUSP_ENTD_ON
                FROM MIG_LNSUSP
               ORDER BY LNSUSP_ACNUM) LOOP
    FETCH_ACNUM(P_BRANCH_CODE,
                LED.LNSUSP_ACNUM,
                'LN52',
                'MIG_LNSUSP GETOTN');

    IF (W_TEMP_ACNUM IS NULL OR W_TEMP_ACNUM <> LED.LNSUSP_ACNUM) AND
       W_LEDCNT <> 1 THEN
      W_TEMP_ACNUM := LED.LNSUSP_ACNUM;
    END IF;

    <<IN_LNSUSPLED>>
    BEGIN
      EXECUTE IMMEDIATE 'INSERT INTO LNSUSPLED
        (LNSUSP_ENTITY_NUM,
         LNSUSP_ACNT_NUM,
         LNSUSP_TRAN_DATE,
         LNSUSP_SL_NUM,
         LNSUSP_VALUE_DATE,
         LNSUSP_ENTRY_TYPE,
         LNSUSP_DB_CR_FLG,
         LNSUSP_CURR_CODE,
         LNSUSP_AMOUNT,
         LNSUSP_INT_AMT,
         LNSUSP_CHGS_AMT,
         LNSUSP_INT_FROM_DATE,
         LNSUSP_INT_UPTO_DATE,
         LNSUSP_REMARKS1,
         LNSUSP_REMARKS2,
         LNSUSP_REMARKS3,
         LNSUSP_AUTO_MANUAL,
         LNSUSP_RECOV_THRU,
         LNSUSP_SRC_REF_KEY,
         LNSUSP_ENTD_BY,
         LNSUSP_ENTD_ON,
         LNSUSP_LAST_MOD_BY,
         LNSUSP_LAST_MOD_ON,
         LNSUSP_AUTH_BY,
         LNSUSP_AUTH_ON,
         TBA_MAIN_KEY)
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
         :25,:26
        ) '
        USING W_ENTITY_NUM, W_ACNT_NUM, LED.LNSUSP_TRAN_DATE, W_LEDCNT, LED.LNSUSP_TRAN_DATE, --NULL,
      LED.LNSUSP_ENTRY_TYPE, LED.LNSUSP_DB_CR_FLG, LED.LNSUSP_CURR_CODE, LED.LNSUSP_AMOUNT, LED.LNSUSP_INT_AMT, LED.LNSUSP_CHGS_AMT, LED.LNSUSP_INT_FROM_DATE, LED.LNSUSP_INT_UPTO_DATE, LED.LNSUSP_REMARKS1, LED.LNSUSP_REMARKS2, LED.LNSUSP_REMARKS3, 'M', W_NULL, W_NULL, W_ENTD_BY, W_OPENING_DATE, --W_CURR_DATE,
      W_NULL, W_NULL, W_ENTD_BY, W_OPENING_DATE, --W_CURR_DATE,
      W_NULL;

      W_LEDCNT := W_LEDCNT + 1;
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'LN51';
        W_ER_DESC := 'SP_LOANS-INSERT-LNSUPLED' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     LED.LNSUSP_ACNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
    END IN_LNSUSPLED;
  END LOOP;

  INSERT INTO LNSUSPBAL
    (LNSUSPBAL_ENTITY_NUM,
     LNSUSPBAL_ACNT_NUM,
     LNSUSPBAL_CURR_CODE,
     LNSUSPBAL_SUSP_BAL,
     LNSUSPBAL_SUSP_DB_SUM,
     LNSUSPBAL_SUSP_CR_SUM,
     LNSUSPBAL_PRIN_BAL,
     LNSUSPBAL_INT_BAL,
     LNSUSPBAL_CHG_BAL)
    SELECT W_ENTITY_NUM,
           LNSUSP_ACNT_NUM,
           LNSUSP_CURR_CODE,
           SUM(DECODE(LNSUSP_DB_CR_FLG, 'C', LNSUSP_AMOUNT, 0)) -
           SUM(DECODE(LNSUSP_DB_CR_FLG, 'D', LNSUSP_AMOUNT, 0)),
           SUM(DECODE(LNSUSP_DB_CR_FLG, 'D', LNSUSP_AMOUNT, 0)),
           SUM(DECODE(LNSUSP_DB_CR_FLG, 'C', LNSUSP_AMOUNT, 0)),
           0,
           SUM(DECODE(LNSUSP_DB_CR_FLG, 'C', LNSUSP_AMOUNT, 0)) -
           SUM(DECODE(LNSUSP_DB_CR_FLG, 'D', LNSUSP_AMOUNT, 0)),
           0
      FROM LNSUSPLED
     GROUP BY LNSUSP_ACNT_NUM, LNSUSP_CURR_CODE;

  FOR ADX IN (SELECT ASSETCLS_ACNUM,
                     ASSETCLS_EFF_DATE,
                     ASSETCLSH_ASSET_CODE,
                     ASSETCLSH_NPA_DATE,
                     ASSETCLSH_REMARKS,
                     ASSETCLSH_ENTD_BY,
                     ASSETCLSH_ENTD_ON
                FROM MIG_ASSETCLS) LOOP
    FETCH_ACNUM(P_BRANCH_CODE,
                ADX.ASSETCLS_ACNUM,
                'LN39',
                'MIG_ASSETCLS GETOTN');

    <<CHECK_NPA_DATE>>
    BEGIN
      SELECT ASSETCLS_NPA_DATE
        INTO W_NPA_DATE
        FROM ASSETCLS
       WHERE ASSETCLS_ENTITY_NUM = W_ENTITY_NUM
         AND ASSETCLS_INTERNAL_ACNUM = W_ACNT_NUM;
    EXCEPTION
      WHEN OTHERS THEN
        W_ER_CODE := 'LN40';
        W_ER_DESC := 'SP_LOANS-SELECT- NPA DATE- ASSETCLS' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' ||
                     ADX.ASSETCLS_ACNUM;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
        NULL;
    END CHECK_NPA_DATE;

    UPDATE ASSETCLS
       SET ASSETCLS_NPA_DATE   = W_NPA_DATE,
           ASSETCLS_ASSET_CODE = ADX.ASSETCLSH_ASSET_CODE
     WHERE ASSETCLS_ENTITY_NUM = W_ENTITY_NUM
       AND ASSETCLS_INTERNAL_ACNUM = W_ACNT_NUM
       AND ASSETCLS_LATEST_EFF_DATE = ADX.ASSETCLS_EFF_DATE;

    UPDATE ASSETCLSHIST
       SET ASSETCLSH_NPA_DATE   = W_NPA_DATE,
           ASSETCLSH_ASSET_CODE = ADX.ASSETCLSH_ASSET_CODE
     WHERE ASSETCLSH_ENTITY_NUM = W_ENTITY_NUM
       AND ASSETCLSH_INTERNAL_ACNUM = W_ACNT_NUM
       AND ASSETCLSH_EFF_DATE = ADX.ASSETCLS_EFF_DATE;
  END LOOP;

  UPDATE LOANACNTS
     SET LNACNT_LAST_AOD_GIVEN_ON = W_LAST_AOD_GIVEN_ON, --'30-SEP-2009',
         LNACNT_NEXT_AOD_DUE_ON   = W_NEXT_AOD_GIVEN_ON; --'31-DEC-2009';

  UPDATE LNACAODHIST
     SET LNACAODH_AOD_DATE          = W_LAST_AOD_GIVEN_ON, --'30-SEP-2009',
         LNACAODH_NEXT_AOD_DUE_DATE = W_NEXT_AOD_GIVEN_ON; -- '31-DEC-2009';

  UPDATE LNACGUAR
     SET LNGUAR_LAST_AOD_GIVEN_ON = W_LAST_AOD_GIVEN_ON, -- '30-SEP-2009',
         LNGUAR_NEXT_AOD_DUE_ON   = W_NEXT_AOD_GIVEN_ON; --'31-DEC-2009';

  UPDATE LIMITLINE
     SET LMTLINE_SEC_LIMIT_LINE    = 1,
         LIMITLINE.LMTLINE_DP_REQD = 0, --1 CHANGED
         LMTLINE_MARKED_AMT_OUT    = 0,
         LMTLINE_MARKED_AMT_INTO   = 0;

  UPDATE LIMITLINE
     SET LMTLINE_DP_REQD       = 1,
         LMTLINE_DP_AMT       =
         (SELECT LNDP_DP_AMT
            FROM LNDP
           WHERE LNDP.LNDP_CLIENT_NUM = LIMITLINE.LMTLINE_CLIENT_CODE
             AND LIMITLINE.LMTLINE_NUM = LNDP.LNDP_LIMIT_NUM),
         LMTLINE_DP_VALID_UPTO =
         (SELECT LNDP_DP_VALID_UPTO_DATE
            FROM LNDP
           WHERE LNDP.LNDP_CLIENT_NUM = LIMITLINE.LMTLINE_CLIENT_CODE
             AND LIMITLINE.LMTLINE_NUM = LNDP.LNDP_LIMIT_NUM);

  INSERT INTO LNACIRS
    (LNACIRS_ENTITY_NUM,
     LNACIRS_INTERNAL_ACNUM,
     LNACIRS_LATEST_EFF_DATE,
     LNACIRS_AC_LEVEL_INT_REQD,
     LNACIRS_REMARKS1,
     LNACIRS_FIXED_FLOATING_RATE)
    SELECT W_ENTITY_NUM,
           LNACNT_INTERNAL_ACNUM,
           ACNTS_OPENING_DATE,
           0,
           'MIGRATION',
           0
      FROM LOANACNTS, ACNTS
     WHERE ACNTS_INTERNAL_ACNUM = LNACNT_INTERNAL_ACNUM
       AND LOANACNTS.LNACNT_INTERNAL_ACNUM NOT IN
           (SELECT LNACIRS.LNACIRS_INTERNAL_ACNUM FROM LNACIRS);

  /*  Ramesh M on 09-may-2012

      INSERT INTO LNACIRSHIST
      (LNACIRSH_ENTITY_NUM,
       LNACIRSH_INTERNAL_ACNUM,
       LNACIRSH_EFF_DATE,
       LNACIRSH_AC_LEVEL_INT_REQD,
       LNACIRSH_REMARKS1,
       LNACIRSH_ENTD_BY,
       LNACIRSH_ENTD_ON,
       LNACIRSH_AUTH_BY,
       LNACIRSH_AUTH_ON,
       LNACIRSH_FIXED_FLOATING_RATE)
      SELECT W_ENTITY_NUM,
             LNACNT_INTERNAL_ACNUM,
             ACNTS_OPENING_DATE,
             0,
             'MIGRATION',
             W_ENTD_BY,
             W_CURR_DATE,
             W_ENTD_BY,
             W_CURR_DATE,
             0
      FROM LOANACNTS, ACNTS
      WHERE ACNTS_INTERNAL_ACNUM = LNACNT_INTERNAL_ACNUM
      AND LOANACNTS.LNACNT_INTERNAL_ACNUM NOT IN
            (SELECT LNACIRS.LNACIRS_INTERNAL_ACNUM
             FROM LNACIRS
             WHERE LNACIRS_AC_LEVEL_INT_REQD = 1);
  */
  --Ramesh M on 09-may-2012

  INSERT INTO LNACMIS
    (LNACMIS_ENTITY_NUM,
     LNACMIS_INTERNAL_ACNUM,
     LNACMIS_LATEST_EFF_DATE,
     LNACMIS_SEGMENT_CODE,
     LNACMIS_HO_DEPT_CODE,
     LNACMIS_INDUS_CODE,
     LNACMIS_SUB_INDUS_CODE,
     LNACMIS_BSR_ACT_OCC_CODE,
     LNACMIS_BSR_MAIN_ORG_CODE,
     LNACMIS_BSR_SUB_ORG_CODE,
     LNACMIS_BSR_STATE_CODE,
     LNACMIS_BSR_DISTRICT_CODE,
     LNACMIS_NATURE_BORROWAL_AC,
     LNACMIS_POP_GROUP_CODE,
     LNACMIS_PURPOSE_CODE)
    SELECT W_ENTITY_NUM,
           (SELECT ACNTOTN_INTERNAL_ACNUM
              FROM ACNTOTN
             WHERE ACNTOTN.ACNTOTN_OLD_ACNT_NUM = LNACNT_ACNUM),
           LNACNT_LIMIT_SANCTION_DATE,
           LNACNT_SEGMENT_CODE,
           LNACNT_HO_DEPT_CODE,
           LNACNT_INDUS_CODE,
           LNACNT_SUB_INDUS_CODE,
           LNACNT_BSR_ACT_OCC_CODE,
           LNACNT_BSR_MAIN_ORG_CODE,
           LNACNT_BSR_SUB_ORG_CODE,
           LNACNT_BSR_STATE_CODE,
           LNACNT_BSR_DISTRICT_CODE,
           LNACNT_NATURE_BORROWAL_AC,
           LNACNT_POP_GROUP_CODE,
           LNACNT_PURPOSE_CODE
      FROM MIG_LNACNT;

  INSERT INTO LNACMISHIST
    (LNACMISH_ENTITY_NUM,
     LNACMISH_INTERNAL_ACNUM,
     LNACMISH_EFF_DATE,
     LNACMISH_SEGMENT_CODE,
     LNACMISH_HO_DEPT_CODE,
     LNACMISH_INDUS_CODE,
     LNACMISH_SUB_INDUS_CODE,
     LNACMISH_BSR_ACT_OCC_CODE,
     LNACMISH_BSR_MAIN_ORG_CODE,
     LNACMISH_BSR_SUB_ORG_CODE,
     LNACMISH_BSR_STATE_CODE,
     LNACMISH_BSR_DISTRICT_CODE,
     LNACMISH_NATURE_BORROWAL_AC,
     LNACMISH_POP_GROUP_CODE,
     LNACMISH_PURPOSE_CODE,
     LNACMISH_ENTD_BY,
     LNACMISH_ENTD_ON,
     LNACMISH_AUTH_BY,
     LNACMISH_AUTH_ON)
    SELECT W_ENTITY_NUM,
           (SELECT ACNTOTN_INTERNAL_ACNUM
              FROM ACNTOTN
             WHERE ACNTOTN.ACNTOTN_OLD_ACNT_NUM = LNACNT_ACNUM),
           LNACNT_LIMIT_SANCTION_DATE,
           LNACNT_SEGMENT_CODE,
           LNACNT_HO_DEPT_CODE,
           LNACNT_INDUS_CODE,
           LNACNT_SUB_INDUS_CODE,
           LNACNT_BSR_ACT_OCC_CODE,
           LNACNT_BSR_MAIN_ORG_CODE,
           LNACNT_BSR_SUB_ORG_CODE,
           LNACNT_BSR_STATE_CODE,
           LNACNT_BSR_DISTRICT_CODE,
           LNACNT_NATURE_BORROWAL_AC,
           LNACNT_POP_GROUP_CODE,
           LNACNT_PURPOSE_CODE,
           W_ENTD_BY,
           W_CURR_DATE,
           W_ENTD_BY,
           W_CURR_DATE
      FROM MIG_LNACNT;

  FOR IDX IN (SELECT * FROM MIG_LNACCHGS WHERE LNACCHGS_AMT > 0) LOOP
    SELECT ACNTOTN_INTERNAL_ACNUM
      INTO W_ACNT_NUM
      FROM ACNTOTN
     WHERE ACNTOTN_OLD_ACNT_NUM = IDX.LNACCHGS_ACNUM;

    SELECT NVL(MAX(LNACCHGS_DAY_SERIAL), 0) + 1
      INTO W_SL
      FROM LNACCHGS
     WHERE LNACCHGS_ENTITY_NUM = W_ENTITY_NUM
       AND LNACCHGS_INTERNAL_ACNUM = W_ACNT_NUM
       AND LNACCHGS_ENTRY_DATE = W_CURR_DATE;

    INSERT INTO LNACCHGS
      (LNACCHGS_ENTITY_NUM,
       LNACCHGS_INTERNAL_ACNUM,
       LNACCHGS_ENTRY_DATE,
       LNACCHGS_DAY_SERIAL,
       LNACCHGS_CHG_CODE,
       LNACCHGS_CHG_CURR,
       LNACCHGS_CHG_ON_AMT,
       LNACCHGS_SYS_CHG_AMT,
       LNACCHGS_SYS_STAX_AMT,
       LNACCHGS_ACT_CHG_AMT,
       LNACCHGS_ACT_STAX_AMT,
       LNACCHGS_SYS_TOT_CHGS,
       LNACCHGS_ACT_TOT_CHGS,
       LNACCHGS_CHGS_DUE_DATE,
       LNACCHGS_TOT_REV_AMT,
       LNACCHGS_TOT_RECOV_AMT,
       LNACCHGS_REMARKS1,
       LNACCHGS_ENTD_BY,
       LNACCHGS_ENTD_ON,
       LNACCHGS_LAST_MOD_BY,
       LNACCHGS_LAST_MOD_ON,
       LNACCHGS_AUTH_BY,
       LNACCHGS_AUTH_ON)
    VALUES
      (W_ENTITY_NUM,
       W_ACNT_NUM,
       W_CURR_DATE,
       W_SL,
       IDX.LNACCHGS_CHG_CODE,
       W_CURR_CODE,
       0,
       IDX.LNACCHGS_AMT,
       0,
       IDX.LNACCHGS_AMT,
       0,
       IDX.LNACCHGS_AMT,
       IDX.LNACCHGS_AMT,
       NULL,
       0,
       0,
       'MIG',
       W_ENTD_BY,
       W_CURR_DATE,
       NULL,
       NULL,
       W_ENTD_BY,
       W_CURR_DATE);

    INSERT INTO LNACCHGSQBAL
      (LNACCHGSQB_ENTITY_NUM,
       LNACCHGSQB_INTERNAL_ACNUM,
       LNACCHGSQB_CHG_CODE,
       LNACCHGSQB_CURR_CODE,
       LNACCHGSQB_CHGS_PENDING_AMT,
       LNACCHGSQB_CHGS_REVERSAL_AMT,
       LNACCHGSQB_CHGS_RECOV_AMT,
       LNACCHGSQB_CHGS_BAL_AMT)
    VALUES
      (W_ENTITY_NUM,
       W_ACNT_NUM,
       IDX.LNACCHGS_CHG_CODE,
       W_CURR_CODE,
       IDX.LNACCHGS_AMT,
       0, --reversal
       0, --recover
       IDX.LNACCHGS_AMT * -1 --balance
       );

    SELECT NVL(MAX(LNCHGSQLED_ENTRY_SL_NUM), 0) + 1
      INTO W_SL
      FROM LNACCHGSQLED
     WHERE LNCHGSQLED_ENTITY_NUM = W_ENTITY_NUM
       AND LNCHGSQLED_INTERNAL_ACNUM = W_ACNT_NUM
       AND LNCHGSQLED_ENTRY_DATE = W_CURR_DATE;

    INSERT INTO LNACCHGSQLED
      (LNCHGSQLED_ENTITY_NUM,
       LNCHGSQLED_INTERNAL_ACNUM,
       LNCHGSQLED_ENTRY_DATE,
       LNCHGSQLED_ENTRY_SL_NUM,
       LNCHGSQLED_CHG_CODE,
       LNCHGSQLED_ENTRY_TYPE,
       LNCHGSQLED_DB_CR,
       LNCHGSQLED_CHG_CURR,
       LNCHGSQLED_CHGS_AMOUNT,
       LNCHGSQLED_SOURCE_KEY)
    VALUES
      (W_ENTITY_NUM,
       W_ACNT_NUM,
       W_CURR_DATE,
       W_SL,
       IDX.LNACCHGS_CHG_CODE,
       'Q',
       'D',
       W_CURR_CODE,
       IDX.LNACCHGS_AMT,
       NULL);
  END LOOP;

  --Added 28-NOV-2010-Beg

  INSERT INTO LNACINTARHIST
    SELECT 1,
           LNACH_INTERNAL_ACNUM,
           LNACH_EFF_DATE,
           LNACH_AUTO_INSTALL_RECOV_REQD,
           LNACH_RECOV_ACNT_NUM,
           LNACH_ENTD_BY,
           LNACH_ENTD_ON,
           NULL,
           NULL,
           LNACH_ENTD_BY,
           LNACH_ENTD_ON,
           NULL
      FROM LOANACHIST
     WHERE LNACH_AUTO_INSTALL_RECOV_REQD = 1;

  INSERT INTO LNACINTARDTL
    SELECT 1,
           LNACH_INTERNAL_ACNUM,
           LNACH_AUTO_INSTALL_RECOV_REQD,
           LNACH_RECOV_ACNT_NUM
      FROM LOANACHIST
     WHERE LNACH_AUTO_INSTALL_RECOV_REQD = 1;

  INSERT INTO LNACINTARHDTL
    SELECT 1,
           LNACH_INTERNAL_ACNUM,
           LNACH_EFF_DATE,
           LNACH_AUTO_INSTALL_RECOV_REQD,
           LNACH_RECOV_ACNT_NUM
      FROM LOANACHIST
     WHERE LNACH_AUTO_INSTALL_RECOV_REQD = 1;

  INSERT INTO LNACINTAR
    SELECT 1,
           LNACH_INTERNAL_ACNUM,
           LNACH_EFF_DATE,
           LNACH_AUTO_INSTALL_RECOV_REQD,
           LNACH_RECOV_ACNT_NUM
      FROM LOANACHIST
     WHERE LNACH_AUTO_INSTALL_RECOV_REQD = 1;

  /*

   UPDATE LOANACNTS
   SET LNACNT_RECOV_ACNT_NUM = (SELECT IACLINK.IACLINK_INTERNAL_ACNUM
                                FROM IACLINK
                                WHERE IACLINK.IACLINK_ACTUAL_ACNUM =
                                      '0' || LNACNT_RECOV_ACNT_NUM)
   WHERE LNACNT_AUTO_INSTALL_RECOV_REQD = 1;

   UPDATE LOANACHIST
   SET LNACH_RECOV_ACNT_NUM = (SELECT IACLINK.IACLINK_INTERNAL_ACNUM
                               FROM IACLINK
                               WHERE IACLINK.IACLINK_ACTUAL_ACNUM =
                                     '0' || LNACH_RECOV_ACNT_NUM)
   WHERE LNACH_AUTO_INSTALL_RECOV_REQD = 1;

   UPDATE LOANACHISTDTL
   SET LNACHDTL_RECOV_ACNUM = (SELECT IACLINK.IACLINK_INTERNAL_ACNUM
                               FROM IACLINK
                               WHERE IACLINK.IACLINK_ACTUAL_ACNUM =
                                     '0' || LNACHDTL_RECOV_ACNUM)
   WHERE LNACHDTL_INTERNAL_ACNUM IN
         (SELECT LNACNT_INTERNAL_ACNUM
          FROM LOANACNTS
          WHERE LNACNT_AUTO_INSTALL_RECOV_REQD = 1);

   UPDATE LOANACDTL
   SET LNACDTL_RECOV_ACNUM = (SELECT IACLINK.IACLINK_INTERNAL_ACNUM
                              FROM IACLINK
                              WHERE IACLINK.IACLINK_ACTUAL_ACNUM =
                                    '0' || LNACDTL_RECOV_ACNUM)
   WHERE LNACDTL_INTERNAL_ACNUM IN
         (SELECT LNACNT_INTERNAL_ACNUM
          FROM LOANACNTS
          WHERE LNACNT_AUTO_INSTALL_RECOV_REQD = 1);
  */
  --Added 28-NOV-2010-End

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    P_ERR_MSG := SQLERRM;
    ROLLBACK;
    /*
    TRUNCATE TABLE LOANACNTS;
    TRUNCATE TABLE LOANACHIST;
    TRUNCATE TABLE LOANACHISTDTL;
    TRUNCATE TABLE LOANACDTL;
    TRUNCATE TABLE LIMITLINE;
    TRUNCATE TABLE ACASLL;
    TRUNCATE TABLE ACASLLDTL;
    TRUNCATE TABLE LIMITLINEHIST;
    TRUNCATE TABLE LIMFACCURR;
    TRUNCATE TABLE LIMITLINEAUX;
    TRUNCATE TABLE LIMITSERIAL;
    TRUNCATE TABLE ASSETCLS;
    TRUNCATE TABLE ASSETCLSHIST;
    TRUNCATE TABLE LIMITLINECTREQ;
    TRUNCATE TABLE LNACGUAR;
    TRUNCATE TABLE LNACAODHIST;
    TRUNCATE TABLE LNACIRS;
    TRUNCATE TABLE LNACIRSHIST;
    TRUNCATE TABLE LNACRSDTL;
    TRUNCATE TABLE LNACRSHIST;
    TRUNCATE TABLE LNACRS;
    TRUNCATE TABLE LNACRSHDTL;
    TRUNCATE TABLE LNDP;
    TRUNCATE TABLE LNDPHIST;
    TRUNCATE TABLE LNACDSDTL;
    TRUNCATE TABLE LNACDSDTLHIST;
    TRUNCATE TABLE LNSUBVENRECV;
    TRUNCATE TABLE LNACSUBSIDY;
    TRUNCATE TABLE LNSUSPBAL;
    TRUNCATE TABLE LNSUSPLED;
    TRUNCATE TABLE LLACNTOS;
    TRUNCATE TABLE LNACIR;
    TRUNCATE TABLE LNACIRHIST;
    TRUNCATE TABLE LNACIRDTL;
    TRUNCATE TABLE LNACIRHDTL;
    TRUNCATE TABLE LNACMIS;
    TRUNCATE TABLE LNACMISHIST;
    TRUNCATE TABLE LNACCHGSQBAL;
    TRUNCATE TABLE LNACCHGSQLED;
    TRUNCATE TABLE LNACINTCTL;
    TRUNCATE TABLE LNACINTCTLHIST;

    TRUNCATE TABLE LNACINTARHIST;
    TRUNCATE TABLE LNACINTARDTL;
    TRUNCATE TABLE LNACINTARHDTL;
    TRUNCATE TABLE LNACINTAR;

    */

END SP_MIG_LOANS;
/
