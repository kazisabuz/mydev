/* Formatted on 9/13/2023 12:35:30 PM (QP5 v5.388) */
CREATE OR REPLACE PROCEDURE SP_LNACBAL (
    V_ENTITY_NUM   IN     NUMBER,
    P_BRN                 NUMBER,
    P_PROD_CODE           NUMBER,
    P_ACTYPE              VARCHAR2,
    P_CUST_ID             NUMBER,
    P_CURRENCY            VARCHAR2,
    P_ASON_DT             DATE,
    P_WRITEOFF            VARCHAR2,
    P_TMP_SER         OUT NUMBER,
    P_ERR_MSG         OUT VARCHAR2)
IS
   

    W_SQL                    VARCHAR2 (1300);
    W_SQL1                   VARCHAR2 (1300);
    W_CBD                    DATE;
    W_BRN                    NUMBER := 0;
    W_PROD_CODE              NUMBER := 0;
    W_PROD_NAME              VARCHAR2 (50) := '';
    W_ACTYPE                 VARCHAR2 (10) := '';
    W_CUST_ID                NUMBER := 0;
    W_CURRENCY               VARCHAR2 (3) := '';
    W_ASON_DATE              DATE;
    W_WRITEOFF               VARCHAR2 (1);
    W_PRODUCT_FOR_RUN_ACS    CHAR (1);
    W_PRODUCT_FOR_LOANS      CHAR (1);
    W_ACNTS_OPENING_DATE     DATE;

    W_ACNTS_INTERNAL_ACNUM   NUMBER (14);
    W_ACNT_NAME              VARCHAR2 (50);
    W_TOT_PRIN_DB_AC         NUMBER (18, 3);
    W_TOT_PRIN_CR_AC         NUMBER (18, 3);
    W_TOT_PRIN_DB_BC         NUMBER (18, 3);
    W_TOT_PRIN_CR_BC         NUMBER (18, 3);
    W_TOT_INT_DB_AC          NUMBER (18, 3);
    W_TOT_INT_CR_AC          NUMBER (18, 3);
    W_TOT_INT_DB_BC          NUMBER (18, 3);
    W_TOT_INT_CR_BC          NUMBER (18, 3);
    W_TOT_CHG_DB_AC          NUMBER (18, 3);
    W_TOT_CHG_CR_AC          NUMBER (18, 3);
    W_TOT_CHG_DB_BC          NUMBER (18, 3);
    W_TOT_CHG_CR_BC          NUMBER (18, 3);

    W_PRIN_BAL               NUMBER (18, 3);
    W_INT_BAL                NUMBER (18, 3);
    W_CHG_BAL                NUMBER (18, 3);
    W_BAL                    NUMBER (18, 3);

    W_INT_RATE               NUMBER (18, 3);
    W_SINGLE_INT_RATE        NUMBER (8, 5);
    W_MULT_INT_RATE          NUMBER (8, 5);
    W_MULT_AMT               NUMBER (18, 3);
    W_MULT_SLAB_FLG          NUMBER (1);


    W_UNUTILIZED_LIMIT       NUMBER (18, 3);
    W_LIMIT_AMT              NUMBER (18, 3);
    W_SANC_LIMIT_AMT         NUMBER (18, 3);
    W_AVAL_LIMIT_AMT         NUMBER (18, 3);                             -- BB
    --S.Ramya       06-MAR-2013 -- BEGIN
    W_DUE_DATE               DATE;
    W_LMT_SANCTION_DATE      DATE;
    W_STATUS                 VARCHAR2 (25);
    --S.Ramya       06-MAR-2013 -- END

    W_ERR_MSG                VARCHAR2 (1300);
    W_TEMP_SER_FLG           NUMBER (7) := 0;
    W_TEMP_SER               NUMBER;
    MYEXCEPTION              EXCEPTION;

    -- R.Senthil Kumar - 13-04-2010 - Begin
    W_OD_AMT                 NUMBER (18, 3) := 0;
    W_OD_DATE                DATE := NULL;

    W_SME_NSME_CODE_DESC     VARCHAR2 (100);


    -- R.Senthil Kumar - 13-04-2010 - End


    TYPE ACNUM_TAB IS RECORD
    (
        ACNTS_INTERNAL_ACNUM    NUMBER (14),
        ACNTS_CURR_CODE         VARCHAR2 (3),
        ACNTS_PROD_CODE         VARCHAR2 (6),
        ACNTS_NAME1             VARCHAR2 (50),
        PRODUCT_NAME            VARCHAR2 (50),
        PRODUCT_FOR_RUN_ACS     CHAR (1),
        PRODUCT_FOR_LOANS       CHAR (1),
        ACNTS_OPENING_DATE      DATE
    );                                                      --added by Tahmina


    TYPE IN_ACNUM_TAB IS TABLE OF ACNUM_TAB
        INDEX BY PLS_INTEGER;

    V_ACNUM_TAB              IN_ACNUM_TAB;

    -- Fetching BALANCE
    PROCEDURE FETCH_BALANCE
    IS
    BEGIN
        SP_LNTRANSUM (PKG_ENTITY.FN_GET_ENTITY_CODE,
                      W_ACNTS_INTERNAL_ACNUM,
                      W_ASON_DATE,
                      W_CBD,
                      NULL,
                      NULL,
                      W_ERR_MSG,
                      W_TOT_PRIN_DB_AC,
                      W_TOT_PRIN_CR_AC,
                      W_TOT_PRIN_DB_BC,
                      W_TOT_PRIN_CR_BC,
                      W_TOT_INT_DB_AC,
                      W_TOT_INT_CR_AC,
                      W_TOT_INT_DB_BC,
                      W_TOT_INT_CR_BC,
                      W_TOT_CHG_DB_AC,
                      W_TOT_CHG_CR_AC,
                      W_TOT_CHG_DB_BC,
                      W_TOT_CHG_CR_BC);

        IF W_ERR_MSG IS NULL
        THEN
            W_PRIN_BAL := W_TOT_PRIN_CR_AC - W_TOT_PRIN_DB_AC;
            W_INT_BAL := W_TOT_INT_CR_AC - W_TOT_INT_DB_AC;
            W_CHG_BAL := W_TOT_CHG_CR_AC - W_TOT_CHG_DB_AC;
            W_BAL := W_PRIN_BAL + W_INT_BAL + W_CHG_BAL;
        ELSE
            W_ERR_MSG := 'ERROR IN FETCH_BALANCE  ' || SQLERRM;

            RAISE MYEXCEPTION;
        END IF;
    END FETCH_BALANCE;

    -- Fetching Limit
    PROCEDURE FETCH_LIMIT
    IS
        W_DUMMY_INPUT    NUMBER;
        W_DUMMY_OUTPUT   NUMBER;
    BEGIN
        W_DUMMY_INPUT := 0;
        W_UNUTILIZED_LIMIT := 0;

       <<CALL_GETLMTASONDATE>>
        BEGIN
            /*PKG_SP_INTERFACE.SP_GETLMTASONDATE(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                               W_DUMMY_INPUT,
                                               W_DUMMY_INPUT,
                                               W_ACNTS_INTERNAL_ACNUM,
                                               W_ASON_DATE,
                                               W_LIMIT_AMT,
                                               W_SANC_LIMIT_AMT,
                                               W_DUMMY_OUTPUT,
                                               W_ERR_MSG);*/
            -- Rem -- BB

            PKG_SP_INTERFACE.SP_GETLMT_ASONDATE (
                PKG_ENTITY.FN_GET_ENTITY_CODE,
                W_DUMMY_INPUT,
                W_DUMMY_INPUT,
                W_ACNTS_INTERNAL_ACNUM,
                W_ASON_DATE,
                W_LIMIT_AMT,
                W_AVAL_LIMIT_AMT,
                W_DUMMY_OUTPUT,
                W_SANC_LIMIT_AMT,
                W_ERR_MSG);
        EXCEPTION
            WHEN OTHERS
            THEN
                IF (TRIM (W_ERR_MSG) IS NULL)
                THEN
                    W_ERR_MSG := 'Error in CALL_GETLMTASONDATE ' || SQLERRM;
                END IF;

                RAISE MYEXCEPTION;
        END CALL_GETLMTASONDATE;

        IF W_PRODUCT_FOR_RUN_ACS <> '1'
        THEN
            /*IF W_TOT_PRIN_DB_AC <= W_SANC_LIMIT_AMT THEN
              W_UNUTILIZED_LIMIT := W_SANC_LIMIT_AMT - W_TOT_PRIN_DB_AC;
            ELSE*/
            -- Rem -- BB
            IF W_TOT_PRIN_DB_AC <= W_AVAL_LIMIT_AMT
            THEN
                W_UNUTILIZED_LIMIT := W_AVAL_LIMIT_AMT - W_TOT_PRIN_DB_AC;
            ELSE
                W_UNUTILIZED_LIMIT := 0;
            END IF;
        END IF;

        IF W_PRODUCT_FOR_RUN_ACS = '1'
        THEN
            IF W_BAL < 0
            THEN
                IF ABS (W_BAL) < W_LIMIT_AMT
                THEN
                    W_UNUTILIZED_LIMIT := W_LIMIT_AMT - ABS (W_BAL);
                ELSE
                    W_UNUTILIZED_LIMIT := 0;
                END IF;
            ELSE
                W_UNUTILIZED_LIMIT := W_LIMIT_AMT;
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF TRIM (W_ERR_MSG) IS NULL
            THEN
                W_ERR_MSG := 'Error in Getting LimitLine' || SQLERRM;
            END IF;

            RAISE MYEXCEPTION;
    END FETCH_LIMIT;

    -- R.Senthil Kumar - CHN - 05-05-2009- Begin
    -- Fetching Interest Rate
    PROCEDURE FETCH_INT_RATE
    IS
        W_TEMP_INT_RATE   NUMBER (18, 3);
        W_SLAB_APPL       NUMBER (1);
        W_INT_ON_AMT      NUMBER (18, 3);
    BEGIN
        W_INT_RATE := 0;
        W_SINGLE_INT_RATE := 0;
        W_MULT_INT_RATE := 0;
        W_MULT_AMT := 0;
        W_MULT_SLAB_FLG := 0;
        W_SLAB_APPL := 0;
        W_INT_ON_AMT := 0;
        W_TEMP_INT_RATE := 0;

       <<CALL_LOANINTRATEASON>>
        BEGIN
            PKG_LOANINTRATEASON.PV_ERR_MSG := '';
            PKG_LOANINTRATEASON.SP_LOANINTRATEASON (
                PKG_ENTITY.FN_GET_ENTITY_CODE,
                W_ACNTS_INTERNAL_ACNUM,
                TO_CHAR (TO_DATE (W_ASON_DATE, 'DD-MON-YY'), 'DD-MON-YYYY'),
                0);

            IF TRIM (PKG_LOANINTRATEASON.PV_ERR_MSG) IS NULL
            THEN
                W_SINGLE_INT_RATE := PKG_LOANINTRATEASON.V_SINGLE_INT_RATE;

                IF W_SINGLE_INT_RATE > 0
                THEN
                    W_INT_RATE := W_SINGLE_INT_RATE;
                ELSE
                    FOR IDX
                        IN 1 ..
                           PKG_LOANINTRATEASON.V_SLAB_INIT_AMT_RATE.COUNT
                    LOOP
                        W_MULT_INT_RATE :=
                            PKG_LOANINTRATEASON.V_SLAB_INIT_AMT_RATE (IDX).SLAB_INIT_RATE;
                        W_MULT_AMT :=
                            PKG_LOANINTRATEASON.V_SLAB_INIT_AMT_RATE (IDX).SLAB_AMOUNT;
                        W_SLAB_APPL :=
                            PKG_LOANINTRATEASON.V_LNACIR_SLAB_APPL_CHOICE;

                        IF TRIM (W_SLAB_APPL) = 2
                        THEN
                            W_INT_RATE := 0;
                            W_MULT_SLAB_FLG := 1;
                            EXIT;
                        ELSE
                            W_INT_ON_AMT := W_BAL;
                            W_TEMP_INT_RATE := 0;

                            IF W_INT_ON_AMT <= W_MULT_AMT
                            THEN
                                W_TEMP_INT_RATE := W_MULT_INT_RATE;
                                EXIT;
                            END IF;

                            IF W_MULT_AMT = 0
                            THEN
                                IF IDX > 1
                                THEN
                                    W_TEMP_INT_RATE :=
                                        PKG_LOANINTRATEASON.V_SLAB_INIT_AMT_RATE (
                                            IDX - 1).SLAB_INIT_RATE;
                                END IF;

                                EXIT;
                            END IF;
                        END IF;
                    END LOOP;

                    W_INT_RATE := W_TEMP_INT_RATE;
                END IF;
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                IF (TRIM (W_ERR_MSG) IS NULL)
                THEN
                    W_ERR_MSG := 'Error in CALL_LOANINTRATEASON ' || SQLERRM;
                END IF;

                RAISE MYEXCEPTION;
        END CALL_LOANINTRATEASON;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF TRIM (W_ERR_MSG) IS NULL
            THEN
                W_ERR_MSG := 'Error in FETCH_INT_RATE' || SQLERRM;
            END IF;

            RAISE MYEXCEPTION;
    END FETCH_INT_RATE;

    -- R.Senthil Kumar - CHN - 05-05-2009- End

    -- R.Senthil Kumar - CHN - 13-04-2010-    Begin
    PROCEDURE GET_OVERDUE
    IS
        W_TMP_ERR_MSG                 VARCHAR2 (5000) := '';
        W_TMP_OD_AMT                  NUMBER (18, 3) := 0;
        W_TMP_OD_DATE                 DATE := NULL;
        W_DUMMY_N                     NUMBER (18, 3);
        W_DUMMY_C                     VARCHAR2 (12) := '';



        V_ACNTS_CURR_CODE             VARCHAR2 (3);
        W_OPENING_DATE                DATE;
        W_MIG_DATE                    DATE;
        V_ACNTS_PROD_CODE             NUMBER (4);
        V_LNPRD_INT_RECOVERY_OPTION   CHAR (1);
        W_PRODUCT_FOR_RUN_ACS         VARCHAR (1);
        W_LIMIT_EXPIRY_DATE           DATE;
        W_ACASLL_CLINET_NUM           NUMBER (12);
        W_ACASLL_LIMITLINE_NUM        NUMBER (12);
    BEGIN
        W_OD_AMT := 0;
        W_OD_DATE := NULL;

        SELECT LNODHIST_OD_AMT, LNODHIST_OD_DATE
          INTO W_OD_AMT, W_OD_DATE
          FROM LNODHIST
         WHERE     LNODHIST_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
               AND LNODHIST_INTERNAL_ACNUM = W_ACNTS_INTERNAL_ACNUM
               AND LNODHIST_OD_AMT > 0
               AND LNODHIST_OD_DATE IS NOT NULL
               AND LNODHIST_EFF_DATE =
                   (SELECT MAX (LNODHIST_EFF_DATE)
                     FROM LNODHIST
                    WHERE     LNODHIST_ENTITY_NUM =
                              PKG_ENTITY.FN_GET_ENTITY_CODE
                          AND LNODHIST_INTERNAL_ACNUM =
                              W_ACNTS_INTERNAL_ACNUM
                          AND LNODHIST_EFF_DATE <= W_ASON_DATE);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            IF W_PRODUCT_FOR_LOANS = '1' AND W_PRODUCT_FOR_RUN_ACS = '1'
            THEN
               <<FETCH_OVERDUE>>
                BEGIN
                    SELECT ACNTS_CURR_CODE,
                           ACNTS_OPENING_DATE,
                           MIG_END_DATE,
                           ACNTS_PROD_CODE,
                           LNPRD_INT_RECOVERY_OPTION,
                           PRODUCT_FOR_RUN_ACS,
                           (SELECT LMTLINE_LIMIT_EXPIRY_DATE
                             FROM LIMITLINE, ACASLLDTL
                            WHERE     LMTLINE_ENTITY_NUM = ACNTS_ENTITY_NUM
                                  AND ACASLLDTL_ENTITY_NUM = ACNTS_ENTITY_NUM
                                  AND LMTLINE_CLIENT_CODE =
                                      ACASLLDTL_CLIENT_NUM
                                  AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM
                                  AND ACASLLDTL_INTERNAL_ACNUM =
                                      ACNTS_INTERNAL_ACNUM),
                           ACNTS_CLIENT_NUM,
                           NVL (
                               (SELECT ACASLLDTL_LIMIT_LINE_NUM
                                 FROM ACASLLDTL
                                WHERE     ACASLLDTL_ENTITY_NUM = 1
                                      AND ACASLLDTL_INTERNAL_ACNUM =
                                          ACNTS_INTERNAL_ACNUM),
                               0)
                      INTO V_ACNTS_CURR_CODE,
                           W_OPENING_DATE,
                           W_MIG_DATE,
                           V_ACNTS_PROD_CODE,
                           V_LNPRD_INT_RECOVERY_OPTION,
                           W_PRODUCT_FOR_RUN_ACS,
                           W_LIMIT_EXPIRY_DATE,
                           W_ACASLL_CLINET_NUM,
                           W_ACASLL_LIMITLINE_NUM
                      FROM ACNTS,
                           PRODUCTS,
                           LNPRODPM,
                           MIG_DETAIL
                     WHERE     ACNTS_ENTITY_NUM =
                               PKG_ENTITY.FN_GET_ENTITY_CODE
                           AND ACNTS_INTERNAL_ACNUM = W_ACNTS_INTERNAL_ACNUM
                           AND ACNTS_PROD_CODE = PRODUCT_CODE
                           AND LNPRD_PROD_CODE = PRODUCT_CODE
                           AND BRANCH_CODE = ACNTS_BRN_CODE;



                    PKG_LNOVERDUE.SP_LNOVERDUE (
                        PKG_ENTITY.FN_GET_ENTITY_CODE,
                        W_ACNTS_INTERNAL_ACNUM,
                        W_ASON_DATE,
                        W_CBD,
                        W_TMP_ERR_MSG,
                        W_DUMMY_N,
                        W_DUMMY_N,
                        W_DUMMY_N,
                        W_DUMMY_N,
                        W_TMP_OD_AMT,
                        W_TMP_OD_DATE,
                        W_DUMMY_N,
                        W_DUMMY_C,
                        W_DUMMY_N,
                        W_DUMMY_C,
                        W_DUMMY_N,
                        W_DUMMY_C,
                        V_ACNTS_CURR_CODE,
                        W_OPENING_DATE,
                        W_MIG_DATE,
                        V_ACNTS_PROD_CODE,
                        V_LNPRD_INT_RECOVERY_OPTION,
                        W_PRODUCT_FOR_RUN_ACS,
                        W_LIMIT_EXPIRY_DATE,
                        W_ACASLL_CLINET_NUM,
                        W_ACASLL_LIMITLINE_NUM,
                        1);

                    IF TRIM (W_TMP_ERR_MSG) IS NULL
                    THEN
                        W_OD_AMT := W_TMP_OD_AMT;
                        W_OD_DATE := W_TMP_OD_DATE;
                    END IF;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        W_OD_AMT := 0;
                        W_OD_DATE := NULL;
                END FETCH_OVERDUE;
            END IF;
        WHEN OTHERS
        THEN
            IF TRIM (W_ERR_MSG) IS NULL
            THEN
                W_ERR_MSG := 'Error in GET_OVERDUE - ' || SQLERRM;
            END IF;

            RAISE MYEXCEPTION;
    END GET_OVERDUE;

    PROCEDURE FETCH_SMEDATA
    IS
    BEGIN
        SELECT M.LNACMISH_NATURE_BORROWAL_AC || ' - ' || B.BSRNBAC_DESCN
          INTO W_SME_NSME_CODE_DESC
          FROM LNACMISHIST M, BSRNBAC B
         WHERE     M.LNACMISH_NATURE_BORROWAL_AC = B.BSRNBAC_CODE
               AND M.LNACMISH_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
               AND M.LNACMISH_INTERNAL_ACNUM = W_ACNTS_INTERNAL_ACNUM
               AND M.LNACMISH_EFF_DATE =
                   (SELECT MAX (H.LNACMISH_EFF_DATE)
                     FROM LNACMISHIST H
                    WHERE     H.LNACMISH_ENTITY_NUM =
                              PKG_ENTITY.FN_GET_ENTITY_CODE
                          AND H.LNACMISH_INTERNAL_ACNUM =
                              W_ACNTS_INTERNAL_ACNUM
                          AND H.LNACMISH_EFF_DATE <= W_ASON_DATE);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            W_SME_NSME_CODE_DESC := '';
        WHEN OTHERS
        THEN
            W_ERR_MSG := ' ERROR IN FETCH_SMEDATA ' || SQLERRM;

            RAISE MYEXCEPTION;
    END FETCH_SMEDATA;

    -- Update the records into RTMPLNACBAL
    PROCEDURE UPDATE_RTMPLNACBAL
    IS
    BEGIN
        IF W_TEMP_SER_FLG <> 1
        THEN
            INSERT INTO RTMPLNACBAL (RTMPLNACBAL_TMP_SER,
                                     RTMPLNACBAL_BRN_CODE,
                                     RTMPLNACBAL_PROD_CODE,
                                     RTMPLNACBAL_CURR_CODE,
                                     RTMPLNACBAL_INTERNAL_ACNUM,
                                     RTMPLNACBAL_ACTUAL_ACNUM,
                                     RTMPLNACBAL_ACNTS_NAME,
                                     RTMPLNACBAL_PROD_NAME,
                                     RTMPLNACBAL_SANC_LIMIT,
                                     RTMPLNACBAL_BAL,
                                     RTMPLNACBAL_PRIN_BAL,
                                     RTMPLNACBAL_INT_BAL,
                                     RTMPLNACBAL_CHG_BAL,
                                     RTMPLNACBAL_UNUTIL_LIMIT,
                                     RTMPLNACBAL_INT_RATE,
                                     RTMPLNACBAL_MULT_SLAB_RATE,
                                     RTMPLNACBAL_OD_AMT,
                                     RTMPLNACBAL_OD_DATE,
                                     RTMPLNACBAL_AVAL_LIMIT,
                                     RTMPLNACBAL_STATUS,
                                     RTMPLNACBAL_DUE_DATE,
                                     RTMPLNACBAL_AC_OPEN_DATE,
                                     RTMPLNACBAL_LMT_SANCTION_DATE,
                                     RTMPLNACBAL_SME_NSME_CODE_DESC)
                     VALUES (
                                W_TEMP_SER,
                                W_BRN,
                                W_PROD_CODE,
                                W_CURRENCY,
                                W_ACNTS_INTERNAL_ACNUM,
                                FACNO (PKG_ENTITY.FN_GET_ENTITY_CODE,
                                       W_ACNTS_INTERNAL_ACNUM),
                                W_ACNT_NAME,
                                W_PROD_NAME,
                                W_SANC_LIMIT_AMT,
                                W_BAL,
                                W_PRIN_BAL,
                                W_INT_BAL,
                                W_CHG_BAL,
                                W_UNUTILIZED_LIMIT,
                                W_INT_RATE,
                                W_MULT_SLAB_FLG,
                                W_OD_AMT,
                                W_OD_DATE,
                                W_AVAL_LIMIT_AMT,
                                W_STATUS,
                                W_DUE_DATE,
                                W_ACNTS_OPENING_DATE,
                                W_LMT_SANCTION_DATE,
                                W_SME_NSME_CODE_DESC);

            W_TEMP_SER_FLG := 0;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            W_ERR_MSG := 'Error in Insertion' || SQLERRM;
            W_TEMP_SER_FLG := 1;
            RAISE MYEXCEPTION;
    END UPDATE_RTMPLNACBAL;
