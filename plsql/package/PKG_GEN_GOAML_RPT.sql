/*<TOAD_FILE_CHUNK>*/
CREATE OR REPLACE PACKAGE PKG_GEN_GOAML_RPT IS

 

  SBL_ENTITY_NUM        CONSTANT NUMBER(2) := 1;

  GOAML_PROCESS_ID      CONSTANT VARCHAR2(10) := 'goaml';
  GOVT_ACC_FLAG         CONSTANT NUMBER(6) := 9;
  OTHER_GOVT_ACC_FLAG   CONSTANT NUMBER(6) := 10;
  GOAML_PROCESS_STARTED CONSTANT VARCHAR2(30) := 'RUNNING';
  GOAML_PROCESS_ENDED   CONSTANT VARCHAR2(30) := 'COMPLETED';
  W_ERROR_MSG           VARCHAR2(100);
  ERROR_CD              VARCHAR2(100);
  W_ERROR_CODE_1        CONSTANT NUMBER := -20999;


  PROCEDURE GENERATE_GOAML_RPT(P_BRNLIST_CODE IN NUMBER,
                               P_BRN_CODE     IN NUMBER,
                               P_RTP_TYPE     IN VARCHAR2,
                               P_YEAR         IN NUMBER,
                               P_MONTH        IN NUMBER);

END PKG_GEN_GOAML_RPT;

/

