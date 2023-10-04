CREATE OR REPLACE PACKAGE PKG_ALERTQ_MOBILE IS
  PROCEDURE SP_MOBILE_ALERTQ;
END PKG_ALERTQ_MOBILE;
/


CREATE OR REPLACE PACKAGE BODY PKG_ALERTQ_MOBILE
IS
   W_ERR_MSG                VARCHAR2 (200);
   W_SQL                    VARCHAR2 (4000);
   W_FIN_YEAR               NUMBER (4);
   W_PREV_DATE              DATE;
   V_TR_COUNT               NUMBER (6);
   V_PROC_SER_CODE          VARCHAR2 (8);
   V_CALL_CODE              VARCHAR2 (6);
   W_RESPONSE_MESSAGE       VARCHAR2 (1000);
   W_TEXT_MESSAGE           VARCHAR2 (1000);
   W_INST_NUM               NUMBER (15);
   W_INST_AMT               NUMBER (18, 3);
   W_INST_ACNT              NUMBER (14);
   W_CURY_CODE              VARCHAR2 (3);
   W_BRANCH_CODE            NUMBER (6);
   W_BRANCH_NAME            VARCHAR2 (50);
   W_BANK_NAME              VARCHAR2 (50);
   SERVICE_CODE             VARCHAR2 (10);
   BANK_CODE                NUMBER (3);
   W_MOBILE_WITH_CODE       VARCHAR2 (30);

   W_ACCOUNT_TYPE           CHAR (1);
   W_PRODUCT_CODE           NUMBER (4);
   W_LOAN_PRODUCT           CHAR (1);
   W_LAD_PRODUCT            CHAR (1);
   W_GUARANTOR_REQ          CHAR (1);

   TYPE LOAN_GUARANTOR IS TABLE OF NUMBER (12)
      INDEX BY PLS_INTEGER;

   LOAN_GUARANTOR_CLIENTS   LOAN_GUARANTOR;

   TYPE LAD_DEPOSITOR IS TABLE OF NUMBER (14)
      INDEX BY PLS_INTEGER;

   LAD_DEPOSITOR_ACNTS      LAD_DEPOSITOR;

   TYPE TRAN_RECORD IS RECORD
   (
      M_INTERNAL_ACNUM          NUMBER (14),
      M_CURR_CODE               VARCHAR2 (3),
      M_TRAN_ACING_BRN_CODE     NUMBER (6),
      M_PROD_CODE               NUMBER (4),
      M_TRAN_AMOUNT             NUMBER (18, 3),
      M_TRAN_DATE_OF_TRAN       DATE,
      M_TRAN_DB_CR_FLG          CHAR (1),
      M_TRAN_TYPE_OF_TRAN       CHAR (1),
      M_TRAN_CODE               VARCHAR2 (6),
      M_TRAN_INSTR_CHQ_NUMBER   NUMBER (15)
   );

   TYPE TM_TRAN_RECORD IS TABLE OF TRAN_RECORD
      INDEX BY PLS_INTEGER;

   M_TRAN_RECORD            TM_TRAN_RECORD;
   V_SMSALERTQ_ROW          SMSALERTQ%ROWTYPE;

   --INSERTING THE OUTGOING MESSAGES
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

   --SERVICE VALIDATION FOR THE PRODUCT
   FUNCTION CHECK_PROD_ALLOWED (V_SMS_SER_CD   IN VARCHAR2,
                                V_PROD_CODE    IN NUMBER)
      RETURN BOOLEAN
   AS
      W_DUMMY   NUMBER (1);
      V_AVL     BOOLEAN;
   BEGIN
      V_AVL := TRUE;

     <<READSMSSVCMASTPROD>>
      BEGIN
         SELECT DISTINCT 1
           INTO W_DUMMY
           FROM SMSSVCMASTPROD CC
          WHERE     CC.SMSMAST_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                AND CC.SMSMAST_CD = V_SMS_SER_CD
                AND CC.SMSMAST_PROD_CD = V_PROD_CODE;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            V_AVL := FALSE;
      END READSMSSVCMASTPROD;

      RETURN V_AVL;
   END CHECK_PROD_ALLOWED;

   --OUTGOING MESSAGE FORMATION
   PROCEDURE PROCESS_FORMAT_TRAN_MESSAGE (P_SERV_CODE       IN VARCHAR2,
                                          P_CURR_CODE       IN VARCHAR2,
                                          P_INST_ACNT       IN NUMBER,
                                          P_INST_AMT        IN NUMBER,
                                          P_INST_NUM        IN NUMBER,
                                          P_TRAN_BRN_CODE   IN NUMBER)
   IS
      FROMATED_ACCOUNT_NUMBER   VARCHAR2 (14);
   BEGIN
      FROMATED_ACCOUNT_NUMBER := '';

      BEGIN
         SELECT SMSSGMT_TEXT
           INTO W_TEXT_MESSAGE
           FROM SMSSVCSGMT
          WHERE     SMSSGMT_CD = P_SERV_CODE
                AND SMSSGMT_ENTITY_NUM = 1
                AND SMSSGMT_SL = 1
                AND SMSSGMT_TYPE = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            INSERT
              INTO SMSALERTPROCERROR (SMSALERTPROCERROR_DATE,
                                      SMSALERTPROCERROR_ERROR)
               VALUES (
                         SYSDATE,
                         'PKG_ALERTQ_MOBILE - Error in Reading Message structure');
      END;

      BEGIN
         IF (P_TRAN_BRN_CODE != 0)
         THEN
            W_BRANCH_CODE := P_TRAN_BRN_CODE;

            SELECT MBRN_NAME
              INTO W_BRANCH_NAME
              FROM MBRN
             WHERE MBRN_CODE = P_TRAN_BRN_CODE;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            INSERT
              INTO SMSALERTPROCERROR (SMSALERTPROCERROR_DATE,
                                      SMSALERTPROCERROR_ERROR)
               VALUES (
                         SYSDATE,
                         'PKG_ALERTQ_MOBILE - Error in Reading Branch Code');
      END;

      BEGIN
         SELECT INS_NAME_OF_BANK
           INTO W_BANK_NAME
           FROM INSTALL
          WHERE INS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            INSERT
              INTO SMSALERTPROCERROR (SMSALERTPROCERROR_DATE,
                                      SMSALERTPROCERROR_ERROR)
               VALUES (
                         SYSDATE,
                         'PKG_ALERTQ_MOBILE - Error in Reading Bank Name');
      END;

      IF (P_SERV_CODE = 'ICLGRTN' OR P_SERV_CODE = 'OCLGRTN')
      THEN
         FROMATED_ACCOUNT_NUMBER :=
               SUBSTR (FACNO (PKG_ENTITY.FN_GET_ENTITY_CODE, P_INST_ACNT),
                       0,
                       4)
            || '*****'
            || SUBSTR (FACNO (PKG_ENTITY.FN_GET_ENTITY_CODE, P_INST_ACNT),
                       10);
         W_TEXT_MESSAGE :=
            REPLACE (W_TEXT_MESSAGE, '$$ACNTNUM$$', FROMATED_ACCOUNT_NUMBER);
      ELSE
         FROMATED_ACCOUNT_NUMBER :=
               SUBSTR (
                  FACNO (PKG_ENTITY.FN_GET_ENTITY_CODE,
                         M_TRAN_RECORD (V_TR_COUNT).M_INTERNAL_ACNUM),
                  0,
                  4)
            || '*****'
            || SUBSTR (
                  FACNO (PKG_ENTITY.FN_GET_ENTITY_CODE,
                         M_TRAN_RECORD (V_TR_COUNT).M_INTERNAL_ACNUM),
                  10);

         W_TEXT_MESSAGE :=
            REPLACE (W_TEXT_MESSAGE, '$$ACNTNUM$$', FROMATED_ACCOUNT_NUMBER);
      END IF;

      IF (P_SERV_CODE = 'ICLGRTN' OR P_SERV_CODE = 'OCLGRTN')
      THEN
         W_TEXT_MESSAGE :=
            REPLACE (
               W_TEXT_MESSAGE,
               '$$TRANAMOUNT$$',
               SP_GETFORMAT (PKG_ENTITY.FN_GET_ENTITY_CODE,
                             P_CURR_CODE,
                             P_INST_AMT));
      ELSE
         W_TEXT_MESSAGE :=
            REPLACE (
               W_TEXT_MESSAGE,
               '$$TRANAMOUNT$$',
               TRIM (
                  SP_GETFORMAT (PKG_ENTITY.FN_GET_ENTITY_CODE,
                                M_TRAN_RECORD (V_TR_COUNT).M_CURR_CODE,
                                M_TRAN_RECORD (V_TR_COUNT).M_TRAN_AMOUNT)));
      END IF;

      IF (P_SERV_CODE = 'ICLGRTN' OR P_SERV_CODE = 'OCLGRTN')
      THEN
         NULL;
      ELSE
         W_TEXT_MESSAGE :=
            REPLACE (
               W_TEXT_MESSAGE,
               '$$TRANDATE$$',
               TO_CHAR (M_TRAN_RECORD (V_TR_COUNT).M_TRAN_DATE_OF_TRAN,
                        'DD-MON-YYYY'));
      END IF;

      W_TEXT_MESSAGE :=
         REPLACE (
            W_TEXT_MESSAGE,
            '$$TRANDATE_TIME$$',
            TO_CHAR (V_SMSALERTQ_ROW.SMSALERTQ_REQ_TIME,
                     'DD-MON-YYYY hh:mi AM'));

      IF (P_INST_NUM != 0)
      THEN
         W_TEXT_MESSAGE := REPLACE (W_TEXT_MESSAGE, '$$CHQNUM$$', P_INST_NUM);
      ELSE
         W_TEXT_MESSAGE :=
            REPLACE (W_TEXT_MESSAGE,
                     '$$CHQNUM$$',
                     M_TRAN_RECORD (V_TR_COUNT).M_TRAN_INSTR_CHQ_NUMBER);
      END IF;

      IF (P_INST_ACNT != 0)
      THEN
         PKG_AVLBAL_WRAPPER.SP_AVLBAL_WRAP (PKG_ENTITY.FN_GET_ENTITY_CODE,
                                            P_INST_ACNT,
                                            '0',
                                            '0',
                                            '0');
         W_TEXT_MESSAGE :=
            REPLACE (W_TEXT_MESSAGE,
                     '$$AC_AUTH_BAL$$',
                     PKG_AVLBAL_WRAPPER.P_AC_AUTH_BAL);
      END IF;

      W_TEXT_MESSAGE := REPLACE (W_TEXT_MESSAGE, '$$BRNNAME$$', W_BRANCH_NAME);
      W_TEXT_MESSAGE := REPLACE (W_TEXT_MESSAGE, '$$BANK$$', W_BANK_NAME);
      W_RESPONSE_MESSAGE := W_TEXT_MESSAGE;
   END PROCESS_FORMAT_TRAN_MESSAGE;

   -- CHECKING THE SERVICE CONDITIONS
   FUNCTION CHECK_FOR_SERVICE_CONDITION (P_TRAN_COND VARCHAR2)
      RETURN BOOLEAN
   IS
      -- INPUT V_PROC_SER_CODE
      W_MET_ALL_CONDITION    BOOLEAN;
      W_EACH_CONDITION_MET   BOOLEAN;
   BEGIN
      W_MET_ALL_CONDITION := FALSE;
      W_EACH_CONDITION_MET := FALSE;

      FOR IXX
         IN (SELECT *
               FROM SMSSVCCOND CC
              WHERE     CC.SMSCOND_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                    AND CC.SMSCOND_CD = V_PROC_SER_CODE
                    AND CC.SMSCOND_TRAN_CD = P_TRAN_COND)
      LOOP
         W_MET_ALL_CONDITION := TRUE;
         W_EACH_CONDITION_MET := TRUE;

         IF IXX.SMSCOND_TRAN_CATG <>
               M_TRAN_RECORD (V_TR_COUNT).M_TRAN_TYPE_OF_TRAN
         THEN
            W_EACH_CONDITION_MET := FALSE;
         END IF;

         IF W_EACH_CONDITION_MET = TRUE
         THEN
            IF     TRIM (IXX.SMSCOND_TRAN_CD) IS NOT NULL
               AND TRIM (IXX.SMSCOND_TRAN_CD) <>
                      M_TRAN_RECORD (V_TR_COUNT).M_TRAN_CODE
            THEN
               W_EACH_CONDITION_MET := FALSE;
            END IF;
         END IF;

         IF W_EACH_CONDITION_MET = TRUE
         THEN
            IF IXX.SMSCOND_TRAN_DB_CR_FLG <>
                  M_TRAN_RECORD (V_TR_COUNT).M_TRAN_DB_CR_FLG
            THEN
               W_EACH_CONDITION_MET := FALSE;
            END IF;
         END IF;

         IF W_EACH_CONDITION_MET = TRUE
         THEN
            IF NVL (IXX.SMSCOND_MIN_AMT_REQ, 0) = '1'
            THEN
               IF NVL (IXX.SMSCOND_MIN_AMT, 0) >
                     M_TRAN_RECORD (V_TR_COUNT).M_TRAN_AMOUNT
               THEN
                  W_EACH_CONDITION_MET := FALSE;
               END IF;
            END IF;
         END IF;

         IF W_EACH_CONDITION_MET = TRUE
         THEN
            IF NVL (IXX.SMSCOND_MAX_AMT_REQ, 0) = '1'
            THEN
               IF NVL (IXX.SMSCOND_MAX_AMT, 0) <
                     M_TRAN_RECORD (V_TR_COUNT).M_TRAN_AMOUNT
               THEN
                  W_EACH_CONDITION_MET := FALSE;
               END IF;
            END IF;
         END IF;

         IF W_EACH_CONDITION_MET = FALSE
         THEN
            W_MET_ALL_CONDITION := FALSE;
         END IF;
      END LOOP;

      RETURN W_MET_ALL_CONDITION;
   END CHECK_FOR_SERVICE_CONDITION;

   -- NORMAL TRANSACTIONS
   PROCEDURE CHECK_FOR_NORMAL_TRANSACTION
   IS
      TMP_ACCOUNT_NUMBER   NUMBER (14);
   BEGIN
      TMP_ACCOUNT_NUMBER := M_TRAN_RECORD (V_TR_COUNT).M_INTERNAL_ACNUM;

      ------------------------------ REGISTERED CUSTOMER -------------------------------------------
      FOR IDCHK
         IN (SELECT CM.SMSMAST_SVC_CD, CM.SMSMAST_CD, M.MOBILE_NUMBER
               FROM MOBILEREG M, SMSSVCMAST CM
              WHERE     M.ENTITY_NUM = CM.SMSMAST_ENTITY_NUM
                    AND M.INT_ACNUM = TMP_ACCOUNT_NUMBER
                    AND M.ACTIVE = 0
                    AND M.MOBILEREG_AUTH_ON IS NOT NULL
                    AND M.SERVICE1 = 1
                    AND M.SERVICE1_DEACTIVATED_ON IS NULL
                    AND M.SERVICE1 = CM.SERVICE_TYPE
                    AND CM.SMSMAST_SVC_CD = SERVICE_CODE
                    AND CM.SERVICE_STATUS = 0)
      LOOP
         IF CHECK_PROD_ALLOWED (IDCHK.SMSMAST_CD,
                                M_TRAN_RECORD (V_TR_COUNT).M_PROD_CODE) =
               TRUE
         THEN
            V_PROC_SER_CODE := IDCHK.SMSMAST_CD;
            V_CALL_CODE := '88';

            IF CHECK_FOR_SERVICE_CONDITION (
                  M_TRAN_RECORD (V_TR_COUNT).M_TRAN_CODE) = TRUE
            THEN
               W_INST_NUM := 0;
               W_CURY_CODE := '';
               W_INST_AMT := M_TRAN_RECORD (V_TR_COUNT).M_TRAN_AMOUNT;
               W_INST_ACNT := TMP_ACCOUNT_NUMBER;

               IF SUBSTR (IDCHK.MOBILE_NUMBER, 0, 2) = '01'
               THEN
                  W_MOBILE_WITH_CODE := V_CALL_CODE || IDCHK.MOBILE_NUMBER;
               ELSE
                  W_MOBILE_WITH_CODE := IDCHK.MOBILE_NUMBER;
               END IF;

               PROCESS_FORMAT_TRAN_MESSAGE (
                  V_PROC_SER_CODE,
                  W_CURY_CODE,
                  W_INST_ACNT,
                  W_INST_AMT,
                  W_INST_NUM,
                  M_TRAN_RECORD (V_TR_COUNT).M_TRAN_ACING_BRN_CODE);

               BEGIN
                 <<MOBSMSOUTQ>>
                  INSERT_MOBSMSOUTQ (
                     M_TRAN_RECORD (V_TR_COUNT).M_TRAN_ACING_BRN_CODE,
                     V_PROC_SER_CODE,
                     W_MOBILE_WITH_CODE,
                     W_RESPONSE_MESSAGE,
                     M_TRAN_RECORD (V_TR_COUNT).M_INTERNAL_ACNUM);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     INSERT INTO SMSALERTPROCERROR
                             VALUES (
                                       SYSDATE,
                                          'Error in MOBSMSOUTQ'
                                       || W_RESPONSE_MESSAGE);
               END mobsmsoutq;
            END IF;
         END IF;
      END LOOP;
   END CHECK_FOR_NORMAL_TRANSACTION;

   -- ATM TRANSACTIONS
   PROCEDURE CHECK_FOR_ATM_TRANSACTION
   IS
      TMP_ACCOUNT_NUMBER   NUMBER (14);
   BEGIN
      TMP_ACCOUNT_NUMBER := M_TRAN_RECORD (V_TR_COUNT).M_INTERNAL_ACNUM;

      --------- REGISTERD CUSTOMER ------------------------------------
      FOR IDCHK
         IN (SELECT CM.SMSMAST_SVC_CD, CM.SMSMAST_CD, M.MOBILE_NUMBER
               FROM MOBILEREG M, SMSSVCMAST CM
              WHERE     M.ENTITY_NUM = CM.SMSMAST_ENTITY_NUM
                    AND M.INT_ACNUM = TMP_ACCOUNT_NUMBER
                    AND M.ACTIVE = 0
                    AND M.MOBILEREG_AUTH_ON IS NOT NULL
                    AND M.SERVICE1 = 1
                    AND M.SERVICE1_DEACTIVATED_ON IS NULL
                    AND M.SERVICE1 = CM.SERVICE_TYPE
                    AND CM.SMSMAST_SVC_CD = SERVICE_CODE
                    AND CM.SERVICE_STATUS = 0)
      LOOP
         IF CHECK_PROD_ALLOWED (IDCHK.SMSMAST_CD,
                                M_TRAN_RECORD (V_TR_COUNT).M_PROD_CODE) =
               TRUE
         THEN
            V_PROC_SER_CODE := IDCHK.SMSMAST_CD;
            V_CALL_CODE := '88';
            W_INST_NUM := 0;
            W_CURY_CODE := '';
            W_INST_AMT := M_TRAN_RECORD (V_TR_COUNT).M_TRAN_AMOUNT;
            W_INST_ACNT := TMP_ACCOUNT_NUMBER;
            PROCESS_FORMAT_TRAN_MESSAGE (
               V_PROC_SER_CODE,
               W_CURY_CODE,
               W_INST_ACNT,
               W_INST_AMT,
               W_INST_NUM,
               M_TRAN_RECORD (V_TR_COUNT).M_TRAN_ACING_BRN_CODE);

            BEGIN
              <<MOBSMSOUTQ>>
               INSERT_MOBSMSOUTQ (
                  M_TRAN_RECORD (V_TR_COUNT).M_TRAN_ACING_BRN_CODE,
                  V_PROC_SER_CODE,
                  V_CALL_CODE || IDCHK.MOBILE_NUMBER,
                  W_RESPONSE_MESSAGE,
                  M_TRAN_RECORD (V_TR_COUNT).M_INTERNAL_ACNUM);
            EXCEPTION
               WHEN OTHERS
               THEN
                  INSERT INTO SMSALERTPROCERROR
                          VALUES (
                                    SYSDATE,
                                       'Error in MOBSMSOUTQ FOR ATM'
                                    || W_RESPONSE_MESSAGE);
            END mobsmsoutq;
         END IF;
      END LOOP;
   END CHECK_FOR_ATM_TRANSACTION;

   PROCEDURE SP_INSERT_MOBILEREG
   IS
      V_MOBILE_NUMBER        VARCHAR2 (15);
      V_CLIENT_CODE          NUMBER (12);
      TMP_ACCOUNT_NUMBER     NUMBER (14);
      V_ACNT_SMS_OPERATION   CHAR (1);
      V_ACNT_PROD_CODE       NUMBER (4);
      V_COUNT_ROW            NUMBER (4);
   BEGIN
      V_CLIENT_CODE := 0;
      V_ACNT_SMS_OPERATION := '0';
      V_ACNT_PROD_CODE := 0;
      V_COUNT_ROW := 0;
      TMP_ACCOUNT_NUMBER := TO_NUMBER (V_SMSALERTQ_ROW.SMSALERTQ_SRC_KEY);

      -- Account Mobile Auto Registration--
      BEGIN
         SELECT A.ACNTS_CLIENT_NUM, A.ACNTS_PROD_CODE, A.ACNTS_SMS_OPERN
           INTO V_CLIENT_CODE, V_ACNT_PROD_CODE, V_ACNT_SMS_OPERATION
           FROM ACNTS A
          WHERE     A.ACNTS_ENTITY_NUM = V_SMSALERTQ_ROW.SMSALERTQ_ENTITY_NUM
                AND A.ACNTS_INTERNAL_ACNUM = TMP_ACCOUNT_NUMBER;

         IF V_ACNT_SMS_OPERATION = '1'
         THEN
            SELECT COUNT (*)
              INTO V_COUNT_ROW
              FROM SMSSVCMAST CM
                   INNER JOIN SMSSVCMASTPROD PR
                      ON (    CM.SMSMAST_ENTITY_NUM = PR.SMSMAST_ENTITY_NUM
                          AND CM.SMSMAST_CD = PR.SMSMAST_CD)
             WHERE     CM.SMSMAST_SVC_CD IN ('TRFCR',
                                             'TRFDB',
                                             'CASHCR',
                                             'CASHDB',
                                             'CLGCR',
                                             'CLGDB')
                   AND PR.SMSMAST_PROD_CD = V_ACNT_PROD_CODE
                   AND CM.SMSMAST_AUTH_BY IS NOT NULL
                   AND CM.SMSMAST_SVC_CLOSE_BY IS NULL
                   AND CM.SERVICE_STATUS = '0';

            IF V_COUNT_ROW >= 1
            THEN
               V_MOBILE_NUMBER := GET_MOBILE_NUM (V_CLIENT_CODE, '+');

              <<INSERTMOBILEREG>>
               BEGIN
                  INSERT INTO MOBILEREG (ENTITY_NUM,
                                         INT_ACNUM,
                                         MOBILE_NUMBER,
                                         CLIENT_NUM,
                                         BRANCH_CODE,
                                         NUMBER_TYPE,
                                         CBD,
                                         SERVICE1,
                                         SERVICE1_ACTIVATED_ON,
                                         SERVICE2,
                                         ACTIVE,
                                         ENTD_BY,
                                         ENTD_ON,
                                         MOBILEREG_AUTH_BY,
                                         MOBILEREG_AUTH_ON)
                          VALUES (
                                    V_SMSALERTQ_ROW.SMSALERTQ_ENTITY_NUM,
                                    TMP_ACCOUNT_NUMBER,
                                    V_MOBILE_NUMBER,
                                    V_CLIENT_CODE,
                                    V_SMSALERTQ_ROW.SMSALERTQ_BRN_CODE,
                                    'P',
                                    TO_DATE (
                                       V_SMSALERTQ_ROW.SMSALERTQ_DATE_OF_TRAN,
                                       'DD-MM-YYYY'),
                                    1,
                                    TO_DATE (
                                       V_SMSALERTQ_ROW.SMSALERTQ_DATE_OF_TRAN,
                                       'DD-MM-YYYY'),
                                    0,
                                    1,
                                    'INTELECT',
                                    SYSDATE,
                                    'INTELECT',
                                    SYSDATE);

                  COMMIT;
               END INSERTMOBILEREG;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            INSERT
              INTO SMSALERTPROCERROR (SMSALERTPROCERROR_DATE,
                                      SMSALERTPROCERROR_ERROR)
               VALUES (
                         SYSDATE,
                            'Error in Inserting data in MOBILEREG Table for Account '
                         || FACNO (PKG_ENTITY.FN_GET_ENTITY_CODE,
                                   TMP_ACCOUNT_NUMBER));
      END;
   END SP_INSERT_MOBILEREG;

   --ACCOUNT TYPE IDENTIFICATION
   PROCEDURE IDENTIFY_ACCOUNT_TYPE
   IS
      TMP_ACNT_NUMBER   NUMBER (14);
   BEGIN
      TMP_ACNT_NUMBER := TO_NUMBER (V_SMSALERTQ_ROW.SMSALERTQ_SRC_KEY);

     <<GET_ACNT_PRODUCT_TYPE>>
      BEGIN
         SELECT A.ACNTS_PROD_CODE, P.PRODUCT_FOR_LOANS
           INTO W_PRODUCT_CODE, W_LOAN_PRODUCT
           FROM ACNTS A, PRODUCTS P
          WHERE     A.ACNTS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                AND A.ACNTS_INTERNAL_ACNUM = TMP_ACNT_NUMBER
                AND A.ACNTS_PROD_CODE = P.PRODUCT_CODE;

         --Check for LAD Product and Loan Guarantor--
         BEGIN
            IF W_LOAN_PRODUCT = '1'
            THEN
               SELECT L.LNPRD_DEPOSIT_LOAN, L.LNPRD_GUARANTOR_REQD
                 INTO W_LAD_PRODUCT, W_GUARANTOR_REQ
                 FROM LNPRODPM L
                WHERE L.LNPRD_PROD_CODE = W_PRODUCT_CODE;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               W_LAD_PRODUCT := '0';
               W_GUARANTOR_REQ := '0';
         END;
      EXCEPTION
         WHEN OTHERS
         THEN
            W_LOAN_PRODUCT := '0';
      END GET_ACNT_PRODUCT_TYPE;

      IF W_LOAN_PRODUCT = '1' AND W_LAD_PRODUCT = '1'
      THEN
         W_ACCOUNT_TYPE := '2';                                 -- LAD Account
      ELSIF W_LOAN_PRODUCT = '1' AND W_LAD_PRODUCT = '0'
      THEN
         W_ACCOUNT_TYPE := '3';                                -- LOAN Account
      ELSE
         W_ACCOUNT_TYPE := '1';                              -- Normal Account
      END IF;
   END IDENTIFY_ACCOUNT_TYPE;

   PROCEDURE PROCESS_ACNT_NOTIFICATION_MSG (
      P_PROD_CODE             IN NUMBER,
      P_ACNT_NUM              IN NUMBER,
      P_TRAN_BRN_CODE         IN NUMBER,
      P_MOBILE_NUMBER         IN VARCHAR2,
      P_ACNT_HOLDER_NAME      IN VARCHAR2,
      P_NOTIFICATION_FLAG     IN VARCHAR2,
      P_SMSALERTQ_SRC_TABLE   IN VARCHAR2)
   IS
      --1=>Normal,2=>LAD Deposit,3=>Loan Guarantor
      V_SMSMASTER_SERVICE_CODE   VARCHAR2 (8);
      FROMATED_ACCOUNT_NUMBER    VARCHAR2 (14);
   BEGIN
      V_SMSMASTER_SERVICE_CODE := '';
      FROMATED_ACCOUNT_NUMBER := '';
      W_TEXT_MESSAGE := '';

      IF P_NOTIFICATION_FLAG = '1'
      THEN
         V_SMSMASTER_SERVICE_CODE := 'AOP';
      ELSIF P_NOTIFICATION_FLAG = '2'
      THEN
         V_SMSMASTER_SERVICE_CODE := 'AOPDP';
      ELSIF P_NOTIFICATION_FLAG = '3'
      THEN
         V_SMSMASTER_SERVICE_CODE := 'AOPGR';
      END IF;


      IF P_SMSALERTQ_SRC_TABLE IN ('DORMNT', 'MAJOR')
      THEN
         V_SMSMASTER_SERVICE_CODE := P_SMSALERTQ_SRC_TABLE;
      END IF;

      --Generate Notification Message--
      BEGIN
         SELECT MS.SMSSGMT_TEXT
           INTO W_TEXT_MESSAGE
           FROM SMSSVCSGMT MS
          WHERE     MS.SMSSGMT_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                AND UPPER (TRIM (MS.SMSSGMT_CD)) IN (SELECT CM.SMSMAST_CD
                                                       FROM SMSSVCMAST CM
                                                            INNER JOIN
                                                            SMSSVCMASTPROD PR
                                                               ON (    CM.SMSMAST_ENTITY_NUM =
                                                                          PR.SMSMAST_ENTITY_NUM
                                                                   AND CM.SMSMAST_CD =
                                                                          PR.SMSMAST_CD)
                                                      WHERE     CM.SMSMAST_SVC_CD =
                                                                   V_SMSMASTER_SERVICE_CODE
                                                            AND PR.SMSMAST_PROD_CD =
                                                                   P_PROD_CODE
                                                            AND CM.SMSMAST_AUTH_BY
                                                                   IS NOT NULL
                                                            AND CM.SMSMAST_SVC_CLOSE_BY
                                                                   IS NULL
                                                            AND CM.SERVICE_STATUS =
                                                                   '0'
                                                            AND CM.SMSMAST_ENTD_ON =
                                                                   (SELECT MAX (
                                                                              S.SMSMAST_ENTD_ON)
                                                                      FROM SMSSVCMAST S
                                                                     WHERE     S.SMSMAST_ENTITY_NUM =
                                                                                  PKG_ENTITY.FN_GET_ENTITY_CODE
                                                                           AND S.SMSMAST_SVC_CD =
                                                                                  V_SMSMASTER_SERVICE_CODE
                                                                           AND S.SMSMAST_AUTH_BY
                                                                                  IS NOT NULL
                                                                           AND S.SMSMAST_SVC_CLOSE_ON
                                                                                  IS NULL));
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN;
      END;

      BEGIN
         IF (P_TRAN_BRN_CODE != 0)
         THEN
            W_BRANCH_CODE := P_TRAN_BRN_CODE;

            SELECT MBRN_NAME
              INTO W_BRANCH_NAME
              FROM MBRN
             WHERE MBRN_CODE = P_TRAN_BRN_CODE;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            INSERT
              INTO SMSALERTPROCERROR (SMSALERTPROCERROR_DATE,
                                      SMSALERTPROCERROR_ERROR)
               VALUES (
                         SYSDATE,
                         'PKG_ALERTQ_MOBILE - Error in Reading Branch Code');
      END;

      BEGIN
         SELECT INS_NAME_OF_BANK
           INTO W_BANK_NAME
           FROM INSTALL
          WHERE INS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            INSERT
              INTO SMSALERTPROCERROR (SMSALERTPROCERROR_DATE,
                                      SMSALERTPROCERROR_ERROR)
               VALUES (
                         SYSDATE,
                         'PKG_ALERTQ_MOBILE - Error in Reading Bank Name');
      END;

      BEGIN
         IF V_SMSMASTER_SERVICE_CODE IN ('AOPDP',
                                         'AOPGR',
                                         'DORMNT',
                                         'MAJOR')
         THEN
            FROMATED_ACCOUNT_NUMBER :=
                  SUBSTR (FACNO (PKG_ENTITY.FN_GET_ENTITY_CODE, P_ACNT_NUM),
                          0,
                          4)
               || '*****'
               || SUBSTR (FACNO (PKG_ENTITY.FN_GET_ENTITY_CODE, P_ACNT_NUM),
                          10);
            W_TEXT_MESSAGE :=
               REPLACE (W_TEXT_MESSAGE,
                        '$$ACNTNUM$$',
                        FROMATED_ACCOUNT_NUMBER);
         ELSE
            W_TEXT_MESSAGE :=
               REPLACE (W_TEXT_MESSAGE,
                        '$$ACNTNUM$$',
                        FACNO (PKG_ENTITY.FN_GET_ENTITY_CODE, P_ACNT_NUM));
         END IF;

         W_TEXT_MESSAGE :=
            REPLACE (W_TEXT_MESSAGE, '$$BRANH_CODE$$', P_TRAN_BRN_CODE);
         W_TEXT_MESSAGE :=
            REPLACE (W_TEXT_MESSAGE, '$$BRNNAME$$', W_BRANCH_NAME);
         W_TEXT_MESSAGE :=
            REPLACE (
               W_TEXT_MESSAGE,
               '$$TRANDATE$$',
               TO_CHAR (V_SMSALERTQ_ROW.SMSALERTQ_DATE_OF_TRAN,
                        'DD-MON-YYYY'));
         W_TEXT_MESSAGE :=
            REPLACE (
               W_TEXT_MESSAGE,
               '$$TRANDATE_TIME$$',
               TO_CHAR (V_SMSALERTQ_ROW.SMSALERTQ_REQ_TIME,
                        'DD-MON-YYYY hh:mi AM'));
         W_TEXT_MESSAGE := REPLACE (W_TEXT_MESSAGE, '$$BANK$$', W_BANK_NAME);
         W_TEXT_MESSAGE :=
            REPLACE (W_TEXT_MESSAGE,
                     '$$ACNTHOLDERNAME$$',
                     P_ACNT_HOLDER_NAME);
      END;

      W_RESPONSE_MESSAGE := W_TEXT_MESSAGE;

      IF ( (W_RESPONSE_MESSAGE IS NOT NULL) AND (P_MOBILE_NUMBER IS NOT NULL))
      THEN                    --If Product is not registered in SMSSVCMASTPROD
         -- table then, W_RESPONSE_MESSAGE will be null and won't generate SMS.

         BEGIN
            V_CALL_CODE := '88';
            W_MOBILE_WITH_CODE := V_CALL_CODE || P_MOBILE_NUMBER;

            SELECT S.SMSMAST_CD
              INTO V_PROC_SER_CODE
              FROM SMSSVCMAST S
             WHERE     S.SMSMAST_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                   AND S.SMSMAST_SVC_CD = V_SMSMASTER_SERVICE_CODE
                   AND S.SMSMAST_ENTD_ON =
                          (SELECT MAX (SS.SMSMAST_ENTD_ON)
                             FROM SMSSVCMAST SS
                            WHERE     SS.SMSMAST_ENTITY_NUM =
                                         PKG_ENTITY.FN_GET_ENTITY_CODE
                                  AND SS.SMSMAST_SVC_CD =
                                         V_SMSMASTER_SERVICE_CODE);

            INSERT_MOBSMSOUTQ (P_TRAN_BRN_CODE,
                               V_PROC_SER_CODE,
                               W_MOBILE_WITH_CODE,
                               W_RESPONSE_MESSAGE,
                               P_ACNT_NUM);
         EXCEPTION
            WHEN OTHERS
            THEN
               INSERT INTO SMSALERTPROCERROR
                       VALUES (
                                 SYSDATE,
                                    'Error in Inserting MOBSMSOUTQ'
                                 || W_RESPONSE_MESSAGE);
         END;
      END IF;
   END PROCESS_ACNT_NOTIFICATION_MSG;

   PROCEDURE CHECK_FOR_ACCOUNT_NOTIFICATION
   IS
      TMP_ACCOUNT_NUMBER   NUMBER (14);
      V_CLIENT_CODE        NUMBER (12);
      V_MOBILE_NUM         VARCHAR2 (15);
      V_ACNT_HOLDER_NAME   VARCHAR2 (50);
   BEGIN
      W_ACCOUNT_TYPE := '0';                        --1=>NORMAL,2=>LAD,3=>LOAN
      V_ACNT_HOLDER_NAME := '';
      V_CLIENT_CODE := 0;
      TMP_ACCOUNT_NUMBER := TO_NUMBER (V_SMSALERTQ_ROW.SMSALERTQ_SRC_KEY);
      IDENTIFY_ACCOUNT_TYPE;

      BEGIN
         W_INST_ACNT := TMP_ACCOUNT_NUMBER;

         -- Deposit/Loan Account Notification
         BEGIN
            SELECT A.ACNTS_CLIENT_NUM, A.ACNTS_AC_NAME1
              INTO V_CLIENT_CODE, V_ACNT_HOLDER_NAME
              FROM ACNTS A
             WHERE     A.ACNTS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                   AND A.ACNTS_INTERNAL_ACNUM = TMP_ACCOUNT_NUMBER;

            V_MOBILE_NUM :=
               SUBSTR (GET_MOBILE_NUM (V_CLIENT_CODE, '+'), 1, 11); -- For handling multiple
            --mobile num returned by func in form num1+num2, SUBSTR is used to fetch the first number only.
            PROCESS_ACNT_NOTIFICATION_MSG (
               W_PRODUCT_CODE,
               W_INST_ACNT,
               V_SMSALERTQ_ROW.SMSALERTQ_BRN_CODE,
               V_MOBILE_NUM,
               V_ACNT_HOLDER_NAME,
               1,
               V_SMSALERTQ_ROW.SMSALERTQ_SRC_TABLE);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               INSERT
                 INTO SMSALERTPROCERROR (SMSALERTPROCERROR_DATE,
                                         SMSALERTPROCERROR_ERROR)
                  VALUES (
                            SYSDATE,
                            'Error in Check for Deposit/Loan Account Notification');
         END;

         --Loan Account's Guarantor Notification
         IF W_ACCOUNT_TYPE = '3'
         THEN
            IF W_GUARANTOR_REQ = '1'
            THEN
               SELECT L.LNGUAR_GUAR_CLIENT_CODE
                 BULK COLLECT INTO LOAN_GUARANTOR_CLIENTS
                 FROM LNACGUAR L
                WHERE     L.LNGUAR_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                      AND L.LNGUAR_INTERNAL_ACNUM = TMP_ACCOUNT_NUMBER;

               IF LOAN_GUARANTOR_CLIENTS.COUNT > 0
               THEN
                  FOR IDX IN 1 .. LOAN_GUARANTOR_CLIENTS.COUNT
                  LOOP
                     V_CLIENT_CODE := LOAN_GUARANTOR_CLIENTS (IDX);
                     V_MOBILE_NUM :=
                        SUBSTR (GET_MOBILE_NUM (V_CLIENT_CODE, '+'), 1, 11);

                     PROCESS_ACNT_NOTIFICATION_MSG (
                        W_PRODUCT_CODE,
                        W_INST_ACNT,
                        V_SMSALERTQ_ROW.SMSALERTQ_BRN_CODE,
                        V_MOBILE_NUM,
                        V_ACNT_HOLDER_NAME,
                        3,
                        V_SMSALERTQ_ROW.SMSALERTQ_SRC_TABLE);
                  END LOOP;

                  LOAN_GUARANTOR_CLIENTS.DELETE;
               END IF;
            END IF;
         --LAD's Depositor Acnt Notification
         ELSIF W_ACCOUNT_TYPE = '2'
         THEN
            SELECT L.LADDTL_DEP_ACNT_NUM
              BULK COLLECT INTO LAD_DEPOSITOR_ACNTS
              FROM LADACNTDTL L
             WHERE     L.LADDTL_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                   AND L.LADDTL_INTERNAL_ACNUM = TMP_ACCOUNT_NUMBER;

            IF LAD_DEPOSITOR_ACNTS.COUNT > 0
            THEN
               FOR IDX IN 1 .. LAD_DEPOSITOR_ACNTS.COUNT
               LOOP
                  SELECT A.ACNTS_CLIENT_NUM
                    INTO V_CLIENT_CODE
                    FROM ACNTS A
                   WHERE     A.ACNTS_ENTITY_NUM =
                                PKG_ENTITY.FN_GET_ENTITY_CODE
                         AND A.ACNTS_INTERNAL_ACNUM =
                                LAD_DEPOSITOR_ACNTS (IDX);

                  V_MOBILE_NUM :=
                     SUBSTR (GET_MOBILE_NUM (V_CLIENT_CODE, '+'), 1, 11);
                  PROCESS_ACNT_NOTIFICATION_MSG (
                     W_PRODUCT_CODE,
                     W_INST_ACNT,
                     V_SMSALERTQ_ROW.SMSALERTQ_BRN_CODE,
                     V_MOBILE_NUM,
                     V_ACNT_HOLDER_NAME,
                     2,
                     V_SMSALERTQ_ROW.SMSALERTQ_SRC_TABLE);
               END LOOP;

               LAD_DEPOSITOR_ACNTS.DELETE;
            END IF;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            INSERT
              INTO SMSALERTPROCERROR (SMSALERTPROCERROR_DATE,
                                      SMSALERTPROCERROR_ERROR)
               VALUES (
                         SYSDATE,
                         'PKG_ALERTQ_MOBILE - Error in Check for Account Notification');
      END;
   END CHECK_FOR_ACCOUNT_NOTIFICATION;

   --MESSAGE PROCESSING FOR ALL TRANSACTIONS
   PROCEDURE PROCESS_FOR_TRANSACTION
   IS
   BEGIN
     <<READTRAN>>
      BEGIN
         IF W_PREV_DATE <> V_SMSALERTQ_ROW.SMSALERTQ_DATE_OF_TRAN
         THEN
            W_FIN_YEAR :=
               SP_GETFINYEAR (PKG_ENTITY.FN_GET_ENTITY_CODE,
                              V_SMSALERTQ_ROW.SMSALERTQ_DATE_OF_TRAN);
         END IF;

         W_PREV_DATE := V_SMSALERTQ_ROW.SMSALERTQ_DATE_OF_TRAN;
         W_SQL :=
               'SELECT TT.TRAN_INTERNAL_ACNUM, TT.TRAN_CURR_CODE, TT.TRAN_BRN_CODE, TT.TRAN_PROD_CODE,TT.TRAN_AMOUNT,TT.TRAN_DATE_OF_TRAN, TT.TRAN_DB_CR_FLG,TT.TRAN_TYPE_OF_TRAN,
                TT.TRAN_CODE, TT.TRAN_INSTR_CHQ_NUMBER FROM TRAN'
            || W_FIN_YEAR
            || '  TT WHERE TT.TRAN_ENTITY_NUM = '
            || PKG_ENTITY.FN_GET_ENTITY_CODE
            || ' AND TT.TRAN_BRN_CODE = '
            || V_SMSALERTQ_ROW.SMSALERTQ_BRN_CODE
            || ' AND TT.TRAN_DATE_OF_TRAN = '
            || CHR (39)
            || V_SMSALERTQ_ROW.SMSALERTQ_DATE_OF_TRAN
            || CHR (39)
            || ' AND TT.TRAN_BATCH_NUMBER = '
            || V_SMSALERTQ_ROW.SMSALERTQ_BATCH_NUMBER
            || ' AND TT.TRAN_INTERNAL_ACNUM <> 0  AND TT.TRAN_AUTH_ON IS NOT NULL';

         EXECUTE IMMEDIATE W_SQL BULK COLLECT INTO M_TRAN_RECORD;

         IF M_TRAN_RECORD.COUNT > 0
         THEN
            FOR IDXX IN 1 .. M_TRAN_RECORD.COUNT
            LOOP
               V_TR_COUNT := IDXX;

               -------------#START#----------
               SERVICE_CODE := '';

               IF (M_TRAN_RECORD (V_TR_COUNT).M_TRAN_TYPE_OF_TRAN = '1')
               THEN
                  IF (M_TRAN_RECORD (V_TR_COUNT).M_TRAN_DB_CR_FLG = 'C')
                  THEN
                     SERVICE_CODE := 'TRFCR';
                  ELSE
                     SERVICE_CODE := 'TRFDB';
                  END IF;
               ELSIF (M_TRAN_RECORD (V_TR_COUNT).M_TRAN_TYPE_OF_TRAN = '2')
               THEN
                  IF (M_TRAN_RECORD (V_TR_COUNT).M_TRAN_DB_CR_FLG = 'C')
                  THEN
                     SERVICE_CODE := 'CLGCR';
                  ELSE
                     SERVICE_CODE := 'CLGDB';
                  END IF;
               ELSIF (M_TRAN_RECORD (V_TR_COUNT).M_TRAN_TYPE_OF_TRAN = '3')
               THEN
                  IF (M_TRAN_RECORD (V_TR_COUNT).M_TRAN_DB_CR_FLG = 'C')
                  THEN
                     SERVICE_CODE := 'CASHCR';
                  ELSE
                     SERVICE_CODE := 'CASHDB';
                  END IF;
               END IF;

               -----#END#----------
               IF V_SMSALERTQ_ROW.SMSALERTQ_SRC_TABLE = 'ATM'
               THEN
                  IF (M_TRAN_RECORD (V_TR_COUNT).M_TRAN_DB_CR_FLG = 'C')
                  THEN
                     SERVICE_CODE := 'ATMREV';
                  ELSE
                     SERVICE_CODE := 'ATMTRF';
                  END IF;

                  CHECK_FOR_ATM_TRANSACTION;
               ELSE
                  CHECK_FOR_NORMAL_TRANSACTION;
               END IF;
            END LOOP;

            M_TRAN_RECORD.DELETE;
         END IF;
      END READTRAN;
   END PROCESS_FOR_TRANSACTION;

   --TRANSACTION IDENTIFICATION
   PROCEDURE PROCESS_EACH_MSG_TYPE
   IS
      V_CHARGE_FLAG   CHAR (1) DEFAULT NULL;
   BEGIN
      IF V_SMSALERTQ_ROW.SMSALERTQ_SRC_TABLE IN ('EXCISE',
                                                 'Charge',
                                                 'ATM_CHG_REC',
                                                 'SMSCHARGE',
                                                 'SBCAIA')
      THEN
         BEGIN
            SELECT CHARGE_FLAG
              INTO V_CHARGE_FLAG
              FROM CONSOLIDATED_SMS_CHARGE
             WHERE CHARGE_CODE = V_SMSALERTQ_ROW.SMSALERTQ_SRC_TABLE;
         EXCEPTION
            WHEN OTHERS
            THEN
               V_CHARGE_FLAG := '0';
         END;

         IF V_CHARGE_FLAG = '0' AND V_SMSALERTQ_ROW.SMSALERTQ_TYPE = 'TR'
         THEN
            PROCESS_FOR_TRANSACTION;
         ELSIF V_CHARGE_FLAG = '0' AND V_SMSALERTQ_ROW.SMSALERTQ_TYPE = 'AC'
         THEN
            CHECK_FOR_ACCOUNT_NOTIFICATION;
         END IF;
      ELSE
         IF V_SMSALERTQ_ROW.SMSALERTQ_TYPE = 'TR'
         THEN
            PROCESS_FOR_TRANSACTION;
         ELSIF V_SMSALERTQ_ROW.SMSALERTQ_TYPE = 'AC'
         THEN
            CHECK_FOR_ACCOUNT_NOTIFICATION;
         --SP_INSERT_MOBILEREG;
         END IF;
      END IF;
   END PROCESS_EACH_MSG_TYPE;

   --FETCH TRANSACTIONS FROM SMSALEERTQ TABLE
   PROCEDURE SP_MOBILE_ALERTQ
   IS
      W_DUMMY_CODE   NUMBER (4);
   BEGIN
      W_PREV_DATE := NULL;

      SELECT INS_OUR_BANK_CODE INTO BANK_CODE FROM install;

      FOR IDX
         IN (SELECT /*+ INDEX_ASC( C SMSALERTQ_NEXT) */
                    *
               FROM SMSALERTQ C
              WHERE C.SMSALERTQ_REQ_TIME > '13-MAR-2017' AND ROWNUM < 10000)
      LOOP
        <<PROCIND_RECORD>>
         SELECT INS.INS_ENTITY_NUM
           INTO W_DUMMY_CODE
           FROM INSTALL INS;

         BEGIN
            W_PREV_DATE := '13-MAR-2017';
            PKG_ENTITY.SP_SET_ENTITY_CODE (IDX.SMSALERTQ_ENTITY_NUM);

            V_SMSALERTQ_ROW := IDX;
            PROCESS_EACH_MSG_TYPE;

            DELETE FROM SMSALERTQ CC
                  WHERE     CC.SMSALERTQ_ENTITY_NUM =
                               IDX.SMSALERTQ_ENTITY_NUM
                        AND CC.SMSALERTQ_TYPE = IDX.SMSALERTQ_TYPE
                        AND CC.SMSALERTQ_BRN_CODE = IDX.SMSALERTQ_BRN_CODE
                        AND CC.SMSALERTQ_DATE_OF_TRAN =
                               IDX.SMSALERTQ_DATE_OF_TRAN
                        AND CC.SMSALERTQ_BATCH_NUMBER =
                               IDX.SMSALERTQ_BATCH_NUMBER
                        AND CC.SMSALERTQ_BATCH_SL_NUM =
                               IDX.SMSALERTQ_BATCH_SL_NUM
                        AND CC.SMSALERTQ_SRC_TABLE = IDX.SMSALERTQ_SRC_TABLE
                        AND CC.SMSALERTQ_SRC_KEY = IDX.SMSALERTQ_SRC_KEY;

            COMMIT;
         EXCEPTION
            WHEN OTHERS
            THEN
               W_ERR_MSG := SUBSTR ( (SQLCODE || ' ' || SQLERRM), 1, 200);

               INSERT
                 INTO SMSALERTPROCERROR (SMSALERTPROCERROR_DATE,
                                         SMSALERTPROCERROR_ERROR)
               VALUES (SYSDATE, 'PKG_ALERTQ_MOBILE - ' || W_ERR_MSG);
         END PROCIND_RECORD;
      END LOOP;
   END SP_MOBILE_ALERTQ;
END PKG_ALERTQ_MOBILE;
/