BEGIN
    --ENTITY CODE COMMONLY ADDED - 06-11-2009  - BEG
    PKG_ENTITY.SP_SET_ENTITY_CODE (V_ENTITY_NUM);

    --ENTITY CODE COMMONLY ADDED - 06-11-2009  - END
    SELECT PKG_PB_GLOBAL.SP_GET_REPORT_SL (PKG_ENTITY.FN_GET_ENTITY_CODE)
      INTO W_TEMP_SER
      FROM DUAL;

    SELECT MN_CURR_BUSINESS_DATE
      INTO W_CBD
      FROM MAINCONT
     WHERE MN_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE;

    IF P_BRN IS NULL
    THEN
        W_ERR_MSG := 'Branch Code Not Passed';
        RAISE MYEXCEPTION;
    ELSE
        W_BRN := P_BRN;
    END IF;

    IF P_PROD_CODE IS NOT NULL
    THEN
        W_PROD_CODE := P_PROD_CODE;
    ELSE
        W_PROD_CODE := 0;
        W_PRODUCT_FOR_RUN_ACS := 0;
    END IF;

    IF P_ACTYPE IS NOT NULL
    THEN
        W_ACTYPE := P_ACTYPE;
    END IF;

    IF P_CUST_ID IS NOT NULL
    THEN
        W_CUST_ID := P_CUST_ID;
    END IF;

    IF P_CURRENCY IS NULL
    THEN
        W_ERR_MSG := 'Currency Code Not Passed';
        RAISE MYEXCEPTION;
    ELSE
        W_CURRENCY := P_CURRENCY;
    END IF;

    IF P_ASON_DT IS NULL
    THEN
        W_ERR_MSG := 'Ason Date Not Passed';
        RAISE MYEXCEPTION;
    ELSE
        W_ASON_DATE := P_ASON_DT;
    END IF;

    IF P_WRITEOFF IS NULL
    THEN
        W_ERR_MSG := 'Write Off Not Passed';
        RAISE MYEXCEPTION;
    ELSE
        W_WRITEOFF := P_WRITEOFF;
    END IF;

    W_SQL := 'SELECT ACNTS_INTERNAL_ACNUM,
                     ACNTS_CURR_CODE,
                     ACNTS_PROD_CODE,
                     ACNTS_AC_NAME1,
                     PRODUCT_NAME,
                     PRODUCT_FOR_RUN_ACS,
                     PRODUCT_FOR_LOANS,
                     ACNTS_OPENING_DATE
               FROM ACNTS, LOANACNTS,PRODUCTS
                WHERE LNACNT_ENTITY_NUM = :1
                AND ACNTS_ENTITY_NUM = :2
                AND  ACNTS_BRN_CODE=:3
                AND (ACNTS_CLOSURE_DATE IS NULL OR
                     ACNTS_CLOSURE_DATE > :4)
                AND  ACNTS_OPENING_DATE <= :5 AND
                     ACNTS_INTERNAL_ACNUM = LNACNT_INTERNAL_ACNUM AND
                     ACNTS_CURR_CODE = :6
                AND ACNTS_PROD_CODE = PRODUCT_CODE ';

    IF P_PROD_CODE > 0
    THEN
        W_SQL := W_SQL || ' AND ACNTS_PROD_CODE = ' || W_PROD_CODE;
    END IF;

    IF P_ACTYPE <> '
             '
    THEN
        W_SQL := W_SQL || ' AND
             ACNTS_AC_TYPE = ' || CHR (39) || W_ACTYPE || CHR (39);
    END IF;

    IF P_CUST_ID > 0
    THEN
        W_SQL := W_SQL || ' AND ACNTS_CLIENT_NUM = ' || W_CUST_ID;
    END IF;


    IF NVL (P_WRITEOFF, 'N') = 'Y'
    THEN
        W_SQL :=
               W_SQL
            || 'AND EXISTS  (select * from LNWRTOFF 
      WHERE LNWRTOFF_ENTITY_NUM = '
            || CHR (39)
            || V_ENTITY_NUM
            || CHR (39)
            || ' and LNWRTOFF_ACNT_NUM = ACNTS_INTERNAL_ACNUM and LNWRTOFF_WRTOFF_DATE <= '
            || CHR (39)
            || W_ASON_DATE
            || CHR (39)
            || ' and LNWRTOFF_SL_NUM = 1
      and LNWRTOFF_REJ_BY is null)';
    END IF;



    EXECUTE IMMEDIATE W_SQL
        BULK COLLECT INTO V_ACNUM_TAB
        USING V_ENTITY_NUM,
              V_ENTITY_NUM,
              W_BRN,
              W_ASON_DATE,
              W_ASON_DATE,
              W_CURRENCY;

    IF V_ACNUM_TAB.COUNT > 0
    THEN
        FOR IDX IN V_ACNUM_TAB.FIRST .. V_ACNUM_TAB.LAST
        LOOP
            W_BAL := 0;
            W_PRIN_BAL := 0;
            W_INT_BAL := 0;
            W_CHG_BAL := 0;
            W_INT_RATE := 0;
            W_MULT_SLAB_FLG := 0;
            W_SQL := NULL;
            W_DUE_DATE := '';

            W_ACNTS_INTERNAL_ACNUM := V_ACNUM_TAB (IDX).ACNTS_INTERNAL_ACNUM;
            W_CURRENCY := V_ACNUM_TAB (IDX).ACNTS_CURR_CODE;
            W_PROD_CODE := V_ACNUM_TAB (IDX).ACNTS_PROD_CODE;
            W_ACNT_NAME := V_ACNUM_TAB (IDX).ACNTS_NAME1;
            W_PROD_NAME := V_ACNUM_TAB (IDX).PRODUCT_NAME;
            W_PRODUCT_FOR_RUN_ACS := V_ACNUM_TAB (IDX).PRODUCT_FOR_RUN_ACS;
            W_PRODUCT_FOR_LOANS := V_ACNUM_TAB (IDX).PRODUCT_FOR_LOANS;
            W_ACNTS_OPENING_DATE := V_ACNUM_TAB (IDX).ACNTS_OPENING_DATE; --added by Tahmina

           ---S.Ramya Begin
           -- IF W_PRODUCT_FOR_LOANS  = 1 AND W_PRODUCT_FOR_RUN_ACS = 1 THEN
           <<DUE_DATE>>
            BEGIN
                W_SQL1 :=
                    'SELECT LMTLINE_LIMIT_EXPIRY_DATE,LMTLINE_DATE_OF_SANCTION FROM ACASLLDTL,LIMITLINE  WHERE ACASLLDTL_INTERNAL_ACNUM = :1
                      AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM AND LMTLINE_ENTITY_NUM = ACASLLDTL_ENTITY_NUM
                      AND ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
                      AND ACASLLDTL_ENTITY_NUM = :2
                      AND LMTLINE_ENTITY_NUM = :3';

                EXECUTE IMMEDIATE W_SQL1
                    INTO W_DUE_DATE, W_LMT_SANCTION_DATE
                    USING W_ACNTS_INTERNAL_ACNUM, V_ENTITY_NUM, V_ENTITY_NUM;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    W_DUE_DATE := '';
                    W_LMT_SANCTION_DATE := '';
            END DUE_DATE;

           --ELSE
           --   <<DUE_DATE1>>
           --  BEGIN
           --    W_SQL1  := 'SELECT ADD_MONTHS(LNACRSDTL_REPAY_FROM_DATE,LNACRSDTL_NUM_OF_INSTALLMENT)  FROM LNACRSDTL WHERE LNACRSDTL_INTERNAL_ACNUM = '||W_ACNTS_INTERNAL_ACNUM||'';
           --   EXECUTE  IMMEDIATE W_SQL1 INTO W_DUE_DATE;
           --  EXCEPTION
           --   WHEN NO_DATA_FOUND THEN
           --      W_DUE_DATE := '';
           -- END DUE_DATE1;
           -- END IF;



           <<STATUS>>
            BEGIN
                W_SQL1 := NULL;
                W_SQL1 := 'SELECT CASE
                 WHEN EXISTS (SELECT L.LNACRS_PURPOSE
                 FROM LNACRS L
                 WHERE L.LNACRS_PURPOSE = ''R''
                 AND AD.ASSETCD_NONPERF_CAT <> ''3''
                 AND AD.ASSETCD_SPECIAL_PURPOSE = ''0''
                 AND L.LNACRS_INTERNAL_ACNUM = :1) THEN
                 ''UC''
                 ELSE
                 AD.ASSETCD_CONC_DESCN
                 END AS ASSETCD_CONC_DESCN
                 FROM ASSETCLS, ASSETCD AD
                 WHERE ASSETCLS_INTERNAL_ACNUM = :2
                 AND ASSETCD_CODE = ASSETCLS_ASSET_CODE
                 AND ASSETCLS_ENTITY_NUM = :3';

                EXECUTE IMMEDIATE W_SQL1
                    INTO W_STATUS
                    USING W_ACNTS_INTERNAL_ACNUM,
                          W_ACNTS_INTERNAL_ACNUM,
                          V_ENTITY_NUM;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    W_STATUS := '';
            END STATUS;

            PKG_LOANINTRATEASON.PV_ERR_MSG := '';

            FETCH_BALANCE;
            FETCH_LIMIT;
            -- R.Senthil Kumar - CHN - 05-05-2009- Added
            FETCH_INT_RATE;
            GET_OVERDUE;         -- R.Senthil Kumar - CHN - 13-04-2010 - Added
            FETCH_SMEDATA;
            UPDATE_RTMPLNACBAL;
        END LOOP;
    END IF;

    IF W_TEMP_SER_FLG = 0
    THEN
        P_TMP_SER := W_TEMP_SER;
    ELSE
        P_TMP_SER := 0;
    END IF;

    COMMIT;
    V_ACNUM_TAB.DELETE;
EXCEPTION
    WHEN MYEXCEPTION
    THEN
        P_ERR_MSG := W_ERR_MSG;
        ROLLBACK;
        V_ACNUM_TAB.DELETE;
    WHEN OTHERS
    THEN
        W_ERR_MSG := SQLERRM;
        P_ERR_MSG := W_ERR_MSG;
        ROLLBACK;
        V_ACNUM_TAB.DELETE;
END SP_LNACBAL;
/
