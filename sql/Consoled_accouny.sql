/* Formatted on 5/28/2023 6:43:22 PM (QP5 v5.388) */
CREATE OR REPLACE PROCEDURE SP_GEN_BULK_SMS (P_ASON_DATE     DATE,
                                             P_FROM_BRANCH   NUMBER,
                                             P_TO_BRANCH     NUMBER)
AS
    FROMATED_ACCOUNT_NUMBER   VARCHAR2 (300);

    V_AVL_BALANCE             NUMBER (18, 2);
    V_SMS_CHARGE              NUMBER (18, 2);
    V_AMC_CHARGE              NUMBER (18, 2);
    V_ATM_CHARGE              NUMBER (18, 2);
    V_ED_CHARGE               NUMBER (18, 2);
    V_SMS_VAT                 NUMBER (18, 2);
    V_AMC_VAT                 NUMBER (18, 2);
    V_ATM_VAT                 NUMBER (18, 2);
    V_INT_AMT                 NUMBER (18, 2);
    V_TDS_AMT                 NUMBER (18, 2);
    W_TEXT_MESSAGE            VARCHAR2 (500);
    V_CBD                     DATE;
    V_ENTITY_NUM              NUMBER;
    V_ERROR                   VARCHAR2 (300);
    V_SERVICE_CODE            VARCHAR2 (20);
    W_MOBILE_NUMBER           VARCHAR2 (20);
    V_CALL_CODE               VARCHAR2 (20);
    W_SQL                     VARCHAR2 (6000);
    W_DUMMY_V                 VARCHAR2 (10);
    W_DUMMY_N                 NUMBER;
    W_DUMMY_D                 DATE;
    W_REC_AC_AUTH_BAL         NUMBER (18, 2);
    W_REC_AC_AVL_BAL          NUMBER (18, 2);


    TYPE TY_SMS_TMP IS RECORD
    (
        V_INTERNAL_ACC      NUMBER (14),
        V_SMSMAST_SVC_CD    VARCHAR2 (20),
        V_SMSMAST_CD        VARCHAR2 (20),
        V_MOBILE_NUMBER     VARCHAR2 (20)
    );

    TYPE TYY_TY_SMS_TMP IS TABLE OF TY_SMS_TMP
        INDEX BY PLS_INTEGER;

    TYYT_SMS_TMP              TYY_TY_SMS_TMP;

    PROCEDURE INSERT_MOBSMSOUTQ (W_BRN_CODE     IN NUMBER,
                                 W_SER_CODE     IN VARCHAR2,
                                 W_MOBILE_NUM   IN VARCHAR2,
                                 W_SMS_TEXT     IN VARCHAR2,
                                 W_INTNUM       IN NUMBER)
    IS
        W_PUSH   NUMBER (2) := 1;
    BEGIN
       <<SMSPARAM>>
        BEGIN
            SELECT P.SMSPARAM_PUSH
              INTO W_PUSH
              FROM SMSPARAM P
             WHERE P.SMSPARAM_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE;
        EXCEPTION
            WHEN OTHERS
            THEN
                W_PUSH := 1;
        END SMSPARAM;

        PKG_INSERT_MOBSMSOUTQ.SP_INSERT_MOBSMSOUTQ (
            PKG_ENTITY.FN_GET_ENTITY_CODE,
            W_BRN_CODE,
            W_SER_CODE,
            W_MOBILE_NUM,
            W_SMS_TEXT,
            0,
            SYSDATE,
            0,
            ' ',
            W_PUSH,
            W_INTNUM);
    END INSERT_MOBSMSOUTQ;

    PROCEDURE CALL_SP_AVLBAL (P_ENTITY_CODE NUMBER, P_ACNT_NUM IN NUMBER)
    IS
    BEGIN
        SP_AVLBAL (P_ENTITY_CODE,
                   P_ACNT_NUM,
                   W_DUMMY_V,
                   W_REC_AC_AUTH_BAL,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_REC_AC_AVL_BAL,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_D,
                   W_DUMMY_V,
                   W_DUMMY_D,
                   W_DUMMY_V,
                   W_DUMMY_V,
                   W_DUMMY_V,
                   W_DUMMY_V,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   V_ERROR,
                   W_DUMMY_V,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   1,
                   1);


        V_AVL_BALANCE := FLOOR (W_REC_AC_AVL_BAL);
    END;
