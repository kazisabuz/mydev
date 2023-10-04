/* Formatted on 7/19/2023 6:16:05 PM (QP5 v5.388) */
CREATE OR REPLACE PROCEDURE SP_GLDIVBAL_TRANSFER (P_ENTITY_NUM    NUMBER,
                                                  P_BRANCH_CODE   NUMBER,
                                                  P_ASON_DATE     DATE,
                                                  P_EXC_FLAG      CHAR, ---1=P/L TRANSFER& MARGE,2=ONLY MERGE
                                                  P_USER_ID       VARCHAR2,
                                                  P_TERMINAL_ID   VARCHAR2)
/*

  Author :Kazi Sabuj
  Created : 07/19/2023 6:00:00 PM
  Purpose : Division wise p/l transfer

  */
AS
    W_ENTITY_NUM         NUMBER    := P_ENTITY_NUM;
    W_ERR_CODE           VARCHAR2 (6);
    W_ERROR              VARCHAR2 (1000);
    W_BATCH_NUM          NUMBER (6);
    W_CURRENT_DATE       DATE;
    E_USEREXCEP          EXCEPTION;
    V_CBD                DATE
                             := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (W_ENTITY_NUM);
    W_DR_TRAN_CD         TRANCD.TRANCD_CODE%TYPE := 'TD';
    W_CR_TRAN_CD         TRANCD.TRANCD_CODE%TYPE := 'TC';
    W_BASE_CURR_CD       INSTALL.INS_BASE_CURR_CODE%TYPE;
    W_ORIG_ADV_NUM       IBRADVICES.IBRADVICES_ADVICE_NUM%TYPE;
    W_TRAN_ADV_SL        NUMBER := 0;
    ERROR_MSG            VARCHAR2 (4000) := '';
    W_IBR_GL_STAT_CHG    BOOLEAN := FALSE;
    W_IBR_GL_MAST        GLMAST.GL_NUMBER%TYPE;
    W_ORIG_RESP          TRAN2015.TRAN_ORIG_RESP%TYPE;
    W_IBR_GL             EXTGL.EXTGL_ACCESS_CODE%TYPE;
    W_IBR_AC_AMOUNT      TRAN2015.TRAN_AMOUNT%TYPE;
    W_IBR_BC_AMOUNT      TRAN2015.TRAN_BASE_CURR_EQ_AMT%TYPE;
    W_IBR_CURR_CODE      TRAN2015.TRAN_CURR_CODE%TYPE;
    W_IBR_PARTICULARS    IBRADVICES.IBRADVICES_PARTICULARS%TYPE;
    W_IBR_CODE           IBTRANCD.IBTRAN_CODE%TYPE;
    W_IBR_CANC_CODE      IBTRANCD.IBTRAN_CODE%TYPE;
    W_CONT_BRN_CODE      MBRN.MBRN_CODE%TYPE;
    W_ADV_NUM            IBRADVICES.IBRADVICES_ADVICE_NUM%TYPE;
    W_ADV_DATE           IBRADVICES.IBRADVICES_ADVICE_DATE%TYPE;
    W_IBR_LEG_SL         TRAN2015.TRAN_BATCH_SL_NUM%TYPE;
    IBRADVICES_REC       IBRADVICES%ROWTYPE;

    W_BANK_CD            BANKCD.BANKCD_CODE%TYPE;
    W_IBR_ADV_CONT_BRN   BANKCD.BANKCD_CONTBRN_CODE%TYPE;

    W_SQL                PKG_COMMON_TYPES.STRING_T;