/*<TOAD_FILE_CHUNK>*/
/* Formatted on 9/27/2023 4:21:38 PM (QP5 v5.388) */
CREATE OR REPLACE PACKAGE BODY PKG_GEN_GOAML_RPT
IS
    ------------------------- TYPES -------------------------------

    TYPE GOAML_DATA_RECORD IS RECORD
    (
        TRAN_BRN_CODE               NUMBER (6),
        TRAN_BATCH_NUMBER           NUMBER (7),
        TRAN_NARR_DTL1              VARCHAR2 (35),
        TRAN_NARR_DTL2              VARCHAR2 (35),
        TRAN_NARR_DTL3              VARCHAR2 (35),
        TRAN_DATE_OF_TRAN           DATE,
        TRAN_VALUE_DATE             DATE,
        TRAN_ENTD_BY                VARCHAR2 (8),
        TRAN_AUTH_BY                VARCHAR2 (8),
        TRAN_CODE                   VARCHAR2 (6),
        TRAN_AMOUNT                 NUMBER (18, 3),
        TRAN_BATCH_SL_NUM           NUMBER (6),
        TRAN_TYPE_OF_TRAN           CHAR (1),
        TRAN_DB_CR_FLG              CHAR (1),
        TRAN_INTERNAL_ACNUM         NUMBER (14),
        TRAN_BASE_CURR_CONV_RATE    NUMBER (14, 9),
        TRAN_BATCH_SL_NO            NUMBER (6),
        CLIENTS_CONST_CODE          NUMBER (6),
        CLIENTS_TYPE_FLG            CHAR (1),
        CLIENTS_CODE                NUMBER (12),
        RPT_BRN                     NUMBER (6)
    );

    TYPE TM_GOAML_DATA IS TABLE OF GOAML_DATA_RECORD;

    TYPE CLIENT_ID_RECORD IS RECORD
    (
        PID_TYPE       VARCHAR2 (3),
        DOCID_NUM      VARCHAR2 (35),
        ISSUE_DATE     DATE,
        EXP_DATE       DATE,
        ISSUE_CNTRY    VARCHAR2 (2)
    );

    TYPE TM_CLIENT_IDS IS TABLE OF CLIENT_ID_RECORD;

    TYPE CLIENT_ADDRESS_RECORD IS RECORD
    (
        ADDR1              VARCHAR2 (100),
        ADDR2              VARCHAR2 (100),
        ADDR3              VARCHAR2 (100),
        ADDR4              VARCHAR2 (100),
        ADDR5              VARCHAR2 (100),
        LOCN_NAME          VARCHAR2 (100),
        LOCN_CNTRY_CODE    VARCHAR2 (100),
        STATE_NAME         VARCHAR2 (100),
        DISTRICT_NAME      VARCHAR2 (100),
        LOCN_CODE          VARCHAR2 (100),
        CURR_ADDR          CHAR (1),
        PERM_ADDR          CHAR (1),
        COMM_ADDR          CHAR (1),
        ADDR_TYPE          VARCHAR2 (3)
    );

    TYPE TM_CLIENT_ADDRESS IS TABLE OF CLIENT_ADDRESS_RECORD;

    TYPE CLIENT_TYPE_RECORD IS RECORD
    (
        AC_CLIENT_NUM           VARCHAR2 (12),
        AC_INTERNAL_ACNUM       VARCHAR2 (14),
        AC_AC_NAME1             VARCHAR (50),
        CONNROLE_CODE           VARCHAR2 (3),
        CONNROLE_DESCN          VARCHAR2 (35),
        CONNP_CLIENT_NUM        VARCHAR2 (12),
        CONNP_INTERNAL_ACNUM    VARCHAR2 (14)
    );

    TYPE TM_CLIENT_TYPE IS TABLE OF CLIENT_TYPE_RECORD;

    V_MID_LAST_NAME   VARCHAR2 (92);

    ------------------------- FUNCTIONS -------------------------------

    FUNCTION IS_GOAML_PROCESS_RUNNING
        RETURN BOOLEAN
    AS
        V_PROCESS_STATUS       VARCHAR2 (15);
        V_IS_PROCESS_RUNNING   BOOLEAN := FALSE;
    BEGIN
        BEGIN
            SELECT PROCESS_STATUS
              INTO V_PROCESS_STATUS
              FROM GOAML_PROCESS
             WHERE PROCESS_ID = GOAML_PROCESS_ID;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                V_PROCESS_STATUS := '';
            WHEN OTHERS
            THEN
                RAISE_APPLICATION_ERROR (
                    W_ERROR_CODE_1,
                    SQLERRM || ' IN IS_GOAML_PROCESS_RUNNING');
        END;

        IF V_PROCESS_STATUS = GOAML_PROCESS_STARTED
        THEN
            V_IS_PROCESS_RUNNING := TRUE;
        ELSE
            V_IS_PROCESS_RUNNING := FALSE;
        END IF;

        RETURN V_IS_PROCESS_RUNNING;
    END IS_GOAML_PROCESS_RUNNING;

    FUNCTION VALIDATE_FOR_XML (P_DATA IN VARCHAR2)
        RETURN VARCHAR2
    AS
        V_VALIDATED   VARCHAR2 (150) := '';
    BEGIN
        V_VALIDATED := P_DATA;
        V_VALIDATED := REPLACE (V_VALIDATED, '<', '');
        V_VALIDATED := REPLACE (V_VALIDATED, '>', '');
        V_VALIDATED := REPLACE (V_VALIDATED, '&', '');
        V_VALIDATED := REPLACE (V_VALIDATED, '%', '');
        V_VALIDATED := REPLACE (V_VALIDATED, ',', '');
        V_VALIDATED := TRIM (V_VALIDATED);
        RETURN V_VALIDATED;
    END VALIDATE_FOR_XML;

    FUNCTION GET_BRN_DISTRICT_LOCATION (P_BRN_CODE IN NUMBER)
        RETURN VARCHAR2
    AS
        V_BRN_DISTRICT_LOCATION   VARCHAR2 (100);
    BEGIN
        BEGIN
            SELECT    MBRN_NAME
                   || ' - '
                   || LPAD (P_BRN_CODE, 5, '0')
                   || ' - '
                   || DISTRICT_NAME
              INTO V_BRN_DISTRICT_LOCATION
              FROM MBRN
                   LEFT JOIN LOCATION ON LOCN_CODE = MBRN_LOCN_CODE
                   LEFT JOIN DISTRICT
                       ON     LOCN_CNTRY_CODE = DISTRICT_CNTRY_CODE
                          AND LOCN_STATE_CODE = DISTRICT_STATE_CODE
                          AND LOCN_DISTRICT_CODE = DISTRICT_CODE
             WHERE MBRN_CODE = P_BRN_CODE;

            V_BRN_DISTRICT_LOCATION :=
                VALIDATE_FOR_XML (V_BRN_DISTRICT_LOCATION);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                V_BRN_DISTRICT_LOCATION := '';
            WHEN OTHERS
            THEN
                RAISE_APPLICATION_ERROR (
                    W_ERROR_CODE_1,
                       SQLERRM
                    || ' IN GET_BRN_DISTRICT_LOCATION FOR BRN '
                    || P_BRN_CODE);
        END;

        RETURN V_BRN_DISTRICT_LOCATION;
    END GET_BRN_DISTRICT_LOCATION;

    FUNCTION GET_USER_NAME (P_USER_ID IN VARCHAR2)
        RETURN VARCHAR2
    AS
        V_USER_NAME   VARCHAR2 (100);
    BEGIN
        BEGIN
            SELECT USER_NAME
              INTO V_USER_NAME
              FROM USERS
             WHERE USERS.USER_ID = P_USER_ID AND ROWNUM < 2;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                V_USER_NAME := P_USER_ID;
            WHEN OTHERS
            THEN
                V_USER_NAME := '';
                RAISE_APPLICATION_ERROR (
                    W_ERROR_CODE_1,
                    SQLERRM || ' IN GET_USER_NAME FOR USER_ID:' || P_USER_ID);
        END;

        V_USER_NAME := VALIDATE_FOR_XML (V_USER_NAME);
        RETURN V_USER_NAME;
    END GET_USER_NAME;

    ------------------------- PROCEDURES -------------------------------

    PROCEDURE UPDATE_GOAML_PROCESS (P_PROCESS_STATUS   IN VARCHAR2,
                                    P_PROCESS_ID       IN VARCHAR2)
    IS
        W_GOAML_PROCESS_UPDATE_SQL   VARCHAR2 (1000);
    BEGIN
        W_GOAML_PROCESS_UPDATE_SQL :=
            'UPDATE GOAML_PROCESS
                                   SET PROCESS_START_TIME=:1, PROCESS_STATUS =:2
                                   WHERE PROCESS_ID=:3';

        EXECUTE IMMEDIATE W_GOAML_PROCESS_UPDATE_SQL
            USING SYSTIMESTAMP, P_PROCESS_STATUS, P_PROCESS_ID;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR (
                W_ERROR_CODE_1,
                   SQLERRM
                || ' IN UPDATE_GOAML_PROCESS WHILE SETTING STATUS '
                || P_PROCESS_STATUS);
    END UPDATE_GOAML_PROCESS;

    PROCEDURE DELETE_GOAML_RPT_RECORDS (P_YEAR       IN NUMBER,
                                        P_MONTH      IN NUMBER,
                                        P_BRN_CODE   IN NUMBER,
                                        P_RTP_TYPE   IN VARCHAR2)
    IS
        W_TRAN_DELETE_SQL          VARCHAR2 (1000);
        W_TRAN_MASTER_DELETE_SQL   VARCHAR2 (1000);
    BEGIN
        BEGIN
            W_TRAN_DELETE_SQL :=
                'DELETE FROM GOAML_TRAN_CORPORATE WHERE SEQ_NO IN (
                            SELECT SEQ_NO FROM GOAML_TRAN_MASTER
                            WHERE RPT_YEAR = :1
                            AND RPT_MONTH = :2
                            AND RPT_BRANCH_CODE = :3
                            AND RTP_TYPE = :4)';

            EXECUTE IMMEDIATE W_TRAN_DELETE_SQL
                USING P_YEAR,
                      P_MONTH,
                      NVL (P_BRN_CODE, 0),
                      P_RTP_TYPE;

            W_TRAN_DELETE_SQL :=
                'DELETE FROM GOAML_TRAN_INDV WHERE SEQ_NO IN (
                            SELECT SEQ_NO FROM GOAML_TRAN_MASTER
                            WHERE RPT_YEAR = :1
                            AND RPT_MONTH = :2
                            AND RPT_BRANCH_CODE = :3
                            AND RTP_TYPE = :4)';

            EXECUTE IMMEDIATE W_TRAN_DELETE_SQL
                USING P_YEAR,
                      P_MONTH,
                      NVL (P_BRN_CODE, 0),
                      P_RTP_TYPE;

            W_TRAN_MASTER_DELETE_SQL := 'DELETE FROM GOAML_TRAN_MASTER
                                   WHERE RPT_YEAR =:1
                                   AND RPT_MONTH=:2
                                   AND RPT_BRANCH_CODE=:3
                                   AND RTP_TYPE =:4';

            EXECUTE IMMEDIATE W_TRAN_MASTER_DELETE_SQL
                USING P_YEAR,
                      P_MONTH,
                      NVL (P_BRN_CODE, 0),
                      P_RTP_TYPE;
        EXCEPTION
            WHEN OTHERS
            THEN
                RAISE_APPLICATION_ERROR (
                    W_ERROR_CODE_1,
                       SQLERRM
                    || ' IN UPDATE_GOAML_PROCESS FOR BRN'
                    || P_BRN_CODE);
        END;
    END DELETE_GOAML_RPT_RECORDS;

    PROCEDURE GET_CONTACT_DTLS (P_CLIENTS_CODE      IN     VARCHAR2,
                                P_PRESENTADDRESS1      OUT VARCHAR2,
                                P_PRESENTADDRESS2      OUT VARCHAR2,
                                P_PRESENT_TOWN         OUT VARCHAR2,
                                P_PRESENT_CITY         OUT VARCHAR2,
                                P_PRESENT_ZIP          OUT VARCHAR2,
                                P_PRESENT_COUNTRY      OUT VARCHAR2,
                                P_PRESENT_STATE        OUT VARCHAR2,
                                P_PERMADDRESS          OUT VARCHAR2,
                                P_PERMTOWN             OUT VARCHAR2,
                                P_PERMCITY             OUT VARCHAR2,
                                P_PERMZIP              OUT VARCHAR2,
                                P_PERMCOUNTRY          OUT VARCHAR2,
                                P_PERMSTATE            OUT VARCHAR2,
                                P_PHONE_NUM            OUT VARCHAR2,
                                P_MOBILE_NO            OUT VARCHAR2)
    IS
        Q_CLIENT_ADDRESS   TM_CLIENT_ADDRESS;
    BEGIN
       <<GETCLIENTADDRESS>>
        BEGIN
            SELECT TRIM (ADDRDTLS_ADDR1),
                   TRIM (ADDRDTLS_ADDR2),
                   TRIM (ADDRDTLS_ADDR3),
                   TRIM (ADDRDTLS_ADDR4),
                   TRIM (ADDRDTLS_ADDR5),
                   LOCN_NAME,
                   NVL (TRIM (LOCN_CNTRY_CODE), 'BD'),
                   STATE_NAME,
                   NVL (DISTRICT_NAME, STATE_NAME),
                   ADDRDTLS_LOCN_CODE,
                   ADDRDTLS_CURR_ADDR,
                   ADDRDTLS_PERM_ADDR,
                   ADDRDTLS_COMM_ADDR,
                   ADDRDTLS_ADDR_TYPE
              BULK COLLECT INTO Q_CLIENT_ADDRESS
              FROM CLIENTS
                   INNER JOIN ADDRDTLS
                       ON ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                   LEFT JOIN LOCATION ON ADDRDTLS_LOCN_CODE = LOCN_CODE
                   LEFT JOIN STATE
                       ON     LOCN_CNTRY_CODE = STATE_CNTRY_CODE
                          AND LOCN_STATE_CODE = STATE_CODE
                   LEFT JOIN DISTRICT
                       ON     LOCN_CNTRY_CODE = DISTRICT_CNTRY_CODE
                          AND LOCN_STATE_CODE = DISTRICT_STATE_CODE
                          AND LOCN_DISTRICT_CODE = DISTRICT_CODE
             WHERE CLIENTS.CLIENTS_CODE = P_CLIENTS_CODE;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
            WHEN OTHERS
            THEN
                RAISE_APPLICATION_ERROR (
                    W_ERROR_CODE_1,
                       SQLERRM
                    || ' FOR '
                    || P_CLIENTS_CODE
                    || ' IN GET_CONTACT_DTLS:GETCLIENTADDRESS');
        END GETCLIENTADDRESS;

        BEGIN
            IF Q_CLIENT_ADDRESS.FIRST IS NOT NULL
            THEN
                FOR IDX IN Q_CLIENT_ADDRESS.FIRST .. Q_CLIENT_ADDRESS.LAST
                LOOP
                    IF    Q_CLIENT_ADDRESS (IDX).PERM_ADDR = '1'
                       OR Q_CLIENT_ADDRESS (IDX).ADDR_TYPE = '01'
                    THEN
                        P_PERMADDRESS :=
                            VALIDATE_FOR_XML (
                                SUBSTR (
                                       TRIM (Q_CLIENT_ADDRESS (IDX).ADDR1)
                                    || ' '
                                    || TRIM (Q_CLIENT_ADDRESS (IDX).ADDR2)
                                    || ' '
                                    || TRIM (Q_CLIENT_ADDRESS (IDX).ADDR3)
                                    || ' '
                                    || TRIM (Q_CLIENT_ADDRESS (IDX).ADDR4)
                                    || ' '
                                    || TRIM (Q_CLIENT_ADDRESS (IDX).ADDR5),
                                    0,
                                    99));
                        P_PERMTOWN :=
                            VALIDATE_FOR_XML (
                                TRIM (Q_CLIENT_ADDRESS (IDX).LOCN_NAME));
                        P_PERMCOUNTRY :=
                            VALIDATE_FOR_XML (
                                NVL (
                                    TRIM (
                                        Q_CLIENT_ADDRESS (IDX).LOCN_CNTRY_CODE),
                                    'BD'));
                        P_PERMSTATE :=
                            VALIDATE_FOR_XML (
                                TRIM (Q_CLIENT_ADDRESS (IDX).STATE_NAME));
                        P_PERMCITY :=
                            VALIDATE_FOR_XML (
                                TRIM (Q_CLIENT_ADDRESS (IDX).DISTRICT_NAME));
                        P_PERMZIP :=
                            VALIDATE_FOR_XML (
                                TRIM (Q_CLIENT_ADDRESS (IDX).LOCN_CODE));
                    END IF;

                    IF    Q_CLIENT_ADDRESS (IDX).CURR_ADDR = '1'
                       OR Q_CLIENT_ADDRESS (IDX).ADDR_TYPE = '02  '
                    THEN
                        P_PRESENTADDRESS1 :=
                            VALIDATE_FOR_XML (
                                SUBSTR (
                                       TRIM (Q_CLIENT_ADDRESS (IDX).ADDR1)
                                    || ' '
                                    || TRIM (Q_CLIENT_ADDRESS (IDX).ADDR2)
                                    || ' '
                                    || TRIM (Q_CLIENT_ADDRESS (IDX).ADDR3)
                                    || ' '
                                    || TRIM (Q_CLIENT_ADDRESS (IDX).ADDR4)
                                    || ' '
                                    || TRIM (Q_CLIENT_ADDRESS (IDX).ADDR5),
                                    0,
                                    99));
                        P_PRESENTADDRESS2 :=
                            VALIDATE_FOR_XML (
                                SUBSTR (
                                       TRIM (Q_CLIENT_ADDRESS (IDX).ADDR3)
                                    || ' '
                                    || TRIM (Q_CLIENT_ADDRESS (IDX).ADDR4)
                                    || ' '
                                    || TRIM (Q_CLIENT_ADDRESS (IDX).ADDR5),
                                    0,
                                    99));

                        IF LENGTH (P_PRESENTADDRESS1 || P_PRESENTADDRESS2) >
                           99
                        THEN
                            P_PRESENTADDRESS1 :=
                                SUBSTR (
                                    P_PRESENTADDRESS1 || P_PRESENTADDRESS2,
                                    0,
                                    99);
                            P_PRESENTADDRESS2 := '';
                        END IF;

                        P_PRESENT_TOWN :=
                            VALIDATE_FOR_XML (
                                TRIM (Q_CLIENT_ADDRESS (IDX).LOCN_NAME));
                        P_PRESENT_COUNTRY :=
                            VALIDATE_FOR_XML (
                                NVL (
                                    TRIM (
                                        Q_CLIENT_ADDRESS (IDX).LOCN_CNTRY_CODE),
                                    'BD'));
                        P_PRESENT_STATE :=
                            VALIDATE_FOR_XML (
                                TRIM (Q_CLIENT_ADDRESS (IDX).STATE_NAME));
                        P_PRESENT_CITY :=
                            VALIDATE_FOR_XML (
                                TRIM (Q_CLIENT_ADDRESS (IDX).DISTRICT_NAME));
                        P_PRESENT_ZIP :=
                            VALIDATE_FOR_XML (
                                TRIM (Q_CLIENT_ADDRESS (IDX).LOCN_CODE));
                    END IF;

                    IF     P_PRESENTADDRESS1 IS NOT NULL
                       AND P_PERMADDRESS IS NOT NULL
                    THEN
                        EXIT;
                    END IF;
                END LOOP;
            END IF;
        END;

       <<GETMOBILENUMBER>>
        BEGIN
            SELECT COALESCE (TRIM (ADDRDTLS_PHONE_NUM1),
                             TRIM (ADDRDTLS_PHONE_NUM2),
                             ''),
                   NVL (ADDRDTLS_MOBILE_NUM, '')
              INTO P_PHONE_NUM, P_MOBILE_NO
              FROM CLIENTS
                   INNER JOIN ADDRDTLS
                       ON ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
             WHERE CLIENTS_CODE = P_CLIENTS_CODE AND ROWNUM < 2;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
            WHEN OTHERS
            THEN
                RAISE_APPLICATION_ERROR (
                    W_ERROR_CODE_1,
                       SQLERRM
                    || ' FOR '
                    || P_CLIENTS_CODE
                    || ' IN GET_CONTACT_DTLS:GETMOBILENUMBER');
        END GETMOBILENUMBER;
    END GET_CONTACT_DTLS;

    PROCEDURE SAVE_INTO_GOAML_TRAN_MASTER (
        P_SEQ_NO                     IN NUMBER,
        P_BRN_CODE                   IN NUMBER,
        P_YEAR                       IN NUMBER,
        P_MONTH                      IN NUMBER,
        P_RTP_TYPE                   IN VARCHAR2,
        P_TRAN_BRN_CODE              IN NUMBER,
        P_TRAN_DATE_OF_TRAN          IN DATE,
        P_TRAN_BATCH_NUMBER          IN NUMBER,
        P_TRAN_BATCH_SL_NO           IN NUMBER,
        P_TRAN_NARR_DTL1             IN VARCHAR2,
        P_TRAN_NARR_DTL2             IN VARCHAR2,
        P_TRAN_NARR_DTL3             IN VARCHAR2,
        P_TRAN_AUTH_BY               IN VARCHAR2,
        P_TRAN_AMOUNT                IN NUMBER,
        P_TRAN_BASE_CURR_CONV_RATE   IN NUMBER,
        P_TRAN_DB_CR_FLG             IN CHAR,
        P_TRAN_ENTD_BY               IN VARCHAR2,
        P_TRAN_VALUE_DATE            IN DATE,
        P_CLIENTS_TYPE_FLG           IN VARCHAR2,
        P_CLIENTS_CODE               IN NUMBER)
    IS
        V_TRXN_NUM                       VARCHAR2 (100);
        V_TRXN_LOCATION                  VARCHAR2 (100);
        V_TRXN_DESC                      VARCHAR2 (300);
        V_TRAN_MODE_CODE                 VARCHAR2 (10);
        V_AMOUNT                         VARCHAR2 (30);
        V_FROM_FUNDS_CODE                VARCHAR2 (10);
        V_TELLER                         VARCHAR2 (100);
        V_AUTH_BY                        VARCHAR2 (100);
        W_GOAML_TRAN_MASTER_INSERT_SQL   VARCHAR2 (1000);
    BEGIN
        V_TRXN_NUM :=
               P_TRAN_BRN_CODE
            || '/'
            || REPLACE (TO_CHAR (P_TRAN_DATE_OF_TRAN, 'YYYY-MM-DD'), '-', '')
            || '/'
            || P_TRAN_BATCH_NUMBER
            || '/'
            || P_TRAN_BATCH_SL_NO;
        V_TRXN_LOCATION := GET_BRN_DISTRICT_LOCATION (P_BRN_CODE);
        V_TRXN_DESC :=
            VALIDATE_FOR_XML (
                P_TRAN_NARR_DTL1 || P_TRAN_NARR_DTL2 || P_TRAN_NARR_DTL3);

        IF P_TRAN_BRN_CODE IS NULL
        THEN
            V_TRAN_MODE_CODE := '';
        ELSIF P_TRAN_AUTH_BY = 'CBSATM'
        THEN
            V_TRAN_MODE_CODE := 'S';
        ELSIF P_TRAN_BRN_CODE = P_BRN_CODE
        THEN
            V_TRAN_MODE_CODE := 'R';
        ELSE
            V_TRAN_MODE_CODE := 'T';
        END IF;

        V_AMOUNT :=
            VALIDATE_FOR_XML (
                TO_CHAR (P_TRAN_AMOUNT * P_TRAN_BASE_CURR_CONV_RATE,
                         '99999999999999.99'));
        V_TELLER := GET_USER_NAME (P_TRAN_ENTD_BY);
        V_AUTH_BY := GET_USER_NAME (P_TRAN_AUTH_BY);

        IF UPPER (P_TRAN_DB_CR_FLG) = 'D'
        THEN
            V_FROM_FUNDS_CODE := 'W';
        ELSIF UPPER (P_TRAN_DB_CR_FLG) = 'C'
        THEN
            V_FROM_FUNDS_CODE := 'K';
        ELSE
            V_FROM_FUNDS_CODE := '';
        END IF;

       <<INSERTINTOTRANMASTER>>
        BEGIN
            W_GOAML_TRAN_MASTER_INSERT_SQL :=
                'INSERT INTO GOAML_TRAN_MASTER (
                                       SEQ_NO,ENTITY_NUMBER,RPT_YEAR,
                                       RPT_MONTH,RPT_BRANCH_CODE,RTP_TYPE,
                                       TRANSACTIONNUMBER, TRANSACTIONLOCATION,
                                       TRANSACTIONDESCRIPTION,DATETRANSACTION,
                                       TELLER,AUTHORIZEDBY,VALUEDATETRANSACTION,
                                       TRANMODECODE,AMOUNTLOCAL,CREDITDEBIT,
                                       CLIENTTYPE,FROMFUNDSCODE,CLIENTNUMBER)
                                       VALUES (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,
                                       :12,:13,:14,:15,:16,:17,:18,:19)';

            EXECUTE IMMEDIATE W_GOAML_TRAN_MASTER_INSERT_SQL
                USING P_SEQ_NO,
                      SBL_ENTITY_NUM,
                      P_YEAR,
                      P_MONTH,
                      P_BRN_CODE,
                      P_RTP_TYPE,
                      V_TRXN_NUM,
                      V_TRXN_LOCATION,
                      V_TRXN_DESC,
                         TO_CHAR (P_TRAN_DATE_OF_TRAN, 'YYYY-MM-DD')
                      || 'T00:00:00',
                      V_TELLER,
                      V_AUTH_BY,
                         TO_CHAR (P_TRAN_VALUE_DATE, 'YYYY-MM-DD')
                      || 'T00:00:00',
                      V_TRAN_MODE_CODE,
                      V_AMOUNT,
                      UPPER (P_TRAN_DB_CR_FLG),
                      P_CLIENTS_TYPE_FLG,
                      V_FROM_FUNDS_CODE,
                      P_CLIENTS_CODE;
        EXCEPTION
            WHEN OTHERS
            THEN
                RAISE_APPLICATION_ERROR (
                    W_ERROR_CODE_1,
                       SQLERRM
                    || ' FOR '
                    || P_CLIENTS_CODE
                    || ' IN SAVE_INTO_GOAML_TRAN_MASTER:INSERTINTOTRANMASTER');
        END INSERTINTOTRANMASTER;
    END SAVE_INTO_GOAML_TRAN_MASTER;

    PROCEDURE SAVE_INTO_GOAML_INDV (P_SEQ_NO           IN NUMBER,
                                    P_CLIENTS_CODE     IN NUMBER,
                                    P_INTERNAL_ACNUM   IN NUMBER,
                                    P_TRAN_DB_CR_FLG   IN VARCHAR2,
                                    P_IS_PRIMARY       IN VARCHAR2,
                                    P_CONNROLE         IN VARCHAR2,
                                    P_FIRST_NAME       IN VARCHAR2,
                                    P_LAST_NAME        IN VARCHAR2)
    IS
        V_TO_FUNDS_CODE                VARCHAR (10);
        V_AC_BRN_CODE                  NUMBER (6);
        V_AC_CURR_CODE                 VARCHAR2 (3);
        V_AC_NAME                      VARCHAR2 (100);
        V_AC_CLIENT_NUM                VARCHAR2 (100);
        V_AC_TYPE                      VARCHAR2 (20);
        V_ACTUAL_ACNUM                 VARCHAR2 (20);
        V_CLIENTS_TYPE_FLG             VARCHAR2 (2);

        V_FIRST_NAME                   VARCHAR2 (100);
        V_MIDDLE_NAME                  VARCHAR2 (100);
        V_LAST_NAME                    VARCHAR2 (100);
        V_FATHER_NAME                  VARCHAR2 (100);
        V_E_SPOUSE_NAME                VARCHAR2 (100);
        V_RESIDENT_STATUS              VARCHAR2 (100);
        V_EMAIL                        VARCHAR2 (100);
        V_SEX                          VARCHAR2 (100);
        V_MOTHER_NAME                  VARCHAR2 (100);
        V_BIRTH_DATE                   VARCHAR2 (100);
        V_BIRTH_PLACE                  VARCHAR2 (100);
        V_OCCUPATIONS_DESCN            VARCHAR2 (100);
        V_SUR_NAME                     VARCHAR2 (100);
        V_TITLE                        VARCHAR2 (50);

        Q_PID_QUERY                    TM_CLIENT_IDS;
        V_ID_ISSUE_CNTRY               VARCHAR2 (3);
        V_DL_ID_NO                     VARCHAR2 (35);
        V_NID_NO                       VARCHAR2 (35);
        V_BC_NO                        VARCHAR2 (35);
        V_SID_NO                       VARCHAR2 (35);
        V_PP_NO                        VARCHAR2 (35);
        V_PP_ISSUE_CNTRY               VARCHAR2 (100);

        V_PRESENTADDRESS1              VARCHAR2 (100);
        V_PRESENTADDRESS2              VARCHAR2 (100);
        V_PRESENT_TOWN                 VARCHAR2 (100);
        V_PRESENT_CITY                 VARCHAR2 (100);
        V_PRESENT_ZIP                  VARCHAR2 (100);
        V_PRESENT_COUNTRY              VARCHAR2 (100);
        V_PRESENT_STATE                VARCHAR2 (100);
        V_PERMADDRESS                  VARCHAR2 (100);
        V_PERMTOWN                     VARCHAR2 (100);
        V_PERMCITY                     VARCHAR2 (100);
        V_PERMZIP                      VARCHAR2 (100);
        V_PERMCOUNTRY                  VARCHAR2 (100);
        V_PERMSTATE                    VARCHAR2 (100);

        V_PHONE_NUM                    VARCHAR2 (15);
        V_MOBILE_NO                    VARCHAR2 (15);

        W_GOAML_TRAN_INDV_INSERT_SQL   CLOB;
    BEGIN
        IF UPPER (P_TRAN_DB_CR_FLG) = 'D'
        THEN
            V_TO_FUNDS_CODE := 'K';
        ELSIF UPPER (P_TRAN_DB_CR_FLG) = 'C'
        THEN
            V_TO_FUNDS_CODE := 'A';
        ELSE
            V_TO_FUNDS_CODE := '';
        END IF;

        GET_CONTACT_DTLS (P_CLIENTS_CODE,
                          V_PRESENTADDRESS1,
                          V_PRESENTADDRESS2,
                          V_PRESENT_TOWN,
                          V_PRESENT_CITY,
                          V_PRESENT_ZIP,
                          V_PRESENT_COUNTRY,
                          V_PRESENT_STATE,
                          V_PERMADDRESS,
                          V_PERMTOWN,
                          V_PERMCITY,
                          V_PERMZIP,
                          V_PERMCOUNTRY,
                          V_PERMSTATE,
                          V_PHONE_NUM,
                          V_MOBILE_NO);

       <<GETCLIENTACNTSDTLS>>
        BEGIN
            SELECT ACNTS_BRN_CODE,
                   ACNTS_CURR_CODE,
                   ACNTS_AC_NAME1,
                   ACNTS_CLIENT_NUM,
                   ACNTS_AC_TYPE,
                   IACLINK_ACTUAL_ACNUM,
                   CLIENTS_TYPE_FLG
              INTO V_AC_BRN_CODE,
                   V_AC_CURR_CODE,
                   V_AC_NAME,
                   V_AC_CLIENT_NUM,
                   V_AC_TYPE,
                   V_ACTUAL_ACNUM,
                   V_CLIENTS_TYPE_FLG
              FROM ACNTS,
                   MBRN,
                   IACLINK,
                   CLIENTS,
                   ACNTBAL
             WHERE     MBRN_ENTITY_NUM = ACNTS_ENTITY_NUM
                   AND MBRN_CODE = ACNTS_BRN_CODE
                   AND ACNTS_ENTITY_NUM = IACLINK_ENTITY_NUM
                   AND ACNTS_INTERNAL_ACNUM = IACLINK_INTERNAL_ACNUM
                   AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                   AND ACNTS_ENTITY_NUM = ACNTBAL_ENTITY_NUM
                   AND ACNTBAL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                   AND ACNTS_INTERNAL_ACNUM = P_INTERNAL_ACNUM;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
            WHEN OTHERS
            THEN
                RAISE_APPLICATION_ERROR (
                    W_ERROR_CODE_1,
                       SQLERRM
                    || ' FOR '
                    || P_CLIENTS_CODE
                    || ' IN SAVE_INTO_GOAML_INDV:GETCLIENTACNTSDTLS');
        END GETCLIENTACNTSDTLS;

       <<GETCLIENTACTYPE>>
        BEGIN
            SELECT ACTYPE_GOAML_RPT_CODE
              INTO V_AC_TYPE
              FROM ACTYPES
             WHERE ACTYPE_CODE = V_AC_TYPE AND ROWNUM < 2;

            IF TRIM (V_AC_TYPE) IS NULL
            THEN
                V_AC_TYPE := 'R';
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                V_AC_TYPE := 'R';
            WHEN OTHERS
            THEN
                RAISE_APPLICATION_ERROR (
                    W_ERROR_CODE_1,
                       SQLERRM
                    || ' FOR '
                    || P_CLIENTS_CODE
                    || ' IN SAVE_INTO_GOAML_INDV:GETCLIENTACTYPE');
        END GETCLIENTACTYPE;

       <<GETINDVDTLS>>
        BEGIN
            SELECT TRIM (INDCLIENT_FIRST_NAME),
                   TRIM (
                          TRIM (INDCLIENT_LAST_NAME)
                       || ' '
                       || TRIM (INDCLIENT_SUR_NAME)),
                   INDCLIENT_FATHER_NAME,
                   INDSPOUSE_SPOUSE_NAME,
                   INDCLIENT_RESIDENT_STATUS,
                   INDCLIENT_EMAIL_ADDR1,
                   CASE
                       WHEN UPPER (INDCLIENT_SEX) = 'T' THEN 'O'
                       ELSE UPPER (INDCLIENT_SEX)
                   END,
                   INDCLIENT_MOTHER_NAME,
                   TO_CHAR (INDCLIENT_BIRTH_DATE, 'YYYY-MM-DD'),
                   OCCUPATIONS_DESCN,
                   TRIM (
                          TRIM (INDCLIENT_LAST_NAME)
                       || ' '
                       || TRIM (INDCLIENT_SUR_NAME)),
                   (SELECT TITLES_DESCN
                      FROM TITLES
                     WHERE TITLES_CODE = CLIENTS_TITLE_CODE)
                       TITLE_DESCN
              INTO V_FIRST_NAME,
                   V_LAST_NAME,
                   V_FATHER_NAME,
                   V_E_SPOUSE_NAME,
                   V_RESIDENT_STATUS,
                   V_EMAIL,
                   V_SEX,
                   V_MOTHER_NAME,
                   V_BIRTH_DATE,
                   V_OCCUPATIONS_DESCN,
                   V_SUR_NAME,
                   V_TITLE
              FROM INDCLIENTS
                   LEFT JOIN OCCUPATIONS
                       ON OCCUPATIONS_CODE = INDCLIENT_OCCUPN_CODE
                   LEFT JOIN INDCLIENTSPOUSE
                       ON INDSPOUSE_CLIENT_CODE = INDCLIENT_CODE
                   LEFT JOIN CLIENTS ON CLIENTS_CODE = INDCLIENT_CODE
             WHERE INDCLIENT_CODE = P_CLIENTS_CODE;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
            WHEN OTHERS
            THEN
                RAISE_APPLICATION_ERROR (
                    W_ERROR_CODE_1,
                       SQLERRM
                    || ' FOR '
                    || P_CLIENTS_CODE
                    || ' IN SAVE_INTO_GOAML_INDV:GETINDVDTLS');
        END GETINDVDTLS;

       <<COLLECTPIDS>>
        BEGIN
            SELECT PIDDOCS_PID_TYPE,
                   PIDDOCS_DOCID_NUM,
                   PIDDOCS_ISSUE_DATE,
                   PIDDOCS_EXP_DATE,
                   PIDDOCS_ISSUE_CNTRY
              BULK COLLECT INTO Q_PID_QUERY
              FROM CLIENTS
                   INNER JOIN PIDDOCS
                       ON TO_CHAR (CLIENTS_CODE) = PIDDOCS_SOURCE_KEY
             WHERE     PIDDOCS_PID_TYPE IN ('PP',
                                            'NID',
                                            'SID',
                                            'BC',
                                            'DL')
                   AND CLIENTS_CODE = P_CLIENTS_CODE;

            IF Q_PID_QUERY.COUNT < 1
            THEN
                SELECT TRIM (PIDDOCS_PID_TYPE),
                       PIDDOCS_DOCID_NUM,
                       PIDDOCS_ISSUE_DATE,
                       PIDDOCS_EXP_DATE,
                       NVL (TRIM (PIDDOCS_ISSUE_CNTRY), 'BD')
                  BULK COLLECT INTO Q_PID_QUERY
                  FROM CLIENTS
                       INNER JOIN JOINTCLIENTSDTL
                           ON CLIENTS_CODE = JNTCLDTL_CLIENT_CODE
                       INNER JOIN PIDDOCS
                           ON TO_CHAR (JNTCLDTL_INDIV_CLIENT_CODE) =
                              PIDDOCS_SOURCE_KEY
                 WHERE     PIDDOCS_PID_TYPE IN ('PP',
                                                'NID',
                                                'SID',
                                                'BC',
                                                'DL')
                       AND CLIENTS_CODE = P_CLIENTS_CODE;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
            WHEN OTHERS
            THEN
                RAISE_APPLICATION_ERROR (
                    W_ERROR_CODE_1,
                       SQLERRM
                    || ' FOR '
                    || P_CLIENTS_CODE
                    || ' IN SAVE_INTO_GOAML_INDV:COLLECTPERSONALIDS');
        END COLLECTPIDS;

        IF Q_PID_QUERY.FIRST IS NOT NULL
        THEN
            FOR IDX IN 1 .. Q_PID_QUERY.COUNT
            LOOP
                IF Q_PID_QUERY (IDX).PID_TYPE = 'PP'
                THEN
                    V_PP_NO := VALIDATE_FOR_XML (Q_PID_QUERY (IDX).DOCID_NUM);
                    V_PP_ISSUE_CNTRY :=
                        NVL (TRIM (Q_PID_QUERY (IDX).ISSUE_CNTRY), 'BD');
                    CONTINUE;
                ELSIF Q_PID_QUERY (IDX).PID_TYPE = 'DL'
                THEN
                    V_DL_ID_NO :=
                        VALIDATE_FOR_XML (Q_PID_QUERY (IDX).DOCID_NUM);
                ELSIF Q_PID_QUERY (IDX).PID_TYPE = 'NID'
                THEN
                    V_NID_NO :=
                        VALIDATE_FOR_XML (Q_PID_QUERY (IDX).DOCID_NUM);
                ELSIF Q_PID_QUERY (IDX).PID_TYPE = 'BC'
                THEN
                    V_BC_NO := VALIDATE_FOR_XML (Q_PID_QUERY (IDX).DOCID_NUM);
                ELSIF Q_PID_QUERY (IDX).PID_TYPE = 'SID'
                THEN
                    V_SID_NO :=
                        VALIDATE_FOR_XML (Q_PID_QUERY (IDX).DOCID_NUM);
                END IF;

                V_ID_ISSUE_CNTRY :=
                    NVL (TRIM (Q_PID_QUERY (IDX).ISSUE_CNTRY), 'BD');
            END LOOP;
        END IF;

        IF P_FIRST_NAME IS NOT NULL
        THEN
            V_FIRST_NAME := P_FIRST_NAME;
        END IF;

        IF P_LAST_NAME IS NOT NULL
        THEN
            V_SUR_NAME := P_LAST_NAME;
        END IF;

       <<INSERTGOAMLTRANINDV>>
        BEGIN
            W_GOAML_TRAN_INDV_INSERT_SQL :=
                'INSERT INTO GOAML_TRAN_INDV(
                                   CLIENTNUMBER, SEQ_NO, GENDER, TITLE, FIRSTNAME, PREFIX,
                                   LASTNAME, BIRTHDATE, BIRTHPLACE, MOTHERNAME, ALIAS_NAME,
                                   SSN, PASSPORTNUMBER, PASSPORTCOUNTRY, IDNUMBER, NATIONALITY,
                                   RESIDENCE, MOBILENUMBER, PHONENUMBER, PRESENTADRESS1,
                                   PRESENTADRESS2, PRESENTTOWN, PRESENTCITY, PRESENTZIP,
                                   PRESENTCOUNTRY, PRESENTSTATE, EMAIL, OCCUPATION, EMPLOYERNAME,
                                   IDENTIFICATIONTYPE, IDENTITFUCATIONNUMBER, IDENTIFICATIONISSUEDATE,
                                   IDENTIFICATIONEXPIRYDATE, IDENTIFICATIONISSUECOUNTRY, TOFUNDSCODE,
                                   BRANCHINFORMATION, ACCOUNT_INFO, CURRENCY, ACCOUNTNAME,
                                   PERSONALACCOUNTTYPE, IS_PRIMARY, CONNECTED_ROLE, MIDDLENAME,
                                   SID, PERMADDRESS, PERMTOWN, PERMCITY, PERMZIP, PERMCOUNTRY,
                                   PERMSTATE, DRIVING_LICENCE,BIRTH_CERTIFICATE)
                                   VALUES (
                                   :1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,:18,:19,
                                   :20,:21,:22,:23,:24,:25,:26,:27,:28,:29,:30,:31,:32,:33,:34,:35,:36,
                                   :37,:38,:39,:40,:41,:42,:43,:44,:45,:46,:47,:48,:49,:50,:51,:52
                                   )';

            EXECUTE IMMEDIATE W_GOAML_TRAN_INDV_INSERT_SQL
                USING P_CLIENTS_CODE,
                      P_SEQ_NO,
                      V_SEX,
                      V_TITLE,
                      VALIDATE_FOR_XML (V_FIRST_NAME),
                      '',
                      VALIDATE_FOR_XML (V_SUR_NAME),
                      V_BIRTH_DATE,
                      V_BIRTH_PLACE,
                      VALIDATE_FOR_XML (V_MOTHER_NAME),
                      VALIDATE_FOR_XML (V_FATHER_NAME),
                      V_NID_NO,
                      V_PP_NO,
                      V_PP_ISSUE_CNTRY,
                      '',
                      NVL (TRIM (V_ID_ISSUE_CNTRY), 'BD'),
                      'BD',
                      V_MOBILE_NO,
                      V_PHONE_NUM,
                      V_PRESENTADDRESS1,
                      V_PRESENTADDRESS2,
                      V_PRESENT_TOWN,
                      V_PRESENT_CITY,
                      V_PRESENT_ZIP,
                      V_PRESENT_COUNTRY,
                      V_PRESENT_STATE,
                      V_EMAIL,
                      VALIDATE_FOR_XML (V_OCCUPATIONS_DESCN),
                      '',
                      '',
                      '',
                      '',
                      '',
                      V_ID_ISSUE_CNTRY,
                      V_TO_FUNDS_CODE,
                      GET_BRN_DISTRICT_LOCATION (V_AC_BRN_CODE),
                      V_ACTUAL_ACNUM,
                      V_AC_CURR_CODE,
                      VALIDATE_FOR_XML (V_AC_NAME),
                      V_AC_TYPE,
                      P_IS_PRIMARY,
                      P_CONNROLE,
                      V_MIDDLE_NAME,
                      V_SID_NO,
                      V_PERMADDRESS,
                      V_PERMTOWN,
                      V_PERMCITY,
                      V_PERMZIP,
                      V_PERMCOUNTRY,
                      V_PERMSTATE,
                      V_DL_ID_NO,
                      V_BC_NO;
        EXCEPTION
            WHEN OTHERS
            THEN
                RAISE_APPLICATION_ERROR (
                    W_ERROR_CODE_1,
                       SQLERRM
                    || ' FOR '
                    || P_CLIENTS_CODE
                    || ' IN SAVE_INTO_GOAML_INDV:INSERTGOAMLTRANINDV');
        END INSERTGOAMLTRANINDV;
    END SAVE_INTO_GOAML_INDV;

    PROCEDURE SAVE_INTO_GOAML_CORP (P_SEQ_NO           IN NUMBER,
                                    P_CLIENTS_CODE     IN NUMBER,
                                    P_INTERNAL_ACNUM   IN NUMBER,
                                    P_TRAN_DB_CR_FLG   IN VARCHAR2)
    IS
        V_CORP_BUS                     VARCHAR2 (150);
        V_CORP_ENTITY_NAME             VARCHAR2 (100);
        V_CORP_INC_STATE               VARCHAR2 (50) := 'Bangladesh';
        V_CORP_INC_CNTRY_CD            VARCHAR2 (10);
        V_CORP_INC_NO                  VARCHAR2 (100);
        V_CORP_CONST_CODE              VARCHAR2 (100);
        V_CORP_INC_LEGAL_FORM          VARCHAR2 (100);
        V_CORP_INC_DATE                VARCHAR2 (25);
        V_TAX_NO                       VARCHAR2 (100);

        V_CORP_CLIENT_NUM              VARCHAR2 (12);
        V_IS_PRIMARY                   VARCHAR2 (2);
        V_CONNROLE                     VARCHAR2 (35);

        V_PRESENTADDRESS1              VARCHAR2 (100);
        V_PRESENTADDRESS2              VARCHAR2 (100);
        V_PRESENT_TOWN                 VARCHAR2 (100);
        V_PRESENT_CITY                 VARCHAR2 (100);
        V_PRESENT_ZIP                  VARCHAR2 (100);
        V_PRESENT_COUNTRY              VARCHAR2 (100);
        V_PRESENT_STATE                VARCHAR2 (100);
        V_PERMADDRESS                  VARCHAR2 (100);
        V_PERMTOWN                     VARCHAR2 (100);
        V_PERMCITY                     VARCHAR2 (100);
        V_PERMZIP                      VARCHAR2 (100);
        V_PERMCOUNTRY                  VARCHAR2 (100);
        V_PERMSTATE                    VARCHAR2 (100);

        V_PHONE_NUM                    VARCHAR2 (15);
        V_MOBILE_NO                    VARCHAR2 (15);

        W_INSERT_INTO_GOAML_CORP_SQL   CLOB;
        V_NAMES                        splitstr;

        Q_CLIENT_TYPE                  TM_CLIENT_TYPE;
    BEGIN
        BEGIN
            SELECT CLIENTS_NAME,
                   SEGMENTS_DESCN,
                   CASE
                       WHEN TRIM (CLIENTS_CONST_CODE) = '10' THEN 'B'
                       WHEN TRIM (CLIENTS_CONST_CODE) = '2' THEN 'A'
                       WHEN TRIM (CLIENTS_CONST_CODE) IN ('8', '13') THEN 'C'
                       WHEN TRIM (CLIENTS_CONST_CODE) = '9' THEN 'F'
                       ELSE 'J'
                   END
                       CORP_INC_LEGAL_FORM,
                   NVL (TRIM (CORPCL_REG_NUM), trim(CORPCLAH_TRADE_LICENSE))
                       CORPCL_REG_NUM,
                   CASE
                       WHEN NVL (CORPCL_REG_DATE,
                                 CORPCLAH_TRADE_LIC_ISS_DATE)
                                IS NOT NULL
                       THEN
                              TO_CHAR (
                                  NVL (CORPCL_REG_DATE,
                                       CORPCLAH_TRADE_LIC_ISS_DATE),
                                  'YYYY-MM-DD')
                           || 'T00:00:00'
                       ELSE
                           ''
                   END
                       CORPCL_REG_DATE,
                   CASE
                       WHEN TRIM (CORPCLAH_TRADE_LICENSE) IS NOT NULL
                       THEN
                           'BD'
                       ELSE
                           CORPCL_INCORP_CNTRY
                   END
                       CORPCL_INCORP_CNTRY,
                   CLIENTS_CONST_CODE,
                   TAX_NO
              INTO V_CORP_ENTITY_NAME,
                   V_CORP_BUS,
                   V_CORP_INC_LEGAL_FORM,
                   V_CORP_INC_NO,
                   V_CORP_INC_DATE,
                   V_CORP_INC_CNTRY_CD,
                   V_CORP_CONST_CODE,
                   V_TAX_NO
              FROM (SELECT CLIENTS_CODE,
                           CLIENTS_NAME,
                           SEGMENTS_DESCN,
                           CORPCL_REG_NUM,
                           CORPCL_REG_DATE,
                           NVL (TRIM (CORPCL_INCORP_CNTRY), 'BD')
                               CORPCL_INCORP_CNTRY,
                           CLIENTS_CONST_CODE,
                           COALESCE (CLIENTS_PAN_GIR_NUM,
                                     CLIENTS_VIN_NUM,
                                     '')
                               TAX_NO
                      FROM CLIENTS
                           INNER JOIN CORPCLIENTS
                               ON CORPCL_CLIENT_CODE = CLIENTS_CODE
                           LEFT JOIN SEGMENTS
                               ON SEGMENTS_CODE = CLIENTS_SEGMENT_CODE
                     WHERE CLIENTS_CODE = P_CLIENTS_CODE) A
                   LEFT JOIN CORPCLIENTSAHIST B
                       ON A.CLIENTS_CODE = B.CORPCLAH_CLIENT_CODE
             WHERE NVL (CORPCLAH_EFF_DATE, '01-JAN-1900') =
                   (SELECT NVL (MAX (CORPCLAH_EFF_DATE), '01-JAN-1900')
                      FROM CORPCLIENTSAHIST
                     WHERE CORPCLAH_CLIENT_CODE = A.CLIENTS_CODE);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
            WHEN OTHERS
            THEN
                RAISE_APPLICATION_ERROR (
                    W_ERROR_CODE_1,
                       SQLERRM
                    || ' FOR '
                    || P_CLIENTS_CODE
                    || ' IN SAVE_INTO_GOAML_CORP:GETCLIENTACTYPE');
        END;

       <<GETINCORPCOUNTRY>>
        BEGIN
            SELECT NVL (TRIM (CNTRY_NAME), 'Bangladesh')
              INTO V_CORP_INC_STATE
              FROM CNTRY
             WHERE CNTRY_CODE = V_CORP_INC_CNTRY_CD;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                V_CORP_INC_STATE := 'Bangladesh';
            WHEN OTHERS
            THEN
                RAISE_APPLICATION_ERROR (
                    W_ERROR_CODE_1,
                       SQLERRM
                    || ' FOR '
                    || P_CLIENTS_CODE
                    || ' IN SAVE_INTO_GOAML_CORP:GETINCORPCOUNTRY');
        END GETINCORPCOUNTRY;

        GET_CONTACT_DTLS (P_CLIENTS_CODE,
                          V_PRESENTADDRESS1,
                          V_PRESENTADDRESS2,
                          V_PRESENT_TOWN,
                          V_PRESENT_CITY,
                          V_PRESENT_ZIP,
                          V_PRESENT_COUNTRY,
                          V_PRESENT_STATE,
                          V_PERMADDRESS,
                          V_PERMTOWN,
                          V_PERMCITY,
                          V_PERMZIP,
                          V_PERMCOUNTRY,
                          V_PERMSTATE,
                          V_PHONE_NUM,
                          V_MOBILE_NO);

       <<GETCONNROLEDTLS>>
        BEGIN
              SELECT ACNTS_INTERNAL_ACNUM,
                     ACNTS_CLIENT_NUM,
                     ACNTS_AC_NAME1,
                     CONNROLE_CODE,
                     CONNROLE_DESCN,
                     CONNP_CLIENT_NUM,
                     CONNP_INTERNAL_ACNUM
                BULK COLLECT INTO Q_CLIENT_TYPE
                FROM ACNTS
                     LEFT JOIN CONNPINFO ON ACNTS_CONNP_INV_NUM = CONNP_INV_NUM
                     LEFT JOIN CONNROLE ON CONNROLE_CODE = CONNP_CONN_ROLE
               WHERE ACNTS_INTERNAL_ACNUM = P_INTERNAL_ACNUM
            ORDER BY DECODE (CONNROLE_CODE,
                             '16', 1,
                             '7', 2,
                             '4', 3,
                             '8', 4);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
            WHEN OTHERS
            THEN
                RAISE_APPLICATION_ERROR (
                    W_ERROR_CODE_1,
                       SQLERRM
                    || ' FOR '
                    || P_CLIENTS_CODE
                    || ' IN SAVE_INTO_GOAML_CORP:GETCONNROLEDTLS');
        END GETCONNROLEDTLS;

        IF Q_CLIENT_TYPE.FIRST IS NOT NULL
        THEN
            FOR IDX IN Q_CLIENT_TYPE.FIRST .. Q_CLIENT_TYPE.LAST
            LOOP
                IF Q_CLIENT_TYPE (IDX).CONNROLE_CODE = '16'
                THEN
                    V_CORP_CLIENT_NUM := Q_CLIENT_TYPE (IDX).CONNP_CLIENT_NUM;

                    IF V_CORP_CLIENT_NUM > 0
                    THEN
                        V_CONNROLE := Q_CLIENT_TYPE (IDX).CONNROLE_DESCN;
                        V_IS_PRIMARY := '1';
                        SAVE_INTO_GOAML_INDV (P_SEQ_NO,
                                              V_CORP_CLIENT_NUM,
                                              P_INTERNAL_ACNUM,
                                              P_TRAN_DB_CR_FLG,
                                              V_IS_PRIMARY,
                                              V_CONNROLE,
                                              NULL,
                                              NULL);
                    ELSIF Q_CLIENT_TYPE (IDX).AC_AC_NAME1 IS NOT NULL
                    THEN
                        V_NAMES :=
                            SPLIT (1, Q_CLIENT_TYPE (IDX).AC_AC_NAME1, ' ');
                        V_MID_LAST_NAME := '';

                        FOR i IN 2 .. V_NAMES.COUNT
                        LOOP
                            V_MID_LAST_NAME :=
                                V_MID_LAST_NAME || ' ' || V_NAMES (i);
                        END LOOP;

                        SAVE_INTO_GOAML_INDV (P_SEQ_NO,
                                              V_CORP_CLIENT_NUM,
                                              P_INTERNAL_ACNUM,
                                              P_TRAN_DB_CR_FLG,
                                              V_IS_PRIMARY,
                                              V_CONNROLE,
                                              V_NAMES (1),
                                              TRIM (V_MID_LAST_NAME));
                    END IF;
                ELSIF Q_CLIENT_TYPE (IDX).CONNROLE_CODE = '7'
                THEN
                    V_CORP_CLIENT_NUM := Q_CLIENT_TYPE (IDX).CONNP_CLIENT_NUM;

                    IF V_CORP_CLIENT_NUM IS NOT NULL
                    THEN
                        V_CONNROLE := Q_CLIENT_TYPE (IDX).CONNROLE_DESCN;

                        IF V_IS_PRIMARY IS NULL
                        THEN
                            V_IS_PRIMARY := '1';
                        ELSE
                            V_IS_PRIMARY := '0';
                        END IF;

                        SAVE_INTO_GOAML_INDV (P_SEQ_NO,
                                              V_CORP_CLIENT_NUM,
                                              P_INTERNAL_ACNUM,
                                              P_TRAN_DB_CR_FLG,
                                              V_IS_PRIMARY,
                                              V_CONNROLE,
                                              NULL,
                                              NULL);
                    ELSIF Q_CLIENT_TYPE (IDX).AC_AC_NAME1 IS NOT NULL
                    THEN
                        V_NAMES :=
                            SPLIT (1, Q_CLIENT_TYPE (IDX).AC_AC_NAME1, ' ');
                        V_MID_LAST_NAME := '';

                        FOR i IN 2 .. V_NAMES.COUNT
                        LOOP
                            V_MID_LAST_NAME :=
                                V_MID_LAST_NAME || ' ' || V_NAMES (i);
                        END LOOP;

                        SAVE_INTO_GOAML_INDV (P_SEQ_NO,
                                              V_CORP_CLIENT_NUM,
                                              P_INTERNAL_ACNUM,
                                              P_TRAN_DB_CR_FLG,
                                              V_IS_PRIMARY,
                                              V_CONNROLE,
                                              V_NAMES (1),
                                              TRIM (V_MID_LAST_NAME));
                    END IF;
                ELSIF Q_CLIENT_TYPE (IDX).CONNROLE_CODE = '4'
                THEN
                    V_CORP_CLIENT_NUM := Q_CLIENT_TYPE (IDX).CONNP_CLIENT_NUM;

                    IF V_CORP_CLIENT_NUM IS NOT NULL
                    THEN
                        V_CONNROLE := Q_CLIENT_TYPE (IDX).CONNROLE_DESCN;

                        IF V_IS_PRIMARY IS NULL
                        THEN
                            V_IS_PRIMARY := '1';
                        ELSE
                            V_IS_PRIMARY := '0';
                        END IF;

                        SAVE_INTO_GOAML_INDV (P_SEQ_NO,
                                              V_CORP_CLIENT_NUM,
                                              P_INTERNAL_ACNUM,
                                              P_TRAN_DB_CR_FLG,
                                              V_IS_PRIMARY,
                                              V_CONNROLE,
                                              NULL,
                                              NULL);
                    END IF;
                ELSIF Q_CLIENT_TYPE (IDX).CONNROLE_CODE = '8'
                THEN
                    V_CORP_CLIENT_NUM := Q_CLIENT_TYPE (IDX).CONNP_CLIENT_NUM;

                    IF V_CORP_CLIENT_NUM IS NOT NULL
                    THEN
                        V_CONNROLE := Q_CLIENT_TYPE (IDX).CONNROLE_DESCN;

                        IF V_IS_PRIMARY IS NULL
                        THEN
                            V_IS_PRIMARY := '1';
                        ELSE
                            V_IS_PRIMARY := '0';
                        END IF;

                        SAVE_INTO_GOAML_INDV (P_SEQ_NO,
                                              V_CORP_CLIENT_NUM,
                                              P_INTERNAL_ACNUM,
                                              P_TRAN_DB_CR_FLG,
                                              V_IS_PRIMARY,
                                              V_CONNROLE,
                                              NULL,
                                              NULL);
                    END IF;
                END IF;

                V_IS_PRIMARY := NULL;
            END LOOP;
        END IF;

       <<INSERTINTOGOAMLTRANCORP>>
        BEGIN
            W_INSERT_INTO_GOAML_CORP_SQL :=
                'INSERT INTO GOAML_TRAN_CORPORATE
        (ENTITY_NAME, ENTITY_COMR_NAME, INCORPORATION_NO,
         INCORPORATION_LEGAL_FORM, INCORPORATION_STATE,
         INCORPORATION_COUNTRY_CODE, INCORPORATION_DATE,
         TAX_NO, BUSINESS, PRESENTADRESS1, PRESENTADRESS2,
         PRESENTTOWN, PRESENTCITY, PRESENTZIP,
         PRESENTCOUNTRY, PRESENTSTATE, MOBILE_NO,
         PHONE_NO, CLIENTNUMBER, SEQ_NO, ACCOUNT_NO)
      VALUES
        (:1, :2, :3, :4, :5, :6, :7, :8, :9,
        :10, :11, :12, :13, :14, :15, :
        16, :17, :18, :19, :20, :21)';

            EXECUTE IMMEDIATE W_INSERT_INTO_GOAML_CORP_SQL
                USING VALIDATE_FOR_XML (V_CORP_ENTITY_NAME),
                      VALIDATE_FOR_XML (V_CORP_ENTITY_NAME),
                      V_CORP_INC_NO,
                      V_CORP_INC_LEGAL_FORM,
                      V_CORP_INC_STATE,
                      V_CORP_INC_CNTRY_CD,
                      V_CORP_INC_DATE,
                      V_TAX_NO,
                      V_CORP_BUS,
                      V_PRESENTADDRESS1,
                      V_PRESENTADDRESS2,
                      V_PRESENT_TOWN,
                      V_PRESENT_CITY,
                      V_PRESENT_ZIP,
                      V_PRESENT_COUNTRY,
                      V_PRESENT_STATE,
                      V_MOBILE_NO,
                      V_PHONE_NUM,
                      P_CLIENTS_CODE,
                      P_SEQ_NO,
                      P_INTERNAL_ACNUM;
        EXCEPTION
            WHEN OTHERS
            THEN
                RAISE_APPLICATION_ERROR (
                    W_ERROR_CODE_1,
                       SQLERRM
                    || ' FOR '
                    || P_CLIENTS_CODE
                    || ' IN SAVE_INTO_GOAML_CORP:INSERTINTOGOAMLTRANCORP');
        END INSERTINTOGOAMLTRANCORP;
    END SAVE_INTO_GOAML_CORP;

    PROCEDURE GENERATE_GOAML_RPT_FOR_BRN (P_YEAR       IN NUMBER,
                                          P_MONTH      IN NUMBER,
                                          P_BRN_CODE   IN NUMBER,
                                          P_RTP_TYPE   IN VARCHAR2)
    IS
        Q_QUERY_RESULTS   TM_GOAML_DATA;
        W_QUERY_SQL       CLOB;
        V_SEQ_NO          NUMBER (18);
        V_CLIENT_EXISTS   BOOLEAN;
    BEGIN
        DELETE_GOAML_RPT_RECORDS (P_YEAR,
                                  P_MONTH,
                                  P_BRN_CODE,
                                  P_RTP_TYPE);

        IF P_RTP_TYPE = 'CTR'
        THEN
            BEGIN
                W_QUERY_SQL :=
                    'SELECT TRAN_BRN_CODE, TRAN_BATCH_NUMBER, TRAN_NARR_DTL1,
               TRAN_NARR_DTL2,TRAN_NARR_DTL3, TRAN_DATE_OF_TRAN,
               TRAN_VALUE_DATE, TRAN_ENTD_BY, TRAN_AUTH_BY,
               TRAN_CODE, TRAN_AMOUNT, TRAN_BATCH_SL_NUM,
               TRAN_TYPE_OF_TRAN, TRAN_DB_CR_FLG, TRAN_INTERNAL_ACNUM,
               TRAN_BASE_CURR_CONV_RATE, TRAN_BATCH_SL_NO,
               CLIENTS_CONST_CODE, CLIENTS_TYPE_FLG, CLIENTS_CODE, RPT_BRN
               FROM GOAML_DATA WHERE RPT_BRN = :1
               AND RPT_YEAR = :2
               AND RPT_MONTH= :3';

                EXECUTE IMMEDIATE W_QUERY_SQL
                    BULK COLLECT INTO Q_QUERY_RESULTS
                    USING P_BRN_CODE, P_YEAR, P_MONTH;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    NULL;
            END;
        ELSE
            BEGIN
                --STR NOT VERIFIED YET
                W_QUERY_SQL := 'SELECT TRAN_BRN_CODE, TRAN_BATCH_NUMBER,
               TRAN_NARR_DTL1, TRAN_NARR_DTL2,
               TRAN_NARR_DTL3, TRAN_DATE_OF_TRAN,
               TRAN_VALUE_DATE, TRAN_ENTD_BY,
               TRAN_AUTH_BY, TRAN_CODE,
               TRAN_AMOUNT, TRAN_BATCH_SL_NUM,
               TRAN_TYPE_OF_TRAN, TRAN_DB_CR_FLG,
               TRAN_INTERNAL_ACNUM,
               TRAN_BASE_CURR_CONV_RATE,
               TRAN_BATCH_SL_NUM
               FROM STRMARK INNER JOIN TRAN:1 ON
               STRMARK_ACNUM_INVOLVED = TRAN_INTERNAL_ACNUM
               AND STRMARK_TRAN_BATCH = TRAN_BATCH_NUMBER
               AND STRMARK_TRAN_BATCH_SERIAL = TRAN_BATCH_SL_NUM
               AND STRMARK_TRAN_DATE = TRAN_VALUE_DATE WHERE
               TO_CHAR(STRMARK_TRAN_DATE, ''MON-YYYY'') = :2
               AND STRMARK_BRN_CODE=:3';

                EXECUTE IMMEDIATE W_QUERY_SQL
                    BULK COLLECT INTO Q_QUERY_RESULTS
                    USING P_YEAR, P_MONTH || '-' || P_YEAR, P_BRN_CODE;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    NULL;
            END;
        END IF;

        IF Q_QUERY_RESULTS.FIRST IS NOT NULL
        THEN
            FOR IDX IN Q_QUERY_RESULTS.FIRST .. Q_QUERY_RESULTS.LAST
            LOOP
                BEGIN
                    SELECT SEQ_NO
                      INTO V_SEQ_NO
                      FROM GOAML_TRAN_MASTER
                     WHERE     RPT_YEAR = P_YEAR
                           AND RPT_MONTH = P_MONTH
                           AND RPT_BRANCH_CODE = P_BRN_CODE
                           AND RTP_TYPE = P_RTP_TYPE
                           AND CLIENTNUMBER =
                               Q_QUERY_RESULTS (IDX).CLIENTS_CODE
                           AND ROWNUM < 2;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        V_SEQ_NO := 0;
                END;

                IF V_SEQ_NO <> 0
                THEN
                    V_CLIENT_EXISTS := TRUE;
                ELSE
                    SELECT GOAML_REC_SEQ.NEXTVAL INTO V_SEQ_NO FROM DUAL;

                    V_CLIENT_EXISTS := FALSE;
                END IF;

                IF     P_RTP_TYPE = 'CTR'
                   AND (   TO_CHAR (Q_QUERY_RESULTS (IDX).CLIENTS_CONST_CODE) =
                           GOVT_ACC_FLAG
                        OR TO_CHAR (Q_QUERY_RESULTS (IDX).CLIENTS_CONST_CODE) =
                           OTHER_GOVT_ACC_FLAG)
                   AND Q_QUERY_RESULTS (IDX).TRAN_DB_CR_FLG = 'C'
                THEN
                    CONTINUE;
                END IF;

                SAVE_INTO_GOAML_TRAN_MASTER (
                    V_SEQ_NO,
                    P_BRN_CODE,
                    P_YEAR,
                    P_MONTH,
                    P_RTP_TYPE,
                    Q_QUERY_RESULTS (IDX).TRAN_BRN_CODE,
                    Q_QUERY_RESULTS (IDX).TRAN_DATE_OF_TRAN,
                    Q_QUERY_RESULTS (IDX).TRAN_BATCH_NUMBER,
                    Q_QUERY_RESULTS (IDX).TRAN_BATCH_SL_NO,
                    Q_QUERY_RESULTS (IDX).TRAN_NARR_DTL1,
                    Q_QUERY_RESULTS (IDX).TRAN_NARR_DTL2,
                    Q_QUERY_RESULTS (IDX).TRAN_NARR_DTL3,
                    Q_QUERY_RESULTS (IDX).TRAN_AUTH_BY,
                    Q_QUERY_RESULTS (IDX).TRAN_AMOUNT,
                    Q_QUERY_RESULTS (IDX).TRAN_BASE_CURR_CONV_RATE,
                    Q_QUERY_RESULTS (IDX).TRAN_DB_CR_FLG,
                    Q_QUERY_RESULTS (IDX).TRAN_ENTD_BY,
                    Q_QUERY_RESULTS (IDX).TRAN_VALUE_DATE,
                    Q_QUERY_RESULTS (IDX).CLIENTS_TYPE_FLG,
                    Q_QUERY_RESULTS (IDX).CLIENTS_CODE);

                IF V_CLIENT_EXISTS = FALSE
                THEN
                    IF Q_QUERY_RESULTS (IDX).CLIENTS_TYPE_FLG = 'C'
                    THEN
                        SAVE_INTO_GOAML_CORP (
                            V_SEQ_NO,
                            Q_QUERY_RESULTS (IDX).CLIENTS_CODE,
                            Q_QUERY_RESULTS (IDX).TRAN_INTERNAL_ACNUM,
                            Q_QUERY_RESULTS (IDX).TRAN_DB_CR_FLG);
                    ELSIF Q_QUERY_RESULTS (IDX).CLIENTS_TYPE_FLG = 'I'
                    THEN
                        SAVE_INTO_GOAML_INDV (
                            V_SEQ_NO,
                            Q_QUERY_RESULTS (IDX).CLIENTS_CODE,
                            Q_QUERY_RESULTS (IDX).TRAN_INTERNAL_ACNUM,
                            Q_QUERY_RESULTS (IDX).TRAN_DB_CR_FLG,
                            NULL,
                            NULL,
                            NULL,
                            NULL);
                    ELSIF Q_QUERY_RESULTS (IDX).CLIENTS_TYPE_FLG = 'J'
                    THEN
                        FOR I
                            IN (  SELECT JNTCLDTL_INDIV_CLIENT_CODE
                                   FROM JOINTCLIENTSDTL
                                  WHERE JNTCLDTL_CLIENT_CODE =
                                        Q_QUERY_RESULTS (IDX).CLIENTS_CODE
                               ORDER BY JNTCLDTL_PRIMARY_APPLICANT DESC)
                        LOOP
                            SAVE_INTO_GOAML_INDV (
                                V_SEQ_NO,
                                I.JNTCLDTL_INDIV_CLIENT_CODE,
                                Q_QUERY_RESULTS (IDX).TRAN_INTERNAL_ACNUM,
                                Q_QUERY_RESULTS (IDX).TRAN_DB_CR_FLG,
                                NULL,
                                NULL,
                                NULL,
                                NULL);
                        END LOOP;
                    END IF;
                END IF;
            END LOOP;
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            W_ERROR_MSG := SUBSTR (SQLERRM, 0, 999);
            ROLLBACK;

            INSERT INTO GOAML_DATA_GEN_ERROR (ERROR_ID, ERROR_MSG)
                 VALUES (GOAML_DATA_GEN_ERROR_SEQ.NEXTVAL, W_ERROR_MSG);

            COMMIT;
    END GENERATE_GOAML_RPT_FOR_BRN;

    PROCEDURE GENERATE_GOAML_RPT (P_BRNLIST_CODE   IN NUMBER,
                                  P_BRN_CODE       IN NUMBER,
                                  P_RTP_TYPE       IN VARCHAR2,
                                  P_YEAR           IN NUMBER,
                                  P_MONTH          IN NUMBER)
    IS
    BEGIN
        IF IS_GOAML_PROCESS_RUNNING = TRUE
        THEN
            RETURN;
        END IF;

        BEGIN
            UPDATE_GOAML_PROCESS (GOAML_PROCESS_STARTED, GOAML_PROCESS_ID);

            DELETE FROM GOAML_DATA_GEN_ERROR;

            COMMIT;

            IF P_BRN_CODE = 0
            THEN
                IF P_BRNLIST_CODE <> 0
                THEN
                    FOR IDX IN (SELECT BRNLISTDTL_BRN_CODE
                                  FROM BRNLISTDTL
                                 WHERE BRNLISTDTL_LIST_NUM = P_BRNLIST_CODE)
                    LOOP
                        GENERATE_GOAML_RPT_FOR_BRN (P_YEAR,
                                                    P_MONTH,
                                                    IDX.BRNLISTDTL_BRN_CODE,
                                                    P_RTP_TYPE);
                    END LOOP;
                ELSE
                    FOR IDX IN (  SELECT MBRN_CODE
                                    FROM MBRN_CORE
                                   WHERE NONCORE = 0
                                ORDER BY MBRN_CODE ASC)
                    LOOP
                        GENERATE_GOAML_RPT_FOR_BRN (P_YEAR,
                                                    P_MONTH,
                                                    IDX.MBRN_CODE,
                                                    P_RTP_TYPE);
                    END LOOP;
                END IF;
            ELSE
                GENERATE_GOAML_RPT_FOR_BRN (P_YEAR,
                                            P_MONTH,
                                            P_BRN_CODE,
                                            P_RTP_TYPE);
            END IF;

            UPDATE_GOAML_PROCESS (GOAML_PROCESS_ENDED, GOAML_PROCESS_ID);
        EXCEPTION
            WHEN OTHERS
            THEN
                INSERT INTO GOAML_DATA_GEN_ERROR (ERROR_ID, ERROR_MSG)
                     VALUES (GOAML_DATA_GEN_ERROR_SEQ.NEXTVAL, W_ERROR_MSG);

                COMMIT;
        END;
    END GENERATE_GOAML_RPT;
END PKG_GEN_GOAML_RPT;
/