BEGIN
    V_ENTITY_NUM := 1;
    V_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (V_ENTITY_NUM);
    FROMATED_ACCOUNT_NUMBER := '';
    W_MOBILE_NUMBER := '';
    V_SERVICE_CODE := 'BULKSMS';
    V_CALL_CODE := '88';
    W_TEXT_MESSAGE := '';
    V_AVL_BALANCE := 0;
    V_SMS_CHARGE := 0;
    V_AMC_CHARGE := 0;
    V_ATM_CHARGE := 0;
    V_ED_CHARGE := 0;
    V_SMS_VAT := 0;
    V_AMC_VAT := 0;
    V_ATM_VAT := 0;
    V_INT_AMT := 0;
    V_TDS_AMT := 0;

    --    BEGIN
    --        SELECT SMSSGMT_TEXT
    --          INTO W_TEXT_MESSAGE
    --          FROM SMSSVCSGMT
    --         WHERE     SMSSGMT_CD = 'BULKSMS'
    --               AND SMSSGMT_ENTITY_NUM = V_ENTITY_NUM
    --               AND SMSSGMT_SL = 1
    --               AND SMSSGMT_TYPE = 1;
    --    EXCEPTION
    --        WHEN NO_DATA_FOUND
    --        THEN
    --            v_error := 'NO sms param';
    --    END;
    DBMS_OUTPUT.PUT_LINE (W_TEXT_MESSAGE);

    FOR IDZ
        IN (SELECT *
             FROM (  SELECT BRANCH_CODE, ROWNUM BRANCH_SL
                       FROM MIG_DETAIL
                      WHERE BRANCH_CODE = 26
                   ORDER BY BRANCH_CODE)
            WHERE     BRANCH_SL BETWEEN P_FROM_BRANCH AND P_TO_BRANCH
                  AND BRANCH_CODE NOT IN
                          (SELECT BRANCH_CODE FROM BULKSMSCOMBRN))
    LOOP
       <<SECOND>>
        BEGIN
            W_SQL :=
                'SELECT INT_ACNUM,CM.SMSMAST_SVC_CD, CM.SMSMAST_CD, M.MOBILE_NUMBER
                 FROM MOBILEREG M, SMSSVCMAST CM
                WHERE     M.ENTITY_NUM = CM.SMSMAST_ENTITY_NUM
                       AND M.ACTIVE = 0
                      AND M.MOBILEREG_AUTH_ON IS NOT NULL
                      AND M.SERVICE1 = 1
                       AND BRANCH_CODE = :BRANCH_CODE
                       AND INT_ACNUM = 10002600022893
                      AND M.SERVICE1_DEACTIVATED_ON IS NULL
                      AND M.SERVICE1 = CM.SERVICE_TYPE
                      AND CM.SMSMAST_SVC_CD = :SERVICE_CODE
                      AND CM.SERVICE_STATUS = 0';

            EXECUTE IMMEDIATE W_SQL
                BULK COLLECT INTO TYYT_SMS_TMP
                USING IDZ.BRANCH_CODE, V_SERVICE_CODE;

            IF TYYT_SMS_TMP.COUNT > 0
            THEN
                FOR IDY IN TYYT_SMS_TMP.FIRST .. TYYT_SMS_TMP.LAST
                LOOP
                    BEGIN
                        SELECT TDSPIDT_TOT_INT_CR, TDSPIDT_TDS_AMT
                          INTO V_INT_AMT, V_TDS_AMT
                          FROM TDSPIDTL
                         WHERE     TDSPIDT_ENTITY_NUM = V_ENTITY_NUM
                               AND TDSPIDT_TOT_INT_CR > 0
                               --AND ACNTCHGAMT_FIN_YEAR = :P_FIN_YEAR
                               AND TDSPIDT_AC_NUM =
                                   TYYT_SMS_TMP (IDY).V_INTERNAL_ACC
                               AND TDSPIDT_DATE_OF_REC = P_ASON_DATE;
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            V_INT_AMT := 0;
                            V_TDS_AMT := 0;
                    END;

                    -- Maintenance Charge
                    BEGIN
                        SELECT ACNTCHGAMT_CHARGE_AMT, ACNTCHGAMT_SERV_TAX_AMT
                          INTO V_AMC_CHARGE, V_AMC_VAT
                          FROM ACNTCHARGEAMT
                         WHERE     ACNTCHGAMT_ENTITY_NUM = V_ENTITY_NUM
                               AND ACNTCHGAMT_CHARGE_AMT > 0
                               --AND ACNTCHGAMT_FIN_YEAR = :P_FIN_YEAR
                               AND ACNTCHGAMT_INTERNAL_ACNUM =
                                   TYYT_SMS_TMP (IDY).V_INTERNAL_ACC
                               AND ACNTCHGAMT_PROCESS_DATE = P_ASON_DATE;
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            V_AMC_CHARGE := 0;
                            V_AMC_VAT := 0;
                    END;

                   -- SMS Charge

                   <<SMS>>
                    BEGIN
                        SELECT NVL (SMSCHARGE_CHARGE_AMT, 0),
                               NVL (SMSCHARGE_VAT_AMT, 0)
                          INTO V_SMS_CHARGE, V_SMS_VAT
                          FROM SMSCHARGE
                         WHERE     SMSCHARGE_ENTITY_NUM = V_ENTITY_NUM
                               AND SMSCHARGE_CHARGE_AMT > 0
                               -- AND SMSCHARGE_FIN_YEAR = :P_FIN_YEAR
                               AND SMSCHARGE_INTERNAL_ACNUM =
                                   TYYT_SMS_TMP (IDY).V_INTERNAL_ACC
                               AND SMSCHARGE_PROCESS_DATE = P_ASON_DATE;
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            V_SMS_CHARGE := 0;
                            V_SMS_VAT := 0;
                    END;

                   -- ATM CHARGE

                   <<ATM>>
                    BEGIN
                        SELECT NVL (ATM_CHG_REC_CHARGE_AMT, 0),
                               NVL (ATM_CHG_REC_VAT_AMT, 0)
                          INTO V_ATM_CHARGE, V_ATM_VAT
                          FROM ATM_CHG_REC
                         WHERE     ATM_CHG_REC_ENTITY_NUM = V_ENTITY_NUM
                               -- AND ATM_CHG_REC_FIN_YEAR = :P_FIN_YEAR
                               AND ATM_CHG_REC_CHARGE_AMT > 0
                               AND ATM_CHG_REC_INTERNAL_ACNUM =
                                   TYYT_SMS_TMP (IDY).V_INTERNAL_ACC
                               AND ATM_CHG_REC_PROCESS_DATE = P_ASON_DATE;
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            V_ATM_CHARGE := 0;
                            V_ATM_VAT := 0;
                    END;

                   -- EXCISE DUTY
                   <<ED>>
                    BEGIN
                        SELECT NVL (ACNTEXCAMT_EXCISE_AMT, 0)
                          INTO V_ED_CHARGE
                          FROM ACNTEXCISEAMT
                         WHERE     ACNTEXCAMT_ENTITY_NUM = V_ENTITY_NUM
                               -- AND ACNTEXCAMT_FIN_YEAR = :P_FIN_YEAR
                               AND ACNTEXCAMT_INTERNAL_ACNUM =
                                   TYYT_SMS_TMP (IDY).V_INTERNAL_ACC
                               AND ACNTEXCAMT_PROCESS_DATE = P_ASON_DATE
                               AND ACNTEXCAMT_EXCISE_AMT > 0;
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            V_ED_CHARGE := 0;
                    END;

                    IF SUBSTR (TYYT_SMS_TMP (IDY).V_MOBILE_NUMBER, 0, 2) =
                       '01'
                    THEN
                        W_MOBILE_NUMBER :=
                            V_CALL_CODE || TYYT_SMS_TMP (IDY).V_MOBILE_NUMBER;
                    ELSE
                        W_MOBILE_NUMBER := TYYT_SMS_TMP (IDY).V_MOBILE_NUMBER;
                    END IF;

                    FROMATED_ACCOUNT_NUMBER :=
                           SUBSTR (
                               FACNO (V_ENTITY_NUM,
                                      TYYT_SMS_TMP (IDY).V_INTERNAL_ACC),
                               0,
                               4)
                        || '*****'
                        || SUBSTR (
                               FACNO (V_ENTITY_NUM,
                                      TYYT_SMS_TMP (IDY).V_INTERNAL_ACC),
                               10);

                    IF (   (V_INT_AMT <> 0 AND V_TDS_AMT <> 0)
                        OR (V_AMC_CHARGE <> 0 AND V_AMC_VAT <> 0)
                        OR (V_SMS_CHARGE <> 0 AND V_SMS_VAT <> 0)
                        OR V_ED_CHARGE <> 0
                        OR (V_ATM_CHARGE <> 0 AND V_ATM_VAT <> 0))
                    THEN
                        W_TEXT_MESSAGE :=
                            'Your A/C : ' || FROMATED_ACCOUNT_NUMBER;
                    END IF;

                    IF (V_INT_AMT <> 0 AND V_TDS_AMT <> 0)
                    THEN
                        W_TEXT_MESSAGE :=
                               W_TEXT_MESSAGE
                            || ' has been credited for Interest '
                            || SP_GETFORMAT (V_ENTITY_NUM, 'BDT ', V_INT_AMT)
                            || ' Debited for TDS '
                            || SP_GETFORMAT (V_ENTITY_NUM, 'BDT', V_TDS_AMT);
                    END IF;

                    IF V_AMC_CHARGE <> 0 AND V_AMC_VAT <> 0
                    THEN
                        W_TEXT_MESSAGE :=
                               W_TEXT_MESSAGE
                            || ', Maintaince Charge: '
                            || SP_GETFORMAT (V_ENTITY_NUM,
                                             'BDT ',
                                             V_AMC_CHARGE)
                            || ' VAT '
                            || SP_GETFORMAT (V_ENTITY_NUM, 'BDT', V_AMC_VAT);
                    END IF;



                    IF (V_SMS_CHARGE <> 0 AND V_SMS_VAT <> 0)
                    THEN
                        W_TEXT_MESSAGE :=
                               W_TEXT_MESSAGE
                            || ', Debited For SMS Charge '
                            || SP_GETFORMAT (V_ENTITY_NUM,
                                             'BDT ',
                                             V_SMS_CHARGE)
                            || ' VAT '
                            || SP_GETFORMAT (V_ENTITY_NUM, 'BDT', V_SMS_VAT);
                    END IF;

                    IF V_ED_CHARGE <> 0
                    THEN
                        W_TEXT_MESSAGE :=
                               W_TEXT_MESSAGE
                            || ', Debited For Exicise Duty: '
                            || SP_GETFORMAT (V_ENTITY_NUM,
                                             'BDT ',
                                             V_ED_CHARGE);
                    END IF;

                    IF (V_ATM_CHARGE <> 0 AND V_ATM_VAT <> 0)
                    THEN
                        W_TEXT_MESSAGE :=
                               W_TEXT_MESSAGE
                            || ' Debit Card Maintenance Chrage: '
                            || SP_GETFORMAT (V_ENTITY_NUM,
                                             'BDT ',
                                             V_ATM_CHARGE)
                            || ' VAT '
                            || SP_GETFORMAT (V_ENTITY_NUM, 'BDT', V_ATM_VAT);
                    END IF;

                    CALL_SP_AVLBAL (V_ENTITY_NUM,
                                    TYYT_SMS_TMP (IDY).V_INTERNAL_ACC);

                    IF (   (V_AMC_CHARGE <> 0 AND V_AMC_VAT <> 0)
                        OR (V_SMS_CHARGE <> 0 AND V_SMS_VAT <> 0)
                        OR V_ED_CHARGE <> 0
                        OR (V_ATM_CHARGE <> 0 AND V_ATM_VAT <> 0))
                    THEN
                        W_TEXT_MESSAGE :=
                               W_TEXT_MESSAGE
                            || ' Available Balance: BDT '
                            || SP_GETFORMAT (V_ENTITY_NUM,
                                             'BDT',
                                             V_AVL_BALANCE);
                        DBMS_OUTPUT.PUT_LINE (W_TEXT_MESSAGE);
                        INSERT_MOBSMSOUTQ (IDZ.BRANCH_CODE,
                                           TYYT_SMS_TMP (IDY).V_SMSMAST_CD,
                                           W_MOBILE_NUMBER,
                                           W_TEXT_MESSAGE,
                                           TYYT_SMS_TMP (IDY).V_INTERNAL_ACC);
                    END IF;
                END LOOP;
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                INSERT INTO SMSALERTPROCERROR
                         VALUES (
                                    SYSDATE,
                                       'ERROR IN INSERTING MOBSMSOUTQ '
                                    || W_TEXT_MESSAGE);
        END;

        INSERT INTO BULKSMSCOMBRN (BRANCH_CODE)
             VALUES (IDZ.BRANCH_CODE);
    END LOOP;
END;