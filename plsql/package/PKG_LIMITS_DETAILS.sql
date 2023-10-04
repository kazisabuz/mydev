/* Formatted on 7/24/2023 6:08:42 PM (QP5 v5.388) */
CREATE OR REPLACE PACKAGE BODY PKG_LIMITS_DETAILS
IS
    TEMP_DATA                   PKG_LIMITS_DETAILS.REC_TYPE;



    TYPE TEMP_RECORD IS RECORD
    (
        V_LIMIT_NO_IO         LIMITLINE.LMTLINE_NUM%TYPE,
        V_PROD_GRP_O          LIMITLINE.LMTLINE_FACILITY_GRP_CODE%TYPE,
        V_PROD_O              LIMITLINE.LMTLINE_PROD_CODE%TYPE,
        V_SHARED_LIM_O        LIMITLINE.LMTLINE_SHARED_LIMIT_LINE%TYPE,
        V_LIM_DESC_O          LIMITLINE.LMTLINE_FACILITY_DESCN%TYPE,
        V_LIM_CURR_O          LIMITLINE.LMTLINE_SANCTION_CURR%TYPE,
        V_LIM_EFF_DT_O        LIMITLINE.LMTLINE_LIMIT_EFF_DATE%TYPE,
        V_LIM_AUTH_ON_O       LIMITLINE.LMTLINE_AUTH_ON%TYPE,
        V_LIM_EXP_DT_O        LIMITLINE.LMTLINE_LIMIT_EXPIRY_DATE%TYPE,
        V_PARENT_LIM_NO_O     LIMITLINE.LMTLINE_SUB_LIMIT_LINE%TYPE,
        V_SANC_AMT_O          LIMITLINE.LMTLINE_SANCTION_AMT%TYPE,
        V_EFF_DP_AMT_O        LIMITLINE.LMTLINE_SANCTION_AMT%TYPE,
        V_UTILIZED_AMT_O      LIMITLINE.LMTLINE_SANCTION_AMT%TYPE,
        V_DISBURSED_AMT_O     LLACNTOS.LLACNTOS_LIMIT_CURR_DISB_MADE%TYPE,
        V_AVLBL_AMT_O         LIMITLINE.LMTLINE_SANCTION_AMT%TYPE,
        V_EXCESS_AMT_O        LIMITLINE.LMTLINE_SANCTION_AMT%TYPE,
        V_MARK_IN_AMT_O       LIMITLINE.LMTLINE_MARKED_AMT_INTO%TYPE,
        V_MARK_OUT_AMT_O      LIMITLINE.LMTLINE_MARKED_AMT_OUT%TYPE,
        V_ERR_MSG_O           PKG_COMMON_TYPES.STRING_T,
        V_REVOLV_GRP_LMT_O    LIMITLINE.LMTLINE_GROUP_LEVEL_LIMIT%TYPE
    );


    TYPE TABLEA IS TABLE OF TEMP_RECORD
        INDEX BY PLS_INTEGER;

    T_TEMP_REC                  TABLEA;
    --V_BASE_CURR_CODE            VARCHAR (10);
    --  V_CURR_BUS_DATE             DATE;
    ---  V_ERR_STATUS                CHAR (1);
    V_ERR_MSG                   VARCHAR (500) := ' ';
    V_LIMIT_OS_AMT              NUMBER (18, 2) := 0;
    W_TX_AMT                    NUMBER (18, 2) := 0;
    W_TX_CLIENT                 NUMBER (18) := '0';
    C_ERR_LIMIT_CURR   CONSTANT VARCHAR2 (4) NOT NULL DEFAULT '0121';
    C_ERR_LIMIT_OS     CONSTANT VARCHAR2 (4) NOT NULL DEFAULT '0122';
    V_CURR_BUS_DATE             DATE
        DEFAULT PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (
                    PKG_ENTITY.FN_GET_ENTITY_CODE);
    V_BASE_CURR_CODE            INSTALL.INS_BASE_CURR_CODE%TYPE
        DEFAULT PKG_PB_GLOBAL.FN_GET_INS_BASE_CURR (
                    PKG_ENTITY.FN_GET_ENTITY_CODE);
    V_ERR_STATUS                VARCHAR2 (4) DEFAULT '0000';

    --V_ERR_MSG                   VARCHAR2 (100);



    PROCEDURE SP_AGN_VALUE (P_ACC_CURR        IN     VARCHAR2,
                            P_LIMIT_CURR      IN     VARCHAR2,
                            P_ACC_AMT         IN     NUMBER,
                            P_LIMIT_CRATE     IN     NUMBER,
                            P_OUT_LIMIT_AMT      OUT NUMBER);

    PROCEDURE GET_CURR_CONV (P_ACC_CURR        IN     VARCHAR2,
                             P_LIMIT_CURR      IN     VARCHAR2,
                             P_ACC_AMT         IN     NUMBER,
                             P_OUT_CRATE          OUT NUMBER,
                             P_OUT_LIMIT_AMT      OUT NUMBER);

    --    FUNCTION GET_DISB_BALANCE_IN_LIMIT_CURR (W_BATCH_SL     IN NUMBER,
    --                                             W_OPTION       IN CHAR,
    --                                             W_LIMIT_CURR   IN VARCHAR2)
    --        RETURN NUMBER;

    PROCEDURE UPDATE_ACNTOS (P_LIMIT_CIF     IN NUMBER,
                             P_LIMIT_LINE    IN NUMBER,
                             P_INT_ACC_NUM   IN NUMBER,
                             P_LIMIT_AMT     IN NUMBER,
                             P_DISB_AMT      IN NUMBER);


    PROCEDURE UPDATE_IINDIRECT (P_LIMIT_CIF       IN NUMBER,
                                P_LIMIT_LINE      IN NUMBER,
                                P_CONTRA_CLINET   IN NUMBER,
                                P_DISB_AMT        IN NUMBER)
    AS
    BEGIN
        BEGIN
            MERGE INTO LLOSINDIRECT T
                 USING (SELECT P_LIMIT_CIF         AS LIMIT_CIF,
                               P_LIMIT_LINE        AS LIMIT_LINE,
                               P_CONTRA_CLINET     AS CONTRA_CLINET,
                               P_DISB_AMT          AS DISB_AMT
                          FROM DUAL) S
                    ON (    T.LLOSIND_ENTITY_NUM =
                            PKG_ENTITY.FN_GET_ENTITY_CODE
                        AND T.LLOSIND_CLIENT_CODE = S.LIMIT_CIF
                        AND T.LLOSIND_LIMIT_LINE = S.LIMIT_LINE
                        AND T.LLOSIND_CONTRA_CLIENT = S.CONTRA_CLINET)
            WHEN MATCHED
            THEN
                UPDATE SET
                    T.LLOSIND_LLCURR_OS_AMT =
                        T.LLOSIND_LLCURR_OS_AMT + S.DISB_AMT
            WHEN NOT MATCHED
            THEN
                INSERT     (T.LLOSIND_ENTITY_NUM,
                            T.LLOSIND_CLIENT_CODE,
                            T.LLOSIND_LIMIT_LINE,
                            T.LLOSIND_CONTRA_CLIENT,
                            T.LLOSIND_LLCURR_OS_AMT)
                    VALUES (PKG_ENTITY.FN_GET_ENTITY_CODE,
                            S.LIMIT_CIF,
                            S.LIMIT_LINE,
                            S.CONTRA_CLINET,
                            S.DISB_AMT);
        EXCEPTION
            WHEN OTHERS
            THEN
                V_ERR_STATUS := '8901';
        END;
    END;

    PROCEDURE CHECK_FOR_IDIRECT_LIMIT_UPD (P_REC_INDEX    IN     NUMBER,
                                           P_OPT_FLG      IN     CHAR,
                                           P_ERR_STATUS      OUT VARCHAR2)
    AS
        V_LIMIT_CURR             VARCHAR2 (3);
        V_CONTRA_CLIENT          NUMBER (12);
        V_LIMIT_CURR_EQU         NUMBER (18, 3) DEFAULT 0;
        V_LIMIT_DISB_AMT         NUMBER (18, 3) DEFAULT 0;
        V_LIMIT_CURR_CRATE       NUMBER (14, 9) DEFAULT 0;
        V_LIMIT_LINE             NUMBER (6) DEFAULT 0;
        V_LIMIT_CIF              NUMBER (12) DEFAULT 0;
        V_BOOL_FLG               BOOLEAN DEFAULT FALSE;
        W_LLODINDDTLS_PREV_REC   PKG_AUTOPOST.LLODINDDTLS_REC;
        W_TRAN_POST_SL           NUMBER (6);
        W_SOURCE_DETAILS         VARCHAR2 (1000);

        W_BASE_BC_AMT            NUMBER (18, 3);
        W_PROD_CODE              NUMBER (4);
    BEGIN
        P_ERR_STATUS := '0000';

        BEGIN
            IF P_OPT_FLG = 'A'
            THEN
                W_LLODINDDTLS_PREV_REC := PKG_AUTOPOST.PV_LLODINDDTLS_REC;
                W_TRAN_POST_SL :=
                    PKG_AUTOPOST.PV_TRAN_REC (P_REC_INDEX).TRAN_BATCH_SL_NUM;
            ELSE
                W_LLODINDDTLS_PREV_REC :=
                    PKG_AUTOPOST.PV_LLODINDDTLS_PREV_REC;
                W_TRAN_POST_SL :=
                    PKG_AUTOPOST.PV_TRAN_PREV_REC (P_REC_INDEX).TRAN_BATCH_SL_NUM;
            END IF;

            FOR IDX IN 1 .. W_LLODINDDTLS_PREV_REC.COUNT
            LOOP
                IF W_LLODINDDTLS_PREV_REC (IDX).LLODINDDTLS_BATCH_SL =
                   W_TRAN_POST_SL
                THEN
                    V_LIMIT_CIF :=
                        W_LLODINDDTLS_PREV_REC (IDX).LLODINDDTLS_LIMIT_CLIENT;
                    V_LIMIT_LINE :=
                        W_LLODINDDTLS_PREV_REC (IDX).LLODINDDTLS_LIMIT_LINE;

                    BEGIN
                        SELECT L.LMTLINE_SANCTION_CURR
                          INTO V_LIMIT_CURR
                          FROM LIMITLINE L
                         WHERE     LMTLINE_ENTITY_NUM =
                                   PKG_ENTITY.FN_GET_ENTITY_CODE
                               AND L.LMTLINE_CLIENT_CODE = V_LIMIT_CIF
                               AND L.LMTLINE_NUM = V_LIMIT_LINE;
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            RETURN;
                    END;

                    IF P_OPT_FLG = 'M'
                    THEN
                        V_LIMIT_CURR_EQU :=
                            W_LLODINDDTLS_PREV_REC (IDX).LLODINDDTLS_BRK_LIMIT_EQU;
                        V_LIMIT_CURR_EQU := V_LIMIT_CURR_EQU;
                    ELSE
                        GET_CURR_CONV (
                            PKG_AUTOPOST.PV_TRAN_REC (P_REC_INDEX).TRAN_CURR_CODE,
                            V_LIMIT_CURR,
                            W_LLODINDDTLS_PREV_REC (IDX).LLODINDDTLS_BRK_AMT,
                            V_LIMIT_CURR_CRATE,
                            V_LIMIT_CURR_EQU);
                        W_LLODINDDTLS_PREV_REC (IDX).LLODINDDTLS_BRK_LIMIT_EQU :=
                            V_LIMIT_CURR_EQU;
                    END IF;


                    W_BASE_BC_AMT := 0;
                    W_PROD_CODE := 0;

                    IF P_OPT_FLG = 'A'
                    THEN
                        W_PROD_CODE :=
                            PKG_AUTOPOST.PV_TRAN_REC (P_REC_INDEX).TRAN_PROD_CODE;

                        IF PKG_AUTOPOST.PV_TRAN_REC (P_REC_INDEX).TRAN_DB_CR_FLG =
                           'C'
                        THEN
                            V_LIMIT_CURR_EQU := V_LIMIT_CURR_EQU;
                            W_BASE_BC_AMT :=
                                PKG_AUTOPOST.PV_TRAN_REC (P_REC_INDEX).TRAN_BASE_CURR_EQ_AMT;
                        ELSE
                            V_LIMIT_CURR_EQU := -1 * V_LIMIT_CURR_EQU;
                            W_BASE_BC_AMT :=
                                  -1
                                * PKG_AUTOPOST.PV_TRAN_REC (P_REC_INDEX).TRAN_BASE_CURR_EQ_AMT;
                        END IF;
                    ELSE
                        W_PROD_CODE :=
                            PKG_AUTOPOST.PV_TRAN_PREV_REC (P_REC_INDEX).TRAN_PROD_CODE;

                        IF PKG_AUTOPOST.PV_TRAN_PREV_REC (P_REC_INDEX).TRAN_DB_CR_FLG =
                           'C'
                        THEN
                            V_LIMIT_CURR_EQU := -1 * V_LIMIT_CURR_EQU;
                            W_BASE_BC_AMT :=
                                  -1
                                * PKG_AUTOPOST.PV_TRAN_PREV_REC (P_REC_INDEX).TRAN_BASE_CURR_EQ_AMT;
                        ELSE
                            V_LIMIT_CURR_EQU := V_LIMIT_CURR_EQU;
                            W_BASE_BC_AMT :=
                                PKG_AUTOPOST.PV_TRAN_PREV_REC (P_REC_INDEX).TRAN_BASE_CURR_EQ_AMT;
                        END IF;
                    END IF;


                    V_CONTRA_CLIENT :=
                        W_LLODINDDTLS_PREV_REC (IDX).LLODINDDTLS_CONTRA_CLIENT;

                    BEGIN
                        MERGE INTO INDIRLLOS I
                             USING (SELECT V_CONTRA_CLIENT     CONTRA_CLIENT,
                                           W_BASE_BC_AMT       BASE_BC_AMT
                                      FROM DUAL) T
                                ON (I.INDIRLLOS_CUST_NUM = CONTRA_CLIENT)
                        WHEN MATCHED
                        THEN
                            UPDATE SET
                                I.INDIRLLOS_OS_AMOUNT =
                                      NVL (I.INDIRLLOS_OS_AMOUNT, 0)
                                    + T.BASE_BC_AMT
                        WHEN NOT MATCHED
                        THEN
                            INSERT     (INDIRLLOS_CUST_NUM,
                                        INDIRLLOS_OS_AMOUNT)
                                VALUES (T.CONTRA_CLIENT, T.BASE_BC_AMT);
                    END;

                    BEGIN
                        MERGE INTO INDIRPRODLLOS L
                             USING (SELECT V_CONTRA_CLIENT     CONTRA_CLIENT,
                                           W_BASE_BC_AMT       BASE_BC_AMT,
                                           W_PROD_CODE         PROD_CODE
                                      FROM DUAL) T
                                ON (    L.INDIRPLLOS_CUST_NUM =
                                        T.CONTRA_CLIENT
                                    AND L.INDIRPLLOS_PROD_CODE = T.PROD_CODE)
                        WHEN MATCHED
                        THEN
                            UPDATE SET
                                L.INDIRPLLOS_OS_AMOUNT =
                                      NVL (L.INDIRPLLOS_OS_AMOUNT, 0)
                                    + T.BASE_BC_AMT
                        WHEN NOT MATCHED
                        THEN
                            INSERT     (INDIRPLLOS_CUST_NUM,
                                        INDIRPLLOS_PROD_CODE,
                                        INDIRPLLOS_OS_AMOUNT)
                                VALUES (T.CONTRA_CLIENT,
                                        T.PROD_CODE,
                                        T.BASE_BC_AMT);
                    END;

                    V_BOOL_FLG := TRUE;

                    WHILE V_BOOL_FLG
                    LOOP
                        UPDATE_IINDIRECT (V_LIMIT_CIF,
                                          V_LIMIT_LINE,
                                          V_CONTRA_CLIENT,
                                          V_LIMIT_CURR_EQU);

                        IF V_ERR_STATUS <> '0000'
                        THEN
                            P_ERR_STATUS := V_ERR_STATUS;
                            RETURN;
                        END IF;


                        SELECT LMTLINE_SUB_LIMIT_LINE
                          INTO V_LIMIT_LINE
                          FROM LIMITLINE
                         WHERE     LMTLINE_ENTITY_NUM =
                                   PKG_ENTITY.FN_GET_ENTITY_CODE
                               AND LMTLINE_CLIENT_CODE = V_LIMIT_CIF
                               AND LMTLINE_NUM = V_LIMIT_LINE;

                        IF V_LIMIT_LINE = 0
                        THEN
                            V_BOOL_FLG := FALSE;
                        END IF;
                    END LOOP;
                END IF;
            END LOOP;
        EXCEPTION
            WHEN OTHERS
            THEN
                V_ERR_STATUS := '8902';
        END;

        W_LLODINDDTLS_PREV_REC.DELETE;
    END;


    FUNCTION SP_GET_LIMIT_RATE_TYPE (V_ENTITY_NUM   IN NUMBER,
                                     P_LIMIT_CURR   IN VARCHAR2,
                                     P_ACC_CURR     IN VARCHAR2)
        RETURN VARCHAR2
    IS
        V_RATE_TYPE   VARCHAR2 (6);
    BEGIN
        PKG_ENTITY.SP_SET_ENTITY_CODE (V_ENTITY_NUM);

        BEGIN
            SELECT CMNPM_MID_RATE_TYPE_PUR INTO V_RATE_TYPE FROM CMNPARAM;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                V_ERR_STATUS := '8903';
                RETURN (NULL);
        END;

        RETURN (V_RATE_TYPE);
    END;

    PROCEDURE SP_AGN_VALUE (P_ACC_CURR        IN     VARCHAR2,
                            P_LIMIT_CURR      IN     VARCHAR2,
                            P_ACC_AMT         IN     NUMBER,
                            P_LIMIT_CRATE     IN     NUMBER,
                            P_OUT_LIMIT_AMT      OUT NUMBER)
    IS
        ERR_STATUS   NUMBER (1);
    BEGIN
        ERR_STATUS := 0;
        SP_CALCAGNSTVALUE (PKG_ENTITY.FN_GET_ENTITY_CODE,
                           P_ACC_CURR,
                           P_LIMIT_CURR,
                           P_ACC_AMT,
                           P_LIMIT_CRATE,
                           '0',
                           P_OUT_LIMIT_AMT,
                           ERR_STATUS);

        IF ERR_STATUS = '1'
        THEN
            IF P_OUT_LIMIT_AMT = 0
            THEN
                V_ERR_STATUS := '8904';
                RETURN;
            END IF;
        END IF;

        P_OUT_LIMIT_AMT :=
            PKG_PB_GLOBAL.FN_GET_FORMAT (PKG_ENTITY.FN_GET_ENTITY_CODE,
                                         P_LIMIT_CURR,
                                         P_OUT_LIMIT_AMT);
    END;

    PROCEDURE GET_CURR_CONV (P_ACC_CURR        IN     VARCHAR2,
                             P_LIMIT_CURR      IN     VARCHAR2,
                             P_ACC_AMT         IN     NUMBER,
                             P_OUT_CRATE          OUT NUMBER,
                             P_OUT_LIMIT_AMT      OUT NUMBER)
    AS
        V_RATE_TYPE   VARCHAR2 (6);
    BEGIN
        V_ERR_STATUS := '0000';

        IF P_ACC_CURR = P_LIMIT_CURR
        THEN
            P_OUT_LIMIT_AMT := P_ACC_AMT;
            P_OUT_CRATE := 1;
            RETURN;
        END IF;

        V_RATE_TYPE :=
            PKG_LIMITS.SP_GET_LIMIT_RATE_TYPE (PKG_ENTITY.FN_GET_ENTITY_CODE,
                                               P_LIMIT_CURR,
                                               P_ACC_CURR);

        IF V_ERR_STATUS <> '0000'
        THEN
            P_OUT_CRATE := 0;
            P_OUT_LIMIT_AMT := 0;
            RETURN;
        END IF;

        SP_CALCAGNAMT (PKG_ENTITY.FN_GET_ENTITY_CODE,
                       P_ACC_CURR,
                       P_LIMIT_CURR,
                       P_ACC_AMT,
                       'M',
                       V_CURR_BUS_DATE,
                       '1',
                       V_RATE_TYPE,
                       V_RATE_TYPE,
                       P_OUT_LIMIT_AMT,
                       P_OUT_CRATE);

        IF P_OUT_LIMIT_AMT = 0
        THEN
            P_OUT_CRATE := 0;
            V_ERR_STATUS := '8905';
            RETURN;
        END IF;

        P_OUT_LIMIT_AMT :=
            PKG_PB_GLOBAL.FN_GET_FORMAT (PKG_ENTITY.FN_GET_ENTITY_CODE,
                                         P_LIMIT_CURR,
                                         P_OUT_LIMIT_AMT);
    END;

    FUNCTION GET_DISB_BALANCE_IN_LIMIT_CURR (W_BATCH_SL     IN NUMBER,
                                             W_OPTION       IN CHAR,
                                             W_LIMIT_CURR   IN VARCHAR2)
        RETURN NUMBER
    IS
        W_DISB_PRIN_AMT            NUMBER (18, 3);
        W_DISB_PRIN_IN_LIMIT_AMT   NUMBER (18, 3);
        W_LIMIT_CURR_CRATE         NUMBER (14, 9) DEFAULT 0;
        W_TRANADV_ARRAY_SL         NUMBER;
        W_TRAN_CURR_CODE           VARCHAR2 (3);
    BEGIN
        W_DISB_PRIN_AMT := 0;
        W_DISB_PRIN_IN_LIMIT_AMT := 0;
        W_TRANADV_ARRAY_SL := 0;

        IF W_OPTION = 'A'
        THEN
            W_TRAN_CURR_CODE :=
                PKG_AUTOPOST.PV_TRAN_REC (W_BATCH_SL).TRAN_CURR_CODE;

            IF PKG_AUTOPOST.PV_TRAN_REC (W_BATCH_SL).TRAN_AMT_BRKUP = '1'
            THEN
                IF PKG_AUTOPOST.PV_TRAN_ADV_REC.COUNT > 0
                THEN
                   <<OUTER>>
                    FOR IDX IN 1 .. PKG_AUTOPOST.PV_TRAN_ADV_REC.COUNT
                    LOOP
                        IF PKG_AUTOPOST.PV_TRAN_ADV_REC (IDX).TRANADV_BATCH_SL_NUM =
                           W_BATCH_SL
                        THEN
                            W_TRANADV_ARRAY_SL := IDX;
                            EXIT OUTER;
                        END IF;
                    END LOOP;

                    IF W_TRANADV_ARRAY_SL = 0
                    THEN
                        W_DISB_PRIN_AMT :=
                            PKG_AUTOPOST.PV_TRAN_REC (W_BATCH_SL).TRAN_AMOUNT;
                    ELSE
                        W_DISB_PRIN_AMT :=
                            PKG_AUTOPOST.PV_TRAN_ADV_REC (W_TRANADV_ARRAY_SL).TRANADV_PRIN_AC_AMT;
                    END IF;
                END IF;
            ELSE
                W_DISB_PRIN_AMT :=
                    PKG_AUTOPOST.PV_TRAN_REC (W_BATCH_SL).TRAN_AMOUNT;
            END IF;
        ELSIF W_OPTION = 'M'
        THEN
            W_TRAN_CURR_CODE :=
                PKG_AUTOPOST.PV_TRAN_PREV_REC (W_BATCH_SL).TRAN_CURR_CODE;

            IF PKG_AUTOPOST.PV_TRAN_PREV_REC (W_BATCH_SL).TRAN_AMT_BRKUP =
               '1'
            THEN
                IF PKG_AUTOPOST.PV_TRAN_PREV_ADV_REC.COUNT > 0
                THEN
                   <<OUTEROLD>>
                    FOR IDX IN 1 .. PKG_AUTOPOST.PV_TRAN_PREV_ADV_REC.COUNT
                    LOOP
                        IF PKG_AUTOPOST.PV_TRAN_PREV_ADV_REC (IDX).TRANADV_BATCH_SL_NUM =
                           W_BATCH_SL
                        THEN
                            W_TRANADV_ARRAY_SL := IDX;
                            EXIT OUTEROLD;
                        END IF;
                    END LOOP;

                    IF W_TRANADV_ARRAY_SL = 0
                    THEN
                        W_DISB_PRIN_AMT :=
                            PKG_AUTOPOST.PV_TRAN_PREV_REC (W_BATCH_SL).TRAN_AMOUNT;
                    ELSE
                        W_DISB_PRIN_AMT :=
                            PKG_AUTOPOST.PV_TRAN_PREV_ADV_REC (
                                W_TRANADV_ARRAY_SL).TRANADV_PRIN_AC_AMT;
                    END IF;
                END IF;
            ELSE
                W_DISB_PRIN_AMT :=
                    PKG_AUTOPOST.PV_TRAN_PREV_REC (W_BATCH_SL).TRAN_AMOUNT;
            END IF;
        END IF;

        IF W_DISB_PRIN_AMT <> 0
        THEN
            IF W_TRAN_CURR_CODE <> W_LIMIT_CURR
            THEN
                IF W_LIMIT_CURR = V_BASE_CURR_CODE
                THEN
                    W_LIMIT_CURR_CRATE :=
                        PKG_AUTOPOST.PV_TRAN_REC (W_BATCH_SL).TRAN_BASE_CURR_CONV_RATE;
                    W_DISB_PRIN_IN_LIMIT_AMT :=
                        PKG_AUTOPOST.PV_TRAN_REC (W_BATCH_SL).TRAN_BASE_CURR_EQ_AMT;
                ELSE
                    GET_CURR_CONV (W_TRAN_CURR_CODE,
                                   W_LIMIT_CURR,
                                   W_DISB_PRIN_AMT,
                                   W_LIMIT_CURR_CRATE,
                                   W_DISB_PRIN_IN_LIMIT_AMT);
                END IF;
            ELSE
                W_DISB_PRIN_IN_LIMIT_AMT := W_DISB_PRIN_AMT;
            END IF;
        END IF;

        RETURN W_DISB_PRIN_IN_LIMIT_AMT;
    END;

    PROCEDURE UPDATE_ACNTOS (P_LIMIT_CIF     IN NUMBER,
                             P_LIMIT_LINE    IN NUMBER,
                             P_INT_ACC_NUM   IN NUMBER,
                             P_LIMIT_AMT     IN NUMBER,
                             P_DISB_AMT      IN NUMBER)
    AS
    BEGIN
        V_ERR_STATUS := '0000';

        MERGE INTO LLACNTOS T
             USING (SELECT P_LIMIT_CIF       AS LIMIT_CIF,
                           P_LIMIT_LINE      AS LIMIT_LINE,
                           P_INT_ACC_NUM     AS ACC_NUM,
                           P_LIMIT_AMT       AS LIMIT_AMT,
                           P_DISB_AMT        AS DISB_AMT
                      FROM DUAL) S
                ON (    T.LLACNTOS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                    AND T.LLACNTOS_CLIENT_CODE = S.LIMIT_CIF
                    AND T.LLACNTOS_LIMIT_LINE_NUM = S.LIMIT_LINE
                    AND T.LLACNTOS_CLIENT_ACNUM = S.ACC_NUM)
        WHEN MATCHED
        THEN
            UPDATE SET
                T.LLACNTOS_LIMIT_CURR_OS_AMT =
                    T.LLACNTOS_LIMIT_CURR_OS_AMT + S.LIMIT_AMT,
                T.LLACNTOS_LIMIT_CURR_DISB_MADE =
                    T.LLACNTOS_LIMIT_CURR_DISB_MADE + S.DISB_AMT
        WHEN NOT MATCHED
        THEN
            INSERT     (T.LLACNTOS_ENTITY_NUM,
                        T.LLACNTOS_CLIENT_CODE,
                        T.LLACNTOS_LIMIT_LINE_NUM,
                        T.LLACNTOS_CLIENT_ACNUM,
                        T.LLACNTOS_LIMIT_CURR_OS_AMT,
                        T.LLACNTOS_LIMIT_CURR_DISB_MADE)
                VALUES (PKG_ENTITY.FN_GET_ENTITY_CODE,
                        S.LIMIT_CIF,
                        S.LIMIT_LINE,
                        S.ACC_NUM,
                        S.LIMIT_AMT,
                        S.DISB_AMT);
    END;

    PROCEDURE SP_UPDATE_LIMITS (V_ENTITY_NUM   IN     NUMBER,
                                P_REC_INDEX    IN     NUMBER,
                                P_OPT_FLG      IN     CHAR,
                                P_ERR_STATUS      OUT VARCHAR2)
    AS
        V_LIMIT_CURR            VARCHAR2 (3);
        V_LIMIT_CURR_EQU        NUMBER (18, 3) DEFAULT 0;
        V_LIMIT_DISB_AMT        NUMBER (18, 3) DEFAULT 0;
        V_LIMIT_CURR_CRATE      NUMBER (14, 9) DEFAULT 0;
        V_LIMIT_LINE            NUMBER (6) DEFAULT 0;
        V_LIMIT_CIF             NUMBER (12) DEFAULT 0;
        V_INT_ACC_NUM           NUMBER (14) DEFAULT 0;
        V_ACC_CIF               NUMBER (12) DEFAULT 0;
        V_ACC_PROD              NUMBER (4) DEFAULT 0;
        V_BOOL_FLG              BOOLEAN DEFAULT FALSE;
        V_REVOLVING_LIMIT       CHAR (1);
        W_DISB_PRIN_LIMIT_AMT   NUMBER (18, 3);
    BEGIN
        PKG_ENTITY.SP_SET_ENTITY_CODE (V_ENTITY_NUM);
        V_BASE_CURR_CODE := PKG_PB_GLOBAL.FN_GET_INS_BASE_CURR (V_ENTITY_NUM);
        W_DISB_PRIN_LIMIT_AMT := 0;
        P_ERR_STATUS := '0000';

        IF P_OPT_FLG = 'A'
        THEN
            V_INT_ACC_NUM :=
                PKG_AUTOPOST.PV_TRAN_REC (P_REC_INDEX).TRAN_INTERNAL_ACNUM;
        ELSE
            V_INT_ACC_NUM :=
                PKG_AUTOPOST.PV_TRAN_PREV_REC (P_REC_INDEX).TRAN_INTERNAL_ACNUM;
        END IF;

        BEGIN
            SELECT ACASLLDTL_LIMIT_LINE_NUM,
                   ACASLLDTL_CLIENT_NUM,
                   LMTLINE_SANCTION_CURR,
                   NVL (LMTLINE_REVOLVING_LIMIT, '0')
              INTO V_LIMIT_LINE,
                   V_LIMIT_CIF,
                   V_LIMIT_CURR,
                   V_REVOLVING_LIMIT
              FROM ACASLLDTL, LIMITLINE
             WHERE     LMTLINE_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                   AND ACASLLDTL_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                   AND LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
                   AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM
                   AND ACASLLDTL_INTERNAL_ACNUM = V_INT_ACC_NUM;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RETURN;
        END;

        SELECT ACNTS_PROD_CODE, ACNTS_CLIENT_NUM
          INTO V_ACC_PROD, V_ACC_CIF
          FROM ACNTS
         WHERE     ACNTS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
               AND ACNTS_INTERNAL_ACNUM = V_INT_ACC_NUM;

        IF P_OPT_FLG = 'M'
        THEN
            V_LIMIT_CURR_EQU :=
                PKG_AUTOPOST.PV_TRAN_PREV_REC (P_REC_INDEX).TRAN_LIMIT_CURR_EQUIVALENT;
        ELSE
            IF NVL (
                   PKG_AUTOPOST.PV_TRAN_REC (P_REC_INDEX).TRAN_CRATE_TO_LIMIT_CURR,
                   0) <>
               0
            THEN
                PKG_AUTOPOST.PV_TRAN_REC (P_REC_INDEX).TRAN_LIMIT_CURR :=
                    V_LIMIT_CURR;
                V_LIMIT_CURR_CRATE :=
                    PKG_AUTOPOST.PV_TRAN_REC (P_REC_INDEX).TRAN_CRATE_TO_LIMIT_CURR;
                SP_AGN_VALUE (
                    PKG_AUTOPOST.PV_TRAN_REC (P_REC_INDEX).TRAN_CURR_CODE,
                    V_LIMIT_CURR,
                    PKG_AUTOPOST.PV_TRAN_REC (P_REC_INDEX).TRAN_AMOUNT,
                    PKG_AUTOPOST.PV_TRAN_REC (P_REC_INDEX).TRAN_CRATE_TO_LIMIT_CURR,
                    V_LIMIT_CURR_EQU);
            ELSE
                IF V_LIMIT_CURR = V_BASE_CURR_CODE
                THEN
                    V_LIMIT_CURR_CRATE :=
                        PKG_AUTOPOST.PV_TRAN_REC (P_REC_INDEX).TRAN_BASE_CURR_CONV_RATE;
                    V_LIMIT_CURR_EQU :=
                        PKG_AUTOPOST.PV_TRAN_REC (P_REC_INDEX).TRAN_BASE_CURR_EQ_AMT;
                ELSE
                    GET_CURR_CONV (
                        PKG_AUTOPOST.PV_TRAN_REC (P_REC_INDEX).TRAN_CURR_CODE,
                        V_LIMIT_CURR,
                        PKG_AUTOPOST.PV_TRAN_REC (P_REC_INDEX).TRAN_AMOUNT,
                        V_LIMIT_CURR_CRATE,
                        V_LIMIT_CURR_EQU);
                END IF;
            END IF;

            IF V_ERR_STATUS <> '0000'
            THEN
                P_ERR_STATUS := V_ERR_STATUS;
                RETURN;
            END IF;

            PKG_AUTOPOST.PV_TRAN_REC (P_REC_INDEX).TRAN_LIMIT_CURR :=
                V_LIMIT_CURR;
            PKG_AUTOPOST.PV_TRAN_REC (P_REC_INDEX).TRAN_CRATE_TO_LIMIT_CURR :=
                V_LIMIT_CURR_CRATE;
            PKG_AUTOPOST.PV_TRAN_REC (P_REC_INDEX).TRAN_LIMIT_CURR_EQUIVALENT :=
                V_LIMIT_CURR_EQU;
        END IF;

        IF P_OPT_FLG = 'A'
        THEN
            IF PKG_AUTOPOST.PV_TRAN_REC (P_REC_INDEX).TRAN_DB_CR_FLG = 'C'
            THEN
                V_LIMIT_DISB_AMT := 0;
            ELSE
                V_LIMIT_DISB_AMT :=
                    GET_DISB_BALANCE_IN_LIMIT_CURR (P_REC_INDEX,
                                                    P_OPT_FLG,
                                                    V_LIMIT_CURR);
                V_LIMIT_DISB_AMT := -1 * ABS (V_LIMIT_DISB_AMT);
                V_LIMIT_CURR_EQU := -1 * V_LIMIT_CURR_EQU;
            END IF;
        ELSE
            IF PKG_AUTOPOST.PV_TRAN_PREV_REC (P_REC_INDEX).TRAN_DB_CR_FLG =
               'C'
            THEN
                V_LIMIT_CURR_EQU := -1 * V_LIMIT_CURR_EQU;
                V_LIMIT_DISB_AMT := 0;
            ELSE
                V_LIMIT_DISB_AMT :=
                    ABS (
                        GET_DISB_BALANCE_IN_LIMIT_CURR (P_REC_INDEX,
                                                        P_OPT_FLG,
                                                        V_LIMIT_CURR));
            END IF;
        END IF;


        V_BOOL_FLG := TRUE;

        WHILE V_BOOL_FLG
        LOOP
            V_REVOLVING_LIMIT := '0';

            IF V_REVOLVING_LIMIT = '1'
            THEN
                W_DISB_PRIN_LIMIT_AMT := 0;
            ELSE
                W_DISB_PRIN_LIMIT_AMT := V_LIMIT_DISB_AMT;
            END IF;

            UPDATE_ACNTOS (V_LIMIT_CIF,
                           V_LIMIT_LINE,
                           V_INT_ACC_NUM,
                           V_LIMIT_CURR_EQU,
                           W_DISB_PRIN_LIMIT_AMT);

            IF V_ERR_STATUS <> '0000'
            THEN
                P_ERR_STATUS := V_ERR_STATUS;
                RETURN;
            END IF;

            SELECT LMTLINE_SUB_LIMIT_LINE, NVL (LMTLINE_REVOLVING_LIMIT, '0')
              INTO V_LIMIT_LINE, V_REVOLVING_LIMIT
              FROM LIMITLINE
             WHERE     LMTLINE_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                   AND LMTLINE_CLIENT_CODE = V_LIMIT_CIF
                   AND LMTLINE_NUM = V_LIMIT_LINE;

            IF V_LIMIT_LINE = 0
            THEN
                V_BOOL_FLG := FALSE;
            END IF;

            IF V_LIMIT_LINE <> 0
            THEN
                SELECT NVL (LMTLINE_REVOLVING_LIMIT, '0')
                  INTO V_REVOLVING_LIMIT
                  FROM LIMITLINE
                 WHERE     LMTLINE_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                       AND LMTLINE_CLIENT_CODE = V_LIMIT_CIF
                       AND LMTLINE_NUM = V_LIMIT_LINE;
            END IF;
        END LOOP;

        CHECK_FOR_IDIRECT_LIMIT_UPD (P_REC_INDEX, P_OPT_FLG, P_ERR_STATUS);
    EXCEPTION
        WHEN OTHERS
        THEN
            P_ERR_STATUS := '9064';
    END;



    FUNCTION FN_GET_LIMIT_CURRENCY (V_ENTITY_NUM      IN NUMBER,
                                    P_CLIENT_NUM      IN NUMBER,
                                    P_LIMITLINE_NUM   IN NUMBER)
        RETURN VARCHAR2
    IS
        V_LIMIT_CURR   VARCHAR2 (3);
    BEGIN
        PKG_ENTITY.SP_SET_ENTITY_CODE (V_ENTITY_NUM);

        SELECT LMTLINE_SANCTION_CURR
          INTO V_LIMIT_CURR
          FROM LIMITLINE
         WHERE     LMTLINE_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
               AND LMTLINE_CLIENT_CODE = P_CLIENT_NUM
               AND LMTLINE_NUM = P_LIMITLINE_NUM;

        RETURN V_LIMIT_CURR;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    PROCEDURE SP_CALC_DISB_MADE_ACNTOS (
        V_ENTITY_NUM            IN     NUMBER,
        P_CLIENT_NUM            IN     NUMBER,
        P_LIMITLINE_NUM         IN     NUMBER,
        P_LIMIT_DISB_MADE_AMT      OUT NUMBER,
        P_ERR_MSG                  OUT VARCHAR2)
    IS
        V_LIMIT_DISB_MADE_AMT   NUMBER (18, 3);
    BEGIN
        PKG_ENTITY.SP_SET_ENTITY_CODE (V_ENTITY_NUM);

        V_ERR_MSG := ' ';
        V_LIMIT_DISB_MADE_AMT := 0;

        BEGIN
            SELECT NVL (
                       SUM (
                           CASE
                               WHEN (TERM_LOAN = '1' AND REVOLVING_LIM <> '1')
                               THEN
                                   DISB_AMT
                               ELSE
                                   -- FOR REVOLVING LIMITS, IF THE ACCOUNT IS HAVING CREDIT BALANCE,
                                   -- THAT BALANCE WILL BE PART OF AVAILABLE BALANCE TIL THE LIMIT IS EXPIRED.
                                   -- IN THAT CASE, THE DISBURSEMENT/UTILIZED AMOUNT WILL BE ZERO, BUT AVAILABLE
                                   -- BALANCE WILL BE INCREASED TO THAT EXTENT OF THE CREDIT BALANCE
                                   CASE
                                       WHEN     OS_AMT > 0
                                            AND LIMIT_EXPIRED = '1'
                                       THEN
                                           0
                                       WHEN     OS_AMT > 0
                                            AND LIMIT_EXPIRED = '0'
                                       THEN
                                             ((-1) * OS_AMT)
                                           + CLG_CR_SUM
                                           + AC_HOLD_AMT
                                       ELSE
                                           ABS (
                                                 OS_AMT
                                               - CLG_CR_SUM
                                               - AC_HOLD_AMT)
                                   END
                           END),
                       0)
              INTO V_LIMIT_DISB_MADE_AMT
              FROM (  SELECT NVL (LLACNTOS_LIMIT_CURR_OS_AMT, 0)
                                 OS_AMT,
                             ABS (NVL (LLACNTOS_LIMIT_CURR_DISB_MADE, 0))
                                 DISB_AMT,
                             NVL (B.ACNTBAL_BC_CLG_DB_SUM, 0)
                                 CLG_DR_SUM,
                             NVL (B.ACNTBAL_BC_CLG_CR_SUM, 0)
                                 CLG_CR_SUM,
                             NVL (B.ACNTBAL_AC_AMT_ON_HOLD, 0)
                                 AC_HOLD_AMT,
                             CASE
                                 WHEN NVL (PRODUCT_FOR_RUN_ACS, '0') = '1'
                                 THEN
                                     '0'
                                 ELSE
                                     '1'
                             END
                                 TERM_LOAN,
                             NVL (LMTLINE_REVOLVING_LIMIT, '0')
                                 REVOLVING_LIM,
                             CASE
                                 WHEN LMTLINE_LIMIT_EXPIRY_DATE <
                                      (SELECT MN_CURR_BUSINESS_DATE
                                         FROM MAINCONT)
                                 THEN
                                     '1'
                                 ELSE
                                     '0'
                             END
                                 LIMIT_EXPIRED
                        FROM (    SELECT LMTLINE_ENTITY_NUM,
                                         LMTLINE_CLIENT_CODE,
                                         LMTLINE_NUM,
                                         LMTLINE_REVOLVING_LIMIT,
                                         LMTLINE_LIMIT_EXPIRY_DATE
                                    FROM LIMITLINE
                              START WITH     LMTLINE_ENTITY_NUM = V_ENTITY_NUM
                                         AND LMTLINE_NUM = P_LIMITLINE_NUM
                                         AND LMTLINE_CLIENT_CODE = P_CLIENT_NUM
                              CONNECT BY     PRIOR LMTLINE_NUM =
                                             LMTLINE_SUB_LIMIT_LINE
                                         AND LMTLINE_CLIENT_CODE = P_CLIENT_NUM)
                             M,
                             ACASLLDTL N,
                             LLACNTOS L,
                             ACNTS    A,
                             ACNTBAL  B,
                             PRODUCTS P
                       WHERE     M.LMTLINE_ENTITY_NUM = N.ACASLLDTL_ENTITY_NUM
                             AND M.LMTLINE_CLIENT_CODE = N.ACASLLDTL_CLIENT_NUM
                             AND M.LMTLINE_NUM = N.ACASLLDTL_LIMIT_LINE_NUM
                             AND N.ACASLLDTL_ENTITY_NUM = L.LLACNTOS_ENTITY_NUM
                             AND N.ACASLLDTL_CLIENT_NUM = LLACNTOS_CLIENT_CODE
                             AND N.ACASLLDTL_LIMIT_LINE_NUM =
                                 L.LLACNTOS_LIMIT_LINE_NUM
                             AND N.ACASLLDTL_INTERNAL_ACNUM =
                                 L.LLACNTOS_CLIENT_ACNUM
                             AND L.LLACNTOS_ENTITY_NUM = A.ACNTS_ENTITY_NUM
                             AND L.LLACNTOS_CLIENT_CODE = A.ACNTS_CLIENT_NUM
                             AND L.LLACNTOS_CLIENT_ACNUM =
                                 A.ACNTS_INTERNAL_ACNUM
                             AND A.ACNTS_ENTITY_NUM = B.ACNTBAL_ENTITY_NUM
                             AND A.ACNTS_INTERNAL_ACNUM =
                                 B.ACNTBAL_INTERNAL_ACNUM
                             AND A.ACNTS_PROD_CODE = P.PRODUCT_CODE
                             AND ACASLLDTL_CLIENT_NUM = P_CLIENT_NUM
                    ORDER BY N.ACASLLDTL_LIMIT_LINE_NUM, N.ACASLLDTL_ACNT_SL);
        EXCEPTION
            WHEN OTHERS
            THEN
                V_ERR_MSG := 'Error in Limit Disbursement Made Calculation';
                V_LIMIT_DISB_MADE_AMT := 0;
        END;

        P_LIMIT_DISB_MADE_AMT := V_LIMIT_DISB_MADE_AMT;
        P_ERR_MSG := V_ERR_MSG;
    END;

    PROCEDURE SP_CALC_LIMIT_ACNTOS (V_ENTITY_NUM      IN     NUMBER,
                                    P_CLIENT_NUM      IN     NUMBER,
                                    P_LIMITLINE_NUM   IN     NUMBER,
                                    P_LIMIT_OS_AMT       OUT NUMBER,
                                    P_ERR_MSG            OUT VARCHAR2)
    IS
        V_LIMIT_OS_AMT   NUMBER (18, 3);
        W_TX_CLIENT      CHAR (1);
        W_TX_AMT         NUMBER (18, 3);
    BEGIN
        PKG_ENTITY.SP_SET_ENTITY_CODE (V_ENTITY_NUM);

        V_ERR_MSG := ' ';
        V_LIMIT_OS_AMT := 0;
        W_TX_AMT := 0;
        W_TX_CLIENT := '0';

        BEGIN
              SELECT NVL (SUM (LLACNTOS_LIMIT_CURR_OS_AMT), 0)
                INTO V_LIMIT_OS_AMT
                FROM (    SELECT LMTLINE_ENTITY_NUM,
                                 LMTLINE_CLIENT_CODE,
                                 LMTLINE_NUM
                            FROM LIMITLINE
                      START WITH     LMTLINE_ENTITY_NUM = V_ENTITY_NUM
                                 AND LMTLINE_NUM = P_LIMITLINE_NUM
                                 AND LMTLINE_CLIENT_CODE = P_CLIENT_NUM
                      CONNECT BY     PRIOR LMTLINE_NUM = LMTLINE_SUB_LIMIT_LINE
                                 AND LMTLINE_CLIENT_CODE = P_CLIENT_NUM) M,
                     ACASLLDTL N,
                     LLACNTOS L,
                     ACNTS    A,
                     PRODUCTS P
               WHERE     M.LMTLINE_ENTITY_NUM = N.ACASLLDTL_ENTITY_NUM
                     AND M.LMTLINE_CLIENT_CODE = N.ACASLLDTL_CLIENT_NUM
                     AND M.LMTLINE_NUM = N.ACASLLDTL_LIMIT_LINE_NUM
                     AND N.ACASLLDTL_ENTITY_NUM = L.LLACNTOS_ENTITY_NUM
                     AND N.ACASLLDTL_CLIENT_NUM = LLACNTOS_CLIENT_CODE
                     AND N.ACASLLDTL_LIMIT_LINE_NUM = L.LLACNTOS_LIMIT_LINE_NUM
                     AND N.ACASLLDTL_INTERNAL_ACNUM = L.LLACNTOS_CLIENT_ACNUM
                     AND L.LLACNTOS_ENTITY_NUM = A.ACNTS_ENTITY_NUM
                     AND L.LLACNTOS_CLIENT_CODE = A.ACNTS_CLIENT_NUM
                     AND L.LLACNTOS_CLIENT_ACNUM = A.ACNTS_INTERNAL_ACNUM
                     AND A.ACNTS_PROD_CODE = P.PRODUCT_CODE
                     AND ACASLLDTL_CLIENT_NUM = P_CLIENT_NUM
            ORDER BY N.ACASLLDTL_LIMIT_LINE_NUM, N.ACASLLDTL_ACNT_SL;
        EXCEPTION
            WHEN OTHERS
            THEN
                V_ERR_MSG := 'Error in Limit Outstanding Calculation';
                V_LIMIT_OS_AMT := 0;
        END;

        P_LIMIT_OS_AMT := V_LIMIT_OS_AMT;
        P_ERR_MSG := V_ERR_MSG;
    END;

    PROCEDURE SP_LIMIT_DETAIL (
        P_ENTITY_NUM_I       ENTITYNUM.ENTITYNUM_NUMBER%TYPE := 1,
        P_INT_ACNO_I         IACLINK.IACLINK_INTERNAL_ACNUM%TYPE := 0,
        P_CLIENT_NO          IACLINK.IACLINK_CIF_NUMBER%TYPE := 0,
        P_LIMIT_NO           LIMITLINE.LMTLINE_NUM%TYPE := 0,
        P_LIM_DETAIL_O   OUT PKG_COMMON_TYPES.LIMIT_DET_RT,
        P_ERR_MSG        OUT PKG_COMMON_TYPES.STRING_T)
    AS
        V_ENTITY_NO             LIMITLINE.LMTLINE_ENTITY_NUM%TYPE := P_ENTITY_NUM_I;
        V_INT_ACNO              IACLINK.IACLINK_INTERNAL_ACNUM%TYPE := P_INT_ACNO_I;
        V_CLIENT                LIMITLINE.LMTLINE_CLIENT_CODE%TYPE
            := CASE WHEN V_INT_ACNO <> 0 THEN 0 ELSE P_CLIENT_NO END;
        V_LIM_NO                LIMITLINE.LMTLINE_NUM%TYPE
            := CASE WHEN V_CLIENT = 0 THEN 0 ELSE P_LIMIT_NO END;
        V_PROD_GRP              LIMITLINE.LMTLINE_FACILITY_GRP_CODE%TYPE;
        V_PROD                  LIMITLINE.LMTLINE_PROD_CODE%TYPE;
        V_SHARED                LIMITLINE.LMTLINE_SHARED_LIMIT_LINE%TYPE := '0';
        V_DESC                  LIMITLINE.LMTLINE_FACILITY_DESCN%TYPE;
        V_CURR                  LIMITLINE.LMTLINE_SANCTION_CURR%TYPE;
        V_EFF_DT                LIMITLINE.LMTLINE_LIMIT_EFF_DATE%TYPE;
        V_AUTH_ON               LIMITLINE.LMTLINE_AUTH_ON%TYPE;
        V_EXP_DT                LIMITLINE.LMTLINE_LIMIT_EXPIRY_DATE%TYPE;
        V_LIM_AVLBL_ON_EXP_DT   CBS_IMP.CBS_IMP_VALUE%TYPE := '0';
        V_APEX_LIM              LIMITLINE.LMTLINE_APEX_LEVEL_LIMIT%TYPE
                                    := '0';
        V_PARENT_LIM_NO         LIMITLINE.LMTLINE_SUB_LIMIT_LINE%TYPE := 0;
        V_IS_GRP_LIMIT          LIMITLINE.LMTLINE_GROUP_LEVEL_LIMIT%TYPE
                                    := '0';
        V_GRP_EFF_LIMIT         LIMITLINE.LMTLINE_SANCTION_AMT%TYPE := 0;
        V_AMT                   LIMITLINE.LMTLINE_SANCTION_AMT%TYPE := 0;
        V_EFF_DP_AMT            LIMITLINE.LMTLINE_SANCTION_AMT%TYPE := 0;
        V_UTILIZED_AMT          LIMITLINE.LMTLINE_SANCTION_AMT%TYPE := 0;
        V_DISBURSED_AMT         LLACNTOS.LLACNTOS_LIMIT_CURR_DISB_MADE%TYPE
                                    := 0;
        V_AVLBL_AMT             LIMITLINE.LMTLINE_SANCTION_AMT%TYPE := 0;
        V_EXCESS_AMT            LIMITLINE.LMTLINE_SANCTION_AMT%TYPE := 0;
        V_MARK_IN_AMT           LIMITLINE.LMTLINE_MARKED_AMT_INTO%TYPE := 0;
        V_MARK_OUT_AMT          LIMITLINE.LMTLINE_MARKED_AMT_OUT%TYPE := 0;
        V_REVOLV_GRP_LMT        LIMITLINE.LMTLINE_GROUP_LEVEL_LIMIT%TYPE
                                    := '0';
        V_TOT_DISB_AMT          PKG_COMMON_TYPES.AMOUNT_T := 0;
        V_TOT_GRP_DISB          PKG_COMMON_TYPES.AMOUNT_T := 0;
        V_GRP_AVLBL_LIMIT       PKG_COMMON_TYPES.AMOUNT_T := 0;

        W_CURR_BUSI_DATE        DATE
            := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (V_ENTITY_NO);

        V_ERR_MSG               PKG_COMMON_TYPES.STRING_T;

        PROCEDURE ASSIGN_VALUES
        AS
        BEGIN
            P_LIM_DETAIL_O.ENTITY_NO := V_ENTITY_NO;
            P_LIM_DETAIL_O.CLIENT_NO := V_CLIENT;
            P_LIM_DETAIL_O.LIM_NO := V_LIM_NO;
            P_LIM_DETAIL_O.PROD_GRP := V_PROD_GRP;
            P_LIM_DETAIL_O.PROD := V_PROD;
            P_LIM_DETAIL_O.SHARED_LIM := V_SHARED;
            P_LIM_DETAIL_O.LIM_DESC := V_DESC;
            P_LIM_DETAIL_O.LIM_CURR := V_CURR;
            P_LIM_DETAIL_O.LIM_EFF_DT := V_EFF_DT;
            P_LIM_DETAIL_O.LIM_AUTH_ON := V_AUTH_ON;
            P_LIM_DETAIL_O.LIM_EXP_DT := V_EXP_DT;
            P_LIM_DETAIL_O.PARENT_LIM_NO := V_PARENT_LIM_NO;
            P_LIM_DETAIL_O.SANC_AMT := V_AMT;
            P_LIM_DETAIL_O.EFF_DP_AMT := V_EFF_DP_AMT;
            P_LIM_DETAIL_O.UTILIZED_AMT := V_UTILIZED_AMT;
            P_LIM_DETAIL_O.DISBURSED_AMT := V_DISBURSED_AMT;
            P_LIM_DETAIL_O.AVLBL_AMT := V_AVLBL_AMT;
            P_LIM_DETAIL_O.EXCESS_AMT := V_EXCESS_AMT;
            P_LIM_DETAIL_O.MARK_IN_AMT := V_MARK_IN_AMT;
            P_LIM_DETAIL_O.MARK_OUT_AMT := V_MARK_OUT_AMT;
            P_LIM_DETAIL_O.REVOLV_GRP_LMT := V_REVOLV_GRP_LMT;
        END;

        PROCEDURE CHECK_GRP_LIMIT
        AS
        BEGIN
            IF     NVL (TRIM (V_APEX_LIM), '1') <> '1'
               AND NVL (TRIM (V_PARENT_LIM_NO), 0) <> 0
            THEN
                BEGIN
                    SELECT LMTLINE_GROUP_LEVEL_LIMIT
                      INTO V_IS_GRP_LIMIT
                      FROM LIMITLINE
                     WHERE     LMTLINE_ENTITY_NUM = V_ENTITY_NO
                           AND LMTLINE_CLIENT_CODE = V_CLIENT
                           AND LMTLINE_NUM = V_PARENT_LIM_NO;

                    IF NVL (TRIM (V_IS_GRP_LIMIT), '0') = '1'
                    THEN
                        V_GRP_EFF_LIMIT :=
                            PKG_LIMIT_DP_AMOUNT.SP_GET_EFF_LIMIT_AMT (
                                V_ENTITY_NO,
                                V_CLIENT,
                                V_PARENT_LIM_NO);
                        SP_CALC_DISB_MADE_ACNTOS (V_ENTITY_NO,
                                                  V_CLIENT,
                                                  V_PARENT_LIM_NO,
                                                  V_TOT_GRP_DISB,
                                                  V_ERR_MSG);
                        --IF V_TOT_GRP_DISB < 0
                        --THEN
                        --    V_GRP_AVLBL_LIMIT := V_GRP_EFF_LIMIT + ABS(V_TOT_GRP_DISB);
                        --ELSE
                        V_GRP_AVLBL_LIMIT := V_GRP_EFF_LIMIT - V_TOT_GRP_DISB;

                        --END IF;

                        IF V_GRP_AVLBL_LIMIT < 0
                        THEN
                            V_GRP_AVLBL_LIMIT := 0;
                        END IF;
                    END IF;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        NULL;
                END;
            END IF;
        END;

        FUNCTION IS_PART_OF_GRP_LIMIT
            RETURN BOOLEAN
        AS
        BEGIN
            RETURN NVL (V_IS_GRP_LIMIT, '0') = '1';
        END;
    BEGIN
        IF V_INT_ACNO <> 0
        THEN
            SELECT ACASLLDTL_ENTITY_NUM,
                   ACASLLDTL_CLIENT_NUM,
                   ACASLLDTL_LIMIT_LINE_NUM,
                   LMTLINE_FACILITY_GRP_CODE,
                   LMTLINE_PROD_CODE,
                   LMTLINE_SHARED_LIMIT_LINE,
                   LMTLINE_FACILITY_DESCN,
                   LMTLINE_SANCTION_CURR,
                   LMTLINE_LIMIT_EFF_DATE,
                   LMTLINE_AUTH_ON,
                   LMTLINE_LIMIT_EXPIRY_DATE,
                   LMTLINE_SUB_LIMIT_LINE,
                   LMTLINE_APEX_LEVEL_LIMIT,
                   LMTLINE_SANCTION_AMT,
                   LMTLINE_SANCTION_AMT,
                   LMTLINE_LIMIT_AVL_ON_DATE,
                   LMTLINE_MARKED_AMT_INTO,
                   LMTLINE_MARKED_AMT_OUT
              INTO V_ENTITY_NO,
                   V_CLIENT,
                   V_LIM_NO,
                   V_PROD_GRP,
                   V_PROD,
                   V_SHARED,
                   V_DESC,
                   V_CURR,
                   V_EFF_DT,
                   V_AUTH_ON,
                   V_EXP_DT,
                   V_PARENT_LIM_NO,
                   V_APEX_LIM,
                   V_AMT,
                   V_EFF_DP_AMT,
                   V_AVLBL_AMT,
                   V_MARK_IN_AMT,
                   V_MARK_OUT_AMT
              FROM ACASLLDTL, LIMITLINE
             WHERE     ACASLLDTL_ENTITY_NUM = LMTLINE_ENTITY_NUM
                   AND ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
                   AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
                   AND ACASLLDTL_ENTITY_NUM = V_ENTITY_NO
                   AND ACASLLDTL_INTERNAL_ACNUM = V_INT_ACNO;
        ELSIF P_CLIENT_NO <> 0 AND P_LIMIT_NO <> 0
        THEN
            SELECT LMTLINE_ENTITY_NUM,
                   LMTLINE_CLIENT_CODE,
                   LMTLINE_NUM,
                   LMTLINE_FACILITY_GRP_CODE,
                   LMTLINE_PROD_CODE,
                   LMTLINE_SHARED_LIMIT_LINE,
                   LMTLINE_FACILITY_DESCN,
                   LMTLINE_SANCTION_CURR,
                   LMTLINE_LIMIT_EFF_DATE,
                   LMTLINE_AUTH_ON,
                   LMTLINE_LIMIT_EXPIRY_DATE,
                   LMTLINE_SUB_LIMIT_LINE,
                   LMTLINE_APEX_LEVEL_LIMIT,
                   LMTLINE_SANCTION_AMT,
                   LMTLINE_SANCTION_AMT,
                   LMTLINE_LIMIT_AVL_ON_DATE,
                   LMTLINE_MARKED_AMT_INTO,
                   LMTLINE_MARKED_AMT_OUT,
                   LMTLINE_GROUP_LEVEL_LIMIT
              INTO V_ENTITY_NO,
                   V_CLIENT,
                   V_LIM_NO,
                   V_PROD_GRP,
                   V_PROD,
                   V_SHARED,
                   V_DESC,
                   V_CURR,
                   V_EFF_DT,
                   V_AUTH_ON,
                   V_EXP_DT,
                   V_PARENT_LIM_NO,
                   V_APEX_LIM,
                   V_AMT,
                   V_EFF_DP_AMT,
                   V_AVLBL_AMT,
                   V_MARK_IN_AMT,
                   V_MARK_OUT_AMT,
                   V_REVOLV_GRP_LMT
              FROM LIMITLINE
             WHERE     LMTLINE_ENTITY_NUM = V_ENTITY_NO
                   AND LMTLINE_CLIENT_CODE = P_CLIENT_NO
                   AND LMTLINE_NUM = V_LIM_NO;
        END IF;

        V_EFF_DP_AMT :=
            PKG_LIMIT_DP_AMOUNT.SP_GET_EFF_LIMIT_AMT (V_ENTITY_NO,
                                                      V_CLIENT,
                                                      V_LIM_NO);

        BEGIN
            SELECT NVL (TRIM (CBS_IMP_VALUE), '0')
              INTO V_LIM_AVLBL_ON_EXP_DT
              FROM CBS_IMP
             WHERE     CBS_IMP_ENTITY_NUM = V_ENTITY_NO
                   AND CBS_IMP_BRN_CODE = '999999'
                   AND CBS_IMP_MODULE_ID = 'LIMITS'
                   AND CBS_IMP_KEY_1 = 'LIMIT_AVLBL_EXP_DT'
                   AND CBS_IMP_KEY_2 = (SELECT INS_OUR_BANK_CODE
                                          FROM INSTALL
                                         WHERE INS_ENTITY_NUM = V_ENTITY_NO);
        EXCEPTION
            WHEN OTHERS
            THEN
                V_LIM_AVLBL_ON_EXP_DT := '0';
        END;

        IF    V_AUTH_ON IS NULL
           OR V_EFF_DT > W_CURR_BUSI_DATE
           OR (V_LIM_AVLBL_ON_EXP_DT = '1' AND V_EXP_DT < W_CURR_BUSI_DATE)
           OR (V_LIM_AVLBL_ON_EXP_DT = '0' AND V_EXP_DT <= W_CURR_BUSI_DATE)
        THEN
            V_AMT := 0;
            V_EFF_DP_AMT := 0;
        END IF;

        -- GROUP LEVEL LIMIT CHECKING
        CHECK_GRP_LIMIT;

        SP_CALC_DISB_MADE_ACNTOS (V_ENTITY_NO,
                                  V_CLIENT,
                                  V_LIM_NO,
                                  V_TOT_DISB_AMT,
                                  V_ERR_MSG);


        -- DISBURSEMENT AMOUNT WILL BE NEGATIVE IF THE ACCOUNT IS HAVING CREDIT BALANCE, LIMIT IS A REVOLVING ONE
        -- AND ITS NOT EXPIRED YET, AND AS LONG AS THE LIMIT OF SUCH ACCOUNT IS NOT EXPIRED
        -- THE DISBURSEMENT/UTILIZED AMOUNT WILL BE ZERO, BUT AVAILABLE BALANCE WILL BE INCREASED TO THAT EXTENT OF THE CREDIT BALANCE
        V_DISBURSED_AMT :=
            CASE WHEN V_TOT_DISB_AMT < 0 THEN 0 ELSE V_TOT_DISB_AMT END;
        V_UTILIZED_AMT := V_DISBURSED_AMT;
        V_AVLBL_AMT := V_EFF_DP_AMT - V_TOT_DISB_AMT;

        /*
        IF V_TOT_DISB_AMT < 0
        THEN
           V_AVLBL_AMT := V_EFF_DP_AMT + ABS (V_TOT_DISB_AMT);
           V_TOT_DISB_AMT := 0;
           V_UTILIZED_AMT := V_TOT_DISB_AMT;
           V_DISBURSED_AMT := V_TOT_DISB_AMT;
        ELSE
           V_UTILIZED_AMT := V_TOT_DISB_AMT;
           V_DISBURSED_AMT := V_TOT_DISB_AMT;
           V_AVLBL_AMT := V_EFF_DP_AMT - V_DISBURSED_AMT;
        END IF;
        */
        -- GROUP LIMIT CHECKING ON AVAILABLE BALANCE
        -- AVAILABLE BALANCE WILL BE LOWER OF OWN AND GROUP AVAILABLE BALANCE
        IF IS_PART_OF_GRP_LIMIT
        THEN
            V_AVLBL_AMT := LEAST (V_AVLBL_AMT, V_GRP_AVLBL_LIMIT);
        END IF;

        IF V_AVLBL_AMT < 0
        THEN
            V_EXCESS_AMT := ABS (V_AVLBL_AMT);
            V_AVLBL_AMT := 0;
        END IF;

        ASSIGN_VALUES;
    EXCEPTION
        WHEN OTHERS
        THEN
            P_ERR_MSG := 'Error in getting limit details...';
    END;

    FUNCTION CALC_LIMIT_DETAIL (
        P_ENTITY_NUM_I      ENTITYNUM.ENTITYNUM_NUMBER%TYPE := 1,
        P_CLIENT_NO_IO   IN IACLINK.IACLINK_CIF_NUMBER%TYPE)
        RETURN REC_TAB
        PIPELINED
    AS
        PROCEDURE CALCULATE
        AS
            LIMIT_DETAILS   PKG_COMMON_TYPES.LIMIT_DET_RT;

            V_ENTITY_NUM    ENTITYNUM.ENTITYNUM_NUMBER%TYPE := P_ENTITY_NUM_I;
            V_INT_ACNO      IACLINK.IACLINK_INTERNAL_ACNUM%TYPE;
            V_CLIENT_NO     IACLINK.IACLINK_CIF_NUMBER%TYPE := P_CLIENT_NO_IO;
            V_LIMIT_NO      LIMITLINE.LMTLINE_NUM%TYPE;

            V_ERR_MSG       PKG_COMMON_TYPES.STRING_T;

            PROCEDURE UPD_LIM_DETAIL (
                P_ENTITY_NUM_I   ENTITYNUM.ENTITYNUM_NUMBER%TYPE,
                P_INT_ACNO_I     IACLINK.IACLINK_INTERNAL_ACNUM%TYPE,
                P_CLIENT_NO      IACLINK.IACLINK_CIF_NUMBER%TYPE,
                P_LIMIT_NO       LIMITLINE.LMTLINE_NUM%TYPE)
            AS
            BEGIN
                SP_LIMIT_DETAIL (P_ENTITY_NUM_I,
                                 P_INT_ACNO_I,
                                 P_CLIENT_NO,
                                 P_LIMIT_NO,
                                 P_LIM_DETAIL_O   => LIMIT_DETAILS,
                                 P_ERR_MSG        => V_ERR_MSG);
            END;

            PROCEDURE ASSIGN_VALUES
            AS
            BEGIN
                P_CLIENT_NO_IO := LIMIT_DETAILS.CLIENT_NO;
                P_LIMIT_NO_IO := LIMIT_DETAILS.LIM_NO;
                P_PROD_GRP_O := LIMIT_DETAILS.PROD_GRP;
                P_PROD_O := LIMIT_DETAILS.PROD;
                P_SHARED_LIM_O := LIMIT_DETAILS.SHARED_LIM;
                P_LIM_DESC_O := LIMIT_DETAILS.LIM_DESC;
                P_LIM_CURR_O := LIMIT_DETAILS.LIM_CURR;
                P_LIM_EFF_DT_O := LIMIT_DETAILS.LIM_EFF_DT;
                P_LIM_AUTH_ON_O := LIMIT_DETAILS.LIM_AUTH_ON;
                P_LIM_EXP_DT_O := LIMIT_DETAILS.LIM_EXP_DT;
                P_PARENT_LIM_NO_O := LIMIT_DETAILS.PARENT_LIM_NO;
                P_SANC_AMT_O := LIMIT_DETAILS.SANC_AMT;
                P_EFF_DP_AMT_O := LIMIT_DETAILS.EFF_DP_AMT;
                P_UTILIZED_AMT_O := LIMIT_DETAILS.UTILIZED_AMT;
                P_DISBURSED_AMT_O := LIMIT_DETAILS.DISBURSED_AMT;
                P_AVLBL_AMT_O := LIMIT_DETAILS.AVLBL_AMT;
                P_EXCESS_AMT_O := LIMIT_DETAILS.EXCESS_AMT;
                P_MARK_IN_AMT_O := LIMIT_DETAILS.MARK_IN_AMT;
                P_MARK_OUT_AMT_O := LIMIT_DETAILS.MARK_OUT_AMT;
                P_ERR_MSG_O := V_ERR_MSG;
                P_REVOLV_GRP_LMT_O := LIMIT_DETAILS.REVOLV_GRP_LMT;
            END;
        BEGIN
            UPD_LIM_DETAIL;
            ASSIGN_VALUES;
        END;
    BEGIN
        CALCULATE;
    EXCEPTION
        WHEN OTHERS
        THEN
            P_ERR_MSG_O := 'Error in limit details calculation...';
    END;
END;
/