BEGIN
    SELECT INS_ENTITY_NUM, INS_OUR_BANK_CODE, INS_BASE_CURR_CODE
      INTO W_ENTITY_NUM, W_BANK_CD, W_BASE_CURR_CD
      FROM INSTALL;

    SELECT NVL (TRIM (BANKCD_CONTBRN_CODE), '0')
      INTO W_IBR_ADV_CONT_BRN
      FROM BANKCD
     WHERE BANKCD_CODE = W_BANK_CD;

    IF P_EXC_FLAG = '1'
    THEN
        FOR REC
            IN (  SELECT M.BATCH_SL,
                         M.LEG_SL,
                         M.LEG_COUNT,
                         CASE
                             WHEN (TRIM (M.TRAN_DATE) IS NOT NULL)
                             THEN
                                 M.TRAN_DATE
                             WHEN (    TRIM (M.TRAN_DATE) IS NULL
                                   AND TRIM (M.CALC_TRAN_DATE) IS NOT NULL)
                             THEN
                                 M.CALC_TRAN_DATE
                             WHEN (    TRIM (M.TRAN_DATE) IS NULL
                                   AND TRIM (M.CALC_TRAN_DATE) IS NULL
                                   AND TRIM (M.VALUE_DATE) IS NOT NULL)
                             THEN
                                 M.VALUE_DATE
                             WHEN (    TRIM (M.TRAN_DATE) IS NULL
                                   AND TRIM (M.CALC_TRAN_DATE) IS NULL
                                   AND TRIM (M.VALUE_DATE) IS NULL
                                   AND TRIM (M.CALC_VALUE_DATE) IS NOT NULL)
                             THEN
                                 M.CALC_VALUE_DATE
                             ELSE
                                 M.CURR_BIZ_DATE
                         END                                    TRAN_DATE,
                         CASE
                             WHEN TRIM (M.VALUE_DATE) IS NOT NULL
                             THEN
                                 M.VALUE_DATE
                             WHEN (    TRIM (M.VALUE_DATE) IS NULL
                                   AND TRIM (M.TRAN_DATE) IS NOT NULL)
                             THEN
                                 M.TRAN_DATE
                             WHEN (    TRIM (M.VALUE_DATE) IS NULL
                                   AND TRIM (M.TRAN_DATE) IS NULL
                                   AND TRIM (M.CALC_TRAN_DATE) IS NOT NULL)
                             THEN
                                 M.CALC_TRAN_DATE
                             WHEN (    TRIM (M.VALUE_DATE) IS NULL
                                   AND TRIM (M.TRAN_DATE) IS NULL
                                   AND TRIM (M.CALC_TRAN_DATE) IS NULL
                                   AND TRIM (M.CALC_VALUE_DATE) IS NOT NULL)
                             THEN
                                 M.CALC_VALUE_DATE
                             ELSE
                                 M.CURR_BIZ_DATE
                         END                                    VALUE_DATE,
                         TRIM (M.CALC_SUPP_TRAN)                SUPP_TRAN,
                         CASE
                             WHEN M.BRN_CODE <> 0
                             THEN
                                 M.BRN_CODE
                             WHEN M.BRN_CODE = 0 AND M.CALC_BRN_CODE <> 0
                             THEN
                                 M.CALC_BRN_CODE
                             WHEN     M.BRN_CODE = 0
                                  AND M.CALC_BRN_CODE = 0
                                  AND M.ACING_BRN_CODE <> 0
                             THEN
                                 M.ACING_BRN_CODE
                             WHEN     M.BRN_CODE = 0
                                  AND M.CALC_BRN_CODE = 0
                                  AND M.ACING_BRN_CODE = 0
                                  AND M.CALC_ACING_BRN_CODE <> 0
                             THEN
                                 M.CALC_ACING_BRN_CODE
                             ELSE
                                 0
                         END                                    BRN_CODE,
                         CASE
                             WHEN M.ACING_BRN_CODE <> 0
                             THEN
                                 M.ACING_BRN_CODE
                             WHEN M.ACING_BRN_CODE = 0 AND M.BRN_CODE <> 0
                             THEN
                                 M.BRN_CODE
                             WHEN     M.ACING_BRN_CODE = 0
                                  AND M.BRN_CODE = 0
                                  AND M.CALC_BRN_CODE <> 0
                             THEN
                                 M.CALC_BRN_CODE
                             WHEN     M.ACING_BRN_CODE = 0
                                  AND M.BRN_CODE = 0
                                  AND M.CALC_BRN_CODE = 0
                                  AND M.CALC_ACING_BRN_CODE <> 0
                             THEN
                                 M.CALC_ACING_BRN_CODE
                             ELSE
                                 0
                         END                                    ACING_BRN_CODE,
                         TRIM (M.DR_CR)                         DR_CR,
                         SUM (
                             CASE
                                 WHEN M.DR_CR = 'D' THEN M.BC_AMOUNT
                                 ELSE 0
                             END)
                             OVER (PARTITION BY M.BATCH_SL)     BC_TOT_DR,
                         SUM (
                             CASE
                                 WHEN M.DR_CR = 'C' THEN M.BC_AMOUNT
                                 ELSE 0
                             END)
                             OVER (PARTITION BY M.BATCH_SL)     BC_TOT_CR,
                         TRIM (M.GLACC_CODE)                    GLACC_CODE,
                         CASE
                             WHEN (TRIM (M.INT_AC_NO) IS NULL) THEN 0
                             ELSE M.INT_AC_NO
                         END                                    INT_AC_NO,
                         M.CONT_NO,
                         M.CURR_CODE,
                         M.AC_AMOUNT,
                         M.BC_AMOUNT,
                         M.PRINCIPAL,
                         M.INTEREST,
                         M.CHARGE,
                         TRIM (M.INST_PREFIX)                   INST_PREFIX,
                         M.INST_NUM,
                         M.INST_DATE,
                         TRIM (M.IBR_GL)                        IBR_GL,
                         TRIM (M.ORIG_RESP)                     ORIG_RESP,
                         CASE
                             WHEN (TRIM (M.ORIGINATING) = 'O') THEN '1'
                             ELSE '0'
                         END                                    ORIG_AVLBL,
                         M.CONT_BRN_CODE,
                         M.ADV_NUM,
                         M.ADV_DATE,
                         TRIM (M.IBR_CODE)                      IBR_CODE,
                         TRIM (M.CAN_IBR_CODE)                  CANC_IBR_CODE,
                         CASE
                             WHEN (    TRIM (M.LEG_NARRATION) IS NULL
                                   AND TRIM (M.CALC_LEG_NARRATION) IS NULL
                                   AND TRIM (M.CALC_BATCH_NARRATION) IS NULL)
                             THEN
                                 'Manual Tx Posting'
                             WHEN (    TRIM (M.LEG_NARRATION) IS NULL
                                   AND TRIM (M.CALC_LEG_NARRATION) IS NULL
                                   AND TRIM (M.CALC_BATCH_NARRATION)
                                           IS NOT NULL)
                             THEN
                                 TRIM (M.CALC_BATCH_NARRATION)
                             WHEN (    TRIM (M.LEG_NARRATION) IS NULL
                                   AND TRIM (M.CALC_LEG_NARRATION) IS NOT NULL)
                             THEN
                                 TRIM (M.CALC_LEG_NARRATION)
                             ELSE
                                 TRIM (M.LEG_NARRATION)
                         END                                    LEG_NARRATION,
                         TRIM (M.CALC_BATCH_NARRATION)          BATCH_NARRATION,
                         TRIM (M.CALC_USER_ID)                  USER_ID,
                         (SELECT U.USER_ROLE_CODE
                            FROM USERS U
                           WHERE U.USER_ID = M.CALC_USER_ID)    USER_ROLE,
                         CASE
                             WHEN TRIM (M.CALC_TERMINAL_ID) IS NULL
                             THEN
                                 '127.0.0.1'
                             ELSE
                                 TRIM (M.CALC_TERMINAL_ID)
                         END                                    TERMINAL_ID,
                         M.DEPT_CODE
                   FROM (SELECT T.BATCH_SL,
                                T.LEG_SL,
                                COUNT (T.LEG_SL) OVER (PARTITION BY T.BATCH_SL)
                                    LEG_COUNT,
                                T.TRAN_DATE,
                                FIRST_VALUE (T.TRAN_DATE)
                                    IGNORE NULLS
                                    OVER (PARTITION BY T.BATCH_SL)
                                    CALC_TRAN_DATE,
                                T.VALUE_DATE,
                                FIRST_VALUE (T.VALUE_DATE)
                                    IGNORE NULLS
                                    OVER (PARTITION BY T.BATCH_SL)
                                    CALC_VALUE_DATE,
                                (SELECT MN_CURR_BUSINESS_DATE FROM MAINCONT)
                                    CURR_BIZ_DATE,
                                T.SUPP_TRAN,
                                FIRST_VALUE (T.SUPP_TRAN)
                                    IGNORE NULLS
                                    OVER (PARTITION BY T.BATCH_SL)
                                    CALC_SUPP_TRAN,
                                NVL (T.BRN_CODE, 0)
                                    BRN_CODE,
                                NVL (
                                    FIRST_VALUE (T.BRN_CODE)
                                        IGNORE NULLS
                                        OVER (PARTITION BY T.BATCH_SL),
                                    0)
                                    CALC_BRN_CODE,
                                NVL (T.ACING_BRN_CODE, 0)
                                    ACING_BRN_CODE,
                                NVL (
                                    FIRST_VALUE (T.ACING_BRN_CODE)
                                        IGNORE NULLS
                                        OVER (PARTITION BY T.BATCH_SL),
                                    0)
                                    CALC_ACING_BRN_CODE,
                                T.DR_CR,
                                T.GLACC_CODE,
                                T.INT_AC_NO,
                                T.CONT_NO,
                                CASE
                                    WHEN TRIM (T.CURR_CODE) IS NULL
                                    THEN
                                        (SELECT INS_BASE_CURR_CODE
                                           FROM INSTALL)
                                    ELSE
                                        TRIM (T.CURR_CODE)
                                END
                                    CURR_CODE,
                                CASE
                                    WHEN (   TRIM (T.AC_AMOUNT) IS NULL
                                          OR T.AC_AMOUNT = 0)
                                    THEN
                                        ABS (T.BC_AMOUNT)
                                    ELSE
                                        ABS (T.AC_AMOUNT)
                                END
                                    AC_AMOUNT,
                                CASE
                                    WHEN (   TRIM (T.BC_AMOUNT) IS NULL
                                          OR T.BC_AMOUNT = 0)
                                    THEN
                                        ABS (T.AC_AMOUNT)
                                    ELSE
                                        ABS (T.BC_AMOUNT)
                                END
                                    BC_AMOUNT,
                                ABS (T.PRINCIPAL)
                                    PRINCIPAL,
                                ABS (T.INTEREST)
                                    INTEREST,
                                ABS (T.CHARGE)
                                    CHARGE,
                                T.INST_PREFIX,
                                T.INST_NUM,
                                T.INST_DATE,
                                T.IBR_GL,
                                T.ORIG_RESP,
                                FIRST_VALUE (T.ORIG_RESP)
                                IGNORE NULLS
                                OVER (PARTITION BY T.BATCH_SL
                                      ORDER BY T.ORIG_RESP)
                                    ORIGINATING,
                                T.CONT_BRN_CODE,
                                T.ADV_NUM,
                                T.ADV_DATE,
                                T.IBR_CODE,
                                T.CAN_IBR_CODE,
                                T.LEG_NARRATION,
                                FIRST_VALUE (T.LEG_NARRATION)
                                    IGNORE NULLS
                                    OVER (PARTITION BY T.BATCH_SL)
                                    CALC_LEG_NARRATION,
                                T.BATCH_NARRATION,
                                FIRST_VALUE (T.BATCH_NARRATION)
                                    IGNORE NULLS
                                    OVER (PARTITION BY T.BATCH_SL)
                                    CALC_BATCH_NARRATION,
                                T.USER_ID,
                                FIRST_VALUE (T.USER_ID)
                                    IGNORE NULLS
                                    OVER (PARTITION BY T.BATCH_SL)
                                    CALC_USER_ID,
                                T.TERMINAL_ID,
                                FIRST_VALUE (T.TERMINAL_ID)
                                    IGNORE NULLS
                                    OVER (PARTITION BY T.BATCH_SL)
                                    CALC_TERMINAL_ID,
                                T.DEPT_CODE
                                    DEPT_CODE
                           FROM (SELECT 1 BATCH_SL, ROWNUM LEG_SL, T.*
                                   FROM (  SELECT P_ASON_DATE
                                                      TRAN_DATE,
                                                  P_ASON_DATE
                                                      VALUE_DATE,
                                                  CASE
                                                      WHEN V_CBD <> P_ASON_DATE
                                                      THEN
                                                          1
                                                      ELSE
                                                          NULL
                                                  END
                                                      SUPP_TRAN,
                                                  P_BRANCH_CODE
                                                      BRN_CODE,
                                                  P_BRANCH_CODE
                                                      ACING_BRN_CODE,
                                                  CASE
                                                      WHEN SUM (CLOSING_BAL) > 0
                                                      THEN
                                                          'D'
                                                      ELSE
                                                          'C'
                                                  END
                                                      DR_CR,
                                                  GLACC_CODE
                                                      GLACC_CODE,
                                                  NULL
                                                      INT_AC_NO,
                                                  NULL
                                                      CONT_NO,
                                                  CURR_CODE,
                                                  ABS (SUM (CLOSING_BAL))
                                                      AC_AMOUNT,
                                                  ABS (SUM (CLOSING_BAL_BC))
                                                      BC_AMOUNT,
                                                  NULL
                                                      PRINCIPAL,
                                                  NULL
                                                      INTEREST,
                                                  NULL
                                                      CHARGE,
                                                  NULL
                                                      INST_PREFIX,
                                                  NULL
                                                      INST_NUM,
                                                  NULL
                                                      INST_DATE,
                                                  NULL
                                                      IBR_GL,
                                                  NULL
                                                      ORIG_RESP,
                                                  NULL
                                                      CONT_BRN_CODE,
                                                  NULL
                                                      ADV_NUM,
                                                  NULL
                                                      ADV_DATE,
                                                  NULL
                                                      IBR_CODE,
                                                  NULL
                                                      CAN_IBR_CODE,
                                                     'P/L transfer '
                                                  || TO_CHAR (P_ASON_DATE,
                                                              'YYYY')
                                                      LEG_NARRATION,
                                                     'P/L transfer '
                                                  || TO_CHAR (P_ASON_DATE,
                                                              'YYYY')
                                                      BATCH_NARRATION,
                                                  P_USER_ID
                                                      USER_ID,
                                                  P_TERMINAL_ID
                                                      TERMINAL_ID,
                                                  NULL
                                                      PROCESSED,
                                                  NULL
                                                      BATCH_NO,
                                                  NULL
                                                      ERR_MSG,
                                                  DEPT_CODE
                                             FROM GLDIVBAL
                                            WHERE     ENTITY_NUM = 1
                                                  AND BRN_CODE = P_BRANCH_CODE
                                                  AND CLOSING_DATE <= P_ASON_DATE ---last year end date
                                                  AND SUBSTR (GLACC_CODE, 1, 3) IN
                                                          ('300', '400')
                                         GROUP BY ENTITY_NUM,
                                                  BRN_CODE,
                                                  GLACC_CODE,
                                                  DEPT_CODE,
                                                  CURR_CODE
                                           HAVING SUM (CLOSING_BAL) * -1 <> 0
                                         UNION ALL
                                           SELECT P_ASON_DATE
                                                      TRAN_DATE,
                                                  P_ASON_DATE
                                                      VALUE_DATE,
                                                  CASE
                                                      WHEN V_CBD <> P_ASON_DATE
                                                      THEN
                                                          1
                                                      ELSE
                                                          NULL
                                                  END
                                                      SUPP_TRAN,
                                                  P_BRANCH_CODE
                                                      BRN_CODE,
                                                  P_BRANCH_CODE
                                                      ACING_BRN_CODE,
                                                  CASE
                                                      WHEN SUM (CLOSING_BAL) > 0
                                                      THEN
                                                          'C'
                                                      ELSE
                                                          'D'
                                                  END
                                                      DR_CR,
                                                  GLACC_CODE
                                                      GLACC_CODE,
                                                  NULL
                                                      INT_AC_NO,
                                                  NULL
                                                      CONT_NO,
                                                  CURR_CODE,
                                                  ABS (SUM (CLOSING_BAL))
                                                      AC_AMOUNT,
                                                  ABS (SUM (CLOSING_BAL_BC))
                                                      BC_AMOUNT,
                                                  NULL
                                                      PRINCIPAL,
                                                  NULL
                                                      INTEREST,
                                                  NULL
                                                      CHARGE,
                                                  NULL
                                                      INST_PREFIX,
                                                  NULL
                                                      INST_NUM,
                                                  NULL
                                                      INST_DATE,
                                                  NULL
                                                      IBR_GL,
                                                  NULL
                                                      ORIG_RESP,
                                                  NULL
                                                      CONT_BRN_CODE,
                                                  NULL
                                                      ADV_NUM,
                                                  NULL
                                                      ADV_DATE,
                                                  NULL
                                                      IBR_CODE,
                                                  NULL
                                                      CAN_IBR_CODE,
                                                     'P/L transfer '
                                                  || TO_CHAR (P_ASON_DATE,
                                                              'YYYY')
                                                      LEG_NARRATION,
                                                     'P/L transfer '
                                                  || TO_CHAR (P_ASON_DATE,
                                                              'YYYY')
                                                      BATCH_NARRATION,
                                                  P_USER_ID
                                                      USER_ID,
                                                  P_TERMINAL_ID
                                                      TERMINAL_ID,
                                                  NULL
                                                      PROCESSED,
                                                  NULL
                                                      BATCH_NO,
                                                  NULL
                                                      ERR_MSG,
                                                  NULL
                                                      DEPT_CODE
                                             FROM GLDIVBAL
                                            WHERE     ENTITY_NUM = 1
                                                  AND BRN_CODE = P_BRANCH_CODE
                                                  AND CLOSING_DATE <= P_ASON_DATE
                                                  AND SUBSTR (GLACC_CODE, 1, 3) IN
                                                          ('300', '400')
                                         GROUP BY ENTITY_NUM,
                                                  BRN_CODE,
                                                  GLACC_CODE,
                                                  CURR_CODE
                                           HAVING SUM (CLOSING_BAL) * -1 <> 0
                                         ORDER BY GLACC_CODE, DEPT_CODE) T) T)
                        M
               ORDER BY M.BATCH_SL, M.LEG_SL)
        LOOP
            BEGIN
                IF REC.LEG_SL = 1
                THEN
                    W_TRAN_ADV_SL := 0;
                    W_IBR_GL_STAT_CHG := FALSE;
                    W_IBR_GL_MAST := NULL;
                    W_IBR_GL := NULL;
                    W_IBR_CODE := NULL;
                    W_IBR_CANC_CODE := NULL;
                    W_CONT_BRN_CODE := NULL;
                    W_IBR_AC_AMOUNT := 0;
                    W_IBR_BC_AMOUNT := 0;
                    W_IBR_CURR_CODE := NULL;
                    W_IBR_PARTICULARS := NULL;
                    W_ADV_NUM := NULL;
                    W_ADV_DATE := NULL;
                    IBRADVICES_REC := NULL;
                    W_ORIG_RESP := NULL;
                    W_IBR_LEG_SL := NULL;
                    W_ORIG_ADV_NUM := NULL;
                    W_SQL := '';
                    PKG_AUTOPOST.PV_TRAN_REC.DELETE;
                    PKG_AUTOPOST.PV_TRANCMN_REC.DELETE;
                    PKG_AUTOPOST.PV_TRAN_ADV_REC.DELETE;

                    PKG_AUTOPOST.PV_USERID := REC.USER_ID;
                    PKG_AUTOPOST.PV_BOPAUTHQ_REQ := FALSE;
                    PKG_AUTOPOST.PV_AUTH_DTLS_UPDATE_REQ := FALSE;
                    PKG_AUTOPOST.PV_CALLED_BY_EOD_SOD := 0;
                    PKG_AUTOPOST.PV_EXCEP_CHECK_NOT_REQD := FALSE;
                    PKG_AUTOPOST.PV_OVERDRAFT_CHK_REQD := FALSE;
                    PKG_AUTOPOST.PV_ALLOW_ZERO_TRANAMT := FALSE;
                    PKG_PROCESS_BOPAUTHQ.V_BOPAUTHQ_UPD := FALSE;
                    PKG_AUTOPOST.PV_CANCEL_FLAG := FALSE;
                    PKG_AUTOPOST.PV_POST_AS_UNAUTH_MOD := FALSE;
                    PKG_AUTOPOST.PV_CLG_BATCH_CLOSURE := FALSE;
                    PKG_AUTOPOST.PV_AUTHORIZED_RECORD_CANCEL := FALSE;
                    PKG_AUTOPOST.PV_BACKDATED_TRAN_REQUIRED :=
                        NVL (TRIM (REC.SUPP_TRAN), '0');
                    PKG_AUTOPOST.PV_CLG_REGN_POSTING := FALSE;
                    PKG_AUTOPOST.PV_FRESH_BATCH_SL := FALSE;
                    PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BRN_CODE := REC.BRN_CODE;
                    PKG_AUTOPOST.PV_TRAN_KEY.TRAN_DATE_OF_TRAN :=
                        REC.TRAN_DATE;
                    PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_NUMBER := 0;
                    PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_SL_NUM := 0;
                    PKG_AUTOPOST.PV_AUTO_AUTHORISE := TRUE;
                    PKG_PB_GLOBAL.G_TERMINAL_ID := REC.TERMINAL_ID;
                    PKG_POST_INTERFACE.G_BATCH_NUMBER_UPDATE_REQ := FALSE;
                    PKG_POST_INTERFACE.G_SRC_TABLE_AUTH_REJ_REQ := FALSE;
                    PKG_AUTOPOST.PV_TRAN_ONLY_UNDO := FALSE;
                    PKG_AUTOPOST.PV_OCLG_POSTING_FLG := FALSE;
                    PKG_POST_INTERFACE.G_IBR_REQUIRED := 1;
                    PKG_POST_INTERFACE.G_PGM_NAME := 'ETRAN';
                    PKG_PB_AUTOPOST.G_FORM_NAME := 'ETRAN';
                    PKG_AUTOPOST.PV_USER_ROLE_CODE := REC.USER_ROLE;
                    PKG_AUTOPOST.PV_SUPP_TRAN_POST :=
                        CASE
                            WHEN REC.SUPP_TRAN = '1' THEN TRUE
                            ELSE FALSE
                        END;
                    PKG_AUTOPOST.PV_FUTURE_TRANSACTION_ALLOWED := TRUE;
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_BRN_CODE := REC.BRN_CODE;
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_DATE_OF_TRAN :=
                        REC.TRAN_DATE;
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_BATCH_NUMBER := 0;
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_ENTRY_BRN_CODE :=
                        REC.BRN_CODE;
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_WITHDRAW_SLIP := '';
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_TOKEN_ISSUED := 0;
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_BACKOFF_SYS_CODE := '';
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_DEVICE_CODE := '';
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_DEVICE_UNIT_NUM := '';
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_CHANNEL_DT_TIME := NULL;
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_CHANNEL_UNIQ_NUM := '';
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_COST_CNTR_CODE := '';
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SUB_COST_CNTR := '';
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_PROFIT_CNTR_CODE := '';
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SUB_PROFIT_CNTR := '';
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NUM_TRANS :=
                        REC.LEG_COUNT;
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_BASE_CURR_TOT_CR :=
                        REC.BC_TOT_CR;
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_BASE_CURR_TOT_DB :=
                        REC.BC_TOT_DR;
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_CANCEL_BY := '';
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_CANCEL_ON := NULL;
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_CANCEL_REM1 := '';
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_CANCEL_REM2 := '';
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_CANCEL_REM3 := '';
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_TABLE := 'TRAN';
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_KEY :=
                        REC.BRN_CODE || '|' || REC.TRAN_DATE || '|0';
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL1 :=
                        SUBSTR (REC.BATCH_NARRATION, 1, 35);
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL2 :=
                        SUBSTR (REC.BATCH_NARRATION, 36, 35);
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL3 :=
                        SUBSTR (REC.BATCH_NARRATION, 71, 35);
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_AUTH_BY := REC.USER_ID;
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_AUTH_ON := NULL;
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SHIFT_TO_TRAN_DATE :=
                        NULL;
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SHIFT_TO_BAT_NUM := 0;
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SHIFT_FROM_TRAN_DATE :=
                        NULL;
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SHIFT_FROM_BAT_NUM := 0;
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_REV_TO_TRAN_DATE := NULL;
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_REV_TO_BAT_NUM := 0;
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_REV_FROM_TRAN_DATE :=
                        NULL;
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_REV_FROM_BAT_NUM := 0;
                    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SUBBRN_CODE := 0;
                END IF;

                IF REC.LEG_SL <= REC.LEG_COUNT
                THEN
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_BRN_CODE :=
                        REC.BRN_CODE;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_DEPT_CODE :=
                        REC.DEPT_CODE;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_DATE_OF_TRAN :=
                        REC.TRAN_DATE;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_BATCH_NUMBER :=
                        0;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_BATCH_SL_NUM :=
                        0;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_PROD_CODE := 0;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_CODE :=
                        CASE
                            WHEN REC.DR_CR = 'D' THEN W_DR_TRAN_CD
                            ELSE W_CR_TRAN_CD
                        END;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_VALUE_DATE :=
                        REC.VALUE_DATE;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_ACING_BRN_CODE :=
                        REC.ACING_BRN_CODE;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_INTERNAL_ACNUM :=
                        REC.INT_AC_NO;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_CONTRACT_NUM :=
                        NVL (TRIM (REC.CONT_NO), 0);
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_GLACC_CODE :=
                        REC.GLACC_CODE;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_DB_CR_FLG :=
                        REC.DR_CR;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_TYPE_OF_TRAN :=
                        '1';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_CURR_CODE :=
                        REC.CURR_CODE;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_AMOUNT :=
                        REC.AC_AMOUNT;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_BASE_CURR_CODE :=
                        W_BASE_CURR_CD;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_BASE_CURR_CONV_RATE :=
                        CASE
                            WHEN (REC.AC_AMOUNT <> REC.BC_AMOUNT)
                            THEN
                                TRUNC (REC.BC_AMOUNT / REC.AC_AMOUNT, 5)
                            ELSE
                                1
                        END;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_BASE_CURR_EQ_AMT :=
                        REC.BC_AMOUNT;

                    IF (   (   TRIM (REC.PRINCIPAL) IS NOT NULL
                            OR REC.PRINCIPAL > 0)
                        OR (   TRIM (REC.INTEREST) IS NOT NULL
                            OR REC.INTEREST > 0)
                        OR (TRIM (REC.CHARGE) IS NOT NULL OR REC.CHARGE > 0))
                    THEN
                        W_TRAN_ADV_SL := W_TRAN_ADV_SL + 1;
                        PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_AMT_BRKUP :=
                            '1';
                        PKG_AUTOPOST.PV_TRAN_ADV_REC (W_TRAN_ADV_SL).TRANADV_BATCH_SL_NUM :=
                            REC.LEG_SL;
                        PKG_AUTOPOST.PV_TRAN_ADV_REC (W_TRAN_ADV_SL).TRANADV_PRIN_AC_AMT :=
                            NVL (TRIM (REC.PRINCIPAL), 0);
                        PKG_AUTOPOST.PV_TRAN_ADV_REC (W_TRAN_ADV_SL).TRANADV_INTRD_AC_AMT :=
                            NVL (TRIM (REC.INTEREST), 0);
                        PKG_AUTOPOST.PV_TRAN_ADV_REC (W_TRAN_ADV_SL).TRANADV_CHARGE_AC_AMT :=
                            NVL (TRIM (REC.CHARGE), 0);
                    ELSE
                        PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_AMT_BRKUP :=
                            '0';
                    END IF;

                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_SERVICE_CODE :=
                        '';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_CHARGE_CODE :=
                        '';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_DELIVERY_CHANNEL_CODE :=
                        '';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_DEVICE_CODE :=
                        '';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_DEVICE_UNIT_NUMBER :=
                        '';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_TRN_EXT_REF_NUMBER :=
                        '';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_INSTR_CHQ_PFX :=
                        REC.INST_PREFIX;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_INSTR_CHQ_NUMBER :=
                        REC.INST_NUM;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_INSTR_DATE :=
                        REC.INST_DATE;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_PROFIT_CUST_CODE :=
                        0;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_REMITTANCE_CODE :=
                        '';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_SIGN_COMB_SL :=
                        0;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_SIGN_VERIFIED_FLG :=
                        '1';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_LIMIT_CURR :=
                        '';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_CRATE_TO_LIMIT_CURR :=
                        0.0;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_LIMIT_CURR_EQUIVALENT :=
                        0.0;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_ENTD_BY :=
                        REC.USER_ID;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_ENTD_ON :=
                        NULL;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_LAST_MOD_BY :=
                        '';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_LAST_MOD_ON :=
                        NULL;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_FIRST_AUTH_BY :=
                        '';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_FIRST_AUTH_ON :=
                        NULL;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_AUTH_BY :=
                        REC.USER_ID;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_AUTH_ON :=
                        NULL;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_RISK_AUTH_BY :=
                        '';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_RISK_AUTH_ON :=
                        NULL;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_SYSTEM_POSTED_TRAN :=
                        '1';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_CASHIER_ID :=
                        '';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_CASH_TRAN_DATE :=
                        NULL;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_CASH_TRAN_DAY_SL :=
                        0;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_AC_CANCEL_AMT :=
                        0.0;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_BC_CANCEL_AMT :=
                        0.0;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_INTERMED_VCR_FLG :=
                        '';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_BACKOFF_SYS_CODE :=
                        '';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_CHANNEL_DT_TIME :=
                        NULL;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_CHANNEL_UNIQ_NUM :=
                        '';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_COST_CNTR_CODE :=
                        '';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_SUB_COST_CNTR :=
                        '';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_PROFIT_CNTR_CODE :=
                        '';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_SUB_PROFIT_CNTR :=
                        '';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_NOM_AC_ENT_TYPE :=
                        '';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_NOM_AC_PRE_ENT_YR :=
                        0;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_NOM_AC_REF_NUM :=
                        0;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_HOLD_REFNUM :=
                        0;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_ACNT_INVALID :=
                        '';
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_AVAILABLE_AC_BAL :=
                        0.0;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_AGENCY_BANK_CODE :=
                        '';

                    IF (    REC.IBR_GL = '1'
                        AND (   TRIM (REC.SUPP_TRAN) IS NULL
                             OR REC.SUPP_TRAN = '0'))
                    THEN
                        PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_IBR_BRN_CODE :=
                            REC.CONT_BRN_CODE;
                        PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_IBR_CODE :=
                            REC.IBR_CODE;

                        IF (REC.ORIG_RESP IN ('P', 'S'))
                        THEN
                            PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_CANC_IBR_CODE :=
                                REC.CANC_IBR_CODE;
                        END IF;

                        PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_ORIG_RESP :=
                            REC.ORIG_RESP;
                        PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_IBR_YEAR :=
                            CASE
                                WHEN REC.ORIG_RESP <> 'O'
                                THEN
                                    TO_NUMBER (
                                        TO_CHAR (REC.ADV_DATE, 'YYYY'))
                                ELSE
                                    0
                            END;
                        PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_IBR_NUM :=
                            0;
                        PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_ADVICE_NUM :=
                            CASE
                                WHEN REC.ORIG_RESP <> 'O' THEN REC.ADV_NUM
                                ELSE 0
                            END;
                        PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_ADVICE_DATE :=
                            CASE
                                WHEN REC.ORIG_RESP <> 'O' THEN REC.ADV_DATE
                                ELSE NULL
                            END;
                    END IF;

                    IF (REC.SUPP_TRAN = '1' AND REC.IBR_GL = '1')
                    THEN
                        W_IBR_GL := REC.GLACC_CODE;
                        W_IBR_AC_AMOUNT := REC.AC_AMOUNT;
                        W_IBR_BC_AMOUNT := REC.BC_AMOUNT;
                        W_IBR_CURR_CODE := REC.CURR_CODE;
                        W_IBR_PARTICULARS :=
                            SUBSTR (REC.LEG_NARRATION, 1, 35);
                        W_ORIG_RESP := REC.ORIG_RESP;
                        W_IBR_CODE := REC.IBR_CODE;
                        W_IBR_CANC_CODE := REC.CANC_IBR_CODE;
                        W_CONT_BRN_CODE := REC.CONT_BRN_CODE;
                        W_IBR_LEG_SL := REC.LEG_SL;
                        W_ADV_NUM :=
                            CASE
                                WHEN REC.ORIG_RESP <> 'O' THEN REC.ADV_NUM
                                ELSE NULL
                            END;
                        W_ADV_DATE :=
                            CASE
                                WHEN REC.ORIG_RESP <> 'O' THEN REC.ADV_DATE
                                ELSE REC.TRAN_DATE
                            END;

                        W_IBR_GL_MAST :=
                            TO_NUMBER (SUBSTR (REC.GLACC_CODE, 1, 3));

                        UPDATE GLMAST
                           SET GL_INTER_BRN_GL = '0'
                         WHERE GL_NUMBER = W_IBR_GL_MAST;

                        W_IBR_GL_STAT_CHG := TRUE;
                    END IF;

                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_TERMINAL_ID :=
                        REC.TERMINAL_ID;
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_NARR_DTL1 :=
                        SUBSTR (REC.LEG_NARRATION, 1, 35);
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_NARR_DTL2 :=
                        SUBSTR (REC.LEG_NARRATION, 36, 35);
                    PKG_AUTOPOST.PV_TRAN_REC (REC.LEG_SL).TRAN_NARR_DTL3 :=
                        SUBSTR (REC.LEG_NARRATION, 71, 35);
                    PKG_AUTOPOST.PV_TRANCMN_REC (REC.LEG_SL).TRANCMN_BATCH_SL_NUM :=
                        1;
                    PKG_AUTOPOST.PV_TRANCMN_REC (REC.LEG_SL).TRANCMN_DTL1 :=
                        '';
                    PKG_AUTOPOST.PV_TRANCMN_REC (REC.LEG_SL).TRANCMN_DTL2 :=
                        '';
                    PKG_AUTOPOST.PV_TRANCMN_REC (REC.LEG_SL).TRANCMN_DTL3 :=
                        '';
                    PKG_AUTOPOST.PV_TRANCMN_REC (REC.LEG_SL).TRANCMN_DTL4 :=
                        '';
                    PKG_AUTOPOST.PV_TRANCMN_REC (REC.LEG_SL).TRANCMN_DTL5 :=
                        '';

                    IF REC.LEG_SL = REC.LEG_COUNT
                    THEN
                        PKG_POST_INTERFACE.SP_AUTOPOSTTRAN (1,
                                                            'A',
                                                            REC.LEG_COUNT,
                                                            W_TRAN_ADV_SL,
                                                            0,
                                                            0,
                                                            0,
                                                            'N',
                                                            W_ERR_CODE,
                                                            W_ERROR,
                                                            W_BATCH_NUM);

                        IF REC.ORIG_AVLBL = '1'
                        THEN
                            IF REC.SUPP_TRAN <> '1'
                            THEN
                                PKG_POST_INTERFACE.SP_GET_ADVICE_NUM (
                                    1,
                                    W_ORIG_ADV_NUM);
                            END IF;
                        END IF;

                        IF    (    TRIM (W_ERR_CODE) IS NOT NULL
                               AND TRIM (W_ERR_CODE) <> '0000')
                           OR TRIM (W_ERROR) IS NOT NULL
                        THEN
                            ERROR_MSG :=
                                   CASE
                                       WHEN     TRIM (W_ERR_CODE) IS NOT NULL
                                            AND TRIM (W_ERR_CODE) <> '0000'
                                       THEN
                                           TRIM (W_ERR_CODE)
                                       ELSE
                                           ''
                                   END
                                || CASE
                                       WHEN (    TRIM (W_ERR_CODE)
                                                     IS NOT NULL
                                             AND TRIM (W_ERR_CODE) <> '0000'
                                             AND TRIM (W_ERROR) IS NOT NULL)
                                       THEN
                                           '|' || TRIM (W_ERROR)
                                       ELSE
                                           ''
                                   END;
                        END IF;
                    END IF;
                END IF;
            END;
        END LOOP;

        IF W_BATCH_NUM <> 0
        THEN
            W_SQL :=
                   '
    MERGE INTO GLDIVBAL G1
         USING (  SELECT TRAN_ENTITY_NUM,
                         TRAN_ACING_BRN_CODE,
                         TRAN_GLACC_CODE,
                         TRAN_CURR_CODE,
                         TRAN_DEPT_CODE,
                         TRAN_DATE_OF_TRAN,
                           NVL (
                               SUM (DECODE (TRAN_DB_CR_FLG, ''C'', TRAN_AMOUNT)),
                               0)
                         - NVL (
                               SUM (DECODE (TRAN_DB_CR_FLG, ''D'', TRAN_AMOUNT)),
                               0)    TRAN_AMOUNT,
                           NVL (
                               SUM (
                                   DECODE (TRAN_DB_CR_FLG,
                                           ''C'', TRAN_BASE_CURR_EQ_AMT)),
                               0)
                         - NVL (
                               SUM (
                                   DECODE (TRAN_DB_CR_FLG,
                                           ''D'', TRAN_BASE_CURR_EQ_AMT)),
                               0)    TRAN_BC_AMOUNT
                    FROM TRAN'
                || TO_CHAR (P_ASON_DATE, 'YYYY')
                || '
                   WHERE     TRAN_ENTITY_NUM = 1
                         AND (TRAN_AMOUNT > 0 OR TRAN_BASE_CURR_EQ_AMT > 0)
                         AND TRAN_AUTH_ON IS NOT NULL
                         AND TRAN_DEPT_CODE IS NOT NULL
                         AND TRAN_DATE_OF_TRAN = :P_ASON_DATE
                GROUP BY TRAN_ENTITY_NUM,
                         TRAN_ACING_BRN_CODE,
                         TRAN_GLACC_CODE,
                         TRAN_CURR_CODE,
                         TRAN_DEPT_CODE,
                         TRAN_DATE_OF_TRAN) G2
            ON (    G1.ENTITY_NUM = G2.TRAN_ENTITY_NUM
                AND G1.BRN_CODE = G2.TRAN_ACING_BRN_CODE
                AND G1.GLACC_CODE = G2.TRAN_GLACC_CODE
                AND G1.CURR_CODE = G2.TRAN_CURR_CODE
                AND G1.DEPT_CODE = G2.TRAN_DEPT_CODE
                AND G1.CLOSING_DATE = G2.TRAN_DATE_OF_TRAN)
    WHEN MATCHED
    THEN
        UPDATE SET
            G1.CLOSING_BAL = G2.TRAN_AMOUNT,
            G1.CLOSING_BAL_BC = G2.TRAN_BC_AMOUNT
    WHEN NOT MATCHED
    THEN
        INSERT     (ENTITY_NUM,
                    BRN_CODE,
                    GLACC_CODE,
                    CURR_CODE,
                    DEPT_CODE,
                    CLOSING_DATE,
                    CLOSING_BAL,
                    CLOSING_BAL_BC)
            VALUES (G2.TRAN_ENTITY_NUM,
                    G2.TRAN_ACING_BRN_CODE,
                    G2.TRAN_GLACC_CODE,
                    G2.TRAN_CURR_CODE,
                    G2.TRAN_DEPT_CODE,
                    G2.TRAN_DATE_OF_TRAN,
                    G2.TRAN_AMOUNT,
                    G2.TRAN_BC_AMOUNT)';

            EXECUTE IMMEDIATE W_SQL
                USING P_ASON_DATE;

            W_SQL := '';
        END IF;
    ELSIF P_EXC_FLAG = '2'
    THEN
        W_SQL :=
               '
    MERGE INTO GLDIVBAL G1
         USING (  SELECT TRAN_ENTITY_NUM,
                         TRAN_ACING_BRN_CODE,
                         TRAN_GLACC_CODE,
                         TRAN_CURR_CODE,
                         TRAN_DEPT_CODE,
                         TRAN_DATE_OF_TRAN,
                           NVL (
                               SUM (DECODE (TRAN_DB_CR_FLG, ''C'', TRAN_AMOUNT)),
                               0)
                         - NVL (
                               SUM (DECODE (TRAN_DB_CR_FLG, ''D'', TRAN_AMOUNT)),
                               0)    TRAN_AMOUNT,
                           NVL (
                               SUM (
                                   DECODE (TRAN_DB_CR_FLG,
                                           ''C'', TRAN_BASE_CURR_EQ_AMT)),
                               0)
                         - NVL (
                               SUM (
                                   DECODE (TRAN_DB_CR_FLG,
                                           ''D'', TRAN_BASE_CURR_EQ_AMT)),
                               0)    TRAN_BC_AMOUNT
                    FROM TRAN'
            || TO_CHAR (V_CBD, 'YYYY')
            || '
                   WHERE     TRAN_ENTITY_NUM = 1
                         AND (TRAN_AMOUNT > 0 OR TRAN_BASE_CURR_EQ_AMT > 0)
                         AND TRAN_AUTH_ON IS NOT NULL
                         AND TRAN_DEPT_CODE IS NOT NULL
                         AND TRAN_DATE_OF_TRAN = :P_ASON_DATE
                GROUP BY TRAN_ENTITY_NUM,
                         TRAN_ACING_BRN_CODE,
                         TRAN_GLACC_CODE,
                         TRAN_CURR_CODE,
                         TRAN_DEPT_CODE,
                         TRAN_DATE_OF_TRAN) G2
            ON (    G1.ENTITY_NUM = G2.TRAN_ENTITY_NUM
                AND G1.BRN_CODE = G2.TRAN_ACING_BRN_CODE
                AND G1.GLACC_CODE = G2.TRAN_GLACC_CODE
                AND G1.CURR_CODE = G2.TRAN_CURR_CODE
                AND G1.DEPT_CODE = G2.TRAN_DEPT_CODE
                AND G1.CLOSING_DATE = G2.TRAN_DATE_OF_TRAN)
    WHEN MATCHED
    THEN
        UPDATE SET
            G1.CLOSING_BAL = G2.TRAN_AMOUNT,
            G1.CLOSING_BAL_BC = G2.TRAN_BC_AMOUNT
    WHEN NOT MATCHED
    THEN
        INSERT     (ENTITY_NUM,
                    BRN_CODE,
                    GLACC_CODE,
                    CURR_CODE,
                    DEPT_CODE,
                    CLOSING_DATE,
                    CLOSING_BAL,
                    CLOSING_BAL_BC)
            VALUES (G2.TRAN_ENTITY_NUM,
                    G2.TRAN_ACING_BRN_CODE,
                    G2.TRAN_GLACC_CODE,
                    G2.TRAN_CURR_CODE,
                    G2.TRAN_DEPT_CODE,
                    G2.TRAN_DATE_OF_TRAN,
                    G2.TRAN_AMOUNT,
                    G2.TRAN_BC_AMOUNT)';

        EXECUTE IMMEDIATE W_SQL
            USING V_CBD;
    END IF;
EXCEPTION
    WHEN OTHERS
    THEN
        RAISE E_USEREXCEP;
END;