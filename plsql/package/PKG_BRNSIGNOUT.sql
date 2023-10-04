/*<TOAD_FILE_CHUNK>*/
CREATE OR REPLACE PACKAGE PKG_BRNSIGNOUT
IS
   PROCEDURE SP_BRNSIGNOUT (V_ENTITY_NUM   IN     NUMBER,
                            P_BRNCODE      IN     NUMBER,
                            P_CURR_DATE    IN     VARCHAR2,
                            P_LOGEDUSER    IN     VARCHAR2,
                            P_VAL_FLAG     IN     VARCHAR2,
                            P_ERR_STATUS      OUT VARCHAR2,
                            P_REPORT_SL       OUT NUMBER,
                            P_STATUS          OUT NUMBER,
                            P_GLB_TMP_SL      OUT NUMBER);
END;
/

/*<TOAD_FILE_CHUNK>*/
/* Formatted on 9/12/2023 11:50:14 AM (QP5 v5.388) */
CREATE OR REPLACE PACKAGE BODY PKG_BRNSIGNOUT
AS
    PROCEDURE SP_BRNSIGNOUT (V_ENTITY_NUM   IN     NUMBER,
                             P_BRNCODE      IN     NUMBER,
                             P_CURR_DATE    IN     VARCHAR2,
                             P_LOGEDUSER    IN     VARCHAR2,
                             P_VAL_FLAG     IN     VARCHAR2,
                             P_ERR_STATUS      OUT VARCHAR2,
                             P_REPORT_SL       OUT NUMBER,
                             P_STATUS          OUT NUMBER,
                             P_GLB_TMP_SL      OUT NUMBER)
    IS
        E_USEREXCEP          EXCEPTION;
        W_ERROR              VARCHAR2 (1300);
        W_MN_SOD_OVER_FLAG   VARCHAR2 (1);
        W_BRNSTATUS_STATUS   VARCHAR2 (1);
        W_SQL                VARCHAR2 (4300);
        W_VAL_FLAG           BOOLEAN;
        COU                  NUMBER (3);
        W_CLG_BATCH          VARCHAR2 (100);
        V_I                  NUMBER (3);
        W_STATUS             NUMBER (1);
        W_TMP_SERIAL         NUMBER;
        W_GLB_TMP_SL         NUMBER;
        V_DENOM_REQ          NUMBER (1);

        PROCEDURE INITPARA
        IS
        BEGIN
            W_ERROR := '';
            W_MN_SOD_OVER_FLAG := '';
            W_BRNSTATUS_STATUS := '';
            W_SQL := '';
            W_VAL_FLAG := FALSE;
            V_I := 0;
            COU := 0;
            W_CLG_BATCH := '';
            W_STATUS := 0;
            W_TMP_SERIAL := 0;
            W_GLB_TMP_SL := 0;
        END;

        PROCEDURE ASSIGN_GRID_VALUE (SRC_DET    VARCHAR2,
                                     REF_DET    VARCHAR2,
                                     MOD_NAME   VARCHAR2,
                                     SRC_KEY    VARCHAR2,
                                     CLASSI     VARCHAR2)
        IS
        BEGIN
            PKG_REPORT_XML.FINAL_REC.DELETE;
            PKG_REPORT_XML.FINAL_REC (
                NVL (PKG_REPORT_XML.FINAL_REC.COUNT, 0) + 1) :=
                V_I;
            PKG_REPORT_XML.FINAL_REC (PKG_REPORT_XML.FINAL_REC.COUNT + 1) :=
                SRC_DET;
            PKG_REPORT_XML.FINAL_REC (PKG_REPORT_XML.FINAL_REC.COUNT + 1) :=
                REF_DET;
            PKG_REPORT_XML.FINAL_REC (PKG_REPORT_XML.FINAL_REC.COUNT + 1) :=
                MOD_NAME;
            PKG_REPORT_XML.FINAL_REC (PKG_REPORT_XML.FINAL_REC.COUNT + 1) :=
                SRC_KEY;
            PKG_REPORT_XML.FINAL_REC (PKG_REPORT_XML.FINAL_REC.COUNT + 1) :=
                CLASSI;
            PKG_REPORT_XML.SP_SET_IND_VALUES (V_ENTITY_NUM,
                                              PKG_REPORT_XML.FINAL_REC);
            V_I := V_I + 1;
        END;

        PROCEDURE CHECK_LOGIN_USER
        IS
            COU_DTL       NUMBER;
            INS_CHQ_REQ   CHAR;
        BEGIN
            SELECT INS_SECURITY_CHK_REQD
              INTO INS_CHQ_REQ
              FROM INSTALL
             WHERE INS_ENTITY_NUM = V_ENTITY_NUM;

            IF (INS_CHQ_REQ = '1')
            THEN
                SELECT COUNT (1)
                  INTO COU_DTL
                  FROM SIGNINOUT, USERS
                 WHERE     SIGN_ENTITY_NUM = V_ENTITY_NUM
                       AND USER_ID = SIGN_USER_ID
                       AND SIGN_BRN_CODE = P_BRNCODE
                       AND SIGN_SESSION_STATUS = '1'
                       AND SIGN_EFF_DATE =
                           TO_DATE (P_CURR_DATE, 'DD-MM-YYYY')
                       AND SIGN_USER_ID <> P_LOGEDUSER
                       AND SIGN_IN_TIME =
                           (SELECT MAX (SIGN_IN_TIME)
                             FROM SIGNINOUT
                            WHERE     SIGN_ENTITY_NUM = V_ENTITY_NUM
                                  AND SIGN_BRN_CODE = P_BRNCODE
                                  AND SIGN_EFF_DATE =
                                      TO_DATE (P_CURR_DATE, 'DD-MM-YYYY')
                                  AND USER_ID = SIGN_USER_ID);

                IF (COU_DTL > 0)
                THEN
                    W_ERROR := 'SOME USERS LOGGED IN PLEASE TRY AGAIN';
                    RAISE E_USEREXCEP;
                END IF;
            END IF;
        END;

        PROCEDURE READMAINCONT
        IS
        BEGIN
            SELECT MN_SOD_OVER_FLAG
              INTO W_MN_SOD_OVER_FLAG
              FROM MAINCONT
             WHERE MN_ENTITY_NUM = V_ENTITY_NUM;

            IF (W_MN_SOD_OVER_FLAG <> '1')
            THEN
                W_ERROR := 'Start of Day not over';
                RAISE E_USEREXCEP;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                W_ERROR := 'Start of Day not over';
                RAISE E_USEREXCEP;
        END;

        PROCEDURE READBRNSTATUS
        IS
            W_FORCE_SIGN_OUT   NUMBER;
        BEGIN
            W_SQL := 'SELECT BRNSTATUS_STATUS  FROM BRNSTATUS';
            W_SQL :=
                   W_SQL
                || ' WHERE BRNSTATUS_ENTITY_NUM = '
                || V_ENTITY_NUM
                || ' AND  BRNSTATUS_BRN_CODE='
                || P_BRNCODE
                || ' AND ';
            W_SQL :=
                   W_SQL
                || 'BRNSTATUS_CURR_DATE=TO_DATE('
                || CHR (39)
                || P_CURR_DATE
                || CHR (39)
                || ','
                || CHR (39)
                || 'DD-MM-YYYY'
                || CHR (39)
                || ')';

            EXECUTE IMMEDIATE W_SQL
                INTO W_BRNSTATUS_STATUS;

            IF (W_BRNSTATUS_STATUS = 'O')
            THEN
                W_ERROR := 'Branch already Signed out';
                RAISE E_USEREXCEP;
            END IF;

            IF (W_BRNSTATUS_STATUS = 'F')
            THEN
                W_ERROR := 'Branch already Forced Signed out';
                RAISE E_USEREXCEP;
            END IF;

            W_FORCE_SIGN_OUT := 0;

            BEGIN
                SELECT BRNFSOUT_FORCE_SIGN_OUT
                  INTO W_FORCE_SIGN_OUT
                  FROM BRNFSIGNOUT
                 WHERE     BRNFSOUT_ENTITY_NUM = V_ENTITY_NUM
                       AND BRNFSOUT_BRN_CODE = P_BRNCODE
                       AND BRNFSOUT_CURR_DATE =
                           TO_DATE (P_CURR_DATE, 'DD-MM-YYYY');

                IF (W_FORCE_SIGN_OUT = 1)
                THEN
                    W_ERROR :=
                        'Branch Marked for Force Sign out, Cannot do Normal Sign out';
                    RAISE E_USEREXCEP;
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    W_ERROR := '';
            END;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                W_ERROR := 'Branch Sign in not done';
                RAISE E_USEREXCEP;
        END;

        PROCEDURE CHECK_BEFORE_UPDATE
        IS
            REC_COUNT   NUMBER DEFAULT 0;
            FINYEAR     NUMBER DEFAULT 0;
        BEGIN
            FINYEAR :=
                SP_GETFINYEAR (V_ENTITY_NUM,
                               TO_DATE (P_CURR_DATE, 'DD-MM-YYYY'));
            W_SQL :=
                   'SELECT COUNT(*) FROM   TRAN'
                || FINYEAR
                || ' WHERE TRAN_ENTITY_NUM = '
                || V_ENTITY_NUM
                || ' AND  TRAN_BRN_CODE ='
                || P_BRNCODE
                || '  AND TRAN_DATE_OF_TRAN>=
                TO_DATE('''
                || P_CURR_DATE
                || ''',''DD-MM-YYYY'') AND TRAN_AUTH_ON IS NULL AND (TRAN_AMOUNT <> 0 OR TRAN_BASE_CURR_EQ_AMT <> 0)
                 AND (NVL(TRAN_AC_CANCEL_AMT, 0) = 0 OR NVL(TRAN_BC_CANCEL_AMT, 0) = 0)';

            EXECUTE IMMEDIATE W_SQL
                INTO REC_COUNT;

            IF (REC_COUNT > 0)
            THEN
                ASSIGN_GRID_VALUE (
                    'Financial Transactions',
                    'Unauthorized Financial Transactions present',
                    'TRAN',
                    '',
                    'Exception');
            END IF;

            IF IS_TABLE_EXISTS ('TRAN' || (FINYEAR + 1)) = 1
            THEN
                W_SQL :=
                       'SELECT COUNT(*) FROM   TRAN'
                    || (FINYEAR + 1)
                    || ' WHERE TRAN_ENTITY_NUM = '
                    || V_ENTITY_NUM
                    || ' AND  TRAN_BRN_CODE ='
                    || P_BRNCODE
                    || '  AND TRAN_DATE_OF_TRAN>=
                    TO_DATE('''
                    || P_CURR_DATE
                    || ''',''DD-MM-YYYY'') AND TRAN_AUTH_ON IS NULL AND (TRAN_AMOUNT <> 0 OR TRAN_BASE_CURR_EQ_AMT <> 0)';

                EXECUTE IMMEDIATE W_SQL
                    INTO REC_COUNT;

                IF (REC_COUNT > 0)
                THEN
                    ASSIGN_GRID_VALUE (
                        'Financial Transactions',
                        'Unauthorized Financial Future Transactions present',
                        'TRAN',
                        '',
                        'Exception');
                END IF;
            END IF;

            REC_COUNT := 0;

            SELECT COUNT (1)
              INTO REC_COUNT
              FROM GOLDLOAN
             WHERE     GLN_ENTITY_NUM = V_ENTITY_NUM
                   AND GLN_BRN_CODE = P_BRNCODE
                   AND GLN_ENTRY_DATE = TO_DATE (P_CURR_DATE, 'DD-MM-YYYY')
                   AND GLN_AUTH_ON IS NULL
                   AND GLN_REJ_ON IS NULL;

            IF (REC_COUNT > 0)
            THEN
                ASSIGN_GRID_VALUE ('Gold Loan',
                                   'Gold Loan Authorization Pending',
                                   'LOAN',
                                   '',
                                   'Exception');
            END IF;

            REC_COUNT := 0;

            SELECT COUNT (1)
              INTO REC_COUNT
              FROM (SELECT DEPCLS_BRN_CODE,
                           DEPCLS_DEP_AC_NUM,
                           DEPCLS_CONT_NUM
                      FROM DEPCLS
                     WHERE     DEPCLS_CLOSURE_DATE =
                               TO_DATE (P_CURR_DATE, 'DD-MM-YYYY')
                           AND DEPCLS_ENTITY_NUM = V_ENTITY_NUM
                           AND DEPCLS_RENEW_TRF = 'R'
                           AND DEPCLS_BRN_CODE = P_BRNCODE
                           AND DEPCLS_AUTH_ON IS NOT NULL
                    MINUS
                    SELECT DEPCLS_BRN_CODE,
                           DEPCLS_DEP_AC_NUM,
                           DEPCLS_CONT_NUM
                      FROM DEPCLS
                           INNER JOIN PBDCONTRACT
                               ON (    DEPCLS_BRN_CODE = PBDCONT_BRN_CODE
                                   AND DEPCLS_DEP_AC_NUM = PBDCONT_DEP_AC_NUM
                                   AND PBDCONT_CONT_NUM > DEPCLS_CONT_NUM)
                     WHERE     DEPCLS_CLOSURE_DATE =
                               TO_DATE (P_CURR_DATE, 'DD-MM-YYYY')
                           AND DEPCLS_ENTITY_NUM = V_ENTITY_NUM
                           AND PBDCONT_ENTITY_NUM = V_ENTITY_NUM
                           AND DEPCLS_RENEW_TRF = 'R'
                           AND DEPCLS_BRN_CODE = P_BRNCODE
                           AND DEPCLS_AUTH_ON IS NOT NULL
                           AND PBDCONT_BRN_CODE = P_BRNCODE
                           AND PBDCONT_DEP_OPEN_DATE =
                               TO_DATE (P_CURR_DATE, 'DD-MM-YYYY')
                           AND PBDCONT_AUTH_ON IS NOT NULL);

            IF (REC_COUNT > 0)
            THEN
                ASSIGN_GRID_VALUE (
                    'Contract Opening Pending',
                    'Deposit renewed contract is pending to be opened',
                    'DEP',
                    '',
                    'Exception');
            END IF;

            REC_COUNT := 0;

            SELECT COUNT (1)
              INTO REC_COUNT
              FROM DDPOISSDTL, DDPOISS
             WHERE     DDPOISS_ENTITY_NUM = V_ENTITY_NUM
                   AND DDPOISSDTL_ENTITY_NUM = V_ENTITY_NUM
                   AND DDPOISSDTL_BRN_CODE = P_BRNCODE
                   AND DDPOISSDTL_ISSUE_DATE =
                       TO_DATE (P_CURR_DATE, 'DD-MM-YYYY')
                   AND DDPOISSDTL_BRN_CODE = DDPOISS_BRN_CODE
                   AND DDPOISSDTL_REMIT_CODE = DDPOISS_REMIT_CODE
                   AND DDPOISSDTL_ISSUE_DATE = DDPOISS_ISSUE_DATE
                   AND DDPOISSDTL_DAY_SL = DDPOISS_DAY_SL
                   AND DDPOISS_AUTH_ON IS NOT NULL
                   AND DDPOISSDTL_INST_NUM = 0;

            IF (REC_COUNT > 0)
            THEN
                ASSIGN_GRID_VALUE ('DD/PO',
                                   'DD/PO Printing to be done',
                                   'DD/PO',
                                   '',
                                   'Exception');
            END IF;

            REC_COUNT := 0;

            SELECT COUNT (*)
              INTO REC_COUNT
              FROM TBAAUTHQ, MPGM
             WHERE     TBAQ_ENTITY_NUM = V_ENTITY_NUM
                   AND TBAQ_DONE_BRN = P_BRNCODE
                   AND TBAQ_PGM_ID = MPGM_ID
                   AND MPGM_UNAUTH_NEXT_DAY <> '1'
                   AND MPGM_REJ_ALL_DURING_EOD <> '1';

            IF (REC_COUNT > 0)
            THEN
                ASSIGN_GRID_VALUE (
                    'Non Financial Transactions',
                    'Unauthorized Non Financial details present',
                    'AUTH',
                    '',
                    'Warning');
                W_STATUS := 2;
            END IF;

            REC_COUNT := 0;
        END;

        PROCEDURE UPDATEBRNSTATUS
        IS
        BEGIN
            W_SQL :=
                   'UPDATE BRNSTATUS SET BRNSTATUS_SIGN_OUT= TO_DATE('
                || CHR (39)
                || P_CURR_DATE
                || ' '
                || PKG_PB_GLOBAL.FN_GET_CURR_TIME_WITH_SECONDS (V_ENTITY_NUM)
                || CHR (39)
                || ','
                || CHR (39)
                || 'DD-MM-YYYY HH24:MI:SS'
                || CHR (39)
                || '),BRNSTATUS_SIGNOUT_USER_ID='
                || CHR (39)
                || P_LOGEDUSER
                || CHR (39)
                || ',BRNSTATUS_STATUS='
                || CHR (39)
                || 'O'
                || CHR (39)
                || ' WHERE BRNSTATUS_ENTITY_NUM = '
                || V_ENTITY_NUM
                || ' AND  BRNSTATUS_BRN_CODE='
                || P_BRNCODE
                || ' AND BRNSTATUS_CURR_DATE=TO_DATE('
                || CHR (39)
                || P_CURR_DATE
                || CHR (39)
                || ','
                || CHR (39)
                || 'DD-MM-YYYY'
                || CHR (39)
                || ')';

            EXECUTE IMMEDIATE W_SQL;

            W_STATUS := 1;
        EXCEPTION
            WHEN OTHERS
            THEN
                IF TRIM (W_ERROR) IS NULL
                THEN
                    W_ERROR := 'Error in UPDATEBRNSTATUS';
                END IF;

                RAISE E_USEREXCEP;
        END;

        PROCEDURE UPDATE_TELBAL
        IS
        BEGIN
            V_DENOM_REQ := 0;

            SELECT DECODE (NVL (C.CASHPARM_DENOM_REQD_CUSTTRN, ' '),
                           '1', 1,
                           0)
              INTO V_DENOM_REQ
              FROM CASHPARM C
             WHERE     CASHPARM_ENTITY_NUM = V_ENTITY_NUM
                   AND C.CASHPARM_BRN_CODE = P_BRNCODE;

            IF (V_DENOM_REQ = 0)
            THEN
                BEGIN
                    W_SQL :=
                           'UPDATE TELBAL SET TELBAL_GOOD_BALANCE = 0,TELBAL_SOILED_BALANCE = 0,TELBAL_CUT_BALANCE = 0,TELBAL_TBA_GOOD = 0,TELBAL_TBA_SOILED = 0,TELBAL_TBA_CUT = 0
               WHERE TELBAL_ENTITY_NUM = '
                        || V_ENTITY_NUM
                        || ' AND  TELBAL_BRN_CODE='
                        || P_BRNCODE;

                    EXECUTE IMMEDIATE W_SQL;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        IF TRIM (W_ERROR) IS NULL
                        THEN
                            W_ERROR := 'Error in UPDATE_TELBAL';
                        END IF;

                        RAISE E_USEREXCEP;
                END;
            END IF;
        END;

        PROCEDURE CHECKCASHGLBAL_VAULTBAL
        IS
        BEGIN
            CHECK_CASHGLBAL_VAULTBAL (V_ENTITY_NUM,
                                      P_BRNCODE,
                                      TO_DATE (P_CURR_DATE, 'DD-MM-YYYY'),
                                      W_ERROR);

            IF TRIM (W_ERROR) IS NOT NULL
            THEN
                ASSIGN_GRID_VALUE ('Cash GL Balance Mismatch.',
                                   W_ERROR,
                                   'CASH',
                                   '',
                                   'Exception');
            END IF;
        END;

        PROCEDURE CHECKCASHCLOSED
        IS
        BEGIN
            SELECT COUNT (*)
              INTO COU
              FROM CASHCTL
             WHERE     CASHCTL_ENTITY_NUM = V_ENTITY_NUM
                   AND CASHCTL_BRN_CODE = P_BRNCODE
                   AND CASHCTL_DATE = TO_DATE (P_CURR_DATE, 'DD-MM-YYYY')
                   AND CASHCTL_STATUS <> 'C';

            IF (COU <> 0)
            THEN
                ASSIGN_GRID_VALUE ('Cash Closing',
                                   'Cash Closing not done',
                                   'CASH',
                                   '',
                                   'Exception');
            END IF;
        END;

        PROCEDURE CHECKOUTWARDCLOSED
        IS
        BEGIN
            W_CLG_BATCH := '';

            FOR IDX_REC_DEP
                IN (SELECT OCLGBAT_CLG_BATCH
                     FROM OCLGBATCH
                    WHERE     OCLGBAT_ENTITY_NUM = V_ENTITY_NUM
                          AND OCLGBAT_BRN_CODE = P_BRNCODE
                          AND OCLGBAT_CLG_DATE =
                              TO_DATE (P_CURR_DATE, 'DD-MM-YYYY')
                          AND OCLGBAT_STATUS <> 'C')
            LOOP
                W_CLG_BATCH :=
                    W_CLG_BATCH || ',' || IDX_REC_DEP.OCLGBAT_CLG_BATCH;
            END LOOP;

            IF (TRIM (W_CLG_BATCH) IS NOT NULL)
            THEN
                ASSIGN_GRID_VALUE (
                    'Outward Clearing Closure',
                    'Outward Clearing Batch' || W_CLG_BATCH || ' Not Closed',
                    'OCLG',
                    '',
                    'Exception');
            END IF;
        END;

        --Added by sabuj for Interest Suspense GL Mismatch check
        PROCEDURE SP_INTSUSGLPM
        IS
            W_ERROR_MSG                      VARCHAR2 (500);
            P_GL_BAL_AC                      NUMBER (18, 2):=0;
            P_GL_BAL_BC                      NUMBER (18, 2):=0;
            E_USEREXCEP                      EXCEPTION;
            P_BGL_BAL_AC                     NUMBER (18, 2):=0;
            P_BGL_BAL_BC                     NUMBER (18, 2):=0;
            V_INTSUSGL_GL_CODE               INTSUSGL.INTSUSGL_GL_CODE%TYPE;
            V_INTSUSGL_GL_CODE_BLOCK         INTSUSGL.INTSUSGL_GL_CODE_BLOCK%TYPE;
            V_INTSUSGL_GL_MISMATCH_BLOCKGL   INTSUSGL.INTSUSGL_GL_MISMATCH_BLOCKGL%TYPE;
            V_INTSUSGL_GL_MISMATCH           INTSUSGL.INTSUSGL_GL_MISMATCH%TYPE;
            V_SUSP_BAL                       LNSUSPBAL.LNSUSPBAL_SUSP_BAL%TYPE;
        BEGIN
            BEGIN
                SELECT INTSUSGL_GL_CODE,
                       INTSUSGL_GL_CODE_BLOCK,
                       INTSUSGL_GL_MISMATCH_BLOCKGL,
                       INTSUSGL_GL_MISMATCH
                  INTO V_INTSUSGL_GL_CODE,
                       V_INTSUSGL_GL_CODE_BLOCK,
                       V_INTSUSGL_GL_MISMATCH_BLOCKGL,
                       V_INTSUSGL_GL_MISMATCH
                  FROM INTSUSGL
                 WHERE INTSUSGL_EFF_DATE =
                       (SELECT MAX (INTSUSGL_EFF_DATE)
                         FROM INTSUSGL
                        WHERE INTSUSGL_EFF_DATE <=
                              TO_DATE (P_CURR_DATE, 'DD-MM-YYYY'));
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    V_INTSUSGL_GL_CODE := 0;
                    V_INTSUSGL_GL_CODE_BLOCK := 0;
                    V_INTSUSGL_GL_MISMATCH_BLOCKGL := NULL;
                    V_INTSUSGL_GL_MISMATCH := NULL;
                WHEN TOO_MANY_ROWS
                THEN
                    W_ERROR := 'Error in face INTSUSGL';
            END;

            IF V_INTSUSGL_GL_MISMATCH = '1'
            THEN
                SELECT NVL (SUM (LNSUSPBAL_SUSP_BAL), 0)
                  INTO V_SUSP_BAL
                  FROM ACNTS, LNSUSPBAL
                 WHERE     ACNTS_ENTITY_NUM = V_ENTITY_NUM
                       AND LNSUSPBAL_ENTITY_NUM = V_ENTITY_NUM
                       AND ACNTS_INTERNAL_ACNUM = LNSUSPBAL_ACNT_NUM
                       AND ACNTS_INTERNAL_ACNUM NOT IN
                               (SELECT LNWRTOFF_ACNT_NUM
                                  FROM LNWRTOFF
                                 WHERE LNWRTOFF_ENTITY_NUM = V_ENTITY_NUM)
                       AND ACNTS_BRN_CODE = P_BRNCODE;

                IF V_INTSUSGL_GL_CODE <> 0
                THEN
                    GET_ASON_GLBAL (V_ENTITY_NUM,
                                    P_BRNCODE,
                                    V_INTSUSGL_GL_CODE,
                                    NULL,
                                    TO_DATE (P_CURR_DATE, 'DD-MM-YYYY'),
                                    TO_DATE (P_CURR_DATE, 'DD-MM-YYYY'),
                                    P_GL_BAL_AC,
                                    P_GL_BAL_BC,
                                    W_ERROR_MSG,
                                    NULL,
                                    NULL,
                                    NULL);
                END IF;

                IF V_INTSUSGL_GL_CODE_BLOCK <> 0
                THEN
                    GET_ASON_GLBAL (V_ENTITY_NUM,
                                    P_BRNCODE,
                                    V_INTSUSGL_GL_CODE_BLOCK,
                                    NULL,
                                    TO_DATE (P_CURR_DATE, 'DD-MM-YYYY'),
                                    TO_DATE (P_CURR_DATE, 'DD-MM-YYYY'),
                                    P_BGL_BAL_AC,
                                    P_BGL_BAL_BC,
                                    W_ERROR_MSG,
                                    NULL,
                                    NULL,
                                    NULL);
                END IF;

                IF P_BGL_BAL_BC = 0
                THEN
                    IF ABS (V_SUSP_BAL) <> ABS (P_GL_BAL_BC)
                    THEN
                        ASSIGN_GRID_VALUE (
                            'Interest Suspense GL Mismatch',
                            'Interest Suspense GL Balance Mismatch with Account Level Interest Suspense Balance',
                            'ADV',
                            '',
                            'Exception');
                    ELSIF P_BGL_BAL_BC <> 0
                    THEN
                        IF ABS (V_SUSP_BAL) <> ABS (P_GL_BAL_BC)
                        THEN
                            ASSIGN_GRID_VALUE (
                                'Interest Suspense GL Mismatch',
                                'Interest Suspense GL Balance Mismatch with Account Level Interest Suspense Balance',
                                'ADV',
                                '',
                                'Warning');
                        END IF;
                    END IF;
                END IF;
            END IF;
        END;

        PROCEDURE CHECKINWARDCLOSD
        IS
        BEGIN
            W_CLG_BATCH := '';

            FOR IDX_REC_DEP
                IN (SELECT ICLGBAT_CLG_BATCH
                     FROM ICLGBATCH
                    WHERE     ICLGBAT_ENTITY_NUM = V_ENTITY_NUM
                          AND ICLGBAT_BRN_CODE = P_BRNCODE
                          AND ICLGBAT_CLG_DATE =
                              TO_DATE (P_CURR_DATE, 'DD-MM-YYYY')
                          AND ICLGBAT_STATUS <> 'C')
            LOOP
                W_CLG_BATCH :=
                    W_CLG_BATCH || ',' || IDX_REC_DEP.ICLGBAT_CLG_BATCH;
            END LOOP;

            IF (TRIM (W_CLG_BATCH) IS NOT NULL)
            THEN
                ASSIGN_GRID_VALUE (
                    'INWARD CLEARING CLOSURE',
                    'INWARD CLEARING BATCH' || W_CLG_BATCH || ' NOT CLOSED',
                    'ICLG',
                    '',
                    'EXCEPTION');
            END IF;
        END;

        PROCEDURE CHECKOUTWARDCLOSEDTRAN
        IS
        BEGIN
            W_CLG_BATCH := '';

            FOR IDX_REC_DEP
                IN (SELECT OCLGBAT_CLG_BATCH, OCLGBAT_STATUS
                     FROM OCLGBATCH
                    WHERE     OCLGBAT_ENTITY_NUM = V_ENTITY_NUM
                          AND OCLGBAT_BRN_CODE = P_BRNCODE
                          AND OCLGBAT_POST_DATE =
                              TO_DATE (P_CURR_DATE, 'DD-MM-YYYY')
                          AND OCLGBAT_NUM_INSTRUMENTS > 0
                          AND TRIM (POST_TRAN_DATE) IS NULL)
            LOOP
                W_CLG_BATCH :=
                    W_CLG_BATCH || ',' || IDX_REC_DEP.OCLGBAT_CLG_BATCH;
            END LOOP;

            IF (TRIM (W_CLG_BATCH) IS NOT NULL)
            THEN
                ASSIGN_GRID_VALUE (
                    'OUTWARD CLEARING POSTING',
                    'OUTWARD CLEARING BATCH' || W_CLG_BATCH || ' NOT POSTED',
                    'OCLG',
                    '',
                    'EXCEPTION');
            END IF;
        END;

        PROCEDURE FINANCIALTRAN
        IS
            W_BAT_INFO   VARCHAR2 (100);
        BEGIN
            FOR IDX_REC_DEP
                IN (SELECT BOPAUTHQ_TRAN_BRN_CODE,
                           TO_CHAR (BOPAUTHQ_TRAN_DATE_OF_TRAN, 'DD-MM-YYYY')
                               BOPAUTHQ_TRAN_DATE_OF_TRAN,
                           BOPAUTHQ_TRAN_BATCH_NUMBER,
                           BOPAUTHQ_MODULE_CODE,
                           BOPAUTHQ_SOURCE_KEY_VALUE,
                           BOPAUTHQ_TRANBAT_NARR1
                     FROM BOPAUTHQ
                    WHERE     BOPAUTHQ_ENTITY_NUM = V_ENTITY_NUM
                          AND BOPAUTHQ_TRAN_BRN_CODE = P_BRNCODE
                          AND BOPAUTHQ_ENTRY_STATUS <> 'A'
                          AND BOPAUTHQ_ENTRY_STATUS <> 'R'
                          AND BOPAUTHQ_TRAN_DATE_OF_TRAN =
                              TO_DATE (P_CURR_DATE, 'DD-MM-YYYY'))
            LOOP
                IF (TRIM (IDX_REC_DEP.BOPAUTHQ_TRAN_BRN_CODE) = 0)
                THEN
                    W_BAT_INFO := '';
                ELSE
                    W_BAT_INFO :=
                           IDX_REC_DEP.BOPAUTHQ_TRAN_BRN_CODE
                        || '/'
                        || IDX_REC_DEP.BOPAUTHQ_TRAN_DATE_OF_TRAN
                        || '/'
                        || IDX_REC_DEP.BOPAUTHQ_TRAN_BATCH_NUMBER;
                END IF;

                ASSIGN_GRID_VALUE (W_BAT_INFO,
                                   'FINANCIAL TRANACTION',
                                   IDX_REC_DEP.BOPAUTHQ_MODULE_CODE,
                                   IDX_REC_DEP.BOPAUTHQ_SOURCE_KEY_VALUE,
                                   'WARNING');
            END LOOP;
        END;

        PROCEDURE DDPODUPLICATE
        IS
            W_BAT_INFO   VARCHAR2 (100);
        BEGIN
            FOR IDX_REC_DEP
                IN (SELECT DDPODUPISS_REMIT_CODE,
                           DDPODUPISS_DAY_SL,
                           POST_TRAN_BRN,
                           TO_CHAR (POST_TRAN_DATE, 'DD-MM-YYYY')
                               POST_TRAN_DATE,
                           POST_TRAN_BATCH_NUM
                     FROM DDPODUPISS
                    WHERE     DDPODUPISS_ENTITY_NUM = V_ENTITY_NUM
                          AND DDPODUPISS_BRN_CODE = P_BRNCODE
                          AND DDPODUPISS_DUPISS_DATE =
                              TO_DATE (P_CURR_DATE, 'DD-MM-YYYY')
                          AND DDPODUPISS_REJ_ON IS NULL
                          AND DDPODUPISS_AUTH_ON IS NULL)
            LOOP
                IF (TRIM (IDX_REC_DEP.POST_TRAN_BRN) = 0)
                THEN
                    W_BAT_INFO := 'DD/PO AUTHORIZATION';
                ELSE
                    W_BAT_INFO :=
                           IDX_REC_DEP.POST_TRAN_BRN
                        || '/'
                        || IDX_REC_DEP.POST_TRAN_DATE
                        || '/'
                        || IDX_REC_DEP.POST_TRAN_BATCH_NUM;
                END IF;

                ASSIGN_GRID_VALUE (
                    W_BAT_INFO,
                    'DD/PO DUPLICATE',
                    'DDPO',
                       IDX_REC_DEP.DDPODUPISS_REMIT_CODE
                    || '|'
                    || IDX_REC_DEP.DDPODUPISS_DAY_SL,
                    'WARNING');
            END LOOP;
        END;

        PROCEDURE DDPOREVALID
        IS
            W_BAT_INFO   VARCHAR2 (100);
        BEGIN
            FOR IDX_REC_DEP
                IN (SELECT DDPOREVALID_REMIT_CODE,
                           DDPOREVALID_DAY_SL,
                           POST_TRAN_BRN,
                           TO_CHAR (POST_TRAN_DATE, 'DD-MM-YYYY')
                               POST_TRAN_DATE,
                           POST_TRAN_BATCH_NUM
                     FROM DDPOREVALID
                    WHERE     DDPOREVALID_ENTITY_NUM = V_ENTITY_NUM
                          AND DDPOREVALID_BRN_CODE = P_BRNCODE
                          AND DDPOREVALID_REVALID_DATE =
                              TO_DATE (P_CURR_DATE, 'DD-MM-YYYY')
                          AND DDPOREVALID_REJ_ON IS NULL
                          AND DDPOREVALID_AUTH_ON IS NULL)
            LOOP
                IF (TRIM (IDX_REC_DEP.POST_TRAN_BRN) = 0)
                THEN
                    W_BAT_INFO := 'DD/PO AUTHORIZATION';
                ELSE
                    W_BAT_INFO :=
                           IDX_REC_DEP.POST_TRAN_BRN
                        || '/'
                        || IDX_REC_DEP.POST_TRAN_DATE
                        || '/'
                        || IDX_REC_DEP.POST_TRAN_BATCH_NUM;
                END IF;

                ASSIGN_GRID_VALUE (
                    W_BAT_INFO,
                    'DD/PO REVALIDATION',
                    'DDPO',
                       IDX_REC_DEP.DDPOREVALID_REMIT_CODE
                    || '|'
                    || IDX_REC_DEP.DDPOREVALID_DAY_SL,
                    'WARNING');
            END LOOP;
        END;

        PROCEDURE DDPOSTOP
        IS
            W_BAT_INFO   VARCHAR2 (100);
        BEGIN
            FOR IDX_REC_DEP
                IN (SELECT TO_CHAR (STOPINSREG_ENTRY_DATE, 'DD-MM-YYYY')
                               STOPINSREG_ENTRY_DATE,
                           STOPINSREG_DAY_SL,
                           POST_TRAN_BRN,
                           TO_CHAR (POST_TRAN_DATE, 'DD-MM-YYYY')
                               POST_TRAN_DATE,
                           POST_TRAN_BATCH_NUM
                     FROM STOPINSREG
                    WHERE     STOPINSREG_ENTITY_NUM = V_ENTITY_NUM
                          AND STOPINSREG_BRN_CODE = P_BRNCODE
                          AND STOPINSREG_ENTRY_DATE =
                              TO_DATE (P_CURR_DATE, 'DD-MM-YYYY')
                          AND STOPINSREG_AUTH_ON IS NULL
                          AND STOPINSREG_REJ_ON IS NULL)
            LOOP
                IF (TRIM (IDX_REC_DEP.POST_TRAN_BRN) = 0)
                THEN
                    W_BAT_INFO := 'DD/PO AUTHORIZATION';
                ELSE
                    W_BAT_INFO :=
                           IDX_REC_DEP.POST_TRAN_BRN
                        || '/'
                        || IDX_REC_DEP.POST_TRAN_DATE
                        || '/'
                        || IDX_REC_DEP.POST_TRAN_BATCH_NUM;
                END IF;

                ASSIGN_GRID_VALUE (
                    W_BAT_INFO,
                    'DD/PO STOP PAYMENT',
                    'DDPO',
                       IDX_REC_DEP.STOPINSREG_ENTRY_DATE
                    || '|'
                    || IDX_REC_DEP.STOPINSREG_DAY_SL,
                    'WARNING');
            END LOOP;
        END;

        PROCEDURE DDPORESPONDINGONUS
        IS
            FINYEAR     NUMBER DEFAULT 0;
            REC_COUNT   NUMBER DEFAULT 0;
        BEGIN
            FINYEAR :=
                SP_GETFINYEAR (V_ENTITY_NUM,
                               TO_DATE (P_CURR_DATE, 'DD-MM-YYYY'));
            W_SQL :=
                   'SELECT COUNT(*) AS REC_COUNT FROM   TRAN'
                || FINYEAR
                || ' WHERE TRAN_ENTITY_NUM = '
                || V_ENTITY_NUM
                || ' AND TRAN_AUTH_ON IS NOT NULL
       AND TRAN_DATE_OF_TRAN = TO_DATE('
                || CHR (39)
                || P_CURR_DATE
                || CHR (39)
                || ','
                || CHR (39)
                || 'DD-MM-YYYY'
                || CHR (39)
                || ')
       AND (TRAN_ORIG_RESP = ''O'' OR TRAN_ORIG_RESP = ''R'')
       AND TRAN_AMOUNT <> 0 AND TRAN_IBR_BRN_CODE = '
                || P_BRNCODE
                || '
       AND TRAN_BRN_CODE IN
              (SELECT MBRN_CODE
                 FROM MBRN M
                WHERE M.MBRN_CODE NOT IN (SELECT BRNNC_BRN_CODE FROM BRNNC))
       AND TRAN_ORIG_RESP = ''O''
        AND TRAN_BATCH_NUMBER    IN (SELECT IBRADVICES_TRAN_BATCH_NUM FROM IBRADVICES  WHERE
                            IBRADVICES_ADVICE_DATE = TRAN_DATE_OF_TRAN
                            AND IBRADVICES_TRAN_BATCH_SL=TRAN_BATCH_SL_NUM
                            AND IBRADVICES_TRAN_BATCH_NUM=TRAN_BATCH_NUMBER
                            AND IBRADVICES_CONTRA_BRN_CODE='
                || P_BRNCODE
                || '
                            AND IBRADVICES_RESP_IN_BATCH_NUM=0) ';

            EXECUTE IMMEDIATE W_SQL
                INTO REC_COUNT;

            IF (REC_COUNT > 0)
            THEN
                ASSIGN_GRID_VALUE (
                    'ADVICES RESPONDING ON US',
                    'ADVICES PRESENT IN THE SYSTEM THAT ARE YET TO BE RESPONDED',
                    'CM',
                    'QIBTRNBROWSER',
                    'WARNING');
            END IF;
        END;

        PROCEDURE DDPOPRINTING
        IS
            W_BAT_INFO   VARCHAR2 (100);
        BEGIN
            FOR IDX_REC_DEP
                IN (SELECT DDPOISSDTL_REMIT_CODE,
                           DDPOISSDTL_ISSUE_DATE,
                           DDPOISSDTL_DAY_SL,
                           POST_TRAN_BRN,
                           TO_CHAR (POST_TRAN_DATE, 'DD-MM-YYYY')
                               POST_TRAN_DATE,
                           POST_TRAN_BATCH_NUM
                     FROM DDPOISSDTL, DDPOISS
                    WHERE     DDPOISS_ENTITY_NUM = V_ENTITY_NUM
                          AND DDPOISSDTL_ENTITY_NUM = V_ENTITY_NUM
                          AND DDPOISSDTL_BRN_CODE = P_BRNCODE
                          AND DDPOISSDTL_ISSUE_DATE =
                              TO_DATE (P_CURR_DATE, 'DD-MM-YYYY')
                          AND DDPOISSDTL_BRN_CODE = DDPOISS_BRN_CODE
                          AND DDPOISSDTL_REMIT_CODE = DDPOISS_REMIT_CODE
                          AND DDPOISSDTL_ISSUE_DATE = DDPOISS_ISSUE_DATE
                          AND DDPOISSDTL_DAY_SL = DDPOISS_DAY_SL
                          AND DDPOISS_AUTH_ON IS NOT NULL
                          AND DDPOISSDTL_INST_NUM = 0)
            LOOP
                IF (TRIM (IDX_REC_DEP.POST_TRAN_BRN) = 0)
                THEN
                    W_BAT_INFO := ' ';
                ELSE
                    W_BAT_INFO :=
                           IDX_REC_DEP.POST_TRAN_BRN
                        || '/'
                        || IDX_REC_DEP.POST_TRAN_DATE
                        || '/'
                        || IDX_REC_DEP.POST_TRAN_BATCH_NUM;
                END IF;

                ASSIGN_GRID_VALUE (
                    W_BAT_INFO,
                    'DD/PO PRINTING',
                    'DDPO',
                       IDX_REC_DEP.DDPOISSDTL_REMIT_CODE
                    || '|'
                    || IDX_REC_DEP.DDPOISSDTL_ISSUE_DATE
                    || '|'
                    || IDX_REC_DEP.DDPOISSDTL_DAY_SL,
                    'EXCEPTION');
            END LOOP;
        END;

        PROCEDURE ACNTCLOSURE
        IS
            W_BAT_INFO   VARCHAR2 (100);
        BEGIN
            FOR IDX_REC_DEP
                IN (SELECT FACNO (V_ENTITY_NUM, ACNTCLS_INTERNAL_ACNUM)
                               ACNTCLS_INTERNAL_ACNUM,
                           POST_TRAN_BRN,
                           TO_CHAR (POST_TRAN_DATE, 'DD-MM-YYYY')
                               POST_TRAN_DATE,
                           POST_TRAN_BATCH_NUM
                     FROM ACNTCLS
                    WHERE     ACNTCLS_ENTITY_NUM = V_ENTITY_NUM
                          AND ACNTCLS_BRN_CODE = P_BRNCODE
                          AND ACNTCLS_AUTH_ON IS NULL
                          AND ACNTCLS_REJ_ON IS NULL)
            LOOP
                IF (TRIM (IDX_REC_DEP.POST_TRAN_BRN) = 0)
                THEN
                    W_BAT_INFO := ' ';
                ELSE
                    W_BAT_INFO :=
                           IDX_REC_DEP.POST_TRAN_BRN
                        || '/'
                        || IDX_REC_DEP.POST_TRAN_DATE
                        || '/'
                        || IDX_REC_DEP.POST_TRAN_BATCH_NUM;
                END IF;

                ASSIGN_GRID_VALUE (W_BAT_INFO,
                                   'ACCOUNT CLOSURE',
                                   'CM',
                                   IDX_REC_DEP.ACNTCLS_INTERNAL_ACNUM,
                                   'WARNING');
            END LOOP;
        END;

        PROCEDURE READ_OCLGQ
        IS
            ROW_COUNT   NUMBER;
        BEGIN
            SELECT COUNT (1)
              INTO ROW_COUNT
              FROM OCLGQ
             WHERE     OCLGQ_ENTITY_NUM = V_ENTITY_NUM
                   AND OCLGQ_BRN_CODE = P_BRNCODE
                   AND OCLGQ_REGULN_DATE =
                       TO_DATE (P_CURR_DATE, 'DD-MM-YYYY')
                   AND OCLGQ_TRAN_DATE IS NOT NULL;

            IF (ROW_COUNT > 0)
            THEN
                ASSIGN_GRID_VALUE ('OUTWARD CLEARING',
                                   'REGULARIZATION NOT DONE',
                                   'OCLG',
                                   ' ',
                                   'EXCEPTION');
            END IF;
        END;

        PROCEDURE READ_CBISSQ
        IS
            ROW_COUNT   NUMBER;
        BEGIN
            SELECT COUNT (1)
              INTO ROW_COUNT
              FROM CBISSQ
             WHERE     CBISSQ_ENTITY_NUM = V_ENTITY_NUM
                   AND CBISSQ_BRN_CODE = P_BRNCODE
                   AND CBISSQ_ISSUE_DATE <=
                       TO_DATE (P_CURR_DATE, 'DD-MM-YYYY')
                   AND CBISSQ_ISSUE_DATE IS NOT NULL;

            IF (ROW_COUNT > 0)
            THEN
                ASSIGN_GRID_VALUE ('CHEQUE BOOK ISSUE',
                                   'AUTHORIZATION PENDING',
                                   'CHQBK',
                                   ' ',
                                   'WARNING');
            END IF;
        END;

        PROCEDURE UPDATEF12
        IS
            ROW_COUNT   NUMBER;
        BEGIN
            SELECT   LAST_DAY (
                         PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (V_ENTITY_NUM))
                   - TO_DATE (P_CURR_DATE, 'DD-MM-YYYY')
              INTO ROW_COUNT
              FROM DUAL;

            IF ROW_COUNT <> 0
            THEN
                BEGIN
                    SP_STATEMENT_OF_AFFAIRS_F12 (
                        P_BRNCODE,
                        TO_DATE (P_CURR_DATE, 'DD-MM-YYYY'),
                        W_ERROR);
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        IF TRIM (W_ERROR) IS NULL
                        THEN
                            W_ERROR :=
                                   'ERROR IN SP_STATEMENT_OF_AFFAIRS_F12 '
                                || SQLERRM;
                        END IF;
                END;
            END IF;
        END;

        PROCEDURE UPDATEF42
        IS
            ROW_COUNT   NUMBER;
        BEGIN
            SELECT   LAST_DAY (
                         PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (V_ENTITY_NUM))
                   - TO_DATE (P_CURR_DATE, 'DD-MM-YYYY')
              INTO ROW_COUNT
              FROM DUAL;

            IF ROW_COUNT <> 0
            THEN
                BEGIN
                    SP_INCOMEEXPENSE (P_BRNCODE,
                                      TO_DATE (P_CURR_DATE, 'DD-MM-YYYY'),
                                      W_ERROR);
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        IF TRIM (W_ERROR) IS NULL
                        THEN
                            W_ERROR :=
                                'ERROR IN SP_INCOMEEXPENSE ' || SQLERRM;
                        END IF;
                END;
            END IF;
        END;

        PROCEDURE CHECKRPSCLOSED
        IS
            REM_COUNT   NUMBER;
        BEGIN
            SELECT COUNT (*)     R_COUNT
              INTO REM_COUNT
              FROM RMS_RECORDS R
             WHERE     LPAD (R.ACCOUNTINGBRANCH, 5, '0') =
                       LPAD (P_BRNCODE, 5, '0')
                   AND R.CHANNEL_TYPE = 'EFT2'
                   AND R.PROCESS_STATUS <> 'REJECT'
                   AND (R.STATUS <> 'BATCH_AUTHORIZED' OR R.STATUS IS NULL);

            IF (REM_COUNT > 0)
            THEN
                ASSIGN_GRID_VALUE ('REMITENCE CLOSURE',
                                   'SOME REMITENCE MESSAGE IS STILL PENDING',
                                   'RPS',
                                   '',
                                   'EXCEPTION');
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                W_ERROR := 'ERROR IN CHECKRPSCLOSED ' || SQLERRM;
        END;

        PROCEDURE READ_MINTOMAJ
        IS
            ROW_COUNT   NUMBER;
        BEGIN
            SELECT COUNT (1)
              INTO ROW_COUNT
              FROM IACLINK, MINMAJSTAT
             WHERE     IACLINK_ENTITY_NUM = V_ENTITY_NUM
                   AND MINMAJSTAT_ENTITY_NUM = V_ENTITY_NUM
                   AND IACLINK_BRN_CODE = P_BRNCODE
                   AND MINMAJSTAT_INTERNAL_ACNUM = IACLINK_INTERNAL_ACNUM
                   AND MINMAJSTAT_MAJOR_DATE =
                       TO_DATE (P_CURR_DATE, 'DD-MM-YYYY');

            IF (ROW_COUNT > 0)
            THEN
                ASSIGN_GRID_VALUE ('MAJOR FROM MINOR',
                                   'SOME ACCOUNTS BECAME MAJOR TODAY',
                                   'CM',
                                   ' ',
                                   'WARNING');
            END IF;
        END;

        PROCEDURE VALIDATE
        IS
        BEGIN
            PKG_REPORT_XML.SP_INIT_VARIABLES (V_ENTITY_NUM);
            PKG_REPORT_XML.V_COLUMN_COUNT := 6;
            V_I := 1;
            W_TMP_SERIAL := PKG_REPORT_XML.V_REPORT_SL;
            CHECKCASHGLBAL_VAULTBAL;
            CHECKCASHCLOSED;
            CHECKOUTWARDCLOSED;
            CHECKOUTWARDCLOSEDTRAN;
            CHECKINWARDCLOSD;
            CHECK_BEFORE_UPDATE;
            -- FINANCIALTRAN;
            DDPORESPONDINGONUS;
            DDPOPRINTING;
            DDPODUPLICATE;
            DDPOREVALID;
            DDPOSTOP;
            ACNTCLOSURE;
            READ_OCLGQ;
            READ_CBISSQ;
            --UPDATEF12;
            --UPDATEF42;
            CHECKRPSCLOSED;
            READ_MINTOMAJ;
            SP_INTSUSGLPM;
        END;
    BEGIN
        PKG_ENTITY.SP_SET_ENTITY_CODE (V_ENTITY_NUM);

        BEGIN
            INITPARA;

            IF (PKG_GLOBAL.GET_ACQUIRE_LOCK (V_ENTITY_NUM,
                                             'BRN' || P_BRNCODE))
            THEN
                READMAINCONT;

                IF (TRIM (P_VAL_FLAG) IS NOT NULL)
                THEN
                    IF (TRIM (P_VAL_FLAG) = 'TRUE')
                    THEN
                        W_VAL_FLAG := TRUE;
                    ELSE
                        W_VAL_FLAG := FALSE;
                    END IF;
                END IF;

                IF (TRIM (W_ERROR) IS NULL)
                THEN
                    READBRNSTATUS;
                END IF;

                IF (W_VAL_FLAG)
                THEN
                    VALIDATE;
                END IF;

                IF (W_VAL_FLAG <> TRUE OR V_I = 1)
                THEN
                    PKG_CHKGLBALCTRL.SP_CHKGLBALCTRL (
                        PKG_ENTITY.FN_GET_ENTITY_CODE,
                        P_BRNCODE,
                        W_GLB_TMP_SL,
                        W_ERROR);

                    IF (TRIM (W_ERROR) IS NOT NULL)
                    THEN
                        RAISE E_USEREXCEP;
                    END IF;

                    IF (W_GLB_TMP_SL = 0)
                    THEN
                        CHECK_LOGIN_USER;
                        UPDATEBRNSTATUS;
                        UPDATE_TELBAL;
                    END IF;
                END IF;
            ELSE
                W_ERROR := 'SERVER BUSY';
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                IF TRIM (W_ERROR) IS NULL
                THEN
                    W_ERROR := 'ERROR IN SP_BRNSIGNOUT ' || SQLERRM;
                END IF;
        END;

        P_ERR_STATUS := W_ERROR;
        P_REPORT_SL := W_TMP_SERIAL;
        P_STATUS := W_STATUS;
        P_GLB_TMP_SL := W_GLB_TMP_SL;
    END;
END;
/

